{ withLatestGit }:

withLatestGit {
  url      = http://chriswarbo.net/git/warbo-utilities.git;
  srcToPkg = (x: import "${x}");
}
