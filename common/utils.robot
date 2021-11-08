*** Settings ***

Library    OperatingSystem
Library    String
Library    Collections
Library    HttpSupportLibrary
Library    VOMSHelperLibrary

Resource   common/voms.robot


*** Keywords ***

Generate UUID
    ${uuid}   Evaluate   uuid.uuid4()   uuid
    [Return]   ${uuid}

Check Success   
    [Arguments]   ${cmd}   ${rc}   ${output}
    Should Be Equal As Integers   ${rc}   0   ${cmd} exited with status ${rc} != 0 : ${output}   False
    [Return]   ${rc}  ${output}

Check Failure
    [Arguments]   ${cmd}   ${rc}   ${output}
    Should Not Be Equal As Integers   ${rc}   0   ${cmd} exited with 0 : ${output}   False
    [Return]   ${rc}  ${output}

Execute and Check Success   [Arguments]   ${cmd}
    ${rc}   ${output}    Run and Return RC And Output   ${cmd}
    Should Be Equal As Integers   ${rc}   0   ${cmd} exited with status ${rc} != 0 : ${output}   False
    [Return]   ${rc}  ${output}

Execute and Check Failure   [Arguments]   ${cmd}
    ${rc}   ${output}    Run and Return RC And Output   ${cmd}
    Should Not Be Equal As Integers   ${rc}   0   ${cmd} exited with 0 : ${output}   False
    [Return]   ${rc}  ${output}

Create Temporary File  
    [Arguments]  ${file}  ${content}=${EMPTY}
    ${path}    Normalize Path   ${TEMPDIR}/${file}
    File Should Not Exist   ${path}
    Create File   ${path}  ${content}
    [Return]   ${path}

Remove Temporary File  
    [Arguments]  ${file}
    ${path}    Normalize Path   ${TEMPDIR}/${file}
    Remove File   ${path}

Create Random Temporary File
    [Arguments]   ${content}=${EMPTY}
    ${file}   Generate UUID
    ${path}    Normalize Path   ${TEMPDIR}/${file}
    File Should Not Exist   ${path}
    Create File   ${path}  ${content}
    [Return]   ${path}

Suite Base URL
    [Arguments]   ${se}=${se_alias}   ${sa}=prefix
    ${endpoint}   GET SE endpoint   ${se_alias}   ${sa}
    ${url}   Set Variable   ${endpoint}/escape-auth-tests/${NOW}-${SUITE_UUID}
    [Return]   ${url}

SE URL
    [Arguments]  ${path}  ${se}=${se_alias}   ${sa}=prefix
    ${suite_url}   Suite Base URL   ${se_alias}   ${sa}
    ${url}   Set Variable   ${suite_url}/${path}
    [Return]   ${url}

Create Suite Directory
    [Arguments]   ${sa}=prefix
    ${endpoint}   GET SE endpoint   ${se_alias}   ${sa}
    Se Create Dir If Missing   ${endpoint}/escape-auth-tests
    Se Create Dir If Missing   ${endpoint}/escape-auth-tests/${SUITE_UUID}

Get NOW Time
    ${year}  ${month}  ${day}  ${hour}  ${min}  ${sec}   Get Time   year month day hour min sec
    [Return]   ${year}${month}${day}_${hour}${min}${sec}

Set Authorization Method
    ${rc}   ${out}   Create VOMS proxy
    Should Contain   ${out}   Created proxy in
    ${status}   ${value}   Run Keyword And Ignore Error   Gfal mkdir Success   ${url}
    IF   '${status}' == 'FAIL'
    Set Global Variable   ${AUTHZ_METHOD}   token
    Log    Authorization method used: BEARER token
    ELSE IF   '${status}' == 'PASS'
    Set Global Variable   ${AUTHZ_METHOD}   proxy
    Log    Authorization method used: VOMS proxy
    ELSE
    Set Global Variable   ${AUTHZ_METHOD}  None
    Log   Unexpected Keyword Status: '${status}'
    END
    Delete VOMS proxy

Get Authorization Method
    IF   '${AUTHZ_METHOD}' == 'proxy'
    ${rc}   ${out}   Create VOMS proxy
    Should Contain   ${out}   Created proxy in
    ELSE IF   '${AUTHZ_METHOD}' == 'token'
    Get token
    ELSE
    Log   No authorization method set; failing test setup and skipping test suite
    END


Cleanup Authorization Environment
    Remove Environment Variable   BEARER_TOKEN
    Run Keyword And Ignore Error   Delete VOMS proxy

Create Suite Sub-Directory
    [Arguments]   ${prefix.dir}=ts
    ${uuid}   Generate UUID
    ${url}   SE URL   ${prefix.dir}-${uuid}
    ${rc}   ${out}   Gfal mkdir Success   ${url}
    Should Contain   ${out}   ${url}
    [Return]   ${url}

Upload File in Suite Sub-Directory
    [Arguments]   ${prefix.dir}=ts   ${content}=${EMPTY}
    ${url}   Create Suite Sub-Directory   ${prefix.dir}
    ${local_file}   Create Random Temporary File   ${content}
    ${file.basename}   Run   basename ${local_file}
    ${rc}   ${out}   Gfal copy Success   ${local_file}   ${url}
    Should Contain   ${out}   ${url}/${file.basename}
    Remove Temporary file   ${file.basename}
    [Return]   ${url}   ${file.basename}

Set Suite Environment
    [Arguments]   ${prefix.dir}=ts   ${content}=${EMPTY}
    ${url}   ${file.basename}   Upload File in Suite Sub-Directory   ${prefix.dir}   ${content}
    Set Suite Variable   ${url}
    Set Suite Variable   ${file.basename}