{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

{
  nix-helpers = fetchgit {
    url    = http://chriswarbo.net/git/nix-helpers.git;
    rev    = "ed8379a";
    sha256 = "1ifyz49x9ck3wkfw3r3yy8s0vcknz937bh00033zy6r1a2alg54g";
  };

  warbo-packages = fetchgit {
    url    = http://chriswarbo.net/git/warbo-packages.git;
    rev    = "e45153b";
    sha256 = "03m21kbpa45zaspsnfbqx67lndsvw1nv9cyr4s12pr9bbdnvnzzy";
  };

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "67d3cc4";
    sha256 = "04fgmf4q4g7aaw3417zrjxssq1a0kcfakz72mbxgshbinfb4hs4g";
  };
}
