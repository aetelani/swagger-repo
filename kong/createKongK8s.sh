cd kong-dist-kubernetes.git/minikube || exit 1
kubectl create -f postgres.yaml

sleep 10
kubectl create -f kong_migration_postgres.yaml

sleep 5
kubectl delete -f kong_migration_postgres.yaml

sleep 10
kubectl create -f kong_postgres.yaml

sleep 10
kubectl get all --selector=app=kong

#curl $(kubectl srv --url kong-admin)
#curl $(kubectl srv --url kong-proxy|head -n1)
