local F, C = unpack(select(2, ...))

C.Themes['Blizzard_InspectUI'] = function()
    -- Inspect Model Frame
    if _G.InspectModelFrame then
        F.StripTextures(_G.InspectModelFrame, true)
    end

    -- Guild background
    if _G.InspectGuildFrameBG then
        _G.InspectGuildFrameBG:Hide()
    end

    -- Equipment slots (Inspect*Slot prefix)
    local slots = {
        'Head', 'Neck', 'Shoulder', 'Shirt', 'Chest', 'Waist', 'Legs', 'Feet',
        'Wrist', 'Hands', 'Finger0', 'Finger1', 'Trinket0', 'Trinket1',
        'Back', 'MainHand', 'SecondaryHand', 'Tabard', 'Ranged',
    }

    for i = 1, #slots do
        local slot = _G['Inspect' .. slots[i] .. 'Slot']
        if slot then
            -- 3.80.1: SetNormalTexture(0) ineffective, use Hide
            local nt = slot:GetNormalTexture()
            if nt then nt:Hide() end
            local pt = slot:GetPushedTexture()
            if pt then pt:Hide() end
            local hl = slot:GetHighlightTexture()
            if hl then hl:SetColorTexture(1, 1, 1, 0.25) end
            slot.SetHighlightTexture = function() end

            if slot.icon then
                slot.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                slot.icon:SetInside()
            end

            slot.bg = F.CreateBDFrame(slot, 0.25)

            if slot.IconBorder then
                F.ReskinIconBorder(slot.IconBorder)
            end

            if slot.IconOverlay then
                slot.IconOverlay:SetInside()
            end
        end
    end

    -- Update hook: icon visibility
    hooksecurefunc('InspectPaperDollItemSlotButton_Update', function(button)
        if button and button.icon then
            button.icon:SetShown(button.hasItem ~= nil and button.hasItem or false)
        end
    end)

    -- Main frames
    if _G.InspectFrame then
        F.ReskinPortraitFrame(_G.InspectFrame)
    end
    if _G.InspectPaperDollFrame then
        F.StripTextures(_G.InspectPaperDollFrame)
    end

    -- View button
    if _G.InspectPaperDollFrame and _G.InspectPaperDollFrame.ViewButton then
        F.ReskinButton(_G.InspectPaperDollFrame.ViewButton)
    end

    -- Inspect talents button
    if _G.InspectPaperDollItemsFrame and _G.InspectPaperDollItemsFrame.InspectTalents then
        F.ReskinButton(_G.InspectPaperDollItemsFrame.InspectTalents)
    end

    -- Tabs
    for i = 1, 3 do
        local tab = _G['InspectFrameTab' .. i]
        if tab then F.ReskinTab(tab) end
    end

    -- Model rotation buttons
    if _G.InspectModelFrame then
        for _, dir in pairs({'Left', 'Right'}) do
            local btn = _G['InspectModelFrameRotate' .. dir .. 'Button']
            if btn then F.ReskinButton(btn) end
        end
    end

    -- PVP Frame
    if _G.InspectPVPFrame then
        if _G.InspectPVPFrame.BG then
            _G.InspectPVPFrame.BG:Hide()
        end
        F.StripTextures(_G.InspectPVPFrame)
        for i = 1, 3 do
            local bg = _G['InspectPVPTeam' .. i .. 'Background']
            if bg then
                F.StripTextures(_G['InspectPVPTeam' .. i])
                F.CreateBDFrame(bg, 0.25)
            end
        end
    end

    -- Talent Frame
    if _G.InspectTalentFrame then
        F.StripTextures(_G.InspectTalentFrame)
        if _G.InspectTalentFramePointsBar then
            F.StripTextures(_G.InspectTalentFramePointsBar)
        end

        local spec = _G.InspectTalentFrame.InspectSpec
        if spec then
            if spec.ring then spec.ring:Hide() end
            if spec.specIcon then
                F.ReskinIcon(spec.specIcon)
            end
            if spec.roleIcon then
                spec.roleIcon:SetTexture(C.Assets.Textures.RoleLfgIcons)
                F.CreateBDFrame(spec.roleIcon)
            end
        end

        -- Talent rows
        if _G.InspectTalentFrame.InspectTalents then
            for i = 1, 7 do
                local row = _G.InspectTalentFrame.InspectTalents['tier' .. i]
                if row then
                    for j = 1, 3 do
                        local bu = row['talent' .. j]
                        if bu then
                            if bu.Slot then bu.Slot:Hide() end
                            if bu.border then bu.border:SetTexture('') end
                            if bu.icon then F.ReskinIcon(bu.icon) end
                        end
                    end
                end
            end
        end
    end
end
