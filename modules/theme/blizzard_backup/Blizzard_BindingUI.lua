local F, C = unpack(select(2, ...))

C.Themes['Blizzard_BindingUI'] = function()
    return  -- [3.80.1 DISABLED: all frames missing]
    local KeyBindingFrame = _G.KeyBindingFrame

    F.StripTextures(KeyBindingFrame.header)
    F.StripTextures(KeyBindingFrame.scrollFrame)
    F.StripTextures(KeyBindingFrame.categoryList)
    F.StripTextures(KeyBindingFrame.bindingsContainer)

    F.ReskinPortraitFrame(KeyBindingFrame)
    F.ReskinButton(KeyBindingFrame.defaultsButton)
    F.ReskinButton(KeyBindingFrame.unbindButton)
    F.ReskinButton(KeyBindingFrame.okayButton)
    F.ReskinButton(KeyBindingFrame.cancelButton)
    F.ReskinCheckbox(KeyBindingFrame.characterSpecificButton)
    F.ReskinTrimScroll(KeyBindingFrameScrollFrameScrollBar)

    for i = 1, _G.KEY_BINDINGS_DISPLAYED do
        local button1 = _G['KeyBindingFrameKeyBinding' .. i .. 'Key1Button']
        local button2 = _G['KeyBindingFrameKeyBinding' .. i .. 'Key2Button']
        button2:SetPoint('LEFT', button1, 'RIGHT', 1, 0)
    end

    hooksecurefunc('BindingButtonTemplate_SetupBindingButton', function(_, button)
        if not button.styled then
            F.ReskinButton(button)
            local selected = button.selectedHighlight
            selected:SetColorTexture(C.r, C.g, C.b, 0.25)
            selected:SetInside()

            button.styled = true
        end
    end)

    local line = KeyBindingFrame:CreateTexture(nil, 'ARTWORK')
    line:SetSize(1, 546)
    line:SetPoint('LEFT', 205, 10)
    line:SetColorTexture(1, 1, 1, 0.2)
end