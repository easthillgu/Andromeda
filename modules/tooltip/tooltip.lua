local F, C, L = unpack(select(2, ...))
local TOOLTIP = F:GetModule('Tooltip')

local npcIDstring = '%s ' .. C.INFO_COLOR .. '%s'
local ignoreString = '|cffff0000' .. _G.IGNORED .. ':|r %s'
local blanchyFix = '|n%s+|n'

TOOLTIP.MountIDs = {}
if C_MountJournal then
    local mountIDs = C_MountJournal.GetMountIDs()
    for _, mountID in ipairs(mountIDs) do
        local _, spellID = C_MountJournal.GetMountInfoByID(mountID)
        TOOLTIP.MountIDs[spellID] = mountID
    end
end

local classification = {
    elite = ' |cffcc8800' .. _G.ELITE .. '|r',
    rare = ' |cffff99cc' .. L['Rare'] .. '|r',
    rareelite = ' |cffff99cc' .. L['Rare'] .. '|r ' .. '|cffcc8800' .. _G.ELITE .. '|r',
    worldboss = ' |cffff0000' .. _G.BOSS .. '|r',
}

local function CanAccessObject(obj)
    return issecure() or not obj:IsForbidden()
end

function TOOLTIP:GetUnit()
    -- 3.80.1: use native GetUnit() (returns name, unit), not Retail GetTooltipData()
    local _, unit = self:GetUnit()
    return unit
end

function TOOLTIP:HideTooltip()
    self:Hide()
end

function TOOLTIP:UpdateUnitInfo(unit)
    if not unit then
        return
    end

    local r, g, b = F:UnitColor(unit)
    local level = UnitLevel(unit)
    local name = GetUnitName(unit, true)
    local _, class = UnitClass(unit)
    local race = UnitRace(unit)
    local classification = UnitClassification(unit)
    local faction = UnitFactionGroup(unit)
    local guild, guildRankName, _, guildRealm = GetGuildInfo(unit)
    local relationship = UnitRealmRelationship(unit)
    local title = UnitPVPName(unit)
    local isPlayer = UnitIsPlayer(unit)

    self:ClearLines()

    if title then
        self:AddLine(title)
    end

    if name then
        local nameText = name
        if race and isPlayer then
            nameText = nameText .. ' ' .. race
        end
        if classification and classification ~= 'normal' then
            nameText = nameText .. (classification[classification] or '')
        end
        self:AddLine(nameText, r, g, b)
    end

    if level then
        local diffColor = GetQuestDifficultyColor(level)
        local levelText = _G.LEVEL .. ' ' .. level
        if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
            levelText = levelText .. ' ' .. _G.BATTLE_PET
        end
        self:AddLine(levelText, diffColor.r, diffColor.g, diffColor.b)
    end

    if guild and C.DB.Tooltip.HideGuildRank then
        local guildText = '<' .. guild .. '>'
        if guildRealm and guildRealm ~= GetRealmName() then
            guildText = guildText .. ' - ' .. guildRealm
        end
        if guildRankName then
            guildText = guildText .. ' [' .. guildRankName .. ']'
        end
        self:AddLine(guildText, 0.8, 0.8, 0.8)
    end

    if isPlayer and faction then
        local factionText = faction == 'Alliance' and _G.FACTION_ALLIANCE or _G.FACTION_HORDE
        self:AddLine(factionText, faction == 'Alliance' and 0.25 or 1, faction == 'Alliance' and 0.5 or 0.25, faction == 'Alliance' and 0.75 or 0.25)
    end

    if relationship and relationship == LE_REALM_RELATION_COALESCED then
        local realmName = GetRealmName()
        self:AddLine(realmName, 0.5, 0.5, 0.5)
    end

    local target = UnitName(unit .. 'target')
    if target then
        local tr, tg, tb = F:UnitColor(unit .. 'target')
        self:AddDoubleLine(_G.TARGET .. ':', target, 0.8, 0.8, 0.8, tr, tg, tb)
    end

    self:Show()
end

function TOOLTIP:OnTooltipSetUnit()
    if self:IsForbidden() then
        return
    end

    local unit = TOOLTIP.GetUnit(self)
    if not unit or not UnitExists(unit) then
        return
    end

    TOOLTIP.UpdateUnitInfo(self, unit)
