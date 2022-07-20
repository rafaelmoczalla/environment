# Experimental Environment for Distributed Batch/Stream Processing Approaches
These project contains an environment for local experminets of distributed batch & stream processing approaches. Currently, that includes Apache Kafka as a message broker/source & Apache Spark as a map reduce engine for batch & stream processing use-cases.

Author: [Rafael Moczalla](Rafael.Moczalla@hpi.de)

Create Date: 17 July 2022

Last Update: 17 July 2022

Tested on Ubuntu 22.04 LTS.

## Prerequisites
1. Install git, a java JDK and Docker.
    ```bash
    sudo apt install gradle default-jdk-headless docker-ce
    ```

2. Install Docker Compose.
    ```bash
    sudo curl -SL https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    ```

3. Download the project and change directory to the project folder.
    ```bash
    git clone https://github.com/rafaelmoczalla/TBD.git
    cd TBD
    ```

## Usage
Docker Compose is the fundamental base for the local cluster setup. In these section we explain how to start & modify the cluster.

### Build the Node Image & the Start Local Cluster with Docker Compose
You need to build the node image initially & each time when you change a configuration in the subfolders of the project.
```bash
docker build --tag node .
```

We use the Docker Compose to start the local cluster. Open a new terminal in the project folder and start the cluster with Docker Compose as follows.
```bash
docker-compose up ; docker-compose rm -f
```
Each time when the cluster is shut done you need to stop all containers with 'docker-compose rm'.

Sometimes it is helpful to first test the settings with a running single node. You can start & login to a node like following.
```bash
docker run -it --rm --name node-main --hostname node-main node:latest /bin/bash
```

### Modifying Cluster Settings
When you want to add an additional broker/source to the cluster you need to modify the files `docker-compose.yml`, `kafka.sh`, `zookeeper.cfg.dynamic` in the `./kafka` folder. Also make sure that each file has two blank lines at the end of a file because of a Docker `COPY` issue.

In the `docker-compose.yml` file you need to remove/add a `source-X` node, increment the ports, add the source nodes to each cluster node in the `depends_on` section & modify the `container_name`, `hostname` & `MISSION` environment variable. In the `kafka.sh` file you need to remove/add a `,source-X:31202` term in the `--override zookeeper.connect=source-1:31202,source-2:31202,source-3:31202/kafka \` line. Finally, in the `zookeeper.cfg.dynamic` file you need to add/remove a `server.X=source-X:31200:31201:participant;31202` line where `X` is a number. For example if you want to add two new brokers/sources the sources in the `docker-compose.yml` file will look like the following.
```yaml
  source-1:
    image: node:latest
    container_name: source-1
    hostname: source-1
    ports:
      - 31200:31200
      - 31201:31201
      - 31202:31202
      - 9092:9092
    command: "/bin/bash -c /kafka.sh"
    environment:
      - "MISSION=source-1"
  source-2:
    image: node:latest
    container_name: source-2
    hostname: source-2
    ports:
      - 31210:31200
      - 31211:31201
      - 31212:31202
      - 9093:9092
    command: "/bin/bash -c /kafka.sh"
    environment:
      - "MISSION=source-2"
  source-3:
    image: node:latest
    container_name: source-3
    hostname: source-3
    ports:
      - 31220:31200
      - 31221:31201
      - 31222:31202
      - 9094:9092
    command: "/bin/bash -c /kafka.sh"
    environment:
      - "MISSION=source-3"
  source-4:
    image: node:latest
    container_name: source-4
    hostname: source-4
    ports:
      - 31230:31200
      - 31231:31201
      - 31232:31202
      - 9095:9092
    command: "/bin/bash -c /kafka.sh"
    environment:
      - "MISSION=source-4"
  source-5:
    image: node:latest
    container_name: source-5
    hostname: source-5
    ports:
      - 31240:31200
      - 31241:31201
      - 31242:31202
      - 9096:9092
    command: "/bin/bash -c /kafka.sh"
    environment:
      - "MISSION=source-5"
