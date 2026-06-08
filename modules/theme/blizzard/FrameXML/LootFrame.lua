local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local LootFrame = _G.LootFrame

    -- 3.80.1: NDui-style approach — use ReskinPortraitFrame for the main frame
    F.ReskinPortraitFrame(LootFrame)
    F.ReskinTrimScroll(LootFrame.ScrollBar)

    -- 3.80.1: ClosePanelButton may not match ReskinPortraitFrame's pattern (frameName..'CloseButton')
    if LootFrame.ClosePanelButton then
        F.ReskinClose(LootFrame.ClosePanelButton)
    end

    -- 3.80.1: NDui reference — hide portrait overlay separately
    if _G.LootFramePortraitOverlay then
        _G.LootFramePortraitOverlay:Hide()
    end

    -- 3.80.1: Classic LootFrame_UpdateButton hook (ScrollBox does NOT exist in Cata Classic)
    hooksecurefunc('LootFrame_UpdateButton', function(index)
        local name = 'LootButton' .. index
        local bu = _G[name]
        if not bu or not bu:IsShown() then return end

        local nameFrame = _G[name .. 'NameFrame']

        if not bu.bg then
            -- Hide Blizzard decorative layers
            if nameFrame then nameFrame:Hide() end
            bu:SetNormalTexture(0)
            if bu.SetPushedTexture then
                bu:SetPushedTexture(0)
            end
            bu:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
            bu.IconBorder:SetAlpha(0)

            -- Andromeda icon border
            bu.bg = F.ReskinIcon(bu.icon)

            -- Text background frame (NDui pattern: bg anchored to icon right)
            local bg = F.CreateBDFrame(bu, 0.25)
            bg:SetPoint('TOPLEFT', bu.bg, 'TOPRIGHT', 1, 0)
            bg:SetPoint('BOTTOMRIGHT', bu.bg, 115, 0)
        end

        -- Quest item: yellow border
        if select(7, GetLootSlotInfo(index)) then
            bu.bg:SetBackdropBorderColor(0.8, 0.8, 0)
        else
            bu.bg:SetBackdropBorderColor(0, 0, 0)
        end
    end)

    -- Reposition navigation buttons (NDui reference)
    local downBtn = _G.LootFrameDownButton
    local prevBtn = _G.LootFramePrev
    local nextBtn = _G.LootFrameNext
    local upBtn = _G.LootFrameUpButton

    if downBtn then
        downBtn:ClearAllPoints()
        downBtn:SetPoint('BOTTOMRIGHT', -8, 6)
    end
    if prevBtn and upBtn then
        prevBtn:ClearAllPoints()
        prevBtn:SetPoint('LEFT', upBtn, 'RIGHT', 4, 0)
    end
    if nextBtn and downBtn then
        nextBtn:ClearAllPoints()
        nextBtn:SetPoint('RIGHT', downBtn, 'LEFT', -4, 0)
    end

    -- Bonus roll
    local BonusRollFrame = _G.BonusRollFrame
    if BonusRollFrame then
        BonusRollFrame.Background:SetAlpha(0)
        BonusRollFrame.IconBorder:Hide()
        BonusRollFrame.BlackBackgroundHoist.Background:Hide()
        BonusRollFrame.SpecRing:SetAlpha(0)
        F.SetBD(BonusRollFrame)

        local specIcon = BonusRollFrame.SpecIcon
        specIcon:ClearAllPoints()
        specIcon:SetPoint('TOPRIGHT', -90, -18)
        local specBg = F.ReskinIcon(specIcon)
        hooksecurefunc('BonusRollFrame_StartBonusRoll', function()
            specBg:SetShown(specIcon:IsShown())
        end)

        local promptFrame = BonusRollFrame.PromptFrame
        if promptFrame then
            F.ReskinIcon(promptFrame.Icon)
            promptFrame.Timer.Bar:SetTexture(C.Assets.Textures.StatusbarNormal)
            F.CreateBDFrame(promptFrame.Timer, 0.25)
        end

        local from, to = '|T.+|t', '|T%%s:14:14:0:0:64:64:5:59:5:59|t'
        _G.BONUS_ROLL_COST = _G.BONUS_ROLL_COST:gsub(from, to)
        _G.BONUS_ROLL_CURRENT_COUNT = _G.BONUS_ROLL_CURRENT_COUNT:gsub(from, to)
    end

    -- Loot Roll Frame
    hooksecurefunc('GroupLootFrame_OpenNewFrame', function()
        for i = 1, _G.NUM_GROUP_LOOT_FRAMES do
            local frame = _G['GroupLootFrame' .. i]
            if frame and not frame.styled then
                if frame.Border then
                    frame.Border:SetAlpha(0)
                end
                if frame.Background then
                    frame.Background:SetAlpha(0)
                end
                frame.bg = F.SetBD(frame)

                if frame.Timer then
                    if frame.Timer.Bar then
                        frame.Timer.Bar:SetTexture(C.Assets.Textures.Backdrop)
                        frame.Timer.Bar:SetVertexColor(1, 0.8, 0)
                    end
                    if frame.Timer.Background then
                        frame.Timer.Background:SetAlpha(0)
                    end
                    F.CreateBDFrame(frame.Timer, 0.25)
                end

                if frame.IconFrame then
                    if frame.IconFrame.Border then
                        frame.IconFrame.Border:SetAlpha(0)
                    end
                    if frame.IconFrame.Icon then
                        F.ReskinIcon(frame.IconFrame.Icon)
                    end
                end

                local bg = F.CreateBDFrame(frame, 0.25)
                if frame.IconFrame and frame.IconFrame.Icon then
                    bg:SetPoint('TOPLEFT', frame.IconFrame.Icon, 'TOPRIGHT', 0, 1)
                    bg:SetPoint('BOTTOMRIGHT', frame.IconFrame.Icon, 'BOTTOMRIGHT', 150, -1)
                end

                frame.styled = true
            end

            if frame and frame:IsShown() and frame.bg then
                local _, _, _, quality = GetLootRollItemInfo(frame.rollID)
                local color = C.QualityColors and C.QualityColors[quality]
                if color then
                    frame.bg:SetBackdropBorderColor(color.r, color.g, color.b)
                end
            end
        end
    end)

    -- Bossbanner
    if _G.BossBanner_ConfigureLootFrame then
        hooksecurefunc('BossBanner_ConfigureLootFrame', function(lootFrame)
        local iconHitBox = lootFrame.IconHitBox
        if not iconHitBox.bg then
            iconHitBox.bg = F.CreateBDFrame(iconHitBox)
            iconHitBox.bg:SetOutside(lootFrame.Icon)
            lootFrame.Icon:SetTexCoord(unpack(C.TEX_COORD))
            F.ReskinIconBorder(iconHitBox.IconBorder, true)
        end

        iconHitBox.IconBorder:SetTexture(nil)
    end)
    end
end)
