local F, C = unpack(select(2, ...))

C.Themes['Blizzard_FlightMap'] = function()
    local frame = _G.FlightMapFrame
    _G.FlightMapFrameBg:Hide()
    -- Don't use ReskinPortraitFrame — its StripTextures + dark bg covers the map art
    F.SetBD(frame)
    F.ReskinClose(frame.CloseButton)
end
