{ lib, pkgs, ... }:
with rec {
  e16Theme = name: hash: {
    name = ".e16/themes/${name}.etheme";
    value.source = pkgs.fetchurl {
      inherit hash;
      url = "https://themes.effx.us/packages/e16/${name}.etheme";
    };
  };

  e16Themes = lib.mapAttrs' e16Theme {
    "23ozGlass" = "sha256-z8qtcyPA8gG09rlPceagrB1UVLzpuLPzuWKdMQlpIwg=";
    "Anomoly" = "sha256-Uxum/CR85Bq+LZKc5Kmh4puqbvTpE/UoKnwvUIP/xBY=";
    "Black" = "sha256-9dAhH1tp9CT0Z0Rf/mWEylvHMleUcwU41sBL8TM8/TA=";
    "Black_E" = "sha256-6gVYkiJ+6U5SASqWi7RPj2UWVM/0WGk4Kn8AKmCpj3g=";
    "BlueHeart" = "sha256-rsVs41eQmyV1DBm8OcNQg+d09F1oUWWnsEuwLQjRbpk=";
    "BlueSteel" = "sha256-yfJ36oil9yHDxgOnITdOg7uO5iloGwBcnbvNtFVB9bM=";
    "Brass" = "sha256-eOaShnLMWU7seXt3mJkB6UBoIAp7/U5ZAfx/xNcewIw=";
    "BrassAlloy" = "sha256-TAw+rr+TwKfqcLMoJTE/bNZGJXzET1m7caC75Pamzxk=";
    "DarkAlloy" = "sha256-ffvlXkRmS5mD5qNQwaLc3PSg8zu1hC65omRN2O216Oo=";
    "DarkOne" = "sha256-1//OSVJpTtUIaMt4lmdkQlQktUhP5RusChc2nF6tx8I=";
    "DreamWorks" = "sha256-T98l5Lj6McfFoUOWpfFF+OERw+0HKSv7/wBncj8EcPw=";
    "Fossils_of_the_Machine" = "sha256-NzoVkS23CCJmKHGMSgGQvvFfuFck1+zosRu/LombqG4=";
    "Workbench" = "sha256-WoOj+yfSwBVk2YTc+7B5PJ7Ihcdi3XkFuN4qFCjlUhw=";
  };
};
{
  xsession.preferStatusNotifierItems = true;
  services.network-manager-applet.enable = true;
  services.pass-secret-service.enable = true;
  systemd.user.targets.tray = {
    # Some Home Manager applets need this. Copypasta from Home Manager modules
    # which provide desktop sessions, since we're using LXQt from NixOS instead.
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session.target" ];
    };
  };
  home = {
    file = e16Themes;
  };
}
