*** Settings ***

Resource    common/gfal.robot
Resource    common/endpoint.robot
Resource    common/oidc-agent.robot
Resource    common/utils.robot

Variables   test/variables.yaml

Force Tags   anonymous-authz   step-0


*** Test cases ***

List directory denied to anonymous clients
    ${uuid}   Generate UUID
    ${url}   SE URL   robot-test-${uuid}
    ${rc}   ${out}   Gfal Read Error   ${url}
    Should Contain   ${out}  401

Read files denied to anonymous clients
    Create VOMS proxy
    ${uuid}   Generate UUID
    ${url}   SE URL   read-access-denied-${uuid}
    ${rc}   ${out}   Gfal mkdir Success   ${url}
    Should Contain   ${out}   ${url}
    ${rc}   ${out}   Gfal copy Success   /etc/services   ${url}
    Should Contain   ${out}   ${url}/services
    Delete VOMS proxy
    Gfal Read File Success  ${url}/services