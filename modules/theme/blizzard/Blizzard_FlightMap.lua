local F, C = unpack(select(2, ...))

-- 3.80.1: Blizzard_FlightMap addon (Retail flight map). May not exist in Cata Classic,
-- but if it does, style it without covering the actual map content.
C.Themes['Blizzard_FlightMap'] = function()
    local frame = _G.FlightMapFrame
    if not frame then return end

    -- NDui reference: hide Blizzard decorative background (safe — not map content)
    if _G.FlightMapFrameBg then
        _G.FlightMapFrameBg:Hide()
    end

    -- 3.80.1: Use CreateSD only — NO SetBD or ReskinPortraitFrame!
    -- Both would create a dark backdrop covering the map → black screen.
    F.CreateSD(frame)

    -- Close button
    if frame.CloseButton then
        F.ReskinClose(frame.CloseButton)
    end

    -- 3.80.1: Do NOT hide TiledBackground — it IS the map rendering surface.
    -- NDui hides it but that causes a completely black map in Cata Classic.
end
