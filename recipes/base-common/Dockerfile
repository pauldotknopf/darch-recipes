FROM pauldotknopf/darch-ubuntu-base

ARG ROOT_PASSWD=password
ARG USER_PASSWD=password

ADD script /scripts/script

RUN cd /scripts && ./script && rm -r /scripts