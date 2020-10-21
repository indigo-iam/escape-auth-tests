*** Settings ***

Resource   common/utils.robot
Resource   common/oidc-agent.robot
Resource   common/endpoint.robot

*** Keywords ***

SE Context
    [Arguments]   ${se_alias}=${se_alias}
    ${se_cfg}   Get SE Config
    Create Http Context   ${se_config.endpoint}

SE Get  
    [Arguments]   ${path}   ${se_alias}=${se_alias}
    
    