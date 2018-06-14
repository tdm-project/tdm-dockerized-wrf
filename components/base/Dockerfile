ARG VERSION=latest
FROM centos:$VERSION
LABEL maintainer="Gianluigi Zanetti <zag@crs4.it>"
#
# This is simply the base centos system and the WRF source
#
# Based on the  wps_wrf_upp Dockerfile
# by Jamie Wolff <jwolff@ucar.edu> adn Michelle Harrold <harrold@ucar.edu>

ARG WRF_VERSION
ENV WRF_VERSION ${WRF_VERSION:-3.9.1.1}

WORKDIR /wrf

RUN yum -y update \
 && yum -y install \
           file \
           yum-utils \
           gcc gcc-gfortran gcc-c++ glibc.i686 libgcc.i686 \
           libpng-devel jasper jasper-devel ksh hostname m4 make perl tar tcsh time \
           wget which zlib zlib-devel epel-release \
 && yum -y install \
           netcdf-devel.x86_64 netcdf-fortran-devel.x86_64 \
           netcdf-fortran.x86_64 hdf5.x86_64 \
 && yum clean all \
 && rm -rf /var/cache/yum \
 && rm -rf /var/tmp/yum-* \
 && curl -SL http://www2.mmm.ucar.edu/wrf/src/WRFV${WRF_VERSION}.TAR.gz | tar zxC /wrf \
 && mkdir /WPSRUN
 