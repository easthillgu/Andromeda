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

    -- 3.80.1: Close button is TaxiCloseButton (global), NOT TaxiFrame.CloseButton
    local closeBtn = _G.TaxiCloseButton
    if closeBtn then
        F.ReskinClose(closeBtn, TaxiFrame)
    end

    -- 3.80.1: TaxiRouteMap created dynamically when flight master dialog opens.
    -- Use OnShow hook. override=true bypasses ShadowOutline setting check.
    TaxiFrame:HookScript('OnShow', function()
        local routeMap = _G.TaxiRouteMap
        if routeMap and not routeMap._andmStyled then
            routeMap._andmStyled = true
            -- override=true: always create shadow border (ShadowOutline off -> still need frame border)
            F.CreateSD(routeMap, nil, nil, nil, true)
        end
    end)
end)
