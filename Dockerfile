FROM python:3.6-alpine

ENV PYTHONDONTWRITEBYTECODE=True
WORKDIR /var/microservices

RUN apk add \
        tini \
        make \
        gcc \
        g++ \
        libffi-dev \
        libcap

# Enhancing caching
ADD requirements.txt .
RUN pip install -r requirements.txt

ADD private_requirements.txt .
RUN pip install -r private_requirements.txt

RUN     apk del \
        make \
        gcc \
        g++ \
    && rm -rf /var/cache/apk/* \
    && setcap 'cap_net_bind_service=+eip' /usr/local/bin/python3.6

ADD --chown=xfs:xfs . .
RUN chmod +x ./startup.sh

#Need of uid:gid 33:33 that is xfs in this image
USER xfs
ENTRYPOINT ["/sbin/tini", "--"]
CMD [ "./startup.sh" ]
