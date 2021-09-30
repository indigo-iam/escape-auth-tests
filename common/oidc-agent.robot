*** Variables ***

${oidc-agent.scope.default}   -s storage.read:/ -s storage.modify:/ -s storage.create:/ -s openid
${oidc-agent.account}  escape-monitoring
${bearer.env}   BEARER_TOKEN

*** Keywords ***

Get token   [Arguments]   ${issuer}=${oidc-agent.account}  ${scope}=${oidc-agent.scope.default}  ${opts}=${EMPTY}
    ${rc}  ${out}   Execute and Check Success   oidc-token ${scope} ${opts} ${issuer} 
    Set Environment Variable   ${bearer.env}   ${out}
    [Return]   ${out}
