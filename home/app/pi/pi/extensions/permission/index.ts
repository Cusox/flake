/**
 * Permission Extension
 *
 * Controls tool execution via settings files:
 *   ~/<agent-dir>/permission.settings.json             (global)
 *   <repo-root>/.agents/permission.settings.json       (project, committed)
 *   <repo-root>/.agents/permission.settings.local.json (project, gitignored)
 *
 * Schema:
 * {
 *   "defaultMode": "ask" | "allow" | "deny",
 *   "allow": ["toolPattern", "tool(argPattern)", ...],
 *   "deny":  ["toolPattern", "tool(argPattern)", ...],
 *   "ask":   ["toolPattern", "tool(argPattern)", ...]
 * }
 *
 * Trusted local skills (global + project) may also contribute runtime allow rules
 * via SKILL frontmatter: allowed_tools / allowed-tools.
 *
 * Rule format:
 *   "read"                — blanket match on tool name
 *   "mcp__playwright__*"  — glob match on tool name
 *   "bash(git *)"         — match tool "bash" where command matches "git *"
 *   "edit(/tmp/*)"        — match tool "edit" where path matches "/tmp/*"
 *
 * Evaluation order: deny > ask > allow > defaultMode (default: "ask")
 *
 * Argument matching depends on the tool:
 *   bash  — matched against command string
 *   edit/write/read — matched against file path
 *   grep/find/ls — matched against path argument
 */

import { spawnSync } from "node:child_process"
import * as fs from "node:fs"
import * as path from "node:path"
import { tmpdir } from "node:os"

import {
    parseFrontmatter,
    type ExtensionAPI,
    type ExtensionContext,
} from "@mariozechner/pi-coding-agent"

import * as project from "../__lib/project.js"

const EXTENSION = "permission"

type Mode = "allow" | "ask" | "deny"

interface PermissionSettings {
    defaultMode?: Mode
    allow?: string[]
    deny?: string[]
    ask?: string[]
    keybindings?: {
        autoAcceptEdits?: string
    }
}

interface ParsedRule {
    toolPattern: string
    argPattern?: string
}

interface SkillCommandInfo {
    name: string
    source: "skill"
    location: "user" | "project"
    path: string
}

interface SkillAllowSource {
    skill: string
    location: string
    path: string
    rules: string[]
}

interface DerivedSkillAllowState {
    cacheKey: string
    rules: string[]
    sources: SkillAllowSource[]
}

interface ReplaceEdit {
    oldText: string
    newText: string
}

interface PreparedEditInput {
    path: string
    edits: ReplaceEdit[]
}

interface WriteToolInput {
    path: string
    content: string
}

interface FileReviewState {
    absolutePath: string
    displayPath: string
    currentContent: string
    proposedContent: string
    existed: boolean
}

interface ReviewDecision {
    reviewer: string
    action: "reject" | "keep-existing" | "apply"
    finalContent?: string
    modified: boolean
}

interface ReviewedToolCall {
    message: string
    replaceContent?: boolean
    forceSuccess?: boolean
}

interface ReviewEditor {
    bin: "nvim"
}

interface TerminalReviewResult {
    accepted: boolean
    exitCode: number | null
    spawnError?: string
}

// Runtime mode overrides (toggled by user during session, not persisted)
const SessionModeOverrides = new Map<string, Mode>()
const reviewedToolCalls = new Map<string, ReviewedToolCall>()

const LOCAL_SKILL_LOCATIONS = new Set(["user", "project", "path"])
const REVIEW_MAX_LINES = 2000
const REVIEW_MAX_BYTES = 50 * 1024
let cachedDerivedSkillAllowState: DerivedSkillAllowState | undefined
let cachedReviewEditor: ReviewEditor | null | undefined
let cachedDiffviewAvailable: boolean | undefined
let cachedPiNvimRpcSession: boolean | undefined

