*** Settings ***

Resource    common/gfal.robot
Resource    common/endpoint.robot
Resource    common/oidc-agent.robot
Resource    common/utils.robot

Variables   test/variables.yaml

Force Tags   basic-authz


*** Test cases ***

Read access denied to IAM ESCAPE general clients
    ${token}   Get token   scope=-s openid
    ${uuid}   Generate UUID
    ${url}   SE URL   robot-test-${uuid}
    ${rc}   ${out}   Gfal Read Error   ${url}
    Should Contain   ${out}  403

Read access granted to /escape group
    ${token}   Get token   scope=-s wlcg.groups:/escape
    ${uuid}   Generate UUID
    ${url}   SE URL   robot-test-${uuid}
    ${rc}   ${out}  Gfal Read Error   ${url}
    Should Contain   ${out}  404

Write access denied to /escape group
    ${token}   Get token   scope=-s wlcg.groups:/escape
    ${uuid}   Generate UUID
    ${url}   SE URL   write-access-denied-${uuid}
    ${rc}   ${out}   Gfal copy Error   /etc/services   ${url}
    Should Contain   ${out}  403
