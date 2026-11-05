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
    Website   = "https://keysystem-obsessionhub.vercel.app",      -- your key site (NO trailing slash)
    GetKeyURL = "https://keysystem-obsessionhub.vercel.app/getkey", -- where users get a key

    -- Base folder (raw) where your script files live. Each script below just uses its file name,
    -- so you don't paste a long raw link every time. CHANGE "KeySystem" if your repo has another name.
    ScriptBase = "https://raw.githubusercontent.com/LazyJiroHub/KeySystem/refs/heads/main/src/",
    Discord   = "https://discord.gg/D8SM7VfTKZ",      -- "" to hide the button
    Youtube   = "https://www.youtube.com/@jirombv",    -- "" to hide the button
    Premium   = "https://discord.gg/D8SM7VfTKZ",      -- Buy Premium link ("" to hide)

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
        { name = "TS",          file = "TSR.lua", requiresKey = true, placeIds = { 72858262610964, 10629695169 } },
        { name = "DB",             file = "DB.lua",  requiresKey = false, placeIds = { 15002061926, 5166944221 } },
        { name = "BASE", file = "BAS.lua", requiresKey = false, placeIds = { 114326934417838, 10765288803 } },
        { name = "AD",             file = "AD.lua",  requiresKey = false, placeIds = { 113290951185459, 10708913337 } },
        { name = "SAE",           file = "SAE.lua", requiresKey = false, placeIds = { 107778070777162, 10563114921 } },
        { name = "SF",             file = "SF.lua",  requiresKey = false, placeIds = { 109020905733214, 9187332740 } },
        { name = "RAP",             file = "RAP.lua", requiresKey = false, placeIds = { 124216119978534, 10035204815 } },
        { name = "DF",           file = "DF.lua",  requiresKey = false, placeIds = { 132239307080610, 10526853622 } },
        { name = "GF",              file = "GF.lua",  requiresKey = false, placeIds = { 75687962646869, 10766957927 } },
        { name = "VS",       file = "VS.lua",  requiresKey = true, placeIds = { 100283815455755, 9224753153 } },
        { name = "PD",          file = "PD.lua",  requiresKey = true, placeIds = { 7336302630, 2862098693 } },
        { name = "LTF",          file = "LTF.lua", requiresKey = true, placeIds = { 118805555015549, 10684750879 } },
        { name = "AH",          file = "AH.lua", requiresKey = true, placeIds = { 10148749921, 78515283254292 } },
        { name = "IV",             file = "IV.lua",  requiresKey = true, placeIds = { 8356562067 } },
        { name = "TFFA",             file = "TFFA.lua",  requiresKey = true, placeIds = { 120219252362013 } }
    },

    -- Optional image shown at the top of the loader. Use YOUR OWN art.
    -- Upload it to Roblox as a Decal, then put its id here, e.g. "rbxassetid://1234567890".
    -- Leave "" for no image (the animated header still looks great).
    BannerImage = "",
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
    bg      = Color3.fromRGB(14, 6, 9),
    panel   = Color3.fromRGB(22, 9, 13),
    stroke  = Color3.fromRGB(60, 24, 32),
    red     = Color3.fromRGB(224, 31, 58),
    red2    = Color3.fromRGB(255, 59, 78),
    violet  = Color3.fromRGB(139, 92, 246),
    blue    = Color3.fromRGB(56, 140, 255),
    cyan    = Color3.fromRGB(80, 220, 255),
    text    = Color3.fromRGB(245, 234, 236),
    muted   = Color3.fromRGB(150, 124, 131),
    good    = Color3.fromRGB(110, 231, 164),
    bad     = Color3.fromRGB(255, 92, 92),
}

--// Small helpers ------------------------------------------------------
local KEY_PATTERN = "^OBSESSION%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w$"

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
        notify("ObsessionHub", "Couldn't download: " .. entry.name, 5)
        return false
    end
    local fn, err = loadstring(src, "=" .. entry.name)
    if not fn then
        notify("ObsessionHub", "Script error: " .. tostring(err), 6)
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
                    LocalPlayer:Kick("\n[ObsessionHub]\nYour key expired or is no longer valid.\nGet a new key to keep playing.")
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
            notify("ObsessionHub", "Loading " .. detected.name .. "...", 4)
            loadScript(detected)
            return
        end
        local saved = loadSavedKey()
        if saved and saved ~= "" then
            local ok = verifyKey(saved)
            if ok then
                notify("ObsessionHub", "Key verified — loading " .. detected.name, 4)
                if loadScript(detected) then startKeyWatch(saved) end
                return
            end
        end
    end
    -- otherwise fall through and open the window (needs a key, or game not supported)
