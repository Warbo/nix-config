# Latest nixpkgs master
self: super:

let repo = self.latestGit {
             url = "https://github.com/NixOS/nixpkgs.git";
           };
in {
  # Explicitly pass an empty config, to avoid loading ~/.nixpkgs/config.nix and
  # causing an infinite loop
  unstable = import repo { config = null; };
}
