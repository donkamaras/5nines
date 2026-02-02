resource "azurerm_kubernetes_cluster_node_pool" "cockroach_pool" {
  name                  = "crdbpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_D8s_v5" # 8 vCPU / 32GiB RAM
  node_count            = 6
  
  # Spread nodes across all 3 Azure Availability Zones
  zones = ["1", "2", "3"]

  # Enable ultra-fast storage access
  os_disk_type = "Ephemeral" # Better for high-IOPS stateful workloads
  os_disk_size_gb = 128

  node_labels = {
    "workload-type" = "database"
    "app"           = "cockroachdb"
  }

  node_taints = [
    "dedicated=cockroachdb:NoSchedule"
  ]

  # Necessary for maintaining availability during cluster upgrades
  upgrade_settings {
    max_surge = "10%"
  }
}