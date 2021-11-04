*** Settings ***

Resource    common/gfal.robot
Resource    common/endpoint.robot
Resource    common/oidc-agent.robot
Resource    common/utils.robot
Resource    common/voms.robot

Variables   test/variables.yaml

Force Tags   anonymous-authz   step-0

Suite Setup   Run Keywords   
              ...   Set Authorization Method
              ...   AND   Set Suite Environment
              ...   AND   Cleanup Authorization Environment


*** Test cases ***

List directory denied to unauthenticated clients
    ${rc}   ${out}   Gfal Read Error   ${url}   -d
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True

Read file denied to unauthenticated clients
    ${rc}   ${out}   Gfal cat Error  ${url}/${file.basename}
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True

Write file denied to unauthenticated clients
    ${local_file}   Create Random Temporary File
    ${file_basename}   Run   basename ${local_file}
    ${rc}   ${out}   Gfal copy Error   ${local_file}   ${url}/${file_basename}   -pf
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True
    Remove Temporary File   ${file_basename}

Delete file denied to unauthenticated clients
    ${rc}   ${out}   Gfal rm Error  ${url}/${file.basename}
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True

Create directory denied to unauthenticated clients
    ${rc}   ${out}   Gfal mkdir Error   ${url}   -p
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True

Delete directory denied to unauthenticated clients
    ${rc}   ${out}   Gfal rm Error  ${url}   -r
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True


*** Keywords ***

Set Suite Environment
    ${url}   ${file.basename}   Upload File in Suite Sub-Directory   anonymous-access-denied   random-content
    Set Suite Variable   ${url}
    Set Suite Variable   ${file.basename}