local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Elements = {}
local SaveConfig, ConfigData, GuiConfig, Icons
function Elements:Initialize(config, saveFunc, configData, icons)
    GuiConfig = config
    SaveConfig = saveFunc
    ConfigData = configData
    Icons = icons
end
local function GetIconId(iconName)
    if not iconName or iconName == "" then return "" end
    if iconName:match("^rbxassetid://") then return iconName end
    if iconName:match("^https?://") then return iconName end
    if iconName:match("^%d+$") then return "rbxassetid://" .. iconName end
    if Icons and Icons[iconName] then return Icons[iconName] end
    return ""
end
function Elements:GetIconId(iconName)
    return GetIconId(iconName)
end

-- Helper: resolve configKey from Flag or fallback to "Prefix_Title"
local function ResolveKey(prefix, cfg)
    if cfg.Flag and cfg.Flag ~= "" then
        return cfg.Flag
    end
    return prefix .. "_" .. cfg.Title
end

local BADGE_CONFIG = {
    New = {
        Text  = "NEW",
        Color = nil,
        Pulse = "glow",
        Dot   = true,
    },
    Warning = {
        Text  = "WARNING",
        Color = Color3.fromRGB(255, 165, 0),
        Pulse = "glow",
        Dot   = true,
    },
    Bug = {
        Text  = "BUG",
        Color = Color3.fromRGB(220, 50, 50),
        Pulse = "glow",
        Dot   = true,
    },
    Fixed = {
        Text  = "FIXED",
        Color = Color3.fromRGB(50, 200, 80),
        Pulse = "none",
        Dot   = false,
    },
    Beta = {
        Text  = "BETA",
        Color = Color3.fromRGB(140, 80, 255),
        Pulse = "none",
        Dot   = false,
    },
    Hot = {
        Text  = "HOT",
        Color = Color3.fromRGB(255, 80, 80),
        Pulse = "glow",
        Dot   = true,
    },
    Soon = {
        Text  = "SOON",
        Color = Color3.fromRGB(100, 160, 255),
        Pulse = "none",
        Dot   = false,
    },
}
local function ApplyLock(frame, isLocked, lockMessage)
    local LockFunc = { IsLocked = isLocked == true }
    local msg = lockMessage or "Locked"
    local _pillBaseW = 90
    local _destroyed = false
    local _rebuilding = false
    local LockOverlay

    local function BuildOverlay()
        if _destroyed then return end

        LockOverlay = Instance.new("TextButton")
        LockOverlay.Name = "LockOverlay"
        LockOverlay.Text = ""
        LockOverlay.Size = UDim2.new(1, 0, 1, 0)
        LockOverlay.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
        LockOverlay.BackgroundTransparency = 0.35
        LockOverlay.BorderSizePixel = 0
        LockOverlay.ZIndex = 10
        LockOverlay.AutoButtonColor = false
        LockOverlay.ClipsDescendants = true
        LockOverlay.Visible = LockFunc.IsLocked
        LockOverlay.Parent = frame
        Instance.new("UICorner", LockOverlay).CornerRadius = UDim.new(0, 6)

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Thickness = 1
        Stroke.Transparency = 0.82
        Stroke.Parent = LockOverlay

        local Pill = Instance.new("Frame")
        Pill.Name = "LockPill"
        Pill.AnchorPoint = Vector2.new(0.5, 0.5)
        Pill.Position = UDim2.new(0.5, 0, 0.5, 0)
        Pill.Size = UDim2.new(0, _pillBaseW, 0, 22)
        Pill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Pill.BackgroundTransparency = 0.88
        Pill.BorderSizePixel = 0
        Pill.ZIndex = 11
        Pill.Parent = LockOverlay
        Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)

        local PillStroke = Instance.new("UIStroke")
        PillStroke.Color = Color3.fromRGB(255, 255, 255)
        PillStroke.Thickness = 1
        PillStroke.Transparency = 0.7
        PillStroke.Parent = Pill

        local LockIcon = Instance.new("ImageLabel")
        LockIcon.Name = "LockIcon"
        LockIcon.Size = UDim2.new(0, 12, 0, 12)
        LockIcon.AnchorPoint = Vector2.new(0, 0.5)
        LockIcon.Position = UDim2.new(0, 8, 0.5, 0)
        LockIcon.BackgroundTransparency = 1
        LockIcon.ScaleType = Enum.ScaleType.Fit
        LockIcon.Image = "rbxassetid://134724289526879"
        LockIcon.ImageColor3 = Color3.fromRGB(220, 220, 220)
        LockIcon.ImageTransparency = 0.1
        LockIcon.ZIndex = 12
        LockIcon.Parent = Pill

        local LockLabel = Instance.new("TextLabel")
        LockLabel.Name = "LockLabel"
        LockLabel.AnchorPoint = Vector2.new(0, 0.5)
        LockLabel.Position = UDim2.new(0, 24, 0.5, 0)
        LockLabel.Size = UDim2.new(1, -28, 1, 0)
        LockLabel.BackgroundTransparency = 1
        LockLabel.Font = Enum.Font.GothamBold
        LockLabel.Text = msg
        LockLabel.TextSize = 11
        LockLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        LockLabel.TextTransparency = 0.1
        LockLabel.TextXAlignment = Enum.TextXAlignment.Left
        LockLabel.TextTruncate = Enum.TextTruncate.AtEnd
        LockLabel.ZIndex = 12
        LockLabel.Parent = Pill

        local function UpdatePillWidth()
            task.wait()
            if not LockLabel.Parent then return end
            local textW = LockLabel.TextBounds.X
            local newW = math.max(60, textW + 38)
            Pill.Size = UDim2.new(0, newW, 0, 22)
            _pillBaseW = newW
        end
        LockLabel:GetPropertyChangedSignal("TextBounds"):Connect(UpdatePillWidth)
        task.defer(UpdatePillWidth)

        LockOverlay.MouseButton1Click:Connect(function()
            if not Pill.Parent then return end
            TweenService:Create(Pill, TweenInfo.new(0.08, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, _pillBaseW + 6, 0, 26)
            }):Play()
            task.delay(0.2, function()
                if not Pill.Parent then return end
                TweenService:Create(Pill, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, _pillBaseW, 0, 22)
                }):Play()
            end)
        end)

        function LockFunc:SetMessage(text)
            msg = tostring(text or "Locked")
            LockLabel.Text = msg
            UpdatePillWidth()
        end
    end

    BuildOverlay()

    frame.DescendantRemoving:Connect(function(desc)
        if desc == LockOverlay and LockFunc.IsLocked and not _destroyed then
            if _rebuilding then return end
            _rebuilding = true
            task.defer(function()
                BuildOverlay()
                _rebuilding = false
            end)
        end
    end)

    frame.AncestryChanged:Connect(function(_, newParent)
        if newParent == nil then
            _destroyed = true
        end
    end)

    local function SetVisible(state)
        LockFunc.IsLocked = state
        if LockOverlay and LockOverlay.Parent then
            LockOverlay.Visible = state
        end
    end
    SetVisible(LockFunc.IsLocked)

    function LockFunc:SetLocked(state)
        SetVisible(state == true)
        if state and (not LockOverlay or not LockOverlay.Parent) then
            BuildOverlay()
        end
    end

    function LockFunc:GetLocked()
        return LockFunc.IsLocked
    end

    return LockFunc
end
local function CreateBadge(parent, badgeType)
    local preset = BADGE_CONFIG[badgeType]
    if not preset then
        warn("[Elements] CreateBadge: unknown type '" .. tostring(badgeType) .. "'")
        return nil
    end
    local color = preset.Color or GuiConfig.Color
    local Badge = Instance.new("Frame")
    Badge.Name = badgeType .. "Badge"
    Badge.AnchorPoint = Vector2.new(1, 0)
    Badge.Position = UDim2.new(1, -6, 0, 6)
    Badge.Size = UDim2.new(0, 10, 0, 18)
    Badge.BackgroundColor3 = color
    Badge.BackgroundTransparency = 0.78
    Badge.BorderSizePixel = 0
    Badge.ZIndex = 5
    Badge.ClipsDescendants = false
    Badge.Parent = parent
    Instance.new("UICorner", Badge).CornerRadius = UDim.new(1, 0)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = color
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    Stroke.Parent = Badge
    local DOT_W = preset.Dot and 14 or 0
    local BadgeText = Instance.new("TextLabel")
    BadgeText.Name = "BadgeText"
    BadgeText.BackgroundTransparency = 1
    BadgeText.Font = Enum.Font.GothamBold
    BadgeText.Text = preset.Text
    BadgeText.TextColor3 = color
    BadgeText.TextTransparency = 0.05
    BadgeText.TextSize = 9
    BadgeText.TextXAlignment = Enum.TextXAlignment.Left
    BadgeText.AnchorPoint = Vector2.new(0, 0.5)
    BadgeText.Position = UDim2.new(0, DOT_W + 6, 0.5, 0)
    BadgeText.Size = UDim2.new(1, -(DOT_W + 10), 1, 0)
    BadgeText.ZIndex = 6
    BadgeText.Parent = Badge
    if preset.Dot then
        local Dot = Instance.new("Frame")
        Dot.Name = "BadgeDot"
        Dot.Size = UDim2.new(0, 5, 0, 5)
        Dot.AnchorPoint = Vector2.new(0, 0.5)
        Dot.Position = UDim2.new(0, 6, 0.5, 0)
        Dot.BackgroundColor3 = color
        Dot.BackgroundTransparency = 0
        Dot.BorderSizePixel = 0
        Dot.ZIndex = 7
        Dot.Parent = Badge
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    end
    local function UpdateBadgeWidth()
        task.wait()
        if not BadgeText.Parent then return end
        local textW = BadgeText.TextBounds.X
        local totalW = textW + DOT_W + 14
        Badge.Size = UDim2.new(0, totalW, 0, 18)
    end
    BadgeText:GetPropertyChangedSignal("TextBounds"):Connect(UpdateBadgeWidth)
    task.defer(UpdateBadgeWidth)
    if preset.Pulse == "glow" then
        local pulseIn = TweenService:Create(Stroke,
            TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { Transparency = 0.1 })
        local pulseOut = TweenService:Create(Stroke,
            TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { Transparency = 0.6 })
        pulseIn.Completed:Connect(function() pulseOut:Play() end)
        pulseOut.Completed:Connect(function() pulseIn:Play() end)
        pulseIn:Play()
        local dotInst = Badge:FindFirstChild("BadgeDot")
        if dotInst then
            local dIn = TweenService:Create(dotInst,
                TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { BackgroundTransparency = 0.5 })
            local dOut = TweenService:Create(dotInst,
                TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { BackgroundTransparency = 0 })
            dIn.Completed:Connect(function() dOut:Play() end)
            dOut.Completed:Connect(function() dIn:Play() end)
            dIn:Play()
        end
    end
    return Badge
end
function Elements:CreateBadge(parent, badgeType)
    return CreateBadge(parent, badgeType)
end
local _activeTweens = {}
local function AnimateButtonClick(button, color)
    color = color or GuiConfig.Color
    if not button:GetAttribute("_origTrans") then
        button:SetAttribute("_origTrans", button.BackgroundTransparency)
    end
    if not button:GetAttribute("_origColorR") then
        local c = button.BackgroundColor3
        button:SetAttribute("_origColorR", c.R)
        button:SetAttribute("_origColorG", c.G)
        button:SetAttribute("_origColorB", c.B)
    end
    local origTrans = button:GetAttribute("_origTrans")
    local origColor = Color3.new(
        button:GetAttribute("_origColorR"),
        button:GetAttribute("_origColorG"),
        button:GetAttribute("_origColorB")
    )
    if _activeTweens[button] then
        _activeTweens[button]:Cancel()
        _activeTweens[button] = nil
    end
    local tweenIn = TweenService:Create(button,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { BackgroundTransparency = 0.7, BackgroundColor3 = color }
    )
    local tweenOut = TweenService:Create(button,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { BackgroundTransparency = origTrans, BackgroundColor3 = origColor }
    )
    _activeTweens[button] = tweenIn
    tweenIn.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            _activeTweens[button] = tweenOut
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                _activeTweens[button] = nil
            end)
        end
    end)
    tweenIn:Play()
end
local function SafeCall(fn, ...)
    if typeof(fn) ~= "function" then return end
    local ok, err = pcall(fn, ...)
    if not ok then warn("[Elements] Callback error:", err) end
end
local function RoundToFactor(value, factor)
    if factor == 0 then return value end
    return math.floor(value / factor + 0.5) * factor
