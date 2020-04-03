FROM pauldotknopf/darch-ubuntu-desktop

ADD script /scripts/script
ADD products /scripts/products

RUN cd /scripts && ./script && rm -r /scripts