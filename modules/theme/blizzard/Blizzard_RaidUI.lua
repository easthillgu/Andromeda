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
            local region4 = select(4, bu:GetRegions())
            if region4 then
                region4:SetAlpha(0)
            end
            local region5 = select(5, bu:GetRegions())
            if region5 then
                region5:SetColorTexture(r, g, b, 0.2)
            end
            F.CreateBDFrame(bu)
        end
    end
end