end
function Elements:CreateParagraph(parent, config, countItem)
    local cfg = config or {}
    cfg.Title      = cfg.Title      or "Title"
    cfg.Content    = cfg.Content    or "Content"
    cfg.Badge      = cfg.Badge      or nil
    cfg.Color      = cfg.Color      or nil
    cfg.Locked     = cfg.Locked     or false
    cfg.MediaType  = cfg.MediaType  or nil
    cfg.MediaId    = cfg.MediaId    or nil
    cfg.VideoId    = cfg.VideoId    or nil
    cfg.MediaWidth  = cfg.MediaWidth  or 80
    cfg.MediaHeight = cfg.MediaHeight or 60
    cfg.AutoPlay   = cfg.AutoPlay   or false
    local ParagraphFunc = {}
    local Paragraph = Instance.new("Frame")
    Paragraph.Name = "Paragraph"
    Paragraph.BorderSizePixel = 0
    Paragraph.LayoutOrder = countItem
    Paragraph.Size = UDim2.new(1, 0, 0, 56)
    Paragraph.ClipsDescendants = true
    Paragraph.Parent = parent
    if cfg.Color then
        Paragraph.BackgroundColor3 = cfg.Color
        Paragraph.BackgroundTransparency = 0.88
        local AccentBar = Instance.new("Frame")
        AccentBar.Name = "AccentBar"
        AccentBar.Size = UDim2.new(0, 3, 1, -10)
        AccentBar.Position = UDim2.new(0, 4, 0, 5)
        AccentBar.BackgroundColor3 = cfg.Color
        AccentBar.BackgroundTransparency = 0
        AccentBar.BorderSizePixel = 0
        AccentBar.ZIndex = 2
        AccentBar.Parent = Paragraph
        Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(1, 0)
        local AccentGlow = Instance.new("UIStroke")
        AccentGlow.Color = cfg.Color
        AccentGlow.Thickness = 1
        AccentGlow.Transparency = 0.55
        AccentGlow.Parent = Paragraph
    else
        Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Paragraph.BackgroundTransparency = 0.935
    end
    Instance.new("UICorner", Paragraph).CornerRadius = UDim.new(0, 8)
    if cfg.Badge then CreateBadge(Paragraph, cfg.Badge) end
    local mediaW = 0
    local mediaPadL = 0
    local VideoObject = nil
    local ThumbnailImg = nil
    local PlayOverlay = nil
    local IsPlaying = false
    if cfg.MediaType == "Image" or cfg.MediaType == "Video" then
        mediaW   = cfg.MediaWidth
        mediaPadL = 10
        local MediaContainer = Instance.new("Frame")
        MediaContainer.Name = "MediaContainer"
        MediaContainer.Position = UDim2.new(0, mediaPadL, 0, 8)
        MediaContainer.Size = UDim2.new(0, mediaW, 0, cfg.MediaHeight)
        MediaContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        MediaContainer.BackgroundTransparency = 0.3
        MediaContainer.BorderSizePixel = 0
        MediaContainer.ClipsDescendants = true
        MediaContainer.Parent = Paragraph
        Instance.new("UICorner", MediaContainer).CornerRadius = UDim.new(0, 6)
        ThumbnailImg = Instance.new("ImageLabel")
        ThumbnailImg.Name = "ThumbnailImg"
        ThumbnailImg.Size = UDim2.new(1, 0, 1, 0)
        ThumbnailImg.BackgroundTransparency = 1
        ThumbnailImg.ScaleType = Enum.ScaleType.Crop
        ThumbnailImg.Image = cfg.MediaId or ""
        ThumbnailImg.Visible = (cfg.MediaId ~= nil and cfg.MediaId ~= "")
        ThumbnailImg.Parent = MediaContainer
        if cfg.MediaType == "Video" then
            VideoObject = Instance.new("VideoFrame")
            VideoObject.Name = "VideoFrame"
            VideoObject.Size = UDim2.new(1, 0, 1, 0)
            VideoObject.BackgroundTransparency = 1
            VideoObject.Video = cfg.VideoId or ""
            VideoObject.Volume = 0.5
            VideoObject.Visible = false
            VideoObject.Parent = MediaContainer
            PlayOverlay = Instance.new("TextButton")
            PlayOverlay.Name = "PlayOverlay"
            PlayOverlay.Size = UDim2.new(1, 0, 1, 0)
            PlayOverlay.BackgroundTransparency = 1
            PlayOverlay.AutoButtonColor = false
            PlayOverlay.Text = ""
            PlayOverlay.ZIndex = 5
            PlayOverlay.Parent = MediaContainer
            local PlayIcon = Instance.new("ImageLabel")
            PlayIcon.Name = "PlayIcon"
            PlayIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            PlayIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
            PlayIcon.Size = UDim2.new(0, 24, 0, 24)
            PlayIcon.BackgroundTransparency = 1
            PlayIcon.ScaleType = Enum.ScaleType.Fit
            PlayIcon.Image = "rbxassetid://7743870813"
            PlayIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            PlayIcon.ZIndex = 6
            PlayIcon.Parent = PlayOverlay
            PlayOverlay.MouseButton1Click:Connect(function()
                if IsPlaying then
                    ParagraphFunc:StopVideo()
                else
                    ParagraphFunc:StartVideo()
                end
            end)
            VideoObject.Ended:Connect(function()
                ParagraphFunc:StopVideo()
            end)
        end
    end
    local iconSize = 0
    local iconPadL = 0
    if cfg.Icon and not cfg.MediaType then
        iconSize = 36
        iconPadL = 10
        local IconContainer = Instance.new("Frame")
        IconContainer.Name = "IconContainer"
        IconContainer.Position = UDim2.new(0, iconPadL, 0, 10)
        IconContainer.Size = UDim2.new(0, iconSize, 0, iconSize)
        IconContainer.BackgroundTransparency = 1
        IconContainer.Parent = Paragraph
        local IconImg = Instance.new("ImageLabel")
        IconImg.Name = "ParagraphIcon"
        IconImg.Size = UDim2.new(1, 0, 1, 0)
        IconImg.BackgroundTransparency = 1
        IconImg.ScaleType = Enum.ScaleType.Fit
        IconImg.Image = GetIconId(cfg.Icon)
        IconImg.Parent = IconContainer
    end
    local textLeft
    if cfg.MediaType then
        textLeft = mediaPadL + mediaW + 10
    elseif cfg.Icon then
        textLeft = iconPadL + iconSize + 10
    else
        textLeft = cfg.Color and 14 or 10
    end
    local ParagraphTitle = Instance.new("TextLabel")
    ParagraphTitle.Name = "ParagraphTitle"
    ParagraphTitle.Font = Enum.Font.GothamBold
    ParagraphTitle.Text = cfg.Title
    ParagraphTitle.TextColor3 = cfg.Color and cfg.Color or Color3.fromRGB(255, 255, 255)
    ParagraphTitle.TextSize = 13
    ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
    ParagraphTitle.BackgroundTransparency = 1
    ParagraphTitle.Position = UDim2.new(0, textLeft, 0, 10)
    ParagraphTitle.Size = UDim2.new(1, -(textLeft + 10), 0, 15)
    ParagraphTitle.TextWrapped = false
    ParagraphTitle.Parent = Paragraph
    local ParagraphContent = Instance.new("TextLabel")
    ParagraphContent.Name = "ParagraphContent"
    ParagraphContent.Font = Enum.Font.GothamBold
    ParagraphContent.Text = cfg.Content
    ParagraphContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    ParagraphContent.TextSize = 11
    ParagraphContent.TextTransparency = cfg.Color and 0.25 or 0.45
    ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphContent.TextYAlignment = Enum.TextYAlignment.Top
    ParagraphContent.BackgroundTransparency = 1
    ParagraphContent.Position = UDim2.new(0, textLeft, 0, 27)
    ParagraphContent.Size = UDim2.new(1, -(textLeft + 10), 0, 12)
    ParagraphContent.TextWrapped = true
    ParagraphContent.RichText = true
    ParagraphContent.Parent = Paragraph
    local btnBgColor = cfg.ButtonColor    or Color3.fromRGB(255, 255, 255)
    local subBgColor = cfg.SubButtonColor or Color3.fromRGB(255, 255, 255)
    local btnBgTrans = cfg.ButtonColor    and 0.15 or 0.85
    local subBgTrans = cfg.SubButtonColor and 0.15 or 0.85
    local ParagraphButton, ParagraphSubButton
    if cfg.ButtonText then
        local hasSubBtn = cfg.SubButtonText ~= nil
        ParagraphButton = Instance.new("TextButton")
        ParagraphButton.Name = "ParagraphButton"
        ParagraphButton.BackgroundColor3 = btnBgColor
        ParagraphButton.BackgroundTransparency = btnBgTrans
        ParagraphButton.Font = Enum.Font.GothamBold
        ParagraphButton.TextSize = 12
        ParagraphButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphButton.TextTransparency = 0
        ParagraphButton.Text = cfg.ButtonText
        ParagraphButton.Size = hasSubBtn and UDim2.new(0.5, -13, 0, 28) or UDim2.new(1, -16, 0, 28)
        ParagraphButton.Position = UDim2.new(0, 8, 0, 0)
        ParagraphButton.AutoButtonColor = false
        ParagraphButton.Parent = Paragraph
        Instance.new("UICorner", ParagraphButton).CornerRadius = UDim.new(0, 6)
        ParagraphButton.MouseButton1Click:Connect(function()
            AnimateButtonClick(ParagraphButton, btnBgColor)
            SafeCall(cfg.ButtonCallback)
        end)
        if hasSubBtn then
            ParagraphSubButton = Instance.new("TextButton")
            ParagraphSubButton.Name = "ParagraphSubButton"
            ParagraphSubButton.BackgroundColor3 = subBgColor
            ParagraphSubButton.BackgroundTransparency = subBgTrans
            ParagraphSubButton.Font = Enum.Font.GothamBold
            ParagraphSubButton.TextSize = 12
            ParagraphSubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ParagraphSubButton.TextTransparency = 0
            ParagraphSubButton.Text = cfg.SubButtonText
            ParagraphSubButton.Size = UDim2.new(0.5, -13, 0, 28)
            ParagraphSubButton.Position = UDim2.new(0.5, 5, 0, 0)
            ParagraphSubButton.AutoButtonColor = false
            ParagraphSubButton.Parent = Paragraph
            Instance.new("UICorner", ParagraphSubButton).CornerRadius = UDim.new(0, 6)
            ParagraphSubButton.MouseButton1Click:Connect(function()
                AnimateButtonClick(ParagraphSubButton, subBgColor)
                SafeCall(cfg.SubButtonCallback)
            end)
        end
    end
    local function UpdateSize()
        task.wait()
        local contentH = math.max(12, ParagraphContent.TextBounds.Y)
        ParagraphContent.Size = UDim2.new(1, -(textLeft + 10), 0, contentH)
        local textBottom = 10 + 15 + 2 + contentH + 8
        local mediaMinH = (cfg.MediaType and cfg.MediaHeight > 0) and (cfg.MediaHeight + 16) or 0
        local headerBottom = math.max(textBottom, mediaMinH)
        local totalH = headerBottom
        if ParagraphButton then
            ParagraphButton.Position = UDim2.new(0, 8, 0, headerBottom)
            if ParagraphSubButton then
                ParagraphSubButton.Position = UDim2.new(0.5, 5, 0, headerBottom)
            end
            totalH = headerBottom + 28 + 8
        end
        Paragraph.Size = UDim2.new(1, 0, 0, totalH)
    end
    UpdateSize()
    ParagraphContent:GetPropertyChangedSignal("Text"):Connect(UpdateSize)
    ParagraphContent:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)
    Paragraph:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)
    local LockFunc = ApplyLock(Paragraph, cfg.Locked)
    function ParagraphFunc:StartVideo()
        if not VideoObject then
            warn("[Elements] StartVideo: bukan tipe Video atau VideoId tidak diset.")
            return
        end
        if IsPlaying then return end
        IsPlaying = true
        if ThumbnailImg then ThumbnailImg.Visible = false end
        VideoObject.Visible = true
        VideoObject:Play()
        if PlayOverlay and PlayOverlay:FindFirstChild("PlayIcon") then
            PlayOverlay.PlayIcon.Image = "rbxassetid://7743871507"
        end
    end
    function ParagraphFunc:StopVideo()
        if not VideoObject then return end
        if not IsPlaying then return end
        IsPlaying = false
        VideoObject:Pause()
        VideoObject.Visible = false
        if ThumbnailImg and cfg.MediaId and cfg.MediaId ~= "" then
            ThumbnailImg.Visible = true
        end
        if PlayOverlay and PlayOverlay:FindFirstChild("PlayIcon") then
            PlayOverlay.PlayIcon.Image = "rbxassetid://7743870813"
        end
    end
    function ParagraphFunc:SetMedia(mediaType, mediaId, videoId)
        if not ThumbnailImg then
            warn("[Elements] SetMedia: Paragraph tidak dibuat dengan MediaType.")
            return
        end
        if IsPlaying then ParagraphFunc:StopVideo() end
        ThumbnailImg.Image = mediaId or ""
        if VideoObject then
            VideoObject.Video = videoId or ""
        end
        cfg.MediaType = mediaType
        cfg.MediaId   = mediaId
        cfg.VideoId   = videoId
    end
    function ParagraphFunc:IsVideoPlaying()
        return IsPlaying
    end
    function ParagraphFunc:SetContent(content)
        ParagraphContent.Text = tostring(content or "Content")
        UpdateSize()
    end
    function ParagraphFunc:SetTitle(title)
        ParagraphTitle.Text = tostring(title or "Title")
    end
    function ParagraphFunc:GetContent()
        return ParagraphContent.Text
    end
    function ParagraphFunc:GetTitle()
        return ParagraphTitle.Text
    end
    function ParagraphFunc:SetLocked(state)
        LockFunc:SetLocked(state)
    end
    function ParagraphFunc:GetLocked()
        return LockFunc:GetLocked()
    end
    function ParagraphFunc:SetLockMessage(text)
        LockFunc:SetMessage(text)
    end
    if cfg.AutoPlay and cfg.MediaType == "Video" then
        task.defer(function() ParagraphFunc:StartVideo() end)
    end
    return ParagraphFunc
