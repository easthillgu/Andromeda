local F, C, L = unpack(select(2, ...))

-- Character Stats Panel Module
-- 角色属性面板增强，显示平均物品等级和自定义属性分类

local cr, cg, cb = C.r or 1, C.g or 1, C.b or 1

-- 修复 Blizz 某些语言版本的本地化问题
local function FixBlizzLocale()
    CR_DODGE_TOOLTIP = gsub(CR_DODGE_TOOLTIP, '。2', '.2')
    CR_PARRY_TOOLTIP = gsub(CR_PARRY_TOOLTIP, '。2', '.2')
    CR_BLOCK_TOOLTIP = gsub(CR_BLOCK_TOOLTIP, '。2', '.2')
    RESILIENCE_TOOLTIP = gsub(RESILIENCE_TOOLTIP, '。2', '.2')
    DEFAULT_STATDEFENSE_TOOLTIP = gsub(DEFAULT_STATDEFENSE_TOOLTIP, '。2', '.2')
end

local orderList = {}
local categoryFrames = {}
local framesToSort = {}

local function SetCharacterStats(statsTable, category)
    if category == 'PLAYERSTAT_BASE_STATS' then
        PaperDollFrame_SetStat(statsTable[1], 1)
        PaperDollFrame_SetStat(statsTable[2], 2)
        PaperDollFrame_SetStat(statsTable[3], 3)
        PaperDollFrame_SetStat(statsTable[4], 4)
        PaperDollFrame_SetStat(statsTable[5], 5)
        PaperDollFrame_SetArmor(statsTable[6])
    elseif category == 'PLAYERSTAT_DEFENSES' then
        PaperDollFrame_SetArmor(statsTable[1])
        PaperDollFrame_SetDefense(statsTable[2])
        PaperDollFrame_SetDodge(statsTable[3])
        PaperDollFrame_SetParry(statsTable[4])
        PaperDollFrame_SetBlock(statsTable[5])
        PaperDollFrame_SetResilience(statsTable[6])
    elseif category == 'PLAYERSTAT_MELEE_COMBAT' then
        PaperDollFrame_SetDamage(statsTable[1])
        statsTable[1]:SetScript('OnEnter', CharacterDamageFrame_OnEnter)
        PaperDollFrame_SetAttackSpeed(statsTable[2])
        PaperDollFrame_SetAttackPower(statsTable[3])
        PaperDollFrame_SetRating(statsTable[4], CR_HIT_MELEE)
        PaperDollFrame_SetMeleeCritChance(statsTable[5])
        PaperDollFrame_SetExpertise(statsTable[6])
    elseif category == 'PLAYERSTAT_SPELL_COMBAT' then
        PaperDollFrame_SetSpellBonusDamage(statsTable[1])
        statsTable[1]:SetScript('OnEnter', CharacterSpellBonusDamage_OnEnter)
        PaperDollFrame_SetSpellBonusHealing(statsTable[2])
        PaperDollFrame_SetRating(statsTable[3], CR_HIT_SPELL)
        PaperDollFrame_SetSpellCritChance(statsTable[4])
        statsTable[4]:SetScript('OnEnter', CharacterSpellCritChance_OnEnter)
        PaperDollFrame_SetSpellHaste(statsTable[5])
        PaperDollFrame_SetManaRegen(statsTable[6])
    elseif category == 'PLAYERSTAT_RANGED_COMBAT' then
        PaperDollFrame_SetRangedDamage(statsTable[1])
        statsTable[1]:SetScript('OnEnter', CharacterRangedDamageFrame_OnEnter)
        PaperDollFrame_SetRangedAttackSpeed(statsTable[2])
        PaperDollFrame_SetRangedAttackPower(statsTable[3])
        PaperDollFrame_SetRating(statsTable[4], CR_HIT_RANGED)
        PaperDollFrame_SetRangedCritChance(statsTable[5])
    end
end

local function BuildListFromValue()
    wipe(orderList)

    local statOrder = C.DB.Misc and C.DB.Misc.StatOrder or '12345'
    for number in gmatch(statOrder, '%d') do
        tinsert(orderList, tonumber(number))
    end
end

local function UpdateCategoriesOrder()
    wipe(framesToSort)

    for _, index in ipairs(orderList) do
        tinsert(framesToSort, categoryFrames[index])
    end
end

