*** Settings ***

Resource    common/gfal.robot
Resource    common/endpoint.robot
Resource    common/oidc-agent.robot
Resource    common/utils.robot
Resource    common/voms.robot

Variables   test/variables.yaml

Force Tags   group-based-authz   step-0

Suite Setup   Run Keywords   
              ...   Set Authorization Method
              ...   AND   Set Suite Environment   group-based-full-access   ${file.content}
              ...   AND   Cleanup Authorization Environment
              ...   AND   Get token   scope=-s wlcg.groups -s openid
Suite Teardown   Remove Environment Variable   BEARER_TOKEN


*** Test cases ***

List directory allowed to default groups
    ${rc}   ${out}   Gfal Read Success   ${url}   -d
    Should Contain   ${out}   ${url}

Read file allowed to default groups
    ${rc}   ${out}   Gfal cat Success  ${url}/${file.basename}
    Should Contain   ${out}   ${file.content}

Write file allowed to default groups
    ${rc}   ${out}   Gfal copy Success   /etc/services   ${url}
    Should Contain   ${out}   ${url}/services

Delete file allowed to default groups
    ${rc}   ${out}   Gfal rm Success   ${url}/${file.basename}
    Should Contain   ${out}   DELETED

Create directory allowed to default groups
    ${rc}   ${out}   Gfal mkdir Success   ${url}
    Should Contain   ${out}   ${url}

Delete directory allowed to default groups
    ${rc}   ${out}   Gfal rm Success   ${url}   -r
    Should Contain   ${out}   RMDIR


*** Variables ***

${file.content}   escape-suite-content-file