end
function Elements:CreateEditableParagraph(parent, config, countItem)
    local cfg = config or {}
    cfg.Title       = cfg.Title       or "Title"
    cfg.Content     = cfg.Content     or "Type here..."
    cfg.Placeholder = cfg.Placeholder or "Type something..."
    cfg.Callback    = cfg.Callback    or function() end
    cfg.Default     = cfg.Default     or ""
    cfg.Badge       = cfg.Badge       or nil
    cfg.Locked      = cfg.Locked      or false
    -- Flag support: Flag takes priority over Title for config key
    local configKey = ResolveKey("EditableParagraph", cfg)
    if ConfigData[configKey] ~= nil then
        cfg.Default = ConfigData[configKey]
    end
    local ParagraphFunc = { Value = cfg.Default }
    local Paragraph        = Instance.new("Frame")
    local UICorner         = Instance.new("UICorner")
    local ParagraphTitle   = Instance.new("TextLabel")
    local TextBoxFrame     = Instance.new("Frame")
    local TextBoxCorner    = Instance.new("UICorner")
    local ParagraphTextBox = Instance.new("TextBox")
    Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Paragraph.BackgroundTransparency = 0.935
    Paragraph.BorderSizePixel = 0
    Paragraph.LayoutOrder = countItem
    Paragraph.Size = UDim2.new(1, 0, 0, 80)
    Paragraph.Name = "EditableParagraph"
    Paragraph.Parent = parent
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Paragraph
    if cfg.Badge then CreateBadge(Paragraph, cfg.Badge) end
    local iconOffset = 10
    if cfg.Icon then
        local IconImg = Instance.new("ImageLabel")
        IconImg.Size = UDim2.new(0, 20, 0, 20)
        IconImg.Position = UDim2.new(0, 8, 0, 10)
        IconImg.BackgroundTransparency = 1
        IconImg.Name = "ParagraphIcon"
        IconImg.Image = GetIconId(cfg.Icon)
        IconImg.Parent = Paragraph
        iconOffset = 35
    end
    ParagraphTitle.Font = Enum.Font.GothamBold
    ParagraphTitle.Text = cfg.Title
    ParagraphTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    ParagraphTitle.TextSize = 13
    ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
    ParagraphTitle.BackgroundTransparency = 1
    ParagraphTitle.Position = UDim2.new(0, iconOffset, 0, 10)
    ParagraphTitle.Size = UDim2.new(1, -iconOffset - 10, 0, 13)
    ParagraphTitle.Name = "ParagraphTitle"
    ParagraphTitle.Parent = Paragraph
    TextBoxFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextBoxFrame.BackgroundTransparency = 0.95
    TextBoxFrame.BorderSizePixel = 0
    TextBoxFrame.Position = UDim2.new(0, 10, 0, 30)
    TextBoxFrame.Size = UDim2.new(1, -20, 0, 40)
    TextBoxFrame.Name = "TextBoxFrame"
    TextBoxFrame.Parent = Paragraph
    TextBoxCorner.CornerRadius = UDim.new(0, 4)
    TextBoxCorner.Parent = TextBoxFrame
    ParagraphTextBox.Font = Enum.Font.Gotham
    ParagraphTextBox.PlaceholderText = cfg.Placeholder
    ParagraphTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    ParagraphTextBox.Text = cfg.Default
    ParagraphTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    ParagraphTextBox.TextSize = 12
    ParagraphTextBox.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphTextBox.TextYAlignment = Enum.TextYAlignment.Top
    ParagraphTextBox.BackgroundTransparency = 1
    ParagraphTextBox.Position = UDim2.new(0, 8, 0, 6)
    ParagraphTextBox.Size = UDim2.new(1, -16, 1, -12)
    ParagraphTextBox.Name = "ParagraphTextBox"
    ParagraphTextBox.TextWrapped = true
    ParagraphTextBox.MultiLine = true
    ParagraphTextBox.ClearTextOnFocus = false
    ParagraphTextBox.RichText = false
    ParagraphTextBox.Parent = TextBoxFrame
    local ParagraphButton
    if cfg.ButtonText then
        ParagraphButton = Instance.new("TextButton")
        ParagraphButton.Size = UDim2.new(1, -20, 0, 28)
        ParagraphButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphButton.BackgroundTransparency = 0.935
        ParagraphButton.Font = Enum.Font.GothamBold
        ParagraphButton.TextSize = 12
        ParagraphButton.TextTransparency = 0.3
        ParagraphButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphButton.Text = cfg.ButtonText
        ParagraphButton.Position = UDim2.new(0, 10, 0, 75)
        ParagraphButton.AutoButtonColor = false
        ParagraphButton.Parent = Paragraph
        Instance.new("UICorner", ParagraphButton).CornerRadius = UDim.new(0, 6)
        ParagraphButton.MouseButton1Click:Connect(function()
            AnimateButtonClick(ParagraphButton)
            SafeCall(cfg.ButtonCallback, ParagraphTextBox.Text)
        end)
    end
    local function UpdateSize()
        local textHeight = math.max(40, ParagraphTextBox.TextBounds.Y + 12)
        TextBoxFrame.Size = UDim2.new(1, -20, 0, textHeight)
        local totalHeight = 30 + textHeight + 10
        if ParagraphButton then
            ParagraphButton.Position = UDim2.new(0, 10, 0, 30 + textHeight + 5)
            totalHeight = totalHeight + ParagraphButton.Size.Y.Offset + 10
        end
        Paragraph.Size = UDim2.new(1, 0, 0, totalHeight)
    end
    UpdateSize()
    ParagraphTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        UpdateSize()
        ParagraphFunc.Value = ParagraphTextBox.Text
        ConfigData[configKey] = ParagraphTextBox.Text
        SaveConfig()
        SafeCall(cfg.Callback, ParagraphTextBox.Text)
    end)
    ParagraphTextBox:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)
    Paragraph:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)
    local LockFunc = ApplyLock(Paragraph, cfg.Locked)
    function ParagraphFunc:SetContent(content)
        ParagraphTextBox.Text = tostring(content or "")
        ParagraphFunc.Value = ParagraphTextBox.Text
        UpdateSize()
    end
    function ParagraphFunc:GetContent()
        return ParagraphTextBox.Text
    end
    function ParagraphFunc:SetTitle(title)
        ParagraphTitle.Text = tostring(title or "Title")
    end
    function ParagraphFunc:GetTitle()
        return ParagraphTitle.Text
    end
    function ParagraphFunc:SetLocked(state)
        LockFunc:SetLocked(state)
    end
    function ParagraphFunc:GetLocked()
        return LockFunc:GetLocked()
    end
    function ParagraphFunc:SetLockMessage(text)
        LockFunc:SetMessage(text)
    end
    return ParagraphFunc
end
function Elements:CreatePanel(parent, config, countItem)
    local cfg = config or {}
    cfg.Title             = cfg.Title          or "Title"
    cfg.Content           = cfg.Content        or ""
    cfg.Placeholder       = cfg.Placeholder    or nil
    cfg.Default           = cfg.Default        or ""
    cfg.ButtonText        = cfg.Button         or cfg.ButtonText     or "Confirm"
    cfg.ButtonCallback    = cfg.Callback       or cfg.ButtonCallback  or function() end
    cfg.SubButtonText     = cfg.SubButton      or cfg.SubButtonText   or nil
    cfg.SubButtonCallback = cfg.SubCallback    or cfg.SubButtonCallback or function() end
    cfg.Badge             = cfg.Badge          or nil
    cfg.Locked            = cfg.Locked         or false
    -- Flag support: Flag takes priority over Title for config key
    local configKey = ResolveKey("Panel", cfg)
    if ConfigData[configKey] ~= nil then
        cfg.Default = ConfigData[configKey]
    end
    local PanelFunc = { Value = cfg.Default }
    local baseHeight = 50
    if cfg.Placeholder then baseHeight = baseHeight + 40 end
    if cfg.SubButtonText then baseHeight = baseHeight + 40 else baseHeight = baseHeight + 36 end
    local Panel = Instance.new("Frame")
    Panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Panel.BackgroundTransparency = 0.935
    Panel.Size = UDim2.new(1, 0, 0, baseHeight)
    Panel.LayoutOrder = countItem
    Panel.Parent = parent
    Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 4)
    if cfg.Badge then CreateBadge(Panel, cfg.Badge) end
    local Title = Instance.new("TextLabel")
    Title.Font = Enum.Font.GothamBold
    Title.Text = cfg.Title
    Title.TextSize = 13
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.Size = UDim2.new(1, -20, 0, 13)
    Title.Parent = Panel
    local Content = Instance.new("TextLabel")
    Content.Font = Enum.Font.Gotham
    Content.Text = cfg.Content
    Content.TextSize = 12
    Content.TextColor3 = Color3.fromRGB(255, 255, 255)
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.BackgroundTransparency = 1
    Content.RichText = true
    Content.TextWrapped = true
    Content.Position = UDim2.new(0, 10, 0, 28)
    Content.Size = UDim2.new(1, -20, 0, 14)
    Content.Parent = Panel
    local InputBox
    local InputFrameRef
    if cfg.Placeholder then
        InputFrameRef = Instance.new("Frame")
        InputFrameRef.AnchorPoint = Vector2.new(0.5, 0)
        InputFrameRef.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputFrameRef.BackgroundTransparency = 0.95
        InputFrameRef.Size = UDim2.new(1, -20, 0, 30)
        InputFrameRef.Name = "InputFrame"
        InputFrameRef.Parent = Panel
        Instance.new("UICorner", InputFrameRef).CornerRadius = UDim.new(0, 4)
        InputBox = Instance.new("TextBox")
        InputBox.Font = Enum.Font.GothamBold
        InputBox.PlaceholderText = cfg.Placeholder
        InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        InputBox.Text = cfg.Default
        InputBox.TextSize = 11
        InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputBox.BackgroundTransparency = 1
        InputBox.TextXAlignment = Enum.TextXAlignment.Left
        InputBox.Size = UDim2.new(1, -10, 1, -6)
        InputBox.Position = UDim2.new(0, 5, 0, 3)
        InputBox.ClearTextOnFocus = false
        InputBox.Parent = InputFrameRef
    end
    local ButtonMain = Instance.new("TextButton")
    ButtonMain.Font = Enum.Font.GothamBold
    ButtonMain.Text = cfg.ButtonText
    ButtonMain.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonMain.TextSize = 12
    ButtonMain.TextTransparency = 0.3
    ButtonMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ButtonMain.BackgroundTransparency = 0.935
    ButtonMain.Size = cfg.SubButtonText and UDim2.new(0.5, -12, 0, 30) or UDim2.new(1, -20, 0, 30)
    ButtonMain.AutoButtonColor = false
    ButtonMain.Parent = Panel
    Instance.new("UICorner", ButtonMain).CornerRadius = UDim.new(0, 6)
    local SubButton
    if cfg.SubButtonText then
        SubButton = Instance.new("TextButton")
        SubButton.Font = Enum.Font.GothamBold
        SubButton.Text = cfg.SubButtonText
        SubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        SubButton.TextSize = 12
        SubButton.TextTransparency = 0.3
        SubButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SubButton.BackgroundTransparency = 0.935
        SubButton.Size = UDim2.new(0.5, -12, 0, 30)
        SubButton.AutoButtonColor = false
        SubButton.Parent = Panel
        Instance.new("UICorner", SubButton).CornerRadius = UDim.new(0, 6)
        SubButton.MouseButton1Click:Connect(function()
            AnimateButtonClick(SubButton)
            local inputVal = InputBox and InputBox.Text or ""
            SafeCall(cfg.SubButtonCallback, inputVal)
        end)
    end
    local function UpdatePanelLayout()
        task.wait()
        local contentH = math.max(14, Content.TextBounds.Y)
        Content.Size = UDim2.new(1, -20, 0, contentH)
        local afterContent = 28 + contentH + 6
        if InputFrameRef then
            InputFrameRef.Position = UDim2.new(0.5, 0, 0, afterContent)
            afterContent = afterContent + 30 + 6
        end
        ButtonMain.Position = UDim2.new(0, 10, 0, afterContent)
        if SubButton then
            SubButton.Position = UDim2.new(0.5, 2, 0, afterContent)
        end
        Panel.Size = UDim2.new(1, 0, 0, afterContent + 30 + 8)
    end
    UpdatePanelLayout()
    Content:GetPropertyChangedSignal("TextBounds"):Connect(UpdatePanelLayout)
    Content:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdatePanelLayout)
    ButtonMain.MouseButton1Click:Connect(function()
        AnimateButtonClick(ButtonMain)
        local inputVal = InputBox and InputBox.Text or ""
        PanelFunc.Value = inputVal
        SafeCall(cfg.ButtonCallback, inputVal)
    end)
    if InputBox then
        InputBox.FocusLost:Connect(function()
            PanelFunc.Value = InputBox.Text
            ConfigData[configKey] = InputBox.Text
            SaveConfig()
        end)
    end
    local LockFunc = ApplyLock(Panel, cfg.Locked)
    function PanelFunc:GetInput()
        return InputBox and InputBox.Text or ""
    end
    function PanelFunc:GetValue()
        return PanelFunc.Value
    end
    function PanelFunc:SetContent(text)
        Content.Text = tostring(text or "")
    end
    function PanelFunc:SetTitle(text)
        Title.Text = tostring(text or "Title")
    end
    function PanelFunc:SetLocked(state)
        LockFunc:SetLocked(state)
    end
    function PanelFunc:GetLocked()
        return LockFunc:GetLocked()
    end
    function PanelFunc:SetLockMessage(text)
        LockFunc:SetMessage(text)
    end
    return PanelFunc
