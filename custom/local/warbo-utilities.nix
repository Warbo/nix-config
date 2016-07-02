{ onOff, withLatestGit }:

withLatestGit {
  url      =  onOff http://chriswarbo.net/git/warbo-utilities.git
                    "/home/chris/Programming/repos/warbo-utilities.git";
  srcToPkg = (x: import "${x}");
}
