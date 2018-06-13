ARG VERSION=latest
FROM centos:$VERSION
LABEL maintainer="Gianluigi Zanetti <zag@crs4.it>"
#
# This is simply the base centos system with all the needed libraries.
#
# Based on Jamie Wolff <jwolff@ucar.edu> adn Michelle Harrold <harrold@ucar.edu> wps_wrf_upp Dockerfile

RUN yum -y update
RUN yum -y install \
           file \
           yum-utils \
           gcc gcc-gfortran gcc-c++ glibc.i686 libgcc.i686 \
           libpng-devel jasper jasper-devel ksh hostname m4 make perl tar tcsh time \
           wget which zlib zlib-devel epel-release

RUN yum -y install \
           netcdf-devel.x86_64 netcdf-fortran-devel.x86_64 \
           netcdf-fortran.x86_64 hdf5.x86_64 \
           netcdf-openmpi-devel.x86_64 \
           netcdf-fortran-openmpi-devel.x86_64 \
           netcdf-fortran-openmpi.x86_64 \
           hdf5-openmpi.x86_64 \
           openmpi.x86_64 openmpi-devel.x86_64

RUN yum clean all \
    && rm -rf /var/cache/yum \
    && rm -rf /var/tmp/yum-*
    