end
function Elements:CreateButton(parent, config, countItem)
    local cfg = config or {}
    cfg.Title       = cfg.Title       or "Confirm"
    cfg.Content     = cfg.Content     or ""
    cfg.Callback    = cfg.Callback    or function() end
    cfg.SubTitle    = cfg.SubTitle    or nil
    cfg.SubCallback = cfg.SubCallback or function() end
    cfg.Badge       = cfg.Badge       or nil
    cfg.Version     = cfg.Version     or "V1"
    cfg.Locked      = cfg.Locked      or false
    local ButtonFunc = {}
    if cfg.Version == "V2" then
        local hasContent = cfg.Content ~= ""
        local frameH = hasContent and 56 or 40
        local Button = Instance.new("Frame")
        Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Button.BackgroundTransparency = 0.935
        Button.BorderSizePixel = 0
        Button.LayoutOrder = countItem
        Button.Size = UDim2.new(1, 0, 0, frameH)
        Button.Name = "ButtonV2"
        Button.Parent = parent
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
        if cfg.Badge then CreateBadge(Button, cfg.Badge) end
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.Text = cfg.Title
        TitleLabel.TextSize = 13
        TitleLabel.TextColor3 = Color3.fromRGB(231, 231, 231)
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.TextYAlignment = Enum.TextYAlignment.Top
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Name = "ButtonTitle"
        TitleLabel.Parent = Button
        if hasContent then
            TitleLabel.Position = UDim2.new(0, 12, 0, 10)
            TitleLabel.Size = UDim2.new(1, -60, 0, 15)
        else
            TitleLabel.Position = UDim2.new(0, 12, 0.5, -7)
            TitleLabel.Size = UDim2.new(1, -60, 0, 15)
        end
        local ContentLabel
        if hasContent then
            ContentLabel = Instance.new("TextLabel")
            ContentLabel.Font = Enum.Font.GothamBold
            ContentLabel.Text = cfg.Content
            ContentLabel.TextSize = 11
            ContentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ContentLabel.TextTransparency = 0.45
            ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
            ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
            ContentLabel.BackgroundTransparency = 1
            ContentLabel.Position = UDim2.new(0, 12, 0, 28)
            ContentLabel.Size = UDim2.new(1, -60, 0, 14)
            ContentLabel.TextWrapped = true
            ContentLabel.RichText = true
            ContentLabel.Name = "ButtonContent"
            ContentLabel.Parent = Button
            ContentLabel.Size = UDim2.new(1, -60, 0, 12 + (12 * (ContentLabel.TextBounds.X // math.max(1, ContentLabel.AbsoluteSize.X))))
            Button.Size = UDim2.new(1, 0, 0, ContentLabel.AbsoluteSize.Y + 42)
            ContentLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                ContentLabel.TextWrapped = false
                ContentLabel.Size = UDim2.new(1, -60, 0, 12 + (12 * (ContentLabel.TextBounds.X // math.max(1, ContentLabel.AbsoluteSize.X))))
                Button.Size = UDim2.new(1, 0, 0, ContentLabel.AbsoluteSize.Y + 42)
                ContentLabel.TextWrapped = true
            end)
        end
        local IconImg
        if cfg.Icon then
            IconImg = Instance.new("ImageLabel")
            IconImg.AnchorPoint = Vector2.new(1, 0.5)
            IconImg.Position = UDim2.new(1, -10, 0.5, 0)
            IconImg.Size = UDim2.new(0, 20, 0, 20)
            IconImg.BackgroundTransparency = 1
            IconImg.ScaleType = Enum.ScaleType.Fit
            IconImg.Image = GetIconId(cfg.Icon)
            IconImg.ImageColor3 = Color3.fromRGB(220, 220, 220)
            IconImg.ImageTransparency = 0.2
            IconImg.Name = "IconImg"
            IconImg.Parent = Button
        else
            local ChevronFrame = Instance.new("Frame")
            ChevronFrame.Name = "IconImg"
            ChevronFrame.AnchorPoint = Vector2.new(1, 0.5)
            ChevronFrame.Position = UDim2.new(1, -12, 0.5, 0)
            ChevronFrame.Size = UDim2.new(0, 16, 0, 16)
            ChevronFrame.BackgroundTransparency = 1
            ChevronFrame.Parent = Button
            local LineTop = Instance.new("Frame")
            LineTop.Size = UDim2.new(0, 6, 0, 2)
            LineTop.Position = UDim2.new(0, 2, 0, 4)
            LineTop.Rotation = 45
            LineTop.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            LineTop.BackgroundTransparency = 0.2
            LineTop.BorderSizePixel = 0
            LineTop.Parent = ChevronFrame
            Instance.new("UICorner", LineTop).CornerRadius = UDim.new(1, 0)
            local LineBot = Instance.new("Frame")
            LineBot.Size = UDim2.new(0, 6, 0, 2)
            LineBot.Position = UDim2.new(0, 2, 0, 9)
            LineBot.Rotation = -45
            LineBot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            LineBot.BackgroundTransparency = 0.2
            LineBot.BorderSizePixel = 0
            LineBot.Parent = ChevronFrame
            Instance.new("UICorner", LineBot).CornerRadius = UDim.new(1, 0)
            IconImg = ChevronFrame
        end
        local ClickButton = Instance.new("TextButton")
        ClickButton.Text = ""
        ClickButton.BackgroundTransparency = 1
        ClickButton.Size = UDim2.new(1, 0, 1, 0)
        ClickButton.Name = "ClickButton"
        ClickButton.AutoButtonColor = false
        ClickButton.Parent = Button
        ClickButton.MouseButton1Click:Connect(function()
            AnimateButtonClick(ClickButton)
            SafeCall(cfg.Callback)
        end)
        ClickButton.MouseEnter:Connect(function()
            TweenService:Create(TitleLabel, TweenInfo.new(0.15), { TextColor3 = GuiConfig.Color }):Play()
            if not cfg.Icon and IconImg then
                for _, line in ipairs(IconImg:GetChildren()) do
                    if line:IsA("Frame") then
                        TweenService:Create(line, TweenInfo.new(0.15), { BackgroundColor3 = GuiConfig.Color, BackgroundTransparency = 0 }):Play()
                    end
                end
            end
        end)
        ClickButton.MouseLeave:Connect(function()
            TweenService:Create(TitleLabel, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(231, 231, 231) }):Play()
            if not cfg.Icon and IconImg then
                for _, line in ipairs(IconImg:GetChildren()) do
                    if line:IsA("Frame") then
                        TweenService:Create(line, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(200, 200, 200), BackgroundTransparency = 0.2 }):Play()
                    end
                end
            end
        end)
        local LockFunc = ApplyLock(Button, cfg.Locked)
        function ButtonFunc:Fire()
            SafeCall(cfg.Callback)
        end
        function ButtonFunc:SetTitle(text)
            TitleLabel.Text = tostring(text or "")
            cfg.Title = TitleLabel.Text
        end
        function ButtonFunc:SetContent(text)
            if ContentLabel then
                ContentLabel.Text = tostring(text or "")
            end
            cfg.Content = tostring(text or "")
        end
        function ButtonFunc:SetCallback(fn)
            cfg.Callback = typeof(fn) == "function" and fn or function() end
        end
        function ButtonFunc:SetLocked(state)
            LockFunc:SetLocked(state)
        end
        function ButtonFunc:GetLocked()
            return LockFunc:GetLocked()
        end
        return ButtonFunc
    end
    local Button = Instance.new("Frame")
    Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Button.BackgroundTransparency = 0.935
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.LayoutOrder = countItem
    Button.Parent = parent
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)
    if cfg.Badge then CreateBadge(Button, cfg.Badge) end
    local MainButton = Instance.new("TextButton")
    MainButton.Font = Enum.Font.GothamBold
    MainButton.Text = cfg.Title
    MainButton.TextSize = 12
    MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainButton.TextTransparency = 0.3
    MainButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainButton.BackgroundTransparency = 0.935
    MainButton.Size = cfg.SubTitle and UDim2.new(0.5, -8, 1, -10) or UDim2.new(1, -12, 1, -10)
    MainButton.Position = UDim2.new(0, 6, 0, 5)
    MainButton.AutoButtonColor = false
    MainButton.Parent = Button
    Instance.new("UICorner", MainButton).CornerRadius = UDim.new(0, 4)
    MainButton.MouseButton1Click:Connect(function()
        AnimateButtonClick(MainButton)
        SafeCall(cfg.Callback)
    end)
    local SubButtonRef
    if cfg.SubTitle then
        SubButtonRef = Instance.new("TextButton")
        SubButtonRef.Font = Enum.Font.GothamBold
        SubButtonRef.Text = cfg.SubTitle
        SubButtonRef.TextSize = 12
        SubButtonRef.TextTransparency = 0.3
        SubButtonRef.TextColor3 = Color3.fromRGB(255, 255, 255)
        SubButtonRef.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SubButtonRef.BackgroundTransparency = 0.935
        SubButtonRef.Size = UDim2.new(0.5, -8, 1, -10)
        SubButtonRef.Position = UDim2.new(0.5, 2, 0, 5)
        SubButtonRef.AutoButtonColor = false
        SubButtonRef.Parent = Button
        Instance.new("UICorner", SubButtonRef).CornerRadius = UDim.new(0, 4)
        SubButtonRef.MouseButton1Click:Connect(function()
            AnimateButtonClick(SubButtonRef)
            SafeCall(cfg.SubCallback)
        end)
    end
    local LockFunc = ApplyLock(Button, cfg.Locked)
    function ButtonFunc:Fire()
        AnimateButtonClick(MainButton)
        SafeCall(cfg.Callback)
    end
    function ButtonFunc:FireSub()
        if SubButtonRef then
            AnimateButtonClick(SubButtonRef)
            SafeCall(cfg.SubCallback)
        end
    end
    function ButtonFunc:SetTitle(text)
        MainButton.Text = tostring(text or "Confirm")
        cfg.Title = MainButton.Text
    end
    function ButtonFunc:SetSubTitle(text)
        if SubButtonRef then
            SubButtonRef.Text = tostring(text or "")
            cfg.SubTitle = SubButtonRef.Text
        end
    end
    function ButtonFunc:SetCallback(fn)
        cfg.Callback = typeof(fn) == "function" and fn or function() end
    end
    function ButtonFunc:SetSubCallback(fn)
        cfg.SubCallback = typeof(fn) == "function" and fn or function() end
    end
    function ButtonFunc:SetLocked(state)
        LockFunc:SetLocked(state)
    end
    function ButtonFunc:GetLocked()
        return LockFunc:GetLocked()
    end
    function ButtonFunc:SetLockMessage(text)
        LockFunc:SetMessage(text)
    end
    return ButtonFunc
end
function Elements:CreateToggle(parent, config, countItem, updateSectionSize, Elements_Table)
    local cfg = config or {}
    cfg.Title    = cfg.Title    or "Title"
    cfg.Title2   = cfg.Title2   or ""
    cfg.Content  = cfg.Content  or ""
    cfg.Default  = cfg.Default  or false
    cfg.Callback = cfg.Callback or function() end
    cfg.Badge    = cfg.Badge    or nil
    cfg.Locked   = cfg.Locked   or false
    cfg.Type     = cfg.Type     or "Toggle"
    -- Flag support: Flag takes priority over Title for config key
    local configKey = ResolveKey("Toggle", cfg)
    if ConfigData[configKey] ~= nil then
        cfg.Default = ConfigData[configKey]
    end
    if typeof(cfg.Default) ~= "boolean" then
        cfg.Default = cfg.Default and true or false
    end
    local ToggleFunc = { Value = cfg.Default }
    local Toggle        = Instance.new("Frame")
    local UICorner20    = Instance.new("UICorner")
    local ToggleTitle   = Instance.new("TextLabel")
    local ToggleTitle2  = Instance.new("TextLabel")
    local ToggleContent = Instance.new("TextLabel")
    local ToggleButton  = Instance.new("TextButton")
    Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.BackgroundTransparency = 0.935
    Toggle.BorderSizePixel = 0
    Toggle.LayoutOrder = countItem
    Toggle.Name = "Toggle"
    Toggle.Parent = parent
    UICorner20.CornerRadius = UDim.new(0, 4)
    UICorner20.Parent = Toggle
    if cfg.Badge then CreateBadge(Toggle, cfg.Badge) end
    ToggleTitle.Font = Enum.Font.GothamBold
    ToggleTitle.Text = cfg.Title
    ToggleTitle.TextSize = 13
    ToggleTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
    ToggleTitle.BackgroundTransparency = 1
    ToggleTitle.Position = UDim2.new(0, 10, 0, 10)
    ToggleTitle.Size = UDim2.new(1, -100, 0, 13)
    ToggleTitle.Name = "ToggleTitle"
    ToggleTitle.Parent = Toggle
    ToggleTitle2.Font = Enum.Font.GothamBold
    ToggleTitle2.Text = cfg.Title2
    ToggleTitle2.TextSize = 12
    ToggleTitle2.TextColor3 = Color3.fromRGB(231, 231, 231)
    ToggleTitle2.TextXAlignment = Enum.TextXAlignment.Left
    ToggleTitle2.TextYAlignment = Enum.TextYAlignment.Top
    ToggleTitle2.BackgroundTransparency = 1
    ToggleTitle2.Position = UDim2.new(0, 10, 0, 23)
    ToggleTitle2.Size = UDim2.new(1, -100, 0, 12)
    ToggleTitle2.Name = "ToggleTitle2"
    ToggleTitle2.Parent = Toggle
    ToggleContent.Font = Enum.Font.GothamBold
    ToggleContent.Text = cfg.Content
    ToggleContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleContent.TextSize = 12
    ToggleContent.TextTransparency = 0.6
    ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
    ToggleContent.TextYAlignment = Enum.TextYAlignment.Bottom
    ToggleContent.BackgroundTransparency = 1
    ToggleContent.Name = "ToggleContent"
    ToggleContent.Parent = Toggle
    if cfg.Title2 ~= "" then
        Toggle.Size = UDim2.new(1, 0, 0, 57)
        ToggleContent.Position = UDim2.new(0, 10, 0, 36)
        ToggleTitle2.Visible = true
    else
        Toggle.Size = UDim2.new(1, 0, 0, 46)
        ToggleContent.Position = UDim2.new(0, 10, 0, 23)
        ToggleTitle2.Visible = false
    end
    ToggleContent.Size = UDim2.new(1, -100, 0, 12 + (12 * (ToggleContent.TextBounds.X // math.max(1, ToggleContent.AbsoluteSize.X))))
    ToggleContent.TextWrapped = true
    if cfg.Title2 ~= "" then
        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
    else
        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
    end
    ToggleContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        ToggleContent.TextWrapped = false
        ToggleContent.Size = UDim2.new(1, -100, 0, 12 + (12 * (ToggleContent.TextBounds.X // math.max(1, ToggleContent.AbsoluteSize.X))))
        if cfg.Title2 ~= "" then
            Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
        else
            Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
        end
        ToggleContent.TextWrapped = true
        if updateSectionSize then updateSectionSize() end
    end)
    ToggleButton.Font = Enum.Font.SourceSans
    ToggleButton.Text = ""
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.AutoButtonColor = false
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = Toggle
    local FeatureFrame, ToggleCircle, UIStroke8
    local CheckboxFrame, CheckMark
    if cfg.Type == "Checkbox" then
        CheckboxFrame = Instance.new("Frame")
        CheckboxFrame.AnchorPoint = Vector2.new(1, 0.5)
        CheckboxFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        CheckboxFrame.BackgroundTransparency = 0.92
        CheckboxFrame.BorderSizePixel = 0
        CheckboxFrame.Position = UDim2.new(1, -15, 0.5, 0)
        CheckboxFrame.Size = UDim2.new(0, 18, 0, 18)
        CheckboxFrame.Name = "CheckboxFrame"
        CheckboxFrame.Parent = Toggle
        Instance.new("UICorner", CheckboxFrame).CornerRadius = UDim.new(0, 4)
        local CBStroke = Instance.new("UIStroke")
        CBStroke.Color = Color3.fromRGB(255, 255, 255)
        CBStroke.Thickness = 1.5
        CBStroke.Transparency = 0.7
        CBStroke.Name = "CBStroke"
        CBStroke.Parent = CheckboxFrame
        CheckMark = Instance.new("ImageLabel")
        CheckMark.Name = "CheckMark"
        CheckMark.AnchorPoint = Vector2.new(0.5, 0.5)
        CheckMark.Position = UDim2.new(0.5, 0, 0.5, 0)
        CheckMark.Size = UDim2.new(0, 12, 0, 12)
        CheckMark.BackgroundTransparency = 1
        CheckMark.ScaleType = Enum.ScaleType.Fit
        CheckMark.Image = "rbxassetid://6031094667"
        CheckMark.ImageColor3 = Color3.fromRGB(255, 255, 255)
        CheckMark.ImageTransparency = 1
        CheckMark.ZIndex = 2
        CheckMark.Parent = CheckboxFrame
    else
        FeatureFrame = Instance.new("Frame")
        FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
        FeatureFrame.BackgroundTransparency = 0.92
        FeatureFrame.BorderSizePixel = 0
        FeatureFrame.Position = UDim2.new(1, -15, 0.5, 0)
        FeatureFrame.Size = UDim2.new(0, 30, 0, 15)
        FeatureFrame.Name = "FeatureFrame"
        FeatureFrame.Parent = Toggle
        Instance.new("UICorner", FeatureFrame)
        UIStroke8 = Instance.new("UIStroke")
        UIStroke8.Color = Color3.fromRGB(255, 255, 255)
        UIStroke8.Thickness = 2
        UIStroke8.Transparency = 0.9
        UIStroke8.Parent = FeatureFrame
        ToggleCircle = Instance.new("Frame")
        ToggleCircle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        ToggleCircle.BorderSizePixel = 0
        ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
        ToggleCircle.Name = "ToggleCircle"
        ToggleCircle.Parent = FeatureFrame
        Instance.new("UICorner", ToggleCircle).CornerRadius = UDim.new(0, 15)
    end
    ToggleButton.Activated:Connect(function()
        ToggleFunc:Set(not ToggleFunc.Value)
    end)
    function ToggleFunc:Set(Value)
        Value = Value and true or false
        ToggleFunc.Value = Value
        ConfigData[configKey] = Value
        SaveConfig()
        SafeCall(cfg.Callback, Value)
        if cfg.Type == "Checkbox" then
            local cbStroke = CheckboxFrame:FindFirstChild("CBStroke")
            if Value then
                TweenService:Create(ToggleTitle,   TweenInfo.new(0.2), { TextColor3 = GuiConfig.Color }):Play()
                TweenService:Create(CheckboxFrame, TweenInfo.new(0.2), { BackgroundColor3 = GuiConfig.Color, BackgroundTransparency = 0 }):Play()
                if cbStroke then TweenService:Create(cbStroke, TweenInfo.new(0.2), { Color = GuiConfig.Color, Transparency = 0 }):Play() end
                TweenService:Create(CheckMark,     TweenInfo.new(0.15), { ImageTransparency = 0 }):Play()
            else
                TweenService:Create(ToggleTitle,   TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(230, 230, 230) }):Play()
                TweenService:Create(CheckboxFrame, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92 }):Play()
                if cbStroke then TweenService:Create(cbStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.7 }):Play() end
                TweenService:Create(CheckMark,     TweenInfo.new(0.1), { ImageTransparency = 1 }):Play()
            end
        else
            if Value then
                TweenService:Create(ToggleTitle,  TweenInfo.new(0.2), { TextColor3 = GuiConfig.Color }):Play()
                TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 15, 0, 0) }):Play()
                TweenService:Create(UIStroke8,    TweenInfo.new(0.2), { Color = GuiConfig.Color, Transparency = 0 }):Play()
                TweenService:Create(FeatureFrame, TweenInfo.new(0.2), { BackgroundColor3 = GuiConfig.Color, BackgroundTransparency = 0 }):Play()
            else
                TweenService:Create(ToggleTitle,  TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(230, 230, 230) }):Play()
                TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 0, 0, 0) }):Play()
                TweenService:Create(UIStroke8,    TweenInfo.new(0.2), { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 }):Play()
                TweenService:Create(FeatureFrame, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92 }):Play()
            end
        end
    end
    function ToggleFunc:GetValue()
        return ToggleFunc.Value
    end
    local LockFunc = ApplyLock(Toggle, cfg.Locked)
    function ToggleFunc:SetLocked(state)
        LockFunc:SetLocked(state)
    end
    function ToggleFunc:GetLocked()
        return LockFunc:GetLocked()
    end
    function ToggleFunc:SetLockMessage(text)
        LockFunc:SetMessage(text)
    end
    ToggleFunc:Set(ToggleFunc.Value)
    Elements_Table[configKey] = ToggleFunc
    return ToggleFunc
