#!/bin/sh

set -eou pipefail

echo -e "************************************************"
echo -e "\nlogin to azure"
echo -e "************************************************"
az login

echo -e "************************************************"
echo -e "\ncreating new resource-group crossplane"
echo -e "************************************************"
az group create -n crossplane

sleep 120

echo -e "************************************************"
echo -e "\ncreating new aks crossplane"
echo -e "************************************************"
az aks create -n crossplane -g crossplane --node-vm-size Standard_DS8_v3 --node-osdisk-type Managed

sleep 300

echo -e "************************************************"
echo -e "\ncreating new service principal crossplane"
echo -e "************************************************"
az ad sp create-for-rbac \
--sdk-auth \
--role Owner \
--scopes /subscriptions/<SUB_ID > creds.json

echo -e "************************************************"
echo -e "\ninstall upbound"
echo -e "************************************************"
curl -sL "https://cli.upbound.io" | sh

up uxp install

kubectl apply -f provider.yaml

kubectl create secret \
generic azure-secret \
-n upbound-system \
--from-file=creds=creds.json --dry-run=client -o yaml > secret.yaml

kubectl apply -f provider-config.yaml

kubectl apply -f rg.yaml
