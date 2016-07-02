# Allow git repos to be used without pre-determined revisions or hashes, in the
# same way we can use `src = ./.`.
#
# For example:
#
# let latestGit = import /path/to/latestGit.nix
#  in stdenv.mkDerivation {
#       name = "My Project";
#       src  = latestGit { url = "http://example.com/project.git"; };
#     }
#
# TODO: This duplicates some functionality of fetchgitrevision; wait for that
# API to settle down, then use it here.

self: super:

with self;
with builtins;

{

# We need the url, but ref is optional (e.g. if we want a particular branch)
latestGit = { url, ref ? "HEAD" }:

let

  hUrl   = builtins.hashString "sha256" url;
  hRef   = builtins.hashString "sha256" ref;
  key    = "${hUrl}_${hRef}";
  envRev = builtins.getEnv "nix_git_rev_${key}";

  # Get the commit ID for the given ref in the given repo. Use currentTime as a
  # version to avoid caching. This is a cheap operation and needs to be
  # up-to-date.
  getHeadRev = stdenv.mkDerivation {
    name    = "repo-head-${hUrl}";
    version = toString currentTime;

    # Required for SSL
    GIT_SSL_CAINFO = "${cacert}/etc/ssl/certs/ca-bundle.crt";

    buildInputs  = [ git gnused ];
    buildCommand = ''
      source $stdenv/setup
      # printf is an ugly way to avoid trailing newlines
      printf "%s" $(git ls-remote "${url}" "${ref}" |
                    head -n1                        |
                    sed -e 's/\s.*//g'              ) > "$out"
    '';
  };

  # Extract the commit ID as a string. Ignore how we got it, to avoid cache
  # misses (unlike commit IDs, git repos are expensive).
  newRev = unsafeDiscardStringContext (readFile "${getHeadRev}");

  rev = if envRev == "" then newRev else envRev;

  # fetchgit does all of the hard work, but it requires a hash. Make one up.
  fg = fetchgit {
    inherit url rev;

    # Dummy hash
    sha256 = hUrl;
  };

# Use the result of fetchgit, but throw away all of the made up hashes; Nix will
# calculate fresh ones, rather than complaining.
in stdenv.lib.overrideDerivation fg (old: {
    outputHash     = null;
    outputHashAlgo = null;
    outputHashMode = null;
    sha256         = null;
  });

}
