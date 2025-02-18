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

# Install specific version of pip with SSL verification disabled
RUN wget --no-check-certificate https://bootstrap.pypa.io/pip/2.7/get-pip.py && \
    python get-pip.py --index-url=http://pypi.python.org/simple/ --trusted-host pypi.python.org 'pip==20.3.4' && \
    rm get-pip.py

# Configure pip to trust PyPI
RUN mkdir -p ~/.pip && \
    echo "[global]\n\
trusted-host = \
    pypi.python.org \
    pypi.org \
    files.pythonhosted.org\n\
timeout = 60\n\
retries = 10\n" > ~/.pip/pip.conf

# Install specific versions of required packages
RUN pip install --no-deps \
    'numpy==1.9.1' \
    'scipy==0.14.0' \
    'matplotlib==1.4.2' \
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