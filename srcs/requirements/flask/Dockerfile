FROM debian:buster


RUN apt-get update -y && \
    apt-get install -y python-pip python-dev; \
    apt-get install -y python3.5
COPY ./requirements.txt /app/requirements.txt

WORKDIR /app

RUN pip install -r requirements.txt

COPY . /app

ENTRYPOINT [ "python" ]

CMD [ "app.py" ]