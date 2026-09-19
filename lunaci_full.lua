-- [[ LUNACI PREMIUM V26.6 | LIQUID GLASS + NIGHT SKY + CHAMS + SFX + KEYBINDS + NOTIFICATIONS + AVATAR ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local lplr = Players.LocalPlayer
local camera = workspace.CurrentCamera
if not (lplr and camera) then return end

-- ============================================================
-- STATE
-- ============================================================
local UNLOADED = false
local IsLoggedIn = false
local MenuOpen = false
local holdKey = false
local capturingKey = nil

-- ============================================================
-- KEY SYSTEM (INTEGRATED) - TG BOT + SUBSCRIPTION
-- ============================================================
local KEY_API_URL = "http://127.0.0.1:5000/validate" -- ПОМЕНЯЙ на свой! Пример: https://lunaci.yourdomain.com/validate
local KEY_FILE = "LunaciPremium_Key.txt"
local TELEGRAM_BOT_LINK = "https://t.me/lunacicheatbot"

local function ReadSavedKey()
    if isfile and isfile(KEY_FILE) then
        local ok, d = pcall(readfile, KEY_FILE)
        if ok and d and d:gsub("%s+", "") ~= "" then return d:gsub("%s+", "") end
    end
    return nil
end
local function SaveKey(k) if writefile then pcall(writefile, KEY_FILE, k) end end

local function ValidateOnline(key)
    if not key or key == "" then return false, "EMPTY" end
    if not key:match("^LUNACI%-") then return false, "FORMAT" end
    local success, result = pcall(function()
        local req = http_request or request or (syn and syn.request)
        local url = KEY_API_URL .. "?key=" .. HttpService:UrlEncode(key)
        local resp
        if req then
            resp = req({Url = url, Method = "GET"})
        else
            resp = HttpService:RequestAsync({Url = url, Method = "GET"})
        end
        local body = resp.Body or resp.body or resp
        if type(body) == "string" then
            return HttpService:JSONDecode(body)
        elseif type(resp) == "string" then
            return HttpService:JSONDecode(resp)
        else
            return body
        end
    end)
    if success and type(result) == "table" then
        if result.valid == true then return true, result else return false, result.reason or "INVALID" end
    else
        warn("[LUNACI KEY] Online validate failed: "..tostring(result))
        if key:match("^LUNACI%-[A-Z0-9]+%-[A-Z0-9]+%-[A-Z0-9]+$") then
            return true, {days_left="?", label="offline"}
        end
        return false, "SERVER_ERROR"
    end
end

local function CreateKeyGUI(onSuccess)
    local CoreGui = game:GetService("CoreGui")
    pcall(function() if CoreGui:FindFirstChild("LunaciKeySystem") then CoreGui.LunaciKeySystem:Destroy() end end)
    if CoreGui:FindFirstChild("LunaciPremium") then
        local old = CoreGui:FindFirstChild("LunaciPremium")
        if old then old.Enabled = false end
    end
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "LunaciKeySystem"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 1000
    local Bg = Instance.new("Frame", ScreenGui)
    Bg.Size = UDim2.new(1,0,1,0)
    Bg.BackgroundColor3 = Color3.fromRGB(12,12,12)
    Bg.BackgroundTransparency = 0.15
    local Card = Instance.new("Frame", Bg)
    Card.Size = UDim2.new(0, 420, 0, 295)
    Card.Position = UDim2.new(0.5, -210, 0.5, -147)
    Card.BackgroundColor3 = Color3.fromRGB(22,22,22)
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", Card)
    stroke.Color = Color3.fromRGB(155,85,255); stroke.Thickness = 1.5; stroke.Transparency = 0.3
    local Title = Instance.new("TextLabel", Card)
    Title.Size = UDim2.new(1, -40, 0, 30); Title.Position = UDim2.new(0,20,0,18)
    Title.BackgroundTransparency = 1; Title.Text = "LUNACI PREMIUM"
    Title.Font = Enum.Font.GothamBold; Title.TextSize = 20; Title.TextColor3 = Color3.fromRGB(235,235,235)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    local Sub = Instance.new("TextLabel", Card)
    Sub.Size = UDim2.new(1, -40, 0, 32); Sub.Position = UDim2.new(0,20,0,44)
    Sub.BackgroundTransparency = 1; Sub.Text = "Введи ключ - подпишись на канал чтобы получить на 1 день"
    Sub.Font = Enum.Font.Gotham; Sub.TextSize = 11; Sub.TextColor3 = Color3.fromRGB(130,130,130)
    Sub.TextXAlignment = Enum.TextXAlignment.Left; Sub.TextWrapped = true
    local Box = Instance.new("TextBox", Card)
    Box.Size = UDim2.new(1, -40, 0, 42); Box.Position = UDim2.new(0,20,0,82)
    Box.BackgroundColor3 = Color3.fromRGB(32,32,32); Box.PlaceholderText = "LUNACI-XXXX-XXXX-XXXX"
    Box.Text = ""; Box.Font = Enum.Font.Gotham; Box.TextSize = 14; Box.TextColor3 = Color3.new(1,1,1)
    Box.ClearTextOnFocus = false
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
    Instance.new("UIPadding", Box).PaddingLeft = UDim.new(0,12)
    local saved = ReadSavedKey()
    if saved then Box.Text = saved end
    local Status = Instance.new("TextLabel", Card)
    Status.Size = UDim2.new(1, -40, 0, 18); Status.Position = UDim2.new(0,20,0,130)
    Status.BackgroundTransparency = 1; Status.Text = saved and "Найден сохраненный ключ - нажми Войти" or ""
    Status.Font = Enum.Font.Gotham; Status.TextSize = 12; Status.TextColor3 = Color3.fromRGB(255,175,40)
    Status.TextXAlignment = Enum.TextXAlignment.Left
    local Btn = Instance.new("TextButton", Card)
    Btn.Size = UDim2.new(1, -40, 0, 40); Btn.Position = UDim2.new(0,20,0,155)
    Btn.BackgroundColor3 = Color3.fromRGB(155,85,255); Btn.Text = "ВОЙТИ"
    Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 14; Btn.TextColor3 = Color3.new(1,1,1)
    Btn.AutoButtonColor = false
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    local GetBtn = Instance.new("TextButton", Card)
    GetBtn.Size = UDim2.new(1, -40, 0, 32); GetBtn.Position = UDim2.new(0,20,0,205)
    GetBtn.BackgroundColor3 = Color3.fromRGB(35,35,35); GetBtn.Text = "Получить ключ в ТГ боте (1 день бесплатно)"
    GetBtn.Font = Enum.Font.Gotham; GetBtn.TextSize = 12; GetBtn.TextColor3 = Color3.fromRGB(200,200,200)
    Instance.new("UICorner", GetBtn).CornerRadius = UDim.new(0, 8)
    local Info = Instance.new("TextLabel", Card)
    Info.Size = UDim2.new(1, -40, 0, 30); Info.Position = UDim2.new(0,20,0,245)
    Info.BackgroundTransparency = 1; Info.Text = "Ключи от админа: навсегда | 1 год | 1 мес | 2 нед | 1 нед | 10 дн"
    Info.Font = Enum.Font.Gotham; Info.TextSize = 10; Info.TextColor3 = Color3.fromRGB(90,90,90)
    Info.TextXAlignment = Enum.TextXAlignment.Center; Info.TextWrapped = true
    GetBtn.MouseButton1Click:Connect(function()
        if setclipboard then pcall(setclipboard, TELEGRAM_BOT_LINK) end
        Status.Text = "Ссылка скопирована: "..TELEGRAM_BOT_LINK
        Status.TextColor3 = Color3.fromRGB(60,210,120)
        pcall(function() if syn and syn.open_url then syn.open_url(TELEGRAM_BOT_LINK) end end)
    end)
    local function doLogin()
        local key = Box.Text:gsub("%s+", "")
        if key == "" then Status.Text = "Введи ключ"; Status.TextColor3 = Color3.fromRGB(255,70,80); return end
        Btn.Text = "ПРОВЕРКА..."; Btn.BackgroundColor3 = Color3.fromRGB(100,100,100)
        local ok, info = ValidateOnline(key)
        if ok then
            SaveKey(key)
            Status.Text = "Ключ принят! Загрузка..."; Status.TextColor3 = Color3.fromRGB(60,210,120)
            IsLoggedIn = true
            task.wait(0.4)
            ScreenGui:Destroy()
            if CoreGui:FindFirstChild("LunaciPremium") then CoreGui.LunaciPremium.Enabled = true end
            if onSuccess then onSuccess(key, info) end
        else
            local reasons = {KEY_NOT_FOUND="Ключ не найден", EXPIRED="Срок истек", FORMAT="Неверный формат", SERVER_UNAVAILABLE="Сервер недоступен"}
            Status.Text = reasons[info] or ("Ошибка: "..tostring(info))
            Status.TextColor3 = Color3.fromRGB(255,70,80)
            Btn.Text = "ВОЙТИ"; Btn.BackgroundColor3 = Color3.fromRGB(155,85,255)
        end
    end
    Btn.MouseButton1Click:Connect(doLogin)
    Box.FocusLost:Connect(function(enter) if enter then doLogin() end end)
    if saved then
        task.delay(0.7, function()
            if not IsLoggedIn and Box.Text == saved then
                local ok,_ = ValidateOnline(saved)
                if ok then
                    IsLoggedIn = true
                    ScreenGui:Destroy()
                    if CoreGui:FindFirstChild("LunaciPremium") then CoreGui.LunaciPremium.Enabled = true end
                    if onSuccess then onSuccess(saved, _) end
                end
            end
        end)
    end
    return ScreenGui
end


local LunaciConnections = {}
local function LunaConnect(sig, fn)
    local c = sig:Connect(function(...) if UNLOADED then return end return fn(...) end)
    table.insert(LunaciConnections, c)
    return c
end

-- ============================================================
-- SFX
-- ============================================================
local SFX = {}
SFX.Enabled = true
SFX.Volume = 0.5

local SFX_IDS = {
    Click   = "rbxassetid://139719503904449",
    Open    = "rbxassetid://78897892629188",
    Error   = "rbxassetid://96628258513206",
    Message = "rbxassetid://131390520971848",
    Close   = "rbxassetid://78897892629188",
    Hover   = "rbxassetid://139719503904449",
    Toggle  = "rbxassetid://139719503904449",
    Slider  = "rbxassetid://139719503904449",
    Tab     = "rbxassetid://139719503904449",
    Notify  = "rbxassetid://131390520971848",
}
local sfxCache = {}
for name, id in pairs(SFX_IDS) do
    local s = Instance.new("Sound")
    s.Name = "LunaciSFX_" .. name
    s.SoundId = id
    s.Volume = SFX.Volume
    sfxCache[name] = s
end
local sfxLast = {}
local SFX_THROTTLE = 0.04
function SFX.Play(name)
    if not SFX.Enabled then return end
    local s = sfxCache[name]
    if not s then return end
    local now = os.clock()
    if sfxLast[name] and now - sfxLast[name] < SFX_THROTTLE then return end
    sfxLast[name] = now
    s.Volume = SFX.Volume
    pcall(function() SoundService:PlayLocalSound(s) end)
end
function SFX.SetVolume(v)
    SFX.Volume = math.clamp(v, 0, 1)
    for _, s in pairs(sfxCache) do s.Volume = SFX.Volume end
end
function SFX.SetEnabled(v)
    SFX.Enabled = v and true or false
end
function SFX.Destroy()
    for _, s in pairs(sfxCache) do s:Destroy() end
    sfxCache = {}
end

-- ============================================================
-- SETTINGS
-- ============================================================
local DefaultSettings = {
    MenuKey = Enum.KeyCode.Tab,
    AimKey = Enum.UserInputType.MouseButton2,
    ConfigName = "LunaciPremium_Config.json",
    Aimbot = false, RageBot = false, SilentAim = false,
    AutoAim = false, AutoAimSmooth = 3, AutoAimAutoFire = true, AutoAimAutoTrigger = true,
    TeamCheck = true,
    Smoothness = 0.5, SilentSmooth = 6,
    TriggerBot = false, AutoFire = false,
    DoubleTap = false, RapidFire = false,
    NoRecoil = false, NoRecoilPower = 100,
    FOV = 450, Predict = 0.08, ShowFOV = true,
    TraceShot = false, TraceGrad = true, TraceBeam = true,
    TraceC1 = 1, TraceC2 = 2, TraceDur = 0.25, TraceDist = 300,
    ESP = false, Names = true, Tracers = false, Boxes = false, Crosshair = false,
    WorldFOV = 90, Speed = 16, Jump = 50,
    Fly = false, Noclip = false, AirJump = false, MoveBeforeRound = false,
    Bhop = false, BhopSpeed = 40,
    SelfChams = false,
    RemSmoke = false, RemFlash = false, RemSky = false, RemImpact = false, RemExplosion = false,
    GrenadeTrajectory = false,
    NightSky = false,
    NightBrightness = 0.15,
    NightAmbient = 0.35,
    NightStars = 3000,
    GlassMode = false,
    SFXEnabled = true, SFXVolume = 0.5,
    Notifications = true, NotifyDuration = 3,
    AvatarID = "rbxassetid://107043317637075",
    ChamWall = true,
    ChamFlat = false, ChamGlow = false, ChamXray = false,
    ChamVis = false, ChamLiquid = false, ChamOutline = false, ChamRainbow = false,
    ChamElectric = false, ChamWave = false, ChamGlowRing = false,
    ChamLava = false, ChamCrystal = false, ChamGlitch = false, ChamCyber = false,
    ChamVertical = false, ChamPulse = false, ChamNoise = false, ChamScan = false,
    ChamHit = false, ChamCaustics = false,
    ChamOrbs = false, ChamOrbCount = 8, ChamElectricStreaks = 8,
    ChamWeapon = false, ChamHolo = false,

    KeyAimbot = Enum.KeyCode.LeftAlt,
    KeyRage = Enum.KeyCode.X,
    KeySilent = Enum.KeyCode.C,
    KeyAutoAim = Enum.KeyCode.V,
    KeyTrigger = Enum.KeyCode.F,
    KeyFly = Enum.KeyCode.G,
    KeyNoclip = Enum.KeyCode.N,
    KeyESP = Enum.KeyCode.E,
    KeyChams = Enum.KeyCode.H,
    KeyNightSky = Enum.KeyCode.J,
}

local Settings = {}
for k, v in pairs(DefaultSettings) do Settings[k] = v end

-- ============================================================
-- TEAM CHECK
-- ============================================================
local function IsEnemy(p)
    if not p then return false end
    if p == lplr then return false end
    if not Settings.TeamCheck then return true end
    if lplr.Team and p.Team and p.Team == lplr.Team then return false end
    return true
end

-- ============================================================
-- THEME
-- ============================================================
local ThemePresets = {
    { Name = "Neon Purple",  Accent = Color3.fromRGB(155, 85, 255) },
    { Name = "Cyber Cyan",   Accent = Color3.fromRGB(35, 135, 255) },
    { Name = "Blood Red",    Accent = Color3.fromRGB(255, 70, 80) },
    { Name = "Toxic Green",  Accent = Color3.fromRGB(0, 215, 120) },
    { Name = "Sunset",       Accent = Color3.fromRGB(255, 145, 0) },
    { Name = "Liquid Glass", Accent = Color3.fromRGB(210, 230, 255) },
}
local ThemeIndex = 1
local Accent = ThemePresets[1].Accent

local BgPanel   = Color3.fromRGB(22, 22, 22)
local BgSidebar = Color3.fromRGB(15, 15, 15)
local BgContent = Color3.fromRGB(22, 22, 22)
local BgGroup   = Color3.fromRGB(28, 28, 28)
local BgRow     = Color3.fromRGB(32, 32, 32)
local TextMain  = Color3.fromRGB(235, 235, 235)
local TextDim   = Color3.fromRGB(130, 130, 130)
local TextMute  = Color3.fromRGB(90, 90, 90)
local Line      = Color3.fromRGB(40, 40, 40)

local function Corner(o, px) Instance.new("UICorner", o).CornerRadius = UDim.new(0, px) end
local function Stroke(o, c, t, a)
    local s = Instance.new("UIStroke", o)
    s.Color = c or Line; s.Thickness = t or 1; s.Transparency = a or 0
end
local function Rnd(n, dp) local m = 10^(dp or 0); return math.floor(n*m + 0.5)/m end
local findWeapon
local function WriteFile(n, t) if writefile then pcall(writefile, n, t) end end
local function ReadFile(n)
    if isfile and isfile(n) then local ok, d = pcall(readfile, n); if ok then return d end end
    return ""
end

local AccentHooks = {}
local SyncHooks = {}
local function OnAccent(fn) table.insert(AccentHooks, fn) end
local function OnSync(fn) table.insert(SyncHooks, fn) end
local function RefreshAccent()
    Accent = ThemePresets[ThemeIndex].Accent
    for _, fn in pairs(AccentHooks) do pcall(fn) end
end
local function SyncAll() for _, fn in pairs(SyncHooks) do pcall(fn) end end

-- ============================================================
-- CONFIG
-- ============================================================
local function serializeValue(v)
    if typeof and typeof(v) == "EnumItem" then return "__enum:" .. tostring(v.EnumType) .. ":" .. v.Name end
    return v
end
local function deserializeValue(v)
    if type(v) == "string" and v:sub(1, 7) == "__enum:" then
        local _, enumType, name = v:find("^__enum:(.+)%:(.+)$")
        if enumType and name then
            local ok, enum = pcall(function() return Enum[enumType][name] end)
            if ok then return enum end
        end
    end
    return v
end

local KEYBIND_FIELDS = {
    "MenuKey", "AimKey",
    "KeyAimbot", "KeyRage", "KeySilent", "KeyAutoAim", "KeyTrigger",
    "KeyFly", "KeyNoclip", "KeyESP", "KeyChams", "KeyNightSky",
}

local function SaveConfig()
    if not writefile then return false end
    local data = {}
    for k, v in pairs(Settings) do
        data[k] = serializeValue(v)
    end
    local ok, enc = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then
        WriteFile(Settings.ConfigName, enc)
        return true
    end
    return false
end

local function LoadConfig()
    if not (isfile and isfile(Settings.ConfigName)) then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(ReadFile(Settings.ConfigName)) end)
    if not (ok and type(data) == "table") then return false end

    for k, v in pairs(data) do
        if Settings[k] ~= nil then
            Settings[k] = deserializeValue(v)
        end
    end

    -- жёсткий ремап keybind-полей: если что-то потерялось при JSON round-trip, ставим дефолт
    for _, field in ipairs(KEYBIND_FIELDS) do
        local val = Settings[field]
        if typeof and typeof(val) ~= "EnumItem" then
            Settings[field] = DefaultSettings[field]
        end
    end

    return true
end

local function ConfigExists()
    return isfile and isfile(Settings.ConfigName)
end

-- ============================================================
-- DRAWING
-- ============================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2; FOVCircle.NumSides = 100
FOVCircle.Filled = false; FOVCircle.Transparency = 0.3; FOVCircle.Visible = false
local CrossL = Drawing.new("Line")
local CrossR = Drawing.new("Line")
CrossL.Thickness, CrossR.Thickness = 1.5, 1.5
CrossL.Color, CrossR.Color = Accent, Accent
CrossL.Visible, CrossR.Visible = false, false

-- ============================================================
-- GUI BASE
-- ============================================================
pcall(function()
    if CoreGui:FindFirstChild("LunaciPremium") then CoreGui.LunaciPremium:Destroy() end
end)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "LunaciPremium"
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
local NotifyHolder = Instance.new("Frame", ScreenGui)
NotifyHolder.Name = "NotifyHolder"
NotifyHolder.AnchorPoint = Vector2.new(1, 0)
NotifyHolder.Position = UDim2.new(1, -20, 0, 20)
NotifyHolder.Size = UDim2.new(0, 280, 1, -40)
NotifyHolder.BackgroundTransparency = 1
NotifyHolder.ZIndex = 5
local NotifyLL = Instance.new("UIListLayout", NotifyHolder)
NotifyLL.SortOrder = Enum.SortOrder.LayoutOrder
NotifyLL.Padding = UDim.new(0, 8)
NotifyLL.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifyLL.VerticalAlignment = Enum.VerticalAlignment.Top

local NotifyColors = {
    info    = Color3.fromRGB(60, 160, 255),
    success = Color3.fromRGB(60, 210, 120),
    warn    = Color3.fromRGB(255, 175, 40),
    error   = Color3.fromRGB(255, 70, 80),
}
local NotifyOrder = 0

local function Notify(title, body, kind, duration)
    if not Settings.Notifications then return end
    kind = kind or "info"
    duration = duration or Settings.NotifyDuration or 3
    NotifyOrder = NotifyOrder + 1

    local card = Instance.new("Frame", NotifyHolder)
    card.BackgroundColor3 = BgGroup
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, 0, 0, 60)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.LayoutOrder = NotifyOrder
    Corner(card, 8)
    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = NotifyColors[kind] or NotifyColors.info
    cardStroke.Thickness = 1.5
    cardStroke.Transparency = 0.2
    local pad = Instance.new("UIPadding", card)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)

    local accentBar = Instance.new("Frame", card)
    accentBar.Size = UDim2.new(0, 3, 1, -20)
    accentBar.Position = UDim2.new(0, 0, 0, 10)
    accentBar.BackgroundColor3 = NotifyColors[kind] or NotifyColors.info
    Corner(accentBar, 2)

    local titleLbl = Instance.new("TextLabel", card)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size = UDim2.new(1, -10, 0, 18)
    titleLbl.Position = UDim2.new(0, 8, 0, 0)
    titleLbl.Text = title or "Lunaci"
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextColor3 = TextMain
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local bodyLbl = Instance.new("TextLabel", card)
    bodyLbl.BackgroundTransparency = 1
    bodyLbl.Size = UDim2.new(1, -10, 0, 0)
    bodyLbl.Position = UDim2.new(0, 8, 0, 22)
    bodyLbl.AutomaticSize = Enum.AutomaticSize.Y
    bodyLbl.Text = body or ""
    bodyLbl.Font = Enum.Font.Gotham
    bodyLbl.TextColor3 = TextDim
    bodyLbl.TextSize = 12
    bodyLbl.TextXAlignment = Enum.TextXAlignment.Left
    bodyLbl.TextWrapped = true

    card.Position = UDim2.new(1, 30, 0, 0)
    TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) }):Play()

    if kind == "error" then SFX.Play("Error")
    else SFX.Play("Notify") end

    task.delay(duration, function()
        if not card.Parent then return end
        local out = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(1, 30, 0, card.Position.Y.Offset) })
        out:Play()
        out.Completed:Connect(function() card:Destroy() end)
    end)
    return card
