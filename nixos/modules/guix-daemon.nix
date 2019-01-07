{ config, lib, pkgs, ... }:

with builtins;
with lib;
with rec {
  cfg  = config.services.guix-daemon;

  hashes = {
    "i686-linux" = "1wv8ih3m708cj6f2ccwvn51vd0xi90ngz62sp8lhqdhllpnxkzcp";
  };

  pkg =
    with {
      url = concatStrings [
        "ftp://alpha.gnu.org/gnu/guix/guix-binary-0.15.0."
        currentSystem
        ".tar.xz"
      ];
    };
    pkgs.fetchurl {
      inherit url;
      sha256 = if hasAttr currentSystem hashes
                  then getAttr currentSystem hashes
                  else abort ''
                         No known hash for Guix binary ${url} built for
                         architecture '${currentSystem}'. Please specify
                         services.guix-daemon.pkg explicitly.
                       '';
    };

  profile = "/root/.guix-profile";
};
{
  options.services.guix-daemon = {
    enable = mkOption {
      type        = types.bool;
      default     = false;
      description = ''
        Enable the builder daemon for the Guix package manager.
      '';
    };

    package = mkOption {
      type        = types.package;
      default     = pkg;
      description = ''
        The package providing Guix binaries.
      '';
    };

    storePath = mkOption {
      type        = types.path;
      default     = "/gnu";
      description = ''
        The path Guix writes to, including its store. Usually /gnu.
      '';
    };

    varPath = mkOption {
      type        = types.path;
      default     = "/var/guix";
      description = ''
        Where Guix should store its runtime data. Usually /var/guix.
      '';
    };

    group = mkOption {
      default     = "guixbuild";
      type        = types.str;
      description = "Primary group of the Guix build users.";
    };

    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of extra groups that the laminar user should be in.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ laminar ];

    systemd.services.guix-daemon = {
      description   = "Build daemon for GNU Guix";
      wantedBy      = [ "multi-user.target" ];
      environment   = {
        GUIX_LOCPATH = "/root/.guix-profile/lib/locale";
      };
      preStart = ''
        echo "Setting up Guix store" 1>&2
        STORE="${cfg.storePath}"
        if [[ -e "$STORE" ]]
        then
          echo "Guix store '$STORE' already exists, leaving as-is" 1>&2
        else
          PARENT=$(dirname "$STORE")
          echo "Extracting /gnu from '${cfg.package}'"
          tar xf "${cfg.package}" -C "$PARENT" /gnu
        fi


        PARENT=$(dirname "${profile}")
        [[ -e "$PARENT" ]] || {
          echo "Directory '$PARENT' not found, can't create profile, abort" 1>&2
          exit 1
        }
        if [[ -e "${profile}" ]]
        chown -v "${cfg.user}"."${cfg.group}" "${cfg.home}"

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
        ExecStart       = "/var/guix/profiles/per-user/root/guix-profile/bin/guix-daemon --build-users-group=guixbuild";
        RemainAfterExit = "yes";
        StandardOutput  = "syslog";
        StandardError   = "syslog";
        TaskMax         = "8192";
      };
    };

    systemd.services.laminar = {
      description   = "Laminar continuous integration service";
      path     = [ cfg.package ];

      serviceConfig = {
        User                 = "root";
        Group                = cfg.group;
        PermissionsStartOnly = true;  # Allow preStart to run as root
        ExecStart            = "${cfg.package}/bin/laminard";
      };
    };

    users.extraUsers =
      with {
        buildUser = i: {
          name  = "guixbuilder${i}";
          value = {
            createHome   = false;
            description  = "Guix build user ${i}";
            extraGroups  = [ cfg.group ];
            group        = cfg.group;
            home         = "/var/empty";
            isSystemUser = true;
            shell        = pkgs.nologin;
          };
        };
      };
      listToAttrs (map (n: buildUser (fixedWidthNumber 2 n))
                       (range 1 10));

    users.extraGroups.guixbuild = optional (cfg.group == "guixbuild") {
      name = "guixbuild";
    };
  };
}
