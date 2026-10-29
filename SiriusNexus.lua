--!native
--!optimize 2

--[[
    SiriusNexus SDK v2.0 (Unified Rayfield + Sirius Gen2 Reactive Framework)
    Author: morik_yt.
    Features:
      - Built-in Premium Preview & Lock Gate (PremiumOnly flag on any UI element)
      - Auto-Syncing Player Selector & Searchable Dynamic Dropdowns
      - Automatic Connection / Loop Maid (Heartbeat, Stepped, RenderStepped, Interval)
      - Full compatibility with Paragraph, Input, Slider, Toggle, Dropdown, Button
]]

local Env = {}
Env.Global = (type(getgenv) == "function" and getgenv()) or _G
Env.CloneRef = (type(cloneref) == "function" and cloneref) or function(inst) return inst end

function Env:GetService(name: string)
    local ok, svc = pcall(game.GetService, game, name)
    return (ok and svc and self.CloneRef(svc)) or nil
end

local Players = Env:GetService("Players")
local RunService = Env:GetService("RunService")
local TweenService = Env:GetService("TweenService")
local Workspace = Env:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

if Env.Global.__SIRIUS_NEXUS_ACTIVE then
    pcall(function()
        Env.Global.__SIRIUS_NEXUS_ACTIVE:Destroy()
    end)
end

-- ============================================================================
-- MAID (LIFECYCLE & CONNECTION JANITOR)
-- ============================================================================
local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({ _tasks = {} }, Maid)
end

function Maid:Add(taskItem: any, key: string?)
    if key then
        self:CleanKey(key)
        self._tasks[key] = taskItem
    else
        table.insert(self._tasks, taskItem)
    end
    return taskItem
end

function Maid:CleanKey(key: string)
    local existing = self._tasks[key]
    if existing then
        self:_clean(existing)
        self._tasks[key] = nil
    end
end

function Maid:_clean(item: any)
    local t = typeof(item)
    if t == "RBXScriptConnection" then
        if item.Connected then item:Disconnect() end
    elseif t == "Instance" then
        pcall(item.Destroy, item)
    elseif t == "thread" then
        pcall(task.cancel, item)
    elseif type(item) == "function" then
        pcall(item)
    elseif type(item) == "table" and type(item.Destroy) == "function" then
        pcall(item.Destroy, item)
    end
end

function Maid:DoCleaning()
    for k, v in pairs(self._tasks) do
        self:_clean(v)
        self._tasks[k] = nil
    end
end

Maid.Destroy = Maid.DoCleaning

-- ============================================================================
-- GAMEPLAY UTILITIES
-- ============================================================================
local Utils = {}

function Utils:GetCharacter(plr: Player?): Model?
    local target = plr or LocalPlayer
    return target and target.Character or nil
end

function Utils:GetHumanoid(plr: Player?): Humanoid?
    local char = self:GetCharacter(plr)
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end

function Utils:GetRootPart(plr: Player?): BasePart?
    local char = self:GetCharacter(plr)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart")
end

function Utils:FreezeRoot(root: BasePart?)
    local targetRoot = root or self:GetRootPart(LocalPlayer)
    if targetRoot then
        targetRoot.AssemblyLinearVelocity = Vector3.zero
        targetRoot.AssemblyAngularVelocity = Vector3.zero
    end
end

function Utils:SafeTeleport(targetCFrame: CFrame, offset: Vector3?, smoothDuration: number?): boolean
    local char = self:GetCharacter(LocalPlayer)
    local hum = self:GetHumanoid(LocalPlayer)
    local root = self:GetRootPart(LocalPlayer)
    if not (char and root) then return false end

    local dest = targetCFrame * CFrame.new(offset or Vector3.zero)
    if hum and hum.Sit then
        hum.Sit = false
        task.wait(0.05)
    end

    self:FreezeRoot(root)

    if smoothDuration and smoothDuration > 0 then
        TweenService:Create(root, TweenInfo.new(smoothDuration, Enum.EasingStyle.Linear), { CFrame = dest }):Play()
    else
        root.CFrame = dest
    end
    return true
end

-- ============================================================================
-- SIRIUS NEXUS CORE
-- ============================================================================
local SiriusNexus = {}
SiriusNexus.__index = SiriusNexus
SiriusNexus.Utils = Utils
SiriusNexus.Env = Env