end

-- ============================================================
-- MAIN WINDOW
-- ============================================================
local W, H = 720, 480
local Main = Instance.new("Frame", ScreenGui)
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, W, 0, H)
Main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
Main.BackgroundColor3 = BgPanel
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = false
Corner(Main, 10)
Stroke(Main, Color3.fromRGB(40,40,40), 1, 0.3)
local MainScale = Instance.new("UIScale", Main)
MainScale.Scale = 0

local dragging, dragInput, dragStart, startPos
LunaConnect(Main.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = Main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
LunaConnect(Main.InputChanged, function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
LunaConnect(UIS.InputChanged, function(input)
    if input == dragInput and dragging then
        local d = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- ============================================================
-- SIDEBAR
-- ============================================================
local SB_W = 180
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, SB_W, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = BgSidebar
Sidebar.BorderSizePixel = 0
Corner(Sidebar, 10)
local sideCorner = Instance.new("Frame", Sidebar)
sideCorner.Size = UDim2.new(0, 10, 1, 0)
sideCorner.Position = UDim2.new(1, -10, 0, 0)
sideCorner.BackgroundColor3 = BgSidebar
sideCorner.BorderSizePixel = 0
sideCorner.ZIndex = 0

local Brand = Instance.new("TextLabel", Sidebar)
Brand.Size = UDim2.new(1, -70, 0, 30)
Brand.Position = UDim2.new(0, 20, 0, 20)
Brand.BackgroundTransparency = 1
Brand.Text = "LUNACI"
Brand.Font = Enum.Font.GothamBold
Brand.TextColor3 = TextMain
Brand.TextSize = 16
Brand.TextXAlignment = Enum.TextXAlignment.Left
Brand.TextYAlignment = Enum.TextYAlignment.Center

local BrandSub = Instance.new("TextLabel", Sidebar)
BrandSub.Size = UDim2.new(1, -70, 0, 14)
BrandSub.Position = UDim2.new(0, 20, 0, 48)
BrandSub.BackgroundTransparency = 1
BrandSub.Text = "PREMIUM V26.6"
BrandSub.Font = Enum.Font.Gotham
BrandSub.TextColor3 = TextMute
BrandSub.TextSize = 10
BrandSub.TextXAlignment = Enum.TextXAlignment.Left

-- Avatar PNG
local AvatarHolder = Instance.new("Frame", Sidebar)
AvatarHolder.Size = UDim2.new(0, 44, 0, 44)
AvatarHolder.Position = UDim2.new(1, -58, 0, 12)
AvatarHolder.BackgroundColor3 = BgRow
AvatarHolder.BorderSizePixel = 0
AvatarHolder.ClipsDescendants = true
Corner(AvatarHolder, 22)
local AvatarStroke = Instance.new("UIStroke", AvatarHolder)
AvatarStroke.Color = Accent
AvatarStroke.Thickness = 1.5
AvatarStroke.Transparency = 0.15

local AvatarImg = Instance.new("ImageLabel", AvatarHolder)
AvatarImg.Size = UDim2.new(1, -4, 1, -4)
AvatarImg.Position = UDim2.new(0, 2, 0, 2)
AvatarImg.BackgroundTransparency = 1
AvatarImg.Image = Settings.AvatarID or ""
AvatarImg.ScaleType = Enum.ScaleType.Crop
Corner(AvatarImg, 20)
OnAccent(function() AvatarStroke.Color = Accent end)

local SideList = Instance.new("Frame", Sidebar)
SideList.Size = UDim2.new(1, -20, 1, -130)
SideList.Position = UDim2.new(0, 10, 0, 80)
SideList.BackgroundTransparency = 1
local SideLL = Instance.new("UIListLayout", SideList)
SideLL.Padding = UDim.new(0, 4)
SideLL.SortOrder = Enum.SortOrder.LayoutOrder

local Profile = Instance.new("Frame", Sidebar)
Profile.Size = UDim2.new(1, -20, 0, 50)
Profile.Position = UDim2.new(0, 10, 1, -60)
Profile.BackgroundTransparency = 1

local ProfName = Instance.new("TextLabel", Profile)
ProfName.Size = UDim2.new(1, 0, 0, 18)
ProfName.Position = UDim2.new(0, 8, 0, 4)
ProfName.BackgroundTransparency = 1
ProfName.Text = lplr and lplr.Name or "Player"
ProfName.Font = Enum.Font.GothamBold
ProfName.TextColor3 = TextMain
ProfName.TextSize = 12
ProfName.TextXAlignment = Enum.TextXAlignment.Left

local ProfRank = Instance.new("TextLabel", Profile)
ProfRank.Size = UDim2.new(1, 0, 0, 14)
ProfRank.Position = UDim2.new(0, 8, 0, 22)
ProfRank.BackgroundTransparency = 1
ProfRank.Text = "S-class"
ProfRank.Font = Enum.Font.Gotham
ProfRank.TextColor3 = TextMute
ProfRank.TextSize = 10
ProfRank.TextXAlignment = Enum.TextXAlignment.Left

-- ============================================================
-- CONTENT
-- ============================================================
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -SB_W, 1, 0)
Content.Position = UDim2.new(0, SB_W, 0, 0)
Content.BackgroundColor3 = BgContent
Content.BorderSizePixel = 0

local pageContainer = Instance.new("Frame", Content)
pageContainer.Size = UDim2.new(1, 0, 1, 0)
pageContainer.BackgroundTransparency = 1

local function CreatePage()
    local p = Instance.new("ScrollingFrame", pageContainer)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = Color3.fromRGB(60,60,60)
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local ll = Instance.new("UIListLayout", p)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll.Padding = UDim.new(0, 12)
    local pad = Instance.new("UIPadding", p)
    pad.PaddingTop = UDim.new(0, 20)
    pad.PaddingBottom = UDim.new(0, 20)
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 20)
    return p
end

local pages = {
    Triggerbot = CreatePage(),
    Aim = CreatePage(),
    Rage = CreatePage(),
    Players = CreatePage(),
    Movement = CreatePage(),
    Keybinds = CreatePage(),
    Config = CreatePage(),
    Misc = CreatePage(),
}

local tabButtons = {}
local function SelectTab(name)
    for n, b in pairs(tabButtons) do
        local sel = (n == name)
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = sel and Color3.fromRGB(35,35,35) or BgSidebar,
            TextColor3 = sel and TextMain or TextDim,
        }):Play()
        local pg = pages[n]
        if pg then pg.Visible = sel end
    end
