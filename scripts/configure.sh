#!/bin/bash

# This script is used to configure the environment for the application.

set -euo pipefail

main() {

    source .env

    # install cert-manager
    kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.8.2/cert-manager.yaml

    # wait for 30s
    echo "-- Waiting for 30s --"
    sleep 30
    echo "-- Finished Waiting, continuing --"

    # add the azure service operator helm repo
    helm repo add aso2 https://raw.githubusercontent.com/Azure/azure-service-operator/main/v2/charts

    # install the azure service operator
    helm upgrade --install --devel aso2 aso2/azure-service-operator \
        --create-namespace \
        --namespace=azureserviceoperator-system \
        --set azureSubscriptionID="$AZURE_SUBSCRIPTION_ID" \
        --set azureTenantID="$AZURE_TENANT_ID" \
        --set azureClientID="$AZURE_CLIENT_ID" \
        --set azureClientSecret="$AZURE_CLIENT_SECRET" \
        --set crdPattern='*'

    echo "--- Cluster configured ---"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
