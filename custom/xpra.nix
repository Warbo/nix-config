self: super:

let fixedPkgSrc = self.latestGit {
      url = "https://github.com/abbradar/nixpkgs.git";
      ref = "xpra";
    };
    fixedPkgs = import "${fixedPkgSrc}" { config = x: {}; };
 in { inherit (fixedPkgs) xpra; }
