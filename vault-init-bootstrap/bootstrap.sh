#!/bin/bash
# author: Tim Fairweather
# email: tim.fairweather@arctiq.ca
# website: www.arctiq.ca

# This script is designed to be run inside of a kubernetes pod as a part of a job spec. The script requires some variable parameters to be passed to it as follows:
# usage: bootstrap.sh -n namespace -s fullname -p ssl_port

# Where namespace is the Kubernetes namespace where Consul is currently installed and fullname is the Name provided for the deployment via Helm, along with the SSL port.

# This bootstrap container is meant to run as a k8s job AFTER Consul has been deployed via the consul-helm project, with customizations to the deployment for acl config.
# spec:
#   template:
#     spec:
#       containers:
#         - name: vault
#           readinessProbe:
#             httpGet:
#               path: /v1/sys/health?perfstandbyok=true;standbyok=true
#               port: 8200
#               scheme: HTTPS
#             initialDelaySeconds: 5
#             periodSeconds: 5

bootstrap ()
{
export VAULT_DETAILS=$(curl \
  --insecure \
  --request PUT \
  --data \
'{
  "secret_shares": 5,
  "secret_threshold": 3
}' https://127.0.0.1:8200/v1/sys/init)

export UNSEAL_KEYS=$(echo VAULT_DETAILS | jq -r '.keys[]')

export ROOT_TOKEN=$(echo VAULT_DETAILS | jq -r '.root_token')

INDEX=0
for unseal_key in $UNSEAL_KEYS
do
  kubectl create secret generic unseal-key-${INDEX} --from-literal=unseal_key=${unseal_key} -n vault
  kubectl set env statefulset/vault KEY_${INDEX}=${unseal_key} -n vault
  let INDEX=${INDEX}+1
done

kubectl create secret generic root-token=${ROOT_TOKEN} -n vault

kubectl patch statefulset $FULLNAME-server -n $NAMESPACE -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"consul\",\"ports\":[{\"containerPort\":$PORT,\"name\":\"https\"}]}]}}}}"
kubectl patch daemonset $FULLNAME -n $NAMESPACE -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"consul\",\"ports\":[{\"containerPort\":$PORT,\"hostPort\":$PORT,\"name\":\"https\"}]}]}}}}"
kubectl patch service $FULLNAME-server -n $NAMESPACE -p "{\"spec\":{\"clusterIP\":\"None\",\"ports\":[{\"name\":\"https\",\"port\":$PORT,\"protocol\":\"TCP\",\"targetPort\":$PORT}]}}"
}

usage ()
{
    echo "usage: bootstrap.sh -n namespace -s fullname -p ssl_port"
}

while [ "$1" != "" ]; do
    case $1 in
        -n | --namespace )      shift
                                NAMESPACE=$1
                                ;;
        -s | --fullname )       shift
                                FULLNAME=$1
                                ;;
        -p | --port )           shift
                                PORT=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

while [ "$3" != "" ]; do
    case $3 in
        -n | --namespace )      shift
                                NAMESPACE=$3
                                ;;
        -s | --fullname )       shift
                                FULLNAME=$3
                                ;;
        -p | --port )           shift
                                PORT=$3
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

while [ "$5" != "" ]; do
    case $5 in
        -n | --namespace )      shift
                                NAMESPACE=$5
                                ;;
        -s | --fullname )       shift
                                FULLNAME=$5
                                ;;
        -p | --port )           shift
                                PORT=$5
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

# echo "Namespace is: $NAMESPACE"
# echo "Fullname is: $FULLNAME"

if [ "$NAMESPACE" ] && [ "$FULLNAME" ] && [ "$PORT" ]; then
  bootstrap
else
  usage
  exit 1
fi