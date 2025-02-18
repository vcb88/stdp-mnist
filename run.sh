#!/bin/bash

# Helper script for running STDP-MNIST in Docker

# Create necessary directories
mkdir -p mnist weights random results

# Ensure correct permissions
chmod 777 mnist weights random results

# Build Docker image
echo "Building Docker image (this may take a while)..."
if ! docker-compose build; then
    echo
    echo "Error: Docker build failed!"
    echo "Common issues:"
    echo "1. Internet connectivity problems"
    echo "2. Package repository issues"
    echo "3. Insufficient disk space"
    echo
    echo "You can try:"
    echo "- Check your internet connection"
    echo "- Run 'docker system prune' to clean up Docker cache"
    echo "- Check available disk space with 'df -h'"
    echo
    exit 1
fi

# Enable X11 forwarding
echo "Enabling X11 forwarding..."
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
        # Default values
        examples=60000
        epochs=3
        
        # Check for additional arguments
        if [ "$2" != "" ]; then
            examples=$2
        fi
        if [ "$3" != "" ]; then
            epochs=$3
        fi
        
        echo "Starting network training..."
        echo "This will:"
        echo "- Process $examples training examples per epoch"
        echo "- Run for $epochs epochs ($((examples * epochs)) total examples)"
        echo "- Save weights in weights/ directory"
        echo "- Generate plots in results/ directory"
        echo
        print_status
        echo "Starting Docker container..."
        docker-compose run --rm brian1-stdp python "Diehl&Cook_spiking_MNIST.py" --train --examples $examples --epochs $epochs
        ;;
    "test")
        if [ ! -d "weights" ] || [ -z "$(ls -A weights/)" ]; then
            echo "Error: No weights found in weights/ directory"
            echo "Please run training first: $0 train"
            exit 1
        fi
        
        # Default value
        examples=10000
        
        # Check for additional argument
        if [ "$2" != "" ]; then
            examples=$2
        fi
        
        echo "Starting network testing..."
        echo "This will:"
        echo "- Load weights from weights/ directory"
        echo "- Process $examples test examples"
        echo "- Generate evaluation plots"
        echo
        print_status
        echo "Starting Docker container..."
        docker-compose run --rm brian1-stdp python "Diehl&Cook_spiking_MNIST.py" --test --examples $examples
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
        echo "Usage:"
        echo "  $0 train [examples_per_epoch] [num_epochs]  - Train the network"
        echo "  $0 test [num_examples]                      - Test the network"
        echo "  $0 random                                   - Generate connectivity"
        echo "  $0 evaluate                                 - Evaluate performance"
        echo "  $0 shell                                   - Open shell in container"
        echo
        echo "Examples:"
        echo "  $0 train                   # Train with defaults (60000 examples, 3 epochs)"
        echo "  $0 train 1000 2            # Train with 1000 examples for 2 epochs"
        echo "  $0 test                    # Test with defaults (10000 examples)"
        echo "  $0 test 100                # Test with 100 examples"
        echo
        print_status
        exit 1
esac