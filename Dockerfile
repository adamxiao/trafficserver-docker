FROM centos:7.4.1708

MAINTAINER  Adam Xiao "http://github.com/adamxiao"

ARG DEBIAN_FRONTEND=noninteractive

RUN yum makecache \
    && yum install -y \
    autoconf \
    automake \
    libtool \
    pkgconfig \
    perl-ExtUtils-MakeMaker \
    gcc-c++ \
    openssl-devel \
    tcl-devel \
    pcre-devel \
    ncurses-devel libcurl-devl \
    libcap-devel \
    hwloc-devel \
    flex \
    wget bzip2 make patch

# Install openssl 1.1.1c
RUN mkdir -p /downloads/openssl && \
    wget https://www.openssl.org/source/openssl-1.1.1c.tar.gz -O /downloads/openssl-1.1.1c.tar.gz && \
    cd /downloads && tar xzf openssl-1.1.1c.tar.gz -C /downloads/openssl --strip-components 1 && \
    cd /downloads/openssl && ./config --prefix=/opt/openssl --openssldir=/usr/local/ssl && \
    make && make install

ADD ./files/adam_certifier_slice.patch /download/adam_certifier_slice.patch

# TODO: opt
RUN yum install -y libxml2-devel

# Install TrafficServer
RUN mkdir -p /downloads/trafficserver && \
    wget http://mirrors.tuna.tsinghua.edu.cn/apache/trafficserver/trafficserver-6.2.3.tar.bz2 -O /downloads/trafficserver-6.2.3.tar.bz2 && \
    cd /downloads && tar xvf trafficserver-6.2.3.tar.bz2 -C /downloads/trafficserver --strip-components 1 && \
    cd /downloads/trafficserver && \
    autoreconf -if && ./configure --prefix=/opt/trafficserver --enable-experimental-plugins --with-luajit=/usr --with-openssl=/opt/openssl && \
    make && make install && \
    rm -rf /downloads

ADD ./files/etc/trafficserver /etc/trafficserver.new
RUN mv /opt/trafficserver/etc/trafficserver /etc/trafficserver && \
    ln -sf /etc/trafficserver /opt/trafficserver/etc/trafficserver && \
    cp -r /etc/trafficserver /etc/trafficserver.org && \
    chown nobody -R /etc/trafficserver

EXPOSE 8080 8443

CMD ["/opt/trafficserver/bin/traffic_cop"]
