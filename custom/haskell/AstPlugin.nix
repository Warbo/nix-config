(import <nixpkgs> {}).haskellGit {
  url = if (import <nixpkgs> {}).localOnly
           then "/home/chris/Programming/repos/ast-plugin.git"
           else http://chriswarbo.net/git/ast-plugin.git;
}
