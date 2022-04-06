#!/bin/bash

# Please run one-off-run-config-script.sh to ensure all prerequisites are met.
# If running the containers for the first time please use the script named "build-script.sh"
# This script can be used to re-run the docker containers.

# Start WEBSERVER
# run -> run the container
# -d -> detach the container while running
# --cpuset-cpus -> which CPU the container should use
# --cpu-shares -> how much CPU resource the container can use
# --memory -> maximum memory the container can use
# --security-opt seccomp:webserver.json -> use webserver.json file for seccomp profile
# --security-opt label:type:docker_webserver_t -> use docker_webserver_t as SELinux policy profile
# --read-only -> make the file system read-only
# --tmpfs -> make the directory writable temporarily
# --cap-drop=ALL -> drop all capability for the container
# --cap-add -> add specified capability for the container
# --security-opt=no-new-privileges -> prevent privilege escalation
docker run -d \
	--cpuset-cpus=0 \
	--cpu-shares=50 \
	--memory=512m \
	--security-opt seccomp:webserver.json \
	--security-opt label:type:docker_webserver_t \
	--read-only --tmpfs /run --tmpfs /var/log/nginx/ --tmpfs /var/lib/nginx/tmp/ --tmpfs /var/log/php-fpm/ \
	--cap-drop=ALL \
	--cap-add=CHOWN --cap-add=NET_BIND_SERVICE --cap-add=SETGID --cap-add=SETUID \
	--security-opt=no-new-privileges \
	--net u2128864/csvs2022_n \
	--ip 198.51.100.180 \
	--hostname www.cyber22.test \
	--add-host db.cyber22.test:198.51.100.179 \
	-p 80:80 \
	--name u2128864_csvs2022-web_c u2128864/csvs2022-web_slim_i

# Start DBSERVER
# run -> run the container
# -d -> detach the container while running
# --cpuset-cpus -> which CPU the container should use
# --cpu-shares -> how much CPU resource the container can use
# --memory -> maximum memory the container can use
# --security-opt seccomp:dbserver.json -> use dbserver.json file for seccomp profile
# --security-opt label:type:docker_dbserver_t -> use docker_dbserver_t as SELinux policy profile
# --read-only -> make the file system read-only
# --tmpfs -> make the directory writable temporarily
# -v -> mount volume from host
# --cap-drop=ALL -> drop all capability for the container
# --cap-add -> add specified capability for the container
# --security-opt=no-new-privileges -> prevent privilege escalation
docker run -d \
	--cpuset-cpus=0 \
	--cpu-shares=50 \
	--memory=512m \
	--security-opt seccomp:dbserver.json \
	--security-opt label:type:docker_dbserver_t \
	--cap-drop=ALL \
	--security-opt=no-new-privileges \
	-v dbvol:/var/lib/mysql:rw \
	--read-only --tmpfs /tmp --tmpfs /var/run/mysqld/ --tmpfs /run/mysqld/ \
	--net u2128864/csvs2022_n \
	--ip 198.51.100.179 \
	--hostname db.cyber22.test \
	-e MYSQL_ROOT_PASSWORD="CorrectHorseBatteryStaple" \
	-e MYSQL_DATABASE="csvs22db" \
	--name u2128864_csvs2022-db_c u2128864/csvs2022-db_slim_i
