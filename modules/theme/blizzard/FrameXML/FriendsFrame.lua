local F, C = unpack(select(2, ...))

local atlasToTex = {
    ['friendslist-invitebutton-horde-normal'] = 'Interface\\FriendsFrame\\PlusManz-Horde',
    ['friendslist-invitebutton-alliance-normal'] = 'Interface\\FriendsFrame\\PlusManz-Alliance',
    ['friendslist-invitebutton-default-normal'] = 'Interface\\FriendsFrame\\PlusManz-PlusManz',
}
local function replaceInviteTex(self, atlas)
    local tex = atlasToTex[atlas]
    if tex then
        self.ownerIcon:SetTexture(tex)
    end
end

local function reskinFriendButton(button)
    if not button.styled then
        local gameIcon = button.gameIcon
        gameIcon:SetSize(22, 22)
        gameIcon:SetTexCoord(0.17, 0.83, 0.17, 0.83)
        button.background:Hide()
        button:SetHighlightTexture(C.Assets.Textures.Backdrop)
        button:GetHighlightTexture():SetVertexColor(0.24, 0.56, 1, 0.2)
        button.bg = F.CreateBDFrame(gameIcon, 0)

        local travelPass = button.travelPassButton
        travelPass:SetSize(22, 22)
        travelPass:SetPoint('TOPRIGHT', -3, -6)
        F.CreateBDFrame(travelPass, 1)
        if travelPass.NormalTexture then travelPass.NormalTexture:SetAlpha(0) end
        if travelPass.PushedTexture then travelPass.PushedTexture:SetAlpha(0) end
        if travelPass.DisabledTexture then travelPass.DisabledTexture:SetAlpha(0) end
        if travelPass.HighlightTexture then
            travelPass.HighlightTexture:SetColorTexture(1, 1, 1, 0.25)
            travelPass.HighlightTexture:SetAllPoints()
        end
        gameIcon:SetPoint('TOPRIGHT', travelPass, 'TOPLEFT', -4, 0)

        local icon = travelPass:CreateTexture(nil, 'ARTWORK')
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        icon:SetAllPoints()
        button.newIcon = icon
        if travelPass.NormalTexture then
            travelPass.NormalTexture.ownerIcon = icon
            hooksecurefunc(travelPass.NormalTexture, 'SetAtlas', replaceInviteTex)
        end

        button.styled = true
    end

    button.bg:SetShown(button.gameIcon:IsShown())
