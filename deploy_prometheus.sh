#!/bin/sh
# Create the prom secret
oc create secret generic prom --from-file=prometheus.yml

# Create the prom-alerts secret
oc create secret generic prom-alerts --from-file=alertmanager.yml

# Create the prometheus instance
oc process -f https://raw.githubusercontent.com/openshift/origin/master/examples/prometheus/prometheus-standalone.yaml | oc apply -f -
#oc process -f prometheus-standalone.yaml | oc apply -f -

# Patch the OAuth proxy to allow Bearer token authentication
oc patch statefulset/prom --type='json' -p="[{'op': 'add', 'path': '/spec/template/spec/containers/0/args/-', 'value': '-openshift-delegate-urls={\"/\":{\"resource\":\"pods\",\"namespace\":\"\$(NAMESPACE)\",\"name\":\"prom\",\"verb\":\"get\"}}'}]"

