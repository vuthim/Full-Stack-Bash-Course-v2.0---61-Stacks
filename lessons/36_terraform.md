# 🏗️ STACK 36: TERRAFORM BASICS
## Infrastructure as Code with Terraform

**What is Terraform?** Think of Terraform as a "blueprint-to-building" tool for IT infrastructure. Instead of manually clicking in a cloud console to create servers, you write a text file describing what you want, and Terraform builds it for you - consistently, every time!

**Why This Matters:** Terraform eliminates "click ops" (manual console clicks). Your infrastructure becomes code - version-controlled, reviewable, and reproducible!

---

## 🔰 What is Terraform?

Terraform is an Infrastructure as Code (IaC) tool that lets you define cloud and on-prem resources in code.

### Why Terraform? (The Benefits)
- ✅ **Declarative**: Define WHAT you want, not HOW to build it (like ordering from a menu)
- ✅ **Provider ecosystem**: AWS, Azure, GCP, and 1000+ more (one tool for everything)
- ✅ **State management**: Tracks what exists (prevents duplicates, detects drift)
- ✅ **Plan/Apply**: Preview changes BEFORE they happen (no surprises!)

### Terraform Analogy for Beginners
```
Manual:     Click around in AWS console → hope you did it right
Terraform:  Write code → terraform plan (preview) → terraform apply (done!)

It's like the difference between:
- Manually drawing a house blueprint each time
- Having a template you can reuse and modify
```

---

## ⚡ Installing Terraform

### Linux
```bash
# Download
curl -LO https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip

# Unzip
unzip terraform_1.6.0_linux_amd64.zip

# Move to PATH
sudo mv terraform /usr/local/bin/

# Verify
terraform version
```

### macOS
```bash
# Via Homebrew
brew install terraform
```

---

## 📝 Basic Terraform Files

### Provider Configuration
```hcl
# provider.tf
provider "aws" {
  region = "us-east-1"
  
  credentials = {
    access_key = "YOUR_ACCESS_KEY"
    secret_key = "YOUR_SECRET_KEY"
  }
}
```

### Resource Definition
```hcl
# main.tf
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "web-server"
  }
}
```

---

## ⚙️ Terraform Workflow

### Initialization
```bash
# Initialize (download providers)
terraform init

# View providers
terraform providers
```

### Planning
```bash
# Create execution plan
terraform plan

# Save plan to file
terraform plan -out=plan.tfplan

# Show plan
terraform show plan.tfplan
```

### Applying
```bash
# Apply changes
terraform apply

# Apply saved plan
terraform apply plan.tfplan
```

### Destroying
```bash
# Destroy resources
terraform destroy

# Destroy specific resource
terraform destroy -target aws_instance.web
```

---

## 📦 Variables

### Variables File
```hcl
# variables.tf
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
```

### Using Variables
```hcl
# main.tf
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type
}
```

### Variable Values
```bash
# Using default
terraform apply

# Override with flag
terraform apply -var="instance_type=t2.small"

# Using terraform.tfvars
# terraform.tfvars:
# instance_type = "t2.small"
```

---

## 📊 Outputs

### Define Output
```hcl
# outputs.tf
output "instance_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.web.public_ip
}

output "instance_id" {
  description = "ID of the instance"
  value       = aws_instance.web.id
}
```

### Show Outputs
```bash
# Apply shows outputs
terraform apply

# Show outputs
terraform output

# Show specific output
terraform output instance_ip
```

---

## 📁 State Management

### Local State
```bash
# Default - terraform.tfstate
ls
terraform.tfstate*
```

### Remote State (S3)
```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### State Commands
```bash
# Show state
terraform show

# List resources
terraform state list

# Move resource
terraform state mv aws_instance.web aws_instance.new_web

# Remove resource (not destroy)
terraform state rm aws_instance.web
```

---

## 🔗 Data Sources

### Using Data Source
```hcl
# Get latest Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Use in resource
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
}
```

---

## 🔄 Modules

### Using Module
```hcl
# main.tf
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
}
```

---

## 🏆 Practice Exercises

### Exercise 1: Create EC2 Instance
```hcl
# main.tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "terraform-web"
  }
}
```

```bash
# Run
terraform init
terraform plan
terraform apply
```

### Exercise 2: Add Variables
```hcl
# variables.tf
variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}
```

### Exercise 3: Create Outputs
```hcl
# outputs.tf
output "public_ip" {
  value = aws_instance.web.public_ip
}

output "private_ip" {
  value = aws_instance.web.private_ip
}
```

---

## 📋 Terraform Cheat Sheet

| Command | Action |
|---------|--------|
| `terraform init` | Initialize |
| `terraform plan` | Preview changes |
| `terraform apply` | Apply changes |
| `terraform destroy` | Destroy resources |
| `terraform state` | Manage state |

---

## 🎓 Final Project: Terraform Infrastructure Manager

Now that you've mastered the concepts of Infrastructure as Code (IaC), let's see how a professional Cloud Architect might automate their Terraform workflows. We'll examine the "Terraform Manager" — a tool that simplifies the entire infrastructure lifecycle, from initialization to destruction.

### What the Terraform Infrastructure Manager Does:
1. **Automates Initialization** of Terraform backends and providers.
2. **Validates Configurations** to catch syntax errors before they hit the cloud.
3. **Simplifies Planning & Applying** by wrapping complex CLI flags.
4. **Manages Workspaces** (e.g., Development vs. Production) with easy commands.
5. **Audits Infrastructure State** by listing and showing managed resources.
6. **Protects Against Accidental Deletion** by requiring clear confirmation for `destroy` commands.

### Key Snippet: Automated Initialization & Validation
A robust script ensures that Terraform is ready to go before attempting to make any changes to your infrastructure.

```bash
cmd_init() {
    local dir=${1:-.}
    
    # Check if Terraform is installed first
    if ! command -v terraform &>/dev/null; then
        error "Terraform not found! Please install it first."
        exit 1
    fi
    
    cd "$dir"
    # Initialize the project (downloads providers and sets up state)
    terraform init
    log "Infrastructure project initialized in $dir."
}
```

### Key Snippet: Workspace Management
Workspaces allow you to use the same code to build multiple environments. The manager makes switching between them a one-word command.

```bash
cmd_workspace_select() {
    local name=$1
    
    # Switch to a specific workspace (e.g., 'staging' or 'production')
    terraform workspace select "$name"
    log "Switched to infrastructure workspace: $name"
}
```

**Pro Tip:** Automation tools like this are how modern teams manage thousands of cloud resources without manual errors or configuration drift!

---

## ✅ Stack 36 Complete!

Congratulations! You've successfully turned your infrastructure into code! You can now:
- ✅ **Understand Terraform's "Declarative" model** (Define what you want, not how to get it)
- ✅ **Manage cloud resources** across AWS, Azure, and Google Cloud
- ✅ **Use Variables and Outputs** to build flexible, reusable infrastructure
- ✅ **Master State Management** to keep track of your deployed resources
- ✅ **Automate infrastructure changes** using Plans and Applies
- ✅ **Use Workspaces** to manage multiple environments with the same code

### What's Next?
In the next stack, we'll dive into **Prometheus & Grafana**. You'll learn how to build professional monitoring dashboards to track the performance of your infrastructure in real-time!

**Next: Stack 37 - Monitoring Stack →**

---

*End of Stack 36*
- **Previous:** [Stack 35 → Firewall & Security](35_firewall.md)
-- **Next:** [Stack 37 - Monitoring Stack](37_monitoring_stack.md)