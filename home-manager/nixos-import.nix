# Adding this to the 'imports' list of a NixOS configuration.nix will enable
# Home Manager for that NixOS system.
with rec {
  # Use builtins.fetchTarball, since nixpkgs.fetchFromGitHub would cause an
  # infinite loop. Using this helper function makes update-nix-fetchgit work.
  fetchFromGitHub =
    {
      owner,
      repo,
      rev,
      sha256,
    }:
    builtins.fetchTarball {
      inherit sha256;
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    };

  home-manager = fetchFromGitHub {
    owner = "nix-community";
    repo = "home-manager";
    rev = "845a5c4c073f74105022533907703441e0464bc3"; # release-24.05
    sha256 = "0l3pcd38p4iq46ipc5h3cw7wmr9h8rbn34h8a5a4v8hcl21s8r5x";
  };
};
import "${home-manager}/nixos"
