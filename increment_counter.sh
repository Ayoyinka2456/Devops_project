#!/bin/bash

# Check if the variable exists, if not set it to 0
if [ -z "$COUNTER" ]; then
  export COUNTER=0
fi

# Increment the counter
export COUNTER=$((COUNTER + 1))

echo "COUNTER is now: $COUNTER"
