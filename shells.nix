{ self', pkgs }:

rec {

  # CLI shell
  cli =
    let
      py = pkgs.python3;
      pythonPackage = py.withPackages (p: with self'.packages; [
        python3-fiona
      ]);

    in
    pkgs.mkShell {
      nativeBuildInputs = [ pkgs.bashInteractive ];
      buildInputs = with self'.packages; [
        gdal
        pythonPackage
      ];
    };

  default = cli;
}
