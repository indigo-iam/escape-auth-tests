*** Settings ***

Resource    common/gfal.robot
Resource    common/endpoint.robot
Resource    common/oidc-agent.robot
Resource    common/utils.robot
Resource    common/voms.robot

Variables   test/variables.yaml

Force Tags   anonymous-authz   step-0


*** Test cases ***

List directory denied to unauthenticated clients
    ${url}   Suite Base URL
    ${rc}   ${out}   Gfal Read Error   ${url}   -d
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True

Read file denied to unauthenticated clients
    ${url}   Suite Base URL
    ${file}   ${file.path}   ${file.basename}   Get File Location From Variable
    ${rc}   ${out}   Gfal cat Error  ${url}/${file.basename}
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True

Write file denied to unauthenticated clients
    ${uuid}   Generate UUID
    ${url}   SE URL   write-access-denied-${uuid}
    ${file}   ${file.path}   ${file.basename}   Get File Location From Variable
    ${rc}   ${out}   Gfal copy Error   ${file}   ${url}/${file.basename}   -pf
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True

Delete file denied to unauthenticated clients
    ${url}   ${file.basename}   Upload file in sub-suite Directory with VOMS proxy   anonymous-access-denied
    Delete VOMS proxy
    ${rc}   ${out}   Gfal rm Error  ${url}/${file.basename}
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True

Create directory denied to unauthenticated clients
    ${uuid}   Generate UUID
    ${url}   SE URL   write-access-denied-${uuid}
    ${rc}   ${out}   Gfal mkdir Error   ${url}
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True

Delete directory denied to unauthenticated clients
    ${url}   Create sub-suite Directory with VOMS proxy   anonymous-access-denied
    Delete VOMS proxy
    ${rc}   ${out}   Gfal rm Error  ${url}   -r
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True