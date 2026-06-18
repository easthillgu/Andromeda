local addonName, engine = ...
local F, C = engine[1], engine[2]

local function IsAddOnLoaded_Compat(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded(name)
    elseif _G.IsAddOnLoaded then
        return _G.IsAddOnLoaded(name)
    end
    return false
end

local EventManager = {
    eventHandlers = {},
    eventFrames = {},
    addonCallbacks = {},
    debugMode = false,
}

local function GetEventFrame(event)
    if not EventManager.eventFrames[event] then
        local frame = CreateFrame('Frame')
        frame:SetScript('OnEvent', function(_, event, ...)
            EventManager:DispatchEvent(event, ...)
        end)
        EventManager.eventFrames[event] = frame
    end
    return EventManager.eventFrames[event]
end

function EventManager:DispatchEvent(event, ...)
    if self.debugMode then
        F:Debug(format('[EventManager] Dispatching: %s', event))
    end

    local handlers = self.eventHandlers[event]
    if not handlers then return end

    for priority = 1, #handlers do
        for _, handlerInfo in ipairs(handlers[priority]) do
            if handlerInfo.condition(...) then
                xpcall(handlerInfo.callback, geterrorhandler(), event, ...)
            end
        end
    end
end

function EventManager:RegisterEvent(event, callback, condition, priority)
    condition = condition or function() return true end
    priority = math.max(1, math.min(5, priority or 3))

    if not self.eventHandlers[event] then
        self.eventHandlers[event] = {}
        for i = 1, 5 do
            self.eventHandlers[event][i] = {}
        end
        GetEventFrame(event):RegisterEvent(event)
    end

    tinsert(self.eventHandlers[event][priority], {
        callback = callback,
        condition = condition
    })
end

function EventManager:UnregisterEvent(event, callback)
    local handlers = self.eventHandlers[event]
    if not handlers then return end

    for priority = 1, #handlers do
        for i = #handlers[priority], 1, -1 do
            if handlers[priority][i].callback == callback then
                tremove(handlers[priority], i)
            end
        end
    end

    local hasHandlers = false
    for priority = 1, #handlers do
        if #handlers[priority] > 0 then
            hasHandlers = true
            break
        end
    end

    if not hasHandlers then
        self.eventHandlers[event] = nil
        GetEventFrame(event):UnregisterEvent(event)
    end
end

function EventManager:RegisterAddonLoaded(addonName, callback, once, priority)
    priority = math.max(1, math.min(5, priority or 3))

    local condition = function(_, loadedAddon)
        return loadedAddon == addonName
    end

    local wrappedCallback
    wrappedCallback = function(...)
        callback(...)
        if once then
            self:UnregisterEvent('ADDON_LOADED', wrappedCallback)
        end
    end

    self:RegisterEvent('ADDON_LOADED', wrappedCallback, condition, priority)
end

function EventManager:RegisterAddonLoadedOrAlreadyLoaded(addonName, callback)
    if IsAddOnLoaded_Compat(addonName) then
        xpcall(callback, geterrorhandler())
    else
        self:RegisterAddonLoaded(addonName, callback, true)
    end
end

function EventManager:SetDebugMode(enabled)
    self.debugMode = enabled
end

function EventManager:GetEventCount(event)
    local handlers = self.eventHandlers[event]
    if not handlers then return 0 end

    local count = 0
    for priority = 1, #handlers do
        count = count + #handlers[priority]
    end
    return count
end

F.EventManager = EventManager