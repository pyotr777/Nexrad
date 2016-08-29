# Distributed under the terms of the Modified BSD License.
FROM ubuntu:14.04

MAINTAINER Peter Bryzgalov

USER root

RUN apt-get update && apt-get install -y wget \
    build-essential checkinstall
RUN apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev \ 
    libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
RUN apt-get install -y  python-setuptools

RUN /usr/bin/python --version

# RUN easy_install pip

RUN mkdir /conda
WORKDIR /conda
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.0.5-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

RUN /opt/conda/bin/conda install boto

# Install pyart requirements
RUN apt-get install -y python-tables libhdf5-serial-dev \
    hdf5-tools hdf5-helpers python-h5py libhdf5-dev
RUN apt-get install -y git python-setuptools python-dev

RUN /opt/conda/bin/conda list
ENV PATH /opt/conda/bin:$PATH
RUN which pip
RUN which conda
RUN ls -l /opt/conda/bin

# Install TRMM Radar Software Library
ADD rsl-v1.49.tar /conda/
RUN ls -l /conda/rsl-v1.49

RUN mkdir /usr/local/rsl
WORKDIR /conda/rsl-v1.49

RUN sed -i".bak" 's/#define HAVE_LASSEN 1/#undef HAVE_LASSEN/' configure
RUN ./configure --prefix=/usr/local/rsl
RUN make install
ENV RSL_PATH=/usr/local/rsl

RUN conda install numpy netCDF4 scipy matplotlib
RUN conda list


# Install pyart
WORKDIR /conda/
RUN git clone https://github.com/ARM-DOE/pyart.git
WORKDIR /conda/pyart
RUN pwd
RUN ls -l /conda/pyart 
RUN python setup.py install 

RUN conda list

# Test pyart installation
ADD test_pyart.py /conda/
WORKDIR /conda/
RUN python test_pyart.py

# Install Jupyter
RUN conda install jupyter -y --quiet && mkdir /opt/notebooks
