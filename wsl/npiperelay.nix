{
  buildGoModule,
  fetchFromGitHub,
  go,
  lib,
  stdenv,
}:
with {
  npiperelay-src = fetchFromGitHub {
    owner = "albertony";
    repo = "npiperelay";
    rev = "3ba90d52cb431b8c71c23293dda25a0bb1589f7b";
    sha256 = "1sx19v1gmqkj5yjlfvi923gzxdwgnqds067jh36maz1c4zjpd1by";
  };
};
import
  (fetchFromGitHub {
    owner = "ykis-0-0";
    repo = "npiperelay.nix";
    rev = "60e314f3b84ffee8a48bd159327c19be69fb730b";
    sha256 = "0zv82lqzvdkmg784rm64y9lvj59m3airixpbhszj6bp4mbjygmx6";
  })
  {
    inherit
      buildGoModule
      go
      lib
      stdenv
      ;
    npiperelay = npiperelay-src // {
      shortRev = builtins.substring 0 7 npiperelay-src.rev;
      lastModifiedDate = "19700101";
    };
  }
