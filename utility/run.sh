#!/bin/bash

set -e
echo "Cassandra run file started"
CASSANDRA_CONF_DIR=$CASSANDRA_HOME/conf
CASSANDRA_CFG=$CASSANDRA_CONF_DIR/cassandra.yaml

CASSANDRA_REPLACE_NODE=''


#if [ -f "$CASSANDRA_UTILITY/old_ip" ]; then
#    CASSANDRA_REPLACE_NODE="$(<$CASSANDRA_UTILITY/old_ip)"
#fi

#CASSANDRA_NEW_IP=$(hostname -i)
#echo "$CASSANDRA_NEW_IP" > "$CASSANDRA_UTILITY/old_ip"
#cat $CASSANDRA_UTILITY/old_ip

# we are doing StatefulSet or just setting our seeds
if [ -z "$CASSANDRA_SEEDS" ]; then
  HOSTNAME=$(hostname -I)
  CASSANDRA_SEEDS=$(hostname -I)
fi

# The following vars relate to there counter parts in $CASSANDRA_CFG
# for instance rpc_address
CASSANDRA_RPC_ADDRESS="${CASSANDRA_RPC_ADDRESS:-0.0.0.0}"
CASSANDRA_NUM_TOKENS="${CASSANDRA_NUM_TOKENS:-256}"
CASSANDRA_CLUSTER_NAME="${CASSANDRA_CLUSTER_NAME:='Test Cluster'}"
CASSANDRA_LISTEN_ADDRESS=${POD_IP:-$HOSTNAME}
CASSANDRA_BROADCAST_ADDRESS=${POD_IP:-$HOSTNAME}
CASSANDRA_BROADCAST_RPC_ADDRESS=${POD_IP:-$HOSTNAME}
#CASSANDRA_SEEDS="${CASSANDRA_SEEDS:false}"
#CASSANDRA_SEED_PROVIDER="${CASSANDRA_SEED_PROVIDER:-org.apache.cassandra.locator.SimpleSeedProvider}"


# Turn off JMX auth
CASSANDRA_OPEN_JMX="${CASSANDRA_OPEN_JMX:-false}"
# send GC to STDOUT
CASSANDRA_GC_STDOUT="${CASSANDRA_GC_STDOUT:-false}"


echo Starting Cassandra on ${CASSANDRA_LISTEN_ADDRESS}
#echo CASSANDRA_CONF_DIR ${CASSANDRA_CONF_DIR}
#echo CASSANDRA_CFG ${CASSANDRA_CFG}
#echo CASSANDRA_BROADCAST_ADDRESS ${CASSANDRA_BROADCAST_ADDRESS}
echo CASSANDRA_BROADCAST_RPC_ADDRESS ${CASSANDRA_BROADCAST_RPC_ADDRESS}
echo CASSANDRA_CLUSTER_NAME ${CASSANDRA_CLUSTER_NAME}
#echo CASSANDRA_LISTEN_ADDRESS ${CASSANDRA_LISTEN_ADDRESS}
echo CASSANDRA_NUM_TOKENS ${CASSANDRA_NUM_TOKENS}
#echo CASSANDRA_RPC_ADDRESS ${CASSANDRA_RPC_ADDRESS}
#echo CASSANDRA_SEEDS ${CASSANDRA_SEEDS}
#echo CASSANDRA_SEED_PROVIDER ${CASSANDRA_SEED_PROVIDER}


#echo "JVM_OPTS=\"\$JVM_OPTS -Djava.rmi.server.hostname=$POD_IP\"" >> ${CASSANDRA_CONG_DIR}/cassandra-env.sh

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
                sed -ri 's/^(# )?('"$yaml"':).*/\2 '"$val"'/' "$CASSANDRA_CFG"
        fi
done

### Todo : will be useful if we are not going with kubernetesSeedProvider. Leaving it here for later use

# echo "auto_bootstrap: ${CASSANDRA_AUTO_BOOTSTRAP}" >> $CASSANDRA_CFG
# set the seed to itself.  This is only for the first pod, otherwise
# it will be able to get seeds from the seed provider
#if [[ $CASSANDRA_SEEDS == 'false' ]]; then
#  sed -ri 's/- seeds:.*/- seeds: "'"$POD_IP"'"/' $CASSANDRA_CFG
#else # if we have seeds set them.  Probably StatefulSet
#  sed -ri 's/- seeds:.*/- seeds: "'"$CASSANDRA_SEEDS"'"/' $CASSANDRA_CFG
#fi


#
echo "JVM_OPTS=\"\$JVM_OPTS -Djava.rmi.server.hostname=$POD_IP\"" >> $CASSANDRA_CONF_DIR/cassandra-env.sh


###
# Currently, we are good to go without replacing the dead node ip with current node ip. 
# Using KubernetesseedProvider, cluster is getting updated automatically without replacing the dead ip with current node ip. 
# I may need to investigate more about this behaviour more. May be, during the next version of base image.

#if [ -n "$CASSANDRA_REPLACE_NODE" ]
#then
#  $CASSANDRA_HOME/bin/cassandra -Dcassandra.replace_address=${CASSANDRA_REPLACE_NODE} -f
#else
$CASSANDRA_HOME/bin/cassandra -f
#fi


