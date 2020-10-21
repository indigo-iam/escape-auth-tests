*** Keywords ***

Load endpoints
    @{aliases}   Get Dictionary Keys   ${endpoints}
    [Return]   @{aliases}

Get SE config
    [Arguments]   ${se_alias}=${se_alias}
    ${se_cfg}   Get From Dictionary   ${endpoints}   ${se_alias}
    [Return]   ${se_cfg}

Get SE endpoint
    [Arguments]   ${se_alias}   ${sa}=wlcg
    ${se_cfg}   Get SE config   ${se_alias}
    ${sa_path}   Get From Dictionary   ${se_cfg.paths}   ${sa}
    [Return]   ${se_cfg.endpoint}${sa_path}