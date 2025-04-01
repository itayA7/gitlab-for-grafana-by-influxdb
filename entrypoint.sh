#!/bin/bash

# Only run setup if the database hasn't been initialized
if [ ! -f /var/lib/influxdb2/influxd.bolt ]; then
  echo "Running InfluxDB setup..."
  influxd &
  sleep 5

  influx setup --username "$DOCKER_INFLUXDB_INIT_USERNAME" \
               --password "$DOCKER_INFLUXDB_INIT_PASSWORD" \
               --org "$DOCKER_INFLUXDB_INIT_ORG" \
               --bucket "$DOCKER_INFLUXDB_INIT_BUCKET" \
               --token "$DOCKER_INFLUXDB_INIT_ADMIN_TOKEN" \
               --force
else
  echo "InfluxDB already set up"
  influxd &
fi

# Wait for it to be ready
sleep 15

# Start your script
python3  -u /app/script.py

