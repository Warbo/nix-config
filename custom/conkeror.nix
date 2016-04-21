pkgs:

let nixpkgs = import <nixpkgs> {};
 in {
  conkeror = nixpkgs.withLatestGit {
    url      = "git://repo.or.cz/conkeror.git";
    ref      = "3e4732cd0d15aa70121fe0a0403103b777c964bf";
    refIsRev = true;
    srcToPkg = s: nixpkgs.stdenv.lib.overrideDerivation pkgs.conkeror
                    (old: { src = s; });
  };
}
