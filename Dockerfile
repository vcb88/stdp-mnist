FROM ubuntu:14.04

# Add old-releases repository as 14.04 is no longer supported
RUN sed -i -e 's/archive.ubuntu.com\|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list

# Install Python and system dependencies
RUN apt-get update && apt-get install -y \
    python2.7 \
    python-dev \
    python-pip \
    build-essential \
    liblapack-dev \
    gfortran \
    pkg-config \
    libfreetype6-dev \
    libpng12-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages from Ubuntu repositories
RUN apt-get update && apt-get install -y \
    python-numpy \
    python-scipy \
    python-matplotlib \
    python-setuptools \
    && rm -rf /var/lib/apt/lists/*

# Install specific version of pip
RUN wget https://bootstrap.pypa.io/pip/2.7/get-pip.py && \
    python get-pip.py 'pip==20.3.4' && \
    rm get-pip.py

# Install Brian and dependencies
RUN pip install --index-url https://pypi.python.org/simple/ --no-deps \
    'sympy==0.7.4' \
    'brian==1.4.1'

# Add matplotlib backend configuration
RUN mkdir -p /root/.config/matplotlib && \
    echo "backend: Agg" > /root/.config/matplotlib/matplotlibrc

# Set up working directory
WORKDIR /app

# Copy project files
COPY . /app/

# Set Python 2 as default
RUN ln -sf /usr/bin/python2.7 /usr/bin/python

# For matplotlib
ENV DISPLAY=:1

CMD ["python", "Diehl&Cook_spiking_MNIST.py"]