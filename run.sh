#!/bin/bash

# Helper script for running STDP-MNIST in Docker

# Create necessary directories
mkdir -p mnist weights random results

# Ensure correct permissions
chmod 777 mnist weights random results

# Enable X11 forwarding
xhost +local:docker

case "$1" in
    "train")
        docker-compose run --rm brian1-stdp python "Diehl&Cook_spiking_MNIST.py" --train
        ;;
    "test")
        docker-compose run --rm brian1-stdp python "Diehl&Cook_spiking_MNIST.py" --test
        ;;
    "random")
        docker-compose run --rm brian1-stdp python "Diehl&Cook_MNIST_random_conn_generator.py"
        ;;
    "evaluate")
        docker-compose run --rm brian1-stdp python "Diehl&Cook_MNIST_evaluation.py"
        ;;
    "shell")
        docker-compose run --rm brian1-stdp /bin/bash
        ;;
    *)
        echo "Usage: $0 {train|test|random|evaluate|shell}"
        echo "  train     - Train the network"
        echo "  test      - Test the network"
        echo "  random    - Generate random connectivity"
        echo "  evaluate  - Evaluate network performance"
        echo "  shell     - Open shell in container"
        exit 1
esac