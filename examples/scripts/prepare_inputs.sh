#!/usr/bin/env bash

#
# Expected sequence:
#


set -euo pipefail


PARAM=param
SCRIPTS=scripts

function get_if_missing {
    OBJECT=$1
    URL=$2
    if [ ! -e ${OBJECT} ]; then
        wget ${URL} -O ${OBJECT}
    fi
}

# Read in run specific details
source ${PARAM}/run.cfg

# This is the V3 geog file
UCAR_PATH="http://www2.mmm.ucar.edu/wrf/src/wps_files"
GEOG_URL="${UCAR_PATH}/${GEOG_TGZ}"

MODEL_DATA_DIR=model_data

# get relevant data
get_if_missing ${GEOG_TGZ} ${GEOG_URL}

# prepare the running environment
mkdir ${WPSPRD_DIR}

# this can take a long time...
tar  xf ${GEOG_TGZ} -C ${WPSPRD_DIR}

# prepare namelist.wps
cp ${PARAM}/wrf.yaml ${WPSPRD_DIR}
docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
       crs4/tdm-wrf-tools:0.1 wrf_configurator --target WPS \
       --config /WPSRUN/wrf.yaml --ofile=/WPSRUN/namelist.wps \
       -D"geometry.geog_data_path=/WPSRUN/"\
       -D"@base.timespan.start.year=${YEAR}"\
       -D"@base.timespan.start.month=${MONTH}"\
       -D"@base.timespan.start.day=${DAY}"\
       -D"@base.timespan.start.hour=${HOUR}"\
       -D"@base.timespan.end.year=${YEAR}"\
       -D"@base.timespan.end.month=${MONTH}"\
       -D"@base.timespan.end.day=${DAY}"\
       -D"@base.timespan.end.hour=${END_HOUR}"

# FIXME move the script in the image, so that it will be automagically run
cp ${SCRIPTS}/run_geogrid  ${WPSPRD_DIR}
docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
           crs4/tdm-wrf-wps:0.1 /WPSRUN/run_geogrid

docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
       crs4/tdm-wrf-tools:0.1 \
       gfs_fetch --year ${YEAR} --month ${MONTH} --day ${DAY} --hour ${HOUR} \
                 --target-directory /WPSRUN/${MODEL_DATA_DIR}\
                 --requested-resolution ${REQUESTED_RESOLUTION}

# this declares how the GFS files should be interpreted
cp ${PARAM}/Vtable.GFS ${WPSPRD_DIR}/Vtable

docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
       crs4/tdm-wrf-tools:0.1 \
       link_grib /WPSRUN/${MODEL_DATA_DIR} /WPSRUN


# prepare the dynamic boundary conditions
cp ${SCRIPTS}/run_ungrib  ${WPSPRD_DIR}
cp ${SCRIPTS}/run_metgrid  ${WPSPRD_DIR}

# FIXME maybe use a ENV variable to control what to run
docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
           crs4/tdm-wrf-wps:0.1 /WPSRUN/run_ungrib

docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
           crs4/tdm-wrf-wps:0.1 /WPSRUN/run_metgrid


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
       -D"@base.timespan.end.hour=${END_HOUR}"

cp ${SCRIPTS}/run_real  ${WPSPRD_DIR}
docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
           crs4/tdm-wrf-arw:0.1 /WPSRUN/run_real




