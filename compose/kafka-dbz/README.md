# Kafka - Debezium setup

Components:
- Kafka standalone broker - v3.9
- Debezium Connect (Kafka Connect) - v3.0.4
- Confluent Schema Registry - v7.8.0
- Kafka Console (Conduktor)

CDC sources:
- MySQL 8
- PostgreSQL 17 (master)
  - *CDC from PostgreSQL standby instance is not fully supported (Debezium 3.0.4/PostgreSQL 17)