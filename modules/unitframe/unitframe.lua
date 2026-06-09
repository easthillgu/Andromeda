local F, C = unpack(select(2, ...))
local UNITFRAME = F:GetModule('UnitFrame')
local colors = F.Libs.oUF.colors

UNITFRAME.Positions = {
    player = { 'CENTER', _G.UIParent, 'CENTER', 0, -180 },
    pet = { 'RIGHT', 'oUF_Player', 'LEFT', -6, 0 },
    target = { 'LEFT', _G.UIParent, 'CENTER', 120, -140 },
    tot = { 'LEFT', 'oUF_Target', 'RIGHT', 6, 0 },
    focus = { 'BOTTOM', _G.UIParent, 'BOTTOM', -240, 220 },
    tof = { 'TOPLEFT', 'oUF_Focus', 'TOPRIGHT', 6, 0 },
    boss = { 'CENTER', _G.UIParent, 'CENTER', 500, 0 },
    arena = { 'CENTER', _G.UIParent, 'CENTER', 500, 0 },
    party = { 'CENTER', _G.UIParent, 'CENTER', -330, 0 },
    raid = { 'TOPRIGHT', 'Minimap', 'TOPLEFT', -6, -42 },
    simple = { 'TOPLEFT', C.UI_GAP, -100 },
}

-- Utility

function UNITFRAME:GetHeightVal(bar, val1, val2, val3, val4, val5, val6, val7, val8, val9, val10)
    local style = bar.unitStyle
    if style == 'player' then
        return val1
    elseif style == 'pet' then
        return val2
    elseif style == 'target' then
        return val3
    elseif style == 'targettarget' then
        return val4
    elseif style == 'focus' then
        return val5
    elseif style == 'focustarget' then
        return val6
    elseif style == 'party' then
        return val7
    elseif style == 'raid' then
        return val8
    elseif style == 'boss' then
        return val9
    elseif style == 'arena' then
        return val10
    end
end

function UNITFRAME:UpdateHealthDefaultColor()
    local color = C.DB.Unitframe.HealthColor
    colors.health = { color.r, color.g, color.b }
end

function UNITFRAME:UpdateClassColor()
    local classColors = C.ClassColors
    for class, value in pairs(classColors) do
        colors.class[class] = { value.r, value.g, value.b }
    end
end

local function replacePowerColor(name, index, color)
    colors.power[name] = color
    colors.power[index] = colors.power[name]
end

-- Colors

do
    replacePowerColor('MANA', 0, { 0.06, 0.56, 0.89 })
    replacePowerColor('RAGE', 1, { 0.94, 0.19, 0.18 })
    replacePowerColor('FOCUS', 2, { 0.84, 0.51, 0.37 })
    replacePowerColor('ENERGY', 3, { 0.94, 0.19, 0.18 })
    replacePowerColor('COMBO_POINTS', 4, { 1, 0.77, 0.08 })
    replacePowerColor('RUNES', 5, { 0.22, 0.95, 0.97 })
    replacePowerColor('RUNIC_POWER', 6, { 0.22, 0.95, 0.97 })
    replacePowerColor('SOUL_SHARDS', 7, { 0.65, 0.45, 1 })
    replacePowerColor('LUNAR_POWER', 8, { 0.65, 0.45, 1 })
    replacePowerColor('HOLY_POWER', 9, { 1, 0.77, 0.08 })
    replacePowerColor('MAELSTROM', 11, { 0.94, 0.19, 0.18 })
    replacePowerColor('CHI', 12, { 0.18, 0.85, 0.59 })
    replacePowerColor('INSANITY', 13, { 0.65, 0.45, 1 })
    replacePowerColor('ARCANE_CHARGES', 16, { 0.22, 0.95, 0.97 })
    replacePowerColor('FURY', 17, { 0.94, 0.19, 0.18 })
    replacePowerColor('PAIN', 18, { 0.94, 0.19, 0.18 })

    colors.power.max = {
        COMBO_POINTS = { 161 / 255, 92 / 255, 255 / 255 },
        SOUL_SHARDS = { 255 / 255, 26 / 255, 48 / 255 },
        LUNAR_POWER = { 161 / 255, 92 / 255, 255 / 255 },
        HOLY_POWER = { 255 / 255, 26 / 255, 48 / 255 },
        CHI = { 0 / 255, 143 / 255, 247 / 255 },
        ARCANE_CHARGES = { 5 / 255, 96 / 255, 250 / 255 },
    }

    colors.runes = {
        [1] = { 0.91, 0.23, 0.21 }, -- Blood
        [2] = { 0.23, 0.67, 0.97 }, -- Frost
        [3] = { 0.41, 0.97, 0.21 }, -- Unholy
    }

    colors.debuff = {
        Curse = { 0.6, 0.2, 1.0 },
        Disease = { 0.6, 0.4, 0.0 },
        Magic = { 0.2, 0.5, 1.0 },
        Poison = { 0.2, 0.8, 0.2 },
        none = { 1.0, 0.1, 0.2 }, -- Physical, etc.
    }

    colors.reaction = {
        [1] = { 223 / 255, 54 / 255, 15 / 255 }, -- Hated / Enemy
        [2] = { 223 / 255, 54 / 255, 15 / 255 },
        [3] = { 223 / 255, 54 / 255, 15 / 255 },
        [4] = { 232 / 255, 190 / 255, 54 / 255 },
        [5] = { 74 / 255, 209 / 255, 68 / 255 },
        [6] = { 74 / 255, 209 / 255, 68 / 255 },
        [7] = { 74 / 255, 209 / 255, 68 / 255 },
        [8] = { 74 / 255, 209 / 255, 68 / 255 },
        [9] = { 69 / 255, 209 / 255, 155 / 255 }, -- Paragon (Reputation)
    }

    colors.smooth = { 1, 0, 0, 1, 1, 0, 0, 1, 0 }
    colors.disconnected = { 0.5, 0.5, 0.5 }
