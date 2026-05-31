local F, C = unpack(select(2, ...))

C.Themes['Blizzard_ItemSocketingUI'] = function()
    local GemTypeInfo = {
        Yellow = { r = 0.97, g = 0.82, b = 0.29 },
        Red = { r = 1, g = 0.47, b = 0.47 },
        Blue = { r = 0.47, g = 0.67, b = 1 },
        Hydraulic = { r = 1, g = 1, b = 1 },
        Cogwheel = { r = 1, g = 1, b = 1 },
        Meta = { r = 1, g = 1, b = 1 },
        Prismatic = { r = 1, g = 1, b = 1 },
        PunchcardRed = { r = 1, g = 0.47, b = 0.47 },
        PunchcardYellow = { r = 0.97, g = 0.82, b = 0.29 },
        PunchcardBlue = { r = 0.47, g = 0.67, b = 1 },
        Domination = { r = 0.24, g = 0.5, b = 0.7 },
        Cypher = { r = 1, g = 0.8, b = 0 },
        Tinker = { r = 1, g = 0.47, b = 0.47 },
        Primordial = { r = 1, g = 0, b = 1 },
    }

    for i = 1, _G.MAX_NUM_SOCKETS do
        local socket = _G['ItemSocketingSocket' .. i]
        local shine = _G['ItemSocketingSocket' .. i .. 'Shine']

        -- 添加安全检查
        if not socket then
            break
        end
        
        F.StripTextures(socket)
        if socket.SetPushedTexture then
            socket:SetPushedTexture(0)
        end
        if socket.GetHighlightTexture then
            local highlight = socket:GetHighlightTexture()
            if highlight then
                highlight:SetColorTexture(1, 1, 1, 0.25)
            end
        end
        if socket.icon and socket.icon.SetTexCoord then
            socket.icon:SetTexCoord(unpack(C.TEX_COORD))
            socket.bg = F.ReskinIcon(socket.icon)
        end

        if shine then
            shine:ClearAllPoints()
            if shine.SetOutside then
                shine:SetOutside()
            end
        end
        if socket.BracketFrame then
            socket.BracketFrame:Hide()
        end
        if socket.Background then
            socket.Background:SetAlpha(0)
        end
    end

    hooksecurefunc('ItemSocketingFrame_Update', function()
        -- 检查 Sockets 是否存在
        if _G.ItemSocketingFrame and _G.ItemSocketingFrame.Sockets then
            for i, socket in ipairs(_G.ItemSocketingFrame.Sockets) do
                if not socket or not socket:IsShown() then
                    break
                end

                local color = GemTypeInfo[_G.GetSocketTypes(i)] or GemTypeInfo.Cogwheel
                if socket.bg and socket.bg.SetBackdropBorderColor then
                    socket.bg:SetBackdropBorderColor(color.r, color.g, color.b)
                end
            end
        end

        if _G.ItemSocketingDescription and _G.ItemSocketingDescription.HideBackdrop then
            _G.ItemSocketingDescription:HideBackdrop()
        end
    end)

    if _G.ItemSocketingFrame then
        F.ReskinPortraitFrame(_G.ItemSocketingFrame)
        if _G.ItemSocketingFrame.BackgroundColor then
            _G.ItemSocketingFrame.BackgroundColor:SetAlpha(0)
        end
    end
    
    if _G.ItemSocketingScrollFrame then
        F.CreateBDFrame(_G.ItemSocketingScrollFrame, 0.25)
        if C.IS_NEW_PATCH_10_1 and _G.ItemSocketingScrollFrame.ScrollBar then
            F.ReskinTrimScroll(_G.ItemSocketingScrollFrame.ScrollBar)
        else
            local scrollBar = _G.ItemSocketingScrollFrameScrollBar
            if scrollBar then
                F.ReskinScroll(scrollBar)
            end
        end
    end
    
    if _G.ItemSocketingSocketButton then
        F.ReskinButton(_G.ItemSocketingSocketButton)
    end
end
