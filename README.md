# Terraform

This repo is my first use of Terraform, written to create a simple VPC on EC2 to run a provided IT_JOBS_WATCH data scraper app.

## What is Terraform
Terraform is an orchestration tool, that is part as Infrastructure as Code, whereas Chef and Packer are Configuration management. The latter two are immutable. 

Terraform includes the creation of networks and complex systems, and deploying AMIs - blueprints of an instance. 

### How to use

1) Run `git clone https://github.com/AshIsbitt/terraform_app_deploy` to pull from Github

2) run `terraform apply` to create VPC.


### Prerequisites
- git
- terraform