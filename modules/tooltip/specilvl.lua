local F, C, L = unpack(select(2, ...))
local TOOLTIP = F:GetModule('Tooltip')

local isPending = _G.LFG_LIST_LOADING
local specPrefix = C.INFO_COLOR .. _G.SPECIALIZATION .. ':|r '
local levelPrefix = C.INFO_COLOR .. _G.STAT_AVERAGE_ITEM_LEVEL .. ':|r '

-- Performance optimization constants (inspired by ATIP)
local CACHE_MAX_SIZE = 500      -- Maximum cache entries
local CACHE_TTL = 900           -- Cache time-to-live (15 minutes)
local THROTTLE_GLOBAL = 0.6     -- Global throttle to prevent disconnect
local THROTTLE_TARGET = 0.95    -- Same target cooldown
local POLL_INTERVAL = 0.10      -- Polling interval
local FAIL_COOLDOWN = 5         -- Failure cooldown penalty
local RETRY_COUNT = 22          -- Retry count per round
local MAX_RETRY_ROUND = 4       -- Maximum retry rounds
local TASK_TIMEOUT = 8.5        -- Task timeout limit

-- Cache with LRU eviction
local cache = {}
local cacheCount = 0

-- Weapon data
local weapon = {}

-- Current inspection state
local currentUNIT, currentGUID

-- Throttle state
local lastInspectTime = 0
local lastTargetTime = 0
local failCooldown = {}

-- Pending state
local pendingGUID = nil
local pendingTimer = nil
local retryRound = 0
local retryCount = 0
local taskStartTime = 0

TOOLTIP.tierSets = { -- t30
    -- HUNTER
    [200390] = true, [200392] = true, [200387] = true, [200389] = true, [200391] = true,
    -- WARRIOR
    [200426] = true, [200428] = true, [200423] = true, [200425] = true, [200427] = true,
    -- PALADIN
    [200417] = true, [200419] = true, [200414] = true, [200416] = true, [200418] = true,
    -- ROGUE
    [200372] = true, [200374] = true, [200369] = true, [200371] = true, [200373] = true,
    -- PRIEST
    [200327] = true, [200329] = true, [200324] = true, [200326] = true, [200328] = true,
    -- DK
    [200408] = true, [200410] = true, [200405] = true, [200407] = true, [200409] = true,
    -- SHAMAN
    [200399] = true, [200401] = true, [200396] = true, [200398] = true, [200400] = true,
    -- MAGE
    [200318] = true, [200320] = true, [200315] = true, [200317] = true, [200319] = true,
    -- WARLOCK
    [200336] = true, [200338] = true, [200333] = true, [200335] = true, [200337] = true,
    -- MONK
    [200363] = true, [200365] = true, [200360] = true, [200362] = true, [200364] = true,
    -- DRUID
    [200354] = true, [200356] = true, [200351] = true, [200353] = true, [200355] = true,
    -- DH
    [200345] = true, [200347] = true, [200342] = true, [200344] = true, [200346] = true,
    -- EVOKER
    [200381] = true, [200383] = true, [200378] = true, [200380] = true, [200382] = true,
}

local formatSets = {
    [1] = ' |cff14b200(1/4)',
    [2] = ' |cff0091f2(2/4)',
    [3] = ' |cff0091f2(3/4)',
    [4] = ' |cffc745f9(4/4)',
    [5] = ' |cffc745f9(5/5)',
}

-- LRU cache eviction
local function evictOldestCache()
    if cacheCount <= CACHE_MAX_SIZE then return end
    
    local oldestTime, oldestGUID
    for guid, data in pairs(cache) do
        local t = data.getTime or 0
        if not oldestTime or t < oldestTime then
            oldestTime = t
            oldestGUID = guid
        end
    end
    
    if oldestGUID then
        cache[oldestGUID] = nil
        failCooldown[oldestGUID] = nil
        cacheCount = cacheCount - 1
    end
end

local function addToCache(guid, data)
    if not cache[guid] then
        cacheCount = cacheCount + 1
        evictOldestCache()
    end
    data.getTime = GetTime()
    cache[guid] = data
end

