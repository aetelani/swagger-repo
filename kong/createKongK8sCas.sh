cd kong-dist-kubernetes.git/minikube || exit 1
kubectl create -f cassandra.yaml

sleep 10
kubectl create -f kong_migration_cassandra.yaml

sleep 5
kubectl delete -f kong_migration_cassandra.yaml

sleep 10
kubectl create -f kong_cassandra.yaml

sleep 10
kubectl get all --selector=app=kong

#curl $(kubectl srv --url kong-admin)
#curl $(kubectl srv --url kong-proxy|head -n1)
