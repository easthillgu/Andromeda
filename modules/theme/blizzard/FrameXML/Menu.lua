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
tinsert(C.BlizzThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	if not Menu then return end

	local menuManagerProxy = Menu.GetManager()

	local backdrops = {}

	local function skinMenu(menuFrame)
		B.StripTextures(menuFrame)

		if backdrops[menuFrame] then
			menuFrame.bg = backdrops[menuFrame]
		else
			menuFrame.bg = B.SetBD(menuFrame)
			backdrops[menuFrame] = menuFrame.bg
		end

		if not menuFrame.ScrollBar.styled then
			B.ReskinTrimScroll(menuFrame.ScrollBar)
			menuFrame.ScrollBar.styled = true
		end

		for i = 1, menuFrame:GetNumChildren() do
			local child = select(i, menuFrame:GetChildren())

			local minLevel = child.MinLevel
			if minLevel and not minLevel.styled then
				B.ReskinEditBox(minLevel)
				minLevel.styled = true
			end

			local maxLevel = child.MaxLevel
			if maxLevel and not maxLevel.styled then
				B.ReskinEditBox(maxLevel)
				maxLevel.styled = true
			end
		end
	end

	local function setupMenu(manager, _, menuDescription)
		local menuFrame = manager:GetOpenMenu()
		if menuFrame then
			skinMenu(menuFrame)
			menuDescription:AddMenuAcquiredCallback(skinMenu)
		end
	end

	hooksecurefunc(menuManagerProxy, "OpenMenu", setupMenu)
	hooksecurefunc(menuManagerProxy, "OpenContextMenu", setupMenu)
end)