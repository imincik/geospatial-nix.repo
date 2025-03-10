#!/usr/bin/env nix-shell
#! nix-shell -i bash -p python3 -p nix-prefetch-git -I nixpkgs=https://github.com/NixOS/nixpkgs/tarball/36fd87b

# Update GDAL master package to the latest master revision.
# Usage: update-master.sh

set -Eeuo pipefail

python ./update-master.py > master-rev.nix
