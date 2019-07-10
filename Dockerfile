FROM ubuntu:18.04

MAINTAINER  Adam Xiao "http://github.com/adamxiao"

ARG DEBIAN_FRONTEND=noninteractive

# This runs all the yum installation, starting with a system level update
RUN apt-get update -y && \
    apt-get install -y \
    zlib1g-dev \
    wget \
    && \
    apt-get install -y \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libmodule-install-perl \
    g++ \
    tcl-dev \
    libssl-dev \
    libpcre3-dev \
    libcap-dev \
    libhwloc-dev  \
    libncurses5-dev \
    libcurl4-openssl-dev \
    flex

# Install openssl 1.1.1c

RUN mkdir -p /downloads/openssl && \
    wget https://www.openssl.org/source/openssl-1.1.1c.tar.gz -O /downloads/openssl-1.1.1c.tar.gz && \
    cd /downloads && tar xzf openssl-1.1.1c.tar.gz -C /downloads/openssl --strip-components 1 && \
    cd /downloads/openssl && ./config --prefix=/opt/openssl --openssldir=/usr/local/ssl && \
    make && make install

ADD ./files/adam_slice.patch /download/adam_slice.patch
ADD ./files/adam_certifier.patch /download/adam_certifier.patch

# Install TrafficServer
RUN mkdir -p /downloads/trafficserver && \
    wget https://mirrors.tuna.tsinghua.edu.cn/apache/trafficserver/trafficserver-8.0.3.tar.bz2 -O /downloads/trafficserver.tar.bz2 && \
    cd /downloads && tar xvf trafficserver.tar.bz2 -C /downloads/trafficserver --strip-components 1 && \
    cd /downloads/trafficserver && patch -p1 < /download/adam_slice.patch && patch -p1 < /download/adam_certifier.patch && \
	autoreconf -if && ./configure --prefix=/opt/trafficserver --enable-experimental-plugins --with-openssl=/opt/openssl && \
    make && make install

ADD ./files/etc/trafficserver /etc/trafficserver
#RUN mv /opt/trafficserver/etc/trafficserver /etc/trafficserver
RUN rm -rf /opt/trafficserver/etc/trafficserver && ln -sf /etc/trafficserver /opt/trafficserver/etc/trafficserver && \
	chmod 777 /opt/trafficserver/etc/trafficserver/certifier /opt/trafficserver/etc/trafficserver/certifier/certs && \
	chmod 666 /opt/trafficserver/etc/trafficserver/certifier/ca-serial.txt

EXPOSE 8080 8443

CMD ["/opt/trafficserver/bin/traffic_server"]
