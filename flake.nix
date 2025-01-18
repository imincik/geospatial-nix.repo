{
  description = "Rolling geospatial packages repository and Nix overlay";

  nixConfig = {
    extra-substituters = [ "https://geonix-rolling.cachix.org" ];
    extra-trusted-public-keys = [ "geonix-rolling.cachix.org-1:27FqadR8Jqcwl+OY7+JvhRJoWixjMwX8xrwc6kIBnDo=" ];

    bash-prompt = "\\[\\033[1m\\][geonix]\\[\\033\[m\\]\\040\\w >\\040";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ self.overlays.geonix ];
          config.allowUnfree = true;
        };

        # Packages
        packages =
          {
            # Libs
            gdal = pkgs.gdal;
            gdal-minimal = pkgs.gdalMinimal;
            gdal-master = pkgs.gdal-master;

            geos = pkgs.geos;
            libgeotiff = pkgs.libgeotiff;
            libLAS = pkgs.libLAS;
            libosmium = pkgs.libosmium;
            librttopo = pkgs.librttopo;
            libspatialindex = pkgs.libspatialindex;
            libspatialite = pkgs.libspatialite;
            libtiff = pkgs.libtiff;
            pdal = pkgs.pdal;
            proj = pkgs.proj;
            shapelib = pkgs.shapelib;

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

            # Tools
            dcw-gmt = pkgs.dcw-gmt;
            entwine = pkgs.entwine;
            gmt = pkgs.gmt;
            gshhg-gmt = pkgs.gshhg-gmt;
            ili2c = pkgs.ili2c;
            LAStools = pkgs.LAStools;
            mapnik = pkgs.mapnik;
            osm2pgsql = pkgs.osm2pgsql;
            osmium-tool = pkgs.osmium-tool;
            pmtiles = pkgs.pmtiles;
            protozero = pkgs.protozero;
            tippecanoe = pkgs.tippecanoe;

            # Apps
            grass = pkgs.grass;
            openjump = pkgs.openjump;
            qgis = pkgs.qgis;
            qgis-ltr = pkgs.qgis-ltr;
            saga = pkgs.saga;
            spatialite-gui = pkgs.spatialite-gui;

            # Services
            geoserver = pkgs.geoserver;
            mapcache = pkgs.mapcache;
            mapproxy = pkgs.mapserver;
            mapserver = pkgs.mapserver;
            mbtileserver = pkgs.mbtileserver;
            pg_featureserv = pkgs.pg_featureserv;
            pg_tileserv = pkgs.pg_tileserv;
            tegola = pkgs.tegola;
            tile38 = pkgs.tile38;
            # t-rex = pkgs.t-rex;

            # Other
            nixGL = pkgs.nixGL;

            # Meta packages
            all-packages = pkgs.symlinkJoin {
              name = "all-packages";
              paths = pkgs.lib.attrValues (pkgs.lib.filterAttrs (n: v: n != "all-packages") self'.packages);
            };
          }
          // (pkgs.lib.mapAttrs'
            (
              name: value: { name = "grass-plugin-" + name; value = value; }
            )
            pkgs.grassPlugins)

          // (pkgs.lib.mapAttrs'
            (
              name: value: { name = "qgis-plugin-" + name; value = value; }
            )
            pkgs.qgisPlugins)

          // (pkgs.lib.mapAttrs'
            (
              name: value: { name = "qgis-ltr-plugin-" + name; value = value; }
            )
            pkgs.qgisLTRPlugins);

        # Shells
        devShells = import ./shells.nix { inherit self' pkgs; };

        # Checks
        checks = import ./checks.nix { inherit self' pkgs; nixpkgs = inputs.nixpkgs; };
      };

      flake =
        let
          lib = inputs.nixpkgs.lib;

          recurseIntoOverlayAttrs = overlay:
            final: prev:
              let
                recurse = lib.mapAttrs (
                  name: value:
                    if lib.isAttrs value && ! lib.isDerivation value && ! prev ? ${name} then
                      lib.recurseIntoAttrs (recurse value)
                    else
                      value
                );
              in
              recurse (overlay final prev);

        in
        {
          overlays.geonix =
            final: prev:
            {
              # Example package override
              # gdal = prev.gdal.overrideAttrs (prev: { version = "1000"; });
              # gdalMinimal = prev.gdal.overrideAttrs
              #   (prev: {
              #     useMinimalFeatures = true;
              #   });

              # Default Python version
              # python3Packages = prev.python311Packages;
              # python3 = prev.python311;

              # Default PostgreSQL version
              # postgresqlPackages = prev.postgresql15Packages;
              # postgresql = prev.postgresql_15;

              # grass
              grass = prev.grass.overrideAttrs (prev: {
                patches = [
                  # Backport of https://github.com/OSGeo/grass/pull/3899
                  # by @landam . Remove for GRASS 8.5.
                  ./pkgs/grass/grass_config_dir.patch
                ];
              });

              # gdal
              gdal-master = (final.pkgs.callPackage ./pkgs/gdal/master.nix { }).master;
              gdal-minimal = final.pkgs.gdalMinimal;

              # grass plugins
              grassPlugins =
                let
                  plugins = import ./pkgs/grass/plugins-list.nix;
                in
                final.lib.mapAttrs'
                  (
                    name: value: {
                      name = name;
                      value = final.callPackage ./pkgs/grass/plugins.nix {
                        name = name;
                        plugin = value;
                      };
                    }
                  )
                  plugins;

              # qgis plugins
              qgisPlugins =
                let
                  plugins = import ./pkgs/qgis/qgis-plugins-list.nix;
                in
                final.lib.mapAttrs'
                  (
                    name: value: {
                      name = name;
                      value = final.callPackage ./pkgs/qgis/plugins.nix { name = name; plugin = value; };
                    }
                  )
                  plugins;

              qgisLTRPlugins =
                let
                  plugins = import ./pkgs/qgis/qgis-ltr-plugins-list.nix;
                in
                final.lib.mapAttrs'
                  (
                    name: value: {
                      name = name;
                      value = final.callPackage ./pkgs/qgis/plugins.nix { name = name; plugin = value; };
                    }
                  )
                  plugins;

              # nixGL
              nixGL = inputs.nixgl.packages.${prev.stdenv.hostPlatform.system}.nixGLIntel;

              # Geospatial-nix patches
              # 
              # ...
              # 
              # End of Geospatial-nix patches
            };


          # legacyPackages output used for nix search
          legacyPackages.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.extend (
            recurseIntoOverlayAttrs self.overlays.geonix
          );
        };
    };
}
