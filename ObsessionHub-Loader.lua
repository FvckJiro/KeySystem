--[[
    ██████  ██████  ███████ ███████ ███████ ███████ ██  ██████  ███    ██
   ██    ██ ██   ██ ██      ██      ██      ██      ██ ██    ██ ████   ██
   ██    ██ ██████  ███████ █████   ███████ ███████ ██ ██    ██ ██ ██  ██
   ██    ██ ██   ██      ██ ██           ██      ██ ██ ██    ██ ██  ██ ██
    ██████  ██████  ███████ ███████ ███████ ███████ ██  ██████  ██   ████
                        O B S E S S I O N   H U B   —   L O A D E R

   HOW TO USE
   1) Upload this file to GitHub (or Pastebin raw) and give users this one line:
        loadstring(game:HttpGet("https://raw.githubusercontent.com/YOU/REPO/main/ObsessionHub-Loader.lua"))()
   2) Edit the CONFIG block below: your website URL, links, and your scripts.
   3) That's it — the loader shows a key window, checks the key against your
      website, binds it to the device (HWID), then loads the chosen script.

   Your website stays key-only: this loader talks to it ONLY at /check-key.
   The actual scripts are fetched from the GitHub raw links you set below.
]]

--========================[ CONFIG — EDIT THIS ]========================--
local Config = {
    Website   = "https://obsessionhub.vercel.app",      -- your key site (NO trailing slash)
    GetKeyURL = "https://obsessionhub.vercel.app/getkey", -- where users get a key

    -- Base folder (raw) where your script files live. Each script below just uses its file name,
    -- so you don't paste a long raw link every time. CHANGE "KeySystem" if your repo has another name.
    ScriptBase = "https://raw.githubusercontent.com/LazyJiroHub/KeySystem/refs/heads/main/src/",
    Discord   = "https://discord.gg/D8SM7VfTKZ",      -- "" to hide the button
    Youtube   = "https://www.youtube.com/@jirombv",    -- "" to hide the button
    Premium   = "https://discord.gg/blackcloverhub",      -- Buy Premium link ("" to hide)

    RememberKey = true,   -- save the key on this device so users don't retype it
    CloseAfterLoad = true, -- close the window after a script loads

    -- Kick the player when their key expires or gets revoked while playing
    KickOnExpire = true,
    RecheckSeconds = 30, -- how often to re-check the key in the background (seconds)

    -- Your scripts. The loader auto-detects the game by its Place ID and loads the match.
    --   name        = shown in the loader
    --   url         = GitHub raw link to the .lua script
    --   requiresKey = true -> needs a valid key, false -> free/no key
    --   placeIds    = { } Roblox Place IDs this script supports (a game can have several)
    --   universal   = true -> used for ANY game when no specific script matches
    -- To find a Place ID: open the game's Roblox page, the number in the URL
    -- (roblox.com/games/XXXXXXXXXX/...) is the Place ID.
    -- "file" = the script's file name inside your src/ folder (added onto ScriptBase above).
    -- placeIds = { <Place ID>, <Universe ID> } -- the loader matches either one.
    Scripts = {
        { name = "TS",   file = "TSR.lua",  requiresKey = true,  placeIds = { 72858262610964, 10629695169 } },
        { name = "DB",   file = "DB.lua",   requiresKey = false, placeIds = { 15002061926, 5166944221 } },
        { name = "BASAE", file = "BASE.lua", requiresKey = false, placeIds = { 114326934417838, 10765288803 } },
        { name = "AD",   file = "AD.lua",   requiresKey = false, placeIds = { 113290951185459, 10708913337 } },
        { name = "KAU",  file = "KAU.lua",  requiresKey = false, placeIds = { 74968636725538, 10759415852 } },
        { name = "DG",   file = "DG.lua",   requiresKey = false, placeIds = { 94217045453265, 9051406594 } },
        { name = "SAE",  file = "SAE.lua",  requiresKey = false, placeIds = { 107778070777162, 10563114921 } },
        { name = "SF",   file = "SF.lua",   requiresKey = false, placeIds = { 109020905733214, 9187332740 } },
        { name = "RAP",  file = "RAP.lua",  requiresKey = false, placeIds = { 124216119978534, 10035204815 } },
        { name = "DF",   file = "DF.lua",   requiresKey = false, placeIds = { 132239307080610, 10526853622 } },
        { name = "GF",   file = "GF.lua",   requiresKey = false, placeIds = { 75687962646869, 10766957927 } },
        { name = "VS",   file = "VS.lua",   requiresKey = true,  placeIds = { 100283815455755, 9224753153 } },
        { name = "PD",   file = "PD.lua",   requiresKey = true,  placeIds = { 7336302630, 2862098693 } },
        { name = "LTF",  file = "LTF.lua",  requiresKey = true,  placeIds = { 118805555015549, 10684750879 } },
        { name = "AH",   file = "AH.lua",   requiresKey = true,  placeIds = { 10148749921, 78515283254292 } },
        { name = "BFE",  file = "BFE.lua",  requiresKey = true,  placeIds = { 74023858073178, 10766620257 } },
        { name = "IV",   file = "IV.lua",   requiresKey = true,  placeIds = { 8356562067 } },
        { name = "RASM",   file = "RASM.lua",   requiresKey = true,  placeIds = { 115068315659966, 10765938934 } },
        { name = "TFFA", file = "TFFA.lua", requiresKey = false, placeIds = { 120219252362013 } }
    },

    -- Optional image shown at the top of the loader. Use YOUR OWN art.
    -- Upload it to Roblox as a Decal, then put its id here, e.g. "rbxassetid://1234567890".
    -- Leave "" for no image (the animated header still looks great).
    BannerImage = "",

    -- Round logo in the top-left of the key window (your eyes image).
    -- Loads your eye image from GitHub (LogoURL below).
    -- (Works on executors with getcustomasset, e.g. Delta.) Leave "" to turn off.
    LogoURL = "https://raw.githubusercontent.com/FvckJiro/KeySystem/refs/heads/main/image/6qeLKYAAAAGSURBVAMAv2cDw5erKM4AAAAASUVORK5CYII.png",
    -- OPTIONAL: a Roblox decal instead, e.g. "rbxassetid://1234567890" (used first if set).
    LogoImage = "",
}
--======================================================================--

--// Services
local Players        = game:GetService("Players")
local HttpService    = game:GetService("HttpService")
local UserInput      = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local CoreGui        = game:GetService("CoreGui")
local LocalPlayer    = Players.LocalPlayer

--// Theme (matches the ObsessionHub website)
local T = {
    bg      = Color3.fromRGB(14, 14, 14),
    panel   = Color3.fromRGB(22, 22, 22),
    stroke  = Color3.fromRGB(60, 60, 60),
    red     = Color3.fromRGB(255, 255, 255),
    red2    = Color3.fromRGB(255, 255, 255),
    violet  = Color3.fromRGB(255, 255, 255),
    blue    = Color3.fromRGB(255, 255, 255),
    cyan    = Color3.fromRGB(255, 255, 255),
    text    = Color3.fromRGB(245, 234, 236),
    muted   = Color3.fromRGB(150, 150, 150),
    good    = Color3.fromRGB(110, 231, 164),
    bad     = Color3.fromRGB(255, 92, 92),
}

--// Small helpers ------------------------------------------------------
local KEY_PATTERN = "^%u%u%u+%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w$" -- any UPPERCASE prefix (OBSESSION, PREMIUM, ...)

local function notify(title, text, dur)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title, Text = text, Duration = dur or 4,
        })
    end)
end

-- Pick whatever HTTP request function this executor provides
local requestFn = (syn and syn.request)
    or (http and http.request)
    or http_request
    or (fluxus and fluxus.request)
    or request
local function httpRequest(opts)
    if requestFn then return requestFn(opts) end
    error("Your executor has no HTTP request function")
end

-- Clipboard shim (for Get Key / Discord buttons)
local setClip = (setclipboard or toclipboard or (syn and syn.write_clipboard)) or function() end

-- A stable per-device id (HWID)
local function getHWID()
    local ok, id
    ok, id = pcall(function() if gethwid then return gethwid() end end)
    if ok and id and #tostring(id) >= 4 then return tostring(id) end
    ok, id = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
    if ok and id and #tostring(id) >= 4 then return tostring(id) end
    -- last resort: stable-ish fallback
    return "UID-" .. tostring(LocalPlayer and LocalPlayer.UserId or "0")
end

-- Key persistence (only if the executor has file APIs)
local KEY_FILE = "ObsessionHub_key.txt"
local function saveKey(k)
    if Config.RememberKey and writefile then pcall(writefile, KEY_FILE, k) end
end
local function loadSavedKey()
    if Config.RememberKey and isfile and readfile and isfile(KEY_FILE) then
        local ok, v = pcall(readfile, KEY_FILE)
        if ok then return v end
    end
    return ""
end

-- Ask the website whether a key is valid for this device
local function verifyKey(key)
    key = tostring(key or ""):gsub("%s+", ""):upper()
    if not key:match(KEY_PATTERN) then
        return false, "Wrong key format"
    end
    local body = HttpService:JSONEncode({ key = key, hwid = getHWID() })
    local res
    local ok = pcall(function()
        res = httpRequest({
            Url = Config.Website .. "/check-key",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = body,
        })
    end)
    if not ok or not res then return false, "Can't reach the server" end
    if res.StatusCode and (res.StatusCode < 200 or res.StatusCode >= 300) then
        return false, "Server error (" .. tostring(res.StatusCode) .. ")"
    end
    local data
    if not pcall(function() data = HttpService:JSONDecode(res.Body) end) then
        return false, "Bad server response"
    end
    if data.valid then return true end
    local reasons = {
        hwid_mismatch = "Key is locked to another device",
        blacklisted   = "This device is blacklisted",
        invalid_or_expired = "Key is invalid or expired",
        bad_request   = "Wrong key format",
    }
    return false, reasons[data.reason] or "Key is invalid or expired"
end

-- Build the full raw URL for a script entry (base + file name), or use a full url if given.
local function scriptUrl(entry)
    if entry.url and entry.url ~= "" then return entry.url end
    return (Config.ScriptBase or "") .. (entry.file or "")
end

-- Fetch + run a script
local function loadScript(entry)
    local src
    local ok = pcall(function() src = game:HttpGet(scriptUrl(entry), true) end)
    if not ok or not src or #src < 1 then
        notify("BlackCloverHub", "Couldn't download: " .. entry.name, 5)
        return false
    end
    local fn, err = loadstring(src, "=" .. entry.name)
    if not fn then
        notify("BlackCloverHub", "Script error: " .. tostring(err), 6)
        return false
    end
    task.spawn(fn)
    return true
end

-- Background watchdog: re-check the key while playing and kick on expiry/revoke.
-- Only started for key-required scripts.
local keyWatchStarted = false
local function startKeyWatch(key)
    if not Config.KickOnExpire or keyWatchStarted then return end
    keyWatchStarted = true
    task.spawn(function()
        while true do
            task.wait(math.max(30, Config.RecheckSeconds or 180))
            local ok, reason = verifyKey(key)
            -- Only kick when the server clearly rejects the key (expired/blacklisted/mismatch).
            -- Network errors are ignored so a brief outage doesn't kick paying users.
            if not ok and reason ~= "Can't reach the server" and reason ~= "Bad server response"
                and reason ~= "Server error" and not tostring(reason):find("Server error") then
                pcall(function()
                    LocalPlayer:Kick("\n[BlackCloverHub]\nYour key expired or is no longer valid.\nGet a new key to keep playing.")
                end)
                break
            end
        end
    end)
end

-- Find the script for the current game. Matches each id against BOTH the Place ID (game.PlaceId)
-- and the Universe ID (game.GameId), so you can list either one -- and a Universe ID catches
-- every place inside that game's universe. Falls back to a universal script if nothing matches.
local function detectScript()
    local placeId = game.PlaceId
    local universeId = game.GameId   -- the "universal id" (Universe ID)
    local universal
    for _, s in ipairs(Config.Scripts) do
        if s.universal then universal = universal or s end
        if s.placeIds then
            for _, id in ipairs(s.placeIds) do
                local n = tonumber(id)
                if n and (n == placeId or n == universeId) then return s, false end
            end
        end
    end
    if universal then return universal, true end
    return nil, false
end

--// FAST PATH: load instantly with no window when we already can =========
do
    local detected = detectScript()
    if detected then
        if not detected.requiresKey then
            notify("BlackCloverHub", "Loading " .. detected.name .. "...", 4)
            loadScript(detected)
            return
        end
        local saved = loadSavedKey()
        if saved and saved ~= "" then
            local ok = verifyKey(saved)
            if ok then
                notify("BlackCloverHub", "Key verified — loading " .. detected.name, 4)
                if loadScript(detected) then startKeyWatch(saved) end
                return
            end
        end
    end
    -- otherwise fall through and open the window (needs a key, or game not supported)
