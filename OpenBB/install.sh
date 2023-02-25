#!/bin/bash
# Instructions from https://docs.openbb.co/terminal/quickstart/installation
# Linux
sudo apt install -y gcc cmake
# MacOS
brew install cmake

# Clone the repository
cd ~/
git clone https://github.com/OpenBB-finance/OpenBBTerminal.git OpenBB

# Create Virtual Environment
cd OpenBB/
conda env create -n OpenBB --file build/conda/conda-3-9-env-full.yaml
conda activate OpenBB

# Install Dependencies
# M1 Mac ML Toolkit and Optimization
conda install -c conda-forge lightgbm=3.3.3 cvxpy=1.2.2 -y

# All
poetry install
# Portfolio Optimization
poetry install -E optimization
# ML Toolkit
poetry install -E forecast

# Start
openbb

