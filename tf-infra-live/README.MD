tf-infra-live/
├── terragrunt.hcl           # Root config: Sets up remote state (S3/GCS)
├── _envcommon/              # Shared logic for all environments
│   └── ledger.hcl
├── client-a-aws/            # Client A: EKS-based deployment
│   ├── region.hcl           # e.g., us-east-1
│   └── thin-ledger/
│       └── terragrunt.hcl   # Inherits from golden module
└── client-b-azure/          # Client B: AKS-based deployment
    ├── region.hcl           # e.g., eastus2
    └── thin-ledger/
        └── terragrunt.hcl   # Overrides storageClass for Azure