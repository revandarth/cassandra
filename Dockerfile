FROM containers.cisco.com/oneidentity/centos7-java:v2.5
MAINTAINER Revanth R Airre <reairre@cisco.com>

ENV CASSANDRA_VERSION=2.2.9

ENV CASSANDRA_BASE=/opt/cassandra \
    CASSANDRA_HOME=/opt/cassandra/apache-cassandra-${CASSANDRA_VERSION} \
    CASSANDRA_DATA=/cassandra_data/data \
    CASSANDRA_COMMITLOG=/cassandra_data/commitlog \
    CASSANDRA_SAVED_CACHES=/cassandra_data/saved_caches 

COPY utility/ /
RUN mv /cassandra.conf /etc/supervisor/conf.d/cassandra.conf
RUN mv /run.sh /bin/ 
RUN mv /readiness.sh /usr/local/bin/
RUN mv /health.sh /usr/local/bin/


RUN chmod 777 /bin/run.sh \
              /usr/local/bin/readiness.sh \
              /usr/local/bin/health.sh

## Create data directories that should be used by Cassandra
RUN mkdir -p ${CASSANDRA_DATA} \
             ${CASSANDRA_BASE} \
             ${CASSANDRA_SAVED_CACHES} \
             ${CASSANDRA_COMMITLOG} \
             ${CASSANDRA_UTILITY}
RUN tar -xzf /apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz -C /opt/cassandra/ 

RUN chmod 777 ${CASSANDRA_HOME} \
              ${CASSANDRA_DATA} \
              ${CASSANDRA_SAVED_CACHES} \
              ${CASSANDRA_COMMITLOG}


RUN mv /cassandra.yaml ${CASSANDRA_HOME}/conf/
RUN mv /kubernetes-cassandra.jar ${CASSANDRA_HOME}/lib/
RUN mv /servicediscovery.json /etc/consul/

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160