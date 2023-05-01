#!/bin/bash
#
set -eux

DRIVER_URL="https://downloadmirror.intel.com/772530/ice-1.11.14.tar.gz"
RELEASE_VER="8.6"

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
OUTPUT_DIR="${DIR}/_output"

deps="jinja2"
for dep in ${deps}; do
    if ! command -v "${dep}" &> /dev/null
    then
        echo "Missing dependency ${dep}"
        exit 1
    fi
done

mkdir -p "${OUTPUT_DIR}"

if [ "$(oc get secret etc-pki-entitlement -o name | wc -l)" -eq 0 ]; then
    echo "Creating etc-pki-entitlement secret"
    tmp_dir=$(mktemp -d)
    pushd "${tmp_dir}"
    oc extract secret/etc-pki-entitlement -n openshift-config-managed
    oc create secret generic etc-pki-entitlement --from-file=entitlement-key.pem --from-file=entitlement.pem
    popd
fi

if [ "$(oc get is ice -o name | wc -l)" -eq 0 ]; then
    echo "Creating ice imagestream"
    oc create is ice
fi

echo "Converting .j2 template to .yaml file"
jinja2 "${DIR}/buildconfig.j2" -D RELEASE_VER="${RELEASE_VER}" -D DRIVER_URL="${DRIVER_URL}" > \
    "${OUTPUT_DIR}/buildconfig.yaml"

echo "Deleting buildconfig if one exists"
oc delete -f "${OUTPUT_DIR}/buildconfig.yaml" || true

echo "Creating buildconfig"
oc apply -f "${OUTPUT_DIR}/buildconfig.yaml"
