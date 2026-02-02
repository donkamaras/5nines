# 🏦 OpenCore Thin Ledger Infrastructure 📖

## Overview

This repository contains the **Infrastructure as Code (IaC)** for the **OpenCore Thin Ledger**, designed for **Multi-Tenant BYOC (Bring Your Own Cloud)** deployments.  
It enforces **five nines (99.999%) availability** through distributed consensus, strict resource isolation, and policy-driven guardrails.

The architecture follows the **RFC: Production & Operationalization Plan (Feb 1, 2026)** and prioritizes:

- **Data Sovereignty** – Physical isolation of tenant data
- **Operational Consistency** – “Golden Image” modules for predictable rollouts
- **Resiliency** – Raft-based consensus using CockroachDB and Redpanda

---

# OpenCore Infrastructure Repository

This repository defines the **foundational infrastructure, policy guardrails, and tenant deployments** for OpenCore environments using an opinionated, ring-based rollout model.

It is designed to support:
- Safe progressive delivery (canary → early → production)
- Strong policy enforcement via OPA/Rego
- Reusable “golden image” infrastructure modules
- Clear separation of **logic (modules)** and **data (live tenants)**

---

## Repository Structure

```text
├── .github/
│   └── workflows/           # CI/CD Pipelines (OPA checks & ring enforcement)
├── modules/                 # "Golden Image" Modules (The Logic)
│   ├── networking/          # VPC/VNet, subnets, security groups
│   ├── kubernetes/          # Cluster API / Managed Kubernetes logic
│   ├── database/            # CockroachDB operator & CRDs
│   └── streaming/           # Redpanda operator & Raft configuration
├── live/                    # Tenant Implementations (The Data)
│   ├── ring-0-canary/       # Internal OpenCore environments
│   ├── ring-1-early/        # Early adopter clients
│   └── ring-2-prod/         # High-stakes production ledgers
├── scripts/                 # Operational tooling
│   └── deploy_tenant.sh     # Main deployment wrapper
└── policies/                # OPA/Rego policy-as-code guardrails

```

# Thin Ledger Deployment & Operations Guide

## 🚀 Deployment Workflow

### 1. Prerequisites

Ensure the following tools and credentials are available before deployment:

- **Terraform** ≥ 1.5.0  
- **kubectl**
- **Helm**
- Cloud credentials using one of:
  - AWS IRSA
  - Azure Managed Identity
  - GCP Workload Identity

---

### 2. Provisioning a New Tenant

To deploy a **Thin Ledger** instance for a specific tenant, use the provided wrapper script.  
This ensures **state isolation** and consistent environment configuration.


# Usage:

# ./scripts/deploy_tenant.sh <tenant_id> <environment> <region>

./scripts/deploy_tenant.sh alpha-bank prod us-east-1

## 🛠 Operational Standards (RFC Compliance)

### CockroachDB Optimization

- **QoS Class**
  - Enforced **Guaranteed** (Requests = Limits)

- **Memory Split**
  - `--cache`: 25% of pod memory
  - `--max-sql-memory`: 25% of pod memory

- **Quorum**
  - Always deployed in **odd increments** (3, 5, 7+ nodes)

---

### Redpanda Tuning

- **Latency**
  - JVM-free execution targeting **< 10ms tail latency**

- **Storage**
  - XFS / NVMe optimization via:
    ```bash
    rpk redpanda tune
    ```
  - Executed through **InitContainers**

- **Isolation**
  - `podAntiAffinity` enforced so brokers never share a physical host

---

## 🛡 Policy-as-Code Guardrails

Before any `terraform apply`, the CI/CD pipeline executes **Open Policy Agent (OPA)** checks:

- **Anti-Deletion**
  - Blocks destruction of Persistent Volume Claims (PVCs)

- **Sizing Check**
  - Rejects production ledgers with **< 4 vCPUs**

- **Cost Check**
  - Flags any **un-tiered storage** configurations

---

## 🚑 Disaster Recovery

- **RPO**: 0  
  - Synchronous replication across **3 AZs / Clouds**

- **RTO**: < 60 seconds  
  - Automated leader re-election

- **Backups**
  - Hourly snapshots
  - Point-in-Time Recovery (PITR)
  - WAL shipping to object storage

---

## 📞 Support & Ownership

- **Author**: Erik Alvarado  
- **Team**: Platform Engineering / SRE  
- **Last Updated**: February 2, 2026