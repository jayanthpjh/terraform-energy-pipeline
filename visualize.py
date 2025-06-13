import boto3
import os
from boto3.dynamodb.conditions import Key
import matplotlib.pyplot as plt

TABLE_NAME = os.environ.get("TABLE_NAME")
if not TABLE_NAME:
    raise RuntimeError("TABLE_NAME environment variable not set")

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

def plot_site(site_id: str, start: str, end: str):
    resp = table.query(
        KeyConditionExpression=Key("site_id").eq(site_id) & Key("timestamp").between(start, end)
    )
    items = resp.get("Items", [])
    if not items:
        print("No records found")
        return
    items.sort(key=lambda x: x["timestamp"])
    times = [item["timestamp"] for item in items]
    net = [float(item.get("net_energy_kwh", 0)) for item in items]
    plt.plot(times, net, marker="o")
    plt.xlabel("timestamp")
    plt.ylabel("net_energy_kwh")
    plt.title(f"Net Energy for {site_id}")
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Visualize energy data")
    parser.add_argument("site_id")
    parser.add_argument("start")
    parser.add_argument("end")
    args = parser.parse_args()
    plot_site(args.site_id, args.start, args.end)