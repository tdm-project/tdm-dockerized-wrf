#!/usr/bin/env bash

set -euo pipefail

# Read in run specific details
source ${PARAM}/run.cfg

# FIXME first check if volume is already here
docker run -it --rm --mount source=${GEOG_NAME},destination=/geo \
       crs4/tdm-wrf-populate-geo:0.1 ${GEOG_NAME} /geo


# FIXME first check if volume is already here
printf -v NOAADATA "noaa-%4d%02d%02d_%02d%02d-%s" \
       $YEAR $MONTH $DAY $HOUR 0 ${REQUESTED_RESOLUTION}
docker run --rm -it\
       --mount src=${NOAADATA},dst=/gfs\
       crs4/tdm-wrf-tools:0.1\
       gfs_fetch \
       --year ${YEAR} --month ${MONTH} --day ${DAY} --hour ${HOUR}\
       --target-directory /gfs/model_data\
       --requested-resolution ${REQUESTED_RESOLUTION}


RUNID=`date -u +"run-%F_%H-%M-%S"`
docker run --rm --mount src=${RUNID},dst=/run\
       --mount type=bind,src=${PWD}/param,dst=/src\
       alpine cp /src/Vtable.GFS /run/Vtable; cp /src/wrf.yaml /run

docker run --rm\
       --mount src=${RUNID},dst=/run\
       crs4/tdm-wrf-tools:0.1 wrf_configurator --target WPS\
       --config /run/wrf.yaml --ofile=/run/namelist.wps\
       -D"geometry.geog_data_path=/geo/"\
       -D"@base.timespan.start.year=${YEAR}"\
       -D"@base.timespan.start.month=${MONTH}"\
       -D"@base.timespan.start.day=${DAY}"\
       -D"@base.timespan.start.hour=${HOUR}"\
       -D"@base.timespan.end.year=${YEAR}"\
       -D"@base.timespan.end.month=${MONTH}"\
       -D"@base.timespan.end.day=${DAY}"\
       -D"@base.timespan.end.hour=${END_HOUR}"

docker run -it --rm\
       --mount src=${GEOG_NAME},dst=/geo\
       --mount src=${RUNID},dst=/run\
       crs4/tdm-wrf-wps:0.1 run_geogrid /run


docker run -it --rm\
       --mount src=${NOAADATA},dst=/gfs\
       --mount src=${RUNID},dst=/run\
       crs4/tdm-wrf-tools:0.1\
       link_grib /gfs/model_data /run

docker run -it --rm\
       --mount src=${GEOG_NAME},dst=/geo\
       --mount src=${NOAADATA},dst=/gfs\
       --mount src=${RUNID},dst=/run\
       crs4/tdm-wrf-wps:0.1 run_ungrib /run

docker run -it --rm\
       --mount src=${GEOG_NAME},dst=/geo\
       --mount src=${NOAADATA},dst=/gfs\
       --mount src=${RUNID},dst=/run\
       crs4/tdm-wrf-wps:0.1 run_metgrid /run

docker run --rm\
       --mount src=${RUNID},dst=/run\
       crs4/tdm-wrf-tools:0.1 wrf_configurator --target WRF\
       --config /run/wrf.yaml --ofile=/run/namelist.input\
       -D"geometry.geog_data_path=/geo/"\
       -D"@base.timespan.start.year=${YEAR}"\
       -D"@base.timespan.start.month=${MONTH}"\
       -D"@base.timespan.start.day=${DAY}"\
       -D"@base.timespan.start.hour=${HOUR}"\
       -D"@base.timespan.end.year=${YEAR}"\
       -D"@base.timespan.end.month=${MONTH}"\
       -D"@base.timespan.end.day=${DAY}"\
       -D"@base.timespan.end.hour=${END_HOUR}"

docker run -it --rm\
       --mount src=${RUNID},dst=/run\
       crs4/tdm-wrf-arw:0.1 run_real /run
