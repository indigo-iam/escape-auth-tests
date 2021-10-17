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

Remove Temporary File  [Arguments]  ${file}
    ${path}    Normalize Path   ${TEMPDIR}/${file}
    Remove File   ${path}

Create Random Temporary File
    [Arguments]   ${content}=${EMPTY}
    ${file}   Execute and Check Success   uuid-gen
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

Get File Location From Variable
    ${file.path}   Get From Dictionary   ${file}   path
    ${file.basename}   Get From Dictionary   ${file}   basename
    [Return]   ${file.path}/${file.basename}   ${file.path}   ${file.basename}

Create sub-suite Directory with VOMS proxy
    [Arguments]   ${prefix.dir}=ts
    ${rc}   ${out}   Create VOMS proxy
    Should Contain   ${out}   Created proxy in
    ${uuid}   Generate UUID
    ${url}   SE URL   ${prefix.dir}-${uuid}
    ${rc}   ${out}   Gfal mkdir Success   ${url}
    Should Contain   ${out}   ${url}
    [Return]   ${url}

Upload file in sub-suite Directory with VOMS proxy
    [Arguments]   ${prefix.dir}=ts
    ${url}   Create sub-suite Directory with VOMS proxy   ${prefix.dir}
    ${file}   ${file.path}   ${file.basename}   Get File Location From Variable
    ${rc}   ${out}   Gfal copy Success   ${file}   ${url}
    Should Contain   ${out}   ${url}/${file.basename}
    [Return]   ${url}   ${file.basename}