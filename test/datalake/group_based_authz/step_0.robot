*** Settings ***

Resource    common/gfal.robot
Resource    common/endpoint.robot
Resource    common/oidc-agent.robot
Resource    common/utils.robot

Variables   test/variables.yaml

Force Tags   group-based-authz   step-0


*** Test cases ***

Full access granted to default groups
    ${token}   Get token   scope=-s wlcg.groups -s openid
    ${uuid}   Generate UUID
    ${url}   SE URL   full-access-${uuid}
    ${rc}   ${out}   Gfal Read Error   ${url}
    Should Contain   ${out}   404
    ${rc}   ${out}   Gfal mkdir Success   ${url}
    Should Contain   ${out}   ${url}
    ${rc}   ${out}   Gfal copy Success   /etc/services   ${url}
    Should Contain   ${out}   ${url}/services
    ${rc}   ${out}   Gfal rm Success   ${url}/services
    Should Contain   ${out}   DELETED
    ${rc}   ${out}   Gfal rm Success   ${url}   -r
    Should Contain   ${out}   RMDIR