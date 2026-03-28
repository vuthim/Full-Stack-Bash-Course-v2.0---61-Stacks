# ☁️ STACK 19: AWS CLI SCRIPTING
## Cloud Automation with AWS

---

## 🔰 Why AWS CLI?

AWS CLI enables:
- **Automation** - Script everything
- **Cost savings** - Start/stop instances on schedule
- **Backup automation** - S3 backups
- **Infrastructure as Code** - CLI-driven deployments
- **Monitoring** - Cost and resource tracking

---

## ⚙️ AWS CLI Installation

### Install AWS CLI v2
```bash
# Download and install
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install

# Verify
aws --version

# Update
sudo ./aws/install --update
```

### Configure AWS CLI
```bash
# Interactive configuration
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
export AWS_DEFAULT_REGION="us-west-2"

# Configuration file locations
~/.aws/config      # Region and output
~/.aws/credentials # Access keys

# Named profiles
aws configure --profile production
aws configure --profile development

# Use profile
aws s3 ls --profile production
```

### Multiple Accounts
```bash
# Use role assumption for cross-account access
aws sts assume-role \
    --role-arn arn:aws:iam::123456789012:role/AdminRole \
    --role-session-name admin-session

# Or useOrganizations
aws configure
# Enter credentials for each account, use --profile
```

---

## 🪣 S3 Operations

### Basic S3 Commands
```bash
# List buckets
aws s3 ls

# List objects in bucket
aws s3 ls s3://my-bucket/
aws s3 ls s3://my-bucket/prefix/

# Create bucket
aws s3 mb s3://my-new-bucket

# Remove bucket (must be empty)
aws s3 rb s3://my-bucket
aws s3 rb s3://my-bucket --force  # force delete
```

### File Operations
```bash
# Upload file
aws s3 cp myfile.txt s3://my-bucket/
aws s3 cp myfile.txt s3://my-bucket/prefix/

# Download file
aws s3 cp s3://my-bucket/myfile.txt ./

# Copy between buckets
aws s3 cp s3://bucket1/file.txt s3://bucket2/

# Move file
aws s3 mv old.txt s3://my-bucket/

# Delete file
aws s3 rm s3://my-bucket/myfile.txt
```

### Sync Folders
```bash
# Sync local to S3
aws s3 sync ./folder s3://my-bucket/folder/

# Sync S3 to local
aws s3 sync s3://my-bucket/folder/ ./local-folder/

# Sync with exclusions
aws s3 sync ./data s3://my-bucket/data/ \
    --exclude "*.tmp" \
    --exclude "*.log" \
    --exclude ".git/*"

# Sync with only (include only)
aws s3 sync ./data s3://my-bucket/data/ \
    --include "*.jpg" \
    --include "*.png" \
    --exclude "*"

# Sync with delete (remove files not in source)
aws s3 sync ./data s3://my-bucket/data/ --delete
```

### S3 Permissions
```bash
# Set ACL
aws s3 cp file.txt s3://my-bucket/ --acl private
aws s3 cp file.txt s3://my-bucket/ --acl public-read

# Set storage class
aws s3 cp file.txt s3://my-bucket/ --storage-class STANDARD_IA
aws s3 cp file.txt s3://my-bucket/ --storage-class GLACIER
```

---

## 🖥️ EC2 Management

### Instance Operations
```bash
# List instances (formatted)
aws ec2 describe-instances \
    --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0],PublicIpAddress]' \
    --output table

# List running instances
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].InstanceId'

# Start instance
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Stop instance
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Reboot instance
aws ec2 reboot-instances --instance-ids i-1234567890abcdef0

# Terminate instance
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0
```

### Create Instance
```bash
# Simple instance creation
aws ec2 run-instances \
    --image-id ami-0c55b159cbfafe1f0 \
    --instance-type t2.micro \
    --key-name my-key-pair \
    --security-group-ids sg-0123456789 \
    --subnet-id subnet-0123456789

# With tags
aws ec2 run-instances \
    --image-id ami-0c55b159cbfafe1f0 \
    --instance-type t2.micro \
    --key-name my-key-pair \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyServer},{Key=Environment,Value=Production}]'
```

### Instance Metadata
```bash
# Get instance ID
aws ec2 describe-tags \
    --filters "Name=resource-type,Values=instance" \
    --query 'Tags[?Key==`Name`].Value' \
    --output text

# Get instance state
aws ec2 describe-instance-status --instance-ids i-1234567890abcdef0

# Get public IP
aws ec2 describe-instances \
    --instance-ids i-1234567890abcdef0 \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text
```

---

## 🚀 Launch Script Example

