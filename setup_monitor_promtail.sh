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

  promtail:
    image: grafana/promtail:latest
    volumes:
      - /var/log:/var/log
      - /var/lib/docker/containers:/var/lib/docker/containers
      - /var/run/docker.sock:/var/run/docker.sock
      - ./promtail-config.yaml:/etc/promtail/promtail-config.yaml
    command: -config.file=/etc/promtail/promtail-config.yaml
    ports:
      - "9080:9080"
    restart: unless-stopped

volumes:
  node_exporter_data: {}
  cadvisor_data: {}

EOF

# Write the promtail-config.yaml content
cat <<EOF >promtail-config.yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://10.10.20.101:3100/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*log

  - job_name: docker
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
    relabel_configs:
      - source_labels: [__meta_docker_container_name]
        target_label: container
      - source_labels: [__meta_docker_container_image]
        target_label: image
      - source_labels: [__meta_docker_container_id]
        target_label: container_id
      - source_labels: [__meta_docker_container_label_com_docker_compose_service]
        target_label: compose_service

EOF

# Run docker compose
docker compose up -d
