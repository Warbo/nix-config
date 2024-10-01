{ lib, pkgs, ... }:
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
    file =
      with { unknown = "sha256-47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU="; };
      lib.mapAttrs'
        (f: hash: {
          name = ".e16/themes/${f}.etheme";
          value.source = pkgs.fetchurl {
            inherit hash;
            url = "https://themes.effx.us/packages/e16/${f}.etheme";
          };
        })
        {
          "23ozGlass" = "sha256-z8qtcyPA8gG09rlPceagrB1UVLzpuLPzuWKdMQlpIwg=";
          # "7teenE" = unknown;
          # "AE" = unknown;
          # "AMC" = unknown;
          # "AbToenAlloyGreen" = unknown;
          # "Absolute_E" = unknown;
          # "Adept-Premier" = unknown;
          # "AeonFlux" = unknown;
          # "Alchemy" = unknown;
          # "AlienConsole" = unknown;
          # "Aliens" = unknown;
          # "Alpha" = unknown;
          # "AluminE" = unknown;
          "Anomoly" = "sha256-Uxum/CR85Bq+LZKc5Kmh4puqbvTpE/UoKnwvUIP/xBY=";
          # "Antarctic" = unknown;
          # "Aphex" = unknown;
          # "Aphex2" = unknown;
          # "ApplePlatinum" = unknown;
          # "Aqua" = unknown;
          # "Aqua-Graphite" = unknown;
          # "Arctic" = unknown;
          # "Arietta" = unknown;
          # "Aspen" = unknown;
          # "Axios" = unknown;
          # "Azteker" = unknown;
          # "Azundris" = unknown;
          # "Azurepolymer" = unknown;
          # "B-42" = unknown;
          # "BS-E" = unknown;
          # "Base" = unknown;
          # "BevelFree" = unknown;
          "Black" = "sha256-9dAhH1tp9CT0Z0Rf/mWEylvHMleUcwU41sBL8TM8/TA=";
          "Black_E" = "sha256-6gVYkiJ+6U5SASqWi7RPj2UWVM/0WGk4Kn8AKmCpj3g=";
          # "Black_and_White" = unknown;
          # "Black_and_Wine" = unknown;
          # "BluNite-BH" = unknown;
          # "Blue.sh" = unknown;
          "BlueHeart" = "sha256-rsVs41eQmyV1DBm8OcNQg+d09F1oUWWnsEuwLQjRbpk=";
          # "BlueIce" = unknown;
          # "BlueOS" = unknown;
          "BlueSteel" = "sha256-yfJ36oil9yHDxgOnITdOg7uO5iloGwBcnbvNtFVB9bM=";
          # "BlueyPurple" = unknown;
          "Brass" = "sha256-eOaShnLMWU7seXt3mJkB6UBoIAp7/U5ZAfx/xNcewIw=";
          "BrassAlloy" = "sha256-TAw+rr+TwKfqcLMoJTE/bNZGJXzET1m7caC75Pamzxk=";
          # "BrushedMetal" = unknown;
          # "BrushedMotif" = unknown;
          # "BurgandE" = unknown;
          # "CD-E" = unknown;
          # "CakeWoman" = unknown;
          # "CandyCane" = unknown;
          # "Chaos" = unknown;
          # "Chrome" = unknown;
          # "ChromiumNoise" = unknown;
          # "Circuit_E" = unknown;
          # "Classic" = unknown;
          # "Comely" = unknown;
          # "Cored" = unknown;
          # "Crazy-Phish" = unknown;
          # "Creative" = unknown;
          # "Cronos" = unknown;
          # "Cyrus" = unknown;
          # "DAE" = unknown;
          # "Dark-pRP" = unknown;
          "DarkAlloy" = "sha256-ffvlXkRmS5mD5qNQwaLc3PSg8zu1hC65omRN2O216Oo=";
          # "DarkGlow" = unknown;
          "DarkOne" = "sha256-1//OSVJpTtUIaMt4lmdkQlQktUhP5RusChc2nF6tx8I=";
          # "DeepBlue" = unknown;
          # "Detroit" = unknown;
          # "DirtChamber" = unknown;
          "DreamWorks" = "sha256-T98l5Lj6McfFoUOWpfFF+OERw+0HKSv7/wBncj8EcPw=";
          # "Dufrenite" = unknown;
          # "E-Tech" = unknown;
          # "E-TechHydro" = unknown;
          # "EMOZ" = unknown;
          # "Eazel" = unknown;
          # "Ecdysis" = unknown;
          # "EcdysisV2" = unknown;
          # "Egradient" = unknown;
          # "Elevator" = unknown;
          # "ElfWood" = unknown;
          # "Ergonomy" = unknown;
          # "Esizer" = unknown;
          # "Et1" = unknown;
          # "EvilJester" = unknown;
          # "Evolution" = unknown;
          # "FinalE" = unknown;
          # "ForestGreenBig" = unknown;
          "Fossils_of_the_Machine" = "sha256-NzoVkS23CCJmKHGMSgGQvvFfuFck1+zosRu/LombqG4=";
          # "FreeFall" = unknown;
          # "Frub" = unknown;
          # "GTK+" = unknown;
          # "Ganymede" = unknown;
          # "Geesh" = unknown;
          # "Genesis" = unknown;
          # "Get-E" = unknown;
          # "Glyph" = unknown;
          # "GradiEnt" = unknown;
          # "Graphiti" = unknown;
          # "GreyMarble" = unknown;
          # "H2O" = unknown;
          # "HackerGreen" = unknown;
          # "HackerGreen138" = unknown;
          # "HackerPurple" = unknown;
          # "HandOfGod" = unknown;
          # "Hazard" = unknown;
          # "Heat" = unknown;
          # "IDs-MachinE" = unknown;
          # "IReX" = unknown;
          # "IceBerg" = unknown;
          # "Illumination" = unknown;
          # "Inbred" = unknown;
          # "Industrial" = unknown;
          # "Inferno" = unknown;
          # "Jander" = unknown;
          # "JavaSteel" = unknown;
          # "Jedi" = unknown;
          # "K10K" = unknown;
          # "K5-FVWM" = unknown;
          # "LCARS" = unknown;
          # "LCDonE" = unknown;
          # "LW2" = unknown;
          # "Lave" = unknown;
          # "Le_Mans" = unknown;
          # "LightOne" = unknown;
          # "LightsDark" = unknown;
          # "Liquid_E" = unknown;
          # "LiteGnome" = unknown;
          # "Luddite" = unknown;
          # "M0kh3" = unknown;
          # "Mac3D" = unknown;
          # "Marble" = unknown;
          # "Marbles" = unknown;
          # "Matrix" = unknown;
          # "Maw" = unknown;
          # "Men_In_Black" = unknown;
          # "Metallique" = unknown;
          # "Midnight" = unknown;
          # "MinEguE" = unknown;
          # "MinEguE_Cut" = unknown;
          # "Moon" = unknown;
          # "MorphiusX" = unknown;
          # "Mozilla-modern" = unknown;
          # "MuffyBig" = unknown;
          # "NQBE" = unknown;
          # "Nebula" = unknown;
          # "Nebulon" = unknown;
          # "Neuromancer" = unknown;
          # "Neuromancer2" = unknown;
          # "NewSTEP" = unknown;
          # "Night" = unknown;
          # "Nix" = unknown;
          # "No_Frills" = unknown;
          # "NorthernLights" = unknown;
          # "OPENSTEP" = unknown;
          # "Oblivion" = unknown;
          # "Obsidian" = unknown;
          # "OldE" = unknown;
          # "OldE-Black" = unknown;
          # "OrangeJuice" = unknown;
          # "Parallelogram" = unknown;
          # "ParodE" = unknown;
          # "Phlat" = unknown;
          # "Pipes3D" = unknown;
          # "Plastique" = unknown;
          # "PoDRaCeR" = unknown;
          # "Presence" = unknown;
          # "PsuedoMac" = unknown;
          # "PurpleNight" = unknown;
          # "QN-X11" = unknown;
          # "R-9X" = unknown;
          # "Razor" = unknown;
          # "Rebound" = unknown;
          # "RunEs" = unknown;
          # "RustE" = unknown;
          # "Sedation" = unknown;
          # "Sensible" = unknown;
          # "SentiEnce" = unknown;
          # "Shade" = unknown;
          # "Shagpad" = unknown;
          # "ShinyMetal" = unknown;
          # "SilverLining" = unknown;
          # "SilverMania" = unknown;
          # "SilverWM" = unknown;
          # "Simplicity" = unknown;
          # "SkiE" = unknown;
          # "Sleep" = unknown;
          # "Slick" = unknown;
          # "Small_E" = unknown;
          # "SnapE" = unknown;
          # "SpaceStation" = unknown;
          # "SphereBlast" = unknown;
          # "SpiffE" = unknown;
          # "Spitfire2" = unknown;
          # "Spring" = unknown;
          # "StarEnli" = unknown;
          # "Stardome" = unknown;
          # "StylE" = unknown;
          # "SuedE" = unknown;
          # "Summer" = unknown;
          # "Sun" = unknown;
          # "Sunset" = unknown;
          # "ThiNicE" = unknown;
          # "ThinGradient" = unknown;
          # "TinyPlatinum" = unknown;
          # "Tubular" = unknown;
          # "Unity" = unknown;
          # "Viridis" = unknown;
          # "Vox" = unknown;
          # "VoxDesert" = unknown;
          # "Warp" = unknown;
          # "WashedBlue" = unknown;
          # "Winter" = unknown;
          # "Wireframe" = unknown;
          "Workbench" = "sha256-WoOj+yfSwBVk2YTc+7B5PJ7Ihcdi3XkFuN4qFCjlUhw=";
          # "X11" = unknown;
          # "XPe" = unknown;
          # "Yell-O-E" = unknown;
          # "Yellow" = unknown;
          # "e13" = unknown;
          # "eGirl" = unknown;
          # "eLap" = unknown;
          # "eMac" = unknown;
          # "eSlate" = unknown;
        };
  };
}
