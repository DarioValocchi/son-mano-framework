#!/bin/bash

#
# This script runs the son-mano-slm plugin related tests.
#
# It starts four Docker containers:
# - RabbitMQ
# - MongoDB
# - son-mano-pluginmanager/Dockerfile
# - plugin/son-mano-service-lifecycle-management/Dockerfile
#
# It triggers the unittest execution in plugin/son-mano-service-lifecycle-management
#

# setup cleanup mechanism
#trap "set +e; docker rm -fv test.broker; docker rm -fv test.mongo; docker rm -fv test.pluginmanager; docker rm -fv test.slm" INT TERM EXIT

# ensure cleanup
set +e
docker rm -fv test.broker
docker rm -fv test.mongo
docker rm -fv test.pluginmanager
docker rm -fv test.slm

#  always abort if an error occurs
set -e

echo "test_plugin-son-mano-slm.sh"
# spin up container with broker (in daemon mode)
docker run -d -p 5672:5672 --name test.broker rabbitmq:3
# wait a bit for broker startup
while ! nc -z localhost 5672; do
sleep 1 && echo -n .; # waiting for rabbitmq
done;
# spin up container with MongoDB (in daemon mode)
docker run -d -p 27017:27017 --name test.mongo mongo
# wait a bit for db startup
while ! nc -z localhost 27017; do
sleep 1 && echo -n .; # waiting for mongo
done;
# spin up the plugin manager
docker run -d --link test.broker:broker --link test.mongo:mongo --name test.pluginmanager registry.sonata-nfv.eu:5000/pluginmanager
# wait a bit for manager startup
sleep 3
# spin up slm container and run py.test
docker run --link test.broker:broker --name test.slm registry.sonata-nfv.eu:5000/servicelifecyclemanagement py.test -v


echo "done."
