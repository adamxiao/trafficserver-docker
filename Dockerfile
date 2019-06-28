FROM ubuntu:18.04

MAINTAINER  Adam Xiao "http://github.com/adamxiao"

ARG DEBIAN_FRONTEND=noninteractive

# This runs all the yum installation, starting with a system level update
RUN apt-get update -y && \
    apt-get install -y \
    zlib1g-dev \
    wget \
    git \
    vim \
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

# Install TrafficServer
RUN mkdir -p /downloads/ && \
    git clone https://github.com/apache/trafficserver /downloads/trafficserver && \
    cd /downloads/trafficserver && \
    autoreconf -if && ./configure --prefix=/opt/trafficserver --enable-experimental-plugins && \
    make && make install && \
    rm -rf /downloads

ADD ./files/etc/trafficserver /etc/trafficserver
RUN mv /opt/trafficserver/etc/trafficserver /etc/trafficserver
RUN ln -sf /etc/trafficserver /opt/trafficserver/etc/trafficserver

EXPOSE 8080

CMD ["/opt/trafficserver/bin/traffic_server"]
