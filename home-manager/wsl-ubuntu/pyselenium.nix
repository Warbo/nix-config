with rec {
  inherit (import ../..) nix-helpers;
  inherit (nix-helpers) nixpkgs;
};
{ python3 ? nixpkgs.python3
, socat ? nixpkgs.socat
, writeShellApplication ? nixpkgs.writeShellApplication
}:
writeShellApplication {
  name = "pyselenium";
  runtimeInputs = [ socat ];
  text = ''
    exec ${python3.withPackages (p: [ p.selenium ])}/bin/python3 \
      ${./pyselenium.py} "$@"
  '';
}
