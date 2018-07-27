{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

{
  nix-helpers = fetchgit {
    url    = http://chriswarbo.net/git/nix-helpers.git;
    rev    = "640102c";
    sha256 = "1v8w012v7j2xg30dlh1i4y933v8ykiq3cc3xw4v92qv7pwfai4zf";
  };

  warbo-packages = fetchgit {
    url    = http://chriswarbo.net/git/warbo-packages.git;
    rev    = "13012b3";
    sha256 = "0mnj1lyyi087namn38jlssj4279q3qyslhljfqv8syamsj0br0hp";
  };

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "1ad737d";
    sha256 = "14z39l3vdb8cxlhjj7xcxh1yl38rv8x0l2j832483kb0f74ncp9a";
  };
}
