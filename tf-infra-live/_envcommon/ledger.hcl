# Inherit root settings for remote state and providers
include "root" {
  path = find_in_parent_folders()
}

# Source the specific version of your Golden Module
terraform {
  source = "git::https://github.com/tf-modules.git//thin-ledger-cluster?ref=v1.2.0"
}

# Client-specific overrides
inputs = {
  client_name    = "client-b"
  node_count     = 5                               # High-volume client requirement
  storage_class  = "managed-csi-premium-zrs"       # Azure-specific high-perf storage
  locality       = "cloud=azure,region=eastus2"    # Active-Active consistency
}