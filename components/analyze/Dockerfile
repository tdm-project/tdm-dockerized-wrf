FROM continuumio/anaconda3

# docker run -i -t -p 8888:8888 crs4/tdm-wrf-analyze /bin/bash -c
# "/opt/conda/bin/jupyter notebook --notebook-dir=/opt/notebooks --ip='*'
#  --port=8888 --no-browser"

RUN apt-get update \
 && rm -rf /var/lib/apt/lists/* \
 && /opt/conda/bin/conda install -c conda-forge wrf-python pygrib -y \
 && /opt/conda/bin/conda install jupyter -y \
 && /opt/conda/bin/conda install \
    numpy pandas scikit-learn matplotlib \
    seaborn pyyaml -y \
 && /opt/conda/bin/conda install cartopy -y \
 && /opt/conda/bin/conda upgrade dask -y \
 && mkdir /WPSRUN
