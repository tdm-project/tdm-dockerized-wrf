#!/usr/bin/env bash

set -euo pipefail

BASE_VERSION=0.1

docker build -t crs4/tdm-wrf-base:${BASE_VERSION} base

docker build --build-arg BASE_VERSION=${BASE_VERSION} \
             -t crs4/tdm-wrf-wps:${BASE_VERSION} wps

docker build --build-arg BASE_VERSION=${BASE_VERSION} \
             --build-arg CMODE=35 --build-arg NEST=1 \
             -t crs4/tdm-wrf-arw:${BASE_VERSION} arw

docker build -t crs4/tdm-wrf-analyze:${BASE_VERSION} analyze

docker build -t crs4/tdm-wrf-tools:${BASE_VERSION} tools
