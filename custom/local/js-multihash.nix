{ latestGit, makeWrapper, nodejs, repo2npm, runCommand }:

runCommand "node-with-js-multihash"
  {
    inherit nodejs;
    buildInputs = [ makeWrapper ];
    cid         = repo2npm (latestGit {
                    url = https://github.com/ipld/js-cid.git;
                  });
    multibase   = repo2npm (latestGit {
                    url = https://github.com/multiformats/js-multibase.git;
                  });
    multihash   = repo2npm (latestGit {
                    url = https://github.com/multiformats/js-multihash.git;
                  });
  }
  ''
    mkdir -p "$out/bin"
    makeWrapper "$nodejs/bin/node" "$out/bin/node"       \
      --prefix NODE_PATH : "$cid/lib/node_modules"       \
      --prefix NODE_PATH : "$multibase/lib/node_modules" \
      --prefix NODE_PATH : "$multihash/lib/node_modules" \
      --set NODE_REPL_HISTORY=""                         \
      --set NODE_DISABLE_COLORS=1  # Damn hipsters...
  ''