### Complete EC2 Launcher
```bash
#!/bin/bash
# launch_ec2.sh

set -euo pipefail

# Configuration
IMAGE_ID="${IMAGE_ID:-ami-0c55b159cbfafe1f0}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t2.micro}"
KEY_NAME="${KEY_NAME:-my-key}"
SECURITY_GROUP="${SECURITY_GROUP:-sg-0123456789}"
SUBNET_ID="${SUBNET_ID:-subnet-0123456789}"
INSTANCE_NAME="${INSTANCE_NAME:-MyServer}"

# Get IAM instance profile ARN
IAM_PROFILE="arn:aws:iam::$(aws sts get-caller-identity --query 'Account' --output text):instance-profile/ecsInstanceRole"

echo "Launching EC2 instance..."

# Launch instance
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$IMAGE_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$SECURITY_GROUP" \
    --subnet-id "$SUBNET_ID" \
    --iam-instance-profile "Arn=$IAM_PROFILE" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Instance ID: $INSTANCE_ID"

# Wait for instance to be running
echo "Waiting for instance to start..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "Instance is running!"
echo "Public IP: $PUBLIC_IP"
echo "SSH: ssh -i ~/${KEY_NAME}.pem ubuntu@$PUBLIC_IP"
```

---

## 🪣 Automated S3 Backup Script

### Complete Backup Solution
```bash
#!/bin/bash
# backup_to_s3.sh

set -euo pipefail

BUCKET="${1:-my-backup-bucket}"
SOURCE_DIR="${2:-/data}"
RETENTION_DAYS="${3:-7}"

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${DATE}.tar.gz"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

log "Starting backup..."

# Check if source exists
if [ ! -d "$SOURCE_DIR" ]; then
    log "ERROR: Source directory $SOURCE_DIR does not exist"
    exit 1
fi

# Create temporary backup
TEMP_FILE=$(mktemp)
tar -czf "$TEMP_FILE" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"

# Calculate checksum
CHECKSUM=$(sha256sum "$TEMP_FILE" | cut -d' -f1)

# Upload to S3
log "Uploading to S3..."
aws s3 cp "$TEMP_FILE" "s3://${BUCKET}/backups/${BACKUP_FILE}"

# Upload checksum
echo "$CHECKSUM" | aws s3 cp - "s3://${BUCKET}/backups/${BACKUP_FILE}.sha256"

# Cleanup temp file
rm -f "$TEMP_FILE"

log "Backup complete: s3://${BUCKET}/backups/${BACKUP_FILE}"

# Delete old backups
log "Cleaning up backups older than $RETENTION_DAYS days..."
aws s3 ls "s3://${BUCKET}/backups/" | while read -r line; do
    FILE_DATE=$(echo "$line" | awk '{print $1}')
    FILE_NAME=$(echo "$line" | awk '{print $4}')
    
    FILE_EPOCH=$(date -d "$FILE_DATE" +%s)
    CUTOFF_EPOCH=$(date -d "$RETENTION_DAYS days ago" +%s)
    
    if [ "$FILE_EPOCH" -lt "$CUTOFF_EPOCH" ]; then
        log "Deleting old backup: $FILE_NAME"
        aws s3 rm "s3://${BUCKET}/backups/${FILE_NAME}"
    fi
done

log "Backup process complete!"
```

---

## 🔄 EC2 Start/Stop Scheduler

### Scheduled Start/Stop
```bash
#!/bin/bash
# manage_ec2_instances.sh

set -euo pipefail

ACTION="${1:-status}"  # start, stop, status
TAG_KEY="${2:-AutoSchedule}"
TAG_VALUE="${3:-business-hours}"

log() { echo "[$(date)] $*"; }

# Get instances with tag
get_tagged_instances() {
    aws ec2 describe-instances \
        --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
                  "Name=instance-state-code,Values=[16,80]" \
        --query 'Reservations[*].Instances[*].InstanceId' \
        --output text
}

case "$ACTION" in
    start)
        log "Starting instances with tag ${TAG_KEY}=${TAG_VALUE}..."
        for instance_id in $(get_tagged_instances); do
            log "Starting $instance_id"
            aws ec2 start-instances --instance-ids "$instance_id" --output text
        done
        ;;
    stop)
        log "Stopping instances with tag ${TAG_KEY}=${TAG_VALUE}..."
        for instance_id in $(get_tagged_instances); do
            log "Stopping $instance_id"
            aws ec2 stop-instances --instance-ids "$instance_id" --output text
        done
        ;;
    status)
        log "Status of tagged instances:"
        aws ec2 describe-instances \
            --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
            --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' \
            --output table
        ;;
    *)
        echo "Usage: $0 {start|stop|status} [tag-key] [tag-value]"
        exit 1
        ;;
esac
```

### Cron Schedule Examples
```bash
# Add to crontab
crontab -e

# Start at 8 AM Monday-Friday
0 8 * * 1-5 /path/to/manage_ec2_instances.sh start AutoSchedule business-hours

# Stop at 6 PM Monday-Friday
0 18 * * 1-5 /path/to/manage_ec2_instances.sh stop AutoSchedule business-hours
```

