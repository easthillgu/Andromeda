-- Credit: rgd87
-- https://github.com/rgd87/NugKeyFeedback

local F, C, L = unpack(select(2, ...))
local ACTIONBAR = F:GetModule('ActionBar')

local settings = {
    point = 'CENTER',
    x = 0,
    y = 0,
    enableCastLine = true,
    enableCooldown = true,
    enablePushEffect = true,
    enableCast = true,
    enableCastFlash = true,
    lineIconSize = 28,
    mirrorSize = 32,
    lineDirection = 'LEFT',
    forceUseActionHook = false,
}

local isClassic = math.floor(select(4, GetBuildInfo()) / 10000) < 5
local dummy = function() end
local IsInPetBattle = isClassic and dummy or (C_PetBattles and C_PetBattles.IsInBattle or dummy)

local FramePool = {
    AddObject = function(self, object)
        local dummy = true
        self.activeObjects[object] = dummy
        self.activeObjectCount = self.activeObjectCount + 1
    end,
    ReclaimObject = function(self, object)
        tinsert(self.inactiveObjects, object)
        self.activeObjects[object] = nil
        self.activeObjectCount = self.activeObjectCount - 1
    end,
    Release = function(self, object)
        local active = self.activeObjects[object] ~= nil
        if active then
            self:resetterFunc(object)
            self:ReclaimObject(object)
        end
        return active
    end,
    Acquire = function(self)
        local object = tremove(self.inactiveObjects)
        if object then
            self:AddObject(object)
            return object, false
        else
            object = self:creationFunc()
            self:AddObject(object)
            return object, true
        end
    end,
    ReleaseAll = function(self)
        for obj in pairs(self.activeObjects) do
            self:Release(obj)
        end
    end,
    Init = function(self, parent)
        self.activeObjects = {}
        self.inactiveObjects = {}
        self.activeObjectCount = 0
        self.parent = parent
    end
}

local function CreateCustomFramePool(frameType, parent, frameTemplate, resetterFunc)
    local self = setmetatable({}, { __index = FramePool })
    self:Init(parent)
    self.frameType = frameType
    self.frameTemplate = frameTemplate
    return self
end

function ACTIONBAR:CreateKeyFeedback()
    if not C.DB.Actionbar.KeyFeedback then
        return
    end

    local keyFeedback = CreateFrame('Frame', C.ADDON_TITLE .. 'KeyFeedback', _G.UIParent)
    keyFeedback.db = settings

    keyFeedback:SetScript('OnEvent', function(self, event, ...)
        return self[event](self, event, ...)
    end)

    keyFeedback.mirror = ACTIONBAR:CreateFeedbackButton(keyFeedback, true)
    ACTIONBAR:HookUseAction(keyFeedback)
    ACTIONBAR:HookDefaultBindings(keyFeedback)

    keyFeedback.mirror.icon:SetTexture('Interface\\Icons\\Spell_Arcane_PortalIronForge')
    keyFeedback.mirror.icon:SetTexCoord(unpack(C.TEX_COORD))

    local GetActionSpellID = function(action)
        local actionType, id = GetActionInfo(action)
        if actionType == 'spell' then
            return id
        elseif actionType == 'macro' then
            return GetMacroSpell(id)
        end
    end

    keyFeedback.mirror.UpdateAction = function(self, fullUpdate)
        local action = self.action
        if not action then
            return
        end

        local tex = GetActionTexture(action)
        if not tex then
            return
        end
        self.icon:SetTexture(tex)
        self.icon:SetTexCoord(unpack(C.TEX_COORD))

        if fullUpdate then
            self:UpdateCooldownOrCast()
        end
    end

    keyFeedback.mirror.UpdateCooldownOrCast = function(self)
        local action = self.action
        if not action then
            return
        end

        local cooldownStartTime, cooldownDuration, enable, modRate = GetActionCooldown(action)

        local cooldownFrame = self.cooldown
        local castDuration = self.castDuration or 0

        if keyFeedback.db.enableCast and self.castSpellID and self.castSpellID == GetActionSpellID(action) and castDuration > cooldownDuration then
            cooldownFrame:SetDrawEdge(true)
            cooldownFrame:SetReverse(self.castInverted)
            CooldownFrame_Set(cooldownFrame, self.castStartTime, castDuration, true, true, 1)
        elseif keyFeedback.db.enableCooldown then
            cooldownFrame:SetDrawEdge(false)
            cooldownFrame:SetReverse(false)
            local charges, maxCharges, chargeStart, chargeDuration, chargeModRate = GetActionCharges and GetActionCharges(action) or nil
            CooldownFrame_Set(cooldownFrame, cooldownStartTime, cooldownDuration, enable, false, modRate)
        else
            cooldownFrame:Hide()
        end
    end

    keyFeedback:SetSize(30, 30)
    keyFeedback:Show()

    local mover = F.Mover(keyFeedback, L['SpellFeedback'], 'SpellFeedback', { 'CENTER', _G.UIParent, 0, -300 }, settings.mirrorSize, settings.mirrorSize)
    keyFeedback:ClearAllPoints()
    keyFeedback:SetPoint('CENTER', mover)

    ACTIONBAR:SetupKeyFeedbackEvents(keyFeedback)
    keyFeedback:RefreshSettings()
