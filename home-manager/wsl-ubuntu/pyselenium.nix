with rec {
  inherit (import ../..) nix-helpers;
  inherit (nix-helpers) nixpkgs;
};
{ python3 ? nixpkgs.python3
, writeShellApplication ? nixpkgs.writeShellApplication
}:
writeShellApplication {
  name = "pyselenium";
  text = ''
    exec ${python3.withPackages (p: [ p.selenium ])}/bin/python3 \
      ${./pyselenium.py} "$@"
  '';
}