end

--// UI (dark-red eye design) ==================================================
local parentGui = (gethui and gethui()) or CoreGui
pcall(function() local old = parentGui:FindFirstChild("ObsessionHubLoader") if old then old:Destroy() end end)

local root = Instance.new("ScreenGui")
root.Name = "obsessionhub"
root.Enabled = true
root.DisplayOrder = 999
root.IgnoreGuiInset = true
root.ResetOnSpawn = false
root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
root.ClipToDeviceSafeArea = true
local o659414 = Instance.new("Frame")
o659414.Name = "Frame"
o659414.Size = UDim2.new(0, 600, 0, 340)
o659414.Position = UDim2.new(0.5, 0, 0.5, 0)
o659414.AnchorPoint = Vector2.new(0.5, 0.5)
o659414.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o659414.BackgroundTransparency = 1
o659414.BorderColor3 = Color3.fromRGB(27, 42, 53)
o659414.BorderSizePixel = 1
o659414.BorderMode = Enum.BorderMode.Outline
o659414.Visible = true
o659414.Rotation = 0
o659414.ClipsDescendants = false
o659414.Active = false
o659414.Selectable = false
o659414.Interactable = true
o659414.AutomaticSize = Enum.AutomaticSize.None
o659414.ZIndex = 1
o659414.LayoutOrder = 0
o659414.ZIndex = 1
o659414.LayoutOrder = 0
o659414.Parent = root
local o410889 = Instance.new("UIScale")
o410889.Name = "UIScale"
o410889.Scale = 1
o410889.Parent = o659414
local o267743 = Instance.new("ImageLabel")
o267743.Name = "ImageLabel"
o267743.Size = UDim2.new(1, 50, 1, 50)
o267743.Position = UDim2.new(0, -25, 0, -25)
o267743.AnchorPoint = Vector2.new(0, 0)
o267743.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o267743.BackgroundTransparency = 1
o267743.BorderColor3 = Color3.fromRGB(27, 42, 53)
o267743.BorderSizePixel = 1
o267743.BorderMode = Enum.BorderMode.Outline
o267743.Visible = true
o267743.Rotation = 0
o267743.ClipsDescendants = false
o267743.Active = false
o267743.Selectable = false
o267743.Interactable = true
o267743.AutomaticSize = Enum.AutomaticSize.None
o267743.ZIndex = 1
o267743.LayoutOrder = 0
o267743.Image = "rbxassetid://6014261993"
o267743.ImageColor3 = Color3.fromRGB(255, 255, 255) -- was ugly black -> red glow
o267743.ImageTransparency = 0.35
o267743.ImageRectOffset = Vector2.new(0, 0)
o267743.ImageRectSize = Vector2.new(0, 0)
o267743.ScaleType = Enum.ScaleType.Slice
o267743.SliceCenter = Rect.new(49, 49, 450, 450)
o267743.SliceScale = 1
o267743.TileSize = UDim2.new(1, 0, 1, 0)
o267743.ResampleMode = Enum.ResamplerMode.Default
o267743.ZIndex = 1
o267743.LayoutOrder = 0
o267743.Parent = o659414
local o740206 = Instance.new("CanvasGroup")
o740206.Name = "CanvasGroup"
o740206.Size = UDim2.new(1, 0, 1, 0)
o740206.Position = UDim2.new(0, 0, 0, 0)
o740206.AnchorPoint = Vector2.new(0, 0)
o740206.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
o740206.BackgroundTransparency = 0
o740206.BorderColor3 = Color3.fromRGB(27, 42, 53)
o740206.BorderSizePixel = 0
o740206.BorderMode = Enum.BorderMode.Outline
o740206.Visible = true
o740206.Rotation = 0
o740206.ClipsDescendants = true
o740206.Active = false
o740206.Selectable = false
o740206.Interactable = true
o740206.AutomaticSize = Enum.AutomaticSize.None
o740206.ZIndex = 1
o740206.LayoutOrder = 0
o740206.GroupColor3 = Color3.fromRGB(255, 255, 255)
o740206.GroupTransparency = 0
o740206.ZIndex = 1
o740206.LayoutOrder = 0
o740206.Parent = o659414
local o360745 = Instance.new("UICorner")
o360745.Name = "UICorner"
o360745.CornerRadius = UDim.new(0, 14)
o360745.Parent = o740206
-- shiny glowing red border (animated shimmer)
local oBorder = Instance.new("UIStroke")
oBorder.Name = "ShinyBorder"
oBorder.Thickness = 2
oBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
oBorder.Color = Color3.fromRGB(255, 255, 255)
oBorder.Transparency = 0
oBorder.Parent = o740206
local oBorderGrad = Instance.new("UIGradient")
oBorderGrad.Name = "Shine"
oBorderGrad.Color = ColorSequence.new({
  ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
  ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
  ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 120)),
})
oBorderGrad.Rotation = 0
oBorderGrad.Parent = oBorder
task.spawn(function()
  while oBorderGrad.Parent do
    oBorderGrad.Rotation = (oBorderGrad.Rotation + 3) % 360
    task.wait(0.03)
  end
end)
local o814341 = Instance.new("ImageLabel")
o814341.Name = "ImageLabel"
o814341.Size = UDim2.new(0, 500, 0, 180)
o814341.Position = UDim2.new(0, 300, 0, 348)
o814341.AnchorPoint = Vector2.new(0.5, 0.5)
o814341.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o814341.BackgroundTransparency = 1
o814341.BorderColor3 = Color3.fromRGB(27, 42, 53)
o814341.BorderSizePixel = 1
o814341.BorderMode = Enum.BorderMode.Outline
o814341.Visible = true
o814341.Rotation = 0
o814341.ClipsDescendants = false
o814341.Active = false
o814341.Selectable = false
o814341.Interactable = true
o814341.AutomaticSize = Enum.AutomaticSize.None
o814341.ZIndex = 1
o814341.LayoutOrder = 0
o814341.Image = "rbxassetid://8992230677"
o814341.ImageColor3 = Color3.fromRGB(255, 255, 255)
o814341.ImageTransparency = 0.8600000143051147
o814341.ImageRectOffset = Vector2.new(0, 0)
o814341.ImageRectSize = Vector2.new(0, 0)
o814341.ScaleType = Enum.ScaleType.Stretch
o814341.SliceCenter = Rect.new(0, 0, 0, 0)
o814341.SliceScale = 1
o814341.TileSize = UDim2.new(1, 0, 1, 0)
o814341.ResampleMode = Enum.ResamplerMode.Default
o814341.ZIndex = 1
o814341.LayoutOrder = 0
o814341.Parent = o740206
local o750338 = Instance.new("UIGradient")
o750338.Name = "UIGradient"
o750338.Rotation = 270
o750338.Enabled = true
o750338.Offset = Vector2.new(0, 0)
o750338.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))})
o750338.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(1, 0, 0)})
o750338.Parent = o814341
local o755262 = Instance.new("ImageLabel")
o755262.Name = "ImageLabel"
o755262.Size = UDim2.new(0, 130, 0, 60)
o755262.Position = UDim2.new(0, -10, 0, 330)
o755262.AnchorPoint = Vector2.new(0.5, 0.5)
o755262.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o755262.BackgroundTransparency = 1
o755262.BorderColor3 = Color3.fromRGB(27, 42, 53)
o755262.BorderSizePixel = 1
o755262.BorderMode = Enum.BorderMode.Outline
o755262.Visible = true
o755262.Rotation = 0
o755262.ClipsDescendants = false
o755262.Active = false
o755262.Selectable = false
o755262.Interactable = true
o755262.AutomaticSize = Enum.AutomaticSize.None
o755262.ZIndex = 1
o755262.LayoutOrder = 0
o755262.Image = "rbxassetid://8992230677"
o755262.ImageColor3 = Color3.fromRGB(255, 255, 255)
o755262.ImageTransparency = 0.75
o755262.ImageRectOffset = Vector2.new(0, 0)
o755262.ImageRectSize = Vector2.new(0, 0)
o755262.ScaleType = Enum.ScaleType.Stretch
o755262.SliceCenter = Rect.new(0, 0, 0, 0)
o755262.SliceScale = 1
o755262.TileSize = UDim2.new(1, 0, 1, 0)
o755262.ResampleMode = Enum.ResamplerMode.Default
o755262.ZIndex = 1
o755262.LayoutOrder = 0
o755262.Parent = o740206
local o703513 = Instance.new("UIGradient")
o703513.Name = "UIGradient"
o703513.Rotation = 90
o703513.Enabled = true
o703513.Offset = Vector2.new(0, 0)
o703513.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))})
o703513.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(1, 0, 0)})
o703513.Parent = o755262
local o929500 = Instance.new("ImageLabel")
o929500.Name = "ImageLabel"
o929500.Size = UDim2.new(0, 520, 0, 240)
o929500.Position = UDim2.new(0, 586, 0, 10)
o929500.AnchorPoint = Vector2.new(0.5, 0.5)
o929500.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o929500.BackgroundTransparency = 1
o929500.BorderColor3 = Color3.fromRGB(27, 42, 53)
o929500.BorderSizePixel = 1
o929500.BorderMode = Enum.BorderMode.Outline
o929500.Visible = true
o929500.Rotation = 0
o929500.ClipsDescendants = false
o929500.Active = false
o929500.Selectable = false
o929500.Interactable = true
o929500.AutomaticSize = Enum.AutomaticSize.None
o929500.ZIndex = 1
o929500.LayoutOrder = 0
o929500.Image = "rbxassetid://8992230677"
o929500.ImageColor3 = Color3.fromRGB(255, 255, 255)
o929500.ImageTransparency = 0.9200000166893005
o929500.ImageRectOffset = Vector2.new(0, 0)
o929500.ImageRectSize = Vector2.new(0, 0)
o929500.ScaleType = Enum.ScaleType.Stretch
o929500.SliceCenter = Rect.new(0, 0, 0, 0)
o929500.SliceScale = 1
o929500.TileSize = UDim2.new(1, 0, 1, 0)
o929500.ResampleMode = Enum.ResamplerMode.Default
o929500.ZIndex = 1
o929500.LayoutOrder = 0
o929500.Parent = o740206
local o421083 = Instance.new("UIGradient")
o421083.Name = "UIGradient"
o421083.Rotation = 90
o421083.Enabled = true
o421083.Offset = Vector2.new(0, 0)
o421083.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))})
o421083.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(1, 0, 0)})
o421083.Parent = o929500
local o736954 = Instance.new("ImageLabel")
o736954.Name = "ImageLabel"
o736954.Size = UDim2.new(0, 90, 0, 180)
o736954.Position = UDim2.new(0, 6, 0, -6)
o736954.AnchorPoint = Vector2.new(0.5, 0.5)
o736954.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o736954.BackgroundTransparency = 1
o736954.BorderColor3 = Color3.fromRGB(27, 42, 53)
o736954.BorderSizePixel = 1
o736954.BorderMode = Enum.BorderMode.Outline
o736954.Visible = true
o736954.Rotation = 0
o736954.ClipsDescendants = false
o736954.Active = false
o736954.Selectable = false
o736954.Interactable = true
o736954.AutomaticSize = Enum.AutomaticSize.None
o736954.ZIndex = 1
o736954.LayoutOrder = 0
o736954.Image = "rbxassetid://8992230677"
o736954.ImageColor3 = Color3.fromRGB(255, 255, 255)
o736954.ImageTransparency = 0.7799999713897705
o736954.ImageRectOffset = Vector2.new(0, 0)
o736954.ImageRectSize = Vector2.new(0, 0)
o736954.ScaleType = Enum.ScaleType.Stretch
o736954.SliceCenter = Rect.new(0, 0, 0, 0)
o736954.SliceScale = 1
o736954.TileSize = UDim2.new(1, 0, 1, 0)
o736954.ResampleMode = Enum.ResamplerMode.Default
o736954.ZIndex = 1
o736954.LayoutOrder = 0
o736954.Parent = o740206
local o808447 = Instance.new("UIGradient")
o808447.Name = "UIGradient"
o808447.Rotation = 90
o808447.Enabled = true
o808447.Offset = Vector2.new(0, 0)
o808447.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))})
o808447.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(1, 0, 0)})
o808447.Parent = o736954
local o288475 = Instance.new("Frame")
o288475.Name = "Frame"
o288475.Size = UDim2.new(0, 356, 0, 340)
o288475.Position = UDim2.new(0, 0, 0, 0)
o288475.AnchorPoint = Vector2.new(0, 0)
o288475.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o288475.BackgroundTransparency = 1
o288475.BorderColor3 = Color3.fromRGB(27, 42, 53)
o288475.BorderSizePixel = 1
o288475.BorderMode = Enum.BorderMode.Outline
o288475.Visible = true
o288475.Rotation = 0
o288475.ClipsDescendants = false
o288475.Active = false
o288475.Selectable = false
o288475.Interactable = true
o288475.AutomaticSize = Enum.AutomaticSize.None
o288475.ZIndex = 1
o288475.LayoutOrder = 0
o288475.ZIndex = 1
o288475.LayoutOrder = 0
o288475.Parent = o740206
local o123988 = Instance.new("ImageLabel")
o123988.Name = "ImageLabel"
o123988.Size = UDim2.new(0, 46, 0, 46)
o123988.Position = UDim2.new(0, 28, 0, 26)
o123988.AnchorPoint = Vector2.new(0, 0)
o123988.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o123988.BackgroundTransparency = 1
o123988.BorderColor3 = Color3.fromRGB(27, 42, 53)
o123988.BorderSizePixel = 1
o123988.BorderMode = Enum.BorderMode.Outline
o123988.Visible = true
o123988.Rotation = 0
o123988.ClipsDescendants = false
o123988.Active = false
o123988.Selectable = false
o123988.Interactable = true
o123988.AutomaticSize = Enum.AutomaticSize.None
o123988.ZIndex = 1
o123988.LayoutOrder = 0
o123988.Image = Config.LogoImage or ""
o123988.ImageColor3 = Color3.fromRGB(255, 255, 255) -- white = eyes decal shows true colors; set to 224,31,58 for a red tint
o123988.ImageTransparency = 0
o123988.ImageRectOffset = Vector2.new(0, 0)
o123988.ImageRectSize = Vector2.new(0, 0)
o123988.ScaleType = Enum.ScaleType.Crop
o123988.SliceCenter = Rect.new(0, 0, 0, 0)
o123988.SliceScale = 1
o123988.TileSize = UDim2.new(1, 0, 1, 0)
o123988.ResampleMode = Enum.ResamplerMode.Default
o123988.ZIndex = 1
o123988.LayoutOrder = 0
o123988.Parent = o288475
local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(1, 0)
logoCorner.Parent = o123988
local logoGlow = Instance.new("UIStroke")
logoGlow.Thickness = 1.5
logoGlow.Color = Color3.fromRGB(255, 255, 255)
logoGlow.Transparency = 0.1
logoGlow.Parent = o123988
local o285654 = Instance.new("TextLabel")
o285654.Name = "TextLabel"
o285654.Size = UDim2.new(0, 200, 0, 24)
o285654.Position = UDim2.new(0, 82, 0, 28)
o285654.AnchorPoint = Vector2.new(0, 0)
o285654.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o285654.BackgroundTransparency = 1
o285654.BorderColor3 = Color3.fromRGB(27, 42, 53)
o285654.BorderSizePixel = 1
o285654.BorderMode = Enum.BorderMode.Outline
o285654.Visible = true
o285654.Rotation = 0
o285654.ClipsDescendants = false
o285654.Active = false
o285654.Selectable = false
o285654.Interactable = true
o285654.AutomaticSize = Enum.AutomaticSize.None
o285654.ZIndex = 1
o285654.LayoutOrder = 0
o285654.Text = "BlackCloverHub"
o285654.TextSize = 22
o285654.TextScaled = false
o285654.TextWrapped = false
o285654.TextColor3 = Color3.fromRGB(233, 229, 234)
o285654.TextXAlignment = Enum.TextXAlignment.Left
o285654.TextYAlignment = Enum.TextYAlignment.Center
o285654.TextTransparency = 0
o285654.RichText = false
o285654.LineHeight = 1
o285654.MaxVisibleGraphemes = -1
o285654.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o285654.TextStrokeTransparency = 1
o285654.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o285654.TextSize = 22
o285654.TextScaled = false
o285654.ZIndex = 1
o285654.LayoutOrder = 0
o285654.Parent = o288475
local o287710 = Instance.new("TextLabel")
o287710.Name = "TextLabel"
o287710.Size = UDim2.new(0, 200, 0, 14)
o287710.Position = UDim2.new(0, 82, 0, 52)
o287710.AnchorPoint = Vector2.new(0, 0)
o287710.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o287710.BackgroundTransparency = 1
o287710.BorderColor3 = Color3.fromRGB(27, 42, 53)
o287710.BorderSizePixel = 1
o287710.BorderMode = Enum.BorderMode.Outline
o287710.Visible = true
o287710.Rotation = 0
o287710.ClipsDescendants = false
o287710.Active = false
o287710.Selectable = false
o287710.Interactable = true
o287710.AutomaticSize = Enum.AutomaticSize.None
o287710.ZIndex = 1
o287710.LayoutOrder = 0
o287710.Text = "Key system"
o287710.TextSize = 12
o287710.TextScaled = false
o287710.TextWrapped = false
o287710.TextColor3 = Color3.fromRGB(125, 115, 126)
o287710.TextXAlignment = Enum.TextXAlignment.Left
o287710.TextYAlignment = Enum.TextYAlignment.Center
o287710.TextTransparency = 0
o287710.RichText = false
o287710.LineHeight = 1
o287710.MaxVisibleGraphemes = -1
o287710.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o287710.TextStrokeTransparency = 1
o287710.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o287710.TextSize = 12
o287710.TextScaled = false
o287710.ZIndex = 1
o287710.LayoutOrder = 0
o287710.Parent = o288475
local o458104 = Instance.new("TextLabel")
o458104.Name = "TextLabel"
o458104.Size = UDim2.new(0, 200, 0, 14)
o458104.Position = UDim2.new(0, 28, 0, 100)
o458104.AnchorPoint = Vector2.new(0, 0)
o458104.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o458104.BackgroundTransparency = 1
o458104.BorderColor3 = Color3.fromRGB(27, 42, 53)
o458104.BorderSizePixel = 1
o458104.BorderMode = Enum.BorderMode.Outline
o458104.Visible = true
o458104.Rotation = 0
o458104.ClipsDescendants = false
o458104.Active = false
o458104.Selectable = false
o458104.Interactable = true
o458104.AutomaticSize = Enum.AutomaticSize.None
o458104.ZIndex = 1
o458104.LayoutOrder = 0
o458104.Text = "License key"
o458104.TextSize = 11
o458104.TextScaled = false
o458104.TextWrapped = false
o458104.TextColor3 = Color3.fromRGB(125, 115, 126)
o458104.TextXAlignment = Enum.TextXAlignment.Left
o458104.TextYAlignment = Enum.TextYAlignment.Center
o458104.TextTransparency = 0
o458104.RichText = false
o458104.LineHeight = 1
o458104.MaxVisibleGraphemes = -1
o458104.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o458104.TextStrokeTransparency = 1
o458104.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o458104.TextSize = 11
o458104.TextScaled = false
o458104.ZIndex = 1
o458104.LayoutOrder = 0
o458104.Parent = o288475
local o772932 = Instance.new("Frame")
o772932.Name = "Frame"
o772932.Size = UDim2.new(0, 300, 0, 40)
o772932.Position = UDim2.new(0, 28, 0, 120)
o772932.AnchorPoint = Vector2.new(0, 0)
o772932.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
o772932.BackgroundTransparency = 0
o772932.BorderColor3 = Color3.fromRGB(27, 42, 53)
o772932.BorderSizePixel = 0
o772932.BorderMode = Enum.BorderMode.Outline
o772932.Visible = true
o772932.Rotation = 0
o772932.ClipsDescendants = false
o772932.Active = false
o772932.Selectable = false
o772932.Interactable = true
o772932.AutomaticSize = Enum.AutomaticSize.None
o772932.ZIndex = 1
o772932.LayoutOrder = 0
o772932.ZIndex = 1
o772932.LayoutOrder = 0
o772932.Parent = o288475
local gl_o772932 = Instance.new("UIGradient")
gl_o772932.Name = "Gloss"
gl_o772932.Rotation = 90
gl_o772932.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(235, 235, 235)), ColorSequenceKeypoint.new(1, Color3.fromRGB(205, 205, 205))})
gl_o772932.Parent = o772932
local o617423 = Instance.new("UICorner")
o617423.Name = "UICorner"
o617423.CornerRadius = UDim.new(0, 8)
o617423.Parent = o772932
local o763833 = Instance.new("UIStroke")
o763833.Name = "UIStroke"
o763833.ZIndex = 1
o763833.Thickness = 1
o763833.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
o763833.LineJoinMode = Enum.LineJoinMode.Round
o763833.Color = Color3.fromRGB(74, 74, 74)
o763833.Transparency = 0
o763833.Parent = o772932
local o169951 = Instance.new("Frame")
o169951.Name = "Frame"
o169951.Size = UDim2.new(0, 16, 0, 16)
o169951.Position = UDim2.new(0, 13, 0, 12)
o169951.AnchorPoint = Vector2.new(0, 0)
o169951.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o169951.BackgroundTransparency = 1
o169951.BorderColor3 = Color3.fromRGB(27, 42, 53)
o169951.BorderSizePixel = 1
o169951.BorderMode = Enum.BorderMode.Outline
o169951.Visible = true
o169951.Rotation = 0
o169951.ClipsDescendants = false
o169951.Active = false
o169951.Selectable = false
o169951.Interactable = true
o169951.AutomaticSize = Enum.AutomaticSize.None
o169951.ZIndex = 1
o169951.LayoutOrder = 0
o169951.ZIndex = 1
o169951.LayoutOrder = 0
o169951.Parent = o772932
local o857230 = Instance.new("ImageLabel")
o857230.Name = "iconglow"
o857230.Size = UDim2.new(2, 0, 2, 0)
o857230.Position = UDim2.new(0.5, 0, 0.5, 0)
o857230.AnchorPoint = Vector2.new(0.5, 0.5)
o857230.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o857230.BackgroundTransparency = 1
o857230.BorderColor3 = Color3.fromRGB(27, 42, 53)
o857230.BorderSizePixel = 1
o857230.BorderMode = Enum.BorderMode.Outline
o857230.Visible = true
o857230.Rotation = 0
o857230.ClipsDescendants = false
o857230.Active = false
o857230.Selectable = false
o857230.Interactable = true
o857230.AutomaticSize = Enum.AutomaticSize.None
o857230.ZIndex = 0
o857230.LayoutOrder = 0
o857230.Image = "rbxassetid://8992230677"
o857230.ImageColor3 = Color3.fromRGB(125, 115, 126)
o857230.ImageTransparency = 0.8999999761581421
o857230.ImageRectOffset = Vector2.new(0, 0)
o857230.ImageRectSize = Vector2.new(0, 0)
o857230.ScaleType = Enum.ScaleType.Stretch
o857230.SliceCenter = Rect.new(0, 0, 0, 0)
o857230.SliceScale = 1
o857230.TileSize = UDim2.new(1, 0, 1, 0)
o857230.ResampleMode = Enum.ResamplerMode.Default
o857230.ZIndex = 0
o857230.LayoutOrder = 0
o857230.Parent = o169951
local o115363 = Instance.new("ImageLabel")
o115363.Name = "ImageLabel"
o115363.Size = UDim2.new(1, 0, 1, 0)
o115363.Position = UDim2.new(0, 0, 0, 0)
o115363.AnchorPoint = Vector2.new(0, 0)
o115363.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o115363.BackgroundTransparency = 1
o115363.BorderColor3 = Color3.fromRGB(27, 42, 53)
o115363.BorderSizePixel = 1
o115363.BorderMode = Enum.BorderMode.Outline
o115363.Visible = true
o115363.Rotation = 0
o115363.ClipsDescendants = false
o115363.Active = false
o115363.Selectable = false
o115363.Interactable = true
o115363.AutomaticSize = Enum.AutomaticSize.None
o115363.ZIndex = 1
o115363.LayoutOrder = 0
o115363.Image = "rbxassetid://122605056588923"
o115363.ImageColor3 = Color3.fromRGB(125, 115, 126)
o115363.ImageTransparency = 0
o115363.ImageRectOffset = Vector2.new(975, 50)
o115363.ImageRectSize = Vector2.new(24, 24)
o115363.ScaleType = Enum.ScaleType.Stretch
o115363.SliceCenter = Rect.new(0, 0, 0, 0)
o115363.SliceScale = 1
o115363.TileSize = UDim2.new(1, 0, 1, 0)
o115363.ResampleMode = Enum.ResamplerMode.Default
o115363.ZIndex = 1
o115363.LayoutOrder = 0
o115363.Parent = o169951
local o284290 = Instance.new("TextBox")
o284290.Name = "TextBox"
o284290.Size = UDim2.new(1, -52, 1, 0)
o284290.Position = UDim2.new(0, 40, 0, 0)
o284290.AnchorPoint = Vector2.new(0, 0)
o284290.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o284290.BackgroundTransparency = 1
o284290.BorderColor3 = Color3.fromRGB(27, 42, 53)
o284290.BorderSizePixel = 1
o284290.BorderMode = Enum.BorderMode.Outline
o284290.Visible = true
o284290.Rotation = 0
o284290.ClipsDescendants = false
o284290.Active = true
o284290.Selectable = true
o284290.Interactable = true
o284290.AutomaticSize = Enum.AutomaticSize.None
o284290.ZIndex = 1
o284290.LayoutOrder = 0
o284290.Text = ""
o284290.TextSize = 13
o284290.TextScaled = false
o284290.TextWrapped = false
o284290.TextColor3 = Color3.fromRGB(233, 229, 234)
o284290.TextXAlignment = Enum.TextXAlignment.Left
o284290.TextYAlignment = Enum.TextYAlignment.Center
o284290.TextTransparency = 0
o284290.RichText = false
o284290.PlaceholderText = "Paste your key here"
o284290.PlaceholderColor3 = Color3.fromRGB(125, 115, 126)
o284290.ClearTextOnFocus = false
o284290.MultiLine = false
o284290.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o284290.TextSize = 13
o284290.TextScaled = false
o284290.MultiLine = false
o284290.ZIndex = 1
o284290.LayoutOrder = 0
o284290.Parent = o772932
local o448724 = Instance.new("TextLabel")
o448724.Name = "TextLabel"
o448724.Size = UDim2.new(0, 300, 0, 16)
o448724.Position = UDim2.new(0, 28, 0, 232)
o448724.AnchorPoint = Vector2.new(0, 0)
o448724.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o448724.BackgroundTransparency = 1
o448724.BorderColor3 = Color3.fromRGB(27, 42, 53)
o448724.BorderSizePixel = 1
o448724.BorderMode = Enum.BorderMode.Outline
o448724.Visible = true
o448724.Rotation = 0
o448724.ClipsDescendants = false
o448724.Active = false
o448724.Selectable = false
o448724.Interactable = true
o448724.AutomaticSize = Enum.AutomaticSize.None
o448724.ZIndex = 1
o448724.LayoutOrder = 0
o448724.Text = ""
o448724.TextSize = 12
o448724.TextScaled = false
o448724.TextWrapped = false
o448724.TextColor3 = Color3.fromRGB(125, 115, 126)
o448724.TextXAlignment = Enum.TextXAlignment.Left
o448724.TextYAlignment = Enum.TextYAlignment.Center
o448724.TextTransparency = 0
o448724.RichText = false
o448724.LineHeight = 1
o448724.MaxVisibleGraphemes = -1
o448724.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o448724.TextStrokeTransparency = 1
o448724.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o448724.TextSize = 12
o448724.TextScaled = false
o448724.ZIndex = 1
o448724.LayoutOrder = 0
o448724.Parent = o288475
local o362935 = Instance.new("TextLabel")
o362935.Name = "TextLabel"
o362935.Size = UDim2.new(0, 300, 0, 14)
o362935.Position = UDim2.new(0, 28, 0, 296)
o362935.AnchorPoint = Vector2.new(0, 0)
o362935.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o362935.BackgroundTransparency = 1
o362935.BorderColor3 = Color3.fromRGB(27, 42, 53)
o362935.BorderSizePixel = 1
o362935.BorderMode = Enum.BorderMode.Outline
o362935.Visible = true
o362935.Rotation = 0
o362935.ClipsDescendants = false
o362935.Active = false
o362935.Selectable = false
o362935.Interactable = true
o362935.AutomaticSize = Enum.AutomaticSize.None
o362935.ZIndex = 1
o362935.LayoutOrder = 0
o362935.Text = "Your key is saved, you only enter it once"
o362935.TextSize = 11
o362935.TextScaled = false
o362935.TextWrapped = false
o362935.TextColor3 = Color3.fromRGB(125, 115, 126)
o362935.TextXAlignment = Enum.TextXAlignment.Left
o362935.TextYAlignment = Enum.TextYAlignment.Center
o362935.TextTransparency = 0
o362935.RichText = false
o362935.LineHeight = 1
o362935.MaxVisibleGraphemes = -1
o362935.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o362935.TextStrokeTransparency = 1
o362935.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o362935.TextSize = 11
o362935.TextScaled = false
o362935.ZIndex = 1
o362935.LayoutOrder = 0
o362935.Parent = o288475
local o749571 = Instance.new("TextButton")
o749571.Name = "TextButton"
o749571.Size = UDim2.new(0, 144, 0, 38)
o749571.Position = UDim2.new(0, 28, 0, 176)
o749571.AnchorPoint = Vector2.new(0, 0)
o749571.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
o749571.BackgroundTransparency = 0.11999999731779099
o749571.BorderColor3 = Color3.fromRGB(27, 42, 53)
o749571.BorderSizePixel = 1
o749571.BorderMode = Enum.BorderMode.Outline
o749571.Visible = true
o749571.Rotation = 0
o749571.ClipsDescendants = false
o749571.Active = true
o749571.Selectable = true
o749571.Interactable = true
o749571.AutomaticSize = Enum.AutomaticSize.None
o749571.ZIndex = 1
o749571.LayoutOrder = 0
o749571.AutoButtonColor = false
o749571.Modal = false
o749571.Selected = false
o749571.Text = "Submit"
o749571.TextSize = 13
o749571.TextScaled = false
o749571.TextWrapped = false
o749571.TextColor3 = Color3.fromRGB(26, 26, 26)
o749571.TextXAlignment = Enum.TextXAlignment.Center
o749571.TextYAlignment = Enum.TextYAlignment.Center
o749571.TextTransparency = 0
o749571.RichText = false
o749571.LineHeight = 1
o749571.MaxVisibleGraphemes = -1
o749571.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o749571.TextStrokeTransparency = 1
o749571.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o749571.TextSize = 13
o749571.TextScaled = false
o749571.ZIndex = 1
o749571.LayoutOrder = 0
o749571.Parent = o288475
local o487805 = Instance.new("UICorner")
o487805.Name = "UICorner"
o487805.CornerRadius = UDim.new(0, 8)
o487805.Parent = o749571
local o719664 = Instance.new("UIStroke")
o719664.Name = "UIStroke"
o719664.ZIndex = 1
o719664.Thickness = 1
o719664.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
o719664.LineJoinMode = Enum.LineJoinMode.Round
o719664.Color = Color3.fromRGB(255, 255, 255)
o719664.Transparency = 0.4000000059604645
o719664.Parent = o749571
local oShine = Instance.new("UIGradient")
oShine.Name = "Shine"
oShine.Rotation = 90
oShine.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(176, 176, 176))})
oShine.Parent = o749571
local o613340 = Instance.new("UIPadding")
o613340.Name = "UIPadding"
o613340.PaddingTop = UDim.new(0, 0)
o613340.PaddingBottom = UDim.new(0, 0)
o613340.PaddingLeft = UDim.new(0, 24)
o613340.PaddingRight = UDim.new(0, 0)
o613340.Parent = o749571
local o459348 = Instance.new("Frame")
o459348.Name = "Frame"
o459348.Size = UDim2.new(0, 16, 0, 16)
o459348.Position = UDim2.new(0, -12, 0, 11)
o459348.AnchorPoint = Vector2.new(0, 0)
o459348.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o459348.BackgroundTransparency = 1
o459348.BorderColor3 = Color3.fromRGB(27, 42, 53)
o459348.BorderSizePixel = 1
o459348.BorderMode = Enum.BorderMode.Outline
o459348.Visible = true
o459348.Rotation = 0
o459348.ClipsDescendants = false
o459348.Active = false
o459348.Selectable = false
o459348.Interactable = true
o459348.AutomaticSize = Enum.AutomaticSize.None
o459348.ZIndex = 1
o459348.LayoutOrder = 0
o459348.ZIndex = 1
o459348.LayoutOrder = 0
o459348.Parent = o749571
local o664696 = Instance.new("ImageLabel")
o664696.Name = "iconglow"
o664696.Size = UDim2.new(2, 0, 2, 0)
o664696.Position = UDim2.new(0.5, 0, 0.5, 0)
o664696.AnchorPoint = Vector2.new(0.5, 0.5)
o664696.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o664696.BackgroundTransparency = 1
o664696.BorderColor3 = Color3.fromRGB(27, 42, 53)
o664696.BorderSizePixel = 1
o664696.BorderMode = Enum.BorderMode.Outline
o664696.Visible = true
o664696.Rotation = 0
o664696.ClipsDescendants = false
o664696.Active = false
o664696.Selectable = false
o664696.Interactable = true
o664696.AutomaticSize = Enum.AutomaticSize.None
o664696.ZIndex = 0
o664696.LayoutOrder = 0
o664696.Image = "rbxassetid://8992230677"
o664696.ImageColor3 = Color3.fromRGB(26, 26, 26)
o664696.ImageTransparency = 0.8999999761581421
o664696.ImageRectOffset = Vector2.new(0, 0)
o664696.ImageRectSize = Vector2.new(0, 0)
o664696.ScaleType = Enum.ScaleType.Stretch
o664696.SliceCenter = Rect.new(0, 0, 0, 0)
o664696.SliceScale = 1
o664696.TileSize = UDim2.new(1, 0, 1, 0)
o664696.ResampleMode = Enum.ResamplerMode.Default
o664696.ZIndex = 0
o664696.LayoutOrder = 0
o664696.Parent = o459348
local o923873 = Instance.new("ImageLabel")
o923873.Name = "ImageLabel"
o923873.Size = UDim2.new(1, 0, 1, 0)
o923873.Position = UDim2.new(0, 0, 0, 0)
o923873.AnchorPoint = Vector2.new(0, 0)
o923873.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o923873.BackgroundTransparency = 1
o923873.BorderColor3 = Color3.fromRGB(27, 42, 53)
o923873.BorderSizePixel = 1
o923873.BorderMode = Enum.BorderMode.Outline
o923873.Visible = true
o923873.Rotation = 0
o923873.ClipsDescendants = false
o923873.Active = false
o923873.Selectable = false
o923873.Interactable = true
o923873.AutomaticSize = Enum.AutomaticSize.None
o923873.ZIndex = 1
o923873.LayoutOrder = 0
o923873.Image = "rbxassetid://122605056588923"
o923873.ImageColor3 = Color3.fromRGB(26, 26, 26)
o923873.ImageTransparency = 0
o923873.ImageRectOffset = Vector2.new(200, 100)
o923873.ImageRectSize = Vector2.new(24, 24)
o923873.ScaleType = Enum.ScaleType.Stretch
o923873.SliceCenter = Rect.new(0, 0, 0, 0)
o923873.SliceScale = 1
o923873.TileSize = UDim2.new(1, 0, 1, 0)
o923873.ResampleMode = Enum.ResamplerMode.Default
o923873.ZIndex = 1
o923873.LayoutOrder = 0
o923873.Parent = o459348
local o354461 = Instance.new("TextButton")
o354461.Name = "TextButton"
o354461.Size = UDim2.new(0, 144, 0, 38)
o354461.Position = UDim2.new(0, 184, 0, 176)
o354461.AnchorPoint = Vector2.new(0, 0)
o354461.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
o354461.BackgroundTransparency = 0
o354461.BorderColor3 = Color3.fromRGB(27, 42, 53)
o354461.BorderSizePixel = 1
o354461.BorderMode = Enum.BorderMode.Outline
o354461.Visible = true
o354461.Rotation = 0
o354461.ClipsDescendants = false
o354461.Active = true
o354461.Selectable = true
o354461.Interactable = true
o354461.AutomaticSize = Enum.AutomaticSize.None
o354461.ZIndex = 1
o354461.LayoutOrder = 0
o354461.AutoButtonColor = false
o354461.Modal = false
o354461.Selected = false
o354461.Text = "Get a key"
o354461.TextSize = 13
o354461.TextScaled = false
o354461.TextWrapped = false
o354461.TextColor3 = Color3.fromRGB(233, 229, 234)
o354461.TextXAlignment = Enum.TextXAlignment.Center
o354461.TextYAlignment = Enum.TextYAlignment.Center
o354461.TextTransparency = 0
o354461.RichText = false
o354461.LineHeight = 1
o354461.MaxVisibleGraphemes = -1
o354461.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o354461.TextStrokeTransparency = 1
o354461.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o354461.TextSize = 13
o354461.TextScaled = false
o354461.ZIndex = 1
o354461.LayoutOrder = 0
o354461.Parent = o288475
local gl_o354461 = Instance.new("UIGradient")
gl_o354461.Name = "Gloss"
gl_o354461.Rotation = 90
gl_o354461.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(235, 235, 235)), ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 210, 210))})
gl_o354461.Parent = o354461
local o998265 = Instance.new("UICorner")
o998265.Name = "UICorner"
o998265.CornerRadius = UDim.new(0, 8)
o998265.Parent = o354461
local o659513 = Instance.new("UIStroke")
o659513.Name = "UIStroke"
o659513.ZIndex = 1
o659513.Thickness = 1
o659513.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
o659513.LineJoinMode = Enum.LineJoinMode.Round
o659513.Color = Color3.fromRGB(74, 74, 74)
o659513.Transparency = 0
o659513.Parent = o354461
local o551392 = Instance.new("UIPadding")
o551392.Name = "UIPadding"
o551392.PaddingTop = UDim.new(0, 0)
o551392.PaddingBottom = UDim.new(0, 0)
o551392.PaddingLeft = UDim.new(0, 24)
o551392.PaddingRight = UDim.new(0, 0)
o551392.Parent = o354461
local o267915 = Instance.new("Frame")
o267915.Name = "Frame"
o267915.Size = UDim2.new(0, 16, 0, 16)
o267915.Position = UDim2.new(0, -12, 0, 11)
o267915.AnchorPoint = Vector2.new(0, 0)
o267915.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o267915.BackgroundTransparency = 1
o267915.BorderColor3 = Color3.fromRGB(27, 42, 53)
o267915.BorderSizePixel = 1
o267915.BorderMode = Enum.BorderMode.Outline
o267915.Visible = true
o267915.Rotation = 0
o267915.ClipsDescendants = false
o267915.Active = false
o267915.Selectable = false
o267915.Interactable = true
o267915.AutomaticSize = Enum.AutomaticSize.None
o267915.ZIndex = 1
o267915.LayoutOrder = 0
o267915.ZIndex = 1
o267915.LayoutOrder = 0
o267915.Parent = o354461
local o308505 = Instance.new("ImageLabel")
o308505.Name = "iconglow"
o308505.Size = UDim2.new(2, 0, 2, 0)
o308505.Position = UDim2.new(0.5, 0, 0.5, 0)
o308505.AnchorPoint = Vector2.new(0.5, 0.5)
o308505.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o308505.BackgroundTransparency = 1
o308505.BorderColor3 = Color3.fromRGB(27, 42, 53)
o308505.BorderSizePixel = 1
o308505.BorderMode = Enum.BorderMode.Outline
o308505.Visible = true
o308505.Rotation = 0
o308505.ClipsDescendants = false
o308505.Active = false
o308505.Selectable = false
o308505.Interactable = true
o308505.AutomaticSize = Enum.AutomaticSize.None
o308505.ZIndex = 0
o308505.LayoutOrder = 0
o308505.Image = "rbxassetid://8992230677"
o308505.ImageColor3 = Color3.fromRGB(233, 229, 234)
o308505.ImageTransparency = 0.8999999761581421
o308505.ImageRectOffset = Vector2.new(0, 0)
o308505.ImageRectSize = Vector2.new(0, 0)
o308505.ScaleType = Enum.ScaleType.Stretch
o308505.SliceCenter = Rect.new(0, 0, 0, 0)
o308505.SliceScale = 1
o308505.TileSize = UDim2.new(1, 0, 1, 0)
o308505.ResampleMode = Enum.ResamplerMode.Default
o308505.ZIndex = 0
o308505.LayoutOrder = 0
o308505.Parent = o267915
local o963696 = Instance.new("ImageLabel")
o963696.Name = "ImageLabel"
o963696.Size = UDim2.new(1, 0, 1, 0)
o963696.Position = UDim2.new(0, 0, 0, 0)
o963696.AnchorPoint = Vector2.new(0, 0)
o963696.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o963696.BackgroundTransparency = 1
o963696.BorderColor3 = Color3.fromRGB(27, 42, 53)
o963696.BorderSizePixel = 1
o963696.BorderMode = Enum.BorderMode.Outline
o963696.Visible = true
o963696.Rotation = 0
o963696.ClipsDescendants = false
o963696.Active = false
o963696.Selectable = false
o963696.Interactable = true
o963696.AutomaticSize = Enum.AutomaticSize.None
o963696.ZIndex = 1
o963696.LayoutOrder = 0
o963696.Image = "rbxassetid://122605056588923"
o963696.ImageColor3 = Color3.fromRGB(233, 229, 234)
o963696.ImageTransparency = 0
o963696.ImageRectOffset = Vector2.new(450, 500)
o963696.ImageRectSize = Vector2.new(24, 24)
o963696.ScaleType = Enum.ScaleType.Stretch
o963696.SliceCenter = Rect.new(0, 0, 0, 0)
o963696.SliceScale = 1
o963696.TileSize = UDim2.new(1, 0, 1, 0)
o963696.ResampleMode = Enum.ResamplerMode.Default
o963696.ZIndex = 1
o963696.LayoutOrder = 0
o963696.Parent = o267915
local o997456 = Instance.new("Frame")
o997456.Name = "Frame"
o997456.Size = UDim2.new(0, 1, 1, -56)
o997456.Position = UDim2.new(0, 356, 0, 28)
o997456.AnchorPoint = Vector2.new(0, 0)
o997456.BackgroundColor3 = Color3.fromRGB(74, 74, 74)
o997456.BackgroundTransparency = 0
o997456.BorderColor3 = Color3.fromRGB(27, 42, 53)
o997456.BorderSizePixel = 0
o997456.BorderMode = Enum.BorderMode.Outline
o997456.Visible = true
o997456.Rotation = 0
o997456.ClipsDescendants = false
o997456.Active = false
o997456.Selectable = false
o997456.Interactable = true
o997456.AutomaticSize = Enum.AutomaticSize.None
o997456.ZIndex = 1
o997456.LayoutOrder = 0
o997456.ZIndex = 1
o997456.LayoutOrder = 0
o997456.Parent = o740206
local o562600 = Instance.new("Frame")
o562600.Name = "Frame"
o562600.Size = UDim2.new(0, 244, 0, 340)
o562600.Position = UDim2.new(0, 357, 0, 0)
o562600.AnchorPoint = Vector2.new(0, 0)
o562600.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o562600.BackgroundTransparency = 1
o562600.BorderColor3 = Color3.fromRGB(27, 42, 53)
o562600.BorderSizePixel = 1
o562600.BorderMode = Enum.BorderMode.Outline
o562600.Visible = true
o562600.Rotation = 0
o562600.ClipsDescendants = false
o562600.Active = false
o562600.Selectable = false
o562600.Interactable = true
o562600.AutomaticSize = Enum.AutomaticSize.None
o562600.ZIndex = 1
o562600.LayoutOrder = 0
o562600.ZIndex = 1
o562600.LayoutOrder = 0
o562600.Parent = o740206
local o329109 = Instance.new("TextLabel")
o329109.Name = "TextLabel"
o329109.Size = UDim2.new(0, 184, 0, 14)
o329109.Position = UDim2.new(0, 28, 0, 30)
o329109.AnchorPoint = Vector2.new(0, 0)
o329109.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o329109.BackgroundTransparency = 1
o329109.BorderColor3 = Color3.fromRGB(27, 42, 53)
o329109.BorderSizePixel = 1
o329109.BorderMode = Enum.BorderMode.Outline
o329109.Visible = true
o329109.Rotation = 0
o329109.ClipsDescendants = false
o329109.Active = false
o329109.Selectable = false
o329109.Interactable = true
o329109.AutomaticSize = Enum.AutomaticSize.None
o329109.ZIndex = 1
o329109.LayoutOrder = 0
o329109.Text = "Detected game"
o329109.TextSize = 11
o329109.TextScaled = false
o329109.TextWrapped = false
o329109.TextColor3 = Color3.fromRGB(125, 115, 126)
o329109.TextXAlignment = Enum.TextXAlignment.Left
o329109.TextYAlignment = Enum.TextYAlignment.Center
o329109.TextTransparency = 0
o329109.RichText = false
o329109.LineHeight = 1
o329109.MaxVisibleGraphemes = -1
o329109.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o329109.TextStrokeTransparency = 1
o329109.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o329109.TextSize = 11
o329109.TextScaled = false
o329109.ZIndex = 1
o329109.LayoutOrder = 0
o329109.Parent = o562600
local o185506 = Instance.new("Frame")
o185506.Name = "Frame"
o185506.Size = UDim2.new(0, 188, 0, 60)
o185506.Position = UDim2.new(0, 28, 0, 50)
o185506.AnchorPoint = Vector2.new(0, 0)
o185506.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
o185506.BackgroundTransparency = 0
o185506.BorderColor3 = Color3.fromRGB(27, 42, 53)
o185506.BorderSizePixel = 0
o185506.BorderMode = Enum.BorderMode.Outline
o185506.Visible = true
o185506.Rotation = 0
o185506.ClipsDescendants = false
o185506.Active = false
o185506.Selectable = false
o185506.Interactable = true
o185506.AutomaticSize = Enum.AutomaticSize.None
o185506.ZIndex = 1
o185506.LayoutOrder = 0
o185506.ZIndex = 1
o185506.LayoutOrder = 0
o185506.Parent = o562600
local gl_o185506 = Instance.new("UIGradient")
gl_o185506.Name = "Gloss"
gl_o185506.Rotation = 90
gl_o185506.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(235, 235, 235)), ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))})
gl_o185506.Parent = o185506
local o651229 = Instance.new("UICorner")
o651229.Name = "UICorner"
o651229.CornerRadius = UDim.new(0, 8)
o651229.Parent = o185506
local o632236 = Instance.new("UIStroke")
o632236.Name = "UIStroke"
o632236.ZIndex = 1
o632236.Thickness = 1
o632236.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
o632236.LineJoinMode = Enum.LineJoinMode.Round
o632236.Color = Color3.fromRGB(74, 74, 74)
o632236.Transparency = 0
o632236.Parent = o185506
local o948994 = Instance.new("ImageLabel")
o948994.Name = "ImageLabel"
o948994.Size = UDim2.new(0, 38, 0, 38)
o948994.Position = UDim2.new(0, 11, 0, 11)
o948994.AnchorPoint = Vector2.new(0, 0)
o948994.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
o948994.BackgroundTransparency = 0
o948994.BorderColor3 = Color3.fromRGB(27, 42, 53)
o948994.BorderSizePixel = 0
o948994.BorderMode = Enum.BorderMode.Outline
o948994.Visible = true
o948994.Rotation = 0
o948994.ClipsDescendants = false
o948994.Active = false
o948994.Selectable = false
o948994.Interactable = true
o948994.AutomaticSize = Enum.AutomaticSize.None
o948994.ZIndex = 1
o948994.LayoutOrder = 0
o948994.Image = "rbxassetid://74584987850498"
o948994.ImageColor3 = Color3.fromRGB(255, 255, 255)
o948994.ImageTransparency = 0
o948994.ImageRectOffset = Vector2.new(0, 0)
o948994.ImageRectSize = Vector2.new(0, 0)
o948994.ScaleType = Enum.ScaleType.Stretch
o948994.SliceCenter = Rect.new(0, 0, 0, 0)
o948994.SliceScale = 1
o948994.TileSize = UDim2.new(1, 0, 1, 0)
o948994.ResampleMode = Enum.ResamplerMode.Default
o948994.ZIndex = 1
o948994.LayoutOrder = 0
o948994.Parent = o185506
local gl_o948994 = Instance.new("UIGradient")
gl_o948994.Name = "Gloss"
gl_o948994.Rotation = 90
gl_o948994.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(235, 235, 235)), ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 170, 170))})
gl_o948994.Parent = o948994
local o314499 = Instance.new("UICorner")
o314499.Name = "UICorner"
o314499.CornerRadius = UDim.new(0, 7)
o314499.Parent = o948994
local o583099 = Instance.new("UIStroke")
o583099.Name = "UIStroke"
o583099.ZIndex = 1
o583099.Thickness = 1
o583099.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
o583099.LineJoinMode = Enum.LineJoinMode.Round
o583099.Color = Color3.fromRGB(74, 74, 74)
o583099.Transparency = 0
o583099.Parent = o948994
local o860169 = Instance.new("TextLabel")
o860169.Name = "TextLabel"
o860169.Size = UDim2.new(0, 122, 0, 14)
o860169.Position = UDim2.new(0, 58, 0, 15)
o860169.AnchorPoint = Vector2.new(0, 0)
o860169.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o860169.BackgroundTransparency = 1
o860169.BorderColor3 = Color3.fromRGB(27, 42, 53)
o860169.BorderSizePixel = 1
o860169.BorderMode = Enum.BorderMode.Outline
o860169.Visible = true
o860169.Rotation = 0
o860169.ClipsDescendants = false
o860169.Active = false
o860169.Selectable = false
o860169.Interactable = true
o860169.AutomaticSize = Enum.AutomaticSize.None
o860169.ZIndex = 1
o860169.LayoutOrder = 0
o860169.Text = "[UP] Just a baseplate."
o860169.TextSize = 12
o860169.TextScaled = false
o860169.TextWrapped = false
o860169.TextColor3 = Color3.fromRGB(233, 229, 234)
o860169.TextXAlignment = Enum.TextXAlignment.Left
o860169.TextYAlignment = Enum.TextYAlignment.Center
o860169.TextTransparency = 0
o860169.RichText = false
o860169.LineHeight = 1
o860169.MaxVisibleGraphemes = -1
o860169.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o860169.TextStrokeTransparency = 1
o860169.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o860169.TextSize = 12
o860169.TextScaled = false
o860169.ZIndex = 1
o860169.LayoutOrder = 0
o860169.Parent = o185506
local o798099 = Instance.new("TextLabel")
o798099.Name = "TextLabel"
o798099.Size = UDim2.new(0, 122, 0, 13)
o798099.Position = UDim2.new(0, 58, 0, 32)
o798099.AnchorPoint = Vector2.new(0, 0)
o798099.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o798099.BackgroundTransparency = 1
o798099.BorderColor3 = Color3.fromRGB(27, 42, 53)
o798099.BorderSizePixel = 1
o798099.BorderMode = Enum.BorderMode.Outline
o798099.Visible = true
o798099.Rotation = 0
o798099.ClipsDescendants = false
o798099.Active = false
o798099.Selectable = false
o798099.Interactable = true
o798099.AutomaticSize = Enum.AutomaticSize.None
o798099.ZIndex = 1
o798099.LayoutOrder = 0
o798099.Text = "Not in our list"
o798099.TextSize = 11
o798099.TextScaled = false
o798099.TextWrapped = false
o798099.TextColor3 = Color3.fromRGB(125, 115, 126)
o798099.TextXAlignment = Enum.TextXAlignment.Left
o798099.TextYAlignment = Enum.TextYAlignment.Center
o798099.TextTransparency = 0
o798099.RichText = false
o798099.LineHeight = 1
o798099.MaxVisibleGraphemes = -1
o798099.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o798099.TextStrokeTransparency = 1
o798099.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o798099.TextSize = 11
o798099.TextScaled = false
o798099.ZIndex = 1
o798099.LayoutOrder = 0
o798099.Parent = o185506
local o905884 = Instance.new("TextLabel")
o905884.Name = "TextLabel"
o905884.Size = UDim2.new(0, 90, 0, 14)
o905884.Position = UDim2.new(0, 28, 0, 126)
o905884.AnchorPoint = Vector2.new(0, 0)
o905884.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o905884.BackgroundTransparency = 1
o905884.BorderColor3 = Color3.fromRGB(27, 42, 53)
o905884.BorderSizePixel = 1
o905884.BorderMode = Enum.BorderMode.Outline
o905884.Visible = true
o905884.Rotation = 0
o905884.ClipsDescendants = false
o905884.Active = false
o905884.Selectable = false
o905884.Interactable = true
o905884.AutomaticSize = Enum.AutomaticSize.None
o905884.ZIndex = 1
o905884.LayoutOrder = 0
o905884.Text = "Executor"
o905884.TextSize = 11
o905884.TextScaled = false
o905884.TextWrapped = false
o905884.TextColor3 = Color3.fromRGB(125, 115, 126)
o905884.TextXAlignment = Enum.TextXAlignment.Left
o905884.TextYAlignment = Enum.TextYAlignment.Center
o905884.TextTransparency = 0
o905884.RichText = false
o905884.LineHeight = 1
o905884.MaxVisibleGraphemes = -1
o905884.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o905884.TextStrokeTransparency = 1
o905884.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o905884.TextSize = 11
o905884.TextScaled = false
o905884.ZIndex = 1
o905884.LayoutOrder = 0
o905884.Parent = o562600
local o955398 = Instance.new("TextLabel")
o955398.Name = "TextLabel"
o955398.Size = UDim2.new(0, 96, 0, 14)
o955398.Position = UDim2.new(0, 120, 0, 126)
o955398.AnchorPoint = Vector2.new(0, 0)
o955398.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o955398.BackgroundTransparency = 1
o955398.BorderColor3 = Color3.fromRGB(27, 42, 53)
o955398.BorderSizePixel = 1
o955398.BorderMode = Enum.BorderMode.Outline
o955398.Visible = true
o955398.Rotation = 0
o955398.ClipsDescendants = false
o955398.Active = false
o955398.Selectable = false
o955398.Interactable = true
o955398.AutomaticSize = Enum.AutomaticSize.None
o955398.ZIndex = 1
o955398.LayoutOrder = 0
o955398.Text = "Delta"
o955398.TextSize = 11
o955398.TextScaled = false
o955398.TextWrapped = false
o955398.TextColor3 = Color3.fromRGB(233, 229, 234)
o955398.TextXAlignment = Enum.TextXAlignment.Right
o955398.TextYAlignment = Enum.TextYAlignment.Center
o955398.TextTransparency = 0
o955398.RichText = false
o955398.LineHeight = 1
o955398.MaxVisibleGraphemes = -1
o955398.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o955398.TextStrokeTransparency = 1
o955398.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o955398.TextSize = 11
o955398.TextScaled = false
o955398.ZIndex = 1
o955398.LayoutOrder = 0
o955398.Parent = o562600
local o613672 = Instance.new("TextLabel")
o613672.Name = "TextLabel"
o613672.Size = UDim2.new(0, 90, 0, 14)
o613672.Position = UDim2.new(0, 28, 0, 148)
o613672.AnchorPoint = Vector2.new(0, 0)
o613672.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o613672.BackgroundTransparency = 1
o613672.BorderColor3 = Color3.fromRGB(27, 42, 53)
o613672.BorderSizePixel = 1
o613672.BorderMode = Enum.BorderMode.Outline
o613672.Visible = true
o613672.Rotation = 0
o613672.ClipsDescendants = false
o613672.Active = false
o613672.Selectable = false
o613672.Interactable = true
o613672.AutomaticSize = Enum.AutomaticSize.None
o613672.ZIndex = 1
o613672.LayoutOrder = 0
o613672.Text = "Status"
o613672.TextSize = 11
o613672.TextScaled = false
o613672.TextWrapped = false
o613672.TextColor3 = Color3.fromRGB(125, 115, 126)
o613672.TextXAlignment = Enum.TextXAlignment.Left
o613672.TextYAlignment = Enum.TextYAlignment.Center
o613672.TextTransparency = 0
o613672.RichText = false
o613672.LineHeight = 1
o613672.MaxVisibleGraphemes = -1
o613672.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o613672.TextStrokeTransparency = 1
o613672.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o613672.TextSize = 11
o613672.TextScaled = false
o613672.ZIndex = 1
o613672.LayoutOrder = 0
o613672.Parent = o562600
local o576053 = Instance.new("TextLabel")
o576053.Name = "TextLabel"
o576053.Size = UDim2.new(0, 96, 0, 14)
o576053.Position = UDim2.new(0, 120, 0, 148)
o576053.AnchorPoint = Vector2.new(0, 0)
o576053.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o576053.BackgroundTransparency = 1
o576053.BorderColor3 = Color3.fromRGB(27, 42, 53)
o576053.BorderSizePixel = 1
o576053.BorderMode = Enum.BorderMode.Outline
o576053.Visible = true
o576053.Rotation = 0
o576053.ClipsDescendants = false
o576053.Active = false
o576053.Selectable = false
o576053.Interactable = true
o576053.AutomaticSize = Enum.AutomaticSize.None
o576053.ZIndex = 1
o576053.LayoutOrder = 0
o576053.Text = "Key required"
o576053.TextSize = 11
o576053.TextScaled = false
o576053.TextWrapped = false
o576053.TextColor3 = Color3.fromRGB(255, 255, 255)
o576053.TextXAlignment = Enum.TextXAlignment.Right
o576053.TextYAlignment = Enum.TextYAlignment.Center
o576053.TextTransparency = 0
o576053.RichText = false
o576053.LineHeight = 1
o576053.MaxVisibleGraphemes = -1
o576053.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o576053.TextStrokeTransparency = 1
o576053.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o576053.TextSize = 11
o576053.TextScaled = false
o576053.ZIndex = 1
o576053.LayoutOrder = 0
o576053.Parent = o562600
local o365821 = Instance.new("Frame")
o365821.Name = "Frame"
o365821.Size = UDim2.new(0, 188, 0, 1)
o365821.Position = UDim2.new(0, 28, 0, 176)
o365821.AnchorPoint = Vector2.new(0, 0)
o365821.BackgroundColor3 = Color3.fromRGB(74, 74, 74)
o365821.BackgroundTransparency = 0
o365821.BorderColor3 = Color3.fromRGB(27, 42, 53)
o365821.BorderSizePixel = 0
o365821.BorderMode = Enum.BorderMode.Outline
o365821.Visible = true
o365821.Rotation = 0
o365821.ClipsDescendants = false
o365821.Active = false
o365821.Selectable = false
o365821.Interactable = true
o365821.AutomaticSize = Enum.AutomaticSize.None
o365821.ZIndex = 1
o365821.LayoutOrder = 0
o365821.ZIndex = 1
o365821.LayoutOrder = 0
o365821.Parent = o562600
local o138397 = Instance.new("TextButton")
o138397.Name = "TextButton"
o138397.Size = UDim2.new(0, 188, 0, 48)
o138397.Position = UDim2.new(0, 28, 0, 190)
o138397.AnchorPoint = Vector2.new(0, 0)
o138397.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
o138397.BackgroundTransparency = 0
o138397.BorderColor3 = Color3.fromRGB(27, 42, 53)
o138397.BorderSizePixel = 1
o138397.BorderMode = Enum.BorderMode.Outline
o138397.Visible = true
o138397.Rotation = 0
o138397.ClipsDescendants = false
o138397.Active = true
o138397.Selectable = true
o138397.Interactable = true
o138397.AutomaticSize = Enum.AutomaticSize.None
o138397.ZIndex = 1
o138397.LayoutOrder = 0
o138397.AutoButtonColor = false
o138397.Modal = false
o138397.Selected = false
o138397.Text = ""
o138397.TextSize = 8
o138397.TextScaled = false
o138397.TextWrapped = false
o138397.TextColor3 = Color3.fromRGB(27, 42, 53)
o138397.TextXAlignment = Enum.TextXAlignment.Center
o138397.TextYAlignment = Enum.TextYAlignment.Center
o138397.TextTransparency = 0
o138397.RichText = false
o138397.LineHeight = 1
o138397.MaxVisibleGraphemes = -1
o138397.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o138397.TextStrokeTransparency = 1
o138397.FontFace = Font.new("rbxasset://fonts/families/LegacyArial.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o138397.Font = Enum.Font.Legacy
o138397.TextSize = 8
o138397.TextScaled = false
o138397.ZIndex = 1
o138397.LayoutOrder = 0
o138397.Parent = o562600
local gl_o138397 = Instance.new("UIGradient")
gl_o138397.Name = "Gloss"
gl_o138397.Rotation = 90
gl_o138397.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(235, 235, 235)), ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))})
gl_o138397.Parent = o138397
local o705156 = Instance.new("UICorner")
o705156.Name = "UICorner"
o705156.CornerRadius = UDim.new(0, 8)
o705156.Parent = o138397
local o630141 = Instance.new("UIStroke")
o630141.Name = "UIStroke"
o630141.ZIndex = 1
o630141.Thickness = 1
o630141.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
o630141.LineJoinMode = Enum.LineJoinMode.Round
o630141.Color = Color3.fromRGB(74, 74, 74)
o630141.Transparency = 0
o630141.Parent = o138397
local o179911 = Instance.new("Frame")
o179911.Name = "Frame"
o179911.Size = UDim2.new(0, 16, 0, 16)
o179911.Position = UDim2.new(0, 13, 0, 16)
o179911.AnchorPoint = Vector2.new(0, 0)
o179911.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o179911.BackgroundTransparency = 1
o179911.BorderColor3 = Color3.fromRGB(27, 42, 53)
o179911.BorderSizePixel = 1
o179911.BorderMode = Enum.BorderMode.Outline
o179911.Visible = true
o179911.Rotation = 0
o179911.ClipsDescendants = false
o179911.Active = false
o179911.Selectable = false
o179911.Interactable = true
o179911.AutomaticSize = Enum.AutomaticSize.None
o179911.ZIndex = 1
o179911.LayoutOrder = 0
o179911.ZIndex = 1
o179911.LayoutOrder = 0
o179911.Parent = o138397
local o474802 = Instance.new("ImageLabel")
o474802.Name = "iconglow"
o474802.Size = UDim2.new(2, 0, 2, 0)
o474802.Position = UDim2.new(0.5, 0, 0.5, 0)
o474802.AnchorPoint = Vector2.new(0.5, 0.5)
o474802.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o474802.BackgroundTransparency = 1
o474802.BorderColor3 = Color3.fromRGB(27, 42, 53)
o474802.BorderSizePixel = 1
o474802.BorderMode = Enum.BorderMode.Outline
o474802.Visible = true
o474802.Rotation = 0
o474802.ClipsDescendants = false
o474802.Active = false
o474802.Selectable = false
o474802.Interactable = true
o474802.AutomaticSize = Enum.AutomaticSize.None
o474802.ZIndex = 0
o474802.LayoutOrder = 0
o474802.Image = "rbxassetid://8992230677"
o474802.ImageColor3 = Color3.fromRGB(255, 255, 255)
o474802.ImageTransparency = 0.8999999761581421
o474802.ImageRectOffset = Vector2.new(0, 0)
o474802.ImageRectSize = Vector2.new(0, 0)
o474802.ScaleType = Enum.ScaleType.Stretch
o474802.SliceCenter = Rect.new(0, 0, 0, 0)
o474802.SliceScale = 1
o474802.TileSize = UDim2.new(1, 0, 1, 0)
o474802.ResampleMode = Enum.ResamplerMode.Default
o474802.ZIndex = 0
o474802.LayoutOrder = 0
o474802.Parent = o179911
local o563038 = Instance.new("ImageLabel")
o563038.Name = "ImageLabel"
o563038.Size = UDim2.new(1, 0, 1, 0)
o563038.Position = UDim2.new(0, 0, 0, 0)
o563038.AnchorPoint = Vector2.new(0, 0)
o563038.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o563038.BackgroundTransparency = 1
o563038.BorderColor3 = Color3.fromRGB(27, 42, 53)
o563038.BorderSizePixel = 1
o563038.BorderMode = Enum.BorderMode.Outline
o563038.Visible = true
o563038.Rotation = 0
o563038.ClipsDescendants = false
o563038.Active = false
o563038.Selectable = false
o563038.Interactable = true
o563038.AutomaticSize = Enum.AutomaticSize.None
o563038.ZIndex = 1
o563038.LayoutOrder = 0
o563038.Image = "rbxassetid://122605056588923"
o563038.ImageColor3 = Color3.fromRGB(255, 255, 255)
o563038.ImageTransparency = 0
o563038.ImageRectOffset = Vector2.new(325, 775)
o563038.ImageRectSize = Vector2.new(24, 24)
o563038.ScaleType = Enum.ScaleType.Stretch
o563038.SliceCenter = Rect.new(0, 0, 0, 0)
o563038.SliceScale = 1
o563038.TileSize = UDim2.new(1, 0, 1, 0)
o563038.ResampleMode = Enum.ResamplerMode.Default
o563038.ZIndex = 1
o563038.LayoutOrder = 0
o563038.Parent = o179911
local o210045 = Instance.new("TextLabel")
o210045.Name = "TextLabel"
o210045.Size = UDim2.new(0, 120, 0, 14)
o210045.Position = UDim2.new(0, 40, 0, 10)
o210045.AnchorPoint = Vector2.new(0, 0)
o210045.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o210045.BackgroundTransparency = 1
o210045.BorderColor3 = Color3.fromRGB(27, 42, 53)
o210045.BorderSizePixel = 1
o210045.BorderMode = Enum.BorderMode.Outline
o210045.Visible = true
o210045.Rotation = 0
o210045.ClipsDescendants = false
o210045.Active = false
o210045.Selectable = false
o210045.Interactable = true
o210045.AutomaticSize = Enum.AutomaticSize.None
o210045.ZIndex = 1
o210045.LayoutOrder = 0
o210045.Text = "Discord"
o210045.TextSize = 12
o210045.TextScaled = false
o210045.TextWrapped = false
o210045.TextColor3 = Color3.fromRGB(233, 229, 234)
o210045.TextXAlignment = Enum.TextXAlignment.Left
o210045.TextYAlignment = Enum.TextYAlignment.Center
o210045.TextTransparency = 0
o210045.RichText = false
o210045.LineHeight = 1
o210045.MaxVisibleGraphemes = -1
o210045.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o210045.TextStrokeTransparency = 1
o210045.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o210045.TextSize = 12
o210045.TextScaled = false
o210045.ZIndex = 1
o210045.LayoutOrder = 0
o210045.Parent = o138397
local o120197 = Instance.new("TextLabel")
o120197.Name = "TextLabel"
o120197.Size = UDim2.new(0, 132, 0, 13)
o120197.Position = UDim2.new(0, 40, 0, 25)
o120197.AnchorPoint = Vector2.new(0, 0)
o120197.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o120197.BackgroundTransparency = 1
o120197.BorderColor3 = Color3.fromRGB(27, 42, 53)
o120197.BorderSizePixel = 1
o120197.BorderMode = Enum.BorderMode.Outline
o120197.Visible = true
o120197.Rotation = 0
o120197.ClipsDescendants = false
o120197.Active = false
o120197.Selectable = false
o120197.Interactable = true
o120197.AutomaticSize = Enum.AutomaticSize.None
o120197.ZIndex = 1
o120197.LayoutOrder = 0
o120197.Text = "discord.gg/blackcloverhub"
o120197.TextSize = 11
o120197.TextScaled = false
o120197.TextWrapped = false
o120197.TextColor3 = Color3.fromRGB(125, 115, 126)
o120197.TextXAlignment = Enum.TextXAlignment.Left
o120197.TextYAlignment = Enum.TextYAlignment.Center
o120197.TextTransparency = 0
o120197.RichText = false
o120197.LineHeight = 1
o120197.MaxVisibleGraphemes = -1
o120197.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o120197.TextStrokeTransparency = 1
o120197.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o120197.TextSize = 11
o120197.TextScaled = false
o120197.ZIndex = 1
o120197.LayoutOrder = 0
o120197.Parent = o138397
local o427664 = Instance.new("TextButton")
o427664.Name = "TextButton"
o427664.Size = UDim2.new(0, 188, 0, 48)
o427664.Position = UDim2.new(0, 28, 0, 246)
o427664.AnchorPoint = Vector2.new(0, 0)
o427664.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
o427664.BackgroundTransparency = 0
o427664.BorderColor3 = Color3.fromRGB(27, 42, 53)
o427664.BorderSizePixel = 1
o427664.BorderMode = Enum.BorderMode.Outline
o427664.Visible = true
o427664.Rotation = 0
o427664.ClipsDescendants = false
o427664.Active = true
o427664.Selectable = true
o427664.Interactable = true
o427664.AutomaticSize = Enum.AutomaticSize.None
o427664.ZIndex = 1
o427664.LayoutOrder = 0
o427664.AutoButtonColor = false
o427664.Modal = false
o427664.Selected = false
o427664.Text = ""
o427664.TextSize = 8
o427664.TextScaled = false
o427664.TextWrapped = false
o427664.TextColor3 = Color3.fromRGB(27, 42, 53)
o427664.TextXAlignment = Enum.TextXAlignment.Center
o427664.TextYAlignment = Enum.TextYAlignment.Center
o427664.TextTransparency = 0
o427664.RichText = false
o427664.LineHeight = 1
o427664.MaxVisibleGraphemes = -1
o427664.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o427664.TextStrokeTransparency = 1
o427664.FontFace = Font.new("rbxasset://fonts/families/LegacyArial.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o427664.Font = Enum.Font.Legacy
o427664.TextSize = 8
o427664.TextScaled = false
o427664.ZIndex = 1
o427664.LayoutOrder = 0
o427664.Parent = o562600
local gl_o427664 = Instance.new("UIGradient")
gl_o427664.Name = "Gloss"
gl_o427664.Rotation = 90
gl_o427664.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(235, 235, 235)), ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))})
gl_o427664.Parent = o427664
local o716425 = Instance.new("UICorner")
o716425.Name = "UICorner"
o716425.CornerRadius = UDim.new(0, 8)
o716425.Parent = o427664
local o877148 = Instance.new("UIStroke")
o877148.Name = "UIStroke"
o877148.ZIndex = 1
o877148.Thickness = 1
o877148.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
o877148.LineJoinMode = Enum.LineJoinMode.Round
o877148.Color = Color3.fromRGB(74, 74, 74)
o877148.Transparency = 0
o877148.Parent = o427664
local o781418 = Instance.new("Frame")
o781418.Name = "Frame"
o781418.Size = UDim2.new(0, 16, 0, 16)
o781418.Position = UDim2.new(0, 13, 0, 16)
o781418.AnchorPoint = Vector2.new(0, 0)
o781418.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o781418.BackgroundTransparency = 1
o781418.BorderColor3 = Color3.fromRGB(27, 42, 53)
o781418.BorderSizePixel = 1
o781418.BorderMode = Enum.BorderMode.Outline
o781418.Visible = true
o781418.Rotation = 0
o781418.ClipsDescendants = false
o781418.Active = false
o781418.Selectable = false
o781418.Interactable = true
o781418.AutomaticSize = Enum.AutomaticSize.None
o781418.ZIndex = 1
o781418.LayoutOrder = 0
o781418.ZIndex = 1
o781418.LayoutOrder = 0
o781418.Parent = o427664
local o812220 = Instance.new("ImageLabel")
o812220.Name = "iconglow"
o812220.Size = UDim2.new(2, 0, 2, 0)
o812220.Position = UDim2.new(0.5, 0, 0.5, 0)
o812220.AnchorPoint = Vector2.new(0.5, 0.5)
o812220.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o812220.BackgroundTransparency = 1
o812220.BorderColor3 = Color3.fromRGB(27, 42, 53)
o812220.BorderSizePixel = 1
o812220.BorderMode = Enum.BorderMode.Outline
o812220.Visible = true
o812220.Rotation = 0
o812220.ClipsDescendants = false
o812220.Active = false
o812220.Selectable = false
o812220.Interactable = true
o812220.AutomaticSize = Enum.AutomaticSize.None
o812220.ZIndex = 0
o812220.LayoutOrder = 0
o812220.Image = "rbxassetid://8992230677"
o812220.ImageColor3 = Color3.fromRGB(255, 255, 255)
o812220.ImageTransparency = 0.8999999761581421
o812220.ImageRectOffset = Vector2.new(0, 0)
o812220.ImageRectSize = Vector2.new(0, 0)
o812220.ScaleType = Enum.ScaleType.Stretch
o812220.SliceCenter = Rect.new(0, 0, 0, 0)
o812220.SliceScale = 1
o812220.TileSize = UDim2.new(1, 0, 1, 0)
o812220.ResampleMode = Enum.ResamplerMode.Default
o812220.ZIndex = 0
o812220.LayoutOrder = 0
o812220.Parent = o781418
local o714051 = Instance.new("ImageLabel")
o714051.Name = "ImageLabel"
o714051.Size = UDim2.new(1, 0, 1, 0)
o714051.Position = UDim2.new(0, 0, 0, 0)
o714051.AnchorPoint = Vector2.new(0, 0)
o714051.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o714051.BackgroundTransparency = 1
o714051.BorderColor3 = Color3.fromRGB(27, 42, 53)
o714051.BorderSizePixel = 1
o714051.BorderMode = Enum.BorderMode.Outline
o714051.Visible = true
o714051.Rotation = 0
o714051.ClipsDescendants = false
o714051.Active = false
o714051.Selectable = false
o714051.Interactable = true
o714051.AutomaticSize = Enum.AutomaticSize.None
o714051.ZIndex = 1
o714051.LayoutOrder = 0
o714051.Image = "rbxassetid://122605056588923"
o714051.ImageColor3 = Color3.fromRGB(255, 255, 255)
o714051.ImageTransparency = 0
o714051.ImageRectOffset = Vector2.new(450, 500)
o714051.ImageRectSize = Vector2.new(24, 24)
o714051.ScaleType = Enum.ScaleType.Stretch
o714051.SliceCenter = Rect.new(0, 0, 0, 0)
o714051.SliceScale = 1
o714051.TileSize = UDim2.new(1, 0, 1, 0)
o714051.ResampleMode = Enum.ResamplerMode.Default
o714051.ZIndex = 1
o714051.LayoutOrder = 0
o714051.Parent = o781418
local o344901 = Instance.new("TextLabel")
o344901.Name = "TextLabel"
o344901.Size = UDim2.new(0, 120, 0, 14)
o344901.Position = UDim2.new(0, 40, 0, 10)
o344901.AnchorPoint = Vector2.new(0, 0)
o344901.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o344901.BackgroundTransparency = 1
o344901.BorderColor3 = Color3.fromRGB(27, 42, 53)
o344901.BorderSizePixel = 1
o344901.BorderMode = Enum.BorderMode.Outline
o344901.Visible = true
o344901.Rotation = 0
o344901.ClipsDescendants = false
o344901.Active = false
o344901.Selectable = false
o344901.Interactable = true
o344901.AutomaticSize = Enum.AutomaticSize.None
o344901.ZIndex = 1
o344901.LayoutOrder = 0
o344901.Text = "Website"
o344901.TextSize = 12
o344901.TextScaled = false
o344901.TextWrapped = false
o344901.TextColor3 = Color3.fromRGB(233, 229, 234)
o344901.TextXAlignment = Enum.TextXAlignment.Left
o344901.TextYAlignment = Enum.TextYAlignment.Center
o344901.TextTransparency = 0
o344901.RichText = false
o344901.LineHeight = 1
o344901.MaxVisibleGraphemes = -1
o344901.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o344901.TextStrokeTransparency = 1
o344901.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o344901.TextSize = 12
o344901.TextScaled = false
o344901.ZIndex = 1
o344901.LayoutOrder = 0
o344901.Parent = o427664
local o354099 = Instance.new("TextLabel")
o354099.Name = "TextLabel"
o354099.Size = UDim2.new(0, 132, 0, 13)
o354099.Position = UDim2.new(0, 40, 0, 25)
o354099.AnchorPoint = Vector2.new(0, 0)
o354099.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
o354099.BackgroundTransparency = 1
o354099.BorderColor3 = Color3.fromRGB(27, 42, 53)
o354099.BorderSizePixel = 1
o354099.BorderMode = Enum.BorderMode.Outline
o354099.Visible = true
o354099.Rotation = 0
o354099.ClipsDescendants = false
o354099.Active = false
o354099.Selectable = false
o354099.Interactable = true
o354099.AutomaticSize = Enum.AutomaticSize.None
o354099.ZIndex = 1
o354099.LayoutOrder = 0
o354099.Text = "blackcloverhub.vercel.app"
o354099.TextSize = 11
o354099.TextScaled = false
o354099.TextWrapped = false
o354099.TextColor3 = Color3.fromRGB(125, 115, 126)
o354099.TextXAlignment = Enum.TextXAlignment.Left
o354099.TextYAlignment = Enum.TextYAlignment.Center
o354099.TextTransparency = 0
o354099.RichText = false
o354099.LineHeight = 1
o354099.MaxVisibleGraphemes = -1
o354099.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
o354099.TextStrokeTransparency = 1
o354099.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
o354099.TextSize = 11
o354099.TextScaled = false
o354099.ZIndex = 1
o354099.LayoutOrder = 0
o354099.Parent = o427664
root.Name = "ObsessionHubLoader"
root.Parent = parentGui

