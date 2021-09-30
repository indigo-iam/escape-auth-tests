*** Settings ***

Library    OperatingSystem
Library    Collections

Resource   common/oidc-agent.robot
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
    ${token}   Get token
    ${url}   Suite Base URL
    ${rc}   ${out}   Gfal mkdir Success   ${url}   -p
    Should Contain   ${out}   ${url}

Cleanup working directory
    ${token}   Get token
    ${url}   Suite Base URL
    ${rc}   ${out}   Gfal rm Success   ${url}
    Should Contain   ${out}   RMDIR