-- Color cache for performance
local colorCache = {}
local function getUnitColorCached(unit)
    local guid = UnitGUID(unit)
    if guid and colorCache[guid] then
        local cached = colorCache[guid]
        if GetTime() - cached.time < 1 then
            return cached.r, cached.g, cached.b
        end
    end
    
    local r, g, b = F:UnitColor(unit)
    if guid then
        colorCache[guid] = { r = r, g = g, b = b, time = GetTime() }
    end
    return r, g, b
end

-- Check if we can inspect
local function canInspect(unit, guid)
    if not unit or not guid then return false end
    if not UnitIsPlayer(unit) then return false end
    if UnitCanAttack('player', unit) then return false end
    if not UnitIsVisible(unit) then return false end
    if not UnitIsInRange(unit) then return false end
    if not CanInspect(unit) then return false end
    if InCombatLockdown() then return false end
    if _G.InspectFrame and _G.InspectFrame:IsShown() then return false end
    if UnitIsDeadOrGhost('player') or UnitOnTaxi('player') then return false end
    
    -- Check fail cooldown
    local failTime = failCooldown[guid]
    if failTime and GetTime() - failTime < FAIL_COOLDOWN then return false end
    
    -- Check global throttle
    local now = GetTime()
    if now - lastInspectTime < THROTTLE_GLOBAL then return false end
    
    return true
end

-- Stop pending inspection
local function stopPending()
    if pendingTimer then
        pendingTimer:Cancel()
        pendingTimer = nil
    end
    pendingGUID = nil
    retryRound = 0
    retryCount = 0
    ClearInspectPlayer()
end

-- Setup spec and level display
function TOOLTIP:SetupSpecLevel(spec, level)
    local _, unit = _G.GameTooltip:GetUnit()
    if not unit or UnitGUID(unit) ~= currentGUID then
        return
    end

    local specLine, levelLine
    for i = 2, _G.GameTooltip:NumLines() do
        local line = _G['GameTooltipTextLeft' .. i]
        local text = line:GetText()
        if text and strfind(text, specPrefix) then
            specLine = line
        elseif text and strfind(text, levelPrefix) then
            levelLine = line
        end
    end

    local r, g, b = getUnitColorCached(unit)
    local hexColor = F:RgbToHex(r, g, b)

    spec = specPrefix .. (spec or isPending)
    if specLine then
        specLine:SetText(hexColor .. spec)
    else
        _G.GameTooltip:AddLine(hexColor .. spec)
    end

    level = levelPrefix .. (level or isPending)
    if levelLine then
        levelLine:SetText(level)
    else
        _G.GameTooltip:AddLine(level)
    end
    
    _G.GameTooltip:Show()
end

