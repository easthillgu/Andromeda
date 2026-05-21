local F, C = unpack(select(2, ...))
local TOOLTIP = F:GetModule('Tooltip')

local newString = '0:0:64:64:5:59:5:59'

function TOOLTIP:SetupTooltipIcon(icon)
    local title = icon and _G[self:GetName() .. 'TextLeft1']
    local titleText = title and title:GetText()
    if titleText and not strfind(titleText, ':20:20:') then
        title:SetFormattedText('|T%s:20:20:' .. newString .. ':%d|t %s', icon, 20, titleText)
    end

    for i = 2, self:NumLines() do
        local line = _G[self:GetName() .. 'TextLeft' .. i]
        if not line then
            break
        end
        local text = line:GetText()
        if text and text ~= ' ' and not strfind(text, 'UI%-CharacterCreate%-Classes') then
            local newText, count = gsub(text, '|T([^:]-):[%d+:]+|t', '|T%1:14:14:' .. newString .. '|t')
            if count > 0 then
                line:SetText(newText)
            end
        end
    end
end

function TOOLTIP:HookTooltipCleared()
    self.tipModified = false
end

function TOOLTIP:HookTooltipSetItem()
    if not self.tipModified then
        local _, link = self:GetItem()
        if link then
            TOOLTIP.SetupTooltipIcon(self, GetItemIcon(link))
        end
        self.tipModified = true
    end
end

function TOOLTIP:HookTooltipSetSpell()
    if not self.tipModified then
        local _, id = self:GetSpell()
        if id then
            TOOLTIP.SetupTooltipIcon(self, GetSpellTexture(id))
        end
        self.tipModified = true
    end
end

function TOOLTIP:HookTooltipMethod()
    self:HookScript('OnTooltipCleared', TOOLTIP.HookTooltipCleared)
end

function TOOLTIP:ReskinRewardIcon()
    self.Icon:SetTexCoord(unpack(C.TEX_COORD))
    self.bg = F.CreateBDFrame(self.Icon, 0)
    F.ReskinIconBorder(self.IconBorder)
end

function TOOLTIP:ReskinTipIcon()
    if not C.DB.Tooltip.Icon then
        return
    end

    local GameTooltip = _G.GameTooltip
    local ItemRefTooltip = _G.ItemRefTooltip
    local EmbeddedItemTooltip = _G.EmbeddedItemTooltip

    TOOLTIP.HookTooltipMethod(GameTooltip)
    TOOLTIP.HookTooltipMethod(ItemRefTooltip)

    hooksecurefunc(GameTooltip, 'SetUnitAura', function(self)
        TOOLTIP.SetupTooltipIcon(self)
    end)

    if GameTooltip.SetItem then
        hooksecurefunc(GameTooltip, 'SetItem', TOOLTIP.HookTooltipSetItem)
    end
    if GameTooltip.SetSpell and type(GameTooltip.SetSpell) == 'function' then
        hooksecurefunc(GameTooltip, 'SetSpell', TOOLTIP.HookTooltipSetSpell)
    end
    if ItemRefTooltip.SetItem and type(ItemRefTooltip.SetItem) == 'function' then
        hooksecurefunc(ItemRefTooltip, 'SetItem', TOOLTIP.HookTooltipSetItem)
    end
    if ItemRefTooltip.SetSpell and type(ItemRefTooltip.SetSpell) == 'function' then
        hooksecurefunc(ItemRefTooltip, 'SetSpell', TOOLTIP.HookTooltipSetSpell)
    end

    if GameTooltip.SetAzeriteEssence then
        hooksecurefunc(GameTooltip, 'SetAzeriteEssence', function(self)
            TOOLTIP.SetupTooltipIcon(self)
        end)
    end

    if GameTooltip.SetAzeriteEssenceSlot then
        hooksecurefunc(GameTooltip, 'SetAzeriteEssenceSlot', function(self)
            TOOLTIP.SetupTooltipIcon(self)
        end)
    end

    TOOLTIP.ReskinRewardIcon(GameTooltip.ItemTooltip)
    TOOLTIP.ReskinRewardIcon(EmbeddedItemTooltip.ItemTooltip)
end
