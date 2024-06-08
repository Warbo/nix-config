self: super:

with {
  inherit (builtins) compareVersions toJSON;
  inherit (self.nix-helpers) onlineCheck;
}; {
  overrides = {
    nix-config-version-check =
      name:
      {
        extra ? [ ],
        script,
        url,
        version,
      }:
      with {
        latest = import (
          self.runCommand "latest-${name}.nix" { page = builtins.fetchurl url; } script
        );
      };
      extra
      ++
        super.lib.optional (onlineCheck && compareVersions version latest == -1)
          (toJSON {
            inherit latest version;
            WARNING = "Newer ${name} is available";
          });
  };
}
