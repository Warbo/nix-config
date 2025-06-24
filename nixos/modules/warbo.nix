# Warbo's preferred setup, used across a bunch of systems. This part is specific
# to NixOS; there is an equivalent module for Home Manager (which this module
# can load for us too!)
{
  config,
  lib,
  pkgs,
  ...
}:
with {
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.warbo;
};
{
  imports = [ (import "${import ../../home-manager/nixos-import.nix}/nixos") ];

  options.warbo =
    with { common = import ../../warbo-options.nix { inherit lib pkgs; }; };
    common
    // {
      home-manager = (common.home-manager or { }) // {
        extras = mkOption {
          default = { };
          description = ''
            Extra configuration for the user's home-manager setup.
          '';
        };

        username = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            The username to enable Home Manager for (leave null to disable HM).
          '';
        };
      };
    };

  config = mkIf cfg.enable (mkMerge [
    {
      # Unconditional settings; override if desired

      # Install packages system-wide. If Home Manager is being used then we'll
      # also put these in the user's home.packages, but it's annoying to not
      # have things available as root, to require a login shell for them, etc.
      environment.systemPackages = cfg.packages;

      fonts = {
        enableDefaultPackages = true;
        fontconfig.defaultFonts = {
          monospace = [ "Droid Sans Mono" ];
          sansSerif = [ "Droid Sans" ];
          serif = [ "Droid Sans" ];
        };
        packages = [
          pkgs.anonymousPro
          pkgs.liberation_ttf
          pkgs.nerd-fonts.droid-sans-mono
          pkgs.terminus_font
          pkgs.ttf_bitstream_vera
        ];
      };

      nix = {
        extraOptions = ''experimental-features = ${
          lib.concatStringsSep " " [
            "configurable-impure-env"
            "flakes"
            "git-hashing"
            "nix-command"
          ]
        }'';
        settings = {
          show-trace = true;
          trusted-users = [
            "root"
            "@wheel"
          ];
        };
      };

      nixpkgs.config.allowUnfree = true;

      programs = {
        fuse.userAllowOther = true;
        iotop.enable = true;
        screen.enable = true;
      };

      services = {
        avahi.hostName = config.networking.hostName;
        openssh.settings.X11Forwarding = config.services.xserver.enable;
        xserver = {
          xkb.layout = "gb";
          xkb.options = "ctrl:nocaps";
        };
      };
    }
    (mkIf (!cfg.wsl) {
      # Trying this on NixOS in WSL will unload the Windows executable support
      # from the kernel, affecting every other running container!
      boot.binfmt = {
        # See https://discourse.nixos.org/t/chroot-into-arm-container-with-systemd-nspawn/34735/9
        emulatedSystems =
          with builtins;
          filter (s: s != currentSystem) [
            "aarch64-linux" # Pinephone
            "armv6l-linux" # RaspberryPi
            "i686-linux" # Thinkpad
            "riscv64-linux" # VisionFive
            "x86_64-linux" # Laptops
          ];
        # https://github.com/felixonmars/archriscv-packages/blob/7c270ecef6a84edd6031b357b7bd1f6be2d6d838/devtools-riscv64/z-archriscv-qemu-riscv64.conf#L1
        registrations."riscv64-linux" = {
          preserveArgvZero = true;
          matchCredentials = true;
          fixBinary = true;
        };
      };
    })
    (mkIf (cfg.nixpkgs.path != null) {
      nix.nixPath = [ "nixpkgs=${cfg.nixpkgs.path}" ];
      nixpkgs.flake.source = cfg.nixpkgs.path;
    })
    (mkIf (cfg.nixpkgs.overlays != null) {
      nixpkgs.overlays = cfg.nixpkgs.overlays (import ../../overlays.nix);
    })
    (mkIf (!cfg.professional) {
      # Disable by setting 'warbo.professional'
      programs.gnupg.agent.enable = true;
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        publish.enable = true;
        publish.addresses = true;
        publish.workstation = true;
      };
    })
    (mkIf cfg.direnv {
      programs.direnv = {
        enable = true;
        loadInNixShell = true; # This option doesn't exist in Home Manager
        nix-direnv.enable = true;
      };
    })
    (mkIf (cfg.home-manager.username != null) {
      home-manager.users."${cfg.home-manager.username}" =
        { ... }:
        cfg.home-manager.extras
        // {
          # Load our Home Manager equivalent
          imports = [ ../../home-manager/modules/warbo.nix ];

          # Pass along relevant config to our Home Manager module
          warbo = {
            inherit (cfg)
              direnv
              enable
              nixpkgs
              packages
              professional
              ;
            is-nixos = true;
            # Passing along username will cause an error, since our Home Manager
            # module doesn't define that option
            home-manager = builtins.removeAttrs cfg.home-manager [
              "extras"
              "username"
            ];
          };
        };
    })
  ]);
}
