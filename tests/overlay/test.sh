#!/usr/bin/env bash

set -euo pipefail

nix eval --raw .\#packages.x86_64-linux.qgis-plugin | grep qgis2web
