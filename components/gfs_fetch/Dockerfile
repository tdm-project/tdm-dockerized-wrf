FROM python:3

WORKDIR /opt/

RUN git clone https://github.com/tdm-project/tdm-python.git \
    && cd tdm-python \
    && git checkout develop \
    && python setup.py install

CMD ["/usr/local/bin/gfs_fetch"]