end

function TOOLTIP:ResetUnit(btn)
    if (btn == 'LSHIFT' or btn == 'LALT') and UnitExists('mouseover') then
        _G.GameTooltip:RefreshData()
    end
end

function TOOLTIP:GameTooltip_OnUpdate(elapsed)
    if not self:IsVisible() then
        return
    end

    if self.fadeOutTimer and self.fadeOutTimer < self.fadeOutTime then
        self.fadeOutTimer = self.fadeOutTimer + elapsed
        if self.fadeOutTimer >= self.fadeOutTime then
            self:FadeOut()
        end
    end
end

function TOOLTIP:FadeOut()
    UIFrameFadeOut(self, 0.3, self:GetAlpha(), 0)
end

function TOOLTIP:GameTooltip_SetDefaultAnchor(parent)
    if not CanAccessObject(self) then
        return
    end
    if not parent then
        return
    end

    if C.DB.Tooltip.FollowCursor then
        self:SetOwner(parent, 'ANCHOR_CURSOR_RIGHT')
    else
        if not mover then
            mover = F.Mover(self, L['Tooltip'], 'GameTooltip', { 'BOTTOMRIGHT', _G.UIParent, 'BOTTOMRIGHT', -C.UI_GAP, 260 }, 240, 120)
        end
        self:SetOwner(parent, 'ANCHOR_NONE')
        self:ClearAllPoints()
        self:SetPoint('BOTTOMRIGHT', mover)
    end
end

function TOOLTIP:RefreshStatusBar()
    if not self.text then
        local fontPath = C.Assets.Fonts.Bold
        local fontSize = 11
        local outline = _G.ANDROMEDA_ADB.FontOutline
        self.text = self:CreateFontString(nil, 'OVERLAY')
        self.text:SetFont(fontPath, fontSize, outline or 'NONE')
        self.text:SetPoint('CENTER')
        self.text:SetTextColor(1, 1, 1)
    end

    local min, max = self:GetMinMaxValues()
    local value = self:GetValue()
    if max and max > 0 then
        local percentage = math.floor((value / max) * 100)
        self.text:SetText(percentage .. '%')
    else
        self.text:SetText('')
    end
end

function TOOLTIP:ReskinStatusBar()
    self:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
    self:SetHeight(3)
    F.CreateBDFrame(self, 0.25)
end

function TOOLTIP:GameTooltip_ShowStatusBar()
    if not self or not CanAccessObject(self) then
        return
    end

    local statusBar = _G.GameTooltip.StatusBar
    if statusBar and not statusBar.styled then
        TOOLTIP.ReskinStatusBar(statusBar)
        statusBar.styled = true
    end
end

function TOOLTIP:GameTooltip_ShowProgressBar()
    if not self or not CanAccessObject(self) then
        return
    end

    local progressBar = _G.GameTooltip.ProgressBar
    if progressBar and not progressBar.styled then
        F.StripTextures(progressBar)
        F.CreateBDFrame(progressBar, 0.25)
        progressBar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
        progressBar.styled = true
    end
end

function TOOLTIP:SetupFonts()
    local fontPath = C.Assets.Fonts.Regular
    local fontSize = 12
    local outline = _G.ANDROMEDA_ADB.FontOutline

    self:SetFont(fontPath, fontSize, outline or 'NONE')
    self:SetHeaderFont(fontPath, fontSize + 2, outline or 'NONE')
end

function TOOLTIP:ReskinTipIcon()
    if not C.DB.Tooltip.Icon then
        return
    end

    local icon = _G.GameTooltipIcon
    icon:SetTexCoord(unpack(C.TEX_COORD))
    F.CreateBDFrame(icon, 0)
    F.ReskinIconBorder(_G.GameTooltipIconBorder)
end