end
function Elements:CreateSlider(parent, config, countItem, updateSectionSize, Elements_Table)
    local cfg = config or {}
    cfg.Title     = cfg.Title     or "Slider"
    cfg.Content   = cfg.Content   or ""
    cfg.Increment = cfg.Increment or 1
    cfg.Min       = cfg.Min       or 0
    cfg.Max       = cfg.Max       or 100
    cfg.Default   = cfg.Default   or 50
    cfg.Callback  = cfg.Callback  or function() end
    cfg.Badge     = cfg.Badge     or nil
    cfg.Locked    = cfg.Locked    or false
    if cfg.Min >= cfg.Max then cfg.Max = cfg.Min + 1 end
    if cfg.Increment <= 0 then cfg.Increment = 1 end
    -- Flag support: Flag takes priority over Title for config key
    local configKey = ResolveKey("Slider", cfg)
    if ConfigData[configKey] ~= nil then
        cfg.Default = ConfigData[configKey]
    end
    local SliderFunc = { Value = cfg.Default }
    local Slider          = Instance.new("Frame")
    local UICorner15      = Instance.new("UICorner")
    local SliderTitle     = Instance.new("TextLabel")
    local SliderContent   = Instance.new("TextLabel")
    local SliderInput     = Instance.new("Frame")
    local UICorner16      = Instance.new("UICorner")
    local TextBox         = Instance.new("TextBox")
    local SliderFrame     = Instance.new("Frame")
    local UICorner17      = Instance.new("UICorner")
    local SliderDraggable = Instance.new("Frame")
    local UICorner18      = Instance.new("UICorner")
    local SliderCircle    = Instance.new("Frame")
    local UICorner19      = Instance.new("UICorner")
    local UIStroke6       = Instance.new("UIStroke")
    Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Slider.BackgroundTransparency = 0.935
    Slider.BorderSizePixel = 0
    Slider.LayoutOrder = countItem
    Slider.Size = UDim2.new(1, 0, 0, 46)
    Slider.Name = "Slider"
    Slider.Parent = parent
    UICorner15.CornerRadius = UDim.new(0, 4)
    UICorner15.Parent = Slider
    if cfg.Badge then CreateBadge(Slider, cfg.Badge) end
    SliderTitle.Font = Enum.Font.GothamBold
    SliderTitle.Text = cfg.Title
    SliderTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    SliderTitle.TextSize = 13
    SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    SliderTitle.TextYAlignment = Enum.TextYAlignment.Top
    SliderTitle.BackgroundTransparency = 1
    SliderTitle.Position = UDim2.new(0, 10, 0, 10)
    SliderTitle.Size = UDim2.new(1, -180, 0, 13)
    SliderTitle.Name = "SliderTitle"
    SliderTitle.Parent = Slider
    SliderContent.Font = Enum.Font.GothamBold
    SliderContent.Text = cfg.Content
    SliderContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderContent.TextSize = 12
    SliderContent.TextTransparency = 0.6
    SliderContent.TextXAlignment = Enum.TextXAlignment.Left
    SliderContent.TextYAlignment = Enum.TextYAlignment.Bottom
    SliderContent.BackgroundTransparency = 1
    SliderContent.Position = UDim2.new(0, 10, 0, 25)
    SliderContent.Size = UDim2.new(1, -180, 0, 12)
    SliderContent.Name = "SliderContent"
    SliderContent.Parent = Slider
    SliderContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (SliderContent.TextBounds.X // math.max(1, SliderContent.AbsoluteSize.X))))
    SliderContent.TextWrapped = true
    Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)
    SliderContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        SliderContent.TextWrapped = false
        SliderContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (SliderContent.TextBounds.X // math.max(1, SliderContent.AbsoluteSize.X))))
        Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)
        SliderContent.TextWrapped = true
        if updateSectionSize then updateSectionSize() end
    end)
    SliderInput.AnchorPoint = Vector2.new(0, 0.5)
    SliderInput.BackgroundColor3 = GuiConfig.Color
    SliderInput.BackgroundTransparency = 1
    SliderInput.BorderSizePixel = 0
    SliderInput.Position = UDim2.new(1, -155, 0.5, 0)
    SliderInput.Size = UDim2.new(0, 28, 0, 20)
    SliderInput.Name = "SliderInput"
    SliderInput.Parent = Slider
    UICorner16.CornerRadius = UDim.new(0, 2)
    UICorner16.Parent = SliderInput
    TextBox.Font = Enum.Font.GothamBold
    TextBox.Text = tostring(cfg.Default)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.TextSize = 13
    TextBox.TextWrapped = true
    TextBox.BackgroundTransparency = 1
    TextBox.BorderSizePixel = 0
    TextBox.Position = UDim2.new(0, -1, 0, 0)
    TextBox.Size = UDim2.new(1, 0, 1, 0)
    TextBox.ClearTextOnFocus = false
    TextBox.Parent = SliderInput
    SliderFrame.AnchorPoint = Vector2.new(1, 0.5)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderFrame.BackgroundTransparency = 0.8
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Position = UDim2.new(1, -20, 0.5, 0)
    SliderFrame.Size = UDim2.new(0, 100, 0, 3)
    SliderFrame.Name = "SliderFrame"
    SliderFrame.Parent = Slider
    UICorner17.Parent = SliderFrame
    SliderDraggable.AnchorPoint = Vector2.new(0, 0.5)
    SliderDraggable.BackgroundColor3 = GuiConfig.Color
    SliderDraggable.BorderSizePixel = 0
    SliderDraggable.Position = UDim2.new(0, 0, 0.5, 0)
    SliderDraggable.Size = UDim2.new(0.9, 0, 0, 1)
    SliderDraggable.Name = "SliderDraggable"
    SliderDraggable.Parent = SliderFrame
    UICorner18.Parent = SliderDraggable
    SliderCircle.AnchorPoint = Vector2.new(1, 0.5)
    SliderCircle.BackgroundColor3 = GuiConfig.Color
    SliderCircle.BorderSizePixel = 0
    SliderCircle.Position = UDim2.new(1, 4, 0.5, 0)
    SliderCircle.Size = UDim2.new(0, 8, 0, 8)
    SliderCircle.Name = "SliderCircle"
    SliderCircle.Parent = SliderDraggable
    UICorner19.Parent = SliderCircle
    UIStroke6.Color = GuiConfig.Color
    UIStroke6.Parent = SliderCircle
    local SliderHitbox = Instance.new("TextButton")
    SliderHitbox.Text = ""
    SliderHitbox.BackgroundTransparency = 1
    SliderHitbox.AutoButtonColor = false
    SliderHitbox.AnchorPoint = Vector2.new(1, 0.5)
    SliderHitbox.Position = UDim2.new(1, -20, 0.5, 0)
    SliderHitbox.Size = UDim2.new(0, 100, 0, 44)
    SliderHitbox.ZIndex = 5
    SliderHitbox.Name = "SliderHitbox"
    SliderHitbox.Parent = Slider
    local Dragging = false
    local _settingFromCode = false
    local function GetScaleFromInput(inputX)
        return math.clamp(
            (inputX - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X,
            0, 1
        )
    end
    function SliderFunc:Set(Value)
        Value = math.clamp(RoundToFactor(tonumber(Value) or cfg.Min, cfg.Increment), cfg.Min, cfg.Max)
        SliderFunc.Value = Value
        _settingFromCode = true
        TextBox.Text = tostring(Value)
        _settingFromCode = false
        local scale = (Value - cfg.Min) / (cfg.Max - cfg.Min)
        TweenService:Create(
            SliderDraggable,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.fromScale(scale, 1) }
        ):Play()
        SafeCall(cfg.Callback, Value)
        ConfigData[configKey] = Value
        SaveConfig()
    end
    function SliderFunc:GetValue()
        return SliderFunc.Value
    end
    function SliderFunc:SetMin(min)
        cfg.Min = tonumber(min) or cfg.Min
        if cfg.Min >= cfg.Max then cfg.Max = cfg.Min + 1 end
        SliderFunc:Set(SliderFunc.Value)
    end
    function SliderFunc:SetMax(max)
        cfg.Max = tonumber(max) or cfg.Max
        if cfg.Max <= cfg.Min then cfg.Min = cfg.Max - 1 end
        SliderFunc:Set(SliderFunc.Value)
    end
    SliderHitbox.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            TweenService:Create(SliderCircle,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = UDim2.new(0, 14, 0, 14) }
            ):Play()
            SliderFunc:Set(cfg.Min + ((cfg.Max - cfg.Min) * GetScaleFromInput(Input.Position.X)))
        end
    end)
    UserInputService.InputEnded:Connect(function(Input)
        if Dragging
        and (Input.UserInputType == Enum.UserInputType.MouseButton1
          or Input.UserInputType == Enum.UserInputType.Touch) then
            Dragging = false
            TweenService:Create(SliderCircle,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = UDim2.new(0, 8, 0, 8) }
            ):Play()
        end
    end)
    UserInputService.InputChanged:Connect(function(Input)
        if Dragging
        and (Input.UserInputType == Enum.UserInputType.MouseMovement
          or Input.UserInputType == Enum.UserInputType.Touch) then
            SliderFunc:Set(cfg.Min + ((cfg.Max - cfg.Min) * GetScaleFromInput(Input.Position.X)))
        end
    end)
    TextBox.FocusLost:Connect(function()
        if _settingFromCode then return end
        local raw = TextBox.Text:gsub("[^%d%-%.]+", "")
        local num = tonumber(raw)
        if num then
            SliderFunc:Set(num)
        else
            _settingFromCode = true
            TextBox.Text = tostring(SliderFunc.Value)
            _settingFromCode = false
        end
    end)
    local LockFunc = ApplyLock(Slider, cfg.Locked)
    function SliderFunc:SetLocked(state)
        LockFunc:SetLocked(state)
    end
    function SliderFunc:GetLocked()
        return LockFunc:GetLocked()
    end
    function SliderFunc:SetLockMessage(text)
        LockFunc:SetMessage(text)
    end
    SliderFunc:Set(cfg.Default)
    Elements_Table[configKey] = SliderFunc
    return SliderFunc
