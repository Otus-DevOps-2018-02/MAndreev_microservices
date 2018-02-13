FROM ruby:2.2-alpine

WORKDIR /app
COPY . /app

RUN apk add --no-cache build-base && \
    bundle install && \
    apk del build-base && \
    rm -rf /root/.bundle

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
