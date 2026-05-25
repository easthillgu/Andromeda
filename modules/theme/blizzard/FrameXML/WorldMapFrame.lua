local F, C = unpack(select(2, ...))

-- 3.80.1: WorldMapFrame uses classic Cata structure (no BorderFrame/overlayFrames/NavBar)
C.Themes['Blizzard_WorldMap'] = function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local WMF = _G.WorldMapFrame
    if not WMF then return end

    -- Title
    if _G.WorldMapTitleButton then
        F.ReskinButton(_G.WorldMapTitleButton)
    end
    if _G.WorldMapZoneButton then
        F.ReskinButton(_G.WorldMapZoneButton)
    end

    -- Dropdowns (3.80.1: simple structure, not Retail dropdowns)
    if _G.WorldMapContinentDropdown then
        F.StripTextures(_G.WorldMapContinentDropdown)
        F.CreateBD(_G.WorldMapContinentDropdown, 0.25)
    end
    if _G.WorldMapZoneDropdown then
        F.StripTextures(_G.WorldMapZoneDropdown)
        F.CreateBD(_G.WorldMapZoneDropdown, 0.25)
    end
    if _G.WorldMapZoneMinimapDropdown then
        F.StripTextures(_G.WorldMapZoneMinimapDropdown)
        F.CreateBD(_G.WorldMapZoneMinimapDropdown, 0.25)
    end

    -- Zoom buttons (arrows)
    if _G.WorldMapZoomOutButton then
        F.ReskinArrow(_G.WorldMapZoomOutButton, 'up')
    end
    if _G.WorldMapLevelUpButton then
        F.ReskinArrow(_G.WorldMapLevelUpButton, 'up')
    end
    if _G.WorldMapLevelDownButton then
        F.ReskinArrow(_G.WorldMapLevelDownButton, 'down')
    end
    if _G.WorldMapMagnifyingGlassButton then
        F.ReskinButton(_G.WorldMapMagnifyingGlassButton)
    end

    -- Close button
    if _G.WorldMapFrameCloseButton then
        F.ReskinClose(_G.WorldMapFrameCloseButton)
    end

    -- Hide decorative borders
    if _G.MiniBorderLeft then _G.MiniBorderLeft:Hide() end
    if _G.MiniBorderRight then _G.MiniBorderRight:Hide() end

    -- Maximize/Minimize (retail-style, may not exist in 3.80.1)
    if WMF.MaximizeMinimizeFrame then
        F.ReskinMinMax(WMF.MaximizeMinimizeFrame)
    end

    -- Opacity slider
    if _G.OpacityFrame then
        F.StripTextures(_G.OpacityFrame)
        F.SetBD(_G.OpacityFrame)
        if _G.OpacityFrameSlider then
            F.ReskinSlider(_G.OpacityFrameSlider, true)
        end
    end

    -- Quest scroll frame
    if _G.QuestScrollFrame and _G.QuestScrollFrame.ScrollBar then
        F.ReskinTrimScroll(_G.QuestScrollFrame.ScrollBar)
    end
    if _G.QuestMapDetailsScrollFrameScrollBar then
        F.ReskinScroll(_G.QuestMapDetailsScrollFrameScrollBar)
    end

    -- Track quest button
    if _G.WorldMapTrackQuest then
        F.ReskinButton(_G.WorldMapTrackQuest)
    end
    if _G.WorldMapQuestShowObjectives then
        F.ReskinCheckbox(_G.WorldMapQuestShowObjectives)
    end

    -- ScrollContainer (map area) — no StripTextures to preserve map tiles
    if WMF.ScrollContainer then
        F.CreateBD(WMF.ScrollContainer, 0.25)
        F.CreateTex(WMF.ScrollContainer)
    end

    -- Portrait frame
    F.ReskinPortraitFrame(WMF)

    -- Background
    F.CreateBD(WMF, 0.75)
    F.CreateSD(WMF, 0.25)
    F.CreateTex(WMF)
end
