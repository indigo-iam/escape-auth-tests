*** Variables ***

${oidc-agent.scope.default}   -s openid -s profile
${oidc-agent.account}  escape
${bearer.env}   BEARER_TOKEN

*** Keywords ***

Get token   [Arguments]   ${issuer}=${oidc-agent.account}  ${scope}=${oidc-agent.scope.default}  ${opts}=${EMPTY}
    ${rc}  ${out}   Execute and Check Success   oidc-token ${scope} ${opts} ${issuer} 
    Set Environment Variable   ${bearer.env}   ${out}
    [Return]   ${out}
