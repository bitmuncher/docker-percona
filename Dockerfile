FROM debian:jessie
MAINTAINER Frank Fuhrmann <frank.fuhrmann@mailbox.org>

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

RUN apt-get update
RUN apt-get -y upgrade

RUN apt-get -y install wget lsb-release nano

RUN wget https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb
RUN dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb
RUN rm percona-release_0.1-4.$(lsb_release -sc)_all.deb

RUN apt-get update
RUN apt-get -y install percona-server-server-5.7

RUN apt-get -y --purge remove wget lsb-release
RUN rm -rf /var/lib/mysql/*

COPY run.sh /run.sh
RUN chmod a+rx /run.sh

COPY conf/my.cnf /etc/mysql/my.cnf
RUN sed "s/bind-address/#bind-address/g" /etc/mysql/percona-server.conf.d/mysqld.cnf

VOLUME /var/log/mysql
VOLUME /var/lib/mysql

EXPOSE 3306

CMD sh -c '/run.sh'
