#!/usr/bin/env bash

# Build all packages and upload them to binary cache. Run tests.
# Usage: nix-build-all.sh

set -Eeuo pipefail

tests=( test-custom-package test-qgis test-qgis-ltr test-nixgl )


# build all packages and upload them to binary chache
echo -e "\nBuilding packages ..."
nix build --json .#all-packages \
    | jq -r '.[].outputs | to_entries[].value' \
    | cachix push geonix-rolling

# run tests
echo -e "\nRunning tests ..."
nix flake check

for test in "${tests[@]}"; do
  nix build --json .#checks.x86_64-linux."$test" \
    | jq -r '.[].outputs | to_entries[].value' \
    | cachix push geonix-rolling
done

echo -e "\nDone."
