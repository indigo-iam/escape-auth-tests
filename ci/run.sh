#!/bin/bash
set -e

IAM_PROXYCERT_ENDPOINT=${IAM_PROXYCERT_ENDPOINT:-https://iam-escape.cloud.cnaf.infn.it/iam/proxycert}
PROXY_CERT_LIFETIME_SECS=${PROXY_CERT_LIFETIME_SECS:-3600}

REPORTS_DIR_BASE=${REPORTS_DIR_BASE:-$(pwd)/reports}
FAIL_ON_TESTS_FAILURE=${FAIL_ON_TESTS_FAILURE:-}

now=$(date +%Y%m%d_%H%M%S)
reports_dir=${REPORTS_DIR_BASE}/reports/${now}

eval $(oidc-agent --no-autoload)

oidc-add --pw-cmd='echo $OIDC_AGENT_SECRET' escape-monitoring
oidc-add --pw-cmd='echo $OIDC_AGENT_CMS_SECRET' escape-auth-tests-cms

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

REPORTS_DIR=${reports_dir}/iam ./run-testsuite.sh

ec_iam=$?

if [ -z "${SKIP_DATALAKE_TESTSUITE}" ]; then

  # remove proxy if you don't need it in the next test suite
  rm -rf ${proxy_file}
  unset X509_USER_PROXY

  echo -e "\nLooking for new RSEs from CRIC..."

  ./ci/assets/fetch-rses-from-cric.sh > /dev/null 2>&1

  if [ $? -eq 0 ]; then
      echo -e "Already up to date.\n"
  else
      echo    "WARNING: your 'variables.yaml' file is not up to date."
      echo -e "Please add missing datalake endpoints.\n"
  fi

  endpoints=$(cat test/variables.yaml | shyaml keys endpoints)

  ec_dl=0

  for e in ${endpoints}; do
    REPORTS_DIR=${reports_dir}/${e} ./run-testsuite.sh ${e}

    if [ $? -ne 0 ]; then
        (( ec_dl++ ))
    fi
  done

fi

set -e

ec=$(( ${ec_dl} + ${ec_iam} ))

if [ ${ec} -ne 0 ]; then
    echo "There are test failures"
fi

reports=$(find ${reports_dir} -name output.xml)

echo "Creating final report..."
rebot --nostatusrc \
  --report ${reports_dir}/joint-report.html \
  --log ${reports_dir}/joint-log.html \
  --ReportTitle "ESCAPE datalake tests ${now}" \
  --name "ESCAPE datalake tests" \
  ${reports}

echo "Done!"

if [ -n "${FAIL_ON_TESTS_FAILURES}" ]; then
  exit ${ec}
else
  exit 0
fi
