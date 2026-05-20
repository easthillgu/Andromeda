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
C.Themes["Blizzard_BindingUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	local KeyBindingFrame = KeyBindingFrame

	KeyBindingFrame.header:DisableDrawLayer("BACKGROUND")
	KeyBindingFrame.header:DisableDrawLayer("BORDER")
	KeyBindingFrame.scrollFrame.scrollBorderTop:SetTexture("")
	KeyBindingFrame.scrollFrame.scrollBorderBottom:SetTexture("")
	KeyBindingFrame.scrollFrame.scrollBorderMiddle:SetTexture("")
	KeyBindingFrame.scrollFrame.scrollFrameScrollBarBackground:SetTexture("")
	B.StripTextures(KeyBindingFrame.categoryList)
	KeyBindingFrame.bindingsContainer:HideBackdrop()

	B.StripTextures(KeyBindingFrame)
	B.SetBD(KeyBindingFrame)
	B.Reskin(KeyBindingFrame.defaultsButton)
	B.Reskin(KeyBindingFrame.unbindButton)
	B.Reskin(KeyBindingFrame.okayButton)
	B.Reskin(KeyBindingFrame.cancelButton)
	B.ReskinCheck(KeyBindingFrame.characterSpecificButton)
	B.ReskinScroll(KeyBindingFrameScrollFrameScrollBar)
	KeyBindingFrameScrollFrame.scrollFrameScrollBarBackground:Hide()

	for i = 1, KEY_BINDINGS_DISPLAYED do
		local button1 = _G["KeyBindingFrameKeyBinding"..i.."Key1Button"]
		local button2 = _G["KeyBindingFrameKeyBinding"..i.."Key2Button"]
		button2:SetPoint("LEFT", button1, "RIGHT", 1, 0)
	end

	hooksecurefunc("BindingButtonTemplate_SetupBindingButton", function(_, button)
		if not button.styled then
			local selected = button.selectedHighlight
			selected:SetTexture(DB.bdTex)
			selected:SetPoint("TOPLEFT", C.MULT, -C.MULT)
			selected:SetPoint("BOTTOMRIGHT", -C.MULT, C.MULT)
			selected:SetColorTexture(r, g, b, .25)
			B.Reskin(button)

			button.styled = true
		end
	end)

	KeyBindingFrame.header.text:ClearAllPoints()
	KeyBindingFrame.header.text:SetPoint("TOP", KeyBindingFrame, "TOP", 0, -8)
	KeyBindingFrame.unbindButton:ClearAllPoints()
	KeyBindingFrame.unbindButton:SetPoint("BOTTOMRIGHT", -207, 16)
	KeyBindingFrame.okayButton:ClearAllPoints()
	KeyBindingFrame.okayButton:SetPoint("BOTTOMLEFT", KeyBindingFrame.unbindButton, "BOTTOMRIGHT", 1, 0)
	KeyBindingFrame.cancelButton:ClearAllPoints()
	KeyBindingFrame.cancelButton:SetPoint("BOTTOMLEFT", KeyBindingFrame.okayButton, "BOTTOMRIGHT", 1, 0)

	local line = KeyBindingFrame:CreateTexture(nil, "ARTWORK")
	line:SetSize(1, 546)
	line:SetPoint("LEFT", 205, 10)
	line:SetColorTexture(1, 1, 1, .2)
end