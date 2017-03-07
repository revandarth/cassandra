#!/bin/bash

set -e
CFG=/opt/cassandra/apache-cassandra-2.2.9/conf/cassandra.yaml
CASSANDRA_RPC_ADDRESS="${CASSANDRA_RPC_ADDRESS:-0.0.0.0}"
CASSANDRA_NUM_TOKENS="${CASSANDRA_NUM_TOKENS:-32}"
CASSANDRA_CLUSTER_NAME="${CASSANDRA_CLUSTER_NAME:='Test Cluster'}"
CASSANDRA_LISTEN_ADDRESS=${POD_IP}
CASSANDRA_BROADCAST_ADDRESS=${POD_IP}
CASSANDRA_BROADCAST_RPC_ADDRESS=${POD_IP}

# TODO what else needs to be modified

for yaml in \
  broadcast_address \
  broadcast_rpc_address \
  cluster_name \
  listen_address \
  num_tokens \
  rpc_address \
; do
  var="CASSANDRA_${yaml^^}"
	val="${!var}"
	if [ "$val" ]; then
		sed -ri 's/^(# )?('"$yaml"':).*/\2 '"$val"'/' "$CFG"
	fi
done

echo "JVM_OPTS=\"\$JVM_OPTS -Djava.rmi.server.hostname=$POD_IP\"" >> /opt/cassandra/apache-cassandra-2.2.9/conf/cassandra-env.sh


# FIXME create README for these args
echo "Starting Cassandra on $POD_IP"
echo CASSANDRA_RPC_ADDRESS ${CASSANDRA_RPC_ADDRESS}
echo CASSANDRA_NUM_TOKENS ${CASSANDRA_NUM_TOKENS}
echo CASSANDRA_CLUSTER_NAME ${CASSANDRA_CLUSTER_NAME}
echo CASSANDRA_LISTEN_ADDRESS ${POD_IP}
echo CASSANDRA_BROADCAST_ADDRESS ${POD_IP}
echo CASSANDRA_BROADCAST_RPC_ADDRESS ${POD_IP}

/opt/cassandra/apache-cassandra-2.2.9/bin/cassandra -f


