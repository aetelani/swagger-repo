cd kong-dist-kubernetes.git || exit 1
kubectl delete -f kong_postgres.yaml
kubectl delete -f postgres.yaml
echo "Still running resources..."
kubectl get all -o=wide --selector=app=kong -ojson