end

--// UI =================================================================
local parentGui = (gethui and gethui()) or CoreGui
pcall(function()
    local old = parentGui:FindFirstChild("ObsessionHubLoader")
    if old then old:Destroy() end
end)

-- state
local verified = (getgenv and getgenv().ObsessionVerified) or false
local currentKey = loadSavedKey()
local selected = Config.Scripts[1]

-- helpers
local function corner(i, r) local c = Instance.new("UICorner", i); c.CornerRadius = UDim.new(0, r or 10); return c end
local function strokeOf(i, col, th) local s = Instance.new("UIStroke", i); s.Color = col or T.stroke; s.Thickness = th or 1; return s end
local function padAll(i, p) local u = Instance.new("UIPadding", i)
    u.PaddingLeft = UDim.new(0, p); u.PaddingRight = UDim.new(0, p); u.PaddingTop = UDim.new(0, p); u.PaddingBottom = UDim.new(0, p); return u end
local function gradient(i, c1, c2, rot) local g = Instance.new("UIGradient", i)
    g.Color = ColorSequence.new(c1, c2); g.Rotation = rot or 0; return g end

local gui = Instance.new("ScreenGui")
gui.Name = "ObsessionHubLoader"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999
gui.Parent = parentGui

-- root card
local root = Instance.new("Frame")
root.Name = "Root"
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.fromScale(0.5, 0.5)
root.Size = UDim2.fromOffset(410, 552)
root.BackgroundColor3 = T.bg
root.BorderSizePixel = 0
root.Parent = gui
corner(root, 18)
root.ClipsDescendants = true
strokeOf(root, T.stroke, 1)

-- ===== dark-red outer glow (wraps the card on both sides and underneath) =====
local outerGlow = Instance.new("ImageLabel")
outerGlow.Name = "OuterGlow"
outerGlow.AnchorPoint = Vector2.new(0.5, 0.5)
outerGlow.BackgroundTransparency = 1
outerGlow.Image = "rbxassetid://1316045217"             -- soft 9-slice glow
outerGlow.ScaleType = Enum.ScaleType.Slice
outerGlow.SliceCenter = Rect.new(10, 10, 118, 118)
outerGlow.ImageColor3 = Color3.fromRGB(150, 12, 26)     -- dark red
outerGlow.ImageTransparency = 0.45
outerGlow.ZIndex = 0                                    -- behind the card
outerGlow.Parent = gui
-- a second, tighter red layer for a richer glow
local outerGlow2 = outerGlow:Clone()
outerGlow2.ImageColor3 = Color3.fromRGB(224, 31, 58)
outerGlow2.ImageTransparency = 0.55
outerGlow2.Parent = gui

-- responsive: scale the whole loader down to fit small / mobile screens
local uiScale = Instance.new("UIScale", root)
uiScale.Scale = 1
local function fitScreen()
    local cam = workspace and workspace.CurrentCamera
    local vp = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
    -- leave a margin; never upscale past 1, never below 0.5
    local s = math.min(1, (vp.X - 28) / 410, (vp.Y - 48) / 552)
    uiScale.Scale = math.clamp(s, 0.5, 1)
end
pcall(fitScreen)
pcall(function()
    if workspace then
        workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(fitScreen)
        if workspace.CurrentCamera then
            workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScreen)
        end
    end
end)

-- animated glow border (red -> violet -> blue, rotating)
local glow = Instance.new("UIStroke", root)
glow.Thickness = 2
local glowGrad = gradient(glow, T.red2, T.blue, 0)
glowGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, T.red2),
    ColorSequenceKeypoint.new(0.5, T.violet),
    ColorSequenceKeypoint.new(1, T.blue),
})

-- animated background sheen (shifting neon wash behind everything)
local sheen = Instance.new("Frame")
sheen.Name = "Sheen"
sheen.Size = UDim2.fromScale(1, 1)
sheen.BackgroundColor3 = Color3.fromRGB(40, 10, 20)
sheen.BorderSizePixel = 0
sheen.ZIndex = 0
sheen.Parent = root
corner(sheen, 18)
local sheenGrad = Instance.new("UIGradient", sheen)
sheenGrad.Rotation = 35
sheenGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 12, 26)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 8, 24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 14, 40)),
})
sheenGrad.Transparency = NumberSequence.new(0.35)