function TOOLTIP:AddIDs()
    if not C.DB.Tooltip.ShowId then
        return
    end

    hooksecurefunc(_G.TooltipDataProcessor, 'AddTooltipPostCall', function(type, func)
        if type == Enum.TooltipDataType.Item then
            local oldFunc = func
            func = function(self)
                oldFunc(self)
                local _, link = self:GetItem()
                if link then
                    local id = GetItemInfoFromHyperlink(link)
                    if id then
                        self:AddLine(C.INFO_COLOR .. _G.ITEMS .. 'ID:|r ' .. id)
                    end
                end
            end
        end
        if type == Enum.TooltipDataType.Spell then
            local oldFunc = func
            func = function(self)
                oldFunc(self)
                local _, id = self:GetSpell()
                if id then
                    self:AddLine(C.INFO_COLOR .. _G.SPELLS .. 'ID:|r ' .. id)
                end
            end
        end
        if type == Enum.TooltipDataType.Quest then
            local oldFunc = func
            func = function(self)
                oldFunc(self)
                local id = self:GetQuestID()
                if id then
                    self:AddLine(C.INFO_COLOR .. _G.QUESTS_LABEL .. 'ID:|r ' .. id)
                end
            end
        end
    end)
end

function TOOLTIP:ItemInfo()
    if not C.DB.Tooltip.ShowItemInfo then
        return
    end

    _G.GameTooltip:HookScript('OnTooltipSetItem', function(self)
        if self:IsForbidden() then
            return
        end

        local _, link = self:GetItem()
        if link then
            local itemID = GetItemInfoFromHyperlink(link)
            if itemID then
                local itemLevel = GetDetailedItemLevelInfo and GetDetailedItemLevelInfo(link)
                if itemLevel then
                    self:AddLine(C.INFO_COLOR .. _G.STAT_AVERAGE_ITEM_LEVEL .. ':|r ' .. itemLevel)
                end

                local itemClassID = select(12, GetItemInfo(link))
                if itemClassID then
                    local itemClassName = GetItemClassInfo(itemClassID)
                    if itemClassName then
                        self:AddLine(C.INFO_COLOR .. _G.ITEM_CLASS .. ':|r ' .. itemClassName)
                    end
                end
            end
        end
    end)
end

function TOOLTIP:MountSource()
    _G.GameTooltip:HookScript('OnTooltipSetSpell', function(self)
        if self:IsForbidden() then
            return
        end

        local _, id = self:GetSpell()
        if id and TOOLTIP.MountIDs[id] then
            local mountID = TOOLTIP.MountIDs[id]
            if C_MountJournal then
                local _, _, sourceText = C_MountJournal.GetMountInfoExtraByID(mountID)
                if sourceText then
                    self:AddLine(C.INFO_COLOR .. _G.SOURCES .. ':|r ' .. sourceText)
                end
            end
        end
    end)
end

function TOOLTIP:HyperLink()
    if not C.DB.Tooltip.LinkIcon then
        return
    end

    hooksecurefunc(_G.GameTooltip, 'SetHyperlink', function(self)
        if self:IsForbidden() then
            return
        end

        local link = select(2, self:GetItem())
        if link then
            local icon = GetItemIcon(link)
            if icon then
                local title = _G[self:GetName() .. 'TextLeft1']
                if title then
                    local text = title:GetText()
                    if text then
                        title:SetText('|T' .. icon .. ':16:16:0:0:64:64:4:60:4:60|t ' .. text)
                    end
                end
            end
        end
    end)
end

function TOOLTIP:CovenantInfo()
    if not C.DB.Tooltip.Covenant then
        return
    end

    hooksecurefunc(_G.GameTooltip, 'SetUnit', function(self)
        if self:IsForbidden() then
            return
        end

        local unit = select(2, self:GetUnit())
        if unit and UnitIsPlayer(unit) then
            local covenantID = C_CovenantSanctumUI.GetPlayerCovenantID()
            if covenantID then
                local covenantName = C_CovenantSanctumUI.GetCovenantInfo(covenantID)
                if covenantName then
                    self:AddLine(C.INFO_COLOR .. _G.COVENANT .. ':|r ' .. covenantName)
                end
            end
        end
    end)
end

function TOOLTIP:Achievement()
    if not C.DB.Tooltip.Achievement then
        return
    end

    hooksecurefunc(_G.GameTooltip, 'SetUnit', function(self)
        if self:IsForbidden() then
            return
        end

        local unit = select(2, self:GetUnit())
        if unit and UnitIsPlayer(unit) then
            local guid = UnitGUID(unit)
            if guid then
                local achievementID = tonumber(strmatch(guid, 'Player%-.-%-.-%-.-%-.-%-(%d+)'))
                if achievementID then
                    local _, name, _, completed = GetAchievementInfo(achievementID)
                    if name then
                        self:AddLine(C.INFO_COLOR .. _G.ACHIEVEMENTS .. ':|r ' .. name, completed and 0 or 1, completed and 1 or 0, 0)
                    end
                end
            end
        end
    end)
