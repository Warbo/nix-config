self: super:

with {
  inherit (builtins) compareVersions toJSON;
};
{
  overrides = {
    nix-config-version-check = name: { extra ? [], script, url, version }:
      with {
        latest = import (self.runCommand "latest-${name}.nix"
          { page = builtins.fetchurl url; }
          script);
      };
      extra ++ super.lib.optional
        (self.onlineCheck && compareVersions version latest == -1)
        (toJSON {
          inherit latest version;
          WARNING = "Newer ${name} is available";
        });
  };
}
