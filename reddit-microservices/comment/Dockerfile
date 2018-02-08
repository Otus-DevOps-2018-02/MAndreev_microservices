FROM ruby:2.2

WORKDIR /app
COPY . /app

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential && \
    bundle install && \
    rm -rf /var/lib/apt/lists/*

ENV COMMENT_DATABASE_HOST comment_db \
    COMMENT_DATABASE comments

CMD ["puma"]
