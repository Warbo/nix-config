self: super:

with { inherit (super.lib) concatStringsSep makeOverridable mapAttrs; }; {
  overrides = {
    get_iplayer =
      with rec {
        src = self.nix-config-sources.get_iplayer;

        get_iplayer_real =
          {
            ffmpeg,
            get_iplayer,
            perlPackages,
          }:
          self.stdenv.lib.overrideDerivation get_iplayer (oldAttrs: {
            name = "get_iplayer-${src.version}";
            src = src;
            propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
              perlPackages.LWPProtocolHttps
              perlPackages.XMLSimple
              ffmpeg
            ];
          });

        mkPkg =
          {
            ffmpeg,
            get_iplayer,
            perlPackages,
          }:
          self.buildEnv {
            name = "get_iplayer-${src.version}";
            paths = [
              (get_iplayer_real { inherit ffmpeg get_iplayer perlPackages; })
              ffmpeg
              perlPackages.LWPProtocolHttps
              perlPackages.XMLSimple
            ];
          };

        # Some dependencies seem to be missing, so bundle them in with get_iplayer
        pkg = makeOverridable mkPkg {
          inherit (super) ffmpeg get_iplayer perlPackages;
        };

        test = self.hasBinary pkg "get_iplayer";
      };
      self.withDeps [ test ] pkg;
  };

  checks = mapAttrs self.nix-config-version-check {
    get_iplayer = {
      inherit (self.nix-config-sources.get_iplayer) version;
      url = "https://github.com/get-iplayer/get_iplayer/releases";
      script = ''
        EXPR='${
          concatStringsSep "/" [
            ''//a[contains(text(), "Latest release")]''
            ".."
            ".."
            ''/a[contains(@href, "releases/tag")]''
            "text()"
          ]
        }'
        LATEST=$("${self.xidel}/bin/xidel" - -s -e "$EXPR" < "$page")
        echo "\"$LATEST\"" > "$out"
      '';
    };
  };
}
