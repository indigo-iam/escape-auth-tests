#!/bin/bash
set -e

IAM_PROXYCERT_ENDPOINT=${IAM_PROXYCERT_ENDPOINT:-https://iam-escape.cloud.cnaf.infn.it/iam/proxycert}
PROXY_CERT_LIFETIME_SECS=${PROXY_CERT_LIFETIME_SECS:-3600}

REPORTS_DIR_BASE=${REPORTS_DIR_BASE:-$(pwd)/reports}

now=$(date +%Y%m%d_%H%M%S)
reports_dir=${REPORTS_DIR_BASE}/reports/${now}

eval $(oidc-agent --no-autoload)
oidc-add --pw-cmd='echo $OIDC_AGENT_SECRET' escape-monitoring

client_config=$(mktemp)
chmod 600 ${client_config}

oidc-add --pw-cmd='echo $OIDC_AGENT_SECRET' -p escape-monitoring > ${client_config}
client_id=$(jq -r .client_id ${client_config})
client_secret=$(jq -r .client_secret ${client_config})
rm -f ${client_config}

BT=$(oidc-token -s proxy:generate escape-monitoring)
proxyresponse=$(mktemp)
chmod 600 ${proxyresponse}

set +e

curl -s -XPOST -H "Authorization: Bearer ${BT}" \
        -d client_id=${client_id} \
        -d client_secret=${client_secret} \
        -d lifetimeSecs=${PROXY_CERT_LIFETIME_SECS} \
        ${IAM_PROXYCERT_ENDPOINT} > ${proxyresponse}

if [ $? -ne 0 ]; then
    echo "Error requesting proxy certificate"
    cat ${proxyresponse}
    exit 1
fi

set -e 

identity=$(jq -r .identity ${proxyresponse})
proxy_file=$(echo /tmp/x509up_u$(id -u))

touch ${proxy_file}
chmod 600 ${proxy_file}

jq -r .certificate_chain ${proxyresponse} > ${proxy_file}
rm -f ${proxyresponse}

export X509_USER_PROXY=${proxy_file}

echo
echo "A proxy certificate for identity:"
echo
echo ${identity}
echo
echo "has been saved to:"
echo
echo ${proxy_file}

voms-proxy-info -all

if [ -n "${RUN_DEBUG}" ]; then
  set -x
fi

set +e

REPORTS_DIR=${reports_dir} ./run-testsuite.sh 

ec=$?

if [ ${ec} -ne 0 ]; then
    echo "There are test failures"
fi

rm -rf ${proxy_file}
exit ${ec}
