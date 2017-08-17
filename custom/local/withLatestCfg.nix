{ latestNixCfg }:

pkgs: import pkgs {
  config = import "${latestNixCfg}/config.nix";
}
