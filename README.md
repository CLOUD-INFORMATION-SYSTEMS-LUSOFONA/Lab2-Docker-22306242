# Lab 11 - CI/CD Pipeline with GitHub Actions

## Student: Gonçalo Soares - 22306242

## Project Description
This repository contains a Java microservices project with a complete CI/CD pipeline built with GitHub Actions, including Docker image builds, AWS OIDC authentication, Terraform automation, and production deployment with approval gates.

## Repository Structure
project-root/
├── .github/
│   └── workflows/
│       ├── hello.yml
│       ├── ci.yml
│       ├── image.yml
│       ├── aws-test.yml
│       ├── terraform.yml
│       ├── build-all.yml
│       ├── deploy-prod.yml
│       ├── reusable-image.yml
│       └── release.yml
├── services/
│   ├── user-service/
│   ├── product-service/
│   ├── order-service/
│   └── api-gateway/
├── terraform/
└── README.md

## Workflows

- **hello.yml** - First workflow, prints repository info on every push
- **ci.yml** - CI pipeline: validates, compiles and tests the Java microservice on every PR
- **image.yml** - Builds and pushes Docker image to Docker Hub on push to main
- **aws-test.yml** - Tests AWS OIDC authentication without storing AWS keys
- **terraform.yml** - Runs terraform plan on PRs and terraform apply on merge to main
- **build-all.yml** - Matrix build for all services in parallel
- **deploy-prod.yml** - Production deployment with manual approval gate + Job Summary + Slack notification
- **reusable-image.yml** - Reusable workflow for Docker build/push
- **release.yml** - Calls reusable workflow on version tags (v*)

## Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| DOCKERHUB_USERNAME | Docker Hub username |
| DOCKERHUB_TOKEN | Docker Hub personal access token |
| AWS_ROLE_TO_ASSUME | IAM role ARN for OIDC authentication |
| SLACK_WEBHOOK | Slack incoming webhook URL |

## How to Trigger Workflows

- **hello.yml** - Automatic on push, or manually via Actions tab
- **ci.yml** - Automatic on PR or push to main
- **image.yml** - Automatic on push to main
- **aws-test.yml** - Manually via Actions tab
- **terraform.yml** - Automatic on PR or push to main (terraform/ changes only)
- **build-all.yml** - Automatic on push to main
- **deploy-prod.yml** - Manually via Actions tab (requires approval)
- **release.yml** - Automatic on version tag push (git tag v1.0.0)

## Docker Hub

Images are published to Docker Hub under `goncfsoares`:
- `goncfsoares/product-service:latest`
- `goncfsoares/product-service:<git-sha>`
- `goncfsoares/user-service:<git-sha>`
- `goncfsoares/order-service:<git-sha>`

## Terraform

The `terraform/` directory contains infrastructure as code for AWS resources including VPC, subnets, and EC2 instances.

To run locally:
```bash
terraform init
terraform plan
terraform apply
```

## AWS OIDC Setup

GitHub Actions authenticates with AWS using OIDC (no stored AWS keys):
1. OIDC Provider: `token.actions.githubusercontent.com`
2. IAM Role: `gha-deployer` with trust policy scoped to this repository
3. Secret `AWS_ROLE_TO_ASSUME` contains the role ARN
