# Custom Nix Packages #

This directory provides user-specific overrides for the Nix package manager.

# Layout #

 - `config.nix` is loaded by Nix automatically and used as a source of configuration options. The most important for us is `packageOverrides` (described below), which is the union of all the top-level *.nix files in `custom/` (i.e. we don't recurse into sub-directories of custom/).
 - `custom/` is where we define the results of `packageOverrides`. Each *.nix file in `custom/` should provide a function, which will be given `pkgs` as its argument and should return a set of attributes; these will be added to the result of `packageOverrides`. The filenames in `custom/` aren't important, as long as they end in `.nix`.
 - `custom/imports/` lets us define named expressions. A file called `custom/imports/foo.nix` will cause an attribute named `foo` to appear in `<nixpkgs>`, whose value corresponds to `import custom/imports/foo.nix`. The expressions in `custom/imports/` are mostly special cases; consider using friendlier alternatives like `custom/local/` instead.
 - `custom/local/` lets us define named packages. Basically the same as `custom/imports/`, but values will have the form `callPackage custom/local/foo.nix {}` rather than just a plain `import`. Most regular packages should probably go here.
 - `custom/haskell/` is where Haskell packages should go. Rather than appearing directly in `<nixpkgs>`, they will instead appear inside the compiler-specific sets of Haskell packages. `haskellPackages` is the default, but others include e.g. `haskell.packages.ghc784` for GHC 7.8.4.

# Important values #

 - `pkgs` is the name we use for the regular, system-wide set of packages. Like all values in Nix, `pkgs` cannot be altered; instead, we can provide *overrides*, which will be used as-well-as/in-place-of the contents of `pkgs`.
 - `packageOverrides` is a function taking `pkgs` as an argument. The result is a set of attributes which Nix will *add to* `pkgs` for our user (replacing, in the case of overlaps). For this reason, the contents of `pkgs` *should not* appear in the result; doing so will effectively override *everything*, and cause the whole system to be recompiled from scratch! Note that these attributes don't need to be packages, for example they might be helper functions which we want to make available globally.
 - `<nixpkgs>` is (the path of) the function for accessing the complete set of Nix packages. By using `import <nixpkgs> {}` we can access the *overridden* set of packages. Thanks to laziness, we can use this to define some overrides in terms of others; although care should be taken to avoid circular dependencies (i.e. infinite loops).
