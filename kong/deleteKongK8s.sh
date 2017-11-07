cd kong-dist-kubernetes.git/minikube || exit 1

kubectl delete -f kong_postgres.yaml

sleep 5
kubectl delete -f postgres.yaml

echo "Still running resources..."
#kubectl get all -o=wide --selector=app=kong -ojson
kubectl get all | grep -i kong
