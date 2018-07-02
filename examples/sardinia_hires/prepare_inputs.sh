#!/usr/bin/env bash

#
# Expected sequence:
#


set -euo pipefail

WPSPRD_DIR=${1:-WPSPRD_DIR}
PARAM=param
SCRIPTS=scripts


function get_if_missing {
    OBJECT=$1
    URL=$2
    if [ ! -e ${OBJECT} ]; then
        wget ${URL} -O ${OBJECT}
    fi
}

#
YEAR=2018
MONTH=6
DAY=18
HOUR=0
END_HOUR=6

# This is the V3 geog file
UCAR_PATH="http://www2.mmm.ucar.edu/wrf/src/wps_files"
GEOG_TGZ="geog_complete.tar.gz"
GEOG_URL="${UCAR_PATH}/${GEOG_TGZ}"


MODEL_DATA_DIR=model_data

# get relevant data
get_if_missing ${GEOG_TGZ} ${GEOG_URL}
# for the time being we assume that we have the high res GFS data available
# get_gfs xxxxx

# prepare the running environment
mkdir ${WPSPRD_DIR}

tar  xf ${GEOG_TGZ} -C ${WPSPRD_DIR}

cp ${PARAM}/wrf.yaml ${WPSPRD_DIR}
cp ${PARAM}/Vtable.GFS ${WPSPRD_DIR}/Vtable

docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
       crs4/tdm-tools:0.1 wrf_configurator --target WPS \
       --config /WPSRUN/wrf.yaml --ofile=/WPSRUN/namelist.wps \
       -D"@base.timespans.start.year=${YEAR}"\
       -D"@base.timespans.start.month=${MONTH}"\
       -D"@base.timespans.start.day=${DAY}"\
       -D"@base.timespans.start.hour=${HOUR}"\
       -D"@base.timespans.end.year=${YEAR}"\
       -D"@base.timespans.end.month=${MONTH}"\
       -D"@base.timespans.end.day=${DAY}"\
       -D"@base.timespans.end.hour=${END_HOUR}"

exit
# FIXME move the script in the image, so that it will be automagically run
cp ${SCRIPTS}/run_geogrid  ${WPSPRD_DIR}
docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
           crs4/tdm-wrf-wps:0.1 /WPSRUN/run_geogrid

# prepare the dynamic boundary conditions
cp ${SCRIPTS}/run_ungrib  ${WPSPRD_DIR}
cp ${SCRIPTS}/run_metgrid  ${WPSPRD_DIR}

docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
       crs4/tdm-tools:0.1 \
       gfs_fetch --year ${YEAR} --month ${MONTH} --day ${DAY} --hour ${HOUR} \
                 --target-directory /WPSRUN/${MODEL_DATA_DIR}

docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
       crs4/tdm-tools:0.1 \
       link_grib /WPSRUN/${MODEL_DATA_DIR} /WPSRUN

# FIXME maybe use a ENV variable to control what to run
docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
           crs4/tdm-wrf-wps:0.1 /WPSRUN/run_ungrib

docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
           crs4/tdm-wrf-wps:0.1 /WPSRUN/run_metgrid

cp ${PARAM}/namelist.input ${WPSPRD_DIR}
cp ${SCRIPTS}/run_real  ${WPSPRD_DIR}
docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
           crs4/tdm-wrf-arw:0.1 /WPSRUN/run_real