end

local function AddTab(label, pageName)
    local tab = Instance.new("TextButton", SideList)
    tab.Size = UDim2.new(1, 0, 0, 34)
    tab.BackgroundColor3 = BgSidebar
    tab.BorderSizePixel = 0
    tab.Text = "  " .. label
    tab.TextColor3 = TextDim
    tab.Font = Enum.Font.Gotham
    tab.TextSize = 13
    tab.TextXAlignment = Enum.TextXAlignment.Left
    tab.TextYAlignment = Enum.TextYAlignment.Center
    tab.AutoButtonColor = false
    Corner(tab, 6)
    tabButtons[pageName] = tab
    LunaConnect(tab.MouseEnter, function() SFX.Play("Hover") end)
    LunaConnect(tab.MouseButton1Click, function() SFX.Play("Tab"); SelectTab(pageName) end)
    return function() SelectTab(pageName) end
end

local SelTriggerbot = AddTab("Triggerbot", "Triggerbot")
local SelAim        = AddTab("Aim", "Aim")
local SelRage       = AddTab("Rage", "Rage")
local SelPlayers    = AddTab("Players", "Players")
local SelMovement   = AddTab("Movement", "Movement")
local SelKeybinds   = AddTab("Keybinds", "Keybinds")
local SelConfig     = AddTab("Config", "Config")
local SelMisc       = AddTab("Misc", "Misc")

-- ============================================================
-- COMPONENTS
-- ============================================================
local function AddHeader(parent, title)
    local h = Instance.new("TextLabel", parent)
    h.Size = UDim2.new(1, 0, 0, 32)
    h.BackgroundTransparency = 1
    h.Text = title
    h.Font = Enum.Font.GothamBold
    h.TextColor3 = TextMain
    h.TextSize = 18
    h.TextXAlignment = Enum.TextXAlignment.Left
end

local function AddGroup(parent, title)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 0)
    holder.AutomaticSize = Enum.AutomaticSize.Y
    holder.BackgroundColor3 = BgGroup
    holder.BorderSizePixel = 0
    Corner(holder, 8)

    local header = Instance.new("TextLabel", holder)
    header.Size = UDim2.new(1, -28, 0, 34)
    header.Position = UDim2.new(0, 14, 0, 6)
    header.BackgroundTransparency = 1
    header.Text = title
    header.Font = Enum.Font.GothamBold
    header.TextColor3 = TextMain
    header.TextSize = 14
    header.TextXAlignment = Enum.TextXAlignment.Left

    local inner = Instance.new("Frame", holder)
    inner.Size = UDim2.new(1, -20, 0, 0)
    inner.Position = UDim2.new(0, 10, 0, 44)
    inner.AutomaticSize = Enum.AutomaticSize.Y
    inner.BackgroundTransparency = 1
    local ll = Instance.new("UIListLayout", inner)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll.Padding = UDim.new(0, 6)

    local bottomPad = Instance.new("Frame", holder)
    bottomPad.Size = UDim2.new(1, 0, 0, 10)
    bottomPad.Position = UDim2.new(0, 0, 1, -10)
    bottomPad.BackgroundTransparency = 1

    return inner
end

local function AddToggle(parent, label, key)
    local row = Instance.new("TextButton", parent)
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1
    row.Text = ""
    row.AutoButtonColor = false

    local knobBg = Instance.new("Frame", row)
    knobBg.Size = UDim2.new(0, 14, 0, 14)
    knobBg.Position = UDim2.new(0, 6, 0.5, -7)
    knobBg.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Corner(knobBg, 7)
    Stroke(knobBg, Color3.fromRGB(70,70,70), 1, 0)

    local knob = Instance.new("Frame", knobBg)
    knob.Size = UDim2.new(0, 8, 0, 8)
    knob.Position = UDim2.new(0.5, -4, 0.5, -4)
    knob.BackgroundColor3 = Color3.fromRGB(120,120,120)
    Corner(knob, 4)

    local txt = Instance.new("TextLabel", row)
    txt.Size = UDim2.new(1, -40, 1, 0)
    txt.Position = UDim2.new(0, 30, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = label
    txt.Font = Enum.Font.Gotham
    txt.TextColor3 = TextDim
    txt.TextSize = 13
    txt.TextXAlignment = Enum.TextXAlignment.Left

    local function render()
        local on = Settings[key]
        knobBg.BackgroundColor3 = on and Accent or Color3.fromRGB(50,50,50)
        knob.BackgroundColor3 = on and Color3.new(1,1,1) or Color3.fromRGB(120,120,120)
        txt.TextColor3 = on and TextMain or TextDim
    end
    OnSync(render); OnAccent(render)
    LunaConnect(row.MouseEnter, function() SFX.Play("Hover") end)
    LunaConnect(row.MouseButton1Click, function()
        Settings[key] = not Settings[key]
        SFX.Play("Toggle")
        render()
        if key == "SFXEnabled" then SFX.SetEnabled(Settings.SFXEnabled) end
        if key == "SFXVolume" then SFX.SetVolume(Settings.SFXVolume) end
    end)
    render()
end

local function AddSlider(parent, label, key, min, max, dp)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 34)
    holder.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(0.7, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.Gotham
    lbl.TextColor3 = TextDim
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", holder)
    val.Size = UDim2.new(0.3, -6, 0, 16)
    val.Position = UDim2.new(0.7, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.TextColor3 = TextMain
    val.TextSize = 12
    val.Font = Enum.Font.Gotham
    val.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("Frame", holder)
    track.Size = UDim2.new(1, 0, 0, 3)
    track.Position = UDim2.new(0, 0, 0, 24)
    track.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Corner(track, 2)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Accent
    Corner(fill, 2)

    local dragged = false
    local function refresh()
        local frac = math.clamp((Settings[key]-min)/(max-min), 0, 1)
        fill.Size = UDim2.new(frac, 0, 1, 0)
        val.Text = tostring(Rnd(Settings[key], dp))
    end
    local function fromMouse()
        local m = UIS:GetMouseLocation()
        local ap = track.AbsolutePosition
        local w = track.AbsoluteSize.X
        if w <= 0 then return end
        local frac = math.clamp((m.X-ap.X)/w, 0, 1)
        Settings[key] = Rnd(min + (max-min)*frac, dp)
        refresh()
        if key == "SFXVolume" then SFX.SetVolume(Settings.SFXVolume) end
        if key == "NightBrightness" or key == "NightAmbient" or key == "NightStars" then
            if Settings.NightSky then SyncAll() end
        end
    end
    LunaConnect(track.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragged = true; fromMouse() end
    end)
    LunaConnect(track.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragged = false
            SFX.Play("Slider")
        end
    end)
    LunaConnect(UIS.InputChanged, function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement and dragged then fromMouse() end
    end)
    OnSync(refresh)
    OnAccent(function() fill.BackgroundColor3 = Accent end)
    refresh()
end

local function AddButton(parent, label)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 30)
    b.BackgroundColor3 = BgRow
    b.Text = label
    b.Font = Enum.Font.Gotham
    b.TextColor3 = TextMain
    b.TextSize = 12
    b.AutoButtonColor = false
    Corner(b, 6)
    LunaConnect(b.MouseEnter, function()
        b.BackgroundColor3 = Color3.fromRGB(40,40,40)
        SFX.Play("Hover")
    end)
    LunaConnect(b.MouseLeave, function() b.BackgroundColor3 = BgRow end)
    LunaConnect(b.MouseButton1Click, function() SFX.Play("Click") end)
    return b
end

local function AddKeybind(parent, label, key)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.Gotham
    lbl.TextColor3 = TextDim
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0.4, -6, 0, 22)
    btn.Position = UDim2.new(0.6, 0, 0.5, -11)
    btn.BackgroundColor3 = BgRow
    btn.Text = ""
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = TextMain
    btn.TextSize = 12
    btn.AutoButtonColor = false
    Corner(btn, 5)

    local function render()
        if capturingKey == key then
            btn.Text = "..."
            btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        else
            local v = Settings[key]
            if typeof and typeof(v) == "EnumItem" then
                btn.Text = v.Name
            else
                btn.Text = tostring(v)
            end
            btn.BackgroundColor3 = BgRow
        end
    end
    OnSync(render)
    LunaConnect(btn.MouseEnter, function() SFX.Play("Hover") end)
    LunaConnect(btn.MouseButton1Click, function()
        capturingKey = key
        SFX.Play("Click")
        render()
    end)
    render()
end

