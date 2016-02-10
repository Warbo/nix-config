{ withLatestGit }:

withLatestGit { url = http://chriswarbo.net/git/warbo-utilities.git; }
              (x: import "${x}")
