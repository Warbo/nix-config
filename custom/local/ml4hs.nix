let source = (import <nixpkgs> {}).latestGit {
      url = "http://chriswarbo.net/git/ml4hs.git";
    };
 in import "${source}"