```
& the `depends_on` section will look like the following.
```yaml
    depends_on:
      - source-1
      - source-2
      - source-3
      - source-4
      - source-5
```
The override in the `kafka.sh` file will look like the following.
```bash
--override zookeeper.connect=source-1:31202,source-2:31202,source-3:31202,source-4:31202,source-5:31202/kafka \
```
And the `zookeeper.cfg.dynamic` will look like the following.
```
server.1=source-1:31200:31201:participant;31202
server.2=source-2:31200:31201:participant;31202
server.3=source-3:31200:31201:participant;31202
server.4=source-3:31200:31201:participant;31202
server.5=source-3:31200:31201:participant;31202
```

When you want to add an additional spark worker just add in the `docker-compose.yml` file a worker node & modify the `container_name`, `hostname` & `MISSION` environment variable. For example if you want to add two workers the modified cluster nodes in the `docker-compose.yml` file look like the following.
```yaml
  node-main:
    image: node:latest
    container_name: node-main
    hostname: node-main
    depends_on:
      - source-1
      - source-2
      - source-3
    ports:
      - 8080:8080
      - 7077:7077
    command: "/bin/bash -c /spark-main.sh"
    environment:
      - "MISSION=node-main"
      - "INIT_DAEMON_STEP=setup_spark"
      - "SPARK_MASTER_PORT=7077"
      - "SPARK_MASTER_WEBUI_PORT=8080"
      - "SPARK_MASTER_LOG=/spark/logs"
  node-worker-1:
    image: node:latest
    container_name: node-worker-1
    hostname: node-worker-1
    depends_on:
      - node-main
      - source-1
      - source-2
      - source-3
    ports:
      - 8081:8081
    command: "/bin/bash -c /spark-worker.sh"
    environment:
      - "MISSION=node-worker-1"
      - "SPARK_WORKER_WEBUI_PORT=8081"
      - "SPARK_WORKER_LOG=/spark/logs"
      - "SPARK_MASTER=spark://node-main:7077"
  node-worker-2:
    image: node:latest
    container_name: node-worker-2
    hostname: node-worker-2
    depends_on:
      - node-main
      - source-1
      - source-2
      - source-3
    ports:
      - 8082:8081
    command: "/bin/bash -c /spark-worker.sh"
    environment:
      - "MISSION=node-worker-2"
      - "SPARK_WORKER_WEBUI_PORT=8081"
      - "SPARK_WORKER_LOG=/spark/logs"
      - "SPARK_MASTER=spark://node-main:7077"
  node-worker-3:
    image: node:latest
    container_name: node-worker-3
    hostname: node-worker-3
    depends_on:
      - node-main
      - source-1
      - source-2
      - source-3
    ports:
      - 8082:8081
    command: "/bin/bash -c /spark-worker.sh"
    environment:
      - "MISSION=node-worker-3"
      - "SPARK_WORKER_WEBUI_PORT=8081"
      - "SPARK_WORKER_LOG=/spark/logs"
      - "SPARK_MASTER=spark://node-main:7077"
  node-worker-4:
    image: node:latest
    container_name: node-worker-4
    hostname: node-worker-4
    depends_on:
      - node-main
      - source-1
      - source-2
      - source-3
    ports:
      - 8082:8081
    command: "/bin/bash -c /spark-worker.sh"
    environment:
      - "MISSION=node-worker-4"
      - "SPARK_WORKER_WEBUI_PORT=8081"
      - "SPARK_WORKER_LOG=/spark/logs"
      - "SPARK_MASTER=spark://node-main:7077"
```

### Submit Job TBD
After you created the local Hadoop Docker cluster and build the initial project or recompiled code use the Makefile to submit the broadcast join with
```bash
make submitBroadcastJoinJob
```
and to submit the repartition join use
```bash
make submitRepartitionJoinJob
```