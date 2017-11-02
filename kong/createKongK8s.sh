cd kong-dist-kubernetes.git || exit 1
kubectl create -f postgres.yaml
kubectl create -f kong_migration_postgres.yaml
kubectl delete -f kong_migration_postgres.yaml
kubectl create -f kong_postgres.yaml
kubectl get all --selector=app=kong
#curl $(kubectl srv --url kong-admin)
#curl $(kubectl srv --url kong-proxy|head -n1)
