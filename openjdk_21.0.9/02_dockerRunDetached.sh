#!/bin/bash

docker run -d \
  --mount type=bind,source="$(pwd)",target=/home/circleci/project \
  -w /home/circleci/project \
  --name "openjdk_21_0_9_container" \
  "openjdk_21_0_9:latest" \
  "/bin/bash" \
  -c "while :; do sleep 10; done"

exit 0