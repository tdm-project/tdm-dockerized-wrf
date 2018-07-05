#!/usr/bin/env bash

set -euo pipefail

# Read in run specific details
source param/run.cfg

NUMPROC=${1:-2}
NUMTILES=${2:-1}

PARAM=param
SCRIPTS=scripts

# prepare namelist.input
docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
       crs4/tdm-wrf-tools:0.1 wrf_configurator --target WRF \
       --config /WPSRUN/wrf.yaml --ofile=/WPSRUN/namelist.input \
       -D"geometry.geog_data_path=/WPSRUN/"\
       -D"@base.timespan.start.year=${YEAR}"\
       -D"@base.timespan.start.month=${MONTH}"\
       -D"@base.timespan.start.day=${DAY}"\
       -D"@base.timespan.start.hour=${HOUR}"\
       -D"@base.timespan.end.year=${YEAR}"\
       -D"@base.timespan.end.month=${MONTH}"\
       -D"@base.timespan.end.day=${DAY}"\
       -D"@base.timespan.end.hour=${END_HOUR}"\
       -D"running.parallel.numtiles=${NUMTILES}"

cp ${SCRIPTS}/run_wrf ${WPSPRD_DIR}
cat >${WPSPRD_DIR}/hosts <<EOF
127.0.0.1 4
EOF
docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
           crs4/tdm-wrf-arw:0.1 /WPSRUN/run_wrf ${NUMPROC} ${NUMTILES} /WPSRUN/hosts
