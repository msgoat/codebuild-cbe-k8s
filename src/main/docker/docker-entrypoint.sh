#!/bin/sh

#echo "setting kubectl context to [${K8S_CONTEXT_NAME}]"
#kubectl config use-context ${K8S_CONTEXT_NAME}

exec "$@"
