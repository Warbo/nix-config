self: super:
with self;
with rec {
  src = latestGit { url = https://github.com/sol/tinc.git; };
};
import "${src}/package.nix"
