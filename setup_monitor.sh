#!/bin/bash

# Create directory for monitors
mkdir -p ./monitors && cd ./monitors

# Write the docker-compose.yaml content
cat <<EOF >docker-compose.yaml
version: '3.7'

services:
  node_exporter:
    image: prom/node-exporter:latest
    volumes:
      - "/proc:/host/proc:ro"
      - "/sys:/host/sys:ro"
      - "/:/rootfs:ro"
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points'
      - '^/(sys|proc|dev|host|etc)($|/)'
    ports:
      - "9900:9100"
    restart: unless-stopped

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    volumes:
      - "/:/rootfs:ro"
      - "/var/run:/var/run:rw"
      - "/sys:/sys:ro"
      - "/var/lib/docker/:/var/lib/docker:ro"
      - "/dev/disk/:/dev/disk:ro"
    ports:
      - "9901:8080"
    restart: unless-stopped

volumes:
  node_exporter_data: {}
  cadvisor_data: {}

EOF

# Run docker compose
docker compose up -d
