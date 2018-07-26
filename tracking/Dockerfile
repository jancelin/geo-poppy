FROM python:2

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY GPS1.py ./
WORKDIR /
CMD [ "python", "/usr/src/app/GPS1.py" ]
