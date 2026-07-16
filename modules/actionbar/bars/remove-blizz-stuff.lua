local F, C = unpack(select(2, ...))
local ACTIONBAR = F:GetModule('ActionBar')

local scripts = {
    'OnShow',
    'OnHide',
    'OnEvent',
    'OnEnter',
    'OnLeave',
    'OnUpdate',
    'OnValueChanged',
    'OnClick',
    'OnMouseDown',
    'OnMouseUp',
}

local framesToHide = {
    _G.MainMenuBar,
    _G.MultiBarBottomLeft,
    _G.MultiBarBottomRight,
    _G.MultiBarLeft,
    _G.MultiBarRight,
    _G.MultiBar5,
    _G.MultiBar6,
    _G.MultiBar7,
    _G.OverrideActionBar,
    _G.PossessActionBar,
    _G.PetActionBar,
    _G.StanceBar,
    _G.StatusTrackingBarManager,
    _G.BagsBar,
    _G.MicroButtonAndBagsBar,
    _G.TalentMicroButton,
    _G.SpellbookMicroButton,
    _G.CharacterMicroButton,
    _G.AchievementMicroButton,
    _G.QuestLogMicroButton,
    _G.GuildMicroButton,
    _G.LFDMicroButton,
    _G.EJMicroButton,
    _G.CollectionsMicroButton,
    _G.StoreMicroButton,
    _G.MainMenuMicroButton,
    _G.BagsBar,
    _G.SocialsMicroButton,
    _G.PVPMicroButton,
    _G.LFGMicroButton,
    _G.HelpMicroButton,
}

local framesToDisable = {
    _G.MainMenuBar,
    _G.MainActionBar,
    _G.MultiBarBottomLeft,
    _G.MultiBarBottomRight,
    _G.MultiBarLeft,
    _G.MultiBarRight,
    _G.MultiBar5,
    _G.MultiBar6,
    _G.MultiBar7,
    _G.PossessActionBar,
    _G.PetActionBar,
    _G.StanceBar,
    _G.MicroButtonAndBagsBar,
    _G.StatusTrackingBarManager,
    _G.MainMenuBarVehicleLeaveButton,
    _G.OverrideActionBar,
    _G.OverrideActionBarExpBar,
    _G.OverrideActionBarHealthBar,
    _G.OverrideActionBarPowerBar,
    _G.OverrideActionBarPitchFrame,
}

local function disableAllScripts(frame)
    for _, script in next, scripts do
        if frame:HasScript(script) then
            frame:SetScript(script, nil)
        end
    end
end

local function updateTokenVisibility()
    TokenFrame_LoadUI()
    TokenFrame_Update()
end

local function buttonEventsRegisterFrame(self, added)
    local frames = self.frames
    for index = #frames, 1, -1 do
        local frame = frames[index]
        local wasAdded = frame == added
        if not added or wasAdded then
            if not strmatch(frame:GetName(), 'ExtraActionButton%d') then
                self.frames[index] = nil
            end

            if wasAdded then
                break
            end
        end
    end
end

local function disableDefaultBarEvents() -- credit: Simpy
    -- MainMenuBar:ClearAllPoints taint during combat
    _G.MainMenuBar.SetPositionForStatusBars = nop

    -- Spellbook open in combat taint, only happens sometimes
    _G.MultiActionBar_HideAllGrids = nop
    _G.MultiActionBar_ShowAllGrids = nop

    -- shut down some events for things we dont use
    _G.ActionBarController:UnregisterAllEvents()
    _G.ActionBarController:RegisterEvent('SETTINGS_LOADED') -- this is needed for page controller to spawn properly
    _G.ActionBarController:RegisterEvent('UPDATE_EXTRA_ACTIONBAR') -- this is needed to let the ExtraActionBar show
    _G.ActionBarActionEventsFrame:UnregisterAllEvents()

    -- used for ExtraActionButton and TotemBar (on wrath)
    _G.ActionBarButtonEventsFrame:UnregisterAllEvents()
    _G.ActionBarButtonEventsFrame:RegisterEvent('ACTIONBAR_SLOT_CHANGED') -- needed to let the ExtraActionButton show and Totems to swap
    _G.ActionBarButtonEventsFrame:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN') -- needed for cooldowns of them both

    hooksecurefunc(_G.ActionBarButtonEventsFrame, 'RegisterFrame', buttonEventsRegisterFrame)
    buttonEventsRegisterFrame(_G.ActionBarButtonEventsFrame)

    -- fix keybind error, this actually just prevents reopen of the GameMenu
    _G.SettingsPanel.TransitionBackOpeningPanel = _G.HideUIPanel
end

function ACTIONBAR:RemoveBlizzStuff()
    -- Move MainActionBar off-screen and hide (Blizzard re-shows hidden frames)
    if _G.MainActionBar then
        _G.MainActionBar:ClearAllPoints()
        _G.MainActionBar:SetPoint("BOTTOMLEFT", _G.UIParent, -5000, -5000)
        _G.MainActionBar:SetAlpha(0)
    end

    for _, frame in next, framesToHide do
        if frame then
            frame:SetParent(F.HiddenFrame)
            frame:SetAlpha(0)
        end
    end

    for _, frame in next, framesToDisable do
        if frame then
            frame:UnregisterAllEvents()
            disableAllScripts(frame)
        end
    end

    disableDefaultBarEvents()

    if _G.MainMenuBarVehicleLeaveButton then
        _G.MainMenuBarVehicleLeaveButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    end

    F:RegisterEvent('CURRENCY_DISPLAY_UPDATE', updateTokenVisibility)

    if _G.StatusTrackingBarManager then
        _G.StatusTrackingBarManager:UnregisterAllEvents()
        _G.StatusTrackingBarManager:Hide()
    end
end