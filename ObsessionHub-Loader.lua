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
    Website   = "https://keysystem-orcin-sigma.vercel.app/",      -- your key site (NO trailing slash)
    GetKeyURL = "https://keysystem-orcin-sigma.vercel.app/getkey", -- where users get a key
    Discord   = "https://discord.gg/Qy8W4JHQ4n",      -- "" to hide the button
    Youtube   = "https://www.youtube.com/@jirombv",    -- "" to hide the button

    RememberKey = true,   -- save the key on this device so users don't retype it
    CloseAfterLoad = true, -- close the window after a script loads

    -- Your scripts. Add as many as you want.
    --   name        = what shows in the list
    --   url         = GitHub raw link to the .lua script
    --   requiresKey = true -> needs a valid key, false -> free/no key
    Scripts = {
        { name = "Blox Fruits",  url = "https://raw.githubusercontent.com/YOU/REPO/main/bloxfruits.lua", requiresKey = true },
        { name = "Blade Ball",   url = "https://raw.githubusercontent.com/YOU/REPO/main/bladeball.lua",  requiresKey = true },
        { name = "Universal Hub", url = "https://raw.githubusercontent.com/YOU/REPO/main/universal.lua", requiresKey = true },
        { name = "Free Script",  url = "https://raw.githubusercontent.com/YOU/REPO/main/free.lua",       requiresKey = false },
    },
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

-- Fetch + run a script
local function loadScript(entry)
    local src
    local ok = pcall(function() src = game:HttpGet(entry.url, true) end)
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

--// UI -----------------------------------------------------------------
-- remove an old copy if the user re-runs the loader
pcall(function()
    local holder = (gethui and gethui()) or CoreGui
    local old = holder:FindFirstChild("ObsessionHubLoader")
    if old then old:Destroy() end
end)

local parentGui = (gethui and gethui()) or CoreGui

local function corner(inst, r) local c = Instance.new("UICorner", inst); c.CornerRadius = UDim.new(0, r or 10); return c end
local function stroke(inst, col, th) local s = Instance.new("UIStroke", inst); s.Color = col or T.stroke; s.Thickness = th or 1; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; return s end
local function pad(inst, p) local u = Instance.new("UIPadding", inst); u.PaddingLeft=UDim.new(0,p); u.PaddingRight=UDim.new(0,p); u.PaddingTop=UDim.new(0,p); u.PaddingBottom=UDim.new(0,p); return u end

local WIN_H = 470

local gui = Instance.new("ScreenGui")
gui.Name = "ObsessionHubLoader"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = parentGui

local root = Instance.new("Frame")
root.Name = "Root"
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.fromScale(0.5, 0.5)
root.Size = UDim2.fromOffset(420, WIN_H)
root.BackgroundColor3 = T.bg
root.BorderSizePixel = 0
root.Parent = gui
corner(root, 16)
stroke(root, T.stroke, 1)

-- animated glow border
local glow = Instance.new("UIStroke", root)
glow.Thickness = 1.6
glow.Transparency = 0.1
local glowGrad = Instance.new("UIGradient", glow)
glowGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, T.red2),
    ColorSequenceKeypoint.new(0.5, T.violet),
    ColorSequenceKeypoint.new(1, T.red2),
})

-- faint red radial using a gradient background panel
local sheen = Instance.new("Frame")
sheen.BackgroundColor3 = T.red
sheen.BackgroundTransparency = 0.88
sheen.Size = UDim2.fromScale(1, 1)
sheen.BorderSizePixel = 0
sheen.Parent = root
corner(sheen, 16)
local sheenGrad = Instance.new("UIGradient", sheen)
sheenGrad.Rotation = 90
sheenGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.6),
    NumberSequenceKeypoint.new(1, 1),
})

--// Title bar (draggable)
local bar = Instance.new("Frame")
bar.Name = "Bar"
bar.BackgroundTransparency = 1
bar.Size = UDim2.new(1, 0, 0, 58)
bar.Parent = root

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(20, 12)
title.Size = UDim2.new(1, -80, 0, 26)
title.Font = Enum.Font.GothamBlack
title.Text = "OBSESSION HUB"
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = T.text
title.Parent = bar
local titleGrad = Instance.new("UIGradient", title)
titleGrad.Color = ColorSequence.new(T.red2, Color3.fromRGB(255,255,255))

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(20, 36)
subtitle.Size = UDim2.new(1, -80, 0, 14)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Key Loader"
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextColor3 = T.muted
subtitle.Parent = bar

