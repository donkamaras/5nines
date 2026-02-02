Thin Ledger Core with CockroachDB
This section details the implementation of CockroachDB, the "unbreakable" distributed SQL engine that powers the OpenCore thin ledger. It is designed to maintain ACID compliance and high availability across active-active-active deployments.

🏛️ Infrastructure & Topology
CockroachDB is operationalized as a StatefulSet managed by the CockroachDB Kubernetes Operator. The deployment is configured with locality-aware replication to ensure survival during provider or regional outages.

Provider	storageClassName	topologyKey	Authentication/IAM
AWS (EKS)	gp3 or io2	topology.kubernetes.io/zone	Use IRSA for backup access to S3.
Azure (AKS)	managed-csi-premium	topology.kubernetes.io/zone	Use Managed Identity for Azure Blob backups.
GCP (GKE)	premium-rwo	topology.kubernetes.io/zone	Use Workload Identity for GCS.
On-Prem	local-path or csi-ceph	kubernetes.io/hostname	Use S3-compatible (Minio) for backups.


Anti-Affinity: Always ensure podAntiAffinity is set so that no two database pods land on the same physical K8s worker node.

PDBs: The Operator automatically manages Pod Disruption Budgets, ensuring that maintenance (like node drains) never takes down enough nodes to lose quorum.

On AWS, m6i or r6i instances provide the consistent EBS bandwidth needed for the database's Write-Ahead Log (WAL). On Azure, the v5 series offers superior throughput compared to older generations.

Storage Class: Ensure the storageClassName in your Helm chart/CRD matches the high-performance disk created by these node groups (e.g., gp3 for AWS or managed-csi-premium-zrs for Azure to get zone-redundant storage).

🛡️ Resiliency & Availability
To achieve a 5-nine (99.999%) SLA, the following guardrails are strictly enforced:

Anti-Affinity: podAntiAffinity is mandatory to ensure no two database pods land on the same physical K8s worker node.

Pod Disruption Budgets (PDBs): Automatically managed by the Operator to guarantee that maintenance (e.g., node drains) never exceeds the quorum threshold.

Quorum Requirements: A minimum of 3 nodes is required for survival of 1 node failure; 5 nodes are recommended for multi-region resiliency.

⚡ Compute & Storage Optimization
Performance for banking workloads is heavily dependent on disk I/O and network stability.

Compute Selection: * AWS: Use m6i or r6i instances for consistent EBS bandwidth required for the Write-Ahead Log (WAL).

Azure: Use the v5 series for superior throughput compared to legacy generations.

Storage Class: Ensure the storageClassName in the CRD matches high-performance disks (e.g., gp3 for AWS or managed-csi-premium-zrs for Azure to utilize Zone-Redundant Storage).

🛠️ Maintenance & Backups
Rolling Upgrades: Handled by the Operator. It ensures each node is fully re-replicated and healthy before moving to the next.

Backup Strategy: Automated full and incremental backups are pushed to provider-native object storage using the IAM mechanisms defined in the matrix above.

