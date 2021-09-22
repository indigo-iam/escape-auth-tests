#!/bin/bash
#
# Copyright (c) Istituto Nazionale di Fisica Nucleare, 2018.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
set -e

REPORTS_DIR=${REPORTS_DIR:-reports/$1}

ROBOT_ARGS=${ROBOT_ARGS:-}

DEFAULT_ARGS="--pythonpath .:common -d ${REPORTS_DIR}"

ARGS=${DEFAULT_ARGS}

if [ -n "${ROBOT_ARGS}" ]; then
  ARGS="${ARGS} ${ROBOT_ARGS}"
fi

alias python='python3'

if [ $# -eq 0 ]; then
  robot ${ARGS} test/iam
elif [ $# -eq 1 ]; then
  echo "Datalake test suite run against: $1"
  robot ${ARGS} --variable se_alias:$1 --name $1 -G $1 test/datalake
else
  echo "Invalid number of arguments"
  exit 1
fi
 