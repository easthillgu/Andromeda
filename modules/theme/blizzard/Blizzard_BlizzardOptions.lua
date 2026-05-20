local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    --[[ Chat Config ]]--
    local chatConfig = _G.ChatConfigFrame
    if chatConfig then
        F.StripTextures(chatConfig)
        F.SetBD(chatConfig)

        -- Chat config tabs
        hooksecurefunc(_G.ChatConfigFrameChatTabManager, 'UpdateWidth', function(tabMgr)
            for tab in tabMgr.tabPool:EnumerateActive() do
                if not tab._andmSkinned then
                    F.StripTextures(tab)
                    F.ReskinButton(tab, true)
                    tab._andmSkinned = true
                end
            end
        end)
    end

    -- Chat config subframes
    local chatFrames = {
        _G.ChatConfigFrame,
        _G.ChatConfigCategoryFrame,
        _G.ChatConfigBackgroundFrame,
        _G.ChatConfigCombatSettingsFilters,
        _G.ChatConfigCombatSettingsFiltersScrollFrame,
        _G.ChatConfigChatSettingsLeft,
        _G.ChatConfigOtherSettingsCombat,
        _G.ChatConfigOtherSettingsPVP,
        _G.ChatConfigOtherSettingsSystem,
        _G.ChatConfigOtherSettingsCreature,
        _G.ChatConfigChannelSettingsAvailable,
        _G.ChatConfigChannelSettingsLeft,
    }
    for _, frame in pairs(chatFrames) do
        if frame then
            F.StripTextures(frame)
            F.SetBD(frame)
        end
    end

    -- Combat config tabs
    for i = 1, 9 do
        local tab = _G['CombatConfigTab' .. i]
        if tab then
            F.ReskinTab(tab)
        end
    end

    -- Chat config buttons
    local chatButtons = {
        _G.ChatConfigFrameDefaultButton,
        _G.ChatConfigFrameRedockButton,
        _G.ChatConfigFrameOkayButton,
        _G.ChatConfigCombatSettingsFiltersDeleteButton,
        _G.ChatConfigCombatSettingsFiltersAddFilterButton,
        _G.ChatConfigCombatSettingsFiltersCopyFilterButton,
        _G.CombatConfigSettingsSaveButton,
        _G.CombatLogDefaultButton,
    }
    for _, btn in pairs(chatButtons) do
        if btn then F.ReskinButton(btn) end
    end

    -- Chat config checkboxes
    local chatCheckboxes = {
        _G.CombatConfigColorsHighlightingLine,
        _G.CombatConfigColorsHighlightingAbility,
        _G.CombatConfigColorsHighlightingDamage,
        _G.CombatConfigColorsHighlightingSchool,
        _G.CombatConfigColorsColorizeUnitNameCheck,
        _G.CombatConfigColorsColorizeSpellNamesCheck,
        _G.CombatConfigColorsColorizeDamageNumberCheck,
        _G.CombatConfigColorsColorizeDamageSchoolCheck,
        _G.CombatConfigColorsColorizeEntireLineCheck,
        _G.CombatConfigFormattingShowTimeStamp,
        _G.CombatConfigFormattingShowBraces,
        _G.CombatConfigFormattingUnitNames,
        _G.CombatConfigFormattingSpellNames,
        _G.CombatConfigFormattingItemNames,
        _G.CombatConfigFormattingFullText,
        _G.CombatConfigSettingsShowQuickButton,
        _G.CombatConfigSettingsSolo,
        _G.CombatConfigSettingsParty,
        _G.CombatConfigSettingsRaid,
    }
    for _, cb in pairs(chatCheckboxes) do
        if cb then F.ReskinCheckbox(cb) end
    end

    -- Chat config editbox
    if _G.CombatConfigSettingsNameEditBox then
        F.ReskinEditbox(_G.CombatConfigSettingsNameEditBox)
    end

    -- Filter move buttons
    if _G.ChatConfigMoveFilterUpButton then
        F.ReskinArrow(_G.ChatConfigMoveFilterUpButton, 'up')
    end
    if _G.ChatConfigMoveFilterDownButton then
        F.ReskinArrow(_G.ChatConfigMoveFilterDownButton, 'down')
    end

    --[[ Interface Options ]]--
    local optionsFrames = {
        _G.InterfaceOptionsFrame,
        _G.InterfaceOptionsFrameCategories,
        _G.InterfaceOptionsFramePanelContainer,
        _G.InterfaceOptionsFrameAddOns,
        _G.VideoOptionsFrame,
        _G.VideoOptionsFrameCategoryFrame,
        _G.VideoOptionsFramePanelContainer,
        _G.Display_,
        _G.Graphics_,
        _G.RaidGraphics_,
    }
    for _, frame in pairs(optionsFrames) do
        if frame then
            F.StripTextures(frame)
            F.SetBD(frame)
        end
    end

    -- Audio panels
    local audioFrames = {
        _G.AudioOptionsSoundPanelHardware,
        _G.AudioOptionsSoundPanelVolume,
        _G.AudioOptionsSoundPanelPlayback,
        _G.AudioOptionsVoicePanelTalking,
        _G.AudioOptionsVoicePanelListening,
        _G.AudioOptionsVoicePanelBinding,
    }
    for _, frame in pairs(audioFrames) do
        if frame then
            F.StripTextures(frame)
            F.CreateBDFrame(frame)
        end
    end

    -- Graphics/Raid buttons
    if _G.GraphicsButton then F.ReskinButton(_G.GraphicsButton) end
    if _G.RaidButton then F.ReskinButton(_G.RaidButton) end

    -- Options panels: iterate children for checkboxes/buttons/sliders/dropdowns
    local panels = {
        _G.InterfaceOptionsControlsPanel,
        _G.InterfaceOptionsCombatPanel,
        _G.InterfaceOptionsDisplayPanel,
        _G.InterfaceOptionsSocialPanel,
        _G.InterfaceOptionsActionBarsPanel,
        _G.InterfaceOptionsNamesPanel,
        _G.InterfaceOptionsNamesPanelFriendly,
        _G.InterfaceOptionsNamesPanelEnemy,
        _G.InterfaceOptionsNamesPanelUnitNameplates,
        _G.InterfaceOptionsCameraPanel,
        _G.InterfaceOptionsMousePanel,
        _G.InterfaceOptionsAccessibilityPanel,
        _G.VideoOptionsFrame,
        _G.Display_,
        _G.Graphics_,
        _G.RaidGraphics_,
        _G.Advanced_,
        _G.NetworkOptionsPanel,
        _G.InterfaceOptionsLanguagesPanel,
        _G.AudioOptionsSoundPanel,
        _G.CompactUnitFrameProfiles,
        _G.CompactUnitFrameProfilesGeneralOptionsFrame,
    }
    for _, panel in pairs(panels) do
        if panel then
            for _, child in pairs({panel:GetChildren()}) do
                if child then
                    if child:IsObjectType('CheckButton') then
                        F.ReskinCheckbox(child)
                    elseif child:IsObjectType('Button') then
                        F.ReskinButton(child)
                    elseif child:IsObjectType('Slider') then
                        F.ReskinSlider(child)
                    elseif child:IsObjectType('Frame')
                        and child.Left and child.Middle and child.Right then
                        F.ReskinDropdown(child)
                    end
                end
            end
        end
    end

    -- Compact Raid Frame profiles
    local newProfile = _G.CompactUnitFrameProfilesNewProfileDialog
    if newProfile then
        F.StripTextures(newProfile)
        F.CreateBDFrame(newProfile)
        if _G.CompactUnitFrameProfilesNewProfileDialogCreateButton then
            F.ReskinButton(_G.CompactUnitFrameProfilesNewProfileDialogCreateButton)
        end
        if _G.CompactUnitFrameProfilesNewProfileDialogCancelButton then
            F.ReskinButton(_G.CompactUnitFrameProfilesNewProfileDialogCancelButton)
        end
    end

    local delProfile = _G.CompactUnitFrameProfilesDeleteProfileDialog
    if delProfile then
        F.StripTextures(delProfile)
        F.CreateBDFrame(delProfile)
        if _G.CompactUnitFrameProfilesDeleteProfileDialogDeleteButton then
            F.ReskinButton(_G.CompactUnitFrameProfilesDeleteProfileDialogDeleteButton)
        end
        if _G.CompactUnitFrameProfilesDeleteProfileDialogCancelButton then
            F.ReskinButton(_G.CompactUnitFrameProfilesDeleteProfileDialogCancelButton)
        end
    end

    --[[ Text to Speech (3.80.1: may not exist) ]]--
    if _G.TextToSpeechButton then
        F.StripTextures(_G.TextToSpeechButton)
    end
    if _G.TextToSpeechDefaultButton then
        F.ReskinButton(_G.TextToSpeechDefaultButton)
    end
end)
