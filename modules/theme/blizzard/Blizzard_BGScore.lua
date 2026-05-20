local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    local wssFrame = _G.WorldStateScoreFrame
    if not wssFrame then return end

    wssFrame:EnableMouse(true)
    F.StripTextures(wssFrame)
    F.SetBD(wssFrame)

    -- Close button
    if _G.WorldStateScoreFrameCloseButton then
        F.ReskinClose(_G.WorldStateScoreFrameCloseButton)
    end

    -- Scroll frame
    local scrollFrame = _G.WorldStateScoreScrollFrame
    if scrollFrame then
        F.StripTextures(scrollFrame)
        if _G.WorldStateScoreScrollFrameScrollBar then
            F.ReskinScroll(_G.WorldStateScoreScrollFrameScrollBar)
        end
    end

    -- Sort buttons (KB, Deaths, HK, Damage, Healing, Honor, Name, Class, Team)
    local sortButtons = {
        _G.WorldStateScoreFrameKB,
        _G.WorldStateScoreFrameDeaths,
        _G.WorldStateScoreFrameHK,
        _G.WorldStateScoreFrameDamageDone,
        _G.WorldStateScoreFrameHealingDone,
        _G.WorldStateScoreFrameHonorGained,
        _G.WorldStateScoreFrameName,
        _G.WorldStateScoreFrameClass,
        _G.WorldStateScoreFrameTeam,
    }
    for _, btn in pairs(sortButtons) do
        if btn then F.ReskinButton(btn) end
    end

    -- Leave button
    if _G.WorldStateScoreFrameLeaveButton then
        F.ReskinButton(_G.WorldStateScoreFrameLeaveButton)
    end

    -- Tabs
    for i = 1, 3 do
        local tab = _G['WorldStateScoreFrameTab' .. i]
        if tab then
            F.ReskinTab(tab)
            local tabText = _G['WorldStateScoreFrameTab' .. i .. 'Text']
            if tabText then
                tabText:SetPoint('CENTER', 0, 2)
            end
        end
    end

    -- Column buttons
    for i = 1, 5 do
        local col = _G['WorldStateScoreColumn' .. i]
        if col then F.ReskinButton(col) end
    end
end)
