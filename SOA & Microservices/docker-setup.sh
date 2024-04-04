# Installing and Configuring Docker for Networking

# Install docker
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
# This will install docker for root user
sudo apt install docker-ce -y

# Optional change the usermod of docker (otherwise have to use sudo everytime using docker commands)
sudo groupadd docker # May say that docker already exists
sudo usermod -aG docker <username> # Example-> sudo usermod -aG docker ubuntu
# Check if the docker is present inside the username's group
groups <username> # Example->  groups ubuntu
# Now just try running docker commands
docker ps

# Create a custom bridge network with name 'net_a'
docker network create -d bridge --subnet 172.18.0.0/16 --gateway 172.18.0.1 --attachable net_a

docker run -d --restart=unless-stopped --name=docker-nginx1 --net net_a --ip=172.18.0.3 -v /root/docker-nginx/html:/usr/share/nginx/html brunodzogovic/nginx-webserver