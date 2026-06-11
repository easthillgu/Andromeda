local F, C = unpack(select(2, ...))
local UNITFRAME = F:GetModule('UnitFrame')

-- ClickCast Key Mapping
local mouseButtonList = { 'LMB', 'RMB', 'MMB', 'MB4', 'MB5' }
local modKeyList = { '', 'ALT-', 'CTRL-', 'SHIFT-', 'ALT-CTRL-', 'ALT-SHIFT-', 'CTRL-SHIFT-', 'ALT-CTRL-SHIFT-' }
local numModKeys = #modKeyList

local keyList = {}
for i = 1, #mouseButtonList do
    local button = mouseButtonList[i]
    for j = 1, numModKeys do
        local modKey = modKeyList[j]
        keyList[modKey .. button] = modKey .. '%s' .. i
    end
end

-- MouseWheel support
local wheelGroupIndex = {}
for i = 1, numModKeys do
    local modKey = modKeyList[i]
    wheelGroupIndex[5 + i] = modKey .. 'MOUSEWHEELUP'
    wheelGroupIndex[numModKeys + 5 + i] = modKey .. 'MOUSEWHEELDOWN'
end

for keyIndex, keyString in pairs(wheelGroupIndex) do
    keyString = keyString:gsub('MOUSEWHEELUP', 'MWU')
    keyString = keyString:gsub('MOUSEWHEELDOWN', 'MWD')
    keyList[keyString] = '%s' .. keyIndex
end

-- Default ClickSets per class
C.ClickCastList = {
    ['DRUID'] = {
        ['RMB'] = 774, -- 回春术
        ['ALT-RMB'] = 8936, -- 愈合
        ['MMB'] = 20484, -- 复生
    },
    ['SHAMAN'] = {
        ['MWU'] = 526, -- 消毒术
        ['MMB'] = 2008, -- 先祖之魂
    },
    ['PALADIN'] = {
        ['MWU'] = 4987, -- 清洁术
        ['RMB'] = 20473, -- 神圣震击
        ['ALT-RMB'] = 1022, -- 保护祝福
        ['MMB'] = 10322, -- 救赎
    },
    ['PRIEST'] = {
        ['MWU'] = 527, -- 驱散魔法
        ['RMB'] = 17, -- 真言术盾
        ['ALT-RMB'] = 139, -- 恢复
        ['MMB'] = 2006, -- 复活术
    },
    ['MAGE'] = {
        ['MWU'] = 475, -- 解除诅咒
        ['MWD'] = 1460, -- 奥术智慧
    },
    ['ROGUE'] = {},
    ['HUNTER'] = {},
    ['WARRIOR'] = {},
    ['WARLOCK'] = {},
    ['DEATHKNIGHT'] = {},
}

-- Initialize default clicksets for player class
function UNITFRAME:InitDefaultClickSets()
    if not _G.ANDROMEDA_ADB['ClickSets'] then
        _G.ANDROMEDA_ADB['ClickSets'] = {}
    end

    if not _G.ANDROMEDA_ADB['ClickSets'][C.MY_CLASS] then
        _G.ANDROMEDA_ADB['ClickSets'][C.MY_CLASS] = {}
    end

    if not next(_G.ANDROMEDA_ADB['ClickSets'][C.MY_CLASS]) then
        for fullkey, spellID in pairs(C.ClickCastList[C.MY_CLASS]) do
            _G.ANDROMEDA_ADB['ClickSets'][C.MY_CLASS][fullkey] = spellID
        end
    end
end

-- Setup mouse wheel cast bindings
local onEnterString = 'self:ClearBindings();'
local onLeaveString = onEnterString
for keyIndex, keyString in pairs(wheelGroupIndex) do
    onEnterString = format('%sself:SetBindingClick(0, "%s", self:GetName(), "Button%d");', onEnterString, keyString, keyIndex)
end
local onMouseString = 'if not self:IsUnderMouse(false) then self:ClearBindings(); end'

local function setupMouseWheelCast(self)
    local found = false
    for fullkey in pairs(_G.ANDROMEDA_ADB['ClickSets'][C.MY_CLASS]) do
        if fullkey:match('MW%w') then
            found = true
            break
        end
    end

    if found then
        self:SetAttribute('clickcast_onenter', onEnterString)
        self:SetAttribute('clickcast_onleave', onLeaveString)
        self:SetAttribute('_onshow', onLeaveString)
        self:SetAttribute('_onhide', onLeaveString)
        self:SetAttribute('_onmousedown', onMouseString)
    end
end

local function setupClickSets(self)
    if self.clickCastRegistered then
        return
    end

    for fullkey, value in pairs(_G.ANDROMEDA_ADB['ClickSets'][C.MY_CLASS]) do
        if fullkey == 'SHIFT-LMB' then
            self.focuser = true
        end

        local keyIndex = keyList[fullkey]
        if keyIndex then
            if tonumber(value) then
                self:SetAttribute(format(keyIndex, 'type'), 'spell')
                self:SetAttribute(format(keyIndex, 'spell'), value)
            elseif value == 'target' then
                self:SetAttribute(format(keyIndex, 'type'), 'target')
            elseif value == 'focus' then
                self:SetAttribute(format(keyIndex, 'type'), 'focus')
            elseif value == 'follow' then
                self:SetAttribute(format(keyIndex, 'type'), 'macro')
                self:SetAttribute(format(keyIndex, 'macrotext'), '/follow mouseover')
            elseif value:match('/') then
                self:SetAttribute(format(keyIndex, 'type'), 'macro')
                value = value:gsub('~', '\n')
                self:SetAttribute(format(keyIndex, 'macrotext'), value)
            end
        end
    end

    setupMouseWheelCast(self)

    self.clickCastRegistered = true
end

local pendingFrames = {}
function UNITFRAME:CreateClickSets(self)
    if not C.DB.Unitframe.ClickCast then
        return
    end

    if InCombatLockdown() then
        pendingFrames[self] = true
    else
        setupClickSets(self)
        pendingFrames[self] = nil
    end
end

function UNITFRAME:DelayClickSets()
    if not next(pendingFrames) then
        return
    end

    for frame in next, pendingFrames do
        UNITFRAME:CreateClickSets(frame)
    end
end

function UNITFRAME:AddClickSetsListener()
    if not C.DB.Unitframe.ClickCast then
        return
    end

    F:RegisterEvent('PLAYER_REGEN_ENABLED', UNITFRAME.DelayClickSets)
end

-- Update click sets for all frames
function UNITFRAME:UpdateAllClickSets()
    if not C.DB.Unitframe.ClickCast then
        return
    end

    for _, frame in pairs(F.Libs.oUF.objects) do
        if frame.unitStyle == 'party' or frame.unitStyle == 'raid' then
            if not InCombatLockdown() then
                frame.clickCastRegistered = false
                UNITFRAME:CreateClickSets(frame)
            else
                pendingFrames[frame] = true
            end
        end
    end
end