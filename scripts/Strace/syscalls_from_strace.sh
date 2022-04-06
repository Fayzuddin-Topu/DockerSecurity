#!/bin/bash

# Use the modified files from /csvs/scripts/Strace/webserver and /csvs/scripts/Strace/dbserver
# to build the images. Those modified files include a waiting loop. 


# After starting the container that contains waiting loop, run the commands below from the host 
# to start the strace command for container process.

# WEBSERVER
sudo strace -p $(docker inspect -f '{{.State.Pid}}' u2128864_csvs2022-web_c) -ff -o output_h/host-strace-output
# DBSERVER
sudo strace -p $(docker inspect -f '{{.State.Pid}}' u2128864_csvs2022-db_c) -ff -o output_h/host-strace-output

# From another terminal run this command to break the loop
touch output_h/ready

# After waiting some time the console will not show any updates. Crtl-C to stop strace and use the command below to get
# syscall list.

# Sort and filter all system calls from raw Strace result
cat output_h/* | grep -oE "^[a-z0-9_]+" | sort | uniq | sed 's/^/\"/; s/$/\",/' > webserverStrace.txt
