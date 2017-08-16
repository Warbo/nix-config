{}:

with builtins;
if getEnv "GIT_REPO_DIR" == ""
   then "http://chriswarbo.net/git"
        else getEnv "GIT_REPO_DIR"
