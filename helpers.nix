{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

{
  nix-helpers = fetchgit {
    url    = http://chriswarbo.net/git/nix-helpers.git;
    rev    = "05182d0";
    sha256 = "1h8jrjrbbab0fymssdwgzl171x6lq817sjd8hzhia7kn5mgm2fib";
  };

  warbo-packages = fetchgit {
    url    = http://chriswarbo.net/git/warbo-packages.git;
    rev    = "6e4a804";
    sha256 = "1aqp5qyvv47cpf16hyv5i41820hjymdbs3xr8czgd8hipjz601zz";
  };

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "956af8c";
    sha256 = "0f387jflfgdzcv01v65vzjvib0b0gc01h7c1a5qnk3gy7gm1d1iy";
  };
}
