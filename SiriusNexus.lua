--!nonstrict
--!optimize 2
--!native

--[[
    SiriusNexus v3.1 (Rayfield Gen2 based — Optimized Edition)
    Author: morik_yt.

    Changes in v3.1:
      - Theme-adaptive Premium header tag (auto-syncs with active theme & ChangeTheme)
      - Single centralized Heartbeat scheduler for all Loops and Toggle OnTicks
      - Zero-allocation hot paths (_safe via direct xpcall, table.create, table.clear)
      - Reduced Luau <-> Engine property bridge crossings & spatial query in NearestPlayer
      - Cached globals, table.find, continue, and native vector math
      - Built-in Profiler (os.clock + debug.profilebegin/profileend)
]]

-- ============================================================================
-- CACHED GLOBALS (Stage 4: Luau micro-optimizations)
-- ============================================================================
local type = type
local typeof = typeof
local pcall = pcall
local xpcall = xpcall
local tostring = tostring
local select = select
local pairs = pairs
local ipairs = ipairs
local setmetatable = setmetatable
local assert = assert
local warn = warn
local loadstring = loadstring

local os_clock = os.clock
local math_max = math.max
local math_min = math.min
local math_huge = math.huge

local table_insert = table.insert
local table_remove = table.remove
local table_find = table.find
local table_clear = table.clear
local table_create = table.create
local table_sort = table.sort
local unpack = table.unpack or unpack

local string_format = string.format
local string_lower = string.lower
local string_find = string.find
local string_sub = string.sub
local string_upper = string.upper
local string_gsub = string.gsub

local task_spawn = task.spawn
local task_defer = task.defer
local task_delay = task.delay
local task_wait = task.wait
local task_cancel = task.cancel

local debug_traceback = debug.traceback
local debug_profilebegin = debug.profilebegin or function() end
local debug_profileend = debug.profileend or function() end

local Vector3_zero = Vector3.zero
local CFrame_new = CFrame.new
local Color3_fromRGB = Color3.fromRGB
local ColorSequence_new = ColorSequence.new
local UDim_new = UDim.new
local UDim2_new = UDim2.new

local Nexus = {
    Version = "3.1.0",
    Price = "$5",
}

-- ============================================================================
-- PROFILER (Stage 5: Measurement with os.clock & debug.profilebegin)
-- ============================================================================
local Profiler = {
    Enabled = false,
    _stats = {},
}

function Profiler:Begin(label)
    if not self.Enabled then return nil end
    debug_profilebegin(label)
    return os_clock()
end

function Profiler:End(label, startClock)
    if not startClock then return end
    local elapsed = os_clock() - startClock
    debug_profileend()
    local st = self._stats[label]
    if not st then
        st = { calls = 0, total = 0, max = 0 }
        self._stats[label] = st
    end
    st.calls += 1
    st.total += elapsed
    if elapsed > st.max then st.max = elapsed end
end

function Profiler:Measure(label, fn, ...)
    if not self.Enabled then
        return fn(...)
    end
    debug_profilebegin(label)
    local t0 = os_clock()
    local a, b, c, d = fn(...)
    local dt = os_clock() - t0
    debug_profileend()
    local st = self._stats[label]
    if not st then
        st = { calls = 0, total = 0, max = 0 }
        self._stats[label] = st
    end
    st.calls += 1
    st.total += dt
    if dt > st.max then st.max = dt end
    return a, b, c, d
end

function Profiler:Reset()
    table_clear(self._stats)
end

function Profiler:GetReport()
    local rows = {}
    for label, st in pairs(self._stats) do
        local avgMs = (st.calls > 0) and ((st.total / st.calls) * 1000) or 0
        rows[#rows + 1] = {
            Label = label,
            Calls = st.calls,
            TotalMs = st.total * 1000,
            AvgMs = avgMs,
            MaxMs = st.max * 1000,
        }
    end
    table_sort(rows, function(a, b) return a.TotalMs > b.TotalMs end)
    return rows
end