end

-- Backdrop

local function onEnter(self)
    UnitFrame_OnEnter(self)
    self.__highlight:Show()
end

local function onLeave(self)
    UnitFrame_OnLeave(self)
    self.__highlight:Hide()
end

function UNITFRAME:CreateBackdrop(self, onKeyDown)
    local hl = self:CreateTexture(nil, 'OVERLAY')
    hl:SetAllPoints()
    hl:SetTexture('Interface\\PETBATTLES\\PetBattle-SelectedPetGlow')
    hl:SetTexCoord(0, 1, 0.5, 1)
    hl:SetVertexColor(0.6, 0.6, 0.6)
    hl:SetBlendMode('ADD')
    hl:Hide()

    self.__highlight = hl

    self:RegisterForClicks(onKeyDown and 'AnyDown' or 'AnyUp')
    self:HookScript('OnEnter', onEnter)
    self:HookScript('OnLeave', onLeave)

    local bg = F.SetBD(self)
    bg:SetBackdropBorderColor(0, 0, 0, 1)
    bg:SetFrameStrata('BACKGROUND')

    self.__bg = bg
    self.__sd = bg.__shadow
end

-- Target border

local function updateTargetBorder(self)
    if UnitIsUnit('target', self.unit) then
        self.__tarBorder:Show()
    else
        self.__tarBorder:Hide()
    end
end

function UNITFRAME:CreateTargetBorder(self)
    local sd = F.CreateBDFrame(self, 0)
    sd:SetBackdropBorderColor(1, 1, 1)
    -- sd:SetFrameLevel(self:GetFrameLevel() + 5)
    sd:Hide()

    self.__tarBorder = sd

    self:RegisterEvent('PLAYER_TARGET_CHANGED', updateTargetBorder, true)
    self:RegisterEvent('GROUP_ROSTER_UPDATE', updateTargetBorder, true)
end

-- Sound effect for target/focus changed

function UNITFRAME:PlayerTargetChanged()
    -- 3.80.1: C_PlayerInteractionManager is Retail DF API; nil guard
    local isReplacing = C_PlayerInteractionManager and C_PlayerInteractionManager.IsReplacingUnit and C_PlayerInteractionManager.IsReplacingUnit()
    if UnitExists('target') and not isReplacing then
        if UnitIsEnemy('target', 'player') then
            PlaySound(SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
        elseif UnitIsFriend('target', 'player') then
            PlaySound(SOUNDKIT.IG_CHARACTER_NPC_SELECT)
        else
            PlaySound(SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT)
        end
    else
        PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT)
    end
end

function UNITFRAME:PlayerFocusChanged()
    -- 3.80.1: C_PlayerInteractionManager is Retail DF API; nil guard
    local isReplacing = C_PlayerInteractionManager and C_PlayerInteractionManager.IsReplacingUnit and C_PlayerInteractionManager.IsReplacingUnit()
    if UnitExists('focus') and not isReplacing then
        if UnitIsEnemy('focus', 'player') then
            PlaySound(SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
        elseif UnitIsFriend('focus', 'player') then
            PlaySound(SOUNDKIT.IG_CHARACTER_NPC_SELECT)
        else
            PlaySound(SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT)
        end
    else
        PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT)
    end