export default function (pi: ExtensionAPI) {
    const initSettings = loadSettings(process.cwd())
    const keybindings = initSettings.keybindings ?? {}

    if (keybindings.autoAcceptEdits) {
        pi.registerShortcut(keybindings.autoAcceptEdits as any, {
            description: "Toggle auto-accept edits",
            handler: toggleAutoAcceptEdits,
        })
    }

    pi.registerCommand("permission-toggle-auto-accept", {
        description: "Toggle auto-accept edits",
        handler: async (_args, ctx) => toggleAutoAcceptEdits(ctx),
    })

    pi.registerCommand("permission-mode", {
        description: "Set permission mode for a tool in the current session",
        handler: async (_args, ctx) => {
            const tool = await ctx.ui.input("Tool name", "e.g. bash, edit")
            if (!tool) return
            const mode = await ctx.ui.select("Mode", ["allow", "ask", "deny"])
            if (!mode) return
            SessionModeOverrides.set(tool, mode as Mode)
            ctx.ui.notify(`Permission mode for "${tool}" set to "${mode}" (current session only)`, "info")
        },
    })

    pi.registerCommand("permission-settings", {
        description: "Show resolved permission settings",
        handler: async (_args, ctx) => {
            const derivedSkillAllowState = getDerivedSkillAllowState(pi)
            const settings = mergeSkillAllowRules(loadSettings(ctx.cwd), derivedSkillAllowState.rules)
            const overrides = Object.fromEntries(SessionModeOverrides)
            const output = JSON.stringify(
                {
                    settings,
                    derivedSkillAllowRules: derivedSkillAllowState.rules,
                    skillRuleSources: derivedSkillAllowState.sources,
                    sessionOverrides: overrides,
                },
                null,
                2,
            )
            await ctx.ui.editor("Resolved permission settings", output)
        },
    })

    pi.on("message_end", async (event) => {
        const msg = event.message as unknown as Record<string, unknown>
        if (msg.role !== "toolResult") return
        if (typeof msg.toolCallId !== "string") return

        const reviewed = reviewedToolCalls.get(msg.toolCallId)
        if (!reviewed) return
        reviewedToolCalls.delete(msg.toolCallId)

        if (reviewed.forceSuccess) {
            msg.isError = false
        }

        if (reviewed.replaceContent) {
            msg.content = [{ type: "text", text: reviewed.message }]
            return
        }

        const content = Array.isArray(msg.content) ? [...(msg.content as Array<Record<string, unknown>>)] : []
        content.push({
            type: "text",
            text: `${content.length > 0 ? "\n" : ""}${reviewed.message}`,
        })
        msg.content = content
    })

    pi.on("tool_call", async (event, ctx) => {
        const derivedSkillAllowState = getDerivedSkillAllowState(pi)
        const settings = mergeSkillAllowRules(loadSettings(ctx.cwd), derivedSkillAllowState.rules)
        const argValue = getMatchValue(event.toolName, event.input as Record<string, unknown>)
        const mode = resolveMode(settings, event.toolName, argValue ?? "", ctx.cwd)

        if (shouldAutoAllowPiNvimMutation(event.toolName, mode)) {
            return undefined
        }

        switch (mode) {
            case "allow": {
                return undefined
            }

            case "deny": {
                ctx.abort()
                return {
                    block: true,
                    reason: `Denied by permission settings (${event.toolName})`,
                }
            }

            case "ask": {
                if (!ctx.hasUI) {
                    return {
                        block: true,
                        reason: `Blocked (no UI for confirmation): ${event.toolName}`,
                    }
                }

                switch (event.toolName) {
                    case "edit":
                    case "write": {
                        if (!argValue) break

                        const reviewState =
                            event.toolName === "edit"
                                ? buildEditReviewState(event.input as Record<string, unknown>, ctx.cwd)
                                : buildWriteReviewState(event.input as Record<string, unknown>, ctx.cwd)

                        if (!reviewState) {
                            const choice = await ctx.ui.select(`${event.toolName}: ${argValue}`, ["Accept", "Reject"])
                            if (choice === "Accept") {
                                return undefined
                            }
                            ctx.abort()
                            return {
                                block: true,
                                reason: `User rejected the ${event.toolName} for ${argValue}. File unchanged.`,
                            }
                        }

                        const decision = await reviewFileMutation(ctx, event.toolName, reviewState)
                        if (decision.action === "reject") {
                            ctx.abort()
                            return {
                                block: true,
                                reason: `User rejected the ${event.toolName} for ${argValue}. File unchanged.`,
                            }
                        }

                        if (decision.action === "keep-existing") {
                            reviewedToolCalls.set(event.toolCallId, {
                                forceSuccess: true,
                                replaceContent: true,
                                message: buildKeepExistingReviewMessage(event.toolName, reviewState, decision.reviewer),
                            })
                            return {
                                block: true,
                                reason: `User reviewed ${argValue} and kept the existing content.`,
                            }
                        }

                        const finalContent = decision.finalContent ?? reviewState.proposedContent
                        if (event.toolName === "write") {
                            ;(event.input as WriteToolInput).content = finalContent
                        } else {
                            if (reviewState.currentContent.length === 0) {
                                try {
                                    fs.writeFileSync(reviewState.absolutePath, finalContent, "utf-8")
                                } catch (error) {
                                    ctx.abort()
                                    return {
                                        block: true,
                                        reason: `Failed to apply the reviewed edit locally: ${getErrorMessage(error)}`,
                                    }
                                }

                                reviewedToolCalls.set(event.toolCallId, {
                                    forceSuccess: true,
                                    replaceContent: true,
                                    message: buildLocalApplyReviewMessage(
                                        event.toolName,
                                        reviewState,
                                        decision.reviewer,
                                        finalContent,
                                    ),
                                })
                                return {
                                    block: true,
                                    reason: `User reviewed ${argValue} and applied the final content locally.`,
                                }
                            }

                            applyReviewedEditInput(
                                event.input as Record<string, unknown>,
                                reviewState.currentContent,
                                finalContent,
                            )
                        }

                        reviewedToolCalls.set(event.toolCallId, {
                            message: buildAppliedReviewMessage(
                                event.toolName,
                                reviewState,
                                decision.reviewer,
                                decision.modified,
                                finalContent,
                            ),
                        })
                        return undefined
                    }
                    case "bash": {
                        if (!argValue) return { block: true, reason: "No command provided" }
                        const allowed = await ctx.ui.confirm("Agent wants to run shell command. Allow?", argValue)
                        if (!allowed) {
                            ctx.abort()
                            return { block: true, reason: `Rejected by user` }
                        }
                        return undefined
                    }
                    default: {
                        const message = argValue ?? JSON.stringify(event.input, null, 2)
                        const allowed = await ctx.ui.confirm(event.toolName, message)
                        if (!allowed) {
                            ctx.abort()
                            return { block: true, reason: `Rejected by user` }
                        }
                        return undefined
                    }
                }
            }
        }
    })
}