-- floating ember particles
local emberHolder = Instance.new("Frame")
emberHolder.Name = "Embers"
emberHolder.BackgroundTransparency = 1
emberHolder.Size = UDim2.fromScale(1, 1)
emberHolder.ZIndex = 1
emberHolder.Parent = root
task.spawn(function()
    while emberHolder.Parent do
        for _ = 1, 2 do
            local e = Instance.new("Frame")
            local sz = math.random(2, 5)
            e.Size = UDim2.fromOffset(sz, sz)
            e.Position = UDim2.new(math.random(), 0, 1, 10)
            e.BackgroundColor3 = (math.random() < 0.25) and T.cyan or T.red2
            e.BorderSizePixel = 0
            e.ZIndex = 1
            e.BackgroundTransparency = 0.2
            e.Parent = emberHolder
            corner(e, 99)
            local dur = math.random(25, 55) / 10
            TweenService:Create(e, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
                Position = UDim2.new(e.Position.X.Scale + (math.random(-8, 8) / 100), 0, -0.1, 0),
                BackgroundTransparency = 1,
            }):Play()
            game:GetService("Debris"):AddItem(e, dur + 0.2)
        end
        task.wait(0.35)
    end
end)

-- top accent bar
local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, 0, 0, 3)
accent.Position = UDim2.fromOffset(0, 0)
accent.BorderSizePixel = 0
accent.BackgroundColor3 = T.red2
accent.Parent = root
gradient(accent, T.red2, T.violet, 0)

-- ===== header =====
local header = Instance.new("Frame")
header.BackgroundTransparency = 1
header.Size = UDim2.new(1, 0, 0, 64)
header.Position = UDim2.fromOffset(0, 6)
header.Parent = root

-- player avatar (with glowing ring)
local avatarRing = Instance.new("Frame")
avatarRing.Position = UDim2.fromOffset(18, 12)
avatarRing.Size = UDim2.fromOffset(42, 42)
avatarRing.BackgroundColor3 = T.panel
avatarRing.BorderSizePixel = 0
avatarRing.Parent = header
corner(avatarRing, 99)
local avatarStroke = strokeOf(avatarRing, T.red2, 1.5)
local avatar = Instance.new("ImageLabel")
avatar.AnchorPoint = Vector2.new(0.5, 0.5)
avatar.Position = UDim2.fromScale(0.5, 0.5)
avatar.Size = UDim2.fromOffset(38, 38)
avatar.BackgroundTransparency = 1
avatar.Parent = avatarRing
corner(avatar, 99)
pcall(function()
    local uid = LocalPlayer and LocalPlayer.UserId or 1
    local img = Players:GetUserThumbnailAsync(uid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    avatar.Image = img
end)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(70, 13)
title.Size = UDim2.new(1, -120, 0, 22)
title.Font = Enum.Font.GothamBlack
title.Text = "OBSESSION HUB"
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = T.text
title.Parent = header
local titleGradAnim = gradient(title, T.red2, Color3.fromRGB(255, 255, 255), 0)

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(70, 36)
subtitle.Size = UDim2.new(1, -120, 0, 14)
subtitle.Font = Enum.Font.GothamMedium
subtitle.Text = "Welcome, " .. ((LocalPlayer and LocalPlayer.DisplayName) or "player")
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextColor3 = T.muted
subtitle.Parent = header

-- close button (drawn X, no unicode glyph)
local closeBtn = Instance.new("TextButton")
closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.Position = UDim2.new(1, -16, 0, 16)
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.BackgroundColor3 = T.panel
closeBtn.Text = ""
closeBtn.AutoButtonColor = true
closeBtn.Parent = header
corner(closeBtn, 9)
strokeOf(closeBtn, T.stroke, 1)
for i = 1, 2 do
    local bar = Instance.new("Frame")
    bar.AnchorPoint = Vector2.new(0.5, 0.5)
    bar.Position = UDim2.fromScale(0.5, 0.5)
    bar.Size = UDim2.fromOffset(13, 2)
    bar.BackgroundColor3 = T.muted
    bar.BorderSizePixel = 0
    bar.Rotation = (i == 1) and 45 or -45
    bar.Parent = closeBtn
    corner(bar, 1)
end
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- ===== body =====
local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Position = UDim2.fromOffset(0, 72)
body.Size = UDim2.new(1, 0, 1, -72)
body.Parent = root
padAll(body, 18)
local layout = Instance.new("UIListLayout", body)
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- optional banner (your own image)
if Config.BannerImage and Config.BannerImage ~= "" then
    local banner = Instance.new("Frame")
    banner.LayoutOrder = 0
    banner.Size = UDim2.new(1, 0, 0, 96)
    banner.BackgroundColor3 = T.panel
    banner.ClipsDescendants = true
    banner.Parent = body
    corner(banner, 12); strokeOf(banner, T.red, 1)
    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.Size = UDim2.fromScale(1, 1)
    img.Image = Config.BannerImage
    img.ScaleType = Enum.ScaleType.Crop
    img.Parent = banner
    local shade = Instance.new("Frame")
    shade.BackgroundColor3 = Color3.fromRGB(10, 5, 8)
    shade.BackgroundTransparency = 0.3
    shade.Size = UDim2.new(1, 0, 0.5, 0)
    shade.Position = UDim2.fromScale(0, 0.5)
    shade.BorderSizePixel = 0
    shade.Parent = banner
    local sg = Instance.new("UIGradient", shade)
    sg.Rotation = 90
    sg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.3) })
