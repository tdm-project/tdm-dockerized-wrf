#!/usr/bin/env bash

set -euo pipefail

WPSPRD_DIR=${1:-WPSPRD_DIR}
NUMPROC=${2:-2}
NUMTILES=${3:-1}

PARAM=param
SCRIPTS=scripts

cp ${SCRIPTS}/run_wrf ${WPSPRD_DIR}
cat >${WPSPRD_DIR}/hosts <<EOF
127.0.0.1 4
EOF
INLIST=namelist.input.numtiles
sed -e "s/NUMTILES/${NUMTILES}/" < ${PARAM}/${INLIST} > ${WPSPRD_DIR}/namelist.input
docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
           crs4/tdm-wrf-arw:0.1 /WPSRUN/run_wrf ${NUMPROC} /WPSRUN/hosts
