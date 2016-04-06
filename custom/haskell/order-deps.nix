(import <nixpkgs> {}).haskellGit {
  url = if (import <nixpkgs> {}).localOnly
           then /home/chris/Programming/repos/order-deps.git
           else http://chriswarbo.net/git/order-deps.git;
}
