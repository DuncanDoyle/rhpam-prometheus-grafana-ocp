#!/bin/sh
oc new-app -f https://raw.githubusercontent.com/mrsiano/openshift-grafana/master/grafana-ocp.yaml -p NAMESPACE=order-it-hw-app-duncandoyle -p IMAGE_GF=mrsiano/openshift-grafana:5.2.0

oc expose svc grafana-ocp
