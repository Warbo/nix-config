{
  config,
  lib,
  pkgs,
  ...
}:

with builtins;
with lib;
with rec {
  cfg = config.services.laminar;

  # Workaround for https://groups.google.com/forum/#!topic/nix-devel/fAMADzFhcFo
  stdenv6 = with pkgs; overrideCC stdenv gcc6;

  capnproto =
    with pkgs;
    stdenv6.mkDerivation {
      name = "capnproto";
      src = fetchFromGitHub {
        owner = "capnproto";
        repo = "capnproto";
        rev = "3079784";
        sha256 = "0d7v9310gq12qwhxbsjcdxwaz9fhyxq13x2lz8cdhm6hbsg8756z";
      };
      buildInputs = [
        autoconf
        automake
        libtool
      ];
      patchPhase = ''
        cd c++/
        autoreconf -i
      '';
      hardeningDisable = [ "all" ];
    };

  laminar = stdenv6.mkDerivation rec {
    name = "laminar-${version}";
    version = "0.6";
    src = pkgs.fetchFromGitHub {
      owner = "ohwgiles";
      repo = "laminar";
      rev = "bbbef11"; # v0.6
      sha256 = "07nnqccm0dgyzkj6k3gcrs6f22h2ac7hdq05zq4wjs1xdyqdksl0";
    };
    buildInputs =
      [ capnproto ]
      ++ (with pkgs; [
        boost
        cmake
        rapidjson
        nix-helpers.replace
        sqlite
        websocketpp
        zlib
      ]);
    hardeningDisable = [ "all" ];
    __noChroot = true; # TODO: Prefetch deps (e.g. vue.js)
    preConfigure = ''
      cmakeFlags="$cmakeFlags -DSYSTEMD_UNITDIR='$out/lib/systemd/system'"
      replace 'usr/bin' 'bin' -- CMakeLists.txt
    '';
  };
};
{
  options.services.laminar = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the Laminar continuous integration system as a systemd service.
      '';
    };

    package = mkOption {
      type = types.package;
      default = laminar;
      description = ''
        The package providing Laminar binaries.
      '';
    };

    home = mkOption {
      type = types.path;
      default = "/var/lib/laminar";
      description = ''
        The directory used to load config, store results, etc.
      '';
    };

    cfg = mkOption {
      type = types.path;
      description = ''
        Path to symlink as LAMINAR_HOME/cfg, used to control Laminar. We use a
        symlink so that content can be managed externally, e.g. via version
        control, without needing to rebuild the service. Note that raw paths
        like './foo' will have a snapshot added to the Nix store; to prevent
        this use a string like '"/.../foo"' or 'toString ./foo'.
      '';
    };

    custom = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to symlink as 'home'/custom, used for Web UI customisation. We use
        a symlink so that content can be managed externally, e.g. via version
        control.
      '';
    };

    bindHttp = mkOption {
      type = types.str;
      default = "*:8080";
      description = ''
        Value for LAMINAR_BIND_HTTP, used for Laminar's read-only WebUI. Has
        the form IPADDR:PORT, unix:PATH/TO/SOCKET or unix-abstract:SOCKETNAME.
        IPADDR may be * to bind on all interfaces.
      '';
    };

    title = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "My Build Server";
      description = ''
        Sets LAMINAR_TITLE, to use your preferred page title on the WebUI. For
        further WebUI customization, consider using a custom style sheet.
      '';
    };

    user = mkOption {
      default = "laminar";
      type = types.str;
      description = "User the laminar service should execute under.";
    };

    group = mkOption {
      default = "laminar";
      type = types.str;
      description = "Primary group of the laminar user.";
    };

    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of extra groups that the laminar user should be in.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ laminar ];

    systemd.services.laminar = {
      description = "Laminar continuous integration service";
      wantedBy = [ "multi-user.target" ];
      environment = {
        LAMINAR_BIND_HTTP = cfg.bindHttp;
        LAMINAR_HOME = cfg.home;
        LAMINAR_TITLE = cfg.title;
      };
      path = [ cfg.package ];
      preStart = ''
        mkdir -vp "${cfg.home}"
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
        ${
          if cfg.custom == null then
            ""
          else
            ''ln -sfv "${cfg.custom}" ${cfg.home}/custom''
        }
      '';
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        PermissionsStartOnly = true; # Allow preStart to run as root
        ExecStart = "${cfg.package}/bin/laminard";
      };
    };

    users.extraGroups = optionalAttrs (cfg.group == "laminar") {
      laminar = {
        name = "laminar";
      };
    };

    users.extraUsers = optionalAttrs (cfg.user == "laminar") {
      "${cfg.user}" = {
        name = "laminar";
        description = "Laminar User.";
        isNormalUser = true;
        createHome = false;
        group = cfg.group;
        extraGroups = cfg.extraGroups;
        useDefaultShell = true;
      };
    };
  };
}
