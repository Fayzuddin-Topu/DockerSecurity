#!/bin/bash
# capability
docker run -d \
	--read-only --tmpfs /run --tmpfs /var/log/nginx/ --tmpfs /var/lib/nginx/tmp/ --tmpfs /var/log/php-fpm/ \
	--cap-drop=ALL \
	--cap-add=CHOWN --cap-add=NET_BIND_SERVICE --cap-add=SETGID --cap-add=SETUID \
	--net u2128864/csvs2022_n \
	--ip 198.51.100.180 \
	--hostname www.cyber22.test \
	--add-host db.cyber22.test:198.51.100.179 \
	-p 80:80 \
	--name u2128864_csvs2022-web_c u2128864/csvs2022-web_i

docker exec -i u2128864_csvs2022-web_c /usr/bin/chown -R 4444 /var/log/nginx/
docker exec -i u2128864_csvs2022-web_c sh -c 'apk add -U libcap; capsh --print'
