local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local KEY_LABELS = {
    RightShift   = "RShift",  LeftShift    = "LShift",
    RightControl = "RCtrl",   LeftControl  = "LCtrl",
    RightAlt     = "RAlt",    LeftAlt      = "LAlt",
    Return       = "Enter",   BackSpace    = "Bksp",
    CapsLock     = "Caps",    Delete       = "Del",
    Insert       = "Ins",     PageUp       = "PgUp",
    PageDown     = "PgDn",    Space        = "Space",
    Up           = "↑",       Down         = "↓",
    Left         = "←",       Right        = "→",
    F1="F1", F2="F2", F3="F3",  F4="F4",
    F5="F5", F6="F6", F7="F7",  F8="F8",
    F9="F9", F10="F10", F11="F11", F12="F12",
}

local EMPTY_KEYS = { None = true, [""] = true }
local SIZE_FULL  = UDim2.new(0, 100, 0, 26)
local SIZE_SMALL = UDim2.new(0, 28,  0, 26)  -- cuma kotak kecil kosong

local function getKeyLabel(keyName)
    return KEY_LABELS[keyName] or keyName
end

local function isEmpty(keyName)
    return keyName == nil or EMPTY_KEYS[keyName] == true
end

local KeybindModule = {}

function KeybindModule:CreateKeybind(SectionAdd, KeybindConfig, CountItem, Elements)
    KeybindConfig = KeybindConfig or {}
    KeybindConfig.Title    = KeybindConfig.Title    or "Keybind"
    KeybindConfig.Content  = KeybindConfig.Content  or ""
    KeybindConfig.Value    = KeybindConfig.Value    or "None"
    KeybindConfig.Flag     = KeybindConfig.Flag     or nil
    KeybindConfig.Callback = KeybindConfig.Callback or function() end

    -- ==================== OUTER FRAME ====================
    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    KeybindFrame.BackgroundTransparency = 0.935
    KeybindFrame.BorderSizePixel = 0
    KeybindFrame.Size = UDim2.new(1, 0, 0, 38)
    KeybindFrame.LayoutOrder = CountItem
    KeybindFrame.Name = "KeybindFrame"
    KeybindFrame.Parent = SectionAdd

    Instance.new("UICorner", KeybindFrame).CornerRadius = UDim.new(0, 4)

    -- ==================== TITLE ====================
    local KBTitle = Instance.new("TextLabel")
    KBTitle.Font = Enum.Font.GothamBold
    KBTitle.Text = KeybindConfig.Title
    KBTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    KBTitle.TextSize = 13
    KBTitle.TextXAlignment = Enum.TextXAlignment.Left
    KBTitle.TextYAlignment = Enum.TextYAlignment.Top
    KBTitle.BackgroundTransparency = 1
    KBTitle.BorderSizePixel = 0
    KBTitle.Position = UDim2.new(0, 10, 0, 10)
    KBTitle.Size = UDim2.new(1, -180, 0, 13)
    KBTitle.Name = "KBTitle"
    KBTitle.Parent = KeybindFrame

    -- ==================== CONTENT ====================
    local KBContent = Instance.new("TextLabel")
    KBContent.Font = Enum.Font.GothamBold
    KBContent.Text = KeybindConfig.Content
    KBContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    KBContent.TextSize = 12
    KBContent.TextTransparency = 0.6
    KBContent.TextXAlignment = Enum.TextXAlignment.Left
    KBContent.TextYAlignment = Enum.TextYAlignment.Bottom
    KBContent.BackgroundTransparency = 1
    KBContent.Position = UDim2.new(0, 10, 0, 25)
    KBContent.Size = UDim2.new(1, -180, 0, 12)
    KBContent.Name = "KBContent"
    KBContent.Parent = KeybindFrame

    -- ==================== INPUT FRAME ====================
    local initialSize = isEmpty(KeybindConfig.Value) and SIZE_SMALL or SIZE_FULL

    local InputFrame = Instance.new("Frame")
    InputFrame.AnchorPoint = Vector2.new(1, 0.5)
    InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InputFrame.BackgroundTransparency = 0.95
    InputFrame.BorderSizePixel = 0
    InputFrame.ClipsDescendants = true
    InputFrame.Position = UDim2.new(1, -7, 0.5, 0)
    InputFrame.Size = initialSize
    InputFrame.Name = "InputFrame"
    InputFrame.Parent = KeybindFrame

    Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 4)

    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(255, 255, 255)
    InputStroke.Thickness = 1
    InputStroke.Transparency = 0.85
    InputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    InputStroke.Parent = InputFrame

    -- Teks key, center
    local KeyLabel = Instance.new("TextLabel")
    KeyLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    KeyLabel.Font = Enum.Font.GothamBold
    KeyLabel.Text = isEmpty(KeybindConfig.Value) and "" or getKeyLabel(KeybindConfig.Value)
    KeyLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    KeyLabel.TextSize = 11
    KeyLabel.TextXAlignment = Enum.TextXAlignment.Center
    KeyLabel.TextYAlignment = Enum.TextYAlignment.Center
    KeyLabel.BackgroundTransparency = 1
    KeyLabel.BorderSizePixel = 0
    KeyLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    KeyLabel.Size = UDim2.new(1, 0, 1, 0)
    KeyLabel.Name = "KeyLabel"
    KeyLabel.Parent = InputFrame

    local ClickBtn = Instance.new("TextButton")
    ClickBtn.Text = ""
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.AutoButtonColor = false
    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    ClickBtn.ZIndex = 5
    ClickBtn.Name = "ClickBtn"
    ClickBtn.Parent = InputFrame

    -- ==================== LOGIC ====================
    local currentKey  = KeybindConfig.Value
    local listening   = false
    local listenConn  = nil
    local triggerConn = nil

    -- Resize InputFrame berdasarkan apakah key kosong atau tidak
    local function updateSize(animate)
        local targetSize = isEmpty(currentKey) and SIZE_SMALL or SIZE_FULL
        if animate then
            TweenService:Create(InputFrame,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = targetSize }
            ):Play()
        else
            InputFrame.Size = targetSize
        end
    end

    local function updateLabel()
        if isEmpty(currentKey) then
            KeyLabel.Text = ""
        else
            KeyLabel.Text = getKeyLabel(currentKey)
        end
        updateSize(true)
    end

    local function setListeningVisual(state)
        if state then
            KeyLabel.Text = "..."
            KeyLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
            -- Saat listening selalu tunjukkan ukuran penuh
            TweenService:Create(InputFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = SIZE_FULL,
                BackgroundTransparency = 0.88
            }):Play()
            TweenService:Create(InputStroke, TweenInfo.new(0.15), {
                Color = Color3.fromRGB(0, 208, 255),
                Transparency = 0.35
            }):Play()
        else
            KeyLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            updateLabel()  -- ini juga update size
            TweenService:Create(InputFrame, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.95
            }):Play()
            TweenService:Create(InputStroke, TweenInfo.new(0.15), {
                Color = Color3.fromRGB(255, 255, 255),
                Transparency = 0.85
            }):Play()
        end
    end

    local function updateTriggerListener()
        if triggerConn then
            triggerConn:Disconnect()
            triggerConn = nil
        end
        if isEmpty(currentKey) then return end
        triggerConn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode.Name == currentKey then
                    pcall(KeybindConfig.Callback, currentKey)
                end
            end
        end)
    end

    local function cancelListening()
        if listenConn then
            listenConn:Disconnect()
            listenConn = nil
        end
        listening = false
        setListeningVisual(false)
    end

    updateTriggerListener()

    -- ==================== HOVER ====================
    ClickBtn.MouseEnter:Connect(function()
        if listening then return end
        TweenService:Create(InputFrame, TweenInfo.new(0.15), {
            BackgroundTransparency = 0.9
        }):Play()
        TweenService:Create(InputStroke, TweenInfo.new(0.15), {
            Transparency = 0.6
        }):Play()
    end)

    ClickBtn.MouseLeave:Connect(function()
        if listening then return end
        TweenService:Create(InputFrame, TweenInfo.new(0.15), {
            BackgroundTransparency = 0.95
        }):Play()
        TweenService:Create(InputStroke, TweenInfo.new(0.15), {
            Transparency = 0.85
        }):Play()
    end)

    -- ==================== CLICK ====================
    ClickBtn.MouseButton1Click:Connect(function()
        if listening then
            cancelListening()
            return
        end

        listening = true
        setListeningVisual(true)

        listenConn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

            local keyName = input.KeyCode.Name

            -- Escape = clear key (set kosong)
            if keyName == "Escape" then
                listenConn:Disconnect()
                listenConn = nil
                currentKey = "None"
                listening = false
                setListeningVisual(false)
                updateTriggerListener()
                return
            end

            currentKey = keyName
            listenConn:Disconnect()
            listenConn = nil
            listening = false
            setListeningVisual(false)
            updateTriggerListener()
        end)
    end)

    -- ==================== PUBLIC API ====================
    local KeybindFunc = {}

    function KeybindFunc:Set(value, silent)
        currentKey = (value == nil or value == "") and "None" or value
        updateLabel()
        updateTriggerListener()
        if not silent then
            pcall(KeybindConfig.Callback, currentKey)
        end
    end

    function KeybindFunc:Get()
        return currentKey
    end

    function KeybindFunc:Clear(silent)
        KeybindFunc:Set("None", silent)
    end

    function KeybindFunc:Destroy()
        if listenConn  then listenConn:Disconnect()  end
        if triggerConn then triggerConn:Disconnect() end
        listenConn  = nil
        triggerConn = nil
        KeybindFrame:Destroy()
    end

    if KeybindConfig.Flag and Elements then
        Elements[KeybindConfig.Flag] = KeybindFunc
    end

    return KeybindFunc
end

return KeybindModule
