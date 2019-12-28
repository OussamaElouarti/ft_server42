FROM debian:buster

#install nginx
RUN apt-get update && apt-get install -y nginx wget lsb-release gnupg
#install mysql noninteracvtive
RUN wget https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb 
RUN DEBIAN_FRONTEND=noninteractive echo 'mysql-apt-config mysql-apt-config/select-server select mysql-5.7' | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.13-1_all.deb 
RUN apt-get update 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
#install phpmyadmin
RUN apt-get install -y php7.3-readline
RUN apt-get install -y php7.3-opcache
RUN apt-get install -y php7.3-json
RUN apt-get install -y php7.3-common
RUN apt-get install -y php7.3-cli
RUN apt-get install -y php-common
RUN apt-get install -y php7.3-mysql
RUN apt-get install -y php7.3-fpm
RUN rm /etc/nginx/sites-enabled/default
COPY /srcs/default.conf /etc/nginx/conf.d/
COPY /srcs/phpmyadmin.conf /etc/nginx/conf.d/
RUN apt-get install -y php-json php-mbstring 
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.tar.gz
RUN tar -zxvf phpMyAdmin-4.9.0.1-all-languages.tar.gz
RUN mv phpMyAdmin-4.9.0.1-all-languages /usr/share/nginx/html/phpmyadmin
RUN rm phpMyAdmin-4.9.0.1-all-languages.tar.gz
RUN mkdir /usr/share/nginx/html/phpmyadmin/tmp
RUN chmod 777 /usr/share/nginx/html/phpmyadmin/tmp
COPY /srcs/config.inc.php /usr/share/nginx/html/phpmyadmin
RUN chown www-data:www-data /usr/share/nginx/html/phpmyadmin -R
#install wordpress
RUN wget wordpress.org/latest.tar.gz
RUN tar xvf latest.tar.gz
RUN mv wordpress/* /usr/share/nginx/html/
COPY /srcs/wp-config.php /usr/share/nginx/html/
RUN chown -R www-data:www-data /usr/share/nginx/html/
COPY /srcs/wordpress.conf /etc/nginx/conf.d
RUN mkdir /etc/nginx/ssl
COPY /srcs/nginx.key /etc/nginx/ssl
COPY /srcs/nginx.crt /etc/nginx/ssl
CMD chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && service mysql start && service php7.3-fpm start && service nginx start && echo "CREATE DATABASE wp_db;" | mysql -u root && echo "GRANT ALL PRIVILEGES ON wp_db.* TO 'wp_user'@'localhost' IDENTIFIED BY '123';" | mysql -u root ; cat
