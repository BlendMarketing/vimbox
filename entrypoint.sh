#!/bin/sh

# Start the ssh server
sudo service ssh restart 

# Execute the CMD
exec "$@"
