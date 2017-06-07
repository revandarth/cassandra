#!/bin/bash

STATUS="/usr/local/bin/status"

if [[ $(/opt/cassandra/apache-cassandra-2.2.9/bin/nodetool status | grep $(hostname -i)) == *"UN"* ]]; then
		echo "UN" > $STATUS                                                                                               
        exit 0                                                                                                                                                                                                                                                                                                                                                                                                      
else                                                                                                                                                                                                      
        echo "DN"  > $STATUS                                                                                                                                                                              
        exit 1                                                                                                                                                                                            
fi