local F, C = unpack(select(2, ...))
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    if not IsAddOnLoaded('Blizzard_CUFProfiles') then return end
    if not IsAddOnLoaded('Blizzard_CompactRaidFrames') then return end
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
            -- 隐藏所有前9个区域（参考 NDui）
            for i = 1, 9 do
                local region = select(i, button:GetRegions())
                if region then region:SetAlpha(0) end
            end
            F.ReskinButton(button)
        end
    end

    -- 处理 CompactRaidFrameManager 的区域
    if _G.CompactRaidFrameManager then
        for i = 1, 8 do
            local region = select(i, _G.CompactRaidFrameManager:GetRegions())
            if region then region:SetAlpha(0) end
        end
        local bd = F.SetBD(_G.CompactRaidFrameManager)
        if bd then
            bd:SetPoint('TOPLEFT')
            bd:SetPoint('BOTTOMRIGHT', -9, 9)
        end
    end

    -- 处理 DisplayFrame 的区域
    if _G.CompactRaidFrameManagerDisplayFrame then
        local region1 = select(1, _G.CompactRaidFrameManagerDisplayFrame:GetRegions())
        if region1 then region1:SetAlpha(0) end
        local region4 = select(4, _G.CompactRaidFrameManagerDisplayFrame:GetRegions())
        if region4 then region4:SetAlpha(0) end
    end

    -- 处理 FilterOptions 的区域
    if _G.CompactRaidFrameManagerDisplayFrameFilterOptions then
        local region = select(1, _G.CompactRaidFrameManagerDisplayFrameFilterOptions:GetRegions())
        if region then region:SetAlpha(0) end
    end

    -- 处理全员协助按钮
    if _G.CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton then
        F.ReskinCheckbox(_G.CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton)
    end
end)
