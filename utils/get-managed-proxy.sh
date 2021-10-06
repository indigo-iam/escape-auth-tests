#!/bin/bash
set -e

IAM_PROXYCERT_ENDPOINT=${IAM_PROXYCERT_ENDPOINT:-https://iam-escape.cloud.cnaf.infn.it/iam/proxycert}
PROXY_CERT_LIFETIME_SECS=${PROXY_CERT_LIFETIME_SECS:-3600}
CLIENT_ID=${CLIENT_ID:-client_id}
CLIENT_SECRET=${CLIENT_SECRET:-secret}

bt_temp=$(mktemp)
chmod 600 ${bt_temp}

oidc-token -s proxy:generate escape-monitoring > ${bt_temp} 2>&1

BT=$(cat ${bt_temp})

if [[ ${BT} =~ ^Could* ]]; then
    echo "Error getting proxy:generate bearer token!"
    cat ${bt_temp}
    exit 1
fi

proxyresponse=$(mktemp)
chmod 600 ${proxyresponse}

set +e

curl -s --fail \
        -XPOST -H "Authorization: Bearer ${BT}" \
        -d client_id=${CLIENT_ID} \
        -d client_secret=${CLIENT_SECRET} \
        -d lifetimeSecs=${PROXY_CERT_LIFETIME_SECS} \
        ${IAM_PROXYCERT_ENDPOINT} > ${proxyresponse}

if [ $? -ne 0 ]; then
    echo "Error requesting proxy certificate"
    cat ${proxyresponse}
    exit 1
fi

set -e 

identity=$(jq -r .identity ${proxyresponse})
proxy_file=/tmp/x509up_ts

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
echo 
echo "The output of 'voms-proxy-info -all' on the proxy is:"

voms-proxy-info -all
