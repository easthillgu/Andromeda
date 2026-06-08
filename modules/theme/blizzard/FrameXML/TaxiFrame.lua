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

    -- 3.80.1: Close button — ReskinButton + Blizzard close icon (ReskinClose SetTexture fails)
    local closeBtn = _G.TaxiCloseButton
    if closeBtn and not closeBtn._andmCloseStyled then
        closeBtn._andmCloseStyled = true
        F.StripTextures(closeBtn)
        closeBtn:SetSize(20, 20)
        F.ReskinButton(closeBtn, true)

        local tex = closeBtn:CreateTexture(nil, 'ARTWORK')
        tex:SetAllPoints()
        tex:SetTexture('Interface\\Buttons\\UI-Panel-MinimizeButton-Up')
        tex:SetTexCoord(0.75, 1, 0, 0.25)
        closeBtn._andmCloseTex = tex
        closeBtn._andmCloseNormal = 'Interface\\Buttons\\UI-Panel-MinimizeButton-Up'

        closeBtn:HookScript('OnEnter', function(b)
            b._andmCloseTex:SetTexture('Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight')
        end)
        closeBtn:HookScript('OnLeave', function(b)
            b._andmCloseTex:SetTexture(b._andmCloseNormal)
        end)
    end

    -- 3.80.1: TaxiRouteMap — hide Blizzard decor + add border (sibling of TaxiFrame)
    TaxiFrame:HookScript('OnShow', function()
        C_Timer.After(0.1, function()
            if not TaxiFrame:IsShown() then return end
            local routeMap = _G.TaxiRouteMap
            if routeMap and not routeMap._andmStyled then
                routeMap._andmStyled = true

                -- Hide Blizzard decorative layers (don't touch ARTWORK = map content)
                routeMap:DisableDrawLayer('BORDER')
                routeMap:DisableDrawLayer('OVERLAY')

                -- Hide named decorative sub-frames
                if routeMap.Bg then routeMap.Bg:Hide() end
                if routeMap.Border then routeMap.Border:Hide() end
                if routeMap.Background then routeMap.Background:Hide() end

                -- Border as TaxiFrame sibling (map frames don't render children)
                local border = CreateFrame('Frame', nil, TaxiFrame, 'BackdropTemplate')
                border:SetAllPoints(routeMap)
                border:SetBackdrop({edgeFile = C.Assets.Textures.Shadow, edgeSize = 3})
                local color = _G.ANDROMEDA_ADB.BorderColor
                border:SetBackdropBorderColor(color.r, color.g, color.b, 0.6)
                routeMap._andmBorder = border
            end
        end)
    end)
end)
