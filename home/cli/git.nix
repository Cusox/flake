let
    users = import ../../config/users.nix;
    user = users.default;
in
{
    programs.git = {
        enable = true;
        signing = {
            key = null;
            format = null;
            signByDefault = null;
            signer = null;
        };
        settings = {
            user = {
                name = user.username;
                email = user.useremail;
            };

            credential.helper = [ 
                "cache --timeout 21600" 
            ];

            column.ui = "auto";

            branch.sort = "-committerdate";

            tag.sort = "version:refname";

            init.defaultBranch = "main";

            diff = {
                algorithm = "histogram";
                colorMoved = "plain";
                mnemonicPrefix = true;
                renames = true;
            };

            push = {
                default = "simple";
                autoSetupRemote = true;
                followTags = true;
            };

            fetch = {
                prune = true;
                pruneTags = true;
                all = true;
            };

            help.autocorrect = "prompt";

            pull.rebase = true;

            include.path = "~/.config/delta/themes/nordic.gitconfig";

            mergetool = {
                keepBackup = false;
                conflictstyle = "zdiff3";
            };
        };

    };

    programs.git-credential-oauth = {
        enable = true;
        extraFlags = [ "-device" ];
    };
}
