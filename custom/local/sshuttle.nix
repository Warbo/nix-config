{ hasBinary, nixpkgs1603, withDeps }:

with rec {
  pkg    = nixpkgs1603.sshuttle;

  tested = withDeps [ (hasBinary pkg "sshuttle") ] pkg;
};
{
  pkg   = tested;
  tests = tested;
}
