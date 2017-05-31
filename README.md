# Demo Habitat + Kubernetes + CosmosDB + Rails + Ember Todo App
This demo will walk you through using Azure Container Service in Kubernetes mode
to deploy a Habitat packaged Rails / Ember application. The Rails application uses
MongoDB locally and CosmosDB in production.

## Prereqs
- Azure CLI
- Bash'y environment

## Structure of the Repository
### [Azure Provisioning](./azure)
This folder contains provision.sh, which will provision all of the Azure infrastructure needed.
This builds the following resources:
- Resource group to logically group resources
- Azure Container Service running in Kubernetes mode
- Azure Container Registry for private image hosting
- Azure CosmosDB running in MongoDB mode

The provisioning script will also install `kubectl` if it is not already on the path.

### [Habitat App Packaging](./habitat)
This folder contains all of the Habitat configuration and plans for packaging the Rails application.

### [Rails Application](./src)
This folder contains all of the Rails source code. The ember todo list application served from this 
Rails app has been pre-built and is included in the public directory. You can find a version of the 
Ember todo application here: https://github.com/devigned/level1/tree/master/api-ruby/todo-ember.

### [Demo Script](./demo.sh)
The `demo.sh` script contains the rough instructions for running the demo. I'm sure there are some missing
pieces, but it's pretty close.