end

local function sectionLabel(txt, order)
    local l = Instance.new("TextLabel")
    l.LayoutOrder = order
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, 0, 0, 14)
    l.Font = Enum.Font.GothamBold
    l.Text = txt
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = T.muted
    l.Parent = body
    return l
end

-- status chip (key state)
local chip = Instance.new("Frame")
chip.LayoutOrder = 1
chip.BackgroundColor3 = T.panel
chip.Size = UDim2.new(1, 0, 0, 36)
chip.Parent = body
corner(chip, 9)
local chipStroke = strokeOf(chip, T.stroke, 1)
local chipDot = Instance.new("Frame")
chipDot.AnchorPoint = Vector2.new(0, 0.5)
chipDot.Position = UDim2.new(0, 14, 0.5, 0)
chipDot.Size = UDim2.fromOffset(9, 9)
chipDot.BackgroundColor3 = T.muted
chipDot.BorderSizePixel = 0
chipDot.Parent = chip
corner(chipDot, 99)
local chipText = Instance.new("TextLabel")
chipText.BackgroundTransparency = 1
chipText.Position = UDim2.new(0, 32, 0, 0)
chipText.Size = UDim2.new(1, -40, 1, 0)
chipText.Font = Enum.Font.GothamMedium
chipText.Text = "No key yet"
chipText.TextSize = 13
chipText.TextXAlignment = Enum.TextXAlignment.Left
chipText.TextColor3 = T.text
chipText.Parent = chip
local function setChip(txt, col)
    chipText.Text = txt
    chipDot.BackgroundColor3 = col
    chipStroke.Color = col
end

-- ===== auto-detect the game =====
sectionLabel("DETECTED GAME", 2)

local keyBox -- fwd decl
local loadBtn, loadLabel
local function refreshUI() end -- fwd

-- try to get the game's name + icon (best effort)
local gameName = "Game " .. tostring(game.PlaceId)
local gameIcon
pcall(function()
    local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    if info then
        if info.Name then gameName = info.Name end
        if info.IconImageAssetId and info.IconImageAssetId ~= 0 then
            gameIcon = "rbxassetid://" .. tostring(info.IconImageAssetId)
        end
    end
end)
local detected, isUniversal = detectScript()
selected = detected

-- detected-game card
local card = Instance.new("Frame")
card.LayoutOrder = 3
card.Size = UDim2.new(1, 0, 0, 72)
card.BackgroundColor3 = T.panel
card.Parent = body
corner(card, 12)
local cardStroke = strokeOf(card, detected and T.red or T.stroke, detected and 1.6 or 1)

-- game icon thumbnail
local iconHolder = Instance.new("Frame")
iconHolder.Position = UDim2.fromOffset(12, 12)
iconHolder.Size = UDim2.fromOffset(48, 48)
iconHolder.BackgroundColor3 = T.bg
iconHolder.BorderSizePixel = 0
iconHolder.ClipsDescendants = true
iconHolder.Parent = card
corner(iconHolder, 10)
strokeOf(iconHolder, T.stroke, 1)
local iconImg = Instance.new("ImageLabel")
iconImg.BackgroundTransparency = 1
iconImg.Size = UDim2.fromScale(1, 1)
iconImg.ScaleType = Enum.ScaleType.Crop
iconImg.Image = gameIcon or "rbxasset://textures/ui/GuiImagePlaceholder.png"
iconImg.Parent = iconHolder

