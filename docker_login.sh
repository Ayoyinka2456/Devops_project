#!/bin/bash
export DOCKER_USERNAME=ayoyinka
export DOCKER_PSWD=joshuaakinlolu

echo "$DOCKER_PSWD" | docker login -u "$DOCKER_USERNAME" --password-stdin
