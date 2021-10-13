*** Settings ***

Resource    common/gfal.robot
Resource    common/endpoint.robot
Resource    common/oidc-agent.robot
Resource    common/utils.robot

Variables   test/variables.yaml

Force Tags   group-based-authz   step-1


*** Test cases ***

Read access denied to IAM ESCAPE general clients
    ${token}   Get token   scope=-s openid
    ${uuid}   Generate UUID
    ${url}   SE URL   robot-test-${uuid}
    ${rc}   ${out}   Gfal Read Error   ${url}
    Should Contain   ${out}  403

Read access granted to default groups
    ${token}   Get token   scope=-s wlcg.groups -s openid
    ${uuid}   Generate UUID
    ${url}   SE URL   robot-test-${uuid}
    ${rc}   ${out}  Gfal Read Error   ${url}
    Should Contain   ${out}  404

Write access denied to default groups
    ${token}   Get token   scope=-s wlcg.groups -s openid
    ${uuid}   Generate UUID
    ${url}   SE URL   write-access-denied-${uuid}
    ${rc}   ${out}   Gfal mkdir Error   ${url}
    Should Contain   ${out}  403

Full access granted to /escape/data-manager group
    ${token}   Get token   scope=-s wlcg.groups:/escape/data-manager -s openid
    ${uuid}   Generate UUID
    ${url}   SE URL   full-access-${uuid}
    ${rc}   ${out}   Gfal Read Error   ${url}
    Should Contain   ${out}   404
    ${rc}   ${out}   Gfal mkdir Success   ${url}
    Should Contain   ${out}   ${url}
    ${rc}   ${out}   Gfal rm Success   ${url}  -r
    Should Contain   ${out}   RMDIR