local textX = 72
local gameLbl = Instance.new("TextLabel")
gameLbl.BackgroundTransparency = 1
gameLbl.Position = UDim2.fromOffset(textX, 15)
gameLbl.Size = UDim2.new(1, -textX - 34, 0, 20)
gameLbl.Font = Enum.Font.GothamBold
gameLbl.Text = gameName
gameLbl.TextSize = 15
gameLbl.TextTruncate = Enum.TextTruncate.AtEnd
gameLbl.TextXAlignment = Enum.TextXAlignment.Left
gameLbl.TextColor3 = T.text
gameLbl.Parent = card

local scriptLbl = Instance.new("TextLabel")
scriptLbl.BackgroundTransparency = 1
scriptLbl.Position = UDim2.fromOffset(textX, 38)
scriptLbl.Size = UDim2.new(1, -textX - 34, 0, 18)
scriptLbl.Font = Enum.Font.GothamMedium
scriptLbl.TextSize = 12
scriptLbl.TextTruncate = Enum.TextTruncate.AtEnd
scriptLbl.TextXAlignment = Enum.TextXAlignment.Left
scriptLbl.Parent = card
if detected then
    scriptLbl.Text = (isUniversal and "Universal → " or "") .. detected.name
    scriptLbl.TextColor3 = T.good
else
    scriptLbl.Text = "No script for this game"
    scriptLbl.TextColor3 = T.bad
end

-- little status dot on the card
local cdot = Instance.new("Frame")
cdot.AnchorPoint = Vector2.new(1, 0.5)
cdot.Position = UDim2.new(1, -16, 0, 24)
cdot.Size = UDim2.fromOffset(10, 10)
cdot.BackgroundColor3 = detected and T.good or T.bad
cdot.BorderSizePixel = 0
cdot.Parent = card
corner(cdot, 99)

-- ===== key input (shown only when needed) =====
local keyHolder = Instance.new("Frame")
keyHolder.LayoutOrder = 4
keyHolder.BackgroundColor3 = T.panel
keyHolder.Size = UDim2.new(1, 0, 0, 44)
keyHolder.Parent = body
corner(keyHolder, 10)
local keyStroke = strokeOf(keyHolder, T.stroke, 1)
keyBox = Instance.new("TextBox")
keyBox.BackgroundTransparency = 1
keyBox.Size = UDim2.fromScale(1, 1)
keyBox.Font = Enum.Font.Code
keyBox.PlaceholderText = "OBSESSION-XXXX-XXXX-XXXX"
keyBox.PlaceholderColor3 = Color3.fromRGB(120, 95, 102)
keyBox.Text = currentKey or ""
keyBox.TextColor3 = Color3.fromRGB(255, 214, 219)
keyBox.TextSize = 14
keyBox.ClearTextOnFocus = false
keyBox.Parent = keyHolder
padAll(keyBox, 14)
keyBox.Focused:Connect(function() keyStroke.Color = T.red2 end)
keyBox.FocusLost:Connect(function() keyStroke.Color = T.stroke end)

-- ===== prominent buttons: Buy Premium + Join Discord =====
local prow = Instance.new("Frame")
prow.LayoutOrder = 5
prow.BackgroundTransparency = 1
prow.Size = UDim2.new(1, 0, 0, 42)
prow.Parent = body
local prowLayout = Instance.new("UIListLayout", prow)
prowLayout.FillDirection = Enum.FillDirection.Horizontal
prowLayout.Padding = UDim.new(0, 8)

local big = {}
if Config.Premium and Config.Premium ~= "" then
    big[#big + 1] = { "BUY PREMIUM", Color3.fromRGB(255, 196, 70), Color3.fromRGB(230, 140, 20), Color3.fromRGB(40, 24, 0), function()
        setClip(Config.Premium); notify("ObsessionHub", "Premium link copied to clipboard", 5)
    end }
end
if Config.Discord and Config.Discord ~= "" then
    big[#big + 1] = { "JOIN DISCORD", Color3.fromRGB(100, 112, 255), Color3.fromRGB(60, 70, 200), Color3.fromRGB(255, 255, 255), function()
        setClip(Config.Discord); notify("ObsessionHub", "Discord link copied", 4)
    end }
