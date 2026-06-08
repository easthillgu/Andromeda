local F, C = unpack(select(2, ...))

C.Themes['Blizzard_RaidUI'] = function()
    local r, g, b = C.r, C.g, C.b

    for i = 1, _G.NUM_RAID_GROUPS do
        local group = _G['RaidGroup' .. i]
        if group then
            group:GetRegions():SetAlpha(0)
            for j = 1, _G.MEMBERS_PER_RAID_GROUP do
                local slot = _G['RaidGroup' .. i .. 'Slot' .. j]
                if slot then
                    select(1, slot:GetRegions()):SetAlpha(0)
                    local region = select(2, slot:GetRegions())
                    if region then
                        region:SetColorTexture(r, g, b, 0.25)
                    end
                    F.CreateBDFrame(slot, 0.2)
                end
            end
        end
    end

    for i = 1, _G.MAX_RAID_MEMBERS do
        local bu = _G['RaidGroupButton' .. i]
        if bu then
            -- 仅隐藏特定区域，保留玩家信息显示
            local region4 = select(4, bu:GetRegions())
            if region4 then region4:SetAlpha(0) end
            local region5 = select(5, bu:GetRegions())
            if region5 then region5:SetColorTexture(r, g, b, 0.2) end
            F.CreateBDFrame(bu)
        end
    end

    -- 就绪检查按钮
    if _G.RaidFrameReadyCheckButton then
        F.ReskinButton(_G.RaidFrameReadyCheckButton)
    end

    -- 职业按钮
    if _G.RAID_CLASS_BUTTONS then
        for class, value in pairs(_G.RAID_CLASS_BUTTONS) do
            local bu = _G['RaidClassButton' .. value.button]
            local icon = _G['RaidClassButton' .. value.button .. 'IconTexture']
            if bu then
                bu:GetRegions():Hide()
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
