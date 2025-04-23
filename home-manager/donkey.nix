{ c-a-p ? <nixpkgs/pkgs/development/mobile/androidenv/compose-android-packages.nix>
, androidenv ? import <nixpkgs/pkgs/development/mobile/androidenv> {
  inherit pkgs;
  config.android_sdk.accept_license = true;
}
, emulator ? import <nixpkgs/pkgs/development/mobile/androidenv/emulator.nix>
  #((import <nixpkgs> {}).callPackage c-a-p {})
, pkgs ? import <nixpkgs> { overlays = [ (self: super: { pkgsi686Linux = self; }) ]; }
}:

androidenv.emulateApp {
  name = "emulate-MyAndroidApp";
  platformVersion = "32";
  abiVersion = "armeabi-v7a"; # mips, x86, x86_64
  systemImageType = "default";
  app = builtins.path {
    path = /home/manjaro/Downloads + "/Donkey Republic Bike share_15.15.4_APKPure.xapk";
    name = "donkey-bike-15.15.4.xapk";
  };
  package = "com.donkeyrepublic.bike.android";
  activity = "MainActivity";
}