end
do
    local n = math.max(1, #big)
    for _, b in ipairs(big) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1 / n, -(8 * (n - 1) / n), 1, 0)
        btn.BackgroundColor3 = b[2]
        btn.Text = b[1]
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 13
        btn.TextColor3 = b[4]
        btn.AutoButtonColor = true
        btn.Parent = prow
        corner(btn, 10)
        gradient(btn, b[2], b[3], 20)
        local gl = Instance.new("UIStroke", btn)
        gl.Color = b[2]; gl.Thickness = 1; gl.Transparency = 0.3
        btn.MouseButton1Click:Connect(b[5])
    end
end

-- ===== big GET KEY button =====
local getKeyBtn = Instance.new("TextButton")
getKeyBtn.LayoutOrder = 6
getKeyBtn.Size = UDim2.new(1, 0, 0, 42)
getKeyBtn.BackgroundColor3 = T.red
getKeyBtn.Text = ""   -- text lives in a child label so the gradient doesn't darken it
getKeyBtn.AutoButtonColor = true
getKeyBtn.ClipsDescendants = true
getKeyBtn.Parent = body
corner(getKeyBtn, 10)
gradient(getKeyBtn, T.red2, Color3.fromRGB(139, 10, 26), 20)
do
    local gkGlow = Instance.new("UIStroke", getKeyBtn)
    gkGlow.Color = T.red2; gkGlow.Thickness = 1; gkGlow.Transparency = 0.3
end
-- GET KEY label (separate object = stays pure white, always readable)
local getKeyLabel = Instance.new("TextLabel")
getKeyLabel.BackgroundTransparency = 1
getKeyLabel.Size = UDim2.fromScale(1, 1)
getKeyLabel.Font = Enum.Font.GothamBlack
getKeyLabel.Text = "GET KEY"
getKeyLabel.TextSize = 13
getKeyLabel.ZIndex = 3
getKeyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
getKeyLabel.Parent = getKeyBtn
-- sweeping shine across the GET KEY button
do
    local gkShine = Instance.new("Frame")
    gkShine.Size = UDim2.new(0, 36, 2, 0)
    gkShine.Position = UDim2.fromScale(-0.3, -0.5)
    gkShine.Rotation = 18
    gkShine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    gkShine.BackgroundTransparency = 0.65
    gkShine.BorderSizePixel = 0
    gkShine.ZIndex = 2
    gkShine.Parent = getKeyBtn
    task.spawn(function()
        while getKeyBtn.Parent do
            gkShine.Position = UDim2.fromScale(-0.3, -0.5)
            TweenService:Create(gkShine, TweenInfo.new(0.9, Enum.EasingStyle.Sine), { Position = UDim2.fromScale(1.3, -0.5) }):Play()
            task.wait(3.1)
        end
    end)
end
getKeyBtn.MouseButton1Click:Connect(function()
    setClip(Config.GetKeyURL); notify("ObsessionHub", "Get-key link copied to clipboard", 5)
end)

-- ===== status + load button =====
local status = Instance.new("TextLabel")
status.LayoutOrder = 7
status.BackgroundTransparency = 1
status.Size = UDim2.new(1, 0, 0, 16)
status.Font = Enum.Font.GothamMedium
status.Text = ""
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextColor3 = T.muted
status.Parent = body
local function setStatus(t, c) status.Text = t; status.TextColor3 = c or T.muted end

loadBtn = Instance.new("TextButton")
loadBtn.LayoutOrder = 8
loadBtn.Size = UDim2.new(1, 0, 0, 48)
loadBtn.BackgroundColor3 = T.red
loadBtn.Text = ""
loadBtn.AutoButtonColor = true
loadBtn.ClipsDescendants = true
loadBtn.Parent = body
corner(loadBtn, 12)
gradient(loadBtn, T.red2, Color3.fromRGB(139, 10, 26), 25)
loadLabel = Instance.new("TextLabel")
loadLabel.BackgroundTransparency = 1
loadLabel.Size = UDim2.fromScale(1, 1)
loadLabel.Font = Enum.Font.GothamBlack
loadLabel.Text = "LOAD"
loadLabel.TextSize = 15
loadLabel.ZIndex = 3
loadLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
loadLabel.Parent = loadBtn
-- sweeping shine across the load button
local shine = Instance.new("Frame")
shine.Size = UDim2.new(0, 40, 2, 0)
shine.Position = UDim2.fromScale(-0.3, -0.5)
shine.Rotation = 18
shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
shine.BackgroundTransparency = 0.6
shine.BorderSizePixel = 0
shine.ZIndex = 2
shine.Parent = loadBtn
task.spawn(function()
    while loadBtn.Parent do
        shine.Position = UDim2.fromScale(-0.3, -0.5)
        TweenService:Create(shine, TweenInfo.new(0.9, Enum.EasingStyle.Sine), { Position = UDim2.fromScale(1.3, -0.5) }):Play()
        task.wait(2.6)
    end
end)

