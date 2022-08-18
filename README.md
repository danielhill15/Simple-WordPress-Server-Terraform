## Interview Coding Problem

### Overview

Simple terraform project that creates a WordPress and MySQL server. The configuration includes:

- VPC 
- Public subnet for WordPress server and Private subnet for MySQL server
- Route table, route table association, and an Internet Gateway attached to VPC
- Security group for WordPress allowing HTTP SSH (fully public for demo)
- Security Group for MySQL allowing access from WordPress Security Group
- Instance running MySQL server
- Instance running WordPress server

### Setup

**Note** If you do not already have AWS access keys stored or saved, navigate to AWS Console, go to IAM -> Users and click on `admin` user. Under `Security credentials` tab, click `Create access key` and download csv

1. Update variables in `terraform.tfvars` using admin keys.
3. Run `terraform init`
4. Run `terraform plan`
5. Run `terraform apply`
6. Wait for the apply to be completed, and give the instances a few minutes to finish configurating.
7. Navigate to the AWS Console and go to EC2 -> Instances and click on the instance running named `"WordPress-OS"`.
8. Find `Public IPv4 address` and click the link `open address` or copy the ip and paste it into a browser. You should be prompted `Your connection is not private`, then click `Advanced` and `Proceed to` to WordPress site.

**NOTE** The security group for the WordPress instance is currently open to all public access for the purpose of the demo, but is configured to only be accessed from inside the vpc if you remove the public access from WordPress Security Group.

### Cleanup

When you are done accessing the WordPress server, run `terraform destroy` to destroy all the resources
