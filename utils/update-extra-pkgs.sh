#!/usr/bin/env bash

# Update extra Geospatial NIX packages.
# Usage: update-extra-pkgs.sh

set -Eeuo pipefail


# gdal-master
echo -e "\nUpdating gdal-master package ..."
pushd pkgs/gdal
./update-master.sh
popd

git add pkgs/gdal/master-rev.nix
git commit -m "gdal-master: weekly update"


# QGIS plugins
echo -e "\nUpdating QGIS plugins ..."
pushd pkgs/qgis
./update-plugins.sh
popd

git add pkgs/qgis/*-plugins-list.nix
git commit -m "qgis-plugins: weekly update"


# GRASS plugins
echo -e "\nUpdating GRASS plugins ..."
pushd pkgs/grass
./update-plugins.sh
popd

git add pkgs/grass/plugins-rev.nix
git add pkgs/grass/plugins-list.nix
git commit -m "grass-plugins: weekly update"