local function UpdateCategoriesAnchor()
    UpdateCategoriesOrder()

    local prev
    for _, frame in pairs(framesToSort) do
        if not prev then
            frame:SetPoint('TOP', 0, -70)
        else
            frame:SetPoint('TOP', prev, 'BOTTOM')
        end
        prev = frame
    end
end

local function BuildValueFromList()
    local str = ''
    for _, index in ipairs(orderList) do
        str = str .. tostring(index)
    end

    if C.DB.Misc then
        C.DB.Misc.StatOrder = str
    end

    UpdateCategoriesAnchor()
end

local function Arrow_GoUp(bu)
    local frameIndex = bu.__owner.index

    BuildListFromValue()

    for order, index in pairs(orderList) do
        if index == frameIndex then
            if order > 1 then
                local oldIndex = orderList[order - 1]
                orderList[order - 1] = frameIndex
                orderList[order] = oldIndex

                BuildValueFromList()
            end
            break
        end
    end
end

local function Arrow_GoDown(bu)
    local frameIndex = bu.__owner.index

    BuildListFromValue()

    for order, index in pairs(orderList) do
        if index == frameIndex then
            if order < 5 then
                local oldIndex = orderList[order + 1]
                orderList[order + 1] = frameIndex
                orderList[order] = oldIndex

                BuildValueFromList()
            end
            break
        end
    end
end

local function CreateStatRow(parent, index)
    local frame = CreateFrame('Frame', '$parentRow' .. index, parent, 'StatFrameTemplate')
    frame:SetWidth(180)
    frame:SetPoint('TOP', parent.header, 'BOTTOM', 0, -2 - (index - 1) * 16)
    local background = frame:CreateTexture(nil, 'BACKGROUND')
    background:SetAtlas('UI-Character-Info-Line-Bounce', true)
    background:SetAlpha(0.3)
    background:SetPoint('CENTER')
    background:SetShown(index % 2 == 0)
    frame.background = background

    return frame
end

local function CreateHeaderArrow(parent, direct, func)
    local onLeft = direct == 'LEFT'
    local xOffset = onLeft and 10 or -10
    local arrowDirec = onLeft and 'up' or 'down'

    local bu = CreateFrame('Button', nil, parent)
    bu:SetPoint(direct, parent.header, xOffset, 0)
    bu:SetSize(18, 18)
    F.ReskinArrow(bu, arrowDirec)
    bu.__owner = parent
    bu:SetScript('OnClick', func)
end

local PlayerILvl

local function CreatePlayerILvl(parent, category)
    local frame = CreateFrame('Frame', 'AndromedaStatCategoryIlvl', parent)
    frame:SetWidth(200)
    frame:SetHeight(42 + 16)
    frame:SetPoint('TOP')

    local header = CreateFrame('Frame', '$parentHeader', frame, 'CharacterStatFrameCategoryTemplate')
    header:SetPoint('TOP', 0, 10)
    header.Background:Hide()
    header.Title:SetText(category)
    header.Title:SetTextColor(cr, cg, cb)
    frame.header = header

    local line = frame:CreateTexture(nil, 'ARTWORK')
    line:SetSize(180, C.MULT)
    line:SetPoint('BOTTOM', header, 0, 5)
    line:SetColorTexture(1, 1, 1, 0.25)

    local iLvlFrame = CreateStatRow(frame, 1)
    iLvlFrame:SetHeight(30)
    iLvlFrame.background:Show()
    iLvlFrame.background:SetAtlas('UI-Character-Info-ItemLevel-Bounce', true)

    PlayerILvl = iLvlFrame:CreateFontString(nil, 'OVERLAY')
    PlayerILvl:SetFont(C.Assets.Fonts.Regular, 20, 'OUTLINE')
    PlayerILvl:SetPoint('CENTER')
end

local function GetItemSlotLevel(unit, index)
    local level
    local itemLink = GetInventoryItemLink(unit, index)
    if itemLink then
        level = select(4, GetItemInfo(itemLink))
    end
    return tonumber(level) or 0
end

-- 物品等级颜色
local function GetILvlTextColor(level)
    if level >= 272 then
        return 1, 0.5, 0
    elseif level >= 259 then
        return 0.63, 0.2, 0.93
    elseif level >= 246 then
        return 0, 0.43, 0.87
    elseif level >= 226 then
        return 0.12, 1, 0
    else
        return 1, 1, 1
    end
end

