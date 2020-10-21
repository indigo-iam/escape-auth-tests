*** Settings ***

Resource   common/utils.robot

*** Variables ***

${voms.args.default}   -voms escape

*** Keywords ***

Get proxy path
	${userId}   Run   id -u
	[Return]   /tmp/x509up_u${userId}

Get proxy info   [Arguments]   
    ${output}   Execute and Check Success   voms-proxy-info -all
    [Return]   ${output}

Create VOMS proxy   [Arguments]   ${voms.args}=${voms.args.default}
    ${output}   Execute and Check Success   voms-proxy-init ${voms.args}
    [Return]   ${output}
