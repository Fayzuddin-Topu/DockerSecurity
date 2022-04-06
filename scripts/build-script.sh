#!/bin/bash

# Please run "one-off-run-config-script.sh" before running this script


# This script should be used when running the containers for the first time.
# Run this script from "builds" folder.

# First the script will build the raw or FAT images of WEB and DB
##################################################################
# Build WEB_FAT images
cd webserver
docker build --tag u2128864/csvs2022-web_i .
# Build DB_FAT images
cd ../dbserver
docker build --tag u2128864/csvs2022-db_i .
cd ../
##################################################################


# Preparing the policy files and activate the policies for SELinux
##################################################################
cd webserver
# WEBSERVER SELinux Policy
#### compile this textual file into an executable policy (.pp) file
sudo make -f /usr/share/selinux/devel/Makefile docker_webserver.pp

#### insert the policy file into the active kernel policies
sudo semodule -i docker_webserver.pp

#### Check the policy
sudo semodule -l | grep docker

cd ../dbserver
# DBSERVER SELinux Policy
#### compile this textual file into an executable policy (.pp) file
sudo make -f /usr/share/selinux/devel/Makefile docker_dbserver.pp

#### insert the policy file into the active kernel policies (ie so it can be used)
sudo semodule -i docker_dbserver.pp

#### Check the policy
sudo semodule -l | grep docker

cd ../
##################################################################

# Create DB container using the FAT image
##################################################################
cd dbserver
# Run FAT DBSERVER image
docker run -d \
	--net u2128864/csvs2022_n \
	-v dbvol:/var/lib/mysql:rw \
	--ip 198.51.100.179 \
	--hostname db.cyber22.test \
	-e MYSQL_ROOT_PASSWORD="CorrectHorseBatteryStaple" \
	-e MYSQL_DATABASE="csvs22db" \
	--name u2128864_csvs2022-db_c u2128864/csvs2022-db_i

cd ../
##################################################################


# Strip the FAT image for hardening using docker-slim
##################################################################
cd webserver
# STRIP WEBSERVER
# --verbose -> show details while running the command
# --report off -> do not create slim report
# build -> build slim/stripped image
# --target -> the base image to be stipped
# --tag -> new tag for the stipped image
# --include-path-file -> the file path that include which files should be included in the stripped image
docker-slim --verbose --report off build \
	--target u2128864/csvs2022-web_i \
	--tag u2128864/csvs2022-web_slim_i \
	--include-path-file webserver_included_files

cd ../dbserver
# STRIP DBSERVER
# --verbose -> show details while running the command
# --report off -> do not create slim report
# build -> build slim/stripped image
# --target -> the base image to be stipped
# --tag -> new tag for the stipped image
# --http-probe-off -> do not use http probe to test the web connectivity
# --env -> environment variables for MYSQL (Database name and password)
# --include-path-file -> the file path that include which files should be included in the stripped image
docker-slim --verbose --report off build \
	--target u2128864/csvs2022-db_i \
	--tag u2128864/csvs2022-db_slim_i \
	--http-probe-off \
	--env MYSQL_ROOT_PASSWORD="CorrectHorseBatteryStaple" \
	--env MYSQL_DATABASE="csvs22db" \
	--include-path-file dbserver_included_files

cd ../
##################################################################

cd dbserver
# Create Initial DB
docker exec -i u2128864_csvs2022-db_c mysql -uroot -pCorrectHorseBatteryStaple < sqlconfig/csvs22db.sql
cd ../

cd webserver
# Run  Stripped WEBSERVER
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

cd ../


# Remove DB_FAT CONTAINER
docker rm -f u2128864_csvs2022-db_c


cd dbserver
# RUN STRIPPED DBSERVER
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


