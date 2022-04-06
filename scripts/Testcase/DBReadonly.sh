#!/bin/bash
# read-only
docker run -d \
	--read-only --tmpfs /tmp --tmpfs /var/run/mysqld/ --tmpfs /run/mysqld/ \
	--net u2128864/csvs2022_n \
	--ip 198.51.100.179 \
	--hostname db.cyber22.test \
	-e MYSQL_ROOT_PASSWORD="CorrectHorseBatteryStaple" \
	-e MYSQL_DATABASE="csvs22db" \
	--name u2128864_csvs2022-db_c u2128864/csvs2022-db_i

docker exec -i u2128864_csvs2022-db_c mysql -uroot -pCorrectHorseBatteryStaple < sqlconfig/csvs22db.sql
docker exec -i u2128864_csvs2022-web_c /usr/bin/touch test
docker exec -i u2128864_csvs2022-web_c /usr/bin/touch /tmp/test

