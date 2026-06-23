local F, C = unpack(select(2, ...))
local THEME = F:GetModule('Theme')

function THEME:ReskinWowLua()
    if not C_AddOns.IsAddOnLoaded('WowLua') then
        return
    end

    if not _G.ANDROMEDA_ADB.ReskinWowLua then
        return
    end

    if _G.WowLuaFrame then
        F.StripTextures(_G.WowLuaFrame)
        F.SetBD(_G.WowLuaFrame)
    end

    if _G.WowLuaFrameLineNumScrollFrame then
        F.StripTextures(_G.WowLuaFrameLineNumScrollFrame, true)
    end

    if _G.WowLuaFrameResizeBar then
        F.StripTextures(_G.WowLuaFrameResizeBar, true)
        _G.WowLuaFrameResizeBar:SetHeight(10)
    end

    if _G.WowLuaButton_Close then
        F.ReskinClose(_G.WowLuaButton_Close, _G.WowLuaFrame)
    end

    if _G.WowLuaFrameEditScrollFrameScrollBar then
        F.ReskinScroll(_G.WowLuaFrameEditScrollFrameScrollBar)
    end

    if _G.WowLuaButton_New and _G.WowLuaFrameToolbar then
        _G.WowLuaButton_New:SetPoint('LEFT', _G.WowLuaFrameToolbar, 'LEFT', 60, 0)
    end

    if _G.WowLuaFrameEditFocusGrabber then
        _G.WowLuaFrameEditFocusGrabber.bg1 = CreateFrame('Frame', nil, _G.WowLuaFrameEditFocusGrabber)
        F.SetBD(_G.WowLuaFrameEditFocusGrabber.bg1)
        _G.WowLuaFrameEditFocusGrabber.bg1:SetPoint('TOPLEFT', 0, 0)
        _G.WowLuaFrameEditFocusGrabber.bg1:SetPoint('BOTTOMRIGHT', 5, -5)
    end

    if _G.WowLuaFrameResizeBar then
        _G.WowLuaFrameResizeBar.bg1 = CreateFrame('Frame', nil, _G.WowLuaFrameResizeBar)
        F.SetBD(_G.WowLuaFrameResizeBar.bg1)
        _G.WowLuaFrameResizeBar.bg1:SetPoint('TOPLEFT', 6, -2)
        _G.WowLuaFrameResizeBar.bg1:SetPoint('BOTTOMRIGHT', -27, 0)
    end

    if _G.WowLuaFrameCommand then
        F.StripTextures(_G.WowLuaFrameCommand)
        _G.WowLuaFrameCommand.bg1 = CreateFrame('Frame', nil, _G.WowLuaFrameCommand)
        F.SetBD(_G.WowLuaFrameCommand.bg1)
        _G.WowLuaFrameCommand.bg1:SetPoint('TOPLEFT', 0, -4)
        _G.WowLuaFrameCommand.bg1:SetPoint('BOTTOMRIGHT', -12, 2)
    end

    local buttons = {
        _G.WowLuaButton_New,
        _G.WowLuaButton_Open,
        _G.WowLuaButton_Save,
        _G.WowLuaButton_Undo,
        _G.WowLuaButton_Redo,
        _G.WowLuaButton_Delete,
        _G.WowLuaButton_Lock,
        _G.WowLuaButton_Unlock,
        _G.WowLuaButton_Config,
        _G.WowLuaButton_Previous,
        _G.WowLuaButton_Next,
        _G.WowLuaButton_Run,
    }

    for _, button in pairs(buttons) do
        if button then
            F.CreateBDFrame(button)
            if button:GetNormalTexture() then
                F.ReskinIcon(button:GetNormalTexture())
            end
            if button:GetDisabledTexture() then
                F.ReskinIcon(button:GetDisabledTexture())
            end
        end
    end
end