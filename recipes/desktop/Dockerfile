FROM pauldotknopf/darch-ubuntu-base-common

ADD script /scripts/script
ADD blacklist-packages /scripts/blacklist-packages
ADD pop.pref /scripts/pop.pref

RUN cd /scripts && ./script && rm -r /scripts