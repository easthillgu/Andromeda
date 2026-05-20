local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    -- 3.80.1: nil guard for ChannelFrame
    local channelFrame = _G.ChannelFrame
    if not channelFrame then return end

    F.StripTextures(channelFrame)
    F.SetBD(channelFrame)

    if channelFrame.SettingsButton then
        F.ReskinButton(channelFrame.SettingsButton)
    end
    if channelFrame.NewButton then
        F.ReskinButton(channelFrame.NewButton)
    end
    if _G.ChannelFrameCloseButton then
        F.ReskinClose(_G.ChannelFrameCloseButton)
    end

    -- Channel roster scroll
    if channelFrame.ChannelRoster and channelFrame.ChannelRoster.ScrollFrame then
        local scrollBar = channelFrame.ChannelRoster.ScrollFrame.scrollBar
        if scrollBar then
            F.ReskinScroll(scrollBar)
        end
    end

    -- Channel list scroll
    if channelFrame.ChannelList and channelFrame.ChannelList.ScrollBar then
        F.ReskinScroll(channelFrame.ChannelList.ScrollBar)
    end

    -- CreateChannel popup
    local createPopup = _G.CreateChannelPopup
    if createPopup then
        F.StripTextures(createPopup)
        F.SetBD(createPopup)

        if createPopup.OKButton then F.ReskinButton(createPopup.OKButton) end
        if createPopup.CancelButton then F.ReskinButton(createPopup.CancelButton) end
        if createPopup.Name then F.ReskinEditbox(createPopup.Name) end
        if createPopup.Password then F.ReskinEditbox(createPopup.Password) end
        if createPopup.CloseButton then F.ReskinClose(createPopup.CloseButton) end
    end

    -- Voice chat prompt
    local voicePrompt = _G.VoiceChatPromptActivateChannel
    if voicePrompt then
        F.StripTextures(voicePrompt)
        F.SetBD(voicePrompt)
        if voicePrompt.AcceptButton then F.ReskinButton(voicePrompt.AcceptButton) end
        if voicePrompt.CloseButton then F.ReskinClose(voicePrompt.CloseButton) end
    end
end)
