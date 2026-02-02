resource "aws_eks_node_group" "cockroach_nodes" {
  cluster_name    = var.eks_cluster_name
  node_group_name = "cockroachdb-ha-pool"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_ids # Must include subnets in 3 different AZs

  scaling_config {
    desired_size = 6 # 2 nodes per zone for 5 nines
    max_size     = 9
    min_size     = 3
  }

  instance_types = ["m6i.2xlarge"] # 8 vCPU / 32GiB RAM
  capacity_type  = "ON_DEMAND"     # 5 Nines requires On-Demand to avoid Spot interruptions

  # Labels used by the CrdbCluster YAML for scheduling
  labels = {
    "workload-type" = "database"
    "app"           = "cockroachdb"
  }

  # Taints prevent standard web apps from "stealing" resources from the DB
  taint {
    key    = "dedicated"
    value  = "cockroachdb"
    effect = "NO_SCHEDULE"
  }

  update_config {
    max_unavailable = 1 # Ensures only one node is upgraded at a time
  }
}