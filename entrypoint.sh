#!/bin/bash

# Start the ssh server
sudo /etc/init.d/ssh restart && \
	sudo /etc/init.d/docker start

# Setup Docker NGINX + Network
sudo docker network create dockerbox
sudo docker run -d -p 80:80 --net dockerbox --restart unless-stopped -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy

# Execute the CMD
exec "$@"