--// Wire the UI ==============================================================
local keyBox      = o284290   -- "Paste your key here"
local submitBtn   = o749571   -- Submit
local getKeyBtn   = o354461   -- Get a key
local msgLabel    = o448724   -- message line under the key box
local gameIcon    = o948994   -- game thumbnail
local gameNameLbl = o860169   -- game name
local gameSubLbl  = o798099   -- "Not in our list" / supported
local execLbl     = o955398   -- executor name
local statusLbl   = o576053   -- status pill text
local discordBtn  = o138397   -- Discord chip
local websiteBtn  = o427664   -- Website chip
local mainFrame   = o659414   -- whole window (for dragging)
local card        = o740206   -- the card

local GOOD = Color3.fromRGB(110, 231, 164)
local BAD  = Color3.fromRGB(255, 92, 106)
local MUTE = Color3.fromRGB(150, 150, 150)

local function say(txt, col) msgLabel.Text = txt or ""; msgLabel.TextColor3 = col or MUTE end
local function setStatus(txt, col) statusLbl.Text = txt; statusLbl.TextColor3 = col or BAD end

-- Detected game: real name + icon
local detected = detectScript()
-- Clean Roblox game names: drop "[🌍2]" / "(UPD)" style tags and emojis the font can't show.
local function cleanName(raw)
    local n = tostring(raw or "")
    n = n:gsub("%b[]", ""):gsub("%b()", ""):gsub("%b{}", "")
    n = n:gsub("[\128-\255]+", "")                 -- emojis / symbols
    n = n:gsub("^[%s%p]+", ""):gsub("[%s|%-]+$", ""):gsub("%s+", " ")
    if n == "" then n = tostring(raw or "") end
    return n
