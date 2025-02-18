FROM ubuntu:14.04

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
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install \
    numpy==1.9.1 \
    scipy==0.14.0 \
    matplotlib==1.4.2 \
    brian==1.4.1

# Set up working directory
WORKDIR /app

# Copy project files
COPY . /app/

# Set Python 2 as default
RUN ln -sf /usr/bin/python2.7 /usr/bin/python

# For matplotlib
ENV DISPLAY=:1

CMD ["python", "Diehl&Cook_spiking_MNIST.py"]