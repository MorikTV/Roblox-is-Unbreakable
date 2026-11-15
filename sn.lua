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

-- Lucide icons as single images (same asset ids Rayfield Gen1 used). Gen2 only
-- takes asset ids, so names are converted here.
local ICON_IDS = {
    ["CD"]=7734110220,["activity"]=7733655755,["airplay"]=7733655834,["alarm-check"]=7733655912,
    ["alarm-clock"]=7733656100,["alarm-clock-off"]=7733656003,["alarm-minus"]=7733656164,
    ["alarm-plus"]=7733658066,["album"]=7733658133,["alert-circle"]=7733658271,["alert-octagon"]=7733658335,
    ["alert-triangle"]=7733658504,["align-center"]=7733909776,["align-center-horizontal"]=8997380477,
    ["align-center-vertical"]=8997380737,["align-end-horizontal"]=8997380820,["align-end-vertical"]=8997380907,
    ["align-horizonal-distribute-center"]=8997381028,["align-horizonal-distribute-end"]=8997381144,
    ["align-horizonal-distribute-start"]=8997381290,["align-horizontal-justify-center"]=8997381461,
    ["align-horizontal-justify-end"]=8997381549,["align-horizontal-justify-start"]=8997381652,
    ["align-horizontal-space-around"]=8997381738,["align-horizontal-space-between"]=8997381854,
    ["align-justify"]=7733661326,["align-left"]=7733911357,["align-right"]=7733663582,
    ["align-start-horizontal"]=8997381965,["align-start-vertical"]=8997382085,
    ["align-vertical-distribute-center"]=8997382212,["align-vertical-distribute-end"]=8997382326,
    ["align-vertical-distribute-start"]=8997382428,["align-vertical-justify-center"]=8997382502,
    ["align-vertical-justify-end"]=8997382584,["align-vertical-justify-start"]=8997382639,
    ["align-vertical-space-around"]=8997382708,["align-vertical-space-between"]=8997382793,["anchor"]=7733911490,
    ["aperture"]=7733666258,["archive"]=7733911621,["arrow-big-down"]=7733668653,["arrow-big-left"]=7733911731,
    ["arrow-big-right"]=7733671493,["arrow-big-up"]=7733671663,["arrow-down"]=7733672933,
    ["arrow-down-circle"]=7733671763,["arrow-down-left"]=7733672282,["arrow-down-right"]=7733672831,
    ["arrow-left"]=7733673136,["arrow-left-circle"]=7733673056,["arrow-left-right"]=8997382869,
    ["arrow-right"]=7733673345,["arrow-right-circle"]=7733673229,["arrow-up"]=7733673717,
    ["arrow-up-circle"]=7733673466,["arrow-up-left"]=7733673539,["arrow-up-right"]=7733673646,
    ["asterisk"]=7733673800,["at-sign"]=7733673907,["award"]=7733673987,["axe"]=7733674079,
    ["banknote"]=7733674153,["bar-chart"]=7733674319,["bar-chart-2"]=7733674239,["battery"]=7733674820,
    ["battery-charging"]=7733674402,["battery-full"]=7733674503,["battery-low"]=7733674589,
    ["battery-medium"]=7733674731,["beaker"]=7733674922,["bell"]=7733911828,["bell-minus"]=7733675028,
    ["bell-off"]=7733675107,["bell-plus"]=7733675181,["bell-ring"]=7733675275,["bike"]=7733678330,
    ["binary"]=7733678388,["bluetooth"]=7733687147,["bluetooth-connected"]=7734110952,
    ["bluetooth-off"]=7733914252,["bluetooth-searching"]=7733914320,["bold"]=7733687211,["book"]=7733914390,
    ["book-open"]=7733687281,["bookmark"]=7733692043,["bookmark-minus"]=7733689754,["bookmark-plus"]=7734111084,
    ["bot"]=7733916988,["box"]=7733917120,["box-select"]=7733696665,["briefcase"]=7733919017,["brush"]=7733701455,
    ["bug"]=7733701545,["building"]=7733701625,["bus"]=7733701715,["calculator"]=7733919105,
    ["calendar"]=7733919198,["camera"]=7733708692,["camera-off"]=7733919260,["car"]=7733708835,
    ["carrot"]=8997382987,["cast"]=7733919326,["charge"]=8997383136,["check"]=7733715400,
    ["check-circle"]=7733919427,["check-circle-2"]=7733710700,["check-square"]=7733919526,
    ["chevron-down"]=7733717447,["chevron-first"]=8997383275,["chevron-last"]=8997383390,
    ["chevron-left"]=7733717651,["chevron-right"]=7733717755,["chevron-up"]=7733919605,
    ["chevrons-down"]=7733720604,["chevrons-down-up"]=7733720483,["chevrons-left"]=7733720701,
    ["chevrons-right"]=7733919682,["chevrons-up"]=7733723433,["chevrons-up-down"]=7733723321,
    ["chrome"]=7733919783,["circle"]=7733919881,["circle-slashed"]=8997383530,["clipboard"]=7733734762,
    ["clipboard-check"]=7733919947,["clipboard-copy"]=7733920037,["clipboard-list"]=7733920117,
    ["clipboard-x"]=7733734668,["clock"]=7733734848,["clock-1"]=8997383694,["clock-10"]=8997383876,
    ["clock-11"]=8997384034,["clock-12"]=8997384150,["clock-2"]=8997384295,["clock-3"]=8997384456,
    ["clock-4"]=8997384603,["clock-5"]=8997384798,["clock-6"]=8997384977,["clock-7"]=8997385147,
    ["clock-8"]=8997385352,["clock-9"]=8997385485,["cloud"]=7733746980,["cloud-drizzle"]=7733920226,
    ["cloud-fog"]=7733920317,["cloud-hail"]=7733920444,["cloud-lightning"]=7733741741,["cloud-moon"]=7733920519,
    ["cloud-off"]=7733745572,["cloud-rain"]=7733746651,["cloud-rain-wind"]=7733746456,["cloud-snow"]=7733746798,
    ["cloud-sun"]=7733746880,["cloudy"]=7733747106,["clover"]=7733747233,["code"]=7733749837,
    ["code-2"]=7733920644,["codepen"]=7733920768,["codesandbox"]=7733752575,["coffee"]=7733752630,
    ["coins"]=7743866529,["columns"]=7733757178,["command"]=7733924046,["compass"]=7733924216,
    ["contact"]=7743866666,["contrast"]=7733764005,["cookie"]=8997385628,["copy"]=7733764083,
    ["copyleft"]=7733764196,["copyright"]=7733764275,["corner-down-left"]=7733764327,
    ["corner-down-right"]=7733764385,["corner-left-down"]=7733764448,["corner-left-up"]=7733764536,
    ["corner-right-down"]=7733764605,["corner-right-up"]=7733764680,["corner-up-left"]=7733764800,
    ["corner-up-right"]=7733764915,["cpu"]=7733765045,["crop"]=7733765140,["cross"]=7733765224,
    ["crosshair"]=7733765307,["crown"]=7733765398,["currency"]=7733765592,["database"]=7743866778,
    ["delete"]=7733768142,["divide"]=7733769365,["divide-circle"]=7733769152,["divide-square"]=7733769261,
    ["dollar-sign"]=7733770599,["download"]=7733770755,["download-cloud"]=7733770689,["dribbble"]=7733770843,
    ["droplet"]=7733770982,["droplets"]=7733771078,["drumstick"]=8997385789,["edit"]=7733771472,
    ["edit-2"]=7733771217,["edit-3"]=7733771361,["egg"]=8997385940,["electricity"]=7733771628,
    ["electricity-off"]=7733771563,["equal"]=7733771811,["equal-not"]=7733771726,["euro"]=7733771891,
    ["expand"]=7733771982,["external-link"]=7743866903,["eye"]=7733774602,["eye-off"]=7733774495,
    ["fast-forward"]=7743867090,["feather"]=7733777166,["figma"]=7743867310,["file"]=7733793319,
    ["file-check"]=7733779668,["file-check-2"]=7733779610,["file-code"]=7733779730,["file-digit"]=7733935829,
    ["file-input"]=7733935917,["file-minus"]=7733936115,["file-minus-2"]=7733936010,["file-output"]=7733788742,
    ["file-plus"]=7733788885,["file-plus-2"]=7733788816,["file-search"]=7733788966,["file-text"]=7733789088,
    ["file-x"]=7733938136,["file-x-2"]=7743867554,["files"]=7743867811,["film"]=7733942579,["filter"]=7733798407,
    ["flag"]=7733798691,["flag-triangle-left"]=7733798509,["flag-triangle-right"]=7733798634,["flame"]=7733798747,
    ["flashlight"]=7733798851,["flashlight-off"]=7733798799,["flask-conical"]=7733798901,
    ["flask-round"]=7733798957,["folder"]=7733799185,["folder-minus"]=7733799022,["folder-open"]=8997386062,
    ["folder-plus"]=7733799092,["form-input"]=7733799275,["forward"]=7733799371,["framer"]=7733799486,
    ["frown"]=7733799591,["function-square"]=7733799682,["gamepad"]=7733799901,["gamepad-2"]=7733799795,
    ["gauge"]=7733799969,["gavel"]=7733800044,["gem"]=7733942651,["ghost"]=7743868000,["gift"]=7733946818,
    ["gift-card"]=7733945018,["git-branch"]=7733949149,["git-branch-plus"]=7743868200,["git-commit"]=7743868360,
    ["git-merge"]=7733952195,["git-pull-request"]=7733952287,["github"]=7733954058,["gitlab"]=7733954246,
    ["glasses"]=7733954403,["globe"]=7733954760,["globe-2"]=7733954611,["grab"]=7733954884,
    ["graduation-cap"]=7733955058,["grid"]=7733955179,["grip-horizontal"]=7733955302,["grip-vertical"]=7733955410,
    ["hammer"]=7733955511,["hand"]=7733955740,["hand-metal"]=7733955664,["hard-drive"]=7733955793,
    ["hard-hat"]=7733955850,["hash"]=7733955906,["haze"]=7733955969,["headphones"]=7733956063,
    ["heart"]=7733956134,["help-circle"]=7733956210,["hexagon"]=7743868527,["highlighter"]=7743868648,
    ["history"]=7733960880,["home"]=7733960981,["image"]=7733964126,["image-minus"]=7733963797,
    ["image-off"]=7733963907,["image-plus"]=7733964016,["import"]=7733964240,["inbox"]=7733964370,
    ["indent"]=7733964452,["indian-rupee"]=7733964536,["infinity"]=7733964640,["info"]=7733964719,
    ["inspect"]=7733964808,["italic"]=7733964917,["jersey-pound"]=7733965029,["key"]=7733965118,
    ["landmark"]=7733965184,["languages"]=7733965249,["laptop"]=7733965386,["laptop-2"]=7733965313,
    ["lasso"]=7733967892,["lasso-select"]=7743868832,["layers"]=7743868936,["layout"]=7733970543,
    ["layout-dashboard"]=7733970318,["layout-grid"]=7733970390,["layout-list"]=7733970442,
    ["layout-template"]=7733970494,["library"]=7743869054,["life-buoy"]=7733973479,["lightbulb"]=7733975185,
    ["lightbulb-off"]=7733975123,["link"]=7733978098,["link-2"]=7743869163,["link-2-off"]=7733975283,
    ["list"]=7743869612,["list-checks"]=7743869317,["list-minus"]=7733980795,["list-ordered"]=7743869411,
    ["list-plus"]=7733984995,["list-x"]=7743869517,["loader"]=7733992358,["loader-2"]=7733989869,
    ["locate"]=7733992469,["locate-fixed"]=7733992424,["lock"]=7733992528,["log-in"]=7733992604,
    ["log-out"]=7733992677,["mail"]=7733992732,["map"]=7733992829,["map-pin"]=7733992789,["maximize"]=7733992982,
    ["maximize-2"]=7733992901,["megaphone"]=7733993049,["meh"]=7733993147,["menu"]=7733993211,
    ["message-circle"]=7733993311,["message-square"]=7733993369,["mic"]=7743869805,["mic-off"]=7743869714,
    ["minimize"]=7733997941,["minimize-2"]=7733997870,["minus"]=7734000129,["minus-circle"]=7733998053,
    ["minus-square"]=7743869899,["monitor"]=7734002839,["monitor-off"]=7734000184,["monitor-speaker"]=7743869988,
    ["moon"]=7743870134,["more-horizontal"]=7734006080,["more-vertical"]=7734006187,["mountain"]=7734008868,
    ["mountain-snow"]=7743870286,["mouse-pointer"]=7743870392,["mouse-pointer-2"]=7734010405,
    ["mouse-pointer-click"]=7734010488,["move"]=7743870731,["move-diagonal"]=7743870505,
    ["move-diagonal-2"]=7734013178,["move-horizontal"]=7734016210,["move-vertical"]=7743870608,
    ["music"]=7734020554,["navigation"]=7734020989,["navigation-2"]=7734020942,["network"]=7734021047,
    ["no_entry"]=7734021118,["octagon"]=7734021165,["on-charge"]=7734021231,["option"]=7734021300,
    ["outdent"]=7734021384,["package"]=7734021469,["package-check"]=8997386143,["package-minus"]=8997386266,
    ["package-plus"]=8997386355,["package-search"]=8997386448,["package-x"]=8997386545,["palette"]=7734021595,
    ["paperclip"]=7734021680,["pause"]=7734021897,["pause-circle"]=7734021767,["pause-octagon"]=7734021827,
    ["pen-tool"]=7734022041,["pencil"]=7734022107,["percent"]=7743870852,["person-standing"]=7743871002,
    ["phone"]=7734032056,["phone-call"]=7734027264,["phone-forwarded"]=7734027345,["phone-incoming"]=7743871120,
    ["phone-missed"]=7734029465,["phone-off"]=7734029534,["phone-outgoing"]=7743871253,["pie-chart"]=7734034378,
    ["piggy-bank"]=7734034513,["pin"]=8997386648,["pipette"]=7743871384,["plane"]=7734037723,["play"]=7743871480,
    ["play-circle"]=7734037784,["plus"]=7734042071,["plus-circle"]=7734040271,["plus-square"]=7734040369,
    ["pocket"]=7734042139,["podcast"]=7734042234,["pointer"]=7734042307,["pound-sterling"]=7734042354,
    ["power"]=7734042493,["power-off"]=7734042423,["printer"]=7734042580,["qr-code"]=7743871575,
    ["quote"]=7734045100,["radio"]=7743871662,["radio-receiver"]=7734045155,["redo"]=7743871739,
    ["refresh-ccw"]=7734050715,["refresh-cw"]=7734051052,["regex"]=7734051188,["repeat"]=7734051454,
    ["repeat-1"]=7734051342,["reply"]=7734051594,["reply-all"]=7734051524,["rewind"]=7734051670,
    ["rocking-chair"]=7734051769,["rotate-ccw"]=7734051861,["rotate-cw"]=7734051957,["rss"]=7734052075,
    ["ruler"]=7734052157,["russian-ruble"]=7734052248,["save"]=7734052335,["scale"]=7734052454,
    ["scan"]=8997386861,["scan-line"]=8997386772,["scissors"]=7734052570,["screen-share"]=7734052814,
    ["screen-share-off"]=7734052653,["search"]=7734052925,["send"]=7734053039,["separator-horizontal"]=7734053146,
    ["separator-vertical"]=7734053213,["server"]=7734053426,["server-crash"]=7734053281,["server-off"]=7734053361,
    ["settings"]=7734053495,["settings-2"]=8997386997,["share"]=7734053697,["share-2"]=7734053595,
    ["sheet"]=7743871876,["shield"]=7734056608,["shield-alert"]=7734056326,["shield-check"]=7734056411,
    ["shield-close"]=7734056470,["shield-off"]=7734056540,["shirt"]=7734056672,["shopping-bag"]=7734056747,
    ["shopping-cart"]=7734056813,["shovel"]=7734056878,["shrink"]=7734056971,["shuffle"]=7734057059,
    ["sidebar"]=7734058260,["sidebar-close"]=7734058092,["sidebar-open"]=7734058165,["sigma"]=7734058345,
    ["signal"]=8997387546,["signal-high"]=8997387110,["signal-low"]=8997387189,["signal-medium"]=8997387319,
    ["signal-zero"]=8997387434,["skip-back"]=7734058404,["skip-forward"]=7734058495,["skull"]=7734058599,
    ["slash"]=8997387644,["sliders"]=7734058803,["smartphone"]=7734058979,["smartphone-charging"]=7734058894,
    ["smile"]=7734059095,["snowflake"]=7734059180,["sort-asc"]=7734060715,["sort-desc"]=7743871973,
    ["speaker"]=7734063416,["sprout"]=7743872071,["square"]=7743872181,["star"]=7734068321,
    ["star-half"]=7734068258,["stop-circle"]=7734068379,["stretch-horizontal"]=8997387754,
    ["stretch-vertical"]=8997387862,["strikethrough"]=7734068425,["subscript"]=8997387937,["sun"]=7734068495,
    ["sunrise"]=7743872365,["sunset"]=7734070982,["superscript"]=8997388036,["swiss-franc"]=7734071038,
    ["switch-camera"]=7743872492,["table"]=7734073253,["tablet"]=7743872620,["tag"]=7734075797,
    ["target"]=7743872758,["tent"]=7734078943,["terminal"]=7743872929,["terminal-square"]=7734079055,
    ["text-cursor"]=8997388195,["text-cursor-input"]=8997388094,["thermometer"]=7734084149,
    ["thermometer-snowflake"]=7743873074,["thermometer-sun"]=7734084018,["thumbs-down"]=7734084236,
    ["thumbs-up"]=7743873212,["ticket"]=7734086558,["timer"]=7743873443,["timer-off"]=8997388325,
    ["timer-reset"]=7743873336,["toggle-left"]=7734091286,["toggle-right"]=7743873539,["tornado"]=7743873633,
    ["trash"]=7743873871,["trash-2"]=7743873772,["trello"]=7743873996,["trending-down"]=7743874143,
    ["trending-up"]=7743874262,["triangle"]=7743874367,["truck"]=7743874482,["tv"]=7743874674,["tv-2"]=7743874599,
    ["type"]=7743874740,["umbrella"]=7743874820,["underline"]=7743874904,["undo"]=7743874974,
    ["unlink"]=7743875149,["unlink-2"]=7743875069,["unlock"]=7743875263,["upload"]=7743875428,
    ["upload-cloud"]=7743875358,["user"]=7743875962,["user-check"]=7743875503,["user-minus"]=7743875629,
    ["user-plus"]=7743875759,["user-x"]=7743875879,["users"]=7743876054,["verified"]=7743876142,
    ["vibrate"]=7743876302,["video"]=7743876610,["video-off"]=7743876466,["view"]=7743876754,
    ["voicemail"]=7743876916,["volume"]=7743877487,["volume-1"]=7743877081,["volume-2"]=7743877250,
    ["volume-x"]=7743877381,["wallet"]=7743877573,["wand"]=8997388430,["watch"]=7743877668,["webcam"]=7743877896,
    ["wifi"]=7743878148,["wifi-off"]=7743878056,["wind"]=7743878264,["wrap-text"]=8997388548,
    ["wrench"]=7743878358,["x"]=7743878857,["x-circle"]=7743878496,["x-octagon"]=7743878618,
    ["x-square"]=7743878737,["zoom-in"]=7743878977,["zoom-out"]=7743879082,
}
local ICON_ALIASES = {
    ["move-3d"] = "move", ["sparkles"] = "wand", ["sparkle"] = "star", ["zap"] = "activity",
    ["trophy"] = "award", ["sword"] = "axe", ["swords"] = "axe", ["rocket"] = "plane",
    ["store"] = "shopping-bag", ["pickaxe"] = "hammer", ["pumpkin"] = "ghost",
    ["backpack"] = "package", ["horse"] = "navigation", ["farm"] = "sprout",
    ["cog"] = "settings", ["bolt"] = "settings", ["fire"] = "flame", ["dollar"] = "dollar-sign",
}