end
-- Let the name use two lines, then trim with "..." if it's still too long
gameNameLbl.Size = UDim2.new(0, 122, 0, 28)
gameNameLbl.Position = UDim2.new(0, 58, 0, 7)
gameNameLbl.TextWrapped = true
gameNameLbl.TextYAlignment = Enum.TextYAlignment.Center
pcall(function() gameNameLbl.TextTruncate = Enum.TextTruncate.AtEnd end)
gameSubLbl.Position = UDim2.new(0, 58, 0, 37)
gameNameLbl.Text = "Game " .. tostring(game.PlaceId)
task.spawn(function()
    local ok, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
    if ok and info and info.Name then gameNameLbl.Text = cleanName(info.Name) end
end)

-- Logo: a decal if you set one, otherwise download the eye image from LogoURL
local logoImg = o123988
task.spawn(function()
    if Config.LogoImage and Config.LogoImage ~= "" then return end
    local getAsset = getcustomasset or getsynasset
    if not getAsset or not writefile or not Config.LogoURL or Config.LogoURL == "" then return end
    local ok, data = pcall(function() return game:HttpGet(Config.LogoURL, true) end)
    if not ok or type(data) ~= "string" or #data < 200 or data:sub(1, 1) == "<" or data:find("^404") then return end
    local path = "ObsessionHub_logo.png"
    if not pcall(writefile, path, data) then return end
    local ok2, id = pcall(getAsset, path)
    if ok2 and id then logoImg.Image = id end
end)
pcall(function() gameIcon.Image = "rbxthumb://type=GameIcon&id=" .. tostring(game.GameId) .. "&w=150&h=150" end)
if detected then
    gameSubLbl.Text = "Supported"
    gameSubLbl.TextColor3 = GOOD