function mergePermissions(
    base: Partial<PermissionSettings>,
    override: Partial<PermissionSettings>,
): Partial<PermissionSettings> {
    return {
        defaultMode: override.defaultMode ?? base.defaultMode,
        allow: [...(base.allow ?? []), ...(override.allow ?? [])],
        deny: [...(base.deny ?? []), ...(override.deny ?? [])],
        ask: [...(base.ask ?? []), ...(override.ask ?? [])],
        keybindings: { ...base.keybindings, ...override.keybindings },
    }
}

function loadSettings(cwd: string) {
    return project.loadExtensionSettings<PermissionSettings>(EXTENSION, cwd, mergePermissions)
}

function detectLineEnding(content: string): "\n" | "\r\n" {
    const crlfIdx = content.indexOf("\r\n")
    const lfIdx = content.indexOf("\n")
    if (lfIdx === -1 || crlfIdx === -1) return "\n"
    return crlfIdx < lfIdx ? "\r\n" : "\n"
}

function normalizeToLF(text: string): string {
    return text.replace(/\r\n/g, "\n").replace(/\r/g, "\n")
}

function restoreLineEndings(text: string, ending: "\n" | "\r\n"): string {
    return ending === "\r\n" ? text.replace(/\n/g, "\r\n") : text
}

function normalizeForFuzzyMatch(text: string): string {
    return text
        .normalize("NFKC")
        .split("\n")
        .map((line) => line.trimEnd())
        .join("\n")
        .replace(/[\u2018\u2019\u201A\u201B]/g, "'")
        .replace(/[\u201C\u201D\u201E\u201F]/g, '"')
        .replace(/[\u2010\u2011\u2012\u2013\u2014\u2015\u2212]/g, "-")
        .replace(/[\u00A0\u2002-\u200A\u202F\u205F\u3000]/g, " ")
}

function fuzzyFindText(content: string, oldText: string) {
    const exactIndex = content.indexOf(oldText)
    if (exactIndex !== -1) {
        return { found: true, index: exactIndex, matchLength: oldText.length, usedFuzzyMatch: false }
    }

    const fuzzyContent = normalizeForFuzzyMatch(content)
    const fuzzyOldText = normalizeForFuzzyMatch(oldText)
    const fuzzyIndex = fuzzyContent.indexOf(fuzzyOldText)
    if (fuzzyIndex === -1) {
        return { found: false, index: -1, matchLength: 0, usedFuzzyMatch: false }
    }

    return { found: true, index: fuzzyIndex, matchLength: fuzzyOldText.length, usedFuzzyMatch: true }
}

function countOccurrences(content: string, oldText: string): number {
    const fuzzyContent = normalizeForFuzzyMatch(content)
    const fuzzyOldText = normalizeForFuzzyMatch(oldText)
    return fuzzyContent.split(fuzzyOldText).length - 1
}

function getEditNotFoundError(filePath: string, editIndex: number, totalEdits: number): Error {
    if (totalEdits === 1) {
        return new Error(
            `Could not find the exact text in ${filePath}. The old text must match exactly including all whitespace and newlines.`,
        )
    }
    return new Error(
        `Could not find edits[${editIndex}] in ${filePath}. The oldText must match exactly including all whitespace and newlines.`,
    )
}

function getEditDuplicateError(filePath: string, editIndex: number, totalEdits: number, occurrences: number): Error {
    if (totalEdits === 1) {
        return new Error(
            `Found ${occurrences} occurrences of the text in ${filePath}. The text must be unique. Please provide more context to make it unique.`,
        )
    }
    return new Error(
        `Found ${occurrences} occurrences of edits[${editIndex}] in ${filePath}. Each oldText must be unique. Please provide more context to make it unique.`,
    )
}

function getEmptyOldTextError(filePath: string, editIndex: number, totalEdits: number): Error {
    if (totalEdits === 1) {
        return new Error(`oldText must not be empty in ${filePath}.`)
    }
    return new Error(`edits[${editIndex}].oldText must not be empty in ${filePath}.`)
}

function getNoChangeError(filePath: string, totalEdits: number): Error {
    if (totalEdits === 1) {
        return new Error(
            `No changes made to ${filePath}. The replacement produced identical content. This might indicate an issue with special characters or the text not existing as expected.`,
        )
    }
    return new Error(`No changes made to ${filePath}. The replacements produced identical content.`)
}