local function UpdateUnitILvl(unit, text)
    if not text then
        return
    end

    local total, level = 0
    for index = 1, 15 do
        if index ~= 4 then
            level = GetItemSlotLevel(unit, index)
            if level > 0 then
                total = total + level
            end
        end
    end

    local mainhand = GetItemSlotLevel(unit, 16)
    local offhand = GetItemSlotLevel(unit, 17)
    local ranged = GetItemSlotLevel(unit, 18)

    if mainhand > 0 and offhand > 0 then
        total = total + mainhand + offhand
    elseif mainhand > 0 and ranged > 0 then
        total = total + mainhand + ranged
    elseif offhand > 0 and ranged > 0 then
        total = total + offhand + ranged
    else
        total = total + max(mainhand, offhand, ranged) * 2
    end

    local average = F:Round(total / 16, 1)
    text:SetText(average)
    local r, g, b = GetILvlTextColor(average)
    text:SetTextColor(r, g, b)
end

local function UpdatePlayerILvl()
    UpdateUnitILvl('player', PlayerILvl)
end

local StatPanel2

local function CreateStatHeader(parent, index, category)
    local maxLines = index == 5 and 5 or 6
    local frame = CreateFrame('Frame', 'AndromedaStatCategory' .. index, parent)
    frame:SetWidth(200)
    frame:SetHeight(42 + maxLines * 16)
    frame.index = index
    tinsert(categoryFrames, frame)

    local header = CreateFrame('Frame', '$parentHeader', frame, 'CharacterStatFrameCategoryTemplate')
    header:SetPoint('TOP')
    header.Background:Hide()
    header.Title:SetText(_G[category])
    header.Title:SetTextColor(cr, cg, cb)
    frame.header = header

    CreateHeaderArrow(frame, 'LEFT', Arrow_GoUp)
    CreateHeaderArrow(frame, 'RIGHT', Arrow_GoDown)

    local line = frame:CreateTexture(nil, 'ARTWORK')
    line:SetSize(180, C.MULT)
    line:SetPoint('BOTTOM', header, 0, 5)
    line:SetColorTexture(1, 1, 1, 0.25)

    local statsTable = {}
    for i = 1, maxLines do
        statsTable[i] = CreateStatRow(frame, i)
    end
    SetCharacterStats(statsTable, category)
    frame.category = category
    frame.statsTable = statsTable

    return frame
end

local function ToggleMagicRes()
    if C.DB.Misc and C.DB.Misc.StatExpand then
        CharacterResistanceFrame:ClearAllPoints()
        CharacterResistanceFrame:SetPoint('TOPLEFT', StatPanel2, 28, -10)
        CharacterResistanceFrame:SetParent(StatPanel2)

        for i = 1, 5 do
            local bu = _G['MagicResFrame' .. i]
            if i > 1 then
                bu:ClearAllPoints()
                bu:SetPoint('LEFT', _G['MagicResFrame' .. (i - 1)], 'RIGHT', 3, 0)
            end
        end
    else
        CharacterResistanceFrame:ClearAllPoints()
        CharacterResistanceFrame:SetPoint('TOPRIGHT', PaperDollFrame, 'TOPLEFT', 297, -77)
        CharacterResistanceFrame:SetParent(PaperDollFrame)

        for i = 1, 5 do
            local bu = _G['MagicResFrame' .. i]
            if i > 1 then
                bu:ClearAllPoints()
                bu:SetPoint('TOP', _G['MagicResFrame' .. (i - 1)], 'BOTTOM', 0, -3)
            end
        end
    end
end

local function UpdateStats()
    if not (StatPanel2 and StatPanel2:IsShown()) then
        return
    end

    for _, frame in pairs(categoryFrames) do
        if frame.statsTable and frame.category then
            SetCharacterStats(frame.statsTable, frame.category)
        end
    end
end

local function ForceUpdateStats()
    -- 强制更新所有数据
    if PlayerILvl then
        UpdatePlayerILvl()
    end
    UpdateStats()
end

local function ToggleStatPanel(texture)
    if C.DB.Misc and C.DB.Misc.StatExpand then
        texture:SetupArrow('left')
        CharacterAttributesFrame:Hide()
        StatPanel2:Show()
    else
        texture:SetupArrow('right')
        CharacterAttributesFrame:Show()
        StatPanel2:Hide()
    end
    ToggleMagicRes()
end

