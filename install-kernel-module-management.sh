#!/bin/bash

set -eux

cat <<'EOF' | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-kmm
EOF

cat <<'EOF' | oc apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: kernel-module-management
  namespace: openshift-kmm
EOF

cat <<'EOF' | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kernel-module-management
  namespace: openshift-kmm
spec:
  channel: release-1.0
  installPlanApproval: Automatic
  name: kernel-module-management
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: kernel-module-management.v1.0.0
EOF

rollout_complete=false
for i in 1..20; do
    if oc rollout status -n openshift-kmm deployments.apps kmm-operator-controller-manager; then
        rollout_complete=true
        break
    fi
    sleep 5
done

if [ "${rollout_complete}" != "true" ]; then
    echo "Rollout failed"
    exit 1
fi
