import os
import requests
import time
from dotenv import load_dotenv
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS

load_dotenv()  # Load .env vars

# GitLab Config
GITLAB_TOKEN = os.getenv('GITLAB_TOKEN')
PROJECT_ID = os.getenv('PROJECT_ID')
GITLAB_IP = os.getenv('GITLAB_IP')

# InfluxDB Config
token = os.getenv("INFLUXDB_TOKEN")
org = os.getenv("ORG")
bucket = os.getenv("BUCKET")
db_url =  "http://localhost:8086"



write_client = InfluxDBClient(url=db_url, token=token, org=org)
write_api = write_client.write_api(write_options=SYNCHRONOUS)


# GitLab API call
GITLAB_API_URL = f"http://{GITLAB_IP}/api/v4/projects/{PROJECT_ID}/repository/commits"
HEADERS = {"PRIVATE-TOKEN": GITLAB_TOKEN}


while True:
    print("Fetching commits from GitLab...")
    try:
        resp = requests.get(GITLAB_API_URL, headers=HEADERS)
        resp.raise_for_status()
        commits = resp.json()

        for commit in commits:
            title = commit['title']
            timestamp = commit['created_at']
            commit_url = commit['web_url']
            commit_id = commit['id']

            point = (
                Point("commits")
                .tag("commit_id", commit_id)
                .time(timestamp)
                .field("title", title)
                .field("commit_url", commit_url)
            )

            write_api.write(bucket=bucket, org=org, record=point)

        print(f" Wrote {len(commits)} commits to InfluxDB")

    except Exception as e:
        print(f"Error: {e}")

    print("Sleeping for 5 minutes...\n")
    time.sleep(300)

