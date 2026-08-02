# Azure Terraform Infrastructure

This repository contains Terraform configuration for deploying Azure infrastructure using GitHub Actions for CI/CD.

## Overview

This project sets up an enterprise-grade Azure infrastructure with:
- **Hub & Spoke Networking**: Virtual network peering between hub and spoke VNets
- **Storage Account**: With private endpoints and DNS zones
- **Identity**: User-assigned managed identities
- **Security**: Resource locks and RBAC configurations

## Prerequisites

- Azure subscription with appropriate permissions
- GitHub repository with Actions enabled
- Azure AD App Registration for GitHub OIDC authentication

## GitHub Actions Setup

### 1. Configure Azure AD OIDC

Create a federated credential in your Azure AD App Registration:
- Audience: `api://AzureADTokenExchange`
- Issuer: `https://token.actions.githubusercontent.com`
- Identifier: Use your GitHub repository details (e.g., `repo:Deepan99@89961904/azure_bb_expd_migration@1320438859:ref:refs/heads/main`)

### 2. Add GitHub Secrets

Add the following secrets to your GitHub repository:
- `AZURE_CLIENT_ID`: Your Azure AD application client ID
- `AZURE_TENANT_ID`: Your Azure AD tenant ID
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID
- `ADMIN_PASSWORD`: Strong password for VM admin access (required for compute module)

### 3. Configure GitHub Actions

The workflow is located in `.github/workflows/terraform.yml` and will:
- Authenticate with Azure using OIDC
- Initialize Terraform
- Apply infrastructure changes on push to main branch

## Local Development

### Initialize Terraform
```bash
terraform init
```

### Plan Changes
```bash
terraform plan
```

### Apply Changes
```bash
terraform apply
```

## Module Structure

- `modules/networking`: Hub and spoke VNet configuration
- `modules/storage`: Storage account with private endpoints
- `modules/identity`: Managed identity and RBAC
- `modules/compute`: Virtual machine configuration (currently disabled)

## State Management

Terraform state is stored in Azure Storage Account:
- Resource Group: `rg-tfstate-eastus`
- Storage Account: `sttfstate2026eastus`
- Container: `tfstate`

## Security Notes

- Resource locks prevent accidental deletion
- Private endpoints ensure secure connectivity
- OIDC authentication eliminates credential management
- All secrets are managed through GitHub Secrets
