How to run an example
=====================


All examples subfolders contain

 * a script called `prepare_inputs.sh` that will prepare all it is
   needed to run the specific example;
 * a script called `run.sh` that will run the actual simulation;
 * the default behaviour is to write everything inside a single directory,
   default name `WPSPRD_DIR`, the specific datasets are downloaded as needed;
 * <something to look at the results>

Thus running a specific example entails:

 * FIXME give details on how to create and run the example
   
The general strategy is that all the needed computational steps -- e.g.,
extracting boundary conditions from grib files -- are encapsulated in stateless
docker containers.



Fully parametrized example
--------------------------

The expected operation streams should be the following.

 #. Prepare the run configuration file

    .. code-block:: bash
       $ cat param/run.cfg
       WPSPRD_DIR=WPSPRD_DIR
       YEAR=2018
       MONTH=6
       DAY=30
       HOUR=0
       END_HOUR=6
       REQUESTED_RESOLUTION=1p00
       GEOG_NAME="geog_minimum"
      
 #. Prepare, if needed, a data volume with the geographic information, most
    likely it exists already, so we should first check if it is already there
    (not shown). Note that the volume will be created on the fly by docker.

    .. code-block:: bash
       $ docker run -it --rm --mount source=${GEOG_NAME},destination=/geo \
                crs4/tdm-wrf-populate-geo:0.1 ${GEOG_NAME} /geo
       

 #. Download the global boundary condition dataset. The result is read-only. This
    is done by invoking `gfs_fetch` to download the requested dataset from NOAA.

    .. code-block:: bash
       $ printf -v NOAADATA "noaa-%4d%02d%02d_%02d%02d-%s" \
                $YEAR $MONTH $DAY $HOUR 0 ${REQUESTED_RESOLUTION}
       $ docker run --rm -it\
            --mount src=${NOAADATA},dst=/gfs\
            crs4/tdm-wrf-tools:0.1\
            gfs_fetch \
            --year ${YEAR} --month ${MONTH} --day ${DAY} --hour ${HOUR}\
            --target-directory /gfs/model_data\
            --requested-resolution ${REQUESTED_RESOLUTION}


 #. Prepare the geography configuration files in a new, run-specific, volume

    .. code-block:: bash
       $ RUNID=`date -u +"run-%F_%H-%M-%S"`
       $ docker run --rm --mount src=${RUNID},dst=/run\
            --mount type=bind,src=${PWD}/param,dst=/src\
            alpine cp /src/Vtable.GFS /run/Vtable; cp /src/wrf.yaml /run
       $ docker run --rm\
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

 #. Prepare geography for this run.

    .. code-block:: bash
       $ docker run -it --rm\
           --mount src=${GEOG_NAME},dst=/geo\
           --mount src=${RUNID},dst=/run\
           crs4/tdm-wrf-wps:0.1 run_geogrid /run

 #. Link the boundary conditions files, ungrib and metgrid.

    .. code-block:: bash
       $ docker run -it --rm\
           --mount src=${NOAADATA},dst=/gfs\       
           --mount src=${RUNID},dst=/run\
           crs4/tdm-wrf-tools:0.1\
           link_grib /gfs/model_data /run
       $ docker run -it --rm\
           --mount src=${GEOG_NAME},dst=/geo\       
           --mount src=${NOAADATA},dst=/gfs\       
           --mount src=${RUNID},dst=/run\
           crs4/tdm-wrf-wps:0.1 run_ungrib /run
       $ docker run -it --rm\
           --mount src=${GEOG_NAME},dst=/geo\       
           --mount src=${NOAADATA},dst=/gfs\       
           --mount src=${RUNID},dst=/run\
           crs4/tdm-wrf-wps:0.1 run_metgrid /run

 #. Finalize global boundary information processing.

    .. code-block:: bash
       $ docker run --rm\
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
       $ docker run -it --rm\
           --mount src=${RUNID},dst=/run\
           crs4/tdm-wrf-arw:0.1 run_real /run


Data analysis
-------------
   
# docker run -i -t -p 8888:8888 crs4/tdm-wrf-analyze /bin/bash -c
# "/opt/conda/bin/jupyter notebook --notebook-dir=/opt/notebooks --ip='*'
#  --port=8888 --no-browser"
