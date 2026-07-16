local F, C = unpack(select(2, ...))

C.Themes['Blizzard_RaidUI'] = function()
    local r, g, b = C.r, C.g, C.b

    for i = 1, _G.NUM_RAID_GROUPS do
        local group = _G['RaidGroup' .. i]
        if group then
            local region = group:GetRegions()
            if region then region:SetAlpha(0) end
            for j = 1, _G.MEMBERS_PER_RAID_GROUP do
                local slot = _G['RaidGroup' .. i .. 'Slot' .. j]
                if slot then
                    local region1 = select(1, slot:GetRegions())
                    if region1 then region1:SetAlpha(0) end
                    local region2 = select(2, slot:GetRegions())
                    if region2 then
                        region2:SetColorTexture(r, g, b, 0.25)
                    end
                    F.CreateBDFrame(slot, 0.2)
                end
            end
        end
    end

    for i = 1, _G.MAX_RAID_MEMBERS do
        local bu = _G['RaidGroupButton' .. i]
        if bu then
            F.StripTextures(bu)
            F.CreateBDFrame(bu)
        end
    end

    if _G.RaidFrameReadyCheckButton then
        F.ReskinButton(_G.RaidFrameReadyCheckButton)
    end

    if _G.RAID_CLASS_BUTTONS then
        for class, value in pairs(_G.RAID_CLASS_BUTTONS) do
            local bu = _G['RaidClassButton' .. value.button]
            local icon = _G['RaidClassButton' .. value.button .. 'IconTexture']
            if bu then
                local region = bu:GetRegions()
                if region then region:Hide() end
                F.CreateBDFrame(bu)
                if icon then
                    if value.button > 10 then
                        icon:SetTexCoord(unpack(C.TEX_COORD))
                    else
                        F.ClassIconTexCoord(icon, class)
                    end
                end
                local hl = bu:GetHighlightTexture()
                if hl then
                    hl:SetColorTexture(1, 1, 1, 0.25)
                end
            end
        end
    end
end