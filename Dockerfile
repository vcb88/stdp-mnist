FROM ubuntu:14.04

# Add old-releases repository as 14.04 is no longer supported
RUN sed -i -e 's/archive.ubuntu.com\|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    python2.7 \
    python-pip \
    python-dev \
    build-essential \
    liblapack-dev \
    gfortran \
    pkg-config \
    libfreetype6-dev \
    libpng12-dev \
    python-numpy \
    python-scipy \
    python-matplotlib \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to a compatible version
RUN pip install --upgrade "pip < 21.0"

# Configure pip to use old PyPI URL format
RUN mkdir -p ~/.pip && echo "[global]\nindex-url = https://pypi.python.org/simple/\nformat = legacy" > ~/.pip/pip.conf

# Copy requirements file
COPY requirements.txt /app/
# Install specific versions using wheels where possible
RUN pip install -r /app/requirements.txt

# Set up working directory
WORKDIR /app

# Copy project files
COPY . /app/

# Set Python 2 as default
RUN ln -sf /usr/bin/python2.7 /usr/bin/python

# For matplotlib
ENV DISPLAY=:1

CMD ["python", "Diehl&Cook_spiking_MNIST.py"]