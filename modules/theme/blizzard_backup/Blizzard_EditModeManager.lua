local F, C = unpack(select(2, ...))

C.Themes['Blizzard_EditModeManager'] = function()
    local EditModeManagerFrame = _G.EditModeManagerFrame

    if not EditModeManagerFrame then
        return
    end

    F.ReskinPortraitFrame(EditModeManagerFrame)
    F.ReskinButton(EditModeManagerFrame.RevertAllChangesButton)
    F.ReskinButton(EditModeManagerFrame.SaveChangesButton)
    F.ReskinButton(EditModeManagerFrame.ResetToDefaultButton)

    if EditModeManagerFrame.ScrollFrame then
        F.ReskinTrimScroll(EditModeManagerFrame.ScrollFrame.ScrollBar)
    end

    hooksecurefunc(EditModeManagerFrame.ScrollFrame.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if child and child.Button and not child.styled then
                F.ReskinButton(child.Button)
                child.styled = true
            end
        end
    end)

    if EditModeManagerFrame.LayoutSelector then
        F.ReskinDropdown(EditModeManagerFrame.LayoutSelector.DropDown)
    end

    if EditModeManagerFrame.RevertAllChangesButton then
        F.ReskinButton(EditModeManagerFrame.RevertAllChangesButton)
    end
end