-- ============================================================
-- KEYBIND ROUTER
-- ============================================================
local function isKeyboardInput(input) return input.UserInputType == Enum.UserInputType.Keyboard end
local function isMouseInput(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.MouseButton2
        or input.UserInputType == Enum.UserInputType.MouseButton3
end
local function boundToken(bound)
    if not bound then return nil end
    local t = typeof and typeof(bound)
    if t == "EnumItem" then
        if bound.EnumType == Enum.KeyCode then return "k:" .. bound.Name end
        if bound.EnumType == Enum.UserInputType then return "m:" .. bound.Name end
    end
    return "raw:" .. tostring(bound)
end
local function inputToken(input)
    if isKeyboardInput(input) then return "k:" .. input.KeyCode.Name end
    if isMouseInput(input) then return "m:" .. input.UserInputType.Name end
    return nil
end

local KEYBIND_ACTIONS = {
    { setting = "KeyAimbot",   target = "Aimbot",     label = "Aimbot" },
    { setting = "KeyRage",     target = "RageBot",    label = "Rage" },
    { setting = "KeySilent",   target = "SilentAim",  label = "Silent Aim" },
    { setting = "KeyAutoAim",  target = "AutoAim",    label = "Auto Aim" },
    { setting = "KeyTrigger",  target = "TriggerBot", label = "Triggerbot" },
    { setting = "KeyFly",      target = "Fly",        label = "Fly" },
    { setting = "KeyNoclip",   target = "Noclip",     label = "Noclip" },
    { setting = "KeyESP",      target = "ESP",        label = "ESP" },
    { setting = "KeyChams",    target = "ChamVis",    label = "Chams" },
    { setting = "KeyNightSky", target = "NightSky",   label = "Night Sky" },
}

local tokenMap = {}
local function rebuildTokenMap()
    tokenMap = {}
    for _, a in ipairs(KEYBIND_ACTIONS) do
        local tk = boundToken(Settings[a.setting])
        if tk then tokenMap[tk] = a end
    end
end
rebuildTokenMap()

-- ============================================================
-- PAGE: TRIGGERBOT
-- ============================================================
AddHeader(pages.Triggerbot, "Triggerbot")
local g1 = AddGroup(pages.Triggerbot, "Triggerbot")
AddToggle(g1, "Enabled", "TriggerBot")
AddToggle(g1, "Team Check", "TeamCheck")
AddToggle(g1, "Visible check", "AutoFire")
AddToggle(g1, "Account recoil", "NoRecoil")
AddToggle(g1, "Accuracy boost", "DoubleTap")

local g1b = AddGroup(pages.Triggerbot, "Adjust")
AddSlider(g1b, "Max distance", "FOV", 100, 1000, 0)
AddSlider(g1b, "Hold key time", "TraceDur", 0.1, 0.8, 2)
AddSlider(g1b, "Before shot delay", "Predict", 0, 0.25, 3)
AddSlider(g1b, "After shot delay", "TraceDist", 50, 500, 0)
AddSlider(g1b, "Humanize %", "NoRecoilPower", 0, 100, 0)

-- ============================================================
-- PAGE: AIM
-- ============================================================
AddHeader(pages.Aim, "Aimbot")

local a0 = AddGroup(pages.Aim, "Auto Aim (no RMB)")
AddToggle(a0, "Auto Aim (always on)", "AutoAim")
AddSlider(a0, "Auto Aim Smooth", "AutoAimSmooth", 1, 15, 0)
AddToggle(a0, "Auto Fire", "AutoAimAutoFire")
AddToggle(a0, "Auto Trigger (near center)", "AutoAimAutoTrigger")

local a1 = AddGroup(pages.Aim, "Targeting")
AddToggle(a1, "Team Check", "TeamCheck")
AddToggle(a1, "Legit Aim (smoothed)", "Aimbot")
AddToggle(a1, "Rage Aim (instant snap)", "RageBot")
AddToggle(a1, "Silent Aim", "SilentAim")
AddSlider(a1, "Silent Aim Speed", "SilentSmooth", 1, 30, 0)
AddSlider(a1, "Smoothness", "Smoothness", 0, 1, 2)
AddSlider(a1, "FOV Radius", "FOV", 100, 1000, 0)
AddSlider(a1, "Prediction", "Predict", 0, 0.25, 3)
AddToggle(a1, "Show FOV circle", "ShowFOV")
AddToggle(a1, "No Recoil", "NoRecoil")
AddSlider(a1, "Recoil Reduction %", "NoRecoilPower", 0, 100, 0)

local a2 = AddGroup(pages.Aim, "Rapid")
AddToggle(a2, "Trigger Bot", "TriggerBot")
AddToggle(a2, "Auto Fire", "AutoFire")
AddToggle(a2, "Double Tap", "DoubleTap")
AddToggle(a2, "Rapid Fire", "RapidFire")

local a3 = AddGroup(pages.Aim, "Shot Tracers")
AddToggle(a3, "Beam Tracers", "TraceShot")
AddToggle(a3, "Inner Glow", "TraceBeam")
AddToggle(a3, "Two-Tone", "TraceGrad")
AddSlider(a3, "Trace Length", "TraceDist", 50, 500, 0)
AddSlider(a3, "Trace Duration", "TraceDur", 0.1, 0.8, 2)

-- ============================================================
-- PAGE: RAGE
-- ============================================================
AddHeader(pages.Rage, "Rage")
local r1 = AddGroup(pages.Rage, "Rage features")
AddToggle(r1, "Team Check", "TeamCheck")
AddToggle(r1, "Rage Aim", "RageBot")
AddSlider(r1, "Snap FOV", "FOV", 100, 1000, 0)
AddToggle(r1, "Silent Aim", "SilentAim")
AddToggle(r1, "Auto Fire", "AutoFire")

-- ============================================================
-- PAGE: PLAYERS
-- ============================================================
AddHeader(pages.Players, "Players")

local p1 = AddGroup(pages.Players, "ESP")
AddToggle(p1, "Team Check", "TeamCheck")
AddToggle(p1, "Highlight ESP", "ESP")
AddToggle(p1, "Name Tags", "Names")
AddToggle(p1, "Tracer Lines", "Tracers")
AddToggle(p1, "Boxes", "Boxes")

local p2 = AddGroup(pages.Players, "Camera")
AddSlider(p2, "Field of View", "WorldFOV", 70, 140, 0)
AddToggle(p2, "Center Crosshair", "Crosshair")

local p3 = AddGroup(pages.Players, "Player Chams")
AddToggle(p3, "Show Through Walls", "ChamWall")
AddToggle(p3, "Flat Cham", "ChamFlat")
AddToggle(p3, "Glow Cham", "ChamGlow")
AddToggle(p3, "X-Ray", "ChamXray")
AddToggle(p3, "Chams (normal)", "ChamVis")
AddToggle(p3, "Liquid (2-color flow)", "ChamLiquid")
AddToggle(p3, "Outline", "ChamOutline")
AddToggle(p3, "Rainbow", "ChamRainbow")
AddToggle(p3, "Electric", "ChamElectric")
AddToggle(p3, "Wave", "ChamWave")
AddToggle(p3, "Glow Ring", "ChamGlowRing")
AddToggle(p3, "Lava / Plasma", "ChamLava")
AddToggle(p3, "Crystal / Diamond", "ChamCrystal")
AddToggle(p3, "Glitch Hologram", "ChamGlitch")
AddToggle(p3, "Cyber Mesh", "ChamCyber")
AddToggle(p3, "Vertical Gradient", "ChamVertical")
AddToggle(p3, "Scan Pulse Wave", "ChamPulse")
AddToggle(p3, "Moving Noise", "ChamNoise")
AddToggle(p3, "Scanline Sweep", "ChamScan")
AddToggle(p3, "Hit Flash", "ChamHit")
AddToggle(p3, "Caustics / Aquatic", "ChamCaustics")
AddSlider(p3, "Electric Streaks", "ChamElectricStreaks", 4, 12, 0)
AddToggle(p3, "Orbit Orbs", "ChamOrbs")
AddSlider(p3, "Orbit Count", "ChamOrbCount", 2, 12, 0)

local p4 = AddGroup(pages.Players, "Weapon Chams")
AddToggle(p4, "Weapon Cham", "ChamWeapon")
AddToggle(p4, "Hologram Flow", "ChamHolo")

local p5 = AddGroup(pages.Players, "Self")
AddToggle(p5, "Chams On Self", "SelfChams")

local p6 = AddGroup(pages.Players, "Removers")
AddToggle(p6, "Remove Smoke", "RemSmoke")
AddToggle(p6, "Remove Flash", "RemFlash")
AddToggle(p6, "Remove Sky", "RemSky")
AddToggle(p6, "Remove Impact", "RemImpact")
AddToggle(p6, "Remove Explosion", "RemExplosion")

-- ============================================================
-- PAGE: MOVEMENT
-- ============================================================
AddHeader(pages.Movement, "Movement")
local m1 = AddGroup(pages.Movement, "Stats")
AddSlider(m1, "Walkspeed", "Speed", 10, 200, 0)
AddSlider(m1, "Jump Power", "Jump", 40, 140, 0)

local m2 = AddGroup(pages.Movement, "Abilities")
AddToggle(m2, "Noclip", "Noclip")
AddToggle(m2, "Fly Mode", "Fly")
AddToggle(m2, "Auto Air-Jump", "AirJump")
AddToggle(m2, "Bunny Hop", "Bhop")
AddSlider(m2, "Bhop Jump Speed", "BhopSpeed", 10, 200, 0)
AddToggle(m2, "Move Before Round", "MoveBeforeRound")

-- ============================================================
-- PAGE: KEYBINDS
-- ============================================================
AddHeader(pages.Keybinds, "Keybinds")
local kb1 = AddGroup(pages.Keybinds, "Menu")
AddKeybind(kb1, "Open / close menu", "MenuKey")
AddKeybind(kb1, "Aim hold", "AimKey")

local kb2 = AddGroup(pages.Keybinds, "Aim")
AddKeybind(kb2, "Toggle Aimbot", "KeyAimbot")
AddKeybind(kb2, "Toggle Rage", "KeyRage")
AddKeybind(kb2, "Toggle Silent", "KeySilent")
AddKeybind(kb2, "Toggle AutoAim", "KeyAutoAim")
AddKeybind(kb2, "Toggle Trigger", "KeyTrigger")

local kb3 = AddGroup(pages.Keybinds, "Movement / Visuals")
AddKeybind(kb3, "Toggle Fly", "KeyFly")
AddKeybind(kb3, "Toggle Noclip", "KeyNoclip")
AddKeybind(kb3, "Toggle ESP", "KeyESP")
AddKeybind(kb3, "Toggle Chams", "KeyChams")
AddKeybind(kb3, "Toggle Night Sky", "KeyNightSky")

-- ============================================================
-- PAGE: CONFIG
-- ============================================================
AddHeader(pages.Config, "Config")

local cf1 = AddGroup(pages.Config, "Theme")
local themeRow = Instance.new("Frame", cf1)
themeRow.Size = UDim2.new(1, 0, 0, 30)
themeRow.BackgroundTransparency = 1
local trLL = Instance.new("UIListLayout", themeRow)
trLL.FillDirection = Enum.FillDirection.Horizontal
trLL.Padding = UDim.new(0, 8)
trLL.SortOrder = Enum.SortOrder.LayoutOrder

for i = 1, #ThemePresets do
    local dot = Instance.new("TextButton", themeRow)
    dot.Size = UDim2.new(0, 40, 0, 26)
    dot.BackgroundColor3 = ThemePresets[i].Accent
    dot.Text = (i == ThemeIndex) and "?" or ""
    dot.Font = Enum.Font.GothamBold
    dot.TextColor3 = Color3.fromRGB(30,30,30)
    dot.TextSize = 14
    dot.AutoButtonColor = false
    Corner(dot, 6)
    dot.LayoutOrder = i
    LunaConnect(dot.MouseButton1Click, function()
        ThemeIndex = i
        for _, d in pairs(themeRow:GetChildren()) do
            if d:IsA("TextButton") then d.Text = (d.LayoutOrder == i) and "?" or "" end
        end
        RefreshAccent()
        SFX.Play("Click")
    end)
end

local cfKey = AddGroup(pages.Config, "Key System")
local KeyStatusLbl = Instance.new("TextLabel", cfKey)
KeyStatusLbl.Size = UDim2.new(1, 0, 0, 18)
KeyStatusLbl.BackgroundTransparency = 1
KeyStatusLbl.Font = Enum.Font.Gotham
KeyStatusLbl.TextSize = 11
KeyStatusLbl.TextColor3 = TextDim
KeyStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
KeyStatusLbl.TextWrapped = true
local function RefreshKeyStatus()
    local k = ReadSavedKey()
    KeyStatusLbl.Text = k and ("Текущий: " .. k) or "Ключ не сохранён"
end
RefreshKeyStatus()

local DelKeyBtn = AddButton(cfKey, "🗑️ Удалить ключ и выйти")
LunaConnect(DelKeyBtn.MouseButton1Click, function()
    pcall(function() if delfile and isfile and isfile(KEY_FILE) then delfile(KEY_FILE) end end)
    pcall(function() if writefile then pcall(writefile, KEY_FILE, "") end end)
    IsLoggedIn = false
    Main.Visible = false
    MenuOpen = false
    MainScale.Scale = 0
    SFX.Play("Close")
    Notify("Ключ удалён", "Введи новый ключ", "warn", 3)
    task.wait(0.3)
    CreateKeyGUI(function(key, info)
        RefreshKeyStatus()
        pcall(function()
            Main.Visible = true; MenuOpen = true; SelectTab("Triggerbot")
            TweenService:Create(MainScale, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
            SFX.Play("Open")
            Notify("Lunaci V26.6", "Ключ активен (" .. tostring(info.label) .. " | " .. tostring(info.days_left) .. " дн.)", "success", 4)
        end)
    end)
end)

local ChangeKeyBtn = AddButton(cfKey, "🔑 Сменить ключ")
LunaConnect(ChangeKeyBtn.MouseButton1Click, function()
    pcall(function() if delfile and isfile and isfile(KEY_FILE) then delfile(KEY_FILE) end end)
    IsLoggedIn = false
    Main.Visible = false
    MainScale.Scale = 0
    CreateKeyGUI(function(key, info)
        RefreshKeyStatus()
        pcall(function()
            Main.Visible = true; MenuOpen = true; SelectTab("Triggerbot")
            TweenService:Create(MainScale, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
            Notify("Ключ сменён", "Новый: " .. key, "success", 3)
        end)
    end)
end)

local CopyKeyBtn = AddButton(cfKey, "📋 Копировать текущий ключ")
LunaConnect(CopyKeyBtn.MouseButton1Click, function()
    local k = ReadSavedKey()
    if k and k ~= "" and setclipboard then
        pcall(setclipboard, k)
        SFX.Play("Message")
        Notify("Скопировано", k, "success", 2)
    else
        SFX.Play("Error")
        Notify("Нет ключа", "Сначала введи ключ", "error", 2)
    end
end)

local cf2 = AddGroup(pages.Config, "Visuals")
AddToggle(cf2, "Liquid Glass Mode", "GlassMode")

local cf3 = AddGroup(pages.Config, "Sound")
AddToggle(cf3, "UI Sounds", "SFXEnabled")
AddSlider(cf3, "Volume", "SFXVolume", 0, 1, 2)

local cf5 = AddGroup(pages.Config, "Notifications")
AddToggle(cf5, "Enable Notifications", "Notifications")
AddSlider(cf5, "Duration", "NotifyDuration", 1, 10, 1)

local cf4 = AddGroup(pages.Config, "Data")
local SaveBtn = AddButton(cf4, "Save Config")
LunaConnect(SaveBtn.MouseButton1Click, function()
    if SaveConfig() then
        SFX.Play("Message")
        Notify("Config saved", Settings.ConfigName, "success", 2)
    else
        SFX.Play("Error")
        Notify("Save failed", "writefile unavailable", "error", 3)
    end
end)
local LoadBtn = AddButton(cf4, "Load Config")
LunaConnect(LoadBtn.MouseButton1Click, function()
    if not ConfigExists() then
        SFX.Play("Error")
        Notify("Load failed", "No config file found", "error", 3)
        return
    end
    if LoadConfig() then
        SyncAll()
        rebuildTokenMap()
        SFX.SetEnabled(Settings.SFXEnabled)
        SFX.SetVolume(Settings.SFXVolume)
        SFX.Play("Message")
        Notify("Config loaded", Settings.ConfigName, "success", 2)
    else
        SFX.Play("Error")
        Notify("Load failed", "Invalid config file", "error", 3)
    end
end)
local ResetCfgBtn = AddButton(cf4, "Reset to Defaults")
LunaConnect(ResetCfgBtn.MouseButton1Click, function()
    for k, v in pairs(DefaultSettings) do Settings[k] = v end
    SyncAll()
    rebuildTokenMap()
    SFX.SetEnabled(Settings.SFXEnabled)
    SFX.SetVolume(Settings.SFXVolume)
    SFX.Play("Message")
    Notify("Reset", "All settings restored to defaults", "warn", 2)
end)

local TestNotifBtn = AddButton(cf4, "Test Notification")
LunaConnect(TestNotifBtn.MouseButton1Click, function()
    Notify("Lunaci", "Test notification — all systems nominal", "info", 2)
end)
local TestErrorBtn = AddButton(cf4, "Test Error")
LunaConnect(TestErrorBtn.MouseButton1Click, function()
    Notify("Error test", "This is what an error looks like", "error", 2)
end)

local UnloadBtn = AddButton(cf4, "UNLOAD LUNACI")
UnloadBtn.BackgroundColor3 = Color3.fromRGB(120, 25, 35)
LunaConnect(UnloadBtn.MouseButton1Click, function()
    UnloadBtn.Text = "UNLOADING..."
    task.wait(0.15)
    LunaciUnload()
end)

-- ============================================================
-- PAGE: MISC
-- ============================================================
AddHeader(pages.Misc, "Misc")

local mi1 = AddGroup(pages.Misc, "Self")
AddToggle(mi1, "Chams On Self", "SelfChams")

local mi2 = AddGroup(pages.Misc, "World")
AddToggle(mi2, "Night Sky (on map)", "NightSky")
AddSlider(mi2, "Brightness", "NightBrightness", -0.5, 0.5, 2)
AddSlider(mi2, "Ambient", "NightAmbient", 0, 1, 2)
AddSlider(mi2, "Stars", "NightStars", 0, 8000, 0)
AddToggle(mi2, "Grenade Trajectory", "GrenadeTrajectory")

local mi3 = AddGroup(pages.Misc, "Notifications")
AddToggle(mi3, "Enable", "Notifications")
AddSlider(mi3, "Duration (s)", "NotifyDuration", 1, 10, 1)

local mi4 = AddGroup(pages.Misc, "Hints")
local hintLbl = Instance.new("TextLabel", mi4)
hintLbl.Size = UDim2.new(1, 0, 0, 40)
hintLbl.BackgroundTransparency = 1
hintLbl.Text = "Open menu: Tab\nAim hold: RMB\nKeybinds: separate tab"
hintLbl.Font = Enum.Font.Gotham
hintLbl.TextColor3 = TextDim
hintLbl.TextSize = 12
hintLbl.TextXAlignment = Enum.TextXAlignment.Left
hintLbl.TextYAlignment = Enum.TextYAlignment.Top
hintLbl.TextWrapped = true

-- ============================================================
-- GLASS MODE
-- ============================================================
local function ApplyGlass()
    local isGlass = Settings.GlassMode
    pcall(function()
        Main.BackgroundTransparency = isGlass and 0.35 or 0
        Sidebar.BackgroundTransparency = isGlass and 0.45 or 0
        Content.BackgroundTransparency = isGlass and 0.35 or 0
        sideCorner.BackgroundTransparency = isGlass and 0.45 or 0
    end)
    for _, page in pairs(pages) do
        for _, child in pairs(page:GetChildren()) do
            if child:IsA("Frame") and child.BackgroundColor3 == BgGroup then
                child.BackgroundTransparency = isGlass and 0.55 or 0
            end
        end
    end
    local lgt = game:FindFirstChildOfClass("Lighting")
    if lgt then
        local blur = lgt:FindFirstChild("LunaciBlur")
        if isGlass then
            if not blur then
                blur = Instance.new("BlurEffect", lgt)
                blur.Name = "LunaciBlur"
                blur.Size = 12
            end
        elseif blur then
            blur:Destroy()
        end
    end
end
OnSync(ApplyGlass)

-- ============================================================
-- NIGHT SKY (играбельный)
-- ============================================================
local NightBackup = nil
local NIGHT_ASSETS = {
    Bk = "rbxassetid://159454299", Dn = "rbxassetid://159454296",
    Ft = "rbxassetid://159454293", Lf = "rbxassetid://159454286",
    Rt = "rbxassetid://159454300", Up = "rbxassetid://159454288",
}
local function ApplyNightSky()
    local lgt = Lighting
    if not lgt then return end
    local sky = lgt:FindFirstChildOfClass("Sky")
    local atm = lgt:FindFirstChildOfClass("Atmosphere")
    local cc = lgt:FindFirstChild("LunaciNightCC")

    if Settings.NightSky then
        if not NightBackup then
            NightBackup = {
                sky = sky and {
                    Bk = sky.SkyboxBk, Dn = sky.SkyboxDn, Ft = sky.SkyboxFt,
                    Lf = sky.SkyboxLf, Rt = sky.SkyboxRt, Up = sky.SkyboxUp,
                    Sun = sky.SunAngularSize, Moon = sky.MoonAngularSize,
                    Stars = sky.StarCount,
                },
                atm = atm and {
                    Density = atm.Density, Offset = atm.Offset,
                    Color = atm.Color, Decay = atm.Decay,
                    Glare = atm.Glare, Haze = atm.Haze,
                },
                lighting = {
                    Brightness = lgt.Brightness,
                    Ambient = lgt.Ambient,
                    OutdoorAmbient = lgt.OutdoorAmbient,
                    ClockTime = lgt.ClockTime,
                    GlobalShadows = lgt.GlobalShadows,
                    FogEnd = lgt.FogEnd,
                    FogStart = lgt.FogStart,
                    FogColor = lgt.FogColor,
                },
            }
        end

        if sky then
            pcall(function()
                sky.SkyboxBk = NIGHT_ASSETS.Bk
                sky.SkyboxDn = NIGHT_ASSETS.Dn
                sky.SkyboxFt = NIGHT_ASSETS.Ft
                sky.SkyboxLf = NIGHT_ASSETS.Lf
                sky.SkyboxRt = NIGHT_ASSETS.Rt
                sky.SkyboxUp = NIGHT_ASSETS.Up
                sky.SunAngularSize = 0
                sky.MoonAngularSize = 14
                sky.StarCount = Settings.NightStars or 3000
            end)
        end

        if atm then
            pcall(function()
                atm.Density = 0.35
                atm.Offset = 0
                atm.Color = Color3.fromRGB(40, 55, 95)
                atm.Decay = Color3.fromRGB(40, 50, 90)
                atm.Glare = 0.3
                atm.Haze = 1.2
            end)
        end

        pcall(function()
            lgt.ClockTime = 0
            lgt.Brightness = 0.5 + (Settings.NightBrightness or 0.15)
            local amb = Settings.NightAmbient or 0.35
            lgt.Ambient = Color3.new(amb, amb, amb * 1.1)
            lgt.OutdoorAmbient = Color3.new(amb * 0.9, amb * 0.9, amb)
            lgt.GlobalShadows = false
            lgt.FogColor = Color3.fromRGB(20, 25, 45)
            lgt.FogStart = 100
            lgt.FogEnd = 2000
        end)

        if not cc then
            cc = Instance.new("ColorCorrectionEffect", lgt)
            cc.Name = "LunaciNightCC"
        end
        cc.Brightness = Settings.NightBrightness or 0.15
        cc.Contrast = 0.08
        cc.Saturation = -0.05
        cc.TintColor = Color3.fromRGB(200, 215, 255)
    else
        if NightBackup then
            if NightBackup.sky and sky then
                pcall(function()
                    sky.SkyboxBk = NightBackup.sky.Bk
                    sky.SkyboxDn = NightBackup.sky.Dn
                    sky.SkyboxFt = NightBackup.sky.Ft
                    sky.SkyboxLf = NightBackup.sky.Lf
                    sky.SkyboxRt = NightBackup.sky.Rt
                    sky.SkyboxUp = NightBackup.sky.Up
                    sky.SunAngularSize = NightBackup.sky.Sun
                    sky.MoonAngularSize = NightBackup.sky.Moon
                    sky.StarCount = NightBackup.sky.Stars
                end)
            end
            if NightBackup.atm and atm then
                pcall(function()
                    atm.Density = NightBackup.atm.Density
                    atm.Offset = NightBackup.atm.Offset
                    atm.Color = NightBackup.atm.Color
                    atm.Decay = NightBackup.atm.Decay
                    atm.Glare = NightBackup.atm.Glare
                    atm.Haze = NightBackup.atm.Haze
                end)
            end
            if NightBackup.lighting then
                pcall(function()
                    local b = NightBackup.lighting
                    lgt.Brightness = b.Brightness
                    lgt.Ambient = b.Ambient
                    lgt.OutdoorAmbient = b.OutdoorAmbient
                    lgt.ClockTime = b.ClockTime
                    lgt.GlobalShadows = b.GlobalShadows
                    lgt.FogEnd = b.FogEnd
                    lgt.FogStart = b.FogStart
                    lgt.FogColor = b.FogColor
                end)
            end
            NightBackup = nil
        end
        if cc then cc:Destroy() end
    end
end
OnSync(ApplyNightSky)

OnSync(function()
    SFX.SetEnabled(Settings.SFXEnabled)
    SFX.SetVolume(Settings.SFXVolume)
    if AvatarImg and Settings.AvatarID then
        AvatarImg.Image = Settings.AvatarID
    end
end)

-- ============================================================
-- UNLOAD
-- ============================================================
function LunaciUnload()
    UNLOADED = true
    MenuOpen = false
    holdKey = false
    capturingKey = nil

    pcall(function() SFX.Play("Close") end)
    pcall(function() if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end end)
    pcall(function() FOVCircle:Remove(); CrossL:Remove(); CrossR:Remove() end)
    pcall(function()
        if Traj then for _, l in pairs(Traj) do l:Remove() end end
        if TrajText then TrajText:Remove() end
        if TrajRadius1 then TrajRadius1:Remove() end
        if TrajRadius2 then TrajRadius2:Remove() end
    end)
    pcall(function()
        if TracerPool then
            for _, objs in pairs(TracerPool) do
                if objs.glow then objs.glow:Remove() end
                if objs.a then objs.a:Remove() end
                if objs.b then objs.b:Remove() end
            end
        end
    end)
    pcall(function()
        for _, d in pairs(esp or {}) do
            if d.tracer then d.tracer:Remove() end
            if d.name then d.name:Remove() end
            if d.hpb then d.hpb:Remove() end
            if d.hpbBg then d.hpbBg:Remove() end
            if d.lines then for _, l in pairs(d.lines) do l:Remove() end end
        end
    end)
    pcall(function()
        for _, cs in pairs(orbHud or {}) do
            for _, c in pairs(cs) do if c.Remove then c:Remove() end end
        end
        orbHud = {}
    end)
    pcall(function()
        for _, p in pairs(Players:GetPlayers()) do
            local ch = p.Character
            if ch then
                for _, n in ipairs({ "LunaciHL", "LunaciCham", "LunaciWpn" }) do
                    local o = ch:FindFirstChild(n); if o then o:Destroy() end
                end
                for _, d in pairs(ch:GetDescendants()) do
                    if d.Name == "LunaciFly" or d.Name == "LunaciFlyLV" or d.Name == "LunaciFlyAtt" then d:Destroy() end
                end
            end
        end
    end)
    pcall(function()
        local char = lplr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local lv = hrp:FindFirstChild("LunaciFlyLV"); if lv then lv:Destroy() end
            local att = hrp:FindFirstChild("LunaciFlyAtt"); if att then att:Destroy() end
        end
    end)
    pcall(function()
        local lgt = game:FindFirstChildOfClass("Lighting")
        if lgt then
            local cc = lgt:FindFirstChild("LunaciNightCC"); if cc then cc:Destroy() end
            local blur = lgt:FindFirstChild("LunaciBlur"); if blur then blur:Destroy() end
        end
    end)
    pcall(function()
        for _, c in pairs(LunaciConnections) do
            if c and c.Disconnect then c:Disconnect() end
        end
        LunaciConnections = {}
    end)
    task.wait(0.4)
    pcall(function() SFX.Destroy() end)
    print("[LUNACI] unloaded.")
end

-- ============================================================
-- BOOT
-- ============================================================
local function BootLunaci(keyInfo)
    if UNLOADED then return end
    pcall(function()
        Main.Visible = true
        MenuOpen = true
        SelectTab("Triggerbot")
        TweenService:Create(MainScale, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
        SFX.Play("Open")
        local label = keyInfo and keyInfo.label or ""
        local days = keyInfo and keyInfo.days_left or "?"
        Notify("Lunaci V26.6", "Ключ активен ("..tostring(label).." | "..tostring(days).." дн.) Tab - меню, RMB - aim", "success", 4)
    end)
end

-- Показываем окно ключа; после успеха грузим меню
CreateKeyGUI(function(key, info) BootLunaci(info) end)

-- ============================================================
-- AIM LOGIC
-- ============================================================
local function GetClosestTarget()
    local target, best = nil, Settings.FOV
    local mouse = UIS:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if IsEnemy(p) and p.Character and p.Character:FindFirstChild("Head") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local vp, onScreen = camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(vp.X, vp.Y) - mouse).Magnitude
                    if mag < best then best = mag; target = p.Character.Head end
                end
            end
        end
    end
    return target
end

-- ============================================================
-- ESP
-- ============================================================
do
local esp = {}
local function GiveESP(p)
    if not p.Character then return end
    local d = {}
    d.tracer = Drawing.new("Line")
    d.tracer.Thickness = 1.5; d.tracer.Transparency = 0.25
    d.lines = {}
    for i = 1, 4 do
        d.lines[i] = Drawing.new("Line")
        d.lines[i].Thickness = 1.2; d.lines[i].Transparency = 0.35
    end
    d.name = Drawing.new("Text")
    d.name.Outline = true
    d.name.OutlineColor = Color3.new(0,0,0)
    d.name.Color = Color3.new(1,1,1)
    d.name.Size = 15
    esp[p] = d
end
local function RemoveESP(p)
    local d = esp[p]
    if d then
        d.tracer:Remove()
        for _, ln in pairs(d.lines) do ln:Remove() end
        if d.hpb then d.hpb:Remove() end
        if d.hpbBg then d.hpbBg:Remove() end
        d.name:Remove()
        esp[p] = nil
    end
end
LunaConnect(Players.PlayerRemoving, RemoveESP)

local function HideESP()
    for _, d in pairs(esp) do
        d.tracer.Visible = false; d.name.Visible = false
        if d.hpb then d.hpb.Visible = false end
        if d.hpbBg then d.hpbBg.Visible = false end
        for _, ln in pairs(d.lines) do ln.Visible = false end
    end
end

local function UpdateESP()
    for p, d in pairs(esp) do
        local char = p.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        if not IsEnemy(p) or not (hum and root and head and hum.Health > 0) then
            d.tracer.Visible = false; d.name.Visible = false
            if d.hpb then d.hpb.Visible = false end
            if d.hpbBg then d.hpbBg.Visible = false end
            for _, ln in pairs(d.lines) do ln.Visible = false end
        else
            local top, onScreen = camera:WorldToViewportPoint(head.CFrame * Vector3.new(0, 0.8, 0))
            local bot = camera:WorldToViewportPoint(root.Position)
            if not onScreen then
                d.tracer.Visible = false; d.name.Visible = false
                if d.hpb then d.hpb.Visible = false end
                if d.hpbBg then d.hpbBg.Visible = false end
                for _, ln in pairs(d.lines) do ln.Visible = false end
            else
                local dist = (camera.CFrame.Position - root.Position).Magnitude
                local h = math.abs(top.Y - bot.Y)
                local w = h * 0.8
                if Settings.Tracers then
                    local vs = camera.ViewportSize
                    d.tracer.From = Vector2.new(vs.X / 2, vs.Y)
                    d.tracer.To = Vector2.new(bot.X, bot.Y)
                    d.tracer.Visible = true
                    d.tracer.Color = Accent
                else d.tracer.Visible = false end
                if Settings.Boxes then
                    local x1, x2 = top.X - w, top.X + w
                    local y1, y2 = top.Y, bot.Y
                    local seg = {
                        { x1, y1, x2, y1 }, { x2, y1, x2, y2 },
                        { x2, y2, x1, y2 }, { x1, y2, x1, y1 },
                    }
                    for i = 1, 4 do
                        d.lines[i].From = Vector2.new(seg[i][1], seg[i][2])
                        d.lines[i].To = Vector2.new(seg[i][3], seg[i][4])
                        d.lines[i].Color = Color3.fromRGB(230, 40, 40)
                        d.lines[i].Thickness = 1.5
                        d.lines[i].Visible = true
                    end
                    if not d.hpb then d.hpb = Drawing.new("Line") end
                    local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    local hbx = x1 - 4
                    d.hpb.Color = Color3.fromRGB(60, 220, 90)
                    d.hpb.Thickness = 2
                    d.hpb.From = Vector2.new(hbx, y2)
                    d.hpb.To = Vector2.new(hbx, y2 - (y2 - y1) * hp)
                    if not d.hpbBg then d.hpbBg = Drawing.new("Line") end
                    d.hpbBg.Color = Color3.fromRGB(20, 20, 20)
                    d.hpbBg.Thickness = 4
                    d.hpbBg.From = Vector2.new(hbx, y2)
                    d.hpbBg.To = Vector2.new(hbx, y1)
                    d.hpbBg.Visible = true
                    d.hpb.Visible = true
                else
                    for _, ln in pairs(d.lines) do ln.Visible = false end
                    if d.hpb then d.hpb.Visible = false end
                    if d.hpbBg then d.hpbBg.Visible = false end
                end
                if Settings.Names then
                    d.name.Text = p.DisplayName .. "  " .. math.round(dist) .. "m"
                    d.name.Position = Vector2.new(top.X, top.Y - 4)
                    d.name.Visible = true
                else d.name.Visible = false end
            end
        end
    end
end
local function EnsureESP()
    for _, p in pairs(Players:GetPlayers()) do
        if IsEnemy(p) then
            local d = esp[p]
            if not d then GiveESP(p) end
        end
    end
end
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
local function ensureFlyAttachment(hrp)
    local att = hrp:FindFirstChild("LunaciFlyAtt")
    if not att then
        att = Instance.new("Attachment", hrp)
        att.Name = "LunaciFlyAtt"
    end
    local lv = hrp:FindFirstChild("LunaciFlyLV")
    if not lv then
        lv = Instance.new("LinearVelocity", hrp)
        lv.Name = "LunaciFlyLV"
        lv.Attachment0 = att
        lv.MaxForce = math.huge
        lv.RelativeTo = Enum.ActuatorRelativeTo.World
        lv.VectorVelocity = Vector3.zero
    end
    return lv
end

LunaConnect(RunService.Heartbeat, function(dt)
    if not IsLoggedIn then return end
    local char = lplr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) then return end
    hum.WalkSpeed = Settings.Speed
    hum.JumpPower = Settings.Jump
    if Settings.Bhop and UIS:IsKeyDown(Enum.KeyCode.Space) and hum.OnFloor then
        local vel = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = Vector3.new(vel.X, Settings.BhopSpeed, vel.Z)
    end
    if Settings.AirJump and UIS:IsKeyDown(Enum.KeyCode.Space) and not hum.OnFloor then
        local vel = hrp.AssemblyLinearVelocity
        if vel.Y < 30 then hrp.AssemblyLinearVelocity = Vector3.new(vel.X, Settings.Jump, vel.Z) end
    end
    if Settings.Noclip then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
    if Settings.Fly then
        local lv = ensureFlyAttachment(hrp)
        local dir = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
        lv.VectorVelocity = dir * 60
        hum.PlatformStand = true
    else
        local lv = hrp:FindFirstChild("LunaciFlyLV")
        if lv then lv:Destroy() end
        local att = hrp:FindFirstChild("LunaciFlyAtt")
        if att then att:Destroy() end
        hum.PlatformStand = false
    end
end)

LunaConnect(RunService.RenderStepped, function(dt)
    if not IsLoggedIn then return end
    camera.FieldOfView = Settings.WorldFOV

    if Settings.AutoAim then
        local target = GetClosestTarget()
        if target then
            local tp = target.Position + (target.Velocity or Vector3.new()) * Settings.Predict
            local desired = CFrame.new(camera.CFrame.Position, tp)
            local k = 1 - math.exp(-Settings.AutoAimSmooth * dt)
            camera.CFrame = camera.CFrame:Lerp(desired, k)

            if Settings.AutoAimAutoFire then
                local vp = camera:WorldToViewportPoint(tp)
                local center = camera.ViewportSize / 2
                local dist = (Vector2.new(vp.X, vp.Y) - center).Magnitude
                if vp.Z > 0 and dist < 30 then
                    if Settings.AutoAimAutoTrigger then
                        LunaciShoot()
                    elseif mouse1click then
                        pcall(mouse1click)
                    end
                end
            end
        end
    end

    if (Settings.Aimbot or Settings.RageBot or Settings.SilentAim) and holdKey then
        local target = GetClosestTarget()
        if target then
            local tp = target.Position + (target.Velocity or Vector3.new()) * Settings.Predict
            if Settings.SilentAim then
                local desired = CFrame.new(camera.CFrame.Position, tp)
                local t = 1 - math.exp(-Settings.SilentSmooth * dt)
                camera.CFrame = camera.CFrame:Lerp(desired, t)
            elseif Settings.RageBot then
                camera.CFrame = CFrame.new(camera.CFrame.Position, tp)
            else
                local vp = camera:WorldToViewportPoint(tp)
                local m = UIS:GetMouseLocation()
                if mousemoverel then
                    mousemoverel((vp.X - m.X) * Settings.Smoothness * dt * 60, (vp.Y - m.Y) * Settings.Smoothness * dt * 60)
                else
                    camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, tp), Settings.Smoothness)
                end
            end
        end
    end

    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = (Settings.Aimbot or Settings.RageBot or Settings.SilentAim) and Settings.ShowFOV

    if Settings.Crosshair then
        local c = UIS:GetMouseLocation()
        CrossL.From = Vector2.new(c.X - 12, c.Y); CrossL.To = Vector2.new(c.X - 2, c.Y)
        CrossR.From = Vector2.new(c.X + 2, c.Y);  CrossR.To = Vector2.new(c.X + 12, c.Y)
        CrossL.Color = Accent; CrossR.Color = Accent
        CrossL.Visible, CrossR.Visible = true, true
    else CrossL.Visible, CrossR.Visible = false, false end

    for _, p in pairs(Players:GetPlayers()) do
        if IsEnemy(p) then
            local char = p.Character
            if Settings.ESP then
                if char and not char:FindFirstChild("LunaciHL") then
                    local hl = Instance.new("Highlight", char)
                    hl.Name = "LunaciHL"
                    hl.FillColor = Accent; hl.OutlineColor = Accent
                    hl.FillTransparency = 0.45; hl.OutlineTransparency = 0
                end
            elseif char then
                local hl = char:FindFirstChild("LunaciHL")
                if hl then hl:Destroy() end
            end
        else
            local ch = p.Character
            if ch then
                local hl = ch:FindFirstChild("LunaciHL")
                if hl then hl:Destroy() end
            end
        end
    end

    if Settings.Tracers or Settings.Boxes or Settings.Names then
        EnsureESP(); UpdateESP()
    else HideESP() end
end)

