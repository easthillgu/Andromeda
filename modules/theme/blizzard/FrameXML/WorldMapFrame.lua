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
        pcall(F.ReskinButton, _G.WorldMapTitleButton)
    end
    if _G.WorldMapZoneButton then
        pcall(F.ReskinButton, _G.WorldMapZoneButton)
    end

    -- Dropdowns (3.80.1: simple structure, not Retail dropdowns)
    if _G.WorldMapContinentDropdown then
        pcall(F.StripTextures, _G.WorldMapContinentDropdown)
        pcall(F.CreateBD, _G.WorldMapContinentDropdown, 0.25)
    end
    if _G.WorldMapZoneDropdown then
        pcall(F.StripTextures, _G.WorldMapZoneDropdown)
        pcall(F.CreateBD, _G.WorldMapZoneDropdown, 0.25)
    end
    if _G.WorldMapZoneMinimapDropdown then
        pcall(F.StripTextures, _G.WorldMapZoneMinimapDropdown)
        pcall(F.CreateBD, _G.WorldMapZoneMinimapDropdown, 0.25)
    end

    -- Zoom buttons (arrows)
    if _G.WorldMapZoomOutButton then
        pcall(F.ReskinArrow, _G.WorldMapZoomOutButton, 'up')
    end
    if _G.WorldMapLevelUpButton then
        pcall(F.ReskinArrow, _G.WorldMapLevelUpButton, 'up')
    end
    if _G.WorldMapLevelDownButton then
        pcall(F.ReskinArrow, _G.WorldMapLevelDownButton, 'down')
    end
    if _G.WorldMapMagnifyingGlassButton then
        pcall(F.ReskinButton, _G.WorldMapMagnifyingGlassButton)
    end

    -- Close button
    if _G.WorldMapFrameCloseButton then
        pcall(F.ReskinClose, _G.WorldMapFrameCloseButton)
    end

    -- Hide decorative borders
    if _G.MiniBorderLeft then _G.MiniBorderLeft:Hide() end
    if _G.MiniBorderRight then _G.MiniBorderRight:Hide() end

    -- Maximize/Minimize (retail-style, may not exist in 3.80.1)
    if WMF.MaximizeMinimizeFrame then
        pcall(F.ReskinMinMax, WMF.MaximizeMinimizeFrame)
    end

    -- Opacity slider
    if _G.OpacityFrame then
        pcall(F.StripTextures, _G.OpacityFrame)
        pcall(F.SetBD, _G.OpacityFrame)
        if _G.OpacityFrameSlider then
            pcall(F.ReskinSlider, _G.OpacityFrameSlider, true)
        end
    end

    -- Quest scroll frame
    if _G.QuestScrollFrame and _G.QuestScrollFrame.ScrollBar then
        pcall(F.ReskinTrimScroll, _G.QuestScrollFrame.ScrollBar)
    end
    if _G.QuestMapDetailsScrollFrameScrollBar then
        pcall(F.ReskinScroll, _G.QuestMapDetailsScrollFrameScrollBar)
    end

    -- Track quest button
    if _G.WorldMapTrackQuest then
        pcall(F.ReskinButton, _G.WorldMapTrackQuest)
    end
    if _G.WorldMapQuestShowObjectives then
        pcall(F.ReskinCheckbox, _G.WorldMapQuestShowObjectives)
    end

    -- ScrollContainer (map area) — no StripTextures to preserve map tiles
    if WMF.ScrollContainer then
        pcall(F.CreateBD, WMF.ScrollContainer, 0.25)
        pcall(F.CreateTex, WMF.ScrollContainer)
    end

    -- Portrait frame
    pcall(F.ReskinPortraitFrame, WMF)

    -- Background
    pcall(F.CreateBD, WMF, 0.75)
    pcall(F.CreateSD, WMF, 0.25)
    pcall(F.CreateTex, WMF)
end
