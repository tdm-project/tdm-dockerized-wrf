#!/usr/bin/env bash

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

DT_CENTER_PATH="http://www.dtcenter.org/eval/meso_mod/mmet/data_for_docker"
GEOG_TGZ="geog_minimum.tar.gz"
DERECHO_TGZ="container-dtc-nwp-derechodata_20120629.tar.gz"
GEOG_URL="${DT_CENTER_PATH}/${GEOG_TGZ}"
DERECHO_URL="${DT_CENTER_PATH}/${DERECHO_TGZ}"

# get relevant data from the dtcenter
get_if_missing ${GEOG_TGZ} ${GEOG_URL}
get_if_missing ${DERECHO_TGZ} ${DERECHO_URL}

# prepare the running environment
mkdir ${WPSPRD_DIR}

tar  xf ${GEOG_TGZ} -C ${WPSPRD_DIR}

cp ${PARAM}/namelist.wps ${WPSPRD_DIR}
cp ${PARAM}/Vtable.GFS ${WPSPRD_DIR}/Vtable

# FIXME move the script in the image, so that it will be automagically run
cp ${SCRIPTS}/run_geogrid  ${WPSPRD_DIR}
docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
           crs4/tdm-wrf-wps:0.1 /WPSRUN/run_geogrid

# prepare the dynamic boundary conditions
cp ${SCRIPTS}/run_ungrib  ${WPSPRD_DIR}
cp ${SCRIPTS}/run_metgrid  ${WPSPRD_DIR}

tar xf ${DERECHO_TGZ}  -C ${WPSPRD_DIR}

pushd ${WPSPRD_DIR}
python ../../../bin/link_grib ./model_data/gfs .
popd

# FIXME maybe use a ENV variable to control what to run
docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
           crs4/tdm-wrf-wps:0.1 /WPSRUN/run_ungrib

docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
           crs4/tdm-wrf-wps:0.1 /WPSRUN/run_metgrid

cp ${PARAM}/namelist.input ${WPSPRD_DIR}
cp ${SCRIPTS}/run_real  ${WPSPRD_DIR}
docker run -it --mount type=bind,src=${PWD}/${WPSPRD_DIR},dst=/WPSRUN \
           crs4/tdm-wrf-arw:0.1 /WPSRUN/run_real




