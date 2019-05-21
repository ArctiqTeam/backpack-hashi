#!/bin/bash

# Update shares and threshold to be vars
# Add routine to update the statefulset with a lifecycle hook to unseal the vault

export VAULT_DETAILS=$(curl \
  --insecure \
  --request PUT \
  --data \
'{
  "secret_shares": 5,
  "secret_threshold": 3
}' https://127.0.0.1:8200/v1/sys/init)

export UNSEAL_KEYS=$(echo $VAULT_DETAILS | jq -r '.keys[]')

export ROOT_TOKEN=$(echo $VAULT_DETAILS | jq -r '.root_token')

INDEX=0
for unseal_key in $UNSEAL_KEYS
do
  kubectl create secret generic unseal-key-${INDEX} --from-literal=unseal_key=${unseal_key} -n vault
  kubectl set env statefulset/vault KEY_${INDEX}=${unseal_key} -n vault
  let INDEX=${INDEX}+1
done

kubectl create secret generic root-token --from-literal=root-token=${ROOT_TOKEN} -n vault
