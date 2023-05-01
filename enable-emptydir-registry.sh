#!/bin/bash

set -eu

confirmation_string="yes-I-really-mean-it"

echo "Executing this script will configure your registry to use empty dir - this should only be used in developement"
echo "environments. Paste '${confirmation_string}' and hit return, or hit any other key to abort"
read -r input
if [ "${input}" != "${confirmation_string}" ]; then
    echo "Exiting without changes"
    exit
fi
oc patch --type=merge configs.imageregistry cluster --patch-file registry.yaml
