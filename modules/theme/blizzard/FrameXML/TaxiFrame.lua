local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then return end

    -- NDui: TaxiFramePortrait = TaxiPortrait; TaxiFrameCloseButton = TaxiCloseButton
    _G.TaxiFrameCloseButton = _G.TaxiCloseButton
    _G.TaxiFramePortrait = _G.TaxiPortrait

    local TaxiFrame = _G.TaxiFrame
    -- NDui: B.ReskinPortraitFrame(TaxiFrame, 17, -8, -45, 82)
    F.ReskinPortraitFrame(TaxiFrame)

    -- Match NDui backdrop offsets
    if TaxiFrame.__bg then
        TaxiFrame.__bg:ClearAllPoints()
        TaxiFrame.__bg:SetPoint('TOPLEFT', 17, -8)
        TaxiFrame.__bg:SetPoint('BOTTOMRIGHT', -45, 82)
    end

    -- 3.80.1: ReskinClose anchors to TaxiFrame (not __bg).
    -- Fix close button position to match NDui's __bg offset.
    local cb = _G.TaxiCloseButton
    if cb and TaxiFrame.__bg then
        cb:ClearAllPoints()
        cb:SetPoint('TOPRIGHT', TaxiFrame.__bg, 'TOPRIGHT', -6, -6)
        -- Update ReskinClose's internal anchor tracking to prevent hooks resetting
        cb.__owner = TaxiFrame.__bg
        cb.__xOffset = -6
        cb.__yOffset = -6
    end

    -- 3.80.1: ReskinClose SetTexture(C.Assets.Textures.Close) fails on TaxiCloseButton
    -- Fallback: font-based X overlay
    if cb then
        local hasIcon = false
        for _, r in pairs({cb:GetRegions()}) do
            if r:GetObjectType() == 'Texture' and r:GetDrawLayer() == 'ARTWORK' and r:GetTexture() then
                hasIcon = true
                break
            end
        end
        if not hasIcon then
            local fs = cb:CreateFontString(nil, 'OVERLAY')
            fs:SetFont(C.Assets.Fonts.Bold, 14, 'OUTLINE')
            fs:SetText('X')
            fs:SetTextColor(1, 1, 1)
            fs:SetPoint('CENTER')
        end
    end

    -- TaxiRouteMap: hide BORDER/OVERLAY decor (keep ARTWORK = map content) + shadow border
    TaxiFrame:HookScript('OnShow', function()
        local rm = _G.TaxiRouteMap
        if not rm or rm._andmStyled then return end
        rm._andmStyled = true

        for _, r in pairs({rm:GetRegions()}) do
            if r:GetObjectType() == 'Texture' then
                local l = r:GetDrawLayer()
                if l == 'BORDER' or l == 'OVERLAY' then
                    r:SetTexture(nil)
                end
            end
        end

        local bd = CreateFrame('Frame', nil, TaxiFrame, 'BackdropTemplate')
        bd:SetAllPoints(rm)
        bd:SetBackdrop({edgeFile = C.Assets.Textures.Shadow, edgeSize = 3})
        local bc = _G.ANDROMEDA_ADB.BorderColor
        bd:SetBackdropBorderColor(bc.r, bc.g, bc.b, 0.5)
    end)
end)
