#!/usr/bin/env bash

set -euf -o pipefail

group="habitat-k8s"
vm_name="habitat-dev"
cluster_name="k8s-cluster"
name_prefix="habk8s"
new_name=$(echo $(mktemp -u ${name_prefix}XXXX) | tr '[:upper:]' '[:lower:]')
location='westus'

if [[ -z $(az account list -o tsv 2>/dev/null ) ]]; then
    az login -o table
fi
echo ""

if [[ ! -f ~/.ssh/id_rsa ]]; then
    echo "Generating ssh keys to use for setting up the Kubernetes cluster"
    ssh-keygen -f ~/.ssh/id_rsa -t rsa -N '' 1>/dev/null
else
    echo "Using ~/.ssh/id_rsa to authenticate with the Kubernetes cluster"
fi

cosmosdb_name=$(az cosmosdb list -g ${group} --query "[?starts_with(name, '${name_prefix}')] | [0].name" -o tsv)
if [[ -z "${cosmosdb_name}" ]]; then
    echo "Create CosmosDB instance named ${new_name} with MongoDB wire format to be used by Rails Mongoid"
    az cosmosdb create -g ${group} -n "${new_name}" --kind MongoDB 1>/dev/null
else
    echo "Using the already provisioned CosmosDB named ${cosmosdb_name}"
fi

if [[ -z $(az acs show -g ${group} -n ${cluster_name} -o tsv) ]]; then
    echo "Creating Resource group named ${group}"
    az group create -n ${group} -l ${location} 1>/dev/null

    echo "Creating Azure Kubernetes cluster named ${cluster_name} in group ${group}"
    az acs create -g ${group} -n ${cluster_name} --orchestrator-type Kubernetes \
        --agent-vm-size Standard_DS2_v2 --agent-count 2 1>/dev/null
else
    echo "Using Azure Kubernetes cluster named ${cluster_name} in group ${group}"
fi

registry=$(az acr show -g ${group} -n ${new_name} --query "loginServer" -o tsv)
if [[ -z ${registry} ]]; then
    echo "Creating Azure Container Registry named ${new_name} in group ${group}"
    registry=$(az acr create -g ${group} -n ${new_name} -l ${location} \
                --admin-enabled true --query "loginServer" -o tsv)
else
    echo "Using Azure Container Registry named ${new_name} in group ${group}"
fi
echo ""

read pw user_name <<< "$(az acr credential show -g ${group} -n ${new_name} -o tsv)"
echo "Logging Docker into ${registry} with user: ${user_name}"
sudo docker login ${registry} -u ${user_name} -p ${pw}
echo "To push to your docker registry run 'docker push ${registry}/myImage'"
echo ""

if [[ ! -d ${HOME}.kube/config ]]; then
    echo "Creating ${HOME}.kube/config w/ credentials for managing ${cluster_name}"
    az acs kubernetes get-credentials -g ${group} -n ${cluster_name} 1>/dev/null
else
    echo "Using ${HOME}.kube/config w/ credentials for managing ${cluster_name}"
fi

echo "Your Kubernetes cluster has been deployed and you are ready to connect."
echo "To connect to the cluster run 'kubectl cluster-info'"
echo ""