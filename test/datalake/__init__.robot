*** Settings ***

Library    OperatingSystem
Library    Collections

Resource   common/voms.robot
Resource   common/endpoint.robot
Resource   common/utils.robot
Resource   common/gfal.robot

Variables   test/variables.yaml

Suite Setup      Create working directory
Suite Teardown   Cleanup working directory


*** Keywords ***

Create working directory
    ${SUITE_UUID}   Generate UUID
    Set Global Variable   ${SUITE_UUID}   ${suite_uuid}
    ${NOW}   Get NOW Time
    Set Global Variable   ${NOW}
    Create VOMS proxy
    ${url}   Suite Base URL
    ${rc}   ${out}   Gfal mkdir Success   ${url}
    Should Contain   ${out}   ${url}
    ${file}   Get File
    ${rc}   ${out}   Gfal copy Success   ${file}   ${url}
    ${file.basename}   Get File Basename
    Should Contain   ${out}   ${url}/${file.basename}
    Delete VOMS proxy

Cleanup working directory
    Create VOMS proxy
    ${url}   Suite Base URL
    ${rc}   ${out}   Gfal rm Success   ${url}  -r
    Should Contain   ${out}   RMDIR
    Delete VOMS proxy