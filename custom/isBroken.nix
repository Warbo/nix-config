self: super:
with self;

{
  # Wrap the buildCommand in a script which checks whether it fails. Note that
  # we do this in a crude way by replacing the attribute, rather than using some
  # override function; this is to ensure that buildCommand contains everything
  # needed (e.g. phases, etc.)
  isBroken = drv:
    with rec {
      orig = if drv ? buildCommand
                then writeScript "buildCommand-${drv.name}" drv.buildCommand
                else writeScript "builder-${drv.name}" ''
                  #!${bash}/bin/bash
                  "${drv.builder}" ${toString (drv.args or [])}
                '';
      newBuildScript = writeScript "isBroken-${drv.name}-script" ''
        if "${orig}"
        then
          echo "Derivation '${drv.name}' should have failed; didn't" 1>&2
          exit 1
        fi
        echo "${drv.name} is broken" > "$out"
      '';
    };
    # As per https://github.com/NixOS/nixpkgs/issues/4017
    lib.overrideDerivation drv (old: {
      name    = "isBroken-${drv.name}";
      builder = "${bash}/bin/bash";
      args    = [ "-e" newBuildScript ];
    });
}
