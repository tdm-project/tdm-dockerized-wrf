ARG BASE_VERSION=latest
FROM crs4/tdm-wrf-base:$BASE_VERSION
LABEL maintainer="Gianluigi Zanetti <zag@crs4.it>"
# Based on Jamie Wolff <jwolff@ucar.edu> adn Michelle Harrold <harrold@ucar.edu> wps_wrf_upp Dockerfile

ARG WRF_VERSION
# GNU (gfortran/gcc) options
# CMODE=32 serial, CMODE=33 DMPAR,  CMODE=34 SMPAR, CMODE=35 DMPAR + SMPAR
# input 1 to WRF to select nested
ARG CMODE
ARG NEST

ENV WRF_VERSION ${WRF_VERSION:-3.9.1.1}
ENV CMODE ${CMODE:-32}
ENV NEST  ${NEST:-1}

WORKDIR /wrf
#
# Download original sources
#
RUN curl -SL http://www2.mmm.ucar.edu/wrf/src/WRFV${WRF_VERSION}.TAR.gz | tar zxC /wrf

# FIXME this can be probably merged in appropriate links commands in the RUN below.
RUN echo export LDFLAGS="-lm" >> /etc/bashrc \
 && echo export NETCDF=/wrf/netcdf_links >> /etc/bashrc \
 && echo export JASPERINC=/usr/include/jasper/ >> /etc/bashrc \
 && echo export JASPERLIB=/usr/lib64/ >> /etc/bashrc \
 && echo export LD_LIBRARY_PATH="/usr/lib64/openmpi/lib" >> /etc/bashrc \
 && echo export PATH="/usr/lib64/openmpi/bin:$PATH" >> /etc/bashrc \
 && echo setenv LDFLAGS "-lm" >> /etc/csh.cshrc \
 && echo setenv NETCDF "/wrf/netcdf_links" >> /etc/csh.cshrc \
 && echo setenv JASPERINC "/usr/include/jasper/" >> /etc/csh.cshrc \
 && echo setenv JASPERLIB "/usr/lib64/" >> /etc/csh.cshrc \
 && echo setenv LD_LIBRARY_PATH "/usr/lib64/openmpi/lib" >> /etc/csh.cshrc \
 && echo setenv PATH "/usr/lib64/openmpi/bin:$PATH" >> /etc/csh.cshrc

RUN pwd \ 
 && mkdir netcdf_links \
 && ln -sf /usr/include/openmpi-x86_64/ netcdf_links/include \
 && ln -sf /usr/lib64/openmpi/lib netcdf_links/lib \
 && export NETCDF=/wrf/netcdf_links \
 && export JASPERINC=/usr/include/jasper/ \
 && export JASPERLIB=/usr/lib64/ \
 && cd ./WRFV3 \
 && printf "${CMODE}\n${NEST}" |./configure \
 && sed -i -e '/^DM_CC/ s/$/ -DMPI2_SUPPORT/' ./configure.wrf \
 && /bin/csh ./compile em_real > compile_wrf_arw_opt34.1.log 2>&1


# RUN cd WRFV3 \
#     && rm -f README* Makefile clean compile configure configure.wrf \
#     && rm -rf Registry arch dyn_em dyn_exp dyn_nmm external frame \
#        hydro inc phys share test tools \
#     && cd main \
#        rm -f *.F *.f90 *.o *.mod *.a *.c Makefile depend.common 