-- ============================================================
-- INPUT: menu, aim hold, keybind router
-- ============================================================
LunaConnect(UIS.InputBegan, function(k, gpe)
    if UNLOADED then return end
    if gpe then return end
    if not IsLoggedIn then return end

    if capturingKey then
        if not (isKeyboardInput(k) or isMouseInput(k)) then return end
        local newVal = isKeyboardInput(k) and k.KeyCode or k.UserInputType
        local oldName = capturingKey
        Settings[capturingKey] = newVal
        capturingKey = nil
        rebuildTokenMap()
        SyncAll()
        SFX.Play("Message")
        Notify("Keybind set", oldName .. " → " .. tostring(newVal.Name), "success", 2)
        return
    end

    if boundToken(Settings.MenuKey) == inputToken(k) then
        MenuOpen = not MenuOpen
        SFX.Play(MenuOpen and "Open" or "Close")
        Main.Visible = MenuOpen
        TweenService:Create(MainScale, TweenInfo.new(0.25), { Scale = MenuOpen and 1 or 0 }):Play()
        return
    end

    if boundToken(Settings.AimKey) == inputToken(k) then
        holdKey = true
        return
    end

    local tk = inputToken(k)
    if tk then
        local action = tokenMap[tk]
        if action then
            local key = action.target
            Settings[key] = not Settings[key]
            SyncAll()
            SFX.Play(Settings[key] and "Toggle" or "Click")
            Notify("Toggled", action.label .. ": " .. tostring(Settings[key]), Settings[key] and "success" or "info", 1.5)
        end
    end
end)
LunaConnect(UIS.InputEnded, function(k)
    if boundToken(Settings.AimKey) == inputToken(k) then
        holdKey = false
    end
end)

