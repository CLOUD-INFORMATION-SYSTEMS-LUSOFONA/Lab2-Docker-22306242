\# Terraform Week 9 - Modules \& Advanced Features



\## How to Run



```bash

terraform init

terraform validate

terraform plan -out=tfplan

terraform apply tfplan

```



\## Project Structure



terraform-week9/

├── main.tf

├── variables.tf

├── outputs.tf

├── terraform.tfvars

└── modules/

├── vpc/

│   ├── main.tf

│   ├── variables.tf

│   └── outputs.tf

└── ec2/

├── main.tf

├── variables.tf

└── outputs.tf



\## Modules



\### VPC Module (`modules/vpc`)

Creates a VPC with public and private subnets, internet gateway, and route tables.



\*\*Inputs:\*\*

\- `vpc\_name` - Name of the VPC (default: "week9-vpc")

\- `vpc\_cidr` - CIDR block for the VPC (default: "10.0.0.0/16")

\- `public\_subnet\_cidr` - CIDR for public subnet (default: "10.0.1.0/24")

\- `private\_subnet\_cidr` - CIDR for private subnet (default: "10.0.2.0/24")

\- `availability\_zone\_1` - First AZ (default: "us-east-1a")

\- `availability\_zone\_2` - Second AZ (default: "us-east-1b")



\*\*Outputs:\*\*

\- `vpc\_id` - ID of the created VPC

\- `public\_subnet\_id` - ID of the public subnet

\- `private\_subnet\_id` - ID of the private subnet

\- `public\_subnet\_ids` - List of public subnet IDs



\### EC2 Module (`modules/ec2`)

Launches an EC2 instance with a security group inside the provided VPC.



\*\*Inputs:\*\*

\- `instance\_name` - Name of the EC2 instance (default: "week9-instance")

\- `vpc\_id` - VPC ID (required)

\- `subnet\_id` - Subnet ID (required)

\- `ami\_id` - AMI ID (required)

\- `instance\_type` - Instance type (default: "t3.micro")

\- `key\_name` - Key pair name (required)



\*\*Outputs:\*\*

\- `instance\_id` - ID of the EC2 instance

\- `public\_ip` - Public IP address

\- `security\_group\_id` - Security group ID



\## Activity 4 - Refactoring Approach

The existing infrastructure was refactored by extracting VPC and EC2 resources into reusable modules. The root `main.tf` now simply calls these modules and passes outputs between them (e.g., `vpc\_id` and `subnet\_id` from the network module to the compute module). This improves reusability, readability, and maintainability.



\## Activity 10 - count vs for\_each

\### Before (static ingress blocks):

```hcl

ingress {

&#x20; from\_port   = 22

&#x20; to\_port     = 22

&#x20; protocol    = "tcp"

&#x20; cidr\_blocks = \["0.0.0.0/0"]

}

ingress {

&#x20; from\_port   = 80

&#x20; to\_port     = 80

&#x20; protocol    = "tcp"

&#x20; cidr\_blocks = \["0.0.0.0/0"]

}

```



\### After (dynamic block with for\_each):

```hcl

locals {

&#x20; ingress\_ports = toset(\["22", "80"])

}



dynamic "ingress" {

&#x20; for\_each = local.ingress\_ports

&#x20; content {

&#x20;   from\_port   = tonumber(ingress.value)

&#x20;   to\_port     = tonumber(ingress.value)

&#x20;   protocol    = "tcp"

&#x20;   cidr\_blocks = \["0.0.0.0/0"]

&#x20; }

}

```



\### What changed in resource addressing:

With `for\_each`, each rule is identified by its key (port number) instead of an index. This means adding or removing a port only affects that specific rule, not all subsequent ones.



\### Why for\_each is safer than count:

With `count`, resources are addressed by index (e.g., `\[0]`, `\[1]`). If you remove an item from the middle of a list, Terraform destroys and recreates all subsequent resources. With `for\_each`, resources are addressed by a unique key, so only the affected resource is changed.

