*** Settings ***

Resource    common/curl.robot
Resource    common/endpoint.robot
Resource    common/oidc-agent.robot
Resource    common/utils.robot

Variables   test/variables.yaml

Force Tags   basic-authz


*** Test cases ***

Read access denied to IAM ESCAPE general clients
    [Tags]   gfal
    ${token}   Get token   scope=-s openid
    ${endpoint}   GET SE endpoint   ${se_alias}
    ${rc}  ${output}  Execute and Check Failure   gfal-ls -d ${endpoint}
    Should Contain   ${output}  403

Read access denied to IAM ESCAPE general clients with curl
    [Tags]   curl
    ${token}   Get token   scope=-s openid
    ${endpoint}   GET SE endpoint   ${se_alias}
    ${rc}   ${out}   Curl Error   ${url}
    Should Contain   ${out}   403

Read access granted to storage.read:/ scope
    [Tags]   gfal
    ${token}   Get token   scope=-s storage.read:/ -s openid
    ${endpoint}   GET SE endpoint   ${se_alias}
    ${rc}  ${output}  Execute and Check Success   gfal-ls -d ${endpoint}
    Should Contain   ${output}  ${endpoint}

Read access granted to /escape group
    [Tags]   gfal
    ${token}   Get token   scope=-s wlcg.groups:/escape -s openid
    ${endpoint}   GET SE endpoint   ${se_alias}
    ${rc}  ${output}  Execute and Check Success   gfal-ls -d ${endpoint}
    Should Contain   ${output}  ${endpoint}
