ARG BASE_VERSION=latest
FROM crs4/tdm-wrf-base:$BASE_VERSION
LABEL maintainer="Gianluigi Zanetti <zag@crs4.it>"
# Based on Jamie Wolff <jwolff@ucar.edu> and Michelle Harrold <harrold@ucar.edu>
# wps_wrf_upp Dockerfile

ARG WPS_VERSION
ENV WPS_VERSION ${WPS_VERSION:-3.9.1}

WORKDIR /wrf

RUN pwd \ 
 && mkdir netcdf_links \
 && ln -sf /usr/include/ netcdf_links/include \
 && ln -sf /usr/lib64 netcdf_links/lib \
 && ln -sf /usr/lib64/gfortran/modules/netcdf.mod netcdf_links/include \
 && export NETCDF=/wrf/netcdf_links \
 && export JASPERINC=/usr/include/jasper/ \
 && export JASPERLIB=/usr/lib64/ \
 && cd ./WRFV3 \
 && ./configure <<< $'32\r1\r' \
 && /bin/csh ./compile em_real > compile_wrf_arw_opt32.1.log 2>&1 \
 && curl -SL http://www2.mmm.ucar.edu/wrf/src/WPSV$WPS_VERSION.TAR.gz | tar zxC /wrf \
 && cd /wrf/WPS \
 && ./configure <<< $'1\r' \
 && sed -i -e 's/-L$(NETCDF)\/lib/-L$(NETCDF)\/lib -lnetcdff /' ./configure.wps \
 && /bin/csh ./compile > compile_wps.log 2>&1


ENV LD_LIBRARY_PATH /usr/lib64/lib
ENV PATH  /usr/lib64/bin:$PATH
