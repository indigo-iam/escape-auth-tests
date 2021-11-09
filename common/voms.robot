*** Settings ***

Resource   common/utils.robot

*** Variables ***

${voms.args.default}   -voms escape -cert /tmp/x509up_ts -noregen

*** Keywords ***

Get proxy path
	${rc}   ${userId}   Execute and Check Success   id -u
    ${output}   Set Variable   /tmp/x509up_u${userId}
	[Return]   ${output}

Get proxy info   [Arguments]   ${opts}=-all 
    ${output}   Execute and Check Success   voms-proxy-info ${opts}
    [Return]   ${output}

Create VOMS proxy   [Arguments]   ${voms.args}=${voms.args.default}
    ${rc}   ${output}   Execute and Check Success   voms-proxy-init ${voms.args}
    [Return]   ${rc}   ${output}

Create Fixture VOMS proxy
    ${rc}   ${output}   Create VOMS proxy   ${voms.args.default} -out /tmp/x509up_ts_fixture
    [Return]   ${rc}   ${output}

Enable Fixture VOMS proxy
    ${proxy_path}   Get proxy path
    ${rc}   ${output}   Execute and Check Success  cp /tmp/x509up_ts_fixture ${proxy_path}
    [Return]   ${rc}   ${output}
    
Delete VOMS proxy   [Arguments]   ${opts}=${EMPTY}
    ${output}   Execute and Check Success   voms-proxy-destroy ${opts}
    [Return]   ${output}