else
    gameSubLbl.Text = "Not in our list"
    gameSubLbl.TextColor3 = MUTE
end

-- Executor name
do
    local name = "Unknown"
    pcall(function()
        if identifyexecutor then name = (identifyexecutor()) or name
        elseif getexecutorname then name = getexecutorname() or name end
    end)
    execLbl.Text = tostring(name)
end

-- Status
if not detected then setStatus("Game not supported", BAD)
elseif detected.requiresKey then setStatus("Key required", BAD)
else setStatus("Free - no key", GOOD) end

-- Buy Premium: centered under Submit / Get a key
do
    local leftPanel = submitBtn.Parent
    local buy = Instance.new("TextButton")
    buy.Name = "BuyPremium"
    buy.Size = UDim2.new(0, 300, 0, 32)
    buy.Position = UDim2.new(0, 28, 0, 256)
    buy.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    buy.AutoButtonColor = false
    buy.Text = "Buy Premium"
    buy.TextSize = 13
    buy.TextColor3 = Color3.fromRGB(255, 255, 255)
    buy.TextXAlignment = Enum.TextXAlignment.Center
    buy.TextYAlignment = Enum.TextYAlignment.Center
    buy.TextWrapped = false
    pcall(function() buy.TextTruncate = Enum.TextTruncate.AtEnd end)
    buy.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    buy.ZIndex = 2
    buy.Visible = (Config.Premium ~= nil and Config.Premium ~= "")
    local bc = Instance.new("UICorner", buy); bc.CornerRadius = UDim.new(0, 8)
    local bs = Instance.new("UIStroke", buy)
    bs.Color = Color3.fromRGB(255, 255, 255); bs.Thickness = 1; bs.Transparency = 0.2
    bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local bg = Instance.new("UIGradient", buy)
    bg.Rotation = 90
    bg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(215, 215, 215)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150)),
    })
    buy.Parent = leftPanel
    local toast
    local toastTick = 0
    buy.MouseButton1Click:Connect(function()
        setClip(Config.Premium)
        toastTick = toastTick + 1
        local mine = toastTick
        if toast then toast:Destroy() end
        toast = Instance.new("Frame")
        toast.Name = "PremiumToast"
        toast.AnchorPoint = Vector2.new(1, 1)
        toast.Position = UDim2.new(1, -16, 1, -16)
        toast.Size = UDim2.new(0, 230, 0, 46)
        toast.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        toast.ZIndex = 100
        local tc = Instance.new("UICorner", toast); tc.CornerRadius = UDim.new(0, 10)
        local ts = Instance.new("UIStroke", toast)
        ts.Color = Color3.fromRGB(255, 255, 255); ts.Thickness = 1; ts.Transparency = 0.2
        local tt = Instance.new("TextLabel", toast)
        tt.BackgroundTransparency = 1
        tt.Size = UDim2.new(1, -24, 1, 0)
        tt.Position = UDim2.new(0, 12, 0, 0)
        tt.Text = "Premium link copied!"
        tt.TextSize = 13
        tt.TextColor3 = Color3.fromRGB(255, 255, 255)
        tt.TextXAlignment = Enum.TextXAlignment.Left
        tt.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        tt.ZIndex = 101
        toast.Parent = root
        task.delay(2.5, function()
            if toastTick == mine and toast then toast:Destroy(); toast = nil end
        end)
    end)