end

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    for i = 1, 4 do
        local tab = _G['FriendsFrameTab' .. i]
        if tab then
            F.ReskinTab(tab)
            F.ResetTabAnchor(tab)

            if i ~= 1 then
                tab:ClearAllPoints()
                tab:SetPoint('TOPLEFT', _G['FriendsFrameTab' .. (i - 1)], 'TOPRIGHT', -10, 0)
            end
        end
    end
    _G.FriendsFrameIcon:Hide()
    F.StripTextures(_G.IgnoreListFrame)

    local INVITE_RESTRICTION_NONE = 9
    hooksecurefunc('FriendsFrame_UpdateFriendButton', function(button)
        if button.gameIcon then
            reskinFriendButton(button)
        end

        if button.newIcon and button.buttonType == _G.FRIENDS_BUTTON_TYPE_BNET then
            if FriendsFrame_GetInviteRestriction(button.id) == INVITE_RESTRICTION_NONE then
                button.newIcon:SetVertexColor(1, 1, 1)
            else
                button.newIcon:SetVertexColor(0.5, 0.5, 0.5)
            end
        end
    end)

    if _G.FriendsFrame_UpdateFriendInviteButton then
        hooksecurefunc('FriendsFrame_UpdateFriendInviteButton', function(button)
            if not button.styled then
                F.ReskinButton(button.AcceptButton)
                F.ReskinButton(button.DeclineButton)

                button.styled = true
            end
        end)
    end

    if _G.FriendsFrame_UpdateFriendInviteHeaderButton then
        hooksecurefunc('FriendsFrame_UpdateFriendInviteHeaderButton', function(button)
        if not button.styled then
            button:DisableDrawLayer('BACKGROUND')
            local bg = F.CreateBDFrame(button, 0.25)
            bg:SetInside(button, 2, 2)
            local hl = button:GetHighlightTexture()
            hl:SetColorTexture(0.24, 0.56, 1, 0.2)
            hl:SetInside(bg)

            button.styled = true
        end
    end)
    end

    if _G.FriendsFrameStatusDropDown then
    _G.FriendsFrameStatusDropDown:ClearAllPoints()
    _G.FriendsFrameStatusDropDown:SetPoint('TOPLEFT', _G.FriendsFrame, 'TOPLEFT', 10, -28)
    end

    -- FriendsFrameBattlenetFrame

    _G.FriendsFrameBattlenetFrame:GetRegions():Hide()
    local bg = F.CreateBDFrame(_G.FriendsFrameBattlenetFrame, 0.25)
    bg:SetPoint('TOPLEFT', 0, -2)
    bg:SetPoint('BOTTOMRIGHT', -2, 2)
    bg:SetBackdropColor(0, 0.6, 1, 0.25)

    local broadcastButton = _G.FriendsFrameBattlenetFrame.BroadcastButton
    broadcastButton:SetSize(20, 20)
    broadcastButton:GetNormalTexture():SetAlpha(0)
    broadcastButton:GetPushedTexture():SetAlpha(0)
    F.ReskinButton(broadcastButton)
    local newIcon = broadcastButton:CreateTexture(nil, 'ARTWORK')
    newIcon:SetAllPoints()
    newIcon:SetTexture('Interface\\FriendsFrame\\BroadcastIcon')

    local broadcastFrame = _G.FriendsFrameBattlenetFrame.BroadcastFrame
    F.StripTextures(broadcastFrame)
    F.SetBD(broadcastFrame, nil, 10, -10, -10, 10)
    if broadcastFrame.EditBox then
        broadcastFrame.EditBox:DisableDrawLayer('BACKGROUND')
    end

    if broadcastFrame.EditBox then
        local ebbg = F.CreateBDFrame(broadcastFrame.EditBox, 0, true)
        ebbg:SetPoint('TOPLEFT', -2, -2)
        ebbg:SetPoint('BOTTOMRIGHT', 2, 2)
    end

    F.ReskinButton(broadcastFrame.UpdateButton)
    F.ReskinButton(broadcastFrame.CancelButton)
    broadcastFrame:ClearAllPoints()
    broadcastFrame:SetPoint('TOPLEFT', _G.FriendsFrame, 'TOPRIGHT', 3, 0)

    local unavailableFrame = _G.FriendsFrameBattlenetFrame.UnavailableInfoFrame
    F.StripTextures(unavailableFrame)
    F.SetBD(unavailableFrame)
    unavailableFrame:SetPoint('TOPLEFT', _G.FriendsFrame, 'TOPRIGHT', 3, -18)

    F.ReskinPortraitFrame(_G.FriendsFrame)
    F.ReskinButton(_G.FriendsFrameAddFriendButton)
    F.ReskinButton(_G.FriendsFrameSendMessageButton)
    F.ReskinButton(_G.FriendsFrameIgnorePlayerButton)
    F.ReskinButton(_G.FriendsFrameUnsquelchButton)
    F.ReskinScroll(_G.FriendsFrameFriendsScrollFrameScrollBar)
    F.ReskinScroll(_G.FriendsFrameIgnoreScrollFrameScrollBar)
    F.ReskinScroll(_G.WhoListScrollFrameScrollBar)
    F.ReskinScroll(_G.FriendsFriendsScrollFrameScrollBar)
    F.ReskinDropdown(_G.FriendsFrameStatusDropDown)
    F.ReskinDropdown(_G.WhoFrameDropDown)
    F.ReskinDropdown(_G.FriendsFriendsFrameDropDown)
    F.ReskinButton(_G.FriendsListFrameContinueButton)
    F.ReskinEditbox(_G.AddFriendNameEditBox)
    F.StripTextures(_G.AddFriendFrame)
    F.SetBD(_G.AddFriendFrame)
    F.StripTextures(_G.FriendsFriendsFrame)
    F.SetBD(_G.FriendsFriendsFrame)
    F.ReskinButton(_G.FriendsFriendsFrame.SendRequestButton)
    F.ReskinButton(_G.FriendsFriendsFrame.CloseButton)
    F.ReskinButton(_G.WhoFrameWhoButton)
    F.ReskinButton(_G.WhoFrameAddFriendButton)
    F.ReskinButton(_G.WhoFrameGroupInviteButton)
    F.ReskinButton(_G.AddFriendEntryFrameAcceptButton)
    F.ReskinButton(_G.AddFriendEntryFrameCancelButton)
    F.ReskinButton(_G.AddFriendInfoFrameContinueButton)

    for i = 1, 4 do
        F.StripTextures(_G['WhoFrameColumnHeader' .. i])
    end

    F.StripTextures(_G.WhoFrameListInset)
    if _G.WhoFrameEditBoxInset then
        _G.WhoFrameEditBoxInset:Hide()
    end
    local whoBg = F.CreateBDFrame(_G.WhoFrameEditBox, 0, true)
    whoBg:SetPoint('TOPLEFT', _G.WhoFrameEditBoxInset)
    whoBg:SetPoint('BOTTOMRIGHT', _G.WhoFrameEditBoxInset, -1, 1)

    for i = 1, 3 do
        F.StripTextures(_G['FriendsTabHeaderTab' .. i])
    end

    _G.WhoFrameWhoButton:SetPoint('RIGHT', _G.WhoFrameAddFriendButton, 'LEFT', -1, 0)
    _G.WhoFrameAddFriendButton:SetPoint('RIGHT', _G.WhoFrameGroupInviteButton, 'LEFT', -1, 0)
    _G.FriendsFrameTitleText:SetPoint('TOP', _G.FriendsFrame, 'TOP', 0, -8)

    -- Recruite frame

    local RecruitAFriendFrame = _G.RecruitAFriendFrame
    if RecruitAFriendFrame then  -- 3.80.1
        RecruitAFriendFrame.SplashFrame.Description:SetTextColor(1, 1, 1)
        F.ReskinButton(RecruitAFriendFrame.SplashFrame.OKButton)
        F.StripTextures(RecruitAFriendFrame.RewardClaiming)
        F.ReskinButton(RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton)
        F.ReskinButton(RecruitAFriendFrame.RecruitmentButton)

        local recruitList = RecruitAFriendFrame.RecruitList
        F.StripTextures(recruitList.Header)
        F.CreateBDFrame(recruitList.Header, 0.25)
        recruitList.ScrollFrameInset:Hide()
        F.ReskinTrimScroll(recruitList.ScrollBar)
    end

    local recruitmentFrame = _G.RecruitAFriendRecruitmentFrame
    if recruitmentFrame then  -- 3.80.1
        F.StripTextures(recruitmentFrame)
        F.ReskinClose(recruitmentFrame.CloseButton)
        F.SetBD(recruitmentFrame)
        F.StripTextures(recruitmentFrame.EditBox)
        local ebBg = F.CreateBDFrame(recruitmentFrame.EditBox, 0.25)
        ebBg:SetPoint('TOPLEFT', -3, -3)
        ebBg:SetPoint('BOTTOMRIGHT', 0, 3)
        F.ReskinButton(recruitmentFrame.GenerateOrCopyLinkButton)
    end

    local rewardsFrame = _G.RecruitAFriendRewardsFrame
    if rewardsFrame then  -- 3.80.1
        F.StripTextures(rewardsFrame)
        F.ReskinClose(rewardsFrame.CloseButton)
        F.SetBD(rewardsFrame)

        rewardsFrame:HookScript('OnShow', function(self)
            for i = 1, self:GetNumChildren() do
                local child = select(i, self:GetChildren())
                local button = child and child.Button
                if button and not button.styled then
                    F.ReskinIcon(button.Icon)
                    button.IconBorder:Hide()
                    button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)

                    button.styled = true
                end
            end
        end)
    end

    -- GuildFrame (3.80.1: ported from NDui, was in separate Retail-only files)

    if _G.GuildFrame then
        F.StripTextures(_G.GuildFrame)
        F.ReskinArrow(_G.GuildFrameGuildListToggleButton, 'right')
        F.ReskinButton(_G.GuildFrameGuildInformationButton)
        F.ReskinButton(_G.GuildFrameAddMemberButton)
        F.ReskinButton(_G.GuildFrameControlButton)
        F.StripTextures(_G.GuildFrameLFGFrame)
        F.ReskinCheckbox(_G.GuildFrameLFGButton)
        F.ReskinScroll(_G.GuildListScrollFrameScrollBar)
        for i = 1, 4 do
            local tab = _G['GuildFrameColumnHeader' .. i]
            if tab then
                local bg = F.ReskinTab(tab)
                if bg then
                    bg:SetPoint('TOPLEFT', 5, -2)
                    bg:SetPoint('BOTTOMRIGHT', 0, 0)
                end
            end
            local statusTab = _G['GuildFrameGuildStatusColumnHeader' .. i]
            if statusTab then
                local bg = F.ReskinTab(statusTab)
                if bg then
                    bg:SetPoint('TOPLEFT', 5, -2)
                    bg:SetPoint('BOTTOMRIGHT', 0, 0)
                end
            end
        end

        -- Member detail
        if _G.GuildMemberDetailFrame then
            F.StripTextures(_G.GuildMemberDetailFrame)
            F.SetBD(_G.GuildMemberDetailFrame)
            _G.GuildMemberDetailFrame:SetPoint('TOPLEFT', _G.GuildFrame, 'TOPRIGHT', 4, -15)
            F.ReskinClose(_G.GuildMemberDetailCloseButton)
            if _G.GuildMemberNoteBackground then
                F.StripTextures(_G.GuildMemberNoteBackground)
                F.CreateBDFrame(_G.GuildMemberNoteBackground, .25)
            end
            if _G.GuildMemberOfficerNoteBackground then
                F.StripTextures(_G.GuildMemberOfficerNoteBackground)
                F.CreateBDFrame(_G.GuildMemberOfficerNoteBackground, .25)
            end
        end

        F.ReskinArrow(_G.GuildFramePromoteButton, 'up')
        F.ReskinArrow(_G.GuildFrameDemoteButton, 'down')
        _G.GuildFramePromoteButton:SetHitRectInsets(0, 0, 0, 0)
        _G.GuildFrameDemoteButton:SetHitRectInsets(0, 0, 0, 0)
        _G.GuildFrameDemoteButton:SetPoint('LEFT', _G.GuildFramePromoteButton, 'RIGHT', 4, 0)
        F.ReskinButton(_G.GuildMemberRemoveButton)
        F.ReskinButton(_G.GuildMemberGroupInviteButton)

        -- Guild info
        if _G.GuildInfoFrame then
            F.StripTextures(_G.GuildInfoFrame)
            F.SetBD(_G.GuildInfoFrame)
            F.ReskinScroll(_G.GuildInfoFrameScrollFrameScrollBar)
            F.ReskinClose(_G.GuildInfoCloseButton)
            if _G.GuildInfoTextBackground then
                F.StripTextures(_G.GuildInfoTextBackground)
                F.CreateBDFrame(_G.GuildInfoTextBackground, .25)
            end
            F.ReskinButton(_G.GuildInfoSaveButton)
            F.ReskinButton(_G.GuildInfoCancelButton)
            F.ReskinButton(_G.GuildInfoGuildEventButton)
        end

        -- Event log
        if _G.GuildEventLogFrame then
            F.StripTextures(_G.GuildEventLogFrame)
            F.SetBD(_G.GuildEventLogFrame)
            F.ReskinClose(_G.GuildEventLogCloseButton)
            F.ReskinScroll(_G.GuildEventLogScrollFrameScrollBar)
            F.ReskinButton(_G.GuildEventLogCancelButton)
        end
        if _G.GuildEventFrame then
            F.StripTextures(_G.GuildEventFrame)
            F.CreateBDFrame(_G.GuildEventFrame, .25)
        end

        -- Guild control popup
        if _G.GuildControlPopupFrame then
            F.StripTextures(_G.GuildControlPopupFrame)
            _G.GuildControlPopupFrame:SetPoint('TOPLEFT', _G.GuildFrame, 'TOPRIGHT', 3, 0)
            F.SetBD(_G.GuildControlPopupFrame)
            F.ReskinDropdown(_G.GuildControlPopupFrameDropdown)
            F.ReskinArrow(_G.GuildControlPopupFrameAddRankButton, 'right')
            F.StripTextures(_G.GuildControlPopupFrameEditBox)
            local bg = F.CreateBDFrame(_G.GuildControlPopupFrameEditBox, 0, true)
            bg:SetPoint('TOPLEFT', -5, -5)
            bg:SetPoint('BOTTOMRIGHT', 5, 5)
            F.ReskinButton(_G.GuildControlPopupAcceptButton)
            F.ReskinButton(_G.GuildControlPopupFrameCancelButton)

            for i = 1, 16 do
                local checkbox = _G['GuildControlPopupFrameCheckbox' .. i]
                if checkbox then
                    F.ReskinCheckbox(checkbox)
                end
            end

            if _G.GuildControlWithdrawGoldEditBox then
                F.ReskinEditbox(_G.GuildControlWithdrawGoldEditBox)
                _G.GuildControlWithdrawGoldEditBox.bg:SetPoint('TOPLEFT', -2, -7)
                _G.GuildControlWithdrawGoldEditBox.bg:SetPoint('BOTTOMRIGHT', 2, 7)
            end
            if _G.GuildControlWithdrawItemsEditBox then
                F.ReskinEditbox(_G.GuildControlWithdrawItemsEditBox)
                _G.GuildControlWithdrawItemsEditBox.bg:SetPoint('TOPLEFT', -2, -7)
                _G.GuildControlWithdrawItemsEditBox.bg:SetPoint('BOTTOMRIGHT', 2, 7)
            end

            F.ReskinCheckbox(_G.GuildControlTabPermissionsViewTab)
            F.ReskinCheckbox(_G.GuildControlTabPermissionsDepositItems)
            F.ReskinCheckbox(_G.GuildControlTabPermissionsUpdateText)
            if _G.GuildControlPopupFrameTabPermissions then
                _G.GuildControlPopupFrameTabPermissions:HideBackdrop()
            end
        end

        -- Font width fix
        for i = 1, 13 do
            local level = _G['GuildFrameButton' .. i .. 'Level']
            if level then level:SetWidth(30) end
        end
    end
end)