end

function ACTIONBAR:SetupKeyFeedbackEvents(keyFeedback)
    keyFeedback.UNIT_SPELLCAST_START = function(self, _, unit, _, spellID)
        local _, _, _, startTime, endTime, _, castID, _ = UnitCastingInfo(unit)
        if not startTime then
            return
        end
        local mirror = self.mirror
        mirror.castInverted = false
        mirror.castID = castID
        mirror.castSpellID = spellID
        mirror.castStartTime = startTime / 1000
        mirror.castDuration = (endTime - startTime) / 1000
        mirror:BumpFadeOut(mirror.castDuration)
        mirror:UpdateCooldownOrCast()
    end

    keyFeedback.UNIT_SPELLCAST_DELAYED = keyFeedback.UNIT_SPELLCAST_START

    keyFeedback.UNIT_SPELLCAST_CHANNEL_START = function(self, _, unit, _, spellID)
        local _, _, _, startTime, endTime, _, castID, _ = UnitChannelInfo(unit)
        local mirror = self.mirror
        mirror.castInverted = true
        mirror.castID = castID
        mirror.castSpellID = spellID
        mirror.castStartTime = startTime / 1000
        mirror.castDuration = (endTime - startTime) / 1000
        mirror:BumpFadeOut(mirror.castDuration)
        mirror:UpdateCooldownOrCast()
    end

    keyFeedback.UNIT_SPELLCAST_CHANNEL_UPDATE = keyFeedback.UNIT_SPELLCAST_CHANNEL_START

    keyFeedback.UNIT_SPELLCAST_STOP = function(self, _, _, _, _)
        local mirror = self.mirror
        mirror.castSpellID = nil
        mirror.castDuration = nil
        mirror:UpdateCooldownOrCast()
    end

    keyFeedback.UNIT_SPELLCAST_FAILED = function(self, event, unit, castID)
        if self.mirror.castID == castID then
            keyFeedback.UNIT_SPELLCAST_STOP(self, event, unit, nil)
        end
    end

    keyFeedback.UNIT_SPELLCAST_INTERRUPTED = keyFeedback.UNIT_SPELLCAST_STOP
    keyFeedback.UNIT_SPELLCAST_CHANNEL_STOP = keyFeedback.UNIT_SPELLCAST_STOP

    keyFeedback.SPELL_UPDATE_COOLDOWN = function(self)
        self.mirror:UpdateAction(true)
    end

    keyFeedback.UNIT_SPELLCAST_SUCCEEDED = function(self, _, _, _, spellID)
        if IsPlayerSpell(spellID) then
            if spellID == 75 then
                return
            end

            if self.db.enableCastLine and self.iconPool then
                local frame = self.iconPool:Acquire()
                local texture = select(3, GetSpellInfo(spellID))
                if frame and frame.icon then
                    frame.icon:SetTexture(texture)
                    frame.icon:SetTexCoord(unpack(C.TEX_COORD))
                    frame:Show()
                    if frame.ag then
                        frame.ag:Play()
                    end
                end
            end

            if self.db.enableCastFlash then
                self.mirror.glow:Show()
                self.mirror.glow.blink:Play()
            end
        end
    end

    keyFeedback.RefreshSettings = function(self)
        local db = self.db
        self.mirror:SetSize(db.mirrorSize, db.mirrorSize)

        self:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player')
        if db.enableCastLine then
            if not self.iconPool then
                self.iconPool = ACTIONBAR:CreateLastSpellIconLine(self, self.mirror)
            end

            local pool = self.iconPool
            pool:ReleaseAll()
            if pool.inactiveObjects then
                for _, f in ipairs(pool.inactiveObjects) do
                    if pool.resetterFunc then
                        pool:resetterFunc(f)
                    end
                end
            end
        end

        if db.enableCooldown then
            self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
        else
            self:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
        end

        if db.enableCast then
            self:RegisterUnitEvent('UNIT_SPELLCAST_START', 'player')
            self:RegisterUnitEvent('UNIT_SPELLCAST_DELAYED', 'player')
            self:RegisterUnitEvent('UNIT_SPELLCAST_STOP', 'player')
            self:RegisterUnitEvent('UNIT_SPELLCAST_FAILED', 'player')
            self:RegisterUnitEvent('UNIT_SPELLCAST_INTERRUPTED', 'player')
            self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_START', 'player')
            self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', 'player')
            self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_STOP', 'player')
        else
            self:UnregisterEvent('UNIT_SPELLCAST_START')
            self:UnregisterEvent('UNIT_SPELLCAST_DELAYED')
            self:UnregisterEvent('UNIT_SPELLCAST_STOP')
            self:UnregisterEvent('UNIT_SPELLCAST_FAILED')
            self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTED')
            self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START')
            self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE')
            self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_STOP')
        end
    end
