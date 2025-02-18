# Running STDP-MNIST in Docker (2014 Environment)

This guide explains how to run the STDP-MNIST project in a Docker container that replicates the original 2014 Python/Brian environment.

## Prerequisites

1. Docker installed on your system
2. Docker Compose installed on your system
3. X11 server running (for visualization)
4. MNIST dataset files:
   - `train-images.idx3-ubyte`
   - `train-labels.idx1-ubyte`
   - `t10k-images.idx3-ubyte`
   - `t10k-labels.idx1-ubyte`

## Project Structure

After cloning, create the following directory structure:
```
stdp-mnist/
├── mnist/             # Place MNIST dataset files here
├── weights/           # Directory for trained weights
├── random/            # Directory for random weights
├── results/           # Training/testing results and plots
└── ...               # Other project files
```

## Setup

1. Create required directories:
```bash
mkdir -p mnist weights random results
```

2. Place MNIST dataset files in the `mnist/` directory

3. Build the Docker image:
```bash
docker-compose build
```

## Running the Project

### Training Mode

To train the network (60,000 examples, 3 epochs):
```bash
docker-compose run --rm brian1-stdp python Diehl\&Cook_spiking_MNIST.py --train
```

The training process will:
- Generate initial random weights (saved in `random/` directory)
- Train the network using STDP
- Save final weights in `weights/` directory
- Generate performance plots in `results/` directory

### Testing Mode

To test the network (10,000 examples):
```bash
docker-compose run --rm brian1-stdp python Diehl\&Cook_spiking_MNIST.py --test
```

Testing will:
- Load trained weights from `weights/` directory
- Evaluate network performance
- Generate evaluation plots in `results/` directory

### Visualization

The project includes real-time visualization of:
- Network activity (raster plots)
- Weight matrices
- Classification performance

To enable X11 forwarding, ensure your X server allows connections and run:
```bash
xhost +local:docker
```

### Generating Random Connectivity

To generate new random connectivity matrices:
```bash
docker-compose run --rm brian1-stdp python Diehl\&Cook_MNIST_random_conn_generator.py
```

### Evaluating Results

To evaluate network performance:
```bash
docker-compose run --rm brian1-stdp python Diehl\&Cook_MNIST_evaluation.py
```

## Directory Mapping

The Docker configuration maps the following directories to preserve data between runs:
- `./mnist:/app/mnist` - MNIST dataset
- `./weights:/app/weights` - Trained network weights
- `./random:/app/random` - Random connectivity matrices
- `./results:/app/results` - Analysis results and plots

## Troubleshooting

1. If you see matplotlib/display errors:
```bash
# Allow X server connections
xhost +local:docker

# Check if DISPLAY variable is set correctly in docker-compose.yml
```

2. If weight files are not being saved:
```bash
# Ensure correct permissions on directories
chmod 777 weights random results
```

3. For memory issues:
```bash
# Adjust Docker resource limits in docker-compose.yml
services:
  brian1-stdp:
    mem_limit: 4g
```

## Environment Details

The Docker container provides a 2014-era Python environment with:
- Python 2.7.9
- Brian 1.4.1
- NumPy 1.9.1
- SciPy 0.14.0
- Matplotlib 1.4.2

This matches the original development environment of the project.