function applyEditsToNormalizedContent(normalizedContent: string, edits: ReplaceEdit[], filePath: string) {
    const normalizedEdits = edits.map((edit) => ({
        oldText: normalizeToLF(edit.oldText),
        newText: normalizeToLF(edit.newText),
    }))

    for (let i = 0; i < normalizedEdits.length; i++) {
        if (normalizedEdits[i].oldText.length === 0) {
            throw getEmptyOldTextError(filePath, i, normalizedEdits.length)
        }
    }

    const initialMatches = normalizedEdits.map((edit) => fuzzyFindText(normalizedContent, edit.oldText))
    const baseContent = initialMatches.some((match) => match.usedFuzzyMatch)
        ? normalizeForFuzzyMatch(normalizedContent)
        : normalizedContent

    const matchedEdits: Array<{
        editIndex: number
        matchIndex: number
        matchLength: number
        newText: string
    }> = []

    for (let i = 0; i < normalizedEdits.length; i++) {
        const edit = normalizedEdits[i]
        const matchResult = fuzzyFindText(baseContent, edit.oldText)
        if (!matchResult.found) {
            throw getEditNotFoundError(filePath, i, normalizedEdits.length)
        }

        const occurrences = countOccurrences(baseContent, edit.oldText)
        if (occurrences > 1) {
            throw getEditDuplicateError(filePath, i, normalizedEdits.length, occurrences)
        }

        matchedEdits.push({
            editIndex: i,
            matchIndex: matchResult.index,
            matchLength: matchResult.matchLength,
            newText: edit.newText,
        })
    }

    matchedEdits.sort((a, b) => a.matchIndex - b.matchIndex)
    for (let i = 1; i < matchedEdits.length; i++) {
        const previous = matchedEdits[i - 1]
        const current = matchedEdits[i]
        if (previous.matchIndex + previous.matchLength > current.matchIndex) {
            throw new Error(
                `edits[${previous.editIndex}] and edits[${current.editIndex}] overlap in ${filePath}. Merge them into one edit or target disjoint regions.`,
            )
        }
    }

    let newContent = baseContent
    for (let i = matchedEdits.length - 1; i >= 0; i--) {
        const edit = matchedEdits[i]
        newContent =
            newContent.substring(0, edit.matchIndex) +
            edit.newText +
            newContent.substring(edit.matchIndex + edit.matchLength)
    }

    if (baseContent === newContent) {
        throw getNoChangeError(filePath, normalizedEdits.length)
    }

    return { baseContent, newContent }
}

function stripBom(content: string): { bom: string; text: string } {
    return content.startsWith("\uFEFF") ? { bom: "\uFEFF", text: content.slice(1) } : { bom: "", text: content }
}

function buildWriteReviewState(input: Record<string, unknown>, cwd: string): FileReviewState | undefined {
    if (typeof input.path !== "string" || typeof input.content !== "string") return undefined

    const absolutePath = path.resolve(cwd, input.path)
    try {
        return {
            absolutePath,
            displayPath: input.path,
            currentContent: fs.readFileSync(absolutePath, "utf-8"),
            proposedContent: input.content,
            existed: true,
        }
    } catch (error) {
        if ((error as NodeJS.ErrnoException).code === "ENOENT") {
            return {
                absolutePath,
                displayPath: input.path,
                currentContent: "",
                proposedContent: input.content,
                existed: false,
            }
        }
        return undefined
    }
}

function prepareEditInput(input: Record<string, unknown>): PreparedEditInput | undefined {
    if (typeof input.path !== "string") return undefined

    let rawEdits = input.edits
    if (typeof rawEdits === "string") {
        try {
            rawEdits = JSON.parse(rawEdits)
        } catch {
            return undefined
        }
    }

    const edits: ReplaceEdit[] = []
    if (Array.isArray(rawEdits)) {
        for (const edit of rawEdits) {
            if (
                !edit ||
                typeof edit !== "object" ||
                typeof (edit as ReplaceEdit).oldText !== "string" ||
                typeof (edit as ReplaceEdit).newText !== "string"
            ) {
                return undefined
            }
            edits.push({
                oldText: (edit as ReplaceEdit).oldText,
                newText: (edit as ReplaceEdit).newText,
            })
        }
    }

    if (typeof input.oldText === "string" && typeof input.newText === "string") {
        edits.push({ oldText: input.oldText, newText: input.newText })
    }

    if (edits.length === 0) return undefined
    return { path: input.path, edits }
}

function buildEditReviewState(input: Record<string, unknown>, cwd: string): FileReviewState | undefined {
    const prepared = prepareEditInput(input)
    if (!prepared) return undefined

    try {
        const absolutePath = path.resolve(cwd, prepared.path)
        const rawCurrent = fs.readFileSync(absolutePath, "utf-8")
        const { text: currentContent } = stripBom(rawCurrent)
        const lineEnding = detectLineEnding(currentContent)
        const normalizedContent = normalizeToLF(currentContent)
        const { newContent } = applyEditsToNormalizedContent(normalizedContent, prepared.edits, prepared.path)
        return {
            absolutePath,
            displayPath: prepared.path,
            currentContent,
            proposedContent: restoreLineEndings(newContent, lineEnding),
            existed: true,
        }
    } catch {
        return undefined
    }
}

function applyReviewedEditInput(input: Record<string, unknown>, currentContent: string, finalContent: string) {
    delete input.oldText
    delete input.newText
    input.edits = [{ oldText: currentContent, newText: finalContent }]
}

async function reviewFileMutation(
    ctx: ExtensionContext,
    toolName: "edit" | "write",
    state: FileReviewState,
): Promise<ReviewDecision> {
    const terminalReview = await reviewWithTerminalEditor(ctx, state)
    if (terminalReview.kind === "reject") {
        return { reviewer: terminalReview.reviewer, action: "reject", modified: false }
    }
    if (terminalReview.kind === "apply") {
        return classifyReviewDecision(state, terminalReview.finalContent, terminalReview.reviewer)
    }

    const edited = await ctx.ui.editor(buildInlineReviewTitle(toolName, state.displayPath), state.proposedContent)
    if (typeof edited !== "string") {
        return { reviewer: "inline editor", action: "reject", modified: false }
    }
    return classifyReviewDecision(state, edited, "inline editor")
}

