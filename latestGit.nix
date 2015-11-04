# Allow git repos to be used without pre-determined revisions or hashes, in the
# same way we can use `src = ./.`.
#
# For example:
#
# let latestGit = import /path/to/latestGit.nix
#  in stdenv.mkDerivation {
#       name = "My Project";
#       src  = latestGit "http://example.com/project.git";
#     }

with import <nixpkgs> {};
with builtins;

# All we need is a URL. Other values can be set by overrides.
url: let

  # Get the commit ID of a git repo's HEAD. Version with currentTime to
  # invalidate the cache. This is a cheap operation and needs to be up-to-date.
  getHeadRev = stdenv.mkDerivation {
    inherit url;
    name        = "repo-head-${hashString "sha256" url}";
    version     = toString currentTime;
    builder     = ./latestGitBuilder.sh;
    buildInputs = [ git gnused ];
  };

  # Extract the commit ID as a string. Ignore how we got it, since fetching git
  # repos is expensive and we don't want to invalidate caches unnecessarily.
  rev = unsafeDiscardStringContext (readFile "${getHeadRev}");

  # fetchgit does all of the hard work, but it requires a hash. Make one up.
  fg = fetchgit {
    inherit url rev;

    # Dummy hash
    sha256 = hashString "sha256" url;
  };

# Use the result of fetchgit, but throw away all of the made up hashes; Nix will
# calculate fresh ones, rather than complaining.
in stdenv.lib.overrideDerivation fg (old: {
    outputHash     = null;
    outputHashAlgo = null;
    outputHashMode = null;
    sha256         = null;
  })
