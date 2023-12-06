#!/bin/bash

# Define variables
CLUSTER_NAME="test--aks"
RESOURCE_GROUP="resource-test"
SUBSCRIPTION="Azure for Students"

# # Run the command
# az aks update \
#   --name $CLUSTER_NAME \
#   --resource-group $RESOURCE_GROUP \
#   --subscription "$SUBSCRIPTION" \
#   --enable-workload-identity \
#   --enable-oidc-issuer

issuerUrl=$(az aks show \
  --name $CLUSTER_NAME \
  --resource-group $RESOURCE_GROUP \
  --subscription "$SUBSCRIPTION" \
  --query oidcIssuerProfile.issuerUrl \
  --output tsv)

#   echo "Issuer URL: $issuerUrl"

az identity federated-credential update \
  --identity-name test--aks-agentpool \
  --name external-dns-credentials \
  --resource-group "MC_resource-test_test--aks_westus3" \
  --subscription "$SUBSCRIPTION" \
  --issuer $issuerUrl \
  --subject "system:serviceaccount:external-dns-system:external-dns-dev" 