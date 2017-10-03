{ latestNixCfg }:

pkgs: import pkgs { config = latestNixCfg; }
