# High Resiliency Application

## Overview

The High Resiliency Application project aims to develop a web application with high availability to ensure uninterrupted service for the client's critical business processes. This README provides an overview of the project's objectives, client requirements, and the Terraform infrastructure code.

## Client Requirements

### Key Objectives

1. **High Availability:** Ensure the application is accessible 24/7, minimizing downtime and interruptions.
2. **Traffic Management:** Effectively manage web traffic, preventing server overload and performance degradation.
3. **Scalability:** Develop a scalable infrastructure to handle increased demand without compromising performance.
4. **Security:** Implement robust security measures to protect user data and prevent unauthorized access.
5. **Ease of Management:** Facilitate easy monitoring, maintenance, and updates to the application.

## Terraform Infrastructure

### EC2 Instance and Auto Scaling

- Launch Configuration: Configures the EC2 instance with necessary packages and deploys the application.
- Auto Scaling Group: Ensures the desired capacity of EC2 instances, adapting to varying traffic loads.
- Auto Scaling Policies: Dynamic scaling based on CPU utilization to add or remove instances.

### Load Balancer

- Elastic Load Balancer: Manages incoming traffic, distributing it across multiple EC2 instances.
- Target Groups: Defines the targets for the load balancer, ensuring efficient routing.

### Networking

- VPC: Creates a Virtual Private Cloud to isolate the infrastructure logically.
- Subnets: Organizes instances into public and private subnets for enhanced security.
- Internet Gateway: Facilitates communication between the VPC and the internet.
- Route Tables: Manages routing within the VPC, directing traffic appropriately.
- NAT Gateway: Enables instances in private subnets to initiate outbound traffic to the internet.

### RDS (Relational Database Service)

- Database Instance: Deploys a MySQL database with specified configurations.
- Security Groups: Controls inbound and outbound traffic to the RDS instance.

### Security Groups

- ELB Security Group: Controls incoming traffic to the Elastic Load Balancer.
- EC2 Security Group: Manages traffic to the EC2 instances.
- RDS Security Group: Governs traffic to the RDS instance.

### PHP Application Code

- PHP Application: Implements a sample web page and handles data interactions with the MySQL database.

## Deployment

1. Clone the repository: `git clone https://github.com/Theo2lt/High-Resiliency-Application.git`
2. Navigate to the project directory: `cd High-Resiliency-Application`
3. Execute Terraform commands to deploy the infrastructure: `terraform init`, `terraform apply`

## Configuration

Adjust Terraform variables in `variables.tf` to customize settings such as database credentials and instance types.

```hcl
variable "pwd" {
  type    = string
  default = "MySecurePass"
}

variable "db" {
  type    = string
  default = "db"
}

variable "user" {
  type    = string
  default = "user"
}
```

## Important Note

Ensure that AWS credentials are configured on your machine before running Terraform commands. Refer to the [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) for details.
