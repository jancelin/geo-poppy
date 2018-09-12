FROM python:2

WORKDIR /usr/src/app

COPY requirements.txt ./
#RUN pip install --no-cache-dir -r requirements.txt
RUN pip install pyserial

ADD geolocation_firefox.py ./
ADD geolocation_server.py ./
ADD usb.sh ./

WORKDIR /
EXPOSE 1950
CMD [ "python","-u","/usr/src/app/geolocation_firefox.py" ]
#CMD [ "python","-u","/usr/src/app/geolocation_server.py" ]
