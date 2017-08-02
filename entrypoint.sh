#!/bin/bash

# Start the ssh server
sudo /etc/init.d/ssh restart && \
	sudo /etc/init.d/docker start

cd ~/
sudo docker-compose up -d

# Execute the CMD
exec "$@"
