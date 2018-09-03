#!/bin/sh

prometheus_namespace="order-it-hw-app-duncandoyle"
sa_reader=prom

payload="$( mktemp )"
cat <<EOF >"${payload}"
{
"name": "prometheus-ddoyle",
"type": "prometheus",
"typeLogoUrl": "",
"access": "proxy",
"url": "https://$( oc get route prom -n "${prometheus_namespace}" -o jsonpath='{.spec.host}' )",
"basicAuth": false,
"withCredentials": false,
"jsonData": {
    "tlsSkipVerify":true
},
"secureJsonData": {
    "httpHeaderName1":"Authorization",
    "httpHeaderValue1":"Bearer $( oc sa get-token "${sa_reader}" -n "${prometheus_namespace}" )"
}
}
EOF

# setup grafana data source
grafana_host="${protocol}$( oc get route grafana-ocp -o jsonpath='{.spec.host}' )"
curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/datasources" -X POST -d "@${payload}"
