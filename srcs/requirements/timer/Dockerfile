FROM debian:buster AS builder

RUN apt-get update -y && \
    apt-get install -y python3-pip python3.7 python3-venv;
COPY ./requirements.txt /app/requirements.txt
WORKDIR /app
RUN python3.7 -m venv venv && source /app/venv/bin/activate
RUN python3.7 -m pip install flask
COPY app.py /app/app.py

FROM debian:buster
COPY --from=builder /app /app
RUN python3.7 -m venv venv && source /app/venv/bin/activate
WORKDIR /app

ENTRYPOINT [ "python3" ]
CMD [ "app.py" ]