function SiriusNexus:CreateWindow(config: { [string]: any })
    local folder = config.ConfigurationSaving and config.ConfigurationSaving.FolderName or "SiriusNexus"
    if type(isfolder) == "function" and type(makefolder) == "function" then
        if not isfolder(folder) then makefolder(folder) end
    end

    local coreLib = nil
    local cachePath = folder .. "/rayfield_core.lua"

    local okFetch, body = pcall(function()
        return game:HttpGet("https://sirius.menu/rayfield")
    end)

    if okFetch and body and #body > 100 then
        if type(writefile) == "function" then
            pcall(writefile, cachePath, body)
        end
        coreLib = loadstring(body)()
    elseif type(isfile) == "function" and isfile(cachePath) then
        coreLib = loadstring(readfile(cachePath))()
    end

    assert(coreLib, "[SiriusNexus] Failed to load UI Core. Check your connection.")

    local rawWindow = coreLib:CreateWindow(config)

    local selfWindow = setmetatable({
        _core = coreLib,
        _window = rawWindow,
        _maid = Maid.new(),
        _flags = {},
        _listeners = {},
        _isPremium = false,
        _onPremiumBlocked = nil,
        Utils = Utils
    }, SiriusNexus)

    Env.Global.__SIRIUS_NEXUS_ACTIVE = selfWindow
    return selfWindow
end

function SiriusNexus:SetPremiumStatus(isPremium: boolean, onBlockedCallback: (() -> ())?)
    self._isPremium = isPremium == true
    self._onPremiumBlocked = onBlockedCallback
end

function SiriusNexus:IsPremium(): boolean
    return self._isPremium
end

function SiriusNexus:TriggerPremiumBlocked()
    if self._onPremiumBlocked then
        task.spawn(self._onPremiumBlocked)
    else
        self:Notify("🔒 Premium Feature", "Purchase Premium ($1) in Discord: morik_yt.", 5)
    end
end

function SiriusNexus:Notify(title: string, content: string, duration: number?, image: number?)
    self._core:Notify({
        Title = title,
        Content = content,
        Duration = duration or 4,
        Image = image or 7733964719
    })
end

function SiriusNexus:SetFlag(flag: string, value: any)
    self._flags[flag] = value
    if self._listeners[flag] then
        for _, fn in ipairs(self._listeners[flag]) do
            task.spawn(fn, value)
        end
    end
end

function SiriusNexus:GetFlag(flag: string): any
    if self._flags[flag] ~= nil then return self._flags[flag] end
    local f = self._core.Flags and self._core.Flags[flag]
    return f and f.CurrentValue or nil
end

function SiriusNexus:BindConnection(signal: RBXScriptSignal, callback: (...any) -> (), key: string?)
    return self._maid:Add(signal:Connect(callback), key)
end

function SiriusNexus:AddTask(taskItem: any, key: string?)
    return self._maid:Add(taskItem, key)
end

function SiriusNexus:CleanTask(key: string)
    self._maid:CleanKey(key)
end

function SiriusNexus:LoadConfiguration()
    if self._core and self._core.LoadConfiguration then
        pcall(function() self._core:LoadConfiguration() end)
    end
end

function SiriusNexus:Destroy()
    self._maid:DoCleaning()
    if self._core and self._core.Destroy then
        pcall(function() self._core:Destroy() end)
    end
    if Env.Global.__SIRIUS_NEXUS_ACTIVE == self then
        Env.Global.__SIRIUS_NEXUS_ACTIVE = nil
    end
end