end

-- Keep every label on one line so nothing runs into its neighbor
for _, b in ipairs({ submitBtn, getKeyBtn, msgLabel }) do
    pcall(function() b.TextWrapped = false; b.TextTruncate = Enum.TextTruncate.AtEnd end)
end

-- Social chips: copy the link
discordBtn.MouseButton1Click:Connect(function()
    if Config.Discord ~= "" then setClip(Config.Discord); notify("BlackCloverHub", "Discord link copied!", 3) end
end)
websiteBtn.MouseButton1Click:Connect(function()
    setClip(Config.Website); notify("BlackCloverHub", "Website link copied!", 3)
end)

-- Get a key: copy the key site link
getKeyBtn.MouseButton1Click:Connect(function()
    setClip(Config.GetKeyURL)
    say("Key link copied - paste it in your browser", GOOD)
    notify("BlackCloverHub", "Get Key link copied to clipboard!", 4)
end)

-- Prefill a saved key
local saved = loadSavedKey()
if saved and saved ~= "" then keyBox.Text = saved end

-- Close button (top-right of the card)
do
    local x = Instance.new("TextButton")
    x.Name = "Close"
    x.Size = UDim2.new(0, 26, 0, 26)
    x.Position = UDim2.new(1, -36, 0, 10)
    x.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    x.BackgroundTransparency = 0.2
    x.Text = "X"
    x.Font = Enum.Font.GothamBold
    x.TextSize = 12
    x.TextColor3 = Color3.fromRGB(255, 255, 255)
    x.AutoButtonColor = true
    x.ZIndex = 50
    local c = Instance.new("UICorner", x); c.CornerRadius = UDim.new(0, 7)
    local s = Instance.new("UIStroke", x); s.Color = Color3.fromRGB(74, 74, 74); s.Thickness = 1
    x.Parent = card
    x.MouseButton1Click:Connect(function() root:Destroy() end)
