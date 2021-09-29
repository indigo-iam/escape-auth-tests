*** Settings ***

Library    OperatingSystem
Library    Collections

Resource   common/oidc-agent.robot
Resource   common/endpoint.robot
Resource   common/utils.robot

Variables   test/variables.yaml

Suite Setup   Create working directory
Suite Teardown   Cleanup working directory


*** Keywords ***

Create working directory
    ${SUITE_UUID}   Generate UUID
    Set Global Variable   ${SUITE_UUID}   ${suite_uuid}
    ${token}   Get token
    ${url}   Suite Base URL
    ${cmd}   Set Variable   gfal-mkdir -p ${url}
    ${rc}   ${output}   Execute and Check Success   ${cmd}

Cleanup working directory
    ${token}   Get token
    ${url}   Suite Base URL
    ${cmd}   Set Variable   gfal-rm -r ${url}
    ${rc}   ${output}   Execute and Check Success   ${cmd}
    Should Contain   ${output}   RMDIR