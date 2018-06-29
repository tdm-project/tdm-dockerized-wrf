FROM python:3

WORKDIR /opt/

RUN git clone https://github.com/tdm-project/tdm-tools.git \
    && cd tdm-tools \
    && git checkout develop \
    && python setup.py install

CMD ["/usr/local/bin/gfs_fetch"]
