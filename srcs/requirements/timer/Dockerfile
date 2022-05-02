FROM debian:buster AS builder

RUN apt-get update -y && \
    apt-get install -y python3-pip python3.7 python3-venv;
COPY ./requirements.txt /app/requirements.txt

RUN python3.7 -m venv /app/venv && . /app/venv/bin/activate && python3.7 -m pip install flask;
COPY app.py /app/app.py
RUN chmod +x /app/app.py

FROM debian:buster
RUN apt-get update && apt-get install -y python3.7
COPY --from=builder /app /app
# activating venv, is just making its content first in the search $PATH!
ENV PATH="/app/venv/bin:$PATH"

CMD [ "python3.7", "/app/app.py" ]