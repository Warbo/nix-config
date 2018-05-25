{ hasBinary, perlPackages, stdenv, withDeps, writeScript }:

with rec {
  pkg = stdenv.lib.overrideDerivation perlPackages.MHonArc (x: {

    # Fixes https://bugzilla.redhat.com/show_bug.cgi?id=1298904
    postInstall = ''
      while read -r F
      do
        echo "Stripping 'defined (%' from $F" 1>&2
        perl -i -pe 's/defined ?\(%/\(%/' "$F"
      done < <(find "$out" -type f -name "*.pl")
    '';

    # Don't include a "devdoc" output, since it's never made
    outputs = [ "out" ];
  });

  tested = withDeps [ (hasBinary pkg "mhonarc") ] pkg;
};
{
  pkg   = tested;
  tests = tested;
}
