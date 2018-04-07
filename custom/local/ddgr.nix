{ nixpkgs1803, super }:

if super ? ddgr
  then builtins.trace "FIXME: Found ddgr in super" super.ddgr
  else nixpkgs1803.ddgr
