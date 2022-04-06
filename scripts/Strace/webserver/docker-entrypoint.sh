#!/bin/bash

############## Sleep code for STRACE ################
echo "wating for /output_c/ready" 1>&2

while [ ! -f /output_c/ready ]
do
  sleep 5
done
rm output_c/ready
echo "launching ENTRYPOINT" 1>&2
#####################################################

mkdir -p /run/php-fpm/
/usr/sbin/nginx
/usr/sbin/php-fpm -F
