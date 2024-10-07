# Options which are common to warbo.nix NixOS module and HomeManager module.
# Check those files to see what extras they provide on top of these!
{ lib }:
with {
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    ;
};
{
  enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Turn on custom "warbo" configuration.
    '';
  };

  is-nixos = mkOption {
    type = types.bool;
    default = false;
    description = ''
      True when using a NixOS module, false when using Home Manager standalone.
    '';
  };

  professional = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Stick to utilities (avoiding music players, torrent clients, etc.).
    '';
  };

  direnv = mkOption {
    type = types.bool;
    default = true;
    description = ''
      Enable direnv and nix-shell integration.
    '';
  };

  dotfiles = mkOption {
    type = types.nullOr types.path;
    default = fetchGit {
      url = "http://chriswarbo.net/git/warbo-dotfiles.git";
      rev = "76428a670145953173a2f74cccbac31d95a97be0";
    };
    description = ''
      Copy of chriswarbo.net/git/warbo-dotfiles.git. Defaults to a git clone,
      but may be useful to override with a local folder.
    '';
  };

  nixpkgs.path = mkOption {
    type = types.nullOr types.path;
    default =
      with rec { inherit (import overrides/repos.nix overrides { }) overrides; };
      (import "${overrides.nix-helpers-src}/helpers/pinnedNixpkgs" { }).repoLatest;
    description = ''
      Path to use for Nixpkgs. We use this to set <nixpkgs>, etc.
    '';
  };

  nixpkgs.overlays = mkOption {
    default = os: [
      os.sources
      os.repos
      os.metaPackages
    ];
    description = ''
      Function choosing which attrs from overlays.nix to use. Null disables.
    '';
  };

  home-manager.stateVersion = mkOption {
    type = types.str;
    default = "24.05"; # Override as needed
    description = ''
      Passed along to user's Home Manager. Records the version of Home
      Manager that was originally installed, so future upgrades can apply
      any necessary fixes/workarounds to maintain compatibility.
    '';
  };

  packages = mkOption {
    default = [ ];
    description = ''
      Packages to add to the user profile or system.
    '';
  };
}
