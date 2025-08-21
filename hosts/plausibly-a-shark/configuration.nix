{ inputs, config, pkgs, systemSettings, userSettings, ... }: {
  imports = [ ../../modules/monitors.nix ];

  monitors = [ ];

  networking.hostName = "plausibly-a-shark";

  hardware = {
    nvidia = {
      open = true; # needed for 50 series
    };
  };
}