-- footer
local footer = Instance.new("TextLabel")
footer.LayoutOrder = 9
footer.BackgroundTransparency = 1
footer.Size = UDim2.new(1, 0, 0, 14)
footer.Font = Enum.Font.Gotham
footer.Text = "ObsessionHub  •  v2.0"
footer.TextSize = 10
footer.TextColor3 = Color3.fromRGB(110, 90, 96)
footer.Parent = body

-- ===== UI refresh logic =====
local busy = false
local loaded = false

function refreshUI()
    local needsKey = selected and selected.requiresKey and not verified
    keyHolder.Visible = needsKey
    keyHolder.Size = needsKey and UDim2.new(1, 0, 0, 44) or UDim2.new(1, 0, 0, 0)
    if not selected then
        loadLabel.Text = "GAME NOT SUPPORTED"
    elseif needsKey then
        loadLabel.Text = "VERIFY & LOAD"
    else
        loadLabel.Text = "LOAD " .. string.upper(selected.name)
    end
end

-- ===== actions =====
local function doLoad(entry)
    if loaded then return end
    loaded = true
    setStatus("Loading " .. entry.name .. "...", T.muted)
    local ok = loadScript(entry)
    if ok then
        setStatus("Loaded " .. entry.name, T.good)
        notify("ObsessionHub", entry.name .. " loaded", 4)
        if entry.requiresKey then startKeyWatch(currentKey) end
        if Config.CloseAfterLoad then task.wait(0.6); gui:Destroy() end
    else
        loaded = false
        setStatus("Failed to load " .. entry.name, T.bad)
    end
end

-- Verify (if needed) then load the detected script
local function runLoad(fromAuto)
    if busy or loaded or not selected then return end

    -- free script, or key already verified -> load straight away
    if (not selected.requiresKey) or verified then
        busy = true
        doLoad(selected)
        busy = false
        return
    end

    -- needs a key and not verified. If auto-triggered, just wait for the user to type it.
    if fromAuto then return end

    local key = keyBox.Text
    busy = true
    loadLabel.Text = "CHECKING..."
    setStatus("Verifying key...", T.muted)
    task.spawn(function()
        local ok, reason = verifyKey(key)
        if not ok then
            setStatus(reason, T.bad)
            setChip("Key invalid", T.bad)
            notify("ObsessionHub", reason, 5)
            refreshUI()
            busy = false
            return
        end
        currentKey = tostring(key):gsub("%s+", ""):upper()
        saveKey(currentKey)
        verified = true
        if getgenv then getgenv().ObsessionVerified = true end
        setChip("Key verified", T.good)
        setStatus("Key verified", T.good)
        busy = false
        doLoad(selected)   -- auto-load right after verifying
    end)
end

-- Auto-load as soon as we can (free game, or key already good)
local function tryAutoLoad()
    if not selected then return end
    if selected.requiresKey and not verified then return end
    runLoad(true)
end

local function markVerified()
    verified = true
    if getgenv then getgenv().ObsessionVerified = true end
    setChip("Key verified", T.good)
    refreshUI()
    tryAutoLoad()
end

loadBtn.MouseButton1Click:Connect(function() runLoad(false) end)

-- ===== drag =====
do
    local dragging, startPos, startInput
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; startInput = i.Position; startPos = root.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInput.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startInput
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ===== entrance + glow loop =====
root.Size = UDim2.fromOffset(400, 0)
TweenService:Create(root, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    { Size = UDim2.fromOffset(410, 552) }):Play()

