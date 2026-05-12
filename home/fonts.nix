{ pkgs, ...}:
let
  juliaMonoNerd = pkgs.stdenvNoCC.mkDerivation {
      pname = "julia-mono-nerd-font";
      version = pkgs.julia-mono.version or "unknown";

      nativeBuildInputs = [
        pkgs.nerd-font-patcher
      ];

      dontUnpack = true;

      installPhase = ''
        runHook preInstall

        original_dir="$TMPDIR/juliamono-original"
        patched_dir="$out/share/fonts/truetype/juliamono-nerd"

        mkdir -p "$original_dir" "patched_dir"

        cp -v ${pkgs.julia-mono}/share/fonts/truetype/*.ttf "$original_dir/"

        for f in "$original_dir"/*.ttf; do
            nerd-font-patcher \
              --complete \
              --outputdir "$patched_dir" \
              "$f"
        done

        runHook postInstall
      '';
  };
in
{
    fonts.fontconfig.enable = true;

    home.packages = [
      juliaMonoNerd
    ];
}
