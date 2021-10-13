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
    Should Contain   ${out}  401

Read file denied to unauthenticated clients
    ${url}   Suite Base URL
    ${file}   ${file.path}   ${file.basename}   Get File Location From Variable
    ${rc}   ${out}   Gfal cat Error  ${url}/${file.basename}
    Should Contain   ${out}   401

Write file denied to unauthenticated clients
    ${uuid}   Generate UUID
    ${url}   SE URL   write-access-denied-${uuid}
    ${file}   ${file.path}   ${file.basename}   Get File Location From Variable
    ${rc}   ${out}   Gfal copy Error   ${file}   ${url}/${file.basename}   -pf
    Should Contain   ${out}  401

Delete file denied to unauthenticated clients
    Upload file with VOMS proxy
    ${rc}   ${out}   Gfal rm Error  ${url}/${file.basename}
    Should Contain   ${out}   401

Create directory denied to unauthenticated clients
    ${uuid}   Generate UUID
    ${url}   SE URL   write-access-denied-${uuid}
    ${rc}   ${out}   Gfal mkdir Error   ${url}
    Should Contain   ${out}  401

Delete directory denied to unauthenticated clients
    Create directory with VOMS proxy
    ${rc}   ${out}   Gfal rm Error  ${url}
    Should Contain   ${out}   401


*** Keywords ***

Upload file with VOMS proxy
  ${rc}   ${out}   Create VOMS proxy
  Should Contain   ${out}   Created proxy in
  ${uuid}   Generate UUID
  ${url}   SE URL   write-access-denied-${uuid}
  Set Test Variable   ${url}
  ${rc}   ${out}   Gfal mkdir Success   ${url}
  Should Contain   ${out}   ${url}
  ${file}   ${file.path}   ${file.basename}   Get File Location From Variable
  Set Test Variable   ${file.basename}
  ${rc}   ${out}   Gfal copy Success   ${file}   ${url}
  Should Contain   ${out}   ${url}/${file.basename}
  Delete VOMS proxy

Create directory with VOMS proxy
  ${rc}   ${out}   Create VOMS proxy
  Should Contain   ${out}   Created proxy in
  ${uuid}   Generate UUID
  ${url}   SE URL   create-directory-denied-${uuid}
  Set Test Variable   ${url}
  ${rc}   ${out}   Gfal mkdir Success   ${url}
  Should Contain   ${out}   ${url}
  Delete VOMS proxy