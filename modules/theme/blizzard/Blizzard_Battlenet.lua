local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    -- 3.80.1: nil guard each frame
    -- BN Toast / Time Alert
    local toastFrames = { _G.BNToastFrame, _G.TimeAlertFrame }
    for _, frame in pairs(toastFrames) do
        if frame then
            F.StripTextures(frame)
            F.SetBD(frame)
        end
    end

    -- Ticket Status
    local ticketFrame = _G.TicketStatusFrameButton
    if ticketFrame and ticketFrame.NineSlice then
        F.StripTextures(ticketFrame.NineSlice)
        F.CreateBDFrame(ticketFrame.NineSlice)
    end

    -- Report Frame
    local reportFrame = _G.ReportFrame
    if reportFrame then
        F.StripTextures(reportFrame)
        F.SetBD(reportFrame)

        if reportFrame.Comment then
            F.StripTextures(reportFrame.Comment)
            F.ReskinEditbox(reportFrame.Comment)
        end
        if reportFrame.ReportingMajorCategoryDropdown then
            F.ReskinDropdown(reportFrame.ReportingMajorCategoryDropdown)
        end
        if reportFrame.ReportButton then
            F.ReskinButton(reportFrame.ReportButton)
        end
        if reportFrame.CloseButton then
            F.ReskinClose(reportFrame.CloseButton)
        end
    end

    -- Report Cheating Dialog
    local cheatDialog = _G.ReportCheatingDialog
    if cheatDialog then
        F.StripTextures(cheatDialog)
        F.SetBD(cheatDialog)

        if _G.ReportCheatingDialogCommentFrame then
            F.StripTextures(_G.ReportCheatingDialogCommentFrame)
        end
        if _G.ReportCheatingDialogReportButton then
            F.ReskinButton(_G.ReportCheatingDialogReportButton)
        end
        if _G.ReportCheatingDialogCancelButton then
            F.ReskinButton(_G.ReportCheatingDialogCancelButton)
        end
        if _G.ReportCheatingDialogCommentFrameEditBox then
            F.ReskinEditbox(_G.ReportCheatingDialogCommentFrameEditBox)
        end
    end

    -- BattleTag Invite Frame
    local btInvite = _G.BattleTagInviteFrame
    if btInvite then
        F.StripTextures(btInvite)
        F.SetBD(btInvite)

        for _, child in pairs({btInvite:GetChildren()}) do
            if child and child:IsObjectType('Button') then
                F.ReskinButton(child)
            end
        end
    end
end)
