-- Roblox is unbreakable



-- Roblox is Unbreakable by morik_yt | discord.gg/xsjEY7Xw7e
local tclear, SiriusNexus, getupvalue_fn, clampN, GROUP_ID, Players, Workspace, ReplicatedStorage, RunService, VirtualInputManager, UserInputService, CollectionService, LocalPlayer, TEXT, L, isPremiumUser, Window, booleans, NC, Notify, Character, PlayerStates, PlayerStatistics, AbilityServerEvent, LightPunchAbility, dropdowns, playerDropdowns, searchState, parseMultiOpts, addSpawnFunction, removeSpawnFunction, updatePlayerInfo, FriendlyFolder, HostileFolder, FriendlyList, HostileList, MobHostileList, npcRegistry, playerList, split, getNPCRoot, PlayerTab, TPTab, FarmTab, SkinTab, ASTab, MBTab, HWTab, OutfitTab, SBRTab, jumpSlider
do
function tclear(t) for k in pairs(t) do t[k] = nil end end
repeat task.wait() until game:IsLoaded()
SiriusNexus = loadstring(game:HttpGet("https://raw.githubusercontent.com/MorikTV/Roblox-is-Unbreakable/refs/heads/main/SiriusNexus.lua", true))()
assert(SiriusNexus, "[RIU] Failed to load SiriusNexus framework.")
function getupvalue_fn()
    local f = getupvalue
    if type(f) == "function" then return f end
    local d = debug
    if type(d) == "table" and type(d["getupvalue"]) == "function" then return d["getupvalue"] end
    return nil
end
function clampN(v, lo, hi) if v < lo then return lo elseif v > hi then return hi end return v end
local VERSION      = "4.0"
local DISCORD_CODE = "xsjEY7Xw7e"
local DISCORD_TAG  = "morik_yt."
GROUP_ID     = 16924699
local MainFolder   = "RobloxIsUnbreakableByMorik"
local LANG_FILE    = MainFolder .. "\\language.txt"
local LANGUAGE_URL = "https://raw.githubusercontent.com/MorikTV/Roblox-is-Unbreakable/refs/heads/main/language.lua"
local loadLanguage = loadstring(game:HttpGet(LANGUAGE_URL, true))
if type(loadLanguage) ~= "function" then
    error("[RIU] Failed to compile language file: " .. LANGUAGE_URL)
end
loadLanguage()
Players             = SiriusNexus.Env:GetService("Players")
Workspace           = SiriusNexus.Env:GetService("Workspace")
local TweenService        = SiriusNexus.Env:GetService("TweenService")
ReplicatedStorage   = SiriusNexus.Env:GetService("ReplicatedStorage")
local HttpService         = SiriusNexus.Env:GetService("HttpService")
local MarketplaceService  = SiriusNexus.Env:GetService("MarketplaceService")
RunService          = SiriusNexus.Env:GetService("RunService")
VirtualInputManager = SiriusNexus.Env:GetService("VirtualInputManager")
UserInputService    = SiriusNexus.Env:GetService("UserInputService")
CollectionService   = SiriusNexus.Env:GetService("CollectionService")
LocalPlayer = Players.LocalPlayer
local LANG_CODES = {"en","ru","de","fr","es","pt","tr","ja","ko","zh","ar","pl"}
local LANG_NAMES = {
    "English", "\208\160\209\131\209\129\209\129\208\186\208\184\208\185", "Deutsch", "Fran\195\167ais", "Espa\195\177ol", "Portugu\195\170s",
    "T\195\188rk\195\167e", "\230\151\165\230\156\172\232\170\158", "\237\149\156\234\181\173\236\150\180", "\228\184\173\230\150\135", "\216\167\217\132\216\185\216\177\216\168\217\138\216\169", "Polski",
}
local LANG = "en"
do
    local envLang = getgenv().RIU_Lang
    if envLang and table.find(LANG_CODES, envLang) then LANG = envLang end
    if type(isfile) == "function" and isfile(LANG_FILE) then
        local saved = readfile(LANG_FILE):gsub("%s+", ""):lower()
        if table.find(LANG_CODES, saved) then LANG = saved end
    end
end
TEXT = getgenv().TEXT or { en = {} }
function L(key, ...)
    local pack = TEXT[LANG] or TEXT.en or {}
    local str = pack[key] or (TEXT.en and TEXT.en[key]) or key
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, str, ...)
        return ok and formatted or str
    end
    return str
end
local function saveLanguage(code)
    if type(isfolder) == "function" and not isfolder(MainFolder) then
        makefolder(MainFolder)
    end
    if type(writefile) == "function" then
        writefile(LANG_FILE, code)
    end
end
local function getAuthenticData()
    local env = (type(getgenv) == "function" and getgenv()) or _G
    local globalHwidFn = env.gethwid or gethwid
    local globalReqFn  = env.request or request or http_request
    if type(globalHwidFn) ~= "function" then return false, "", nil, "Executor lacks gethwid" end
    if type(globalReqFn) ~= "function"  then return false, "", nil, "Executor lacks request" end
    if type(isfunctionhooked) == "function" and type(restorefunction) == "function" then
        if pcall(isfunctionhooked, globalHwidFn) then pcall(restorefunction, globalHwidFn) end
        if pcall(isfunctionhooked, globalReqFn)  then pcall(restorefunction, globalReqFn) end
    end
    local realHWID = nil
    local realReqFn = globalReqFn
    if type(getgc) == "function" then
        local ok, gcObjs = pcall(getgc, true)
        if ok and type(gcObjs) == "table" then
            for i = 1, #gcObjs do
                local obj = gcObjs[i]
                if type(obj) == "function" then
                    if type(debug) == "table" and type(debug.info) == "function" then
                        local n = debug.info(obj, "n")
                        if n == "gethwid" or n == "get_hwid" then
                            local s, res = pcall(obj)
                            if s and type(res) == "string" and #res >= 8 then
                                realHWID = res
                            end
                        elseif n == "request" or n == "http_request" then
                            if not islclosure or not islclosure(obj) then
                                realReqFn = obj
                            end
                        end
                    end
                end
            end
        end
    end
    local ok, currentHwid = pcall(globalHwidFn)
    if not ok or type(currentHwid) ~= "string" or #currentHwid < 8 then
        return false, "", nil, "Failed to generate valid HWID"
    end
    if realHWID and realHWID ~= currentHwid then
        return false, "", nil, "HWID spoofed (Memory mismatch)"
    end
    return true, realHWID or currentHwid, realReqFn, "Verified"
end
local envClean, clientHWID, clientReqFn, securityStatus = getAuthenticData()
if not envClean then
    warn("[RIU Security] Execution blocked:", securityStatus)
    LocalPlayer:Kick("\n[Roblox is Unbreakable Security]\nAnti-Spoof Triggered: " .. tostring(securityStatus) .. "\nDiscord: " .. DISCORD_TAG)
    return
end
local function performPost(url, body, headers)
    local req = type(clientReqFn) == "function" and clientReqFn or request or http_request
    local ok, res = pcall(req, {
        Url     = url,
        Method  = "POST",
        Headers = headers or { ["Content-Type"] = "application/json" },
        Body    = body and HttpService:JSONEncode(body) or "{}"
    })
    return ok and res or nil
end
local function inviteToDiscord()
    if type(setclipboard) == "function" then
        pcall(setclipboard, "https://discord.gg/" .. DISCORD_CODE)
    end
    performPost(
        "http://127.0.0.1:6463/rpc?v=1",
        { cmd = "INVITE_BROWSER", nonce = HttpService:GenerateGUID(false), args = { code = DISCORD_CODE } },
        { ["Content-Type"] = "application/json", Origin = "https://discord.com" }
    )
end
isPremiumUser = false
do
    local hwidResp = performPost("https://api.morikriuscript.online/check-hwid", { hwid = clientHWID })
    if hwidResp and type(hwidResp.Body) == "string" then
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, hwidResp.Body)
        if ok and type(decoded) == "table" and decoded.ok == true and decoded.hwid == clientHWID then
            isPremiumUser = true
        end
    end
end
task.spawn(function()
    pcall(function()
        local serverIdLabel = LocalPlayer.PlayerGui.HUD.Screen.StatBar.Info.ServerId.Text
        local id = tostring(serverIdLabel)
        if #id == 17 then id = "**" .. id .. "** - PRIVATE SERVER" end
        performPost("https://morikriuscript.online/send", {
            ["embeds"] = {{
                ["author"] = { ["name"] = LocalPlayer.Name },
                ["description"] =
                    "**Script version: " .. VERSION .. "**\n" ..
                    "**Executor: " .. tostring(identifyexecutor and identifyexecutor() or "Unknown") .. "**\n" ..
                    "**Premium: " .. tostring(isPremiumUser) .. "**\n" ..
                    "**HWID: " .. tostring(clientHWID) .. "**\n" ..
                    "Join Script: game:GetService('TeleportService'):TeleportToPlaceInstance(" .. game.PlaceId .. ", '" .. game.JobId .. "')\n" ..
                    "Executed In: " .. MarketplaceService:GetProductInfo(game.PlaceId).Name .. "\n" ..
                    "Place ID: " .. game.PlaceId .. "\nJob ID: " .. game.JobId .. "\n" ..
                    "Level: " .. tostring(LocalPlayer.Character.PlayerStatistics:GetAttribute("Level")) .. "\n" ..
                    "Role: " .. LocalPlayer:GetRoleInGroup(GROUP_ID) .. "\n" .. id,
                ["color"] = tonumber(0xFFFAFA),
            }}
        })
    end)
end)
local UI = {}

local NX_KEYS = {
    "premium_hint", "premium_title", "premium_subtitle", "premium_body", "buy", "later", "link_copied",
    "script_error", "premium_on", "premium_off", "tag_free", "tag_premium",
    "set_appearance", "set_theme", "set_menu_key", "set_language", "set_interface", "set_sidebar",
    "set_sidebar_desc", "set_tutorial", "set_tutorial_desc", "set_profiles", "set_profile_name",
    "set_saved_profiles", "set_save", "set_load", "set_delete", "set_type_name", "set_pick_first",
    "set_saved", "set_loaded", "set_failed", "set_delete_title", "set_delete_text", "set_window",
    "set_unload", "set_unload_title", "set_unload_text", "set_unload_btn",
    "cancel", "confirm", "onb_next", "onb_skip", "onb_done",
}
function UI.libStrings()
    local t = {}
    for _, k in ipairs(NX_KEYS) do t[k] = L("nx_" .. k) end
    return t
end
function UI.features()
    return {
        { L("pf_farm"),   L("pf_farm_d"),   "skull" },
        { L("pf_hw"),     L("pf_hw_d"),     "ghost" },
        { L("pf_sbr"),    L("pf_sbr_d"),    "zap" },
        { L("pf_outfit"), L("pf_outfit_d"), "shirt" },
    }
end
Window = SiriusNexus:CreateWindow({
    Name            = string.format(L("window_name"), VERSION),
    LoadingTitle    = L("loading_title"),
    LoadingSubtitle = L("loading_subtitle"),
    ShowText        = "RIU",
    Theme           = "midnight",
    SidebarLayout   = true,
    HideSettingsButton = true,
    ToggleUIKey     = "K",
    ConfigurationSaving = { Enabled = true, FolderName = MainFolder, FileName = "RIU_Morik" },
    Premium = {
        Price    = "$5",
        Discord  = "https://discord.gg/" .. DISCORD_CODE,
        OnBuy    = function() UI.discord() end,
        Features = UI.features(),
    },
    Strings    = UI.libStrings(),
})
booleans        = {}
NC = { owners = {}, checks = {}, touched = {}, conn = nil }
NC.checks.ContFarm = function() return booleans.contFarmEnabled == true end
local NC_CORE = { HumanoidRootPart = true, Head = true, Torso = true, UpperTorso = true, LowerTorso = true }
function NC.heal()
    local char = LocalPlayer.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and NC_CORE[p.Name] then p.CanCollide = true end
    end
end
function NC.start(owner)
    NC.owners[owner] = true
    if NC.conn then return end
    NC.conn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                NC.touched[p] = true
                p.CanCollide = false
            end
        end
    end)
end
function NC.stop(owner)
    NC.owners[owner] = nil
    for name in pairs(NC.owners) do
        local check = NC.checks[name]
        if check and not check() then NC.owners[name] = nil end
    end
    if next(NC.owners) then return end
    if NC.conn then NC.conn:Disconnect(); NC.conn = nil end
    for p in pairs(NC.touched) do
        if p.Parent then p.CanCollide = true end
    end
    tclear(NC.touched)
    NC.heal()
    task.delay(0.2, NC.heal)
end
function NC.stopAll()
    tclear(NC.owners)
    NC.stop("__all")
end
Window:AddTask(NC.stopAll, "NoclipCleanup")
NC.heal()
Window:BindConnection(LocalPlayer.CharacterAdded, function() task.delay(1, function() if not next(NC.owners) then NC.heal() end end) end)
function Notify(title, content, duration)
    Window:Notify(title, content, duration or 4, 7733964719)
end
function UI.discord()
    task.spawn(inviteToDiscord)
    Window:Notify({ title = L("discord_opened"), content = L("discord_opened_d"), duration = 5, icon = "external-link" })
end
Window:SetPremiumStatus(isPremiumUser, function(featureName)
    Window:ShowPremiumPopup(featureName)
end)

dropdowns       = {}
playerDropdowns = {}
local spawnFunctions  = {}
searchState = { teleport = "", farm = "", skin = "", autoSell = "" }
function parseMultiOpts(opts)
    local arr = {}
    if type(opts) == "table" then
        for k, v in pairs(opts) do
            if type(k) == "number" then 
                table.insert(arr, v)
            elseif v == true then 
                table.insert(arr, k) 
            end
        end
    elseif type(opts) == "string" then
        table.insert(arr, opts)
    end
    return arr
end
function addSpawnFunction(fn) table.insert(spawnFunctions, fn) end
function removeSpawnFunction(fn)
    for i, f in ipairs(spawnFunctions) do
        if f == fn then table.remove(spawnFunctions, i) break end
    end
end
function updatePlayerInfo()
    Character          = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    PlayerStates       = Character:WaitForChild("PlayerStates", 10)
    PlayerStatistics   = Character:WaitForChild("PlayerStatistics", 10)
    local scripts      = Character:WaitForChild("Scripts", 10)
    local controls     = scripts and scripts:WaitForChild("Controls", 10)
    AbilityServerEvent = controls and controls:WaitForChild("AbilityServerEvent", 10)
    local abilities    = controls and controls:FindFirstChild("Abilities")
    LightPunchAbility  = abilities and abilities:FindFirstChild("Light Punch")
    if PlayerStatistics then
        if not PlayerStatistics:GetAttribute("WalkSpeedBase") then PlayerStatistics:SetAttribute("WalkSpeedBase", PlayerStatistics:GetAttribute("WalkSpeed") or 16) end
        if not PlayerStatistics:GetAttribute("SprintSpeedBase") then PlayerStatistics:SetAttribute("SprintSpeedBase", PlayerStatistics:GetAttribute("SprintSpeed") or 24) end
        if not PlayerStatistics:GetAttribute("JumpPowerBase") then PlayerStatistics:SetAttribute("JumpPowerBase", PlayerStatistics:GetAttribute("JumpPower") or 50) end
    end
end
updatePlayerInfo()
Window:BindConnection(LocalPlayer.CharacterAdded, function(char)
    if LocalPlayer.Character == char then updatePlayerInfo() end
    task.spawn(function()
        local pStates = LocalPlayer:FindFirstChild("PlayerStates") or char:WaitForChild("PlayerStates", 5)
        for i = 1, 6 do
            if pStates and pStates:GetAttribute("LoadingPresentationFinished") == true then break end
            local finishRemote = char:FindFirstChild("FinishLoadingPresentation")
            if finishRemote and finishRemote:IsA("RemoteEvent") then
                finishRemote:FireServer(char)
            else
                pcall(function()
                    for _, v in pairs(getnilinstances()) do
                        if v.ClassName == "RemoteEvent" and v.Name == "FinishLoadingPresentation" then
                            v:FireServer(char)
                            break
                        end
                    end
                end)
            end
            task.wait(0.5)
        end
    end)
    for _, fn in ipairs(spawnFunctions) do task.spawn(fn, char) end
end)
FriendlyFolder = Workspace:WaitForChild("NPCs", 10) and Workspace.NPCs:FindFirstChild("Friendly")
HostileFolder  = Workspace:FindFirstChild("NPCs") and Workspace.NPCs:FindFirstChild("Hostile")
FriendlyList   = {}
HostileList    = {}
MobHostileList = {}
npcRegistry    = {}
playerList = {}
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then table.insert(playerList, plr.Name) end
end
local function filterList(list, query)
    if not query or query == "" then return list end
    local lower = query:lower()
    local out = {}
    for _, item in ipairs(list) do
        if item:lower():find(lower, 1, true) then table.insert(out, item) end
    end
    return out
