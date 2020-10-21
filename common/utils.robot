*** Settings ***

Library    OperatingSystem
Library    String
Library    Collections
Library    HttpSupportLibrary
Library    VOMSHelperLibrary

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
    [Arguments]   ${se}=${se_alias}   ${sa}=wlcg
    ${endpoint}   GET SE endpoint   ${se_alias}   ${sa}
    ${url}   Set Variable   ${endpoint}/wlcg-jwt-compliance/${SUITE_UUID}
    [Return]   ${url}

SE URL
    [Arguments]  ${path}  ${se}=${se_alias}   ${sa}=wlcg
    ${suite_url}   Suite Base URl   ${se_alias}   ${sa}
    ${url}   Set Variable   ${suite_url}/${path}
    [Return]   ${url}

Create Suite Directory
    [Arguments]   ${sa}=wlcg
    ${endpoint}   GET SE endpoint   ${se_alias}   ${sa}
    Se Create Dir If Missing   ${endpoint}/wlcg-jwt-compliance
    Se Create Dir If Missing   ${endpoint}/wlcg-jwt-compliance/${SUITE_UUID}