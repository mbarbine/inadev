#!/bin/bash

# Install Homebrew if not installed
if ! command -v brew &> /dev/null
then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install CLI tools: AWS CLI, kubectl, and Helm using Homebrew
# Function to check if a command is available
command_exists () {
  type "$1" &> /dev/null ;
}

# Install AWS CLI
if command_exists aws; then
  echo "AWS CLI already installed."
else
  echo "Installing AWS CLI..."
  brew install awscli
fi

# Install kubectl
if command_exists kubectl; then
  echo "kubectl already installed."
else
  echo "Installing kubectl..."
  brew install kubectl
fi

# Install Helm
if command_exists helm; then
  echo "Helm already installed."
else
  echo "Installing Helm..."
  brew install helm
fi

echo "All CLI tools are installed successfully!"
