self: super:

with builtins;
with rec {
  haveAgda = super.haskellPackages ? Agda;

  agdaWorks = haveAgda && (tryEval super.haskellPackages.Agda).success;

  warning = ''
    WARNING: haskellPackages.Agda seems to work upstream; our override might not
    be needed anymore.
  '';

  warner = if agdaWorks then trace warning else (x: x);
};

warner self.nixpkgs1609.haskellPackages.Agda.override
