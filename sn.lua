--!nonstrict
--!optimize 2

--[[
    SiriusNexus v3.0 (Rayfield Gen2 based)
    Author: morik_yt.

    A layer on top of Rayfield Gen2. It does not draw UI itself. It adds
      Maid, Loop, Utils, Net, Signal
      Premium gate (lock, buy popup, verifier hook, server module loader hook)
      Auto updating player dropdown, searchable dropdowns, search input
      Safe callbacks (an error in your callback never breaks the UI)
      Hotkeys, UI toggle key, notifications with dedupe, confirm popup
      Settings tab (theme, UI key, language, config profiles, unload)
      Nexus Midnight and Nexus Abyss themes
      Gen1 style API compatibility (Name, CurrentValue, Callback, Options...)

    There is NO hardcoded premium flag. Premium comes only from
    Window:SetPremiumVerifier(fn) or Window:SetPremiumStatus(bool).
    Real protection must live on your server. Deliver the paid code through
    Window:SetPremiumLoader(fn) after the server confirms the license.
]]

local Nexus = {
    Version = "3.0.0",
    Price = "$5",
}

-- ============================================================================
-- ENV
-- ============================================================================
local unpack = table.unpack or unpack
local Env = {}
Env.Global = (type(getgenv) == "function" and getgenv()) or _G
Env.CloneRef = (type(cloneref) == "function" and cloneref) or function(inst) return inst end

function Env:GetService(name)
    local ok, svc = pcall(function() return game:GetService(name) end)
    if not ok or not svc then return nil end
    local ok2, ref = pcall(Env.CloneRef, svc)
    return ok2 and ref or svc
end

local Players          = Env:GetService("Players")
local RunService       = Env:GetService("RunService")
local TweenService     = Env:GetService("TweenService")
local UserInputService = Env:GetService("UserInputService")
local HttpService      = Env:GetService("HttpService")
local LocalPlayer      = Players and Players.LocalPlayer

Nexus.Env = Env

local LOCK = "\u{1F512} "

local function pick(t, ...)
    for i = 1, select("#", ...) do
        local v = t[(select(i, ...))]
        if v ~= nil then return v end
    end
    return nil
end

local function copyList(t)
    local o = {}
    if type(t) == "table" then
        for i, v in ipairs(t) do o[i] = v end
    end
    return o
end

local function toIcon(v)
    if type(v) == "number" then
        if v ~= 0 then return v end
        return nil
    end
    if type(v) == "string" and v:find("^rbx") then return v end
    return nil -- Gen2 has no Lucide names, so Gen1 style names are dropped
end

local function toKeyCode(v)
    if typeof(v) == "EnumItem" then return v end
    if type(v) == "string" then
        local ok, k = pcall(function() return Enum.KeyCode[v] end)
        if ok then return k end
    end
    return nil
end