task.delay(0.5, function()
    if UNLOADED then return end
    if LoadConfig() then
        SyncAll()
        rebuildTokenMap()
        SFX.SetEnabled(Settings.SFXEnabled)
        SFX.SetVolume(Settings.SFXVolume)
    end
end)

-- ============================================================
-- SHOT TRACERS
-- ============================================================
do
local ActiveTracers = {}
local TracerPool = {}
local PoolCursor = 0

for i = 1, 8 do
    local objs = {
        glow = Drawing.new("Line"),
        a = Drawing.new("Line"),
        b = Drawing.new("Line"),
    }
    objs.glow.Thickness = 6; objs.glow.Visible = false
    objs.a.Thickness = 2; objs.a.Visible = false
    objs.b.Thickness = 2; objs.b.Visible = false
    TracerPool[i] = objs
end

local function findMuzzle(char)
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local m = tool:FindFirstChild("Muzzle") or tool:FindFirstChild("Barrel")
            or tool:FindFirstChild("Muzzle_L") or tool:FindFirstChild("Handle")
        if m and m:IsA("BasePart") then return m.CFrame.p + m.CFrame.LookVector * 0.3 end
    end
    local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
    if hand then
        local cf = hand.CFrame or CFrame.new(hand.Position)
        return hand.Position + cf.LookVector * 0.2
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hrp and hrp.Position or (camera.CFrame.Position + camera.CFrame.LookVector * 2)
end

