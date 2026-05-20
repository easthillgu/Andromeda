local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    return  -- [3.80.1 DISABLED: all frames missing]
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    F.SetBD(_G.GuildInviteFrame)
    for i = 1, 10 do
        select(i, _G.GuildInviteFrame:GetRegions()):Hide()
    end
    F.ReskinButton(_G.GuildInviteFrameJoinButton)
    F.ReskinButton(_G.GuildInviteFrameDeclineButton)
end)
