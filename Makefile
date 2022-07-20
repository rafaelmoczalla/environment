buildImage:
	docker build --tag node .

startCluster: buildImage
	docker-compose up ; docker-compose rm -f

startDebugConsumer1:
	docker exec -it source-1 /kafka/bin/kafka-topics.sh --if-not-exists --create --topic stream --bootstrap-server localhost:9092
	docker exec -it source-1 /kafka/bin/kafka-console-consumer.sh --topic stream-1 --from-beginning --bootstrap-server localhost:9092

startDebugConsumer2:
	docker exec -it source-2 /kafka/bin/kafka-topics.sh --if-not-exists --create --topic stream --bootstrap-server localhost:9092
	docker exec -it source-2 /kafka/bin/kafka-console-consumer.sh --topic stream --from-beginning --bootstrap-server localhost:9092

startDebugConsumer3:
	docker exec -it source-3 /kafka/bin/kafka-topics.sh --if-not-exists --create --topic stream --bootstrap-server localhost:9092
	docker exec -it source-3 /kafka/bin/kafka-console-consumer.sh --topic stream --from-beginning --bootstrap-server localhost:9092

startDebugProducer1:
	docker exec -it source-1 /kafka/bin/kafka-topics.sh --if-not-exists --create --topic stream --bootstrap-server localhost:9092
	docker exec -it source-1 /kafka/bin/kafka-console-producer.sh --topic stream --bootstrap-server localhost:9092

startDebugProducer2:
	docker exec -it source-2 /kafka/bin/kafka-topics.sh --if-not-exists --create --topic stream --bootstrap-server localhost:9092
	docker exec -it source-2 /kafka/bin/kafka-console-producer.sh --topic stream --bootstrap-server localhost:9092

startDebugProducer3:
	docker exec -it source-3 /kafka/bin/kafka-topics.sh --if-not-exists --create --topic stream --bootstrap-server localhost:9092
	docker exec -it source-3 /kafka/bin/kafka-console-producer.sh --topic stream --bootstrap-server localhost:9092

rmImage:
	docker rmi node

