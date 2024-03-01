CREATE TABLE IF NOT EXISTS actor (
    PRIMARY KEY(actor_id)
) WITH (
    connector = 'kafka',
    kafka.topic = 'debezium.mysql.sakila.sakila.actor',
    kafka.brokers = 'kafka:9092',
    kafka.scan.startup.mode = 'earliest'
) FORMAT DEBEZIUM ENCODE AVRO (
    schema.registry = 'http://schema-registry:8081'
);

CREATE TABLE IF NOT EXISTS film_actor (
    PRIMARY KEY(actor_id, film_id)
) WITH (
    connector = 'kafka',
    kafka.topic = 'debezium.mysql.sakila.sakila.film_actor',
    kafka.brokers = 'kafka:9092',
    kafka.scan.startup.mode = 'earliest'
) FORMAT DEBEZIUM ENCODE AVRO (
    schema.registry = 'http://schema-registry:8081'
);

CREATE TABLE IF NOT EXISTS film (
    PRIMARY KEY(film_id)
) WITH (
    connector = 'kafka',
    kafka.topic = 'debezium.mysql.sakila.sakila.film',
    kafka.brokers = 'kafka:9092',
    kafka.scan.startup.mode = 'earliest'
) FORMAT DEBEZIUM ENCODE AVRO (
    schema.registry = 'http://schema-registry:8081'
);