end
function Elements:CreateInput(parent, config, countItem, updateSectionSize, Elements_Table)
    local cfg = config or {}
    cfg.Title       = cfg.Title       or "Title"
    cfg.Content     = cfg.Content     or ""
    cfg.Callback    = cfg.Callback    or function() end
    cfg.Default     = cfg.Default     or ""
    cfg.Badge       = cfg.Badge       or nil
    cfg.Locked      = cfg.Locked      or false
    cfg.Type        = cfg.Type        or "Input"
    cfg.Placeholder = cfg.Placeholder or (cfg.Type == "Textarea" and "Type here..." or "Input Here")
    cfg.TextHeight  = cfg.TextHeight  or 60
    -- Flag support: Flag takes priority over Title for config key
    local configKey = ResolveKey("Input", cfg)
    if ConfigData[configKey] ~= nil then
        cfg.Default = ConfigData[configKey]
    end
    local InputFunc = { Value = cfg.Default }
    local Input      = Instance.new("Frame")
    local InputTitle = Instance.new("TextLabel")
    local InputTextBox
    Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Input.BackgroundTransparency = 0.935
    Input.BorderSizePixel = 0
    Input.LayoutOrder = countItem
    Input.Name = "Input"
    Input.Parent = parent
    Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 4)
    if cfg.Badge then CreateBadge(Input, cfg.Badge) end
    local iconOffset = 10
    InputTitle.Font = Enum.Font.GothamBold
    InputTitle.Text = cfg.Title
    InputTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    InputTitle.TextSize = 13
    InputTitle.TextXAlignment = Enum.TextXAlignment.Left
    InputTitle.TextYAlignment = Enum.TextYAlignment.Top
    InputTitle.BackgroundTransparency = 1
    InputTitle.Name = "InputTitle"
    InputTitle.Parent = Input
    if cfg.Type == "Input" then
        InputTitle.Position = UDim2.new(0, iconOffset, 0, 10)
        InputTitle.Size = UDim2.new(1, -180, 0, 13)
        local InputContent = Instance.new("TextLabel")
        InputContent.Font = Enum.Font.GothamBold
        InputContent.Text = cfg.Content
        InputContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputContent.TextSize = 12
        InputContent.TextTransparency = 0.6
        InputContent.TextWrapped = true
        InputContent.TextXAlignment = Enum.TextXAlignment.Left
        InputContent.TextYAlignment = Enum.TextYAlignment.Bottom
        InputContent.BackgroundTransparency = 1
        InputContent.Position = UDim2.new(0, iconOffset, 0, 25)
        InputContent.Size = UDim2.new(1, -180, 0, 12)
        InputContent.Name = "InputContent"
        InputContent.Parent = Input
        InputContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (InputContent.TextBounds.X // math.max(1, InputContent.AbsoluteSize.X))))
        Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)
        InputContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            InputContent.TextWrapped = false
            InputContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (InputContent.TextBounds.X // math.max(1, InputContent.AbsoluteSize.X))))
            Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)
            InputContent.TextWrapped = true
            if updateSectionSize then updateSectionSize() end
        end)
        local InputFrame = Instance.new("Frame")
        InputFrame.AnchorPoint = Vector2.new(1, 0.5)
        InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputFrame.BackgroundTransparency = 0.95
        InputFrame.BorderSizePixel = 0
        InputFrame.ClipsDescendants = true
        InputFrame.Position = UDim2.new(1, -7, 0.5, 0)
        InputFrame.Size = UDim2.new(0, 148, 0, 30)
        InputFrame.Name = "InputFrame"
        InputFrame.Parent = Input
        Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 4)
        local boxIconOffset = 5
        if cfg.InputIcon and cfg.InputIcon ~= "" then
            local BoxIcon = Instance.new("ImageLabel")
            BoxIcon.Size = UDim2.new(0, 14, 0, 14)
            BoxIcon.AnchorPoint = Vector2.new(0, 0.5)
            BoxIcon.Position = UDim2.new(0, 6, 0.5, 0)
            BoxIcon.BackgroundTransparency = 1
            BoxIcon.ScaleType = Enum.ScaleType.Fit
            BoxIcon.Image = GetIconId(cfg.InputIcon)
            BoxIcon.ImageColor3 = Color3.fromRGB(160, 160, 160)
            BoxIcon.ImageTransparency = 0.2
            BoxIcon.Name = "BoxIcon"
            BoxIcon.Parent = InputFrame
            boxIconOffset = 24
        end
        InputTextBox = Instance.new("TextBox")
        InputTextBox.CursorPosition = -1
        InputTextBox.Font = Enum.Font.GothamBold
        InputTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        InputTextBox.PlaceholderText = cfg.Placeholder
        InputTextBox.Text = cfg.Default
        InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputTextBox.TextSize = 12
        InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
        InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
        InputTextBox.BackgroundTransparency = 1
        InputTextBox.BorderSizePixel = 0
        InputTextBox.Position = UDim2.new(0, boxIconOffset, 0.5, 0)
        InputTextBox.Size = UDim2.new(1, -boxIconOffset - 5, 1, -8)
        InputTextBox.ClearTextOnFocus = false
        InputTextBox.Name = "InputTextBox"
        InputTextBox.Parent = InputFrame
        InputTextBox.FocusLost:Connect(function()
            InputFunc:Set(InputTextBox.Text)
        end)
    else
        InputTitle.Position = UDim2.new(0, iconOffset, 0, 10)
        InputTitle.Size = UDim2.new(1, -20, 0, 13)
        if cfg.Content and cfg.Content ~= "" then
            local InputContent = Instance.new("TextLabel")
            InputContent.Font = Enum.Font.GothamBold
            InputContent.Text = cfg.Content
            InputContent.TextColor3 = Color3.fromRGB(255, 255, 255)
            InputContent.TextSize = 11
            InputContent.TextTransparency = 0.55
            InputContent.TextWrapped = true
            InputContent.TextXAlignment = Enum.TextXAlignment.Left
            InputContent.BackgroundTransparency = 1
            InputContent.Position = UDim2.new(0, iconOffset, 0, 26)
            InputContent.Size = UDim2.new(1, -20, 0, 12)
            InputContent.Name = "InputContent"
            InputContent.Parent = Input
        end
        local titleBottom = (cfg.Content and cfg.Content ~= "") and 42 or 30
        local TextareaFrame = Instance.new("Frame")
        TextareaFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextareaFrame.BackgroundTransparency = 0.95
        TextareaFrame.BorderSizePixel = 0
        TextareaFrame.ClipsDescendants = true
        TextareaFrame.Position = UDim2.new(0, 8, 0, titleBottom)
        TextareaFrame.Size = UDim2.new(1, -16, 0, cfg.TextHeight)
        TextareaFrame.Name = "TextareaFrame"
        TextareaFrame.Parent = Input
        Instance.new("UICorner", TextareaFrame).CornerRadius = UDim.new(0, 5)
        local TAStroke = Instance.new("UIStroke")
        TAStroke.Color = Color3.fromRGB(255, 255, 255)
        TAStroke.Thickness = 1
        TAStroke.Transparency = 0.88
        TAStroke.Name = "TAStroke"
        TAStroke.Parent = TextareaFrame
        InputTextBox = Instance.new("TextBox")
        InputTextBox.Font = Enum.Font.GothamBold
        InputTextBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 110)
        InputTextBox.PlaceholderText = cfg.Placeholder
        InputTextBox.Text = cfg.Default
        InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputTextBox.TextSize = 12
        InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
        InputTextBox.TextYAlignment = Enum.TextYAlignment.Top
        InputTextBox.BackgroundTransparency = 1
        InputTextBox.BorderSizePixel = 0
        InputTextBox.Position = UDim2.new(0, 8, 0, 6)
        InputTextBox.Size = UDim2.new(1, -16, 1, -12)
        InputTextBox.ClearTextOnFocus = false
        InputTextBox.MultiLine = true
        InputTextBox.TextWrapped = true
        InputTextBox.Name = "InputTextBox"
        InputTextBox.Parent = TextareaFrame
        InputTextBox.Focused:Connect(function()
            TweenService:Create(TAStroke, TweenInfo.new(0.2), {
                Color = GuiConfig.Color, Transparency = 0.4
            }):Play()
        end)
        InputTextBox.FocusLost:Connect(function()
            TweenService:Create(TAStroke, TweenInfo.new(0.2), {
                Color = Color3.fromRGB(255, 255, 255), Transparency = 0.88
            }):Play()
            InputFunc:Set(InputTextBox.Text)
        end)
        local MIN_H = cfg.TextHeight
        local function UpdateTextareaSize()
            task.wait()
            local lines = math.max(1, InputTextBox.TextBounds.Y)
            local newH = math.max(MIN_H, lines + 18)
            TextareaFrame.Size = UDim2.new(1, -16, 0, newH)
            Input.Size = UDim2.new(1, 0, 0, titleBottom + newH + 10)
            if updateSectionSize then updateSectionSize() end
        end
        InputTextBox:GetPropertyChangedSignal("TextBounds"):Connect(UpdateTextareaSize)
        Input.Size = UDim2.new(1, 0, 0, titleBottom + cfg.TextHeight + 10)
    end
    function InputFunc:Set(Value)
        Value = tostring(Value or "")
        InputFunc.Value = Value
        InputTextBox.Text = Value
        ConfigData[configKey] = Value
        SaveConfig()
        SafeCall(cfg.Callback, Value)
    end
    function InputFunc:GetValue()
        return InputFunc.Value
    end
    function InputFunc:Clear()
        InputFunc:Set("")
    end
    function InputFunc:SetTitle(text)
        InputTitle.Text = tostring(text or "Title")
    end
    function InputFunc:GetTitle()
        return InputTitle.Text
    end
    local LockFunc = ApplyLock(Input, cfg.Locked)
    function InputFunc:SetLocked(state)
        LockFunc:SetLocked(state)
    end
    function InputFunc:GetLocked()
        return LockFunc:GetLocked()
    end
    function InputFunc:SetLockMessage(text)
        LockFunc:SetMessage(text)
    end
    InputFunc:Set(InputFunc.Value)
    Elements_Table[configKey] = InputFunc
    return InputFunc
