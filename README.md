
# 🐙 GitLab Commit Tracker for Grafana (via InfluxDB)👋

Track Gitlab commits and send them to InfluxDB for visualization in Grafana 📊

The official GitLab plugin requires a Grafana enterprise license 😒 So I created this container instead 😎


## 📦 Features
- Pulls commit data from Gitlab API
- Pushes to InfluxDB 2.x using Python
- Built into one Docker container

## 🛠️ Installation

Before building the image (the second step), change the env variables shown on the **configuration section**. 

```bash
# 1. Clone the repository
git clone https://github.com/itayA7/gitlab-for-grafana-by-influxdb.git
cd gitlab-for-grafana-by-influxdb

#Change ENV Variables

# 2. Build the Docker image 
docker build -t gitlab-for-grafana-by-influxdb .

# 3. Run the container
docker run -d -p 8086:8086 \
  -v ./influxdb/data:/var/lib/influxdb2 \
  -v ./influxdb/config:/etc/influxdb2 \
  gitlab-for-grafana-by-influxdb
```

## ⚙️ Configuration

Edit the `Dockerfile` file with your InfluxDB env:

```env
#ENV for InfluxDB
ENV DOCKER_INFLUXDB_INIT_MODE=setup
ENV DOCKER_INFLUXDB_INIT_USERNAME=admin
ENV DOCKER_INFLUXDB_INIT_PASSWORD=<influxdb admin password>
ENV DOCKER_INFLUXDB_INIT_ORG=myorg
ENV DOCKER_INFLUXDB_INIT_BUCKET=gitlab
ENV DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=<influxdb admin token>
```

Edit the `.env` file with your GitLab + InfluxDB details (InfluxDB info should be the same as  in the `Dockerfile`):

```env
#Gitlab Info
GITLAB_TOKEN = <your gitlab user api token>
PROJECT_ID = <your gitlab project id>
GITLAB_IP=<your gitlab domain  or ip>

#InfluxDB Info
INFLUXDB_TOKEN=<influxdb admin token>
ORG=myorg
BUCKET=gitlab
```

## 📊 View in Grafana

- Connect Grafana to InfluxDB (use the free InfluxDB plugin)
- Use Flux to query commits:

```flux
from(bucket: "gitlab")
  |> range(start: -10d)
  |> filter(fn: (r) => r._measurement == "commits")
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> keep(columns: ["_time","title", "commit_url"])


```