end

function UNITFRAME:CreateTargetSound()
    F:RegisterEvent('PLAYER_TARGET_CHANGED', UNITFRAME.PlayerTargetChanged)
    F:RegisterEvent('PLAYER_FOCUS_CHANGED', UNITFRAME.PlayerFocusChanged)
end

-- Remove blizz raid frame

function UNITFRAME:RemoveBlizzRaidFrame()
    local function HideFrame(frameName)
        local frame = _G[frameName]
        if frame then
            frame:Hide()
            frame:UnregisterAllEvents()
            frame.Show = function() end
        end
    end

    HideFrame('RaidGroup1')
    HideFrame('RaidGroup2')
    HideFrame('RaidGroup3')
    HideFrame('RaidGroup4')
    HideFrame('RaidGroup5')
    HideFrame('RaidGroup6')
    HideFrame('RaidGroup7')
    HideFrame('RaidGroup8')
    HideFrame('PartyMemberFrame1')
    HideFrame('PartyMemberFrame2')
    HideFrame('PartyMemberFrame3')
    HideFrame('PartyMemberFrame4')
    HideFrame('PartyMemberFrame5')
    HideFrame('PartyMemberFrame1PetFrame')
    HideFrame('PartyMemberFrame2PetFrame')
    HideFrame('PartyMemberFrame3PetFrame')
    HideFrame('PartyMemberFrame4PetFrame')
    HideFrame('PartyMemberFrame5PetFrame')
    HideFrame('PartyFrame')

    -- 参考 NDui：使用 CompactRaidFrameManager_SetSetting 来隐藏 CompactRaidFrame
    -- 而不是直接隐藏 RaidFrame，保留社交界面中的团队管理功能
    if _G.CompactRaidFrameManager_SetSetting then
        _G.CompactRaidFrameManager_SetSetting("IsShown", "0")
        _G.UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
        CompactRaidFrameManager:UnregisterAllEvents()
        CompactRaidFrameManager:SetParent(_G.HiddenFrame or UIParent)
    elseif CompactRaidFrameManager then
        -- 经典版兼容：直接隐藏 CompactRaidFrame
        CompactRaidFrameManager:UnregisterAllEvents()
        CompactRaidFrameManager:Hide()
        CompactRaidFrameManager.Show = function() end
    end
end

-- Make sure the state of each element is reliable #TODO

function UNITFRAME:UpdateAllElements()
    UNITFRAME:UpdatePortrait()
    UNITFRAME:UpdateGCDTicker()
    UNITFRAME:UpdateAuras()
    UNITFRAME:UpdateFader()
    UNITFRAME:UpdateClassPower()
    UNITFRAME:UpdateRaidTargetIndicator()
end

function UNITFRAME:OnLogin()
    -- 3.80.1: EditModeManagerFrame doesn't exist, manually hide Blizzard castbars
    if _G.PlayerCastingBarFrame then
        _G.PlayerCastingBarFrame:Hide()
        _G.PlayerCastingBarFrame:UnregisterAllEvents()
        _G.PlayerCastingBarFrame.Show = function() end
    end
    if _G.PetCastingBarFrame then
        _G.PetCastingBarFrame:Hide()
        _G.PetCastingBarFrame:UnregisterAllEvents()
        _G.PetCastingBarFrame.Show = function() end
    end

    -- Hide default combo point frame
    local function hideComboFrame(frame)
        if _G[frame] then
            _G[frame]:Hide()
            _G[frame]:UnregisterAllEvents()
            _G[frame].Show = function() end
        end
    end

    hideComboFrame('ComboFrame')
    hideComboFrame('TargetFrameComboFrame')
    hideComboFrame('PlayerFrameComboFrame')

    -- 使用官方 API 隐藏 Raid 框架（参考 NDui 和 ElvUI）
    F.Libs.oUF:DisableBlizzardRaid()

    -- Initialize ClickCast defaults
    UNITFRAME:InitDefaultClickSets()
    UNITFRAME:AddClickSetsListener()

    UNITFRAME:InitFilters()
    UNITFRAME:SpawnUnits()
    UNITFRAME:UpdateAllElements()
end
