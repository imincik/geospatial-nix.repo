{
  description = "Geospatial NIX";

  nixConfig = {
    extra-substituters = [
      "https://geonix-rolling.cachix.org"
    ];
    extra-trusted-public-keys = [
      "geonix-rolling.cachix.org-1:27FqadR8Jqcwl+OY7+JvhRJoWixjMwX8xrwc6kIBnDo="
    ];
    bash-prompt = "\\[\\033[1m\\][geonix]\\[\\033\[m\\]\\040\\w >\\040";
  };

  inputs = {
    geonix.url = "path:../../.";
    nixpkgs.follows = "geonix/nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.geonix.overlays.geonix ];
          config.allowUnfree = true;
        };

        packages = {
          qgis-plugin = pkgs.qgisPlugins.qgis2web;
        };
      };

      flake = { };
    };
}
