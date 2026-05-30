local F, C = unpack(select(2, ...))

C.Themes['Blizzard_FlightMap'] = function()
    local frame = _G.FlightMapFrame
    _G.FlightMapFrameBg:Hide()
    -- Don't use SetBD or ReskinPortraitFrame — their dark backdrop covers the map art
    -- Only add shadow border + close button, skip background fill
    F.CreateSD(frame)
    F.ReskinClose(frame.CloseButton)
end