local function stripLock(name)
    name = tostring(name)
    if name:sub(1, #LOCK) == LOCK then return name:sub(#LOCK + 1) end
    return name
end

-- ============================================================================
-- SIGNAL
-- ============================================================================
local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({ _h = {} }, Signal)
end

function Signal:Connect(fn)
    local handler = { fn = fn }
    table.insert(self._h, handler)
    local conn = { Connected = true }
    function conn.Disconnect()
        conn.Connected = false
        for i, h in ipairs(self._h) do
            if h == handler then table.remove(self._h, i) break end
        end
    end
    return conn
end

function Signal:Fire(...)
    local snapshot = copyList(self._h)
    for _, h in ipairs(snapshot) do
        task.spawn(h.fn, ...)
    end
end

function Signal:Destroy()
    self._h = {}
end

Nexus.Signal = Signal

-- ============================================================================
-- MAID
-- ============================================================================
local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({ _tasks = {}, _n = 0 }, Maid)
end

function Maid:_clean(item)
    local t = typeof(item)
    if t == "RBXScriptConnection" then
        if item.Connected then item:Disconnect() end
    elseif t == "Instance" then
        pcall(item.Destroy, item)
    elseif t == "thread" then
        pcall(task.cancel, item)
    elseif type(item) == "function" then
        pcall(item)
    elseif type(item) == "table" then
        if type(item.Destroy) == "function" then
            pcall(item.Destroy, item)
        elseif type(item.Disconnect) == "function" then
            pcall(item.Disconnect, item)
        end
    end
end

function Maid:Add(item, key)
    if key ~= nil then
        self:CleanKey(key)
        self._tasks[key] = item
    else
        self._n = self._n + 1
        self._tasks[self._n] = item
    end
    return item
end

function Maid:Connect(signal, fn, key)
    return self:Add(signal:Connect(fn), key)
end

function Maid:CleanKey(key)
    local existing = self._tasks[key]
    if existing ~= nil then
        self._tasks[key] = nil
        self:_clean(existing)
    end
end

function Maid:Has(key)
    return self._tasks[key] ~= nil
end

function Maid:DoCleaning()
    local snapshot = {}
    for k, v in pairs(self._tasks) do snapshot[k] = v end
    self._tasks = {}
    for _, v in pairs(snapshot) do self:_clean(v) end
end

Maid.Destroy = Maid.DoCleaning
Nexus.Maid = Maid

-- ============================================================================
-- UTILS
-- ============================================================================
local Utils = {}

function Utils:GetCharacter(plr)
    local target = plr or LocalPlayer
    return target and target.Character or nil
end

function Utils:GetHumanoid(plr)
    local char = self:GetCharacter(plr)
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end

function Utils:GetRootPart(plr)
    local char = self:GetCharacter(plr)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart")
end

function Utils:IsAlive(plr)
    local hum = self:GetHumanoid(plr)
    return hum ~= nil and hum.Health > 0
end

function Utils:FreezeRoot(root)
    local r = root or self:GetRootPart(LocalPlayer)
    if r then
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
    end
end

function Utils:SafeTeleport(targetCFrame, offset, smoothDuration)
    local hum = self:GetHumanoid(LocalPlayer)
    local root = self:GetRootPart(LocalPlayer)
    if not root then return false end
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

-- Runs fn now and after every respawn. Returns a connection for your Maid.
function Utils:OnRespawn(fn)
    if LocalPlayer.Character then task.spawn(fn, LocalPlayer.Character) end
    return LocalPlayer.CharacterAdded:Connect(function(char) task.spawn(fn, char) end)
end

function Utils:NearestPlayer(maxDistance)
    local root = self:GetRootPart(LocalPlayer)
    if not root then return nil end
    local best, bestDist = nil, maxDistance or math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local r = self:GetRootPart(p)
            if r then
                local d = (r.Position - root.Position).Magnitude
                if d < bestDist then best, bestDist = p, d end
            end
        end
    end
    return best, bestDist
end

function Utils.Debounce(fn, delay)
    local last = 0
    return function(...)
        local now = os.clock()
        if now - last >= delay then
            last = now
            return fn(...)
        end
    end
end

function Utils.Clamp(v, a, b)
    return math.max(a, math.min(b, v))
end

function Utils.Copy(text)
    local fn = Env.Global.setclipboard or Env.Global.toclipboard
    if type(fn) == "function" then
        return pcall(fn, text)
    end
    return false
end

Nexus.Utils = Utils

-- ============================================================================
-- NET (small helper for your HWID / license backend)
-- ============================================================================
local Net = {}

function Net.Request(opts)
    local g = Env.Global
    local fn = g.request or g.http_request or (g.syn and g.syn.request)
    if type(fn) ~= "function" then return false, "Executor has no request function" end
    local ok, res = pcall(fn, opts)
    if not ok then return false, tostring(res) end
    return true, res
end

-- Returns ok, decodedBody, rawResponse. Retries on network failure only.
function Net.PostJson(url, body, headers, retries)
    local h = { ["Content-Type"] = "application/json" }
    for k, v in pairs(headers or {}) do h[k] = v end
    local payload = HttpService:JSONEncode(body or {})
    local lastErr = "unknown"
    for attempt = 1, (retries or 1) + 1 do
        local ok, res = Net.Request({ Url = url, Method = "POST", Headers = h, Body = payload })
        if ok and res then
            local code = res.StatusCode or 0
            local decoded = nil
            if type(res.Body) == "string" and #res.Body > 0 then
                local okJ, d = pcall(HttpService.JSONDecode, HttpService, res.Body)
                if okJ then decoded = d end
            end
            return code >= 200 and code < 300, decoded, res
        end
        lastErr = tostring(res)
        task.wait(0.4 * attempt)
    end
    return false, nil, lastErr
end

Nexus.Net = Net

-- ============================================================================
-- THEMES (documented Gen2 keys only)
-- ============================================================================
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end

local function buildTheme(accent, accentStroke, glowFrom, glowTo)
    return {
        CornerRoundness = UDim.new(0, 14),
        ElementCornerRadius = UDim.new(0, 10),
        PillCornerRadius = UDim.new(0, 10),
        WindowColor = ColorSequence.new(rgb(19, 20, 28), rgb(13, 14, 20)),
        ShadowColor = rgb(0, 0, 0),
        SurfaceStroke = rgb(44, 46, 64),
        LiveAnimation = true,

        ContentColor = rgb(222, 226, 242),
        TitlingColor = rgb(246, 247, 255),
        ElementTextHoverColor = rgb(255, 255, 255),
        ActionColor = rgb(150, 156, 190),

        TabColor = rgb(172, 178, 208),
        TabBackground = ColorSequence.new(rgb(32, 34, 50), rgb(25, 27, 39)),
        TabStroke = ColorSequence.new(rgb(70, 72, 110), rgb(48, 50, 78)),

        ElementGradient = ColorSequence.new(rgb(28, 30, 43), rgb(22, 24, 34)),
        ElementStroke = rgb(46, 48, 68),
        ElementStrokeHover = accent,
        ElementTransparency = 0,
        ElementStrokeTransparency = 0.15,
        ElementStrokeHoverTransparency = 0.2,
        StatBackground = rgb(24, 26, 37),

        AccentColor = accent,
        AccentStroke = accentStroke,
        AccentGlow = 0.7,
        SliderBackground = rgb(34, 36, 52),
        SliderBackgroundHover = rgb(41, 43, 62),
        SliderProgress = ColorSequence.new(glowFrom, glowTo),
        SliderStroke = rgb(60, 62, 90),
        SliderHandle = rgb(255, 255, 255),
        ToggleTrack = rgb(40, 42, 60),
        ToggleKnobOff = rgb(132, 136, 164),
        DropdownHighlight = rgb(58, 52, 118),

        FieldBackground = rgb(24, 26, 38),
        FieldGlow = accent,
        PlaceholderColor = rgb(110, 114, 142),
        NeutralButton = rgb(36, 38, 54),
        NeutralButtonHover = rgb(46, 48, 68),
        NeutralButtonStroke = rgb(60, 62, 90),
        ErrorColor = rgb(255, 90, 110),
        ErrorStrokeColor = rgb(255, 130, 142),
    }
end

Nexus.Themes = {
    midnight = buildTheme(rgb(124, 92, 255), rgb(152, 128, 255), rgb(88, 101, 242), rgb(142, 92, 255)),
    abyss    = buildTheme(rgb(62, 140, 255), rgb(110, 176, 255), rgb(40, 110, 240), rgb(90, 170, 255)),
}

local THEME_LABELS = { "Nexus Midnight", "Nexus Abyss", "Default", "Cobalt", "Ember", "Amethyst", "Frost", "Rose" }
local THEME_VALUES = { "midnight", "abyss", "default", "cobalt", "ember", "amethyst", "frost", "rose" }

function Nexus:RegisterTheme(name, tbl)
    self.Themes[tostring(name):lower()] = tbl
end

local function resolveTheme(t)
    if type(t) == "string" then
        local key = t:lower():gsub("^nexus%s*", "")
        return Nexus.Themes[key] or Nexus.Themes[t:lower()] or t
    end
    return t
end

-- ============================================================================
-- STRINGS
-- ============================================================================
Nexus.Strings = {
    premium_hint = "Premium",
    premium_title = "Unlock Premium for %s",
    premium_subtitle = "Locked feature",
    premium_body = "This feature is part of Premium. Get it for %s.",
    buy = "Get Premium",
    later = "Later",
    link_copied = "Link copied to clipboard",
    script_error = "Script error",
    premium_on = "Premium active",
    premium_off = "Free version",
    profile_free = "Free \u{00B7} Premium %s",
    profile_premium = "Premium",
}

-- ============================================================================
-- CORE LOADER
-- ============================================================================
local function loadCore(folder, channel)
    local url = (channel == "preview") and "https://sirius.menu/gen2-preview" or "https://sirius.menu/gen2"
    local cache = folder .. "/gen2_core_" .. (channel or "stable") .. ".lua"
    local lib = nil

    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok and type(body) == "string" and #body > 200 then
        local fn = loadstring(body)
        if fn then
            local ok2, res = pcall(fn)
            if ok2 and res then
                lib = res
                if type(writefile) == "function" then pcall(writefile, cache, body) end
            end
        end
    end

    if not lib and type(isfile) == "function" and isfile(cache) then
        local fn = loadstring(readfile(cache))
        if fn then
            local ok2, res = pcall(fn)
            if ok2 then lib = res end
        end
    end
    return lib
end

-- ============================================================================
-- WINDOW
-- ============================================================================
local Win = {}

local function wrapHandle(raw, extras, virtual)
    extras = extras or {}
    virtual = virtual or {}
    local proxy = setmetatable({}, {
        __index = function(_, k)
            local e = extras[k]
            if e ~= nil then return e end
            local vf = virtual[k]
            if vf then return vf() end
            local v = raw[k]
            if type(v) == "function" then
                return function(_, ...) return v(raw, ...) end
            end
            return v
        end,
        __newindex = function(_, k, v) extras[k] = v end,
    })
    extras.__raw = raw
    return proxy
end

function Win:_safe(label, fn, ...)
    local n = select("#", ...)
    local args = { ... }
    local ok = xpcall(function() return fn(unpack(args, 1, n)) end, function(e)
        warn("[Nexus] " .. tostring(label) .. ": " .. tostring(e) .. "\n" .. debug.traceback())
        return e
    end)
    if not ok and self._debugErrors then
        local now = os.clock()
        if now - (self._lastErrAt or -99) > 4 then
            self._lastErrAt = now
            self:Notify({ title = self._S.script_error, content = tostring(label), duration = 4 })
        end
    end
    return ok
end

-- Flags -----------------------------------------------------------------------
function Win:SetFlag(flag, value)
    self._flags[flag] = value
    local l = self._listeners[flag]
    if l then
        for _, fn in ipairs(copyList(l)) do task.spawn(fn, value) end
    end
end

function Win:GetFlag(flag)
    if self._flags[flag] ~= nil then return self._flags[flag] end
    local ok, v = pcall(self._raw.Get, self._raw, flag)
    if ok then return v end
    return nil
end

function Win:OnFlag(flag, fn)
    self._listeners[flag] = self._listeners[flag] or {}
    table.insert(self._listeners[flag], fn)
    return { Disconnect = function()
        local l = self._listeners[flag]
        if l then
            for i, f in ipairs(l) do if f == fn then table.remove(l, i) break end end
        end
    end }
end

-- Lifecycle -------------------------------------------------------------------
function Win:BindConnection(signal, callback, key)
    return self._maid:Add(signal:Connect(callback), key)
end
Win.Connect = Win.BindConnection

function Win:AddTask(item, key) return self._maid:Add(item, key) end
function Win:CleanTask(key) self._maid:CleanKey(key) end

-- Starts a named loop. Replaces any loop with the same key.
function Win:Loop(key, interval, fn)
    local k = "Loop_" .. tostring(key)
    self._maid:CleanKey(k)
    local step = math.max(0.03, interval or 0.1)
    local thread = task.spawn(function()
        while true do
            self:_safe(k, fn, step)
            task.wait(step)
        end
    end)
    self._maid:Add(thread, k)
    return thread
end

function Win:StopLoop(key) self._maid:CleanKey("Loop_" .. tostring(key)) end

function Win:IsAlive() return not self._destroyed end

function Win:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    self.Destroying:Fire()
    self._maid:DoCleaning()
    pcall(function() self._raw:Unload() end)
    if Env.Global.__SIRIUS_NEXUS_ACTIVE == self then
        Env.Global.__SIRIUS_NEXUS_ACTIVE = nil
    end
end
Win.Unload = Win.Destroy

-- Notifications ---------------------------------------------------------------
function Win:Notify(a, b, c, d)
    local props
    if type(a) == "table" then
        props = {
            title = pick(a, "title", "Title"),
            content = pick(a, "content", "Content"),
            duration = pick(a, "duration", "Duration"),
            icon = toIcon(pick(a, "icon", "Icon", "image", "Image")),
        }
    else
        props = { title = a, content = b, duration = c, icon = toIcon(d) }
    end
    local sig = tostring(props.title) .. "|" .. tostring(props.content)
    local now = os.clock()
    if self._lastNote == sig and now - (self._lastNoteAt or 0) < 1.5 then return end
    self._lastNote, self._lastNoteAt = sig, now
    pcall(self._raw.Notify, self._raw, props)
end

function Win:Toast(a, b)
    local props = type(a) == "table" and a or { title = a, subtitle = b }
    pcall(self._raw.Toast, self._raw, props)
end

function Win:Success(title, content) self:Notify("\u{2705} " .. tostring(title), content) end
function Win:Warn(title, content)    self:Notify("\u{26A0} " .. tostring(title), content) end
function Win:Error(title, content)   self:Notify("\u{274C} " .. tostring(title), content) end
function Win:Info(title, content)    self:Notify("\u{2139} " .. tostring(title), content) end

function Win:Confirm(cfg)
    local opts = {
        { text = cfg.CancelText or "Cancel" },
        {
            text = cfg.ConfirmText or "Confirm",
            style = cfg.Danger and "danger" or "primary",
            callback = function()
                if cfg.OnConfirm then self:_safe("Confirm", cfg.OnConfirm) end
            end,
        },
    }
    pcall(self._raw.Popup, self._raw, {
        title = cfg.Title or "Are you sure?",
        content = cfg.Content,
        options = opts,
    })
end

-- Hotkeys ---------------------------------------------------------------------
function Win:Bind(id, key, callback, opts)
    local kc = toKeyCode(key)
    if not kc then return false end
    self._binds[id] = { key = kc, cb = callback, opts = opts or {} }
    return true
end

function Win:Unbind(id) self._binds[id] = nil end

function Win:SetToggleKey(key)
    local kc = toKeyCode(key)
    if kc then self._uiKey = kc end
    return self._uiKey
end

-- Theme -----------------------------------------------------------------------
function Win:ChangeTheme(t)
    return self._raw:ChangeTheme(resolveTheme(t))
end

-- Premium ---------------------------------------------------------------------
function Win:IsPremium() return self._isPremium end

function Win:SetPremiumVerifier(fn) self._verifier = fn end
function Win:SetPremiumLoader(fn) self._loader = fn end

function Win:_refreshLocks()
    for _, item in ipairs(self._lockables) do
        local label = self._isPremium and item.base or (LOCK .. item.base)
        for _, m in ipairs({ "SetName", "SetLabel", "SetTitle", "Rename" }) do
            local f = item.raw[m]
            if type(f) == "function" then
                if pcall(f, item.raw, label) then break end
            end
        end
    end
end

function Win:_updateProfile()
    if self._premium.ManageProfile == false then return end
    local text = self._isPremium and self._S.profile_premium or string.format(self._S.profile_free, self._price)
    pcall(self._raw.SetProfile, self._raw, text)
end

function Win:_applyPremium(valid, info)
    local changed = (self._isPremium ~= (valid == true))
    self._isPremium = valid == true
    self.PremiumInfo = info
    if changed then
        self:_refreshLocks()
        self:_updateProfile()
        self.PremiumChanged:Fire(self._isPremium, info)
        self:Toast(self._isPremium and self._S.premium_on or self._S.premium_off)
    end
end

-- Compatible with the old API. Prefer SetPremiumVerifier.
function Win:SetPremiumStatus(isPremium, onBlocked)
    if onBlocked ~= nil then self._onPremiumBlocked = onBlocked end
    self:_applyPremium(isPremium == true, nil)
    if self._isPremium then task.spawn(function() self:LoadPremiumModule() end) end
end

function Win:VerifyPremium(callback)
    if not self._verifier then return false end
    if self._verifying then return false end
    self._verifying = true
    task.spawn(function()
        local ok, res, info = pcall(self._verifier, self)
        if not ok then warn("[Nexus] Premium verifier error: " .. tostring(res)) end
        local valid = ok and res == true
        self._verifying = false
        self:_applyPremium(valid, info)
        if valid then self:LoadPremiumModule() end
        if callback then self:_safe("VerifyPremium callback", callback, valid, info) end
    end)
    return true
end

-- Runs only after the verifier said yes. The loader should ask YOUR server for
-- the paid code and return a string (Lua source) or a function.
function Win:LoadPremiumModule()
    if not self._isPremium or not self._loader or self._moduleLoaded or self._moduleLoading then return false end
    self._moduleLoading = true
    local ok, payload = pcall(self._loader, { Window = self, Info = self.PremiumInfo, Nexus = Nexus })
    if not ok or payload == nil then
        self._moduleLoading = false
        warn("[Nexus] Premium loader failed: " .. tostring(payload))
        self:Error("Premium", "Could not load premium module")
        return false
    end
    if type(payload) == "string" then
        local fn, err = loadstring(payload)
        if not fn then
            self._moduleLoading = false
            warn("[Nexus] Premium module compile error: " .. tostring(err))
            return false
        end
        payload = fn
    end
    if type(payload) == "function" then
        local ran = self:_safe("PremiumModule", payload, self, { Info = self.PremiumInfo, Nexus = Nexus })
        self._moduleLoaded = ran
    end
    self._moduleLoading = false
    return self._moduleLoaded == true
end

function Win:CopyBuyLink()
    local link = self._premium.Discord
    if link and Utils.Copy(link) then
        self:Toast(self._S.link_copied)
    end
end

function Win:ShowPremiumPopup(featureName)
    local boxes = {}
    for _, f in ipairs(self._premium.Features or {}) do
        if type(f) == "string" then
            boxes[#boxes + 1] = { title = f }
        else
            boxes[#boxes + 1] = {
                title = pick(f, "title", "Title", 1) or "",
                description = pick(f, "description", "Description", 2),
                icon = toIcon(pick(f, "icon", "Icon")),
            }
        end
    end
    local props = {
        title = string.format(self._S.premium_title, self._price),
        subtitle = featureName and (self._S.premium_subtitle .. ": " .. featureName) or nil,
        options = {
            { text = self._S.later },
            { text = self._S.buy, style = "primary", callback = function() self:CopyBuyLink() end },
        },
    }
    if #boxes > 0 then
        props.boxes = boxes
    else
        props.content = string.format(self._S.premium_body, self._price)
    end
    pcall(self._raw.Popup, self._raw, props)
end

function Win:_premiumBlocked(featureName)
    if os.clock() < self._bootUntil then return end -- config autoload must not spam popups
    local now = os.clock()
    if now - (self._lastGate or -99) < 2 then return end
    self._lastGate = now
    if self._onPremiumBlocked then
        task.spawn(self._onPremiumBlocked, featureName)
    else
        self:ShowPremiumPopup(featureName)
    end
end

-- ============================================================================
-- ELEMENT CONTAINER (tab or group)
-- ============================================================================
local idCounter = 0

local function makeContainer(win, rawC)
    local C = {}

    local function isLocked(cfg)
        return cfg.PremiumOnly == true and not win._isPremium
    end

    local function labelFor(cfg, name)
        if isLocked(cfg) then return LOCK .. name end
        return name
    end

    local function descFor(cfg)
        local d = pick(cfg, "Description", "description")
        if d == nil and cfg.PremiumOnly and not win._isPremium then
            return win._S.premium_hint .. " " .. win._price
        end
        return d
    end

    local function blocked(cfg, name)
        if cfg.PremiumOnly and not win._isPremium then
            win:_premiumBlocked(name)
            return true
        end
        return false
    end

    local function register(raw, name, cfg)
        if cfg.PremiumOnly then
            table.insert(win._lockables, { raw = raw, base = name })
        end
    end

    local function flagFor(cfg, name)
        local f = pick(cfg, "Flag", "flag")
        if f then return f end
        return (stripLock(name):gsub("%s+", ""))
    end

    local function noSave(cfg)
        return pick(cfg, "ForgetState", "forgetState", "NoSave") == true
    end

    -- Section / Divider / Paragraph ------------------------------------------
    function C:CreateSection(cfg)
        if type(cfg) == "string" then cfg = { name = cfg } end
        cfg = cfg or {}
        return rawC:CreateSection({ name = pick(cfg, "Name", "name", "Title"), icon = toIcon(pick(cfg, "Icon", "icon")) })
    end

    function C:CreateDivider(cfg)
        if type(rawC.CreateDivider) ~= "function" then return nil end
        if type(cfg) == "string" then cfg = { text = cfg } end
        return rawC:CreateDivider(cfg or {})
    end

    -- Gen2 may have no paragraph element, so fall back to a quiet button.
    function C:CreateParagraph(cfg)
        local title = pick(cfg, "Title", "title", "Name", "name") or ""
        local content = pick(cfg, "Content", "content", "Description", "description") or ""
        if type(rawC.CreateParagraph) == "function" then
            return rawC:CreateParagraph({ title = title, content = content })
        end
        if type(rawC.CreateLabel) == "function" then
            return rawC:CreateLabel({ name = title, description = content })
        end
        return rawC:CreateButton({ name = title, description = content, callback = function() end })
    end

    function C:CreateGroup(cfg)
        return makeContainer(win, rawC:CreateGroup(cfg or {}))
    end

    -- Button -------------------------------------------------------------------
    function C:CreateButton(cfg)
        local name = pick(cfg, "Name", "name") or "Button"
        local cb = pick(cfg, "Callback", "callback")
        local raw = rawC:CreateButton({
            name = labelFor(cfg, name),
            description = descFor(cfg),
            icon = toIcon(pick(cfg, "Icon", "icon")),
            callback = function()
                if blocked(cfg, name) then return end
                if cb then win:_safe(name, cb) end
            end,
        })
        register(raw, name, cfg)
        return wrapHandle(raw)
    end

    -- Toggle -------------------------------------------------------------------
    function C:CreateToggle(cfg)
        local name = pick(cfg, "Name", "name") or "Toggle"
        local flag = flagFor(cfg, name)
        local cb = pick(cfg, "Callback", "callback")
        local onTick = pick(cfg, "OnTick", "onTick")
        local loop = pick(cfg, "Loop", "loop")
        local loopKey = "ToggleLoop_" .. flag
        local initial = pick(cfg, "CurrentValue", "value", "Default") == true
        if isLocked(cfg) then initial = false end
        local raw

        local function syncLoop(state)
            win._maid:CleanKey(loopKey)
            if not state or not onTick then return end
            if loop == nil or loop == "Heartbeat" then
                win._maid:Add(RunService.Heartbeat:Connect(function(dt) win:_safe(name, onTick, dt) end), loopKey)
            elseif loop == "Stepped" then
                win._maid:Add(RunService.Stepped:Connect(function(_, dt) win:_safe(name, onTick, dt) end), loopKey)
            elseif loop == "RenderStepped" then
                win._maid:Add(RunService.RenderStepped:Connect(function(dt) win:_safe(name, onTick, dt) end), loopKey)
            elseif type(loop) == "number" then
                local interval = math.max(0.03, loop)
                local thread = task.spawn(function()
                    while true do
                        win:_safe(name, onTick, interval)
                        task.wait(interval)
                    end
                end)
                win._maid:Add(thread, loopKey)
            end
        end

        raw = rawC:CreateToggle({
            name = labelFor(cfg, name),
            description = descFor(cfg),
            icon = toIcon(pick(cfg, "Icon", "icon")),
            value = initial,
            flag = flag,
            forgetState = noSave(cfg) or nil,
            callback = function(state)
                if blocked(cfg, name) then
                    if state then
                        task.defer(function()
                            if raw then pcall(raw.Set, raw, false, true) end
                        end)
                    end
                    return
                end
                win:SetFlag(flag, state)
                if cb then win:_safe(name, cb, state) end
                syncLoop(state)
            end,
        })
        register(raw, name, cfg)
        win._flags[flag] = initial
        if initial then syncLoop(true) end
        return wrapHandle(raw, {}, {
            CurrentValue = function() return raw.value end,
        })
    end

    -- Slider -------------------------------------------------------------------
    function C:CreateSlider(cfg)
        local name = pick(cfg, "Name", "name") or "Slider"
        local flag = flagFor(cfg, name)
        local range = pick(cfg, "Range", "range") or { 0, 100 }
        local cb = pick(cfg, "Callback", "callback")
        local val = pick(cfg, "CurrentValue", "value", "Default") or range[1]
        local last = val
        local raw
        raw = rawC:CreateSlider({
            name = labelFor(cfg, name),
            description = descFor(cfg),
            icon = toIcon(pick(cfg, "Icon", "icon")),
            range = range,
            increment = pick(cfg, "Increment", "increment") or 1,
            suffix = pick(cfg, "Suffix", "suffix"),
            value = val,
            flag = flag,
            forgetState = noSave(cfg) or nil,
            callback = function(v, dragging)
                if blocked(cfg, name) then
                    if raw then pcall(raw.Set, raw, last, true) end
                    return
                end
                last = v
                win:SetFlag(flag, v)
                if cb then win:_safe(name, cb, v, dragging) end
            end,
        })
        register(raw, name, cfg)
        win._flags[flag] = val
        return wrapHandle(raw, {}, { CurrentValue = function() return raw.value end })
    end

    -- Input --------------------------------------------------------------------
    function C:CreateInput(cfg)
        local name = pick(cfg, "Name", "name") or "Input"
        local flag = flagFor(cfg, name)
        local cb = pick(cfg, "Callback", "callback")
        local clearAfter = pick(cfg, "RemoveTextAfterFocusLost") == true
        local raw
        raw = rawC:CreateInput({
            name = labelFor(cfg, name),
            description = descFor(cfg),
            icon = toIcon(pick(cfg, "Icon", "icon")),
            value = pick(cfg, "CurrentValue", "value") or "",
            placeholder = pick(cfg, "PlaceholderText", "Placeholder", "placeholder") or "",
            numeric = pick(cfg, "Numeric", "numeric"),
            flag = flag,
            forgetState = noSave(cfg) or nil,
            callback = function(text)
                if blocked(cfg, name) then
                    if raw then pcall(raw.Set, raw, "", true) end
                    return
                end
                win:SetFlag(flag, text)
                if cb then win:_safe(name, cb, text) end
                if clearAfter and raw then task.defer(function() pcall(raw.Set, raw, "", true) end) end
            end,
        })
        register(raw, name, cfg)
        return wrapHandle(raw, {}, { CurrentValue = function() return raw.value end })
    end

    -- Keybind ------------------------------------------------------------------
    function C:CreateKeybind(cfg)
        local name = pick(cfg, "Name", "name") or "Keybind"
        local flag = flagFor(cfg, name)
        local cb = pick(cfg, "Callback", "callback")
        local raw = rawC:CreateKeybind({
            name = labelFor(cfg, name),
            description = descFor(cfg),
            value = toKeyCode(pick(cfg, "CurrentKeybind", "value", "Default")),
            hold = pick(cfg, "HoldToInteract", "hold"),
            flag = flag,
            forgetState = noSave(cfg) or nil,
            callback = function(v)
                if blocked(cfg, name) then return end
                if cb then win:_safe(name, cb, v) end
            end,
        })
        register(raw, name, cfg)
        return wrapHandle(raw, {}, { CurrentKeybind = function() return raw.value end })
    end

    -- Color picker -------------------------------------------------------------
    function C:CreateColorPicker(cfg)
        local name = pick(cfg, "Name", "name") or "Color"
        local flag = flagFor(cfg, name)
        local cb = pick(cfg, "Callback", "callback")
        local initial = pick(cfg, "Color", "color", "CurrentValue", "value") or Color3.fromRGB(255, 255, 255)
        local last = initial
        local raw
        raw = rawC:CreateColorPicker({
            name = labelFor(cfg, name),
            description = descFor(cfg),
            color = initial,
            alpha = pick(cfg, "Alpha", "alpha"),
            flag = flag,
            forgetState = noSave(cfg) or nil,
            callback = function(color, alpha)
                if blocked(cfg, name) then
                    if raw then pcall(raw.Set, raw, last, true) end
                    return
                end
                last = color
                win:SetFlag(flag, color)
                if cb then win:_safe(name, cb, color, alpha) end
            end,
        })
        register(raw, name, cfg)
        return wrapHandle(raw)
    end

    -- Dropdown -----------------------------------------------------------------
    local function buildDropdown(cfg)
        local name = pick(cfg, "Name", "name") or "Dropdown"
        local flag = pick(cfg, "Flag", "flag")
        local multi = pick(cfg, "MultipleOptions", "MultiSelect", "multiSelect") == true
        local legacy = (cfg.Compat ~= false) and win._compat
        local cb = pick(cfg, "Callback", "callback")
        local source = copyList(pick(cfg, "Options", "options"))
        local raw

        local function norm(v)
            if v == nil or v == "" then return {} end
            if type(v) == "string" then return { v } end
            if type(v) == "table" then return copyList(v) end
            return {}
        end
        local function toRaw(arr)
            if multi then return arr end
            return arr[1]
        end

        local initial = norm(pick(cfg, "CurrentOption", "value"))
        if not multi and #initial > 1 then initial = { initial[1] } end
        if isLocked(cfg) then initial = {} end
        local last = initial

        local function setRaw(arr)
            if not raw then return end
            local v = toRaw(arr)
            if v == nil then v = multi and {} or "" end
            pcall(raw.Set, raw, v, true)
        end

        local function inList(list, item)
            for _, x in ipairs(list) do if x == item then return true end end
            return false
        end

        raw = rawC:CreateDropdown({
            name = labelFor(cfg, name),
            description = descFor(cfg),
            icon = toIcon(pick(cfg, "Icon", "icon")),
            options = source,
            value = toRaw(initial),
            multiSelect = multi,
            placeholder = pick(cfg, "Placeholder", "placeholder"),
            flag = flag,
            forgetState = noSave(cfg) or nil,
            callback = function(v)
                local arr = norm(v)
                if blocked(cfg, name) then
                    task.defer(function() setRaw(last) end)
                    return
                end
                last = arr
                local out = (legacy or multi) and arr or v
                if flag then win:SetFlag(flag, out) end
                if cb then win:_safe(name, cb, out) end
            end,
        })
        register(raw, name, cfg)

        local extras = {}

        function extras:Set(v, skip)
            local arr = norm(v)
            if not multi and #arr > 1 then arr = { arr[1] } end
            last = arr
            local rv = toRaw(arr)
            if rv == nil then rv = multi and {} or "" end
            return raw:Set(rv, skip)
        end

        function extras:GetSelected() return norm(raw.value) end

        -- Replaces the option list and keeps the selection that still exists.
        function extras:Refresh(list)
            source = copyList(list)
            local keep = {}
            for _, x in ipairs(norm(raw.value)) do
                if inList(source, x) then keep[#keep + 1] = x end
            end
            raw:Refresh(copyList(source))
            setRaw(keep)
            last = keep
        end
        extras.SetOptions = extras.Refresh

        -- Shows only options that contain the text. Selected ones stay visible.
        function extras:Filter(text)
            text = tostring(text or ""):lower()
            local selected = norm(raw.value)
            local out = {}
            for _, o in ipairs(source) do
                if text == "" or tostring(o):lower():find(text, 1, true) or inList(selected, o) then
                    out[#out + 1] = o
                end
            end
            raw:Refresh(out)
            setRaw(selected)
        end

        function extras:GetOptions() return copyList(source) end

        local handle = wrapHandle(raw, extras, {
            CurrentOption = function() return norm(raw.value) end,
            CurrentValue = function() return raw.value end,
        })
        return handle, extras, norm, setRaw
    end

    function C:CreateDropdown(cfg)
        local handle = buildDropdown(cfg)
        return handle
    end

    -- Search input that filters one or more dropdowns --------------------------
    function C:CreateSearchInput(cfg)
        cfg = cfg or {}
        local targets = cfg.Targets or {}
        if cfg.Target then targets = { cfg.Target } end
        local pending = 0
        return C:CreateInput({
            Name = cfg.Name or "Search",
            PlaceholderText = cfg.PlaceholderText or cfg.Placeholder or "Type to filter...",
            ForgetState = true,
            PremiumOnly = cfg.PremiumOnly,
            Callback = function(text)
                pending = pending + 1
                local mine = pending
                task.delay(0.18, function()
                    if mine ~= pending then return end
                    for _, dd in ipairs(targets) do
                        pcall(dd.Filter, dd, text)
                    end
                    if cfg.Callback then win:_safe("SearchInput", cfg.Callback, text) end
                end)
            end,
        })
    end

    -- Player selector that keeps itself up to date ----------------------------
    function C:CreatePlayerDropdown(cfg)
        cfg = cfg or {}
        idCounter = idCounter + 1
        local id = "PlayerDD_" .. idCounter
        local includeLocal = cfg.IncludeLocal == true
        local useDisplay = cfg.DisplayNames == true
        local filter = cfg.Filter
        local userCb = pick(cfg, "Callback", "callback")
        local map = {}

        local function build()
            map = {}
            local list = {}
            local plrs = Players:GetPlayers()
            table.sort(plrs, function(a, b) return a.Name:lower() < b.Name:lower() end)
            for _, p in ipairs(plrs) do
                if (includeLocal or p ~= LocalPlayer) and (not filter or filter(p)) then
                    local label = useDisplay and string.format("%s (@%s)", p.DisplayName, p.Name) or p.Name
                    map[label] = p
                    list[#list + 1] = label
                end
            end
            return list
        end

        local function playersFrom(labels)
            local out = {}
            for _, l in ipairs(labels) do
                local p = map[l]
                if p and p.Parent then out[#out + 1] = p end
            end
            return out
        end

        local sub = {}
        for k, v in pairs(cfg) do sub[k] = v end
        sub.Options = build()
        sub.Callback = function(sel)
            local labels = type(sel) == "table" and sel or { sel }
            if userCb then userCb(labels, playersFrom(labels)) end
        end
        sub.Compat = true

        local handle, extras = buildDropdown(sub)

        local function refresh()
            local before = handle:GetSelected()
            local list = build()
            handle:Refresh(list)
            local after = handle:GetSelected()
            if #before ~= #after and userCb then
                win:_safe("PlayerDropdown", userCb, after, playersFrom(after))
            end
        end

        local pending = false
        local function queue()
            if pending then return end
            pending = true
            task.delay(0.3, function()
                pending = false
                if not win._destroyed then refresh() end
            end)
        end

        win._maid:Add(Players.PlayerAdded:Connect(queue), id .. "_add")
        win._maid:Add(Players.PlayerRemoving:Connect(queue), id .. "_rem")

        function extras:GetPlayers() return playersFrom(handle:GetSelected()) end
        function extras:RefreshPlayers() refresh() end
        function extras:Destroy()
            win._maid:CleanKey(id .. "_add")
            win._maid:CleanKey(id .. "_rem")
        end
        return handle
    end

    -- Premium showcase block ---------------------------------------------------
    function C:CreatePremiumShowcase(cfg)
        cfg = cfg or {}
        C:CreateSection(cfg.Title or ("\u{1F48E} Premium " .. win._price))
        C:CreateButton({
            Name = cfg.InfoText or "What is included",
            Description = cfg.InfoDescription or "See every Premium feature",
            Callback = function() win:ShowPremiumPopup() end,
        })
        C:CreateButton({
            Name = cfg.BuyText or ("Get Premium for " .. win._price),
            Callback = function()
                win:CopyBuyLink()
                win:ShowPremiumPopup()
            end,
        })
    end

    -- Everything else (CreateStat, CreateProgress, Select, Remove...) goes to Gen2
    return setmetatable(C, {
        __index = function(_, k)
            local v = rawC[k]
            if type(v) == "function" then
                return function(_, ...) return v(rawC, ...) end
            end
            return v
        end,
    })
end

-- ============================================================================
-- WINDOW BUILDERS
-- ============================================================================
function Win:CreateTab(a, b)
    local props
    if type(a) == "table" then
        props = { name = pick(a, "name", "Name"), icon = toIcon(pick(a, "icon", "Icon")) }
    else
        props = { name = a, icon = toIcon(b) }
    end
    props.name = props.name or "Tab"
    local rawTab = self._raw:CreateTab(props)
    local tab = makeContainer(self, rawTab)
    self.Tabs[props.name] = tab
    return tab
end

function Win:CreateSection(a)
    if type(a) == "string" then a = { name = a } end
    if type(self._raw.CreateSection) == "function" then
        return self._raw:CreateSection(a or {})
    end
end

function Win:_configs()
    local ok, list = pcall(self._raw.ListConfigs, self._raw)
    if ok and type(list) == "table" then return list end
    return {}
end

function Win:CreateSettingsTab(opts)
    opts = opts or {}
    local tab = self:CreateTab(opts.Name or "Settings", opts.Icon)

    tab:CreateSection("Appearance")
    tab:CreateDropdown({
        Name = "Theme",
        Flag = "Nexus_Theme",
        Options = THEME_LABELS,
        CurrentOption = { THEME_LABELS[1] },
        Callback = function(sel)
            local label = sel[1]
            for i, l in ipairs(THEME_LABELS) do
                if l == label then self:ChangeTheme(THEME_VALUES[i]) break end
            end
        end,
    })

    local keyNames = { "RightShift", "RightControl", "LeftAlt", "Insert", "Delete", "K", "F6" }
    tab:CreateDropdown({
        Name = "Menu key",
        Flag = "Nexus_MenuKey",
        Options = keyNames,
        CurrentOption = { "RightShift" },
        Callback = function(sel)
            if sel[1] then self:SetToggleKey(sel[1]) end
        end,
    })

    if opts.Languages then
        local names, codeByName = {}, {}
        for _, l in ipairs(opts.Languages) do
            names[#names + 1] = l.name
            codeByName[l.name] = l.code
        end
        tab:CreateDropdown({
            Name = opts.LanguageLabel or "Language",
            Flag = "Nexus_Language",
            Options = names,
            CurrentOption = opts.CurrentLanguage and { opts.CurrentLanguage } or {},
            Callback = function(sel)
                local code = sel[1] and codeByName[sel[1]]
                if not code then return end
                pcall(self._raw.SetLocale, self._raw, code)
                if opts.OnLanguage then opts.OnLanguage(code) end
            end,
        })
    end

    tab:CreateSection("Profiles")
    local cfgName, picked = "", nil
    tab:CreateInput({
        Name = "Profile name",
        PlaceholderText = "my-profile",
        ForgetState = true,
        Callback = function(t) cfgName = t end,
    })
    local list = tab:CreateDropdown({
        Name = "Saved profiles",
        Options = self:_configs(),
        ForgetState = true,
        Callback = function(sel) picked = sel[1] end,
    })
    tab:CreateButton({
        Name = "Save profile",
        Callback = function()
            local n = (cfgName ~= "" and cfgName) or picked
            if not n then self:Warn("Profiles", "Type a name first") return end
            local ok = pcall(self._raw.Save, self._raw, n)
            if ok then self:Success("Profiles", "Saved " .. n) else self:Error("Profiles", "Save failed") end
            list:Refresh(self:_configs())
        end,
    })
    tab:CreateButton({
        Name = "Load profile",
        Callback = function()
            local n = picked or (cfgName ~= "" and cfgName)
            if not n then self:Warn("Profiles", "Pick a profile first") return end
            local ok = pcall(self._raw.Load, self._raw, n)
            if ok then self:Success("Profiles", "Loaded " .. n) else self:Error("Profiles", "Load failed") end
        end,
    })
    tab:CreateButton({
        Name = "Delete profile",
        Callback = function()
            local n = picked
            if not n then self:Warn("Profiles", "Pick a profile first") return end
            self:Confirm({
                Title = "Delete profile?",
                Content = "This removes " .. n .. " for good.",
                ConfirmText = "Delete",
                Danger = true,
                OnConfirm = function()
                    pcall(self._raw.DeleteConfig, self._raw, n)
                    list:Refresh(self:_configs())
                end,
            })
        end,
    })

    tab:CreateSection("Window")
    tab:CreateButton({
        Name = "Unload script",
        Callback = function()
            self:Confirm({
                Title = "Unload?",
                Content = "Everything stops and the UI closes.",
                ConfirmText = "Unload",
                Danger = true,
                OnConfirm = function() self:Destroy() end,
            })
        end,
    })
    return tab
end

-- ============================================================================
-- CREATE WINDOW
-- ============================================================================
function Nexus:CreateWindow(config)
    config = config or {}

    local old = Env.Global.__SIRIUS_NEXUS_ACTIVE
    if old then pcall(function() old:Destroy() end) end

    local name = pick(config, "Name", "name") or "Nexus"
    local cs = config.ConfigurationSaving
    local folder = (cs and cs.FolderName) or config.Folder or "SiriusNexus"
    if type(isfolder) == "function" and type(makefolder) == "function" then
        pcall(function() if not isfolder(folder) then makefolder(folder) end end)
    end

    local core = loadCore(folder, config.Channel)
    assert(core, "[SiriusNexus] Could not load Rayfield Gen2. Check your connection.")

    local save = pick(config, "Configuration", "configuration")
    if not save then
        if cs then
            if cs.Enabled ~= false then
                save = { autoSave = true, autoLoad = true, fileName = cs.FileName or name, customFolder = cs.FolderName }
            end
        else
            save = { autoSave = true, autoLoad = true, fileName = name }
        end
    end

    local props = {
        name = name,
        subtitle = pick(config, "Subtitle", "subtitle", "LoadingSubtitle"),
        theme = resolveTheme(pick(config, "Theme", "theme") or "midnight"),
        icon = toIcon(pick(config, "Icon", "icon")),
        sidebarLayout = config.SidebarLayout ~= false,
        profile = pick(config, "Profile", "profile"),
        showName = pick(config, "ShowName", "showName", "ShowText"),
        showIcon = toIcon(pick(config, "ShowIcon", "showIcon")),
        showIconOnly = pick(config, "ShowIconOnly", "showIconOnly"),
        configuration = save,
        locale = pick(config, "Locale", "locale"),
        translations = pick(config, "Translations", "translations"),
        translator = pick(config, "Translator", "translator"),
        fallbackFont = pick(config, "FallbackFont", "fallbackFont"),
    }

    local raw = core:CreateWindow(props)
    assert(raw, "[SiriusNexus] Gen2 CreateWindow returned nothing.")

    local premium = config.Premium or {}
    local strings = {}
    for k, v in pairs(Nexus.Strings) do strings[k] = v end
    for k, v in pairs(config.Strings or {}) do strings[k] = v end

    local win = {
        _core = core,
        _raw = raw,
        _maid = Maid.new(),
        _flags = {},
        _listeners = {},
        _binds = {},
        _lockables = {},
        _isPremium = false,
        _premium = premium,
        _price = premium.Price or Nexus.Price,
        _S = strings,
        _compat = config.Compat ~= false,
        _debugErrors = config.DebugErrors ~= false,
        _bootUntil = os.clock() + 3,
        _uiKey = toKeyCode(pick(config, "ToggleUIKey", "ToggleKey")) or Enum.KeyCode.RightShift,
        Tabs = {},
        Utils = Utils,
        Net = Net,
        Nexus = Nexus,
        PremiumChanged = Signal.new(),
        Destroying = Signal.new(),
    }
    setmetatable(win, {
        __index = function(t, k)
            local m = Win[k]
            if m ~= nil then return m end
            local v = raw[k]
            if type(v) == "function" then
                return function(_, ...) return v(raw, ...) end
            end
            return v
        end,
    })

    -- global hotkeys
    if UserInputService then
        win._maid:Add(UserInputService.InputBegan:Connect(function(input, processed)
            if win._destroyed then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            local typing = UserInputService:GetFocusedTextBox() ~= nil
            if typing then return end
            if input.KeyCode == win._uiKey and not processed then
                pcall(raw.ToggleHide, raw)
                return
            end
            for id, b in pairs(win._binds) do
                if b.key == input.KeyCode and (b.opts.AllowProcessed or not processed) then
                    win:_safe("Bind " .. tostring(id), b.cb)
                end
            end
        end), "Hotkeys")
    end

    if premium.Verify then win._verifier = premium.Verify end
    if premium.LoadModule then win._loader = premium.LoadModule end
    win:_updateProfile()

    Env.Global.__SIRIUS_NEXUS_ACTIVE = win
    return win
end

Nexus.Win = Win
return Nexus
