#!/bin/bash
# Flutter Project Setup Script
# Run this script to create the directory structure and files

set -e

cd "$(dirname "$0")"

echo "Creating Flutter project structure..."

# Create directory structure
mkdir -p lib/domain/models
mkdir -p lib/data/repositories
mkdir -p lib/presentation/screens
mkdir -p lib/presentation/widgets
mkdir -p lib/presentation/state
mkdir -p test
mkdir -p integration_test

echo "Directory structure created successfully!"
echo "Now creating source files..."

# The actual Dart files will be created in subsequent steps
# This script establishes the necessary directory structure

echo "Setup complete! Ready for Dart file creation."
