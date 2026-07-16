local F, C, L = unpack(select(2, ...))

-- iColor Module
-- 为聊天列表着色：公会、好友、查询、战场计分板

local myName = UnitName('player')
local myRace = UnitRace('player')
local normal = NORMAL_FONT_COLOR
local green = GREEN_FONT_COLOR
local white = HIGHLIGHT_FONT_COLOR
local defColor = FRIENDS_WOW_NAME_COLOR_CODE

local BC = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
    BC[v] = k
end
for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
    BC[v] = k
end

local function getClassToken(class)
    return class and (RAID_CLASS_COLORS[class] and class or BC[class]) or nil
end

local function colorString(value, class)
    local color = class and RAID_CLASS_COLORS[class]
    local level = not color and tonumber(value)
    return ('%s%s|r'):format(ConvertRGBtoColorString(color or level and GetQuestDifficultyColor(level) or normal), tostring(value or ''))
end

local function setTextColor(text, color, dimmed)
    local factor = dimmed and 0.5 or 1
    text:SetTextColor(color.r * factor, color.g * factor, color.b * factor)
end

local function getHighlightColor(value, current)
    return value == current and green or white
end

local function getWhoVariableColor(info, value, myZone, myGuild)
    return value == info.area and getHighlightColor(info.area, myZone)
        or value == info.fullGuildName and getHighlightColor(info.fullGuildName, myGuild)
        or value == info.raceStr and getHighlightColor(info.raceStr, myRace)
        or white
end

local function getScoreRealmColor(isArena, faction)
    return isArena and (faction == 0 and '|cff20ff20' or '|cffffd200') or (faction == 0 and '|cffff2020' or '|cff00aef0')
end

local function guildRankColor(index)
    local pct = index / GuildControlGetNumRanks()
    return pct >= 0.5 and (1 - pct) * 2 or 1, pct >= 0.5 and 1 or pct * 2, 0
end

function F:InitIColor()
    -- Guild 成员列表着色
    hooksecurefunc('GuildStatus_Update', function()
        local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame)
        local myZone = GetRealZoneText()

        for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
            local name, _, rankIndex, level, _, zone, _, _, online, _, classFileName = GetGuildRosterInfo(guildOffset + i)
            if not name then
                break
            end

            local dimmed = not online
            local color = RAID_CLASS_COLORS[classFileName] or normal
            local zoneColor = getHighlightColor(zone, myZone)
            local levelColor = GetQuestDifficultyColor(level) or white
            local r, g, b = guildRankColor(rankIndex)
            local buttonName = 'GuildFrameButton' .. i
            local statusButton = 'GuildFrameGuildStatusButton' .. i

            setTextColor(_G[buttonName .. 'Name'], color, dimmed)
            setTextColor(_G[buttonName .. 'Zone'], zoneColor, dimmed)
            setTextColor(_G[buttonName .. 'Level'], levelColor, dimmed)
            setTextColor(_G[buttonName .. 'Class'], color, dimmed)
            setTextColor(_G[statusButton .. 'Name'], color, dimmed)
            setTextColor(_G[statusButton .. 'Rank'], { r = r, g = g, b = b }, dimmed)
        end
    end)

    -- Friends 列表着色
    local function updateFriends()
        local buttons = FriendsFrameFriendsScrollFrame.buttons
        local myZone = GetRealZoneText()

        for i = 1, #buttons do
            local nameText, infoText
            local button = buttons[i]
            if button:IsShown() then
                if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
                    local info = C_FriendList.GetFriendInfoByIndex(button.id)
                    if info and info.connected then
                        local classToken = getClassToken(info.className)
                        local name = colorString(info.name, classToken)
                        local level = colorString(info.level)
                        local class = colorString(info.className, classToken)
                        nameText = name .. ', Lv' .. level .. '  ' .. class
                        if info.area and info.area == myZone then
                            infoText = format('|cff00ff00%s|r', info.area)
                        end
                    end
                elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
                    local _, presenceName, _, _, _, toonID, client, isOnline = BNGetFriendInfo(button.id)
                    if isOnline and client == BNET_CLIENT_WOW then
                        local _, toonName, _, _, _, _, _, class, _, zoneName, level = BNGetGameAccountInfo(toonID)
                        if presenceName and toonName then
                            local classToken = getClassToken(class)
                            level = colorString(level)
                            toonName = colorString(toonName, classToken)
                            nameText = presenceName .. ' ' .. defColor .. '(Lv' .. level .. ' ' .. toonName .. defColor .. ')'
                        end
                        if zoneName and zoneName == myZone then
                            infoText = format('|cff00ff00%s|r', zoneName)
                        end
                    end
                end
            end
            if nameText then
                button.name:SetText(nameText)
            end
            if infoText then
                button.info:SetText(infoText)
            end
        end
    end

    hooksecurefunc(FriendsFrameFriendsScrollFrame, 'update', updateFriends)
    hooksecurefunc('FriendsFrame_UpdateFriends', updateFriends)

    -- Who 列表着色
    hooksecurefunc('WhoList_Update', function()
        local whoOffset = FauxScrollFrame_GetOffset(WhoListScrollFrame)
        local myZone = GetRealZoneText()
        local myGuild = GetGuildInfo('player')
        for i = 1, WHOS_TO_DISPLAY do
            local info = C_FriendList.GetWhoInfo(whoOffset + i)
            if not info then
                break
            end
            local nameText = _G['WhoFrameButton' .. i .. 'Name']
            local levelText = _G['WhoFrameButton' .. i .. 'Level']
            local variableText = _G['WhoFrameButton' .. i .. 'Variable']
            local nameColor = info.filename and RAID_CLASS_COLORS[info.filename] or normal
            if nameText then
                setTextColor(nameText, nameColor)
            end
            local levelColor = info.level and GetQuestDifficultyColor(info.level) or white
            if levelText then
                setTextColor(levelText, levelColor)
                levelText:SetFont(levelText:GetFont(), 13)
            end
            if variableText then
                setTextColor(variableText, getWhoVariableColor(info, variableText:GetText(), myZone, myGuild))
            end
        end
    end)

    -- 战场计分板着色
    hooksecurefunc('WorldStateScoreFrame_Update', function()
        local isArena = IsActiveBattlefieldArena()
        local scrollOffset = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame)

        for i = 1, MAX_WORLDSTATE_SCORE_BUTTONS do
            local scoreButton = _G['WorldStateScoreButton' .. i]
            local name, _, _, _, _, faction, _, _, classToken = GetBattlefieldScore(scrollOffset + i)
            if scoreButton and scoreButton.name and scoreButton.name.text and name and faction then
                local rawName, realmName = strsplit('-', name, 2)
                local n = colorString(rawName, getClassToken(classToken))
                if rawName == myName then
                    n = '> ' .. n .. ' <'
                end
                if realmName then
                    n = n .. '|cffffffff - |r' .. getScoreRealmColor(isArena, faction) .. realmName .. '|r'
                end
                scoreButton.name.text:SetText(n)
            end
        end
    end)
end