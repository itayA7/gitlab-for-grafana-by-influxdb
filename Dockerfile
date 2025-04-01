FROM influxdb:2

# Install Python and dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip \
    git curl

RUN pip install --break-system-packages requests influxdb-client dotenv


#ENV for the InfluxDB
ENV DOCKER_INFLUXDB_INIT_MODE=setup
ENV DOCKER_INFLUXDB_INIT_USERNAME=admin
ENV DOCKER_INFLUXDB_INIT_PASSWORD=<influxdb admin password> 
ENV DOCKER_INFLUXDB_INIT_ORG=myorg
ENV DOCKER_INFLUXDB_INIT_BUCKET=gitlab
ENV DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=<influxdb admin token>


# Create working dir and copy script + env
WORKDIR /app
COPY script.py .
COPY .env .

EXPOSE 8086

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]



