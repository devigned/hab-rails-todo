##################
# Prep
##################

# Assumed your shell is in the root of the repository
# Run ./azure/provision.sh or you will be waiting for all of the resources to deploy during the talk
# Ensure you have run `hab studio enter` prior to the talk or it will download a docker image


##################
# Demo
##################

# kick off Azure Provisioning
./azure/provision.sh

# In separate tab show the application running locally and talk about the app
bundle exec rails server
http://localhost:3000

# in separate tab start habitat build
# cosmosdb_name=$(az cosmosdb list -g habitat-k8s --query "[?starts_with(name, 'habk8s')] | [0].name" -o tsv)
# conn_string=$(az cosmosdb list-connection-strings -g habitat-k8s -n ${cosmosdb_name} --query "connectionStrings[0].connectionString" -o tsv | sed -e 's/[\/&]/\\&/g')
# sed "s/{{cosmosdb_connection_string}}/${conn_string}/g" habitat/sample_default.toml > habitat/default.toml
hab studio enter
build
# build will take a little while
hab pkg export docker devigned/rails-todo
# exit hab

# run the docker image to test it out
docker run -it -p 3000:3000 devigned/rails-todo

# Review the output and walk through the Azure Provisioning script
# Talk about each resource and show the resource group in the portal
# Resource group: logical container for the resources
# ACS: Kubernetes
# ACR: Private image store
# CosmosDB: MongoDB wire format + Global Scalability (show multiregion in the protal)
https://portal.azure.com


##################
## Deploy to K8s
##################
registry=$(az acr list -g habitat-k8s --query "[?starts_with(name, 'habk8s')] | [0].loginServer" -o tsv)
# Once we have exported the docker image, push it to private registry and deploy to K8s
docker tag devigned/rails-todo:latest ${registry}/rails-todo:latest
docker push ${registry}/rails-todo:latest

kubectl run rails-todo --image=${registry}/rails-todo:latest --port 3000
kubectl get po
kubectl expose deployment rails-todo --port=80 --target-port=3000 --type=LoadBalancer
# wait for the Public IP to be exposed
watch kubectl get services

# scale up to 5 instances
kubectl scale --replicas=5 deployments/rails-todo
kubectl get po


##################
# End Demo
##################


# Helpful
docker ps --filter "status=exited" | grep 'weeks ago' | awk '{print $1}' | xargs docker rm
docker images | awk '{print $3}' | xargs docker rmi

kubectl delete service rails-todo
kubectl delete deployment rails-todo