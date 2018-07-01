{}:

with builtins;
with {
  env = getEnv "GIT_REPO_DIR";
  dir = /home/chris/Programming/repos;
};
if env != ""
   then env
   else if pathExists dir
           then toString dir
           else "http://chriswarbo.net/git"
