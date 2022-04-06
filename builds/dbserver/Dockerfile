# Database Dockerfile

FROM mariadb:10

COPY configfiles/mysqld.cnf  /mysql/mysql.conf.d/mysqld.cnf
RUN chown mysql:mysql /mysql/*

# Change user
USER mysql

EXPOSE 3306
