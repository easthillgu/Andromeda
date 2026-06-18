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

    for _, handlerInfo in ipairs(handlers) do
        if handlerInfo.condition(...) then
            xpcall(handlerInfo.callback, geterrorhandler(), event, ...)
        end
    end
end

function EventManager:RegisterEvent(event, callback, condition)
    condition = condition or function() return true end

    if not self.eventHandlers[event] then
        self.eventHandlers[event] = {}
        GetEventFrame(event):RegisterEvent(event)
    end

    tinsert(self.eventHandlers[event], {
        callback = callback,
        condition = condition
    })
end

function EventManager:UnregisterEvent(event, callback)
    local handlers = self.eventHandlers[event]
    if not handlers then return end

    for i = #handlers, 1, -1 do
        if handlers[i].callback == callback then
            tremove(handlers, i)
            break
        end
    end

    if #handlers == 0 then
        self.eventHandlers[event] = nil
        GetEventFrame(event):UnregisterEvent(event)
    end
end

function EventManager:RegisterAddonLoaded(addonName, callback, once)
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

    self:RegisterEvent('ADDON_LOADED', wrappedCallback, condition)
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
    return handlers and #handlers or 0
end

F.EventManager = EventManager