local F, C = unpack(select(2, ...))

-- Fix AlertFrames bg
local function fixBg(frame)
    local color = _G.ANDROMEDA_ADB.BackdropColor
    local alpha = _G.ANDROMEDA_ADB.BackdropAlpha
    if frame:IsObjectType('AnimationGroup') then
        frame = frame:GetParent()
    end
    if frame.bg then
        frame.bg:SetBackdropColor(color.r, color.g, color.b, alpha)
        if frame.bg.__shadow then
            frame.bg.__shadow:SetBackdropBorderColor(0, 0, 0, 0.25)
        end
    end
end

local function fixParentbg(anim)
    local color = _G.ANDROMEDA_ADB.BackdropColor
    local alpha = _G.ANDROMEDA_ADB.BackdropAlpha
    local frame = anim.__owner
    if frame.bg then
        frame.bg:SetBackdropColor(color.r, color.g, color.b, alpha)
        if frame.bg.__shadow then
            frame.bg.__shadow:SetBackdropBorderColor(0, 0, 0, 0.25)
        end
    end
end

local function fixAnim(frame)
    if frame.hooked then
        return
    end

    frame:HookScript('OnEnter', fixBg)
    frame:HookScript('OnShow', fixBg)
    frame.animIn:HookScript('OnFinished', fixBg)
    if frame.animArrows then
        frame.animArrows:HookScript('OnPlay', fixBg)
        frame.animArrows:HookScript('OnFinished', fixBg)
    end
    if frame.Arrows and frame.Arrows.ArrowsAnim then
        frame.Arrows.ArrowsAnim.__owner = frame
        frame.Arrows.ArrowsAnim:HookScript('OnPlay', fixParentbg)
        frame.Arrows.ArrowsAnim:HookScript('OnFinished', fixParentbg)
    end

    frame.hooked = true
end

