#!/bin/bash
# Python Setup from bash

# WSL in Windows
wget -O ~/conda.sh \
    https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash ~/conda.sh
rm conda.sh && source ~/.bashrc
conda update -y conda && conda update -y --all
conda install -y radian pandas plotnine scikit-learn pyarrow pyfinance linearmodels polar

# OS X
# Install xcode from App Store, then:
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
brew update && brew upgrade
brew install miniforge
conda init zsh
conda update -y conda && conda update -y --all
conda install -y pandas plotnine scikit-learn pyarrow pyfinance
pip3 install linearmodels radian

