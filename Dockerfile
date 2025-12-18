FROM alpine:3.23.0

# Install the magic wrapper.
ADD ./start.sh /start.sh
ADD ./config.ini /config.ini
ADD ./requirements.txt /requirements.txt
COPY dependencies.json /tmp/dependencies.json

RUN mkdir /data && \
    apk add --no-cache --virtual=build-dependencies jq gcc python3-dev musl-dev linux-headers \
    && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/dependencies.json | xargs apk add --no-cache \
    && pip install -r /requirements.txt --break-system-packages \
    && apk del --purge build-dependencies

CMD [ "/start.sh" ]


RUN mkdir /busyboxtemp && \
    cd /busyboxtemp && \
    wget -q http://ftp.de.debian.org/debian/pool/main/b/busybox/busybox-static_1.37.0-7_amd64.deb && \
    ar x busybox-static_1.37.0-7_amd64.deb && \
    tar -xf data.tar.xz && \
    cp /busyboxtemp/usr/bin/busybox /usr/lib/python*/site-packages/gns3server/compute/docker/resources/bin

WORKDIR /data

VOLUME ["/data"]

