self: super: with { inherit (self.nix-config-sources) firefox; }; {
  overrides = {
    firefoxBinary = self.makeFirefoxBinary (
      # Force output path to end in .tar.bz2 so it unpacks properly
      self.runCommand "firefox-src-${firefox.version}.tar.bz2" {
        raw = firefox.outPath;
      } ''ln -s "$raw" "$out"''
      // {
        inherit (firefox) version;
      }
    );
  };
  checks = super.lib.mapAttrs self.nix-config-version-check {
    firefoxBinary = {
      inherit (firefox) version;
      url = "https://www.mozilla.org/en-US/firefox/releases";
      script = ''
        grep -o 'data-latest-firefox="[^"]*"' < "$page" |
        grep -o '".*"' > "$out"
      '';
    };
  };
}
