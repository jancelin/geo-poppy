FROM jancelin/geopoppy:postgis
MAINTAINER  Julien Ancelin \
            build for IRSTEA/Collec


ADD start-postgis.sh /start-postgis.sh
RUN chmod 0755 /start-postgis.sh

CMD /start-postgis.sh
