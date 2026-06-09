local F, C = unpack(select(2, ...))
local THEME = F:GetModule('Theme')

C.Themes = {}
C.BlizzThemes = {}
C.AddonThemes = {}

function THEME:RegisterSkin(addonName, func)
    C.AddonThemes[addonName] = func
end

function THEME:LoadSkins(list)
    if not next(list) then
        return
    end

    for addonName, func in pairs(list) do
        local isLoaded, isFinished = C_AddOns.IsAddOnLoaded(addonName)
        if isLoaded and isFinished then
            xpcall(func, geterrorhandler())
            list[addonName] = nil
        end
    end
end

function THEME:LoadAddOnSkins()
    if C_AddOns.IsAddOnLoaded("AuroraClassic") or C_AddOns.IsAddOnLoaded("Aurora") then return end

    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        wipe(C.BlizzThemes)
        wipe(C.Themes)
    end

    if next(C.BlizzThemes) then
        for _, func in pairs(C.BlizzThemes) do
            xpcall(func, geterrorhandler())
        end
        wipe(C.BlizzThemes)
    end

    THEME:LoadSkins(C.Themes) -- blizzard ui
    THEME:LoadSkins(C.AddonThemes) -- other addons

    F:RegisterEvent('ADDON_LOADED', function(_, addonName)
        local blizzFunc = C.Themes[addonName]
        if blizzFunc then
            xpcall(blizzFunc, geterrorhandler())
            C.Themes[addonName] = nil
        end

        local addonFunc = C.AddonThemes[addonName]
        if addonFunc then
            xpcall(addonFunc, geterrorhandler())
            C.AddonThemes[addonName] = nil
        end
    end)

    hooksecurefunc("SetItemButtonQuality", function(button, quality, itemID)
        if quality then
            if quality >= Enum.ItemQuality.Standard and C.QualityColors and C.QualityColors[quality] then
                local colors = C.QualityColors[quality]
                if button.IconBorder then
                    button.IconBorder:Show()
                    button.IconBorder:SetVertexColor(colors.r, colors.g, colors.b)
                end
            else
                if button.IconBorder then
                    button.IconBorder:Hide()
                end
            end
        else
            if button.IconBorder then
                button.IconBorder:Hide()
            end
        end
    end)
end

do
    local function reskinTimerBar(bar)
        if not bar then return end

        bar:SetSize(200, 18)
        F.StripTextures(bar)

        local statusbar
        if bar.StatusBar then
            statusbar = bar.StatusBar
        elseif bar.GetName then
            local name = bar:GetName()
            if name then
                statusbar = _G[name .. 'StatusBar']
            end
        end

        if statusbar then
            statusbar:SetAllPoints()
        elseif bar.SetStatusBarTexture then
            bar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
        end

        bar.bg = F.SetBD(bar)
        bar.bg:SetBackdropBorderColor(0, 0, 0)
    end

    function THEME:ReskinMirrorBars()
        local previous
        for i = 1, 3 do
            local bar = _G['MirrorTimer' .. i]
            local text = _G['MirrorTimer' .. i .. 'Text']
            reskinTimerBar(bar)

            -- 3.80.1: add custom timer text overlay (credit: ElvUI)
            if text then
                bar.label = text
                text:Hide()
            end
            if not bar.TimerText then
                local tt = bar:CreateFontString(nil, 'OVERLAY')
                tt:SetFont(C.Assets.Fonts.Regular, 12, 'OUTLINE')
                tt:SetPoint('CENTER', bar, 'CENTER', 0, 0)
                bar.TimerText = tt
                bar.timeSinceUpdate = 0.3
                bar:HookScript('OnUpdate', function(frame, elapsed)
                    if frame.paused then return end
                    if frame.timeSinceUpdate >= 0.3 then
                        local labelText = frame.label and frame.label:GetText()
                        if frame.value > 0 then
                            frame.TimerText:SetFormattedText('%s (%d:%02d)', labelText,
                                frame.value / 60, frame.value % 60)
                        else
                            frame.TimerText:SetFormattedText('%s (0:00)', labelText)
                        end
                        frame.timeSinceUpdate = 0
                    else
                        frame.timeSinceUpdate = frame.timeSinceUpdate + elapsed
                    end
                end)
            end

            if previous then
                bar:SetPoint('TOP', previous, 'BOTTOM', 0, -5)
            end
            previous = bar
        end
    end

    local function updateTimerTracker()
        if not _G.TimerTracker or not _G.TimerTracker.timerList then return end

        for _, timer in pairs(_G.TimerTracker.timerList) do
            if timer and timer.bar and not timer.bar.styled then
                xpcall(reskinTimerBar, geterrorhandler(), timer.bar)
                timer.bar.styled = true
            end
        end
    end

    function THEME:ReskinTimerTrakcer()
        if not _G.ANDROMEDA_ADB.ReskinBlizz then
            return
        end

        xpcall(updateTimerTracker, geterrorhandler())

        F:RegisterEvent('START_TIMER', updateTimerTracker)
    end
end

function THEME:OnLogin()
    THEME:LoadAddOnSkins()

    THEME:ReskinMirrorBars()
    THEME:ReskinTimerTrakcer()
    THEME:ReskinDBM()
    THEME:ReskinPGF()
    THEME:ReskinREHack()
    THEME:ReskinMRT()
    THEME:ReskinMeetingHorn()
end
