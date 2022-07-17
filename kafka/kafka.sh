#!/bin/bash

/wait-for-step.sh
/execute-step.sh
# Configure & start zookeeper
/kafka/bin/zk-config.sh
MYID=$?
/kafka/bin/zookeeper-server-start.sh /kafka/config/zookeeper.properties &
sleep 10s
# Start kafka
/kafka/bin/kafka-server-start.sh /kafka/config/server.properties \
  --override -Djava.net.preferIPv4Stack=true \
  --override delete.topic.enable=true \
  --override advertised.host.name=$HOSTNAME \
  --override advertised.port=9092 \
  --override zookeeper.connect=source-1:31202,source-2:31202,source-3:31202/kafka \
  --override broker.id=$MYID
cd /
/finish-step.sh

