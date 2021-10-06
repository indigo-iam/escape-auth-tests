*** Settings ***

Resource   common/curl.robot
Resource   common/oidc-agent.robot
Resource   common/voms.robot
Library   requests
Library   jwt

*** Variables ***

${iam.url.base}   https://iam-escape.cloud.cnaf.infn.it
${iam.url.health}   ${iam.url.base}/health
${iam.url.userinfo}   ${iam.url.base}/userinfo

*** Test cases ***

IAM ESCAPE is up
    ${result}   get   ${iam.url.health}
    Should Be Equal  ${result.status_code}  ${200}
    ${json}   Set Variable  ${result.json()}
    ${status}   Get From Dictionary  ${json}  status
    Should Be Equal  ${status}  UP

IAM token service work as expected
    ${token}   Get token
    ${payload}   decode   ${token}   verify=False
    ${wlcg.version}   Get From Dictionary  ${payload}  wlcg.ver
    Should Be Equal  ${wlcg.version}  1.0

IAM VOMS service work as expected
    Create VOMS proxy   -voms escape -noregen -cert /tmp/x509up_ts -out /tmp/x509up_voms_check
    ${rc}  ${out}   Get proxy info   -file /tmp/x509up_voms_check -all
    Should Contain   ${out}   /escape
    Execute And Check Success   rm -f /tmp/x509up_voms_check