end

function TOOLTIP:AzeriteArmor()
    if not C.DB.Tooltip.AzeriteArmor then
        return
    end

    _G.GameTooltip:HookScript('OnTooltipSetItem', function(self)
        if self:IsForbidden() then
            return
        end

        local _, link = self:GetItem()
        if link then
            if C_AzeriteItem and C_AzeriteItem.HasActiveAzeriteItem() then
                local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
                if azeriteItemLocation then
                    local azeriteLevel = C_AzeriteItem.GetAzeriteItemLevel(azeriteItemLocation)
                    if azeriteLevel then
                        self:AddLine(C.INFO_COLOR .. _G.AZERITE .. ':|r ' .. azeriteLevel)
                    end
                end
            end
        end
    end)
end

function TOOLTIP:ParagonRewards()
    if not C.DB.Tooltip.ParagonRewards then
        return
    end

    hooksecurefunc(_G.GameTooltip, 'SetFaction', function(self, factionIndex)
        if self:IsForbidden() then
            return
        end

        local currentRank, maxRank = GetFactionParagonInfo(factionIndex)
        if currentRank and maxRank then
            local value = currentRank % maxRank
            local percentage = math.floor((value / maxRank) * 100)
            self:AddLine(C.INFO_COLOR .. _G.PARAGON .. ':|r ' .. percentage .. '%')
        end
    end)
end

function TOOLTIP:FixStoneSoupError()
    hooksecurefunc(_G.GameTooltip, 'SetRecipeResultItem', function(self, recipeID)
        local itemID = C_TradeSkillUI.GetTradeSkillLineForRecipe(recipeID)
        if itemID == 2653 then
            for i = 3, self:NumLines() do
                local line = _G[self:GetName() .. 'TextLeft' .. i]
                if line then
                    local text = line:GetText()
                    if text and text:find('Citrine Chestnut') then
                        line:SetText('')
                    end
                end
            end
        end
    end)
end

function TOOLTIP:OnLogin()
    if not C.DB.Tooltip.Enable then
        return
    end

    -- 3.80.1: use HookScript instead of TooltipDataProcessor (TacoTip pattern)
    _G.GameTooltip:HookScript('OnTooltipSetUnit', TOOLTIP.OnTooltipSetUnit)
    if _G.GameTooltip.StatusBar then
        hooksecurefunc(_G.GameTooltip.StatusBar, 'SetValue', TOOLTIP.RefreshStatusBar)
    end
    if _G.TooltipDataProcessor then
        _G.TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, TOOLTIP.UpdateFactionLine)
        _G.TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, TOOLTIP.FixRecipeItemNameWidth)
    end

    hooksecurefunc('GameTooltip_ShowStatusBar', TOOLTIP.GameTooltip_ShowStatusBar)
    hooksecurefunc('GameTooltip_ShowProgressBar', TOOLTIP.GameTooltip_ShowProgressBar)
    hooksecurefunc('GameTooltip_SetDefaultAnchor', TOOLTIP.GameTooltip_SetDefaultAnchor)

    _G.GameTooltip:HookScript('OnUpdate', TOOLTIP.GameTooltip_OnUpdate)
    _G.GameTooltip.FadeOut = TOOLTIP.FadeOut

    TOOLTIP:ReskinTipIcon()
    TOOLTIP:SetupFonts()
    TOOLTIP:AddIDs()
    TOOLTIP:ItemInfo()
    TOOLTIP:MountSource()
    TOOLTIP:HyperLink()
    TOOLTIP:CovenantInfo()
    TOOLTIP:Achievement()
    TOOLTIP:AzeriteArmor()
    TOOLTIP:ParagonRewards()
    TOOLTIP:FixStoneSoupError()

    F:RegisterEvent('MODIFIER_STATE_CHANGED', TOOLTIP.ResetUnit)
end
