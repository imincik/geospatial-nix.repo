#!/usr/bin/env bash

set -euo pipefail

nix search --json ../.. qgis2web | grep "legacyPackages.x86_64-linux.qgisPlugins.qgis2web"
