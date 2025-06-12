import boto3, json, os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    s3 = boto3.client("s3")
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        obj = s3.get_object(Bucket=bucket, Key=key)
        data = json.loads(obj['Body'].read())

        for item in data:
            anomaly = item['energy_generated_kwh'] < 0 or item['energy_consumed_kwh'] < 0
            item['net_energy_kwh'] = item['energy_generated_kwh'] - item['energy_consumed_kwh']
            item['anomaly'] = anomaly
            table.put_item(Item=item)