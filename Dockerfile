FROM alpine

LABEL "com.github.actions.name"="Github Pull Request"
LABEL "com.github.actions.description"="⤵️ Create pull request"
LABEL "com.github.actions.icon"="git-pull-request"
LABEL "com.github.actions.color"="black"

LABEL "repository"="http://github.com/wei/pull-request"
LABEL "homepage"="http://github.com/wei/pull-request"
LABEL "maintainer"="Wei He <github@weispot.com>"

RUN echo http://dl-4.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
  apk add --no-cache git hub

ADD *.sh /

ENTRYPOINT ["/entrypoint.sh"]
