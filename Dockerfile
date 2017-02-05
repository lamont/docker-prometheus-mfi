FROM alpine:latest

MAINTAINER lamont@fastrobot.com

RUN apk update
RUN apk add ruby ruby-dev ruby-libs ruby-bundler
RUN apk add ca-certificates
RUN update-ca-certificates
RUN rm -r /var/cache/

ADD app /opt/app

EXPOSE 5000

WORKDIR /opt/app

RUN bundle install

ENTRYPOINT ["/usr/bin/foreman", "start", "-d", "/opt/app"]

