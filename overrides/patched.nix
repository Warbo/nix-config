# Packages with our own custom patches, for things other than breakages (i.e.
# not backports or issues that should be resolved upstream). For example, some
# projects are configured at build time rather than reading config files at
# runtime (e.g. suckless projects)
self: super:

{
  overrides = {
    dvtm = super.dvtm.override {
      callPackage = f: args: super.callPackage f (args // {
        patches = args.patches or [] ++ [
          # Make the bstack layout first, so it's used by default
          (builtins.toFile "dvtm-layout.patch" ''
            --- a/config.def.h	2019-08-12 13:52:45.071756726 +0100
            +++ b/config.def.h	2019-08-12 13:53:35.231176305 +0100
            @@ -63,9 +63,9 @@

             /* by default the first layout entry is used */
             static Layout layouts[] = {
            +	{ "TTT", bstack },
             	{ "[]=", tile },
             	{ "+++", grid },
            -	{ "TTT", bstack },
             	{ "[ ]", fullscreen },
             };
          '')

          # Use Ctrl-b as modifier
          (builtins.toFile "dvtm-mod.patch" ''
            --- a/config.def.h	2019-08-12 13:52:45.071756726 +0100
            +++ b/config.def.h	2019-08-12 14:05:11.313498641 +0100
            @@ -69,7 +69,7 @@
             	{ "[ ]", fullscreen },
             };

            -#define MOD  CTRL('g')
            +#define MOD  CTRL('b')
             #define TAGKEYS(KEY,TAG) \
          '')
        ];
      });
    };
  };

  tests = {};
}
