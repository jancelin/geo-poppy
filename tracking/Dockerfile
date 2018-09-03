FROM python:2

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt


ADD GPS1.py ./
ADD usb.sh ./

WORKDIR /
CMD [ "python","-u","/usr/src/app/GPS1.py" ]
