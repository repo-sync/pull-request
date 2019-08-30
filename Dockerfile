FROM alpine

LABEL \
  "name"="GitHub Pull Request" \
  "homepage"="https://github.com/marketplace/actions/github-pull-request" \
  "repository"="https://github.com/repo-sync/pull-request" \
  "maintainer"="Wei He <github@weispot.com>"

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
  apk add --no-cache git hub

ADD *.sh /

ENTRYPOINT ["/entrypoint.sh"]
