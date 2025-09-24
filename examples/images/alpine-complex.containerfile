FROM ghcr.io/linuxcontainers/alpine

RUN apk update && apk add curl

WORKDIR /app

CMD ["sh"]