local function toIcon(v)
    if type(v) == "number" then
        if v ~= 0 then return v end
        return nil
    end
    if type(v) ~= "string" or v == "" then return nil end
    if v:find("^rbx") then return v end
    local key = v:lower()
    key = ICON_ALIASES[key] or key
    local id = ICON_IDS[key]
    if id then return "rbxassetid://" .. id end
    return nil
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
    tag_free = "Free",
    tag_premium = "Premium",
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

-- Shows FREE or PREMIUM as a pill next to the window title.
function Win:_updateTag()
    if self._premium.ShowTag == false then return end
    local text = self._isPremium and self._S.tag_premium or self._S.tag_free
    -- Muted colors taken from the Nexus theme so the pill blends in. Override
    -- with Premium.TagColors = { Free = Color3, Premium = Color3 }.
    local colors = self._premium.TagColors or {}
    local color = self._isPremium
        and (colors.Premium or Color3.fromRGB(82, 70, 176))
        or (colors.Free or Color3.fromRGB(42, 44, 62))
    if not self._tag then
        local ok, tag = pcall(self._raw.CreateTag, self._raw, { text = text, color = color })
        if ok then self._tag = tag end
    else
        pcall(self._tag.SetText, self._tag, text)
        pcall(self._tag.SetColor, self._tag, color)
    end
