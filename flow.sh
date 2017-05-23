
cd ~/code/devigned/hab-rails-todo
























## helpful
docker ps --filter "status=exited" | grep 'weeks ago' | awk '{print $1}' | xargs rm
docker images | awk '{print $3}' | xargs docker rmi