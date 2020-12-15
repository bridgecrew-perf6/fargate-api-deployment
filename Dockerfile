FROM python:3.8-slim-buster

ADD ./app/* /app/

WORKDIR /app

RUN pip install -r requirements.txt

EXPOSE 8000

ENTRYPOINT [ "gunicorn", "--log-level", "debug", "--bind", "0.0.0.0:8000", "api:app" ]