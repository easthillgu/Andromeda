local F, C = unpack(select(2, ...))
local THEME = F:GetModule('Theme')

----------------------------
-- Credit: AddOnSkins_MeetingStone by hokohuang
----------------------------

local function reskinDropDown(dropdown)
    if not dropdown or not dropdown.MenuButton then
        return
    end

    F.StripTextures(dropdown)
    local down = dropdown.MenuButton
    down:ClearAllPoints()
    down:SetPoint('RIGHT', -18, 0)
    F.ReskinArrow(down, 'down')
    down:SetSize(20, 20)

    local bg = F.CreateBDFrame(dropdown, 0)
    bg:SetPoint('TOPLEFT', 0, -2)
    bg:SetPoint('BOTTOMRIGHT', -18, 2)
    F.CreateGradient(bg)
end

local function reskinQRTooltip(self)
    F.StripTextures(self, 0)
    self.bg = F.SetBD(self, .7)
    F.ReskinClose(self.Close)
    self.Close:SetHitRectInsets(0, 0, 0, 0)

    if self.Image then
        self.Image:SetAlpha(1)
        self.bg:SetFrameLevel(self:GetFrameLevel())
    end
end

local imageFrameStyled
local function reskinImageFrame(self)
    if imageFrameStyled then return end

    for _, child in pairs({self:GetChildren()}) do
        if child:GetObjectType() == 'Frame' and child.Image and child.Close then
            reskinQRTooltip(child)
            imageFrameStyled = true
            break
        end
    end
end

local function hook_Show(self)
    self:GetParent().bg:Show()
end

local function hook_Hide(self)
    self:GetParent().bg:Hide()
end

local function reskinHeader(header)
    for i = 4, 18 do
        select(i, header.Button:GetRegions()):SetTexture('')
    end
    F.ReskinButton(header.Button)
    header.Button.Title:SetTextColor(1, 1, 1)
    header.Button.Title.SetTextColor = nop
    header.Button.ExpandedIcon:SetWidth(20)
    header.Button.ExpandedIcon.SetTextColor = nop
    header.Button.bg = F.ReskinIcon(header.Button.AbilityIcon)
    hooksecurefunc(header.Button.AbilityIcon, 'Show', hook_Show)
    hooksecurefunc(header.Button.AbilityIcon, 'Hide', hook_Hide)

    F.StripTextures(header.Overview)
    header.Overview.Text:SetTextColor(1, 1, 1)
    header.Overview.Text.SetTextColor = nop
end

local function reskinSummary(summary)
    F.StripTextures(summary.Title)
    summary.Title.Text:SetTextColor(1, 1, 1)
    summary.Title.Text.SetTextColor = nop
    summary.Overview.Text:SetTextColor(1, 1, 1)
    summary.Overview.Text.SetTextColor = nop
end

local function replaceTextColor(self, text)
    if self.isReplacing then return end
    self.isReplacing = true
    self:SetText(gsub(text, '^|c%x%x%x%x%x%x%x%x', '|cffffffff'))
    self.isReplacing = nil
end

local function reskinItemButton(self)
    self:SetSize(34, 34)
    F.StripTextures(self, 0)
    self.icon:SetAlpha(1)
    self.bg = F.ReskinIcon(self.icon)
    F.ReskinIconBorder(self.IconBorder, true)
end

local function strToPath(str)
    local path = {}
    for v in string.gmatch(str, '([^%.]+)') do
        table.insert(path, v)
    end
    return path
end

local function getValue(pathStr, tbl)
    local keys = strToPath(pathStr)
    local value
    for _, key in pairs(keys) do
        value = value and value[key] or tbl[key]
    end
    return value
end

