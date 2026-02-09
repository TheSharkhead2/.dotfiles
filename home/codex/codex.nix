{
  config,
  lib,
  pkgs,
  userSettings,
  ...
}:
let
  cfg = config.codexAuth;
  profiles = [
    "personal"
    "school"
  ];
in
{
  options.codexAuth = {
    enable = lib.mkEnableOption "Codex auth profile switching";

    profile = lib.mkOption {
      type = lib.types.enum profiles;
      default = "personal";
      description = "Which auth profile should back ~/.codex/auth.json.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".codex/auth.json" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.codex/auth-${cfg.profile}.json";
      force = true;
    };

    home.packages = [
      (pkgs.writeShellScriptBin "codex-auth" ''
        set -euo pipefail

        if [ "$#" -ne 1 ]; then
          echo "Usage: codex-auth <personal|school>"
          exit 1
        fi

        profile="$1"
        case "$profile" in
          personal|school) ;;
          *)
            echo "Invalid profile '$profile'. Use: personal or school"
            exit 1
            ;;
        esac

        codex_dir="$HOME/.codex"
        target="$codex_dir/auth-$profile.json"
        link="$codex_dir/auth.json"

        mkdir -p "$codex_dir"

        if [ ! -f "$target" ]; then
          echo "Missing credentials file: $target"
          exit 1
        fi

        ln -sfn "$target" "$link"
        echo "Codex auth is now using '$profile' credentials."
      '')
    ];

    programs.zsh.shellAliases.codex-auth-personal = "codex-auth personal";
    programs.zsh.shellAliases.codex-auth-school = "codex-auth school";

    codexAuth.profile = lib.mkDefault (userSettings.codexAuthProfile or "personal");
  };
}
