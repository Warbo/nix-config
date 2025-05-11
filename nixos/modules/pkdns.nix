{
  config,
  lib,
  pkgs,
  ...
}:
with rec {
  inherit (lib) mkIf mkOption types;

  cfg = config.services.pkdns;

  pinned-warbo-packages =
    with rec { inherit (import overrides/repos.nix overrides { }) overrides; };
    overrides.warbo-packages;

  warbo-packages = pkgs.warbo-packages or pinned-warbo-packages;

  package = pkgs.pkdns or warbo-packages.pkdns;
};
{
  options.services.pkdns = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        pkdns - Self-Sovereign And Censorship-Resistant Domain Names
      '';
    };

    package = mkOption {
      description = "pkdns package to use";
      default = package;
    };
  };

  config = mkIf cfg.enable {
    users = {
      groups.pkdns = { };
      users.pkdns = {
        isSystemUser = true;
        group = "pkdns";
      };
    };

    # TODO: Currently squats on port 53, which prevents us running any other DNS
    # server. We could avoid this by putting it in a container with its own
    # network interface (or bridge, or whatever) and adding its IP to this list.
    networking.nameservers = [ "127.0.0.1" ];

    systemd.services.pkdns = {
      description = "pkdns - Self-Sovereign And Censorship-Resistant Domain Names";
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.writeScript "pkdns-start" ''
          #!${pkgs.bash}/bin/bash
          export HOME="$STATE_DIRECTORY"
          ${cfg.package}/bin/pkdns -p "$STATE_DIRECTORY"
        ''}";
        Restart = "on-failure";
        RestartSec = "5s";
        User = "pkdns";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        StateDirectory = "pkdns";
        StateDirectoryMode = "0755";
      };
    };
  };
}
