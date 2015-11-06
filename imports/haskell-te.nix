with import <nixpkgs> {};

callPackage (latestGit { url = http://chriswarbo.net/git/haskell-te.git; }) {}
