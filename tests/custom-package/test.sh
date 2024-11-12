#!/usr/bin/env bash

set -euo pipefail


package=$(nix build --accept-flake-config --no-link --print-out-paths --impure \
    --expr "(builtins.getFlake (toString ../../.)).packages.x86_64-linux.gdal.overrideAttrs { \
        version = \"1000.0.0\"; \
        postPatch = ''sed -i \"s|Usage:|Usage (patched):|\" apps/argparse/argparse.hpp'';
        doInstallCheck = false;
}")

"$package"/bin/gdalinfo --help | grep "Usage (patched): gdalinfo"
