local F, C = unpack(select(2, ...))
local oUF = F.Libs.oUF

-- Colors
local function classColor(class, showRGB)
    local color = C.ClassColors[C.ClassList[class] or class]
    if not color then
        color = C.ClassColors['PRIEST']
    end

    if showRGB then
        return color.r, color.g, color.b
    else
        return '|c' .. color.colorStr
    end
end

local function diffColor(level)
    return F:RgbToHex(GetQuestDifficultyColor(level))
end

local rankColor = { 1, 0, 0, 1, 1, 0, 0, 1, 0 }

local repColor = { 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1 }

local function smoothColor(cur, max, color)
    local r, g, b = oUF:RGBColorGradient(cur, max, unpack(color))
    return F:RgbToHex(r, g, b)
end

-- Guild (3.80.1: use classic GuildStatus_Update + GuildFrameButton, ref iColor)
local function classColorRGB(class)
    local color = C.ClassColors[C.ClassList[class] or class]
    if not color then color = C.ClassColors['PRIEST'] end
    return color.r, color.g, color.b
end

hooksecurefunc('GuildStatus_Update', function()
    local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame)
    local myZone = GetRealZoneText()

    for i = 1, GUILDMEMBERS_TO_DISPLAY do
        local name, _, rankIndex, level, _, zone, _, class, online = GetGuildRosterInfo(guildOffset + i)
        if not name then break end

        local dimmed = not online
        local r, g, b = classColorRGB(class)

        local nameText = _G['GuildFrameButton' .. i .. 'Name']
        local zoneText = _G['GuildFrameButton' .. i .. 'Zone']
        local levelText = _G['GuildFrameButton' .. i .. 'Level']
        local classText = _G['GuildFrameButton' .. i .. 'Class']

        local factor = dimmed and 0.5 or 1
        if nameText then nameText:SetTextColor(r * factor, g * factor, b * factor) end
        if classText then classText:SetTextColor(r * factor, g * factor, b * factor) end
        if zoneText then
            if zone == myZone then
                zoneText:SetTextColor(0, 1, 0)
            else
                zoneText:SetTextColor(1 * factor, 1 * factor, 1 * factor)
            end
        end
        if levelText then
            local lc = GetQuestDifficultyColor(level)
            levelText:SetTextColor(lc.r * factor, lc.g * factor, lc.b * factor)
        end
    end
end)

-- Friends (3.80.1: use FriendsFrame_UpdateFriends + buttons array, ref iColor)
local function updateFriends()
    local buttons = FriendsFrameFriendsScrollFrame.buttons
    local myZone = GetRealZoneText()

    for i = 1, #buttons do
        local button = buttons[i]
        if button:IsShown() then
            if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
                local info = C_FriendList.GetFriendInfoByIndex(button.id)
                if info and info.connected then
                    local classToken = (LOCALIZED_CLASS_NAMES_MALE[info.className] and info.className) or
                                       C.ClassList[info.className] or info.className
                    local r, g, b = classColorRGB(classToken)
                    if button.name then button.name:SetTextColor(r, g, b) end
                    if info.area and info.area == myZone and button.info then
                        button.info:SetTextColor(0, 1, 0)
                    end
                end
            end
        end
    end
end
hooksecurefunc(FriendsFrameFriendsScrollFrame, 'update', updateFriends)
hooksecurefunc('FriendsFrame_UpdateFriends', updateFriends)

-- WhoFrame (3.80.1: use WhoList_Update, ref iColor)
hooksecurefunc('WhoList_Update', function()
    local whoOffset = FauxScrollFrame_GetOffset(WhoListScrollFrame)
    local myZone = GetRealZoneText()
    local myGuild = GetGuildInfo('player')

    for i = 1, WHOS_TO_DISPLAY do
        local info = C_FriendList.GetWhoInfo(whoOffset + i)
        if not info then break end

        local nameText = _G['WhoFrameButton' .. i .. 'Name']
        local levelText = _G['WhoFrameButton' .. i .. 'Level']
        local variableText = _G['WhoFrameButton' .. i .. 'Variable']

        if nameText and info.filename then
            local r, g, b = classColorRGB(info.filename)
            nameText:SetTextColor(r, g, b)
        end
        if levelText then
            local lc = GetQuestDifficultyColor(info.level)
            levelText:SetTextColor(lc.r, lc.g, lc.b)
        end
        if variableText then
            local val = variableText:GetText()
            if val == info.area and val == myZone then
                variableText:SetTextColor(0, 1, 0)
            elseif val == info.fullGuildName and val == myGuild then
                variableText:SetTextColor(0, 1, 0)
            end
        end
    end
end)

--
local blizzHexColors = {}
for class, color in pairs(_G.RAID_CLASS_COLORS) do
    blizzHexColors[color.colorStr] = class
end

-- FrameXML/ChatFrame.lua
do
    local AddMessage = {}

    local function FixClassColors(frame, message, ...)
        if type(message) == 'string' and strfind(message, '|cff') then
            for hex, class in pairs(blizzHexColors) do
                local color = C.ClassColors[class]
                if color then
                    color = F:RgbToHex(color.r, color.g, color.b, 'ff')
                    message = gsub(message, hex, color)
                end
            end
        end
        return AddMessage[frame](frame, message, ...)
    end

    for i = 1, _G.NUM_CHAT_WINDOWS do
        local frame = _G['ChatFrame' .. i]
        AddMessage[frame] = frame.AddMessage
        frame.AddMessage = FixClassColors
    end
end

-- FrameXML/LevelUpDisplay.lua
if _G.BossBanner_ConfigureLootFrame then
    hooksecurefunc('BossBanner_ConfigureLootFrame', function(lootFrame, data)
    local color = C.ClassColors[data.className]
    lootFrame.PlayerName:SetTextColor(color.r, color.g, color.b)
end)
end

-- FrameXML/PaperDollFrame.lua
local primaryTalentTree, specName
hooksecurefunc('PaperDollFrame_SetLevel', function()
    local className, class = UnitClass('player')
    local color = C.ClassColors[class]
    color = F:RgbToHex(color.r, color.g, color.b, 'ff')

    primaryTalentTree, specName = GetSpecialization and GetSpecialization() or GetActiveSpecGroup and GetActiveSpecGroup()
    if primaryTalentTree then
        primaryTalentTree, specName = GetSpecializationInfo(primaryTalentTree)
    end

    local level = UnitLevel('player')
    local effectiveLevel = UnitEffectiveLevel('player')
    if effectiveLevel ~= level then
        level = _G.EFFECTIVE_LEVEL_FORMAT:format(effectiveLevel, level)
    end

    if specName and specName ~= '' then
        _G.CharacterLevelText:SetFormattedText(_G.PLAYER_LEVEL, level, color, specName, className)
    else
        _G.CharacterLevelText:SetFormattedText(_G.PLAYER_LEVEL_NO_SPEC, level, color, className)
    end
end)

-- FrameXML/RaidWarning.lua
do
    local AddMessage = _G.RaidNotice_AddMessage
    _G.RaidNotice_AddMessage = function(frame, message, ...)
        if strfind(message, '|cff') then
            for hex, class in pairs(blizzHexColors) do
                local color = C.ClassColors[class]
                message = gsub(message, hex, color.colorStr)
            end
        end
        return AddMessage(frame, message, ...)
    end
end
