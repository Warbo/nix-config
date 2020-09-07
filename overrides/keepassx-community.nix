self: super:

with { inherit (builtins) compareVersions; };
{
  overrides = {
    keepassx-community =
      with rec {
        source = self.nix-config-sources.keepassx-community;

        updated = check: super.keepassx-community.overrideAttrs (old: rec {
          inherit (source) version;
          name        = "keepassxc-${version}";
          src         = self.linkTo { name = name + ".tar.xz"; path = source; };
          buildInputs = old.buildInputs ++ [
            self.asciidoctor                          # Needed for documentation
            self.nixpkgs1709.pkgconfig                # Needed to find qrencode
            self.qt5.qtsvg self.nixpkgs1709.qrencode  # New dependencies
          ];
          checkPhase =
            if check
               then ''
                 export LC_ALL="en_US.UTF-8"
                 export QT_QPA_PLATFORM=offscreen
                 export QT_PLUGIN_PATH="${with self.qt5.qtbase;
                                          "${bin}/${qtPluginPrefix}"}"
                 make test ARGS+="-E testgui --output-on-failure"
               ''
               else builtins.trace ''
                 FIXME: keepassxc tests disabled due to:
                     === Received signal at function time: 300000ms, total time: 301016ms, dumping stack ===
                     === End of stack trace ===
                     QFATAL : TestCli::testAdd() Test function timed out
                     FAIL!  : TestCli::testAdd() Received a fatal error.
                     Loc: [Unknown file(0)]
                 '' ''echo "FIXME: Tests disabled" 1>&2'';
          patches = [];  # One patch is Mac-only, other has been included in src
        });
      };
      # Provide the untested version, but also ensure that the tested
      # version is indeed still failing
      self.withDeps' "keepassxc-unchecked"
                     [ (self.isBroken (updated true)) ]
                     (updated false);

  };

  checks = {
    keepassx-community =
      with {
        latest = import (self.runCommand "latest-keepassxc"
          {
            buildInputs = [ self.utillinux self.xidel ];
            pat  = "//a[contains(text(),'Latest release')]/../..//a/@href";
            page = builtins.fetchurl
              https://github.com/keepassxreboot/keepassxc/releases/latest;
          }
          ''
            mkdir "$out"
            xidel - -q -e "$pat" < "$page"  |
              grep tag                      |
              rev                           |
              cut -d / -f1                  |
              rev                           |
              sed -e 's/^/"/g' -e 's/$/"/g' > "$out/default.nix"
          '');

        source = self.nix-config-sources.keepassx-community;
      };
      super.lib.optional
        (self.onlineCheck && (compareVersions source.version latest != 0))
        (toJSON {
          inherit latest;
          inherit (source) version;
          warning = "KeePassXC version doesn't match latest";
        });
  };
}