-- keep the dark-red outer glow glued around the card (follows drag + scale), a touch lower for "under"
local function syncGlow()
    local sc = uiScale.Scale
    local w, h = root.AbsoluteSize.X, root.AbsoluteSize.Y
    if w < 10 then w, h = 410 * sc, 552 * sc end
    outerGlow.Size = UDim2.fromOffset(w + 30 * sc, h + 34 * sc)
    outerGlow.Position = root.Position + UDim2.fromOffset(0, 4 * sc)
    outerGlow2.Size = UDim2.fromOffset(w + 16 * sc, h + 18 * sc)
    outerGlow2.Position = root.Position + UDim2.fromOffset(0, 2 * sc)
end
pcall(syncGlow)

-- rotating glow border + shifting background sheen + glow pulse
local glowT = 0
task.spawn(function()
    while gui.Parent do
        glowGrad.Rotation = (glowGrad.Rotation + 2) % 360
        sheenGrad.Rotation = (sheenGrad.Rotation + 0.4) % 360
        glowT = glowT + 0.03
        local pulse = (math.sin(glowT * 1.6) + 1) / 2          -- 0..1 breathing
        outerGlow.ImageTransparency = 0.42 + pulse * 0.12
        outerGlow2.ImageTransparency = 0.5 + pulse * 0.14
        syncGlow()
        task.wait(0.03)
    end
end)

-- ===== glossy shine sweeping across the whole card =====
local cardShine = Instance.new("Frame")
cardShine.Name = "CardShine"
cardShine.Size = UDim2.new(0, 80, 2, 0)
cardShine.Position = UDim2.fromScale(-0.4, -0.5)
cardShine.Rotation = 18
cardShine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
cardShine.BackgroundTransparency = 0.88
cardShine.BorderSizePixel = 0
cardShine.ZIndex = 60
cardShine.Parent = root
do
    local sg = Instance.new("UIGradient", cardShine)
    sg.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    sg.Rotation = 90
end
task.spawn(function()
    while root.Parent do
        cardShine.Position = UDim2.fromScale(-0.4, -0.5)
        TweenService:Create(cardShine, TweenInfo.new(1.3, Enum.EasingStyle.Sine), { Position = UDim2.fromScale(1.4, -0.5) }):Play()
        task.wait(4.2)
    end
end)

-- neon glow pulse on the title
local titleGlow = Instance.new("UIStroke", title)
titleGlow.Color = T.red2
titleGlow.Thickness = 0
titleGlow.Transparency = 0.2
task.spawn(function()
    while gui.Parent do
        TweenService:Create(titleGlow, TweenInfo.new(1.4, Enum.EasingStyle.Sine), { Thickness = 1.4 }):Play()
        task.wait(1.4)
        TweenService:Create(titleGlow, TweenInfo.new(1.4, Enum.EasingStyle.Sine), { Thickness = 0 }):Play()
        task.wait(1.4)
    end
end)

-- pulsing glow around the LOAD button
local loadGlow = Instance.new("UIStroke", loadBtn)
loadGlow.Color = T.red2
loadGlow.Thickness = 1
loadGlow.Transparency = 0.4
task.spawn(function()
    while gui.Parent do
        TweenService:Create(loadGlow, TweenInfo.new(1.1, Enum.EasingStyle.Sine), { Transparency = 0, Thickness = 2.4 }):Play()
        task.wait(1.1)
        TweenService:Create(loadGlow, TweenInfo.new(1.1, Enum.EasingStyle.Sine), { Transparency = 0.5, Thickness = 1 }):Play()
        task.wait(1.1)
    end
end)

-- Enter key in the key box = verify & load
keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then runLoad(false) end
end)

-- ===== startup: detect game, auto-verify saved key, auto-load =====
refreshUI()
if not selected then
    setChip("Game not supported", T.bad)
    setStatus("No script for this game", T.bad)
elseif not selected.requiresKey then
    setChip("Free script", T.good)
    tryAutoLoad()                       -- free game: load immediately
elseif verified then
    setChip("Key verified", T.good)
    tryAutoLoad()                       -- already verified: load immediately
elseif currentKey and currentKey ~= "" then
    setChip("Checking saved key...", T.muted)
    task.spawn(function()
        local ok = verifyKey(currentKey)
        if ok then
            setStatus("Saved key verified", T.good)
            markVerified()              -- verified -> auto-loads
        else
            setChip("Enter your key", T.muted)
        end
    end)
else
    setChip("Enter your key", T.muted)  -- needs a key: wait for the user
end

notify("ObsessionHub", "Loader ready", 3)
