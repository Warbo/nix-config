# Custom Nix Packages #

This directory provides user-specific overrides for the Nix package manager. By
naming it `~/.config/nixpkgs`, it will be automatically loaded by Nix; you could
also load it separately, e.g. via an `import`.

# Layout #

 - `release.nix` is used for testing and continuous integration. It can be
   ignored if you just want to *use* these packages.
 - `config.nix` is loaded by Nix automatically (if it's in `~/.nixpkgs`) and
   used as a source of configuration options. The most important for us is
   `packageOverrides` (described below). Other, less important options are
   loaded from `other.nix`.
 - `custom.nix` defines the `packageOverrides` value used by `config.nix`. It
   combines the definitions from all the top-level `*.nix` files in `custom/`:
    - Each `custom/foo.nix` file is imported.
    - The resulting function is called with `self` and `super` package sets.
    - The resulting attribute set is combined with those of the other files.
    - This combination is used as the value of `packageOverrides`.
 - `custom/` is where we define the contents for `packageOverrides`. Each
   `custom/*.nix` file should provide a (curried) 2-argument function, which
   takes `self` (the overridden package set) as its first argument and `super`
   (the original package set) as its second argument. The function should return
   a set of name/value pairs which will be added to the contents of
   `packageOverrides`. The filenames in `custom/` aren't important, as long as
   they end in `.nix`.
 - `custom/local/*.nix` files define packages more like those in nixpkgs: as a
   function from a set of dependencies to a derivation. The `custom/local.nix`
   file will add these to the `packageOverrides`, using the filename (sans the
   `.nix` suffix) as the attribute name. Most packages should probably go here,
   unless you have a reason otherwise.
 - `custom/haskell/*.nix` define Haskell packages. Each package is named from
   its filename, and will appear in each Haskell package set (e.g. for different
   versions of GHC). This is arranged by `custom/haskell.nix`.

# Important values #

 - `super` is the name we use for the regular, system-wide set of packages. Like
   all values in Nix, `super` cannot be altered; instead, we can provide
   *overrides*, which will be used as-well-as/in-place-of the contents of
   `super`.
 - `packageOverrides` is a function taking `super` as an argument. The result is
   a set of attributes which Nix will *add to* `super` for our user (replacing,
   in the case of overlaps), i.e. `self = super // packageOverrides super`. For
   this reason, the `packageOverrides` should only contain new or overridden
   packages; copying from `super` to `packageOverrides` serves no purpose other
   than invalidating the binary cache. Note that these attributes don't need to
   be "packages" per se, for example they might be helper functions which we
   want to make available globally.
 - `self` is the complete set of Nix packages, including our overrides. Thanks
   to laziness, we can use `self` to define some overrides in terms of others;
   although care should be taken to avoid circular dependencies (i.e. infinite
   loops).
