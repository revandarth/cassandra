#!/bin/bash

STATUS="/usr/local/bin/status"

HOSTNAME=$(hostname)                                                                                                                                                                  
IS_HOSTNAME=$(curl http://localhost:8500/v1/catalog/service/kong-db | jq -r ".[] | select(.Node | contains(env.HOSTNAME))? | .Node")  
CONSUL_API_EXIT=$?                                                                                                                                                                    

if [[ $(cat /usr/local/bin/status) == "UN" ]]; then                                                                                               
		if [ $CONSUL_API_EXIT -eq 0 ]; then                                                                                                                                                   
   			if [[ $IS_HOSTNAME -ne $HOSTNAME ]]; then exit 1; fi                                                                                                                           
		fi 
		echo "Node is UP"                                                                                              
        exit 0                                                                                                                                                                                                                                                                                                                                                                                                      
else                                                                                                                                                                                                      
        echo "Node is down"                                                                                                                                                                             
        exit 1                                                                                                                                                                                            
fi