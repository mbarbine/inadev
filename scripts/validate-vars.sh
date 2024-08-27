#!/bin/bash

# Validate if required environment variables are set

VARS_DIR="../us-east-2/vars"

if [ ! -f "$VARS_DIR/common.tfvars" ] || [ ! -f "$VARS_DIR/stage.tfvars" ] || [ ! -f "$VARS_DIR/prod.tfvars" ]; then
  echo "ERROR: One or more variable files are missing in $VARS_DIR."
  exit 1
fi

echo "All variable files are present."
