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
    ${rc}   ${out}   Gfal cat Error  ${url}/${FILE_BASENAME}
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True

Write file denied to unauthenticated clients
    ${uuid}   Generate UUID
    ${url}   SE URL   write-access-denied-${uuid}
    ${local_file}   Create Random Temporary File
    ${file.basename}   Run   basename ${local_file}
    ${rc}   ${out}   Gfal copy Error   ${local_file}   ${url}/${file.basename}   -pf
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True
    Remove Temporary File   ${file.basename}

Delete file denied to unauthenticated clients
    ${url}   ${file.basename}   Upload file in sub-suite Directory with VOMS proxy   anonymous-delete-file-denied   random-content
    Delete VOMS proxy
    ${rc}   ${out}   Gfal rm Error  ${url}/${file.basename}
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True
    [Teardown]   Run   voms-proxy-destroy

Create directory denied to unauthenticated clients
    ${uuid}   Generate UUID
    ${url}   SE URL   write-access-denied-${uuid}
    ${rc}   ${out}   Gfal mkdir Error   ${url}
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True

Delete directory denied to unauthenticated clients
    ${url}   Create sub-suite Directory with VOMS proxy   anonymous-delete-directory-denied
    Delete VOMS proxy
    ${rc}   ${out}   Gfal rm Error  ${url}   -r
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True
    [Teardown]   Run   voms-proxy-destroy