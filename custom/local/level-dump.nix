{ latestGit, makeWrapper, nodejs, repo2npm, runCommand }:

runCommand "node-with-level-dump"
  {
    inherit nodejs;
    buildInputs = [ makeWrapper ];
    lup         = repo2npm (latestGit {
                    url = https://github.com/Level/levelup.git;
                  });
    ldown       = repo2npm (latestGit {
                    url = https://github.com/level/leveldown.git;
                  });
    ldump       = repo2npm (latestGit {
                    url = https://github.com/thlorenz/level-dump.git;
                  });
  }
  ''
    mkdir -p "$out/bin"
    makeWrapper "$nodejs/bin/node" "$out/bin/node"   \
      --prefix NODE_PATH : "$lup/lib/node_modules"   \
      --prefix NODE_PATH : "$ldown/lib/node_modules" \
      --prefix NODE_PATH : "$ldump/lib/node_modules" \
      --set NODE_REPL_HISTORY=""                     \
      --set NODE_DISABLE_COLORS=1  # Damn hipsters...
  ''
