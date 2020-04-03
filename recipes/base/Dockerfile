FROM godarch/ubuntu:bionic

ADD script /scripts/script
ADD network.yaml /scripts/network.yaml

RUN cd /scripts && ./script && rm -r /scripts