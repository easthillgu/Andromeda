local F, C = unpack(select(2, ...))

local function SetupButtonHighlight(button, bg)
    button:SetHighlightTexture(C.Assets.Textures.Backdrop)
    local hl = button:GetHighlightTexture()
    hl:SetVertexColor(C.r, C.g, C.b, 0.25)
    hl:SetInside(bg)
end

local function SetupStatusbar(bar)
    F.StripTextures(bar)
    bar:SetStatusBarTexture(C.Assets.Textures.Backdrop)
    bar:GetStatusBarTexture():SetGradient('VERTICAL', CreateColor(0, 0.4, 0, 1), CreateColor(0, 0.6, 0, 1))
    F.CreateBDFrame(bar, 0.25)
end

C.Themes['Blizzard_AchievementUI'] = function()
    local r, g, b = C.r, C.g, C.b

    F.StripTextures(AchievementFrame)
    F.SetBD(AchievementFrame)
    if AchievementFrameWaterMark then
        AchievementFrameWaterMark:SetAlpha(0)
    end
    if AchievementFrame.Header then
        F.StripTextures(AchievementFrame.Header)
        if AchievementFrame.Header.Title then
            AchievementFrame.Header.Title:Hide()
        end
        if AchievementFrame.Header.Points then
            AchievementFrame.Header.Points:SetPoint('TOP', AchievementFrame, 0, -3)
        end
    end

    AchievementFrameCategories:HideBackdrop()
    AchievementFrameSummaryBackground:Hide()
    AchievementFrameSummary:GetChildren():Hide()
    if AchievementFrameCategoriesContainerScrollBarBG then
        AchievementFrameCategoriesContainerScrollBarBG:SetAlpha(0)
    end

    for i = 1, 4 do
        select(i, AchievementFrameHeader:GetRegions()):Hide()
    end
    if AchievementFrameHeaderRightDDLInset then
        AchievementFrameHeaderRightDDLInset:SetAlpha(0)
    end

    select(2, AchievementFrameAchievements:GetChildren()):Hide()
    AchievementFrameAchievementsBackground:Hide()
    select(3, AchievementFrameAchievements:GetRegions()):Hide()

    AchievementFrameStatsBG:Hide()
    AchievementFrameSummaryAchievementsHeaderHeader:Hide()
    AchievementFrameSummaryCategoriesHeaderTexture:Hide()
    select(3, AchievementFrameStats:GetChildren()):Hide()
    select(5, AchievementFrameComparison:GetChildren()):Hide()
    AchievementFrameComparisonHeaderBG:Hide()
    AchievementFrameComparisonHeaderPortrait:Hide()
    AchievementFrameComparisonBackground:Hide()
    if AchievementFrameComparisonDark then
        AchievementFrameComparisonDark:SetAlpha(0)
    end
    AchievementFrameComparisonSummaryPlayerBackground:Hide()
    AchievementFrameComparisonSummaryFriendBackground:Hide()

    hooksecurefunc('AchievementFrameCategories_DisplayButton', function(bu)
        if bu.styled then return end

        bu.background:Hide()
        local bg = F.CreateBDFrame(bu, 0.25)
        bg:SetPoint('TOPLEFT', 0, -1)
        bg:SetPoint('BOTTOMRIGHT')
        SetupButtonHighlight(bu, bg)

        bu.styled = true
    end)

    -- AchievementFrameCategories
    if AchievementFrameCategories then
        F.StripTextures(AchievementFrameCategories)
        if AchievementFrameCategories.ScrollBar then
            F.ReskinTrimScroll(AchievementFrameCategories.ScrollBar)
        end
        if AchievementFrameCategories.ScrollBox then
            hooksecurefunc(AchievementFrameCategories.ScrollBox, 'Update', function(self)
                for i = 1, self.ScrollTarget:GetNumChildren() do
                    local child = select(i, self.ScrollTarget:GetChildren())
                    local button = child.Button
                    if button and not button.styled then
                        button.background:Hide()
                        local bg = F.CreateBDFrame(button, 0.25)
                        bg:SetPoint('TOPLEFT', 0, -1)
                        bg:SetPoint('BOTTOMRIGHT')
                        SetupButtonHighlight(button, bg)

                        button.styled = true
                    end
                end
            end)
        end
    end

    AchievementFrameHeaderPoints:SetPoint('TOP', AchievementFrame, 'TOP', 0, -6)
    if AchievementFrameFilterDropdown then
        F.ReskinFilterButton(AchievementFrameFilterDropdown)
        AchievementFrameFilterDropdown:ClearAllPoints()
        AchievementFrameFilterDropdown:SetPoint('TOPLEFT', 25, -5)
    end

    F.StripTextures(AchievementFrameSummaryCategoriesStatusBar)
    AchievementFrameSummaryCategoriesStatusBar:SetStatusBarTexture(C.Assets.Textures.Backdrop)
    AchievementFrameSummaryCategoriesStatusBar:GetStatusBarTexture():SetGradient('VERTICAL', CreateColor(0, 0.4, 0, 1), CreateColor(0, 0.6, 0, 1))
    AchievementFrameSummaryCategoriesStatusBarTitle:SetTextColor(1, 1, 1)
    AchievementFrameSummaryCategoriesStatusBarTitle:SetPoint('LEFT', AchievementFrameSummaryCategoriesStatusBar, 'LEFT', 6, 0)
    AchievementFrameSummaryCategoriesStatusBarText:SetPoint('RIGHT', AchievementFrameSummaryCategoriesStatusBar, 'RIGHT', -5, 0)
    F.CreateBDFrame(AchievementFrameSummaryCategoriesStatusBar, 0.25)

    for i = 1, 3 do
        local tab = _G['AchievementFrameTab' .. i]
        if tab then
            F.ReskinTab(tab)
            if i ~= 1 then
                tab:ClearAllPoints()
                tab:SetPoint('TOPLEFT', _G['AchievementFrameTab' .. (i - 1)], 'TOPRIGHT', -10, 0)
            end
        end
    end

    -- Search box
    if AchievementFrame.SearchBox then
        F.ReskinEditbox(AchievementFrame.SearchBox)
        AchievementFrame.SearchBox:ClearAllPoints()
        AchievementFrame.SearchBox:SetPoint('TOPRIGHT', AchievementFrame, 'TOPRIGHT', -25, -5)
        AchievementFrame.SearchBox:SetPoint('BOTTOMLEFT', AchievementFrame, 'TOPRIGHT', -130, -25)
    end

    if AchievementFrame.SearchPreviewContainer then
        local previewContainer = AchievementFrame.SearchPreviewContainer
        local showAllSearchResults = previewContainer.ShowAllSearchResults
        F.StripTextures(previewContainer)
        previewContainer:ClearAllPoints()
        previewContainer:SetPoint('TOPLEFT', AchievementFrame, 'TOPRIGHT', 7, -2)
        local bg = F.SetBD(previewContainer)
        bg:SetPoint('TOPLEFT', -3, 3)
        bg:SetPoint('BOTTOMRIGHT', showAllSearchResults, 3, -3)

        for i = 1, 5 do
            F.StyleSearchButton(previewContainer['SearchPreview' .. i])
        end
        F.StyleSearchButton(showAllSearchResults)
    end

    if AchievementFrame.SearchResults then
        local result = AchievementFrame.SearchResults
        result:SetPoint('BOTTOMLEFT', AchievementFrame, 'BOTTOMRIGHT', 15, -1)
        F.StripTextures(result)
        local rbg = F.SetBD(result)
        rbg:SetPoint('TOPLEFT', -10, 0)
        rbg:SetPoint('BOTTOMRIGHT')

        F.ReskinClose(result.CloseButton)
        F.ReskinTrimScroll(result.ScrollBar)
        if result.ScrollBox then
            hooksecurefunc(result.ScrollBox, 'Update', function(self)
                for i = 1, self.ScrollTarget:GetNumChildren() do
                    local child = select(i, self.ScrollTarget:GetChildren())
                    if not child.styled then
                        F.StripTextures(child, 2)
                        F.ReskinIcon(child.Icon)
                        local bg = F.CreateBDFrame(child, 0.25)
                        bg:SetInside()
                        SetupButtonHighlight(child, bg)

                        child.styled = true
                    end
                end
            end)
        end
    end

    if AchievementFrameAchievements then
        F.StripTextures(AchievementFrameAchievements)
        if AchievementFrameAchievements.ScrollBar then
            F.ReskinTrimScroll(AchievementFrameAchievements.ScrollBar)
        end
        local thirdChild = select(3, AchievementFrameAchievements:GetChildren())
        if thirdChild then thirdChild:Hide() end

        local function updateAccountString(button)
            if button and button.DateCompleted and button.DateCompleted:IsShown() and button.label then
                if button.accountWide then
                    button.label:SetTextColor(0, 0.6, 1)
                else
                    button.label:SetTextColor(0.9, 0.9, 0.9)
                end
            elseif button and button.label then
                if button.accountWide then
                    button.label:SetTextColor(0, 0.3, 0.5)
                else
                    button.label:SetTextColor(0.65, 0.65, 0.65)
                end
            end
        end

        local function updateProgressBars(frame)
            local objectives = frame:GetObjectiveFrame()
            if objectives and objectives.progressBars then
                for _, bar in next, objectives.progressBars do
                    if not bar.styled then
                        SetupStatusbar(bar)
                        bar.styled = true
                    end
                end
            end
        end

        if AchievementFrameAchievements.ScrollBox then
            hooksecurefunc(AchievementFrameAchievements.ScrollBox, 'Update', function(self)
                for i = 1, self.ScrollTarget:GetNumChildren() do
                    local child = select(i, self.ScrollTarget:GetChildren())
                    if child and not child.styled then
                        F.StripTextures(child, true)
                        child.Background:SetAlpha(0)
                        child.highlight:SetAlpha(0)
                        child.icon.frame:Hide()
                        child.description:SetTextColor(0.9, 0.9, 0.9)
                        child.description.SetTextColor = nop

                        local bg = F.CreateBDFrame(child, 0.25)
                        bg:SetPoint('TOPLEFT', 1, -1)
                        bg:SetPoint('BOTTOMRIGHT', 0, 2)
                        F.ReskinIcon(child.icon.texture)

                        if child.tracked then
                            F.ReskinCheckbox(child.tracked)
                            child.tracked:SetSize(20, 20)
                        end
                        if child.Check then child.Check:SetAlpha(0) end

                        hooksecurefunc(child, 'UpdatePlusMinusTexture', updateAccountString)
                        hooksecurefunc(child, 'DisplayObjectives', updateProgressBars)

                        child.styled = true
                    end
                end
            end)
        end
    end

    hooksecurefunc('AchievementButton_DisplayAchievement', function(button, category, achievement)
        local _, _, _, completed = GetAchievementInfo(category, achievement)
        if completed then
            if button.accountWide then
                button.label:SetTextColor(0, 0.6, 1)
            else
                button.label:SetTextColor(0.9, 0.9, 0.9)
            end
        else
            if button.accountWide then
                button.label:SetTextColor(0, 0.3, 0.5)
            else
                button.label:SetTextColor(0.65, 0.65, 0.65)
            end
        end
        if button.description then button.description:SetTextColor(0.9, 0.9, 0.9) end
    end)

    hooksecurefunc('AchievementObjectives_DisplayCriteria', function(_, id)
        for i = 1, GetAchievementNumCriteria(id) do
            local name = _G['AchievementFrameCriteria' .. i .. 'Name']
            if name and select(2, name:GetTextColor()) == 0 then
                name:SetTextColor(1, 1, 1)
            end

            local bu = _G['AchievementFrameMeta' .. i]
            if bu and select(2, bu.label:GetTextColor()) == 0 then
                bu.label:SetTextColor(1, 1, 1)
            end
        end
    end)

    hooksecurefunc('AchievementButton_GetProgressBar', function(index)
        local bar = _G['AchievementFrameProgressBar' .. index]
        if not bar.styled then
            F.StripTextures(bar)
            bar:SetStatusBarTexture(C.Assets.Textures.Backdrop)
            F.CreateBDFrame(bar, 0.25)

            bar.styled = true
        end
    end)

    AchievementFrameSummaryAchievementsEmptyText:SetText('')

    hooksecurefunc('AchievementFrameSummary_UpdateAchievements', function()
        for i = 1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
            local bu = _G['AchievementFrameSummaryAchievement' .. i]
            if bu.accountWide then
                bu.label:SetTextColor(0, 0.6, 1)
            else
                bu.label:SetTextColor(0.9, 0.9, 0.9)
            end

            if not bu.styled then
                bu:DisableDrawLayer('ARTWORK')
                bu:DisableDrawLayer('BORDER')
                bu:DisableDrawLayer('BACKGROUND')
                bu:HideBackdrop()

                bu.titleBar:Hide()
                bu.highlight:SetAlpha(0)
                bu.icon.frame:Hide()
                F.ReskinIcon(bu.icon.texture)

                local bg = F.CreateBDFrame(bu, 0.25)
                bg:SetInside(nil, 2, 2)

                bu.styled = true
            end

            bu.description:SetTextColor(0.9, 0.9, 0.9)
        end
    end)

    for i = 1, 8 do
        local bu = _G['AchievementFrameSummaryCategoriesCategory' .. i]
        F.StripTextures(bu)
        bu:SetStatusBarTexture(C.Assets.Textures.Backdrop)
        bu:GetStatusBarTexture():SetGradient('VERTICAL', CreateColor(0, 0.4, 0, 1), CreateColor(0, 0.6, 0, 1))
        F.CreateBDFrame(bu, 0.25)

        bu.text:SetPoint('RIGHT', bu, 'RIGHT', -5, 0)
        _G[bu:GetName() .. 'ButtonHighlight']:SetAlpha(0)
    end

    -- Summaries
    if AchievementFrameStats then
        if AchievementFrameStats.ScrollBar then
            F.ReskinTrimScroll(AchievementFrameStats.ScrollBar)
        end
        if AchievementFrameStats.ScrollBox then
            hooksecurefunc(AchievementFrameStats.ScrollBox, 'Update', function(self)
                for i = 1, self.ScrollTarget:GetNumChildren() do
                    local child = select(i, self.ScrollTarget:GetChildren())
                    if not child.styled then
                        F.StripTextures(child)
                        local bg = F.CreateBDFrame(child, 0.25)
                        bg:SetPoint('TOPLEFT', 2, -C.MULT)
                        bg:SetPoint('BOTTOMRIGHT', 4, C.MULT)
                        SetupButtonHighlight(child, bg)

                        child.styled = true
                    end
                end
            end)
        end
    end

    for i = 1, 20 do
        local bu = _G['AchievementFrameStatsContainerButton' .. i]
        if bu then
            F.StripTextures(bu)
            local bg = F.CreateBDFrame(bu, 0.25)
            bg:SetPoint('TOPLEFT', 2, -C.MULT)
            bg:SetPoint('BOTTOMRIGHT', 4, C.MULT)
            SetupButtonHighlight(bu, bg)
        end
    end

    -- Comparison
    if AchievementFrameComparisonHeader then
        AchievementFrameComparisonHeader:SetPoint('BOTTOMRIGHT', AchievementFrameComparison, 'TOPRIGHT', 39, 26)
        local headerbg = F.SetBD(AchievementFrameComparisonHeader)
        headerbg:SetPoint('TOPLEFT', 20, -20)
        headerbg:SetPoint('BOTTOMRIGHT', -28, -5)
    end

    if AchievementFrameComparison then
        F.StripTextures(AchievementFrameComparison)
        local compChild = select(5, AchievementFrameComparison:GetChildren())
        if compChild then compChild:Hide() end
        if AchievementFrameComparison.AchievementContainer and AchievementFrameComparison.AchievementContainer.ScrollBar then
            F.ReskinTrimScroll(AchievementFrameComparison.AchievementContainer.ScrollBar)
        end
    end

    local function handleCompareSummary(frame)
        if not frame then return end
        frame:HideBackdrop()
        local bg = F.CreateBDFrame(frame, 0.25)
        bg:SetPoint('TOPLEFT', 2, -2)
        bg:SetPoint('BOTTOMRIGHT', -2, 0)
    end
    handleCompareSummary(AchievementFrameComparisonSummaryPlayer)
    handleCompareSummary(AchievementFrameComparisonSummaryFriend)

    local function handleCompareCategory(button)
        if not button then return end
        button:DisableDrawLayer('BORDER')
        button:HideBackdrop()
        if button.Background then button.Background:Hide() end
        local bg = F.CreateBDFrame(button, 0.25)
        bg:SetInside(button, 2, 2)

        if button.TitleBar then button.TitleBar:Hide() end
        if button.Glow then button.Glow:Hide() end
        if button.icon and button.icon.frame then button.icon.frame:Hide() end
        if button.icon and button.icon.texture then F.ReskinIcon(button.icon.texture) end
    end

    if AchievementFrameComparison and AchievementFrameComparison.AchievementContainer and AchievementFrameComparison.AchievementContainer.ScrollBox then
        hooksecurefunc(AchievementFrameComparison.AchievementContainer.ScrollBox, 'Update', function(self)
            for i = 1, self.ScrollTarget:GetNumChildren() do
                local child = select(i, self.ScrollTarget:GetChildren())
                if child and not child.styled then
                    if child.Player then handleCompareCategory(child.Player) end
                    if child.Player and child.Player.description then
                        child.Player.description:SetTextColor(0.9, 0.9, 0.9)
                        child.Player.description.SetTextColor = nop
                    end
                    if child.Friend then handleCompareCategory(child.Friend) end

                    child.styled = true
                end
            end
        end)
    end

    hooksecurefunc('AchievementFrameComparison_DisplayAchievement', function(button)
        if button and button.player and button.player.description then
            button.player.description:SetTextColor(0.9, 0.9, 0.9)
        end
    end)

    F.ReskinClose(AchievementFrameCloseButton)
    if AchievementFrameAchievementsContainerScrollBar then
        F.ReskinScroll(AchievementFrameAchievementsContainerScrollBar)
    end
    if AchievementFrameStatsContainerScrollBar then
        F.ReskinScroll(AchievementFrameStatsContainerScrollBar)
    end
    if AchievementFrameCategoriesContainerScrollBar then
        F.ReskinScroll(AchievementFrameCategoriesContainerScrollBar)
    end
    if AchievementFrameComparisonContainerScrollBar then
        F.ReskinScroll(AchievementFrameComparisonContainerScrollBar)
    end

    -- Comparison Stats
    if AchievementFrameComparison and AchievementFrameComparison.StatsContainer and AchievementFrameComparison.StatsContainer.ScrollBar then
        F.ReskinTrimScroll(AchievementFrameComparison.StatsContainer.ScrollBar)
    end
    for i = 1, 20 do
        local bu = _G['AchievementFrameComparisonStatsContainerButton' .. i]
        if bu then
            F.StripTextures(bu)
            local bg = F.CreateBDFrame(bu, 0.25)
            bg:SetPoint('TOPLEFT', 2, -C.MULT)
            bg:SetPoint('BOTTOMRIGHT', 4, C.MULT)
            SetupButtonHighlight(bu, bg)
        end
    end
    if AchievementFrameComparisonStatsContainerScrollBar then
        F.ReskinScroll(AchievementFrameComparisonStatsContainerScrollBar)
    end
    if AchievementFrameComparisonWatermark then
        AchievementFrameComparisonWatermark:SetAlpha(0)
    end

    local fixedIndex = 1
    hooksecurefunc('AchievementObjectives_DisplayProgressiveAchievement', function()
        local mini = _G['AchievementFrameMiniAchievement' .. fixedIndex]
        while mini do
            mini.points:SetWidth(22)
            mini.points:ClearAllPoints()
            mini.points:SetPoint('BOTTOMRIGHT', 2, 2)

            fixedIndex = fixedIndex + 1
            mini = _G['AchievementFrameMiniAchievement' .. fixedIndex]
        end
    end)
end