function Profiler:FormatReport(topN)
    local rows = self:GetReport()
    local limit = math_min(#rows, topN or 15)
    if limit == 0 then return "[Nexus Profiler] No samples recorded." end
    local lines = table_create(limit + 1)
    lines[1] = "[Nexus Profiler] Top hotspots (sorted by TotalMs):"
    for i = 1, limit do
        local r = rows[i]
        lines[i + 1] = string_format(
            "  %d. %-28s | calls: %-6d | avg: %.3f ms | max: %.3f ms | total: %.2f ms",
            i, r.Label, r.Calls, r.AvgMs, r.MaxMs, r.TotalMs
        )
    end
    return table.concat(lines, "\n")
end

Nexus.Profiler = Profiler

-- ============================================================================
-- ENV
-- ============================================================================
local Env = {}
Env.Global = (type(getgenv) == "function" and getgenv()) or _G
Env.CloneRef = (type(cloneref) == "function" and cloneref) or function(inst) return inst end

function Env:GetService(name)
    local ok, svc = pcall(game.GetService, game, name)
    if not ok or not svc then return nil end
    local ok2, ref = pcall(Env.CloneRef, svc)
    return ok2 and ref or svc
end

local Players          = Env:GetService("Players")
local RunService       = Env:GetService("RunService")
local TweenService     = Env:GetService("TweenService")
local UserInputService = Env:GetService("UserInputService")
local HttpService      = Env:GetService("HttpService")
local Workspace        = Env:GetService("Workspace") or workspace
local LocalPlayer      = Players and Players.LocalPlayer

Nexus.Env = Env

local LOCK = ""

local function pick(t, ...)
    local n = select("#", ...)
    for i = 1, n do
        local v = t[(select(i, ...))]
        if v ~= nil then return v end
    end
    return nil
end

local function copyList(t)
    if type(t) ~= "table" then return {} end
    local n = #t
    if n == 0 then return {} end
    local o = table_create(n)
    for i = 1, n do o[i] = t[i] end
    return o
end

-- ============================================================================
-- ICONS
-- ============================================================================
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

local ICON_CACHE = {}

local function toIcon(v)
    if type(v) == "number" then
        return v ~= 0 and v or nil
    end
    if type(v) ~= "string" or v == "" then return nil end
    local cached = ICON_CACHE[v]
    if cached ~= nil then return cached or nil end
    if string_find(v, "^rbx") then
        ICON_CACHE[v] = v
        return v
    end
    local key = string_lower(v)
    key = ICON_ALIASES[key] or key
    local id = ICON_IDS[key]
    local res = id and ("rbxassetid://" .. id) or false
    ICON_CACHE[v] = res
    return res or nil
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
    if string_sub(name, 1, #LOCK) == LOCK then return string_sub(name, #LOCK + 1) end
    return name
end

-- ============================================================================
-- SIGNAL (Zero-allocation Fire when single/no mutation)
-- ============================================================================
local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({ _h = {} }, Signal)
end

function Signal:Connect(fn)
    local hList = self._h
    table_insert(hList, fn)
    local conn = { Connected = true }
    function conn.Disconnect()
        if not conn.Connected then return end
        conn.Connected = false
        local idx = table_find(hList, fn)
        if idx then table_remove(hList, idx) end
    end
    return conn
end

function Signal:Fire(...)
    local hList = self._h
    local n = #hList
    if n == 0 then return end
    local snap = table_create(n)
    for i = 1, n do snap[i] = hList[i] end
    for i = 1, n do
        task_spawn(snap[i], ...)
    end
end

function Signal:Destroy()
    table_clear(self._h)
end

Nexus.Signal = Signal

-- ============================================================================
-- MAID
-- ============================================================================
local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({ _tasks = {}, _scratch = {}, _n = 0 }, Maid)
end

function Maid:_clean(item)
    local t = typeof(item)
    if t == "RBXScriptConnection" then
        if item.Connected then item:Disconnect() end
    elseif t == "Instance" then
        pcall(item.Destroy, item)
    elseif t == "thread" then
        pcall(task_cancel, item)
    elseif t == "function" then
        pcall(item)
    elseif t == "table" then
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
        local n = self._n + 1
        self._n = n
        self._tasks[n] = item
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
    local tasks = self._tasks
    local scratch = self._scratch
    table_clear(scratch)
    local count = 0
    for k, v in pairs(tasks) do
        count += 1
        scratch[count] = v
        tasks[k] = nil
    end
    self._n = 0
    for i = 1, count do
        self:_clean(scratch[i])
    end
    table_clear(scratch)
end

Maid.Destroy = Maid.DoCleaning
Nexus.Maid = Maid

-- ============================================================================
-- UTILS (Stage 3 & 4: Reduced Instance reads/writes + Spatial Query)
-- ============================================================================
local Utils = {}

-- Shared OverlapParams reused across NearestPlayer spatial queries (zero allocations)
local sharedOverlapParams = OverlapParams.new()
sharedOverlapParams.FilterType = Enum.RaycastFilterType.Exclude
local sharedFilterArray = table_create(1)

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
    if not r then return end
    -- Stage 3: Read once, only write across the Luau-Engine boundary if non-zero
    if r.AssemblyLinearVelocity ~= Vector3_zero then
        r.AssemblyLinearVelocity = Vector3_zero
    end
    if r.AssemblyAngularVelocity ~= Vector3_zero then
        r.AssemblyAngularVelocity = Vector3_zero
    end
end

function Utils:SafeTeleport(targetCFrame, offset, smoothDuration)
    local hum = self:GetHumanoid(LocalPlayer)
    local root = self:GetRootPart(LocalPlayer)
    if not root then return false end
    local dest = offset and (targetCFrame * CFrame_new(offset)) or targetCFrame
    if hum and hum.Sit then
        hum.Sit = false
        task_wait(0.05)
    end
    self:FreezeRoot(root)
    if smoothDuration and smoothDuration > 0 then
        TweenService:Create(root, TweenInfo.new(smoothDuration, Enum.EasingStyle.Linear), { CFrame = dest }):Play()
    else
        root.CFrame = dest
    end
    return true
end

function Utils:OnRespawn(fn)
    local char = LocalPlayer and LocalPlayer.Character
    if char then task_spawn(fn, char) end
    return LocalPlayer.CharacterAdded:Connect(function(newChar)
        task_spawn(fn, newChar)
    end)
end

@native
local function vectorDistance(a: Vector3, b: Vector3): number
    return (a - b).Magnitude
end

-- Stage 3: Uses GetPartBoundsInRadius spatial query when a finite radius is given,
-- and caches root.Position in a local variable before iterating.
function Utils:NearestPlayer(maxDistance)
    local localChar = LocalPlayer and LocalPlayer.Character
    local root = localChar and (localChar:FindFirstChild("HumanoidRootPart") or localChar.PrimaryPart)
    if not root then return nil end

    local origin = root.Position
    local bestPlr = nil
    local bestDist = maxDistance or math_huge

    -- Use spatial query if radius is reasonable and Workspace supports GetPartBoundsInRadius
    if bestDist < 2000 and Workspace and type(Workspace.GetPartBoundsInRadius) == "function" then
        sharedFilterArray[1] = localChar
        sharedOverlapParams.FilterDescendantsInstances = sharedFilterArray
        local ok, parts = pcall(Workspace.GetPartBoundsInRadius, Workspace, origin, bestDist, sharedOverlapParams)
        if ok and parts then
            local seenModels = {}
            for i = 1, #parts do
                local part = parts[i]
                local model = part.Parent
                if not model or seenModels[model] then continue end
                seenModels[model] = true
                local plr = Players:GetPlayerFromCharacter(model)
                if not plr or plr == LocalPlayer then continue end
                local targetRoot = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or part
                local d = vectorDistance(targetRoot.Position, origin)
                if d < bestDist then
                    bestDist = d
                    bestPlr = plr
                end
            end
            return bestPlr, bestDist
        end
    end

    -- Fallback: linear scan with single cached `origin` read
    local plrs = Players:GetPlayers()
    for i = 1, #plrs do
        local p = plrs[i]
        if p == LocalPlayer then continue end
        local r = self:GetRootPart(p)
        if not r then continue end
        local d = vectorDistance(r.Position, origin)
        if d < bestDist then
            bestDist = d
            bestPlr = p
        end
    end
    return bestPlr, bestDist
end

function Utils.Debounce(fn, delay)
    local last = 0
    return function(...)
        local now = os_clock()
        if now - last >= delay then
            last = now
            return fn(...)
        end
    end
end

@native
function Utils.Clamp(v: number, a: number, b: number): number
    return math_max(a, math_min(b, v))
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
-- NET
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

function Net.PostJson(url, body, headers, retries)
    local h = { ["Content-Type"] = "application/json" }
    if headers then
        for k, v in pairs(headers) do h[k] = v end
    end
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
        task_wait(0.4 * attempt)
    end
    return false, nil, lastErr
end

Nexus.Net = Net

-- ============================================================================
-- THEMES & THEME-MATCHED PREMIUM TAG PALETTES
-- ============================================================================
local function rgb(r, g, b) return Color3_fromRGB(r, g, b) end

local function buildTheme(accent, accentStroke, glowFrom, glowTo)
    return {
        CornerRoundness = UDim_new(0, 14),
        ElementCornerRadius = UDim_new(0, 10),
        PillCornerRadius = UDim_new(0, 10),
        WindowColor = ColorSequence_new(rgb(19, 20, 28), rgb(13, 14, 20)),
        ShadowColor = rgb(0, 0, 0),
        SurfaceStroke = rgb(44, 46, 64),
        LiveAnimation = true,

        ContentColor = rgb(222, 226, 242),
        TitlingColor = rgb(246, 247, 255),
        ElementTextHoverColor = rgb(255, 255, 255),
        ActionColor = rgb(150, 156, 190),

        TabColor = rgb(172, 178, 208),
        TabBackground = ColorSequence_new(rgb(32, 34, 50), rgb(25, 27, 39)),
        TabStroke = ColorSequence_new(rgb(70, 72, 110), rgb(48, 50, 78)),

        ElementGradient = ColorSequence_new(rgb(28, 30, 43), rgb(22, 24, 34)),
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
        SliderProgress = ColorSequence_new(glowFrom, glowTo),
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

-- Fallback surface & accent colors for built-in Gen2 themes so the Premium tag
-- always blends seamlessly with the active window theme.
local BUILTIN_THEME_SURFACES = {
    midnight = { free = rgb(30, 32, 46), premium = rgb(44, 40, 68) },
    abyss    = { free = rgb(28, 32, 46), premium = rgb(34, 48, 72) },
    default  = { free = rgb(34, 30, 32), premium = rgb(46, 38, 42) },
    cobalt   = { free = rgb(26, 32, 44), premium = rgb(34, 46, 68) },
    ember    = { free = rgb(38, 28, 26), premium = rgb(54, 36, 32) },
    amethyst = { free = rgb(34, 28, 44), premium = rgb(48, 36, 66) },
    frost    = { free = rgb(28, 36, 42), premium = rgb(36, 50, 60) },
    rose     = { free = rgb(38, 28, 34), premium = rgb(54, 36, 46) },
}

local THEME_LABELS = { "Nexus Midnight", "Nexus Abyss", "Default", "Cobalt", "Ember", "Amethyst", "Frost", "Rose" }
local THEME_VALUES = { "midnight", "abyss", "default", "cobalt", "ember", "amethyst", "frost", "rose" }

function Nexus:RegisterTheme(name, tbl)
    self.Themes[string_lower(tostring(name))] = tbl
end

local function resolveThemeKey(t)
    if type(t) == "string" then
        return string_gsub(string_lower(t), "^nexus%s*", "")
    end
    return "midnight"
end

local function resolveTheme(t)
    if type(t) == "string" then
        local key = resolveThemeKey(t)
        return Nexus.Themes[key] or Nexus.Themes[string_lower(t)] or t
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
    -- settings tab
    set_appearance = "Appearance", set_theme = "Theme", set_menu_key = "Menu key",
    set_language = "Language", set_interface = "Interface",
    set_sidebar = "Show or hide side panel", set_sidebar_desc = "Collapse the tab list to make the window smaller",
    set_tutorial = "Show tutorial", set_tutorial_desc = "Replay the quick start guide",
    set_profiles = "Profiles", set_profile_name = "Profile name", set_saved_profiles = "Saved profiles",
    set_save = "Save profile", set_load = "Load profile", set_delete = "Delete profile",
    set_type_name = "Type a name first", set_pick_first = "Pick a profile first",
    set_saved = "Saved", set_loaded = "Loaded", set_failed = "Failed",
    set_delete_title = "Delete profile?", set_delete_text = "This removes the profile for good.",
    set_window = "Window", set_unload = "Unload script", set_unload_title = "Unload?",
    set_unload_text = "Everything stops and the UI closes.", set_unload_btn = "Unload",
    cancel = "Cancel", confirm = "Confirm",
    onb_next = "Next", onb_skip = "Skip", onb_done = "Start",
}

-- ============================================================================
-- CORE LOADER
-- ============================================================================
local function loadCore(folder, channel)
    local url = (channel == "preview") and "https://sirius.menu/gen2-preview" or "https://sirius.menu/gen2"
    local cache = folder .. "/gen2_core_" .. (channel or "stable") .. ".lua"
    local lib = nil

    local ok, body = pcall(game.HttpGet, game, url)
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
-- WINDOW & ZERO-ALLOCATION ERROR HANDLER (Stage 2)
-- ============================================================================
local Win = {}

local _currentErrorLabel = "Nexus"
local function xpcallErrorHandler(err)
    warn("[Nexus] " .. tostring(_currentErrorLabel) .. ": " .. tostring(err) .. "\n" .. debug_traceback())
    return err
end

local function wrapHandle(raw, extras, virtual)
    extras = extras or {}
    virtual = virtual or {}
    local methodCache = {}
    local proxy = setmetatable({}, {
        __index = function(_, k)
            local e = extras[k]
            if e ~= nil then return e end
            local vf = virtual[k]
            if vf then return vf() end
            local cached = methodCache[k]
            if cached then return cached end
            local v = raw[k]
            if type(v) == "function" then
                local wrapped = function(_, ...) return v(raw, ...) end
                methodCache[k] = wrapped
                return wrapped
            end
            return v
        end,
        __newindex = function(_, k, v) extras[k] = v end,
    })
    extras.__raw = raw
    return proxy
end

-- Stage 2: Direct xpcall with varargs — allocates ZERO tables and ZERO closures!
function Win:_safe(label, fn, ...)
    if type(fn) ~= "function" then return false end
    _currentErrorLabel = label
    local t0 = Profiler.Enabled and Profiler:Begin(label) or nil
    local ok = xpcall(fn, xpcallErrorHandler, ...)
    if t0 then Profiler:End(label, t0) end
    if not ok and self._debugErrors then
        local now = os_clock()
        if now - (self._lastErrAt or -99) > 4 then
            self._lastErrAt = now
            self:Notify({ title = self._S.script_error, content = tostring(label), duration = 4 })
        end
    end
    return ok
end

-- ============================================================================
-- CENTRALIZED SCHEDULER (Stage 1: Single shared Heartbeat loop)
-- ============================================================================
function Win:_ensureScheduler()
    if self._stepConn or self._destroyed then return end
    if #self._tasksList == 0 then return end

    self._stepConn = RunService.Heartbeat:Connect(function(dt)
        if self._destroyed then
            self:_stopScheduler()
            return
        end
        local list = self._tasksList
        local count = #list
        if count == 0 then
            self:_stopScheduler()
            return
        end

        local i = 1
        while i <= #list do
            local entry = list[i]
            if not entry or not entry.active then
                table_remove(list, i)
                continue
            end
            local interval = entry.interval
            if interval <= 0 then
                self:_safe(entry.label, entry.fn, dt)
            else
                local elapsed = entry.elapsed + dt
                if elapsed >= interval then
                    entry.elapsed = 0
                    self:_safe(entry.label, entry.fn, elapsed)
                else
                    entry.elapsed = elapsed
                end
            end
            i += 1
        end
    end)
end

function Win:_stopScheduler()
    if self._stepConn then
        if self._stepConn.Connected then self._stepConn:Disconnect() end
        self._stepConn = nil
    end
end

function Win:_scheduleTask(key, label, interval, fn)
    local existing = self._taskMap[key]
    if existing then
        existing.fn = fn
        existing.label = label
        existing.interval = interval or 0
        existing.elapsed = 0
        existing.active = true
        self:_ensureScheduler()
        return existing
    end

    local entry = {
        key = key,
        label = label,
        fn = fn,
        interval = interval or 0,
        elapsed = 0,
        active = true,
    }
    self._taskMap[key] = entry
    table_insert(self._tasksList, entry)
    self:_ensureScheduler()
    return entry
end

function Win:_unscheduleTask(key)
    local entry = self._taskMap[key]
    if not entry then return end
    entry.active = false
    self._taskMap[key] = nil
    local idx = table_find(self._tasksList, entry)
    if idx then table_remove(self._tasksList, idx) end
    if #self._tasksList == 0 then
        self:_stopScheduler()
    end
end

-- Flags -----------------------------------------------------------------------
function Win:SetFlag(flag, value)
    if self._flags[flag] == value then return end
    self._flags[flag] = value
    local l = self._listeners[flag]
    if l and #l > 0 then
        local snap = copyList(l)
        for i = 1, #snap do
            task_spawn(snap[i], value)
        end
    end
end

function Win:GetFlag(flag)
    local v = self._flags[flag]
    if v ~= nil then return v end
    local ok, rawVal = pcall(self._raw.Get, self._raw, flag)
    if ok then return rawVal end
    return nil
end

function Win:OnFlag(flag, fn)
    local list = self._listeners[flag]
    if not list then
        list = {}
        self._listeners[flag] = list
    end
    table_insert(list, fn)
    return {
        Disconnect = function()
            local idx = table_find(list, fn)
            if idx then table_remove(list, idx) end
        end,
    }
end

-- Profiler helpers ------------------------------------------------------------
function Win:EnableProfiler(enabled)
    Profiler.Enabled = (enabled ~= false)
end

function Win:GetProfileReport(topN)
    return Profiler:FormatReport(topN)
end

-- Lifecycle -------------------------------------------------------------------
function Win:BindConnection(signal, callback, key)
    return self._maid:Add(signal:Connect(callback), key)
end
Win.Connect = Win.BindConnection

function Win:AddTask(item, key) return self._maid:Add(item, key) end
function Win:CleanTask(key) self._maid:CleanKey(key) end

-- Uses the single shared Heartbeat scheduler instead of spawning threads!
function Win:Loop(key, interval, fn)
    local k = "Loop_" .. tostring(key)
    local step = math_max(0, interval or 0.1)
    return self:_scheduleTask(k, k, step, fn)
end

function Win:StopLoop(key)
    self:_unscheduleTask("Loop_" .. tostring(key))
end

function Win:IsAlive() return not self._destroyed end

function Win:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    self:_stopScheduler()
    table_clear(self._tasksList)
    table_clear(self._taskMap)
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
    local now = os_clock()
    if self._lastNote == sig and now - (self._lastNoteAt or 0) < 1.5 then return end
    self._lastNote, self._lastNoteAt = sig, now
    pcall(self._raw.Notify, self._raw, props)
end

function Win:Toast(a, b)
    local props = type(a) == "table" and a or { title = a, subtitle = b }
    pcall(self._raw.Toast, self._raw, props)
end

function Win:Success(title, content, dur) self:Notify({ title = tostring(title), content = content, duration = dur, icon = "check-circle" }) end
function Win:Warn(title, content, dur)    self:Notify({ title = tostring(title), content = content, duration = dur, icon = "alert-triangle" }) end
function Win:Error(title, content, dur)   self:Notify({ title = tostring(title), content = content, duration = dur, icon = "x-circle" }) end
function Win:Info(title, content, dur)    self:Notify({ title = tostring(title), content = content, duration = dur, icon = "info" }) end

function Win:Confirm(cfg)
    local opts = {
        { text = cfg.CancelText or self._S.cancel },
        {
            text = cfg.ConfirmText or self._S.confirm,
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
    -- Stage 2: Precompute label string once on Bind instead of inside InputBegan
    self._binds[id] = {
        key = kc,
        cb = callback,
        opts = opts or {},
        label = "Bind " .. tostring(id),
    }
    return true
end

function Win:Unbind(id) self._binds[id] = nil end

function Win:SetToggleKey(key)
    local kc = toKeyCode(key)
    if kc then self._uiKey = kc end
    return self._uiKey
end

-- Theme & Theme-Synced Premium Tag --------------------------------------------
function Win:_resolveTagColor()
    local custom = self._premium.TagColors
    if custom then
        local c = self._isPremium and custom.Premium or custom.Free
        if c then return c end
    end

    -- 1. Try reading surface & accent colors directly from the active theme table
    local rawTheme = (self._raw and self._raw.theme) or (type(self._activeTheme) == "table" and self._activeTheme) or nil
    if type(rawTheme) == "table" then
        local surface = rawTheme.NeutralButton or rawTheme.StatBackground or rawTheme.FieldBackground
        local accent = rawTheme.AccentColor or rawTheme.ElementStrokeHover
        if typeof(surface) == "Color3" then
            if self._isPremium and typeof(accent) == "Color3" then
                -- Subtle 15% tint of the theme's accent over its own button surface
                return surface:Lerp(accent, 0.15)
            end
            return surface
        end
    end

    -- 2. Fallback to the built-in theme palette matching the current theme key
    local key = self._themeKey or "default"
    local palette = BUILTIN_THEME_SURFACES[key] or BUILTIN_THEME_SURFACES.default
    return self._isPremium and palette.premium or palette.free
end

function Win:_styleTagInstance(tagObj, color)
    -- If Gen2 exposes the underlying Frame/Instance on the tag object, harmonize
    -- its stroke and transparency with the rest of the window's buttons/tabs.
    local inst = type(tagObj) == "table" and (tagObj.instance or tagObj.tag or tagObj.frame or tagObj.container) or nil
    if typeof(inst) ~= "Instance" then return end
    local rawTheme = (self._raw and self._raw.theme) or (type(self._activeTheme) == "table" and self._activeTheme) or nil
    local strokeColor = (type(rawTheme) == "table" and (rawTheme.ElementStroke or rawTheme.SurfaceStroke)) or rgb(52, 50, 58)
    local textColor = (type(rawTheme) == "table" and (self._isPremium and rawTheme.TitlingColor or rawTheme.TabColor)) or rgb(220, 220, 230)

    pcall(function()
        local stroke = inst:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = strokeColor
            stroke.Transparency = 0.2
        end
        local label = inst:FindFirstChildOfClass("TextLabel")
        if label then
            label.TextColor3 = textColor
        end
    end)
end

function Win:_updateTag()
    if self._premium.ShowTag == false then return end
    local text = self._isPremium and self._S.tag_premium or self._S.tag_free
    local color = self:_resolveTagColor()

    if not self._tag then
        local ok, tag = pcall(self._raw.CreateTag, self._raw, { text = text, color = color })
        if ok and tag then
            self._tag = tag
            self._tagText = text
            self._tagColor = color
            self:_styleTagInstance(tag, color)
        end
    else
        -- Stage 3: Avoid redundant Luau <-> Engine property writes
        if self._tagText ~= text then
            self._tagText = text
            pcall(self._tag.SetText, self._tag, text)
        end
        if self._tagColor ~= color then
            self._tagColor = color
            pcall(self._tag.SetColor, self._tag, color)
        end
        self:_styleTagInstance(self._tag, color)
    end
end

function Win:ChangeTheme(t)
    self._themeKey = resolveThemeKey(t)
    local resolved = resolveTheme(t)
    self._activeTheme = resolved
    local res = self._raw:ChangeTheme(resolved)
    -- Keep the Premium tag in sync with the newly applied theme
    self:_updateTag()
    return res
end

-- Premium ---------------------------------------------------------------------
function Win:IsPremium() return self._isPremium end

function Win:SetPremiumVerifier(fn) self._verifier = fn end
function Win:SetPremiumLoader(fn) self._loader = fn end

local RENAME_METHODS = { "SetName", "SetLabel", "SetTitle", "Rename" }

function Win:_refreshLocks()
    local isPrem = self._isPremium
    local lockables = self._lockables
    for i = 1, #lockables do
        local item = lockables[i]
        local label = isPrem and item.base or item.locked
        if item.lastApplied ~= label then
            for m = 1, #RENAME_METHODS do
                local f = item.raw[RENAME_METHODS[m]]
                if type(f) == "function" then
                    if pcall(f, item.raw, label) then
                        item.lastApplied = label
                        break
                    end
                end
            end
        end
    end
end

function Win:_applyPremium(valid, info)
    local newStatus = (valid == true)
    local changed = (self._isPremium ~= newStatus)
    self._isPremium = newStatus
    self.PremiumInfo = info
    if changed then
        self:_refreshLocks()
        self:_updateTag()
        self.PremiumChanged:Fire(self._isPremium, info)
        self:Toast(self._isPremium and self._S.premium_on or self._S.premium_off)
    end
end

function Win:SetPremiumStatus(isPremium, onBlocked)
    if onBlocked ~= nil then self._onPremiumBlocked = onBlocked end
    self:_applyPremium(isPremium == true, nil)
    if self._isPremium then task_spawn(function() self:LoadPremiumModule() end) end
end

function Win:VerifyPremium(callback)
    if not self._verifier or self._verifying then return false end
    self._verifying = true
    task_spawn(function()
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
    if type(self._premium.OnBuy) == "function" then
        self:_safe("OnBuy", self._premium.OnBuy, self)
        return
    end
    local link = self._premium.Discord
    if link and Utils.Copy(link) then
        self:Toast(self._S.link_copied)
    end
end

function Win:ShowPremiumPopup(featureName)
    local features = self._premium.Features
    local boxes = features and table_create(#features) or {}
    if features then
        for i = 1, #features do
            local f = features[i]
            if type(f) == "string" then
                boxes[#boxes + 1] = { title = f }
            else
                boxes[#boxes + 1] = {
                    title = pick(f, "title", "Title", 1) or "",
                    description = pick(f, "description", "Description", 2),
                    icon = toIcon(pick(f, "icon", "Icon", 3)),
                }
            end
        end
    end
    local props = {
        title = string_format(self._S.premium_title, self._price),
        subtitle = featureName and (self._S.premium_subtitle .. ": " .. featureName) or nil,
        options = {
            { text = self._S.later },
            { text = self._S.buy, style = "primary", callback = function() self:CopyBuyLink() end },
        },
    }
    if #boxes > 0 then
        props.boxes = boxes
    else
        props.content = string_format(self._S.premium_body, self._price)
    end
    pcall(self._raw.Popup, self._raw, props)
end

function Win:_premiumBlocked(featureName)
    local now = os_clock()
    if now < self._bootUntil then return end
    if now - (self._lastGate or -99) < 2 then return end
    self._lastGate = now
    if self._onPremiumBlocked then
        task_spawn(self._onPremiumBlocked, featureName)
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
        return pick(cfg, "Description", "description")
    end

    local function blocked(cfg, name)
        if cfg.PremiumOnly and not win._isPremium then
            win:_premiumBlocked(name)
            return true
        end
        return false
    end

    local function register(raw, name, cfg, initialLabel)
        if cfg.PremiumOnly then
            table_insert(win._lockables, {
                raw = raw,
                base = name,
                locked = LOCK .. name,
                lastApplied = initialLabel,
            })
        end
    end

    local function flagFor(cfg, name)
        local f = pick(cfg, "Flag", "flag")
        if not f then
            f = string_gsub(stripLock(tostring(name)), "[^%w]+", "")
            if f == "" then
                idCounter += 1
                f = "Element" .. idCounter
            end
        end
        local used = win._usedFlags
        if used[f] then
            local n = 2
            while used[f .. "_" .. n] do n += 1 end
            f = f .. "_" .. n
        end
        used[f] = true
        return f
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

    local PARA_TITLE_SETTERS = { "SetTitle", "SetName", "SetLabel", "Rename" }
    local PARA_BODY_SETTERS = { "SetContent", "SetDescription", "SetText", "SetBody", "SetSubtitle" }

    local function rawInstances(raw)
        local out = {}
        if typeof(raw) == "Instance" then out[1] = raw return out end
        if type(raw) ~= "table" then return out end
        for _, k in ipairs({ "instance", "frame", "container", "root", "holder", "element", "gui", "main", "object", "body", "card" }) do
            local v = rawget(raw, k)
            if typeof(v) == "Instance" then out[#out + 1] = v end
        end
        if #out == 0 then
            for _, v in pairs(raw) do
                if typeof(v) == "Instance" and v:IsA("GuiObject") then out[#out + 1] = v end
            end
        end
        return out
    end

    local function guiRoots()
        local roots = {}
        local ok, h = pcall(function() return gethui and gethui() end)
        if ok and typeof(h) == "Instance" then roots[#roots + 1] = h end
        local okc, cg = pcall(function() return game:GetService("CoreGui") end)
        if okc and cg then roots[#roots + 1] = cg end
        local okp, pg = pcall(function() return game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui") end)
        if okp and pg then roots[#roots + 1] = pg end
        return roots
    end

    local function labelText(l)
        local ok, v = pcall(function() return l.Text end)
        return ok and v or nil
    end

    local function norm(s)
        s = tostring(s or "")
        s = s:gsub("<[^>]->", ""):gsub("&amp;", "&"):gsub("&lt;", "<"):gsub("&gt;", ">")
        s = s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        return string.lower(s)
    end

    -- Finds the rendered title/content labels of a paragraph by text.
    local function locateLabels(raw, title, content)
        local nt, nc = norm(title), norm(content)
        local scopes = rawInstances(raw)
        for _, r in ipairs(guiRoots()) do scopes[#scopes + 1] = r end
        for _, scope in ipairs(scopes) do
            local all = scope:GetDescendants()
            local titles, contents = {}, {}
            for i = 1, #all do
                local d = all[i]
                if d:IsA("TextLabel") or d:IsA("TextButton") then
                    local tx = labelText(d)
                    if tx and tx ~= "" then
                        local n = norm(tx)
                        if nt ~= "" and n == nt then titles[#titles + 1] = d end
                        if nc ~= "" and n == nc then contents[#contents + 1] = d end
                    end
                end
            end
            if #contents > 0 or #titles > 0 then
                for _, c in ipairs(contents) do
                    for _, tl in ipairs(titles) do
                        local anc = c.Parent
                        for _ = 1, 6 do
                            if anc and tl:IsDescendantOf(anc) then return tl, c end
                            anc = anc and anc.Parent
                        end
                    end
                end
                return titles[1], contents[1]
            end
        end
        return nil, nil
    end

    function C:CreateParagraph(cfg)
        local title = pick(cfg, "Title", "title", "Name", "name") or ""
        local content = pick(cfg, "Content", "content", "Description", "description") or ""
        local raw
        local isText = false
        if type(rawC.CreateText) == "function" then
            raw = rawC:CreateText({ name = title, text = content })
            isText = raw ~= nil
        end
        if isText then
            -- Gen2 Text element: Set(body) / SetTitle(title) are native
        elseif type(rawC.CreateParagraph) == "function" then
            raw = rawC:CreateParagraph({ title = title, content = content })
        elseif type(rawC.CreateLabel) == "function" then
            raw = rawC:CreateLabel({ name = title, description = content })
        else
            raw = rawC:CreateButton({ name = title, description = content, callback = function() end })
        end
        local shown = { title = title, content = content }
        table_insert(win._translatable, shown)
        local extras = {}
        local lblT, lblC
        local function relocate()
            local a, b = locateLabels(raw, shown.title, shown.content)
            if a then lblT = a end
            if b then lblC = b end
        end
        if not isText then
            task_spawn(function()
                task_wait(0.4)
                pcall(relocate)
            end)
        end

        local function push(newTitle, newContent)
            newTitle, newContent = tostring(newTitle or ""), tostring(newContent or "")
            local oldT, oldC = shown.title, shown.content
            if newTitle == oldT and newContent == oldC then return end
            local done = false
            if isText then
                local okT, okC = true, true
                if newTitle ~= oldT and type(raw.SetTitle) == "function" then okT = pcall(raw.SetTitle, raw, newTitle) end
                if newContent ~= oldC and type(raw.Set) == "function" then okC = pcall(raw.Set, raw, newContent) end
                done = okT and okC
            elseif type(raw.Set) == "function" then
                done = pcall(raw.Set, raw, { title = newTitle, content = newContent, Title = newTitle, Content = newContent })
            end
            if not done then
                if newTitle ~= oldT then
                    for i = 1, #PARA_TITLE_SETTERS do
                        local f = raw[PARA_TITLE_SETTERS[i]]
                        if type(f) == "function" and pcall(f, raw, newTitle) then done = true break end
                    end
                end
                if newContent ~= oldC then
                    for i = 1, #PARA_BODY_SETTERS do
                        local f = raw[PARA_BODY_SETTERS[i]]
                        if type(f) == "function" and pcall(f, raw, newContent) then done = true break end
                    end
                end
            end
            -- Make sure the rendered labels really show the new text
            local function apply()
                if newTitle ~= oldT then
                    if not (lblT and lblT.Parent) then pcall(relocate) end
                    if lblT and lblT.Parent then lblT.Text = newTitle end
                end
                if newContent ~= oldC then
                    if not (lblC and lblC.Parent) then pcall(relocate) end
                    if lblC and lblC.Parent then lblC.Text = newContent end
                end
            end
            local okA = true
            if not done then okA = pcall(apply) end
            if not done and (not okA or (newContent ~= oldC and not (lblC and lblC.Parent))) then
                if not win._paraDiag then
                    win._paraDiag = true
                    local keys = {}
                    for k, v in pairs(raw) do keys[#keys + 1] = tostring(k) .. ":" .. typeof(v) end
                    warn("[RIU] paragraph raw keys: " .. table.concat(keys, ", "))
                    local roots = {}
                    for _, r in ipairs(guiRoots()) do roots[#roots + 1] = r:GetFullName() end
                    warn("[RIU] gui roots: " .. table.concat(roots, ", "))
                end
                warn("[RIU] Paragraph label not found for update: " .. tostring(oldT))
            end
            shown.title, shown.content = newTitle, newContent
        end

        function extras:Set(a, b)
            if type(a) == "table" then
                local t = pick(a, "Title", "title", "Name", "name")
                local c = pick(a, "Content", "content", "Description", "description")
                push(t ~= nil and t or shown.title, c ~= nil and c or shown.content)
            elseif b ~= nil then
                push(a, b)
            elseif a ~= nil then
                push(shown.title, a)
            end
        end
        function extras:SetTitle(t) push(t, shown.content) end
        function extras:SetContent(c) push(shown.title, c) end
        function extras:Get() return shown.title, shown.content end
        return wrapHandle(raw, extras)
    end

    function C:CreateGroup(cfg)
        return makeContainer(win, rawC:CreateGroup(cfg or {}))
    end

    -- Button -------------------------------------------------------------------
    function C:CreateButton(cfg)
        local name = pick(cfg, "Name", "name") or "Button"
        local cb = pick(cfg, "Callback", "callback")
        local initLabel = labelFor(cfg, name)
        local raw = rawC:CreateButton({
            name = initLabel,
            description = descFor(cfg),
            icon = toIcon(pick(cfg, "Icon", "icon")),
            callback = function()
                if blocked(cfg, name) then return end
                if cb then win:_safe(name, cb) end
            end,
        })
        register(raw, name, cfg, initLabel)
        return wrapHandle(raw)
    end

    -- Toggle (Stage 1: Routed through the centralized Heartbeat scheduler) -----
    function C:CreateToggle(cfg)
        local name = pick(cfg, "Name", "name") or "Toggle"
        local flag = flagFor(cfg, name)
        local cb = pick(cfg, "Callback", "callback")
        local onTick = pick(cfg, "OnTick", "onTick")
        local loop = pick(cfg, "Loop", "loop")
        local loopKey = "ToggleLoop_" .. flag
        local initial = pick(cfg, "CurrentValue", "value", "Default") == true
        if isLocked(cfg) then initial = false end
        local initLabel = labelFor(cfg, name)
        local raw

        local function syncLoop(state)
            win:_unscheduleTask(loopKey)
            win._maid:CleanKey(loopKey)
            if not state or not onTick then return end

            if loop == nil or loop == "Heartbeat" then
                win:_scheduleTask(loopKey, name, 0, onTick)
            elseif type(loop) == "number" then
                win:_scheduleTask(loopKey, name, math_max(0.03, loop), onTick)
            elseif loop == "Stepped" then
                win._maid:Add(RunService.Stepped:Connect(function(_, dt) win:_safe(name, onTick, dt) end), loopKey)
            elseif loop == "RenderStepped" then
                win._maid:Add(RunService.RenderStepped:Connect(function(dt) win:_safe(name, onTick, dt) end), loopKey)
            end
        end

        raw = rawC:CreateToggle({
            name = initLabel,
            description = descFor(cfg),
            icon = toIcon(pick(cfg, "Icon", "icon")),
            value = initial,
            flag = flag,
            forgetState = noSave(cfg) or nil,
            callback = function(state)
                if blocked(cfg, name) then
                    if state then
                        task_defer(function()
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
        register(raw, name, cfg, initLabel)
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
        local initLabel = labelFor(cfg, name)
        local raw
        raw = rawC:CreateSlider({
            name = initLabel,
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
        register(raw, name, cfg, initLabel)
        win._flags[flag] = val
        return wrapHandle(raw, {}, { CurrentValue = function() return raw.value end })
    end

    -- Input --------------------------------------------------------------------
    function C:CreateInput(cfg)
        local name = pick(cfg, "Name", "name") or "Input"
        local flag = flagFor(cfg, name)
        local cb = pick(cfg, "Callback", "callback")
        local clearAfter = pick(cfg, "RemoveTextAfterFocusLost") == true
        local initLabel = labelFor(cfg, name)
        local raw
        raw = rawC:CreateInput({
            name = initLabel,
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
                if clearAfter and raw then task_defer(function() pcall(raw.Set, raw, "", true) end) end
            end,
        })
        register(raw, name, cfg, initLabel)
        return wrapHandle(raw, {}, { CurrentValue = function() return raw.value end })
    end

    -- Keybind ------------------------------------------------------------------
    function C:CreateKeybind(cfg)
        local name = pick(cfg, "Name", "name") or "Keybind"
        local flag = flagFor(cfg, name)
        local cb = pick(cfg, "Callback", "callback")
        local initLabel = labelFor(cfg, name)
        local raw = rawC:CreateKeybind({
            name = initLabel,
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
        register(raw, name, cfg, initLabel)
        return wrapHandle(raw, {}, { CurrentKeybind = function() return raw.value end })
    end

    -- Color picker -------------------------------------------------------------
    function C:CreateColorPicker(cfg)
        local name = pick(cfg, "Name", "name") or "Color"
        local flag = flagFor(cfg, name)
        local cb = pick(cfg, "Callback", "callback")
        local initial = pick(cfg, "Color", "color", "CurrentValue", "value") or rgb(255, 255, 255)
        local last = initial
        local initLabel = labelFor(cfg, name)
        local raw
        raw = rawC:CreateColorPicker({
            name = initLabel,
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
        register(raw, name, cfg, initLabel)
        return wrapHandle(raw)
    end

    -- Dropdown -----------------------------------------------------------------
    local function buildDropdown(cfg)
        local name = pick(cfg, "Name", "name") or "Dropdown"
        local flag = flagFor(cfg, name)
        local multi = pick(cfg, "MultipleOptions", "MultiSelect", "multiSelect") == true
        local legacy = (cfg.Compat ~= false) and win._compat
        local cb = pick(cfg, "Callback", "callback")
        local source = copyList(pick(cfg, "Options", "options"))
        local initLabel = labelFor(cfg, name)
        local clearOnSelect = pick(cfg, "ClearOnSelect", "clearOnSelect") == true
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

        raw = rawC:CreateDropdown({
            name = initLabel,
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
                    task_defer(function() setRaw(last) end)
                    return
                end
                -- Single mode: clicking the already selected option makes the raw
                -- control deselect it (empty value). Treat that as a re-select so the
                -- same item can be picked again without choosing another one first.
                if not multi and #arr == 0 and #last > 0 then
                    arr = last
                    v = arr[1]
                    task_defer(function() setRaw(arr) end)
                end
                last = arr
                local out = (legacy or multi) and arr or v
                if flag then win:SetFlag(flag, out) end
                if cb then win:_safe(name, cb, out) end
                -- ClearOnSelect: action-style dropdowns (teleport etc.) reset after
                -- every pick, so any entry, including the same one, can be chosen again.
                if clearOnSelect and not multi and #arr > 0 then
                    last = {}
                    task_defer(function() setRaw({}) end)
                end
            end,
        })
        register(raw, name, cfg, initLabel)

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

        -- Stage 4: Uses table_find instead of manual loop
        function extras:Refresh(list)
            source = copyList(list)
            local current = norm(raw.value)
            local keep = {}
            for i = 1, #current do
                local x = current[i]
                if table_find(source, x) then
                    keep[#keep + 1] = x
                end
            end
            raw:Refresh(copyList(source))
            setRaw(keep)
            last = keep
        end
        extras.SetOptions = extras.Refresh

        function extras:Filter(text)
            text = string_lower(tostring(text or ""))
            local selected = norm(raw.value)
            local out = {}
            for i = 1, #source do
                local o = source[i]
                if text == "" or string_find(string_lower(tostring(o)), text, 1, true) or table_find(selected, o) then
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

    -- Search input -------------------------------------------------------------
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
                pending += 1
                local mine = pending
                task_delay(0.18, function()
                    if mine ~= pending then return end
                    for i = 1, #targets do
                        pcall(targets[i].Filter, targets[i], text)
                    end
                    if cfg.Callback then win:_safe("SearchInput", cfg.Callback, text) end
                end)
            end,
        })
    end

    -- Player selector (Stage 2: Reuses map table with table.clear) -------------
    function C:CreatePlayerDropdown(cfg)
        cfg = cfg or {}
        idCounter += 1
        local id = "PlayerDD_" .. idCounter
        local includeLocal = cfg.IncludeLocal == true
        local useDisplay = cfg.DisplayNames == true
        local filter = cfg.Filter
        local userCb = pick(cfg, "Callback", "callback")
        local map = {}

        local function build()
            table_clear(map)
            local plrs = Players:GetPlayers()
            table_sort(plrs, function(a, b) return string_lower(a.Name) < string_lower(b.Name) end)
            local list = table_create(#plrs)
            for i = 1, #plrs do
                local p = plrs[i]
                if not includeLocal and p == LocalPlayer then continue end
                if filter and not filter(p) then continue end
                local label = useDisplay and string_format("%s (@%s)", p.DisplayName, p.Name) or p.Name
                map[label] = p
                list[#list + 1] = label
            end
            return list
        end

        local function playersFrom(labels)
            local out = table_create(#labels)
            for i = 1, #labels do
                local p = map[labels[i]]
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
            task_delay(0.3, function()
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

    -- Premium showcase block (Clean, theme-matching buttons & icons) -----------
    function C:CreatePremiumShowcase(cfg)
        cfg = cfg or {}
        C:CreateSection({ Name = cfg.Title or ("Premium " .. win._price), Icon = cfg.Icon or "crown" })
        C:CreateButton({
            Name = cfg.InfoText or "What is included",
            Description = cfg.InfoDescription or "See every Premium feature",
            Icon = "sparkles",
            Callback = function() win:ShowPremiumPopup() end,
        })
        C:CreateButton({
            Name = cfg.BuyText or ("Get Premium for " .. win._price),
            Description = cfg.BuyDescription or "Opens the purchase invite",
            Icon = "arrow-up-right",
            Callback = function()
                win:CopyBuyLink()
                if type(win._premium.OnBuy) ~= "function" then win:ShowPremiumPopup() end
            end,
        })
    end

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

function Win:SetStrings(map)
    if type(map) ~= "table" then return end
    for k, v in pairs(map) do self._S[k] = v end
    self:_updateTag()
end

function Win:LoadConfiguration()
    local f = self._raw.LoadConfiguration
    if type(f) == "function" then return pcall(f, self._raw) end
    return false
end

function Win:_configs()
    local ok, list = pcall(self._raw.ListConfigs, self._raw)
    if ok and type(list) == "table" then return list end
    return {}
end

function Win:CreateSettingsTab(opts)
    opts = opts or {}
    local S = self._S
    local tab = self:CreateTab(opts.Name or "Settings", opts.Icon or "settings")

    tab:CreateSection({ Name = S.set_appearance, Icon = "palette" })
    local curTheme = THEME_LABELS[table_find(THEME_VALUES, self._themeKey) or 1]
    tab:CreateDropdown({
        Name = S.set_theme, Flag = "Nexus_Theme", Icon = "palette",
        Options = THEME_LABELS, CurrentOption = { curTheme },
        Callback = function(sel)
            local idx = sel[1] and table_find(THEME_LABELS, sel[1])
            if idx then self:ChangeTheme(THEME_VALUES[idx]) end
        end,
    })

    if opts.Languages then
        local names = table_create(#opts.Languages)
        local codeByName = {}
        for i = 1, #opts.Languages do
            local l = opts.Languages[i]
            names[i] = l.name
            codeByName[l.name] = l.code
        end
        tab:CreateDropdown({
            Name = S.set_language, Flag = "Nexus_Language", Icon = "languages",
            Options = names,
            CurrentOption = opts.CurrentLanguage and { opts.CurrentLanguage } or {},
            ForgetState = true,
            Callback = function(sel)
                local code = sel[1] and codeByName[sel[1]]
                if not code then return end
                pcall(self._raw.SetLocale, self._raw, code)
                if opts.OnLanguage then opts.OnLanguage(code) end
            end,
        })
        self._languageNames = names
    end

    tab:CreateSection({ Name = S.set_interface, Icon = "layout-dashboard" })
    local keyNames = { "RightShift", "RightControl", "LeftAlt", "Insert", "Delete", "K", "F6" }
    local curKey = (self._uiKey and self._uiKey.Name) or "RightShift"
    if not table_find(keyNames, curKey) then table_insert(keyNames, curKey) end
    tab:CreateDropdown({
        Name = S.set_menu_key, Flag = "Nexus_MenuKey", Icon = "key",
        Options = keyNames, CurrentOption = { curKey },
        Callback = function(sel) if sel[1] then self:SetToggleKey(sel[1]) end end,
    })

    tab:CreateSection({ Name = S.set_profiles, Icon = "save" })
    local cfgName, picked = "", nil
    tab:CreateInput({
        Name = S.set_profile_name, PlaceholderText = "my-profile", ForgetState = true,
        Callback = function(t) cfgName = t end,
    })
    local list = tab:CreateDropdown({
        Name = S.set_saved_profiles, Options = self:_configs(), ForgetState = true,
        Callback = function(sel) picked = sel[1] end,
    })
    tab:CreateButton({
        Name = S.set_save, Icon = "save",
        Callback = function()
            local n = (cfgName ~= "" and cfgName) or picked
            if not n then self:Warn(S.set_profiles, S.set_type_name) return end
            local ok = pcall(self._raw.Save, self._raw, n)
            if ok then self:Success(S.set_profiles, S.set_saved .. ": " .. n) else self:Error(S.set_profiles, S.set_failed) end
            list:Refresh(self:_configs())
        end,
    })
    tab:CreateButton({
        Name = S.set_load, Icon = "download",
        Callback = function()
            local n = picked or (cfgName ~= "" and cfgName)
            if not n then self:Warn(S.set_profiles, S.set_pick_first) return end
            local ok = pcall(self._raw.Load, self._raw, n)
            if ok then self:Success(S.set_profiles, S.set_loaded .. ": " .. n) else self:Error(S.set_profiles, S.set_failed) end
        end,
    })
    tab:CreateButton({
        Name = S.set_delete, Icon = "trash-2",
        Callback = function()
            local n = picked
            if not n then self:Warn(S.set_profiles, S.set_pick_first) return end
            self:Confirm({
                Title = S.set_delete_title, Content = S.set_delete_text .. " (" .. n .. ")",
                ConfirmText = S.set_delete, Danger = true,
                OnConfirm = function()
                    pcall(self._raw.DeleteConfig, self._raw, n)
                    list:Refresh(self:_configs())
                end,
            })
        end,
    })

    tab:CreateSection({ Name = S.set_window, Icon = "power" })
    tab:CreateButton({
        Name = S.set_unload, Icon = "log-out",
        Callback = function()
            self:Confirm({
                Title = S.set_unload_title, Content = S.set_unload_text,
                ConfirmText = S.set_unload_btn, Danger = true,
                OnConfirm = function() self:Destroy() end,
            })
        end,
    })
    return tab
end

-- ============================================================================
-- CHROME PATCH
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
        local idx = table_find(raw.actions, action)
        if idx then table_remove(raw.actions, idx) end
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
                if raw.tabList then raw.tabList.Size = UDim2_new(1, 0, 1, 0) end
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

    local rawThemeArg = pick(config, "Theme", "theme") or "midnight"
    local themeKey = resolveThemeKey(rawThemeArg)
    local resolvedTheme = resolveTheme(rawThemeArg)

    local props = {
        name = name,
        subtitle = pick(config, "Subtitle", "subtitle", "LoadingSubtitle"),
        theme = resolvedTheme,
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
    if config.Strings then
        for k, v in pairs(config.Strings) do strings[k] = v end
    end

    local win = {
        _core = core,
        _raw = raw,
        _maid = Maid.new(),
        _tasksList = {},
        _taskMap = {},
        _stepConn = nil,
        _flags = {},
        _usedFlags = {},
        _translatable = {},
        _listeners = {},
        _binds = {},
        _lockables = {},
        _isPremium = false,
        _premium = premium,
        _price = premium.Price or Nexus.Price,
        _themeKey = themeKey,
        _activeTheme = resolvedTheme,
        _S = strings,
        _compat = config.Compat ~= false,
        _debugErrors = config.DebugErrors ~= false,
        _bootUntil = os_clock() + 3,
        _uiKey = toKeyCode(pick(config, "ToggleUIKey", "ToggleKey")) or Enum.KeyCode.RightShift,
        Tabs = {},
        Utils = Utils,
        Net = Net,
        Profiler = Profiler,
        Nexus = Nexus,
        PremiumChanged = Signal.new(),
        Destroying = Signal.new(),
    }
    setmetatable(win, {
        __index = function(_, k)
            local m = Win[k]
            if m ~= nil then return m end
            local v = raw[k]
            if type(v) == "function" then
                return function(_, ...) return v(raw, ...) end
            end
            return v
        end,
    })

    -- Global hotkeys (Stage 2 & 4: Uses continue and precomputed bind labels)
    if UserInputService then
        win._maid:Add(UserInputService.InputBegan:Connect(function(input, processed)
            if win._destroyed then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if UserInputService:GetFocusedTextBox() ~= nil then return end

            local keyCode = input.KeyCode
            if keyCode == win._uiKey and not processed then
                pcall(raw.ToggleHide, raw)
                return
            end
            for _, b in pairs(win._binds) do
                if b.key ~= keyCode then continue end
                if not b.opts.AllowProcessed and processed then continue end
                win:_safe(b.label, b.cb)
            end
        end), "Hotkeys")
    end

    if premium.Verify then win._verifier = premium.Verify end
    if premium.LoadModule then win._loader = premium.LoadModule end
    win:_updateTag()

    -- Truncation fixer: any label whose text does not fit gets wrapped instead of cut.
    if config.FixTruncation ~= false then
        task_spawn(function()
            local gui
            for _ = 1, 20 do
                local ok, g = pcall(function() return raw.tabList and raw.tabList:FindFirstAncestorOfClass("ScreenGui") end)
                if ok and g then gui = g break end
                task_wait(0.25)
            end
            if not gui then return end
            local TextService = game:GetService("TextService")
            local pending, queued = {}, false
            local function fixLabel(l)
                if not l.Parent or l:GetAttribute("NxFixed") then return end
                if l.Text == "" or l.AbsoluteSize.X < 8 then return end
                if l.TextTruncate == Enum.TextTruncate.None and l.TextWrapped then return end
                local ok, sz = pcall(function()
                    return TextService:GetTextSize(l.Text, l.TextSize, l.Font, Vector2.new(100000, 100000))
                end)
                if not ok or sz.X <= l.AbsoluteSize.X + 1 then return end
                l:SetAttribute("NxFixed", true)
                l.TextTruncate = Enum.TextTruncate.None
                l.TextWrapped = true
                if l.AutomaticSize == Enum.AutomaticSize.None and l.Size.Y.Scale == 0 then
                    l.AutomaticSize = Enum.AutomaticSize.Y
                end
                local p = l.Parent
                for _ = 1, 3 do
                    if not p or not p:IsA("GuiObject") or p:IsA("ScrollingFrame") then break end
                    if p.AutomaticSize == Enum.AutomaticSize.None and p.Size.Y.Scale == 0 then
                        p.AutomaticSize = Enum.AutomaticSize.Y
                    end
                    p = p.Parent
                end
            end
            local function flush()
                queued = false
                local batch = pending
                pending = {}
                for l in pairs(batch) do pcall(fixLabel, l) end
            end
            local function consider(d)
                if d:IsA("TextLabel") or d:IsA("TextButton") then
                    pending[d] = true
                    if not queued then
                        queued = true
                        task_delay(0.15, flush)
                    end
                end
            end
            win._maid:Add(gui.DescendantAdded:Connect(consider), "TruncFix")
            for _, d in ipairs(gui:GetDescendants()) do consider(d) end
        end)
    end

    Env.Global.__SIRIUS_NEXUS_ACTIVE = win
    return win
end

Nexus.Win = Win
Nexus.Icons = { Get = toIcon, Ids = ICON_IDS, Aliases = ICON_ALIASES }
return Nexus
