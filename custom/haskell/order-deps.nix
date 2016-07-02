self: super: with self;

haskellGit {
  url = onOff http://chriswarbo.net/git/order-deps.git
              "/home/chris/Programming/repos/order-deps.git";
}
