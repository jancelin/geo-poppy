FROM python:2

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY GPS.py ./
RUN stty -F /dev/ttyUSB0 4800

CMD [ "python", "./GPS.py" ]
