{ config, lib, pkgs, ... }:

with builtins;
with lib;
with rec {
  cfg = config.services.laminar;

  laminar = version:
    with {
      revs    = {
        "0.6" = {
          rev    = "bbbef11";
          sha256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
        };
      };
    };
    pkgs.stdenv.mkDerivation {
      inherit version;
      name = "laminar-${version}";
      src = pkgs.fetchFromGitHub (getAttr version revs // {
        owner = "ohwgiles";
        repo  = "laminar";
      });
      buildInputs = [ pkgs.cmake ];
    };
};
{
  options.services.laminar = {
    enable = mkOption {
      type        = types.bool;
      default     = false;
      description = ''
        Enable the Laminar continuous integration system as a systemd service.
      '';
    };

    package = mkOption {
      type        = types.package;
      default     = laminar;
      description = ''
        The package providing Laminar binaries.
      '';
    };

    home = mkOption {
      type        = types.path;
      default     = "/var/lib/laminar";
      description = ''
        The directory used to load config, store results, etc.
      '';
    };

    cfg = mkOption {
      type        = types.nullOr types.path;
      default     = null;
      description = ''
        Path to symlink as 'home'/cfg, used to control Laminar. We use a symlink
        so that content can be managed externally, e.g. via version control,
        without needing to rebuild the service.
      '';
    };

    custom = mkOption {
      type        = types.nullOr types.path;
      default     = null;
      description = ''
        Path to symlink as 'home'/custom, used for Web UI customisation. We use
        a symlink so that content can be managed externally, e.g. via version
        control.
      '';
    };

    bindHttp = mkOption {
      type        = types.str;
      default     = "*:8080";
      description = ''
        Value for LAMINAR_BIND_HTTP, used for Laminar's read-only WebUI. Has
        the form IPADDR:PORT, unix:PATH/TO/SOCKET or unix-abstract:SOCKETNAME.
        IPADDR may be * to bind on all interfaces.
      '';
    };

    title = mkOption {
      type        = types.nullOr types.str;
      default     = null;
      example     = "My Build Server";
      description = ''
        Sets LAMINAR_TITLE, to use your preferred page title on the WebUI. For
        further WebUI customization, consider using a custom style sheet.
      '';
    };

    user = mkOption {
      default     = "laminar";
      type        = types.str;
      description = "User the laminar service should execute under.";
    };

    group = mkOption {
      default     = "laminar";
      type        = types.str;
      description = "Primary group of the laminar user.";
    };

    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of extra groups that the laminar user should be in.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.laminar = {
      description   = "Laminar continuous integration service";
      wantedBy      = [ "multi-user.target" ];
      path          = [ cfg.package ];
      preStart = ''
        env > envvars
        mkdir -vp "${cfg.home}"

        if [[ -h "${cfg.home}"/cfg ]]
        then
          rm -v "${cfg.home}"/cfg
        fi
        ln -sfv "${cfg.cfg}" ${cfg.home}/cfg

        if [[ -h "${cfg.home}"/custom ]]
        then
          rm -v "${cfg.home}"/custom
        fi
        ${if cfg.custom == null
             then ""
             else ''ln -sfv "${cfg.custom}" ${cfg.home}/custom''}
      '';
      serviceConfig = {
        User        = cfg.user;
        Group       = cfg.group;
        Environment = {
          LAMINAR_BIND_HTTP = cfg.bindHttp;
          LAMINAR_HOME      = cfg.home;
          LAMINAR_TITLE     = cfg.title;
        };
        ExecStart = pkgs.writeScript "Start laminar" ''
          #!${pkgs.bash}/bin/bash
          set -e
          [[ -e "$LAMINAR_HOME" ]] || {
            echo "LAMINAR_HOME directory '$LAMINAR_HOME' doesn't exist" 1>&2
            exit 1
          }
          [[ -h "$LAMINAR_HOME/cfg" ]] || {
            echo "Laminar cfg symlink '$LAMINAR_HOME/cfg' doesn't exist" 1>&2
            exit 1
          }
          CFG=$(readlink -f "$LAMINAR_HOME/cfg")
          [[ -e "$LAMINAR_HOME" ]] || {
            echo "Laminar cfg directory '$CFG' doesn't exist" 1>&2
            exit 1
          }
          "${cfg.package}/bin/laminard"
        '';
      };
    };

    users.extraGroups = optional (cfg.group == "laminar") {
      name = "laminar";
    };

    users.extraUsers = optional (cfg.user == "laminar") {
      name            = "laminar";
      description     = "Laminar User.";
      isNormalUser    = true;
      createHome      = false;
      group           = cfg.group;
      extraGroups     = cfg.extraGroups;
      useDefaultShell = true;
    };
  };
}