local function CreateStatPanel()
    -- 修复本地化问题
    FixBlizzLocale()

    local statPanel = CreateFrame('Frame', 'AndromedaStatPanel', PaperDollFrame)
    statPanel:SetSize(200, 422)
    statPanel:SetPoint('TOPLEFT', PaperDollFrame, 'TOPRIGHT', -32, -15 - C.MULT)
    F.SetBD(statPanel)
    StatPanel2 = statPanel

    -- 添加 EditMode 所需的更新方法，避免报错
    statPanel.UpdateHeight = function() end
    statPanel.UpdateWidth = function() end
    statPanel.UpdateSize = function() end

    local scrollFrame = CreateFrame('ScrollFrame', nil, statPanel, 'UIPanelScrollFrameTemplate')
    scrollFrame:SetPoint('TOPLEFT', 0, -45)
    scrollFrame:SetPoint('BOTTOMRIGHT', 0, 2)
    scrollFrame.ScrollBar:Hide()
    scrollFrame.ScrollBar.Show = F.Dummy
    local stat = CreateFrame('Frame', nil, scrollFrame)
    stat:SetSize(200, 1)
    statPanel.child = stat
    scrollFrame:SetScrollChild(stat)
    scrollFrame:SetScript('OnMouseWheel', function(self, delta)
        local scrollBar = self.ScrollBar
        local step = delta * 25
        if IsShiftKeyDown() then
            step = step * 6
        end
        scrollBar:SetValue(scrollBar:GetValue() - step)
    end)

    -- 玩家物品等级
    CreatePlayerILvl(stat, STAT_AVERAGE_ITEM_LEVEL)
    hooksecurefunc('PaperDollFrame_UpdateStats', UpdatePlayerILvl)

    -- 玩家属性分类
    local categories = {
        'PLAYERSTAT_BASE_STATS',
        'PLAYERSTAT_DEFENSES',
        'PLAYERSTAT_MELEE_COMBAT',
        'PLAYERSTAT_SPELL_COMBAT',
        'PLAYERSTAT_RANGED_COMBAT',
    }
    for index, category in pairs(categories) do
        CreateStatHeader(stat, index, category)
    end

    -- 初始化
    BuildListFromValue()
    BuildValueFromList()

    -- 延迟更新数据，确保物品信息已加载
    C_Timer.After(0.1, ForceUpdateStats)
    C_Timer.After(0.5, ForceUpdateStats)
    C_Timer.After(1.0, ForceUpdateStats)
    CharacterNameFrame:ClearAllPoints()
    CharacterNameFrame:SetPoint('TOPLEFT', CharacterFrame, 130, -20)
    PaperDollFrame.__statPanels = {}

    -- 更新数据
    hooksecurefunc('ToggleCharacter', UpdateStats)
    PaperDollFrame:HookScript('OnEvent', UpdateStats)
    PaperDollFrame:RegisterEvent('UNIT_STATS')
    PaperDollFrame:RegisterEvent('UNIT_ATTACK_POWER')
    PaperDollFrame:RegisterEvent('UNIT_RANGED_ATTACK_POWER')
    PaperDollFrame:RegisterEvent('UNIT_SPELL_HASTE')
    PaperDollFrame:RegisterEvent('UNIT_INVENTORY_CHANGED')
    PaperDollFrame:RegisterEvent('BAG_UPDATE')

    -- 监听物品信息加载完成
    hooksecurefunc('GetItemInfo', function()
        if StatPanel2 and StatPanel2:IsShown() then
            UpdatePlayerILvl()
        end
    end)

    -- 展开/收起按钮
    local bu = CreateFrame('Button', nil, PaperDollFrame)
    bu:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT', -3, 0)
    F.ReskinArrow(bu, 'right')

    bu:SetScript('OnClick', function(self)
        if not C.DB.Misc then
            C.DB.Misc = {}
        end
        C.DB.Misc.StatExpand = not C.DB.Misc.StatExpand
        ToggleStatPanel(self.__texture)
    end)

    ToggleStatPanel(bu.__texture)

    PaperDollFrame:HookScript('OnShow', function()
        UpdatePlayerILvl()
        UpdateStats()
    end)
end

function F:InitCharacterStatPanel()
    -- 检查是否启用了属性面板展开
    if not C.DB.Misc or not C.DB.Misc.StatExpand then
        return
    end

    CreateStatPanel()

    -- 确保面板可见
    if StatPanel2 then
        StatPanel2:Show()
        CharacterAttributesFrame:Hide()
    end
end
