*** Settings ***

Library    OperatingSystem
Library    Collections

Resource   common/voms.robot
Resource   common/endpoint.robot
Resource   common/utils.robot
Resource   common/gfal.robot

Variables   test/variables.yaml

Suite Setup   Set Parent Suite Environment
Suite Teardown   Cleanup Parent Suite Environment


*** Keywords ***

Set Test Suite Global Variables
    ${SUITE_UUID}   Generate UUID
    Set Global Variable   ${SUITE_UUID}   ${suite_uuid}
    ${NOW}   Get NOW Time
    Set Global Variable   ${NOW}
    ${url}   Suite Base URL
    Set Global Variable   ${url}

Create Working Directory
    ${rc}   ${out}   Gfal mkdir Success   ${url}
    Should Contain   ${out}   ${url}
    ${local_file}   Create Random Temporary File   escape-test-content
    ${file_basename}   Run   basename ${local_file}
    ${rc}   ${out}   Gfal copy Success   ${local_file}   ${url}
    Should Contain   ${out}   ${url}/${file_basename}
    Remove Temporary file   ${file_basename}

Cleanup Working Directory
    ${url}   Suite Base URL
    ${rc}   ${out}   Gfal rm Success   ${url}  -r
    Should Contain   ${out}   RMDIR

Set Parent Suite Environment
    Set Test Suite Global Variables
    Set Authorization Method
    Get Authorization Method
    Create Working Directory
    Cleanup Authorization Environment

Cleanup Parent Suite Environment
    Remove Environment Variable   BEARER_TOKEN
    Get Authorization Method
    Cleanup Working Directory
    Cleanup Authorization Environment