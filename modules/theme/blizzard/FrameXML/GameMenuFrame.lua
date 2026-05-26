local F, C = unpack(select(2, ...))

local function HideAllTextures(frame)
    if not frame or not frame.GetRegions then return end
    
    local regions = {frame:GetRegions()}
    for _, region in ipairs(regions) do
        if region then
            local objType = region.GetObjectType and region:GetObjectType()
            if objType ~= 'FontString' then
                region:Hide()
                region:SetAlpha(0)
                if region.SetTexture then
                    region:SetTexture(nil)
                end
            end
        end
    end
end

local function AddHoverEffects(frame)
    if not frame or not frame.SetScript then return end
    
    local highlight = frame:CreateTexture(nil, 'HIGHLIGHT')
    highlight:SetColorTexture(C.r, C.g, C.b, 0.2)
    highlight:SetAllPoints()
    
    local pushed = frame:CreateTexture(nil, 'PUSHED')
    pushed:SetColorTexture(0, 0, 0, 0.3)
    pushed:SetAllPoints()
end

local function ReskinButtonDirectly(button)
    if not button then return end
    
    HideAllTextures(button)
    
    if button.SetNormalTexture then button:SetNormalTexture('') end
    if button.SetHighlightTexture then button:SetHighlightTexture('') end
    if button.SetPushedTexture then button:SetPushedTexture('') end
    if button.SetDisabledTexture then button:SetDisabledTexture('') end
    
    local bg = F.CreateBDFrame(button, 0.25)
    bg:SetAllPoints()
    
    F.SetBorderColor(bg)
    
    F.CreateTex(button)
    
    local gradStyle = _G.ANDROMEDA_ADB.GradientStyle
    local color = _G.ANDROMEDA_ADB.ButtonBackdropColor
    local alpha = _G.ANDROMEDA_ADB.ButtonBackdropAlpha
    
    if gradStyle then
        button.__gradient:SetGradient('Vertical', CreateColor(color.r, color.g, color.b, alpha), CreateColor(0, 0, 0, 0.25))
    else
        button.__gradient:SetVertexColor(color.r, color.g, color.b, alpha)
    end
    
    AddHoverEffects(button)
end

local function IsButtonLike(frame)
    if not frame then return false end
    
    if frame.GetObjectType and frame:GetObjectType() == 'Button' then
        return true
    end
    
    if frame.SetText and frame.GetText then
        return true
    end
    
    return false
end

local function StyleGameMenu()
    local GameMenuFrame = _G.GameMenuFrame
    if not GameMenuFrame then return end

    pcall(F.SetBD, GameMenuFrame)

    if GameMenuFrame.Header then
        pcall(F.StripTextures, GameMenuFrame.Header)
    end

    if GameMenuFrame.Border then
        GameMenuFrame.Border:Hide()
    end

    local buttonHeight = 28
    local buttonGap = 4
    local allButtons = {}
    local andromedaButton = nil
    
    local children = {GameMenuFrame:GetChildren()}
    for _, child in ipairs(children) do
        if child and child:IsShown() then
            local name = child.GetName and child:GetName()
            if name == 'GameMenuButtonAndromedaUI' then
                andromedaButton = child
            elseif IsButtonLike(child) then
                tinsert(allButtons, child)
            end
        end
    end
    
    -- 找到最后一个按钮（按顶部位置排序，找最低的）
    local lastButton = nil
    local lowestTopY = 0
    local frameTop = GameMenuFrame.GetTop and GameMenuFrame:GetTop() or 0
    
    for _, button in ipairs(allButtons) do
        if button.GetTop then
            local top = button:GetTop()
            if top and frameTop then
                local topY = top - frameTop
                if topY < lowestTopY then
                    lowestTopY = topY
                    lastButton = button
                end
            end
        end
    end
    
    -- 为 Andromeda 按钮计算位置（在最后一个按钮上方）
    if andromedaButton and lastButton then
        pcall(function()
            local buttonWidth = lastButton:GetWidth()
            local andromedaY = lowestTopY - buttonHeight - buttonGap
            
            andromedaButton:ClearAllPoints()
            andromedaButton:SetPoint('TOPLEFT', GameMenuFrame, 16, andromedaY)
            andromedaButton:SetSize(buttonWidth, buttonHeight)
        end)
    end
    
    -- 美化其他按钮
    for _, button in ipairs(allButtons) do
        pcall(ReskinButtonDirectly, button)
    end
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:SetScript('OnEvent', function(self, event)
    self:UnregisterEvent(event)
    
    local GameMenuFrame = _G.GameMenuFrame
    if GameMenuFrame then
        GameMenuFrame:HookScript('OnShow', StyleGameMenu)
        
        if GameMenuFrame:IsShown() then
            StyleGameMenu()
        end
    end
end)