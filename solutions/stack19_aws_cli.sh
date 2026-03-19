#!/bin/bash
# Stack 19 Solution: AWS CLI Scripting - AWS Manager

set -euo pipefail

NAME="AWS Manager"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - AWS CLI Management Tool

Usage: $0 [COMMAND] [OPTIONS]

EC2:
    instances           List EC2 instances
    start INSTANCE      Start instance
    stop INSTANCE       Stop instance
    status INSTANCE     Instance status

S3:
    s3-ls               List buckets
    s3-ls BUCKET        List objects in bucket
    s3-put BUCKET FILE  Upload file
    s3-get BUCKET KEY   Download file
    s3-rm BUCKET KEY    Delete object

IAM:
    users               List IAM users
    whoami              Current IAM user

CLOUDFORMATION:
    stacks              List CloudFormation stacks
    stack-create STACK FILE  Create stack

EXAMPLES:
    $0 instances
    $0 s3-ls mybucket
    $0 s3-put mybucket file.txt
EOF
}

check_aws() {
    if ! command -v aws &>/dev/null; then
        error "AWS CLI not installed"
        exit 1
    fi
}

cmd_instances() {
    check_aws
    echo -e "${BLUE}=== EC2 Instances ===${NC}"
    aws ec2 describe-instances \
        --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,Tags[0].Value,PublicIpAddress]' \
        --output table 2>/dev/null || \
        aws ec2 describe-instances --output table
}

cmd_start() {
    check_aws
    local instance=$1
    aws ec2 start-instances --instance-ids "$instance"
    log "Started instance: $instance"
}

cmd_stop() {
    check_aws
    local instance=$1
    aws ec2 stop-instances --instance-ids "$instance"
    log "Stopped instance: $instance"
}

cmd_status() {
    check_aws
    local instance=$1
    aws ec2 describe-instances --instance-ids "$instance" \
        --query 'Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress,LaunchTime]' \
        --output table
}

cmd_s3_ls() {
    check_aws
    local bucket=${1:-}
    
    if [ -z "$bucket" ]; then
        echo -e "${BLUE}=== S3 Buckets ===${NC}"
        aws s3 ls
    else
        echo -e "${BLUE}=== Objects in $bucket ===${NC}"
        aws s3 ls "s3://$bucket/"
    fi
}

cmd_s3_put() {
    check_aws
    local bucket=$1
    local file=$2
    
    aws s3 cp "$file" "s3://$bucket/"
    log "Uploaded $file to s3://$bucket/"
}

cmd_s3_get() {
    check_aws
    local bucket=$1
    local key=$2
    
    aws s3 cp "s3://$bucket/$key" ./
    log "Downloaded $key from s3://$bucket/"
}

cmd_s3_rm() {
    check_aws
    local bucket=$1
    local key=$2
    
    aws s3 rm "s3://$bucket/$key"
    log "Deleted $key from s3://$bucket/"
}

cmd_users() {
    check_aws
    echo -e "${BLUE}=== IAM Users ===${NC}"
    aws iam list-users --output table
}

cmd_whoami() {
    check_aws
    echo -e "${BLUE}=== Current User ===${NC}"
    aws iam get-user --output table
}

cmd_stacks() {
    check_aws
    echo -e "${BLUE}=== CloudFormation Stacks ===${NC}"
    aws cloudformation list-stacks --query 'StackSummaries[*].[StackName,StackStatus,CreationTime]' --output table
}

cmd_stack_create() {
    check_aws
    local name=$1
    local file=$2
    
    aws cloudformation create-stack --stack-name "$name" --template-body "file://$file"
    log "Creating stack: $name"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        instances) cmd_instances ;;
        start) cmd_start "$1" ;;
        stop) cmd_stop "$1" ;;
        status) cmd_status "$1" ;;
        s3-ls) cmd_s3_ls "${1:-}" ;;
        s3-put) cmd_s3_put "$1" "$2" ;;
        s3-get) cmd_s3_get "$1" "$2" ;;
        s3-rm) cmd_s3_rm "$1" "$2" ;;
        users) cmd_users ;;
        whoami) cmd_whoami ;;
        stacks) cmd_stacks ;;
        stack-create) cmd_stack_create "$1" "$2" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