-- ============================================================================
-- TAB & COMPONENT BUILDERS (WITH AUTOMATIC PREMIUM LOCK SUPPORT)
-- ============================================================================
function SiriusNexus:CreateTab(name: string, icon: (string | number)?)
    local rawTab = self._window:CreateTab(name, icon)
    local win = self
    local Tab = {}

    local function formatName(rawName: string, isPremOnly: boolean?): string
        if isPremOnly and not win._isPremium then
            return "🔒 " .. rawName
        end
        return rawName
    end

    function Tab:CreateSection(title: string)
        return rawTab:CreateSection(title)
    end

    function Tab:CreateDivider()
        if rawTab.CreateDivider then return rawTab:CreateDivider() end
    end

    function Tab:CreateParagraph(config: { Title: string, Content: string })
        return rawTab:CreateParagraph(config)
    end

    function Tab:CreateButton(config: { Name: string, PremiumOnly: boolean?, Callback: () -> () })
        return rawTab:CreateButton({
            Name = formatName(config.Name, config.PremiumOnly),
            Callback = function()
                if config.PremiumOnly and not win._isPremium then
                    win:TriggerPremiumBlocked()
                    return
                end
                local ok, err = pcall(config.Callback)
                if not ok then warn("[SiriusNexus Button Error]:", err) end
            end
        })
    end

    function Tab:CreateInput(config: {
        Name: string,
        CurrentValue: string?,
        PlaceholderText: string?,
        RemoveTextAfterFocusLost: boolean?,
        PremiumOnly: boolean?,
        Callback: (string) -> ()
    })
        return rawTab:CreateInput({
            Name = formatName(config.Name, config.PremiumOnly),
            CurrentValue = config.CurrentValue or "",
            PlaceholderText = config.PlaceholderText or "",
            RemoveTextAfterFocusLost = config.RemoveTextAfterFocusLost or false,
            Callback = function(text: string)
                if config.PremiumOnly and not win._isPremium then
                    win:TriggerPremiumBlocked()
                    return
                end
                if config.Callback then config.Callback(text) end
            end
        })
    end

    function Tab:CreateSlider(config: {
        Name: string,
        Range: { number },
        Increment: number?,
        Suffix: string?,
        CurrentValue: number?,
        Default: number?,
        Flag: string?,
        PremiumOnly: boolean?,
        Callback: ((number) -> ())?
    })
        local val = config.CurrentValue or config.Default or config.Range[1]
        local flag = config.Flag or config.Name:gsub("%s+", "")
        win:SetFlag(flag, val)

        local rawSlider = rawTab:CreateSlider({
            Name = formatName(config.Name, config.PremiumOnly),
            Range = config.Range,
            Increment = config.Increment or 1,
            Suffix = config.Suffix or "",
            CurrentValue = val,
            Flag = flag,
            Callback = function(newVal: number)
                if config.PremiumOnly and not win._isPremium then
                    win:TriggerPremiumBlocked()
                    return
                end
                win:SetFlag(flag, newVal)
                if config.Callback then config.Callback(newVal) end
            end
        })

        return rawSlider
    end

    function Tab:CreateDropdown(config: {
        Name: string,
        Options: { string },
        CurrentOption: any,
        MultipleOptions: boolean?,
        Flag: string?,
        PremiumOnly: boolean?,
        Callback: ((any) -> ())?
    })
        local flag = config.Flag
        local rawDropdown = rawTab:CreateDropdown({
            Name = formatName(config.Name, config.PremiumOnly),
            Options = config.Options or {},
            CurrentOption = config.CurrentOption or {},
            MultipleOptions = config.MultipleOptions or false,
            Flag = flag,
            Callback = function(opts)
                if config.PremiumOnly and not win._isPremium then
                    win:TriggerPremiumBlocked()
                    return
                end
                if flag then win:SetFlag(flag, opts) end
                if config.Callback then config.Callback(opts) end
            end
        })
        return rawDropdown
    end

    function Tab:CreateToggle(config: {
        Name: string,
        CurrentValue: boolean?,
        Default: boolean?,
        Flag: string?,
        Loop: (string | number)?,
        PremiumOnly: boolean?,
        Callback: ((boolean) -> ())?,
        OnTick: ((number) -> ())?
    })
        local flag = config.Flag or config.Name:gsub("%s+", "")
        local loopKey = "ToggleLoop_" .. flag
        local initial = (config.CurrentValue ~= nil and config.CurrentValue) or config.Default or false
        if config.PremiumOnly and not win._isPremium then
            initial = false
        end

        local rawToggle
        local isResetting = false

        local function syncLoop(state: boolean)
            win:CleanTask(loopKey)
            if not state or not config.OnTick then return end

            if config.Loop == "Heartbeat" or config.Loop == nil then
                win:BindConnection(RunService.Heartbeat, config.OnTick, loopKey)
            elseif config.Loop == "Stepped" then
                win:BindConnection(RunService.Stepped, function(_, dt) config.OnTick(dt) end, loopKey)
            elseif config.Loop == "RenderStepped" then
                win:BindConnection(RunService.RenderStepped, config.OnTick, loopKey)
            elseif type(config.Loop) == "number" then
                local interval = math.max(0.05, config.Loop)
                local thread = task.spawn(function()
                    while true do
                        config.OnTick(interval)
                        task.wait(interval)
                    end
                end)
                win:AddTask(thread, loopKey)
            end
        end

        rawToggle = rawTab:CreateToggle({
            Name = formatName(config.Name, config.PremiumOnly),
            CurrentValue = initial,
            Flag = flag,
            Callback = function(state: boolean)
                if isResetting then return end
                if config.PremiumOnly and not win._isPremium then
                    if state then
                        win:TriggerPremiumBlocked()
                        isResetting = true
                        task.defer(function()
                            if rawToggle and rawToggle.Set then
                                pcall(rawToggle.Set, rawToggle, false)
                            end
                            isResetting = false
                        end)
                    end
                    return
                end

                win:SetFlag(flag, state)
                if config.Callback then
                    task.spawn(config.Callback, state)
                end
                syncLoop(state)
            end
        })

        return rawToggle
    end

    return Tab
end

return SiriusNexus
