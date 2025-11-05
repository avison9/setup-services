#!/bin/bash
set -e

# Install dependencies
apt-get update -y
apt-get install -y curl jq

# Create runner directory
mkdir -p /actions-runner && cd /actions-runner

# Download latest runner
curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-x64-2.317.0.tar.gz
tar xzf ./actions-runner-linux-x64.tar.gz

# Configure runner
./config.sh \
  --url https://github.com/${ORGANIZATION} \
  --token ${TOKEN} \
  --name ${RUNNER_NAME} \
  --unattended \
  --replace \
  --labels ubuntu,aws,ci

# Install and start as service
sudo ./svc.sh install
sudo ./svc.sh start