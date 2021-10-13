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
    ${rc}   ${out}   Create VOMS proxy
    Should Contain   ${out}   Created proxy in
    ${url}   Suite Base URL
    ${rc}   ${out}   Gfal mkdir Success   ${url}
    Should Contain   ${out}   ${url}
    ${file}   ${file.path}   ${file.basename}   Get File Location From Variable
    ${rc}   ${out}   Gfal copy Success   ${file}   ${url}
    Should Contain   ${out}   ${url}/${file.basename}
    Delete VOMS proxy

Cleanup working directory
    Remove Environment Variable   BEARER_TOKEN
    ${rc}   ${out}   Create VOMS proxy
    Should Contain   ${out}   Created proxy in
    ${url}   Suite Base URL
    ${rc}   ${out}   Gfal rm Success   ${url}  -r
    Should Contain   ${out}   RMDIR
    Delete VOMS proxy