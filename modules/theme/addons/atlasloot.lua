local F, C = unpack(select(2, ...))
local THEME = F:GetModule('Theme')

function THEME:ReskinAtlasLoot()
    if not C_AddOns.IsAddOnLoaded('AtlasLoot') then
        return
    end

    if not _G.ANDROMEDA_ADB.ReskinAtlasLoot then
        return
    end

    local function SkinTooltip(tooltip)
        if not tooltip then return end
        F.SetBD(tooltip)
        tooltip:HookScript('OnShow', function(self)
            local Link = select(2, self:GetItem())
            local Quality = Link and select(3, GetItemInfo(Link))
            if Quality and Quality >= 2 then
                local r, g, b = GetItemQualityColor(Quality)
                self:SetBackdropBorderColor(r, g, b)
            else
                F.SetBorderColor(self)
            end
            self:SetBackdropColor(C.General.BackdropColor.r, C.General.BackdropColor.g, C.General.BackdropColor.b, C.General.BackdropAlpha)
        end)
    end

    SkinTooltip(_G.AtlasLootTooltip)

    local AtlasLootFrame = _G["AtlasLoot_GUI-Frame"]
    if AtlasLootFrame then
        F.StripTextures(AtlasLootFrame)
        F.SetBD(AtlasLootFrame)
        F.ReskinClose(AtlasLootFrame.CloseButton)
        F.StripTextures(AtlasLootFrame.titleFrame)
    end

    local function SkinDropDown(frameName)
        local frame = _G[frameName]
        if not frame then return end

        F.SetBD(frame)
        F.ReskinArrow(_G[frameName..'-button'])

        frame:HookScript('OnUpdate', function(self)
            for i = 1, 3 do
                local CatFrame = _G['AtlasLoot-DropDown-CatFrame'..i]
                if CatFrame and not CatFrame.IsSkinned then
                    local r, g, b = CatFrame:GetBackdropColor()
                    F.SetBD(CatFrame)
                    CatFrame:SetBackdropColor(r, g, b)

                    CatFrame:HookScript('OnShow', function(self)
                        local a, f, c, d, e = self:GetPoint()
                        self:SetPoint(a, f, c, d, e - 3)
                    end)

                    CatFrame:GetScript('OnShow')(CatFrame)
                    CatFrame.IsSkinned = true
                end
            end
        end)
    end

    SkinDropDown('AtlasLoot-DropDown-1')
    SkinDropDown('AtlasLoot-DropDown-2')

    for i = 1, 3 do
        local selectFrame = _G['AtlasLoot-Select-'..i]
        if selectFrame then
            F.SetBD(selectFrame)
        end
    end

    local AtlasLootItemFrame = _G["AtlasLoot_GUI-ItemFrame"]
    if AtlasLootItemFrame then
        F.CreateBDFrame(AtlasLootItemFrame)
        F.ReskinArrow(AtlasLootItemFrame.nextPageButton)
        F.ReskinButton(AtlasLootItemFrame.modelButton)
        F.ReskinButton(AtlasLootItemFrame.soundsButton)
        F.ReskinArrow(AtlasLootItemFrame.prevPageButton)
        F.ReskinButton(AtlasLootItemFrame.itemsButton)
        F.ReskinButton(AtlasLootItemFrame.clasFilterButton)

        AtlasLootItemFrame.clasFilterButton:HookScript('OnUpdate', function(self)
            if self.texture:GetTexture() == "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes" then
                self.texture:SetTexCoord(CLASS_ICON_TCOORDS[C.MY_CLASS][1] + 0.015, CLASS_ICON_TCOORDS[C.MY_CLASS][2] - 0.02, CLASS_ICON_TCOORDS[C.MY_CLASS][3] + 0.018, CLASS_ICON_TCOORDS[C.MY_CLASS][4] - .02)
            end
        end)
    end
end