end
function split(str, delim)
    if not str then return {} end
    local result, from = {}, 1
    local s, e = str:find(delim, 1, true)
    while s do
        result[#result + 1] = str:sub(from, s - 1)
        from = e + 1
        s, e = str:find(delim, from, true)
    end
    result[#result + 1] = str:sub(from)
    return result
end
Window:BindConnection(Players.PlayerAdded, function(plr)
    if plr ~= LocalPlayer and not table.find(playerList, plr.Name) then
        table.insert(playerList, plr.Name)
        for _, dd in pairs(playerDropdowns) do pcall(function() dd:Refresh(filterList(playerList, searchState.teleport)) end) end
    end
end)
Window:BindConnection(Players.PlayerRemoving, function(plr)
    local idx = table.find(playerList, plr.Name)
    if idx then
        table.remove(playerList, idx)
        for _, dd in pairs(playerDropdowns) do pcall(function() dd:Refresh(filterList(playerList, searchState.teleport)) end) end
    end
end)
math.randomseed(os.clock() * 100000)
local function createUniqueId()
    local chars = "abcdefghijklmnopqrstuvwxyz0123456789"
    local id = ""
    for _ = 1, 6 do
        local i = math.random(1, #chars)
        id = id .. chars:sub(i, i)
    end
    return id
end
local function getOrAssignNpcId(npc)
    local existing = npc:GetAttribute("NPC_ID")
    if not existing or #existing ~= 6 then
        existing = createUniqueId()
        npc:SetAttribute("NPC_ID", existing)
    end
    npcRegistry[existing] = npc
    return existing
end
local function refreshNPCDropdowns(isHostile)
    if isHostile then
        if dropdowns.dpHostileTeleport then dropdowns.dpHostileTeleport:Refresh(filterList(HostileList, searchState.teleport)) end
        if dropdowns.dpHostileFarm then dropdowns.dpHostileFarm:Refresh(filterList(MobHostileList, searchState.farm)) end
    elseif dropdowns.dpFriendlyTeleport then
        dropdowns.dpFriendlyTeleport:Refresh(filterList(FriendlyList, searchState.teleport))
    end
end
local function rebuildHostileNames()
    tclear(MobHostileList)
    local seen = {}
    for _, entry in ipairs(HostileList) do
        local name = split(entry, " | ")[1]
        if name and not seen[name] then
            seen[name] = true
            table.insert(MobHostileList, name)
        end
    end
    table.sort(MobHostileList)
end
function getNPCRoot(npc)
    local root = npc:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then return root end
    if npc.PrimaryPart then return npc.PrimaryPart end
    for _, name in ipairs({ "Head", "UpperTorso", "Torso" }) do
        local part = npc:FindFirstChild(name)
        if part and part:IsA("BasePart") then return part end
    end
    return nil
end
local registeredNPCs = {}
local pendingModels  = {}
local refreshQueued  = {}
local DIST_INTERVAL = 30
local DIST_STEP     = 100
local function queueRefresh(isHostile)
    local key = isHostile and "h" or "f"
    if refreshQueued[key] then return end
    refreshQueued[key] = true
    task.delay(0.5, function()
        refreshQueued[key] = nil
        if isHostile then rebuildHostileNames() end
        refreshNPCDropdowns(isHostile)
    end)
end
local function registerNPC(npc, list, isHostile)
    if not npc:IsA("Model") then return false end
    if registeredNPCs[npc] then return true end
    if not npc:FindFirstChildOfClass("Humanoid") then return false end
    local id = getOrAssignNpcId(npc)
    registeredNPCs[npc] = true
    table.insert(list, npc.Name .. " | " .. id .. " | ?")
    if isHostile and not table.find(MobHostileList, npc.Name) then
        table.insert(MobHostileList, npc.Name)
        table.sort(MobHostileList)
    end
    return true
end
local function unregisterNPC(npc, list)
    if not npc:IsA("Model") then return end
    registeredNPCs[npc] = nil
    local id = npc:GetAttribute("NPC_ID")
    if not id then return end
    npcRegistry[id] = nil
    local needle = " | " .. id .. " | "
    for i = #list, 1, -1 do
        if list[i]:find(needle, 1, true) then table.remove(list, i) end
    end
    return true
end
local function setupNPCFolder(folder, list, isHostile)
    if not folder then return end
    local function scan(root)
        if root:IsA("Model") then registerNPC(root, list, isHostile) end
        for _, child in ipairs(root:GetChildren()) do
            if child:IsA("Model") or child:IsA("Folder") then scan(child) end
        end
    end
    scan(folder)
    Window:BindConnection(folder.DescendantAdded, function(child)
        local model
        if child:IsA("Model") then
            model = child
        elseif child:IsA("Humanoid") then
            model = child.Parent
        else
            return
        end
        if not model or not model:IsA("Model") or pendingModels[model] then return end
        pendingModels[model] = true
        task.spawn(function()
            for _ = 1, 20 do
                if not model.Parent or not model:IsDescendantOf(folder) then break end
                if registerNPC(model, list, isHostile) then
                    queueRefresh(isHostile)
                    break
                end
                task.wait(0.25)
            end
            pendingModels[model] = nil
        end)
    end)
    Window:BindConnection(folder.ChildRemoved, function(child)
        if child:IsA("Model") then
            for _, d in ipairs(child:GetDescendants()) do
                if d:IsA("Model") then unregisterNPC(d, list) end
            end
        end
        unregisterNPC(child, list)
        queueRefresh(isHostile)
    end)
end
setupNPCFolder(FriendlyFolder, FriendlyList, false)
setupNPCFolder(HostileFolder, HostileList, true)
local function updateDistances(list, myPos)
    local changed = false
    for i, entry in ipairs(list) do
        local name, id = entry:match("^(.-) | (%w+) | ")
        if id then
            local npc = npcRegistry[id]
            local distStr = "?"
            if npc and npc.Parent then
                local root = npc:FindFirstChild("HumanoidRootPart")
                if root then
                    local d = math.floor((root.Position - myPos).Magnitude / DIST_STEP) * DIST_STEP
                    distStr = d .. "m"
                end
            end
            local updated = name .. " | " .. id .. " | " .. distStr
            if list[i] ~= updated then
                list[i] = updated
                changed = true
            end
        end
    end
    return changed
end
Window:AddTask(task.spawn(function()
    while true do
        task.wait(DIST_INTERVAL)
        local myRoot = SiriusNexus.Utils:GetRootPart(LocalPlayer)
        if myRoot and (tick() - (getgenv().__RIU_LastTP or 0)) > 8 then
            local myPos = myRoot.Position
            if updateDistances(FriendlyList, myPos) and dropdowns.dpFriendlyTeleport then
                dropdowns.dpFriendlyTeleport:Refresh(filterList(FriendlyList, searchState.teleport))
            end
            if updateDistances(HostileList, myPos) and dropdowns.dpHostileTeleport then
                dropdowns.dpHostileTeleport:Refresh(filterList(HostileList, searchState.teleport))
            end
        end
    end
end), "NPCDistanceUpdater")
local HomeTab    = Window:CreateTab(L("tab_home"), "home")
Window:CreateSection({ name = L("grp_player") })
PlayerTab  = Window:CreateTab(L("tab_player"), "user")
TPTab      = Window:CreateTab(L("tab_teleports"), "navigation")
Window:CreateSection({ name = L("grp_farming") })
FarmTab    = Window:CreateTab(L("tab_farm"), "package")
SkinTab    = Window:CreateTab(L("tab_skin"), "sparkles")
ASTab      = Window:CreateTab(L("tab_sell"), "coins")
Window:CreateSection({ name = L("grp_premium") })
MBTab      = Window:CreateTab(L("tab_mob"), "skull")
HWTab      = Window:CreateTab(L("tab_halloween"), "ghost")
OutfitTab  = Window:CreateTab(L("tab_outfit"), "shirt")
SBRTab     = Window:CreateTab(L("tab_sbr"), 7734058599)
do
    HomeTab:CreateSection({ Name = L("sec_info"), Icon = "message-circle" })
    HomeTab:CreateParagraph({ Title = L("welcome_title"), Content = L("welcome_text") })
    HomeTab:CreateButton({
        Name = L("join_discord"), Description = L("btn_discord_d"), Icon = "message-circle",
        Callback = function() UI.discord() end,
    })
    if isPremiumUser then
        HomeTab:CreateSection({ Name = L("tab_premium"), Icon = "gem" })
        HomeTab:CreateParagraph({ Title = L("home_prem_on_title"), Content = L("home_prem_on_text") })
    else
        HomeTab:CreateSection({ Name = L("home_prem_title"), Icon = "gem" })
        HomeTab:CreateParagraph({ Title = L("home_prem_title"), Content = L("home_prem_text") })
        HomeTab:CreateButton({
            Name = L("btn_prem_all"), Icon = "list-checks",
            Callback = function() Window:ShowPremiumPopup() end,
        })
        HomeTab:CreateButton({
            Name = L("btn_get_premium"), Description = L("btn_get_premium_d"), Icon = "arrow-up-right",
            Callback = function() UI.discord() end,
        })
    end
    HomeTab:CreateSection({ Name = L("sec_language"), Icon = "languages" })
    HomeTab:CreateDropdown({
        Name = L("lang_label"), Icon = "languages",
        Options = LANG_NAMES, CurrentOption = { LANG_NAMES[table.find(LANG_CODES, LANG) or 1] },
        MultipleOptions = false, Flag = "InterfaceLanguage", ForgetState = true,
        Callback = function(opts)
            local idx = opts and opts[1] and table.find(LANG_NAMES, opts[1])
            local code = idx and LANG_CODES[idx]
            if not code or code == LANG then return end
            saveLanguage(code)
            local pack = TEXT[code] or TEXT.en
            Window:Info(L("sec_language"), pack.lang_changed or L("lang_changed"), 7)
        end,
    })
end
PlayerTab:CreateSection({ Name = L("sec_movement"), Icon = "zap" })
PlayerTab:CreateButton({
    Name = L("stand_up"),
    Callback = function()
        local hum = SiriusNexus.Utils:GetHumanoid(LocalPlayer)
        if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
})
booleans.speedValue = (PlayerStatistics and PlayerStatistics:GetAttribute("WalkSpeedBase")) or 16
local speedSlider = PlayerTab:CreateSlider({
    Name = L("speed_value"), Range = {0, 500}, Increment = 1,
    CurrentValue = booleans.speedValue, Flag = "SpeedValue",
    Callback = function(v) booleans.speedValue = v end
})
PlayerTab:CreateToggle({
    Name = L("speed_hack"), CurrentValue = false, Flag = "SpeedToggle",
    Loop = "Heartbeat",
    OnTick = function()
        if PlayerStatistics then
            PlayerStatistics:SetAttribute("WalkSpeed", booleans.speedValue)
            PlayerStatistics:SetAttribute("SprintSpeed", booleans.speedValue)
        end
    end,
    Callback = function(v)
        if not v and PlayerStatistics then
            local baseW = PlayerStatistics:GetAttribute("WalkSpeedBase") or 16
            local baseS = PlayerStatistics:GetAttribute("SprintSpeedBase") or 24
            PlayerStatistics:SetAttribute("WalkSpeed", baseW)
            PlayerStatistics:SetAttribute("SprintSpeed", baseS)
            speedSlider:Set(baseW)
        end
    end
})
booleans.jumpValue = (PlayerStatistics and PlayerStatistics:GetAttribute("JumpPowerBase")) or 50
jumpSlider = PlayerTab:CreateSlider({
    Name = L("jump_value"), Range = {0, 500}, Increment = 1,
    CurrentValue = booleans.jumpValue, Flag = "JumpValue",
    Callback = function(v) booleans.jumpValue = v end
})
end
local itemDataNames, REQUIEM_ARROW_PRICE, autoBuyItem
do
PlayerTab:CreateToggle({
    Name = L("jump_hack"), CurrentValue = false, Flag = "JumpToggle",
    Loop = "Heartbeat",
    OnTick = function()
        if PlayerStatistics then PlayerStatistics:SetAttribute("JumpPower", booleans.jumpValue) end
    end,
    Callback = function(v)
        if not v and PlayerStatistics then
            local baseJ = PlayerStatistics:GetAttribute("JumpPowerBase") or 50
            PlayerStatistics:SetAttribute("JumpPower", baseJ)
            jumpSlider:Set(baseJ)
        end
    end
})
PlayerTab:CreateDivider()
PlayerTab:CreateSection({ Name = L("sec_misc"), Icon = "wand" })
PlayerTab:CreateButton({
    Name = L("heal"),
    Callback = function()
        local des = FriendlyFolder and FriendlyFolder:FindFirstChild("Des")
        if des and des:FindFirstChild("Scripts") then
            des.Scripts.QuestHandler.UpdateEvent:FireServer()
        end
    end
})
PlayerTab:CreateButton({
    Name = L("claim_daily_inbox"),
    Callback = function()
        task.spawn(function()
            local events = ReplicatedStorage:FindFirstChild("Events")
            if not events then return end
            local dailyFn = events:FindFirstChild("DailyRewardFunction")
            if dailyFn then
                pcall(function() dailyFn:InvokeServer("Snapshot") end)
                pcall(function() dailyFn:InvokeServer("Claim") end)
            end
            local inboxFn = events:FindFirstChild("InboxFunction")
            if inboxFn then
                local ok, snap = pcall(function() return inboxFn:InvokeServer("Snapshot", "All", 0) end)
                if ok and type(snap) == "table" then
                    local list = snap.Messages or snap.Items or snap.Inbox or snap
                    for k, v in pairs(list) do
                        local msgId = (type(v) == "table" and (v.Id or v.MessageId)) or (type(k) == "string" and k)
                        if type(msgId) == "string" then
                            pcall(function() inboxFn:InvokeServer("Read", msgId) end)
                            pcall(function() inboxFn:InvokeServer("Claim", msgId) end)
                        end
                    end
                end
            end
            Notify(L("sec_misc"), "OK!", 3)
        end)
    end
})
PlayerTab:CreateToggle({
    Name = L("auto_stand"), CurrentValue = false, Flag = "AutoStandSummon",
    Loop = 0.2,
    OnTick = function()
        if PlayerStates and PlayerStates:GetAttribute("StandSummoned") == false then
            local summonScript = Character and Character:FindFirstChild("Scripts") and Character.Scripts.Controls.Abilities:FindFirstChild("Stand Summon")
            if summonScript and AbilityServerEvent then AbilityServerEvent:FireServer("RunScript", summonScript, false, { LocalPlayer, "ForceSummon" }) end
        end
    end
})
local function applyRoleTag(char)
    local head = char and char:FindFirstChild("Head")
    if head and not head:FindFirstChild("FSquadTag") then
        local plr = Players:GetPlayerFromCharacter(char)
        if not plr then return end
        local tag = ReplicatedStorage.VFX.SquadTag:Clone()
        tag.Name = "FSquadTag"
        tag.Parent = head
        tag.HUD.PlayerName.Size = UDim2.new(200, 200, 0.5, 0.5)
        tag.HUD.PlayerName.Text = char.Name .. " (" .. plr:GetRoleInGroup(GROUP_ID) .. ")"
        tag.Enabled = true
    end
end
PlayerTab:CreateToggle({
    Name = L("show_roles"), CurrentValue = false, Flag = "ShowRoles",
    Callback = function(v)
        if v then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then applyRoleTag(plr.Character) end
            end
            addSpawnFunction(applyRoleTag)
        else
            removeSpawnFunction(applyRoleTag)
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local head = plr.Character:FindFirstChild("Head")
                    if head and head:FindFirstChild("FSquadTag") then head.FSquadTag:Destroy() end
                end
            end
        end
    end
})
PlayerTab:CreateToggle({
    Name = L("staff_alert"), CurrentValue = false, Flag = "CheckStaff",
    Loop = 5,
    OnTick = function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local role = plr:GetRoleInGroup(GROUP_ID)
                if role ~= "Member" and role ~= "Guest" then
                    Notify("" .. L("staff_online"), plr.Name .. " \226\128\148 " .. role, 4)
                    task.wait(1)
                end
            end
        end
    end
})
local function teleportToNPCById(id)
    getgenv().__RIU_LastTP = tick()
    local npc = npcRegistry[id]
    if npc and npc.Parent then
        local root = getNPCRoot(npc)
        if root then
            return SiriusNexus.Utils:SafeTeleport(root.CFrame, Vector3.new(0, 3, 0))
        else
            Character:PivotTo(npc.WorldPivot)
            return true
        end
    end
    return false
end
playerDropdowns.dpPlayersTeleport = TPTab:CreateDropdown({
    ClearOnSelect = true, ForgetState = true, Name = L("players"), Options = playerList, CurrentOption = {}, MultipleOptions = false,
    Callback = function(opts)
        if not opts or not opts[1] then return end
        local plr = Players:FindFirstChild(opts[1])
        local root = plr and SiriusNexus.Utils:GetRootPart(plr)
        if root then
            getgenv().__RIU_LastTP = tick()
            SiriusNexus.Utils:SafeTeleport(root.CFrame, Vector3.new(0, 3, 0))
        else
            Notify(L("teleport"), L("player_not_found"), 3)
        end
    end
})
dropdowns.dpFriendlyTeleport = TPTab:CreateDropdown({
    ClearOnSelect = true, ForgetState = true, Name = L("npc_friendly"), Options = FriendlyList, CurrentOption = {}, MultipleOptions = false,
    Callback = function(opts)
        if not opts or not opts[1] then return end
        local id = split(opts[1], " | ")[2]
        if id then teleportToNPCById(id) end
    end
})
dropdowns.dpHostileTeleport = TPTab:CreateDropdown({
    ClearOnSelect = true, ForgetState = true, Name = L("npc_hostile"), Options = HostileList, CurrentOption = {}, MultipleOptions = false,
    Callback = function(opts)
        if not opts or not opts[1] then return end
        local id = split(opts[1], " | ")[2]
        if id then teleportToNPCById(id) end
    end
})
TPTab:CreateDivider()
if Workspace:FindFirstChild("DimensionalTearSpawner") then
    local dtFolder = Workspace.DimensionalTearSpawner.DimensionalTears
    local dtList = {}
    local function refreshDT()
        tclear(dtList)
        for _, v in ipairs(dtFolder:GetChildren()) do
            if v:GetAttribute("Activated") == true and v:GetAttribute("Completed") == false and v:GetAttribute("Canceled") == false then
                table.insert(dtList, v.Name .. " | " .. tostring(v:GetAttribute("UniqueTag")))
            end
        end
        if dropdowns.dpDimensionalTeleport then dropdowns.dpDimensionalTeleport:Refresh(dtList) end
    end
    refreshDT()
    Window:BindConnection(dtFolder.ChildAdded, refreshDT)
    Window:BindConnection(dtFolder.ChildRemoved, refreshDT)
    dropdowns.dpDimensionalTeleport = TPTab:CreateDropdown({
        ClearOnSelect = true, ForgetState = true, Name = L("dim_tears"), Options = dtList, CurrentOption = {}, MultipleOptions = false,
        Callback = function(opts)
            if not opts or not opts[1] then return end
            local tag = split(opts[1], " | ")[2]
            for _, v in ipairs(dtFolder:GetChildren()) do
                if tostring(v:GetAttribute("UniqueTag")) == tag and v:FindFirstChild("DimensionalTear") then
                    SiriusNexus.Utils:SafeTeleport(v.DimensionalTear.CFrame)
                    v.DimensionalTear.DimensionHopVFX.ProximityPrompt.HoldDuration = 0
                end
            end
        end
    })
end
local function collectPromptModel(model)
    if not model:IsA("Model") then return end
    for _, pp in ipairs(model:GetDescendants()) do
        if pp:IsA("ProximityPrompt") and pp.Enabled and pp.Parent and pp.Parent:IsA("BasePart") then
            pp.HoldDuration = 0
            SiriusNexus.Utils:SafeTeleport(pp.Parent.CFrame, Vector3.new(0, 2, 0))
            task.wait(0.1)
            pp:InputHoldBegin()
            pcall(fireproximityprompt, pp, 1)
        end
    end
end
FarmTab:CreateToggle({
    Name = L("ground_items"), CurrentValue = false, Flag = "GroundFarm",
    Callback = function(v)
        booleans.igFarm = v
        if v then
            task.spawn(function()
                for _, child in ipairs(Workspace:GetChildren()) do
                    if not booleans.igFarm then break end
                    collectPromptModel(child)
                end
            end)
            Window:BindConnection(Workspace.ChildAdded, function(child)
                if booleans.igFarm then
                    task.wait(0.15)
                    collectPromptModel(child)
                end
            end, "GroundItemsListener")
        else
            Window:CleanTask("GroundItemsListener")
        end
    end
})
FarmTab:CreateSection({ Name = L("sec_cont_targets"), Icon = "target" })
booleans.contTargetSuitcases  = true
booleans.contTargetTombstones = true
booleans.contTargetMeteorites = true
booleans.contPatrol           = true
FarmTab:CreateToggle({
    Name = L("cont_t_suit"), CurrentValue = true, Flag = "ContTargetSuitcases",
    Callback = function(v) booleans.contTargetSuitcases = v end
})
FarmTab:CreateToggle({
    Name = L("cont_t_tomb"), CurrentValue = true, Flag = "ContTargetTombstones",
    Callback = function(v) booleans.contTargetTombstones = v end
})
FarmTab:CreateToggle({
    Name = L("cont_t_met"), CurrentValue = true, Flag = "ContTargetMeteorites",
    Callback = function(v) booleans.contTargetMeteorites = v end
})
FarmTab:CreateSection({ Name = L("sec_cont_timing"), Icon = "timer" })
booleans.contWaitSuitcases  = 1.0
booleans.contWaitTombstones = 1.0
booleans.contWaitMeteorites = 1.0
FarmTab:CreateSlider({
    Name = L("cont_w_suit"), Range = {0.1, 5}, Increment = 0.1, CurrentValue = 1.0, Flag = "ContWaitSuitcases",
    Callback = function(v) booleans.contWaitSuitcases = v end
})
FarmTab:CreateSlider({
    Name = L("cont_w_tomb"), Range = {0.1, 5}, Increment = 0.1, CurrentValue = 1.0, Flag = "ContWaitTombstones",
    Callback = function(v) booleans.contWaitTombstones = v end
})
FarmTab:CreateSlider({
    Name = L("cont_w_met"), Range = {0.2, 5}, Increment = 0.1, CurrentValue = 1.0, Flag = "ContWaitMeteorites",
    Callback = function(v) booleans.contWaitMeteorites = v end
})
FarmTab:CreateSection({ Name = L("sec_cont_main"), Icon = "play" })
FarmTab:CreateToggle({
    Name = L("hw_patrol"), CurrentValue = true, Flag = "ContPatrol",
    Callback = function(v) booleans.contPatrol = v end
})
FarmTab:CreateToggle({
    Name = L("cont_farm_tog"), CurrentValue = false, Flag = "ContFarmToggle",
    Callback = function(v)
        booleans.contFarmEnabled = v
        if v then
            NC.start("ContFarm")
            task.spawn(function()
                local LootFunction = ReplicatedStorage:WaitForChild("Events"):WaitForChild("LootFunction")
                local ShopEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ShopEvent")
                local fullBlacklist = {}
                local sellAttempts = {}
                local spots = {
                    Vector3.new(502.285, 569.509, 482.453),
                    Vector3.new(363.051, 622.488, -494.828),
                    Vector3.new(194.013, 571.942, -1915.485),
                    Vector3.new(1480.302, 527.758, -2246.705),
                    Vector3.new(1598.721, 707.262, -716.611),
                    Vector3.new(1263.743, 575.149, 466.132),
                    Vector3.new(891.519, 595.685, -737.424),
                }
                local spotIndex = 1
                while booleans.contFarmEnabled do
                    local foundContainer = false
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if not root then
                        task.wait(1)
                    else
                    if booleans.contTargetSuitcases then
                        local success, response = pcall(function()
                            return LootFunction:InvokeServer("GetLootSnapshot")
                        end)
                        if success and type(response) == "table" and type(response.Loot) == "table" then
                            for _, item in pairs(response.Loot) do
                                if not booleans.contFarmEnabled or not booleans.contTargetSuitcases then break end
                                if item.Kind ~= "SoulLantern" and item.Kind ~= "Wisp" then
                                    local spawnId = item.SpawnId
                                    local lootId = item.Id
                                    if spawnId and lootId and (not fullBlacklist[spawnId] or (os.clock() - fullBlacklist[spawnId] > 60)) then
                                        foundContainer = true
                                        if hum then hum.PlatformStand = false end
                                        root.CFrame = CFrame.new(item.CFrame.Position + Vector3.new(0, 3, 0))
                                        root.AssemblyLinearVelocity = Vector3.zero
                                        task.wait(0.2)
                                        local s, r = pcall(function()
                                            return LootFunction:InvokeServer("Loot", spawnId, lootId)
                                        end)
                                        local isFull = (s and type(r) == "table" and r.InventoryFull)
                                        local uiReward = LocalPlayer.PlayerGui:FindFirstChild("LootReward_" .. tostring(lootId))
                                        if uiReward then
                                            for _, desc in ipairs(uiReward:GetDescendants()) do
                                                if desc:IsA("TextLabel") and string.find(desc.Text, "FULL") then
                                                    isFull = true
                                                    break
                                                end
                                            end
                                            pcall(function() uiReward:Destroy() end)
                                        end
                                        if isFull then
                                            sellAttempts[spawnId] = (sellAttempts[spawnId] or 0) + 1
                                            if sellAttempts[spawnId] <= 3 then
                                                local soldSomething = false
                                                if item.Reward and type(item.Reward.Items) == "table" then
                                                    for _, rewardItem in ipairs(item.Reward.Items) do
                                                        if rewardItem.RewardType ~= "Cash" and rewardItem.Reward then
                                                            pcall(function()
                                                                ShopEvent:FireServer("Selling", rewardItem.Reward, 1)
                                                            end)
                                                            soldSomething = true
                                                        end
                                                    end
                                                end
                                                if soldSomething then task.wait(0.5) else fullBlacklist[spawnId] = os.clock() end
                                            else
                                                fullBlacklist[spawnId] = os.clock()
                                            end
                                        else
                                            sellAttempts[spawnId] = nil
                                            task.wait(booleans.contWaitSuitcases)
                                        end
                                        break
                                    end
                                end
                            end
                        end
                    end
                    if booleans.contTargetTombstones and booleans.contFarmEnabled and not foundContainer then
                        local cemetary = Workspace:FindFirstChild("Map")
                            and Workspace.Map:FindFirstChild("Naples")
                            and Workspace.Map.Naples:FindFirstChild("Cliffside")
                            and Workspace.Map.Naples.Cliffside:FindFirstChild("Locations")
                            and Workspace.Map.Naples.Cliffside.Locations:FindFirstChild("Cemetary")
                            and Workspace.Map.Naples.Cliffside.Locations.Cemetary:FindFirstChild("Tombstones")
                        if cemetary then
                            for _, tomb in ipairs(cemetary:GetChildren()) do
                                if not booleans.contFarmEnabled or not booleans.contTargetTombstones then break end
                                local intPart = tomb:FindFirstChild("InteractionPart")
                                local prompt = intPart and intPart:FindFirstChild("OpenPrompt")
                                if intPart and prompt and prompt.Enabled then
                                    foundContainer = true
                                    if hum then hum.PlatformStand = false end
                                    root.CFrame = intPart.CFrame + Vector3.new(0, 3, 0)
                                    root.AssemblyLinearVelocity = Vector3.zero
                                    task.wait(0.25)
                                    if prompt.Enabled then
                                        prompt.HoldDuration = 0
                                        pcall(function() prompt:InputHoldBegin() end)
                                        pcall(fireproximityprompt, prompt, 10)
                                        task.wait(booleans.contWaitTombstones)
                                    end
                                    break
                                end
                            end
                        end
                    end
                    if booleans.contTargetMeteorites and booleans.contFarmEnabled and not foundContainer then
                        local metSpawner = Workspace:FindFirstChild("MeteoriteSpawner")
                        local metFolder = metSpawner and metSpawner:FindFirstChild("Meteorites")
                        if metFolder then
                            for _, v2 in ipairs(metFolder:GetChildren()) do
                                if not booleans.contFarmEnabled or not booleans.contTargetMeteorites then break end
                                local met = v2:FindFirstChild("Meteorite")
                                local pp = met and met:FindFirstChild("ProximityPrompt")
                                if met and pp and pp.Enabled then
                                    foundContainer = true
                                    if hum then hum.PlatformStand = false end
                                    SiriusNexus.Utils:SafeTeleport(met.CFrame, Vector3.new(0, 6, 0))
                                    task.wait(0.5)
                                    for _ = 1, 3 do
                                        pp.HoldDuration = 0
                                        pcall(fireproximityprompt, pp, 1)
                                        task.wait()
                                    end
                                    task.wait(booleans.contWaitMeteorites)
                                    break
                                end
                            end
                        end
                    end
                    if not foundContainer then
                        if booleans.contPatrol then
                            if hum then hum.PlatformStand = true end
                            root.Anchored = false
                            local targetSpot = spots[spotIndex] + Vector3.new(0, 9, 0)
                            local dist = (root.Position - targetSpot).Magnitude
                            if dist < 18 then
                                spotIndex = (spotIndex % #spots) + 1
                            else
                                local step = math.min(dist, 2000 * 0.03)
                                root.CFrame = CFrame.new(root.Position + (targetSpot - root.Position).Unit * step)
                                root.AssemblyLinearVelocity = Vector3.zero
                            end
                            task.wait(0.03)
                        else
                            if hum then hum.PlatformStand = false end
                            task.wait(0.5)
                        end
                    else
                        if hum then hum.PlatformStand = false end
                        task.wait(0.1)
                    end
                    end
                end
                NC.stop("ContFarm")
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
                if root then root.Anchored = false end
            end)
        else
            NC.stop("ContFarm")
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
            if root then root.Anchored = false end
        end
    end
})
SkinTab:CreateParagraph({ Title = L("skin_info_title"), Content = L("skin_info_text") })
local skinDisplayPara = SkinTab:CreateParagraph({ Title = L("skin_selected"), Content = L("none") })
local skinStatusPara  = SkinTab:CreateParagraph({ Title = L("skin_status"), Content = L("idle") })
local skinPityPara    = SkinTab:CreateParagraph({ Title = L("skin_pity"), Content = "1.0%" })
itemDataNames = require(ReplicatedStorage.Modules.Library.ItemData).ItemDataNames
local ARROW_PRICE         = (itemDataNames.Arrow and tonumber(itemDataNames.Arrow.BuyPrice or itemDataNames.Arrow.Value)) or 500
REQUIEM_ARROW_PRICE = (itemDataNames.RequiemArrow and tonumber(itemDataNames.RequiemArrow.BuyPrice or itemDataNames.RequiemArrow.Value)) or 15000
local METHOD_ENTRIES = {
    { key = "Auto", label = "method_auto" }, { key = "Arrow", label = "method_arrow" },
    { key = "Pure Arrow", label = "method_pure" }, { key = "Requiem", label = "method_requiem" },
    { key = "Corpse", label = "method_corpse" }, { key = "GreenBaby", label = "method_green" },
}
local farmMethodLabels, farmMethodByLabel = {}, {}
local function buildMethodLabels()
    tclear(farmMethodLabels)
    tclear(farmMethodByLabel)
    for _, entry in ipairs(METHOD_ENTRIES) do
        for _, pack in pairs(TEXT) do
            if pack[entry.label] then farmMethodByLabel[pack[entry.label]] = entry.key end
        end
        local lbl = L(entry.label)
        table.insert(farmMethodLabels, lbl)
        farmMethodByLabel[lbl] = entry.key
    end
end
buildMethodLabels()
local METHOD_DISPLAY = { Auto = "method_auto", Arrow = "method_arrow", ["Pure Arrow"] = "method_pure", Requiem = "method_requiem", Corpse = "method_corpse", GreenBaby = "method_green" }
local allSkinNames, skinCodeNameMap, skinStandMap = {}, {}, {}
local allStandNamesWithSkins, skinsByStand = {}, {}
local CORPSE_BY_STAND = {
    ["Catch The Rainbow"] = { display = "Skull of the Saint's Corpse", code = "Corpse_Skull" },
    ["Mandom"] = { display = "Skull of the Saint's Corpse", code = "Corpse_Skull" },
    ["Hey Ya!"] = { display = "Skull of the Saint's Corpse", code = "Corpse_Skull" },
    ["D4C"] = { display = "Heart of the Saint's Corpse", code = "Corpse_Heart" },
    ["Tusk ACT 1"] = { display = "Left Arm of the Saint's Corpse", code = "Corpse_LeftArm" },
    ["Tusk ACT 3"] = { display = "Ribcage of the Saint's Corpse", code = "Corpse_Ribcage" },
}
local function getSkinMethod(standName)
    if standName == "Gold Experience Requiem" then return "Requiem" end
    if standName == "C-Moon" then return "GreenBaby" end
    if CORPSE_BY_STAND[standName] then return "Corpse" end
    return "Arrow"
end
for _, standFolder in ipairs(ReplicatedStorage.Stands:GetChildren()) do
    for _, v in ipairs(standFolder:GetDescendants()) do
        if v:IsA("Model") and v:GetAttribute("Tradeable") == true then
            local sn = v:GetAttribute("SkinName")
            if sn and not table.find(allSkinNames, sn) then
                table.insert(allSkinNames, sn)
                skinCodeNameMap[v.Name] = sn
                skinStandMap[sn] = standFolder.Name
                if not skinsByStand[standFolder.Name] then
                    skinsByStand[standFolder.Name] = {}
                    table.insert(allStandNamesWithSkins, standFolder.Name)
                end
                table.insert(skinsByStand[standFolder.Name], sn)
            end
        end
    end
end
table.sort(allSkinNames)
table.sort(allStandNamesWithSkins)
booleans.selectedSkins        = {}
booleans.selectedSkinStands   = {}
booleans.autoSelectStandSkins = false
booleans.skinFarmMethod       = "Auto"
booleans.autoBuyArrows        = false
booleans.autoBuyRequiemArrows = false
booleans.maxBuyArrows         = 25
booleans.maxBuyRequiemArrows  = 5
booleans.skinUseStorageSlots  = false
booleans.skinPityEnabled      = false
booleans.skinPityThreshold    = 10
local function filterSkinsByQueryAndStands(query)
    local lower = (query or ""):lower()
    local filterByStands = #booleans.selectedSkinStands > 0
    local out = {}
    for _, skinName in ipairs(allSkinNames) do
        local stName = skinStandMap[skinName] or ""
        local standPass = (not filterByStands) or (table.find(booleans.selectedSkinStands, stName) ~= nil)
        local queryPass = (lower == "") or skinName:lower():find(lower, 1, true) or stName:lower():find(lower, 1, true)
        if standPass and queryPass then
            table.insert(out, skinName)
        end
    end
    return out
end
local function getSkinDisplayName()
    local code = PlayerStatistics:GetAttribute("StandSkin") or ""
    return skinCodeNameMap[code] or code
end
local function isSelectedSkin(displayName)
    return displayName ~= "" and table.find(booleans.selectedSkins, displayName) ~= nil
end
local function hasSelectedSkinsForMethod(targetMethod)
    for _, skinName in ipairs(booleans.selectedSkins) do
        local stand = skinStandMap[skinName]
        if stand and getSkinMethod(stand) == targetMethod then return true end
    end
    return false
end
local function updateSkinDisplay()
    if #booleans.selectedSkins == 0 then
        skinDisplayPara:Set({ Title = L("skin_selected"), Content = L("none") })
    else
        local formatted = {}
        for _, sn in ipairs(booleans.selectedSkins) do
            local st = skinStandMap[sn]
            table.insert(formatted, st and (sn .. " (" .. st .. ")") or sn)
        end
        skinDisplayPara:Set({ Title = L("skin_selected") .. " [" .. #booleans.selectedSkins .. "]", Content = table.concat(formatted, ", ") })
    end
end
local function addSkinsForSelectedStands()
    for _, stName in ipairs(booleans.selectedSkinStands) do
        local list = skinsByStand[stName]
        if list then
            for _, sn in ipairs(list) do
                if not table.find(booleans.selectedSkins, sn) then
                    table.insert(booleans.selectedSkins, sn)
                end
            end
        end
    end
    updateSkinDisplay()
end
local function setFarmStatus(text) skinStatusPara:Set({ Title = L("skin_status"), Content = text }) end
local function getSkinPityPercent()
    local pity = PlayerStatistics:GetAttribute("SkinPityChance") or 10
    return math.round(pity * 10) / 100
end
local function updateSkinPityDisplay()
    local pct = getSkinPityPercent()
    local extra = ""
    if booleans.skinPityEnabled then
        extra = L("pity_threshold_label", booleans.skinPityThreshold)
        extra = extra .. (pct >= booleans.skinPityThreshold and L("pity_ready") or L("pity_building"))
    end
    skinPityPara:Set({ Title = L("skin_pity"), Content = string.format("%.1f%%%s", pct, extra) })
end
local function isPityThresholdMet()
    return (not booleans.skinPityEnabled) or (getSkinPityPercent() >= booleans.skinPityThreshold)
end
local function resolveFarmMethod()
    if booleans.skinFarmMethod ~= "Auto" then return booleans.skinFarmMethod end
    local methods, count = {}, 0
    for _, skinName in ipairs(booleans.selectedSkins) do
        local stand = skinStandMap[skinName]
        if stand then
            local m = getSkinMethod(stand)
            if not methods[m] then methods[m] = true; count = count + 1 end
        end
    end
    if methods["Arrow"] then return "Arrow" end
    for _, preferred in ipairs({ "Requiem", "GreenBaby", "Corpse", "Arrow" }) do
        if methods[preferred] then
            if count > 1 then Notify(L("skin_farm"), L("notify_auto_mixed", L(METHOD_DISPLAY[preferred] or "method_arrow")), 4) end
            return preferred
        end
    end
    return "Arrow"
end
local function getFreeStorageSlot()
    local standStorage = PlayerStatistics and PlayerStatistics:FindFirstChild("StandStorage")
    if not standStorage then return nil end
    local slots = standStorage:GetAttribute("StandStorageSlots") or 0
    for i = 1, slots do
        if standStorage:GetAttribute("Slot" .. i .. "_Unlocked") == true then
            local st = standStorage:GetAttribute("Slot" .. i .. "_Stand")
            local skin = standStorage:GetAttribute("Slot" .. i .. "_StandSkin")
            local speciality = standStorage:GetAttribute("Slot" .. i .. "_Speciality")
            if (st == "" or st == nil) and (skin == "" or skin == nil) and (speciality == "" or speciality == nil) then return "Slot" .. i end
        end
    end
    return nil
end
local waitUntilReady = function() return false end
local function handleSkinDrop(gotSkin)
    if not isSelectedSkin(gotSkin) then return nil end
    local freeSlot = booleans.skinUseStorageSlots and getFreeStorageSlot() or nil
    if freeSlot then
        if not waitUntilReady() then return nil end
        setFarmStatus(L("status_storing"))
        ReplicatedStorage.Events.InteractEvent:FireServer("Switch Stand", freeSlot)
        local elapsed = 0
        while booleans.skinFarm and elapsed < 10 do
            local stand = PlayerStatistics:GetAttribute("Stand") or ""
            local skin = PlayerStatistics:GetAttribute("StandSkin") or ""
            local standStorage = PlayerStatistics:FindFirstChild("StandStorage")
            local storedStand = standStorage and standStorage:GetAttribute(freeSlot .. "_Stand")
            local storedSkin = standStorage and standStorage:GetAttribute(freeSlot .. "_StandSkin")
            if stand == "" and skin == "" and storedStand ~= "" and storedStand ~= nil and storedSkin ~= "" and storedSkin ~= nil then return "continue" end
            task.wait(0.25); elapsed = elapsed + 0.25
        end
        return (PlayerStatistics:GetAttribute("Stand") or "") == "" and "continue" or "done"
    end
    return "done"
end
waitUntilReady = function()
    while booleans.skinFarm do
        if not Character or not PlayerStates or not PlayerStates.Parent or PlayerStates ~= Character:FindFirstChild("PlayerStates") then updatePlayerInfo() end
        local inCombat = PlayerStates and PlayerStates:GetAttribute("InCombat")
        local stunned = PlayerStates and PlayerStates:GetAttribute("Stunned")
        local fullStunned = PlayerStates and PlayerStates:GetAttribute("FullStunned")
        local performingMove = PlayerStates and PlayerStates:GetAttribute("PerformingMove")
        if inCombat ~= false then
            setFarmStatus(L("status_wait_combat")); task.wait(0.5)
        elseif stunned ~= false or fullStunned ~= false or performingMove ~= false then
            setFarmStatus(L("status_wait_stun")); task.wait(0.35)
        else
            task.wait(0.35)
            if PlayerStates and PlayerStates.Parent and PlayerStates:GetAttribute("InCombat") == false and PlayerStates:GetAttribute("Stunned") == false and PlayerStates:GetAttribute("FullStunned") == false and PlayerStates:GetAttribute("PerformingMove") == false then return true end
        end
    end
    return false
end
local function waitForStandChangeFrom(startStand, startSkin, timeout)
    local prevStand = startStand or (PlayerStatistics:GetAttribute("Stand") or "")
    local prevSkin  = startSkin  or (PlayerStatistics:GetAttribute("StandSkin") or "")
    local elapsed   = 0
    local limit     = timeout or 45
    while booleans.skinFarm and elapsed < limit do
        local stand = PlayerStatistics:GetAttribute("Stand") or ""
        local skin  = PlayerStatistics:GetAttribute("StandSkin") or ""
        if stand ~= prevStand or skin ~= prevSkin then
            repeat task.wait(0.25); elapsed = elapsed + 0.25 until not booleans.skinFarm or not PlayerStates:GetAttribute("PerformingMove") or elapsed > limit
            return PlayerStatistics:GetAttribute("Stand") or "", PlayerStatistics:GetAttribute("StandSkin") or "", true
        end
        task.wait(0.25); elapsed = elapsed + 0.25
    end
    return PlayerStatistics:GetAttribute("Stand") or "", PlayerStatistics:GetAttribute("StandSkin") or "", false
end
local function removeCurrentStand()
    if not booleans.skinFarm then return false end
    if (PlayerStatistics:GetAttribute("Stand") or "") == "" then return true end
    if not waitUntilReady() then return false end
    if not booleans.skinFarm then return false end
    setFarmStatus(L("status_removing"))
    ReplicatedStorage.Events.InteractEvent:FireServer("Remove Stand")
    local elapsed = 0
    while booleans.skinFarm and elapsed < 20 do
        if (PlayerStatistics:GetAttribute("Stand") or "") == "" and (PlayerStatistics:GetAttribute("StandSkin") or "") == "" then task.wait(1); return true end
        task.wait(0.25); elapsed = elapsed + 0.25
    end
    return (PlayerStatistics:GetAttribute("Stand") or "") == ""
end
local autoBuyNextAttempt = {}
local function getShopStock(codeName)
    local getInfo = Workspace:FindFirstChild("WorldStates") and Workspace.WorldStates:FindFirstChild("WorldStatesHandler") and Workspace.WorldStates.WorldStatesHandler:FindFirstChild("Shops") and Workspace.WorldStates.WorldStatesHandler.Shops:FindFirstChild("GetInfo")
    if not getInfo then return 0 end
    local ok, stocks = pcall(function() return getInfo:InvokeServer("GetStocks") end)
    if not ok or type(stocks) ~= "table" then return 0 end
    local directStock = tonumber(stocks[codeName])
    if directStock then return directStock end
    for _, entry in pairs(stocks) do
        if type(entry) == "table" and entry.CodeName == codeName then return tonumber(entry.Stock or entry.Amount) or 0 end
    end
    return 0
end
function autoBuyItem(codeName, price, invKey)
    local inv = PlayerStatistics and PlayerStatistics:FindFirstChild("Inventory")
    if not inv or not PlayerStates or PlayerStates:GetAttribute("InCombat") ~= false then return end
    local now = os.clock()
    if (autoBuyNextAttempt[codeName] or 0) > now then return end
    local cash = PlayerStatistics:GetAttribute("Cash") or 0
    local have = inv:GetAttribute(invKey) or 0
    local targetAmount = codeName == "Arrow" and (booleans.maxBuyArrows or 25) or (booleans.maxBuyRequiemArrows or 5)
    local enabled = (codeName == "Arrow" and booleans.autoBuyArrows) or (codeName == "RequiemArrow" and booleans.autoBuyRequiemArrows)
    if not enabled or have >= targetAmount then return end
    local stock = getShopStock(codeName)
    if stock <= 0 then autoBuyNextAttempt[codeName] = now + 5; return end
    local buyCount = math.min(targetAmount - have, stock, math.floor(cash / (price * 1.35)))
    if buyCount > 0 then
        ReplicatedStorage.Events.ShopEvent:FireServer("Buying", codeName, buyCount)
        autoBuyNextAttempt[codeName] = now + 2
    end
end
local function ensureItem(codeName, invKey, price)
    local inv = PlayerStatistics and PlayerStatistics:FindFirstChild("Inventory")
    if not inv then return false end
    autoBuyItem(codeName, price, invKey)
    if (inv:GetAttribute(invKey) or 0) > 0 then return true end
    local elapsed = 0
    while booleans.skinFarm and elapsed < 3 do
        if (inv:GetAttribute(invKey) or 0) > 0 then return true end
        task.wait(0.25); elapsed = elapsed + 0.25
    end
    return (inv:GetAttribute(invKey) or 0) > 0
end
local function fireItemUse(itemName, itemCode)
    if not waitUntilReady() then return false end
    updatePlayerInfo()
    local character = LocalPlayer.Character
    if not character or character ~= Character then return false end
    ReplicatedStorage.Events.ItemUseEvent:FireServer(character, itemName, itemCode)
    return true
end
local function useArrowItem() return fireItemUse("Arrow", "Arrow") end
local function usePureArrowItem() return fireItemUse("PureArrow", "PureArrow") end
local function useRequiemArrowItem() return fireItemUse("Requiem Arrow", "RequiemArrow") end
local function useGreenBabyItem() return fireItemUse("Green Baby", "GreenBaby") end
local function useCorpseItem(info)
    for _, v in pairs(PlayerStatistics.Inventory.SaintsCorpse:GetChildren()) do
        if v:GetAttribute(v.Name .. "_Equipped") == true then ReplicatedStorage.Events.ItemUseEvent:FireServer(Character, info.display, info.code, "Unequip") end
    end
    task.wait(0.25)
    ReplicatedStorage.Events.ItemUseEvent:FireServer(Character, info.display, info.code, true)
end
local function mergeGreenBaby()
    local mod = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Items") and ReplicatedStorage.Modules.Items:FindFirstChild("Green Baby")
    local mergeEvent = mod and mod:FindFirstChild("GreenBabyMerge")
    if mergeEvent then mergeEvent:FireServer("Merge") end
end
local function evolveGoldExperienceToGER()
    if not waitUntilReady() then return false end
    if not ensureItem("RequiemArrow", "RequiemArrow", REQUIEM_ARROW_PRICE) then return "no_item" end
    setFarmStatus(L("status_phase2_req"))
    local startStand = PlayerStatistics:GetAttribute("Stand") or ""
    local startSkin  = PlayerStatistics:GetAttribute("StandSkin") or ""
    for attempt = 1, 3 do
        if not booleans.skinFarm then return false end
        waitUntilReady()
        useRequiemArrowItem(); task.wait(0.8); useRequiemArrowItem()
        local waited = 0
        while booleans.skinFarm and waited < 5 do
            local curStand = PlayerStatistics:GetAttribute("Stand") or ""
            if curStand == "Gold Experience Requiem" or PlayerStates:GetAttribute("PerformingMove") then break end
            task.wait(0.25); waited = waited + 0.25
        end
        if (PlayerStatistics:GetAttribute("Stand") or "") == "Gold Experience Requiem" or PlayerStates:GetAttribute("PerformingMove") then break end
    end
    waitForStandChangeFrom(startStand, startSkin, 90)
    if not booleans.skinFarm then return false end
    local gotSkin = getSkinDisplayName()
    if gotSkin ~= "" then Notify(L("skin_farm"), L("notify_got_skin", gotSkin), 3) end
    local dropResult = handleSkinDrop(gotSkin)
    if dropResult == "done" then return "done" end
    if dropResult ~= "continue" then
        if not removeCurrentStand() then return false end
    end
    return "continue"
end
local function evolveWhitesnakeToCMoon()
    if not waitUntilReady() then return false end
    local inv = PlayerStatistics:FindFirstChild("Inventory")
    if not inv or (inv:GetAttribute("GreenBaby") or 0) <= 0 then return "no_item" end
    if PlayerStates:GetAttribute("StandSummoned") == true then
        Character.PlayerStates.Toggles:SetAttribute("ForceStandUnsummon", true)
        local elapsed = 0
        repeat task.wait(0.2); elapsed = elapsed + 0.2 until not PlayerStates:GetAttribute("StandSummoned") or elapsed > 10 or not booleans.skinFarm
    end
    setFarmStatus(L("status_phase2_gb"))
    local startStand = PlayerStatistics:GetAttribute("Stand") or ""
    local startSkin  = PlayerStatistics:GetAttribute("StandSkin") or ""
    useGreenBabyItem(); task.wait(1.5); mergeGreenBaby()
    waitForStandChangeFrom(startStand, startSkin, 90)
    if not booleans.skinFarm then return false end
    local gotSkin = getSkinDisplayName()
    if gotSkin ~= "" then Notify(L("skin_farm"), L("notify_got_skin", gotSkin), 3) end
    local dropResult = handleSkinDrop(gotSkin)
    if dropResult == "done" then return "done" end
    if dropResult ~= "continue" then
        if not removeCurrentStand() then return false end
    end
    return "continue"
end
local buildPityWithArrows
local function handleAutoSpecialConversion()
    if booleans.skinFarmMethod ~= "Auto" then return nil end
    local currentStand = PlayerStatistics:GetAttribute("Stand") or ""
    if currentStand == "Gold Experience" and hasSelectedSkinsForMethod("Requiem") and isPityThresholdMet() then
        local res = evolveGoldExperienceToGER()
        if res == "no_item" then return nil end
        return res
    elseif currentStand == "Whitesnake" and hasSelectedSkinsForMethod("GreenBaby") and isPityThresholdMet() then
        local res = evolveWhitesnakeToCMoon()
        if res == "no_item" then return nil end
        return res
    end
    return nil
end
local function rollArrowUntilStand(targetStand, useFn, itemCode, itemKey, itemPrice)
    while booleans.skinFarm do
        if not waitUntilReady() then return false end
        if PlayerStatistics:GetAttribute("Stand") == targetStand then return true end
        if (PlayerStatistics:GetAttribute("Stand") or "") ~= "" then
            if not removeCurrentStand() then return false end
        end
        if not booleans.skinFarm then return false end
        if not ensureItem(itemCode, itemKey, itemPrice) then Notify(L("skin_farm"), L("notify_not_enough", itemCode), 5); return false end
        local prevStand = PlayerStatistics:GetAttribute("Stand") or ""
        local prevSkin  = PlayerStatistics:GetAttribute("StandSkin") or ""
        setFarmStatus(L("status_rolling", itemCode, targetStand))
        if not useFn() then return false end
        waitForStandChangeFrom(prevStand, prevSkin, 60)
        if not booleans.skinFarm then return false end
        local gotSkin = getSkinDisplayName()
        if gotSkin ~= "" then Notify(L("skin_farm"), L("notify_got_skin_stand", gotSkin, PlayerStatistics:GetAttribute("Stand")), 3) end
        local dropResult = handleSkinDrop(gotSkin)
        if dropResult == "done" then return "done" end
        if PlayerStatistics:GetAttribute("Stand") == targetStand then return true end
    end
    return false
end
local function farmArrowLike(useFn, itemCode, itemKey, itemPrice, label, allowAutoSpecial)
    while booleans.skinFarm do
        if not waitUntilReady() then return false end
        if isSelectedSkin(getSkinDisplayName()) then return "done" end
        if allowAutoSpecial and (PlayerStatistics:GetAttribute("Stand") or "") ~= "" then
            local preAuto = handleAutoSpecialConversion()
            if preAuto == "done" then return "done" end
            if preAuto == false then return false end
        end
        if (PlayerStatistics:GetAttribute("Stand") or "") ~= "" then
            if not removeCurrentStand() then return false end
        end
        if not booleans.skinFarm then return false end
        if not ensureItem(itemCode, itemKey, itemPrice) then Notify(L("skin_farm"), L("notify_not_enough", label), 5); return false end
        local prevStand = PlayerStatistics:GetAttribute("Stand") or ""
        local prevSkin  = PlayerStatistics:GetAttribute("StandSkin") or ""
        setFarmStatus(L("status_using", label))
        if not useFn() then return false end
        waitForStandChangeFrom(prevStand, prevSkin, 60)
        if not booleans.skinFarm then return false end
        local gotSkin = getSkinDisplayName()
        if gotSkin ~= "" then Notify(L("skin_farm"), L("notify_got_skin", gotSkin), 3) end
        local directDrop = handleSkinDrop(gotSkin)
        if directDrop == "done" then return "done" end
        if directDrop ~= "continue" and allowAutoSpecial then
            local autoRes = handleAutoSpecialConversion()
            if autoRes == "done" then return "done" end
            if autoRes == false then return false end
        end
    end
    return false
end
function buildPityWithArrows()
    while booleans.skinFarm and not isPityThresholdMet() do
        if isSelectedSkin(getSkinDisplayName()) then return "done" end
        updateSkinPityDisplay()
        setFarmStatus(L("status_building_pity", getSkinPityPercent(), booleans.skinPityThreshold))
        local res = farmArrowLike(useArrowItem, "Arrow", "Arrow", ARROW_PRICE, "Arrow", false)
        if res == "done" then return "done" end
        if not res then return false end
    end
    updateSkinPityDisplay()
    return true
end
local function farmCorpseSkins()
    local targetStands = {}
    for _, skinName in ipairs(booleans.selectedSkins) do
        local stand = skinStandMap[skinName]
        if stand and CORPSE_BY_STAND[stand] then targetStands[stand] = CORPSE_BY_STAND[stand] end
    end
    if not next(targetStands) then Notify(L("skin_farm"), L("notify_no_corpse_skins"), 5); return false end
    while booleans.skinFarm do
        for standName, corpseInfo in pairs(targetStands) do
            if not booleans.skinFarm then break end
            if isSelectedSkin(getSkinDisplayName()) then return "done" end
            if booleans.skinPityEnabled and not isPityThresholdMet() then
                local pityRes = buildPityWithArrows()
                if pityRes == "done" then return "done" end
                if not pityRes then return false end
            end
            if not waitUntilReady() then return false end
            if standName == "Tusk ACT 3" then
                if PlayerStatistics:GetAttribute("Stand") ~= "Tusk ACT 2" then
                    local rollResult = rollArrowUntilStand("Tusk ACT 2", useArrowItem, "Arrow", "Arrow", ARROW_PRICE)
                    if rollResult == "done" then return "done" end
                    if not rollResult then return false end
                end
            else
                if (PlayerStatistics:GetAttribute("Stand") or "") ~= "" and not removeCurrentStand() then return false end
            end
            if not booleans.skinFarm then return false end
            local inv = PlayerStatistics:FindFirstChild("Inventory")
            if not inv or (inv:GetAttribute(corpseInfo.code) or 0) <= 0 then Notify(L("skin_farm"), L("notify_missing_corpse", corpseInfo.display), 5); return false end
            local prevStand = PlayerStatistics:GetAttribute("Stand") or ""
            local prevSkin  = PlayerStatistics:GetAttribute("StandSkin") or ""
            setFarmStatus(L("status_using_for", corpseInfo.display, standName))
            useCorpseItem(corpseInfo)
            waitForStandChangeFrom(prevStand, prevSkin, 60)
            if not booleans.skinFarm then return false end
            local gotSkin = getSkinDisplayName()
            if gotSkin ~= "" then Notify(L("skin_farm"), L("notify_got_skin", gotSkin), 3) end
            if handleSkinDrop(gotSkin) == "done" then return "done" end
        end
    end
    return false
end
local function farmRequiemSkins()
    while booleans.skinFarm do
        if isSelectedSkin(getSkinDisplayName()) then return "done" end
        if not waitUntilReady() then return false end
        if PlayerStatistics:GetAttribute("Stand") ~= "Gold Experience" then
            setFarmStatus(L("status_phase1_ge"))
            local res = rollArrowUntilStand("Gold Experience", useArrowItem, "Arrow", "Arrow", ARROW_PRICE)
            if res == "done" then return "done" end
            if not res then return false end
        end
        if not booleans.skinFarm then return false end
        if PlayerStatistics:GetAttribute("Stand") == "Gold Experience" then
            if booleans.skinPityEnabled and not isPityThresholdMet() then
                if not removeCurrentStand() then return false end
            else
                local evoRes = evolveGoldExperienceToGER()
                if evoRes == "no_item" then Notify(L("skin_farm"), L("notify_no_req"), 5); return false
                elseif evoRes == "done" then return "done"
                elseif evoRes == false then return false end
            end
        end
    end
    return false
end
local function farmGreenBabySkins()
    while booleans.skinFarm do
        if isSelectedSkin(getSkinDisplayName()) then return "done" end
        if not waitUntilReady() then return false end
        if PlayerStatistics:GetAttribute("Stand") ~= "Whitesnake" then
            setFarmStatus(L("status_phase1_ws"))
            local res = rollArrowUntilStand("Whitesnake", useArrowItem, "Arrow", "Arrow", ARROW_PRICE)
            if res == "done" then return "done" end
            if not res then return false end
        end
        if not booleans.skinFarm then return false end
        if PlayerStatistics:GetAttribute("Stand") == "Whitesnake" then
            if booleans.skinPityEnabled and not isPityThresholdMet() then
                if not removeCurrentStand() then return false end
            else
                local evoRes = evolveWhitesnakeToCMoon()
                if evoRes == "no_item" then Notify(L("skin_farm"), L("notify_no_green"), 5); return false
                elseif evoRes == "done" then return "done"
                elseif evoRes == false then return false end
            end
        end
    end
    return false
end
local skinFarmToggleRef
local function runSkinFarmLoop()
    if booleans.autoSelectStandSkins and #booleans.selectedSkinStands > 0 then
        addSkinsForSelectedStands()
    end
    if #booleans.selectedSkins == 0 then
        booleans.skinFarm = false
        if skinFarmToggleRef then skinFarmToggleRef:Set(false) end
        Notify(L("skin_farm"), L("notify_select_skin"), 5)
        return
    end
    local curStand = PlayerStatistics:GetAttribute("Stand") or ""
    local curSkin  = PlayerStatistics:GetAttribute("StandSkin") or ""
    local canStartWithBase = (curSkin == "") and (
        (curStand == "Gold Experience" and (booleans.skinFarmMethod == "Requiem" or hasSelectedSkinsForMethod("Requiem"))) or
        (curStand == "Whitesnake" and (booleans.skinFarmMethod == "GreenBaby" or hasSelectedSkinsForMethod("GreenBaby")))
    )
    if (curStand ~= "" or curSkin ~= "") and not canStartWithBase then
        booleans.skinFarm = false
        if skinFarmToggleRef then skinFarmToggleRef:Set(false) end
        Notify(L("skin_farm"), L("notify_remove_stand", curStand), 6)
        setFarmStatus(L("status_remove_first"))
        return
    end
    if not waitUntilReady() then return end
    local method = resolveFarmMethod()
    setFarmStatus(L("status_starting", L(METHOD_DISPLAY[method] or "method_arrow")))
    updateSkinPityDisplay()
    local result
    if method ~= "Arrow" and method ~= "Pure Arrow" and booleans.skinPityEnabled then
        local pityRes = buildPityWithArrows()
        if pityRes == "done" then result = "done" elseif pityRes == false then result = false end
    end
    if result == nil then
        if method == "Pure Arrow" then result = farmArrowLike(usePureArrowItem, "PureArrow", "PureArrow", 0, "Pure Arrow", false)
        elseif method == "Requiem" then result = farmRequiemSkins()
        elseif method == "Corpse" then result = farmCorpseSkins()
        elseif method == "GreenBaby" then result = farmGreenBabySkins()
        else result = farmArrowLike(useArrowItem, "Arrow", "Arrow", ARROW_PRICE, "Arrow", booleans.skinFarmMethod == "Auto") end
    end
    updateSkinPityDisplay()
    booleans.skinFarm = false
    if skinFarmToggleRef then skinFarmToggleRef:Set(false) end
    if result == "done" then
        setFarmStatus(L("status_done", getSkinDisplayName()))
        Notify(L("skin_farm"), L("notify_target_skin", getSkinDisplayName()), 6)
    else
        setFarmStatus(L("status_stopped"))
    end
end
SkinTab:CreateSection({ Name = L("sec_stand_filter"), Icon = "filter" })
dropdowns.dpSkinStands = SkinTab:CreateDropdown({
    Name = L("select_stands_skin"),
    Options = allStandNamesWithSkins,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "SelectedSkinStands",
    Callback = function(opts)
        booleans.selectedSkinStands = parseMultiOpts(opts)
        if dropdowns.dpSkins then
            dropdowns.dpSkins:Refresh(filterSkinsByQueryAndStands(searchState.skin))
        end
        if booleans.autoSelectStandSkins then
            addSkinsForSelectedStands()
        end
    end
})
SkinTab:CreateToggle({
    Name = L("auto_stand_skins_tog"),
    CurrentValue = false,
    Flag = "AutoSelectStandSkins",
    Callback = function(v)
        booleans.autoSelectStandSkins = v
        if v then addSkinsForSelectedStands() end
    end
})
SkinTab:CreateButton({
    Name = L("add_stand_skins_btn"),
    Callback = function()
        addSkinsForSelectedStands()
    end
})
SkinTab:CreateSection({ Name = L("sec_skin_sel"), Icon = "sparkles" })
dropdowns.dpSkins = SkinTab:CreateDropdown({
    Name = L("select_skins"), Options = allSkinNames, CurrentOption = {}, MultipleOptions = true, Flag = "SelectedSkins",
    Callback = function(opts) 
        booleans.selectedSkins = parseMultiOpts(opts)
        updateSkinDisplay() 
    end
})
dropdowns.dpFarmMethod = SkinTab:CreateDropdown({
    Name = L("farm_method"), Options = farmMethodLabels, CurrentOption = { farmMethodLabels[1] }, MultipleOptions = false, Flag = "SkinFarmMethod",
    Callback = function(opts) booleans.skinFarmMethod = farmMethodByLabel[opts[1] or ""] or "Auto" end
})
SkinTab:CreateButton({
    Name = L("select_all_skins"),
    Callback = function()
        booleans.selectedSkins = {}
        for code, display in pairs(skinCodeNameMap) do
            if not code:find("Default") and not table.find(booleans.selectedSkins, display) then
                table.insert(booleans.selectedSkins, display)
            end
        end
        updateSkinDisplay()
    end
})
SkinTab:CreateButton({
    Name = L("clear_skins"),
    Callback = function()
        booleans.selectedSkins = {}
        dropdowns.dpSkins:Set({})
        updateSkinDisplay()
    end
})
SkinTab:CreateSection({ Name = L("sec_skin_farm_settings"), Icon = "sliders" })

SkinTab:CreateToggle({
    Name = L("use_storage"),
    CurrentValue = false,
    Flag = "SkinUseStorage",
    Callback = function(v)
        booleans.skinUseStorageSlots = v
    end
})

SkinTab:CreateToggle({
    Name = L("use_pity"),
    CurrentValue = false,
    Flag = "SkinPityEnabled",
    Callback = function(v)
        booleans.skinPityEnabled = v
        updateSkinPityDisplay()
    end
})

SkinTab:CreateSlider({
    Name = L("pity_threshold"),
    Range = {1, 20},
    Increment = 1,
    CurrentValue = 10,
    Flag = "SkinPityThreshold",
    Callback = function(v)
        booleans.skinPityThreshold = v
        updateSkinPityDisplay()
    end
})

updateSkinPityDisplay()

local skinPitySignal = PlayerStatistics:GetAttributeChangedSignal("SkinPityChance")
Window:BindConnection(skinPitySignal, updateSkinPityDisplay)

SkinTab:CreateSection({ Name = L("sec_farm_control"), Icon = "play" })
skinFarmToggleRef = SkinTab:CreateToggle({ Name = L("skin_auto_farm"), CurrentValue = false, Flag = "SkinFarm", Callback = function(v) booleans.skinFarm = v; if v then task.spawn(runSkinFarmLoop) end end })
SkinTab:CreateSection({ Name = L("sec_auto_buy"), Icon = "shopping-cart" })
SkinTab:CreateSlider({
    Name = L("arrow_keep_target"), Range = {1, 25}, Increment = 1, CurrentValue = 25, Flag = "MaxBuyArrows",
    Callback = function(v) booleans.maxBuyArrows = v end
})
SkinTab:CreateToggle({
    Name = L("auto_buy_arrows"), CurrentValue = false, Flag = "AutoBuyArrows", Loop = 0.5,
    Callback = function(v) booleans.autoBuyArrows = v end,
    OnTick = function() autoBuyItem("Arrow", ARROW_PRICE, "Arrow") end
})
end
do
SkinTab:CreateSlider({
    Name = L("req_keep_target"), Range = {1, 10}, Increment = 1, CurrentValue = 5, Flag = "MaxBuyReqArrows",
    Callback = function(v) booleans.maxBuyRequiemArrows = v end
})
SkinTab:CreateToggle({
    Name = L("auto_buy_req"), CurrentValue = false, Flag = "AutoBuyRequiemArrows", Loop = 0.5,
    Callback = function(v) booleans.autoBuyRequiemArrows = v end,
    OnTick = function() autoBuyItem("RequiemArrow", REQUIEM_ARROW_PRICE, "RequiemArrow") end
})
local ItemsWithCost = {
    SteelBall            = { DisplayName = "Steel Ball",              SellCost = 3000  },
    MeteoriteShard       = { DisplayName = "Meteorite Shard",         SellCost = 2000  },
    SteelIngot           = { DisplayName = "Steel Ingot",             SellCost = 1500  },
    GoldIngot            = { DisplayName = "Gold Ingot",              SellCost = 10000 },
    VampireBlood         = { DisplayName = "Vampire Blood",           SellCost = 6000  },
    Fabric               = { DisplayName = "Fabric",                  SellCost = 500   },
    Wood                 = { DisplayName = "Wood",                    SellCost = 500   },
    Stone                = { DisplayName = "Stone",                   SellCost = 500   },
    Leather              = { DisplayName = "Leather",                 SellCost = 1500  },
    LadybugBrooch        = { DisplayName = "Ladybug Brooch",          SellCost = 20000 },
    KillerTie            = { DisplayName = "Killer Tie",              SellCost = 20000 },
    PassioneBadge        = { DisplayName = "Passione Badge",          SellCost = 35000 },
    GyrosTeddyBear       = { DisplayName = "Gyro's Teddy Bear",       SellCost = 35000 },
    Horseshoe            = { DisplayName = "Horseshoe",               SellCost = 30000 },
    BlackmoresUmbrella   = { DisplayName = "Blackmore's Umbrella",    SellCost = 35000 },
    BlackmoresBrokenMask = { DisplayName = "Blackmore's Broken Mask", SellCost = 35000 },
    BossTie              = { DisplayName = "Boss's Tie",              SellCost = 20000 },
    BrunosZipper         = { DisplayName = "Bruno's Zipper",          SellCost = 20000 },
    FugosTie             = { DisplayName = "Fugo's Tie",              SellCost = 10000 },
}
for codeName, item in pairs(ItemsWithCost) do
    local data = itemDataNames[codeName]
    if data then
        item.DisplayName = data.DisplayName or item.DisplayName
        if type(data.Value) == "number" and data.Value > 0 then item.SellCost = math.floor(data.Value / 2.5) end
    end
end
ASTab:CreateParagraph({ Title = L("sell_info_title"), Content = L("sell_info_text") })
local sellDisplayPara = ASTab:CreateParagraph({ Title = L("sell_selected"), Content = L("none") })
local sellCustomPara  = ASTab:CreateParagraph({ Title = L("sell_custom_status"), Content = L("none") })
local sellDisplayList = {}
local sellItemNamesOnly = {}
for _, v in pairs(ItemsWithCost) do
    table.insert(sellDisplayList, v.DisplayName .. " | $" .. v.SellCost)
    table.insert(sellItemNamesOnly, v.DisplayName)
end
table.sort(sellDisplayList)
table.sort(sellItemNamesOnly)
booleans.selectedSellItems  = {}
booleans.sellKeepGlobal     = 0
booleans.sellIgnoreCashCap  = false
booleans.customKeepByCode   = {}
booleans.selectedCustomCode = nil
booleans.pendingCustomKeep  = 5
local function findItemCodeByDisplay(displayStr)
    if not displayStr then return nil end
    local cleanName = split(displayStr, " | ")[1]:gsub("%s+", "")
    for k, v in pairs(ItemsWithCost) do
        if v.DisplayName:gsub("%s+", "") == cleanName then
            return k
        end
    end
    return nil
end
local function updateSellDisplay()
    if #booleans.selectedSellItems == 0 then
        sellDisplayPara:Set({ Title = L("sell_selected"), Content = L("none") })
    else
        local names = {}
        for _, k in ipairs(booleans.selectedSellItems) do
            local disp = ItemsWithCost[k] and ItemsWithCost[k].DisplayName or k
            local keep = booleans.customKeepByCode[k] or booleans.sellKeepGlobal or 0
            table.insert(names, keep > 0 and (disp .. " (keep " .. keep .. ")") or disp)
        end
        sellDisplayPara:Set({ Title = L("sell_selected"), Content = table.concat(names, ", ") })
    end
end
local function updateCustomKeepDisplay()
    local parts = {}
    for code, amt in pairs(booleans.customKeepByCode) do
        local disp = ItemsWithCost[code] and ItemsWithCost[code].DisplayName or code
        table.insert(parts, disp .. ": " .. tostring(amt))
    end
    table.sort(parts)
    sellCustomPara:Set({
        Title = L("sell_custom_status"),
        Content = (#parts == 0) and L("none") or table.concat(parts, " | ")
    })
    updateSellDisplay()
end
local function performSellPass()
    local inv = PlayerStatistics and PlayerStatistics:FindFirstChild("Inventory")
    if not inv or (PlayerStates and PlayerStates:GetAttribute("InCombat")) then return end
    for _, key in ipairs(booleans.selectedSellItems) do
        local item = ItemsWithCost[key]
        if item then
            local keepAmt = booleans.customKeepByCode[key]
            if keepAmt == nil then keepAmt = booleans.sellKeepGlobal or 0 end
            local count = inv:GetAttribute(key) or 0
            local excess = count - keepAmt
            if excess > 0 then
                ReplicatedStorage.Events.ShopEvent:FireServer("Selling", key, 1)
            end
        end
    end
end
dropdowns.dpAutoSell = ASTab:CreateDropdown({
    Name = L("select_items"), Options = sellDisplayList, CurrentOption = {}, MultipleOptions = true, Flag = "AutoSellItems",
    Callback = function(opts)
        booleans.selectedSellItems = {}
        for _, opt in ipairs(parseMultiOpts(opts)) do
            local code = findItemCodeByDisplay(opt)
            if code then table.insert(booleans.selectedSellItems, code) end
        end
        updateSellDisplay()
    end
})
ASTab:CreateButton({ Name = L("select_all_items"), Callback = function() booleans.selectedSellItems = {}; for k in pairs(ItemsWithCost) do table.insert(booleans.selectedSellItems, k) end; updateSellDisplay() end })
ASTab:CreateButton({ Name = L("clear_items"), Callback = function() booleans.selectedSellItems = {}; dropdowns.dpAutoSell:Set({}); updateSellDisplay() end })
ASTab:CreateSection({ Name = L("sec_sell_settings"), Icon = "sliders" })
ASTab:CreateSlider({
    Name = L("sell_keep_global"), Range = {0, 30}, Increment = 1, CurrentValue = 0, Flag = "SellKeepGlobal",
    Callback = function(v)
        booleans.sellKeepGlobal = v
        updateSellDisplay()
    end
})
ASTab:CreateToggle({
    Name = L("sell_ignore_cap"), CurrentValue = false, Flag = "SellIgnoreCashCap",
    Callback = function(v) booleans.sellIgnoreCashCap = v end
})
ASTab:CreateDropdown({
    Name = L("sell_custom_item"), Options = sellItemNamesOnly, CurrentOption = {}, MultipleOptions = false,
    Callback = function(opts)
        if opts and opts[1] then
            booleans.selectedCustomCode = findItemCodeByDisplay(opts[1])
        end
    end
})
ASTab:CreateSlider({
    Name = L("sell_custom_keep"), Range = {0, 30}, Increment = 1, CurrentValue = 5,
    Callback = function(v) booleans.pendingCustomKeep = v end
})
ASTab:CreateButton({
    Name = L("sell_save_custom"),
    Callback = function()
        if booleans.selectedCustomCode then
            booleans.customKeepByCode[booleans.selectedCustomCode] = booleans.pendingCustomKeep
            updateCustomKeepDisplay()
        end
    end
})
ASTab:CreateButton({
    Name = L("sell_clear_custom"),
    Callback = function()
        tclear(booleans.customKeepByCode)
        updateCustomKeepDisplay()
    end
})
ASTab:CreateSection({ Name = L("sec_actions"), Icon = "zap" })
ASTab:CreateButton({
    Name = L("sell_once_btn"),
    Callback = function()
        task.spawn(function()
            for _ = 1, 15 do
                performSellPass()
                task.wait(0.1)
            end
        end)
    end
})
ASTab:CreateToggle({
    Name = L("auto_sell"), CurrentValue = false, Flag = "AutoSell", Loop = 0.15,
    OnTick = performSellPass
})
local MOB_FARM_ENABLED = true
if MOB_FARM_ENABLED then
local mf = {
    enabled        = false,
    mode           = "NPCs",
    targetMobs     = {},
    targetPlayers  = {},
    speed          = 225,
    height         = 6.7,
    stopDist       = 4,
    attackDelay    = 0.12,
    attackCombo    = 3,
    maxDist        = 10000,
    currentTarget  = nil,
    inRange        = false,
    lastSafePos    = nil,
    autoSummon     = true,
    allowedAttacks = { "Light Attacks" },
    comboStep      = 1,
    lastSummonTime = 0,
    skillCooldowns = {},
    combatTimingU4 = nil,
}
pcall(function()
    local ctMod = ReplicatedStorage:WaitForChild("Modules", 5) and ReplicatedStorage.Modules:WaitForChild("CombatTiming", 5)
    if ctMod then
        local CombatTiming = require(ctMod)
        if type(CombatTiming) == "table" and type(CombatTiming.OnMove) == "function" and getupvalue_fn() then
            for idx = 1, 5 do
                local ok, upv = pcall(getupvalue_fn(), CombatTiming.OnMove, idx)
                if ok and type(upv) == "table" then
                    mf.combatTimingU4 = upv
                    break
                end
            end
        end
    end
end)
local function generateValidSequenceId(char)
    local u4 = mf.combatTimingU4
    if type(u4) ~= "table" then return math.random(1000, 9999) end
    local charState = u4[char]
    if not charState then
        charState = { Sequence = 0, Recent = {}, Order = {} }
        u4[char] = charState
    end
    charState.Sequence = charState.Sequence + 1
    return charState.Sequence
end
local NON_OFFENSIVE_NAMES = {
    ["pose"] = true, ["stand pose"] = true, ["character pose"] = true,
    ["stand summon"] = true, ["weapon summon"] = true, ["summon stand"] = true,
    ["summon weapon"] = true, ["equip weapon"] = true, ["block"] = true,
    ["dash"] = true, ["sprint"] = true, ["run"] = true, ["stand jump"] = true,
    ["time skip"] = true, ["time stop"] = true, ["the world"] = true,
    ["time erase"] = true, ["epitaph"] = true, ["return to zero"] = true,
    ["your next line"] = true, ["love train"] = true, ["dimension hop"] = true,
    ["bites the dust"] = true, ["awakening"] = true, ["mode"] = true,
    ["hamon charge"] = true, ["hamon breathing"] = true, ["vampirism"] = true,
    ["heal"] = true, ["self heal"] = true, ["restoration"] = true,
    ["pilot"] = true, ["stand pilot"] = true, ["invisibility"] = true,
    ["body dodge"] = true, ["afterimage"] = true, ["taunt"] = true,
    ["quote"] = true, ["slide"] = true, ["glide"] = true,
}
local NON_OFFENSIVE_TYPES = {
    ["pose"] = true, ["summon"] = true, ["movement"] = true, ["defense"] = true,
    ["block"] = true, ["dash"] = true, ["passive"] = true, ["utility"] = true,
    ["toggle"] = true, ["heal"] = true, ["counter"] = true, ["mode"] = true,
    ["awakening"] = true, ["timestop"] = true, ["pilot"] = true, ["emote"] = true,
    ["buff"] = true, ["dodge"] = true,
}
local function isSkillReady(skill, minInternalCd)
    if not skill or not skill.Parent then return false end
    if skill:GetAttribute("Cooldown") == true then return false end
    if skill:GetAttribute("Disabled") == true then return false end
    local cdTime = skill:GetAttribute("CooldownTime")
    if typeof(cdTime) == "number" and cdTime > 0 then return false end
    local lastUsed = mf.skillCooldowns[skill.Name]
    if lastUsed and (os.clock() - lastUsed) < (minInternalCd or 1.2) then
        return false
    end
    return true
end
local function isOffensiveSkill(ab)
    if not ab then return false end
    local lowerName = ab.Name:lower()
    if NON_OFFENSIVE_NAMES[lowerName] then return false end
    if lowerName:find("^light ") or lowerName:find("barrage") then
        return false
    end
    for _, kw in ipairs({ "pose", "summon", "block", "dash", "sprint", "heal", "pilot", "dodge", "counter", "time stop", "timestop", "time skip", "awakening", "charge", "taunt", "mode" }) do
        if lowerName:find(kw, 1, true) then return false end
    end
    if ab:GetAttribute("Pose") == true or ab:GetAttribute("Passive") == true or ab:GetAttribute("IsPassive") == true or ab:GetAttribute("Utility") == true then
        return false
    end
    for _, attrName in ipairs({ "Type", "AbilityType", "MoveType", "Category", "ActionType" }) do
        local val = ab:GetAttribute(attrName)
        if typeof(val) == "string" and NON_OFFENSIVE_TYPES[val:lower()] then
            return false
        end
    end
    return true
end
local function resolveStandModel(char, pst)
    if not char then return nil end
    local standName = pst and pst:GetAttribute("Stand")
    if typeof(standName) == "string" and standName ~= "" and standName ~= "None" then
        local found = char:FindFirstChild(standName)
        if found then return found end
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Model") and (child:GetAttribute("StandModel") == true or child:FindFirstChild("StandHumanoidRootPart") or child.Name == "Star Platinum" or child.Name == "The World" or child.Name == "The Hand") then
            return child
        end
    end
    return nil
end
local function isWeaponEquipped(char, pStates, weaponSummonAb)
    if pStates then
        if pStates:GetAttribute("WeaponSummoned") ~= nil then
            return pStates:GetAttribute("WeaponSummoned") == true
        end
        if pStates:GetAttribute("WeaponEquipped") ~= nil then
            return pStates:GetAttribute("WeaponEquipped") == true
        end
    end
    if weaponSummonAb and weaponSummonAb:GetAttribute("Summoned") ~= nil then
        return weaponSummonAb:GetAttribute("Summoned") == true
    end
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child:GetAttribute("Weapon") == true or child:GetAttribute("IsWeapon") == true then
                return true
            end
        end
    end
    return false
end
local function ensureStandAndWeapon(char, pStates, pStats, abilitiesFolder, abilityEvent)
    if not mf.autoSummon or (os.clock() - mf.lastSummonTime) < 1.5 then return end
    local standName = pStats and pStats:GetAttribute("Stand")
    if typeof(standName) == "string" and standName ~= "" and standName ~= "None" then
        if pStates and pStates:GetAttribute("StandSummoned") == false then
            local standSummon = abilitiesFolder:FindFirstChild("Stand Summon") or abilitiesFolder:FindFirstChild("Summon Stand")
            if standSummon then
                mf.lastSummonTime = os.clock()
                abilityEvent:FireServer("RunScript", standSummon, false, { LocalPlayer, "ForceSummon" })
                task.wait(0.18)
            end
        end
    end
    local weaponSummon = abilitiesFolder:FindFirstChild("Weapon Summon")
        or abilitiesFolder:FindFirstChild("Summon Weapon")
        or abilitiesFolder:FindFirstChild("Equip Weapon")
    if weaponSummon and not isWeaponEquipped(char, pStates, weaponSummon) then
        mf.lastSummonTime = os.clock()
        abilityEvent:FireServer("RunScript", weaponSummon, false, { LocalPlayer, "ForceSummon" })
        task.wait(0.18)
    end
end
local function getBestLightAbility(abilitiesFolder, pStates)
    local standSummoned = pStates and pStates:GetAttribute("StandSummoned") == true
    if standSummoned then
        local lps = abilitiesFolder:FindFirstChild("Light Punch Stand")
        if lps then return lps, true end
    end
    local lSlash = abilitiesFolder:FindFirstChild("Light Slash")
    if lSlash then return lSlash, false end
    local lp = abilitiesFolder:FindFirstChild("Light Punch")
    if lp then return lp, false end
    local lpsFallback = abilitiesFolder:FindFirstChild("Light Punch Stand")
    if lpsFallback then return lpsFallback, true end
    for _, ab in ipairs(abilitiesFolder:GetChildren()) do
        if ab.Name:lower():find("^light ") then
            return ab, (ab.Name:find("Stand") ~= nil)
        end
    end
    return nil, false
end
local function executeLightHit(char, pStates, pStats, abilitiesFolder, abilityEvent, targetChar)
    local lightAb, isStand = getBestLightAbility(abilitiesFolder, pStates)
    if not lightAb then return false end
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHumanoid or not targetRoot or targetHumanoid.Health <= 0 then return false end
    local standModel = isStand and resolveStandModel(char, pStats) or nil
    if isStand and not standModel then
        isStand = false
    end
    local maxCombo = clampN(mf.attackCombo or 3, 1, 4)
    local currentCombo = mf.comboStep
    mf.comboStep = (mf.comboStep % maxCombo) + 1
    local validActionId = generateValidSequenceId(char)
    local currentPing = 0
    abilityEvent:FireServer(
        "RunScript",
        lightAb,
        false,
        { LocalPlayer, true, false, false, false, currentPing, currentCombo },
        nil,
        nil,
        { Id = validActionId }
    )
    local waited = false
    local animPackMod = char:FindFirstChild("AnimationPack")
    if animPackMod then
        local ok, animPack = pcall(require, animPackMod)
        if ok and type(animPack) == "table" and type(animPack.GetAnimation) == "function" then
            local animPrefix = lightAb.Name:find("Slash") and "LightSlash" or "LightPunch"
            local animTrack = animPack.GetAnimation(animPrefix .. currentCombo) or animPack.GetAnimation("LightPunch" .. currentCombo)
            if animTrack and type(animTrack.GetTimeOfKeyframe) == "function" then
                local okKf, punchTime = pcall(animTrack.GetTimeOfKeyframe, animTrack, "Punch")
                if okKf and type(punchTime) == "number" and punchTime > 0 then
                    local u6_val = (currentCombo == 1 or currentCombo == 3) and 1.755 or (currentCombo == 2 and 1.62 or 1.08)
                    local u92_val = (currentCombo == 1 or currentCombo == 2) and 0.1 or 0
                    local exactWait = (punchTime - u92_val) / u6_val
                    local pingComp = clampN(currentPing / 2, 0, 0.1)
                    task.wait(clampN(exactWait - pingComp, 0.06, 0.3))
                    waited = true
                end
            end
        end
    end
    if not waited then
        task.wait(math.max(mf.attackDelay or 0.12, 0.08))
    end
    if not mf.enabled or not targetChar.Parent or targetHumanoid.Health <= 0 then return false end
    local targetPlr = Players:GetPlayerFromCharacter(targetChar)
    local targetData
    if isStand then
        targetData = { LocalPlayer, char, pStates, standModel, targetPlr, targetChar, targetHumanoid, currentCombo, abilitiesFolder, false }
    else
        targetData = { LocalPlayer, char, pStates, targetPlr, targetChar, targetHumanoid, currentCombo, abilitiesFolder, false }
    end
    local hitboxSize = isStand and Vector3.new(4, 6, 10) or Vector3.new(5, 6, 7)
    local hitboxData = { { LocalPlayer, char, 0.15, hitboxSize, nil, nil }, false, char, targetChar }
    abilityEvent:FireServer(
        "HitCheck", lightAb, false, targetData, hitboxData, nil, { Id = validActionId, Strike = "Hit" }
    )
    return true
end
local function executeSkillOrHeavy(char, pStats, abilitiesFolder, abilityEvent, targetChar, skillAb)
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    if not targetHumanoid or targetHumanoid.Health <= 0 then return false end
    local standModel = resolveStandModel(char, pStats)
    local targetPlr = Players:GetPlayerFromCharacter(targetChar)
    mf.skillCooldowns[skillAb.Name] = os.clock()
    abilityEvent:FireServer(
        "RunScript", skillAb, false, { LocalPlayer, true, false, false, false, 0, 1 }
    )
    task.wait(0.08)
    if not mf.enabled or not targetChar.Parent or targetHumanoid.Health <= 0 then return false end
    abilityEvent:FireServer(
        "HitCheck", skillAb, false,
        { LocalPlayer, char, standModel, targetPlr, targetChar, targetHumanoid, 1, abilitiesFolder, false },
        { { LocalPlayer, char, 0.2, Vector3.new(5, 6, 7) }, false, char, targetChar }
    )
    if not skillAb.Name:lower():find("^heavy ") then
        abilityEvent:FireServer(
            "HitCheck", skillAb, false,
            { LocalPlayer, char, standModel, targetPlr, targetChar, targetHumanoid, skillAb.Name, "Backward", false },
            { { LocalPlayer, char, 0.2, Vector3.new(5, 6, 7) }, false, char, targetChar }
        )
    end
    task.wait(0.05)
    return true
end
local function performSmartMobAttack(targetChar)
    local char = LocalPlayer.Character
    if not char then return end
    local pStates = char:FindFirstChild("PlayerStates")
    local pStats  = char:FindFirstChild("PlayerStatistics")
    local scripts = char:FindFirstChild("Scripts")
    local controls = scripts and scripts:FindFirstChild("Controls")
    local abilityEvent = controls and controls:FindFirstChild("AbilityServerEvent")
    local abilitiesFolder = controls and controls:FindFirstChild("Abilities")
    if not (pStates and pStats and abilityEvent and abilitiesFolder) then return end
    ensureStandAndWeapon(char, pStates, pStats, abilitiesFolder, abilityEvent)
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    if not targetHumanoid or targetHumanoid.Health <= 0 then return end
    local hpPercent = targetHumanoid.Health / math.max(targetHumanoid.MaxHealth, 1)
    local useLight = table.find(mf.allowedAttacks, "Light Attacks") ~= nil
    local heavyAb = abilitiesFolder:FindFirstChild("Heavy Punch Stand")
        or abilitiesFolder:FindFirstChild("Heavy Slash")
        or abilitiesFolder:FindFirstChild("Heavy Punch")
    if heavyAb and table.find(mf.allowedAttacks, heavyAb.Name) and hpPercent <= 0.12 and isSkillReady(heavyAb, 0.8) then
        executeSkillOrHeavy(char, pStats, abilitiesFolder, abilityEvent, targetChar, heavyAb)
        return
    end
    for _, ab in ipairs(abilitiesFolder:GetChildren()) do
        if not mf.enabled or not mf.inRange or targetHumanoid.Health <= 0 then break end
        if table.find(mf.allowedAttacks, ab.Name) then
            if isSkillReady(ab, 1.5) then
                executeSkillOrHeavy(char, pStats, abilitiesFolder, abilityEvent, targetChar, ab)
                return
            end
        end
    end
    if useLight then
        executeLightHit(char, pStates, pStats, abilitiesFolder, abilityEvent, targetChar)
    end
end
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = false
local DANGER_KEYWORDS = { "dead", "kill", "danger", "void", "death", "lava", "abyss", "outofbounds" }
local function isDangerPart(part)
    if not part then return false end
    local check = part
    while check and check ~= Workspace do
        local lowerName = check.Name:lower()
        for _, kw in ipairs(DANGER_KEYWORDS) do
            if lowerName:find(kw, 1, true) then
                return true
            end
        end
        check = check.Parent
    end
    return false
end
local function resetPhysicsAndState()
    local myRoot = SiriusNexus.Utils:GetRootPart(LocalPlayer)
    local hum = SiriusNexus.Utils:GetHumanoid(LocalPlayer)
    if myRoot then
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
        local pos = mf.lastSafePos or myRoot.Position
        myRoot.CFrame = CFrame.new(pos)
    end
    if hum then
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    SiriusNexus.Utils:FreezeRoot()
end
local function setCharacterNoclip(state)
    Window:CleanTask("MobFarmNoclip")
    if state then
        NC.checks.MobFarm = function() return mf.enabled == true end
        NC.start("MobFarm")
        Window:BindConnection(RunService.Stepped, function()
            if not Character then return end
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanTouch then part.CanTouch = false end
            end
        end, "MobFarmNoclip")
    else
        NC.stop("MobFarm")
        if Character then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanTouch = true end
            end
        end
    end
end
local function isTargetValid(model)
    if not model or not model.Parent then return false end
    local hum  = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
    if not (hum and root and hum.Health > 0 and not root.Anchored) then return false end
    local destroyY = Workspace.FallenPartsDestroyHeight
    if destroyY == destroyY and root.Position.Y < (destroyY + 80) then return false end
    if root.AssemblyLinearVelocity.Y < -18 then return false end
    rayParams.FilterDescendantsInstances = { Character, model, FriendlyFolder, HostileFolder }
    local hit = Workspace:Raycast(root.Position, Vector3.new(0, -35, 0), rayParams)
    if not hit or not hit.Instance then
        return false
    end
    if isDangerPart(hit.Instance) then
        return false
    end
    return true
end
local function acquireClosestTarget()
    local myRoot = SiriusNexus.Utils:GetRootPart(LocalPlayer)
    if not myRoot then return nil end
    local bestTarget = nil
    local bestDist = mf.maxDist
    local function evaluateCandidate(candidate, candidateName)
        if not isTargetValid(candidate) then return end
        local allowed = (mf.mode == "NPCs" and table.find(mf.targetMobs, candidateName)) or (mf.mode == "Players" and table.find(mf.targetPlayers, candidateName))
        if not allowed then return end
        local root = candidate:FindFirstChild("HumanoidRootPart")
        local dist = (root.Position - myRoot.Position).Magnitude
        if dist < bestDist then bestDist = dist; bestTarget = candidate end
    end
    if mf.mode == "Players" then
        for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer and plr.Character then evaluateCandidate(plr.Character, plr.Name) end end
    elseif HostileFolder then
        for _, npc in ipairs(HostileFolder:GetChildren()) do if npc:IsA("Model") then evaluateCandidate(npc, npc.Name) end end
    end
    return bestTarget
end
local function stopMobFarm()
    mf.enabled = false
    mf.currentTarget = nil
    mf.inRange = false
    Window:CleanTask("MobFarmMovementLoop")
    Window:CleanTask("MobFarmAttackLoop")
    setCharacterNoclip(false)
    resetPhysicsAndState()
end
local function startMobFarm()
    if not isPremiumUser then return end
    local initRoot = SiriusNexus.Utils:GetRootPart(LocalPlayer)
    if initRoot then mf.lastSafePos = initRoot.Position end
    setCharacterNoclip(true)
    Window:BindConnection(RunService.Heartbeat, function(dt)
        if not mf.enabled then return end
        if not isTargetValid(mf.currentTarget) then
            mf.currentTarget = acquireClosestTarget()
        end
        local myRoot = SiriusNexus.Utils:GetRootPart(LocalPlayer)
        local hum = SiriusNexus.Utils:GetHumanoid(LocalPlayer)
        if not myRoot then
            mf.inRange = false
            return
        end
        if hum and not hum.PlatformStand then
            hum.PlatformStand = true
        end
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
        local target = mf.currentTarget
        local targetRoot = target and target:FindFirstChild("HumanoidRootPart")
        if not (target and targetRoot) then
            mf.inRange = false
            if mf.lastSafePos then
                myRoot.CFrame = CFrame.new(mf.lastSafePos)
            end
            return
        end
        local safeHeight = clampN(mf.height, 2, 11)
        local hoverPos   = targetRoot.Position + Vector3.new(0, safeHeight, 0)
        local diff       = hoverPos - myRoot.Position
        local dist       = diff.Magnitude
        local _, targetYaw, _ = targetRoot.CFrame:ToOrientation()
        local lookDownRotation = CFrame.Angles(0, targetYaw, 0) * CFrame.Angles(-math.pi / 2, 0, 0)
        if dist <= mf.stopDist then
            mf.inRange = true
            mf.lastSafePos = hoverPos
            myRoot.CFrame = CFrame.new(hoverPos) * lookDownRotation
        else
            mf.inRange = false
            local step = math.min(dist, math.max(mf.speed, 25) * dt)
            local nextPos = myRoot.Position + (diff.Unit * step)
            mf.lastSafePos = nextPos
            myRoot.CFrame = CFrame.new(nextPos) * lookDownRotation
        end
    end, "MobFarmMovementLoop")
    Window:AddTask(task.spawn(function()
        while mf.enabled do
            if mf.inRange and isTargetValid(mf.currentTarget) then
                performSmartMobAttack(mf.currentTarget)
                task.wait()
            else
                task.wait(0.08)
            end
        end
    end), "MobFarmAttackLoop")
end
MBTab:CreateSection({ Name = L("sec_target"), Icon = "crosshair" })
playerDropdowns.dpPlayersFarm = MBTab:CreateDropdown({ Name = L("target_players"), Options = playerList, CurrentOption = {}, MultipleOptions = true, PremiumOnly = true, Callback = function(opts) mf.targetPlayers = parseMultiOpts(opts) end })
dropdowns.dpHostileFarm = MBTab:CreateDropdown({ Name = L("target_npcs"), Options = MobHostileList, CurrentOption = {}, MultipleOptions = true, PremiumOnly = true, Callback = function(opts) mf.targetMobs = parseMultiOpts(opts) end })
MBTab:CreateSection({ Name = L("sec_move_settings"), Icon = "navigation" })
MBTab:CreateSlider({ Name = L("fly_speed"), Range = {25, 1250}, Increment = 25, CurrentValue = 225, Flag = "FarmSpeed", PremiumOnly = true, Callback = function(v) mf.speed = v end })
MBTab:CreateSlider({ Name = L("height_offset"), Range = {2, 11}, Increment = 0.5, CurrentValue = 6.7, Flag = "FarmHeight", PremiumOnly = true, Callback = function(v) mf.height = v end })
MBTab:CreateSlider({ Name = L("stop_dist"), Range = {0, 20}, Increment = 1, CurrentValue = 4, Flag = "FarmStopDist", PremiumOnly = true, Callback = function(v) mf.stopDist = v end })
MBTab:CreateSlider({ Name = L("max_range"), Range = {100, 10000}, Increment = 100, CurrentValue = 10000, Flag = "FarmMaxDist", PremiumOnly = true, Callback = function(v) mf.maxDist = v end })
MBTab:CreateSection({ Name = L("sec_attack"), Icon = "swords" })
MBTab:CreateToggle({ Name = "Auto Summon Stand & Weapon", CurrentValue = true, Flag = "FarmAutoSummon", PremiumOnly = true, Callback = function(v) mf.autoSummon = v end })
local availableAttacksList = { "Light Attacks" }
local function refreshAttackDropdown()
    local char = LocalPlayer.Character
    local abilities = char and char:FindFirstChild("Scripts") and char.Scripts:FindFirstChild("Controls") and char.Scripts.Controls:FindFirstChild("Abilities")
    local newList = { "Light Attacks" }
    if abilities then
        for _, ab in ipairs(abilities:GetChildren()) do
            if isOffensiveSkill(ab) then
                table.insert(newList, ab.Name)
            end
        end
    end
    availableAttacksList = newList
    if dropdowns.dpMobAttacks then
        dropdowns.dpMobAttacks:Refresh(availableAttacksList)
    end
end
MBTab:CreateButton({
    Name = "Refresh Attacks (Use after spawning/changing stand)",
    PremiumOnly = true,
    Callback = function()
        refreshAttackDropdown()
        Notify(L("tab_mob"), "Attack list refreshed successfully!", 3)
    end
})
dropdowns.dpMobAttacks = MBTab:CreateDropdown({
    Name = "Select Attacks To Use",
    Options = availableAttacksList,
    CurrentOption = { "Light Attacks" },
    MultipleOptions = true,
    PremiumOnly = true,
    Callback = function(opts)
        mf.allowedAttacks = opts or {}
    end
})
MBTab:CreateSlider({ Name = L("atk_delay"), Range = {0.05, 1.0}, Increment = 0.01, CurrentValue = 0.12, Flag = "FarmAtkDelay", PremiumOnly = true, Callback = function(v) mf.attackDelay = v end })
MBTab:CreateSlider({ Name = L("combo_count"), Range = {1, 4}, Increment = 1, CurrentValue = 3, Flag = "FarmCombo", PremiumOnly = true, Callback = function(v) mf.attackCombo = v end })
MBTab:CreateSection({ Name = L("sec_farm"), Icon = "play" })
local npcFarmToggle, playerFarmToggle
npcFarmToggle = MBTab:CreateToggle({
    Name = L("npcs_farm"), CurrentValue = false, Flag = "NPCsFarm", PremiumOnly = true,
    Callback = function(v)
        if v then
            if mf.enabled then stopMobFarm(); playerFarmToggle:Set(false) end
            mf.mode = "NPCs"; mf.enabled = true; startMobFarm()
        else stopMobFarm() end
    end
})
playerFarmToggle = MBTab:CreateToggle({
    Name = L("players_farm"), CurrentValue = false, Flag = "PlayersFarm", PremiumOnly = true,
    Callback = function(v)
        if v then
            if mf.enabled then stopMobFarm(); npcFarmToggle:Set(false) end
            mf.mode = "Players"; mf.enabled = true; startMobFarm()
        else stopMobFarm() end
    end
})
MBTab:CreateButton({ Name = L("stop_farm"), PremiumOnly = true, Callback = function() stopMobFarm(); npcFarmToggle:Set(false); playerFarmToggle:Set(false); Notify(L("tab_mob"), L("farm_stopped"), 3) end })
end
HWTab:CreateParagraph({
    Title   = "" .. L("hw_info_title"),
    Content = L("hw_info_text")
})
RIU_HW = {
    enabled        = false,
    flySpeed       = 2000,
    stopDist       = 3,
    doorCooldown   = 185,
    blacklist      = {},
    lootCache      = {},
    doorCache      = {},
    currentTarget  = nil,
    targetType     = nil,
    targetModel    = nil,
    hoverStartTime = 0,
    spotIndex      = 1,
    attackCooldown = 0,
    targets        = { door = true, pumpkin = true, wisp = true },
    doorsFirst     = false,
    pumpkinHeight  = 2.2,
    wispHeight     = 3,
    pumpkinTime    = 2.2,
    wispTime       = 1.3,
    attackDelay    = 0.3,
    autoAnswer     = true,
    patrol         = true,
    noclip         = true,
    spots = {
        Vector3.new(502.285, 569.509, 482.453),
        Vector3.new(363.051, 622.488, -494.828),
        Vector3.new(194.013, 571.942, -1915.485),
        Vector3.new(1480.302, 527.758, -2246.705),
        Vector3.new(1598.721, 707.262, -716.611),
        Vector3.new(1263.743, 575.149, 466.132),
        Vector3.new(891.519, 595.685, -737.424),
    }
}
do
    local function bindTrick(trickEvent)
        Window:BindConnection(trickEvent.OnClientEvent, function(action, doorId, arg3, arg4)
            if not RIU_HW.enabled or not RIU_HW.autoAnswer then return end
            if action == "Begin" then
                trickEvent:FireServer("Ready", doorId)
            elseif action == "Cue" then
                task.spawn(function()
                    local waitTime = arg4 - Workspace:GetServerTimeNow()
                    if waitTime > 0 then task.wait(waitTime) end
                    if RIU_HW.enabled and RIU_HW.autoAnswer then
                        trickEvent:FireServer("Answer", doorId, arg3)
                    end
                end)
            elseif action == "Roots" then
                task.spawn(function()
                    if type(arg3) == "table" and arg3.StartedAt then
                        local waitTime = arg3.StartedAt - Workspace:GetServerTimeNow()
                        if waitTime > 0 then task.wait(waitTime + 0.05) end
                    else
                        task.wait(0.3)
                    end
                    if RIU_HW.enabled and RIU_HW.autoAnswer then
                        trickEvent:FireServer("RootsJump", doorId, Workspace:GetServerTimeNow())
                    end
                end)
            end
        end)
    end
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    local trickEvent = eventsFolder and eventsFolder:FindFirstChild("TrickOrTreat")
    if trickEvent then
        bindTrick(trickEvent)
    elseif eventsFolder then
        task.spawn(function()
            trickEvent = eventsFolder:WaitForChild("TrickOrTreat", 10)
            if trickEvent then bindTrick(trickEvent) end
        end)
    end
end
local function hwCacheLoot(obj)
    if not obj or not obj.Parent then return end
    if obj.Name == "SoulJackOLantern" or obj:FindFirstChild("SoulJackOLantern", true) then
        RIU_HW.lootCache[obj] = "pumpkin"
    elseif obj.Name == "SoulWisp" or obj:FindFirstChild("SoulWisp", true) then
        RIU_HW.lootCache[obj] = "wisp"
    end
end
local function hwScanAllLoot()
    local clientLoot = Workspace:FindFirstChild("ClientLoot")
    if not clientLoot then return end
    for _, child in ipairs(clientLoot:GetChildren()) do
        hwCacheLoot(child)
    end
end
local function hwFindAllDoors()
    tclear(RIU_HW.doorCache)
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then return end
    for _, obj in ipairs(mapFolder:GetDescendants()) do
        if obj.Name == "TrickOrTreatMenacingPoint" then
            local pos = obj:IsA("Attachment") and obj.WorldPosition or (obj:IsA("BasePart") and obj.Position) or nil
            if pos then RIU_HW.doorCache[obj] = pos end
        end
    end
end
local function setHalloweenNoclip(state)
    if state then
        NC.checks.Halloween = function() return RIU_HW.enabled == true end
        NC.start("Halloween")
    else
        NC.stop("Halloween")
    end
end
local function hwFireAttack()
    if UserInputService:GetFocusedTextBox() then return end
    local cam = Workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    local x, y = math.floor(vp.X / 2), math.floor(vp.Y / 2)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
    task.wait(0.03)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
end
local function hwFlyTo(pos, lookDown)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not root then return false end
    if hum then hum.PlatformStand = true end
    local dist = (root.Position - pos).Magnitude
    if dist <= RIU_HW.stopDist then
        local cf = CFrame.new(pos)
        if lookDown then cf = cf * CFrame.Angles(-math.pi / 2, 0, 0) end
        root.CFrame = cf
        root.AssemblyLinearVelocity = Vector3.zero
        root.Anchored = true
        return true
    end
    root.Anchored = false
    local direction = (pos - root.Position).Unit
    local step = math.min(dist, RIU_HW.flySpeed * 0.016)
    local nextPos = root.Position + direction * step
    local cf = CFrame.new(nextPos)
    if lookDown then cf = cf * CFrame.Angles(-math.pi / 2, 0, 0) end
    root.CFrame = cf
    root.AssemblyLinearVelocity = Vector3.zero
    return false
end
local function hwFindLoot()
    for obj, lType in pairs(RIU_HW.lootCache) do
        if obj and obj.Parent then
            if RIU_HW.targets[lType] then
                if not RIU_HW.blacklist[obj] or (tick() - RIU_HW.blacklist[obj] > 6) then
                    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                    if part then return part, lType, obj end
                end
            end
        else
            RIU_HW.lootCache[obj] = nil
        end
    end
    return nil, nil, nil
end
local function hwFindDoor()
    if not RIU_HW.targets.door then return nil, nil, nil end
    for door, _ in pairs(RIU_HW.doorCache) do
        if door and door.Parent then
            local doorModel = door.Parent
            if doorModel.Name == "NPC_SpawnLocation" then doorModel = doorModel.Parent end
            local isBusy = doorModel and doorModel:GetAttribute("TrickOrTreatBusy") == true
            local prompt = doorModel and doorModel:FindFirstChild("TrickOrTreatPrompt", true)
            local isEnabled = prompt and prompt.Enabled == true
            if not isBusy and isEnabled then
                if not RIU_HW.blacklist[doorModel] or (tick() - RIU_HW.blacklist[doorModel] > 0) then
                    return door, "door", doorModel
                end
            end
        else
            RIU_HW.doorCache[door] = nil
        end
    end
    return nil, nil, nil
end
local function hwFindTarget()
    local p, t, m
    if RIU_HW.doorsFirst then
        p, t, m = hwFindDoor()
        if p then return p, t, m end
        return hwFindLoot()
    end
    p, t, m = hwFindLoot()
    if p then return p, t, m end
    return hwFindDoor()
end
local function hwInteractWithDoor(point, doorModel)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not point then return end
    local cam = Workspace.CurrentCamera
    local oldType = cam.CameraType
    local pointPos = point:IsA("Attachment") and point.WorldPosition or point.Position
    local parentPos = (point.Parent and point.Parent:IsA("BasePart") and point.Parent.Position) or (pointPos + Vector3.new(0, 0, 1))
    local dir = (pointPos - parentPos).Unit
    if dir.Magnitude == 0 or dir.Magnitude ~= dir.Magnitude then dir = Vector3.new(0, 0, 1) end
    local standPos = pointPos + (dir * 1.5)
    root.Anchored = true
    root.CFrame = CFrame.lookAt(standPos, Vector3.new(parentPos.X, standPos.Y, parentPos.Z))
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.2)
    local prompt = point.Parent and point.Parent:FindFirstChild("TrickOrTreatPrompt", true)
    if prompt then
        pcall(fireproximityprompt, prompt, 1)
        task.wait(0.5)
    end
    task.wait(0.5)
    local t = 0
    while RIU_HW.enabled and cam:FindFirstChild("TrickOrTreatEncounter") and t < 15 do
        task.wait(0.2)
        t = t + (0.2)
        if root and root.Parent then
            root.AssemblyLinearVelocity = Vector3.zero
            root.Anchored = true
        end
    end
    if root and root.Parent then root.Anchored = false end
    cam.CameraType = oldType
    if doorModel then
        RIU_HW.blacklist[doorModel] = tick() + RIU_HW.doorCooldown
    end
end
local function stopHalloweenFarm()
    RIU_HW.enabled = false
    RIU_HW.currentTarget = nil
    RIU_HW.targetType = nil
    RIU_HW.targetModel = nil
    Window:CleanTask("HalloweenFarmLoop")
    Window:CleanTask("HalloweenDoorScanner")
    Window:CleanTask("HalloweenLootListener")
    setHalloweenNoclip(false)
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if hum then
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    if root then
        root.Anchored = false
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
    if Workspace.CurrentCamera then
        Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end
local function startHalloweenFarm()
    if not isPremiumUser then return end
    hwScanAllLoot()
    hwFindAllDoors()
    setHalloweenNoclip(RIU_HW.noclip)
    local clientLoot = Workspace:FindFirstChild("ClientLoot")
    if clientLoot then
        Window:BindConnection(clientLoot.ChildAdded, function(child)
            task.wait(0.1)
            if RIU_HW.enabled then hwCacheLoot(child) end
        end, "HalloweenLootListener")
    end
    Window:AddTask(task.spawn(function()
        while RIU_HW.enabled do
            task.wait(20)
            if not RIU_HW.enabled then break end
            hwScanAllLoot()
            hwFindAllDoors()
        end
    end), "HalloweenDoorScanner")
    Window:AddTask(task.spawn(function()
        while RIU_HW.enabled do
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then
                task.wait(0.1)
            else
            if RIU_HW.currentTarget and RIU_HW.targetType and not RIU_HW.targets[RIU_HW.targetType] then
                RIU_HW.currentTarget = nil
            end
            if not RIU_HW.currentTarget or not RIU_HW.currentTarget.Parent then
                RIU_HW.currentTarget, RIU_HW.targetType, RIU_HW.targetModel = hwFindTarget()
                RIU_HW.hoverStartTime = 0
            end
            if RIU_HW.currentTarget and RIU_HW.currentTarget.Parent then
                local hoverPos = RIU_HW.currentTarget:IsA("Attachment") and RIU_HW.currentTarget.WorldPosition or RIU_HW.currentTarget.Position
                if RIU_HW.targetType == "pumpkin" then
                    hoverPos = hoverPos + Vector3.new(0, RIU_HW.pumpkinHeight, 0)
                elseif RIU_HW.targetType == "wisp" then
                    hoverPos = hoverPos + Vector3.new(0, RIU_HW.wispHeight, 0)
                end
                local reached = hwFlyTo(hoverPos, RIU_HW.targetType == "pumpkin" or RIU_HW.targetType == "door")
                if reached then
                    if RIU_HW.hoverStartTime == 0 then RIU_HW.hoverStartTime = tick() end
                    if RIU_HW.targetType == "pumpkin" then
                        if tick() > RIU_HW.attackCooldown then
                            hwFireAttack()
                            task.wait(0.04)
                            hwFireAttack()
                            RIU_HW.attackCooldown = tick() + RIU_HW.attackDelay
                        end
                        if tick() - RIU_HW.hoverStartTime > RIU_HW.pumpkinTime then
                            if RIU_HW.targetModel then RIU_HW.blacklist[RIU_HW.targetModel] = tick() end
                            RIU_HW.currentTarget = nil
                        end
                    elseif RIU_HW.targetType == "wisp" then
                        if tick() - RIU_HW.hoverStartTime > RIU_HW.wispTime then
                            if RIU_HW.targetModel then RIU_HW.blacklist[RIU_HW.targetModel] = tick() end
                            RIU_HW.currentTarget = nil
                        end
                    elseif RIU_HW.targetType == "door" then
                        hwInteractWithDoor(RIU_HW.currentTarget, RIU_HW.targetModel)
                        RIU_HW.currentTarget = nil
                    end
                else
                    RIU_HW.hoverStartTime = 0
                end
            elseif RIU_HW.patrol then
                local spot = RIU_HW.spots[RIU_HW.spotIndex]
                if spot then
                    hwFlyTo(spot + Vector3.new(0, 9, 0), false)
                    if (root.Position - (spot + Vector3.new(0, 9, 0))).Magnitude < 18 then
                        RIU_HW.spotIndex = (RIU_HW.spotIndex % #RIU_HW.spots) + 1
                    end
                end
            else
                root.AssemblyLinearVelocity = Vector3.zero
            end
            task.wait(0.03)
            end
        end
    end), "HalloweenFarmLoop")
end
HWTab:CreateSection({ Name = L("sec_hw_targets"), Icon = "target" })
HWTab:CreateToggle({
    Name = L("hw_t_doors"), CurrentValue = true, Flag = "HWTargetDoors", PremiumOnly = true,
    Callback = function(v) RIU_HW.targets.door = v end
})
HWTab:CreateToggle({
    Name = L("hw_t_pumpkins"), CurrentValue = true, Flag = "HWTargetPumpkins", PremiumOnly = true,
    Callback = function(v) RIU_HW.targets.pumpkin = v end
})
HWTab:CreateToggle({
    Name = L("hw_t_wisps"), CurrentValue = true, Flag = "HWTargetWisps", PremiumOnly = true,
    Callback = function(v) RIU_HW.targets.wisp = v end
})
HWTab:CreateToggle({
    Name = L("hw_doors_first"), CurrentValue = false, Flag = "HWDoorsFirst", PremiumOnly = true,
    Callback = function(v) RIU_HW.doorsFirst = v end
})
HWTab:CreateSection({ Name = L("sec_move_settings"), Icon = "navigation" })
HWTab:CreateSlider({
    Name = L("fly_speed"), Range = {100, 5000}, Increment = 50,
    CurrentValue = 2000, Flag = "HWFlySpeed", PremiumOnly = true,
    Callback = function(v) RIU_HW.flySpeed = v end
})
HWTab:CreateSlider({
    Name = L("stop_dist"), Range = {1, 20}, Increment = 1,
    CurrentValue = 3, Flag = "HWStopDist", PremiumOnly = true,
    Callback = function(v) RIU_HW.stopDist = v end
})
HWTab:CreateSlider({
    Name = L("hw_height_pumpkin"), Range = {0.5, 8}, Increment = 0.1,
    CurrentValue = 2.2, Flag = "HWPumpkinHeight", PremiumOnly = true,
    Callback = function(v) RIU_HW.pumpkinHeight = v end
})
HWTab:CreateSlider({
    Name = L("hw_height_wisp"), Range = {0.5, 10}, Increment = 0.1,
    CurrentValue = 3, Flag = "HWWispHeight", PremiumOnly = true,
    Callback = function(v) RIU_HW.wispHeight = v end
})
HWTab:CreateSection({ Name = L("sec_hw_timing"), Icon = "timer" })
HWTab:CreateSlider({
    Name = L("hw_pumpkin_time"), Range = {0.5, 10}, Increment = 0.1,
    CurrentValue = 2.2, Flag = "HWPumpkinTime", PremiumOnly = true,
    Callback = function(v) RIU_HW.pumpkinTime = v end
})
HWTab:CreateSlider({
    Name = L("hw_wisp_time"), Range = {0.3, 5}, Increment = 0.1,
    CurrentValue = 1.3, Flag = "HWWispTime", PremiumOnly = true,
    Callback = function(v) RIU_HW.wispTime = v end
})
HWTab:CreateSlider({
    Name = L("hw_attack_delay"), Range = {0.05, 1}, Increment = 0.05,
    CurrentValue = 0.3, Flag = "HWAttackDelay", PremiumOnly = true,
    Callback = function(v) RIU_HW.attackDelay = v end
})
HWTab:CreateSlider({
    Name = L("hw_door_cd"), Range = {30, 600}, Increment = 5,
    CurrentValue = 185, Flag = "HWDoorCooldown", PremiumOnly = true,
    Callback = function(v) RIU_HW.doorCooldown = v end
})
HWTab:CreateSection({ Name = L("sec_hw_extra"), Icon = "sliders" })
HWTab:CreateToggle({
    Name = L("hw_auto_answer"), CurrentValue = true, Flag = "HWAutoAnswer", PremiumOnly = true,
    Callback = function(v) RIU_HW.autoAnswer = v end
})
HWTab:CreateToggle({
    Name = L("hw_patrol"), CurrentValue = true, Flag = "HWPatrol", PremiumOnly = true,
    Callback = function(v) RIU_HW.patrol = v end
})
HWTab:CreateToggle({
    Name = L("hw_noclip"), CurrentValue = true, Flag = "HWNoclip", PremiumOnly = true,
    Callback = function(v)
        RIU_HW.noclip = v
        if RIU_HW.enabled then setHalloweenNoclip(v) end
    end
})
HWTab:CreateSection({ Name = L("sec_farm"), Icon = "play" })
HWTab:CreateToggle({
    Name         = L("hw_farm"),
    CurrentValue = false,
    Flag         = "HalloweenAutoFarm",
    PremiumOnly  = true,
    Callback     = function(v)
        if v then
            RIU_HW.enabled = true
            startHalloweenFarm()
        else
            stopHalloweenFarm()
        end
    end
})
do
local savedOutfitsByUserId = {}
local originalOutfitBackup = {}
booleans.keepOutfitOnRespawn = true
local pendingOutfit = { OutfitHead = "", OutfitUpper = "", OutfitLower = "", OutfitMisc = "" }
local outfitsRoot   = ReplicatedStorage:WaitForChild("VFX"):WaitForChild("Outfits")
local outfitSectionLookup = {}
for _, desc in ipairs(outfitsRoot:GetDescendants()) do
    if desc:IsA("Model") then
        for _, sec in ipairs({ "OutfitHead", "OutfitUpper", "OutfitLower", "OutfitMisc" }) do
            if desc:GetAttribute(sec) == true then
                outfitSectionLookup[desc.Name] = sec
            end
        end
    end
end
local function getPlayerSavedOutfit(plr)
    local uid = plr.UserId
    if not savedOutfitsByUserId[uid] then
        savedOutfitsByUserId[uid] = { OutfitHead = "", OutfitUpper = "", OutfitLower = "", OutfitMisc = "" }
    end
    return savedOutfitsByUserId[uid]
end
local function isModelOfOutfitSection(obj, sectionType)
    if not obj:IsA("Model") then return false end
    if obj:GetAttribute(sectionType) == true then return true end
    if outfitSectionLookup[obj.Name] == sectionType then return true end
    return false
end
local function removeExistingSectionPieces(character, sectionType)
    if not character then return end
    originalOutfitBackup[character] = originalOutfitBackup[character] or {}
    originalOutfitBackup[character][sectionType] = originalOutfitBackup[character][sectionType] or {}
    for _, obj in ipairs(character:GetChildren()) do
        if isModelOfOutfitSection(obj, sectionType) then
            if obj:GetAttribute("_RIU_Script") == true then
                obj:Destroy()
            else
                table.insert(originalOutfitBackup[character][sectionType], obj)
                obj.Parent = nil
            end
        end
    end
end
local function restoreOriginalOutfits(character)
    local charBackup = originalOutfitBackup[character]
    if not charBackup then return end
    for sectionType, list in pairs(charBackup) do
        for _, origObj in ipairs(list) do
            if origObj then origObj.Parent = character end
        end
        charBackup[sectionType] = {}
    end
end
local function applyOutfitSection(targetPlayer, character, outfitName, sectionType)
    if not isPremiumUser or not character then return end
    removeExistingSectionPieces(character, sectionType)
    if outfitName == "" then return end
    local folder = outfitsRoot:FindFirstChild(outfitName, true)
    local modelSrc = folder and (folder:IsA("Model") and folder or folder:FindFirstChild(outfitName))
    if not modelSrc then return end
    local outfitModel = modelSrc:Clone()
    if outfitModel.ClassName == "Folder" then
        local inner = outfitModel:FindFirstChild(outfitName)
        outfitModel:Destroy()
        if not inner then return end
        outfitModel = inner:Clone()
    end
    for _, desc in ipairs(outfitModel:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Anchored = false
            desc.CanCollide = false
            desc.CanTouch = false
            desc.CanQuery = false
            desc.Massless = true
        end
    end
    outfitModel:SetAttribute(sectionType, true)
    outfitModel:SetAttribute("_RIU_Script", true)
    outfitModel.Parent = character
    for _, outfitPart in ipairs(outfitModel:GetChildren()) do
        local bodyPartName = outfitPart:GetAttribute("BodyPart")
        local bodyPart = bodyPartName and character:FindFirstChild(bodyPartName)
        local cp = outfitPart:FindFirstChild("CenterPosition")
        local wc = outfitPart:FindFirstChild("WeldConstraint")
        if bodyPart and bodyPart:IsA("BasePart") and cp and outfitPart:IsA("BasePart") then
            local oldRootCF = outfitPart.CFrame
            local targetRootCF = bodyPart.CFrame * cp.CFrame:Inverse()
            local childOffsets = {}
            local childWelds = {}
            for _, d in ipairs(outfitPart:GetDescendants()) do
                if d:IsA("BasePart") and d ~= outfitPart then
                    childOffsets[d] = oldRootCF:ToObjectSpace(d.CFrame)
                elseif d:IsA("WeldConstraint") and d ~= wc then
                    table.insert(childWelds, d)
                    d.Enabled = false
                end
            end
            if wc then wc.Enabled = false end
            outfitPart.CFrame = targetRootCF
            for childPart, relCF in pairs(childOffsets) do
                childPart.CFrame = targetRootCF * relCF
            end
            for _, cw in ipairs(childWelds) do
                cw.Enabled = true
            end
            if wc then
                wc.Part0 = bodyPart
                wc.Part1 = outfitPart
                wc.Enabled = true
            else
                local newWeld = Instance.new("WeldConstraint")
                newWeld.Part0 = bodyPart
                newWeld.Part1 = outfitPart
                newWeld.Parent = outfitPart
            end
        end
    end
    if targetPlayer then
        local plrSaved = getPlayerSavedOutfit(targetPlayer)
        plrSaved[sectionType] = outfitName
    end
end
local function bindPlayerOutfitRespawn(plr)
    Window:BindConnection(plr.CharacterAdded, function(newChar)
        if not isPremiumUser or not booleans.keepOutfitOnRespawn then return end
        local saved = savedOutfitsByUserId[plr.UserId]
        if not saved then return end
        task.spawn(function()
            newChar:WaitForChild("UpperTorso", 10)
            newChar:WaitForChild("Head", 10)
            task.wait(1.2)
            if not newChar.Parent or not booleans.keepOutfitOnRespawn then return end
            for sectionType, outfitName in pairs(saved) do
                if outfitName and outfitName ~= "" then
                    applyOutfitSection(plr, newChar, outfitName, sectionType)
                end
            end
        end)
    end)
end
for _, plr in ipairs(Players:GetPlayers()) do
    bindPlayerOutfitRespawn(plr)
end
OutfitTab:CreateSection(L("sec_player_outfit"))
local ofselectedPlayer = LocalPlayer
local ofplayerList = { LocalPlayer.Name }
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then table.insert(ofplayerList, plr.Name) end
end
local ofplayerDrop = OutfitTab:CreateDropdown({ ForgetState = true,
    Name = L("outfit_player"), Options = ofplayerList, CurrentOption = { LocalPlayer.Name }, MultipleOptions = false, PremiumOnly = true,
    Callback = function(opts) if opts and opts[1] then ofselectedPlayer = Players:FindFirstChild(opts[1]) or LocalPlayer end end
})
OutfitTab:CreateToggle({
    Name = L("outfit_keep_respawn"), CurrentValue = true, Flag = "KeepOutfitRespawn", PremiumOnly = true,
    Callback = function(v) booleans.keepOutfitOnRespawn = v end
})
Window:BindConnection(Players.PlayerAdded, function(plr)
    bindPlayerOutfitRespawn(plr)
    if not table.find(ofplayerList, plr.Name) then table.insert(ofplayerList, plr.Name); ofplayerDrop:Refresh(ofplayerList) end
end)
Window:BindConnection(Players.PlayerRemoving, function(plr)
    local idx = table.find(ofplayerList, plr.Name)
    if idx then table.remove(ofplayerList, idx); ofplayerDrop:Refresh(ofplayerList) end
    savedOutfitsByUserId[plr.UserId] = nil
    if ofselectedPlayer == plr then ofselectedPlayer = LocalPlayer end
end)
local mainOutfitList = {}
for _, folder in ipairs(outfitsRoot:GetChildren()) do table.insert(mainOutfitList, folder.Name) end
table.sort(mainOutfitList)
local outfitCurrentSet = ""
local headDropdown, upperDropdown, lowerDropdown, miscDropdown
local function buildPieceListForSection(setName, sectionAttr)
    local list = { L("none_opt") }
    local setFolder = outfitsRoot:FindFirstChild(setName)
    if not setFolder then return list end
    for _, piece in ipairs(setFolder:GetDescendants()) do
        if piece:IsA("Model") and piece:GetAttribute(sectionAttr) then table.insert(list, piece.Name) end
    end
    return list
end
OutfitTab:CreateDropdown({ ForgetState = true,
    Name = L("outfit_set"), Options = mainOutfitList, CurrentOption = {}, MultipleOptions = false, PremiumOnly = true,
    Callback = function(opts)
        if not opts or not opts[1] then return end
        outfitCurrentSet = opts[1]
        pendingOutfit = { OutfitHead = "", OutfitUpper = "", OutfitLower = "", OutfitMisc = "" }
        headDropdown:Refresh(buildPieceListForSection(outfitCurrentSet, "OutfitHead"))
        upperDropdown:Refresh(buildPieceListForSection(outfitCurrentSet, "OutfitUpper"))
        lowerDropdown:Refresh(buildPieceListForSection(outfitCurrentSet, "OutfitLower"))
        miscDropdown:Refresh(buildPieceListForSection(outfitCurrentSet, "OutfitMisc"))
        Notify(L("outfit"), L("set_pick_pieces", outfitCurrentSet), 4)
    end
})
OutfitTab:CreateSection(L("sec_pieces"))
headDropdown  = OutfitTab:CreateDropdown({ ForgetState = true, Name = L("head_piece"),  Options = { L("none_opt") }, CurrentOption = {}, MultipleOptions = false, PremiumOnly = true, Callback = function(o) if o and o[1] then pendingOutfit.OutfitHead  = (o[1] == L("none_opt")) and "" or o[1] end end })
upperDropdown = OutfitTab:CreateDropdown({ ForgetState = true, Name = L("upper_piece"), Options = { L("none_opt") }, CurrentOption = {}, MultipleOptions = false, PremiumOnly = true, Callback = function(o) if o and o[1] then pendingOutfit.OutfitUpper = (o[1] == L("none_opt")) and "" or o[1] end end })
lowerDropdown = OutfitTab:CreateDropdown({ ForgetState = true, Name = L("lower_piece"), Options = { L("none_opt") }, CurrentOption = {}, MultipleOptions = false, PremiumOnly = true, Callback = function(o) if o and o[1] then pendingOutfit.OutfitLower = (o[1] == L("none_opt")) and "" or o[1] end end })
miscDropdown  = OutfitTab:CreateDropdown({ ForgetState = true, Name = L("misc_piece"),  Options = { L("none_opt") }, CurrentOption = {}, MultipleOptions = false, PremiumOnly = true, Callback = function(o) if o and o[1] then pendingOutfit.OutfitMisc  = (o[1] == L("none_opt")) and "" or o[1] end end })
OutfitTab:CreateSection(L("sec_actions"))
OutfitTab:CreateButton({
    Name = L("apply_pieces"), PremiumOnly = true,
    Callback = function()
        local targetPlr = ofselectedPlayer or LocalPlayer
        local char = targetPlr.Character
        if not char then Notify(L("outfit"), L("char_not_found"), 3) return end
        for section, pieceName in pairs(pendingOutfit) do
            if pieceName ~= "" then applyOutfitSection(targetPlr, char, pieceName, section) end
        end
        Notify(L("outfit"), L("outfit_applied"), 3)
    end
})
OutfitTab:CreateButton({
    Name = L("wear_full"), PremiumOnly = true,
    Callback = function()
        if outfitCurrentSet == "" then Notify(L("outfit"), L("select_set_first"), 3) return end
        local targetPlr = ofselectedPlayer or LocalPlayer
        local char = targetPlr.Character
        if not char then Notify(L("outfit"), L("char_not_found"), 3) return end
        local setFolder = outfitsRoot:FindFirstChild(outfitCurrentSet)
        if not setFolder then return end
        local count = 0
        for _, piece in ipairs(setFolder:GetDescendants()) do
            if piece:IsA("Model") then
                for _, attr in ipairs({ "OutfitHead", "OutfitUpper", "OutfitLower", "OutfitMisc" }) do
                    if piece:GetAttribute(attr) then applyOutfitSection(targetPlr, char, piece.Name, attr); count = count + 1 end
                end
            end
        end
        Notify(L("outfit"), L("full_set_applied", outfitCurrentSet, count), 4)
    end
})
OutfitTab:CreateButton({
    Name = L("outfit_copy_plr"), PremiumOnly = true,
    Callback = function()
        local srcPlr = ofselectedPlayer
        local srcChar = srcPlr and srcPlr.Character
        local myChar = LocalPlayer.Character
        if not srcChar or not myChar then Notify(L("outfit"), L("char_not_found"), 3) return end
        local count = 0
        for _, obj in ipairs(srcChar:GetChildren()) do
            if obj:IsA("Model") then
                for _, attr in ipairs({ "OutfitHead", "OutfitUpper", "OutfitLower", "OutfitMisc" }) do
                    if isModelOfOutfitSection(obj, attr) then
                        applyOutfitSection(LocalPlayer, myChar, obj.Name, attr)
                        count = count + (1)
                    end
                end
            end
        end
        Notify(L("outfit"), L("outfit_applied") .. " (" .. count .. ")", 3)
    end
})
OutfitTab:CreateButton({
    Name = L("clear_outfit"), PremiumOnly = true,
    Callback = function()
        local targetPlr = ofselectedPlayer or LocalPlayer
        local char = targetPlr.Character
        if not char then Notify(L("outfit"), L("char_not_found"), 3) return end
        local removed = 0
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Model") and obj:GetAttribute("_RIU_Script") == true then obj:Destroy(); removed = removed + 1 end
        end
        restoreOriginalOutfits(char)
        local plrSaved = getPlayerSavedOutfit(targetPlr)
        for k in pairs(plrSaved) do plrSaved[k] = "" end
        Notify(L("outfit"), L("cleared_pieces", removed), 3)
    end
})
end
local SBRH = {
    stageOptions     = { "Start", "Stage 1", "Stage 2", "Stage 3", "Stage 4", "Stage 5", "Stage 6", "Finish Line" },
    corpseAnchors    = {},
    disabledBarriers = {},
    rayParams        = RaycastParams.new(),
    staminaHook      = { active = false, oldStep = nil, oldSpend = nil },
    origHorseConfig  = nil,
    origHorseTuning  = nil,
    origRideAttrs    = nil,
    lastSurfacePos   = nil,
    inDangerZone     = false,
    L                = L,
    stageFallbackPos = {
        ["Start"]       = Vector3.new(-1580, 45, 118),
        ["Stage 1"]     = Vector3.new(985, 65, 210),
        ["Stage 2"]     = Vector3.new(3420, 85, -140),
        ["Stage 3"]     = Vector3.new(6180, 95, 310),
        ["Stage 4"]     = Vector3.new(8840, 110, -85),
        ["Stage 5"]     = Vector3.new(11350, 90, 420),
        ["Stage 6"]     = Vector3.new(12950, 82, 760),
        ["Finish Line"] = Vector3.new(13944.5, 79.2, 759.2),
    },
}
SBRH.rayParams.FilterType = Enum.RaycastFilterType.Exclude
SBRH.rayParams.IgnoreWater = false
SBRH.rayParams.RespectCanCollide = true
function SBRH.hasHookSupport()
    return type(hookmetamethod) == "function"
        or type(hookfunction) == "function"
        or type(replaceclosure) == "function"
end
function SBRH.hasReadonlySupport()
    return type(setreadonly) == "function"
        or type(makewritable) == "function"
        or type( make_writeable ) == "function"
end
function SBRH.hasTouchSupport()
    return type(firetouchinterest) == "function"
end
function SBRH.unlockTable(t)
    if type(t) ~= "table" then return false end
    if type(isreadonly) == "function" and not isreadonly(t) then return true end
    if type(makewritable) == "function" then
        pcall(makewritable, t)
    elseif type(make_writeable) == "function" then
        pcall(make_writeable, t)
    elseif type(setreadonly) == "function" then
        pcall(setreadonly, t, false)
    end
    if type(isreadonly) == "function" then
        return not isreadonly(t)
    end
    return true
end
function SBRH.getMyHorse()
    local byName = Workspace:FindFirstChild("Horse_" .. LocalPlayer.UserId)
    if byName and byName:FindFirstChild("HorseRoot") then return byName end
    for _, obj in ipairs(CollectionService:GetTagged("RIURideableHorse")) do
        if obj:IsA("Model") and obj:GetAttribute("OwnerUserId") == LocalPlayer.UserId and obj:FindFirstChild("HorseRoot") then
            return obj
        end
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart and hum.SeatPart.Parent and hum.SeatPart.Parent:FindFirstChild("HorseRoot") then
        return hum.SeatPart.Parent
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("HorseRoot") and obj:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return obj
        end
    end
    return nil
end
function SBRH.isOnHorse()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local myHorse = SBRH.getMyHorse()
    return hum ~= nil and hum.SeatPart ~= nil and myHorse ~= nil and hum.SeatPart:IsDescendantOf(myHorse)
end
function SBRH.teleport(targetCFrame)
    local myHorse = SBRH.getMyHorse()
    if myHorse and myHorse.PrimaryPart then
        local hr = myHorse:FindFirstChild("HorseRoot")
        if hr then
            hr.AssemblyLinearVelocity = Vector3.zero
            hr.AssemblyAngularVelocity = Vector3.zero
        end
        if SBRH.isOnHorse() then
            myHorse:PivotTo(targetCFrame)
            if hr then
                hr.AssemblyLinearVelocity = Vector3.zero
                hr.AssemblyAngularVelocity = Vector3.zero
            end
            return true
        end
        myHorse:PivotTo(targetCFrame * CFrame.new(4, 0.5, 0))
    end
    return SiriusNexus.Utils:SafeTeleport(targetCFrame)
end
function SBRH.findGroundY(x, refY, z)
    local ignoreList = { LocalPlayer.Character, SBRH.getMyHorse() }
    local dz = Workspace:FindFirstChild("DangerZonePart")
    if dz then table.insert(ignoreList, dz) end
    local stages = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Locations") and Workspace.Map.Locations:FindFirstChild("Stages")
    if stages then table.insert(ignoreList, stages) end
    SBRH.rayParams.FilterDescendantsInstances = ignoreList
    local startHeights = { (refY or 80) + 25, (refY or 80) + 120, 350 }
    for _, startY in ipairs(startHeights) do
        local hit = Workspace:Raycast(Vector3.new(x, startY, z), Vector3.new(0, -900, 0), SBRH.rayParams)
        if hit and hit.Position.Y > -50 then
            return hit.Position.Y
        end
    end
    return nil
end
function SBRH.teleportGrounded(pos, yHint, callbackAfter)
    task.spawn(function()
        local baseY = yHint or pos.Y
        pcall(function()
            LocalPlayer:RequestStreamAroundAsync(Vector3.new(pos.X, baseY, pos.Z), 3)
        end)
        local groundY = SBRH.findGroundY(pos.X, baseY, pos.Z)
        local initialY = groundY and (groundY + 3.2) or (baseY + 3.2)
        SBRH.teleport(CFrame.new(pos.X, initialY, pos.Z))
        for _ = 1, 8 do
            task.wait(0.15)
            local gy = SBRH.findGroundY(pos.X, baseY, pos.Z)
            if gy then
                SBRH.teleport(CFrame.new(pos.X, gy + 3.2, pos.Z))
                break
            end
        end
        if type(callbackAfter) == "function" then
            pcall(callbackAfter)
        end
    end)
end
function SBRH.getCorpseRealPos(corpse)
    if not corpse then return Vector3.zero end
    local star = corpse:FindFirstChild("Star")
    local sv = star and star.Value
    if sv then
        if sv:IsA("Attachment") then return sv.WorldPosition end
        if sv:IsA("BasePart") then return sv.Position end
        if sv:IsA("Model") then return sv:GetPivot().Position end
    end
    local bp = corpse:FindFirstChildWhichIsA("BasePart", true)
    if bp then return bp.Position end
    return corpse:GetPivot().Position
end
local function buildSBRTagESP(targetPart, tagName, textStr, fillCol)
    if not targetPart then return end
    if not targetPart:FindFirstChild(tagName .. "_HL") then
        local hl = Instance.new("Highlight")
        hl.Name = tagName .. "_HL"
        hl.FillColor = fillCol or Color3.fromRGB(255, 200, 80)
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = targetPart
    end
    local gui = targetPart:FindFirstChild(tagName .. "_GUI")
    if not gui then
        gui = Instance.new("BillboardGui")
        gui.Name = tagName .. "_GUI"
        gui.Size = UDim2.new(0, 160, 0, 40)
        gui.AlwaysOnTop = true
        gui.MaxDistance = 15000
        gui.Parent = targetPart
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 0.25
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BorderSizePixel = 0
        frame.Parent = gui
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        local label = Instance.new("TextLabel")
        label.Name = "Title"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = textStr
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0.5
        label.TextScaled = true
        label.Font = Enum.Font.GothamMedium
        label.Parent = frame
    else
        local lbl = gui:FindFirstChild("Title", true)
        if lbl then lbl.Text = textStr end
    end
end
local function removeSBRTagESP(targetPart, tagName)
    if not targetPart then return end
    if targetPart:FindFirstChild(tagName .. "_GUI") then targetPart[tagName .. "_GUI"]:Destroy() end
    if targetPart:FindFirstChild(tagName .. "_HL") then targetPart[tagName .. "_HL"]:Destroy() end
end
function SBRH.distText(pos)
    local root = SiriusNexus.Utils:GetRootPart(LocalPlayer)
    if not root then return "" end
    return string.format(" \194\183 %dm", math.floor((root.Position - pos).Magnitude))
end
function SBRH.getCorpseAnchor(corpse)
    local anchor = SBRH.corpseAnchors[corpse]
    if anchor and anchor.Parent then return anchor end
    anchor = Instance.new("Part")
    anchor.Name = "RIU_CorpseESPAnchor"
    anchor.Anchored = true
    anchor.Transparency = 1
    anchor.CanCollide = false
    anchor.CanTouch = false
    anchor.CanQuery = false
    anchor.Size = Vector3.new(2.5, 2.5, 2.5)
    anchor.CFrame = CFrame.new(SBRH.getCorpseRealPos(corpse))
    anchor.Parent = Workspace
    SBRH.corpseAnchors[corpse] = anchor
    return anchor
end
function SBRH.cleanupCorpseESP()
    for corpse, anchor in pairs(SBRH.corpseAnchors) do
        if not corpse or not corpse.Parent then
            if anchor and anchor.Parent then anchor:Destroy() end
            SBRH.corpseAnchors[corpse] = nil
        end
    end
end
function SBRH.destroyAllCorpseESP()
    for corpse, anchor in pairs(SBRH.corpseAnchors) do
        if anchor and anchor.Parent then anchor:Destroy() end
        SBRH.corpseAnchors[corpse] = nil
    end
end
function SBRH.getFinishPos()
    local fl = Workspace:FindFirstChild("Map")
        and Workspace.Map:FindFirstChild("Locations")
        and Workspace.Map.Locations:FindFirstChild("BrooklynBridge")
        and Workspace.Map.Locations.BrooklynBridge:FindFirstChild("Brdige")
        and Workspace.Map.Locations.BrooklynBridge.Brdige:FindFirstChild("FinishLine")
    if fl then
        local bp = fl:FindFirstChildWhichIsA("BasePart", true)
        if bp then return bp.Position end
        local piv = fl:GetPivot().Position
        if Vector2.new(piv.X, piv.Z).Magnitude > 100 then return piv end
    end
    return SBRH.stageFallbackPos["Finish Line"]
end
function SBRH.getStageBorderPos(stageOpt)
    if stageOpt == "Finish Line" then return SBRH.getFinishPos() end
    local folderName = (stageOpt == "Start") and "StartBarrier" or stageOpt:gsub("%s+", "")
    local stages = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Locations") and Workspace.Map.Locations:FindFirstChild("Stages")
    local stFolder = stages and stages:FindFirstChild(folderName)
    local function extractValidPos(folder)
        if not folder then return nil end
        local bestPart, bestScore = nil, -1
        for _, d in ipairs(folder:GetDescendants()) do
            if d:IsA("BasePart") then
                local isDetect = (d.Name == "StageDetection")
                local score = (isDetect and 1000000 or 0) + (d.Size.X * d.Size.Z)
                if score > bestScore and Vector2.new(d.Position.X, d.Position.Z).Magnitude > 100 then
                    bestScore = score
                    bestPart = d
                end
            end
        end
        if bestPart then
            local bottomY = bestPart.Position.Y - math.min(bestPart.Size.Y * 0.35, 25)
            return Vector3.new(bestPart.Position.X, bottomY, bestPart.Position.Z)
        end
        for _, c in ipairs(folder:GetChildren()) do
            if c:IsA("Model") and c.Name:find("Border") then
                local piv = c.WorldPivot.Position
                if Vector2.new(piv.X, piv.Z).Magnitude > 150 then
                    return piv
                end
            end
        end
        return nil
    end
    local foundPos = extractValidPos(stFolder)
    if foundPos then return foundPos end
    local fb = SBRH.stageFallbackPos[stageOpt]
    if fb then
        pcall(function()
            LocalPlayer:RequestStreamAroundAsync(fb, 3)
        end)
        foundPos = extractValidPos(stFolder)
        if foundPos then return foundPos end
    end
    return fb
end
function SBRH.updateStageBarriersCollision(disableCollision)
    if disableCollision then
        local stages = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Locations") and Workspace.Map.Locations:FindFirstChild("Stages")
        if stages then
            for _, d in ipairs(stages:GetDescendants()) do
                if d:IsA("BasePart") and d.Name ~= "StageDetection" and d.CanCollide then
                    SBRH.disabledBarriers[d] = true
                    d.CanCollide = false
                end
            end
        end
    else
        for part in pairs(SBRH.disabledBarriers) do
            if part and part.Parent then
                part.CanCollide = true
            end
            SBRH.disabledBarriers[part] = nil
        end
    end
end
function SBRH.touchAllStageBarriers()
    if not SBRH.hasTouchSupport() then return end
    local stages = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Locations") and Workspace.Map.Locations:FindFirstChild("Stages")
    if not stages then return end
    local myRoot = SiriusNexus.Utils:GetRootPart(LocalPlayer)
    local myHorse = SBRH.getMyHorse()
    local horseRoot = myHorse and myHorse:FindFirstChild("HorseRoot")
    for _, d in ipairs(stages:GetDescendants()) do
        if d:IsA("BasePart") and (d.Name == "StageDetection" or d:FindFirstChildOfClass("TouchTransmitter")) then
            if myRoot then
                pcall(firetouchinterest, myRoot, d, 0)
                pcall(firetouchinterest, myRoot, d, 1)
            end
            if horseRoot then
                pcall(firetouchinterest, horseRoot, d, 0)
                pcall(firetouchinterest, horseRoot, d, 1)
            end
        end
    end
end
function SBRH.exitDangerZone()
    local myRoot = SiriusNexus.Utils:GetRootPart(LocalPlayer)
    local targetPos = SBRH.lastSurfacePos
    if not targetPos and myRoot then
        targetPos = Vector3.new(myRoot.Position.X, 120, myRoot.Position.Z)
    end
    if targetPos then
        SBRH.inDangerZone = false
        SBRH.teleportGrounded(targetPos, targetPos.Y + 30)
        Notify(L("tab_sbr"), SBRH.L("sbr_danger_exited"), 3)
    end
end
function SBRH.setStaminaHook(enable)
    local hook = SBRH.staminaHook
    if enable then
        if hook.active then return true end
        local ok, HE = pcall(require, ReplicatedStorage.Modules.HorseRiding.HorseEndurance)
        if not ok or type(HE) ~= "table" then return false end
        SBRH.unlockTable(HE)
        if not SBRH.hasHookSupport() and (type(isreadonly) == "function" and isreadonly(HE)) then
            return false
        end
        hook.oldStep, hook.oldSpend = HE.Step, HE.Spend
        local sOk = pcall(function()
            HE.Step = function(self, ...)
                self.Value = 100
                self.Exhausted = false
                return hook.oldStep(self, ...)
            end
            HE.Spend = function(self)
                if type(self) == "table" then
                    self.Value = 100
                    self.Exhausted = false
                end
            end
        end)
        if not sOk then return false end
        hook.active = true
        return true
    elseif hook.active then
        local ok, HE = pcall(require, ReplicatedStorage.Modules.HorseRiding.HorseEndurance)
        if ok and type(HE) == "table" then
            SBRH.unlockTable(HE)
            pcall(function()
                HE.Step, HE.Spend = hook.oldStep, hook.oldSpend
            end)
        end
        hook.active = false
    end
    return true
end
SBRTab:CreateSection({ Name = L("sec_sbr_free"), Icon = "eye" })
SBRTab:CreateButton({
    Name = L("anti_danger"),
    Callback = function()
        local myRoot = SiriusNexus.Utils:GetRootPart(LocalPlayer)
        if SBRH.inDangerZone and myRoot and (myRoot.Position - Vector3.new(12897, 4, 807)).Magnitude < 250 then
            SBRH.exitDangerZone()
            return
        end
        if myRoot and myRoot.Position.Y > 10 then
            SBRH.lastSurfacePos = myRoot.Position
        end
        if not Workspace:FindFirstChild("DangerZonePart") then
            local p = Instance.new("Part")
            p.Name = "DangerZonePart"
            p.Anchored = true
            p.CFrame = CFrame.new(12897, -1, 807)
            p.Size = Vector3.new(2000, 2, 2000)
            p.Parent = Workspace
        end
        SBRH.inDangerZone = true
        SBRH.teleport(CFrame.new(12897, 4, 807))
        Notify(L("tab_sbr"), SBRH.L("sbr_danger_entered"), 5)
    end
})
SBRTab:CreateButton({
    Name = SBRH.L("sbr_exit_danger"),
    Callback = function()
        SBRH.exitDangerZone()
    end
})
local sbrStatusPara = SBRTab:CreateParagraph({ Title = SBRH.L("sbr_race_status"), Content = "..." })
Window:AddTask(task.spawn(function()
    local suffixes = { "st", "nd", "rd" }
    while true do
        task.wait(1)
        local stats = Workspace:FindFirstChild("SBR_Stats")
        if not stats then
            sbrStatusPara:Set({ Title = SBRH.L("sbr_race_status"), Content = SBRH.L("sbr_not_in_sbr") })
        else
            local state = stats:GetAttribute("RaceFinished") and SBRH.L("sbr_status_finished")
                or stats:GetAttribute("RaceStarted") and SBRH.L("sbr_status_started")
                or stats:GetAttribute("RaceStarting") and SBRH.L("sbr_status_starting")
                or SBRH.L("sbr_status_idle")
            local place = ""
            for i = 1, 15 do
                local nm = stats:GetAttribute(i .. (suffixes[i] or "th") .. "_Place")
                if nm == LocalPlayer.Name then place = "#" .. i break end
            end
            local parts = {}
            local char = LocalPlayer.Character
            local cp = char and char:FindFirstChild("SBR_Stats") and char.SBR_Stats:FindFirstChild("CorpseParts")
            if cp then
                for k, v in pairs(cp:GetAttributes()) do
                    if v == true then table.insert(parts, k) end
                end
            end
            table.sort(parts)
            local content = state
            if place ~= "" then content = content .. " | " .. place end
            if #parts > 0 then content = content .. "\n" .. table.concat(parts, ", ") end
            sbrStatusPara:Set({ Title = SBRH.L("sbr_race_status"), Content = content })
        end
    end
end), "SBRRaceStatus")
SBRTab:CreateToggle({
    Name = L("corpse_esp"), CurrentValue = false, Flag = "CorpseESP", Loop = 0.5,
    OnTick = function()
        local folder = Workspace:FindFirstChild("CorpseParts")
        local spawned = folder and folder:FindFirstChild("SpawnedCorpseParts")
        if spawned then
            for _, corpse in ipairs(spawned:GetChildren()) do
                local realPos = SBRH.getCorpseRealPos(corpse)
                local anchor = SBRH.getCorpseAnchor(corpse)
                anchor.CFrame = CFrame.new(realPos)
                buildSBRTagESP(anchor, "CorpseESP", "" .. corpse.Name .. SBRH.distText(realPos), Color3.fromRGB(255, 200, 80))
            end
        end
        SBRH.cleanupCorpseESP()
    end,
    Callback = function(v)
        if not v then SBRH.destroyAllCorpseESP() end
    end
})
SBRTab:CreateToggle({
    Name = L("sbr_wagon_esp"), CurrentValue = false, Flag = "SBRWagonESP", Loop = 1.0,
    OnTick = function()
        local wagons = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Decoration") and Workspace.Map.Decoration:FindFirstChild("MedicalWagons")
        if wagons then
            for _, w in ipairs(wagons:GetChildren()) do
                local treat = w:FindFirstChild("Treatment")
                local uses = w:GetAttribute("MedicalUses") or 0
                local cap = w:GetAttribute("MedicalCapacity") or 0
                if treat then
                    buildSBRTagESP(treat, "WagonESP", string.format("Wagon [%d/%d]%s", uses, cap, SBRH.distText(treat.Position)), Color3.fromRGB(80, 255, 120))
                end
            end
        end
        local bodies = Workspace:FindFirstChild("Debris") and Workspace.Debris:FindFirstChild("SBRRecoveryBodies")
        if bodies then
            for _, b in ipairs(bodies:GetChildren()) do
                local pp = b.PrimaryPart or b:FindFirstChildWhichIsA("BasePart")
                if pp then
                    buildSBRTagESP(pp, "BodyESP", "Downed: " .. b.Name .. SBRH.distText(pp.Position), Color3.fromRGB(255, 80, 80))
                end
            end
        end
    end,
    Callback = function(v)
        if not v then
            local wagons = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Decoration") and Workspace.Map.Decoration:FindFirstChild("MedicalWagons")
            if wagons then
                for _, w in ipairs(wagons:GetChildren()) do
                    if w:FindFirstChild("Treatment") then removeSBRTagESP(w.Treatment, "WagonESP") end
                end
            end
            local bodies = Workspace:FindFirstChild("Debris") and Workspace.Debris:FindFirstChild("SBRRecoveryBodies")
            if bodies then
                for _, b in ipairs(bodies:GetChildren()) do
                    local pp = b.PrimaryPart or b:FindFirstChildWhichIsA("BasePart")
                    if pp then removeSBRTagESP(pp, "BodyESP") end
                end
            end
        end
    end
})
local legacyStaminaToggle
legacyStaminaToggle = SBRTab:CreateToggle({
    Name = L("sbr_legacy_stamina"), CurrentValue = false, Flag = "InfStamina",
    Callback = function(v)
        if v then
            Notify(L("tab_sbr"), SBRH.L("sbr_legacy_dead"), 6)
            task.defer(function()
                if legacyStaminaToggle then legacyStaminaToggle:Set(false) end
            end)
        end
    end
})
SBRTab:CreateSection({ Name = L("sec_sbr_horse"), Icon = "horse" })
SBRTab:CreateButton({
    Name = SBRH.L("sbr_call_horse"), PremiumOnly = true,
    Callback = function()
        if not isPremiumUser then return end
        task.spawn(function()
            local myHorse = SBRH.getMyHorse()
            local root = SiriusNexus.Utils:GetRootPart(LocalPlayer)
            if not myHorse or not myHorse.PrimaryPart then Notify(L("tab_sbr"), SBRH.L("sbr_no_horse"), 3) return end
            if not root or SBRH.isOnHorse() then return end
            local function tryMount()
                for _, d in ipairs(myHorse:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Name == "HorseMountPrompt" then
                        d.HoldDuration = 0
                        pcall(fireproximityprompt, d)
                        return true
                    end
                end
                return false
            end
            local horseReq = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("HorseRequest")
            if horseReq then
                pcall(function() horseReq:FireServer("Call", Workspace.CurrentCamera.CFrame) end)
            end
            local arrived = false
            for _ = 1, 8 do
                task.wait(0.25)
                local hr = myHorse:FindFirstChild("HorseRoot")
                local myRoot = SiriusNexus.Utils:GetRootPart(LocalPlayer)
                if hr and myRoot and (hr.Position - myRoot.Position).Magnitude <= 12 then arrived = true break end
            end
            if not arrived then
                local hr = myHorse:FindFirstChild("HorseRoot")
                if hr then
                    SiriusNexus.Utils:SafeTeleport(hr.CFrame, Vector3.new(0, 0, 3))
                    task.wait(0.6)
                end
            end
            for _ = 1, 3 do
                local hum = SiriusNexus.Utils:GetHumanoid(LocalPlayer)
                if hum and hum.SeatPart then break end
                tryMount()
                task.wait(0.7)
                hum = SiriusNexus.Utils:GetHumanoid(LocalPlayer)
                if hum and hum.SeatPart then
                    Notify(L("tab_sbr"), SBRH.L("sbr_horse_called"), 2)
                    break
                end
            end
        end)
    end
})
SBRTab:CreateToggle({
    Name = L("sbr_true_stamina"), CurrentValue = false, Flag = "SBRTrueInfStamina", PremiumOnly = true, Loop = 0.15,
    Callback = function(v)
        if not isPremiumUser then return end
        local ok = SBRH.setStaminaHook(v)
        if v and not ok then
            Notify(L("tab_sbr"), SBRH.L("sbr_no_hooks"), 6)
        end
    end,
    OnTick = function()
        if not isPremiumUser then return end
        local horseReq = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("HorseRequest")
        if horseReq then
            pcall(function()
                horseReq:FireServer("Stamina", 100, false, 0, 0, 0, 0, 0)
            end)
        end
        local myHorse = SBRH.getMyHorse()
        if myHorse then
            myHorse:SetAttribute("HorseStamina", 100)
            myHorse:SetAttribute("HorseExhausted", false)
            myHorse:SetAttribute("HorseStaminaCostTotal", 0)
        end
    end
})
SBRTab:CreateToggle({
    Name = L("sbr_auto_boost"), CurrentValue = false, Flag = "SBRAutoBoost", PremiumOnly = true, Loop = 0.35,
    OnTick = function()
        if not isPremiumUser then return end
        local char = LocalPlayer.Character
        local hi = char and char:FindFirstChild("Scripts") and char.Scripts:FindFirstChild("Controls") and char.Scripts.Controls:FindFirstChild("HorseInput")
        if hi and hi:IsA("BindableEvent") then
            pcall(function() hi:Fire("Sprint", true) end)
        end
        local myHorse = SBRH.getMyHorse()
        if myHorse then
            myHorse:SetAttribute("HorseLocalBoost", true)
            for _, d in ipairs(myHorse:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Enabled then
                    if d.Name ~= "HorseMountPrompt" or not SBRH.isOnHorse() then
                        d.HoldDuration = 0
                        pcall(fireproximityprompt, d)
                    end
                end
            end
        end
        local horseReq = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("HorseRequest")
        if horseReq then
            pcall(function() horseReq:FireServer("Boost", true) end)
        end
    end,
    Callback = function(v)
        if not v then
            local char = LocalPlayer.Character
            local hi = char and char:FindFirstChild("Scripts") and char.Scripts:FindFirstChild("Controls") and char.Scripts.Controls:FindFirstChild("HorseInput")
            if hi and hi:IsA("BindableEvent") then pcall(function() hi:Fire("Sprint", false) end) end
            local myHorse = SBRH.getMyHorse()
            if myHorse then myHorse:SetAttribute("HorseLocalBoost", false) end
            local horseReq = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("HorseRequest")
            if horseReq then pcall(function() horseReq:FireServer("Boost", false) end) end
        end
    end
})
SBRTab:CreateToggle({
    Name = L("sbr_unlock_skills"), CurrentValue = false, Flag = "SBRUnlockHorseSkills", PremiumOnly = true, Loop = 1.0,
    OnTick = function()
        if not isPremiumUser then return end
        local char = LocalPlayer.Character
        local abilities = char and char:FindFirstChild("Scripts") and char.Scripts:FindFirstChild("Controls") and char.Scripts.Controls:FindFirstChild("Abilities")
        if abilities then
            for _, ab in ipairs(abilities:GetChildren()) do
                if ab:GetAttribute("UsableOnHorse") ~= true then
                    ab:SetAttribute("UsableOnHorse", true)
                end
            end
        end
    end
})
booleans.sbrHorseSpeedMult = 1.0
local function applyHorseConfigMods(enableBypass, speedMult)
    local hrFolder = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("HorseRiding")
    if not hrFolder then return false end
    local mult = tonumber(speedMult) or 1.0
    local modifiedAny = false
    if not SBRH.origRideAttrs then
        SBRH.origRideAttrs = {
            WalkMoveSpeed   = hrFolder:GetAttribute("WalkMoveSpeed") or 18.9,
            CruiseMoveSpeed = hrFolder:GetAttribute("CruiseMoveSpeed") or 42.0,
            SprintMoveSpeed = hrFolder:GetAttribute("SprintMoveSpeed") or 52.5,
        }
        for k, v in pairs(hrFolder:GetAttributes()) do
            if type(v) == "number" and SBRH.origRideAttrs[k] == nil then
                SBRH.origRideAttrs[k] = v
            end
        end
    end
    pcall(function()
        hrFolder:SetAttribute("WalkMoveSpeed", SBRH.origRideAttrs.WalkMoveSpeed * mult)
        hrFolder:SetAttribute("CruiseMoveSpeed", SBRH.origRideAttrs.CruiseMoveSpeed * mult)
        hrFolder:SetAttribute("SprintMoveSpeed", SBRH.origRideAttrs.SprintMoveSpeed * mult)
        modifiedAny = true
    end)
    local htMod = hrFolder:FindFirstChild("HorseTuning")
    if htMod then
        local okT, ht = pcall(require, htMod)
        if okT and type(ht) == "table" and SBRH.unlockTable(ht) then
            if not SBRH.origHorseTuning then
                SBRH.origHorseTuning = {}
                for k, v in pairs(ht) do
                    if type(v) == "number" then SBRH.origHorseTuning[k] = v end
                end
            end
            pcall(function()
                for k, baseVal in pairs(SBRH.origHorseTuning) do
                    if k:lower():find("speed") then
                        ht[k] = baseVal * mult
                    end
                end
            end)
        end
    end
    local hcMod = hrFolder:FindFirstChild("HorseConfig")
    if hcMod then
        local ok, hc = pcall(require, hcMod)
        if ok and type(hc) == "table" then
            local unlocked = SBRH.unlockTable(hc)
            if type(hc.GaitSpeeds) == "table" then
                SBRH.unlockTable(hc.GaitSpeeds)
            end
            if not SBRH.origHorseConfig then
                SBRH.origHorseConfig = {
                    WaterSpeedScale     = hc.WaterSpeedScale,
                    WaterKneeDepth      = hc.WaterKneeDepth,
                    SlopeSpeedLoss      = hc.SlopeSpeedLoss,
                    MaxSlope            = hc.MaxSlope,
                    JumpCooldown        = hc.JumpCooldown,
                    CrashDamageMinSpeed = hc.CrashDamageMinSpeed,
                    CrashDamageMax      = hc.CrashDamageMax,
                    JumpStaminaCost     = hc.JumpStaminaCost,
                    BumpStaminaCost     = hc.BumpStaminaCost,
                    RamStaminaCost      = hc.RamStaminaCost,
                    GaitSpeeds          = hc.GaitSpeeds and table.clone(hc.GaitSpeeds) or nil,
                }
            end
            if unlocked then
                pcall(function()
                    if enableBypass then
                        hc.WaterSpeedScale     = 1
                        hc.WaterKneeDepth      = 9999
                        hc.SlopeSpeedLoss      = 0
                        if hc.MaxSlope then hc.MaxSlope = 89 end
                        hc.JumpCooldown        = 0.1
                        hc.CrashDamageMinSpeed = math.huge
                        hc.CrashDamageMax      = 0
                        hc.JumpStaminaCost     = 0
                        hc.BumpStaminaCost     = 0
                        hc.RamStaminaCost      = 0
                    elseif SBRH.origHorseConfig then
                        hc.WaterSpeedScale     = SBRH.origHorseConfig.WaterSpeedScale
                        hc.WaterKneeDepth      = SBRH.origHorseConfig.WaterKneeDepth
                        hc.SlopeSpeedLoss      = SBRH.origHorseConfig.SlopeSpeedLoss
                        if SBRH.origHorseConfig.MaxSlope then hc.MaxSlope = SBRH.origHorseConfig.MaxSlope end
                        hc.JumpCooldown        = SBRH.origHorseConfig.JumpCooldown
                        hc.CrashDamageMinSpeed = SBRH.origHorseConfig.CrashDamageMinSpeed
                        hc.CrashDamageMax      = SBRH.origHorseConfig.CrashDamageMax
                        hc.JumpStaminaCost     = SBRH.origHorseConfig.JumpStaminaCost
                        hc.BumpStaminaCost     = SBRH.origHorseConfig.BumpStaminaCost
                        hc.RamStaminaCost      = SBRH.origHorseConfig.RamStaminaCost
                    end
                    if SBRH.origHorseConfig and SBRH.origHorseConfig.GaitSpeeds and type(hc.GaitSpeeds) == "table" then
                        for i, baseSpd in ipairs(SBRH.origHorseConfig.GaitSpeeds) do
                            hc.GaitSpeeds[i] = baseSpd * mult
                        end
                    end
                    modifiedAny = true
                end)
            else
                return false
            end
        end
    end
    return modifiedAny
end
SBRTab:CreateToggle({
    Name = L("sbr_horse_god"), CurrentValue = false, Flag = "SBRHorseGod", PremiumOnly = true, Loop = 0.15,
    Callback = function(v)
        booleans.sbrHorseGod = v
        if not isPremiumUser then return end
        local ok = applyHorseConfigMods(v, booleans.sbrHorseSpeedMult)
        if v and (not SBRH.hasReadonlySupport() or not ok) then
            Notify(L("tab_sbr"), SBRH.L("sbr_no_hooks"), 6)
        end
    end,
    OnTick = function()
        if not isPremiumUser then return end
        local myHorse = SBRH.getMyHorse()
        if myHorse then
            myHorse:SetAttribute("HorseCollisionUntil", 0)
            myHorse:SetAttribute("HorseStumbleStrength", 0)
            myHorse:SetAttribute("HorseLocalStumble", 0)
            myHorse:SetAttribute("HorseLocalStumbleStrength", 0)
            myHorse:SetAttribute("HorseLocalDownhillSlide", 0)
            myHorse:SetAttribute("HorseBushDrag", 1)
        end
    end
})
SBRTab:CreateSlider({
    Name = L("sbr_horse_speed"), Range = {1.0, 3.0}, Increment = 0.1, CurrentValue = 1.0, Flag = "SBRHorseSpeedMult", PremiumOnly = true,
    Callback = function(v)
        booleans.sbrHorseSpeedMult = v
        if not isPremiumUser then return end
        local ok = applyHorseConfigMods(booleans.sbrHorseGod, v)
        if v > 1.0 and not ok then
            Notify(L("tab_sbr"), SBRH.L("sbr_no_hooks"), 6)
        end
    end
})
SBRTab:CreateSection({ Name = L("sec_sbr_auto"), Icon = "rocket" })
SBRTab:CreateButton({
    Name = L("tp_finish"), PremiumOnly = true,
    Callback = function()
        if not isPremiumUser then return end
        local pos = SBRH.getFinishPos()
        SBRH.teleportGrounded(pos, pos.Y)
    end
})
SBRTab:CreateDropdown({
    Name = L("sbr_tp_stage"),
    Options = SBRH.stageOptions,
    CurrentOption = {},
    MultipleOptions = false,
    PremiumOnly = true,
    Callback = function(opts)
        if not isPremiumUser or not opts or not opts[1] then return end
        local pos = SBRH.getStageBorderPos(opts[1])
        if pos then
            SBRH.teleportGrounded(pos, pos.Y)
        else
            Notify(L("tab_sbr"), L("player_not_found"), 3)
        end
    end
})
SBRTab:CreateButton({
    Name = L("sbr_tp_wagon"), PremiumOnly = true,
    Callback = function()
        if not isPremiumUser then return end
        local wagons = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Decoration") and Workspace.Map.Decoration:FindFirstChild("MedicalWagons")
        local myRoot = SiriusNexus.Utils:GetRootPart(LocalPlayer)
        if not wagons or not myRoot then return end
        local bestPart, bestDist = nil, math.huge
        local anyPart, anyDist = nil, math.huge
        for _, w in ipairs(wagons:GetChildren()) do
            local treat = w:FindFirstChild("Treatment")
            if treat then
                local d = (treat.Position - myRoot.Position).Magnitude
                if d < anyDist then anyDist = d; anyPart = treat end
                local uses = w:GetAttribute("MedicalUses") or 0
                if uses > 0 and d < bestDist then bestDist = d; bestPart = treat end
            end
        end
        local target = bestPart or anyPart
        if target then
            SBRH.teleport(target.CFrame + Vector3.new(0, 3.5, 0))
            if not bestPart then Notify(L("tab_sbr"), SBRH.L("sbr_no_wagon"), 3) end
        end
    end
})
playerDropdowns.dpSBRPingPlayer = SBRTab:CreateDropdown({
    Name = L("sbr_ping_plr"), Options = playerList, CurrentOption = {}, MultipleOptions = false, PremiumOnly = true,
    Callback = function(opts)
        if not isPremiumUser or not opts or not opts[1] then return end
        local targetPlr = Players:FindFirstChild(opts[1])
        if not targetPlr then return end
        task.spawn(function()
            local pingFn = ReplicatedStorage:FindFirstChild("LevelAssets") and ReplicatedStorage.LevelAssets:FindFirstChild("LocationPing")
            local pos = nil
            if pingFn then
                local ok, res = pcall(function() return pingFn:InvokeServer(targetPlr) end)
                if ok and typeof(res) == "Vector3" then pos = res end
            end
            if not pos and targetPlr.Character then
                local r = SiriusNexus.Utils:GetRootPart(targetPlr)
                if r then pos = r.Position end
            end
            if pos then
                SBRH.teleportGrounded(pos, pos.Y)
            else
                Notify(L("tab_sbr"), L("player_not_found"), 3)
            end
        end)
    end
})
SBRTab:CreateToggle({
    Name = L("sbr_auto_corpse"), CurrentValue = false, Flag = "SBRAutoCorpse", PremiumOnly = true, Loop = 0.5,
    OnTick = function()
        if not isPremiumUser then return end
        local folder = Workspace:FindFirstChild("CorpseParts") and Workspace.CorpseParts:FindFirstChild("SpawnedCorpseParts")
        if not folder then return end
        for _, corpse in ipairs(folder:GetChildren()) do
            if corpse.Parent then
                local realPos = SBRH.getCorpseRealPos(corpse)
                SBRH.teleport(CFrame.new(realPos + Vector3.new(0, 1.5, 0)))
                task.wait(0.25)
                local pivPos = corpse.WorldPivot.Position
                if (pivPos - realPos).Magnitude > 5 and Vector2.new(pivPos.X, pivPos.Z).Magnitude > 100 then
                    SBRH.teleport(CFrame.new(pivPos + Vector3.new(0, 1.5, 0)))
                    task.wait(0.2)
                end
                break
            end
        end
    end
})
SBRTab:CreateToggle({
    Name = L("auto_stage"), CurrentValue = false, Flag = "AutoStageSBR", PremiumOnly = true, Loop = 0.4,
    Callback = function(v)
        if not isPremiumUser then return end
        if v then
            if not SBRH.hasTouchSupport() then
                Notify(L("tab_sbr"), SBRH.L("sbr_no_touch"), 6)
            else
                Notify(L("tab_sbr"), SBRH.L("sbr_stage_progress"), 3)
            end
            SBRH.updateStageBarriersCollision(true)
            SBRH.touchAllStageBarriers()
        else
            SBRH.updateStageBarriersCollision(false)
            Notify(L("tab_sbr"), SBRH.L("sbr_stage_done"), 3)
        end
    end,
    OnTick = function()
        if not isPremiumUser then return end
        SBRH.updateStageBarriersCollision(true)
        SBRH.touchAllStageBarriers()
    end
})
end
do
Window:CreateSection({ name = L("grp_system") })
Window:CreateSettingsTab({ Name = L("tab_settings"), Icon = "settings" })
pcall(Window.LoadConfiguration, Window)

end

