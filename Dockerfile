FROM ubuntu:18.04

MAINTAINER  Adam Xiao "http://github.com/adamxiao"

ARG DEBIAN_FRONTEND=noninteractive

# This runs all the yum installation, starting with a system level update
RUN apt-get update -y && \
    apt-get install -y \
    zlib1g-dev \
    libluajit-5.1-dev \
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
    autoreconf -if && ./configure --prefix=/opt/trafficserver --enable-experimental-plugins --with-luajit=/usr --with-openssl=/opt/openssl && \
    make && make install && \
    rm -rf /downloads

ADD ./files/etc/trafficserver /etc/trafficserver.new
RUN mv /opt/trafficserver/etc/trafficserver /etc/trafficserver && \
    ln -sf /etc/trafficserver /opt/trafficserver/etc/trafficserver && \
    cp -r /etc/trafficserver /etc/trafficserver.org && \
    cp -r /etc/trafficserver.new/* /etc/trafficserver/ && \
    chown nobody -R /etc/trafficserver && \
    chmod 777 /etc/trafficserver/certifier /etc/trafficserver/certifier/certs && \
    chmod 666 /etc/trafficserver/certifier/ca-serial.txt

EXPOSE 8080 8443

CMD ["/opt/trafficserver/bin/traffic_manager"]
