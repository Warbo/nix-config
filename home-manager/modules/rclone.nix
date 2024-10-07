{
  config,
  lib,
  pkgs,
  ...
}:
with rec {
  inherit (lib)
    concatStringsSep
    escapeShellArg
    literalExpression
    mapAttrs
    mkIf
    mkOption
    types
    ;
  cfg = config.services.rclone;

  mountType = types.submodule (
    { name, ... }:
    {
      options = {
        name = mkOption {
          internal = true;
          default = name;
          type = types.str;
          description = "The name that should be given to this unit.";
        };

        mountPoint = mkOption {
          type = types.path;
          description = "The path at which to mount this filesystem";
        };

        filesystem = mkOption {
          type = types.str;
          example = ":sftp,user=alice,host=example.com:/home/alice";
          description = ''
            The filesystem to mount. To avoid needing a separate config file,
            it is recommended to specify all parameters via this string and
            the 'args' list.

            NOTE: For flexibility, we allow the shell to expand this string.
            For example, we could use ""
          '';
        };

        setup = mkOption {
          type = types.str;
          example = ''REMOTE_DIR=$(ssh example.com echo '$HOME')'';
          default = "";
          description = ''
            Shell code to run before attempting to mount. This could be used
            for setting variables to be expanded in 'filesystem' and 'args'.
          '';
        };

        program = mkOption {
          type = types.str;
          default = "${pkgs.rclone}/bin/rclone";
          description = ''
            The rclone command to invoke. Defaults to the 'rclone' binary from
            pkgs.rclone. Useful if we want to invoke a wrapper.
          '';
        };

        vfsCacheMode = mkOption {
          type = with types; nullOr (enum [ "full" ]); # TODO: Add more
          default = null;
          description = ''
            Whether to cache data locally, and if so to what extent.
          '';
        };

        rcAddr = mkOption {
          type = with types; nullOr str;
          default = null;
          example = ":12345";
          description = ''
            Port or address to listen for rc commands (e.g. 'vfs/stats'). If
            set, this will add the '--rc' arg automatically, but you may want to
            add other args e.g. to restrict access.
          '';
        };

        args = mkOption {
          type = with types; listOf str;
          default = [ ];
          example = literalExpression ''[\"--no-update-modtime"]'';
          description = ''
            Extra commandline options for rclone mount.
          '';
        };

        extraSystemd = mkOption {
          type = types.attrs;
          default = { };
          example = literalExpression ''{ Unit.After = [ "foo.service" ]; }'';
          description = ''
            Extra attributes to give the generated SystemD service.
          '';
        };
      };
    }
  );
};
{
  options.services.rclone = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Turn on custom "warbo" configuration.
      '';
    };

    sshAgentSocketPath = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        If non-null, the path to use for SSH_AUTH_SOCK. Will also cause socket
        activation of the unit.
      '';
    };

    mounts = mkOption {
      type = with types; attrsOf mountType;
      description = ''
        The filesystems to mount.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services = mapAttrs (
      _:
      {
        args,
        name,
        mountPoint,
        filesystem,
        setup,
        program,
        vfsCacheMode,
        rcAddr,
      }:
      {
        Unit = {
          Description = "Use rclone to mount ${mountPoint}";
          After = [
            "network-online.target"
            "dietpi-accessible" # TODO: Stabilise dietpi connecting
          ];
          Wants = [
            "network-online.target"
            "dietpi-accessible" # TODO: Stabilise dietpi connecting
          ];
        };
        Service = {
          ExecStart = "${pkgs.writeShellScript "${name}.sh" ''
            set -ex
            ${setup}
            ${concatStringsSep " " (
              map escapeShellArg (
                [
                  "exec"
                  program
                  "mount"
                ]
                ++ (optionalList (rcAddr != null) [
                  "--rc"
                  "--rc-addr=${rcAddr}"
                ])
                ++ (optionalList (vfsCacheMode != null) [ "--vfs-cache-mode=${vfsCacheMode}" ])
              )
              ++ args
              ++ [
                filesystem
                (escapeShellArg mountPoint)
              ]
            )}
          ''}";
          ExecStop = "fusermount -u ${escapeShellArg mountPoint}";
          Restart = "on-failure";
        };
        Install = { };
      }
    ) cfg.mounts;
  };
}