local closeBtn = Instance.new("TextButton")
closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.Position = UDim2.new(1, -16, 0, 14)
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.BackgroundColor3 = T.panel
closeBtn.Text = "✕"
closeBtn.TextColor3 = T.muted
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.AutoButtonColor = true
closeBtn.Parent = bar
corner(closeBtn, 8)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- drag logic
do
    local dragging, startPos, startInput
    bar.InputBegan:Connect(function(i)
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

--// Body container
local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Position = UDim2.fromOffset(0, 58)
body.Size = UDim2.new(1, 0, 1, -58)
body.Parent = root
pad(body, 20)
local layout = Instance.new("UIListLayout", body)
layout.FillDirection = Enum.FillDirection.Vertical
layout.Padding = UDim.new(0, 12)
layout.SortOrder = Enum.SortOrder.LayoutOrder

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

--// Script picker
sectionLabel("SELECT SCRIPT", 1)

local pickerHolder = Instance.new("Frame")
pickerHolder.LayoutOrder = 2
pickerHolder.BackgroundColor3 = T.panel
pickerHolder.Size = UDim2.new(1, 0, 0, 44)
pickerHolder.Parent = body
corner(pickerHolder, 10); stroke(pickerHolder)

local pickerBtn = Instance.new("TextButton")
pickerBtn.BackgroundTransparency = 1
pickerBtn.Size = UDim2.fromScale(1, 1)
pickerBtn.Font = Enum.Font.GothamMedium
pickerBtn.TextSize = 14
pickerBtn.TextColor3 = T.text
pickerBtn.TextXAlignment = Enum.TextXAlignment.Left
pickerBtn.Parent = pickerHolder
pad(pickerBtn, 14)

local caret = Instance.new("TextLabel")
caret.AnchorPoint = Vector2.new(1, 0.5)
caret.Position = UDim2.new(1, -12, 0.5, 0)
caret.Size = UDim2.fromOffset(16, 16)
caret.BackgroundTransparency = 1
caret.Text = "▾"
caret.TextColor3 = T.red2
caret.Font = Enum.Font.GothamBold
caret.TextSize = 14
caret.Parent = pickerHolder

-- dropdown list
local dropdown = Instance.new("Frame")
dropdown.Visible = false
dropdown.BackgroundColor3 = T.panel
dropdown.Position = UDim2.new(0, 0, 0, 48)
dropdown.Size = UDim2.new(1, 0, 0, 0)
dropdown.ZIndex = 5
dropdown.Parent = pickerHolder
corner(dropdown, 10); stroke(dropdown, T.red)
local ddList = Instance.new("UIListLayout", dropdown)
ddList.Padding = UDim.new(0, 2)
pad(dropdown, 4)

local selected = Config.Scripts[1]
local function setSelected(entry)
    selected = entry
    pickerBtn.Text = entry.name .. (entry.requiresKey and "" or "   (free)")
end

for i, entry in ipairs(Config.Scripts) do
    local opt = Instance.new("TextButton")
    opt.Size = UDim2.new(1, 0, 0, 34)
    opt.BackgroundColor3 = T.bg
    opt.BackgroundTransparency = 0.3
    opt.Text = entry.name
    opt.Font = Enum.Font.GothamMedium
    opt.TextSize = 13
    opt.TextColor3 = T.text
    opt.ZIndex = 6
    opt.Parent = dropdown
    corner(opt, 8)
    opt.MouseButton1Click:Connect(function()
        setSelected(entry)
        dropdown.Visible = false
        dropdown.Size = UDim2.new(1, 0, 0, 0)
        caret.Text = "▾"
    end)
end

pickerBtn.MouseButton1Click:Connect(function()
    local open = not dropdown.Visible
    dropdown.Visible = open
    local h = open and (#Config.Scripts * 36 + 8) or 0
    dropdown.Size = UDim2.new(1, 0, 0, h)
    caret.Text = open and "▴" or "▾"
end)

--// Key box
sectionLabel("LICENSE KEY", 3)

local keyHolder = Instance.new("Frame")
keyHolder.LayoutOrder = 4
keyHolder.BackgroundColor3 = T.panel
keyHolder.Size = UDim2.new(1, 0, 0, 44)
keyHolder.Parent = body
corner(keyHolder, 10)
local keyStroke = stroke(keyHolder)

local keyBox = Instance.new("TextBox")
keyBox.BackgroundTransparency = 1
keyBox.Size = UDim2.fromScale(1, 1)
keyBox.Font = Enum.Font.Code
keyBox.PlaceholderText = "OBSESSION-XXXX-XXXX-XXXX"
keyBox.PlaceholderColor3 = Color3.fromRGB(120, 95, 102)
keyBox.Text = loadSavedKey()
keyBox.TextColor3 = Color3.fromRGB(255, 214, 219)
keyBox.TextSize = 15
keyBox.ClearTextOnFocus = false
keyBox.Parent = keyHolder
pad(keyBox, 14)
keyBox.Focused:Connect(function() keyStroke.Color = T.red2 end)
keyBox.FocusLost:Connect(function() keyStroke.Color = T.stroke end)

--// Buttons row (Get Key / Discord / YouTube)
local linkRow = Instance.new("Frame")
linkRow.LayoutOrder = 5
linkRow.BackgroundTransparency = 1
linkRow.Size = UDim2.new(1, 0, 0, 34)
linkRow.Parent = body
local linkLayout = Instance.new("UIListLayout", linkRow)
linkLayout.FillDirection = Enum.FillDirection.Horizontal
linkLayout.Padding = UDim.new(0, 8)
linkLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

local function smallBtn(txt, col, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 0, 1, 0)
    b.AutomaticSize = Enum.AutomaticSize.X
    b.BackgroundColor3 = col
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextColor3 = T.text
    b.Parent = linkRow
    corner(b, 8)
    local p = Instance.new("UIPadding", b)
    p.PaddingLeft = UDim.new(0, 14); p.PaddingRight = UDim.new(0, 14)
    b.MouseButton1Click:Connect(cb)
    return b
end

smallBtn("Get Key", T.red, function()
    setClip(Config.GetKeyURL)
    notify("ObsessionHub", "Get-key link copied — paste it in your browser", 5)
end)
if Config.Discord ~= "" then
    smallBtn("Discord", Color3.fromRGB(45, 24, 32), function()
        setClip(Config.Discord); notify("ObsessionHub", "Discord link copied", 4)
    end)
end
if Config.Youtube ~= "" then
    smallBtn("YouTube", Color3.fromRGB(45, 24, 32), function()
        setClip(Config.Youtube); notify("ObsessionHub", "YouTube link copied", 4)
    end)
end

--// Status
local status = Instance.new("TextLabel")
status.LayoutOrder = 6
status.BackgroundTransparency = 1
status.Size = UDim2.new(1, 0, 0, 18)
status.Font = Enum.Font.GothamMedium
status.Text = ""
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextColor3 = T.muted
status.Parent = body
local function setStatus(txt, col) status.Text = txt; status.TextColor3 = col or T.muted end

--// Main action button
local loadBtn = Instance.new("TextButton")
loadBtn.LayoutOrder = 7
loadBtn.Size = UDim2.new(1, 0, 0, 48)
loadBtn.BackgroundColor3 = T.red
loadBtn.Text = "VERIFY & LOAD"
loadBtn.Font = Enum.Font.GothamBlack
loadBtn.TextSize = 15
loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loadBtn.AutoButtonColor = true
loadBtn.Parent = body
corner(loadBtn, 12)
local loadGrad = Instance.new("UIGradient", loadBtn)
loadGrad.Color = ColorSequence.new(T.red2, Color3.fromRGB(139, 10, 26))
loadGrad.Rotation = 25

setSelected(selected)

local busy = false
loadBtn.MouseButton1Click:Connect(function()
    if busy then return end
    local entry = selected
    if not entry then return end

    if not entry.requiresKey then
        busy = true; setStatus("Loading " .. entry.name .. "...", T.muted); loadBtn.Text = "LOADING..."
        local ok = loadScript(entry)
        if ok then
            setStatus("Loaded " .. entry.name, T.good)
            notify("ObsessionHub", entry.name .. " loaded", 4)
            if Config.CloseAfterLoad then task.wait(0.6); gui:Destroy() end
        else
            setStatus("Failed to load", T.bad); loadBtn.Text = "VERIFY & LOAD"
        end
        busy = false
        return
    end

    local key = keyBox.Text
    busy = true; loadBtn.Text = "CHECKING..."; setStatus("Verifying key...", T.muted)
    task.spawn(function()
        local ok, reason = verifyKey(key)
        if not ok then
            setStatus(reason, T.bad)
            loadBtn.Text = "VERIFY & LOAD"
            notify("ObsessionHub", reason, 5)
            busy = false
            return
        end
        saveKey(tostring(key):gsub("%s+", ""):upper())
        setStatus("Key valid — loading " .. entry.name .. "...", T.good)
        loadBtn.Text = "LOADING..."
        local loaded = loadScript(entry)
        if loaded then
            setStatus("Loaded " .. entry.name, T.good)
            notify("ObsessionHub", entry.name .. " loaded", 4)
            if Config.CloseAfterLoad then task.wait(0.6); gui:Destroy() end
        else
            setStatus("Download failed", T.bad); loadBtn.Text = "VERIFY & LOAD"
        end
        busy = false
    end)
end)

--// entrance animation + glow loop
root.Size = UDim2.fromOffset(420, 0)
TweenService:Create(root, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    { Size = UDim2.fromOffset(420, WIN_H) }):Play()

task.spawn(function()
    while gui.Parent do
        glowGrad.Rotation = (glowGrad.Rotation + 2) % 360
        task.wait(0.03)
    end
end)

-- optional: prefill key from getgenv().ObsessionKey if the user set one
if getgenv and getgenv().ObsessionKey then
    keyBox.Text = tostring(getgenv().ObsessionKey)
end

notify("ObsessionHub", "Loader ready", 3)
