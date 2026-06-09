local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    if not _G.CompactRaidFrameManagerToggleButton then
        return
    end

    _G.CompactRaidFrameManagerToggleButton:SetNormalTexture('Interface\\Buttons\\UI-ColorPicker-Buttons')
    _G.CompactRaidFrameManagerToggleButton:GetNormalTexture():SetTexCoord(0.15, 0.39, 0, 1)
    _G.CompactRaidFrameManagerToggleButton:SetSize(15, 15)
    hooksecurefunc('CompactRaidFrameManager_Collapse', function()
        _G.CompactRaidFrameManagerToggleButton:GetNormalTexture():SetTexCoord(0.15, 0.39, 0, 1)
    end)
    hooksecurefunc('CompactRaidFrameManager_Expand', function()
        _G.CompactRaidFrameManagerToggleButton:GetNormalTexture():SetTexCoord(0.86, 1, 0, 1)
    end)

    -- 参考 NDui：只美化按钮，不隐藏按钮区域
    local buttons = {
        _G.CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleTank,
        _G.CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleHealer,
        _G.CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleDamager,
        _G.CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup1,
        _G.CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup2,
        _G.CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup3,
        _G.CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup4,
        _G.CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup5,
        _G.CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup6,
        _G.CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup7,
        _G.CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup8,
        _G.CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll,
        _G.CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck,
        _G.CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton,
        _G.CompactRaidFrameManagerDisplayFrameLockedModeToggle,
        _G.CompactRaidFrameManagerDisplayFrameHiddenModeToggle,
        _G.CompactRaidFrameManagerDisplayFrameConvertToRaid,
    }
    for _, button in pairs(buttons) do
        if button then
            F.ReskinButton(button)
        end
    end

    if _G.CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton then
        _G.CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetNormalTexture('Interface\\RaidFrame\\Raid-WorldPing')
    end

    -- 参考 NDui：只隐藏管理器本身的区域
    for i = 1, 8 do
        local region = select(i, _G.CompactRaidFrameManager:GetRegions())
        if region then
            region:SetAlpha(0)
        end
    end

    if _G.CompactRaidFrameManagerDisplayFrameFilterOptions then
        local region = select(1, _G.CompactRaidFrameManagerDisplayFrameFilterOptions:GetRegions())
        if region then
            region:SetAlpha(0)
        end
    end

    if _G.CompactRaidFrameManagerDisplayFrame then
        local region = select(1, _G.CompactRaidFrameManagerDisplayFrame:GetRegions())
        if region then
            region:SetAlpha(0)
        end
        region = select(4, _G.CompactRaidFrameManagerDisplayFrame:GetRegions())
        if region then
            region:SetAlpha(0)
        end
    end

    local bd = F.SetBD(_G.CompactRaidFrameManager)
    bd:SetPoint('TOPLEFT')
    bd:SetPoint('BOTTOMRIGHT', -9, 9)

    if _G.CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton then
        F.ReskinCheckbox(_G.CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton)
    end
end)
