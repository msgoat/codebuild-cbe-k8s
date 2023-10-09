#!/bin/sh

echo "### starting docker daemon bypassing systemd with options [${DOCKERD_OPTIONS}]"
dockerd ${DOCKERD_OPTIONS} &
sleep 3

echo "### display information about current docker installation with docker daemon listening to [${DOCKER_HOST}]"
docker info

echo "### display information about current docker-compose installation"
docker-compose version

exec "$@"