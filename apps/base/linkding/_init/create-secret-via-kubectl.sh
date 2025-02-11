#!/bin/bash
set -E
set -o pipefail
set -u

SECRET_NAME=linkding-secrets
USERNAME=superuser
PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)

if kubectl get secret "$SECRET_NAME" > /dev/null 2>&1; then
    echo "Secret '$SECRET_NAME' already exists. Exiting successfully."
    exit 0
fi


until kubectl get secret/"$SECRET_NAME" ; do

  echo "INFO: initially creating secret for LinkDing"

  kubectl create secret generic "$SECRET_NAME" \
    --from-literal="LD_SUPERUSER_NAME"="$USERNAME"\
    --from-literal="LD_SUPERUSER_PASSWORD"="$PASSWORD" \
    --field-manager "(basename $0)"

  kubectl annotate secret "$SECRET_NAME" \
    'homelab/managed-by'="$(basename "$0")"

  sleep 1

done