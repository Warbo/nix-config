self: super:

rec {
  # The latest version of this repo
  latestNixCfg = self.latestGit {
    url = "http://chriswarbo.net/git/nix-config.git";
  };

  withLatestCfg = pkgs: import pkgs {
    config = import "${latestNixCfg}/config.nix";
  };

  latestCfgPkgs = withLatestCfg <nixpkgs>;
}
