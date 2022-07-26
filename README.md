# Experimental Environment for Distributed Batch/Stream Processing Approaches
These project contains an environment for local experiments of distributed batch & stream processing approaches. Currently, that includes Apache Kafka as a message broker/source & Apache Spark as a map reduce engine for batch & stream processing use-cases.

Author: [Rafael Moczalla](Rafael.Moczalla@hpi.de)

Create Date: 17 July 2022

Last Update: 26 July 2022

Tested on Ubuntu 22.04 LTS.

## Prerequisites
1. Install git, a java JDK, Docker & Gradle.
    ```bash
    sudo apt install gradle default-jdk-headless docker-ce
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk install gradle 7.5
    ```

2. Install Docker Compose.
    ```bash
    sudo curl -SL https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    ```

3. Download the project & change directory to the project folder.
    ```bash
    git clone https://github.com/rafaelmoczalla/environment.git
    cd environment
    ```

## Usage
We use Gradle for the setup of this project. The `gradle.properties` file contains all nobs for setting up the cluster in the `ext { ... }` section. When you want to add a template file with additional nob variables you need to add the file to the `gradle.build` file & add the nobs to the `gradle.properties` & the `build.gradle` file. Also make sure that each additional template file has two blank lines at the end of a file because of a Docker `COPY` issue.

### Build the Node Image & the Start Local Cluster with Docker Compose
When you first start the project or when some files are missing you need to run the following command in the project directory.
```bash
gradle build
```

When you change the configuration in any of the `gradle.properties` file, or you added a new template file via the `gradle.build` file you need to do a clean rebuild of the project with the following command.
```bash
gradle clean & gradle build
```
Be careful as all files generated from template files are deleted & rebuild.

After a successful build you should have a Makefile that contains a set of options. To start the cluster you need to run the following command in the project directory.
```bash
make startCluster
```

Each time when the cluster is shut done you need to stop all containers with following command before the next cluster start.
```bash
make deleteCluster
```

Sometimes it is helpful to first test the settings with a running single node. You can start & login to a node like shown in the following example.
```bash
make loginMain
```
This command logs you into the main-node with a bash.

We also provide a debug consumer & producer option to play around. First you need to create the stream topics in Kafka.
```bash
make initKafkaTopics
```
After successfully creating the topics start in one terminal a consumer instance
```bash
make startDebugConsumer
```
& in another terminal a producer instance.
```bash
make startDebugProducer
```
Now in the producer instance you can type some words. These words appear in the consumer terminal.

There are also more options. Look in the Makefile to learn them.

### Modifying Cluster Settings
When you want to add a source or stream to the cluster you need to modify the files `docker-compose.yml` & `gradle.properties`. Be careful with the `docker-compose.yml` as this file is deleted on a clean rebuild with `gradle clean`. Another option is to directly modify the `docker-compose.yml.template` file.

In the `gradle.properties` file add additional sources & streams to the `sourceList` & `streamList` respectively. When adding additional source nodes you also need to modify the `docker-compose.yml` file as well.

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

When you want to add a spark worker just add it in the `docker-compose.yml` file as a worker node & modify the `container_name`, `hostname` & `MISSION` environment variable. For example if you want to add two workers the modified cluster nodes in the `docker-compose.yml` file look like the following.
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

## To-Do List
- [ ] Add utilities for measuring network, CPU & memory utilization.
- [ ] Add an example for tree like network topologies.
- [ ] Add utilities restricting network bandwidth.