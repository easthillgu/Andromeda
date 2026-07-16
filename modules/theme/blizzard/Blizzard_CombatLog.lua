local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    -- 3.80.1: nil guard
    local button = _G.CombatLogQuickButtonFrame_Custom
    if not button then return end

    F.StripTextures(button)
    F.CreateBDFrame(button)

    -- Progress bar
    local progressBar = _G.CombatLogQuickButtonFrame_CustomProgressBar
    if progressBar then
        progressBar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
        progressBar:SetInside(button)
    end

    -- Quick filter buttons
    if _G.Blizzard_CombatLog_Filters then
        for index = 1, #_G.Blizzard_CombatLog_Filters.filters do
            local btn = _G['CombatLogQuickButtonFrameButton' .. index]
            if btn then
                local fontString = btn:GetFontString()
                if fontString then
                    fontString:SetFont(C.Assets.Fonts.Normal, 11, 'OUTLINE')
                end
            end
        end
    end

    -- Additional filter button
    local additionalBtn = _G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton
    if additionalBtn then
        F.ReskinArrow(additionalBtn, 'right')
    end

    -- Hide default texture overlay
    local customTex = _G.CombatLogQuickButtonFrame_CustomTexture
    if customTex then
        customTex:Hide()
    end
end)