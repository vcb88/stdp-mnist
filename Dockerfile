FROM ubuntu:14.04

# Add old-releases repository as 14.04 is no longer supported
RUN sed -i -e 's/archive.ubuntu.com\|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list

# Add Universe repository for older packages
RUN sed -i 's/archive/old-releases/g' /etc/apt/sources.list && \
    sed -i 's/security/old-releases/g' /etc/apt/sources.list && \
    sed -i 's/^deb h/deb [trusted=yes] h/g' /etc/apt/sources.list

# Install system dependencies
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
    && rm -rf /var/lib/apt/lists/*

# Configure pip to use HTTP and trust all hosts
RUN mkdir -p ~/.pip && \
    echo "[global]\n\
index-url = http://pypi.python.org/simple/\n\
trusted-host = \
    pypi.python.org \
    pypi.org \
    files.pythonhosted.org" > ~/.pip/pip.conf

# Install older versions of Python packages that were used with Brian 1.4.1
RUN pip install --index-url http://pypi.python.org/simple/ --trusted-host pypi.python.org \
    "numpy==1.7.1" \
    "scipy==0.12.0" \
    "sympy==0.7.2" \
    "matplotlib==1.2.1" \
    "brian==1.4.1"

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