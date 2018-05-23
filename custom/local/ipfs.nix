{ hasBinary, latest, nixpkgs1803, self, withDeps }:

with builtins;
with rec {
  stable     = import ../../stableVersion.nix;

  stablePkgs = getAttr stable self;

  stableIpfs = stablePkgs.ipfs;

  newIpfs    = nixpkgs1803.ipfs;

  warning = ''WARNING: Stable IPFS is version ${stableIpfs.version}; our
              override to version ${newIpfs.version} seems to be obsolete.'';

  warn = if compareVersions stableIpfs.version newIpfs.version == -1
            then (x: x)
            else trace warning;

  pkg = warn newIpfs;

  tested = withDeps [ (hasBinary pkg.bin "ipfs") ] pkg;
};
{
  pkg   =   tested;
  tests = [ tested ];
}
