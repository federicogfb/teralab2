FROM public.ecr.aws/docker/library/php:8.0-apache

Instalar dependencias del sistema y Composer
RUN apt-get update && apt-get install -y git unzip
RUN docker-php-ext-install mysqli pdo pdo_mysql

Instalar Composer
COPY --from=public.ecr.aws/composer/composer:latest /usr/bin/composer /usr/bin/composer

Copiar archivos de la aplicación
COPY . /var/www/html/
WORKDIR /var/www/html

Instalar dependencias de Composer
RUN composer install --no-dev --optimize-autoloader --no-interaction

Configuración de Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN mkdir -p /var/log/apache2/example-app
COPY apache/default-site.conf /etc/apache2/sites-available/000-default.conf
RUN sed -i 's/ServerName example-app.com/ServerName localhost/' /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

Copiar archivos de configuración
COPY config/db-connection.php /var/www/html/config/db-connection.php
COPY config-dev/vhost.conf /var/www/html/config/vhost.conf

Crear directorio de logs con permisos de escritura
RUN mkdir -p /var/www/html/logs && \
    chmod 777 /var/www/html/logs && \
    chown www-data:www-data /var/www/html/logs

Permisos generales (DESPUÉS de crear logs)
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html
RUN chmod 777 /var/www/html/logs

EXPOSE 80

#FROM public.ecr.aws/docker/library/php:7.2-apache

# COPY . /var/www/html
# COPY ./apache/default-site.conf /etc/apache2/sites-available/default-site.conf

# WORKDIR /var/www/html

# #Esto es del dockerfile de lisandro, necesario para poder tirar los apt update y upgrade`3
# RUN sed -i -e 's/deb.debian.org/archive.debian.org/g' \
#            -e 's|security.debian.org|archive.debian.org/|g' \
#            -e '/stretch-updates/d' /etc/apt/sources.list

# RUN apt-get update && apt-get upgrade -y
# RUN apt-get update && apt-get install wget git -y

# RUN composer install --no-dev --optimize-autoloader --no-interaction

# #Esto es del dockerfile de joaco
# RUN ln -s /etc/apache2/sites-available/default-site.conf /etc/apache2/sites-enabled/default-site.conf

# #Esto es del dockerfile de lisandro, si no lo uso (osea, si no se desactiva el 000-default) la app te tira Forbidden.
# RUN a2dissite 000-default.conf && \
#     a2ensite default-site.conf

# RUN docker-php-ext-install pdo pdo_mysql &&\
# 	docker-php-ext-configure pdo &&\
# 	docker-php-ext-configure pdo_mysql

# RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf &&\
# 	chown -R www-data:www-data /var/www/html/ &&\
# 	# sed -i 's/localhost/database/g' ./config/db-connection.php &&\
# 	mkdir /var/log/apache2/example-app/ &&\
# 	chown -R www-data:www-data /var/log/apache2/example-app/ &&\
# 	a2enmod rewrite &&\
# 	service apache2 restart

# ##Remove unnecesary files
# RUN rm -r sql/ apache/ &&\
# 	rm Dockerfile Makefile README.md

# EXPOSE 80
