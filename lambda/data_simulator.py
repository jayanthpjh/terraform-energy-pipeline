import boto3, json, random
from datetime import datetime
import uuid
import os

s3 = boto3.client('s3')
BUCKET_NAME = os.environ['BUCKET_NAME']

def lambda_handler(event, context):
    site_ids = ["site_nyc", "site_chi", "site_sfo"]
    data = [{
        "site_id": random.choice(site_ids),
        "timestamp": datetime.utcnow().isoformat(),
        "energy_generated_kwh": round(random.uniform(-5, 100), 2),
        "energy_consumed_kwh": round(random.uniform(-5, 100), 2)
    } for _ in range(10)]

    file_key = f"data/{uuid.uuid4()}.json"
    s3.put_object(Bucket=BUCKET_NAME, Key=file_key, Body=json.dumps(data))
    return {"status": "uploaded", "file": file_key}