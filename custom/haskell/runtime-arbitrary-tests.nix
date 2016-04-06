(import <nixpkgs> {}).haskellGit {
  url = if (import <nixpkgs> {}).localOnly
        then /home/chris/Programming/repos/runtime-arbitrary-tests.git
        else http://chriswarbo.net/git/runtime-arbitrary-tests.git;
}
