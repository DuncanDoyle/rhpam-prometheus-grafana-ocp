#!/bin/sh

# Create the config-map with required Prometheus JAR
oc create configmap rhpam-kieserver-prometheus-config-map --from-file=jmx_prometheus_javaagent-0.3.1.jar,jmx_exporter_conf-wildfly-10.yaml

# Mount ConfigMap in container
oc volume dc/rhpam-dev-kieserver --add --name=prometheus-config-volume --configmap-name=rhpam-kieserver-prometheus-config-map --mount-path=/tmp/prometheus

# Set the JBoss Modules System Packackes environment variable
oc set env dc/rhpam-dev-kieserver JAVA_OPTS_APPEND="-Dkie.mbeans=enabled -javaagent:/tmp/prometheus/jmx_prometheus_javaagent-0.3.1.jar=58080:/tmp/prometheus/jmx_exporter_conf-wildfly-10.yaml"

# Expose the 58080 Prometheus port from the container
oc patch dc/rhpam-dev-kieserver -p '{"spec":{"template":{"spec":{"containers":[{"name":"rhpam-dev-kieserver", "ports":[{"name":"prometheus", "containerPort":58080, "protocol":"TCP"}]}]}}}}'

# Add that port to service
oc patch svc/rhpam-dev-kieserver -p '{"spec":{"ports":[{"name":"prometheus", "port":58080, "protocol":"TCP", "targetPort":58080}]}}'

#Create the route
oc expose svc/rhpam-dev-kieserver --name=rhpam-dev-kieserver-prometheus --port=58080
