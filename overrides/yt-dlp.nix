self: super:

with {
  rev = "e691f848a29bb0e156f08450d7b2604971b91f92";
  sha256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
}; {
  overrides = {
    yt-dlp = self.nixpkgsUpstream.yt-dlp;
  };
  tests = { };
}
