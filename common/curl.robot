*** Settings ***

Resource   common/utils.robot
Resource   common/oidc-agent.robot

*** Variables ***

${x509.trustdir}  /etc/grid-security/certificates
${curl.opts.default}  --max-time 10 -s -L --capath ${x509.trustdir}

*** Keywords ***

Curl   [Arguments]  ${url}  ${opts}=${curl.opts.default}
    ${rc}   ${out}    Run and Return RC And Output   curl ${opts} ${url} 
    [Return]  ${rc}  ${out}

Curl Success  [Arguments]  ${url}  ${opts}=${curl.opts.default}
    ${rc}  ${out}   Execute and Check Success  curl ${url} ${opts}
    [Return]  ${rc}  ${out}

Curl Error   [Arguments]  ${url}  ${opts}=${curl.opts.default}
    ${rc}  ${out}   Execute and Check Failure  curl ${opts} -H "Authorization: Bearer %{${bearer.env}}" ${url}
    [Return]  ${rc}  ${out}

Curl PUT Command
    [Arguments]  ${file}   ${url}  ${opts}=${curl.opts.default}
    ${cmd}   Set Variable   curl ${opts} -H "Authorization: Bearer %{${bearer.env}}" --upload-file ${file} ${url}
    [Return]   ${cmd}
    
Curl PUT Success
    [Arguments]  ${file}   ${url}  ${opts}=${curl.opts.default}
    ${cmd}   Curl PUT Command   ${file}   ${url}   ${opts}
    ${rc}  ${out}   Execute and Check Success  ${cmd}
    [Return]  ${rc}  ${out}

Curl PUT Error
    [Arguments]  ${file}   ${url}  ${opts}=${curl.opts.default}
    ${cmd}   Curl PUT Command   ${file}   ${url}   ${opts}
    ${rc}  ${out}   Execute and Check Failure  ${cmd}
    [Return]  ${rc}  ${out}

Curl HEAD Command
    [Arguments]  ${file}   ${url}  ${opts}=${curl.opts.default}
    ${cmd}   Set Variable   curl ${opts} -I ${url}
    [Return]   ${cmd}

Curl HEAD Success
    [Arguments]  ${file}   ${url}  ${opts}=${curl.opts.default}
    ${cmd}   Curl HEAD Command   ${file}   ${url}  ${opts}
    ${rc}  ${out}   Execute and Check Failure  ${cmd}
    [Return]  ${rc}  ${out}

Curl pull COPY Success  [Arguments]  ${dest}  ${source}  ${opts}=${curl.opts.default}
    ${all_opts}   Set variable   -X COPY -H "Source: ${source}" -H "Authorization: Bearer %{${bearer.env}}" -H "TransferHeaderAuthorization: Bearer %{${bearer.env}}" ${opts}
    ${rc}  ${out}  Curl Success  ${dest}  ${all_opts}
    [Return]  ${rc}  ${out}

Curl push COPY Success  [Arguments]  ${dest}  ${source}  ${opts}=${curl.opts.default}
    ${all_opts}   Set variable   -X COPY -H "Destination: ${dest}" ${opts}
    ${rc}  ${out}  Curl Success  ${source}  ${all_opts}
    [Return]  ${rc}  ${out}

Curl DELETE Success   
    [Arguments]   ${url}   ${opts}=${curl.opts.default}
    ${all_opts}   Set variable   -X DELETE ${opts} -H "Authorization: Bearer %{${bearer.env}}"
    ${rc}  ${out}  Curl Success  ${url}  ${all_opts}
    [Return]  ${rc}  ${out}

Curl DELETE Error   
    [Arguments]   ${url}   ${opts}=${curl.opts.default}
    ${all_opts}   Set variable   -X DELETE ${opts} -H "Authorization: Bearer %{${bearer.env}}"
    ${rc}  ${out}  Curl Error  ${url}  ${all_opts}
    [Return]  ${rc}  ${out}

Curl MKCOL Success   
    [Arguments]   ${url}   ${opts}=${curl.opts.default}
    ${all_opts}   Set variable   -X MKCOL ${opts} -H "Authorization: Bearer %{${bearer.env}}"
    ${rc}  ${out}  Curl Success  ${url}  ${all_opts}
    [Return]  ${rc}  ${out}