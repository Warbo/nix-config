self: super:
with {
  inherit (builtins)
    compareVersions
    fetchurl
    foldl'
    getAttr
    mapAttrs
    toJSON
    trace
    ;
  inherit (super.lib)
    concatStringsSep
    genAttrs
    makeOverridable
    optional
    ;
};
{
  overrides = {
    youtube-dl =
      with rec {
        src = self.nix-config-sources.youtube-dl;

        override = super.youtube-dl.overrideDerivation (old: {
          inherit (src) version;
          name = "youtube-dl-${src.version}";
          src  = src;
        });
      };
      foldl' (x: msg: trace msg x) override self.nix-config-checks.youtube-dl;
  };

  checks = super.lib.mapAttrs self.nix-config-version-check {
    youtube-dl = {
      inherit (self.nix-config-sources.youtube-dl) version;
      url    = https://ytdl-org.github.io/youtube-dl/download.html;
      script = ''
        grep   -o '[^"]*\.tar\.gz' < "$page" |
        head -n1                           |
        grep -o 'youtube-dl-.*\.tar.gz'    |
        cut  -d - -f3                      |
        cut  -d . -f 1-3                   |
        sed  -e 's/\(.*\)/"\1"/g'          > "$out"
      '';
      extra =
        with {
        ours     = self.nix-config-sources.youtube-dl.version;
        packaged = self.nixpkgsLatest.youtube-dl.version;
      };
      optional (compareVersions ours packaged < 1) (toJSON {
        inherit ours packaged;
        WARNING = "New youtube-dl is in nixpkgs";
      });
    };
  };
}