end
function Elements:CreateDropdown(parent, config, countItem, countDropdown, DropdownFolder, MoreBlur, DropdownSelect, DropPageLayout, Elements_Table)
    local cfg = config or {}
    cfg.Title    = cfg.Title    or "Title"
    cfg.Content  = cfg.Content  or ""
    cfg.Multi    = cfg.Multi    or false
    cfg.Options  = cfg.Options  or {}
    cfg.Default  = cfg.Default  or (cfg.Multi and {} or nil)
    cfg.Callback = cfg.Callback or function() end
    cfg.Badge    = cfg.Badge    or nil
    cfg.Locked   = cfg.Locked   or false
    -- Flag support: Flag takes priority over Title for config key
    local configKey = ResolveKey("Dropdown", cfg)
    if ConfigData[configKey] ~= nil then
        cfg.Default = ConfigData[configKey]
    end
    local DropdownFunc = { Value = cfg.Default, Options = {} }
    local Dropdown           = Instance.new("Frame")
    local DropdownButton     = Instance.new("TextButton")
    local UICorner10         = Instance.new("UICorner")
    local DropdownTitle      = Instance.new("TextLabel")
    local DropdownContent    = Instance.new("TextLabel")
    local SelectOptionsFrame = Instance.new("Frame")
    local UICorner11         = Instance.new("UICorner")
    local OptionSelecting    = Instance.new("TextLabel")
    local OptionImg          = Instance.new("ImageLabel")
    Dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dropdown.BackgroundTransparency = 0.935
    Dropdown.BorderSizePixel = 0
    Dropdown.LayoutOrder = countItem
    Dropdown.Size = UDim2.new(1, 0, 0, 46)
    Dropdown.Name = "Dropdown"
    Dropdown.Parent = parent
    DropdownButton.Text = ""
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.AutoButtonColor = false
    DropdownButton.Size = UDim2.new(1, 0, 1, 0)
    DropdownButton.Name = "ToggleButton"
    DropdownButton.Parent = Dropdown
    UICorner10.CornerRadius = UDim.new(0, 4)
    UICorner10.Parent = Dropdown
    if cfg.Badge then CreateBadge(Dropdown, cfg.Badge) end
    DropdownTitle.Font = Enum.Font.GothamBold
    DropdownTitle.Text = cfg.Title
    DropdownTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
    DropdownTitle.TextSize = 13
    DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
    DropdownTitle.BackgroundTransparency = 1
    DropdownTitle.Position = UDim2.new(0, 10, 0, 10)
    DropdownTitle.Size = UDim2.new(1, -180, 0, 13)
    DropdownTitle.Name = "DropdownTitle"
    DropdownTitle.Parent = Dropdown
    DropdownContent.Font = Enum.Font.GothamBold
    DropdownContent.Text = cfg.Content
    DropdownContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownContent.TextSize = 12
    DropdownContent.TextTransparency = 0.6
    DropdownContent.TextWrapped = true
    DropdownContent.TextXAlignment = Enum.TextXAlignment.Left
    DropdownContent.BackgroundTransparency = 1
    DropdownContent.Position = UDim2.new(0, 10, 0, 25)
    DropdownContent.Size = UDim2.new(1, -180, 0, 12)
    DropdownContent.Name = "DropdownContent"
    DropdownContent.Parent = Dropdown
    DropdownContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (DropdownContent.TextBounds.X // math.max(1, DropdownContent.AbsoluteSize.X))))
    Dropdown.Size = UDim2.new(1, 0, 0, DropdownContent.AbsoluteSize.Y + 33)
    DropdownContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        DropdownContent.TextWrapped = false
        DropdownContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (DropdownContent.TextBounds.X // math.max(1, DropdownContent.AbsoluteSize.X))))
        Dropdown.Size = UDim2.new(1, 0, 0, DropdownContent.AbsoluteSize.Y + 33)
        DropdownContent.TextWrapped = true
    end)
    SelectOptionsFrame.AnchorPoint = Vector2.new(1, 0.5)
    SelectOptionsFrame.BackgroundTransparency = 0.95
    SelectOptionsFrame.Position = UDim2.new(1, -7, 0.5, 0)
    SelectOptionsFrame.Size = UDim2.new(0, 148, 0, 30)
    SelectOptionsFrame.Name = "SelectOptionsFrame"
    SelectOptionsFrame.LayoutOrder = countDropdown
    SelectOptionsFrame.Parent = Dropdown
    UICorner11.CornerRadius = UDim.new(0, 4)
    UICorner11.Parent = SelectOptionsFrame
    DropdownButton.Activated:Connect(function()
        if not MoreBlur.Visible then
            MoreBlur.Visible = true
            DropPageLayout:JumpToIndex(SelectOptionsFrame.LayoutOrder)
            TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(DropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, -11, 0.5, 0) }):Play()
        end
    end)
    OptionSelecting.Font = Enum.Font.GothamBold
    OptionSelecting.Text = cfg.Multi and "Select Options" or "Select Option"
    OptionSelecting.TextColor3 = Color3.fromRGB(255, 255, 255)
    OptionSelecting.TextSize = 12
    OptionSelecting.TextTransparency = 0.6
    OptionSelecting.TextXAlignment = Enum.TextXAlignment.Left
    OptionSelecting.AnchorPoint = Vector2.new(0, 0.5)
    OptionSelecting.BackgroundTransparency = 1
    OptionSelecting.Position = UDim2.new(0, 5, 0.5, 0)
    OptionSelecting.Size = UDim2.new(1, -30, 1, -8)
    OptionSelecting.Name = "OptionSelecting"
    OptionSelecting.Parent = SelectOptionsFrame
    OptionImg.Image = "rbxassetid://16851841101"
    OptionImg.ImageColor3 = Color3.fromRGB(230, 230, 230)
    OptionImg.AnchorPoint = Vector2.new(1, 0.5)
    OptionImg.BackgroundTransparency = 1
    OptionImg.Position = UDim2.new(1, 0, 0.5, 0)
    OptionImg.Size = UDim2.new(0, 25, 0, 25)
    OptionImg.Name = "OptionImg"
    OptionImg.Parent = SelectOptionsFrame
    local DropdownContainer = Instance.new("Frame")
    DropdownContainer.Size = UDim2.new(1, 0, 1, 0)
    DropdownContainer.BackgroundTransparency = 1
    DropdownContainer.Parent = DropdownFolder
    local SearchBox = Instance.new("TextBox")
    SearchBox.PlaceholderText = "Search"
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.Text = ""
    SearchBox.TextSize = 12
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SearchBox.BackgroundTransparency = 0.9
    SearchBox.BorderSizePixel = 0
    SearchBox.Size = UDim2.new(1, 0, 0, 25)
    SearchBox.Position = UDim2.new(0, 0, 0, 0)
    SearchBox.ClearTextOnFocus = false
    SearchBox.Name = "SearchBox"
    SearchBox.Parent = DropdownContainer
    local ScrollSelect = Instance.new("ScrollingFrame")
    ScrollSelect.Size = UDim2.new(1, 0, 1, -30)
    ScrollSelect.Position = UDim2.new(0, 0, 0, 30)
    ScrollSelect.ScrollBarImageTransparency = 1
    ScrollSelect.BorderSizePixel = 0
    ScrollSelect.BackgroundTransparency = 1
    ScrollSelect.ScrollBarThickness = 0
    ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollSelect.Name = "ScrollSelect"
    ScrollSelect.Parent = DropdownContainer
    local UIListLayout4 = Instance.new("UIListLayout")
    UIListLayout4.Padding = UDim.new(0, 3)
    UIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout4.Parent = ScrollSelect
    UIListLayout4:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, UIListLayout4.AbsoluteContentSize.Y)
    end)
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        for _, option in pairs(ScrollSelect:GetChildren()) do
            if option.Name == "Option" and option:FindFirstChild("OptionText") then
                local text = string.lower(option.OptionText.Text)
                option.Visible = query == "" or string.find(text, query, 1, true) ~= nil
            end
        end
    end)
    local AllButton
    if cfg.Multi then
        AllButton = Instance.new("Frame")
        Instance.new("UICorner", AllButton).CornerRadius = UDim.new(0, 3)
        AllButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        AllButton.BackgroundTransparency = 0.97
        AllButton.BorderSizePixel = 0
        AllButton.Size = UDim2.new(1, 0, 0, 22)
        AllButton.LayoutOrder = -1
        AllButton.Name = "AllButton"
        AllButton.Parent = ScrollSelect
        local AllFeatureFrame = Instance.new("Frame")
        AllFeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
        AllFeatureFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        AllFeatureFrame.BackgroundTransparency = 0.93
        AllFeatureFrame.BorderSizePixel = 0
        AllFeatureFrame.Position = UDim2.new(1, -6, 0.5, 0)
        AllFeatureFrame.Size = UDim2.new(0, 22, 0, 11)
        AllFeatureFrame.Name = "AllFeatureFrame"
        AllFeatureFrame.Parent = AllButton
        Instance.new("UICorner", AllFeatureFrame)
        local AllStroke = Instance.new("UIStroke")
        AllStroke.Color = Color3.fromRGB(255, 255, 255)
        AllStroke.Thickness = 1
        AllStroke.Transparency = 0.85
        AllStroke.Name = "AllStroke"
        AllStroke.Parent = AllFeatureFrame
        local AllCircle = Instance.new("Frame")
        AllCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        AllCircle.BorderSizePixel = 0
        AllCircle.Position = UDim2.new(0, 1, 0, 1)
        AllCircle.Size = UDim2.new(0, 9, 0, 9)
        AllCircle.Name = "AllCircle"
        AllCircle.Parent = AllFeatureFrame
        Instance.new("UICorner", AllCircle).CornerRadius = UDim.new(1, 0)
        local AllText = Instance.new("TextLabel")
        AllText.Font = Enum.Font.Gotham
        AllText.Text = "All"
        AllText.TextSize = 10
        AllText.TextColor3 = Color3.fromRGB(200, 200, 200)
        AllText.TextTransparency = 0.45
        AllText.Position = UDim2.new(0, 7, 0, 0)
        AllText.Size = UDim2.new(1, -40, 1, 0)
        AllText.BackgroundTransparency = 1
        AllText.TextXAlignment = Enum.TextXAlignment.Left
        AllText.TextYAlignment = Enum.TextYAlignment.Center
        AllText.Name = "AllText"
        AllText.Parent = AllButton
        local AllDivider = Instance.new("Frame")
        AllDivider.Size = UDim2.new(1, -12, 0, 1)
        AllDivider.Position = UDim2.new(0, 6, 1, -1)
        AllDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        AllDivider.BackgroundTransparency = 0.92
        AllDivider.BorderSizePixel = 0
        AllDivider.Name = "AllDivider"
        AllDivider.Parent = AllButton
        local AllButtonClick = Instance.new("TextButton")
        AllButtonClick.BackgroundTransparency = 1
        AllButtonClick.AutoButtonColor = false
        AllButtonClick.Size = UDim2.new(1, 0, 1, 0)
        AllButtonClick.Text = ""
        AllButtonClick.ZIndex = 2
        AllButtonClick.Name = "AllButtonClick"
        AllButtonClick.Parent = AllButton
        AllButtonClick.Activated:Connect(function()
            local allValues = {}
            for _, opt in ipairs(DropdownFunc.Options) do
                local v = (typeof(opt) == "table" and opt.Value ~= nil) and opt.Value or opt
                table.insert(allValues, v)
            end
            local allSelected = #allValues > 0
            for _, v in ipairs(allValues) do
                if not table.find(DropdownFunc.Value, v) then
                    allSelected = false
                    break
                end
            end
            if allSelected then
                DropdownFunc:Set({})
            else
                DropdownFunc:Set(allValues)
            end
        end)
    end
    function DropdownFunc:Clear()
        for _, child in ScrollSelect:GetChildren() do
            if child.Name == "Option" then child:Destroy() end
        end
        DropdownFunc.Value   = cfg.Multi and {} or nil
        DropdownFunc.Options = {}
        OptionSelecting.Text = cfg.Multi and "Select Options" or "Select Option"
        if AllButton then
            local af = AllButton:FindFirstChild("AllFeatureFrame")
            local st = af and af:FindFirstChild("AllStroke")
            local ac = af and af:FindFirstChild("AllCircle")
            local at = AllButton:FindFirstChild("AllText")
            if af then TweenService:Create(af, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.93 }):Play() end
            if st then TweenService:Create(st, TweenInfo.new(0.2), { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.85 }):Play() end
            if ac then TweenService:Create(ac, TweenInfo.new(0.2), { Position = UDim2.new(0, 1, 0, 1), BackgroundColor3 = Color3.fromRGB(200, 200, 200) }):Play() end
            if at then TweenService:Create(at, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(200, 200, 200), TextTransparency = 0.45 }):Play() end
            TweenService:Create(AllButton, TweenInfo.new(0.2), { BackgroundTransparency = 0.97 }):Play()
        end
    end
    function DropdownFunc:AddOption(option)
        local label, value
        if typeof(option) == "table" and option.Label and option.Value ~= nil then
            label = tostring(option.Label)
            value = option.Value
        else
            label = tostring(option)
            value = option
        end
        table.insert(DropdownFunc.Options, option)
        local Option = Instance.new("Frame")
        Instance.new("UICorner", Option).CornerRadius = UDim.new(0, 3)
        Option.BackgroundTransparency = 0.999
        Option.Size = UDim2.new(1, 0, 0, 30)
        Option.Name = "Option"
        Option.Parent = ScrollSelect
        local OptionButton = Instance.new("TextButton")
        OptionButton.BackgroundTransparency = 1
        OptionButton.AutoButtonColor = false
        OptionButton.Size = UDim2.new(1, 0, 1, 0)
        OptionButton.Text = ""
        OptionButton.Name = "OptionButton"
        OptionButton.Parent = Option
        local OptionText = Instance.new("TextLabel")
        OptionText.Font = Enum.Font.GothamBold
        OptionText.Text = label
        OptionText.TextSize = 13
        OptionText.TextColor3 = Color3.fromRGB(230, 230, 230)
        OptionText.Position = UDim2.new(0, 8, 0, 8)
        OptionText.Size = UDim2.new(1, -100, 0, 13)
        OptionText.BackgroundTransparency = 1
        OptionText.TextXAlignment = Enum.TextXAlignment.Left
        OptionText.Name = "OptionText"
        OptionText.Parent = Option
        Option:SetAttribute("RealValue", value)
        local ChooseFrame = Instance.new("Frame")
        ChooseFrame.AnchorPoint = Vector2.new(0, 0.5)
        ChooseFrame.BackgroundColor3 = GuiConfig.Color
        ChooseFrame.Position = UDim2.new(0, 2, 0.5, 0)
        ChooseFrame.Size = UDim2.new(0, 0, 0, 0)
        ChooseFrame.Name = "ChooseFrame"
        ChooseFrame.Parent = Option
        Instance.new("UICorner", ChooseFrame)
        local UIStroke = Instance.new("UIStroke")
        UIStroke.Color = GuiConfig.Color
        UIStroke.Thickness = 1.6
        UIStroke.Transparency = 0.999
        UIStroke.Name = "UIStroke"
        UIStroke.Parent = ChooseFrame
        OptionButton.Activated:Connect(function()
            if cfg.Multi then
                local idx = table.find(DropdownFunc.Value, value)
                if not idx then
                    table.insert(DropdownFunc.Value, value)
                else
                    table.remove(DropdownFunc.Value, idx)
                end
                DropdownFunc:Set(DropdownFunc.Value)
            else
                if DropdownFunc.Value == value then
                    DropdownFunc:Set(nil)
                else
                    DropdownFunc:Set(value)
                end
            end
        end)
    end
    function DropdownFunc:Set(Value)
        if cfg.Multi then
            if type(Value) == "table" then
                DropdownFunc.Value = Value
            elseif Value == nil then
                DropdownFunc.Value = {}
            else
                DropdownFunc.Value = { Value }
            end
        else
            if type(Value) == "table" then
                DropdownFunc.Value = Value[1]
            else
                DropdownFunc.Value = Value
            end
        end
        ConfigData[configKey] = DropdownFunc.Value
        SaveConfig()
        local texts = {}
        for _, Drop in ScrollSelect:GetChildren() do
            if Drop.Name == "Option" and Drop:FindFirstChild("OptionText") then
                local v = Drop:GetAttribute("RealValue")
                local selected = cfg.Multi
                    and (type(DropdownFunc.Value) == "table" and table.find(DropdownFunc.Value, v) ~= nil)
                    or (DropdownFunc.Value == v)
                local cf = Drop:FindFirstChild("ChooseFrame")
                local st = cf and cf:FindFirstChild("UIStroke")
                if selected then
                    if cf then TweenService:Create(cf, TweenInfo.new(0.2), { Size = UDim2.new(0, 1, 0, 12) }):Play() end
                    if st then TweenService:Create(st, TweenInfo.new(0.2), { Transparency = 0 }):Play() end
                    TweenService:Create(Drop, TweenInfo.new(0.2), { BackgroundTransparency = 0.935 }):Play()
                    table.insert(texts, Drop.OptionText.Text)
                else
                    if cf then TweenService:Create(cf, TweenInfo.new(0.1), { Size = UDim2.new(0, 0, 0, 0) }):Play() end
                    if st then TweenService:Create(st, TweenInfo.new(0.1), { Transparency = 0.999 }):Play() end
                    TweenService:Create(Drop, TweenInfo.new(0.1), { BackgroundTransparency = 0.999 }):Play()
                end
            end
        end
        OptionSelecting.Text = (#texts == 0)
            and (cfg.Multi and "Select Options" or "Select Option")
            or table.concat(texts, ", ")
        if cfg.Multi and AllButton then
            local allValues = {}
            for _, opt in ipairs(DropdownFunc.Options) do
                local v = (typeof(opt) == "table" and opt.Value ~= nil) and opt.Value or opt
                table.insert(allValues, v)
            end
            local allSelected = #allValues > 0
            for _, v in ipairs(allValues) do
                if not table.find(DropdownFunc.Value, v) then
                    allSelected = false
                    break
                end
            end
            local af = AllButton:FindFirstChild("AllFeatureFrame")
            local st = af and af:FindFirstChild("AllStroke")
            local ac = af and af:FindFirstChild("AllCircle")
            local at = AllButton:FindFirstChild("AllText")
            if allSelected then
                TweenService:Create(AllButton, TweenInfo.new(0.2), { BackgroundTransparency = 0.93 }):Play()
                if at then TweenService:Create(at, TweenInfo.new(0.2), { TextColor3 = GuiConfig.Color, TextTransparency = 0.2 }):Play() end
                if ac then TweenService:Create(ac, TweenInfo.new(0.2), { Position = UDim2.new(0, 11, 0, 1), BackgroundColor3 = GuiConfig.Color }):Play() end
                if st then TweenService:Create(st, TweenInfo.new(0.2), { Color = GuiConfig.Color, Transparency = 0.5 }):Play() end
                if af then TweenService:Create(af, TweenInfo.new(0.2), { BackgroundColor3 = GuiConfig.Color, BackgroundTransparency = 0.7 }):Play() end
            else
                TweenService:Create(AllButton, TweenInfo.new(0.2), { BackgroundTransparency = 0.97 }):Play()
                if at then TweenService:Create(at, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(200, 200, 200), TextTransparency = 0.45 }):Play() end
                if ac then TweenService:Create(ac, TweenInfo.new(0.2), { Position = UDim2.new(0, 1, 0, 1), BackgroundColor3 = Color3.fromRGB(200, 200, 200) }):Play() end
                if st then TweenService:Create(st, TweenInfo.new(0.2), { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.85 }):Play() end
                if af then TweenService:Create(af, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.93 }):Play() end
            end
        end
        if cfg.Multi then
            SafeCall(cfg.Callback, DropdownFunc.Value)
        else
            SafeCall(cfg.Callback, DropdownFunc.Value ~= nil and tostring(DropdownFunc.Value) or nil)
        end
    end
    function DropdownFunc:SetValue(val) self:Set(val) end
    function DropdownFunc:GetValue() return self.Value end
    function DropdownFunc:SetValues(newList, selecting)
        newList   = newList   or {}
        selecting = selecting or (cfg.Multi and {} or nil)
        DropdownFunc:Clear()
        for _, v in ipairs(newList) do
            DropdownFunc:AddOption(v)
        end
        DropdownFunc:Set(selecting)
    end
    local LockFunc = ApplyLock(Dropdown, cfg.Locked)
    function DropdownFunc:SetLocked(state)
        LockFunc:SetLocked(state)
    end
    function DropdownFunc:GetLocked()
        return LockFunc:GetLocked()
    end
    function DropdownFunc:SetLockMessage(text)
        LockFunc:SetMessage(text)
    end
    DropdownFunc:SetValues(cfg.Options, cfg.Default)
    Elements_Table[configKey] = DropdownFunc
    return DropdownFunc
