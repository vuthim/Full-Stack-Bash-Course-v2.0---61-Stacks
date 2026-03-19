# ☁️ STACK 19: AWS CLI SCRIPTING
## Cloud Automation with AWS

---

## 🔰 AWS CLI Basics

```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure
aws configure
# Enter: Access Key, Secret Key, Region, Output format

# Test
aws s3 ls
aws ec2 describe-instances
```

---

## 🪣 S3 Operations

```bash
# List buckets
aws s3 ls

# List objects
aws s3 ls s3://my-bucket/

# Upload file
aws s3 cp file.txt s3://my-bucket/

# Download file
aws s3 cp s3://my-bucket/file.txt ./

# Sync folders
aws s3 sync ./data/ s3://my-bucket/data/

# Delete
aws s3 rm s3://my-bucket/file.txt
```

---

## 🖥️ EC2 Management

```bash
# List instances
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId, State.Name, Tags[?Key==`Name`].Value | [0], PublicIpAddress]'

# Start instance
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Stop instance
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Create instance
aws ec2 run-instances --image-id ami-0c55b159cbfafe1f0 --instance-type t2.micro --key-name my-key
```

---

## 🔄 Automated Backup to S3

```bash
#!/bin/bash
# backup_to_s3.sh

BUCKET="my-backup-bucket"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup
tar -czf /tmp/backup_$DATE.tar.gz /important/data/

# Upload to S3
aws s3 cp /tmp/backup_$DATE.tar.gz s3://$BUCKET/backups/

# Cleanup local
rm /tmp/backup_$DATE.tar.gz

# Delete old backups (keep last 7)
aws s3 ls s3://$BUCKET/backups/ | head -n -7 | while read line; do
    file=$(echo $line | awk '{print $4}')
    aws s3 rm s3://$BUCKET/backups/$file
done
```

---

## 📡 EC2 Startup Script

```bash
#!/bin/bash
# launch_ec2.sh

IMAGE_ID="ami-0c55b159cbfafe1f0"
INSTANCE_TYPE="t2.micro"
KEY_NAME="my-key"
SECURITY_GROUP="sg-0123456789"

INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SECURITY_GROUP \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Instance ID: $INSTANCE_ID"

# Wait for running
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Get public IP
IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "Public IP: $IP"
```

---

## 🏷️ Tag-Based Management

```bash
#!/bin/bash
# tag_instances.sh

# Tag all untagged instances
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].InstanceId' \
    --output text | while read instance; do
    aws ec2 create-tags \
        --resources $instance \
        --tags "Key=Environment,Value=Production"
done
```

---

## 📊 Cost Monitoring

```bash
#!/bin/bash
# cost_check.sh

# Get current month cost
aws ce get-cost-and-usage \
    --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) \
    --granularity DAILY \
    --metrics UnblendedCost \
    --query 'ResultsByTime[].Total.UnblendedCost.Amount' \
    --output text | awk '{sum+=$1} END {print "Cost: $" sum}'
```

---

## ✅ Stack 19 Complete!