function THEME:ReskinMeetingHorn()
    if not _G.ANDROMEDA_ADB.ReskinMeetingHorn then return end

    local MeetingHorn = LibStub('AceAddon-3.0'):GetAddon('MeetingHorn', true)
    if not MeetingHorn then return end

    local mainFrame = MeetingHorn.MainPanel
    if not mainFrame then return end

    F.ReskinPortraitFrame(mainFrame)
    mainFrame.PortraitFrame:SetAlpha(0)

    for _, tab in ipairs(mainFrame.Tabs) do
        F.ReskinTab(tab)
        local text = tab.Text or _G[tab:GetName() .. 'Text']
        if text then
            text:SetPoint('CENTER', tab)
        end
    end

    local Dropdowns = {
        'Browser.Activity',
        'Browser.Mode',
        'Browser.Quick',
        'Browser.SortMode',
        'Manage.Creator.Activity',
        'Manage.Creator.Mode',
        'Encounter.Instance',
        'Challenge.Left.Groups',
    }

    local Headers = {
        'Browser',
        'Manage.Applicant',
    }

    local ScrollBars = {
        'Browser.ActivityList.scrollBar',
        'Browser.VoiceActivityList.scrollBar',
        'Manage.Applicant.ApplicantList.scrollBar',
        'Options.Filters.FilterList.scrollBar',
        'FeedBack.EditBox.ScrollFrame.ScrollBar',
        'Manage.Creator.Comment.ScrollFrame.ScrollBar',
        'Manage.Chat.ChatFrame.scrollBar',
        'Quest.Body.Quests.scrollBar',
    }

    local Panels = {
        'Browser',
        'Manage.Creator',
        'Manage.Chat.ChatBg',
        'Manage.Creator.Comment',
        'Manage.Applicant',
        'Help',
        'Options.Options',
        'Options.Filters',
        'Recent.Left',
        'Recent.Right',
        'PracticalTool.Present',
        'PracticalTool.QRCodeExhibition',
        'PracticalTool.Toolbar'
    }

    local Buttons = {
        'Manage.Creator.CreateButton',
        'Manage.Creator.CloseButton',
        'Manage.Creator.RecruitButton',
        'Options.Filters.Add',
        'Options.Filters.Import',
        'Options.Filters.Export',
        'FeedBack.AcceptButton',
        'FeedBack.CancelButton',
        'Recent.Invite',
    }

    for _, v in pairs(Dropdowns) do
        local dropdown = getValue(v, mainFrame)
        if dropdown then
            reskinDropDown(dropdown)
        end
    end

    for _, v in pairs(Headers) do
        local headerParent = getValue(v, mainFrame)
        if headerParent then
            local index = 1
            local header = headerParent['Header' .. index]
            while header do
                header:DisableDrawLayer('BACKGROUND')
                local bg = F.CreateBDFrame(header, .25)
                bg:SetPoint('BOTTOMRIGHT', -2, C.MULT)
                header:SetHighlightTexture(C.Assets.Textures.Backdrop)
                local hl = header:GetHighlightTexture()
                hl:SetVertexColor(C.r, C.g, C.b, .25)
                hl:SetInside()
                index = index + 1
                header = headerParent['Header' .. index]
            end
        end
    end

    for _, v in pairs(ScrollBars) do
        local scrollBar = getValue(v, mainFrame)
        if scrollBar then
            F.ReskinScroll(scrollBar)
        end
    end

    for _, v in pairs(Panels) do
        local panel = getValue(v, mainFrame)
        if panel then
            F.StripTextures(panel)
            local bg = F.CreateBDFrame(panel, .25)
            bg:SetPoint('TOPLEFT', 0, 0)
            bg:SetPoint('BOTTOMRIGHT', 0, 0)
        end
    end

    for _, v in pairs(Buttons) do
        local button = getValue(v, mainFrame)
        if button then
            F.ReskinButton(button)
            if button.LeftSeparator then button.LeftSeparator:SetAlpha(0) end
            if button.RightSeparator then button.RightSeparator:SetAlpha(0) end
        end
    end

    local input = getValue('Browser.Input', mainFrame)
    if input then
        F.ReskinInput(input)
    end

    local ListView = MeetingHorn:GetClass('UI.ListView')
    hooksecurefunc(ListView, 'GetButton', function(self, index)
        local button = self._buttons[index]
        if button and not button.styled then
            F.StripTextures(button, 0)
            button:SetHighlightTexture(C.Assets.Textures.Backdrop)
            local hl = button:GetHighlightTexture()
            hl:SetVertexColor(C.r, C.g, C.b, .25)
            hl:SetInside()

            if button.Icon then
                button.Icon:SetAlpha(1)
            end

            if button.Signup then
                F.ReskinButton(button.Signup)
                button.Signup:SetSize(60, 20)
            end

            if button.QRIcon then
                button.QRIcon:HookScript('PostClick', function()
                    local tooltip = mainFrame.Browser and mainFrame.Browser.QRTooltip
                    if tooltip and not tooltip.styled then
                        reskinQRTooltip(tooltip)
                        tooltip.styled = true
                    end
                end)
            end

            if button.Text and button.Creature then
                button.Text:SetTextColor(1, 1, 1)
                button.Text.SetTextColor = nop
                button.Creature:SetPoint('TOPLEFT', 0, -8)
                F.CreateBD(button, .25)
                F.CreateGradient(button)
            end

            button.styled = true
        end
    end)

    -- Browser
    local Browser = mainFrame.Browser
    if Browser then
        for _, key in ipairs({'ApplyLeaderBtn', 'RechargeBtn'}) do
            local bu = Browser[key]
            if bu then
                bu:HookScript('PostClick', reskinImageFrame)
            end
        end

        for _, child in pairs({Browser:GetChildren()}) do
            local objType = child:GetObjectType()
            if objType == 'Button' and child.Left and child.Right and child.Middle and child.Text then
                F.ReskinButton(child)
            end
        end

        if Browser.OpenVoiceRoom then
            hooksecurefunc(Browser, 'OpenVoiceRoom', function(self)
                if self.QRTooltip and not self.QRTooltip.styled then
                    reskinQRTooltip(self.QRTooltip)
                    self.QRTooltip.styled = true
                end
            end)
        end

        local progressBar = Browser.ProgressBar
        if progressBar then
            F.StripTextures(progressBar)
            progressBar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
            progressBar:DisableDrawLayer('BACKGROUND')
            F.CreateBDFrame(progressBar, .25)
        end
    end

    -- Encounter
    local Encounter = mainFrame.Encounter
    if Encounter then
        F.StripTextures(Encounter)
        F.StripTextures(Encounter.ZoneButton)
        F.ReskinButton(Encounter.ZoneButton)

        F.ReskinScroll(Encounter.BossList.scrollBar)
        Encounter.BossList.scrollBar.trackBG:SetAlpha(0)
        F.ReskinScroll(Encounter.Panel1.ScrollBar)
        F.ReskinScroll(Encounter.Panel2.ScrollBar)

        Encounter.BossTitle:SetTextColor(1, 1, 1)
        Encounter.Panel1.Overview.Text:SetTextColor(1, 1, 1)
        Encounter.Panel1.Overview.Text.SetTextColor = nop
        hooksecurefunc(Encounter.Panel1.Overview.Text, 'SetText', replaceTextColor)
        Encounter.Panel2.Overview.Text:SetTextColor(1, 1, 1)
        Encounter.Panel2.Overview.Text.SetTextColor = nop
        hooksecurefunc(Encounter.Panel2.Overview.Text, 'SetText', replaceTextColor)
        F.ReskinInput(Encounter.Panel3.Url)

        for i, tab in ipairs(Encounter.Tabs) do
            local bg = F.SetBD(tab)
            bg:SetInside(tab, 2, 2)
            tab:SetNormalTexture(0)
            tab:SetPushedTexture(0)
            tab:SetDisabledTexture(0)
            local hl = tab:GetHighlightTexture()
            hl:SetColorTexture(C.r, C.g, C.b, .2)
            hl:SetInside(bg)

            if i == 1 then
                tab:SetPoint('TOPLEFT', Encounter, 'TOPRIGHT', 7, -35)
            else
                tab:SetPoint('TOPLEFT', Encounter.Tabs[i-1], 'BOTTOMLEFT', 0, 2)
            end
        end

        local LookFall = Encounter.LookFall
        if LookFall then
            LookFall:HookScript('PostClick', reskinImageFrame)
        end
    end

    local EncounterInfo = MeetingHorn:GetClass('UI.EncounterInfo')
    local origEncounterInfoCreate = EncounterInfo.Create
    EncounterInfo.Create = function(self, parent)
        local header = origEncounterInfoCreate(self, parent)
        reskinHeader(header)
        return header
    end

    local EncounterInfoSummary = MeetingHorn:GetClass('UI.EncounterInfoSummary')
    local origEncounterInfoSummaryCreate = EncounterInfoSummary.Create
    EncounterInfoSummary.Create = function(self, parent)
        local summary = origEncounterInfoSummaryCreate(self, parent)
        reskinSummary(summary)
        return summary
    end

    -- Challenge
    local Challenge = mainFrame.Challenge
    if Challenge then
        F.StripTextures(Challenge.Left)
        F.StripTextures(Challenge.Summary)
        F.CreateBDFrame(Challenge.Summary, .25)

        local Body = Challenge.Body
        Body:DisableDrawLayer('BORDER')
        F.CreateBDFrame(Body, .25)
        F.ReskinButton(Body.WebButton)
        F.ReskinButton(Body.UpdateButton)
        F.ReskinButton(Body.Reward.Exchange)

        for i = 1, Body.Reward:GetNumRegions() do
            local region = select(i, Body.Reward:GetRegions())
            if region and region.IsObjectType and region:IsObjectType('FontString') then
                region:SetTextColor(1, 1, 1)
            end
        end

        local progressBar = Body.ProgressBar
        F.StripTextures(progressBar)
        progressBar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
        progressBar:DisableDrawLayer('BACKGROUND')
        F.CreateBDFrame(progressBar, .25)

        local UIChallenge = MeetingHorn:GetClass('UI.Challenge')
        hooksecurefunc(UIChallenge, 'GetChallengeButton', function(self, i)
            local button = self.challengeButtons[i]
            if button and not button.styled then
                button.bg:SetAlpha(0)
                F.ReskinButton(button)
                button.styled = true
            end
        end)
    end

    -- Quest
    local Quest = mainFrame.Quest
    if Quest then
        local Body = Quest.Body
        if Body then
            F.StripTextures(Body)
            F.CreateBDFrame(Body, .25)
            if Body.Refresh then F.ReskinButton(Body.Refresh) end
        end

        local Summary = Quest.Summary
        if Summary then
            F.StripTextures(Summary)
            F.CreateBDFrame(Summary, .25)

            for _, child in pairs({Summary:GetChildren()}) do
                if child.ScrollBar then
                    F.ReskinScroll(child.ScrollBar)
                    break
                end
            end
        end
    end

    -- QuestItem
    local QuestItem = MeetingHorn:GetClass('UI.QuestItem')
    if QuestItem then
        hooksecurefunc(QuestItem, 'SetQuest', function(self)
            if not self.itemStyled then
                F.CreateBD(self, .25)

                if self.Reward then
                F.ReskinButton(self.Reward)
            end

                for index, item in ipairs(self.Items) do
                    reskinItemButton(item)

                    if index > 1 then
                        item:ClearAllPoints()
                        item:SetPoint('LEFT', self.Items[index-1], 'RIGHT', 4, 0)
                    end
                end

                self.itemStyled = true
            end
        end)
    end

    -- GoodLeader
    local GoodLeader = mainFrame.GoodLeader
    if GoodLeader then
        for _, v in ipairs({'First.Footer', 'First.Header', 'First.Inset', 'Result.Info', 'Result.Raids', 'Result.Score'}) do
            local subFrame = getValue(v, GoodLeader)
            if subFrame then
                F.StripTextures(subFrame)
                subFrame.bg = F.CreateBDFrame(subFrame, .25)
                subFrame.bg:SetInside()

                if v == 'First.Header' then
                    local ApplyLeaderBtn = subFrame.ApplyLeaderBtn
                    if ApplyLeaderBtn then
                        F.ReskinButton(ApplyLeaderBtn)
                        ApplyLeaderBtn:HookScript('PostClick', reskinImageFrame)
                    end
                end
            end
        end

        local instances = GoodLeader.Result.Raids.instances
        if instances then
            for _, button in ipairs(instances) do
                button:HideBackdrop()
                F.CreateBDFrame(button.Image, 0)
            end
        end
    end

    local GradePanel = MeetingHorn:GetClass('UI.GradePanel')
    if GradePanel then
        hooksecurefunc(GradePanel, 'OnShow', function(self)
            if not self.styled then
                F.StripTextures(self, 0)
                self.Logo:SetAlpha(1)
                local bg = F.SetBD(self)
                bg:SetInside()

                F.StripTextures(self.QrCodeFrame)
                local qrBG = F.SetBD(self.QrCodeFrame)
                qrBG:SetInside()

                F.ReskinButton(self.Commit)
                F.ReskinButton(self.Cancel)

                self.styled = true
            end
        end)
    end

    -- Announcement
    local Announcement = mainFrame.Announcement
    if Announcement then
        local loading = Announcement.loading
        if loading then
            F.StripTextures(loading)
            F.SetBD(loading, .8)
        end

        local container = Announcement.container
        if container then
            for _, region in pairs({container:GetRegions()}) do
                if region:GetObjectType() == 'FontString' then
                    region:SetTextColor(1, 1, 1)
                end
            end
        end
    end

    -- MissionGuidance
    local MissionGuidance = mainFrame.MissionGuidance
    if MissionGuidance then
        for _, region in pairs({MissionGuidance:GetRegions()}) do
            if region:GetObjectType() == 'FontString' then
                local fontFile, fontSize = region:GetFont()
                region:SetFont(fontFile, fontSize, '')
                region:SetTextColor(0, 0, 0)
            end
        end
    end

    if C_AddOns.IsAddOnLoaded('tdInspect') then  -- Credit: tdUI
        local tdInspect = LibStub('AceAddon-3.0'):GetAddon('tdInspect')
        local Browser = MeetingHorn:GetClass('UI.Browser')
        local Inspect = tdInspect:GetModule('Inspect')

        local origCreateActivityMenu = Browser.CreateActivityMenu
        Browser.CreateActivityMenu = function(self, activity)
            local r = origCreateActivityMenu(self, activity)
            tinsert(r, 3, {
                text = _G.INSPECT,
                func = function()
                    Inspect:Query(nil, activity:GetLeader())
                end,
            })
            return r
        end
    end

    local DataBroker = _G.MeetingHornDataBroker
    if DataBroker then
        DataBroker:DisableDrawLayer('BACKGROUND')
        DataBroker:SetSize(158, 32)
        F.SetBD(DataBroker, nil, C.MULT, -C.MULT, -C.MULT, C.MULT)
        DataBroker.Text:SetPoint('CENTER', 16, 0)
        local logo = DataBroker:CreateTexture(nil, 'ARTWORK')
        logo:SetTexture('Interface\\AddOns\\MeetingHorn\\Media\\Logo2')
        logo:SetSize(30, 30)
        logo:SetPoint('LEFT', 12, 0)
    end
end