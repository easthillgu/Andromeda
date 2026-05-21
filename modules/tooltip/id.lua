local F, C, L = unpack(select(2, ...))
local TOOLTIP = F:GetModule('Tooltip')

local LEARNT_STRING = '|cffff0000' .. _G.ALREADY_LEARNED .. '|r'

local typesList = {
    spell = _G.SPELLS .. 'ID:',
    item = _G.ITEMS .. 'ID:',
    quest = _G.QUESTS_LABEL .. 'ID:',
    talent = _G.TALENT .. 'ID:',
    achievement = _G.ACHIEVEMENTS .. 'ID:',
    currency = _G.CURRENCY .. 'ID:',
    azerite = L['Trait'] .. 'ID:',
}

function TOOLTIP:AddLineForId(id, linkType, noadd)
    if self:IsForbidden() then
        return
    end

    if C.DB.Tooltip.ShowIdByAlt and not IsAltKeyDown() then
        return
    end

    for i = 1, self:NumLines() do
        local line = _G[self:GetName() .. 'TextLeft' .. i]
        if not line then
            break
        end
        local text = line:GetText()
        if text and text == linkType then
            return
        end
    end

    if linkType == typesList.spell and IsPlayerSpell(id) then
        if C_MountJournal and C_MountJournal.GetMountFromSpell and C_MountJournal.GetMountFromSpell(id) then
            self:AddLine(LEARNT_STRING)
        end
    end

    if not noadd then
        self:AddLine(' ')
    end

    self:AddDoubleLine(linkType, format(C.INFO_COLOR .. '%s|r', id), 0.5, 0.8, 1)
    self:Show()
end

function TOOLTIP:SetHyperLinkID(link)
    if self:IsForbidden() then
        return
    end

    local linkType, id = strmatch(link, '^(%a+):(%d+)')
    if not linkType or not id then
        return
    end

    if linkType == 'spell' or linkType == 'enchant' or linkType == 'trade' then
        TOOLTIP.AddLineForId(self, id, typesList.spell)
    elseif linkType == 'talent' then
        TOOLTIP.AddLineForId(self, id, typesList.talent, true)
    elseif linkType == 'quest' then
        TOOLTIP.AddLineForId(self, id, typesList.quest)
    elseif linkType == 'achievement' then
        TOOLTIP.AddLineForId(self, id, typesList.achievement)
    elseif linkType == 'item' then
        TOOLTIP.AddLineForId(self, id, typesList.item)
    elseif linkType == 'currency' then
        TOOLTIP.AddLineForId(self, id, typesList.currency)
    end
end

function TOOLTIP:AddIDs()
    if not C.DB.Tooltip.ShowId then
        return
    end

    local GameTooltip = _G.GameTooltip
    local ItemRefTooltip = _G.ItemRefTooltip

    hooksecurefunc(GameTooltip, 'SetHyperlink', TOOLTIP.SetHyperLinkID)
    hooksecurefunc(ItemRefTooltip, 'SetHyperlink', TOOLTIP.SetHyperLinkID)

    hooksecurefunc(GameTooltip, 'SetUnitAura', function(self, ...)
        if self:IsForbidden() then
            return
        end

        local _, _, _, _, _, _, caster, _, _, id = UnitAura(...)
        if id then
            TOOLTIP.AddLineForId(self, id, typesList.spell)
        end

        if caster then
            self:AddLine(' ')
            local name = GetUnitName(caster, true)
            local hexColor = F:RgbToHex(F:UnitColor(caster))
            self:AddDoubleLine(L['From'] .. ':', hexColor .. name)
            self:Show()
        end
    end)

    hooksecurefunc('SetItemRef', function(link)
        local id = tonumber(strmatch(link, 'spell:(%d+)'))
        if id then
            TOOLTIP.AddLineForId(ItemRefTooltip, id, typesList.spell)
        end
    end)

    GameTooltip:HookScript('OnTooltipSetItem', function(self)
        if self:IsForbidden() then
            return
        end
        local _, link = self:GetItem()
        if link then
            local id = GetItemInfoFromHyperlink(link)
            if id then
                TOOLTIP.AddLineForId(self, id, typesList.item)
            end
        end
    end)

    GameTooltip:HookScript('OnTooltipSetSpell', function(self)
        if self:IsForbidden() then
            return
        end
        local _, id = self:GetSpell()
        if id then
            TOOLTIP.AddLineForId(self, id, typesList.spell)
        end
    end)

    hooksecurefunc(GameTooltip, 'SetQuestLogItem', function(self, type, index)
        if self:IsForbidden() then
            return
        end
        local link = GetQuestLogItemLink(type, index)
        if link then
            local id = GetItemInfoFromHyperlink(link)
            if id then
                TOOLTIP.AddLineForId(self, id, typesList.item)
            end
        end
    end)

    hooksecurefunc(GameTooltip, 'SetLootItem', function(self, slot)
        if self:IsForbidden() then
            return
        end
        local link = GetLootSlotLink(slot)
        if link then
            local id = GetItemInfoFromHyperlink(link)
            if id then
                TOOLTIP.AddLineForId(self, id, typesList.item)
            end
        end
    end)

    hooksecurefunc(GameTooltip, 'SetMerchantItem', function(self, index)
        if self:IsForbidden() then
            return
        end
        local link = GetMerchantItemLink(index)
        if link then
            local id = GetItemInfoFromHyperlink(link)
            if id then
                TOOLTIP.AddLineForId(self, id, typesList.item)
            end
        end
    end)

    hooksecurefunc(GameTooltip, 'SetQuestLogReward', function(self, questID)
        if self:IsForbidden() then
            return
        end
        local link = GetQuestLogItemLink('reward', questID)
        if link then
            local id = GetItemInfoFromHyperlink(link)
            if id then
                TOOLTIP.AddLineForId(self, id, typesList.item)
            end
        end
    end)

    hooksecurefunc(GameTooltip, 'SetAchievement', function(self, id)
        if self:IsForbidden() then
            return
        end
        if id then
            TOOLTIP.AddLineForId(self, id, typesList.achievement)
        end
    end)

    hooksecurefunc('QuestMapLogTitleButton_OnEnter', function(self)
        if self.questID then
            TOOLTIP.AddLineForId(GameTooltip, self.questID, typesList.quest)
        end
    end)
end
