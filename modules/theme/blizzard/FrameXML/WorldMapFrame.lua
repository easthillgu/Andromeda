local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local WorldMapFrame = _G.WorldMapFrame
    local BorderFrame = WorldMapFrame.BorderFrame

    F.ReskinPortraitFrame(WorldMapFrame)
    if BorderFrame.NineSlice then
        BorderFrame.NineSlice:Hide()
    end
    if BorderFrame.Tutorial then
        BorderFrame.Tutorial.Ring:Hide()
    end
    F.ReskinMinMax(BorderFrame.MaximizeMinimizeFrame)

    local overlayFrames = WorldMapFrame.overlayFrames
    F.ReskinDropdown(overlayFrames[1])
    F.StripTextures(overlayFrames[2], 3)
    F.StripTextures(overlayFrames[3], 3)
    local frame = overlayFrames[3]
    if frame and frame.ActiveTexture then
    frame.ActiveTexture:SetTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Toggle')
    end

    local sideToggle = WorldMapFrame.SidePanelToggle
    if sideToggle then
        sideToggle:SetFrameLevel(3)
    sideToggle.OpenButton:GetRegions():Hide()
    F.ReskinArrow(sideToggle.OpenButton, 'right')
    sideToggle.CloseButton:GetRegions():Hide()
    F.ReskinArrow(sideToggle.CloseButton, 'left')

    F.ReskinNavBar(WorldMapFrame.NavBar)

    for i = 1, #overlayFrames do
        local frame = overlayFrames[i]
        if frame.BountyDropdownButton then
    F.ReskinArrow(frame.BountyDropdownButton, 'right')
            break
        end
    end
    end
end)
