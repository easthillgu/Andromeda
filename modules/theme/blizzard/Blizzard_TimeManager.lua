local F, C = unpack(select(2, ...))

-- NDui → Andromeda compat shim
-- 3.80.1 Texture:SetColorTexture polyfill (handles both (r,g,b,a) and (color,a) signatures)
do
    local tex = UIParent:CreateTexture(nil, "ARTWORK")
    local mt = tex and getmetatable(tex)
    if mt and mt.__index and mt.__index.SetColorTexture and not mt.__index.__SetColorTexture_patched then
        mt.__index.__SetColorTexture_patched = true
        local orig = mt.__index.SetColorTexture
        mt.__index.SetColorTexture = function(self, r, g, b, a)
            if type(r) == "number" and type(g) == "number" and type(b) == "number" then
                local ok = pcall(orig, self, r, g, b, a)
                if not ok then
                    orig(self, CreateColor(r, g, b, a or 1))
                end
            else
                orig(self, r, g)
            end
        end
    end
end

local B = {}
setmetatable(B, {__index = F})
-- Name mismatches
B.Reskin = F.ReskinButton
B.ReskinCheck = F.ReskinCheckbox
B.ReskinDropDown = F.ReskinDropdown
B.ReskinEditBox = F.ReskinEditbox
B.ReskinInput = F.ReskinEditbox
B.Dummy = function() end

-- NDui config compat
C.db = C.db or {}
C.db.Skins = {BlizzardSkins = _G.ANDROMEDA_ADB and _G.ANDROMEDA_ADB.ReskinBlizz ~= false}
C.db.Bags = {Enable = false}
C.db.Nameplate = {Enable = false}

local DB = {
    r = C.r, g = C.g, b = C.b,
    bdTex = C.Assets.Textures.Backdrop,
    TexCoord = C.TEX_COORD,
    isDeveloper = false,
    pushedTex = C.Assets.Textures.ButtonPushed,
    normTex = C.Assets.Textures.StatusbarNormal,
    closeTex = C.Assets.Textures.Close,
    ClassColors = RAID_CLASS_COLORS,
    QualityColors = ITEM_QUALITY_COLORS,
}
C.Themes["Blizzard_TimeManager"] = function()
	TimeManagerGlobe:Hide()
	TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
	TimeManagerStopwatchCheck:SetCheckedTexture(DB.pushedTex)
	B.CreateBDFrame(TimeManagerStopwatchCheck)

	B.ReskinDropDown(TimeManagerAlarmTimeFrame.HourDropdown)
	B.ReskinDropDown(TimeManagerAlarmTimeFrame.MinuteDropdown)
	B.ReskinDropDown(TimeManagerAlarmTimeFrame.AMPMDropdown)

	B.ReskinPortraitFrame(TimeManagerFrame)
	B.ReskinInput(TimeManagerAlarmMessageEditBox)
	B.ReskinCheck(TimeManagerAlarmEnabledButton)
	B.ReskinCheck(TimeManagerMilitaryTimeCheck)
	B.ReskinCheck(TimeManagerLocalTimeCheck)

	B.StripTextures(StopwatchFrame)
	B.StripTextures(StopwatchTabFrame)
	B.SetBD(StopwatchFrame)
	B.ReskinClose(StopwatchCloseButton, StopwatchFrame, -2, -2)

	local reset = StopwatchResetButton
	reset:GetNormalTexture():SetTexCoord(.25, .75, .27, .75)
	reset:SetSize(18, 18)
	reset:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	reset:SetPoint("BOTTOMRIGHT", -5, 7)
	local play = StopwatchPlayPauseButton
	play:GetNormalTexture():SetTexCoord(.25, .75, .27, .75)
	play:SetSize(18, 18)
	play:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	play:SetPoint("RIGHT", reset, "LEFT", -2, 0)
end