ARG ARW_VERSION=latest
FROM crs4/tdm-wrf-arw:$ARW_VERSION
LABEL maintainer="Gianluigi Zanetti <zag@crs4.it>"
# Based on Jamie Wolff <jwolff@ucar.edu> and Michelle Harrold <harrold@ucar.edu>
# wps_wrf_upp Dockerfile

ARG WPS_VERSION
ENV WPS_VERSION ${WPS_VERSION:-3.9.1}

RUN curl -SL http://www2.mmm.ucar.edu/wrf/src/WPSV$WPS_VERSION.TAR.gz | tar zxC /wrf \
 && cd /wrf/WPS \
 && export NETCDF=/wrf/netcdf_links \
 && export JASPERINC=/usr/include/jasper/ \
 && export JASPERLIB=/usr/lib64/ \
 && ./configure <<< $'1\r' \
 && sed -i -e 's/-L$(NETCDF)\/lib/-L$(NETCDF)\/lib -lnetcdff /' ./configure.wps \
 && /bin/csh ./compile > compile_wps.log 2>&1 \
 && mkdir /WPSRUN

ENV LD_LIBRARY_PATH /usr/lib64/lib
ENV PATH  /usr/lib64/bin:$PATH
