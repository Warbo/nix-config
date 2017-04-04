{ callPackage, fetchFromGitHub, nodejs, nodePackages, recurseIntoAttrs, runCommand }:

with builtins;
with rec {
  ipfsSyncNix = runCommand "ipfs-sync"
    {
      buildInputs = [ nodePackages.node2nix ];
      repo = fetchFromGitHub {
        owner  = "fazo96";
        repo   = "ipfs-sync";
        rev    = "1d1be31";
        sha256 = "07r3qskqhrs91hvn80ld3gsznhmij5lbnmv8z556rg5kzh6v4phd";
      };
    }
    ''
      cp -r "$repo" "$out"
      chmod +w -R "$out"
      cd "$out"
      node2nix
    '';

  generatedPackages = callPackage "${ipfsSyncNix}" {};
};

generatedPackages.package
