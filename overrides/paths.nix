# Useful paths
self: super:

with builtins;
{
  overrides = {
    configSrc = ./..;

    # Useful for getting warbo-* git repositories from a local mirror
    repoSource =
      with {
        env = getEnv "GIT_REPO_DIR";
        dir = /home/chris/Programming/repos;
      };
      if env != ""
         then env
         else if pathExists dir
                 then toString dir
                 else "http://chriswarbo.net/git";
  };

  tests = {};
}
