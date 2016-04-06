let source = (import <nixpkgs> {}).latestGit {
      url =  if (import <nixpkgs> {}).localOnly
                then /home/chris/Programming/repos/ml4hs.git
                else http://chriswarbo.net/git/ml4hs.git;
    };
 in import "${source}"
