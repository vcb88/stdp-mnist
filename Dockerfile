FROM ubuntu:14.04

# Add old-releases repository as 14.04 is no longer supported
RUN sed -i -e 's/archive.ubuntu.com\|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list

# Install all required packages from Ubuntu repositories
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
    python-numpy \
    python-scipy \
    python-matplotlib \
    python-sympy \
    python-brian \
    python-setuptools \
    && rm -rf /var/lib/apt/lists/*

# Print versions of installed packages for reference
RUN echo "Installed package versions:" && \
    python -c "import numpy; print('numpy: ' + numpy.__version__)" && \
    python -c "import scipy; print('scipy: ' + scipy.__version__)" && \
    python -c "import matplotlib; print('matplotlib: ' + matplotlib.__version__)" && \
    python -c "import sympy; print('sympy: ' + sympy.__version__)" && \
    python -c "import brian; print('brian: ' + brian.__version__)"

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