#!/bin/bash

##
script_name=`basename $0`
echo "$script_name started running"

#Define required directories
BACKUP_DIR=/backup-3
DATA_DIR=/cassandra_data/data

#Define required tools
CQLSH=$CASSANDRA_HOME/bin/cqlsh
NODETOOL=$CASSANDRA_HOME/bin/nodetool


### Get today's date and time. Name snapshot schema directory, snapshot directorr
y and snapshot name according to 'em'.
# It will enable us to access/identify backups without any confusion.

TODAY_DATE=$(date +%F)
BACKUP_SNAPSHOT_DIR="$BACKUP_DIR/$TODAY_DATE/SNAPSHOTS"
BACKUP_SCHEMA_DIR="$BACKUP_DIR/$TODAY_DATE/SCHEMA"
SNAPSHOT_DIR=$(find $DATA_DIR -type d -name snapshots)
SNAPSHOT_NAME=snp-$(date +%F-%H%M-%S)
DATE_SCHEMA=$(date +%F-%H%M-%S)

# Error handling
function fail {
  echo $1 >&2
  exit 1
}
# Retry until n times before exiting.
function retry {
  local n=1
  local try=$1
  local delay=15
  while true; do
    "${@: 2}" && break || {
      if [[ $n -lt $try ]]; then
        ((n++))
        echo "Command failed. Attempt $n/$max:"
        sleep $delay;
      else
        fail "The command has failed after $n attempts."
      fi
    }
  done
}

################ Create backup Directories if they don't exist ##################
########

if [ -d  "$BACKUP_SCHEMA_DIR" ]
then
        echo "$BACKUP_SCHEMA_DIR already exist"
else
        mkdir -p "$BACKUP_SCHEMA_DIR"
        echo "$BACKUP_SCHEMA_DIR is created"
fi

if [ -d  "$BACKUP_SNAPSHOT_DIR" ]
then
        echo "$BACKUP_SNAPSHOT_DIR already exist"
else
        mkdir -p "$BACKUP_SNAPSHOT_DIR"
        echo "$BACKUP_SNAPSHOT_DIR is created"
fi
## Get all keyspaces using cqlsh with host ip and port name. Re-try for 3 times,,
 exit otherwise

echo "Quering to get existing keyspaces"
retry 3 $CQLSH $(hostname -i) 9042 -e "DESC KEYSPACES" > Keyspace_names.cql

## Create directory inside backup SCHEMA directory for every keyspace.

echo "Started to create directories inside backup SCHEMA directory for every keyspace"
for i in $(cat Keyspace_names.cql);
do
if [ -d $BACKUP_SCHEMA_DIR/$i ]
then
        echo "$i directory exist"
else
        mkdir -p $BACKUP_SCHEMA_DIR/$i
        echo "$i: $BACKUP_SCHEMA_DIR/$i is created"
fi
done

## SCHEMA Backup with All Keyspace and All tables
echo "Started Schema backup with all keyspaces and tables"
for i in $(cat Keyspace_names.cql);
do
# Connect to cqlsh using host ip and port, re-try for 3 times, exit otherwise

        retry 3 $CQLSH $(hostname -i) 9042 -e "DESC KEYSPACE  $i" > "$BACKUP_SCHEMA_DIR/$i/$i"_schema-"$DATE_SCHEMA".cql;
done

### Create snapshots using nodetool, re-try for 2 times, exit otherwise

echo "Taking snapshot of cassandra latest"

retry 2 $NODETOOL snapshot -t $SNAPSHOT_NAME

echo "Snapshot is ready, created for all the keyspaces"

## Get Snapshot directory path

echo "Gonna get snapshot directory  path"

_SNAPSHOT_DIR_LIST=`find $DATA_DIR -type d -name snapshots|awk '{gsub("'$DATA_DIR'", "");print}' > snapshot_dir_list`

echo "Creating keyspace directories inside backup snapshot directory"
for i in `cat snapshot_dir_list`
do
echo "dude you are here"
if [ -d $BACKUP_SNAPSHOT_DIR/$i ]
then
echo "$i directory exist"
else
mkdir -p $BACKUP_SNAPSHOT_DIR/$i
echo $i Directory is created
fi
done

echo "Done with creating directories inside backup snapshot directory for all the keyspaces"


echo "Started copying default Snapshot dir to backup dir"

find $DATA_DIR -type d -name $SNAPSHOT_NAME > snp_dir_list


for SNP_VAR in $(cat snp_dir_list);
do
echo "Trim the absolute path and get snapshot relative path from data directory"

SNAPSHOT_RELATIVE_PATH=`echo $SNP_VAR|awk '{gsub("'$DATA_DIR'", "");print}'`

cp -prvf "$SNP_VAR" "$BACKUP_SNAPSHOT_DIR$SNAPSHOT_RELATIVE_PATH";

done

