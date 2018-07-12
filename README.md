# Deploying Cassandra with PetSets on Openshift/Kubernetes


This article shows you how to develop a cloud native Cassandra deployment on Openshift. In this instance, a custom Cassandra SeedProvider enables Cassandra to discover new Cassandra nodes as they join the cluster.

Deploying stateful distributed applications, like Cassandra, within a clustered environment can be challenging. PetSets greatly simplify this process. Please read about PetSets for more information about the features used in this article.

Cassandra Docker

The pods use the registry.revan.com/identity/cassandra image from registry.revan.com. The docker is based on centos7-java and includes OpenJDK 8. This image includes a standard Cassandra installation using source code – For this simply untar the source ball and start using it . By using environment variables you can change values that are inserted into cassandra.yaml.

## Objectives
#### Before you begin
Additional Minikube Setup Instructions
Creating a Cassandra Headless Service
Validating (optional)
Using a Petset/StatefulSet to Create a Cassandra Ring
Validating The Cassandra PetSet
Modifying the Cassandra PetSet
Cleaning up

#### Objectives
Deploy and Verify Cassandra cluster.

Download cae.yaml file
Installation Steps

1. Create PVC with names data-kong-database-0, data-kong-database-1, data-kong-database-2 for 3 replicas of cassandra nodes.

Gotcha: You need to pre-provision the persistent volumes. And create persistent claim that uses provisioned volume. The naming conventions should be volume name, app name/ label and ordinal index. <volume_name>-<app_name/label>-<ordinal_index>.  For instance, data-kong-database-0.
The PetSet/StatefulSet manifest, included below, creates a Cassandra ring that consists of three pods.


2. Create the Cassandra cluster that consists three peer nodes using following template cae.yaml. 
```
$oc apply -f kong-cassandra.yaml -n coi-gateway-dev
service "cassandra" created
petset "kong-database" created
#oc rsh kong-database-0
```

Verify Service and Petset

```
$ oc get service cassandra
NAME CLUSTER-IP EXTERNAL-IP PORT(S) AGE
cassandra 172.30.191.141 <none> 9042/TCP 3d
```

```
$ oc get petsets kong-database
NAME DESIRED CURRENT AGE
kong-database 3 3 1d
```

Verify pods are up, the PetSet deploys pods sequentially.

```
$ oc get pods --watch
NAME READY STATUS RESTARTS AGE
coi-base-r577h 1/1 Running 0 1d
kong-app-379870019-ptnrj 0/1 CrashLoopBackOff 345 1d
service-iam-template-qbcfn 0/1 ImagePullBackOff 0 31d
toolkit-4qvch 1/1 Running 4 31d
NAME READY STATUS RESTARTS AGE
kong-database-0 0/1 Pending 0 0s
kong-database-0 0/1 Pending 0 0s
kong-database-0 0/1 ContainerCreating 0 0s
kong-database-0 0/1 Running 0 10s
kong-database-0 1/1 Running 0 1m
kong-database-1 0/1 Pending 0 0s
kong-database-1 0/1 Pending 0 0s
kong-database-1 0/1 ContainerCreating 0 1s
kong-database-1 0/1 Running 0 5s
kong-database-1 1/1 Running 0 1m
kong-database-2 0/1 Pending 0 0s
kong-database-2 0/1 Pending 0 0s
kong-database-2 0/1 ContainerCreating 0 0s
kong-database-2 0/1 Running 0 35s
kong-database-2 1/1 Running 0 1m
```

```
$ oc get pods | grep kong-database
kong-database-0 1/1 Running 0 1d
kong-database-1 1/1 Running 0 1d
kong-database-2 1/1 Running 0 1d
```

Login to the pod to verify the service is running.

```
sh-4.2# /opt/cassandra/apache-cassandra-2.2.9/bin/nodetool status
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
-- Address Load Tokens Owns (effective) Host ID Rack
UN 10.0.29.195 261.71 KB 256 67.7% 4c605c3a-8348-4be9-a892-8e495acbf8fe rack1
UN 10.0.37.8 287.9 KB 256 68.1% 0b266f84-b368-4922-b083-9a33b22e705a rack1
UN 10.0.24.140 375.03 KB 256 64.3% 722cb842-7846-489a-a7c0-5331729ed2e8 rack1
```

```sh-4.2# /opt/cassandra/apache-cassandra-2.2.9/bin/nodetool status                                                                                                                                     
Datacenter: datacenter1                                                                                                                                                             =======================                                                                               
Status=Up/Down                                                                                  |/ State=Normal/Leaving/Joining/Moving                                                          --  Address      Load       Tokens       Owns (effective)  Host ID                               Rack     
UN  10.0.29.195  261.71 KB  256          37.7%             4c605c3a-8348-4be9-a892-8e495acbf8fe  rack1                                                                                                    
UN  10.0.37.8    287.9 KB   256          38.1%             0b266f84-b368-4922-b083-9a33b22e705a  rack1                                                                                                    
UN  10.0.24.140  375.03 KB  256          34.3%             722cb842-7846-489a-a7c0-5331729ed2e8  rack1

 ```                                                                             
oc describe svc cassandra
$ oc describe svc cassandra
Name: cassandra
Namespace: coi-gateway-poc
Labels: <none>
Selector: app=kong-database
Type: ClusterIP
IP: 172.30.191.141
Port: cql 9042/TCP
Endpoints: 10.0.24.140:9042,10.0.29.195:9042,10.0.37.8:9042
Session Affinity: None
No events.
```

Compare the peer nodes with the endpoints listed above for cassandra service. They should match if you see any dead node, which usually in UD status or UL(If its leaving). you can remove manually using nodetool removenode command. If you don't remove node, kong may complain about the consistency requirements.

nodetool removenode <Host ID>


Update/Modify Cluster ring or Scale down or Scale up the cluster. 

Scale Cassandra cluster to 3 using following patch comman

```revan@REAIRRE-FLV8LMINGW64$ oc patch petset kong-database -p '{"spec":{"replicas":3}}'```

Verify whether all nodes are joined the ring. You can connect to any one of the Cassandra petset to verify. 

Destroy the pods

```revan@REAIRRE-FLV8L MINGW64 ~/git/jenkinsnew

$ for i in 1 2 3; do oc delete po kong-database-$i; done
pod "kong-database-0" deleted
pod "kong-database-1" deleted
pod "kong-database-2" deleted
```