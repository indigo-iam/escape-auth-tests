*** Settings ***

Resource    common/endpoint.robot
Resource    common/oidc-agent.robot
Resource    common/utils.robot

Variables   test/variables.yaml

Force Tags   read-permissions

*** Test cases ***

Read access granted to ESCAPE members
    ${token}   Get token   scope=-s openid
    ${endpoint}   GET SE endpoint   ${se_alias}
    ${rc}  ${output}  Execute and Check Success   gfal-ls -d ${endpoint}
    Should Contain   ${output}  ${endpoint}