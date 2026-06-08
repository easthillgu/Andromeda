local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local TaxiFrame = _G.TaxiFrame
    TaxiFrame:DisableDrawLayer('BORDER')
    TaxiFrame:DisableDrawLayer('OVERLAY')
    if TaxiFrame.Bg then TaxiFrame.Bg:Hide() end
    if _G.TaxiFrame.TitleBg then
        _G.TaxiFrame.TitleBg:Hide()
    end
    if TaxiFrame.TopTileStreaks then
        TaxiFrame.TopTileStreaks:Hide()
    end

    F.SetBD(TaxiFrame, nil, 3, -23, -5, 3)

    -- 3.80.1: Close button — ReskinButton + font-based X (avoid external texture issues)
    local closeBtn = _G.TaxiCloseButton
    if closeBtn then
        F.StripTextures(closeBtn)
        closeBtn:SetSize(20, 20)
        F.ReskinButton(closeBtn, true)
        -- Clear any existing textures from ReskinButton
        for _, r in pairs({closeBtn:GetRegions()}) do
            if r:GetObjectType() == 'Texture' and r:GetDrawLayer() == 'ARTWORK' then
                r:SetTexture(nil)
            end
        end
        -- Font-based X icon
        local fs = closeBtn:CreateFontString(nil, 'OVERLAY')
        fs:SetFont(C.Assets.Fonts.Bold, 14, 'OUTLINE')
        fs:SetText('✕')
        fs:SetTextColor(1, 1, 1)
        fs:SetPoint('CENTER')
        closeBtn._andmCloseFS = fs
    end

    -- 3.80.1: TaxiRouteMap — hide named decor + border overlay (from TaxiFrame)
    TaxiFrame:HookScript('OnShow', function()
        local routeMap = _G.TaxiRouteMap
        if not routeMap then return end

        -- One-time: hide Blizzard decorative sub-frames
        if not routeMap._andmStyled then
            routeMap._andmStyled = true
            if routeMap.Bg then routeMap.Bg:Hide() end
            if routeMap.Border then routeMap.Border:Hide() end
            if routeMap.Background then routeMap.Background:Hide() end
            -- hide any Region-type unnamed decorative textures on BORDER/OVERLAY
            for _, r in pairs({routeMap:GetRegions()}) do
                if r:GetObjectType() == 'Texture' then
                    local layer = r:GetDrawLayer()
                    if layer == 'BORDER' or layer == 'OVERLAY' then
                        r:SetTexture(nil)
                    end
                end
            end
        end

        -- Border frame (re-create each show — may be cleaned up on hide)
        if not routeMap._andmBorder or not routeMap._andmBorder:IsShown() then
            if routeMap._andmBorder then routeMap._andmBorder:Hide() end
            local border = CreateFrame('Frame', nil, TaxiFrame, 'BackdropTemplate')
            border:SetAllPoints(routeMap)
            border:SetBackdrop({edgeFile = C.Assets.Textures.Shadow, edgeSize = 3})
            local color = _G.ANDROMEDA_ADB.BorderColor
            border:SetBackdropBorderColor(color.r, color.g, color.b, 0.6)
            routeMap._andmBorder = border
        end
    end)
end)
