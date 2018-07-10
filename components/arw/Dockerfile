ARG BASE_VERSION=latest
FROM crs4/tdm-wrf-base:$BASE_VERSION
LABEL maintainer="Gianluigi Zanetti <zag@crs4.it>"
# Based on the wps_wrf_upp Dockerfile
# of Jamie Wolff <jwolff@ucar.edu> and Michelle Harrold <harrold@ucar.edu> 

ARG WRF_VERSION
# GNU (gfortran/gcc) options
# CMODE=32 serial, CMODE=33 DMPAR,  CMODE=34 SMPAR, CMODE=35 DMPAR + SMPAR
# NEST=0 plain, NEST=1 nested, ...
ARG CMODE
ARG NEST

ENV WRF_VERSION ${WRF_VERSION:-3.9.1.1}
ENV CMODE ${CMODE:-32}
ENV NEST  ${NEST:-0}

WORKDIR /wrf

RUN mkdir netcdf_links \
 && if [ "$CMODE" = "32" ]; then \
    ln -sf /usr/include/ netcdf_links/include \
    && ln -sf /usr/lib64 netcdf_links/lib \
    && ln -sf /usr/lib64/gfortran/modules/netcdf.mod netcdf_links/include \
    ; else \
    yum -y install \
           netcdf-openmpi-devel.x86_64 \
           netcdf-fortran-openmpi-devel.x86_64 \
           netcdf-fortran-openmpi.x86_64 \
           hdf5-openmpi.x86_64 \
           openmpi.x86_64 openmpi-devel.x86_64 \
           openssh-clients openssh-server net-tools \
    && yum clean all && rm -rf /var/cache/yum \
    && ln -sf /usr/include/openmpi-x86_64/ netcdf_links/include \
    && ln -sf /usr/lib64/openmpi/lib netcdf_links/lib \
    && export LD_LIBRARY_PATH="/usr/lib64/openmpi/lib" \
    && export PATH="/usr/lib64/openmpi/bin:$PATH" \
    ; fi \
 && export NETCDF=/wrf/netcdf_links \
 && export JASPERINC=/usr/include/jasper/ \
 && export JASPERLIB=/usr/lib64/ \
 && cd ./WRFV3 \
 && printf "${CMODE}\n${NEST}" |./configure \
 && sed -i -e '/^DM_CC/ s/$/ -DMPI2_SUPPORT/' ./configure.wrf \
 && /bin/csh ./compile em_real > compile_wrf_arw_opt${CMODE}.${NEST}.log 2>&1 \
 && if [ "$CMODE" != "32" ]; then \
    mkdir -p /var/run/sshd \
    && ssh-keygen -A \
    && sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config \
    && sed -i 's/#RSAAuthentication yes/RSAAuthentication yes/g' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config \
    && ssh-keygen -f /root/.ssh/id_rsa -t rsa -N '' \
    && echo "StrictHostKeyChecking no" > /root/.ssh/config \
    && chmod 600 /root/.ssh/config \
    && chmod 700 /root/.ssh \
    && cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys \
    && echo -e "#"'!'"/bin/bash\n/usr/sbin/sshd -D" > /wrf/slave \
    && chmod +x /wrf/slave \
    ; fi

COPY run_wrf run_real /usr/bin/