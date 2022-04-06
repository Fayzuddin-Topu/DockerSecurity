#!/bin/bash

# After editing the policy using the audit report, 
# repeat the process again to make sure the container is functioning properly.
# The policy should be edited manually to get better result.

############################ WEBSERVER SELinux ################################################

# Make the webserver policy file
sudo make -f /usr/share/selinux/devel/Makefile docker_webserver.pp
# Add the webserver policy to semodule
sudo semodule -i docker_webserver.pp
# Check the added policy exists
sudo semodule -l | grep docker

# Run the WEBSERVER with new policy
docker run -d \
	--cpuset-cpus=0 \
	--cpu-shares=50 \
	--memory=512m \
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
	--name u2128864_csvs2022-web_c u2128864/csvs2022-web_i

# If AVC denial occurs check the audit log
sudo cat /var/log/audit/audit.log
# Create audit allow rules and choose appropiate rules, then add to the policy file
sudo ausearch -m avc --start recent | audit2allow -r

###############################################################################################


############################ DBSERVER SELinux #################################################

# Make the dbserver policy file
sudo make -f /usr/share/selinux/devel/Makefile docker_dbserver.pp
# Add the dbserver policy to semodule
sudo semodule -i docker_dbserver.pp
# Check the added policy exists
sudo semodule -l | grep docker

# Run the DBSERVER with new policy
docker run -d \
	--cpuset-cpus=0 \
	--cpu-shares=50 \
	--memory=512m \
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
	--name u2128864_csvs2022-db_c u2128864/csvs2022-db_i

# If AVC denial occurs check the audit log
sudo cat /var/log/audit/audit.log
# Create audit allow rules and choose appropiate rules, then add to the policy file
sudo ausearch -m avc --start recent | audit2allow -r

###############################################################################################
