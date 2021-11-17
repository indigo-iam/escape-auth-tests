*** Settings ***

Resource    common/gfal.robot
Resource    common/endpoint.robot
Resource    common/oidc-agent.robot
Resource    common/utils.robot
Resource    common/voms.robot

Variables   test/variables.yaml

Force Tags   anonymous-authz   step-0

Suite Setup   Set Child Suite Environment


*** Test cases ***

Show directory content denied to unauthenticated clients
    ${cmd}   Set Variable   gfal-ls ${url}
    ${rc}   ${out}    Run and Return RC And Output   ${cmd}
    ${status.empty.out}   ${value}   Run Keyword And Ignore Error   Should Be Empty   ${out}
    ${status.error.out}   ${value}   Run Keyword And Ignore Error   Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True
    Run Keyword If   '${status.empty.out}' == 'FAIL' and '${status.error.out}' == 'FAIL'   Fail   Show directory content allowed to unauthenticated clients

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
    [Teardown]   Run   voms-proxy-destroy

Create directory denied to unauthenticated clients
    ${rc}   ${out}   Gfal mkdir Error   ${url}   -p
    Should Contain Any   ${out}  401   403   Permission denied   ignore_case=True

Delete directory denied to unauthenticated clients
    ${rc}   ${out}   Gfal rm Error  ${url}   -r
    Should Contain Any   ${out}  401   403   424   Permission denied   ignore_case=True


*** Keywords ***

Set Child Suite Environment
    Get Fixture Authorization Method
    Set Suite Environment   anonymous-access-denied   random-content
    Cleanup Authorization Environment
