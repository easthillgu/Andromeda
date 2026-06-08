local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then return end

    local TaxiFrame = _G.TaxiFrame

    -- Hide Blizzard decorative layers (NDui: ReskinPortraitFrame StripTextures equivalent)
    TaxiFrame:DisableDrawLayer('BORDER')
    TaxiFrame:DisableDrawLayer('OVERLAY')
    if TaxiFrame.Bg then TaxiFrame.Bg:Hide() end
    if _G.TaxiFrame.TitleBg then _G.TaxiFrame.TitleBg:Hide() end
    if TaxiFrame.TopTileStreaks then TaxiFrame.TopTileStreaks:Hide() end
    -- NDui: hide portrait
    if TaxiFrame.PortraitTexture or TaxiFrame.portrait then
        (TaxiFrame.PortraitTexture or TaxiFrame.portrait):SetAlpha(0)
    end

    -- Background: original Andromeda offsets (proven visible in 3.80.1)
    F.SetBD(TaxiFrame, nil, 3, -23, -5, 3)

    -- NDui: TaxiCloseButton → ReskinButton + font X
    local cb = _G.TaxiCloseButton
    if cb then
        F.StripTextures(cb)
        cb:SetSize(20, 20)
        cb:ClearAllPoints()
        cb:SetPoint('TOPRIGHT', TaxiFrame, 'TOPRIGHT', -6, -6)
        F.ReskinButton(cb, true)

        -- Font-based X (ReskinClose's C.Assets.Textures.Close fails on this frame)
        local fs = cb:CreateFontString(nil, 'OVERLAY')
        fs:SetFont(C.Assets.Fonts.Bold, 14, 'OUTLINE')
        fs:SetText('X')
        fs:SetTextColor(1, 1, 1)
        fs:SetPoint('CENTER')
    end

    -- TaxiRouteMap: hide BORDER/OVERLAY decor + shadow border
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
