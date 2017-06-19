{ latestGit }:

rec {
  # The latest version of this repo
  latestNixCfg = latestGit {
    url = "http://chriswarbo.net/git/nix-config.git";
  };

  withLatestCfg = pkgs: import pkgs {
    config = import "${latestNixCfg}/config.nix";
  };

  latestCfgPkgs = withLatestCfg <nixpkgs>;
}
