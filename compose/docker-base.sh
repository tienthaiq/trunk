#!/bin/bash

docker network create \
  --subnet "10.0.1.0/24" \
  trunk-network
