#!/bin/bash


# Create Docker network
docker network create --subnet=198.51.100.0/24 u2128864/csvs2022_n

# Install Docker-Slim
curl -L -o ds.tar.gz https://downloads.dockerslim.com/releases/1.37.4/dist_linux.tar.gz
tar -xvf ds.tar.gz
mv  dist_linux/docker-slim /usr/local/bin/
mv  dist_linux/docker-slim-sensor /usr/local/bin/

# Install SELinux
sudo yum install selinux-policy-devel

# Enable SELinux
sudo nano /usr/lib/systemd/system/docker.service
#   # Modify one line from:
#   #     ExecStart=/usr/bin/dockerd
#   # To
#   #     ExecStart=/usr/bin/dockerd --selinux-enabled
#   # Save <CTRL> x and respond with y to "Save Changes" and press return to accept the filename.

# Restart Docker for enable the changes

sudo systemctl daemon-reload
systemctl restart docker

# Check SELinux is enabled and docker is running
docker info | grep -A5 Security
systemctl status docker


# Set Enforce to "Enforcing" mode
sudo setenforce 1
# Check Enforce status
sudo getenforce


