# Prep
## Run ./azure/provision.sh or you will be waiting for all of the resources to deploy during the talk

## Ensure you have run `hab studio enter` prior to the talk or it will download a docker image

## Ensure mongoid connection string is up-to-date with the current deployment
## If the not sync'd run something like the following:
az cosmosdb list-connection-strings -g habitat-k8s -n habk8s2dk1


##################
# Demo
##################
cd ~/code/devigned/hab-rails-todo

## In separate tab show the application running locally and talk about the app
bundle exec rails server
http://localhost:3000

## kick off Azure Provisioning
./azure/provision.sh

## in separate tab start habitat build
hab studio enter
build
# build will take a little while
hab pkg export docker devigned/rails-todo

## in separate tab talk about and use CLI
## overview of the Azure services talk about the ones we are using
az -h
## zoom in and search for kubernetes
az find -q kubernetes
## list the groups
az group list
## list groups as table illustrating the default of json and the optional table format
az group list -o table
## let's just select name
az group list --query "[].name"
## let's just select names starting with habitat
az group list --query "[?starts_with(name, 'habitat')] | [].name" -o tsv
## something a bit more usable
az group list --query "[].name" -o tsv

## Review the output and walk through the Azure Provisioning script
## Talk about each resource and show the resource group in the portal
## Resource group: logical container for the resources
## ACS: Kubernetes
## ACR: Private image store
## CosmosDB: MongoDB wire format + Global Scalability (show multiregion in the protal)
https://portal.azure.com


##################
## Deploy to K8s
##################

# Once we have exported the docker image, push it to private registry and deploy to K8s
docker tag devigned/rails-todo:latest habk8s2dk1.azurecr.io/rails-todo:latest
docker push habk8s2dk1.azurecr.io/rails-todo:latest

kubectl run rails-todo --image=habk8s2dk1.azurecr.io/rails-todo:latest --port 3000
kubectl get po
kubectl expose deployment rails-todo --type=LoadBalancer
# wait for the Public IP to be exposed
watch kubectl get services






# Helpful
docker ps --filter "status=exited" | grep 'weeks ago' | awk '{print $1}' | xargs rm
docker images | awk '{print $3}' | xargs docker rmi

kubectl delete service rails-todo
kubectl delete deployment rails-todo