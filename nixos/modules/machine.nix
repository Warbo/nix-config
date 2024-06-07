{
  config,
  lib,
  pkgs,
  ...
}:
with {
  macbook = { };
  pinephone = import ../machines/pinephone.nix { inherit config lib pkgs; };
  thinkpad = import ../machines/thinkpad.nix { inherit config lib pkgs; };
};
{
  options.machine = lib.mkOption {
    type = lib.types.enum [
      "macbook"
      "pinephone"
      "thinkpad"
    ];
    description = ''
      Which machine-specific config to use for this system.
    '';
  };

  imports =
    /*
      lib.mkIf (config.machine == "pinephone") [
        (import "${
          (import ../nix/sources.nix).mobile-nixos.outPath
        }/lib/configuration.nix" { device = "pine64-pinephone"; })
      ];
    */
    [ ];

  config = lib.mkMerge [
    (lib.mkIf (config.machine or "" == "macbook") macbook)
    (lib.mkIf (config.machine or "" == "pinephone") pinephone)
    (lib.mkIf (config.machine or "" == "thinkpad") thinkpad)
  ];
}