end

function ACTIONBAR:CreateFeedbackButton(keyFeedback, autoKeyup)
    local db = keyFeedback.db

    local mirror = CreateFrame('Button', C.ADDON_TITLE .. 'KeyFeedbackMirror', keyFeedback, 'ActionButtonTemplate')
    mirror:SetHeight(db.mirrorSize)
    mirror:SetWidth(db.mirrorSize)
    mirror.NormalTexture:ClearAllPoints()

    local bg = F.CreateBDFrame(mirror)
    bg:SetBackdropBorderColor(0, 0, 0)
    F.CreateSD(bg)

    if mirror.SetPushedTexture then
        mirror:SetPushedTexture(0)
    end

    mirror.cooldown:SetEdgeTexture('Interface\\Cooldown\\edge')
    mirror.cooldown:SetSwipeColor(0, 0, 0)
    mirror.cooldown:SetHideCountdownNumbers(true)
    mirror.cooldown:SetAllPoints(mirror)
    mirror.cooldown:Hide()

    mirror:Show()
    mirror._elapsed = 0

    local glow = CreateFrame('Frame', nil, mirror)
    glow:SetPoint('TOPLEFT', -16, 16)
    glow:SetPoint('BOTTOMRIGHT', 16, -16)
    local gtex = glow:CreateTexture(nil, 'OVERLAY')
    gtex:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
    gtex:SetTexCoord(0, 66 / 128, 136 / 256, 202 / 256)
    gtex:SetVertexColor(0, 1, 0)
    gtex:SetAllPoints(glow)
    mirror.glow = glow
    glow:Hide()

    local ag = glow:CreateAnimationGroup()
    glow.blink = ag

    local a2 = ag:CreateAnimation('Alpha')
    a2:SetFromAlpha(1)
    a2:SetToAlpha(0)
    a2:SetSmoothing('OUT')
    a2:SetDuration(0.3)
    a2:SetOrder(2)

    ag:SetScript('OnFinished', function(self)
        self:GetParent():Hide()
    end)

    if db.enablePushEffect then
        local pushedCircle = CreateFrame('Frame', nil, mirror)
        local size = db.mirrorSize
        pushedCircle:SetSize(size, size)
        pushedCircle:SetPoint('CENTER', 0, 0)
        local pctex = pushedCircle:CreateTexture(nil, 'OVERLAY')
        pctex:SetTexture(C.Assets.Textures.ButtonPushed)
        pctex:SetBlendMode('ADD')
        pctex:SetAllPoints(pushedCircle)
        mirror.pushedCircle = pushedCircle
        pushedCircle:Hide()

        local gag = pushedCircle:CreateAnimationGroup()
        pushedCircle.grow = gag

        local ga1 = gag:CreateAnimation('Scale')
        ga1:SetScaleFrom(0.1, 0.1)
        ga1:SetScaleTo(1.3, 1.3)
        ga1:SetDuration(0.3)
        ga1:SetOrder(2)

        local ga2 = gag:CreateAnimation('Alpha')
        ga2:SetFromAlpha(0.5)
        ga2:SetToAlpha(0)
        ga2:SetDuration(0.2)
        ga2:SetStartDelay(0.1)
        ga2:SetOrder(2)

        gag:SetScript('OnFinished', function(self)
            self:GetParent():Hide()
        end)
    end

    mirror.BumpFadeOut = function(self, modifier)
        modifier = modifier or 1.5
        if -modifier < self._elapsed then
            self._elapsed = -modifier
        end
    end

    if autoKeyup then
        mirror:SetScript('OnUpdate', function(self, elapsed)
            self._elapsed = self._elapsed + elapsed

            local timePassed = self._elapsed

            if timePassed >= 0.1 and self.pushed then
                mirror:SetButtonState('NORMAL')
                self.pushed = false
            end

            if timePassed >= 1 then
                local alpha = 2 - timePassed
                if alpha <= 0 then
                    alpha = 0
                    self:Hide()
                end
                self:SetAlpha(alpha)
            end
        end)
    else
        mirror:SetScript('OnUpdate', function(self, elapsed)
            self._elapsed = self._elapsed + elapsed

            local timePassed = self._elapsed
            if timePassed >= 1 then
                local alpha = 2 - timePassed
                if alpha <= 0 then
                    alpha = 0
                    self:Hide()
                end
                self:SetAlpha(alpha)
            end
        end)
    end

    mirror:EnableMouse(false)

    mirror:SetPoint('CENTER', keyFeedback, 'CENTER')

    mirror:Show()

    return mirror
