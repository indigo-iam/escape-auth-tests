*** Settings ***

Resource    common/gfal.robot
Resource    common/endpoint.robot
Resource    common/oidc-agent.robot
Resource    common/utils.robot
Resource    common/voms.robot

Variables   test/variables.yaml

Force Tags   group-based-authz   step-0

Test Timeout  15

Suite Setup   Set Child Suite Environment
Suite Teardown   Remove Environment Variable   BEARER_TOKEN


*** Test cases ***

Show directory content allowed to default groups
    ${rc}   ${out}   Gfal Read Success  ${url}
    Should Contain   ${out}  ${file.basename}

Read file allowed to default groups
    ${rc}   ${out}   Gfal cat Success  ${url}/${file.basename}
    Should Contain   ${out}   ${file.content}

Write file allowed to default groups
    ${rc}   ${out}   Gfal copy Success   /etc/services   ${url}   -f
    Should Contain   ${out}   ${url}/services

Delete file allowed to default groups
    ${rc}   ${out}   Gfal rm Success   ${url}/${file.basename}
    Should Contain   ${out}   DELETED

Create directory allowed to default groups
    ${uuid}   Generate UUID
    ${rc}   ${out}   Gfal mkdir Success   ${url}/${uuid}
    Should Contain   ${out}   ${url}

Delete directory allowed to default groups
    ${rc}   ${out}   Gfal rm Success   ${url}   -r
    Should Contain   ${out}   RMDIR


*** Variables ***

${file.content}   escape-suite-content-file


*** Keywords ***

Set Child Suite Environment
    Get Fixture Authorization Method
    Set Suite Environment   group-based-full-access   ${file.content}
    Cleanup Authorization Environment
    Get token   scope=-s wlcg.groups -s openid