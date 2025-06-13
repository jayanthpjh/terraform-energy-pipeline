from fastapi import FastAPI, HTTPException
from boto3.dynamodb.conditions import Key
import boto3
import os

TABLE_NAME = os.environ.get("TABLE_NAME")
if not TABLE_NAME:
    raise RuntimeError("TABLE_NAME environment variable not set")

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

app = FastAPI(title="Energy Data API")

@app.get("/records")
async def get_records(site_id: str, start: str, end: str):
    try:
        resp = table.query(
            KeyConditionExpression=Key("site_id").eq(site_id) & Key("timestamp").between(start, end)
        )
        return resp.get("Items", [])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/anomalies")
async def get_anomalies(site_id: str):
    try:
        resp = table.query(
            KeyConditionExpression=Key("site_id").eq(site_id),
            FilterExpression=Key("anomaly").eq(True)
        )
        return resp.get("Items", [])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))