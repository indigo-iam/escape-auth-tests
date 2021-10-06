*** Settings ***

Resource   common/utils.robot
Resource   common/oidc-agent.robot


*** Keywords ***

Gfal Read Error   
    [Arguments]  ${url}  ${opts}=${EMPTY}
    ${cmd}   Set Variable   gfal-ls ${opts} ${url}
    ${rc}  ${out}   Execute and Check Failure  ${cmd}
    [Return]  ${rc}  ${out}

Gfal Read Success   
    [Arguments]  ${url}  ${opts}=-d
    ${cmd}   Set Variable   gfal-ls ${opts} ${url}
    ${rc}  ${out}   Execute and Check Success  ${cmd}
    [Return]  ${rc}  ${out}

Gfal copy Error   
    [Arguments]  ${file}  ${url}  ${opts}=${EMPTY}
    ${cmd}   Set Variable   gfal-copy ${opts} ${file} ${url}
    ${rc}  ${out}   Execute and Check Failure  ${cmd}
    [Return]  ${rc}  ${out}

Gfal copy Success   
    [Arguments]  ${file}  ${url}  ${opts}=${EMPTY}
    ${cmd}   Set Variable   gfal-copy ${opts}  ${file} ${url}
    ${rc}  ${out}   Execute and Check Success  ${cmd}
    [Return]  ${rc}  ${out}

Gfal mkdir Success   
    [Arguments]  ${url}  ${opts}=${EMPTY}
    ${cmd}   Set Variable   gfal-mkdir ${opts} ${url}
    Execute and Check Success   ${cmd}
    ${rc}   ${out}   Gfal read Success   ${url}   -d
    [Return]  ${rc}  ${out}

Gfal mkdir Error   
    [Arguments]  ${url}  ${opts}=-p
    ${cmd}   Set Variable   gfal-mkdir ${opts} ${url}
    ${rc}   ${out}   Execute and Check Failure   ${cmd}
    [Return]  ${rc}  ${out}

Gfal rm Success
    [Arguments]  ${url}  ${opts}=-r
    ${cmd}   Set Variable   gfal-rm ${opts} ${url}
    ${rc}   ${out}   Execute and Check Success   ${cmd}
    [Return]  ${rc}  ${out}