function classifyReviewDecision(state: FileReviewState, finalContent: string, reviewer: string): ReviewDecision {
    if (finalContent === state.currentContent && finalContent !== state.proposedContent) {
        return {
            reviewer,
            action: "keep-existing",
            finalContent,
            modified: true,
        }
    }

    return {
        reviewer,
        action: "apply",
        finalContent,
        modified: finalContent !== state.proposedContent,
    }
}

type ExternalReviewResult =
    | { kind: "unavailable" }
    | { kind: "reject"; reviewer: string }
    | { kind: "apply"; reviewer: string; finalContent: string }

async function reviewWithTerminalEditor(ctx: ExtensionContext, state: FileReviewState): Promise<ExternalReviewResult> {
    const editor = findReviewEditor()
    if (!editor || !process.stdin.isTTY || !process.stdout.isTTY) {
        return { kind: "unavailable" }
    }

    const tempDir = fs.mkdtempSync(path.join(tmpdir(), "pi-permission-"))
    const { currentPath, proposedPath } = buildReviewTempPaths(tempDir, state.displayPath)

    try {
        fs.writeFileSync(currentPath, state.currentContent, "utf-8")
        fs.writeFileSync(proposedPath, state.proposedContent, "utf-8")
        try {
            fs.chmodSync(currentPath, 0o444)
        } catch {
            // Ignore chmod failures on platforms/filesystems that do not support it.
        }

        let result: TerminalReviewResult | undefined
        try {
            result = await ctx.ui.custom<TerminalReviewResult | undefined>((tui, _theme, _kb, done) => {
                tui.stop()
                process.stdout.write("\x1b[2J\x1b[H")

                let child: ReturnType<typeof spawnSync> | undefined
                try {
                    const launch = buildReviewEditorLaunch(editor, currentPath, proposedPath)
                    child = spawnSync(editor.bin, launch.args, {
                        stdio: "inherit",
                        env: launch.env,
                    })
                } finally {
                    tui.start()
                    tui.requestRender(true)
                }

                done({
                    accepted: !child?.error && (child?.status ?? 1) === 0,
                    exitCode: child?.status ?? null,
                    spawnError: child?.error?.message,
                })
                return { render: () => [], invalidate: () => {} }
            })
        } catch {
            return { kind: "unavailable" }
        }

        if (!result || result.spawnError) {
            return { kind: "unavailable" }
        }
        if (!result.accepted) {
            return { kind: "reject", reviewer: editor.bin }
        }

        return {
            kind: "apply",
            reviewer: editor.bin,
            finalContent: fs.readFileSync(proposedPath, "utf-8"),
        }
    } catch {
        return { kind: "unavailable" }
    } finally {
        fs.rmSync(tempDir, { recursive: true, force: true })
    }
}

function findReviewEditor(): ReviewEditor | undefined {
    if (cachedReviewEditor !== undefined) {
        return cachedReviewEditor ?? undefined
    }

    cachedReviewEditor = commandExists("nvim") ? { bin: "nvim" } : null
    return cachedReviewEditor ?? undefined
}

function commandExists(command: string): boolean {
    const result = spawnSync(command, ["--version"], { stdio: "ignore" })
    return !result.error
}

function buildReviewTempPaths(tempDir: string, displayPath: string) {
    const parsed = path.parse(path.basename(displayPath) || "file")
    const stem = parsed.name || "file"
    return {
        currentPath: path.join(tempDir, `${stem}.current${parsed.ext}`),
        proposedPath: path.join(tempDir, `${stem}.review${parsed.ext}`),
    }
}

function buildReviewEditorLaunch(editor: ReviewEditor, currentPath: string, proposedPath: string) {
    if (hasDiffviewCommand(editor)) {
        return {
            args: [
                "-c",
                "execute 'DiffviewDiffFiles ' .. fnameescape($PI_PERMISSION_REVIEW_CURRENT) .. ' ' .. fnameescape($PI_PERMISSION_REVIEW_PROPOSED)",
                "-c",
                "wincmd l",
                "-c",
                "setlocal noreadonly modifiable",
                "-c",
                "echo 'Review the writable pane. :wqa to apply, :cq to reject.'",
            ],
            env: {
                ...process.env,
                PI_PERMISSION_REVIEW_CURRENT: currentPath,
                PI_PERMISSION_REVIEW_PROPOSED: proposedPath,
            },
        }
    }

    return {
        args: [
            "-d",
            currentPath,
            proposedPath,
            "-c",
            "setlocal readonly nomodifiable",
            "-c",
            "wincmd l",
            "-c",
            "setlocal noreadonly modifiable",
            "-c",
            "echo 'Review the writable pane. :wqa to apply, :cq to reject.'",
        ],
        env: process.env,
    }
}

function hasDiffviewCommand(editor: ReviewEditor): boolean {
    if (cachedDiffviewAvailable !== undefined) {
        return cachedDiffviewAvailable
    }

    const result = spawnSync(
        editor.bin,
        ["--headless", "-c", "if exists(':DiffviewDiffFiles') | cquit 0 | else | cquit 1 | endif"],
        { stdio: "ignore", env: process.env },
    )
    cachedDiffviewAvailable = !result.error && result.status === 0
    return cachedDiffviewAvailable
}

function buildInlineReviewTitle(toolName: "edit" | "write", displayPath: string): string {
    return `Review ${toolName}: ${displayPath}\nSave to apply. Cancel to reject.`
}

