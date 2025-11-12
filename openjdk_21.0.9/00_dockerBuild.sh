#!/bin/bash

# Build the Docker image for cmig/OpenJDK 21.0.9
# Additional tools
docker build -f ./Dockerfile -t "openjdk_21_0_9:latest" .

exit 0