cd kong-dist-kubernetes.git/minikube || exit 1

kubectl delete -f kong_cassandra.yaml

sleep 5
kubectl delete -f cassandra.yaml

echo "Still running resources..."
#kubectl get all -o=wide --selector=app=kong -ojson
kubectl get all | grep -i kong
