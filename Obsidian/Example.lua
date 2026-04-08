local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true
Library.NotifyOnError = false

local Window = Library:CreateWindow({
	Title = "Obsidian",
	Footer = "version: full",
	Icon = 95816097006870,
	Center = true,
	AutoShow = true,
	Resizable = true,
	NotifySide = "Right",
	ShowCustomCursor = true,
	EnableSidebarResize = true,
	EnableCompacting = true,
	SidebarCompacted = false,
	MinSidebarWidth = 128,
	ToggleKeybind = Enum.KeyCode.RightControl,
	MobileButtonsSide = "Left",
	GlobalSearch = false,
})

local Tabs = {
	Main = Window:AddTab("Main", "house"),
	Sliders = Window:AddTab("Sliders", "sliders-horizontal"),
	Dropdowns = Window:AddTab("Dropdowns", "chevrons-up-down"),
	Pickers = Window:AddTab("Pickers", "pipette"),
	Notify = Window:AddTab("Notify", "bell"),
	Key = Window:AddKeyTab("Key System"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

Tabs["UI Settings"]:UpdateWarningBox({
	Visible = true,
	Title = "Warning",
	Text = "Changes here affect the global UI appearance.",
})

local LeftGroup = Tabs.Main:AddLeftGroupbox("Controls", "toggle-right")
local RightGroup = Tabs.Main:AddRightGroupbox("Actions", "mouse-pointer-click")

LeftGroup:AddToggle("MyToggle", {
	Text = "Enable feature",
	Default = true,
	Risky = false,
	Tooltip = "Turns the main feature on/off",
	DisabledTooltip = "Locked",
	Disabled = false,
	Visible = true,
	Callback = function(Value)
		print("[cb] MyToggle:", Value)
	end,
})
:AddColorPicker("ToggleColor", {
	Default = Color3.fromRGB(125, 85, 255),
	Title = "Feature color",
	Transparency = 0,
	Callback = function(Value)
		print("[cb] ToggleColor:", Value)
	end,
})
:AddKeyPicker("ToggleKey", {
	Default = "F",
	Mode = "Toggle",
	SyncToggleState = true,
	Text = "Feature keybind",
	NoUI = false,
	Callback = function(Value)
		print("[cb] ToggleKey state:", Value)
	end,
	ChangedCallback = function(NewKey, NewMods)
		print("[cb] ToggleKey changed:", NewKey, table.unpack(NewMods or {}))
	end,
})

Toggles.MyToggle:OnChanged(function()
	print("MyToggle:", Toggles.MyToggle.Value)
end)

Toggles.MyToggle:SetValue(false)

LeftGroup:AddToggle("RiskyToggle", {
	Text = "Risky action",
	Default = false,
	Risky = true,
	Tooltip = "This is risky",
	Callback = function(Value)
		print("[cb] RiskyToggle:", Value)
	end,
})

LeftGroup:AddDivider()

LeftGroup:AddCheckbox("MyCheckbox", {
	Text = "Checkbox option",
	Default = true,
	Tooltip = "Always box style",
	DisabledTooltip = "Locked",
	Disabled = false,
	Visible = true,
	Callback = function(Value)
		print("[cb] MyCheckbox:", Value)
	end,
})

Toggles.MyCheckbox:OnChanged(function()
	print("MyCheckbox:", Toggles.MyCheckbox.Value)
end)

local DepBox = LeftGroup:AddDependencyBox()
DepBox:SetupDependencies({ { Toggles.MyToggle, true } })

DepBox:AddToggle("SubToggle", {
	Text = "Sub-feature",
	Default = false,
	Callback = function(Value)
		print("[cb] SubToggle:", Value)
	end,
})

DepBox:AddSlider("SubSlider", {
	Text = "Sub intensity",
	Default = 50,
	Min = 0,
	Max = 100,
	Rounding = 0,
	Suffix = "%",
})

LeftGroup:AddDivider({ Text = "Labels" })

LeftGroup:AddLabel("Plain label")
LeftGroup:AddLabel("Wrapping label\n\nLine two here.", true)
LeftGroup:AddLabel("IndexedLabel", {
	Text = "Label with index",
	DoesWrap = false,
})

task.delay(3, function()
	if Options.IndexedLabel then
		Options.IndexedLabel:SetText("Updated at t=3s")
	end
end)

local MyButton = RightGroup:AddButton({
	Text = "Run action",
	Func = function()
		print("Action ran!")
	end,
	DoubleClick = false,
	Tooltip = "Single click",
	DisabledTooltip = "Locked",
	Disabled = false,
	Visible = true,
	Risky = false,
})

MyButton:AddButton({
	Text = "Confirm (double-click)",
	Func = function()
		print("Confirmed!")
	end,
	DoubleClick = true,
	Tooltip = "Double click to confirm",
})

RightGroup:AddButton({
	Text = "Disabled",
	Func = function() end,
	Disabled = true,
	Tooltip = "Can't click",
	DisabledTooltip = "Disabled",
})

RightGroup:AddButton({
	Text = "Risky delete",
	Func = function()
		print("Deleted!")
	end,
	Risky = true,
})

RightGroup:AddDivider({ Text = "Collapse demo" })

RightGroup:AddButton({
	Text = "Toggle left group collapse",
	Func = function()
		LeftGroup:ToggleCollapsed()
	end,
})

RightGroup:AddButton({
	Text = "Collapse left group",
	Func = function()
		LeftGroup:SetCollapsed(true)
	end,
})

RightGroup:AddButton({
	Text = "Expand left group",
	Func = function()
		LeftGroup:SetCollapsed(false)
	end,
})

local TabBox = Tabs.Main:AddRightTabbox()

local Tab1 = TabBox:AddTab("Tab 1")
Tab1:AddToggle("Tab1Toggle", { Text = "Tab 1 toggle", Default = false })
Tab1:AddSlider("Tab1Slider", { Text = "Tab 1 slider", Default = 10, Min = 0, Max = 100, Rounding = 0 })

local Tab2 = TabBox:AddTab("Tab 2")
Tab2:AddToggle("Tab2Toggle", { Text = "Tab 2 toggle", Default = true })
Tab2:AddInput("Tab2Input", { Text = "Tab 2 input", Default = "hello", Placeholder = "type here" })

local SliderLeft = Tabs.Sliders:AddLeftGroupbox("Sliders")
local SliderRight = Tabs.Sliders:AddRightGroupbox("Inputs & Special")

SliderLeft:AddSlider("Slider1", {
	Text = "Walk speed",
	Default = 16,
	Min = 0,
	Max = 250,
	Rounding = 0,
	Suffix = " st/s",
	Tooltip = "Drag to see live tooltip",
	DisabledTooltip = "Locked",
	Disabled = false,
	Visible = true,
	Callback = function(Value)
		print("[cb] Slider1:", Value)
	end,
})

Options.Slider1:OnChanged(function()
	print("Slider1:", Options.Slider1.Value)
end)

Options.Slider1:SetValue(50)

SliderLeft:AddSlider("Slider2", {
	Text = "Jump power",
	Default = 50,
	Min = 0,
	Max = 500,
	Rounding = 0,
	Prefix = "×",
})

SliderLeft:AddSlider("SliderCompact", {
	Text = "Volume",
	Default = 70,
	Min = 0,
	Max = 100,
	Rounding = 0,
	Compact = true,
	Suffix = "%",
})

SliderLeft:AddSlider("SliderHideMax", {
	Text = "Opacity",
	Default = 80,
	Min = 0,
	Max = 100,
	Rounding = 0,
	HideMax = true,
	Suffix = "%",
})

SliderLeft:AddSlider("SliderFormatted", {
	Text = "Quality",
	Default = 2,
	Min = 1,
	Max = 4,
	Rounding = 0,
	FormatDisplayValue = function(slider, value)
		return ({ "Low", "Medium", "High", "Ultra" })[value] or tostring(value)
	end,
})

SliderLeft:AddSlider("SliderDisabled", {
	Text = "Locked slider",
	Default = 30,
	Min = 0,
	Max = 100,
	Rounding = 0,
	Disabled = true,
	DisabledTooltip = "This slider is locked",
})

SliderRight:AddSlider("DynSlider", {
	Text = "Dynamic range",
	Default = 50,
	Min = 0,
	Max = 100,
	Rounding = 1,
})

SliderRight:AddButton({
	Text = "Halve max",
	Func = function()
		local s = Options.DynSlider
		s:SetMax(math.max(s.Min + 1, math.floor(s.Max / 2)))
	end,
})

SliderRight:AddButton({
	Text = "Double max",
	Func = function()
		Options.DynSlider:SetMax(Options.DynSlider.Max * 2)
	end,
})

SliderRight:AddButton({
	Text = "Set min to 25",
	Func = function()
		Options.DynSlider:SetMin(25)
	end,
})

SliderRight:AddDivider({ Text = "Inputs" })

SliderRight:AddInput("TextInput", {
	Text = "Server note",
	Default = "",
	Placeholder = "Enter text…",
	Finished = true,
	ClearTextOnFocus = true,
	AllowEmpty = true,
	Tooltip = "Press Enter to confirm",
	Callback = function(Value)
		print("[cb] TextInput:", Value)
	end,
})

Options.TextInput:OnChanged(function()
	print("TextInput:", Options.TextInput.Value)
end)

SliderRight:AddInput("NumInput", {
	Text = "Player limit",
	Default = "10",
	Numeric = true,
	Finished = false,
	Placeholder = "0–100",
	Callback = function(Value)
		print("[cb] NumInput:", Value)
	end,
})

local DDLeft = Tabs.Dropdowns:AddLeftGroupbox("Single Dropdowns")
local DDRight = Tabs.Dropdowns:AddRightGroupbox("Multi & Special")

DDLeft:AddDropdown("DD1", {
	Values = { "Option A", "Option B", "Option C" },
	Default = 1,
	Multi = false,
	Text = "Basic dropdown",
	Tooltip = "Pick one",
	DisabledTooltip = "Locked",
	Disabled = false,
	Visible = true,
	Callback = function(Value)
		print("[cb] DD1:", Value)
	end,
})

Options.DD1:OnChanged(function()
	print("DD1:", Options.DD1.Value)
end)

Options.DD1:SetValue("Option B")

DDLeft:AddDropdown("DDSearchable", {
	Values = { "Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta" },
	Default = 1,
	Multi = false,
	Text = "Searchable dropdown",
	Searchable = true,
})

DDLeft:AddDropdown("DDDisabledVal", {
	Values = { "Yes", "No", "Maybe", "LOCKED" },
	DisabledValues = { "LOCKED" },
	Default = 1,
	Multi = false,
	Text = "Dropdown with disabled value",
})

DDLeft:AddDropdown("DDFormatted", {
	Values = { "low", "medium", "high", "ultra" },
	Default = 1,
	Multi = false,
	Text = "Display formatted dropdown",
	FormatDisplayValue = function(Value)
		return Value:sub(1,1):upper() .. Value:sub(2)
	end,
})

DDLeft:AddDropdown("DDLong", {
	Values = {
		"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P",
	},
	Default = 1,
	Multi = false,
	Text = "Long dropdown",
	MaxVisibleDropdownItems = 12,
	Searchable = true,
})

DDLeft:AddDropdown("DDDisabled", {
	Values = { "X", "Y", "Z" },
	Default = 1,
	Multi = false,
	Text = "Disabled dropdown",
	Disabled = true,
	DisabledTooltip = "Locked",
})

DDRight:AddDropdown("DDMulti", {
	Values = { "Fly", "Speed", "Noclip", "ESP", "Aimbot", "Bhop" },
	Default = 1,
	Multi = true,
	Text = "Multi-select dropdown",
	Callback = function()
		local sel = {}
		for k, v in pairs(Options.DDMulti.Value) do
			if v then table.insert(sel, k) end
		end
		print("[cb] DDMulti:", table.concat(sel, ", "))
	end,
})

Options.DDMulti:SetValue({ Fly = true, Speed = true })

DDRight:AddDivider({ Text = "Special types" })

DDRight:AddDropdown("DDPlayer", {
	SpecialType = "Player",
	ExcludeLocalPlayer = true,
	Text = "Player picker",
	Callback = function(Value)
		print("[cb] DDPlayer:", Value and Value.Name or "nil")
	end,
})

DDRight:AddDropdown("DDTeam", {
	SpecialType = "Team",
	Text = "Team picker",
	Callback = function(Value)
		print("[cb] DDTeam:", Value and Value.Name or "nil")
	end,
})

local PickLeft = Tabs.Pickers:AddLeftGroupbox("Color Pickers", "pipette")
local PickRight = Tabs.Pickers:AddRightGroupbox("Key Pickers", "key")

PickLeft:AddLabel("Stroke color")
	:AddColorPicker("StrokeColor", {
		Default = Color3.fromRGB(255, 255, 255),
		Title = "Stroke color",
		Transparency = 0,
		Callback = function(Value)
			print("[cb] StrokeColor:", Value)
		end,
	})

PickLeft:AddLabel("Fill color")
	:AddColorPicker("FillColor", {
		Default = Color3.fromRGB(0, 120, 255),
		Title = "Fill color",
		Transparency = 0.5,
		Callback = function(Value)
			print("[cb] FillColor:", Value)
		end,
	})

Options.FillColor:OnChanged(function()
	print("FillColor:", Options.FillColor.Value, "transparency:", Options.FillColor.Transparency)
end)

Options.StrokeColor:SetValueRGB(Color3.fromRGB(200, 200, 200))

PickLeft:AddDivider()

PickLeft:AddToggle("GlowToggle", {
	Text = "Glow effect",
	Default = false,
})
:AddColorPicker("GlowInner", {
	Default = Color3.fromRGB(255, 200, 0),
	Title = "Inner glow color",
})
:AddColorPicker("GlowOuter", {
	Default = Color3.fromRGB(255, 100, 0),
	Title = "Outer glow color",
	Transparency = 0.3,
})

PickRight:AddLabel("Toggle mode"):AddKeyPicker("KP_Toggle", {
	Default = "E",
	Mode = "Toggle",
	SyncToggleState = false,
	Text = "Toggle keybind",
	NoUI = false,
	Callback = function(Value)
		print("[cb] KP_Toggle state:", Value)
	end,
	ChangedCallback = function(NewKey, NewMods)
		print("[cb] KP_Toggle changed:", NewKey, table.unpack(NewMods or {}))
	end,
})

Options.KP_Toggle:OnClick(function()
	print("KP_Toggle clicked, state:", Options.KP_Toggle:GetState())
end)

Options.KP_Toggle:OnChanged(function()
	print("KP_Toggle key:", Options.KP_Toggle.Value, table.unpack(Options.KP_Toggle.Modifiers or {}))
end)

PickRight:AddLabel("Hold mode"):AddKeyPicker("KP_Hold", {
	Default = "MB2",
	Mode = "Hold",
	Text = "Hold to activate",
	Callback = function(Value)
		print("[cb] KP_Hold:", Value)
	end,
})

task.spawn(function()
	while task.wait(1) do
		if Library.Unloaded then break end
		if Options.KP_Hold and Options.KP_Hold:GetState() then
			print("KP_Hold is being held")
		end
	end
end)

PickRight:AddLabel("Press mode"):AddKeyPicker("KP_Press", {
	Default = "X",
	Mode = "Press",
	WaitForCallback = false,
	Text = "Press to fire",
	Callback = function()
		print("[cb] KP_Press fired")
	end,
})

Options.KP_Toggle:SetValue({ "G", "Hold" })

local NotifyLeft = Tabs.Notify:AddLeftGroupbox("Type Presets", "bell")
local NotifyRight = Tabs.Notify:AddRightGroupbox("Custom Notifications", "bell-dot")

NotifyLeft:AddButton({
	Text = "Success notify",
	Func = function()
		Library:Notify({
			Title = "Success",
			Description = "Operation completed successfully.",
			Type = "success",
			Time = 4,
		})
	end,
})

NotifyLeft:AddButton({
	Text = "Error notify",
	Func = function()
		Library:Notify({
			Title = "Error",
			Description = "Something went wrong. Please try again.",
			Type = "error",
			Time = 5,
		})
	end,
})

NotifyLeft:AddButton({
	Text = "Warning notify",
	Func = function()
		Library:Notify({
			Title = "Warning",
			Description = "Proceed with caution.",
			Type = "warning",
			Time = 4,
		})
	end,
})

NotifyLeft:AddButton({
	Text = "Info notify",
	Func = function()
		Library:Notify({
			Title = "Info",
			Description = "Here is some useful information.",
			Type = "info",
			Time = 4,
		})
	end,
})

NotifyLeft:AddDivider()

NotifyLeft:AddButton({
	Text = "Type + custom AccentColor",
	Func = function()
		Library:Notify({
			Title = "Custom accent",
			Description = "Type preset with overridden bar color.",
			Type = "success",
			AccentColor = Color3.fromRGB(0, 220, 180),
			Time = 4,
		})
	end,
})

NotifyRight:AddButton({
	Text = "Plain description only",
	Func = function()
		Library:Notify("This is a plain notification", 3)
	end,
})

NotifyRight:AddButton({
	Text = "Title + description",
	Func = function()
		Library:Notify({
			Title = "Hello",
			Description = "This is a standard notification.",
			Time = 4,
		})
	end,
})

NotifyRight:AddButton({
	Text = "With small icon",
	Func = function()
		Library:Notify({
			Title = "Shield active",
			Description = "Protection mode is now on.",
			Icon = "shield-check",
			IconColor = Color3.fromRGB(80, 200, 120),
			Time = 4,
		})
	end,
})

NotifyRight:AddButton({
	Text = "With big icon",
	Func = function()
		Library:Notify({
			Title = "Download complete",
			Description = "Your file has been saved.",
			BigIcon = "download",
			IconColor = Color3.fromRGB(80, 150, 255),
			Time = 4,
		})
	end,
})

NotifyRight:AddButton({
	Text = "Persistent notify",
	Func = function()
		local n = Library:Notify({
			Title = "Persistent",
			Description = "Will stay until dismissed.",
			Persist = true,
		})
		task.delay(6, function()
			if not n.Destroyed then
				n:Destroy()
			end
		end)
	end,
})

NotifyRight:AddButton({
	Text = "Stepped progress notify",
	Func = function()
		local n = Library:Notify({
			Title = "Loading…",
			Description = "Processing steps.",
			Steps = 5,
			Persist = true,
		})
		task.spawn(function()
			for i = 1, 5 do
				task.wait(0.6)
				n:ChangeStep(i)
				n:ChangeTitle("Step " .. i .. " / 5")
			end
			task.wait(0.5)
			n:Destroy()
		end)
	end,
})

NotifyRight:AddButton({
	Text = "With sound",
	Func = function()
		Library:Notify({
			Title = "Ding!",
			Description = "Notification with a sound.",
			SoundId = 9120273648,
			Time = 3,
		})
	end,
})

Tabs.Key:AddLabel({
	Text = "Enter the key below to unlock.",
	DoesWrap = true,
	Size = 16,
})

Tabs.Key:AddKeyBox(function(ReceivedKey)
	local Success = ReceivedKey == "Obsidian"
	print("Key attempt:", ReceivedKey, "| Success:", Success)
	Library:Notify({
		Title = Success and "Access granted" or "Wrong key",
		Description = "Received: " .. ReceivedKey,
		Type = Success and "success" or "error",
		Time = 4,
	})
end)

Library:AddDraggableLabel("Draggable Label")

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(Value)
		Library.KeybindFrame.Visible = Value
	end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})

MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",
	Text = "Notification Side",
	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})

MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",
	Text = "DPI Scale",
	Callback = function(Value)
		Library:SetDPIScale(tonumber(Value:gsub("%%", "")))
	end,
})

MenuGroup:AddSlider("UICornerSlider", {
	Text = "Corner Radius",
	Default = Library.CornerRadius,
	Min = 0,
	Max = 20,
	Rounding = 0,
	Callback = function(Value)
		Window:SetCornerRadius(Value)
	end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", {
		Default = "RightShift",
		NoUI = true,
		Text = "Menu keybind",
	})

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

Library:OnUnload(function()
	print("Unloaded!")
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("ObsidianFullExample")
SaveManager:SetFolder("ObsidianFullExample/game")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()
