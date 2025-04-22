self: super:
with rec {
  inherit (builtins)
    concatStringsSep
    currentSystem
    getEnv
    fetchTree
    pathExists
    unsafeDiscardStringContext
    ;

  fetchGitIPFS =
    with rec {
      # The version of fetchGitIPFS.nix. Shouldn't need updating often.
      cid = "bafkreihec2oflgbudu5ncpttdyqsjcc74hs4k26b6absfdmqopqogajhj4";
      narHash = "sha256-CgpPlgMjIt3DYVTJYmpdm/V5626f2s5lrEMtGEYQzTU=";

      # fetchTree only takes one URL, so allow it to be overridden by env var.
      override = getEnv "IPFS_GATEWAY";
      gateway = if override == "" then "https://ipfs.io" else override;

      # Workaround for https://github.com/NixOS/nix/issues/12751
      # A derivation which copies 'src'. Since it's fixed-output, the resulting
      # 'outPath' is independent of 'src' (it only depends on 'narHash').
      fixed =
        src:
        derivation {
          name = "source";
          builder = "/bin/sh";
          system = currentSystem;
          outputHashMode = "nar";
          outputHash = narHash;
          args = [
            "-c"
            ''
              exec 1>"$out"
              while IFS= read -r line
              do
                printf "%s\n" "$line"
              done <${src}
              [ -n "$line" ] && printf "%s" "$line"
              exec 1>&-
            ''
          ];
        };
      # See if we already have an outPath for this narHash, by checking with a
      # dummy src: if so, use that path; otherwise call 'fetchTree'. We need
      # unsafeDiscardStringContext to prevent depending on the /dev/null drv
      # (which will fail to build, since it's nonsense). Note that the evaluator
      # seems to cache the result of pathExists; so once fetchTree has run, its
      # outPath will still be assumed to not exist. Running your command again
      # should work though (this is so hacky...)
      existing = unsafeDiscardStringContext (fixed "/dev/null").outPath;
      file =
        if pathExists existing then
          existing
        else
          fixed (fetchTree {
            inherit narHash;
            type = "file";
            url = "${gateway}/ipfs/${cid}";
          });

      raw = import file;
    };
    # super is full of references to self, so reimport with no overlays
    if super ? path then
      raw {
        pkgs = import super.path {
          config = { };
          overlays = [ ];
        };
      }
    else
      raw;
}; {
  overrides.fetchGitIPFS = fetchGitIPFS;
}
