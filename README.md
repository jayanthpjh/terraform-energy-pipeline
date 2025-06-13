# Terraform Energy Pipeline

This repository contains Terraform configurations that provision an AWS-based pipeline for processing energy metrics. The infrastructure components include an S3 bucket for data ingestion, a DynamoDB table for storage, and two Lambda functions. A scheduled rule invokes the data simulator every five minutes, while S3 events trigger the data processor. If anomalies are detected during processing, they are published to an SNS topic.

## Components

- **S3 Bucket** – Stores raw energy data uploaded by the simulator.
- **DynamoDB Table** – Persists processed records including calculated fields and anomaly flags.
- **Data Simulator Lambda** – Generates sample energy readings and writes them to the S3 bucket.
- **Data Processor Lambda** – Reads uploaded data, computes net energy, flags anomalies, and records the results in DynamoDB.
- **EventBridge Rule** – Runs the simulator Lambda on a five‑minute schedule.
- **S3 Notification** – Invokes the processor when new objects appear in the bucket.
- **SNS Topic** – Receives messages whenever the processor detects anomalous data.

## Usage

1. Install Terraform and configure AWS credentials.
2. Initialize the working directory:
   ```bash
   terraform init
   ```
3. Review the planned infrastructure changes:
   ```bash
   terraform plan
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```

Outputs will display names and ARNs for the created resources.

## License

This project is released under the MIT License.