function buildAppliedReviewMessage(
    toolName: string,
    state: FileReviewState,
    reviewer: string,
    modified: boolean,
    finalContent: string,
): string {
    const via = describeReviewer(reviewer)
    if (!modified) {
        return `User reviewed this ${toolName} in ${via} and accepted the proposed changes for ${state.displayPath}.`
    }
    return `User reviewed this ${toolName} in ${via}, modified the final content before applying it, and the tool executed with the reviewed content for ${state.displayPath}. Final content of ${state.displayPath}:\n\`\`\`\n${formatReviewedContent(finalContent)}\n\`\`\``
}

function buildKeepExistingReviewMessage(toolName: string, state: FileReviewState, reviewer: string): string {
    const via = describeReviewer(reviewer)
    if (!state.existed) {
        return `User reviewed this ${toolName} in ${via} and declined to create ${state.displayPath}.`
    }
    return `User reviewed this ${toolName} in ${via} and kept the existing content of ${state.displayPath}. The proposed changes were not applied. Current content of ${state.displayPath}:\n\`\`\`\n${formatReviewedContent(state.currentContent)}\n\`\`\``
}

function buildLocalApplyReviewMessage(
    toolName: string,
    state: FileReviewState,
    reviewer: string,
    finalContent: string,
): string {
    const via = describeReviewer(reviewer)
    return `User reviewed this ${toolName} in ${via}, modified the final content, and the extension applied the reviewed content locally for ${state.displayPath}. This path was used because the reviewed result could not be represented safely as a built-in edit operation. Final content of ${state.displayPath}:\n\`\`\`\n${formatReviewedContent(finalContent)}\n\`\`\``
}

function describeReviewer(reviewer: string): string {
    return reviewer === "inline editor" ? "the inline editor" : `${reviewer} in the terminal`
}

function formatReviewedContent(content: string): string {
    const normalized = content.replace(/\r\n/g, "\n").replace(/\r/g, "\n")
    const lines = normalized.split("\n")
    const kept: string[] = []
    let bytes = 0
    let truncated = false

    for (let i = 0; i < lines.length; i++) {
        if (i >= REVIEW_MAX_LINES) {
            truncated = true
            break
        }

        const prefix = kept.length === 0 ? "" : "\n"
        const next = `${prefix}${lines[i]}`
        const nextBytes = Buffer.byteLength(next, "utf-8")
        if (bytes + nextBytes > REVIEW_MAX_BYTES) {
            truncated = true
            break
        }

        kept.push(lines[i])
        bytes += nextBytes
    }

    let text = kept.join("\n")
    if (!text && normalized.length > 0) {
        text = normalized.slice(0, 1024)
        truncated = normalized.length > text.length
    }
    if (!text) {
        text = "(empty file)"
    }
    if (truncated) {
        text += "\n[truncated; re-read the file for full content]"
    }
    return text
}

function getErrorMessage(error: unknown): string {
    return error instanceof Error ? error.message : String(error)
}

function toggleAutoAcceptEdits(ctx: ExtensionContext) {
    const editCurrent = SessionModeOverrides.get("edit")
    const writeCurrent = SessionModeOverrides.get("write")

    if (editCurrent === "allow" && writeCurrent === "allow") {
        SessionModeOverrides.delete("edit")
        SessionModeOverrides.delete("write")
        ctx.ui.setStatus("permission", undefined)
    } else {
        SessionModeOverrides.set("edit", "allow")
        SessionModeOverrides.set("write", "allow")
        ctx.ui.setStatus("permission", "▶︎ Auto-accept edits")
    }
}

function parseRuleList(value: unknown): string[] {
    if (Array.isArray(value)) {
        return value
            .filter((entry): entry is string => typeof entry === "string")
            .map((entry) => entry.trim())
            .filter((entry) => entry.length > 0)
    }

    if (typeof value === "string") {
        const trimmed = value.trim()
        return trimmed ? [trimmed] : []
    }

    return []
}

function getSkillAllowedRules(skillPath: string): string[] {
    try {
        const content = fs.readFileSync(skillPath, "utf-8")
        const { frontmatter } = parseFrontmatter<Record<string, unknown>>(content)
        return [...parseRuleList(frontmatter.allowed_tools), ...parseRuleList(frontmatter["allowed-tools"])]
    } catch {
        return []
    }
}

function buildSkillAllowCacheKey(skills: SkillCommandInfo[]): string {
    return skills
        .map((skill) => {
            const skillPath = skill.path ?? ""
            let stamp = "missing"

            if (skillPath) {
                try {
                    const stat = fs.statSync(skillPath)
                    stamp = `${stat.mtimeMs}:${stat.size}`
                } catch {
                    stamp = "missing"
                }
            }

            return `${skill.location ?? ""}:${skillPath}:${stamp}`
        })
        .sort()
        .join("\n")
}

function getDerivedSkillAllowState(pi: ExtensionAPI): DerivedSkillAllowState {
    const skills = pi
        .getCommands()
        .filter(
            (command): command is SkillCommandInfo =>
                command.source === "skill" &&
                LOCAL_SKILL_LOCATIONS.has(command.location ?? "") &&
                typeof command.path === "string",
        )
        .sort((a, b) => a.path.localeCompare(b.path))

    const cacheKey = buildSkillAllowCacheKey(skills)
    if (cachedDerivedSkillAllowState?.cacheKey === cacheKey) {
        return cachedDerivedSkillAllowState
    }

    const sources = skills
        .map((skill) => {
            const rules = getSkillAllowedRules(skill.path)
            return {
                skill: skill.name.replace(/^skill:/, ""),
                location: skill.location ?? "",
                path: skill.path,
                rules,
            }
        })
        .filter((skill) => skill.rules.length > 0)

    cachedDerivedSkillAllowState = {
        cacheKey,
        rules: [...new Set(sources.flatMap((skill) => skill.rules))],
        sources,
    }
    return cachedDerivedSkillAllowState
}