function TOOLTIP:GetUnitItemLevel(unit)
    if not unit or UnitGUID(unit) ~= currentGUID then
        return
    end

    local class = select(2, UnitClass(unit))
    local ilvl
    local boa, total, haveWeapon, twohand, sets = 0, 0, 0, 0, 0
    local delay, mainhand, offhand, hasArtifact
    weapon[1], weapon[2] = 0, 0

    for i = 1, 17 do
        if i ~= 4 then
            local itemTexture = GetInventoryItemTexture(unit, i)
            if itemTexture then
                local itemLink = GetInventoryItemLink(unit, i)
                if not itemLink then
                    delay = true
                else
                    local _, _, quality, level, _, _, _, _, slot = GetItemInfo(itemLink)
                    if not quality or not level then
                        delay = true
                    else
                        if quality == Enum.ItemQuality.Heirloom then
                            boa = boa + 1
                        end

                        local itemID = GetItemInfoFromHyperlink(itemLink)
                        if TOOLTIP.tierSets[itemID] then
                            sets = sets + 1
                        end

                        if unit ~= 'player' then
                            level = F.GetItemLevel(itemLink) or level
                            if i < 16 then
                                total = total + level
                            elseif i > 15 and quality == Enum.ItemQuality.Artifact then
                                local relics = { select(4, strsplit(':', itemLink)) }
                                for j = 1, 3 do
                                    local relicID = relics[j] ~= '' and relics[j]
                                    local relicLink = select(2, GetItemGem(itemLink, j))
                                    if relicID and not relicLink then
                                        delay = true
                                        break
                                    end
                                end
                            end

                            if i == 16 then
                                if quality == Enum.ItemQuality.Artifact then
                                    hasArtifact = true
                                end
                                weapon[1] = level
                                haveWeapon = haveWeapon + 1
                                if slot == 'INVTYPE_2HWEAPON' or slot == 'INVTYPE_RANGED' or (slot == 'INVTYPE_RANGEDRIGHT' and class == 'HUNTER') then
                                    mainhand = true
                                    twohand = twohand + 1
                                end
                            elseif i == 17 then
                                weapon[2] = level
                                haveWeapon = haveWeapon + 1
                                if slot == 'INVTYPE_2HWEAPON' then
                                    offhand = true
                                    twohand = twohand + 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if not delay then
        if unit == 'player' then
            ilvl = select(2, GetAverageItemLevel())
        else
            if hasArtifact or twohand == 2 then
                local higher = max(weapon[1], weapon[2])
                total = total + higher * 2
            elseif twohand == 1 and haveWeapon == 1 then
                total = total + weapon[1] * 2 + weapon[2] * 2
            elseif twohand == 1 and haveWeapon == 2 then
                if mainhand and weapon[1] >= weapon[2] then
                    total = total + weapon[1] * 2
                elseif offhand and weapon[2] >= weapon[1] then
                    total = total + weapon[2] * 2
                else
                    total = total + weapon[1] + weapon[2]
                end
            else
                total = total + weapon[1] + weapon[2]
            end
            ilvl = total / 16
        end

        if ilvl > 0 then
            ilvl = format('%.1f', ilvl)
        end
        if boa > 0 then
            ilvl = ilvl .. ' |cff00ccff(' .. boa .. _G.HEIRLOOMS .. ')'
        end
        if sets > 0 then
            ilvl = ilvl .. formatSets[sets]
        end
    else
        ilvl = nil
    end

    return ilvl
end

function TOOLTIP:GetUnitSpec(unit)
    if not unit or UnitGUID(unit) ~= currentGUID then
        return
    end

    local specName
    if unit == 'player' then
        local specIndex = GetSpecialization()
        if specIndex then
            specName = select(2, GetSpecializationInfo(specIndex))
        end
    else
        local specID = GetInspectSpecialization(unit)
        if specID and specID > 0 then
            specName = select(2, GetSpecializationInfoByID(specID))
        end
    end

    if specName == '' then
        specName = _G.NONE
    end

    return specName
end

-- Try to build inspection data
local function tryBuildData(unit, guid, isForce)
    local spec = TOOLTIP:GetUnitSpec(unit)
    local level = TOOLTIP:GetUnitItemLevel(unit)
    
    local data = cache[guid] or {}
    data.spec = spec
    data.level = level
    
    if spec and level then
        addToCache(guid, data)
        TOOLTIP:SetupSpecLevel(spec, level)
        return true
    end
    
    if isForce then
        TOOLTIP:SetupSpecLevel(nil, nil)
        return false
    end
    
    return false
end

-- Inspection tick using C_Timer
local function inspectionTick()
    if pendingGUID ~= currentGUID then
        stopPending()
        return
    end
    
    if not canInspect(currentUNIT, currentGUID) then
        stopPending()
        failCooldown[currentGUID] = GetTime()
        return
    end
    
    if tryBuildData(currentUNIT, currentGUID, false) then
        stopPending()
        return
    end
    
    retryCount = retryCount - 1
    if retryCount > 0 and GetTime() - taskStartTime < TASK_TIMEOUT then
        pendingTimer = C_Timer.After(POLL_INTERVAL, inspectionTick)
        return
    end
    
    retryRound = retryRound + 1
    if retryRound >= MAX_RETRY_ROUND then
        failCooldown[currentGUID] = GetTime()
        tryBuildData(currentUNIT, currentGUID, true)
        stopPending()
        return
    end
    
    local wait = THROTTLE_TARGET - (GetTime() - lastTargetTime)
    if wait < 0 then wait = 0 end
    
    pendingTimer = C_Timer.After(wait, function()
        if pendingGUID == currentGUID and canInspect(currentUNIT, currentGUID) then
            lastInspectTime = GetTime()
            lastTargetTime = GetTime()
            retryCount = RETRY_COUNT
            NotifyInspect(currentUNIT)
            pendingTimer = C_Timer.After(POLL_INTERVAL, inspectionTick)
        else
            stopPending()
        end
    end)