---

## 📊 Cost Monitoring

### Cost Explorer Script
```bash
#!/bin/bash
# cost_check.sh

set -euo pipefail

# Get current month
START_DATE=$(date +%Y-%m-01)
END_DATE=$(date +%Y-%m-%d)

# Get daily costs
echo "=== Daily Costs ==="
aws ce get-cost-and-usage \
    --time-period Start="$START_DATE",End="$END_DATE" \
    --granularity DAILY \
    --metrics UnblendedCost \
    --query 'ResultsByTime[].{Date:TimePeriod.Start,Cost:Total.UnblendedCost.Amount}' \
    --output table

# Get total
TOTAL=$(aws ce get-cost-and-usage \
    --time-period Start="$START_DATE",End="$END_DATE" \
    --granularity DAILY \
    --metrics UnblendedCost \
    --query 'ResultsByTime[].Total.UnblendedCost.Amount' \
    --output text | awk '{sum+=$1} END {print sum}')

echo ""
echo "=== Total Cost (MTD): $${TOTAL} ==="

# Get costs by service
echo ""
echo "=== Costs by Service ==="
aws ce get-cost-and-usage \
    --time-period Start="$START_DATE",End="$END_DATE" \
    --granularity DAILY \
    --metrics UnblendedCost \
    --group-by Type=DIMENSION,Key=SERVICE \
    --query 'ResultsByTime[].Groups[].{Service:Keys[0],Cost:Metrics.UnblendedCost.Amount}' \
    --output table
```

### EC2 Cost by Tag
```bash
#!/bin/bash
# ec2_cost_by_tag.sh

aws ce get-cost-and-usage \
    --time-period Start=$(date -d '30 days ago' +%Y-%m-01),End=$(date +%Y-%m-%d) \
    --granularity DAILY \
    --metrics UnblendedCost \
    --group-by Type=TAG,Key=Environment \
    --query 'ResultsByTime[].Groups[].{Tag:Keys[0],Cost:Metrics.UnblendedCost.Amount}' \
    --output table
```

---

## 🔧 AWS Systems Manager

### Run Commands
```bash
# Run command on instances
aws ssm send-command \
    --instance-ids i-1234567890abcdef0 \
    --document-name "AWS-RunShellScript" \
    --parameters 'commands=["echo hello", "uptime"]'

# Get command output
aws ssm get-command-invocation \
    --command-id "abc123" \
    --instance-id i-1234567890abcdef0

# Run on all instances with tag
aws ssm send-command \
    --targets "Key=tag:Environment,Values=production" \
    --document-name "AWS-RunShellScript" \
    --parameters 'commands=["apt-get update", "apt-get upgrade -y"]'
```

---

## 📋 IAM Management

### Create User with S3 Access
```bash
#!/bin/bash
# create_iam_user.sh

set -euo pipefail

USERNAME="${1:-deploy-user}"

# Create user
aws iam create-user --user-name "$USERNAME"

# Create access key
ACCESS_KEY=$(aws iam create-access-key --user-name "$USERNAME" --query 'AccessKey.[AccessKeyId,SecretAccessKey]' --output text)
AK=$(echo "$ACCESS_KEY" | awk '{print $1}')
SK=$(echo "$ACCESS_KEY" | awk '{print $2}')

# Attach policy
aws iam attach-user-policy \
    --user-name "$USERNAME" \
    --policy-arn "arn:aws:iam::aws:policy/AmazonS3FullAccess"

echo "User created: $USERNAME"
echo "Access Key: $AK"
echo "Secret Key: $SK"
```

---

## 🔍 Troubleshooting

### Common Issues
```bash
# Credentials not found
# Check: ~/.aws/credentials and config
aws configure
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."

# Region not set
aws configure
export AWS_DEFAULT_REGION="us-west-2"

# Permission denied
aws iam get-user
# Check your IAM policy

# Rate limiting
# Use --max-items or pagination
aws s3 ls --max-items 1000
```

### Debug Mode
```bash
# Enable debug output
aws s3 ls --debug

# Validate commands
aws ec2 run-instances --dry-run

# Check service quotas
aws ec2 describe-account-attributes --attribute-names default-vcpus
```

---

## ✅ Stack 19 Complete!

You learned:
- ✅ AWS CLI installation and configuration
- ✅ S3 operations (ls, cp, sync, rm)
- ✅ EC2 management (start, stop, create)
- ✅ Complete launch script
- ✅ Automated S3 backup script
- ✅ EC2 scheduler (start/stop)
- ✅ Cost monitoring
- ✅ Systems Manager commands
- ✅ IAM management
- ✅ Troubleshooting

### Next: Stack 20 - Database Operations →

---

*End of Stack 19*
