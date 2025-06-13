import boto3
import json
import os
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])
sns = boto3.client("sns")
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")

def convert_floats(obj):
    if isinstance(obj, list):
        return [convert_floats(i) for i in obj]
    elif isinstance(obj, dict):
        return {k: convert_floats(v) for k, v in obj.items()}
    elif isinstance(obj, float):
        return Decimal(str(obj))
    else:
        return obj

def lambda_handler(event, context):
    s3 = boto3.client("s3")
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        obj = s3.get_object(Bucket=bucket, Key=key)
        data = json.loads(obj['Body'].read())

        for item in data:
            item['net_energy_kwh'] = item['energy_generated_kwh'] - item['energy_consumed_kwh']
            item['anomaly'] = (
                item['energy_generated_kwh'] < 0 or
                item['energy_consumed_kwh'] < 0
            )

            # 💥 CONVERT all float types to Decimal to avoid DynamoDB error
            safe_item = convert_floats(item)

            table.put_item(Item=safe_item)
