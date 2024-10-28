{
  description = "Geospatial packages repository and overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule

      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ self.overlays.geonix ];
        };

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        packages = {
          # libs
          gdal = pkgs.gdal;
          gdal-minimal = pkgs.gdalMinimal;
          geos = pkgs.geos;
          libgeotiff = pkgs.libgeotiff;
          librttopo = pkgs.librttopo;
          libspatialindex = pkgs.libspatialindex;
          libspatialite = pkgs.libspatialite;
          pdal = pkgs.pdal;
          proj = pkgs.proj;

          # Python packages
          python3-fiona = pkgs.python3Packages.fiona;
          python3-gdal = pkgs.python3Packages.gdal;
          python3-geopandas = pkgs.python3Packages.geopandas;
          python3-owslib = pkgs.python3Packages.owslib;
          python3-psycopg = pkgs.python3Packages.psycopg;
          python3-pyogrio = pkgs.python3Packages.pyogrio;
          python3-pyproj = pkgs.python3Packages.pyproj;
          python3-pystac = pkgs.python3Packages.pystac;
          python3-rasterio = pkgs.python3Packages.rasterio;
          python3-shapely = pkgs.python3Packages.shapely;

          # PostgreSQL packages
          postgresql-postgis = pkgs.postgresqlPackages.postgis;

          # apps
          qgis = pkgs.qgis;
          grass = pkgs.grass;

          # services
          pg_featureserv = pkgs.pg_featureserv;
          pg_tileserv = pkgs.pg_tileserv;

          # other
          nixGLIntel = inputs'.nixgl.packages.nixGLIntel;
        };
      };

      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
        overlays.geonix = final: prev: {

          # FIXME: remove overrides below
          # gdal = prev.gdal.overrideAttrs (prev: { version = "1000"; });
          # gdalMinimal = prev.gdal.overrideAttrs
          #   (prev: {
          #     useMinimalFeatures = true;
          #   });

          # Default Python version
          python3Packages = prev.python311Packages;
          python3 = prev.python311;

          # Default PostgreSQL version
          postgresqlPackages = prev.postgresql15Packages;
          postgresql = prev.postgresql_15;
        };
      };
    };
}
