--[[
    ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗    ██╗   ██╗██╗
    ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝    ██║   ██║██║
    ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗    ██║   ██║██║
    ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║    ██║   ██║██║
    ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║    ╚██████╔╝██║
    ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚═╝

    NexusUI — A Modern Roblox GUI Library
    Version: 1.0.0

    Features:
    - Clean, modern dark UI
    - Tabs, Buttons, Toggles, Sliders, Dropdowns, Inputs, Keybinds, Labels, Paragraphs, Color Pickers
    - Configuration saving/loading
    - Notifications system
    - Search functionality
    - Mobile support
    - Smooth animations
    - Multiple themes
    - Flags system for config saving

    Usage:
        local Nexus = loadstring(game:HttpGet("..."))()
        
        local Window = Nexus:CreateWindow({
            Title = "My Script",
            SubTitle = "v1.0",
            Theme = "Dark",           -- "Dark" | "Light" | "Midnight" | "Nord" | "Rose"
            Icon = "shield",          -- Lucide icon name or rbxassetid number
            ConfigSaving = {
                Enabled = true,
                FolderName = "NexusConfigs",
                FileName = "MyScript"
            },
            KeySystem = false,
            KeySettings = {
                Title = "Key Required",
                SubTitle = "Enter your key",
                Note = "Get key at discord.gg/example",
                FileName = "Key",
                SaveKey = true,
                Key = {"mykey123"}
            }
        })

        local Tab = Window:CreateTab("Main", "home")
        
        Tab:CreateButton({
            Name = "Click Me",
            Description = "Optional description",
            Callback = function() print("clicked") end
        })

        Tab:CreateToggle({
            Name = "My Toggle",
            Description = "Toggles something",
            Default = false,
            Flag = "MyToggle",
            Callback = function(val) print(val) end
        })

        Tab:CreateSlider({
            Name = "Speed",
            Description = "Player walkspeed",
            Min = 16, Max = 500,
            Default = 16,
            Increment = 1,
            Suffix = "studs/s",
            Flag = "Speed",
            Callback = function(val) print(val) end
        })

        Tab:CreateDropdown({
            Name = "Team",
            Description = "Select your team",
            Options = {"Red", "Blue", "Green"},
            Default = "Red",
            MultiSelect = false,
            Flag = "Team",
            Callback = function(val) print(val) end
        })

        Tab:CreateInput({
            Name = "Username",
            Description = "Enter a username",
            Placeholder = "Type here...",
            Default = "",
            ClearOnFocus = false,
            Flag = "Username",
            Callback = function(val) print(val) end
        })

        Tab:CreateKeybind({
            Name = "Toggle GUI",
            Description = "Keybind to toggle",
            Default = Enum.KeyCode.RightShift,
            Hold = false,
            Flag = "GUIToggle",
            Callback = function() print("pressed") end
        })

        Tab:CreateColorPicker({
            Name = "ESP Color",
            Description = "Color for ESP",
            Default = Color3.fromRGB(255, 0, 0),
            Flag = "ESPColor",
            Callback = function(color) print(color) end
        })

        Tab:CreateSection("Advanced")

        Tab:CreateLabel({
            Text = "This is a label",
            Icon = "info",
            Color = nil -- optional accent
        })

        Tab:CreateParagraph({
            Title = "Info",
            Content = "This is a long paragraph with information."
        })

        Window:Notify({
            Title = "Hello",
            Content = "Welcome to NexusUI!",
            Duration = 5,
            Icon = "bell"
        })

        Window:LoadConfig()
]]

-- ─── Services ────────────────────────────────────────────────────────────────

local function GetService(name)
    local s = game:GetService(name)
    return cloneref and cloneref(s) or s
end

local Players        = GetService("Players")
local TweenService   = GetService("TweenService")
local UserInputService = GetService("UserInputService")
local RunService     = GetService("RunService")
local HttpService    = GetService("HttpService")
local CoreGui        = GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ─── Utility ─────────────────────────────────────────────────────────────────

