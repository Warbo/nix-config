self: super: with self;

with { ref = "e3ca283"; };
haskellGit {
  inherit ref;
  url      = https://github.com/valderman/ghc-simple.git;
  refIsRev = true;
  stable   = {
    rev    = ref;
    sha256 = "16fjgq4y4cv0fq7p8cs53ifwyvn8fxnzwrq7zysi9pvpisy3k060";
  };
}
