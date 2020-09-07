self: super: {
  overrides = {
    firefoxBinary = self.makeFirefoxBinary self.nix-config-sources.firefox;
  };
  checks = super.lib.mapAttrs self.nix-config-version-check {
    firefoxBinary = {
      inherit (self.nix-config-sources.firefox) version;
      url    = https://www.mozilla.org/en-US/firefox/releases;
      script = ''
        grep -o 'data-latest-firefox="[^"]*"' < "$page" |
        grep -o '".*"' > "$out"
      '';
    };
  };
}