local function Tween(obj, props, t, style, dir)
    return TweenService:Create(obj,
        TweenInfo.new(t or 0.3, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

local function New(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, c in pairs(children or {}) do c.Parent = inst end
    return inst
end

local function Round(n, factor)
    return math.floor(n / factor + 0.5) * factor
end

local function Clamp(n, min, max) return math.clamp(n, min, max) end

-- ─── Themes ──────────────────────────────────────────────────────────────────

local Themes = {
    Dark = {
        Background       = Color3.fromRGB(18, 18, 22),
        Surface          = Color3.fromRGB(26, 26, 32),
        SurfaceHover     = Color3.fromRGB(32, 32, 40),
        Elevated         = Color3.fromRGB(34, 34, 42),
        Border           = Color3.fromRGB(52, 52, 64),
        BorderFocus      = Color3.fromRGB(100, 100, 130),
        Topbar           = Color3.fromRGB(22, 22, 28),
        Text             = Color3.fromRGB(235, 235, 245),
        TextMuted        = Color3.fromRGB(130, 130, 155),
        TextDisabled     = Color3.fromRGB(70, 70, 90),
        Accent           = Color3.fromRGB(99, 102, 241),
        AccentHover      = Color3.fromRGB(118, 121, 255),
        AccentDim        = Color3.fromRGB(40, 42, 100),
        Success          = Color3.fromRGB(52, 199, 89),
        Warning          = Color3.fromRGB(255, 159, 10),
        Error            = Color3.fromRGB(255, 69, 58),
        ToggleOn         = Color3.fromRGB(99, 102, 241),
        ToggleOff        = Color3.fromRGB(55, 55, 70),
        SliderFill       = Color3.fromRGB(99, 102, 241),
        SliderTrack      = Color3.fromRGB(40, 40, 55),
        Shadow           = Color3.fromRGB(8, 8, 12),
        TabActive        = Color3.fromRGB(99, 102, 241),
        TabInactive      = Color3.fromRGB(55, 55, 75),
        ScrollBar        = Color3.fromRGB(70, 70, 90),
        InputBg          = Color3.fromRGB(22, 22, 30),
        NotifBg          = Color3.fromRGB(26, 26, 34),
    },
    Midnight = {
        Background       = Color3.fromRGB(8, 10, 20),
        Surface          = Color3.fromRGB(14, 16, 30),
        SurfaceHover     = Color3.fromRGB(20, 22, 40),
        Elevated         = Color3.fromRGB(22, 24, 44),
        Border           = Color3.fromRGB(40, 45, 80),
        BorderFocus      = Color3.fromRGB(80, 90, 180),
        Topbar           = Color3.fromRGB(10, 12, 24),
        Text             = Color3.fromRGB(220, 225, 255),
        TextMuted        = Color3.fromRGB(110, 115, 160),
        TextDisabled     = Color3.fromRGB(55, 60, 90),
        Accent           = Color3.fromRGB(80, 120, 255),
        AccentHover      = Color3.fromRGB(100, 140, 255),
        AccentDim        = Color3.fromRGB(20, 35, 90),
        Success          = Color3.fromRGB(0, 210, 120),
        Warning          = Color3.fromRGB(255, 180, 0),
        Error            = Color3.fromRGB(255, 80, 80),
        ToggleOn         = Color3.fromRGB(80, 120, 255),
        ToggleOff        = Color3.fromRGB(35, 40, 70),
        SliderFill       = Color3.fromRGB(80, 120, 255),
        SliderTrack      = Color3.fromRGB(25, 30, 60),
        Shadow           = Color3.fromRGB(0, 0, 5),
        TabActive        = Color3.fromRGB(80, 120, 255),
        TabInactive      = Color3.fromRGB(35, 40, 70),
        ScrollBar        = Color3.fromRGB(55, 60, 100),
        InputBg          = Color3.fromRGB(10, 12, 25),
        NotifBg          = Color3.fromRGB(14, 16, 32),
    },
    Nord = {
        Background       = Color3.fromRGB(46, 52, 64),
        Surface          = Color3.fromRGB(59, 66, 82),
        SurfaceHover     = Color3.fromRGB(67, 76, 94),
        Elevated         = Color3.fromRGB(67, 76, 94),
        Border           = Color3.fromRGB(76, 86, 106),
        BorderFocus      = Color3.fromRGB(136, 192, 208),
        Topbar           = Color3.fromRGB(36, 42, 54),
        Text             = Color3.fromRGB(236, 239, 244),
        TextMuted        = Color3.fromRGB(144, 163, 195),
        TextDisabled     = Color3.fromRGB(90, 100, 120),
        Accent           = Color3.fromRGB(136, 192, 208),
        AccentHover      = Color3.fromRGB(160, 210, 224),
        AccentDim        = Color3.fromRGB(55, 80, 100),
        Success          = Color3.fromRGB(163, 190, 140),
        Warning          = Color3.fromRGB(235, 203, 139),
        Error            = Color3.fromRGB(191, 97, 106),
        ToggleOn         = Color3.fromRGB(136, 192, 208),
        ToggleOff        = Color3.fromRGB(67, 76, 94),
        SliderFill       = Color3.fromRGB(136, 192, 208),
        SliderTrack      = Color3.fromRGB(46, 52, 64),
        Shadow           = Color3.fromRGB(20, 24, 30),
        TabActive        = Color3.fromRGB(136, 192, 208),
        TabInactive      = Color3.fromRGB(67, 76, 94),
        ScrollBar        = Color3.fromRGB(76, 86, 106),
        InputBg          = Color3.fromRGB(36, 42, 54),
        NotifBg          = Color3.fromRGB(59, 66, 82),
    },
    Rose = {
        Background       = Color3.fromRGB(20, 16, 18),
        Surface          = Color3.fromRGB(30, 22, 26),
        SurfaceHover     = Color3.fromRGB(40, 30, 35),
        Elevated         = Color3.fromRGB(40, 30, 35),
        Border           = Color3.fromRGB(70, 45, 55),
        BorderFocus      = Color3.fromRGB(200, 100, 130),
        Topbar           = Color3.fromRGB(24, 18, 21),
        Text             = Color3.fromRGB(240, 230, 235),
        TextMuted        = Color3.fromRGB(160, 120, 140),
        TextDisabled     = Color3.fromRGB(90, 65, 75),
        Accent           = Color3.fromRGB(220, 80, 120),
        AccentHover      = Color3.fromRGB(240, 100, 140),
        AccentDim        = Color3.fromRGB(80, 25, 45),
        Success          = Color3.fromRGB(100, 200, 120),
        Warning          = Color3.fromRGB(240, 180, 60),
        Error            = Color3.fromRGB(255, 80, 80),
        ToggleOn         = Color3.fromRGB(220, 80, 120),
        ToggleOff        = Color3.fromRGB(65, 40, 50),
        SliderFill       = Color3.fromRGB(220, 80, 120),
        SliderTrack      = Color3.fromRGB(45, 28, 36),
        Shadow           = Color3.fromRGB(8, 4, 6),
        TabActive        = Color3.fromRGB(220, 80, 120),
        TabInactive      = Color3.fromRGB(65, 40, 50),
        ScrollBar        = Color3.fromRGB(100, 65, 80),
        InputBg          = Color3.fromRGB(18, 12, 15),
        NotifBg          = Color3.fromRGB(28, 20, 24),
    },
    Light = {
        Background       = Color3.fromRGB(248, 248, 252),
        Surface          = Color3.fromRGB(255, 255, 255),
        SurfaceHover     = Color3.fromRGB(242, 242, 248),
        Elevated         = Color3.fromRGB(255, 255, 255),
        Border           = Color3.fromRGB(220, 220, 232),
        BorderFocus      = Color3.fromRGB(99, 102, 241),
        Topbar           = Color3.fromRGB(240, 240, 248),
        Text             = Color3.fromRGB(30, 30, 45),
        TextMuted        = Color3.fromRGB(120, 120, 150),
        TextDisabled     = Color3.fromRGB(180, 180, 200),
        Accent           = Color3.fromRGB(99, 102, 241),
        AccentHover      = Color3.fromRGB(79, 82, 221),
        AccentDim        = Color3.fromRGB(220, 222, 255),
        Success          = Color3.fromRGB(40, 160, 70),
        Warning          = Color3.fromRGB(200, 130, 0),
        Error            = Color3.fromRGB(200, 50, 40),
        ToggleOn         = Color3.fromRGB(99, 102, 241),
        ToggleOff        = Color3.fromRGB(200, 200, 220),
        SliderFill       = Color3.fromRGB(99, 102, 241),
        SliderTrack      = Color3.fromRGB(220, 220, 235),
        Shadow           = Color3.fromRGB(180, 180, 210),
        TabActive        = Color3.fromRGB(99, 102, 241),
        TabInactive      = Color3.fromRGB(210, 210, 230),
        ScrollBar        = Color3.fromRGB(180, 180, 210),
        InputBg          = Color3.fromRGB(245, 245, 252),
        NotifBg          = Color3.fromRGB(255, 255, 255),
    },
}

-- ─── NexusUI Library ─────────────────────────────────────────────────────────

local NexusUI = {
    Flags     = {},
    Windows   = {},
    Version   = "1.0.0",
    Themes    = Themes,
    _Conns    = {},
    _Destroyed = false,
}
NexusUI.__index = NexusUI

-- ─── Icon system (Lucide-compatible sheet) ───────────────────────────────────
-- Minimal icon map using roblox image assets. Add more as needed.
local Icons = {
    home         = "rbxassetid://10723407389",
    settings     = "rbxassetid://10723448757",
    shield       = "rbxassetid://10723426648",
    bell         = "rbxassetid://10723396047",
    info         = "rbxassetid://10723412789",
    star         = "rbxassetid://10723430107",
    zap          = "rbxassetid://10723437248",
    eye          = "rbxassetid://10723404138",
    lock         = "rbxassetid://10723415677",
    user         = "rbxassetid://10723432956",
    search       = "rbxassetid://10723424046",
    close        = "rbxassetid://10723399958",
    chevrondown  = "rbxassetid://10723398458",
    chevronup    = "rbxassetid://10723398763",
    check        = "rbxassetid://10723398065",
    plus         = "rbxassetid://10723421564",
    minus        = "rbxassetid://10723419028",
    trash        = "rbxassetid://10723431441",
    palette      = "rbxassetid://10723420158",
    sliders      = "rbxassetid://10723428547",
    keyboard     = "rbxassetid://10723413957",
    toggleleft   = "rbxassetid://10723431066",
    toggleright  = "rbxassetid://10723431255",
    folder       = "rbxassetid://10723406006",
    save         = "rbxassetid://10723422983",
    refresh      = "rbxassetid://10723422296",
    code         = "rbxassetid://10723399228",
    terminal     = "rbxassetid://10723430597",
    list         = "rbxassetid://10723415194",
    grid         = "rbxassetid://10723409218",
    activity     = "rbxassetid://10723394855",
    map          = "rbxassetid://10723416997",
    globe        = "rbxassetid://10723408296",
    heart         = "rbxassetid://10723410451",
    sword        = "rbxassetid://10723429528",
    gamepad      = "rbxassetid://10723406980",
    trophy       = "rbxassetid://10723432181",
    alert        = "rbxassetid://10723395542",
    warning      = "rbxassetid://10723433748",
    maximize     = "rbxassetid://10723417520",
    minimize     = "rbxassetid://10723419228",
    hide         = "rbxassetid://10723410960",
    show         = "rbxassetid://10723404138",
}

local function GetIcon(name)
    if type(name) == "number" then
        return "rbxassetid://"..name
    end
    if type(name) == "string" then
        return Icons[name:lower()] or "rbxassetid://0"
    end
    return "rbxassetid://0"
end

-- ─── GUI Scaffolding ─────────────────────────────────────────────────────────

local ScreenGui = New("ScreenGui", {
    Name             = "NexusUI",
    ResetOnSpawn     = false,
    ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
    DisplayOrder     = 999,
})

-- Parent safely
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
elseif RunService:IsStudio() then
    ScreenGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
else
    ScreenGui.Parent = CoreGui
end

-- Remove duplicate GUIs
local function CleanDuplicates()
    local parent = ScreenGui.Parent
    if not parent then return end
    for _, v in ipairs(parent:GetChildren()) do
        if v ~= ScreenGui and v.Name == "NexusUI" then
            v:Destroy()
        end
    end
end
CleanDuplicates()

-- Notification container
local NotifContainer = New("Frame", {
    Name              = "Notifications",
    AnchorPoint       = Vector2.new(1, 1),
    Position          = UDim2.new(1, -16, 1, -16),
    Size              = UDim2.new(0, 320, 1, -32),
    BackgroundTransparency = 1,
    Parent            = ScreenGui,
}, {
    New("UIListLayout", {
        SortOrder            = Enum.SortOrder.LayoutOrder,
        VerticalAlignment    = Enum.VerticalAlignment.Bottom,
        Padding              = UDim.new(0, 8),
    })
})

-- ─── Dragging helper ─────────────────────────────────────────────────────────

local function MakeDraggable(handle, frame)
    local dragging = false
    local dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ─── Notification ─────────────────────────────────────────────────────────────

function NexusUI:Notify(cfg)
    cfg = cfg or {}
    local title    = cfg.Title    or "Notification"
    local content  = cfg.Content  or ""
    local duration = cfg.Duration or 5
    local icon     = cfg.Icon     or "bell"
    local ntype    = cfg.Type     or "info" -- info | success | warning | error

    local theme = self._theme or Themes.Dark

    local accentMap = {
        info    = theme.Accent,
        success = theme.Success,
        warning = theme.Warning,
        error   = theme.Error,
    }
    local accent = accentMap[ntype] or theme.Accent

    local notif = New("Frame", {
        Name              = "Notification",
        Size              = UDim2.new(1, 0, 0, 0),
        AutomaticSize     = Enum.AutomaticSize.Y,
        BackgroundColor3  = theme.NotifBg,
        BackgroundTransparency = 0.05,
        ClipsDescendants  = true,
        LayoutOrder       = tick(),
    }, {
        New("UICorner",   {CornerRadius = UDim.new(0, 10)}),
        New("UIStroke",   {Color = theme.Border, Thickness = 1}),
        New("UIPadding",  {
            PaddingLeft  = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14),
            PaddingTop   = UDim.new(0, 12),
            PaddingBottom= UDim.new(0, 12),
        }),
        -- accent strip
        New("Frame", {
            Size             = UDim2.new(0, 3, 1, -24),
            Position         = UDim2.new(0, -14, 0, 12),
            BackgroundColor3 = accent,
            BorderSizePixel  = 0,
        }, {
            New("UICorner", {CornerRadius = UDim.new(0, 3)})
        }),
        -- icon
        New("ImageLabel", {
            Image            = GetIcon(icon),
            Size             = UDim2.new(0, 20, 0, 20),
            Position         = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            ImageColor3      = accent,
        }),
        -- title
        New("TextLabel", {
            Name             = "Title",
            Text             = title,
            TextColor3       = theme.Text,
            Font             = Enum.Font.GothamBold,
            TextSize         = 14,
            Size             = UDim2.new(1, -30, 0, 20),
            Position         = UDim2.new(0, 30, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }),
        -- content
        New("TextLabel", {
            Name             = "Content",
            Text             = content,
            TextColor3       = theme.TextMuted,
            Font             = Enum.Font.Gotham,
            TextSize         = 13,
            Size             = UDim2.new(1, 0, 0, 0),
            Position         = UDim2.new(0, 0, 0, 24),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            TextXAlignment   = Enum.TextXAlignment.Left,
            TextWrapped      = true,
        }),
        -- progress bar
        New("Frame", {
            Name             = "Progress",
            Size             = UDim2.new(1, 0, 0, 2),
            Position         = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = accent,
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(0, 1),
        }, {
            New("UICorner", {CornerRadius = UDim.new(0, 2)})
        }),
    })

    notif.Parent = NotifContainer
    notif.Position = UDim2.new(1, 20, 0, 0)
    Tween(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.4)

    -- shrink progress bar
    task.delay(0.1, function()
        Tween(notif:FindFirstChild("Progress"), {Size = UDim2.new(0, 0, 0, 2)}, duration - 0.1, Enum.EasingStyle.Linear)
    end)

    task.delay(duration, function()
        Tween(notif, {Position = UDim2.new(1, 20, 0, 0)}, 0.4)
        task.wait(0.4)
        notif:Destroy()
    end)

    return notif
end

-- ─── Window ──────────────────────────────────────────────────────────────────

function NexusUI:CreateWindow(cfg)
    cfg = cfg or {}
    local title      = cfg.Title    or "NexusUI"
    local subtitle   = cfg.SubTitle or ""
    local themeName  = cfg.Theme    or "Dark"
    local icon       = cfg.Icon     or "shield"
    local configCfg  = cfg.ConfigSaving or {Enabled = false}
    local keySys     = cfg.KeySystem   or false
    local keySet     = cfg.KeySettings or {}
    local hideKey    = cfg.HideKey     -- Enum.KeyCode or string

    local theme = Themes[themeName] or Themes.Dark
    self._theme = theme

    -- ── Config I/O ──────────────────────────────────────────────────────────
    local configFolder = configCfg.FolderName or "NexusUI"
    local configFile   = (configCfg.FileName  or "config") .. ".json"
    local configEnabled = configCfg.Enabled or false

    local function EnsureFolder(path)
        if isfolder and not isfolder(path) then
            makefolder(path)
        end
    end

    local function WriteConfig(data)
        if not (writefile and configEnabled) then return end
        pcall(function()
            EnsureFolder(configFolder)
            writefile(configFolder .. "/" .. configFile, HttpService:JSONEncode(data))
        end)
    end

    local function ReadConfig()
        if not (readfile and isfile and configEnabled) then return nil end
        local ok, result = pcall(function()
            local path = configFolder .. "/" .. configFile
            if isfile(path) then
                return HttpService:JSONDecode(readfile(path))
            end
        end)
        return ok and result or nil
    end

    local function SaveAll()
        if not configEnabled then return end
        local data = {}
        for flag, element in pairs(NexusUI.Flags) do
            local t = element.Type
            if t == "Toggle"   then data[flag] = element.Value
            elseif t == "Slider" then data[flag] = element.Value
            elseif t == "Dropdown" then data[flag] = element.Value
            elseif t == "Input"  then data[flag] = element.Value
            elseif t == "Keybind" then data[flag] = type(element.Value) == "string" and element.Value or element.Value.Name
            elseif t == "ColorPicker" then
                data[flag] = {r = element.Value.R*255, g = element.Value.G*255, b = element.Value.B*255}
            end
        end
        WriteConfig(data)
    end

    -- ── Key System ──────────────────────────────────────────────────────────
    local passthrough = not keySys
    if keySys then
        EnsureFolder(configFolder .. "/Keys")
        local keyFile = configFolder .. "/Keys/" .. (keySet.FileName or "key") .. ".txt"
        local savedKey = nil
        if isfile and isfile(keyFile) then
            pcall(function() savedKey = readfile(keyFile) end)
        end
        -- Build accepted keys list
        local accepted = type(keySet.Key) == "table" and keySet.Key
            or (keySet.Key and {keySet.Key} or {})

        if keySet.GrabKeyFromSite then
            local fetched = {}
            for i, url in ipairs(accepted) do
                local ok, res = pcall(function()
                    return game:HttpGet(url):gsub("%s+", "")
                end)
                fetched[i] = ok and res or url
            end
            accepted = fetched
        end

        -- Check saved key
        if savedKey then
            for _, k in ipairs(accepted) do
                if savedKey == k then passthrough = true break end
            end
        end

        if not passthrough then
            -- Simple key UI
            local keyGui = New("ScreenGui", {
                Name = "NexusKey", ResetOnSpawn = false,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                DisplayOrder = 1000,
            })
            if gethui then keyGui.Parent = gethui()
            elseif syn and syn.protect_gui then syn.protect_gui(keyGui); keyGui.Parent = CoreGui
            else keyGui.Parent = CoreGui end

            local keyFrame = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position    = UDim2.new(0.5, 0, 0.5, 0),
                Size        = UDim2.new(0, 420, 0, 220),
                BackgroundColor3 = theme.Surface,
                Parent      = keyGui,
            }, {
                New("UICorner", {CornerRadius = UDim.new(0, 12)}),
                New("UIStroke", {Color = theme.Border, Thickness = 1.5}),
                New("UIPadding", {PaddingLeft=UDim.new(0,24),PaddingRight=UDim.new(0,24),PaddingTop=UDim.new(0,24),PaddingBottom=UDim.new(0,24)}),
                New("TextLabel", {
                    Text=keySet.Title or "Key Required",
                    Font=Enum.Font.GothamBold, TextSize=20,
                    TextColor3=theme.Text, BackgroundTransparency=1,
                    Size=UDim2.new(1,0,0,28), TextXAlignment=Enum.TextXAlignment.Left,
                }),
                New("TextLabel", {
                    Text=keySet.SubTitle or "Enter your access key to continue",
                    Font=Enum.Font.Gotham, TextSize=13,
                    TextColor3=theme.TextMuted, BackgroundTransparency=1,
                    Size=UDim2.new(1,0,0,18), Position=UDim2.new(0,0,0,36),
                    TextXAlignment=Enum.TextXAlignment.Left,
                }),
                New("TextLabel", {
                    Text=keySet.Note or "",
                    Font=Enum.Font.Gotham, TextSize=12,
                    TextColor3=theme.TextDisabled, BackgroundTransparency=1,
                    Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,0,58),
                    TextXAlignment=Enum.TextXAlignment.Left,
                }),
                New("Frame", {
                    Name="InputBox",
                    Size=UDim2.new(1,0,0,40), Position=UDim2.new(0,0,0,84),
                    BackgroundColor3=theme.InputBg,
                }, {
                    New("UICorner",{CornerRadius=UDim.new(0,8)}),
                    New("UIStroke",{Color=theme.Border}),
                    New("TextBox", {
                        Name="Input",
                        Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,12,0,0),
                        BackgroundTransparency=1, PlaceholderText="Paste your key here...",
                        PlaceholderColor3=theme.TextDisabled,
                        Font=Enum.Font.GothamSemibold, TextSize=14,
                        TextColor3=theme.Text, TextXAlignment=Enum.TextXAlignment.Left,
                    }),
                }),
                New("TextButton", {
                    Name="Submit",
                    Size=UDim2.new(1,0,0,40), Position=UDim2.new(0,0,0,136),
                    BackgroundColor3=theme.Accent,
                    Text="Submit Key", TextColor3=Color3.fromRGB(255,255,255),
                    Font=Enum.Font.GothamBold, TextSize=15,
                }, {
                    New("UICorner",{CornerRadius=UDim.new(0,8)}),
                }),
            })

            local submitBtn = keyFrame:FindFirstChild("Submit", true)
            local inputBox  = keyFrame.InputBox.Input
            local statusLbl = New("TextLabel", {
                Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,1,8),
                BackgroundTransparency=1, TextColor3=theme.Error,
                Font=Enum.Font.Gotham, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left,
                Parent=keyFrame,
            })

            submitBtn.MouseButton1Click:Connect(function()
                local entered = inputBox.Text:gsub("%s+","")
                local found = false
                for _, k in ipairs(accepted) do
                    if entered == k then found = true break end
                end
                if found then
                    passthrough = true
                    if keySet.SaveKey and writefile then
                        EnsureFolder(configFolder.."/Keys")
                        writefile(keyFile, entered)
                    end
                    Tween(keyFrame, {BackgroundTransparency=1}, 0.3)
                    task.wait(0.35)
                    keyGui:Destroy()
                else
                    statusLbl.Text = "⚠  Invalid key. Please try again."
                    Tween(keyFrame, {BackgroundColor3=Color3.fromRGB(60,20,20)}, 0.15)
                    task.delay(0.3, function()
                        Tween(keyFrame, {BackgroundColor3=theme.Surface}, 0.3)
                    end)
                    inputBox.Text = ""
                end
            end)
        end
    end

    if keySys then
        local t = 0
        repeat task.wait(0.05) t+=0.05 until passthrough or t > 120
        if not passthrough then return end
    end

    -- ── Main Frame ──────────────────────────────────────────────────────────

    local isMinimized = false
    local isHidden    = false
    local tabs        = {}
    local activeTab   = nil

    -- Drop shadow
    local Shadow = New("ImageLabel", {
        Name              = "Shadow",
        AnchorPoint       = Vector2.new(0.5, 0.5),
        Position          = UDim2.new(0.5, 0, 0.5, 6),
        Size              = UDim2.new(1, 40, 1, 40),
        BackgroundTransparency = 1,
        Image             = "rbxassetid://5554236805",
        ImageColor3       = theme.Shadow,
        ImageTransparency = 0.4,
        ScaleType         = Enum.ScaleType.Slice,
        SliceCenter       = Rect.new(23, 23, 277, 277),
        Parent            = ScreenGui,
    })

    local MainFrame = New("Frame", {
        Name             = "NexusWindow",
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 620, 0, 420),
        BackgroundColor3 = theme.Background,
        ClipsDescendants = false,
        Parent           = ScreenGui,
    }, {
        New("UICorner", {CornerRadius = UDim.new(0, 12)}),
        New("UIStroke", {Color = theme.Border, Thickness = 1.2}),
    })

    -- Link shadow to window
    local function SyncShadow()
        Shadow.Position = UDim2.new(0, MainFrame.AbsolutePosition.X + MainFrame.AbsoluteSize.X/2,
                                     0, MainFrame.AbsolutePosition.Y + MainFrame.AbsoluteSize.Y/2 + 6)
        Shadow.Size     = UDim2.new(0, MainFrame.AbsoluteSize.X + 40, 0, MainFrame.AbsoluteSize.Y + 40)
    end
    MainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(SyncShadow)
    MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(SyncShadow)
    task.defer(SyncShadow)

    -- ── Topbar ──────────────────────────────────────────────────────────────

    local Topbar = New("Frame", {
        Name             = "Topbar",
        Size             = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = theme.Topbar,
        ClipsDescendants = false,
        ZIndex           = 5,
        Parent           = MainFrame,
    }, {
        New("UICorner",  {CornerRadius = UDim.new(0, 12)}),
        New("Frame", { -- cover bottom round corners
            Size             = UDim2.new(1, 0, 0.5, 0),
            Position         = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = theme.Topbar,
            BorderSizePixel  = 0,
        }),
        New("Frame", {
            Name             = "Divider",
            Size             = UDim2.new(1, 0, 0, 1),
            Position         = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = theme.Border,
            BorderSizePixel  = 0,
        }),
    })

    -- Icon badge (accent rounded square)
    New("Frame", {
        Size             = UDim2.new(0, 32, 0, 32),
        Position         = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = theme.AccentDim,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = Topbar,
    }, {
        New("UICorner", {CornerRadius = UDim.new(0, 8)}),
        New("ImageLabel", {
            Image            = GetIcon(icon),
            Size             = UDim2.new(0, 18, 0, 18),
            Position         = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint      = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            ImageColor3      = theme.Accent,
            ZIndex           = 7,
        }),
    })

    -- Title + subtitle stacked block
    local titleY = subtitle ~= "" and -9 or 0
    New("TextLabel", {
        Name             = "Title",
        Text             = title,
        Font             = Enum.Font.GothamBold,
        TextSize         = 15,
        TextColor3       = theme.Text,
        Size             = UDim2.new(0, 220, 0, 20),
        Position         = UDim2.new(0, 52, 0.5, titleY),
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 6,
        Parent           = Topbar,
    })
    if subtitle ~= "" then
        New("TextLabel", {
            Name             = "SubTitle",
            Text             = subtitle,
            Font             = Enum.Font.Gotham,
            TextSize         = 11,
            TextColor3       = theme.TextMuted,
            Size             = UDim2.new(0, 220, 0, 14),
            Position         = UDim2.new(0, 52, 0.5, 11),
            AnchorPoint      = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 6,
            Parent           = Topbar,
        })
    end

    -- macOS-style control circles: red=close, yellow=minimize
    local function MakeCircleBtn(color, xOff, iconName, cb)
        local btn = New("TextButton", {
            Size             = UDim2.new(0, 14, 0, 14),
            Position         = UDim2.new(1, xOff, 0.5, 0),
            AnchorPoint      = Vector2.new(1, 0.5),
            BackgroundColor3 = color,
            Text             = "",
            AutoButtonColor  = false,
            ZIndex           = 6,
            Parent           = Topbar,
        }, { New("UICorner", {CornerRadius = UDim.new(1, 0)}) })
        local ico = New("ImageLabel", {
            Image            = GetIcon(iconName),
            Size             = UDim2.new(0, 8, 0, 8),
            Position         = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint      = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            ImageColor3      = Color3.fromRGB(80, 30, 20),
            ImageTransparency= 1,
            ZIndex           = 7,
            Parent           = btn,
        })
        btn.MouseEnter:Connect(function() Tween(ico,{ImageTransparency=0},0.1) end)
        btn.MouseLeave:Connect(function() Tween(ico,{ImageTransparency=1},0.1) end)
        btn.MouseButton1Click:Connect(cb)
        return btn
    end

    -- Search bar
    local searchOpen = false
    local SearchBar = New("Frame", {
        Name             = "SearchBar",
        Size             = UDim2.new(0, 190, 0, 28),
        Position         = UDim2.new(0.5, -20, 0.5, 0),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.InputBg,
        BorderSizePixel  = 0,
        Visible          = false,
        ZIndex           = 7,
        Parent           = Topbar,
    }, {
        New("UICorner", {CornerRadius=UDim.new(0,6)}),
        New("UIStroke", {Color=theme.Border}),
        New("TextBox", {
            Name             = "Input",
            Size             = UDim2.new(1,-32,1,0),
            Position         = UDim2.new(0,28,0,0),
            BackgroundTransparency=1,
            PlaceholderText  = "Search...",
            PlaceholderColor3= theme.TextDisabled,
            Font             = Enum.Font.Gotham,
            TextSize         = 13,
            TextColor3       = theme.Text,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 8,
        }),
        New("ImageLabel", {
            Image            = GetIcon("search"),
            Size             = UDim2.new(0,13,0,13),
            Position         = UDim2.new(0,8,0.5,0),
            AnchorPoint      = Vector2.new(0,0.5),
            BackgroundTransparency=1,
            ImageColor3      = theme.TextMuted,
            ZIndex           = 8,
        }),
    })
    local SearchInput = SearchBar.Input

    -- Search icon button
    local searchIco = New("ImageButton", {
        Image            = GetIcon("search"),
        Size             = UDim2.new(0, 16, 0, 16),
        Position         = UDim2.new(1, -46, 0.5, 0),
        AnchorPoint      = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        ImageColor3      = theme.TextMuted,
        ZIndex           = 6,
        Parent           = Topbar,
    })
    searchIco.MouseEnter:Connect(function() Tween(searchIco,{ImageColor3=theme.Text},0.15) end)
    searchIco.MouseLeave:Connect(function() Tween(searchIco,{ImageColor3=theme.TextMuted},0.15) end)
    searchIco.MouseButton1Click:Connect(function()
        searchOpen = not searchOpen
        SearchBar.Visible = searchOpen
        if searchOpen then SearchInput:CaptureFocus() else SearchInput.Text = "" end
    end)

    -- Minimize (yellow circle)
    MakeCircleBtn(Color3.fromRGB(255, 189, 46), -26, "minus", function()
        if isMinimized then
            isMinimized = false
            for _, c in ipairs(MainFrame:GetChildren()) do
                if c ~= Topbar then c.Visible = true end
            end
            Tween(MainFrame, {Size = UDim2.new(0, 620, 0, 420)}, 0.3, Enum.EasingStyle.Quint)
        else
            isMinimized = true
            Tween(MainFrame, {Size = UDim2.new(0, 620, 0, 52)}, 0.3, Enum.EasingStyle.Quint)
            task.delay(0.32, function()
                if isMinimized then
                    for _, c in ipairs(MainFrame:GetChildren()) do
                        if c ~= Topbar then c.Visible = false end
                    end
                end
            end)
        end
    end)

    -- Close/hide (red circle)
    MakeCircleBtn(Color3.fromRGB(255, 96, 92), -10, "x", function()
        isHidden = true
        Tween(MainFrame, {Size=UDim2.new(0,0,0,0), BackgroundTransparency=1}, 0.3)
        Tween(Shadow,    {ImageTransparency=1}, 0.3)
        NexusUI:Notify({
            Title   = "UI Hidden",
            Content = "Press " .. (hideKey and tostring(hideKey) or "RightShift") .. " to show the UI again.",
            Duration = 6,
            Icon    = "eye",
        })
    end)

    -- Hotkey to show/hide
    local keyConn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        local targetKey = hideKey or Enum.KeyCode.RightShift
        if type(targetKey) == "string" then
            targetKey = Enum.KeyCode[targetKey]
        end
        if input.KeyCode == targetKey then
            if isHidden then
                isHidden = false
                MainFrame.Size = UDim2.new(0,0,0,0)
                MainFrame.BackgroundTransparency = 1
                Tween(MainFrame, {Size=UDim2.new(0,620,0,420), BackgroundTransparency=0}, 0.35)
                Tween(Shadow,    {ImageTransparency=0.4}, 0.35)
            else
                isHidden = true
                Tween(MainFrame, {Size=UDim2.new(0,0,0,0), BackgroundTransparency=1}, 0.35)
                Tween(Shadow,    {ImageTransparency=1}, 0.35)
            end
        end
    end)
    table.insert(NexusUI._Conns, keyConn)

    MakeDraggable(Topbar, MainFrame)

    -- ── Tab bar ──────────────────────────────────────────────────────────────

    local TabBar = New("Frame", {
        Name             = "TabBar",
        Size             = UDim2.new(0, 148, 1, -52),
        Position         = UDim2.new(0, 0, 0, 52),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        Parent           = MainFrame,
    }, {
        New("UICorner", {CornerRadius=UDim.new(0,12)}),
        -- cover right corners
        New("Frame", {Size=UDim2.new(0,12,1,0), Position=UDim2.new(1,-12,0,0),
            BackgroundColor3=theme.Surface, BorderSizePixel=0}),
        New("Frame", {Name="TopFill", Size=UDim2.new(1,0,0,12), Position=UDim2.new(0,0,0,0),
            BackgroundColor3=theme.Surface, BorderSizePixel=0}),
        New("Frame", {Name="Divider", Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,-1,0,0),
            BackgroundColor3=theme.Border, BorderSizePixel=0}),
    })

    local TabScroll = New("ScrollingFrame", {
        Name              = "TabScroll",
        Size              = UDim2.new(1, 0, 1, -16),
        Position          = UDim2.new(0, 0, 0, 8),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.ScrollBar,
        BorderSizePixel   = 0,
        CanvasSize        = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent            = TabBar,
    }, {
        New("UIListLayout", {
            Padding          = UDim.new(0, 4),
            SortOrder        = Enum.SortOrder.LayoutOrder,
        }),
        New("UIPadding", {
            PaddingLeft  = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop   = UDim.new(0, 6),
        }),
    })

    -- ── Content area ─────────────────────────────────────────────────────────

    local ContentHolder = New("Frame", {
        Name             = "ContentHolder",
        Size             = UDim2.new(1, -148, 1, -52),
        Position         = UDim2.new(0, 148, 0, 52),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent           = MainFrame,
    })

    -- ── Accent bar at top ────────────────────────────────────────────────────

    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 10,
        Parent           = MainFrame,
    }, {
        New("UICorner", {CornerRadius = UDim.new(0, 2)}),
        New("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,  theme.AccentHover),
                ColorSequenceKeypoint.new(0.5, theme.Accent),
                ColorSequenceKeypoint.new(1,  theme.AccentDim),
            })
        }),
    })

    -- ── Search logic ─────────────────────────────────────────────────────────
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local q = SearchInput.Text:lower()
        if activeTab and activeTab._page then
            for _, elem in ipairs(activeTab._page:GetChildren()) do
                if elem:IsA("Frame") and elem.Name ~= "Placeholder" then
                    if q == "" then
                        elem.Visible = true
                    else
                        local match = elem.Name:lower():find(q, 1, true)
                        elem.Visible = match ~= nil
                    end
                end
            end
        end
    end)

    -- ── Animate in ───────────────────────────────────────────────────────────
    MainFrame.BackgroundTransparency = 1
    MainFrame.Size = UDim2.new(0, 640, 0, 0)
    Shadow.ImageTransparency = 1
    Tween(MainFrame, {BackgroundTransparency=0, Size=UDim2.new(0,620,0,420)}, 0.5, Enum.EasingStyle.Back)
    Tween(Shadow,    {ImageTransparency=0.4}, 0.6)

    -- ── Window object ────────────────────────────────────────────────────────
    local Window = {
        _frame   = MainFrame,
        _tabbar  = TabScroll,
        _content = ContentHolder,
        _theme   = theme,
        _tabs    = tabs,
        _configEnabled = configEnabled,
        _saveAll = SaveAll,
    }

    -- ─── CreateTab ───────────────────────────────────────────────────────────

    function Window:CreateTab(name, tabIcon)
        local isFirst = #tabs == 0

        -- Tab button
        local TabBtn = New("TextButton", {
            Name             = name,
            Size             = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = isFirst and theme.AccentDim or Color3.fromRGB(0,0,0),
            BackgroundTransparency = isFirst and 0 or 1,
            Text             = "",
            AutoButtonColor  = false,
            LayoutOrder      = #tabs + 1,
            Parent           = TabScroll,
        }, {
            New("UICorner", {CornerRadius=UDim.new(0,8)}),
            New("ImageLabel", {
                Name         = "Icon",
                Image        = GetIcon(tabIcon or "list"),
                Size         = UDim2.new(0,16,0,16),
                Position     = UDim2.new(0,10,0.5,0),
                AnchorPoint  = Vector2.new(0,0.5),
                BackgroundTransparency=1,
                ImageColor3  = isFirst and theme.Accent or theme.TextMuted,
            }),
            New("TextLabel", {
                Name         = "Label",
                Text         = name,
                Font         = Enum.Font.GothamSemibold,
                TextSize     = 13,
                TextColor3   = isFirst and theme.Text or theme.TextMuted,
                Size         = UDim2.new(1,-34,1,0),
                Position     = UDim2.new(0,34,0,0),
                BackgroundTransparency=1,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            -- active indicator
            New("Frame", {
                Name         = "Indicator",
                Size         = UDim2.new(0,3,0.6,0),
                Position     = UDim2.new(0,1,0.2,0),
                BackgroundColor3 = theme.Accent,
                BorderSizePixel  = 0,
                Visible          = isFirst,
            }, {New("UICorner",{CornerRadius=UDim.new(0,2)})}),
        })

        -- Content page (scrolling frame)
        local Page = New("ScrollingFrame", {
            Name              = name,
            Size              = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel   = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = theme.ScrollBar,
            CanvasSize        = UDim2.new(0,0,0,0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible           = isFirst,
            Parent            = ContentHolder,
        }, {
            New("UIListLayout", {
                Padding      = UDim.new(0, 6),
                SortOrder    = Enum.SortOrder.LayoutOrder,
            }),
            New("UIPadding", {
                PaddingLeft  = UDim.new(0, 14),
                PaddingRight = UDim.new(0, 14),
                PaddingTop   = UDim.new(0, 12),
                PaddingBottom= UDim.new(0, 12),
            }),
        })

        local tabObj = {
            _btn     = TabBtn,
            _page    = Page,
            _name    = name,
            _theme   = theme,
            _window  = Window,
        }
        tabs[#tabs+1] = tabObj

        if isFirst then
            activeTab = tabObj
        end

        -- Tab click
        TabBtn.MouseButton1Click:Connect(function()
            if activeTab == tabObj then return end
            -- Deactivate old
            if activeTab then
                local ob = activeTab._btn
                Tween(ob, {BackgroundTransparency=1}, 0.2)
                ob.Icon.ImageColor3   = theme.TextMuted
                ob.Label.TextColor3   = theme.TextMuted
                ob.Indicator.Visible  = false
                activeTab._page.Visible = false
            end
            -- Activate new
            activeTab = tabObj
            Tween(TabBtn, {BackgroundColor3=theme.AccentDim, BackgroundTransparency=0}, 0.2)
            TabBtn.Icon.ImageColor3  = theme.Accent
            TabBtn.Label.TextColor3  = theme.Text
            TabBtn.Indicator.Visible = true
            Page.Visible = true
        end)

        TabBtn.MouseEnter:Connect(function()
            if activeTab ~= tabObj then
                Tween(TabBtn, {BackgroundColor3=theme.SurfaceHover, BackgroundTransparency=0}, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if activeTab ~= tabObj then
                Tween(TabBtn, {BackgroundTransparency=1}, 0.15)
            end
        end)

        -- ── Element helpers ──────────────────────────────────────────────────

        local function BaseElement(height)
            local f = New("Frame", {
                Size             = UDim2.new(1, 0, 0, height or 42),
                BackgroundColor3 = theme.Surface,
                BorderSizePixel  = 0,
                LayoutOrder      = #Page:GetChildren(),
                Parent           = Page,
            }, {
                New("UICorner",  {CornerRadius=UDim.new(0,8)}),
                New("UIStroke",  {Color=theme.Border, Thickness=1}),
            })
            return f
        end

        local function ElemTitle(parent, text, desc, xOff)
            xOff = xOff or 14
            local tl = New("TextLabel", {
                Name         = "Title",
                Text         = text,
                Font         = Enum.Font.GothamSemibold,
                TextSize     = 14,
                TextColor3   = theme.Text,
                Size         = UDim2.new(1, -xOff-10, 0, 18),
                Position     = UDim2.new(0, xOff, desc and 0.15 or 0.5, 0),
                AnchorPoint  = Vector2.new(0, desc and 0 or 0.5),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent       = parent,
            })
            if desc and desc ~= "" then
                New("TextLabel", {
                    Name         = "Desc",
                    Text         = desc,
                    Font         = Enum.Font.Gotham,
                    TextSize     = 12,
                    TextColor3   = theme.TextMuted,
                    Size         = UDim2.new(1, -xOff-10, 0, 14),
                    Position     = UDim2.new(0, xOff, 0, 22),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent       = parent,
                })
            end
            return tl
        end

        -- ── Section ──────────────────────────────────────────────────────────

        function tabObj:CreateSection(sectionName)
            local sectionFrame = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                LayoutOrder      = #Page:GetChildren(),
                Parent           = Page,
            })
            -- left line
            New("Frame", {
                Size             = UDim2.new(0, 2, 0, 14),
                Position         = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint      = Vector2.new(0, 0.5),
                BackgroundColor3 = theme.Accent,
                BorderSizePixel  = 0,
                Parent           = sectionFrame,
            }, {New("UICorner",{CornerRadius=UDim.new(0,2)})})

            New("TextLabel", {
                Text         = sectionName:upper(),
                Font         = Enum.Font.GothamBold,
                TextSize     = 11,
                TextColor3   = theme.TextMuted,
                Size         = UDim2.new(1,-12,1,0),
                Position     = UDim2.new(0,10,0,0),
                BackgroundTransparency=1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent       = sectionFrame,
            })
            local sv = {}
            function sv:Set(t)
                local lbl = sectionFrame:FindFirstChildOfClass("TextLabel")
                if lbl then lbl.Text = t:upper() end
            end
            return sv
        end

        -- ── Divider ──────────────────────────────────────────────────────────

        function tabObj:CreateDivider()
            New("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = theme.Border,
                BorderSizePixel  = 0,
                BackgroundTransparency = 0.3,
                LayoutOrder      = #Page:GetChildren(),
                Parent           = Page,
            })
        end

        -- ── Label ────────────────────────────────────────────────────────────

        function tabObj:CreateLabel(lcfg)
            lcfg = type(lcfg) == "string" and {Text=lcfg} or lcfg
            local txt   = lcfg.Text  or "Label"
            local licon = lcfg.Icon  or nil
            local color = lcfg.Color or nil

            local frame = BaseElement(36)
            frame.BackgroundColor3 = color or theme.Elevated
            frame.BackgroundTransparency = color and 0.7 or 0

            if licon then
                New("ImageLabel", {
                    Image        = GetIcon(licon),
                    Size         = UDim2.new(0,16,0,16),
                    Position     = UDim2.new(0,12,0.5,0),
                    AnchorPoint  = Vector2.new(0,0.5),
                    BackgroundTransparency=1,
                    ImageColor3  = color or theme.Accent,
                    Parent       = frame,
                })
            end

            New("TextLabel", {
                Text         = txt,
                Font         = Enum.Font.GothamSemibold,
                TextSize     = 14,
                TextColor3   = theme.Text,
                Size         = UDim2.new(1, licon and -40 or -20, 1, 0),
                Position     = UDim2.new(0, licon and 36 or 14, 0, 0),
                BackgroundTransparency=1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent       = frame,
            })

            local lv = {}
            function lv:Set(newText)
                frame:FindFirstChildOfClass("TextLabel").Text = newText
            end
            return lv
        end

        -- ── Paragraph ────────────────────────────────────────────────────────

        function tabObj:CreateParagraph(pcfg)
            local frame = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = theme.Surface,
                BorderSizePixel  = 0,
                LayoutOrder      = #Page:GetChildren(),
                Parent           = Page,
            }, {
                New("UICorner", {CornerRadius=UDim.new(0,8)}),
                New("UIStroke", {Color=theme.Border, Thickness=1}),
                New("UIPadding", {PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14),PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12)}),
                New("TextLabel", {
                    Name         = "Title",
                    Text         = pcfg.Title or "",
                    Font         = Enum.Font.GothamBold,
                    TextSize     = 14,
                    TextColor3   = theme.Text,
                    Size         = UDim2.new(1,0,0,18),
                    BackgroundTransparency=1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }),
                New("TextLabel", {
                    Name         = "Content",
                    Text         = pcfg.Content or "",
                    Font         = Enum.Font.Gotham,
                    TextSize     = 13,
                    TextColor3   = theme.TextMuted,
                    Size         = UDim2.new(1,0,0,0),
                    Position     = UDim2.new(0,0,0,22),
                    AutomaticSize= Enum.AutomaticSize.Y,
                    BackgroundTransparency=1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped  = true,
                }),
            })

            local pv = {}
            function pv:Set(nc)
                if nc.Title   then frame.Title.Text   = nc.Title   end
                if nc.Content then frame.Content.Text = nc.Content end
            end
            return pv
        end

        -- ── Button ───────────────────────────────────────────────────────────

        function tabObj:CreateButton(bcfg)
            local hasDesc = bcfg.Description and bcfg.Description ~= ""
            local frame   = BaseElement(hasDesc and 52 or 42)
            frame.Name    = bcfg.Name

            ElemTitle(frame, bcfg.Name, bcfg.Description)

            local arrow = New("ImageLabel", {
                Image        = GetIcon("chevrondown"),
                Size         = UDim2.new(0,16,0,16),
                Position     = UDim2.new(1,-30,0.5,0),
                AnchorPoint  = Vector2.new(0.5,0.5),
                Rotation     = -90,
                BackgroundTransparency=1,
                ImageColor3  = theme.TextMuted,
                Parent       = frame,
            })

            local ripple = New("Frame", {
                Size             = UDim2.new(0,0,0,0),
                AnchorPoint      = Vector2.new(0.5,0.5),
                Position         = UDim2.new(0.5,0,0.5,0),
                BackgroundColor3 = theme.Accent,
                BackgroundTransparency=0.7,
                BorderSizePixel  = 0,
                ZIndex           = 2,
                Parent           = frame,
            }, {New("UICorner",{CornerRadius=UDim.new(0.5,0)})})
            frame.ClipsDescendants = true

            local btn = New("TextButton", {
                Size             = UDim2.new(1,0,1,0),
                BackgroundTransparency=1,
                Text             = "",
                ZIndex           = 3,
                Parent           = frame,
            })

            btn.MouseEnter:Connect(function()
                Tween(frame, {BackgroundColor3=theme.SurfaceHover}, 0.15)
                Tween(arrow, {ImageColor3=theme.Accent}, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                Tween(frame, {BackgroundColor3=theme.Surface}, 0.15)
                Tween(arrow, {ImageColor3=theme.TextMuted}, 0.2)
            end)
            btn.MouseButton1Click:Connect(function()
                -- ripple
                ripple.Size = UDim2.new(0,0,0,0)
                ripple.BackgroundTransparency = 0.6
                Tween(ripple, {Size=UDim2.new(2,0,2,0), BackgroundTransparency=1}, 0.5)
                -- callback
                local ok, err = pcall(bcfg.Callback)
                if not ok then
                    frame.UIStroke.Color = theme.Error
                    task.delay(1, function() frame.UIStroke.Color = theme.Border end)
                    warn("[NexusUI] Button '"..bcfg.Name.."' error: "..tostring(err))
                end
            end)

            local bv = {}
            function bv:Set(newName) frame.Title.Text = newName end
            return bv
        end

        -- ── Toggle ───────────────────────────────────────────────────────────

        function tabObj:CreateToggle(tcfg)
            local hasDesc = tcfg.Description and tcfg.Description ~= ""
            local frame   = BaseElement(hasDesc and 52 or 42)
            frame.Name    = tcfg.Name

            ElemTitle(frame, tcfg.Name, tcfg.Description)

            local trackW, trackH = 42, 24
            local Track = New("Frame", {
                Size         = UDim2.new(0, trackW, 0, trackH),
                Position     = UDim2.new(1, -trackW-12, 0.5, 0),
                AnchorPoint  = Vector2.new(0, 0.5),
                BackgroundColor3 = tcfg.Default and theme.ToggleOn or theme.ToggleOff,
                BorderSizePixel  = 0,
                Parent       = frame,
            }, {New("UICorner",{CornerRadius=UDim.new(1,0)})})

            local Knob = New("Frame", {
                Size         = UDim2.new(0, 18, 0, 18),
                Position     = tcfg.Default and UDim2.new(1,-20,0.5,0) or UDim2.new(0,3,0.5,0),
                AnchorPoint  = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
                Parent       = Track,
            }, {
                New("UICorner",{CornerRadius=UDim.new(1,0)}),
                New("UIStroke", {Color = Color3.fromRGB(200,200,200), Thickness = 1}),
            })

            local val = tcfg.Default == true
            local toggleObj = {Type="Toggle", Value=val}

            local function SetToggle(newVal, fireCallback)
                val = newVal
                toggleObj.Value = val
                local onColor  = theme.ToggleOn
                local offColor = theme.ToggleOff
                Tween(Track, {BackgroundColor3 = val and onColor or offColor}, 0.25)
                Tween(Knob,  {Position = val and UDim2.new(1,-20,0.5,0) or UDim2.new(0,3,0.5,0)}, 0.25)
                if fireCallback ~= false and tcfg.Callback then
                    pcall(tcfg.Callback, val)
                end
                if Window._configEnabled then Window._saveAll() end
            end

            local btn = New("TextButton", {
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", Parent=frame
            })
            btn.MouseButton1Click:Connect(function() SetToggle(not val) end)
            btn.MouseEnter:Connect(function() Tween(frame,{BackgroundColor3=theme.SurfaceHover},0.15) end)
            btn.MouseLeave:Connect(function() Tween(frame,{BackgroundColor3=theme.Surface},0.15) end)

            function toggleObj:Set(newVal)
                SetToggle(newVal == true, true)
            end

            if tcfg.Flag then NexusUI.Flags[tcfg.Flag] = toggleObj end
            return toggleObj
        end

        -- ── Slider ───────────────────────────────────────────────────────────

        function tabObj:CreateSlider(scfg)
            local frame = BaseElement(62)
            frame.Name  = scfg.Name

            ElemTitle(frame, scfg.Name, scfg.Description)

            local valLabel = New("TextLabel", {
                Font         = Enum.Font.GothamBold,
                TextSize     = 12,
                TextColor3   = theme.Accent,
                Size         = UDim2.new(0,60,0,14),
                Position     = UDim2.new(1,-72,0,0),
                AnchorPoint  = Vector2.new(0,0),
                BackgroundTransparency=1,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent       = frame,
            })

            local trackFrame = New("Frame", {
                Size         = UDim2.new(1,-28,0,6),
                Position     = UDim2.new(0,14,1,-18),
                AnchorPoint  = Vector2.new(0,0.5),
                BackgroundColor3 = theme.SliderTrack,
                BorderSizePixel  = 0,
                Parent       = frame,
                ClipsDescendants = false,
            }, {New("UICorner",{CornerRadius=UDim.new(1,0)})})

            local fill = New("Frame", {
                Size         = UDim2.new(0,0,1,0),
                BackgroundColor3 = theme.SliderFill,
                BorderSizePixel  = 0,
                Parent       = trackFrame,
            }, {New("UICorner",{CornerRadius=UDim.new(1,0)})})

            local thumb = New("Frame", {
                Size         = UDim2.new(0,14,0,14),
                Position     = UDim2.new(0,0,0.5,0),
                AnchorPoint  = Vector2.new(0.5,0.5),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
                ZIndex       = 5,
                Parent       = trackFrame,
            }, {
                New("UICorner",{CornerRadius=UDim.new(1,0)}),
                New("UIStroke",{Color=theme.SliderFill, Thickness=2}),
            })

            local minV = scfg.Min or 0
            local maxV = scfg.Max or 100
            local inc  = scfg.Increment or 1
            local curV = math.clamp(scfg.Default or minV, minV, maxV)
            local suf  = scfg.Suffix or ""

            local sliderObj = {Type="Slider", Value=curV}

            local function UpdateDisplay(v)
                local pct = (v - minV) / (maxV - minV)
                fill.Size  = UDim2.new(pct, 0, 1, 0)
                thumb.Position = UDim2.new(pct, 0, 0.5, 0)
                valLabel.Text = tostring(v) .. (suf ~= "" and " "..suf or "")
            end
            UpdateDisplay(curV)

            local function SetSlider(v, fire)
                v = Round(Clamp(v, minV, maxV), inc)
                curV = v
                sliderObj.Value = v
                UpdateDisplay(v)
                if fire ~= false and scfg.Callback then pcall(scfg.Callback, v) end
                if Window._configEnabled then Window._saveAll() end
            end

            local dragging = false
            local interact = New("TextButton", {
                Size=UDim2.new(1,0,3,0), Position=UDim2.new(0,0,-1,0),
                BackgroundTransparency=1, Text="", ZIndex=6, Parent=trackFrame
            })

            interact.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            RunService.RenderStepped:Connect(function()
                if dragging then
                    local mx = UserInputService:GetMouseLocation().X
                    local ax = trackFrame.AbsolutePosition.X
                    local aw = trackFrame.AbsoluteSize.X
                    local pct = Clamp((mx - ax) / aw, 0, 1)
                    local newV = minV + pct * (maxV - minV)
                    SetSlider(newV)
                end
            end)

            function sliderObj:Set(v) SetSlider(v, true) end
            if scfg.Flag then NexusUI.Flags[scfg.Flag] = sliderObj end
            return sliderObj
        end

        -- ── Dropdown ─────────────────────────────────────────────────────────

        function tabObj:CreateDropdown(dcfg)
            dcfg = dcfg or {}
            local hasDesc = dcfg.Description and dcfg.Description ~= ""
            local baseH   = hasDesc and 52 or 42
            local multi   = dcfg.MultiSelect or false
            local opts    = dcfg.Options or {}

            -- current value
            local curOpts
            if multi then
                curOpts = type(dcfg.Default) == "table" and dcfg.Default
                          or (dcfg.Default and {dcfg.Default} or {})
            else
                curOpts = type(dcfg.Default) == "string" and dcfg.Default
                          or (opts[1] or "")
            end

            local frame = New("Frame", {
                Name             = dcfg.Name or "Dropdown",
                Size             = UDim2.new(1, 0, 0, baseH),
                BackgroundColor3 = theme.Surface,
                BorderSizePixel  = 0,
                LayoutOrder      = #Page:GetChildren(),
                ClipsDescendants = false,
                Parent           = Page,
            }, {
                New("UICorner", {CornerRadius = UDim.new(0, 8)}),
                New("UIStroke", {Color = theme.Border, Thickness = 1}),
            })

            ElemTitle(frame, dcfg.Name, dcfg.Description)

            -- Selected value label
            local selLabel = New("TextLabel", {
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextColor3       = theme.TextMuted,
                Size             = UDim2.new(0, 110, 0, 18),
                Position         = UDim2.new(1, -134, 0.5, 0),
                AnchorPoint      = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                TextXAlignment   = Enum.TextXAlignment.Right,
                TextTruncate     = Enum.TextTruncate.AtEnd,
                Parent           = frame,
            })

            -- Chevron arrow
            local chevron = New("ImageLabel", {
                Image            = GetIcon("chevrondown"),
                Size             = UDim2.new(0, 14, 0, 14),
                Position         = UDim2.new(1, -18, 0.5, 0),
                AnchorPoint      = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                ImageColor3      = theme.TextMuted,
                Parent           = frame,
            })

            local dropObj = {Type = "Dropdown", Value = curOpts}
            local isOpen  = false

            local function DisplayText()
                if multi then
                    if #curOpts == 0 then return "None"
                    elseif #curOpts == 1 then return curOpts[1]
                    else return #curOpts .. " selected" end
                else
                    return (curOpts == "" or curOpts == nil) and "None" or tostring(curOpts)
                end
            end

            local function RefreshLabel()
                selLabel.Text  = DisplayText()
                dropObj.Value  = curOpts
            end
            RefreshLabel()

            -- Floating dropdown list — parented to ScreenGui so it renders above everything
            local listPanel = New("Frame", {
                Name             = "DropList_" .. (dcfg.Name or ""),
                Size             = UDim2.new(0, 0, 0, 0), -- set dynamically
                BackgroundColor3 = theme.Elevated,
                BorderSizePixel  = 0,
                ZIndex           = 50,
                Visible          = false,
                Parent           = ScreenGui,
            }, {
                New("UICorner",  {CornerRadius = UDim.new(0, 8)}),
                New("UIStroke",  {Color = theme.Border, Thickness = 1}),
            })

            local listScroll = New("ScrollingFrame", {
                Size                 = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel      = 0,
                ScrollBarThickness   = 3,
                ScrollBarImageColor3 = theme.ScrollBar,
                CanvasSize           = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize  = Enum.AutomaticSize.Y,
                ClipsDescendants     = true,
                ZIndex               = 50,
                Parent               = listPanel,
            }, {
                New("UIListLayout",  {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}),
                New("UIPadding",     {PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6),PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6)}),
            })

            -- Position panel below the frame on screen
            local function PositionPanel()
                local absPos  = frame.AbsolutePosition
                local absSize = frame.AbsoluteSize
                local itemH   = 34
                local padV    = 12
                local count   = #opts
                local listH   = math.min(count * (itemH + 3) + padV, 200)
                local panelW  = absSize.X

                listPanel.Size     = UDim2.new(0, panelW, 0, listH)
                listPanel.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
            end

            -- Rebuild option rows
            local function BuildList()
                for _, c in ipairs(listScroll:GetChildren()) do
                    if c:IsA("Frame") then c:Destroy() end
                end
                for i, opt in ipairs(opts) do
                    local isSel = multi and (table.find(curOpts, opt) ~= nil) or (curOpts == opt)
                    local row = New("Frame", {
                        Name             = tostring(opt),
                        Size             = UDim2.new(1, 0, 0, 34),
                        BackgroundColor3 = isSel and theme.AccentDim or theme.Surface,
                        BorderSizePixel  = 0,
                        LayoutOrder      = i,
                        ZIndex           = 51,
                    }, {
                        New("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    })
                    if isSel then
                        New("UIStroke", {Color = theme.Accent, Thickness = 1, Parent = row})
                    end
                    New("TextLabel", {
                        Text             = tostring(opt),
                        Font             = Enum.Font.GothamSemibold,
                        TextSize         = 13,
                        TextColor3       = isSel and theme.Accent or theme.Text,
                        Size             = UDim2.new(1, -38, 1, 0),
                        Position         = UDim2.new(0, 10, 0, 0),
                        BackgroundTransparency = 1,
                        TextXAlignment   = Enum.TextXAlignment.Left,
                        ZIndex           = 52,
                        Parent           = row,
                    })
                    if isSel then
                        New("ImageLabel", {
                            Image            = GetIcon("check"),
                            Size             = UDim2.new(0, 13, 0, 13),
                            Position         = UDim2.new(1, -22, 0.5, 0),
                            AnchorPoint      = Vector2.new(0.5, 0.5),
                            BackgroundTransparency = 1,
                            ImageColor3      = theme.Accent,
                            ZIndex           = 52,
                            Parent           = row,
                        })
                    end
                    -- click handler
                    local hitbox = New("TextButton", {
                        Size             = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text             = "",
                        ZIndex           = 53,
                        Parent           = row,
                    })
                    hitbox.MouseEnter:Connect(function()
                        if not isSel then
                            Tween(row, {BackgroundColor3 = theme.SurfaceHover}, 0.1)
                        end
                    end)
                    hitbox.MouseLeave:Connect(function()
                        if not isSel then
                            Tween(row, {BackgroundColor3 = theme.Surface}, 0.1)
                        end
                    end)
                    hitbox.MouseButton1Click:Connect(function()
                        if multi then
                            local idx = table.find(curOpts, opt)
                            if idx then table.remove(curOpts, idx)
                            else table.insert(curOpts, opt) end
                            RefreshLabel()
                            BuildList()
                            if dcfg.Callback then pcall(dcfg.Callback, curOpts) end
                            if Window._configEnabled then Window._saveAll() end
                        else
                            curOpts = opt
                            RefreshLabel()
                            BuildList()
                            if dcfg.Callback then pcall(dcfg.Callback, curOpts) end
                            if Window._configEnabled then Window._saveAll() end
                            -- close on single select
                            isOpen = false
                            listPanel.Visible = false
                            Tween(chevron, {Rotation = 0, ImageColor3 = theme.TextMuted}, 0.2)
                        end
                    end)
                    row.Parent = listScroll
                end
            end
            BuildList()

            -- Toggle open/close
            local toggleBtn = New("TextButton", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 4,
                Parent           = frame,
            })

            local function OpenDropdown()
                isOpen = true
                BuildList()
                PositionPanel()
                listPanel.Visible = true
                Tween(chevron, {Rotation = 180, ImageColor3 = theme.Accent}, 0.2)
                Tween(frame, {BackgroundColor3 = theme.SurfaceHover}, 0.15)
            end

            local function CloseDropdown()
                isOpen = false
                listPanel.Visible = false
                Tween(chevron, {Rotation = 0, ImageColor3 = theme.TextMuted}, 0.2)
                Tween(frame, {BackgroundColor3 = theme.Surface}, 0.15)
            end

            toggleBtn.MouseButton1Click:Connect(function()
                if isOpen then CloseDropdown() else OpenDropdown() end
            end)

            -- Close when clicking outside
            UserInputService.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    if isOpen then
                        local mx, my = inp.Position.X, inp.Position.Y
                        local pp = listPanel.AbsolutePosition
                        local ps = listPanel.AbsoluteSize
                        local fp = frame.AbsolutePosition
                        local fs = frame.AbsoluteSize
                        local inList  = mx >= pp.X and mx <= pp.X+ps.X and my >= pp.Y and my <= pp.Y+ps.Y
                        local inFrame = mx >= fp.X and mx <= fp.X+fs.X and my >= fp.Y and my <= fp.Y+fs.Y
                        if not inList and not inFrame then
                            CloseDropdown()
                        end
                    end
                end
            end)

            function dropObj:Set(val)
                if multi then
                    curOpts = type(val) == "table" and val or {val}
                else
                    curOpts = val
                end
                RefreshLabel()
                BuildList()
            end
            function dropObj:Refresh(newOpts)
                opts = newOpts
                BuildList()
            end
            function dropObj:Close() CloseDropdown() end

            if dcfg.Flag then NexusUI.Flags[dcfg.Flag] = dropObj end
            return dropObj
        end

        -- ── Input ────────────────────────────────────────────────────────────

        function tabObj:CreateInput(icfg)
            local hasDesc = icfg.Description and icfg.Description ~= ""
            local frame   = BaseElement(hasDesc and 66 or 54)
            frame.Name    = icfg.Name

            ElemTitle(frame, icfg.Name, icfg.Description)

            local inputFrame = New("Frame", {
                Size         = UDim2.new(1,-28,0,28),
                Position     = UDim2.new(0,14,1,-36),
                BackgroundColor3 = theme.InputBg,
                BorderSizePixel  = 0,
                Parent       = frame,
            }, {
                New("UICorner",{CornerRadius=UDim.new(0,6)}),
                New("UIStroke",{Color=theme.Border}),
                New("TextBox", {
                    Name         = "Input",
                    Size         = UDim2.new(1,-16,1,0),
                    Position     = UDim2.new(0,10,0,0),
                    BackgroundTransparency=1,
                    PlaceholderText = icfg.Placeholder or "Type here...",
                    PlaceholderColor3 = theme.TextDisabled,
                    Font         = Enum.Font.Gotham,
                    TextSize     = 13,
                    TextColor3   = theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text         = icfg.Default or "",
                    ClearTextOnFocus = icfg.ClearOnFocus or false,
                }),
            })

            local textbox = inputFrame.Input
            local inputObj = {Type="Input", Value=icfg.Default or ""}

            textbox.Focused:Connect(function()
                Tween(inputFrame.UIStroke, {Color=theme.Accent}, 0.15)
            end)
            textbox.FocusLost:Connect(function(enter)
                Tween(inputFrame.UIStroke, {Color=theme.Border}, 0.15)
                inputObj.Value = textbox.Text
                if icfg.Callback then pcall(icfg.Callback, textbox.Text) end
                if icfg.ClearOnFocus then textbox.Text = "" end
                if Window._configEnabled then Window._saveAll() end
            end)

            function inputObj:Set(val)
                textbox.Text = tostring(val)
                inputObj.Value = val
            end
            if icfg.Flag then NexusUI.Flags[icfg.Flag] = inputObj end
            return inputObj
        end

        -- ── Keybind ──────────────────────────────────────────────────────────

        function tabObj:CreateKeybind(kcfg)
            local hasDesc = kcfg.Description and kcfg.Description ~= ""
            local frame   = BaseElement(hasDesc and 52 or 42)
            frame.Name    = kcfg.Name

            ElemTitle(frame, kcfg.Name, kcfg.Description)

            local defKey = kcfg.Default
            if typeof(defKey) == "EnumItem" then defKey = defKey.Name
            elseif defKey == nil then defKey = "None" end

            local keyBox = New("Frame", {
                Size         = UDim2.new(0, 0, 0, 26),
                AutomaticSize= Enum.AutomaticSize.X,
                Position     = UDim2.new(1,-14,0.5,0),
                AnchorPoint  = Vector2.new(1,0.5),
                BackgroundColor3 = theme.InputBg,
                BorderSizePixel  = 0,
                Parent       = frame,
            }, {
                New("UICorner",{CornerRadius=UDim.new(0,6)}),
                New("UIStroke",{Color=theme.Border}),
                New("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)}),
                New("TextLabel",{
                    Name         = "Key",
                    Text         = defKey,
                    Font         = Enum.Font.GothamBold,
                    TextSize     = 12,
                    TextColor3   = theme.Accent,
                    Size         = UDim2.new(0,0,1,0),
                    AutomaticSize= Enum.AutomaticSize.X,
                    BackgroundTransparency=1,
                    TextXAlignment = Enum.TextXAlignment.Center,
                }),
            })

            local curKey  = defKey
            local waiting = false
            local kbObj   = {Type="Keybind", Value=curKey}

            local function SetKey(k)
                curKey = k
                kbObj.Value = k
                keyBox.Key.Text = k
                keyBox.UIStroke.Color = theme.Border
                keyBox.Key.TextColor3 = theme.Accent
                if Window._configEnabled then Window._saveAll() end
            end

            local interactBtn = New("TextButton", {
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=5, Parent=frame
            })
            interactBtn.MouseButton1Click:Connect(function()
                if waiting then return end
                waiting = true
                keyBox.UIStroke.Color = theme.Accent
                keyBox.Key.TextColor3 = theme.Warning
                keyBox.Key.Text = "..."
            end)

            local kConn = UserInputService.InputBegan:Connect(function(inp, proc)
                if waiting then
                    if inp.KeyCode ~= Enum.KeyCode.Unknown then
                        local kname = inp.KeyCode.Name
                        waiting = false
                        SetKey(kname)
                        if kcfg.Callback then pcall(kcfg.Callback, kname) end
                    end
                elseif not proc and curKey ~= "None" then
                    local ok, kc = pcall(function() return Enum.KeyCode[curKey] end)
                    if ok and inp.KeyCode == kc then
                        if kcfg.Callback then pcall(kcfg.Callback) end
                    end
                end
            end)
            table.insert(NexusUI._Conns, kConn)

            function kbObj:Set(k)
                if typeof(k) == "EnumItem" then k = k.Name end
                SetKey(tostring(k))
            end
            if kcfg.Flag then NexusUI.Flags[kcfg.Flag] = kbObj end
            return kbObj
        end

        -- ── Color Picker ─────────────────────────────────────────────────────

        function tabObj:CreateColorPicker(cpcfg)
            local frame = New("Frame", {
                Name             = cpcfg.Name,
                Size             = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = theme.Surface,
                BorderSizePixel  = 0,
                LayoutOrder      = #Page:GetChildren(),
                ClipsDescendants = true,
                Parent           = Page,
            }, {
                New("UICorner",  {CornerRadius=UDim.new(0,8)}),
                New("UIStroke",  {Color=theme.Border, Thickness=1}),
            })

            ElemTitle(frame, cpcfg.Name, cpcfg.Description)

            local defColor = cpcfg.Default or Color3.fromRGB(255,100,100)
            local h, s, v  = Color3.toHSV(defColor)

            local preview = New("Frame", {
                Size         = UDim2.new(0,28,0,28),
                Position     = UDim2.new(1,-42,0.5,0),
                AnchorPoint  = Vector2.new(0,0.5),
                BackgroundColor3 = defColor,
                BorderSizePixel  = 0,
                Parent       = frame,
            }, {
                New("UICorner",{CornerRadius=UDim.new(0,6)}),
                New("UIStroke",{Color=theme.Border}),
            })

            -- Expand panel
            local panelH = 160
            local isOpen = false

            local panel = New("Frame", {
                Size         = UDim2.new(1,-28,0,panelH),
                Position     = UDim2.new(0,14,0,50),
                BackgroundTransparency=1,
                ClipsDescendants=false,
                Parent       = frame,
            })

            -- Saturation/Value picker
            local svPicker = New("ImageLabel", {
                Name         = "SVPicker",
                Size         = UDim2.new(1,-44,1,0),
                Position     = UDim2.new(0,0,0,0),
                Image        = "rbxassetid://4155801252",
                BackgroundColor3 = Color3.fromHSV(h,1,1),
                ScaleType    = Enum.ScaleType.Stretch,
                Parent       = panel,
            }, {New("UICorner",{CornerRadius=UDim.new(0,6)})})

            -- Hue slider (vertical, right)
            local huePicker = New("Frame", {
                Name         = "HuePicker",
                Size         = UDim2.new(0,20,1,0),
                Position     = UDim2.new(1,-20,0,0),
                AnchorPoint  = Vector2.new(0,0),
                Parent       = panel,
            }, {
                New("UICorner",{CornerRadius=UDim.new(0,6)}),
                New("UIGradient",{
                    Rotation=270,
                    Color=ColorSequence.new({
                        ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
                        ColorSequenceKeypoint.new(0.167,Color3.fromRGB(255,255,0)),
                        ColorSequenceKeypoint.new(0.333,Color3.fromRGB(0,255,0)),
                        ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,255,255)),
                        ColorSequenceKeypoint.new(0.667,Color3.fromRGB(0,0,255)),
                        ColorSequenceKeypoint.new(0.833,Color3.fromRGB(255,0,255)),
                        ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0)),
                    })
                }),
            })

            local svCursor = New("Frame", {
                Size         = UDim2.new(0,12,0,12),
                AnchorPoint  = Vector2.new(0.5,0.5),
                Position     = UDim2.new(s,0,1-v,0),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
                ZIndex       = 5,
                Parent       = svPicker,
            }, {
                New("UICorner",{CornerRadius=UDim.new(1,0)}),
                New("UIStroke",{Color=Color3.fromRGB(0,0,0),Thickness=1.5}),
            })

            local hueCursor = New("Frame", {
                Size         = UDim2.new(1,4,0,4),
                Position     = UDim2.new(0,-2,1-h,0),
                AnchorPoint  = Vector2.new(0,0.5),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
                ZIndex       = 5,
                Parent       = huePicker,
            }, {New("UICorner",{CornerRadius=UDim.new(0,2)})})

            local cpObj = {Type="ColorPicker", Value=defColor}

            local function UpdateCP()
                local color = Color3.fromHSV(h, s, v)
                cpObj.Value = color
                preview.BackgroundColor3 = color
                svPicker.BackgroundColor3 = Color3.fromHSV(h,1,1)
                svCursor.Position = UDim2.new(s,0,1-v,0)
                hueCursor.Position = UDim2.new(0,-2,1-h,0)
                if cpcfg.Callback then pcall(cpcfg.Callback, color) end
                if Window._configEnabled then Window._saveAll() end
            end

            local dragSV, dragHue = false, false

            New("TextButton",{
                Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=6,Parent=svPicker
            }).InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                    dragSV = true
                end
            end)
            New("TextButton",{
                Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=6,Parent=huePicker
            }).InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                    dragHue = true
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                    dragSV = false; dragHue = false
                end
            end)
            RunService.RenderStepped:Connect(function()
                local mPos = UserInputService:GetMouseLocation()
                if dragSV then
                    local ax,ay = svPicker.AbsolutePosition.X, svPicker.AbsolutePosition.Y
                    local aw,ah = svPicker.AbsoluteSize.X, svPicker.AbsoluteSize.Y
                    s = Clamp((mPos.X-ax)/aw, 0, 1)
                    v = 1-Clamp((mPos.Y-ay)/ah, 0, 1)
                    UpdateCP()
                end
                if dragHue then
                    local ay = huePicker.AbsolutePosition.Y
                    local ah = huePicker.AbsoluteSize.Y
                    h = 1-Clamp((mPos.Y-ay)/ah, 0, 1)
                    UpdateCP()
                end
            end)

            -- Toggle open
            local openBtn = New("TextButton", {
                Size=UDim2.new(1,0,0,42), BackgroundTransparency=1, Text="", ZIndex=4, Parent=frame
            })
            openBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                Tween(frame, {Size=UDim2.new(1,0,0, isOpen and 42+panelH+8 or 42)}, 0.3)
            end)
            openBtn.MouseEnter:Connect(function() Tween(frame,{BackgroundColor3=theme.SurfaceHover},0.15) end)
            openBtn.MouseLeave:Connect(function() Tween(frame,{BackgroundColor3=theme.Surface},0.15) end)

            function cpObj:Set(color)
                h,s,v = Color3.toHSV(color)
                cpObj.Value = color
                UpdateCP()
            end
            if cpcfg.Flag then NexusUI.Flags[cpcfg.Flag] = cpObj end
            return cpObj
        end

        -- ── Return tab ───────────────────────────────────────────────────────
        return tabObj
    end

    -- ── Notify shortcut on window ─────────────────────────────────────────────

    function Window:Notify(ncfg)
        return NexusUI:Notify(ncfg)
    end

    -- ── LoadConfig ────────────────────────────────────────────────────────────

    function Window:LoadConfig()
        if not configEnabled then return end
        local data = ReadConfig()
        if not data then
            self:Notify({Title="NexusUI Configs", Content="No saved configuration found.", Icon="info", Duration=4})
            return
        end
        local loaded = 0
        for flag, val in pairs(data) do
            if NexusUI.Flags[flag] then
                local elem = NexusUI.Flags[flag]
                if elem.Type == "ColorPicker" then
                    local ok, color = pcall(function()
                        return Color3.fromRGB(val.r, val.g, val.b)
                    end)
                    if ok then elem:Set(color) end
                else
                    pcall(function() elem:Set(val) end)
                end
                loaded += 1
            end
        end
        self:Notify({
            Title="Configuration Loaded",
            Content="Restored "..loaded.." saved settings.",
            Icon="save", Type="success", Duration=4
        })
    end

    -- ── SaveConfig ────────────────────────────────────────────────────────────

    function Window:SaveConfig()
        SaveAll()
        self:Notify({
            Title="Configuration Saved",
            Content="Settings saved to "..configFile,
            Icon="save", Type="success", Duration=3
        })
    end

    -- ── ChangeTheme ──────────────────────────────────────────────────────────

    function Window:SetTheme(themeName)
        local newTheme = Themes[themeName]
        if not newTheme then
            self:Notify({Title="Theme Error", Content="Theme '"..themeName.."' not found.", Icon="alert", Type="error"})
            return
        end
        theme = newTheme
        self._theme = newTheme
        NexusUI._theme = newTheme
        -- Note: full re-theme would require re-parenting all elements.
        -- For now, this is a lightweight version.
        self:Notify({Title="Theme Changed", Content="Switched to "..themeName.." theme.", Icon="palette", Duration=3})
    end

    -- ── Destroy ──────────────────────────────────────────────────────────────

    function Window:Destroy()
        NexusUI._Destroyed = true
        for _, c in ipairs(NexusUI._Conns) do c:Disconnect() end
        ScreenGui:Destroy()
    end

    -- Animate in complete
    task.delay(4, function()
        if configEnabled then
            Window:LoadConfig()
        end
    end)

    table.insert(NexusUI.Windows, Window)
    return Window
end

-- ─── Quick loader ─────────────────────────────────────────────────────────────

function NexusUI:GetThemes()
    local names = {}
    for k in pairs(Themes) do names[#names+1] = k end
    return names
end

return NexusUI