end

-- Start inspection
local function startInspection(unit, guid)
    if not canInspect(unit, guid) then return end
    if pendingGUID == guid then return end
    
    stopPending()
    
    local now = GetTime()
    if now - lastInspectTime < THROTTLE_GLOBAL then return end
    
    pendingGUID = guid
    retryRound = 0
    retryCount = RETRY_COUNT
    taskStartTime = now
    lastInspectTime = now
    lastTargetTime = now
    
    TOOLTIP:SetupSpecLevel(nil, nil)
    
    NotifyInspect(unit)
    pendingTimer = C_Timer.After(POLL_INTERVAL, inspectionTick)
end

function TOOLTIP:InspectUnit(unit, forced)
    local spec, level

    if UnitIsUnit(unit, 'player') then
        spec = self:GetUnitSpec('player')
        level = self:GetUnitItemLevel('player')
        self:SetupSpecLevel(spec, level)
    else
        if not unit or UnitGUID(unit) ~= currentGUID then
            return
        end
        if not UnitIsPlayer(unit) then
            return
        end

        local currentDB = cache[currentGUID]
        spec = currentDB and currentDB.spec
        level = currentDB and currentDB.level
        
        if spec and level and not forced then
            local cacheTime = currentDB.getTime or 0
            if GetTime() - cacheTime < CACHE_TTL then
                self:SetupSpecLevel(spec, level)
                return
            end
        end

        if not C.DB.Tooltip.SpecIlvlByAlt and IsAltKeyDown() then
            forced = true
        end

        if not UnitIsVisible(unit) or UnitIsDeadOrGhost('player') or UnitOnTaxi('player') then
            return
        end

        if _G.InspectFrame and _G.InspectFrame:IsShown() then
            return
        end

        self:SetupSpecLevel(spec or nil, level or nil)
        startInspection(unit, currentGUID)
    end
end

-- Event handlers
local lastInventoryTime = 0
function TOOLTIP:GetInspectInfo(event, ...)
    if event == 'UNIT_INVENTORY_CHANGED' then
        local thisTime = GetTime()
        if thisTime - lastInventoryTime > 0.1 then
            lastInventoryTime = thisTime
            local unit = ...
            if UnitGUID(unit) == currentGUID then
                TOOLTIP:InspectUnit(unit, true)
            end
        end
    elseif event == 'INSPECT_READY' then
        local guid = ...
        if guid == currentGUID and pendingGUID == guid then
            C_Timer.After(0, function()
                if pendingGUID == guid and canInspect(currentUNIT, guid) then
                    tryBuildData(currentUNIT, guid, false)
                end
            end)
        end
    end
end

F:RegisterEvent('UNIT_INVENTORY_CHANGED', function(...) TOOLTIP:GetInspectInfo('UNIT_INVENTORY_CHANGED', ...) end)
F:RegisterEvent('INSPECT_READY', function(...) TOOLTIP:GetInspectInfo('INSPECT_READY', ...) end)

function TOOLTIP:InspectUnitSpecAndLevel(unit)
    if not C.DB.Tooltip.SpecIlvl then
        return
    end
    if C.DB.Tooltip.PlayerInfoByAlt and not IsAltKeyDown() then
        return
    end

    if not unit or not CanInspect(unit) then
        return
    end

    currentUNIT, currentGUID = unit, UnitGUID(unit)
    
    -- Check cache first
    local cachedData = cache[currentGUID]
    if cachedData and cachedData.spec and cachedData.level then
        local cacheAge = GetTime() - (cachedData.getTime or 0)
        if cacheAge < CACHE_TTL then
            TOOLTIP:SetupSpecLevel(cachedData.spec, cachedData.level)
            return
        end
    end

    TOOLTIP:InspectUnit(unit)
end

-- Periodic cache cleanup
C_Timer.NewTicker(60, function()
    local now = GetTime()
    for guid, data in pairs(cache) do
        if now - (data.getTime or 0) > CACHE_TTL then
            cache[guid] = nil
            failCooldown[guid] = nil
            colorCache[guid] = nil
            cacheCount = cacheCount - 1
        end
    end
end)