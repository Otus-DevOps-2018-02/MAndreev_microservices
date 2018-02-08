FROM ruby:2.2

WORKDIR /app
COPY . /app

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential && \
    bundle install && \
    rm -rf /var/lib/apt/lists/*


ENV POST_SERVICE_HOST post \
    POST_SERVICE_PORT 5000 \
    COMMENT_SERVICE_HOST comment \
    COMMENT_SERVICE_PORT 9292

CMD ["puma"]