end

-- Submit: verify -> save -> load
local busy = false
local function submit()
    if busy then return end
    local key = tostring(keyBox.Text or ""):gsub("%s+", ""):upper()
    if key == "" then say("Paste your key first", BAD) return end
    busy = true
    submitBtn.Text = "Checking..."
    say("Checking your key...", MUTE)
    local ok, reason = verifyKey(key)
    submitBtn.Text = "Submit"
    busy = false
    if not ok then
        say(reason or "Key is invalid or expired", BAD)
        setStatus("Invalid key", BAD)
        return
    end
    saveKey(key)
    if getgenv then pcall(function() getgenv().ObsessionVerified = true end) end
    setStatus("Verified", GOOD)
    if not detected then
        say("Key is valid - but this game isn't supported yet", GOOD)
        return
    end
    say("Key verified! Loading " .. tostring(gameNameLbl.Text) .. "...", GOOD)
    if loadScript(detected) then
        if detected.requiresKey then startKeyWatch(key) end
        if Config.CloseAfterLoad then task.delay(0.6, function() pcall(function() root:Destroy() end) end) end
    else
        say("Couldn't load the script - try again", BAD)
    end
end
submitBtn.MouseButton1Click:Connect(submit)
keyBox.FocusLost:Connect(function(enter) if enter then submit() end end)

-- Drag the window
do
    local dragging, startPos, startInput
    mainFrame.Active = true
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, startInput, startPos = true, input.Position, mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInput.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - startInput
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- Fit small screens (phones): scale the 600x340 window down if needed
do
    local cam = workspace.CurrentCamera
    local sc = Instance.new("UIScale"); sc.Parent = mainFrame
    local function fit()
        local v = cam and cam.ViewportSize or Vector2.new(1280, 720)
        sc.Scale = math.min(1, (v.X - 24) / 600, (v.Y - 24) / 340)
    end
    fit()
    if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(fit) end
end
