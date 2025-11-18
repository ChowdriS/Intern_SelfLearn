NS=trainee-chowdri
 
mkdir -p deployments replicasets pods services statefulsets configmaps secrets
 
# Deployments
for d in $(kubectl get deploy -n $NS -o name); do
  kubectl get -n $NS $d -o yaml > "deployments/$(basename $d).yaml"
done
 
# ReplicaSets
for rs in $(kubectl get rs -n $NS -o name); do
  kubectl get -n $NS $rs -o yaml > "replicasets/$(basename $rs).yaml"
done
 
# Pods
for p in $(kubectl get pods -n $NS -o name); do
  kubectl get -n $NS $p -o yaml > "pods/$(basename $p).yaml"
done
 
# Services
for s in $(kubectl get svc -n $NS -o name); do
  kubectl get -n $NS $s -o yaml > "services/$(basename $s).yaml"
done
 
# StatefulSets
for ss in $(kubectl get statefulset -n $NS -o name); do
  kubectl get -n $NS $ss -o yaml > "statefulsets/$(basename $ss).yaml"
done
 
# ConfigMaps
for cm in $(kubectl get configmap -n $NS -o name); do
  kubectl get -n $NS $cm -o yaml > "configmaps/$(basename $cm).yaml"
done
 
# Secrets (optional) — note: may include sensitive data
for sec in $(kubectl get secret -n $NS -o name); do
  kubectl get -n $NS $sec -o yaml > "secrets/$(basename $sec).yaml"
done