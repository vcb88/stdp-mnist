#!/bin/bash

# Helper script for running STDP-MNIST in Docker

# Create necessary directories
mkdir -p mnist weights random results

# Ensure correct permissions
chmod 777 mnist weights random results

# Enable X11 forwarding
xhost +local:docker

print_status() {
    echo "Directory status:"
    echo "  mnist/   - $(ls -1 mnist/ 2>/dev/null | wc -l) files"
    echo "  weights/ - $(ls -1 weights/ 2>/dev/null | wc -l) files"
    echo "  random/  - $(ls -1 random/ 2>/dev/null | wc -l) files"
    echo "  results/ - $(ls -1 results/ 2>/dev/null | wc -l) files"
    echo
}

case "$1" in
    "train")
        echo "Starting network training..."
        echo "This will:"
        echo "- Process 60,000 training examples"
        echo "- Run for 3 epochs (180,000 total examples)"
        echo "- Save weights in weights/ directory"
        echo "- Generate plots in results/ directory"
        echo
        print_status
        echo "Starting Docker container..."
        docker-compose run --rm brian1-stdp python "Diehl&Cook_spiking_MNIST.py" --train
        ;;
    "test")
        if [ ! -d "weights" ] || [ -z "$(ls -A weights/)" ]; then
            echo "Error: No weights found in weights/ directory"
            echo "Please run training first: $0 train"
            exit 1
        fi
        echo "Starting network testing..."
        echo "This will:"
        echo "- Load weights from weights/ directory"
        echo "- Process 10,000 test examples"
        echo "- Generate evaluation plots"
        echo
        print_status
        echo "Starting Docker container..."
        docker-compose run --rm brian1-stdp python "Diehl&Cook_spiking_MNIST.py" --test
        ;;
    "random")
        echo "Generating random connectivity matrices..."
        echo "This will create initial weight matrices in random/ directory"
        echo
        print_status
        docker-compose run --rm brian1-stdp python "Diehl&Cook_MNIST_random_conn_generator.py"
        ;;
    "evaluate")
        if [ ! -d "weights" ] || [ -z "$(ls -A weights/)" ]; then
            echo "Error: No weights found in weights/ directory"
            echo "Please run training first: $0 train"
            exit 1
        fi
        echo "Evaluating network performance..."
        echo "This will analyze the network results and generate detailed metrics"
        echo
        print_status
        docker-compose run --rm brian1-stdp python "Diehl&Cook_MNIST_evaluation.py"
        ;;
    "shell")
        echo "Opening shell in Docker container..."
        echo "You can run Python scripts manually from here"
        echo
        print_status
        docker-compose run --rm brian1-stdp /bin/bash
        ;;
    *)
        echo "STDP-MNIST Network Training/Testing Tool"
        echo
        echo "Usage: $0 {train|test|random|evaluate|shell}"
        echo
        echo "Commands:"
        echo "  train     - Train the network (3 epochs, 180k examples)"
        echo "  test      - Test the network (10k examples)"
        echo "  random    - Generate random connectivity matrices"
        echo "  evaluate  - Evaluate network performance"
        echo "  shell     - Open interactive shell in container"
        echo
        print_status
        exit 1
esac