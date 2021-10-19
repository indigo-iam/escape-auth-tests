*** Settings ***

Resource    common/gfal.robot
Resource    common/endpoint.robot
Resource    common/oidc-agent.robot
Resource    common/utils.robot
Resource    common/voms.robot

Variables   test/variables.yaml

Force Tags   group-based-authz   step-0

Suite Setup   Set suite path and get token with default groups scope
Suite Teardown   Remove Environment Variable   BEARER_TOKEN


*** Test cases ***

List directory allowed to default groups
    ${rc}   ${out}   Gfal Read Success   ${url}   -d
    Should Contain   ${out}   ${url}

Read file allowed to default groups
    ${rc}   ${out}   Gfal cat Success  ${url}/${file}
    Should Contain   ${out}   ${file.content}

Write file allowed to default groups
    ${rc}   ${out}   Gfal copy Success   /etc/services   ${url}
    Should Contain   ${out}   ${url}/services

Delete file allowed to default groups
    ${rc}   ${out}   Gfal rm Success   ${url}/${file}
    Should Contain   ${out}   DELETED

Create directory allowed to default groups
    ${rc}   ${out}   Gfal mkdir Success   ${url}
    Should Contain   ${out}   ${url}

Delete directory allowed to default groups
    ${rc}   ${out}   Gfal rm Success   ${url}   -r
    Should Contain   ${out}   RMDIR


*** Keywords ***

Set suite path and get token with default groups scope
    ${url}   ${file}   Upload file in sub-suite Directory with VOMS proxy   group-based-full-access   ${file.content}
    Set Suite Variable   ${url}
    Set Suite Variable   ${file}
    Delete VOMS proxy
    ${token}   Get token   scope=-s wlcg.groups -s openid

*** Variables ***

${file.content}   escape-suite-content-file