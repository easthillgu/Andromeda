local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then return end

    -- NDui base: aliases + ReskinPortraitFrame
    _G.TaxiFrameCloseButton = _G.TaxiCloseButton
    _G.TaxiFramePortrait = _G.TaxiPortrait
    F.ReskinPortraitFrame(_G.TaxiFrame)

    -- Close button font X fallback (ReskinClose icon texture may fail on this frame)
    local cb = _G.TaxiCloseButton
    if cb then
        C_Timer.After(0, function()  -- next frame: let ReskinClose finish first
            local hasIcon = false
            for _, r in pairs({cb:GetRegions()}) do
                if r:GetObjectType() == 'Texture' and r:GetDrawLayer() == 'ARTWORK' and r:GetTexture() then
                    hasIcon = true; break
                end
            end
            if not hasIcon then
                local fs = cb:CreateFontString(nil, 'OVERLAY')
                fs:SetFont(C.Assets.Fonts.Bold, 14, 'OUTLINE')
                fs:SetText('X')
                fs:SetTextColor(1, 1, 1)
                fs:SetPoint('CENTER')
            end
        end)
    end

    -- TaxiRouteMap: shadow border (delayed — lazy init)
    _G.TaxiFrame:HookScript('OnShow', function()
        C_Timer.After(0.15, function()
            if not _G.TaxiFrame:IsShown() then return end
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
            local bd = CreateFrame('Frame', nil, _G.TaxiFrame, 'BackdropTemplate')
            bd:SetAllPoints(rm)
            bd:SetBackdrop({edgeFile = C.Assets.Textures.Shadow, edgeSize = 3})
            local bc = _G.ANDROMEDA_ADB.BorderColor
            bd:SetBackdropBorderColor(bc.r, bc.g, bc.b, 0.5)
        end)
    end)
end)