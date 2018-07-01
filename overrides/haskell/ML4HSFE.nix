self: super: with self;

haskellGit {
  url    = "${repoSource}/ml4hsfe.git";
  stable = {
    rev    = "fa3543e";
    sha256 = "1yaf9r8v1f0grblw31qqy1zc8zjdwq0i96ksyfarkmciydc0rjyi";
  };
}
