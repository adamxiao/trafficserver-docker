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

# Install TrafficServer
RUN mkdir -p /downloads/trafficserver && \
    wget http://mirrors.tuna.tsinghua.edu.cn/apache/trafficserver/trafficserver-7.1.6.tar.bz2 -O /downloads/trafficserver-7.1.6.tar.bz2 && \
    cd /downloads && tar xvf trafficserver-7.1.6.tar.bz2 -C /downloads/trafficserver --strip-components 1 && \
    cd /downloads/trafficserver && patch -p1 < /download/adam_certifier_slice.patch && \
    autoreconf -if && ./configure --prefix=/opt/trafficserver --enable-experimental-plugins --with-openssl=/opt/openssl && \
    make && make install

ADD ./files/etc/trafficserver /etc/trafficserver
#RUN mv /opt/trafficserver/etc/trafficserver /etc/trafficserver
RUN rm -rf /opt/trafficserver/etc/trafficserver && ln -sf /etc/trafficserver /opt/trafficserver/etc/trafficserver && \
	chmod 777 /opt/trafficserver/etc/trafficserver/certifier /opt/trafficserver/etc/trafficserver/certifier/certs && \
	chmod 666 /opt/trafficserver/etc/trafficserver/certifier/ca-serial.txt

EXPOSE 8080 8443

CMD ["/opt/trafficserver/bin/traffic_cop"]