end
function Elements:CreateDivider(parent, countItem)
    local Divider = Instance.new("Frame")
    Divider.Name = "Divider"
    Divider.AnchorPoint = Vector2.new(0.5, 0)
    Divider.Position = UDim2.new(0.5, 0, 0, 0)
    Divider.Size = UDim2.new(1, 0, 0, 2)
    Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Divider.BackgroundTransparency = 0
    Divider.BorderSizePixel = 0
    Divider.LayoutOrder = countItem
    Divider.Parent = parent
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
        ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20)),
    }
    UIGradient.Parent = Divider
    Instance.new("UICorner", Divider).CornerRadius = UDim.new(0, 2)
    return Divider
end
function Elements:CreateSubSection(parent, title, countItem)
    title = title or "Sub Section"
    local SubSection = Instance.new("Frame")
    SubSection.Name = "SubSection"
    SubSection.BackgroundTransparency = 1
    SubSection.Size = UDim2.new(1, 0, 0, 22)
    SubSection.LayoutOrder = countItem
    SubSection.Parent = parent
    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Background.BackgroundTransparency = 0.935
    Background.BorderSizePixel = 0
    Background.Parent = SubSection
    Instance.new("UICorner", Background).CornerRadius = UDim.new(0, 6)
    local Label = Instance.new("TextLabel")
    Label.AnchorPoint = Vector2.new(0, 0.5)
    Label.Position = UDim2.new(0, 10, 0.5, 0)
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = "── [ " .. title .. " ] ──"
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SubSection
    return SubSection
end
return Elements
