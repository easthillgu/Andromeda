local F, C = unpack(select(2, ...))

C.Themes['Blizzard_FlightMap'] = function()
    return  -- [3.80.1 DISABLED: all frames missing]
    local FlightMapFrame = _G.FlightMapFrame

    F.ReskinPortraitFrame(FlightMapFrame)
    FlightMapFrameBg:Hide()

    if FlightMapFrame.ScrollContainer and FlightMapFrame.ScrollContainer.Child then
        FlightMapFrame.ScrollContainer.Child.TiledBackground:Hide()
    end
end