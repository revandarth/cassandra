#!/bin/bash

### Define required variables
BACKUP_DIR="/backup-3"
CASSANDRA_DIR="/cassandra_data/data"
KEYSPACE_NAME="demo"



####  I am leaving this for improvment. Current script will do the restore without restarting the cassandra
# pid="`ps -ef | grep [C]assandraDaemon | awk '{print $2}'`"
# if [ ! -z "$pid" ] ; then
#     CASSANDRA_PID="$pid"
#     echo "Cassandra seems to be running with pid $CASSANDRA_PID (this is my best guess)"
#     if [ -z "$CASSANDRA_PID" ] ; then
#         echo "Couldn't reliably determine Cassandra pidfile. Is it running?"
#         exit 1
#     fi
#     else
#     echo "Cassandra is not running"
# fi


### 1. Shut down the node using pid

# until ! kill $CASSANDRA_PID 2> /dev/null ; do
#     echo "Shutting down cassandra..."
#     sleep 3
# done;

# ### clear commitlog 

# if [ -d "$CASSANDRA_COMMITLOG" ] ; then
#     echo "Clearing all files in commitlog: $CASSANDRA_COMMITLOG"
#     rm -f $CASSANDRA_COMMITLOG/*
# fi

# ### clear caches

# if [ -d "$CASSANDRA_SAVED_CACHES" ] ; then
#     echo "Clearing all files in cache: $CASSANDRA_CACHES"
#     rm -f $CASSANDRA_SAVED_CACHES/*
# fi

### Clear db files from cassandra directory 

for i in `find $CASSANDRA_DATA/$KEYSPACE_NAME -iname "*.db" -and -not -path "*snapshots*" -and -not -path "*backups*"` ; do
    rm -f $i
done

### Restore latest snapshot


if [ -d "$BACKUP_DIR" ]
then
        echo "Moving db files from snapshot to data directory"

        LATEST_BACKUP="`ls -1 $BACKUP_DIR | tail -n 1`"
        echo $LATEST_BACKUP
        find $BACKUP_DIR/$LATEST_BACKUP/SNAPSHOTS/$KEYSPACE_NAME -type d -name ss
napshots >keyspace_list
        for SNP_VAR in $(cat keyspace_list)
        do
                LATEST_SNAP="`ls $SNP_VAR | tail -n 1`"
                TABLE_NAME="`echo $SNP_VAR | awk -F/ '{print $(NF -1)}'`"
                echo $TABLE_NAME
                cp $SNP_VAR/$LATEST_SNAP/* $CASSANDRA_DATA/$KEYSPACE_NAME/$TABLEE
_NAME
        done
        echo "Successfully moved files to cassandra directory"
else
        echo "directory doesn't exist"
fi

