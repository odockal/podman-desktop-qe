FROM alpine:latest
RUN echo $PATH
COPY echo_and_run.sh /usr/bin/
RUN ls -al /usr/bin/echo_and_run.sh
ENTRYPOINT ["echo_and_run.sh"]
