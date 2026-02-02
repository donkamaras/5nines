# Add the CockroachDB Helm repository
helm repo add cockroachdb https://charts.cockroachdb.com/
helm repo update

# Install the Operator in a dedicated namespace
kubectl create namespace cockroach-operator-system
helm install cockroach-operator cockroachdb/cockroachdb-operator \
  --namespace cockroach-operator-system
