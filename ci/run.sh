#!/bin/bash
set -e

REPORTS_DIR_BASE=${REPORTS_DIR_BASE:-$(pwd)/reports}

if [ -n "${RUN_DEBUG}" ]; then
  set -x
fi

now=$(date +%Y%m%d_%H%M%S)
reports_dir=${REPORTS_DIR_BASE}/reports/${now}

eval $(oidc-agent --no-autoload)
oidc-add --pw-cmd='echo $OIDC_AGENT_SECRET' escape-monitoring

REPORTS_DIR=${reports_dir} ./run-testsuite.sh 
