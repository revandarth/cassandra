FROM centos
MAINTAINER Revanth R Airre <reairre@cisco.com>

RUN yum update -y
RUN yum install -y java-1.8.0-openjdk

RUN java -version
COPY utility/ /

RUN \
    mkdir /opt/cassandra; \
    mkdir /cassandra_data; \
    mkdir /cassandra_data/data; \
    mkdir /cassandra_data/commitlog; \
    ls -la /cassandra_data; \
    mkdir /cassandra_data/saved_caches; \
    chmod 777 /cassandra_data; \
    chmod +x /run.sh; \
    tar xf apache-cassandra-2.2.9-bin.tar.gz -C /opt/cassandra; \
    chmod +x /opt/cassandra; \
    cp /cassandra.yaml /opt/cassandra/apache-cassandra-2.2.9/conf
EXPOSE 7000 7001 7199 9042 9160

CMD ["/bin/bash", "/run.sh"]