function mergeSkillAllowRules(settings: PermissionSettings, skillRules: string[]): PermissionSettings {
    if (skillRules.length === 0) return settings

    return {
        ...settings,
        allow: [...new Set([...(settings.allow ?? []), ...skillRules])],
    }
}

function parseRule(rule: string): ParsedRule {
    const match = rule.match(/^([^(]+)\((.+)\)$/)
    if (match) {
        return { toolPattern: match[1], argPattern: match[2] }
    }
    return { toolPattern: rule }
}

function matchPattern(pattern: string, value: string): boolean {
    const escaped = pattern.replace(/[.+^${}()|[\]\\]/g, "\\$&").replace(/\*/g, ".*")
    // Make trailing " .*" optional so "cmd *" also matches bare "cmd"
    const adjusted = escaped.replace(/ \.\*$/, "( .*)?")
    return new RegExp(`^${adjusted}$`).test(value)
}

function matchesAnyRule(rules: string[], toolName: string, argValue: string): boolean {
    return rules.some((rule) => {
        const parsed = parseRule(rule)
        if (!matchPattern(parsed.toolPattern, toolName)) return false
        if (parsed.argPattern) return matchPattern(parsed.argPattern, argValue)
        return true
    })
}

function getMatchValue(tool: string, input: Record<string, unknown>): string | undefined {
    switch (tool) {
        case "bash":
            return input.command as string | undefined
        case "edit":
        case "write":
        case "read":
            return input.path as string | undefined
        case "fetch":
            return input.url as string | undefined
        case "grep":
        case "find":
        case "ls":
            return (input.path as string | undefined) ?? ""
        default:
            return undefined
    }
}

function shouldAutoAllowPiNvimMutation(toolName: string, mode: Mode): boolean {
    return mode === "ask" && (toolName === "edit" || toolName === "write") && isPiNvimRpcSession()
}

function isPiNvimRpcSession(): boolean {
    if (cachedPiNvimRpcSession !== undefined) {
        return cachedPiNvimRpcSession
    }

    cachedPiNvimRpcSession = isRpcNoSessionMode() && hasNvimAncestor()
    return cachedPiNvimRpcSession
}

function isRpcNoSessionMode(): boolean {
    const args = process.argv.slice(2)
    return hasCliArgValue(args, "--mode", "rpc") && args.includes("--no-session")
}

function hasCliArgValue(args: string[], name: string, value: string): boolean {
    for (let i = 0; i < args.length; i++) {
        const arg = args[i]
        if (arg === name && args[i + 1] === value) return true
        if (arg === `${name}=${value}`) return true
    }
    return false
}

function hasNvimAncestor(): boolean {
    let pid = process.ppid

    for (let depth = 0; depth < 8 && pid > 1; depth++) {
        const name = readProcName(pid)
        if (name && isNvimProcessName(name)) return true

        const parent = readProcParentPid(pid)
        if (!parent || parent === pid) return false
        pid = parent
    }

    return false
}

function readProcName(pid: number): string | undefined {
    try {
        const comm = fs.readFileSync(`/proc/${pid}/comm`, "utf-8").trim()
        if (comm) return comm
    } catch {
        // Fall through to cmdline.
    }

    try {
        const cmdline = fs.readFileSync(`/proc/${pid}/cmdline`, "utf-8").split("\0").find(Boolean)
        return cmdline ? path.basename(cmdline) : undefined
    } catch {
        return undefined
    }
}

function isNvimProcessName(name: string): boolean {
    const base = path.basename(name).toLowerCase()
    return base === "nvim" || base.startsWith("nvim-") || base.startsWith("nvim.")
}

function readProcParentPid(pid: number): number | undefined {
    try {
        const stat = fs.readFileSync(`/proc/${pid}/stat`, "utf-8")
        const end = stat.lastIndexOf(")")
        if (end === -1) return undefined

        const fields = stat.slice(end + 2).trim().split(/\s+/)
        const parent = Number(fields[1])
        return Number.isFinite(parent) ? parent : undefined
    } catch {
        return undefined
    }
}

function resolveSingleMode(settings: PermissionSettings, toolName: string, argValue: string): Mode {
    const override = SessionModeOverrides.get(toolName)
    if (override) return override

    if (matchesAnyRule(settings.deny ?? [], toolName, argValue)) return "deny"
    if (matchesAnyRule(settings.ask ?? [], toolName, argValue)) return "ask"
    if (matchesAnyRule(settings.allow ?? [], toolName, argValue)) return "allow"

    return settings.defaultMode ?? "ask"
}

/**
 * Resolve the permission mode for a tool call.
 * For bash commands, splits on pipes/operators and checks every segment.
 * The strictest mode wins: deny > ask > allow.
 * As an extra safety layer, otherwise-allowed bash commands that contain
 * output redirection are escalated to "ask".
 */
function resolveMode(settings: PermissionSettings, toolName: string, argValue: string, cwd?: string): Mode {
    if (toolName !== "bash" || !argValue) {
        return resolveSingleMode(settings, toolName, argValue)
    }

    const normalized = cwd ? normalizeBashForPermission(argValue, cwd) : argValue
    const segments = splitShellCommand(normalized)
    let worst: Mode = "allow"

    for (const segment of segments) {
        const mode = resolveSingleMode(settings, toolName, segment)
        if (mode === "deny") return "deny"
        if (mode === "ask") worst = "ask"
    }

    if (worst === "allow" && hasShellOutputRedirection(normalized)) {
        return "ask"
    }

    return worst
}

function normalizeBashForPermission(command: string, cwd: string): string {
    const start = skipWhitespace(command, 0)
    if (!command.startsWith("cd", start)) return command

    const afterCd = start + 2
    if (afterCd < command.length && !/\s/.test(command[afterCd])) return command

    const dirStart = skipWhitespace(command, afterCd)
    const dirToken = readShellWord(command, dirStart)
    if (!dirToken?.word) return command

    const afterDir = skipWhitespace(command, dirToken.end)
    if (command.slice(afterDir, afterDir + 2) !== "&&") return command

    const rest = command.slice(afterDir + 2).trim()
    if (!rest) return command

    const currentDir = path.resolve(cwd)
    const targetDir = path.resolve(cwd, dirToken.word)

    return targetDir === currentDir ? rest : command
}

/**
 * Split a shell command on unquoted operators: |, ||, &&, ;
 * Respects single/double quotes and backslash escapes.
 */
function splitShellCommand(command: string): string[] {
    const segments: string[] = []
    let current = ""
    let inSingle = false
    let inDouble = false
    let escaped = false

    for (let i = 0; i < command.length; i++) {
        const char = command[i]

        if (escaped) {
            current += char
            escaped = false
            continue
        }
        if (char === "\\" && !inSingle) {
            escaped = true
            current += char
            continue
        }
        if (char === "'" && !inDouble) {
            inSingle = !inSingle
            current += char
            continue
        }
        if (char === '"' && !inSingle) {
            inDouble = !inDouble
            current += char
            continue
        }

        if (!inSingle && !inDouble) {
            if (char === "|" && command[i + 1] === "|") {
                segments.push(current)
                current = ""
                i++
                continue
            }
            if (char === "&" && command[i + 1] === "&") {
                segments.push(current)
                current = ""
                i++
                continue
            }
            if (char === ";") {
                segments.push(current)
                current = ""
                continue
            }
            if (char === "|") {
                segments.push(current)
                current = ""
                continue
            }
        }

        current += char
    }

    if (current.trim()) {
        segments.push(current)
    }

    return segments.map((s) => s.trim()).filter((s) => s.length > 0)
}

/**
 * Detect unquoted shell output redirections.
 * Escalates otherwise-allowed bash commands to "ask" for an extra confirmation.
 * Redirections to /dev/null are exempt.
 */
function hasShellOutputRedirection(command: string): boolean {
    let inSingle = false
    let inDouble = false
    let escaped = false

    for (let i = 0; i < command.length; i++) {
        const char = command[i]

        if (escaped) {
            escaped = false
            continue
        }
        if (char === "\\" && !inSingle) {
            escaped = true
            continue
        }
        if (char === "'" && !inDouble) {
            inSingle = !inSingle
            continue
        }
        if (char === '"' && !inSingle) {
            inDouble = !inDouble
            continue
        }

        if (inSingle || inDouble) continue

        if (char === "&" && command[i + 1] === ">") {
            return true
        }

        if (char !== ">") continue

        // Ignore fd duplication/closing like 2>&1, >&2, >&-
        if (command[i + 1] === "&") continue
        // Ignore process substitution like >(...)
        if (command[i + 1] === "(") continue
        // Ignore redirection to /dev/null (e.g. >/dev/null, 2>/dev/null, >>/dev/null)
        {
            let j = i + 1
            if (j < command.length && command[j] === ">") j++ // skip >> second >
            while (j < command.length && command[j] === " ") j++ // skip whitespace
            if (command.startsWith("/dev/null", j)) continue
        }

        return true
    }

    return false
}

function skipWhitespace(command: string, index: number): number {
    while (index < command.length && /\s/.test(command[index])) index++
    return index
}

function readShellWord(command: string, start: number): { word: string; end: number } | undefined {
    if (start >= command.length) return undefined

    const first = command[start]
    if (first === '"' || first === "'") {
        const quote = first
        let value = ""
        let escaped = false

        for (let i = start + 1; i < command.length; i++) {
            const char = command[i]
            if (escaped) {
                value += char
                escaped = false
                continue
            }
            if (char === "\\" && quote === '"') {
                escaped = true
                continue
            }
            if (char === quote) {
                return { word: value, end: i + 1 }
            }
            value += char
        }

        return undefined
    }

    let value = ""
    let escaped = false

    for (let i = start; i < command.length; i++) {
        const char = command[i]
        if (escaped) {
            value += char
            escaped = false
            continue
        }
        if (char === "\\") {
            escaped = true
            continue
        }
        if (/\s/.test(char) || char === "&" || char === "|" || char === ";") {
            return value ? { word: value, end: i } : undefined
        }
        value += char
    }

    return value ? { word: value, end: command.length } : undefined
}
