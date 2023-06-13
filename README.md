# Service Operator Sample

This sample demonstrates how to use the Service Operator to create resources using Helm charts.

## Prerequisites

[Service Operator prerequisites](https://azure.github.io/azure-service-operator/#prerequisites)

## Creating service principal

The service principal needed to provision resources needs access to an Azure subscription.

There are multiple ways on creating the service prinicipal. The chosen way for this guide is to use the Azure CLI.

1. Run `az login` to login to Azure
1. Run `az account list` to list all subscriptions
1. Run `az account set --subscription <subscriptionId>` to set the subscription to use
1. Run `az account show -o json` and store values for `id` and `tenantId` in environment variables `AZURE_SUBSCRIPTION_ID` and `AZURE_TENANT_ID` respectively (use the .env file)
1. Run `source .env` to load the environment variables
1. Run `az ad sp create-for-rbac --name azure-service-operator --role contributor --scopes subscriptions/<subscriptionId>` to create the service principal

    >info: The name of the service principal can be changed, only the id and password are important.

1. Store the values for `AZURE_CLIENT_ID` and `AZURE_CLIENT_SECRET` in the .env file as well

The service principal is now created and can be used to provision resources.

## Configuring the cluster

The cluster needs to be configured to use the Service Operator. This is done by installing the Service Operator Helm chart. Before installing the chart, the cert manager needs to be installed to handle the certificates:

1. Install the cert-manager: `kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.8.2/cert-manager.yaml`
1. Wait until all pods are running when running: `kubectl get pods -n cert-manager -w`
1. Run `helm repo add aso2 https://raw.githubusercontent.com/Azure/azure-service-operator/main/v2/charts` to add the Service Operator Helm repository
1. Run `source .env` to load the environment variables set in the previous step
1. Run:

    ```bash
    helm upgrade --install --devel aso2 aso2/azure-service-operator \
        --create-namespace \
        --namespace=azureserviceoperator-system \
        --set azureSubscriptionID=$AZURE_SUBSCRIPTION_ID \
        --set azureTenantID=$AZURE_TENANT_ID \
        --set azureClientID=$AZURE_CLIENT_ID \
        --set azureClientSecret=$AZURE_CLIENT_SECRET \
        --set crdPattern='*'
    ```

1. Run `kubectl apply -f ./manifests/resourcegroup.yaml` to create a resource group
1. Check the status of the resource group by running `kubectl get resourcegroups`

## Links

- [Service Operator documentation](https://azure.github.io/azure-service-operator/)
- [Service Operator repository](https://github.com/Azure/azure-service-operator)
