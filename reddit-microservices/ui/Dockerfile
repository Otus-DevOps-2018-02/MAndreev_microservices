FROM ruby:2.2-alpine

WORKDIR /app
COPY . /app

RUN apk add --no-cache build-base && \
    bundle install && \
    apk del build-base && \
    rm -rf /root/.bundle
