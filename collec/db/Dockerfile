FROM jancelin/geopoppy:postgis

MAINTAINER  Julien Ancelin - Christine Plumejeaud \
            db test for IRSTEA/Collec 

#RUN apt-get update
#RUN apt-get install postgresql-contrib-9.6
ADD start-postgis.sh /start-postgis.sh
ADD collec.sql /collec.sql
RUN chmod 0755 /start-postgis.sh

CMD /start-postgis.sh