end

function Win:_applyPremium(valid, info)
    local changed = (self._isPremium ~= (valid == true))
    self._isPremium = valid == true
    self.PremiumInfo = info
    if changed then
        self:_refreshLocks()
        self:_updateTag()
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
        C:CreateSection({ Name = cfg.Title or ("Premium " .. win._price), Icon = cfg.Icon or "crown" })
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
    local tab = self:CreateTab(opts.Name or "Settings", opts.Icon or "settings")

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
-- CHROME PATCH (removes parts of the Gen2 window we do not want)
-- Uses Gen2 internals, so every step is wrapped. If a step fails the window
-- still works, it just keeps that part.
-- ============================================================================
local function dropInstance(raw, inst)
    if not inst then return end
    if type(raw.DestroySubtree) == "function" then
        if pcall(raw.DestroySubtree, raw, inst) then return end
    end
    pcall(inst.Destroy, inst)
end

local function removeAction(raw, action)
    if not action then return end
    if type(raw.actions) == "table" then
        for i, a in ipairs(raw.actions) do
            if a == action then table.remove(raw.actions, i) break end
        end
    end
    dropInstance(raw, action.action)
end

local function patchChrome(raw, config)
    if config.ShowMinimise ~= true then
        pcall(function()
            removeAction(raw, raw.minimiseAction)
            raw.ToggleMinimise = function() end
        end)
    end
    if config.HideSettingsButton == true then
        pcall(function() removeAction(raw, raw.settingsAction) end)
    end
    if config.ShowProfile ~= true then
        pcall(function()
            if raw.profile then
                dropInstance(raw, raw.profile)
                raw.profile, raw.profileContainer, raw.profileAvatar = nil, nil, nil
                raw.profileName, raw.profileSubtitle, raw.profileLabels, raw.profileLayout = nil, nil, nil, nil
                if type(raw.settings) == "table" then raw.settings.showProfile = false end
                if raw.tabList then raw.tabList.Size = UDim2.new(1, 0, 1, 0) end
            end
        end)
    end
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
    patchChrome(raw, config)

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
    win:_updateTag()

    Env.Global.__SIRIUS_NEXUS_ACTIVE = win
    return win
end

Nexus.Win = Win
Nexus.Icons = { Get = toIcon, Ids = ICON_IDS, Aliases = ICON_ALIASES }
return Nexus
