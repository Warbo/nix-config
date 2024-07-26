self: super:

with {
  # Update this as you like, when some packages become out-of-date (e.g. when
  # some online API has made a breaking change)
  rev = "e21630230c77140bc6478a21cd71e8bb73706fce";
  sha256 = "08l6ly2gv2a2z1aqb8rdn4gy6na87a1py2pxnvblgr0kilnkr66m";
}; {
  overrides = {
    nixpkgsUpstream =
      import
        (fetchTarball {
          inherit sha256;
          name = "nixpkgs-${rev}";
          url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
        })
        {
          config = { };
          overlays = [ ];
        };
  };
  tests = { };
}
