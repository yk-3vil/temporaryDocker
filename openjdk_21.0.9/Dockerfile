FROM cimg/openjdk:21.0.9
# HOME DIR is /home/circleci/project

# Install additional packages
RUN sudo apt-get update && \
  sudo apt-get install -y --no-install-recommends \
  vim && \
  sudo apt-get clean &&\
  sudo rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]