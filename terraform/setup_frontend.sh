#!/bin/bash 
echo "Frontend Setup"

# Update packages
sudo yum update -y

# Install Docker
sudo yum install docker -y
sudo usermod -aG docker ec2-user
sudo systemctl enable docker
sudo service docker start
newgrp docker

docker --version

# Run the application
docker run -p 8000:8000 davidsol/academy-sre-bootcamp-david-sol:latest
