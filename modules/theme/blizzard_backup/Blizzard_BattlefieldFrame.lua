local F, C = unpack(select(2, ...))

C.Themes['Blizzard_BattlefieldFrame'] = function()
    local BattlefieldFrame = _G.BattlefieldFrame

    if not BattlefieldFrame then
        return
    end

    F.StripTextures(BattlefieldFrame)
    F.SetBD(BattlefieldFrame)

    F.ReskinButton(BattlefieldFrame.JoinButton)
    F.ReskinButton(BattlefieldFrame.LeaveButton)
    F.ReskinButton(BattlefieldFrame.GroupJoinButton)

    F.ReskinClose(_G.BattlefieldFrameCloseButton)

    if BattlefieldFrame.ScrollFrame then
        F.ReskinTrimScroll(BattlefieldFrame.ScrollFrame.ScrollBar)
    end

    hooksecurefunc('BattlefieldFrame_UpdateButtons', function()
        for i = 1, _G.MAX_BATTLEFIELD_QUEUES do
            local button = _G['BattlefieldQueueFrame' .. i]
            if button and not button.styled then
                F.StripTextures(button)
                button:SetHighlightTexture(C.Assets.Textures.Backdrop)
                local hl = button:GetHighlightTexture()
                hl:SetVertexColor(C.r, C.g, C.b, 0.2)
                hl:SetInside()
                button.styled = true
            end
        end
    end)
end

C.Themes['Blizzard_WorldStateScore'] = function()
    local WorldStateScoreFrame = _G.WorldStateScoreFrame

    if not WorldStateScoreFrame then
        return
    end

    F.ReskinPortraitFrame(WorldStateScoreFrame)
    WorldStateScoreFrame.NineSlice:Hide()

    F.ReskinButton(WorldStateScoreFrame.LeaveButton)
    F.ReskinButton(WorldStateScoreFrame.ScoreButton)

    F.ReskinTrimScroll(WorldStateScoreFrame.ScrollBar)

    hooksecurefunc('WorldStateScoreFrame_Update', function()
        for i = 1, _G.MAX_WORLDSTATE_SCORE_BUTTONS do
            local button = _G['WorldStateScoreButton' .. i]
            if button and not button.styled then
                button:SetHighlightTexture(C.Assets.Textures.Backdrop)
                local hl = button:GetHighlightTexture()
                hl:SetVertexColor(C.r, C.g, C.b, 0.2)
                hl:SetInside()
                button.styled = true
            end
        end
    end)

    local bg = F.CreateBDFrame(WorldStateScoreFrame.ScrollBox, 0.25)
    bg:SetPoint('TOPLEFT', 2, -2)
    bg:SetPoint('BOTTOMRIGHT', -2, 2)
end