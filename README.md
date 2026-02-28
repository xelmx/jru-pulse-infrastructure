# JRU-PULSE Infrastructure (IaC)

This repository contains the **Terraform** configuration used to provision a production-grade AWS environment for the JRU-PULSE Analytics Platform.

## Architecture Overview
The platform is built on a **Microservices Architecture** using a "Separation of Concerns" strategy:
- **Frontend:** PHP Web Application (ECS Fargate)
- **Backend:** Python FastAPI NLP Engine (ECS Fargate)
- **Database:** Amazon RDS (MySQL 8.0) in a private subnet.

## Key DevOps Features
- **Zero-Trust Security:** No permanent IAM Access Keys. CI/CD is secured via **OIDC Federation**.
- **Global Delivery:** SSL/TLS termination and edge caching provided by **Amazon CloudFront**.
- **Network Isolation:** Multi-tier VPC design with Public/Private subnets and Security Group referencing to prevent unauthorized database access.
- **FinOps Optimized:** Infrastructure supports "Scale-to-Zero" and utilizes AWS Free Tier eligible resources to manage university-level budgets.

## Repository Map
- `vpc.tf`: Multi-AZ network foundation.
- `ecs_tasks.tf`: Container orchestration & resource limits.
- `alb.tf`: Application Load Balancer with Path-Based Routing (`/ai` vs `/`).
- `secrets.tf`: Encrypted credential management.
- `iam.tf`: OIDC Provider and Least Privilege roles.


### -------------

![JRU-PULSE CI/CD Pipeline] (<img/JRU-PULSE_AWS-Cloud-CI_CD-Pipeline.png>)

### Architecture Breakdown
- **Identity & Security:** GitHub Actions authenticates via **OIDC** to eliminate permanent credentials. Sensitive data is injected into containers at runtime via **AWS Secrets Manager**.
- **Traffic Management:** **Amazon CloudFront** provides global HTTPS delivery. An **Application Load Balancer** performs path-based routing to decouple the PHP Frontend and the Python NLP Backend.
- **Compute:** Services are hosted on **AWS ECS Fargate**, providing a serverless, scalable container environment.
- **Database:** A private **Amazon RDS (MySQL)** instance ensures data persistence, isolated from the public internet for maximum security.