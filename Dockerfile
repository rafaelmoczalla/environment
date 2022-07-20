FROM alpine:3.10

LABEL maintainer="Rafael Moczalla <Rafael.Moczalla@hpi.de>"

ENV ENABLE_INIT_DAEMON false
ENV INIT_DAEMON_BASE_URI http://identifier/init-daemon
ENV INIT_DAEMON_STEP spark_master_init

ENV SPARK_BASE_URL=https://archive.apache.org/dist/spark
ENV SPARK_VERSION=3.3.0
ENV HADOOP_VERSION=3

ENV KAFKA_BASE_URL=https://archive.apache.org/dist/kafka
ENV KAFKA_VERSION=3.2.0
ENV SCALA_VERSION=2.12

# Install dependencies
RUN apk add --no-cache curl bash openjdk8-jre python3 py-pip nss libc6-compat coreutils procps \
      && ln -s /lib64/ld-linux-x86-64.so.2 /lib/ld-linux-x86-64.so.2

# Fix the value of PYTHONHASHSEED
# Note: this is needed when you use Python 3.3 or greater
ENV PYTHONHASHSEED 1

# Spark Setup \
RUN wget ${SPARK_BASE_URL}/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
 && tar -xvzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
 && mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark \
 && rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
 && cd /

# Kafka Setup
RUN wget ${KAFKA_BASE_URL}/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
 && tar -xvzf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
 && mv kafka_${SCALA_VERSION}-${KAFKA_VERSION} kafka \
 && rm kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
 && cd /

COPY common/wait-for-step.sh /
COPY common/execute-step.sh /
COPY common/finish-step.sh /

COPY spark/spark-main.sh /
COPY spark/spark-worker.sh /

COPY kafka/zookeeper.properties /kafka/config/
COPY kafka/zookeeper.cfg.dynamic /kafka/config/
COPY kafka/zk-config.sh /kafka/bin/
COPY kafka/kafka.sh /
RUN chmod +x /kafka/bin/zk-config.sh
RUN echo ok

RUN chmod +x *.sh