tinsert(C.BlizzThemes, function()
    -- AlertFrames
    hooksecurefunc('AlertFrame_PauseOutAnimation', fixBg)

    local AlertTemplateFunc = {}

    if _G.AchievementAlertSystem then
        AlertTemplateFunc[_G.AchievementAlertSystem] = function(frame)
            if not frame.bg then
                frame.bg = F.SetBD(frame)
                frame.Unlocked:SetTextColor(1, 0.8, 0)
                frame.Unlocked:SetFontObject(_G.NumberFont_GameNormal)
                frame.GuildName:ClearAllPoints()
                frame.GuildName:SetPoint('TOPLEFT', 50, -14)
                frame.GuildName:SetPoint('TOPRIGHT', -50, -14)
                F.ReskinIcon(frame.Icon.Texture)

                frame.GuildBanner:SetTexture('')
                frame.GuildBorder:SetTexture('')
                frame.Icon.Bling:SetTexture('')
            end
            frame.glow:SetTexture('')
            frame.Background:SetTexture('')
            frame.Icon.Overlay:SetTexture('')
            if frame.GuildBanner:IsShown() then
                frame.bg:SetPoint('TOPLEFT', 2, -29)
                frame.bg:SetPoint('BOTTOMRIGHT', -2, 4)
            else
                frame.bg:SetPoint('TOPLEFT', frame, -2, -17)
                frame.bg:SetPoint('BOTTOMRIGHT', 2, 12)
            end
        end
    end

    if _G.CriteriaAlertSystem then
        AlertTemplateFunc[_G.CriteriaAlertSystem] = function(frame)
            if not frame.bg then
                frame.bg = F.SetBD(frame)
                frame.bg:SetPoint('TOPLEFT', frame, 5, -7)
                frame.bg:SetPoint('BOTTOMRIGHT', frame, 18, 10)

                frame.Unlocked:SetTextColor(1, 0.8, 0)
                frame.Unlocked:SetFontObject(_G.NumberFont_GameNormal)
                F.ReskinIcon(frame.Icon.Texture)
                frame.Background:SetTexture('')
                frame.Icon.Bling:SetTexture('')
                frame.Icon.Overlay:SetTexture('')
                frame.glow:SetTexture('')
                frame.shine:SetTexture('')
            end
        end
    end

    if _G.LootAlertSystem then
        AlertTemplateFunc[_G.LootAlertSystem] = function(frame)
            local lootItem = frame.lootItem
            if not frame.bg then
                frame.bg = F.SetBD(frame)
                frame.bg:SetPoint('TOPLEFT', frame, 13, -15)
                frame.bg:SetPoint('BOTTOMRIGHT', frame, -13, 13)

                F.ReskinIcon(lootItem.Icon)
                lootItem.Icon:SetInside()
                lootItem.IconOverlay:SetInside()
                lootItem.IconOverlay2:SetInside()
                lootItem.SpecRing:SetTexture('')
                lootItem.SpecIcon:SetPoint('TOPLEFT', lootItem.Icon, -5, 5)
                lootItem.SpecIcon.bg = F.ReskinIcon(lootItem.SpecIcon)
            end
            frame.glow:SetTexture('')
            frame.shine:SetTexture('')
            frame.Background:SetTexture('')
            frame.PvPBackground:SetTexture('')
            frame.BGAtlas:SetTexture('')
            lootItem.IconBorder:SetTexture('')
            lootItem.SpecIcon.bg:SetShown(lootItem.SpecIcon:IsShown() and lootItem.SpecIcon:GetTexture() ~= nil)
        end
    end

    if _G.LootUpgradeAlertSystem then
        AlertTemplateFunc[_G.LootUpgradeAlertSystem] = function(frame)
            if not frame.bg then
                frame.bg = F.SetBD(frame)
                frame.bg:SetPoint('TOPLEFT', 10, -14)
                frame.bg:SetPoint('BOTTOMRIGHT', -10, 12)

                F.ReskinIcon(frame.Icon)
                frame.Icon:ClearAllPoints()
                frame.Icon:SetPoint('CENTER', frame.BaseQualityBorder)

                frame.BaseQualityBorder:SetSize(52, 52)
                frame.BaseQualityBorder:SetTexture(C.Assets.Textures.Backdrop)
                frame.UpgradeQualityBorder:SetTexture(C.Assets.Textures.Backdrop)
                frame.UpgradeQualityBorder:SetSize(52, 52)
                frame.Background:SetTexture('')
                frame.Sheen:SetTexture('')
                frame.BorderGlow:SetTexture('')
            end
            frame.BaseQualityBorder:SetTexture('')
            frame.UpgradeQualityBorder:SetTexture('')
        end
    end

    if _G.MoneyWonAlertSystem then
        AlertTemplateFunc[_G.MoneyWonAlertSystem] = function(frame)
            if not frame.bg then
                frame.bg = F.SetBD(frame)
                frame.bg:SetInside(frame, 7, 7)

                F.ReskinIcon(frame.Icon)
                frame.Background:SetTexture('')
                frame.IconBorder:SetTexture('')
            end
        end
    end

    if _G.NewRecipeLearnedAlertSystem then
        AlertTemplateFunc[_G.NewRecipeLearnedAlertSystem] = function(frame)
            if not frame.bg then
                frame.bg = F.SetBD(frame)
                frame.bg:SetPoint('TOPLEFT', 10, -5)
                frame.bg:SetPoint('BOTTOMRIGHT', -10, 5)

                frame:GetRegions():SetTexture('')
                F.CreateBDFrame(frame.Icon)
                frame.glow:SetTexture('')
                frame.shine:SetTexture('')
            end
            frame.Icon:SetMask('')
            frame.Icon:SetTexCoord(unpack(C.TEX_COORD))
        end
    end

    if _G.NewPetAlertSystem then
        AlertTemplateFunc[_G.NewPetAlertSystem] = function(frame)
            if not frame.bg then
                frame.bg = F.SetBD(frame)
                frame.IconBorder:SetAlpha(0)
                F.ReskinIcon(frame.Icon)
                frame.Background:Hide()
                frame.Background2:Hide()
            end
            frame.Icon:SetMask('')
            frame.Icon:SetTexCoord(unpack(C.TEX_COORD))
            frame.IconBorder:SetTexture('')
        end
    end

    if _G.NewMountAlertSystem then
        AlertTemplateFunc[_G.NewMountAlertSystem] = function(frame)
            if not frame.bg then
                frame.bg = F.SetBD(frame)
                frame.IconBorder:SetAlpha(0)
                F.ReskinIcon(frame.Icon)
                frame.Background:Hide()
                frame.Background2:Hide()
            end
            frame.Icon:SetMask('')
            frame.Icon:SetTexCoord(unpack(C.TEX_COORD))
            frame.IconBorder:SetTexture('')
        end
    end

    if _G.NewToyAlertSystem then
        AlertTemplateFunc[_G.NewToyAlertSystem] = function(frame)
            if not frame.bg then
                frame.bg = F.SetBD(frame)
                frame.IconBorder:SetAlpha(0)
                F.ReskinIcon(frame.Icon)
                frame.Background:Hide()
                frame.Background2:Hide()
            end
            frame.Icon:SetMask('')
            frame.Icon:SetTexCoord(unpack(C.TEX_COORD))
            frame.IconBorder:SetTexture('')
        end
    end

    if _G.EntitlementDeliveredAlertSystem then
        AlertTemplateFunc[_G.EntitlementDeliveredAlertSystem] = function(frame)
            if not frame.bg then
                frame.bg = F.SetBD(frame)
                frame.bg:SetInside(frame, 12, 12)

                F.ReskinIcon(frame.Icon)
                if frame.Title then
                    frame.Title:SetTextColor(0, 0.6, 1)
                end
                if frame.Background then
                    frame.Background:Hide()
                end
            end
        end
    end

    if _G.RafRewardDeliveredAlertSystem then
        AlertTemplateFunc[_G.RafRewardDeliveredAlertSystem] = function(frame)
            if not frame.bg then
                frame.bg = F.SetBD(frame)
                frame.bg:SetPoint('TOPLEFT', 24, -14)
                frame.bg:SetPoint('BOTTOMRIGHT', -24, 8)

                F.ReskinIcon(frame.Icon)
                if frame.StandardBackground then
                    frame.StandardBackground:SetTexture('')
                end
            end
        end
    end

    -- Aliases (only if both source and target exist)
    if _G.MoneyWonAlertSystem and _G.HonorAwardedAlertSystem and AlertTemplateFunc[_G.MoneyWonAlertSystem] then
        AlertTemplateFunc[_G.HonorAwardedAlertSystem] = AlertTemplateFunc[_G.MoneyWonAlertSystem]
    end
    if _G.CriteriaAlertSystem and _G.MonthlyActivityAlertSystem and AlertTemplateFunc[_G.CriteriaAlertSystem] then
        AlertTemplateFunc[_G.MonthlyActivityAlertSystem] = AlertTemplateFunc[_G.CriteriaAlertSystem]
    end

    -- 3.80.1: Garrison alert systems not available; already nil-guarded
    if _G.GarrisonTalentAlertSystem and _G.GarrisonBuildingAlertSystem and AlertTemplateFunc[_G.GarrisonTalentAlertSystem] then
        AlertTemplateFunc[_G.GarrisonBuildingAlertSystem] = AlertTemplateFunc[_G.GarrisonTalentAlertSystem]
    end
    if _G.NewRecipeLearnedAlertSystem and _G.SkillLineSpecsUnlockedAlertSystem and AlertTemplateFunc[_G.NewRecipeLearnedAlertSystem] then
        AlertTemplateFunc[_G.SkillLineSpecsUnlockedAlertSystem] = AlertTemplateFunc[_G.NewRecipeLearnedAlertSystem]
    end
    if _G.GarrisonMissionAlertSystem and AlertTemplateFunc[_G.GarrisonMissionAlertSystem] then
        if _G.GarrisonShipMissionAlertSystem then
            AlertTemplateFunc[_G.GarrisonShipMissionAlertSystem] = AlertTemplateFunc[_G.GarrisonMissionAlertSystem]
        end
        if _G.GarrisonShipFollowerAlertSystem then
            AlertTemplateFunc[_G.GarrisonShipFollowerAlertSystem] = AlertTemplateFunc[_G.GarrisonMissionAlertSystem]
        end
        if _G.GarrisonRandomMissionAlertSystem then
            AlertTemplateFunc[_G.GarrisonRandomMissionAlertSystem] = AlertTemplateFunc[_G.GarrisonMissionAlertSystem]
        end
        if _G.GarrisonFollowerAlertSystem then
            AlertTemplateFunc[_G.GarrisonFollowerAlertSystem] = AlertTemplateFunc[_G.GarrisonMissionAlertSystem]
        end
    end

    hooksecurefunc(_G.AlertFrame, 'AddAlertFrame', function(_, frame)
        if not frame or not frame.queue then
            return
        end
        local func = AlertTemplateFunc[frame.queue]
        if func then
            func(frame)
            fixAnim(frame)
        end
    end)

    -- Reward Icons
    hooksecurefunc('StandardRewardAlertFrame_AdjustRewardAnchors', function(frame)
        if frame.RewardFrames then
            for i = 1, frame.numUsedRewardFrames do
                local reward = frame.RewardFrames[i]
                if not reward.bg then
                    select(2, reward:GetRegions()):SetTexture('')
                    reward.texture:ClearAllPoints()
                    reward.texture:SetInside(reward, 6, 6)
                    reward.bg = F.ReskinIcon(reward.texture)
                end
            end
        end
    end)

    -- BonusRollLootWonFrame
    hooksecurefunc('LootWonAlertFrame_SetUp', function(frame)
        local lootItem = frame.lootItem
        if not frame.bg then
            frame.bg = F.SetBD(frame)
            frame.bg:SetInside(frame, 10, 10)
            fixAnim(frame)

            frame.shine:SetTexture('')
            F.ReskinIcon(lootItem.Icon)

            lootItem.SpecRing:SetTexture('')
            lootItem.SpecIcon:SetPoint('TOPLEFT', lootItem.Icon, -5, 5)
            lootItem.SpecIcon.bg = F.ReskinIcon(lootItem.SpecIcon)
        end

        frame.glow:SetTexture('')
        frame.Background:SetTexture('')
        frame.PvPBackground:SetTexture('')
        frame.BGAtlas:SetAlpha(0)
        lootItem.IconBorder:SetTexture('')
    end)
end)