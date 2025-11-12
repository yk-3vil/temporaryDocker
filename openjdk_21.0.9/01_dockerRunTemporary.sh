#!/bin/bash

docker run -it --rm \
  --mount type=bind,source="$(pwd)",target=/home/circleci/project \
  -w /home/circleci/project \
  --name "openjdk_21_0_9_container" \
  "openjdk_21_0_9:latest" \
  "/bin/bash"

exit 0