local F, C = unpack(select(2, ...))

C.Themes['Blizzard_FlightMap'] = function()
    F.ReskinPortraitFrame(_G.FlightMapFrame)
    _G.FlightMapFrameBg:Hide()
    -- 3.80.1: TiledBackground is the actual map surface, don't hide it
end
