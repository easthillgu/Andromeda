local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    local QuestLogFrame = _G.QuestLogFrame
    if not QuestLogFrame then return end

    F.ReskinPortraitFrame(QuestLogFrame)

    F.StripTextures(_G.QuestLogScrollFrame, 0)

    if C.IS_NEW_PATCH_10_1 then
        F.ReskinTrimScroll(_G.QuestLogScrollFrame.ScrollBar)
    else
        F.ReskinScroll(_G.QuestLogScrollFrameScrollBar)
    end

    F.ReskinButton(_G.QuestLogFrameAbandonButton)
    F.ReskinButton(_G.QuestLogFrameTrackButton)
    F.ReskinButton(_G.QuestLogFrameShareButton)

    hooksecurefunc('QuestLog_UpdateQuestDetails', function()
        local rewardsFrame = _G.QuestInfoFrame.rewardsFrame
        if rewardsFrame then
            for _, name in next, { 'HonorFrame', 'SkillPointFrame', 'ArtifactXPFrame', 'WarModeBonusFrame' } do
                local frame = rewardsFrame[name]
                if frame and not frame.styled then
                    local icon = frame.Icon
                    if icon then
                        F.ReskinIcon(icon)
                    end
                    local bg = F.CreateBDFrame(frame, 0.25)
                    bg:SetPoint('TOPLEFT', icon, 'TOPRIGHT', 2, 0)
                    bg:SetPoint('BOTTOMRIGHT', icon, 100, 0)
                    frame.styled = true
                end
            end
        end
    end)

    _G.QuestLogTitleText:SetTextColor(1, 0.8, 0)
    _G.QuestLogTitleText:SetShadowColor(0, 0, 0)

    local questLogObjectives = _G.QuestLogObjectivesFrame
    if questLogObjectives then
        F.StripTextures(questLogObjectives)
        local bg = F.CreateBDFrame(questLogObjectives, 0.25)
        bg:SetAllPoints()
    end
end)