# Developer documentation

## Building packages

* Build single package
```bash
nix build .#<PACKAGE>
```

* Build all packages
```bash
nix build .#all-packages
```

* Build customized version of a package
```bash
nix build \
  --impure \
  --expr "(builtins.getFlake (toString ./.)).packages.x86_64-linux.<PACKAGE>.override { <PARAMETER> = <VALUE>; }"

# e.g. build QGIS with rasterio
nix build \
  --impure \
  --expr "let f = builtins.getFlake (toString ./.); in f.packages.x86_64-linux.qgis.override { extraPythonPackages = ps: with f.packages.x86_64-linux; [ python3-rasterio ]; }"

# e.g. build package containing multiple qgis-plugins
nix build \
  --impure \
  --expr "let f = builtins.getFlake (toString ./.); in f.inputs.nixpkgs.legacyPackages.x86_64-linux.symlinkJoin { name = \"qgis-plugins\"; paths = with f.packages.x86_64-linux; [ qgis-plugin-qgis2web qgis-plugin-MapTiler ]; }"
```

* Run package passthru tests
```bash
nix build -L .#<PACKAGE>.tests.<TEST-NAME>
```

* Run single flake check
```bash
nix build -L .#checks.x86_64-linux.<TEST-NAME>
```

_To an re-build already built package or to re-run already succeeded tests, use the
`--rebuild` switch._

## Debugging packages

* Explore derivation
```bash
nix show-derivation .#<PACKAGE>
```

* Explore package store path content
```bash
nix path-info -rsSh .#<PACKAGE> | sort -nk3
```

* Explain package dependencies
```bash
nix why-depends .#<PACKAGE> .#<DEPENDENCY>
```


## Weekly development cycle

* Thursday (1 AM): Nixpkgs update PR (nix flake update)

* Thursday - Friday: manual update of extra geospatial packages, build and test all packages

* Sunday (11 PM): automatic release of new version

### Packages update process

* Checkout to `weekly-update` PR
  (PR title "pkgs: weekly update (weekly-update-<DATE>)") (Thursday - Friday)
```bash
gh pr checkout -f <PR-NUMBER>
```

* Test build of Nixpkg update PR
```bash
nix build --dry-run .#all-packages
```

* Update gdal-master package
```bash
pushd pkgs/gdal
./update-master.sh
popd

git add pkgs/gdal/master-rev.nix
git commit -m "gdal-master: weekly update"
```

* Update QGIS plugins
```bash
pushd pkgs/qgis
./update-plugins.sh
popd

git add pkgs/qgis/*-plugins-list.nix
git commit -m "qgis-plugins: weekly update"
```

* Update GRASS plugins
```bash
pushd pkgs/grass
./update-plugins.sh
popd

git add pkgs/grass/plugins-rev.nix
git add pkgs/grass/plugins-list.nix
git commit -m "grass-plugins: weekly update"
```

* Build, test and upload all packages to binary chache
```bash
source ./env.sh  # file not present in git, containing cachix token
utils/nix-build-all.sh
```

* Print the list of updated packages since last release
```bash
nvd diff \
  $(nix build github:imincik/geospatial-nix.repo/latest#all-packages --print-out-paths) \
  $(nix build .#all-packages --print-out-paths)
```


* Push changes to `weekly-update` PR
```bash
git push
```

* Merge `weekly-update` PR (Friday, Saturday)


## URLs

* Nixpkgs PRs [tracking](https://nixpkgs-tracker.ocfox.me/)

* Nixpkgs channel [status](https://status.nixos.org/)

