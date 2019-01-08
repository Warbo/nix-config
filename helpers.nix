{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

{
  nix-helpers = fetchgit {
    url    = http://chriswarbo.net/git/nix-helpers.git;
    rev    = "5cecd3f";
    sha256 = "0g4qjciim81wi2hqydmlkxcb1923gaxdln5qx5icyy3639ap6xq3";
  };

  warbo-packages = fetchgit {
    url    = http://chriswarbo.net/git/warbo-packages.git;
    rev    = "e988092";
    sha256 = "082ibmy2q9zvrm85bncm10v29rm53k25dwlgmqgmldfppprxcwja";
  };

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "fd37d11";
    sha256 = "1vgsiclyd2ksi8n8z94m3dd242bm277sc3pjihl6qrw1nkiia82m";
  };
}
