{ nix-helpers ? (import ./warbo-utilities.nix).warbo-packages.nix-helpers
, linkFarm ? nix-helpers.nixpkgs.linkFarm
, newScope ? nix-helpers.nixpkgs.newScope
, writeShellScriptBin ? nix-helpers.nixpkgs.writeShellScriptBin }:
with rec {
  inherit (nix-helpers) nixDirsIn nixFilesIn nixpkgs-lib suffixedFilesIn;
  inherit (nixpkgs-lib) mapAttrs;

  call = f: newScope nix-helpers f { };

  files = suffixedFilesIn ".sh" ./commands;

  scripts =
    mapAttrs (name: path: writeShellScriptBin name (builtins.readFile path))
    files;

  standalone = mapAttrs (name: call) (nixDirsIn {
    filename = "default.nix";
    dir = ./commands;
  });
};
scripts // standalone
