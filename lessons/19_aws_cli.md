# ☁️ STACK 19: AWS CLI SCRIPTING
## Cloud Automation with AWS

**What is AWS CLI?** Think of it as a remote control for Amazon's cloud services. Instead of clicking around in a web browser, you type commands to create servers, store files, and manage everything - and you can script it all!

**⚠️ Cost Awareness:** AWS services cost money. Always check what you're creating and clean up when done. This guide shows costs where relevant, but always verify current pricing!

---

## 🔰 Why AWS CLI?

AWS CLI enables:
- ✅ **Automation** - Script everything (no more manual console clicks)
- ✅ **Cost savings** - Start/stop instances on schedule (don't pay for idle servers!)
- ✅ **Backup automation** - S3 backups on autopilot
- ✅ **Infrastructure as Code** - CLI-driven deployments (reproducible)
- ✅ **Monitoring** - Cost and resource tracking

### Real-World Example
Instead of paying for a dev server 24/7 (~$70/month), script it to:
- Start at 9 AM, stop at 6 PM on weekdays
- Save ~$45/month = ~$540/year!

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

## 🎓 Final Project: AWS Cloud Manager

Now that you've mastered AWS CLI basics, let's see how a professional Cloud Engineer might automate infrastructure. We'll examine the "AWS Manager" — a tool that provides a simplified interface for managing EC2 instances, S3 buckets, and CloudFormation stacks.

### What the AWS Cloud Manager Does:
1. **EC2 Fleet Management** (list, start, stop, and check status of instances).
2. **S3 Bucket Operations** (list buckets/objects, upload, download, and delete).
3. **IAM User Auditing** (list all users and verify your current identity).
4. **Infrastructure Deployment** (list and create CloudFormation stacks).
5. **Output Formatting** using AWS `--query` and `--output table` for readability.
6. **Automatic CLI Validation** (checks if AWS CLI is installed before running).

### Key Snippet: Beautiful Table Output with Queries
The power of AWS CLI in scripts comes from the `--query` flag, which lets you filter out only the information you need.

```bash
cmd_instances() {
    echo "=== EC2 Instances ==="
    # Query only specific fields: ID, Type, State, Name (from tags), and IP
    aws ec2 describe-instances \
        --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,Tags[0].Value,PublicIpAddress]' \
        --output table
}
```

### Key Snippet: Managing S3 Objects
The manager provides a simplified way to interact with S3 without typing long `s3://` URLs every time.

```bash
cmd_s3_put() {
    local bucket=$1
    local file=$2
    
    # Upload to S3
    aws s3 cp "$file" "s3://$bucket/"
    log "Uploaded $file successfully!"
}
```

**Pro Tip:** Automation like this is the foundation of "Infrastructure as Code" (IaC) — it makes your cloud environment predictable, repeatable, and easy to manage!

---

## ✅ Stack 19 Complete!

Congratulations! You've taken your Bash skills to the global scale of the AWS Cloud! You can now:
- ✅ **Install and configure AWS CLI** with secure credentials
- ✅ **Master S3** for globally accessible file storage and backups
- ✅ **Manage EC2 instances** to run your code on virtual servers
- ✅ **Automate infrastructure** using CloudFormation and CLI scripts
- ✅ **Audit IAM users** to ensure your cloud environment is secure
- ✅ **Save money** by scheduling servers to run only when needed

### What's Next?
In the next stack, we'll dive into **Database Operations**. You'll learn how to connect your scripts to SQL databases like MySQL and PostgreSQL to store and retrieve persistent data!

**Next: Stack 20 - Database Operations →**

---

*End of Stack 19*
- **Previous:** [Stack 18 → System Monitoring](18_system_monitoring.md)
- **Next:** [Stack 20 - Database Operations](20_database_ops.md)