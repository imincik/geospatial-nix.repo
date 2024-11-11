{ self', nixpkgs, pkgs }:

{
  # package tests
  inherit (self'.packages.gdal.tests)
    ogrinfo-version
    gdalinfo-version
    ogrinfo-format-geopackage
    gdalinfo-format-geotiff
    vector-file
    raster-file;

  inherit (self'.packages.geos.tests) geos;
  inherit (self'.packages.pdal.tests) pdal;
  inherit (self'.packages.proj.tests) proj;
  inherit (self'.packages.grass.tests) grass;

  # nixos tests
  test-qgis = pkgs.nixosTest (import ./tests/nixos/qgis.nix {
    inherit nixpkgs pkgs;
    lib = nixpkgs.lib;
    qgisPackage = self'.packages.qgis;
  });

  test-qgis-ltr = pkgs.nixosTest (import ./tests/nixos/qgis.nix {
    inherit nixpkgs pkgs;
    lib = nixpkgs.lib;
    qgisPackage = self'.packages.qgis-ltr;
  });

  test-nixgl = pkgs.nixosTest (import ./tests/nixos/nixgl.nix {
    inherit nixpkgs pkgs;
    lib = pkgs.lib;
    nixGL = self'.packages.nixGL;
  });

  # TODO: add postgis test
}
