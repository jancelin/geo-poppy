FROM resin/rpi-raspbian:latest
MAINTAINER  Julien Ancelin from Irstea/collec \
            Logiciel diffusé sous licence AGPL \
            https://github.com/Irstea/collec

RUN echo "deb    http://http.debian.net/debian sid main " >> /etc/apt/sources.list
#RUN gpg --keyserver hkp://keys.gnupg.net:80 --recv-keys A04A6C4681484CF1
#RUN gpg --keyserver hkp://68.187.0.77:80 --recv-keys A04A6C4681484CF1
#RUN gpg --export A04A6C4681484CF1 | apt-key add -
RUN apt-get -y update
RUN apt-get -t sid install -y apache2 php7.0 php-mbstring php7.0-pgsql php7.0-xml php-xdebug php-curl default-jre php-gd fop php-imagick unzip ssl-cert vim
RUN apt-get clean && apt-get -y autoremove
RUN a2enmod ssl; a2enmod headers; a2enmod rewrite

# Generate certificate
RUN mkdir /etc/apache2/ssl
RUN /usr/sbin/make-ssl-cert /usr/share/ssl-cert/ssleay.cnf /etc/apache2/ssl/apache.pem

# Copy config site available
ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
ADD default-ssl.conf /etc/apache2/sites-available/default-ssl.conf

# Activ site
RUN a2ensite 000-default.conf; a2ensite default-ssl.conf

# Droits
RUN chmod -R g+r /etc/ssl/private
RUN command addgroup --system 'ssl-cert'
RUN usermod -a -G ssl-cert www-data

#Variable de dépot et de nom de dossier

ENV ZIP feature_metadata.zip
ENV REP collec-feature_metadata

# Install Collec
ADD https://github.com/Irstea/collec/archive/$ZIP /var/www/html

RUN unzip /var/www/html/$ZIP -d /var/www/html/ && \
    rm /var/www/html/$ZIP

# tempates-c
RUN mkdir /var/www/html/$REP/display/templates_c
RUN chmod 777 /var/www/html/$REP/display/templates_c && chmod 777 /var/www/html/$REP/temp

# Param
ADD param.inc.php /var/www/html/$REP/param/param.inc.php

# Droits
RUN chown -hR www-data:users /var/www/html/$REP && \
    sudo chmod -R 755 /var/www/html/$REP && \
    sudo chmod -R 777 /var/www/html/$REP/temp && \
    sudo chmod -R 777 /var/www/html/$REP/display/templates_c

#Start apache2
ADD start.sh /start.sh
RUN chmod 0755 /start.sh
CMD /start.sh
# Setup JAVA_HOME, this is useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-armhf/
RUN export JAVA_HOME

