local F, C = unpack(select(2, ...))

function F.ReplaceIconString(frame, text)
    if not text then text = frame:GetText() end
    if not text or text == '' then return end

    local newText, count = gsub(text, '|T([^:]-):[%d+:]+|t', '|T%1:14:14:0:0:64:64:5:59:5:59|t')
    if count > 0 then frame:SetFormattedText('%s', newText) end
end

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    F.ReskinPortraitFrame(_G.AddonList)

    if _G.AddonList.EnableAllButton then
        F.ReskinButton(_G.AddonList.EnableAllButton)
    else
        F.ReskinButton(_G.AddonListEnableAllButton)
    end
    if _G.AddonList.DisableAllButton then
        F.ReskinButton(_G.AddonList.DisableAllButton)
    else
        F.ReskinButton(_G.AddonListDisableAllButton)
    end
    if _G.AddonList.CancelButton then
        F.ReskinButton(_G.AddonList.CancelButton)
    else
        F.ReskinButton(_G.AddonListCancelButton)
    end
    if _G.AddonList.OkayButton then
        F.ReskinButton(_G.AddonList.OkayButton)
    else
        F.ReskinButton(_G.AddonListOkayButton)
    end

    if _G.AddonList.ForceLoad then
        F.ReskinCheckbox(_G.AddonList.ForceLoad)
        _G.AddonList.ForceLoad:SetSize(18, 18)
    elseif _G.AddonListForceLoad then
        F.ReskinCheckbox(_G.AddonListForceLoad)
        _G.AddonListForceLoad:SetSize(18, 18)
    end

    if _G.AddonList.Dropdown then
        F.ReskinDropdown(_G.AddonList.Dropdown)
    elseif _G.AddonCharacterDropDown then
        F.ReskinDropdown(_G.AddonCharacterDropDown)
        _G.AddonCharacterDropDown:SetWidth(170)
    end

    if _G.AddonList.ScrollBar then
        F.ReskinTrimScroll(_G.AddonList.ScrollBar)
    end

    if _G.AddonList.SearchBox then
        F.ReskinEditbox(_G.AddonList.SearchBox)
    end

    local function forceSaturation(self, _, force)
        if force then
            return
        end
        self:SetVertexColor(C.r, C.g, C.b)
        self:SetDesaturated(true, true)
    end

    local function handleEntry(entry)
        if not entry.styled then
            if entry.Enabled then
                entry.Enabled:SetSize(18, 18)
                F.ReskinCheckbox(entry.Enabled, true)
                hooksecurefunc(entry.Enabled:GetCheckedTexture(), 'SetDesaturated', forceSaturation)
            end
            if entry.LoadAddonButton then
                F.ReskinButton(entry.LoadAddonButton)
            end

            if entry.Title then
                F.ReplaceIconString(entry.Title)
                hooksecurefunc(entry.Title, 'SetText', F.ReplaceIconString)
            end

            entry.styled = true
        end
    end

    if AddonList_InitAddon then
        hooksecurefunc('AddonList_InitAddon', handleEntry)
    elseif AddonList_InitButton then
        hooksecurefunc('AddonList_InitButton', handleEntry)
    end

    hooksecurefunc('AddonList_Update', function()
        for i = 1, _G.MAX_ADDONS_DISPLAYED do
            local entry = _G['AddonListEntry' .. i]
            if entry and entry:IsShown() then
                local checkbox = _G['AddonListEntry' .. i .. 'Enabled']
                if checkbox.forceSaturation then
                    local tex = checkbox:GetCheckedTexture()
                    if checkbox.state == 2 then
                        tex:SetDesaturated(true)
                        tex:SetVertexColor(C.r, C.g, C.b)
                    elseif checkbox.state == 1 then
                        tex:SetVertexColor(1, 0.8, 0, 0.8)
                    end
                end
            end
        end
    end)
end)