end

function ACTIONBAR:HookDefaultBindings(keyFeedback)
    local MirrorActionButtonDown = function(action)
        if not HasAction(action) then
            return
        end
        if IsInPetBattle() then
            return
        end

        local mirror = keyFeedback.mirror

        if mirror.action ~= action then
            mirror.action = action
            mirror:UpdateAction(true)
        else
            mirror:UpdateAction()
        end

        mirror:Show()
        mirror._elapsed = 0
        mirror:SetAlpha(1)
        mirror:BumpFadeOut()
        mirror.pushed = true
        if mirror:GetButtonState() == 'NORMAL' then
            if mirror.pushedCircle then
                if mirror.pushedCircle.grow:IsPlaying() then
                    mirror.pushedCircle.grow:Stop()
                end
                mirror.pushedCircle:Show()
                mirror.pushedCircle.grow:Play()
            end
            mirror:SetButtonState('PUSHED')
        end
    end

    local MirrorActionButtonUp = function()
        local mirror = keyFeedback.mirror
        if mirror:GetButtonState() == 'PUSHED' then
            mirror:SetButtonState('NORMAL')
        end
    end

    local GetActionButtonForID = _G.GetActionButtonForID
    hooksecurefunc('ActionButtonDown', function(id)
        local button = GetActionButtonForID(id)
        if button then
            return MirrorActionButtonDown(button.action)
        end
    end)
    hooksecurefunc('ActionButtonUp', MirrorActionButtonUp)
    hooksecurefunc('MultiActionButtonDown', function(bar, id)
        local button = _G[bar .. 'Button' .. id]
        return MirrorActionButtonDown(button.action)
    end)
    hooksecurefunc('MultiActionButtonUp', MirrorActionButtonUp)
end

function ACTIONBAR:HookUseAction(keyFeedback)
    local MirrorActionButtonDown = function(action)
        if not HasAction(action) then
            return
        end
        if IsInPetBattle() then
            return
        end

        local mirror = keyFeedback.mirror

        if mirror.action ~= action then
            mirror.action = action
            mirror:UpdateAction(true)
        else
            mirror:UpdateAction()
        end

        mirror:Show()
        mirror._elapsed = 0
        mirror:SetAlpha(1)
        mirror:BumpFadeOut()
        mirror.pushed = true
        if mirror:GetButtonState() == 'NORMAL' then
            if mirror.pushedCircle then
                if mirror.pushedCircle.grow:IsPlaying() then
                    mirror.pushedCircle.grow:Stop()
                end
                mirror.pushedCircle:Show()
                mirror.pushedCircle.grow:Play()
            end
            mirror:SetButtonState('PUSHED')
        end
    end

    hooksecurefunc('UseAction', function(action)
        return MirrorActionButtonDown(action)
    end)
end

