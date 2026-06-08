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
    F.ReskinClose(TaxiFrame.CloseButton, _G.TaxiRouteMap)

    -- 3.80.1: TaxiRouteMap is the flight path map inside TaxiFrame.
    -- Only add shadow border — NO SetBD (dark backdrop covers the map art).
    local routeMap = _G.TaxiRouteMap
    if routeMap then
        F.CreateSD(routeMap)
    end
end)