local function fireShot()
    local char = lplr.Character
    if not char then return end
    PoolCursor = PoolCursor + 1
    if PoolCursor > #TracerPool then PoolCursor = 1 end
    local objs = TracerPool[PoolCursor]
    local from = findMuzzle(char)
    local target = GetClosestTarget()
    local to = target and target.Position or (from + camera.CFrame.LookVector * Settings.TraceDist)

    for _, tr in pairs(ActiveTracers) do
        if tr.objs == objs then
            tr.from, tr.to, tr.t, tr.life = from, to, 0, Settings.TraceDur
            return
        end
    end
    ActiveTracers[#ActiveTracers + 1] = { from = from, to = to, t = 0, life = Settings.TraceDur, objs = objs }
end

LunaConnect(RunService.RenderStepped, function(dt)
    local i = 1
    while i <= #ActiveTracers do
        local tr = ActiveTracers[i]
        tr.t = tr.t + dt
        if tr.t >= tr.life then
            tr.objs.glow.Visible = false
            tr.objs.a.Visible = false
            tr.objs.b.Visible = false
            table.remove(ActiveTracers, i)
        else
            local f = camera:WorldToViewportPoint(tr.from)
            local tt = camera:WorldToViewportPoint(tr.to)
            local md = camera:WorldToViewportPoint((tr.from + tr.to) * 0.5)
            local fv = Vector2.new(f.X, f.Y); local tv = Vector2.new(tt.X, tt.Y); local mv = Vector2.new(md.X, md.Y)
            local fade = 1 - (tr.t / tr.life)
            local cA = Color3.fromRGB(255, 70, 90)
            local cB = Color3.fromRGB(80, 150, 255)
            local env = math.sin(fade * math.pi); env = env * env
            if Settings.TraceBeam then
                tr.objs.glow.Visible = true
                tr.objs.glow.From = fv; tr.objs.glow.To = tv
                tr.objs.glow.Color = cA
                tr.objs.glow.Transparency = 0.5 + (1 - env) * 0.5
            else tr.objs.glow.Visible = false end
            tr.objs.a.Visible = true; tr.objs.b.Visible = true
            tr.objs.a.From = fv; tr.objs.a.To = mv
            tr.objs.b.From = mv; tr.objs.b.To = tv
            tr.objs.a.Transparency = (1 - env) * 0.7
            tr.objs.b.Transparency = (1 - env) * 0.7
            if Settings.TraceGrad then tr.objs.a.Color = cA; tr.objs.b.Color = cB
            else tr.objs.a.Color = cA; tr.objs.b.Color = cA end
            i = i + 1
        end
    end
end)

LunaConnect(UIS.InputBegan, function(k, gpe)
    if gpe then return end
    if IsLoggedIn and k.UserInputType == Enum.UserInputType.MouseButton1 and Settings.TraceShot then
        fireShot()
    end
end)
end

-- ============================================================
-- findWeapon
-- ============================================================
local WEAPON_HINTS = { "gun", "rifle", "pistol", "smg", "shotgun", "sniper", "knife", "sword", "bow", "launcher", "weapon", "tool" }
findWeapon = function(char)
    if not char then return nil end
    local t = char:FindFirstChildOfClass("Tool")
    if t then return t end
    for _, d in pairs(char:GetDescendants()) do
        if d:IsA("Tool") then return d end
    end
    for _, d in pairs(char:GetChildren()) do
        if d:IsA("Model") or d:IsA("Accessory") then
            local n = tostring(d.Name):lower()
            for _, hint in ipairs(WEAPON_HINTS) do
                if n:find(hint, 1, true) then return d end
            end
        end
    end
    return nil
end

-- ============================================================
-- NO RECOIL
-- ============================================================
local RecoilKeys = { "recoil", "coil", "kick", "spread" }
local recoilSnapshot = {}
local function scanRecoilContainer(parent, cap)
    local touched = 0
    for _, d in pairs(parent:GetDescendants()) do
        if touched >= cap then break end
        local n = type(d.Name) == "string" and d.Name:lower() or ""
        if n ~= "" and not n:find("recover", 1, true) then
            local match = false
            for _, kw in ipairs(RecoilKeys) do
                if n:find(kw, 1, true) then match = true; break end
            end
            if match then
                local full = 1 - Settings.NoRecoilPower / 100
                local id = d
                if d:IsA("NumberValue") or d:IsA("IntValue") then
                    if type(d.Value) == "number" then
                        if recoilSnapshot[id] == nil then recoilSnapshot[id] = d.Value end
                        local base = recoilSnapshot[id]
                        local target = base * full
                        if math.abs(d.Value - target) > 1e-4 then d.Value = d.Value + (target - d.Value) * 0.35 end
                        touched = touched + 1
                    end
                elseif d:IsA("Vector3Value") and type(d.Value) == "userdata" then
                    if recoilSnapshot[id] == nil then recoilSnapshot[id] = d.Value end
                    local base = recoilSnapshot[id]
                    local target = base * full
                    d.Value = d.Value:Lerp(target, 0.35)
                    touched = touched + 1
                end
            end
        end
    end
    return touched
end
LunaConnect(RunService.Heartbeat, function()
    if not (IsLoggedIn and Settings.NoRecoil) then return end
    local char = lplr.Character
    if not char then return end
    local wpn = findWeapon(char)
    local cap = 60
    if wpn then cap = cap - scanRecoilContainer(wpn, cap) end
    if cap > 0 then scanRecoilContainer(char, cap) end
end)

-- ============================================================
-- SHOOT / TRIGGER / AUTO
-- ============================================================
local lastShoot = 0
local SHOOT_COOLDOWN = 0.02
local function DoShoot()
    local char = lplr.Character
    if not char then return end
    local now = os.clock()
    if now - lastShoot < SHOOT_COOLDOWN then return end
    lastShoot = now
    if mouse1click then pcall(mouse1click)
    else
        pcall(function()
            local tool = findWeapon(char)
            if tool and tool.Activated then tool.Activated:Fire() end
        end)
    end
end
function LunaciShoot()
    DoShoot()
    if Settings.DoubleTap and Settings.RapidFire then
        for _ = 1, 18 do task.wait(0.01); DoShoot() end
    elseif Settings.DoubleTap then task.wait(); DoShoot()
    elseif Settings.RapidFire then        for _ = 1, 18 do task.wait(0.01); DoShoot() end
    end
end
local losParams = RaycastParams.new()
losParams.FilterType = Enum.RaycastFilterType.Exclude
local function hasLOS(from, to)
    local filter = {}
    if lplr.Character then filter[#filter+1] = lplr.Character end
    if to.Parent then filter[#filter+1] = to.Parent end
    filter[#filter+1] = to
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character ~= lplr.Character then
            filter[#filter+1] = p.Character
        end
    end
    losParams.FilterDescendantsInstances = filter
    local ray = workspace:Raycast(from.Position, (to.Position - from.Position) * 1.2, losParams)
    return not ray
end
local function onScreenTargets()
    local out = {}
    local center = camera.ViewportSize / 2
    for _, p in pairs(Players:GetPlayers()) do
        if IsEnemy(p) and p.Character and p.Character:FindFirstChild("Head") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local head = p.Character.Head
                local vp, on = camera:WorldToViewportPoint(head.Position)
                if on then
                    local dist = (Vector2.new(vp.X, vp.Y) - center).Magnitude
                    out[#out + 1] = { head = head, player = p, dist = dist }
                end
            end
        end
    end
    table.sort(out, function(a, b) return a.dist < b.dist end)
    return out
end
LunaConnect(RunService.Heartbeat, function()
    if not IsLoggedIn then return end
    if not (Settings.TriggerBot or Settings.AutoFire) then return end
    local char = lplr.Character
    if not char or not char:FindFirstChild("Head") then return end
    local myHead = char.Head
    local shots = 0
    for _, t in ipairs(onScreenTargets()) do
        local blocked = not hasLOS(myHead, t.head)
        if blocked and not Settings.AutoFire then break end
        local triggerHit = Settings.TriggerBot and t.dist <= 60 and not blocked
        local autoHit = Settings.AutoFire and not blocked
        if triggerHit or autoHit then
            LunaciShoot()
            shots = shots + 1
            if shots >= 4 then break end
        end
        if not Settings.AutoFire then break end
    end
end)
local firingHeld = false
local fireHookRunning = false
local function LunaciHookFire()
    if fireHookRunning then return end
    fireHookRunning = true
    task.spawn(function()
        while firingHeld and not UNLOADED and (Settings.DoubleTap or Settings.RapidFire) do
            LunaciShoot()
            task.wait(0.05)
        end
        fireHookRunning = false
    end)
end
LunaConnect(UIS.InputBegan, function(k, gpe)
    if gpe then return end
    if IsLoggedIn and k.UserInputType == Enum.UserInputType.MouseButton1 then
        firingHeld = true
        if Settings.DoubleTap or Settings.RapidFire then LunaciHookFire() end
    end
end)
LunaConnect(UIS.InputEnded, function(k)
    if k.UserInputType == Enum.UserInputType.MouseButton1 then firingHeld = false end
end)

-- ============================================================
-- REMOVERS
-- ============================================================
local RemKeys = {
    RemSmoke = { "smoke", "fume" },
    RemFlash = { "flash", "muzzle", "bloom" },
    RemImpact = { "impact", "spark", "bullet", "tracer" },
    RemExplosion = { "explosion", "blast", "orangeexplosion", "explosionparticles" },
}
local function matchesAny(name, kws)
    for _, kw in ipairs(kws) do if name:find(kw, 1, true) then return true end end
    return false
end
local remLast = 0
local remCache = {}
local remCacheStamp = 0
LunaConnect(RunService.Heartbeat, function()
    if not IsLoggedIn then return end
    local now = os.clock()
    if now - remLast < 0.1 then return end
    remLast = now
    local any = false
    for k, _ in pairs(RemKeys) do if Settings[k] then any = true; break end end
    if not any then return end
    if Settings.RemSky and Lighting then
        local sky = Lighting:FindFirstChildOfClass("Sky"); if sky then sky:Destroy() end
        local atm = Lighting:FindFirstChildOfClass("Atmosphere"); if atm then atm:Destroy() end
        local clouds = Lighting:FindFirstChildOfClass("Clouds"); if clouds then clouds.Enabled = false end
    end
    if now - remCacheStamp > 2 or #remCache == 0 then
        remCache = workspace:GetDescendants()
        remCacheStamp = now
    end
    for i = 1, #remCache do
        local o = remCache[i]
        if o.Parent then
            if o:IsA("BasePart") and o.Transparency < 1 then
                local n = type(o.Name) == "string" and o.Name:lower() or ""
                if n ~= "" then
                    for k, kws in pairs(RemKeys) do
                        if Settings[k] and matchesAny(n, kws) then o.Transparency = 1; o.CanCollide = false end
                    end
                end
            elseif o:IsA("ParticleEmitter") and o.Enabled then
                local n = type(o.Name) == "string" and o.Name:lower() or ""
                local pn = type(o.Parent and o.Parent.Name) == "string" and o.Parent.Name:lower() or ""
                for e, kws in pairs(RemKeys) do
                    if Settings[e] and (matchesAny(n, kws) or matchesAny(pn, kws)) then o.Enabled = false end
                end
            end
        end
    end
end)

-- ============================================================
-- GRENADE TRAJECTORY
-- ============================================================
do
local Traj = {}
for i = 1, 24 do
    Traj[i] = Drawing.new("Line")
    Traj[i].Thickness = 1.5; Traj[i].Transparency = 0.6; Traj[i].Visible = false; Traj[i].Color = Accent
end
local TrajText = Drawing.new("Text")
TrajText.Size = 14; TrajText.Center = true; TrajText.Outline = true
TrajText.Color = Accent; TrajText.Visible = false
local TrajRadius1 = Drawing.new("Circle")
TrajRadius1.Thickness = 1.5; TrajRadius1.NumSides = 40
TrajRadius1.Color = Color3.fromRGB(255, 80, 80); TrajRadius1.Filled = true
TrajRadius1.Transparency = 0.7; TrajRadius1.Visible = false
local TrajRadius2 = Drawing.new("Circle")
TrajRadius2.Thickness = 1.5; TrajRadius2.NumSides = 40
TrajRadius2.Color = Color3.fromRGB(80, 200, 255); TrajRadius2.Filled = true
TrajRadius2.Transparency = 0.7; TrajRadius2.Visible = false

local function getGrenadeInfo()
    local char = lplr.Character
    local wpn = char and findWeapon(char)
    if not wpn then return nil end
    local n = wpn.Name:lower()
    if n:find("molotov", 1, true) or n:find("molot", 1, true) then
        return { dmg = 40, radius = 10, speed = 32, name = "Molotov" }
    elseif n:find("hae", 1, true) or n:find("grenade", 1, true) then
        return { dmg = 70, radius = 12, speed = 40, name = "HE Grenade" }
    end
    return nil
end

LunaConnect(RunService.RenderStepped, function()
    if not IsLoggedIn or not Settings.GrenadeTrajectory then
        for i = 1, 24 do Traj[i].Visible = false end
        TrajText.Visible = false; TrajRadius1.Visible = false; TrajRadius2.Visible = false
        return
    end
    local info = getGrenadeInfo()
    if not info then
        TrajText.Text = "Throwable not equipped"
        TrajText.Visible = true
        TrajText.Position = UIS:GetMouseLocation()
        TrajText.Color = Color3.fromRGB(255, 255, 255)
        return
    end
    local char = lplr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local origin = hrp and (hrp.Position + Vector3.new(0, 1.4, 0)) or (camera.CFrame.Position + camera.CFrame.LookVector)
    local startVel = camera.CFrame.LookVector * info.speed + Vector3.new(0, 10, 0)
    local G = Vector3.new(0, -30, 0)
    local p = origin
    local vel = startVel
    TrajText.Position = UIS:GetMouseLocation()
    TrajText.Text = info.name .. " DMG: " .. info.dmg .. " | Radius: " .. info.radius
    TrajText.Visible = true
    local lastPoint = p
    for i = 1, 24 do Traj[i].Visible = false end
    for i = 1, 24 do
        local nextP = p + vel * 0.05 + G * 0.5 * 0.05 ^ 2
        vel = vel + G * 0.05
        local vp1, on1 = camera:WorldToViewportPoint(p)
        local vp2, on2 = camera:WorldToViewportPoint(nextP)
        Traj[i].Visible = on1 or on2
        Traj[i].From = Vector2.new(vp1.X, vp1.Y)
        Traj[i].To = Vector2.new(vp2.X, vp2.Y)
        p = nextP; lastPoint = p
        if p.Y < 0 then break end
    end
    local lp = lastPoint
    if lp.Y < 0 then lp = Vector3.new(lastPoint.X, 0, lastPoint.Z) end
    local radiusPos = lp + Vector3.new(0, 0.2, 0)
    local vp = camera:WorldToViewportPoint(radiusPos)
    if vp.Z > 0 then
        local dist = (camera.CFrame.Position - radiusPos).Magnitude
        local pxPerStud = (camera.ViewportSize.Y / math.max(dist, 1)) / math.tan(math.rad(camera.FieldOfView) / 2) * 1.1
        TrajRadius1.Position = Vector2.new(vp.X, vp.Y)
        TrajRadius1.Radius = math.clamp(info.radius * pxPerStud, 4, 600)
        TrajRadius1.Visible = true
        TrajRadius2.Position = Vector2.new(vp.X, vp.Y)
        TrajRadius2.Radius = math.clamp((info.radius * 0.5) * pxPerStud, 4, 600)
        TrajRadius2.Visible = true
    end
end)
end

-- ============================================================
-- CHAMS ENGINE
-- ============================================================
do
local orbHud = {}

local function playerChamMode()
    if Settings.ChamFlat then return "flat" end
    if Settings.ChamGlow then return "glow" end
    if Settings.ChamXray then return "xray" end
    if Settings.ChamVis then return "vis" end
    if Settings.ChamLiquid then return "liquid" end
    if Settings.ChamOutline then return "outline" end
    if Settings.ChamRainbow then return "rainbow" end
    if Settings.ChamWave then return "wave" end
    if Settings.ChamElectric then return "electric" end
    if Settings.ChamLava then return "lava" end
    if Settings.ChamCrystal then return "crystal" end
    if Settings.ChamGlitch then return "glitch" end
    if Settings.ChamCyber then return "cyber" end
    if Settings.ChamVertical then return "vertical" end
    if Settings.ChamPulse then return "pulse" end
    if Settings.ChamNoise then return "noise" end
    if Settings.ChamScan then return "scan" end
    if Settings.ChamCaustics then return "caustics" end
    return nil
end

local function applyPlayerCham(char, style, t, offset)
    local hl = char:FindFirstChild("LunaciCham")
    if not hl then
        hl = Instance.new("Highlight", char)
        hl.Name = "LunaciCham"
    end
    for _, c in pairs(char:GetChildren()) do
        if c:IsA("Highlight") and c ~= hl and c.Name == "LunaciCham" then
            c:Destroy()
        end
    end
    local c1 = Accent
    local c2 = Color3.fromRGB(255,255,255)
    local mix = (math.sin(t*3 + (offset or 0)) + 1) / 2
    local rainbow = Color3.fromHSV((t*0.35 + (offset or 0)*0.01) % 1, 1, 1)
    hl.DepthMode = Settings.ChamWall and Enum.HighlightDepthMode.AlwaysOnTop
        or Enum.HighlightDepthMode.Occluded
    if style == "flat" then
        hl.FillTransparency = 0.35; hl.OutlineTransparency = 0.05
        hl.FillColor = c1; hl.OutlineColor = c2
    elseif style == "glow" then
        hl.FillTransparency = 0.2; hl.OutlineTransparency = 0
        hl.FillColor = c1; hl.OutlineColor = Color3.new(1,1,1)
    elseif style == "xray" then
        hl.FillTransparency = 0.3; hl.OutlineTransparency = 0
        hl.FillColor = c1; hl.OutlineColor = c1
    elseif style == "vis" then
        hl.FillTransparency = 0.3; hl.OutlineTransparency = 0
        hl.FillColor = c1; hl.OutlineColor = c2
    elseif style == "liquid" then
        hl.FillTransparency = 0.1; hl.OutlineTransparency = 0
        hl.FillColor = c1:Lerp(c2, mix); hl.OutlineColor = c2:Lerp(c1, mix)
    elseif style == "outline" then
        hl.FillTransparency = 1; hl.OutlineTransparency = 0
        hl.FillColor = c1; hl.OutlineColor = c1
    elseif style == "rainbow" then
        hl.FillTransparency = 0.35; hl.OutlineTransparency = 0
        hl.FillColor = rainbow; hl.OutlineColor = rainbow
    elseif style == "wave" then
        local wave = (math.sin(t*5 + (offset or 0)) + 1) / 2
        hl.FillTransparency = 0.25; hl.OutlineTransparency = 0
        hl.FillColor = c1:Lerp(c2, wave); hl.OutlineColor = c1:Lerp(c2, 1-wave)
    elseif style == "electric" then
        local flick = (math.sin(t*22 + (offset or 0)) + 1) / 2
        local white = flick > 0.82
        hl.FillTransparency = 0.5 - (white and 0.25 or 0)
        hl.OutlineTransparency = 0
        hl.FillColor = white and Color3.fromRGB(200,235,255) or c1
        hl.OutlineColor = white and Color3.new(1,1,1) or c2
    elseif style == "caustics" then
        local wave = (math.sin(t*6 + (offset or 0)*1.7) + 1) / 2
        local vein = (math.sin(t*9 + (offset or 0)*2.3) + 1) / 2
        local base = Color3.fromRGB(20, 120, 150)
        local bright = base:Lerp(Color3.fromRGB(210, 245, 255), wave)
        hl.FillTransparency = 0.45; hl.OutlineTransparency = 0
        hl.FillColor = bright
        hl.OutlineColor = (vein > 0.7) and Color3.new(1,1,1) or base:Lerp(Color3.fromRGB(80,200,220), vein)
    elseif style == "lava" then
        local flow = (math.sin(t*3 + (offset or 0)) + 1) / 2
        hl.FillTransparency = 0.35; hl.OutlineTransparency = 0
        hl.FillColor = c1:Lerp(c2, flow); hl.OutlineColor = c1:Lerp(c2, 1-flow)
    elseif style == "crystal" then
        local shine = (math.sin(t*1.2 + (offset or 0)) + 1) / 2
        hl.FillTransparency = 0.5; hl.OutlineTransparency = 0.2
        hl.FillColor = c1:Lerp(c2, shine); hl.OutlineColor = Color3.new(1,1,1)
    elseif style == "glitch" then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hp = hum and math.clamp(hum.Health/hum.MaxHealth, 0, 1) or 1
        local rnd = ((offset or 0) + math.sin(t*7)) % 1
        local rgb = rnd > 0.82 or hp < 0.35
        hl.FillTransparency = 0.35; hl.OutlineTransparency = 0
        hl.FillColor = rgb and Color3.fromRGB(0,255,255) or c1
        hl.OutlineColor = rgb and Color3.fromRGB(255,70,90) or Color3.new(1,1,1)
    elseif style == "cyber" then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hp = hum and math.clamp(hum.Health/hum.MaxHealth, 0, 1) or 1
        local rate = 6 - hp*4
        local pulse = (math.sin(t*rate + (offset or 0)) + 1) / 2
        hl.FillTransparency = 0.6 - pulse*0.35; hl.OutlineTransparency = 0
        hl.FillColor = c1; hl.OutlineColor = c1:Lerp(c2, pulse)
    elseif style == "vertical" then
        hl.FillColor = c1; hl.OutlineColor = c2
        hl.FillTransparency = 0.25; hl.OutlineTransparency = 0
    elseif style == "pulse" then
        local band = (t % 1.8) / 1.8
        hl.FillTransparency = 0.35; hl.OutlineTransparency = 0
        hl.FillColor = Color3.new(1,1,1):Lerp(c1, band)
        hl.OutlineColor = c1:Lerp(c2, band)
    elseif style == "noise" then
        local r = ((offset or 0) + math.floor(t*28)) % 1
        local flick = r < 0.45
        hl.FillTransparency = flick and 0.5 or 0.2; hl.OutlineTransparency = 0
        hl.FillColor = flick and c1 or Color3.new(1,1,1)
        hl.OutlineColor = flick and Color3.new(1,1,1) or c2
    elseif style == "scan" then
        local s = ((t*1.2 + (offset or 0)*0.01) % 1)
        local wave = s < 0.18
        hl.FillTransparency = 0.4; hl.OutlineTransparency = 0
        hl.FillColor = wave and Color3.new(1,1,1) or c1
        hl.OutlineColor = wave and c2 or Color3.new(1,1,1)
    else
        hl.FillTransparency = 0.1; hl.OutlineTransparency = 0
        hl.FillColor = c1:Lerp(c2, mix); hl.OutlineColor = c2:Lerp(c1, mix)
    end
end

local function removePlayerCham(char)
    if not char then return end
    local hl = char:FindFirstChild("LunaciCham")
    if hl then hl:Destroy() end
end

local function getOrbs(p)
    if not orbHud[p] then
        local cs = {}
        for i = 1, 12 do
            local c = Drawing.new("Circle")
            c.NumSides = 12; c.Thickness = 1.5; c.Filled = false; c.Visible = false
            cs[i] = c
        end
        orbHud[p] = cs
    end
    return orbHud[p]
end
local function updateOrbs(t)
    for _, p in pairs(Players:GetPlayers()) do
        if IsEnemy(p) then
            local char = p.Character
            local cs = getOrbs(p)
            if char and char:FindFirstChild("HumanoidRootPart") then
                local chest = char.HumanoidRootPart.Position + Vector3.new(0, 1.1, 0)
                local count = math.clamp(Settings.ChamOrbCount or 8, 2, 12)
                for k = 1, count do
                    local ang = t*2.2 + (k-1) * (2*math.pi/count)
                    local off = Vector3.new(math.cos(ang)*1.8, math.sin(ang*2)*0.4, math.sin(ang)*1.8)
                    local vp, on = camera:WorldToViewportPoint(chest + off)
                    local dist = (camera.CFrame.Position - (chest + off)).Magnitude
                    cs[k].Visible = on
                    cs[k].Position = Vector2.new(vp.X, vp.Y)
                    cs[k].Radius = math.clamp(1200/math.max(dist,1), 3, 14)
                    cs[k].Color = Accent
                end
                for k = count+1, 12 do cs[k].Visible = false end
            else
                for _, c in pairs(cs) do c.Visible = false end
            end
        end
    end
end
local function hideOrbs()
    for _, cs in pairs(orbHud) do
        for _, c in pairs(cs) do c.Visible = false end
    end
end

LunaConnect(Players.PlayerRemoving, function(p)
    local cs = orbHud[p]
    if cs then
        for _, c in pairs(cs) do c:Remove() end
        orbHud[p] = nil
    end
end)

local chamsLast = 0
LunaConnect(RunService.RenderStepped, function()
    if not IsLoggedIn then return end
    local now = os.clock()
    if now - chamsLast < 1/30 then return end
    chamsLast = now
    local t = now
    local mode = playerChamMode()
    for _, p in pairs(Players:GetPlayers()) do
        if IsEnemy(p) then
            local char = p.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if char and hum and hum.Health > 0 then
                if mode then
                    applyPlayerCham(char, mode, t, p.UserId)
                else
                    removePlayerCham(char)
                end
            elseif char then
                removePlayerCham(char)
            end
        else
            local tc = p.Character
            if tc then removePlayerCham(tc) end
        end
    end

    if mode and Settings.ChamOrbs then updateOrbs(t) else hideOrbs() end

    if Settings.ChamWeapon and lplr.Character then
        local tool = lplr.Character:FindFirstChildOfClass("Tool")
        if tool then
            local hl = tool:FindFirstChild("LunaciWpn")
            if not hl then
                hl = Instance.new("Highlight", tool); hl.Name = "LunaciWpn"
            end
            hl.FillColor = Accent; hl.OutlineColor = Color3.new(1,1,1)
            hl.FillTransparency = 0.4; hl.OutlineTransparency = 0
            if Settings.ChamHolo then
                hl.FillColor = Accent:Lerp(Color3.new(1,1,1), (math.sin(t*3.5)+1)/2)
            end
        end
    end

    if Settings.SelfChams and lplr.Character then
        local me = lplr.Character
        local meh = me:FindFirstChildOfClass("Humanoid")
        if meh and meh.Health > 0 and mode then
            applyPlayerCham(me, mode, t, 9999)
        end
    end
end)
end

-- ============================================================
-- GC
-- ============================================================
task.spawn(function()
    while not UNLOADED do
        task.wait(30)
        pcall(function()
            if collectgarbage then collectgarbage() end
        end)
    end
end)

-- ============================================================
-- BOOT LOG
-- ============================================================
print("[LUNACI] V26.6 loaded. Avatar + night sky + config keybinds ready.")