function ACTIONBAR:CreateLastSpellIconLine(keyFeedback, parent)
    local template = nil
    local resetterFunc = function(pool, f)
        local db = keyFeedback.db

        f:SetHeight(db.lineIconSize)
        f:SetWidth(db.lineIconSize)

        if f.ag then
            f.ag:Stop()
        end

        local scaleOrigin, revOrigin, translateX, translateY
        if db.lineDirection == 'RIGHT' then
            scaleOrigin = 'LEFT'
            revOrigin = 'RIGHT'
            translateX = 100
            translateY = 0
        elseif db.lineDirection == 'TOP' then
            scaleOrigin = 'BOTTOM'
            revOrigin = 'TOP'
            translateX = 0
            translateY = 100
        elseif db.lineDirection == 'BOTTOM' then
            scaleOrigin = 'TOP'
            revOrigin = 'BOTTOM'
            translateX = 0
            translateY = -100
        else
            scaleOrigin = 'RIGHT'
            revOrigin = 'LEFT'
            translateX = -100
            translateY = 0
        end
        local ag = f.ag
        if ag then
            ag.s1:SetOrigin(scaleOrigin, 0, 0)
            ag.s2:SetOrigin(scaleOrigin, 0, 0)
            ag.t1:SetOffset(translateX, translateY)
        end

        f:ClearAllPoints()
        local poolParent = pool.parent
        f:SetPoint(scaleOrigin, poolParent, revOrigin, 0, 0)
    end

    local iconPool = CreateCustomFramePool('Frame', parent, template, resetterFunc)
    iconPool.creationFunc = function(pool)
        local db = keyFeedback.db

        local hdr = pool.parent
        local id = pool.idCounter
        pool.idCounter = pool.idCounter + 1
        local f = CreateFrame('Button', C.ADDON_TITLE .. 'KeyFeedbackPoolIcon' .. id, hdr, 'ActionButtonTemplate')

        if f.SetNormalTexture then
            f:SetNormalTexture(0)
        end

        if f.cooldown then
            f.cooldown:SetHideCountdownNumbers(true)
            f.cooldown:Hide()
        end

        local bg = F.CreateBDFrame(f)
        bg:SetBackdropBorderColor(0, 0, 0)
        F.CreateSD(bg)

        f:EnableMouse(false)
        f:SetHeight(db.lineIconSize)
        f:SetWidth(db.lineIconSize)
        f:SetPoint('BOTTOM', hdr, 'BOTTOM', 0, -0)

        local t = f.icon
        f:SetAlpha(0)

        t:SetTexture('Interface\\Icons\\Spell_Shadow_SacrificialShield')
        t:SetTexCoord(unpack(C.TEX_COORD))

        local ag = f:CreateAnimationGroup()
        f.ag = ag

        local scaleOrigin = 'RIGHT'
        local translateX = -100
        local translateY = 0

        local s1 = ag:CreateAnimation('Scale')
        s1:SetScale(0.01, 1)
        s1:SetDuration(0)
        s1:SetOrigin(scaleOrigin, 0, 0)
        s1:SetOrder(1)

        local s2 = ag:CreateAnimation('Scale')
        s2:SetScale(100, 1)
        s2:SetDuration(0.5)
        s2:SetOrigin(scaleOrigin, 0, 0)
        s2:SetSmoothing('OUT')
        s2:SetOrder(2)

        local a1 = ag:CreateAnimation('Alpha')
        a1:SetFromAlpha(0)
        a1:SetToAlpha(1)
        a1:SetDuration(0.1)
        a1:SetOrder(2)

        local t1 = ag:CreateAnimation('Translation')
        t1:SetOffset(translateX, translateY)
        t1:SetDuration(1.2)
        t1:SetSmoothing('IN')
        t1:SetOrder(2)

        local a2 = ag:CreateAnimation('Alpha')
        a2:SetFromAlpha(1)
        a2:SetToAlpha(0)
        a2:SetSmoothing('OUT')
        a2:SetDuration(0.5)
        a2:SetStartDelay(0.6)
        a2:SetOrder(2)

        ag.s1 = s1
        ag.s2 = s2
        ag.t1 = t1

        ag:SetScript('OnFinished', function(self)
            local icon = self:GetParent()
            icon:Hide()
            pool:Release(icon)
        end)

        return f
    end
    iconPool.resetterFunc = resetterFunc
    iconPool.idCounter = 1

    return iconPool
end
