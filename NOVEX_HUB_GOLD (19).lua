-- NOVEX HUB 5.0 GOLD | ARQUIVO UNICO: MENU + COMANDOS GOLD + PAINEL VIVO
-- visual estilo Novoline + fotos + comandos estilo Infinite Yield | feito para celular (Delta)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

------------------------------------------------------------------
-- Onde colocar a interface
------------------------------------------------------------------
local function getParent()
  local candidates = {}
  if type(gethui) == "function" then
    local ok, r = pcall(gethui)
    if ok and r then table.insert(candidates, r) end
  end
  local okCore, core = pcall(function() return game:GetService("CoreGui") end)
  if okCore and core then table.insert(candidates, core) end
  table.insert(candidates, PlayerGui)
  for _, p in ipairs(candidates) do
    local ok = pcall(function()
      local t = Instance.new("Folder")
      t.Parent = p
      t:Destroy()
    end)
    if ok then return p end
  end
  return PlayerGui
end

local Parent = getParent()

for _, p in ipairs({ Parent, PlayerGui }) do
  pcall(function()
    local previous = p:FindFirstChild("NOVEX")
    if previous then previous:Destroy() end
  end)
end

------------------------------------------------------------------
-- Cores e funções de ajuda
------------------------------------------------------------------
local C = {
  panel = Color3.fromRGB(14, 9, 30),
  card = Color3.fromRGB(30, 19, 60),
  card2 = Color3.fromRGB(58, 36, 104),
  white = Color3.fromRGB(244, 246, 252),
  gray = Color3.fromRGB(170, 160, 205),
  blue = Color3.fromRGB(0, 229, 255),
  blue2 = Color3.fromRGB(146, 66, 255),
  purple = Color3.fromRGB(255, 58, 212),
  green = Color3.fromRGB(0, 255, 140),
  red = Color3.fromRGB(255, 48, 92),
  orange = Color3.fromRGB(255, 196, 40),
  gold = Color3.fromRGB(255, 205, 64),
  gold2 = Color3.fromRGB(255, 142, 38),
  black = Color3.fromRGB(8, 9, 13),
}

local GOTHAM, BOLD, BLACK = Enum.Font.Gotham, Enum.Font.GothamBold, Enum.Font.GothamBlack
local LEFT, CENTER, RIGHT = Enum.TextXAlignment.Left, Enum.TextXAlignment.Center, Enum.TextXAlignment.Right
local CROP = Enum.ScaleType.Crop

local function create(class, props, parent)
  local obj = Instance.new(class)
  for k, v in pairs(props or {}) do obj[k] = v end
  obj.Parent = parent
  return obj
end

local function corner(obj, r)
  create("UICorner", { CornerRadius = UDim.new(0, r or 12) }, obj)
end

local function stroke(obj, color, transparency, thickness)
  return create("UIStroke", {
    Color = color or C.white,
    Transparency = transparency or 0.88,
    Thickness = thickness or 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
  }, obj)
end

local function label(parent, text, x, y, w, h, color, font, size, align)
  return create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(x, y),
    Size = UDim2.fromOffset(w, h),
    Text = text,
    TextColor3 = color or C.white,
    TextSize = size or 12,
    Font = font or GOTHAM,
    TextXAlignment = align or LEFT,
    TextYAlignment = Enum.TextYAlignment.Center,
    TextWrapped = true,
  }, parent)
end

local function line(parent, text, x, y, w, h, color, font, size, align)
  local l = label(parent, text, x, y, w, h, color, font, size, align)
  l.TextWrapped = false
  l.TextTruncate = Enum.TextTruncate.AtEnd
  return l
end

local function button(parent, text, x, y, w, h, bg, size, textColor)
  local b = create("TextButton", {
    Position = UDim2.fromOffset(x, y),
    Size = UDim2.fromOffset(w, h),
    BackgroundColor3 = bg or C.card2,
    Text = text,
    TextColor3 = textColor or C.white,
    TextSize = size or 12,
    Font = BOLD,
    AutoButtonColor = true,
    BorderSizePixel = 0,
  }, parent)
  corner(b, math.floor(h / 2))
  return b
end

local function panel(parent, x, y, w, h, r)
  local f = create("Frame", {
    Position = UDim2.fromOffset(x, y),
    Size = UDim2.fromOffset(w, h),
    BackgroundColor3 = C.panel,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Active = true,
  }, parent)
  corner(f, r or 22)

  -- Borda com brilho de vidro no topo de cada widget
  local st = stroke(f, C.white, 0.75, 1.3)
  create("UIGradient", {
    Rotation = 90,
    Transparency = NumberSequence.new({
      NumberSequenceKeypoint.new(0, 0.1),
      NumberSequenceKeypoint.new(0.45, 0.85),
      NumberSequenceKeypoint.new(1, 0.95)
    })
  }, st)

  -- Luz ambiente azulada bem sutil no topo
  local glow = create("Frame", {
    Size = UDim2.new(1, 0, 0, 55),
    BackgroundColor3 = C.blue,
    BackgroundTransparency = 0.92,
    BorderSizePixel = 0,
    ZIndex = 0,
  }, f)
  corner(glow, r or 22)
  create("UIGradient", {
    Rotation = 90,
    Transparency = NumberSequence.new({
      NumberSequenceKeypoint.new(0, 0),
      NumberSequenceKeypoint.new(1, 1)
    })
  }, glow)

  return f
end

local function scroller(parent, x, y, w, h, horizontal)
  return create("ScrollingFrame", {
    Position = UDim2.fromOffset(x, y),
    Size = UDim2.fromOffset(w, h),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Active = true,
    ScrollingEnabled = true,
    ScrollingDirection = horizontal and Enum.ScrollingDirection.X or Enum.ScrollingDirection.Y,
    ScrollBarThickness = horizontal and 0 or 3,
    ScrollBarImageColor3 = C.blue,
    ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
    AutomaticCanvasSize = horizontal and Enum.AutomaticSize.X or Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(),
    ClipsDescendants = true,
  }, parent)
end

local function vlist(parent, pad)
  return create("UIListLayout", { Padding = UDim.new(0, pad or 6), SortOrder = Enum.SortOrder.LayoutOrder }, parent)
end

local function statBox(parent, x, y, w, h, name)
  local f = create("Frame", {
    Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h),
    BackgroundColor3 = C.card, BackgroundTransparency = 0.25, BorderSizePixel = 0,
  }, parent)
  corner(f, 14)
  local vy = math.floor((h - 36) / 2)
  local v = line(f, "--", 0, vy, w, 22, C.white, BLACK, 15, CENTER)
  line(f, name, 0, vy + 22, w, 14, C.gray, GOTHAM, 10, CENTER)
  return v
end

local function statText(parent, x, y, w, name)
  local v = line(parent, "--", x, y, w, 22, C.white, BLACK, 16)
  line(parent, name, x, y + 22, w, 14, C.gray, GOTHAM, 10)
  return v
end

local function makeSwitch(parent, x, y, default, cb, auto)
  local track = create("TextButton", {
    Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(46, 26),
    BackgroundColor3 = default and C.blue2 or C.card2,
    Text = "", AutoButtonColor = false, BorderSizePixel = 0,
  }, parent)
  corner(track, 13)
  local knob = create("Frame", {
    Size = UDim2.fromOffset(20, 20),
    Position = default and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
    BackgroundColor3 = C.white, BorderSizePixel = 0,
  }, track)
  corner(knob, 10)
  local sw = { value = default and true or false }
  function sw.set(v)
    sw.value = v and true or false
    TweenService:Create(knob, TweenInfo.new(0.12),
      { Position = sw.value and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3) }):Play()
    track.BackgroundColor3 = sw.value and C.blue2 or C.card2
  end
  track.MouseButton1Click:Connect(function()
    local v = not sw.value
    if auto then sw.set(v) end
    if cb then cb(v) end
  end)
  return sw
end

local function fmt(n)
  n = tonumber(n) or 0
  if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
  if n >= 1000 then return string.format("%.1fK", n / 1000) end
  return tostring(math.floor(n))
end

local function hueFor(s)
  s = tostring(s or "x")
  local h = 0
  for i = 1, #s do h = (h * 31 + string.byte(s, i)) % 360 end
  return h / 360
end

local function copyText(text)
  local fn = setclipboard or toclipboard
  if fn then return (pcall(fn, text)) end
  return false
end

local function avatarUrl(userId)
  return string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", tonumber(userId) or 1)
end

local function enc(t) return HttpService:UrlEncode(tostring(t)) end

-- imagem de capa com sombra embaixo (estilo Novoline)
local function cover(parent, r)
  local img = create("ImageLabel", {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScaleType = CROP, ZIndex = 1,
  }, parent)
  corner(img, r)
  local sh = create("Frame", {
    Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 2,
  }, parent)
  corner(sh, r)
  create("UIGradient", {
    Rotation = 90,
    Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.05) }),
  }, sh)
  return img
end

------------------------------------------------------------------
-- Dados salvos no celular
------------------------------------------------------------------
local DATA_FILE = "NOVEX_dados.json"
local DATA = {
  scriptFavs = {},
  cmdFavs = {},
  music = {},
  binds = {},
  autorun = {},
  settings = { confirmRun = true, rscriptsKey = "", guiScale = 1, theme = "ouro", aiKey = "", aiAlerts = true, aiAuto = false },
}

local function saveData()
  if writefile then
    pcall(function() writefile(DATA_FILE, HttpService:JSONEncode(DATA)) end)
  end
end

if isfile and readfile then
  pcall(function()
    if isfile(DATA_FILE) then
      local d = HttpService:JSONDecode(readfile(DATA_FILE))
      if type(d) == "table" then
        DATA.scriptFavs = d.scriptFavs or {}
        DATA.cmdFavs = d.cmdFavs or {}
        DATA.music = d.music or {}
        DATA.binds = d.binds or {}
        DATA.autorun = d.autorun or {}
        for k, v in pairs(d.settings or {}) do DATA.settings[k] = v end
      end
    end
  end)
end

------------------------------------------------------------------
-- Temas de cores (muda com a aba Configurações > Geral)
------------------------------------------------------------------
local THEMES = {
  ouro = {
    panel = Color3.fromRGB(15, 11, 6), card = Color3.fromRGB(32, 24, 12), card2 = Color3.fromRGB(66, 48, 20),
    gray = Color3.fromRGB(196, 180, 142), blue = Color3.fromRGB(255, 196, 56), blue2 = Color3.fromRGB(222, 142, 16),
    purple = Color3.fromRGB(255, 150, 60), green = Color3.fromRGB(110, 255, 150), red = Color3.fromRGB(255, 72, 72),
    orange = Color3.fromRGB(255, 176, 40), gold = Color3.fromRGB(255, 214, 90), gold2 = Color3.fromRGB(255, 150, 40),
    black = Color3.fromRGB(9, 7, 4),
  },
  roxo = {
    panel = Color3.fromRGB(14, 9, 30), card = Color3.fromRGB(30, 19, 60), card2 = Color3.fromRGB(58, 36, 104),
    gray = Color3.fromRGB(170, 160, 205), blue = Color3.fromRGB(0, 229, 255), blue2 = Color3.fromRGB(146, 66, 255),
    purple = Color3.fromRGB(255, 58, 212), green = Color3.fromRGB(0, 255, 140), red = Color3.fromRGB(255, 48, 92),
    orange = Color3.fromRGB(255, 196, 40), gold = Color3.fromRGB(255, 205, 64), gold2 = Color3.fromRGB(255, 142, 38),
    black = Color3.fromRGB(8, 9, 13),
  },
  azul = {
    panel = Color3.fromRGB(12, 14, 25), card = Color3.fromRGB(22, 25, 43), card2 = Color3.fromRGB(38, 43, 70),
    gray = Color3.fromRGB(138, 146, 168), blue = Color3.fromRGB(0, 200, 255), blue2 = Color3.fromRGB(112, 72, 255),
    purple = Color3.fromRGB(205, 75, 255), green = Color3.fromRGB(0, 245, 160), red = Color3.fromRGB(255, 65, 105),
    orange = Color3.fromRGB(255, 175, 65), gold = Color3.fromRGB(255, 205, 80), gold2 = Color3.fromRGB(255, 160, 50),
    black = Color3.fromRGB(8, 9, 13),
  },
}
do
  local escolhido = THEMES[DATA.settings.theme or "ouro"] or THEMES.ouro
  for k, v in pairs(escolhido) do C[k] = v end
end

------------------------------------------------------------------
-- Internet
------------------------------------------------------------------
local HTTPERR = { msg = nil } -- motivo do último erro de download (usado pela IA)
local function httpGet(url, headers, raw)
  local funcs = {}
  if type(request) == "function" then table.insert(funcs, request) end
  if type(http_request) == "function" then table.insert(funcs, http_request) end
  if type(syn) == "table" and type(syn.request) == "function" then table.insert(funcs, syn.request) end

  local h = { ["Accept"] = raw and "*/*" or "application/json, text/plain, */*" }
  for k, v in pairs(headers or {}) do h[k] = v end

  local lastErr = "sem resposta"
  for _, fn in ipairs(funcs) do
    local ok, res = pcall(fn, { Url = url, Method = "GET", Headers = h })
    if ok and res then
      local body = res.Body or res.body
      local status = tonumber(res.StatusCode or res.Status) or 200
      if body and status >= 200 and status < 300 then return body end
      lastErr = "HTTP " .. tostring(status)
    elseif not ok then
      lastErr = tostring(res)
    end
  end

  if not headers then
    local ok, result = pcall(function() return game:HttpGet(url) end)
    if ok then return result end
    lastErr = tostring(result)
  end
  HTTPERR.msg = lastErr
  return nil, lastErr
end

local function api(url, headers)
  local body, err = httpGet(url, headers)
  if not body then return nil, err end
  local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
  if not ok then return nil, "Resposta inválida da API" end
  return data
end

------------------------------------------------------------------
-- Fotos da internet (baixa, guarda no celular e mostra)
------------------------------------------------------------------
local IMG_DIR = "NOVEX_img"
local assetFn = getcustomasset or getsynasset
local imgCache, imgWait, activeDl, iconUrlCache = {}, {}, 0, {}

local function hashName(s)
  local h1, h2 = 5381, 7
  for i = 1, #s do
    local b = string.byte(s, i)
    h1 = (h1 * 33 + b) % 4294967296
    h2 = (h2 * 131 + b) % 4294967296
  end
  return string.format("%08x%08x", h1, h2)
end

-- o Roblox só mostra PNG e JPEG (webp não funciona)
local function imgKind(body)
  if string.sub(body, 1, 4) == "\137PNG" then return "png" end
  if string.byte(body, 1) == 255 and string.byte(body, 2) == 216 then return "jpg" end
  return nil
end

local function getImageAsset(url, cb)
  if not url or not assetFn or not writefile then cb(nil) return end
  if imgCache[url] ~= nil then cb(imgCache[url] or nil) return end
  if imgWait[url] then table.insert(imgWait[url], cb) return end
  imgWait[url] = { cb }
  task.spawn(function()
    while activeDl >= 3 do task.wait(0.1) end
    activeDl = activeDl + 1
    local result = false
    pcall(function()
      if makefolder and isfolder and not isfolder(IMG_DIR) then makefolder(IMG_DIR) end
      local base = IMG_DIR .. "/" .. hashName(url)
      local path
      if isfile then
        if isfile(base .. ".png") then path = base .. ".png"
        elseif isfile(base .. ".jpg") then path = base .. ".jpg" end
      end
      if not path then
        local body = httpGet(url, nil, true)
        local kind = body and #body > 100 and imgKind(body)
        if not kind then error("formato não suportado") end
        path = base .. "." .. kind
        writefile(path, body)
      end
      result = assetFn(path)
    end)
    activeDl = activeDl - 1
    imgCache[url] = result
    local list = imgWait[url]
    imgWait[url] = nil
    for _, f in ipairs(list or {}) do pcall(f, result or nil) end
  end)
end

-- ícone do jogo pelo Roblox (sempre PNG)
local function placeIconUrl(placeId, cb)
  placeId = tostring(placeId or "")
  if placeId == "" or not tonumber(placeId) then cb(nil) return end
  if iconUrlCache[placeId] ~= nil then cb(iconUrlCache[placeId] or nil) return end
  task.spawn(function()
    local data = api("https://thumbnails.roblox.com/v1/places/gameicons?placeIds=" .. placeId ..
      "&returnPolicy=PlaceHolder&size=256x256&format=Png&isCircular=false")
    local u = data and data.data and data.data[1] and data.data[1].imageUrl
    iconUrlCache[placeId] = u or false
    cb(u)
  end)
end

-- tenta as fotos do script; se não der, usa o ícone do jogo
local function loadPicture(img, item, valid)
  if not assetFn or not writefile then return end
  local urls = item.imgs or {}
  local i = 0
  local function apply(a)
    if a and img.Parent and (not valid or valid()) then img.Image = a end
  end
  local function nextTry()
    i = i + 1
    local u = urls[i]
    if u then
      getImageAsset(u, function(a) if a then apply(a) else nextTry() end end)
    elseif item.placeId then
      placeIconUrl(item.placeId, function(iu)
        if iu then getImageAsset(iu, apply) end
      end)
    end
  end
  nextTry()
end


------------------------------------------------------------------
-- Estrutura: tela escura + área do menu + pastilha do topo
------------------------------------------------------------------
local X = { tick = {} } -- funções compartilhadas entre as seções
local CW, CH = 1170, 540

local GUI = create("ScreenGui", {
  Name = "NOVEX", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 100,
  ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, Parent)

local Shell = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, GUI)
create("Frame", {
  Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
  BackgroundTransparency = 0.5, BorderSizePixel = 0,
}, Shell)

local Root = create("Frame", {
  AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
  Size = UDim2.fromOffset(CW, CH), BackgroundTransparency = 1, ZIndex = 2,
}, Shell)

local Scale = create("UIScale", { Scale = 1 }, Root)

local function resize()
  local camera = workspace.CurrentCamera
  if not camera then return end
  local v = camera.ViewportSize
  local mul = tonumber(DATA.settings.guiScale) or 1
  Scale.Scale = math.clamp(math.min(v.X / CW, v.Y / CH) * mul, 0.3, 2)
end
resize()
if workspace.CurrentCamera then
  workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
end

-- Pastilha do topo: abre e fecha o menu
local Pill = create("TextButton", {
  AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 12),
  Size = UDim2.fromOffset(160, 36), BackgroundColor3 = C.black, BackgroundTransparency = 0.05,
  Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 50,
}, GUI)
corner(Pill, 18)
stroke(Pill, C.white, 0.8)
label(Pill, "▲", 14, 0, 26, 36, C.gold, BLACK, 18, CENTER).ZIndex = 51
label(Pill, "NOVEX", 44, 0, 104, 36, C.white, BOLD, 17).ZIndex = 51
do
    local function toque(i)
        return i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1
    end

    local function arrastavel(alvo, alca, aoClicar)
        local arrastando, moveu, inicio, pos, abs0 = false, false, nil, nil, nil
        alca.InputBegan:Connect(function(i)
            if toque(i) then
                arrastando, moveu = true, false
                inicio, pos, abs0 = i.Position, alvo.Position, alvo.AbsolutePosition
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if arrastando and (i.UserInputType == Enum.UserInputType.Touch
                or i.UserInputType == Enum.UserInputType.MouseMovement) then
                local d = i.Position - inicio
                if d.Magnitude > 7 then moveu = true end
                if moveu then
                    local pai = alvo.Parent
                    local dx, dy = d.X, d.Y
                    if pai and pai:IsA("GuiBase2d") then
                        local pp, ps, s = pai.AbsolutePosition, pai.AbsoluteSize, alvo.AbsoluteSize
                        local nx = math.clamp(abs0.X + dx, pp.X, math.max(pp.X, pp.X + ps.X - s.X))
                        local ny = math.clamp(abs0.Y + dy, pp.Y, math.max(pp.Y, pp.Y + ps.Y - s.Y))
                        dx, dy = nx - abs0.X, ny - abs0.Y
                    end
                    alvo.Position = UDim2.new(pos.X.Scale, pos.X.Offset + dx, pos.Y.Scale, pos.Y.Offset + dy)
                end
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if toque(i) then arrastando = false end
        end)
        if aoClicar then
            alca.MouseButton1Click:Connect(function()
                if not moveu then aoClicar() end
            end)
        end
    end

    -- Pastilha compacta e movel.
    pcall(function()
        for _, f in ipairs(Pill:GetChildren()) do
            if f:IsA("TextLabel") then
                if f.Text == "▲" then
                    f.Position, f.Size, f.TextSize = UDim2.fromOffset(7, 0), UDim2.fromOffset(22, 28), 14
                elseif f.Text == "NOVEX" then
                    f.Position, f.Size, f.TextSize = UDim2.fromOffset(30, 0), UDim2.fromOffset(76, 28), 14
                end
            end
        end
        Pill.Size = UDim2.fromOffset(110, 28)
        Pill.Position = UDim2.new(0.5, 0, 0, 7)
        Pill.BackgroundTransparency = 0.12
        local cr = Pill:FindFirstChildOfClass("UICorner")
        if cr then cr.CornerRadius = UDim.new(0, 14) end
    end)
    arrastavel(Pill, Pill, function() Shell.Visible = not Shell.Visible end)

    -- Brilho animado da borda.
    task.spawn(function()
        local h = 0
        while GUI.Parent do
            h = (h + 0.004) % 1
            local st = Pill:FindFirstChildOfClass("UIStroke")
            if st then st.Color = Color3.fromHSV(h, 0.78, 1) end
            task.wait(0.035)
        end
    end)

    local function dataPt()
        local dias = {"domingo", "segunda-feira", "terça-feira", "quarta-feira", "quinta-feira", "sexta-feira", "sábado"}
        local meses = {"janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"}
        local t = os.date("*t")
        return string.format("%s, %02d de %s de %04d", dias[t.wday] or "dia", t.day, meses[t.month] or "", t.year)
    end

    local okExtra, erroExtra = pcall(function()
        local fps, ping, jogo = 0, 0, game.Name
        local frames, ultimo = 0, os.clock()
        local infoLigada = true

        local Info = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, 5),
            Size = UDim2.fromOffset(300, 66), BackgroundColor3 = C.black,
            BackgroundTransparency = 0.18, BorderSizePixel = 0, ZIndex = 55, Visible = false,
        }, Pill)
        corner(Info, 13)
        stroke(Info, C.blue, 0.25, 1.2)
        local nomeLbl = line(Info, "🎮 " .. jogo, 9, 4, 282, 15, C.white, BOLD, 10, CENTER)
        local dataLbl = line(Info, dataPt(), 9, 20, 282, 14, C.gray, GOTHAM, 9, CENTER)
        local statLbl = line(Info, "", 7, 36, 286, 14, C.white, BOLD, 9, CENTER)
        local servLbl = line(Info, "", 7, 50, 286, 12, C.gray, GOTHAM, 8, CENTER)

        task.spawn(function()
            local okInfo, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
            if okInfo and info and info.Name then
                jogo = info.Name
                nomeLbl.Text = "🎮 " .. jogo
            end
        end)

        RunService.RenderStepped:Connect(function() frames = frames + 1 end)
        task.spawn(function()
            while GUI.Parent do
                task.wait(1)
                local agora = os.clock()
                fps = math.floor(frames / math.max(agora - ultimo, 0.01) + 0.5)
                frames, ultimo = 0, agora
                pcall(function()
                    ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                dataLbl.Text = dataPt() .. " • " .. os.date("%H:%M:%S")
                statLbl.Text = string.format("%d FPS   •   %d ms   •   %d/%d jogadores",
                    fps, ping, #Players:GetPlayers(), Players.MaxPlayers)
                servLbl.Text = "PlaceId: " .. tostring(game.PlaceId) .. "   •   Servidor: " .. tostring(game.JobId):sub(1, 10)
            end
        end)


        local function sincroniza()
            Info.Visible = infoLigada and Shell.Visible
        end
        Shell:GetPropertyChangedSignal("Visible"):Connect(sincroniza)
        sincroniza()
    end)
    if not okExtra then warn("NOVEX LOADER extras: " .. tostring(erroExtra)) end
end

local keyConn = UIS.InputBegan:Connect(function(input, processed)
  if processed then return end
  if input.KeyCode == Enum.KeyCode.K then Shell.Visible = not Shell.Visible end
end)
GUI.Destroying:Connect(function() keyConn:Disconnect() end)

-- Seu rosto no meio de cima
local Ring = create("ImageLabel", {
  Position = UDim2.fromOffset(551, 88), Size = UDim2.fromOffset(68, 68),
  BackgroundColor3 = C.card, BorderSizePixel = 0, Image = avatarUrl(Player.UserId),
}, Root)
corner(Ring, 34)
stroke(Ring, C.blue, 0, 3)

-- Aviso rápido
local Toast = create("TextLabel", {
  AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromOffset(CW / 2, 164),
  Size = UDim2.fromOffset(360, 32), BackgroundColor3 = C.black,
  BackgroundTransparency = 1, TextTransparency = 1, Text = "", TextColor3 = C.white,
  TextSize = 13, Font = BOLD, BorderSizePixel = 0, ZIndex = 40,
}, Root)
corner(Toast, 16)

local toastId = 0
local function toast(msg, color)
  toastId = toastId + 1
  local id = toastId
  Toast.Text = msg
  Toast.TextColor3 = color or C.white
  TweenService:Create(Toast, TweenInfo.new(0.2), { BackgroundTransparency = 0.1, TextTransparency = 0 }):Play()
  task.delay(2.8, function()
    if id == toastId and Toast.Parent then
      TweenService:Create(Toast, TweenInfo.new(0.3), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
    end
  end)
end

-- Título da página + páginas
local Pages, pageHooks = {}, {}
local TitleLbl = line(Root, "Home", 93, 22, 400, 34, C.gold, BLACK, 24)
local SubLbl = line(Root, "", 94, 58, 400, 18, C.gray, GOTHAM, 12)

for _, n in ipairs({ "Home", "Cmds", "Players", "Music", "Scripts", "AI", "Settings" }) do
  Pages[n] = create("Frame", {
    Size = UDim2.fromOffset(CW, CH), BackgroundTransparency = 1, Visible = false,
  }, Root)
end

------------------------------------------------------------------
-- BLOCO A: ações de servidor
------------------------------------------------------------------
do
  function X.doCopy(text, okMsg)
    if copyText(text) then toast(okMsg, C.green) else toast("Seu executor não deixa copiar.", C.red) end
  end

  function X.rejoin()
    toast("Reentrando no servidor...", C.blue)
    pcall(function()
      if #Players:GetPlayers() <= 1 then
        Player:Kick("\nReentrando...")
        task.wait()
        TeleportService:Teleport(game.PlaceId, Player)
      else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
      end
    end)
  end

  -- vai pro servidor com menos ms (usa o ping que a lista de servidores do Roblox informa).
  -- Obs.: o Roblox não deixa filtrar por região; servidor com jogadores brasileiros tende a dar menos ms pra você.
  function X.melhorServer(args)
    local soVer, posicao = false, 1
    for _, a in ipairs(args or {}) do
      local t = string.lower(tostring(a))
      if t == "ver" or t == "lista" or t == "list" then soVer = true
      elseif tonumber(t) then posicao = math.max(1, math.floor(tonumber(t))) end
    end
    toast("Procurando servidor com menos ms...", C.blue)
    task.spawn(function()
      local achados, cursor = {}, nil
      for _ = 1, 3 do
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId ..
          "/servers/Public?sortOrder=Desc&excludeFullGames=true&limit=100" .. (cursor and ("&cursor=" .. cursor) or "")
        local data = api(url)
        if not (data and data.data) then break end
        for _, sv in ipairs(data.data) do
          if sv.id ~= game.JobId and sv.ping and sv.ping > 0 and sv.playing and sv.maxPlayers and sv.playing < sv.maxPlayers then
            table.insert(achados, sv)
          end
        end
        cursor = data.nextPageCursor
        if not cursor then break end
      end
      if #achados == 0 then
        toast("Não achei servidor com ping informado. Tente de novo ou use serverhop.", C.red)
        return
      end
      table.sort(achados, function(a, b) return a.ping < b.ping end)
      if soVer then
        local linhas = {}
        for i = 1, math.min(5, #achados) do
          local sv = achados[i]
          table.insert(linhas, i .. ") " .. math.floor(sv.ping) .. "ms  " .. sv.playing .. "/" .. sv.maxPlayers)
        end
        toast(table.concat(linhas, "  |  "), C.green)
        return
      end
      local sv = achados[math.min(posicao, #achados)]
      toast("Indo pro servidor de " .. math.floor(sv.ping) .. "ms (" .. sv.playing .. "/" .. sv.maxPlayers .. " jogadores)", C.green)
      pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, sv.id, Player) end)
    end)
  end

  function X.serverHop()
    toast("Procurando outro servidor...", C.blue)
    task.spawn(function()
      local data = api("https://games.roblox.com/v1/games/" .. game.PlaceId ..
        "/servers/Public?sortOrder=Asc&limit=100")
      if data and data.data then
        for _, s in ipairs(data.data) do
          if s.id ~= game.JobId and s.playing and s.maxPlayers and s.playing < s.maxPlayers then
            pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player) end)
            return
          end
        end
      end
      toast("Nenhum servidor encontrado.", C.red)
    end)
  end
end


------------------------------------------------------------------
-- BLOCO B: motor dos comandos (estilo Infinite Yield / Novoline)
------------------------------------------------------------------
do
  local StarterGui = game:GetService("StarterGui")
  local Cfg = { flySpeed = 60, walkSpeed = nil, jumpPower = nil, fov = nil, animSpeed = nil }
  local Cmds, CmdByName, Alias, OffAlias, recent = {}, {}, {}, {}, {}
  local loopGen = 0
  local waypoints = {}
  local espData = {}
  local savedLight = {}
  local runLine

  local function fail(msg) error(msg, 0) end

  local function hum()
    local c = Player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
  end

  local function root()
    local c = Player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
  end

  local function track(cmd, conn)
    table.insert(cmd.conns, conn)
    return conn
  end

  local function unbind(cmd)
    for _, c in ipairs(cmd.conns) do pcall(function() c:Disconnect() end) end
    cmd.conns = {}
  end

  -- opt: arg = texto de ajuda do argumento, need = precisa de argumento, alias = { apelidos }, exact = não aceitar abreviação
  local function addCmd(name, desc, cat, isToggle, fn, opt)
    opt = opt or {}
    local def = {
      name = name, desc = desc, cat = cat, toggle = isToggle, fn = fn, state = false,
      syncs = {}, conns = {}, arg = opt.arg, need = opt.need, exact = opt.exact,
    }
    table.insert(Cmds, def)
    CmdByName[name] = def
    for _, a in ipairs(opt.alias or {}) do Alias[a] = name end
    return def
  end

  local function setToggle(cmd, v, args)
    v = v and true or false
    local ok, err = pcall(cmd.fn, v, args)
    if ok then
      cmd.state = v
    else
      cmd.state = false
      pcall(cmd.fn, false)
      toast(cmd.name .. ": " .. string.sub(tostring(err), 1, 60), C.red)
    end
    for _, f in ipairs(cmd.syncs) do f(cmd.state) end
  end

  local function must(args, usage)
    local n = tonumber(args and args[1])
    if not n then fail("use: " .. usage) end
    return n
  end

  ---------------- jogadores / alvos ----------------
  local function findPlayer(str)
    if not str or str == "" then return nil end
    str = string.lower(str)
    local partial
    for _, p in ipairs(Players:GetPlayers()) do
      local n, d = string.lower(p.Name), string.lower(p.DisplayName)
      if n == str or d == str then return p end
      if not partial and (string.sub(n, 1, #str) == str or string.sub(d, 1, #str) == str) then partial = p end
    end
    return partial
  end

  -- alvos especiais: all, others, me, random, nearest, farthest, friends, team, enemies, @usuario, parte do nome
  local function getTargets(str)
    local list = {}
    str = string.lower(tostring(str or ""))
    if str == "" then return list end
    local others = {}
    for _, p in ipairs(Players:GetPlayers()) do
      if p ~= Player then table.insert(others, p) end
    end
    local r = root()
    local function dist(p)
      local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
      if r and pr then return (r.Position - pr.Position).Magnitude end
      return math.huge
    end
    if str == "all" then
      return Players:GetPlayers()
    elseif str == "others" then
      return others
    elseif str == "me" then
      return { Player }
    elseif str == "random" then
      if #others > 0 then list[1] = others[math.random(#others)] end
    elseif str == "nearest" or str == "farthest" then
      local best, bd
      for _, p in ipairs(others) do
        local d = dist(p)
        if d < math.huge and (not best or (str == "nearest" and d < bd) or (str == "farthest" and d > bd)) then
          best, bd = p, d
        end
      end
      if best then list[1] = best end
    elseif str == "friends" then
      for _, p in ipairs(others) do
        local ok, f = pcall(function() return Player:IsFriendsWith(p.UserId) end)
        if ok and f then table.insert(list, p) end
      end
    elseif str == "team" or str == "allies" then
      for _, p in ipairs(others) do
        if p.Team == Player.Team then table.insert(list, p) end
      end
    elseif str == "enemies" then
      for _, p in ipairs(others) do
        if p.Team ~= Player.Team then table.insert(list, p) end
      end
    elseif string.sub(str, 1, 1) == "@" then
      local n = string.sub(str, 2)
      for _, p in ipairs(Players:GetPlayers()) do
        if string.lower(p.Name) == n then list[1] = p break end
      end
    else
      local p = findPlayer(str)
      if p then list[1] = p end
    end
    return list
  end

  local function getTarget(str)
    local t = getTargets(str)[1]
    if not t then fail("jogador não encontrado") end
    return t
  end

  local function gotoPlayer(p)
    local r, tr = root(), p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if r and tr then
      r.CFrame = tr.CFrame * CFrame.new(0, 0, 3)
      return true
    end
    return false
  end

  local function viewPlayer(p)
    local cam = workspace.CurrentCamera
    local h = p and p.Character and p.Character:FindFirstChildOfClass("Humanoid")
    if cam and h then cam.CameraSubject = h return true end
    return false
  end

  local function unview()
    local cam, h = workspace.CurrentCamera, hum()
    if cam and h then cam.CameraSubject = h end
  end

  local function applyStats()
    local h = hum()
    if h then
      if Cfg.walkSpeed then h.WalkSpeed = Cfg.walkSpeed end
      if Cfg.jumpPower then h.UseJumpPower = true; h.JumpPower = Cfg.jumpPower end
    end
    if Cfg.fov and workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = Cfg.fov end
  end

  -- iluminação (guarda o original para poder voltar)
  local function lset(prop, v)
    if savedLight[prop] == nil then savedLight[prop] = Lighting[prop] end
    Lighting[prop] = v
  end
  local function lreset()
    for k, v in pairs(savedLight) do pcall(function() Lighting[k] = v end) end
    savedLight = {}
  end

  -- ================================================================
  -- MOVIMENTO
  -- ================================================================
  addCmd("fly", "Voe livremente. Ex: fly 80", "Movimento", true, function(on, args)
    local cmd = CmdByName.fly
    unbind(cmd)
    if cmd.bv then cmd.bv:Destroy() cmd.bv = nil end
    if cmd.bg then cmd.bg:Destroy() cmd.bg = nil end
    local h = hum()
    if h then h.PlatformStand = false end
    if not on then return end
    local sp = tonumber(args and args[1])
    if sp then Cfg.flySpeed = math.clamp(sp, 1, 500) end
    local r = root()
    if not r or not h then fail("sem personagem") end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.new()
    bv.Parent = r
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bg.P = 9e4
    bg.CFrame = r.CFrame
    bg.Parent = r
    cmd.bv, cmd.bg = bv, bg
    h.PlatformStand = true
    track(cmd, RunService.Heartbeat:Connect(function()
      local hh, cam = hum(), workspace.CurrentCamera
      if not hh or not cam or not bv.Parent then return end
      local mv = hh.MoveDirection
      local vel = Vector3.new()
      if mv.Magnitude > 0 then
        local look = cam.CFrame.LookVector
        local flat = Vector3.new(look.X, 0, look.Z)
        local fwd = flat.Magnitude > 0 and flat.Unit or Vector3.new()
        vel = mv * Cfg.flySpeed + Vector3.new(0, look.Y * Cfg.flySpeed * mv:Dot(fwd), 0)
      end
      if UIS:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, Cfg.flySpeed, 0) end
      if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0, Cfg.flySpeed, 0) end
      bv.Velocity = vel
      bg.CFrame = cam.CFrame
    end))
  end, { arg = "velocidade" })

  addCmd("noclip", "Atravesse paredes", "Movimento", true, function(on)
    local cmd = CmdByName.noclip
    unbind(cmd)
    if not on then return end
    track(cmd, RunService.Stepped:Connect(function()
      local c = Player.Character
      if c then
        for _, p in ipairs(c:GetDescendants()) do
          if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
      end
    end))
  end)
  OffAlias.clip = "noclip"

  local function platformCmd(name, desc, follow)
    addCmd(name, desc, "Movimento", true, function(on)
      local cmd = CmdByName[name]
      unbind(cmd)
      if cmd.part then cmd.part:Destroy() cmd.part = nil end
      if not on then return end
      local r, h = root(), hum()
      if not r or not h then fail("sem personagem") end
      local function feetY() return r.Position.Y - (h.HipHeight + r.Size.Y / 2) - 0.5 end
      local p = Instance.new("Part")
      p.Name = "NOVEX_Plataforma"
      p.Size = Vector3.new(8, 1, 8)
      p.Anchored = true
      p.Transparency = 1
      p.CFrame = CFrame.new(r.Position.X, feetY(), r.Position.Z)
      p.Parent = workspace
      cmd.part = p
      if follow then
        track(cmd, RunService.Heartbeat:Connect(function()
          local rr = root()
          if rr and p.Parent then p.CFrame = CFrame.new(rr.Position.X, feetY(), rr.Position.Z) end
        end))
      end
    end)
  end
  platformCmd("float", "Fique parado no ar onde está", false)
  platformCmd("airwalk", "Ande no ar", true)

  addCmd("infjump", "Pule de novo no ar", "Movimento", true, function(on)
    local cmd = CmdByName.infjump
    unbind(cmd)
    if not on then return end
    track(cmd, UIS.JumpRequest:Connect(function()
      local h = hum()
      if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end))
  end, { alias = { "infinitejump" } })

  addCmd("spin", "Girar o personagem. Ex: spin 30", "Movimento", true, function(on, args)
    local cmd = CmdByName.spin
    unbind(cmd)
    if not on then return end
    local sp = tonumber(args and args[1]) or 18
    track(cmd, RunService.Heartbeat:Connect(function()
      local r = root()
      if r then r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(sp), 0) end
    end))
  end, { arg = "graus" })

  addCmd("tpwalk", "Andar mais rápido por teleporte. Ex: tpwalk 2", "Movimento", true, function(on, args)
    local cmd = CmdByName.tpwalk
    unbind(cmd)
    if not on then return end
    local sp = tonumber(args and args[1]) or 1
    track(cmd, RunService.Heartbeat:Connect(function(dt)
      local h, c = hum(), Player.Character
      if h and c and h.MoveDirection.Magnitude > 0 then
        c:TranslateBy(h.MoveDirection * sp * dt * 10)
      end
    end))
  end, { arg = "n", alias = { "teleportwalk" } })

  addCmd("bhop", "Pula sozinho enquanto anda", "Movimento", true, function(on)
    local cmd = CmdByName.bhop
    unbind(cmd)
    if not on then return end
    track(cmd, RunService.Heartbeat:Connect(function()
      local h = hum()
      if h and h.MoveDirection.Magnitude > 0 and h.FloorMaterial ~= Enum.Material.Air then
        h:ChangeState(Enum.HumanoidStateType.Jumping)
      end
    end))
  end, { alias = { "bunnyhop" } })

  addCmd("clicktp", "Toque no chão para teleportar", "Movimento", true, function(on)
    local cmd = CmdByName.clicktp
    unbind(cmd)
    if not on then return end
    track(cmd, UIS.InputBegan:Connect(function(input, processed)
      if processed then return end
      if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
      local cam, r = workspace.CurrentCamera, root()
      if not cam or not r then return end
      local ray = cam:ViewportPointToRay(input.Position.X, input.Position.Y)
      local params = RaycastParams.new()
      params.FilterType = Enum.RaycastFilterType.Exclude
      params.FilterDescendantsInstances = { Player.Character }
      local res = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
      if res then r.CFrame = CFrame.new(res.Position + Vector3.new(0, 3, 0)) end
    end))
  end, { alias = { "ctp" } })

  addCmd("speed", "Velocidade. Ex: speed 50", "Movimento", false, function(args)
    Cfg.walkSpeed = math.clamp(must(args, "speed 50"), 0, 500)
    applyStats()
  end, { arg = "n", need = true, alias = { "ws", "walkspeed" } })

  addCmd("jump", "Pular, ou definir a força. Ex: jump 100", "Movimento", false, function(args)
    local n = tonumber(args and args[1])
    if n then
      Cfg.jumpPower = math.clamp(n, 0, 500)
      applyStats()
    else
      local h = hum()
      if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
  end, { arg = "n", alias = { "jp", "jumppower" } })

  addCmd("hipheight", "Altura do quadril. Ex: hipheight 5", "Movimento", false, function(args)
    local h = hum()
    if not h then fail("sem personagem") end
    h.HipHeight = must(args, "hipheight 5")
  end, { arg = "n", need = true, alias = { "hh" } })

  addCmd("flyspeed", "Velocidade do voo. Ex: flyspeed 100", "Movimento", false, function(args)
    Cfg.flySpeed = math.clamp(must(args, "flyspeed 100"), 1, 500)
  end, { arg = "n", need = true, alias = { "fs" } })

  addCmd("goto", "Ir até um jogador. Ex: goto nome", "Movimento", false, function(args)
    local p = getTarget(args and args[1])
    if not gotoPlayer(p) then fail("jogador sem personagem") end
  end, { arg = "jogador", need = true, alias = { "to" } })

  addCmd("tp", "Teleportar. Ex: tp 0 50 0", "Movimento", false, function(args)
    local x, y, z = tonumber(args and args[1]), tonumber(args and args[2]), tonumber(args and args[3])
    if not (x and y and z) then fail("use: tp 0 50 0") end
    local r = root()
    if not r then fail("sem personagem") end
    r.CFrame = CFrame.new(x, y, z)
  end, { arg = "x y z", need = true, alias = { "tppos" } })

  addCmd("up", "Subir alguns metros. Ex: up 20", "Movimento", false, function(args)
    local r = root()
    if not r then fail("sem personagem") end
    r.CFrame = r.CFrame + Vector3.new(0, tonumber(args and args[1]) or 10, 0)
  end, { arg = "n" })

  addCmd("down", "Descer alguns metros. Ex: down 20", "Movimento", false, function(args)
    local r = root()
    if not r then fail("sem personagem") end
    r.CFrame = r.CFrame - Vector3.new(0, tonumber(args and args[1]) or 10, 0)
  end, { arg = "n" })

  addCmd("follow", "Seguir um jogador. Ex: follow nome", "Movimento", true, function(on, args)
    local cmd = CmdByName.follow
    unbind(cmd)
    if not on then return end
    local target = getTarget(args and args[1])
    track(cmd, RunService.Heartbeat:Connect(function()
      local r, tr = root(), target.Character and target.Character:FindFirstChild("HumanoidRootPart")
      if r and tr then r.CFrame = tr.CFrame * CFrame.new(0, 0, 4) end
    end))
  end, { arg = "jogador", need = true, alias = { "loopgoto" } })

  addCmd("waypoint", "Salvar sua posição. Ex: waypoint casa", "Movimento", false, function(args)
    local r = root()
    if not r then fail("sem personagem") end
    local n = string.lower(args and args[1] or "ponto")
    waypoints[n] = r.CFrame
    toast("Ponto salvo: " .. n, C.green)
  end, { arg = "nome", alias = { "wp", "setpoint" } })

  addCmd("gotowaypoint", "Voltar a um ponto salvo. Ex: gotowaypoint casa", "Movimento", false, function(args)
    local n = string.lower(args and args[1] or "ponto")
    local cf, r = waypoints[n], root()
    if not cf then fail("esse ponto não existe") end
    if not r then fail("sem personagem") end
    r.CFrame = cf
  end, { arg = "nome", alias = { "gwp", "gotopoint" } })

  addCmd("waypoints", "Lista seus pontos salvos", "Movimento", false, function()
    local names = {}
    for n in pairs(waypoints) do table.insert(names, n) end
    table.sort(names)
    toast(#names == 0 and "Nenhum ponto salvo." or ("Pontos: " .. table.concat(names, ", ")), C.white)
  end, { alias = { "wps" } })

  addCmd("removewaypoint", "Apagar um ponto. Ex: removewaypoint casa", "Movimento", false, function(args)
    local n = string.lower(args and args[1] or "")
    if not waypoints[n] then fail("esse ponto não existe") end
    waypoints[n] = nil
  end, { arg = "nome", need = true, alias = { "rwp" } })

  addCmd("clearwaypoints", "Apagar todos os pontos", "Movimento", false, function()
    waypoints = {}
  end, { alias = { "cwp" } })

  -- ================================================================
  -- CÂMERA
  -- ================================================================
  addCmd("fov", "Campo de visão. Ex: fov 90", "Câmera", false, function(args)
    Cfg.fov = math.clamp(must(args, "fov 90"), 1, 120)
    applyStats()
  end, { arg = "n", need = true })

  addCmd("zoom", "Libera o zoom da câmera", "Câmera", false, function()
    Player.CameraMaxZoomDistance = 100000
    Player.CameraMinZoomDistance = 0
  end)

  addCmd("maxzoom", "Zoom máximo. Ex: maxzoom 500", "Câmera", false, function(args)
    Player.CameraMaxZoomDistance = must(args, "maxzoom 500")
  end, { arg = "n", need = true })

  addCmd("minzoom", "Zoom mínimo. Ex: minzoom 0", "Câmera", false, function(args)
    Player.CameraMinZoomDistance = must(args, "minzoom 0")
  end, { arg = "n", need = true })

  addCmd("thirdperson", "Câmera em terceira pessoa", "Câmera", false, function()
    Player.CameraMode = Enum.CameraMode.Classic
    if Player.CameraMaxZoomDistance < 20 then Player.CameraMaxZoomDistance = 128 end
  end, { alias = { "3rdperson" } })

  addCmd("firstperson", "Câmera em primeira pessoa", "Câmera", false, function()
    Player.CameraMode = Enum.CameraMode.LockFirstPerson
  end, { alias = { "1stperson" } })

  addCmd("shiftlock", "Libera o shift lock", "Câmera", true, function(on)
    Player.DevEnableMouseLock = on
  end, { alias = { "mouselock" } })

  addCmd("camclip", "Câmera atravessa paredes", "Câmera", true, function(on)
    Player.DevCameraOcclusionMode = on and Enum.DevCameraOcclusionMode.Invisicam or Enum.DevCameraOcclusionMode.Zoom
  end, { alias = { "noclipcam" } })

  addCmd("resetcam", "Volta a câmera ao normal", "Câmera", false, function()
    local cam, h = workspace.CurrentCamera, hum()
    Cfg.fov = nil
    cam.CameraType = Enum.CameraType.Custom
    cam.FieldOfView = 70
    if h then cam.CameraSubject = h end
  end, { alias = { "fixcam" } })

  -- ================================================================
  -- VISUAL
  -- ================================================================
  local function espParent()
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    return ok and core or workspace
  end

  local function clearEsp()
    for _, list in pairs(espData) do
      for _, o in ipairs(list) do pcall(function() o:Destroy() end) end
    end
    espData = {}
  end

  local function espFor(plr)
    if plr == Player then return end
    for _, o in ipairs(espData[plr] or {}) do pcall(function() o:Destroy() end) end
    espData[plr] = {}
    local ch = plr.Character
    if not ch then return end
    local hl = Instance.new("Highlight")
    hl.Adornee = ch
    hl.FillColor = C.red
    hl.FillTransparency = 0.7
    hl.OutlineColor = C.white
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = espParent()
    table.insert(espData[plr], hl)
    local head = ch:FindFirstChild("Head")
    if head then
      local bb = Instance.new("BillboardGui")
      bb.Adornee = head
      bb.AlwaysOnTop = true
      bb.Size = UDim2.fromOffset(120, 18)
      bb.StudsOffset = Vector3.new(0, 2.2, 0)
      bb.Parent = espParent()
      local tl = Instance.new("TextLabel")
      tl.Size = UDim2.fromScale(1, 1)
      tl.BackgroundTransparency = 1
      tl.Text = plr.DisplayName
      tl.TextColor3 = C.white
      tl.TextStrokeTransparency = 0.4
      tl.Font = BOLD
      tl.TextSize = 13
      tl.Parent = bb
      table.insert(espData[plr], bb)
    end
  end

  addCmd("esp", "Veja jogadores através das paredes", "Visual", true, function(on)
    local cmd = CmdByName.esp
    unbind(cmd)
    clearEsp()
    if not on then return end
    local function hook(p)
      if p == Player then return end
      track(cmd, p.CharacterAdded:Connect(function() task.wait(0.6) if cmd.state then espFor(p) end end))
      espFor(p)
    end
    for _, p in ipairs(Players:GetPlayers()) do hook(p) end
    track(cmd, Players.PlayerAdded:Connect(hook))
    track(cmd, Players.PlayerRemoving:Connect(function(p)
      for _, o in ipairs(espData[p] or {}) do pcall(function() o:Destroy() end) end
      espData[p] = nil
    end))
  end, { alias = { "chams" } })

  addCmd("fullbright", "Clareia o mapa todo", "Visual", true, function(on)
    if on then
      lset("Brightness", 2)
      lset("ClockTime", 14)
      lset("FogEnd", 1e6)
      lset("GlobalShadows", false)
      lset("Ambient", Color3.fromRGB(190, 190, 190))
      lset("OutdoorAmbient", Color3.fromRGB(190, 190, 190))
    else
      lreset()
    end
  end, { alias = { "fb" } })

  addCmd("nofog", "Tira a neblina", "Visual", true, function(on)
    if on then lset("FogEnd", 1e6) else lreset() end
  end)

  addCmd("noshadows", "Desliga as sombras", "Visual", true, function(on)
    if on then lset("GlobalShadows", false) else lreset() end
  end, { alias = { "noglobalshadows" } })

  addCmd("brightness", "Brilho do mapa. Ex: brightness 3", "Visual", false, function(args)
    lset("Brightness", must(args, "brightness 3"))
  end, { arg = "n", need = true })

  addCmd("ambient", "Cor do ambiente. Ex: ambient 255 200 150", "Visual", false, function(args)
    local r, g, b = tonumber(args and args[1]), tonumber(args and args[2]), tonumber(args and args[3])
    if not (r and g and b) then fail("use: ambient 255 200 150") end
    local col = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
    lset("Ambient", col)
    lset("OutdoorAmbient", col)
  end, { arg = "r g b", need = true })

  addCmd("resetlighting", "Volta a iluminação ao normal", "Visual", false, function()
    lreset()
  end, { alias = { "rl" } })

  addCmd("xray", "Deixa as paredes transparentes", "Visual", true, function(on)
    local cmd = CmdByName.xray
    if cmd.parts then
      for p in pairs(cmd.parts) do pcall(function() p.LocalTransparencyModifier = 0 end) end
      cmd.parts = nil
    end
    if not on then return end
    cmd.parts = {}
    for _, p in ipairs(workspace:GetDescendants()) do
      if p:IsA("BasePart") and p.Transparency < 0.9 and not (p.Parent and p.Parent:FindFirstChildOfClass("Humanoid")) then
        cmd.parts[p] = true
        p.LocalTransparencyModifier = 0.7
      end
    end
  end)

  addCmd("nopostfx", "Desliga efeitos (blur, bloom...)", "Visual", true, function(on)
    local cmd = CmdByName.nopostfx
    if cmd.fx then
      for e in pairs(cmd.fx) do pcall(function() e.Enabled = true end) end
      cmd.fx = nil
    end
    if not on then return end
    cmd.fx = {}
    for _, e in ipairs(Lighting:GetChildren()) do
      if e:IsA("PostEffect") and e.Enabled then
        cmd.fx[e] = true
        e.Enabled = false
      end
    end
  end)

  addCmd("noparticles", "Desliga partículas (menos lag)", "Visual", true, function(on)
    local cmd = CmdByName.noparticles
    if cmd.items then
      for e in pairs(cmd.items) do pcall(function() e.Enabled = true end) end
      cmd.items = nil
    end
    if not on then return end
    cmd.items = {}
    for _, e in ipairs(workspace:GetDescendants()) do
      if e:IsA("ParticleEmitter") and e.Enabled then
        cmd.items[e] = true
        e.Enabled = false
      end
    end
  end)

  addCmd("lowgraphics", "Gráficos baixos para ganhar FPS", "Visual", false, function()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    lset("GlobalShadows", false)
    for _, e in ipairs(Lighting:GetChildren()) do
      if e:IsA("PostEffect") then e.Enabled = false end
    end
    task.spawn(function()
      local n = 0
      for _, p in ipairs(workspace:GetDescendants()) do
        pcall(function()
          if p:IsA("BasePart") then
            p.Material = Enum.Material.SmoothPlastic
            p.Reflectance = 0
          elseif p:IsA("ParticleEmitter") or p:IsA("Trail") then
            p.Enabled = false
          end
        end)
        n = n + 1
        if n % 400 == 0 then task.wait() end
      end
      toast("Gráficos baixos aplicados.", C.green)
    end)
  end, { alias = { "fpsboost", "potato" } })

  addCmd("transparency", "Transparência do seu personagem. Ex: transparency 0.5", "Visual", false, function(args)
    local n = math.clamp(tonumber(args and args[1]) or 0.5, 0, 1)
    local c = Player.Character
    if not c then fail("sem personagem") end
    for _, p in ipairs(c:GetDescendants()) do
      if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = n end
    end
  end, { arg = "0 a 1", alias = { "trans" } })

  -- ================================================================
  -- INTERFACE
  -- ================================================================
  addCmd("hideui", "Esconde todas as telas do jogo", "Interface", true, function(on)
    local cmd = CmdByName.hideui
    if cmd.hidden then
      for g in pairs(cmd.hidden) do pcall(function() g.Enabled = true end) end
      cmd.hidden = nil
      pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
    end
    if not on then return end
    cmd.hidden = {}
    for _, g in ipairs(PlayerGui:GetChildren()) do
      if g:IsA("ScreenGui") and g ~= GUI and g.Enabled then
        cmd.hidden[g] = true
        g.Enabled = false
      end
    end
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
  end)

  addCmd("crosshair", "Mira no meio da tela", "Interface", true, function(on)
    local cmd = CmdByName.crosshair
    if cmd.gui then cmd.gui:Destroy() cmd.gui = nil end
    if not on then return end
    local g = create("ScreenGui", { Name = "NOVEX_Mira", ResetOnSpawn = false, IgnoreGuiInset = true }, Parent)
    local dot = create("Frame", {
      AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
      Size = UDim2.fromOffset(6, 6), BackgroundColor3 = C.red, BorderSizePixel = 0,
    }, g)
    corner(dot, 3)
    cmd.gui = g
  end, { alias = { "mira" } })

  local function coreToggle(name, desc, coreType)
    addCmd(name, desc, "Interface", true, function(on)
      pcall(function() StarterGui:SetCoreGuiEnabled(coreType, not on) end)
    end)
  end
  coreToggle("hidechat", "Esconde o chat", Enum.CoreGuiType.Chat)
  coreToggle("hideplayerlist", "Esconde a lista de jogadores", Enum.CoreGuiType.PlayerList)
  coreToggle("hidebackpack", "Esconde a mochila", Enum.CoreGuiType.Backpack)
  coreToggle("hidehealth", "Esconde a barra de vida", Enum.CoreGuiType.Health)
  coreToggle("hideemotes", "Esconde o menu de emotes", Enum.CoreGuiType.EmotesMenu)

  addCmd("guiscale", "Tamanho do menu NOVEX. Ex: guiscale 0.8", "Interface", false, function(args)
    DATA.settings.guiScale = math.clamp(must(args, "guiscale 0.8"), 0.5, 1.5)
    saveData()
    resize()
  end, { arg = "0.5 a 1.5", need = true })

  addCmd("hide", "Esconde o menu NOVEX", "Interface", false, function()
    Shell.Visible = false
  end, { alias = { "hidenovex" } })

  -- ================================================================
  -- PERSONAGEM
  -- ================================================================
  addCmd("reset", "Reiniciar o personagem", "Personagem", false, function()
    local h = hum()
    if h then h.Health = 0 end
  end, { exact = true, alias = { "respawn" } })

  addCmd("refresh", "Renasce no mesmo lugar", "Personagem", false, function()
    local r, h = root(), hum()
    local cf = r and r.CFrame
    if h then h.Health = 0 end
    local c = Player.CharacterAdded:Wait()
    local nr = c:WaitForChild("HumanoidRootPart", 5)
    task.wait(0.15)
    if nr and cf then nr.CFrame = cf end
  end, { alias = { "re" }, exact = true })

  addCmd("god", "Vida infinita (só funciona em alguns jogos)", "Personagem", true, function(on)
    local cmd = CmdByName.god
    unbind(cmd)
    if not on then
      local h = hum()
      if h then h.MaxHealth = 100 h.Health = 100 end
      return
    end
    track(cmd, RunService.Heartbeat:Connect(function()
      local h = hum()
      if h then
        h.MaxHealth = 1e9
        h.Health = 1e9
      end
    end))
  end, { alias = { "godmode" } })

  addCmd("sit", "Sentar", "Personagem", false, function()
    local h = hum()
    if h then h.Sit = true end
  end)

  addCmd("unsit", "Levantar", "Personagem", false, function()
    local h = hum()
    if h then h.Sit = false h:ChangeState(Enum.HumanoidStateType.GettingUp) end
  end, { alias = { "stand" } })

  addCmd("anchor", "Congela você no lugar", "Personagem", true, function(on)
    local r = root()
    if r then r.Anchored = on end
  end, { alias = { "freeze" } })

  addCmd("platformstand", "Fica sem controle (como no ar)", "Personagem", true, function(on)
    local h = hum()
    if h then h.PlatformStand = on end
  end, { alias = { "ps" } })

  addCmd("autojump", "Pula sozinho ao encostar em degraus", "Personagem", true, function(on)
    local h = hum()
    if h then h.AutoJumpEnabled = on end
  end)

  addCmd("noanimate", "Desliga as animações do personagem", "Personagem", true, function(on)
    local c = Player.Character
    local a = c and c:FindFirstChild("Animate")
    if a then a.Disabled = on end
    if on then
      local h = hum()
      if h then
        for _, t in ipairs(h:GetPlayingAnimationTracks()) do pcall(function() t:Stop() end) end
      end
    end
  end)

  addCmd("animspeed", "Velocidade das animações. Ex: animspeed 2", "Personagem", false, function(args)
    local n = must(args, "animspeed 2")
    Cfg.animSpeed = (n ~= 1) and n or nil
  end, { arg = "n", need = true })

  addCmd("droptools", "Solta todas as suas ferramentas", "Personagem", false, function()
    local c, h = Player.Character, hum()
    if not c then fail("sem personagem") end
    if h then h:UnequipTools() end
    for _, t in ipairs(Player.Backpack:GetChildren()) do
      if t:IsA("Tool") then
        t.Parent = c
        t.Parent = workspace
      end
    end
  end)

  addCmd("equiptools", "Equipa todas as ferramentas", "Personagem", false, function()
    local c = Player.Character
    if not c then fail("sem personagem") end
    for _, t in ipairs(Player.Backpack:GetChildren()) do
      if t:IsA("Tool") then t.Parent = c end
    end
  end, { alias = { "equipall" } })

  addCmd("unequiptools", "Guarda as ferramentas na mochila", "Personagem", false, function()
    local h = hum()
    if h then h:UnequipTools() end
  end, { alias = { "unequipall" } })


 -- ================================================================
 -- JOGADORES
 -- ================================================================
 addCmd("view", "Assistir um jogador. Ex: view nome", "Jogadores", false, function(args)
 local p = getTarget(args and args[1])
 if not viewPlayer(p) then fail("jogador sem personagem") end
 end, { arg = "jogador", need = true, alias = { "spectate" } })

 addCmd("unview", "Parar de assistir", "Jogadores", false, function()
 unview()
 end, { alias = { "unspectate" } })

 addCmd("face", "Olhar na direção de um jogador. Ex: face nome", "Jogadores", false, function(args)
 local p = getTarget(args and args[1])
 local r, tr = root(), p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 if not r or not tr then fail("sem personagem") end
 r.CFrame = CFrame.lookAt(r.Position, Vector3.new(tr.Position.X, r.Position.Y, tr.Position.Z))
 end, { arg = "jogador", need = true })

 addCmd("whois", "Info de um jogador. Ex: whois nome", "Jogadores", false, function(args)
 local p = getTarget(args and args[1])
 toast(string.format("%s (@%s) • conta %d dias • %s", p.DisplayName, p.Name, p.AccountAge,
 p.Team and p.Team.Name or "sem time"), C.white)
 end, { arg = "jogador", need = true, alias = { "info" } })

 addCmd("distance", "Distância até um jogador. Ex: distance nome", "Jogadores", false, function(args)
 local p = getTarget(args and args[1])
 local r, tr = root(), p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 if not r or not tr then fail("sem personagem") end
 toast(p.DisplayName .. " está a " .. math.floor((r.Position - tr.Position).Magnitude) .. " studs", C.white)
 end, { arg = "jogador", need = true, alias = { "dist" } })

 addCmd("nearest", "Mostra o jogador mais perto", "Jogadores", false, function()
 local p = getTargets("nearest")[1]
 if not p then fail("ninguém por perto") end
 local r, tr = root(), p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 local d = (r and tr) and math.floor((r.Position - tr.Position).Magnitude) or 0
 toast("Mais perto: " .. p.DisplayName .. " (" .. d .. " studs)", C.white)
 end)

 addCmd("players", "Lista quem está no servidor", "Jogadores", false, function()
 local names = {}
 for _, p in ipairs(Players:GetPlayers()) do
 if #names < 8 then table.insert(names, p.DisplayName) end
 end
 toast(#Players:GetPlayers() .. " jogadores: " .. table.concat(names, ", "), C.white)
 end, { alias = { "plist" } })

 addCmd("copyname", "Copia o nome de um jogador. Ex: copyname nome", "Jogadores", false, function(args)
 local p = getTarget(args and args[1])
 if not copyText(p.Name) then fail("não consegui copiar") end
 toast("Nome copiado: " .. p.Name, C.green)
 end, { arg = "jogador", need = true })

 addCmd("copyid", "Copia o ID de um jogador. Ex: copyid nome", "Jogadores", false, function(args)
 local p = getTarget(args and args[1])
 if not copyText(tostring(p.UserId)) then fail("não consegui copiar") end
 toast("ID copiado: " .. p.UserId, C.green)
 end, { arg = "jogador", need = true })

 -- ================================================================
 -- MUNDO
 -- ================================================================
 addCmd("gravity", "Gravidade. Ex: gravity 50", "Mundo", false, function(args)
 workspace.Gravity = must(args, "gravity 50")
 end, { arg = "n", need = true, alias = { "grav" } })

 addCmd("time", "Hora do dia (0-24). Ex: time 14", "Mundo", false, function(args)
 lset("ClockTime", must(args, "time 14"))
 end, { arg = "0 a 24", need = true, alias = { "clocktime" } })

 addCmd("day", "Deixa de dia", "Mundo", false, function() lset("ClockTime", 14) end)
 addCmd("night", "Deixa de noite", "Mundo", false, function() lset("ClockTime", 0) end)
 addCmd("sunrise", "Nascer do sol", "Mundo", false, function() lset("ClockTime", 6) end)
 addCmd("sunset", "Pôr do sol", "Mundo", false, function() lset("ClockTime", 18) end)

 local function gameSettings()
 local ok, gs = pcall(function() return UserSettings():GetService("UserGameSettings") end)
 return ok and gs or nil
 end

 addCmd("mute", "Silencia o jogo", "Mundo", true, function(on)
 local cmd, gs = CmdByName.mute, gameSettings()
 if not gs then fail("executor sem suporte") end
 if on then
 cmd.prev = gs.MasterVolume
 gs.MasterVolume = 0
 else
 gs.MasterVolume = cmd.prev or 1
 end
 end)

 addCmd("volume", "Volume do jogo (0-100). Ex: volume 50", "Mundo", false, function(args)
 local gs = gameSettings()
 if not gs then fail("executor sem suporte") end
 gs.MasterVolume = math.clamp(must(args, "volume 50"), 0, 100) / 100
 end, { arg = "0 a 100", need = true })

 addCmd("partcount", "Conta as peças do mapa", "Mundo", false, function()
 local n = 0
 for _, p in ipairs(workspace:GetDescendants()) do
 if p:IsA("BasePart") then n = n + 1 end
 end
 toast("O mapa tem " .. n .. " peças.", C.white)
 end)

 -- ================================================================
 -- FERRAMENTAS
 -- ================================================================
 addCmd("breakloops", "Para todos os comandos repetidos", "Ferramentas", false, function()
 loopGen = loopGen + 1
 toast("Repetições paradas.", C.green)
 end, { alias = { "bl" } })

 addCmd("bind", "Atalho de teclado (PC). Ex: bind f fly", "Ferramentas", false, function(args)
 if not args or #args < 2 then fail("use: bind f fly") end
 local key = string.lower(table.remove(args, 1))
 DATA.binds[key] = table.concat(args, " ")
 saveData()
 toast("Tecla " .. string.upper(key) .. " = " .. DATA.binds[key], C.green)
 end, { arg = "tecla comando", need = true })

 addCmd("unbindkey", "Remove um atalho. Ex: unbindkey f", "Ferramentas", false, function(args)
 local key = string.lower(args and args[1] or "")
 if not DATA.binds[key] then fail("essa tecla não tem atalho") end
 DATA.binds[key] = nil
 saveData()
 end, { arg = "tecla", need = true })

 addCmd("binds", "Lista seus atalhos", "Ferramentas", false, function()
 local out = {}
 for k, v in pairs(DATA.binds) do table.insert(out, string.upper(k) .. "=" .. v) end
 toast(#out == 0 and "Nenhum atalho." or table.concat(out, " • "), C.white)
 end)

 addCmd("autorun", "Roda um comando sempre que abrir o NOVEX. Ex: autorun antiafk", "Ferramentas", false, function(args)
 if not args or #args < 1 then fail("use: autorun antiafk") end
 local l = table.concat(args, " ")
 table.insert(DATA.autorun, l)
 saveData()
 toast("Vai rodar ao abrir: " .. l, C.green)
 end, { arg = "comando", need = true })

 addCmd("autorunlist", "Lista os comandos automáticos", "Ferramentas", false, function()
 toast(#DATA.autorun == 0 and "Nenhum comando automático." or table.concat(DATA.autorun, " • "), C.white)
 end)

 addCmd("autorunclear", "Apaga os comandos automáticos", "Ferramentas", false, function()
 DATA.autorun = {}
 saveData()
 toast("Comandos automáticos apagados.", C.green)
 end)

 addCmd("say", "Falar no chat. Ex: say oi", "Ferramentas", false, function(args)
 local msg = table.concat(args or {}, " ")
 if msg == "" then fail("use: say oi") end
 local ok = pcall(function()
 local TCS = game:GetService("TextChatService")
 local ch = TCS:FindFirstChild("TextChannels") and TCS.TextChannels:FindFirstChild("RBXGeneral")
 if not ch then error("x") end
 ch:SendAsync(msg)
 end)
 if not ok then
 pcall(function()
 game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
 end)
 end
 end, { arg = "texto", need = true, alias = { "chat" } })

 addCmd("notify", "Mostra um aviso. Ex: notify oi", "Ferramentas", false, function(args)
 toast(table.concat(args or {}, " "), C.white)
 end, { arg = "texto", need = true })

 addCmd("clear", "Limpa a lista de recentes", "Ferramentas", false, function()
 for i = #recent, 1, -1 do table.remove(recent, i) end
 if X.updateRecent then X.updateRecent() end
 end, { alias = { "clearhistory" } })

 addCmd("cmds", "Abre a lista de comandos", "Ferramentas", false, function() X.setPage("Cmds") end)
 addCmd("scripts", "Abre a biblioteca de scripts", "Ferramentas", false, function() X.setPage("Scripts") end)
 addCmd("settings", "Abre as configurações", "Ferramentas", false, function() X.setPage("Settings") end, { alias = { "config" } })

 -- ================================================================
 -- UTILIDADES
 -- ================================================================
 addCmd("antiafk", "Não ser expulso por ficar parado", "Utilidades", true, function(on)
 local cmd = CmdByName.antiafk
 unbind(cmd)
 if not on then return end
 track(cmd, Player.Idled:Connect(function()
 VirtualUser:CaptureController()
 VirtualUser:ClickButton2(Vector2.new())
 end))
 end, { alias = { "antiidle" } })

 addCmd("fpscap", "Limite de FPS. Ex: fpscap 60 (sem número = sem limite)", "Utilidades", false, function(args)
 if not setfpscap then fail("executor sem suporte") end
 setfpscap(tonumber(args and args[1]) or 999)
 end, { arg = "n", alias = { "unlockfps" } })

 addCmd("rejoin", "Reentrar no servidor", "Utilidades", false, function() X.rejoin() end, { exact = true, alias = { "rj" } })
 addCmd("serverhop", "Ir para outro servidor", "Utilidades", false, function() X.serverHop() end, { exact = true, alias = { "shop" } })
 addCmd("melhorserver", "Vai pro servidor com MENOS MS. Ex: melhorserver | melhorserver 2 (o 2º melhor) | melhorserver ver (só lista os 5 melhores)", "Utilidades", false, function(args) X.melhorServer(args) end, { exact = true, arg = "[número|ver]", alias = { "menosms", "lowping", "serverbr", "bestping" } })

 addCmd("joinplace", "Ir para outro jogo. Ex: joinplace 1234", "Utilidades", false, function(args)
 local id = must(args, "joinplace 1234")
 TeleportService:Teleport(id, Player)
 end, { arg = "place id", need = true, exact = true })

 addCmd("leave", "Sair do jogo", "Utilidades", false, function()
 game:Shutdown()
 end, { exact = true, alias = { "exit", "quit" } })

 addCmd("copyjobid", "Copiar o Job ID", "Utilidades", false, function()
 if not copyText(tostring(game.JobId)) then fail("não consegui copiar") end
 toast("Job ID copiado!", C.green)
 end, { alias = { "jobid" } })

 addCmd("copyplaceid", "Copiar o Place ID", "Utilidades", false, function()
 if not copyText(tostring(game.PlaceId)) then fail("não consegui copiar") end
 toast("Place ID copiado!", C.green)
 end, { alias = { "placeid" } })

 addCmd("copygameid", "Copiar o Game ID", "Utilidades", false, function()
 if not copyText(tostring(game.GameId)) then fail("não consegui copiar") end
 toast("Game ID copiado!", C.green)
 end)

 addCmd("copyuserid", "Copiar o seu User ID", "Utilidades", false, function()
 if not copyText(tostring(Player.UserId)) then fail("não consegui copiar") end
 toast("Seu ID copiado!", C.green)
 end)

 addCmd("copylink", "Copiar o link do jogo", "Utilidades", false, function()
 if not copyText("https://www.roblox.com/games/" .. game.PlaceId) then fail("não consegui copiar") end
 toast("Link do jogo copiado!", C.green)
 end)

 addCmd("pos", "Mostra suas coordenadas", "Utilidades", false, function()
 local r = root()
 if not r then fail("sem personagem") end
 local p = r.Position
 toast(string.format("Posição: %d, %d, %d", p.X, p.Y, p.Z), C.white)
 end, { alias = { "position" } })

 addCmd("copypos", "Copia suas coordenadas", "Utilidades", false, function()
 local r = root()
 if not r then fail("sem personagem") end
 local p = r.Position
 if not copyText(string.format("%d %d %d", p.X, p.Y, p.Z)) then fail("não consegui copiar") end
 toast("Coordenadas copiadas!", C.green)
 end)

 addCmd("ping", "Mostra o seu ping", "Utilidades", false, function()
 toast("Ping: " .. math.floor(Player:GetNetworkPing() * 1000) .. " ms", C.white)
 end)

 addCmd("serverinfo", "Info do servidor", "Utilidades", false, function()
 toast(string.format("%d/%d jogadores • %d min ativo • %d ms", #Players:GetPlayers(), Players.MaxPlayers,
 math.floor(workspace.DistributedGameTime / 60), math.floor(Player:GetNetworkPing() * 1000)), C.white)
 end, { alias = { "sinfo" } })

 addCmd("placeinfo", "Nome e criador do jogo", "Utilidades", false, function()
 local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
 if not ok or not info then fail("não consegui ver") end
 toast((info.Name or "?") .. " • por " .. ((info.Creator and info.Creator.Name) or "?"), C.white)
 end, { alias = { "gameinfo" } })

 -- ================================================================
 -- COMANDOS DO NOVEX GOLD (já embutidos; só entra o que ainda não existe)
 -- ================================================================
 do
 local function add(name, desc, cat, isToggle, fn, opt)
 if CmdByName[name] then return end
 opt = opt or {}
 local livres = {}
 for _, a in ipairs(opt.alias or {}) do
 if not CmdByName[a] and not Alias[a] then table.insert(livres, a) end
 end
 opt.alias = livres
 return addCmd(name, desc, cat, isToggle, fn, opt)
 end
 local function num(args, i, padrao) return tonumber(args and args[i or 1]) or padrao end
 local function eu()
 local r = root()
 if not r then fail("sem personagem") end
 return r
 end

 -- MOVIMENTO
 add("dash", "Impulso pra frente. Ex: dash 120", "Movimento", false, function(args)
 local r = eu()
 r.AssemblyLinearVelocity = r.CFrame.LookVector * num(args, 1, 100) + Vector3.new(0, 15, 0)
 end, { arg = "n" })

 add("launch", "Impulso pra cima. Ex: launch 150", "Movimento", false, function(args)
 local r = eu()
 local v = r.AssemblyLinearVelocity
 r.AssemblyLinearVelocity = Vector3.new(v.X, num(args, 1, 120), v.Z)
 end, { arg = "n" })

 local function passo(nome, desc, dir)
 add(nome, desc .. " Ex: " .. nome .. " 20", "Movimento", false, function(args)
 local r = eu()
 r.CFrame = r.CFrame + dir(r.CFrame) * num(args, 1, 10)
 end, { arg = "n", exact = true })
 end
 passo("forward", "Anda pra frente por teleporte.", function(cf) return cf.LookVector end)
 passo("back", "Anda pra trás por teleporte.", function(cf) return -cf.LookVector end)
 passo("left", "Anda pra esquerda por teleporte.", function(cf) return -cf.RightVector end)
 passo("right", "Anda pra direita por teleporte.", function(cf) return cf.RightVector end)


 -- VISUAL
 local function efeito(nome, desc, classe, props, alias)
 add(nome, desc, "Visual", true, function(on)
 local cmd = CmdByName[nome]
 if cmd.fx then pcall(function() cmd.fx:Destroy() end) cmd.fx = nil end
 if not on then return end
 local fx = Instance.new(classe)
 for k, v in pairs(props) do fx[k] = v end
 fx.Parent = Lighting
 cmd.fx = fx
 end, { alias = alias })
 end
 efeito("vivid", "Deixa as cores do jogo mais vivas", "ColorCorrectionEffect", { Saturation = 0.4, Contrast = 0.12, Brightness = 0.02 }, { "vivo" })
 efeito("grayscale", "Jogo em preto e branco", "ColorCorrectionEffect", { Saturation = -1 }, { "bw" })
 efeito("bloom", "Brilho suave nas luzes", "BloomEffect", { Intensity = 0.7, Size = 30, Threshold = 0.85 })
 efeito("sunrays", "Raios de sol", "SunRaysEffect", { Intensity = 0.2, Spread = 0.8 })
 efeito("blur", "Desfoca a tela", "BlurEffect", { Size = 14 })

 add("noclouds", "Tira as nuvens", "Visual", true, function(on)
 local c = workspace.Terrain:FindFirstChildOfClass("Clouds")
 if c then c.Enabled = not on end
 end)

 add("hidenames", "Esconde os nomes acima da cabeça", "Visual", true, function(on)
 for _, p in ipairs(Players:GetPlayers()) do
 local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
 if h then
 h.DisplayDistanceType = on and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer
 end
 end
 end, { alias = { "nonames" } })

 -- MUNDO
 local gravPadrao = workspace.Gravity
 add("resetgravity", "Gravidade normal de volta", "Mundo", false, function()
 workspace.Gravity = gravPadrao
 end, { alias = { "rgrav" } })
 add("lowgravity", "Gravidade baixa (pule alto e flutue)", "Mundo", true, function(on)
 workspace.Gravity = on and gravPadrao * 0.25 or gravPadrao
 end, { alias = { "moon" } })

 add("rainbow", "Ambiente do mapa com cores que mudam", "Mundo", true, function(on)
 local cmd = CmdByName.rainbow
 unbind(cmd)
 if not on then lreset() return end
 local h = 0
 track(cmd, RunService.Heartbeat:Connect(function(dt)
 h = (h + dt * 0.1) % 1
 local cor = Color3.fromHSV(h, 0.6, 1)
 lset("Ambient", cor)
 lset("OutdoorAmbient", cor)
 end))
 end, { alias = { "disco" } })

 add("timeloop", "O dia passa rápido. Ex: timeloop 1", "Mundo", true, function(on, args)
 local cmd = CmdByName.timeloop
 unbind(cmd)
 if not on then return end
 local v = num(args, 1, 1)
 track(cmd, RunService.Heartbeat:Connect(function(dt)
 Lighting.ClockTime = (Lighting.ClockTime + dt * v) % 24
 end))
 end, { arg = "velocidade" })

 add("fog", "Define a neblina. Ex: fog 200", "Mundo", false, function(args)
 lset("FogEnd", math.max(1, must(args, "fog 200")))
 end, { arg = "n", need = true })

 add("fogcolor", "Cor da neblina. Ex: fogcolor 255 100 200", "Mundo", false, function(args)
 local r, g, b = tonumber(args and args[1]), tonumber(args and args[2]), tonumber(args and args[3])
 if not (r and g and b) then fail("use: fogcolor 255 100 200") end
 lset("FogColor", Color3.fromRGB(r, g, b))
 end, { arg = "r g b", need = true })

 -- JOGADORES
 add("inspect", "Mostra info de um jogador. Ex: inspect nome", "Jogadores", false, function(args)
 local p = getTarget(args and args[1])
 local r = root()
 local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
 local dist = (r and pr) and math.floor((r.Position - pr.Position).Magnitude) or "?"
 toast(string.format("%s (@%s) | %s dias | %s studs | vida %s",
 p.DisplayName, p.Name, tostring(p.AccountAge), tostring(dist), h and tostring(math.floor(h.Health)) or "?"), C.white)
 end, { arg = "jogador", need = true })

 add("gotonearest", "Vai até o jogador mais próximo", "Jogadores", false, function()
 local r = eu()
 local melhor, dmin
 for _, p in ipairs(Players:GetPlayers()) do
 local pr = p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 if pr then
 local d = (pr.Position - r.Position).Magnitude
 if not dmin or d < dmin then melhor, dmin = pr, d end
 end
 end
 if not melhor then fail("ninguém por perto") end
 r.CFrame = melhor.CFrame * CFrame.new(0, 0, 3)
 end, { alias = { "gtn" } })

 -- PERSONAGEM
 add("heal", "Enche sua vida (funciona em alguns jogos)", "Personagem", false, function()
 local h = hum()
 if h then h.Health = h.MaxHealth end
 end)

 add("ghost", "Fica transparente só pra você", "Personagem", true, function(on)
 local c = Player.Character
 if not c then return end
 for _, p in ipairs(c:GetDescendants()) do
 if p:IsA("BasePart") then p.LocalTransparencyModifier = on and 0.7 or 0 end
 end
 end)


 -- INVIS: some pra você e esconde seu nome (só a SUA tela; o servidor não deixa os outros te perderem de vista)
 add("invis", "Fica invisível na sua tela e esconde seu nome (os outros ainda podem te ver, depende do jogo)", "Personagem", true, function(on)
 local cmd = CmdByName.invis
 unbind(cmd)
 local function aplicar(ligado)
 local c = Player.Character
 if not c then return end
 for _, p in ipairs(c:GetDescendants()) do
 if p:IsA("BasePart") then p.LocalTransparencyModifier = ligado and 1 or 0 end
 end
 local h = c:FindFirstChildOfClass("Humanoid")
 if h then
 h.DisplayDistanceType = ligado and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer
 end
 end
 aplicar(on)
 if not on then return end
 local acc = 0
 track(cmd, RunService.Heartbeat:Connect(function(dt)
 acc = acc + dt
 if acc >= 0.25 then
 acc = 0
 pcall(aplicar, true)
 end
 end))
 track(cmd, { Disconnect = function() pcall(aplicar, false) end })
 end, { alias = { "invisible", "invisivel" } })

 -- CHATLOG: mostra e guarda o que os jogadores falam
 local ChatLog = { linhas = {} }
 add("chatlog", "Mostra o que os jogadores falam no chat (últimas 60). Ex: chatlog | chatcopy copia tudo", "Utilidades", true, function(on)
 local cmd = CmdByName.chatlog
 unbind(cmd)
 if cmd.gui then cmd.gui:Destroy() cmd.gui = nil end
 if not on then return end
 local UIS = game:GetService("UserInputService")
 local f = create("Frame", {
 Position = UDim2.fromOffset(10, 170), Size = UDim2.fromOffset(240, 160),
 BackgroundColor3 = C.black, BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 20,
 }, GUI)
 corner(f, 12)
 stroke(f, C.gold, 0.3, 1.4)
 cmd.gui = f
 local barra = create("TextButton", {
 Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1,
 Text = "  💬 Chat log (arraste aqui)", TextColor3 = C.gold, Font = BOLD, TextSize = 12,
 TextXAlignment = LEFT, AutoButtonColor = false, ZIndex = 21,
 }, f)
 local rolagem = create("ScrollingFrame", {
 Position = UDim2.fromOffset(6, 28), Size = UDim2.new(1, -12, 1, -34), BackgroundTransparency = 1,
 BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(),
 AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 21,
 }, f)
 create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, rolagem)

 -- arrastar pela barra de cima
 local arrastando, pos0, quadro0 = false, nil, nil
 barra.InputBegan:Connect(function(i)
 if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
 arrastando, pos0, quadro0 = true, i.Position, f.Position
 i.Changed:Connect(function()
 if i.UserInputState == Enum.UserInputState.End then arrastando = false end
 end)
 end
 end)
 track(cmd, UIS.InputChanged:Connect(function(i)
 if arrastando and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
 local d = i.Position - pos0
 f.Position = UDim2.new(quadro0.X.Scale, quadro0.X.Offset + d.X, quadro0.Y.Scale, quadro0.Y.Offset + d.Y)
 end
 end))

 local ordem, itens = 0, {}
 local function registrar(nome, texto)
 ordem = ordem + 1
 table.insert(ChatLog.linhas, nome .. ": " .. texto)
 while #ChatLog.linhas > 200 do table.remove(ChatLog.linhas, 1) end
 local l = create("TextLabel", {
 Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
 Text = nome .. ": " .. texto, TextColor3 = C.white, Font = GOTHAM, TextSize = 11, TextWrapped = true,
 TextXAlignment = LEFT, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = ordem, ZIndex = 22,
 }, rolagem)
 table.insert(itens, l)
 if #itens > 60 then
 local velho = table.remove(itens, 1)
 velho:Destroy()
 end
 task.defer(function()
 pcall(function() rolagem.CanvasPosition = Vector2.new(0, rolagem.AbsoluteCanvasSize.Y) end)
 end)
 end

 local TCS = game:GetService("TextChatService")
 local novoChat = false
 pcall(function() novoChat = TCS.ChatVersion == Enum.ChatVersion.TextChatService end)
 if novoChat then
 track(cmd, TCS.MessageReceived:Connect(function(m)
 local src = m.TextSource
 if not src then return end
 local nome = src.Name
 local p = Players:GetPlayerByUserId(src.UserId)
 if p then nome = p.DisplayName end
 registrar(nome, m.Text)
 end))
 else
 local function ouvir(p)
 track(cmd, p.Chatted:Connect(function(msg) registrar(p.DisplayName, msg) end))
 end
 for _, p in ipairs(Players:GetPlayers()) do ouvir(p) end
 track(cmd, Players.PlayerAdded:Connect(ouvir))
 end
 end, { alias = { "chatspy", "logchat" } })

 add("chatcopy", "Copia tudo que o chat log guardou", "Utilidades", false, function()
 if #ChatLog.linhas == 0 then fail("o chat log está vazio (ligue com: chatlog)") end
 copyText(table.concat(ChatLog.linhas, "\n"))
 toast(#ChatLog.linhas .. " mensagens copiadas", C.green)
 end)

 -- UTILIDADES
 local inicio = os.clock()
 add("uptime", "Há quanto tempo o NOVEX está aberto", "Utilidades", false, function()
 local s = math.floor(os.clock() - inicio)
 toast(string.format("Aberto há %dmin %ds", math.floor(s / 60), s % 60), C.white)
 end)

 add("serverage", "Há quanto tempo o servidor está aberto", "Utilidades", false, function()
 local s = math.floor(workspace.DistributedGameTime)
 toast(string.format("Servidor aberto há %dh %dmin", math.floor(s / 3600), math.floor((s % 3600) / 60)), C.white)
 end, { alias = { "serveruptime" } })

 add("autoclick", "Clica sozinho. Ex: autoclick 10 (cliques por segundo)", "Utilidades", true, function(on, args)
 local cmd = CmdByName.autoclick
 unbind(cmd)
 if not on then return end
 local cps = math.clamp(num(args, 1, 10), 1, 30)
 local acc = 0
 track(cmd, RunService.Heartbeat:Connect(function(dt)
 acc = acc + dt
 if acc >= 1 / cps then
 acc = 0
 pcall(function()
 VirtualUser:CaptureController()
 VirtualUser:ClickButton1(Vector2.new(0, 0))
 end)
 end
 end))
 end, { arg = "cps", alias = { "clicker" } })



 -- FERRAMENTAS
 add("lua", "Executa um código Lua. Ex: lua print('oi')", "Ferramentas", false, function(args)
 local fonte = table.concat(args or {}, " ")
 if fonte == "" then fail("use: lua print('oi')") end
 local f, e = loadstring(fonte)
 if not f then fail(tostring(e)) end
 f()
 end, { arg = "código", need = true, exact = true })

 add("loadurl", "Roda um script de um link. Ex: loadurl https://...", "Ferramentas", false, function(args)
 local url = args and args[1]
 if not url then fail("use: loadurl https://...") end
 local ok, src = pcall(function() return game:HttpGet(url) end)
 if not ok then fail("não consegui baixar") end
 local f = loadstring(src)
 if not f then fail("script inválido") end
 f()
 end, { arg = "link", need = true, exact = true })

 add("copy", "Copia um texto. Ex: copy olá", "Ferramentas", false, function(args)
 X.doCopy(table.concat(args or {}, " "), "Texto copiado!")
 end, { arg = "texto", need = true, exact = true })

 add("timer", "Avisa depois de alguns segundos. Ex: timer 30", "Ferramentas", false, function(args)
 local s = must(args, "timer 30")
 toast("Timer de " .. s .. "s iniciado.", C.gray)
 task.delay(s, function() toast("Acabou o tempo (" .. s .. "s)!", C.orange) end)
 end, { arg = "segundos", need = true })

 add("calc", "Faz uma conta. Ex: calc 2*(3+4)", "Ferramentas", false, function(args)
 local expr = table.concat(args or {}, " ")
 if not expr:match("^[%d%s%+%-%*/%%%^%(%)%.]+$") then fail("só números e + - * / ^ ( )") end
 local f = loadstring("return " .. expr)
 if not f then fail("conta inválida") end
 local ok, r = pcall(f)
 if not ok then fail("conta inválida") end
 toast(expr .. " = " .. tostring(r), C.green)
 end, { arg = "conta", need = true, exact = true })

 -- ================================================================
 -- NOVOS (estilo Infinite Yield): fling e outros
 -- ================================================================
 add("walkfling", "Quem encostar em você é jogado longe", "Jogadores", true, function(on)
 local cmd = CmdByName.walkfling
 cmd.gen = (cmd.gen or 0) + 1
 local gen = cmd.gen
 if not on then return end
 task.spawn(function()
 local mov = 0.1
 while cmd.gen == gen and GUI.Parent do
 RunService.Heartbeat:Wait()
 local r = root()
 if r then
 local vel = r.AssemblyLinearVelocity
 r.AssemblyLinearVelocity = Vector3.new(0, 10000, 0)
 RunService.RenderStepped:Wait()
 r = root()
 if r then r.AssemblyLinearVelocity = vel end
 RunService.Stepped:Wait()
 r = root()
 if r then
 r.AssemblyLinearVelocity = vel + Vector3.new(0, mov, 0)
 mov = -mov
 end
 end
 end
 end)
 end)


 add("orbit", "Gira em volta de um jogador. Ex: orbit nome 2 8", "Jogadores", true, function(on, args)
 local cmd = CmdByName.orbit
 unbind(cmd)
 if not on then return end
 local alvo = getTarget(args and args[1])
 local vel = num(args, 2, 2)
 local raio = num(args, 3, 8)
 local ang = 0
 track(cmd, RunService.Heartbeat:Connect(function(dt)
 local r = root()
 local tr = alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart")
 if not r or not tr then return end
 ang = ang + dt * vel
 local pos = tr.Position + Vector3.new(math.cos(ang) * raio, 0, math.sin(ang) * raio)
 r.CFrame = CFrame.lookAt(pos, tr.Position)
 end))
 end, { arg = "jogador vel raio", need = true })

 add("walkto", "Anda até um jogador. Ex: walkto nome", "Movimento", false, function(args)
 local p = getTarget(args and args[1])
 local h = hum()
 local tr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 if not h or not tr then fail("sem personagem") end
 h:MoveTo(tr.Position)
 end, { arg = "jogador", need = true })

 add("swim", "Nade no ar", "Movimento", true, function(on)
 local cmd = CmdByName.swim
 unbind(cmd)
 if cmd.grav then
 workspace.Gravity = cmd.grav
 cmd.grav = nil
 end
 local h = hum()
 if h then
 for _, st in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
 if st ~= Enum.HumanoidStateType.None then pcall(function() h:SetStateEnabled(st, true) end) end
 end
 end
 if not on then
 if h then h:ChangeState(Enum.HumanoidStateType.Freefall) end
 return
 end
 local r = root()
 if not r or not h then fail("sem personagem") end
 cmd.grav = workspace.Gravity
 workspace.Gravity = 0
 for _, st in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
 if st ~= Enum.HumanoidStateType.None and st ~= Enum.HumanoidStateType.Swimming then
 pcall(function() h:SetStateEnabled(st, false) end)
 end
 end
 h:ChangeState(Enum.HumanoidStateType.Swimming)
 track(cmd, RunService.Heartbeat:Connect(function()
 local rr, hh = root(), hum()
 if rr and hh and hh.MoveDirection.Magnitude == 0 and not UIS:IsKeyDown(Enum.KeyCode.Space) then
 rr.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
 end
 end))
 end)

 add("lay", "Deita no chão", "Personagem", false, function()
 local h, r = hum(), root()
 if not h or not r then fail("sem personagem") end
 h.Sit = true
 task.wait(0.1)
 r.CFrame = r.CFrame * CFrame.Angles(math.pi * 0.5, 0, 0)
 for _, t in ipairs(h:GetPlayingAnimationTracks()) do pcall(function() t:Stop() end) end
 end)

 add("trip", "Tropeça e cai no chão", "Personagem", false, function()
 local h, r = hum(), root()
 if not h or not r then fail("sem personagem") end
 h:ChangeState(Enum.HumanoidStateType.FallingDown)
 r.AssemblyLinearVelocity = r.CFrame.LookVector * 30
 end)

 add("clickdelete", "Toque numa peça para apagar (só pra você)", "Mundo", true, function(on)
 local cmd = CmdByName.clickdelete
 unbind(cmd)
 if not on then return end
 track(cmd, UIS.InputBegan:Connect(function(input, processed)
 if processed then return end
 if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
 local cam = workspace.CurrentCamera
 if not cam then return end
 local ray = cam:ViewportPointToRay(input.Position.X, input.Position.Y)
 local params = RaycastParams.new()
 params.FilterType = Enum.RaycastFilterType.Exclude
 params.FilterDescendantsInstances = { Player.Character }
 local res = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
 if res and res.Instance and not res.Instance:IsA("Terrain") then
 pcall(function() res.Instance:Destroy() end)
 end
 end))
 end, { alias = { "cdelete" } })

 add("unlockworkspace", "Destrava todas as peças do mapa", "Mundo", false, function()
 for _, d in ipairs(workspace:GetDescendants()) do
 if d:IsA("BasePart") then pcall(function() d.Locked = false end) end
 end
 toast("Peças destravadas.", C.green)
 end, { alias = { "unlockws" } })
 end

  -- ================================================================
  -- NOVEX GOLD 2: aimbot, fling de verdade e mais comandos estilo Infinite Yield
  -- ================================================================
  do
    local function add(name, desc, cat, isToggle, fn, opt)
      if CmdByName[name] then return end
      opt = opt or {}
      local livres = {}
      for _, a in ipairs(opt.alias or {}) do
        if not CmdByName[a] and not Alias[a] then table.insert(livres, a) end
      end
      opt.alias = livres
      return addCmd(name, desc, cat, isToggle, fn, opt)
    end
    local function num(args, i, padrao) return tonumber(args and args[i or 1]) or padrao end
    local function eu()
      local r = root()
      if not r then fail("sem personagem") end
      return r
    end

    GUI.Destroying:Connect(function()
      pcall(function() RunService:UnbindFromRenderStep("NOVEX_Aim") end)
    end)

    -- ---------------------------------------------------------------
    -- AIMBOT (mira sozinha no jogador mais perto do centro da tela)
    -- ---------------------------------------------------------------
    local Aim = { part = "Head", fov = 220, smooth = 0.4, team = true, teamBot = true, teamAssist = true, wall = true, circle = nil }

    -- descobre se o jogador é do seu time (cada jogo faz time de um jeito, então tenta vários)
    function Aim.mesmoTime(p)
      if p.Team ~= nil and Player.Team ~= nil then return p.Team == Player.Team end
      local a, b = p:GetAttribute("Team"), Player:GetAttribute("Team")
      if a ~= nil and b ~= nil then return a == b end
      if p.Neutral == false and Player.Neutral == false then return p.TeamColor == Player.TeamColor end
      return false
    end

    -- devolve o que está na frente do alvo (ou nil se dá pra ver). Ignora outros jogadores,
    -- coisas transparentes e sem colisão (hitbox, parede invisível, vidro), que antes travavam a mira.
    local function aimBloqueio(parte, ch)
      local cam = workspace.CurrentCamera
      if not cam then return nil end
      local origem = cam.CFrame.Position
      local ignorar = { ch }
      for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Character then table.insert(ignorar, pl.Character) end
      end
      local params = RaycastParams.new()
      params.FilterType = Enum.RaycastFilterType.Exclude
      params.IgnoreWater = true
      params.FilterDescendantsInstances = ignorar
      for _ = 1, 8 do
        local r = workspace:Raycast(origem, parte.Position - origem, params)
        if not r then return nil end
        local h = r.Instance
        if h.Transparency >= 0.8 or not h.CanCollide then
          table.insert(ignorar, h)
          params.FilterDescendantsInstances = ignorar
        else
          return h
        end
      end
      return nil
    end

    local function aimVisible(parte, ch)
      return aimBloqueio(parte, ch) == nil
    end

    local function aimBest()
      local cam = workspace.CurrentCamera
      if not cam then return nil end
      local centro = cam.ViewportSize / 2
      local melhor, menor = nil, Aim.fov
      for _, p in ipairs(Players:GetPlayers()) do
        local ch = p.Character
        if p ~= Player and ch and not (Aim.teamBot and Aim.mesmoTime(p)) then
          local h = ch:FindFirstChildOfClass("Humanoid")
          local parte = ch:FindFirstChild(Aim.part) or ch:FindFirstChild("HumanoidRootPart")
          if h and h.Health > 0 and parte then
            local v, dentro = cam:WorldToViewportPoint(parte.Position)
            if dentro then
              local d = (Vector2.new(v.X, v.Y) - centro).Magnitude
              if d < menor and (not Aim.wall or aimVisible(parte, ch)) then
                melhor, menor = parte, d
              end
            end
          end
        end
      end
      return melhor
    end

    add("aimbot", "Mira sozinha no jogador mais perto do centro. Ex: aimbot head", "Jogadores", true, function(on, args)
      pcall(function() RunService:UnbindFromRenderStep("NOVEX_Aim") end)
      if Aim.circle then Aim.circle:Destroy() Aim.circle = nil end
      if not on then return end
      local a = string.lower(tostring(args and args[1] or ""))
      if a == "head" or a == "cabeca" then
        Aim.part = "Head"
      elseif a == "torso" or a == "body" or a == "corpo" then
        Aim.part = "HumanoidRootPart"
      end
      local c = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(Aim.fov * 2, Aim.fov * 2), BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 5,
      }, GUI)
      corner(c, Aim.fov)
      stroke(c, C.gold, 0.35, 2)
      Aim.circle = c
      RunService:BindToRenderStep("NOVEX_Aim", Enum.RenderPriority.Last.Value, function()
        local cam = workspace.CurrentCamera
        local alvo = aimBest()
        if cam and alvo then
          local ponto = CFrame.lookAt(cam.CFrame.Position, alvo.Position)
          cam.CFrame = cam.CFrame:Lerp(ponto, math.clamp(Aim.smooth, 0.02, 1))
        end
      end)
    end, { arg = "head ou torso", alias = { "aim", "lockon" } })

    add("aimfov", "Tamanho do círculo do aimbot. Ex: aimfov 150", "Jogadores", false, function(args)
      Aim.fov = math.clamp(num(args, 1, 220), 30, 800)
      if Aim.circle then
        Aim.circle.Size = UDim2.fromOffset(Aim.fov * 2, Aim.fov * 2)
        local cr = Aim.circle:FindFirstChildOfClass("UICorner")
        if cr then cr.CornerRadius = UDim.new(0, Aim.fov) end
      end
    end, { arg = "n" })

    add("aimsmooth", "Suavidade da mira: 0.05 devagar, 1 instantâneo. Ex: aimsmooth 0.3", "Jogadores", false, function(args)
      Aim.smooth = math.clamp(num(args, 1, 0.4), 0.02, 1)
    end, { arg = "0.05 a 1" })

    add("aimpart", "Onde o aimbot mira: head ou torso", "Jogadores", false, function(args)
      local a = string.lower(tostring(args and args[1] or ""))
      if a == "torso" or a == "body" or a == "corpo" then
        Aim.part = "HumanoidRootPart"
      else
        Aim.part = "Head"
      end
    end, { arg = "head ou torso" })

    add("aimwall", "Aimbot mira mesmo com parede na frente (liga/desliga)", "Jogadores", true, function(on)
      Aim.wall = not on
    end)

    -- liga/desliga o botão de um comando sem rodar ele (só atualiza o estado)
    function Aim.sinc(nome, estado)
      local c = CmdByName[nome]
      if c then
        c.state = estado
        for _, f in ipairs(c.syncs) do f(estado) end
      end
    end

    add("aimallies", "Mira também no seu time (liga/desliga). Vale pro aimbot, aimassist, aimpoder e meleeaim", "Jogadores", true, function(on)
      Aim.team, Aim.teamBot, Aim.teamAssist = not on, not on, not on
    end)

    -- AIMS SÓ NOS INIMIGOS: ligam o aim de verdade, já focado só nos inimigos (começam desligados).
    -- Jogo sem times: todo mundo conta como inimigo.
    do
      local function aviso(rotulo)
        local ok, n = pcall(function() return #game:GetService("Teams"):GetTeams() end)
        if ok and n == 0 then
          toast(rotulo .. " ligado. Esse jogo não tem times, então todos contam como inimigos", C.orange)
        else
          toast(rotulo .. " ligado só nos inimigos (seu time é ignorado)", C.green)
        end
      end

      -- quando o aim de baixo for desligado (por qualquer jeito), o botão "inimigos" desliga junto
      local ligados = {
        aimbot = { "aimbotinimigos", "aiminimigos" },
        aimassist = { "assistinimigos", "aiminimigos" },
      }

      local function ligarAim(nome, on, args)
        local c = CmdByName[nome]
        if not c then fail("o comando " .. nome .. " não existe") end
        if not c.syncInimigos then
          c.syncInimigos = true
          table.insert(c.syncs, function(estado)
            if not estado then
              for _, w in ipairs(ligados[nome] or {}) do Aim.sinc(w, false) end
            end
          end)
        end
        if on then
          if c.state then setToggle(c, false) end -- recomeça com os valores novos
          setToggle(c, true, args)
          if not c.state then fail(nome .. " não conseguiu ligar") end
        elseif c.state then
          setToggle(c, false)
        end
      end

      add("aimbotinimigos", "Liga o AIMBOT (mira que gruda) só nos inimigos. Ex: aimbotinimigos head", "Jogadores", true, function(on, args)
        if on then Aim.teamBot = true end
        ligarAim("aimbot", on, args)
        if on then aviso("Aimbot") else toast("Aimbot desligado", C.orange) end
      end, { arg = "head ou torso", alias = { "botinimigos", "aimbotenemies" } })

      add("assistinimigos", "Liga o AIM ASSIST (mira que puxa) só nos inimigos. Padrão: head 200 0.3. Ex: assistinimigos head 200 0.3", "Jogadores", true, function(on, args)
        if on then Aim.teamAssist = true end
        ligarAim("aimassist", on, args)
        if on then aviso("Aim assist") else toast("Aim assist desligado", C.orange) end
      end, { arg = "head|torso fov suavidade", alias = { "assistenemies", "aimassistinimigos" } })

      add("aiminimigos", "Liga o AIMBOT e o AIM ASSIST juntos, só nos inimigos. Ex: aiminimigos head", "Jogadores", true, function(on, args)
        if on then Aim.team, Aim.teamBot, Aim.teamAssist = true, true, true end
        ligarAim("aimbot", on, args)
        ligarAim("aimassist", on, args)
        if on then aviso("Aimbot + assist") else toast("Aimbot + assist desligados", C.orange) end
      end, { arg = "head ou torso", alias = { "soinimigos", "aimenemies", "enemyonly" } })
    end

    -- ---------------------------------------------------------------
    -- ESP SÓ DOS INIMIGOS (time contrário): contorno vermelho + nome, vida e distância
    -- Não mostra quem é do seu time. Se o jogo não tiver times, todos contam como inimigos.
    -- ---------------------------------------------------------------
    do
      local objs = {}
      local function limparUm(p)
        local o = objs[p]
        if o then
          for _, x in pairs(o) do pcall(function() x:Destroy() end) end
          objs[p] = nil
        end
      end
      local function limparTodos()
        for p in pairs(objs) do limparUm(p) end
      end
      local okCore, core = pcall(function() return game:GetService("CoreGui") end)
      local pai = (okCore and core) or workspace

      add("espinimigos", "ESP só dos inimigos (outro time): contorno vermelho, nome, vida e distância", "Visual", true, function(on)
        local cmd = CmdByName.espinimigos
        cmd.gen = (cmd.gen or 0) + 1
        local gen = cmd.gen
        limparTodos()
        if not on then return end
        task.spawn(function()
          while cmd.gen == gen and GUI.Parent do
            local r = root()
            for _, p in ipairs(Players:GetPlayers()) do
              local ch = p.Character
              local h = ch and ch:FindFirstChildOfClass("Humanoid")
              local cab = ch and ch:FindFirstChild("Head")
              if p ~= Player and h and cab and h.Health > 0 and not Aim.mesmoTime(p) then
                local o = objs[p]
                if not o or o.hl.Adornee ~= ch then
                  limparUm(p)
                  local hl = Instance.new("Highlight")
                  hl.Adornee = ch
                  hl.FillColor = C.red
                  hl.FillTransparency = 0.65
                  hl.OutlineColor = C.white
                  hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                  hl.Parent = pai
                  local bb = Instance.new("BillboardGui")
                  bb.Adornee = cab
                  bb.AlwaysOnTop = true
                  bb.Size = UDim2.fromOffset(170, 20)
                  bb.StudsOffset = Vector3.new(0, 2.4, 0)
                  bb.Parent = pai
                  local tl = Instance.new("TextLabel")
                  tl.Size = UDim2.fromScale(1, 1)
                  tl.BackgroundTransparency = 1
                  tl.TextColor3 = C.red
                  tl.TextStrokeTransparency = 0.3
                  tl.Font = BOLD
                  tl.TextSize = 13
                  tl.Parent = bb
                  o = { hl = hl, bb = bb, tl = tl }
                  objs[p] = o
                end
                local dist = r and math.floor((cab.Position - r.Position).Magnitude) or 0
                o.tl.Text = p.DisplayName .. " • " .. math.floor(h.Health) .. "hp • " .. dist .. "m"
              else
                limparUm(p)
              end
            end
            for p in pairs(objs) do
              if not p.Parent then limparUm(p) end
            end
            task.wait(0.3)
          end
          limparTodos()
        end)
      end, { alias = { "enemyesp", "espenemy", "espinimigo" } })
    end

    -- ---------------------------------------------------------------
    -- FLING DE VERDADE (gira em cima do jogador e arremessa ele)
    -- ---------------------------------------------------------------
    local flingBusy, flingStop = false, false

    -- Arremessa um jogador pra longe. forca = velocidade do empurrão (ex: 4000).
    -- Seu personagem NÃO gira: ele só atravessa o jogador na direção do lançamento.
    local function flingOne(alvo, forca)
      local c, r, h = Player.Character, root(), hum()
      local tc = alvo.Character
      local tr = tc and tc:FindFirstChild("HumanoidRootPart")
      local th = tc and tc:FindFirstChildOfClass("Humanoid")
      local parte = tr or (tc and tc:FindFirstChild("Head"))
      if not (c and r and h and tc and th and parte) then return false end
      forca = math.clamp(tonumber(forca) or 3000, 50, 100000)

      local origem = r.CFrame
      local camera = workspace.CurrentCamera
      local alturaVelha = workspace.FallenPartsDestroyHeight

      -- pausa a proteção só durante o seu fling (senão ela atrapalha o empurrão)
      Aim.antiPause = true
      if Aim.restoreCollide then pcall(Aim.restoreCollide) end
      pcall(function() workspace.FallenPartsDestroyHeight = 0 / 0 end)
      pcall(function() camera.CameraSubject = th end)
      pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end)

      -- direção do lançamento: pra longe de onde você estava, um pouco pra cima
      local dir = (parte.Position - origem.Position) * Vector3.new(1, 0, 1)
      if dir.Magnitude < 0.5 then
        local look = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
        dir = Vector3.new(look.X, 0, look.Z)
      end
      if dir.Magnitude < 0.1 then dir = Vector3.new(0, 0, -1) end
      dir = (dir.Unit + Vector3.new(0, 0.3, 0)).Unit

      local limiar = math.clamp(forca * 0.5, 30, 500)
      local offs = { Vector3.new(0, 0, 0), Vector3.new(0, 1.5, 0), Vector3.new(0, -1.5, 0) }
      local t0, i = os.clock(), 0
      while not flingStop and GUI.Parent and os.clock() - t0 < 2.5 do
        local rr = root()
        if not rr or not parte.Parent or th.Health <= 0 or alvo.Parent ~= Players then break end
        if parte.AssemblyLinearVelocity.Magnitude > limiar then break end
        i = i % #offs + 1
        local prev = th.MoveDirection * (parte.AssemblyLinearVelocity.Magnitude / 1.25)
        rr.CFrame = CFrame.new(parte.Position - dir * 1.2 + offs[i] + prev, parte.Position + dir)
        rr.AssemblyLinearVelocity = dir * forca
        rr.AssemblyAngularVelocity = Vector3.new()
        RunService.Heartbeat:Wait()
      end

      pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end)
      pcall(function() camera.CameraSubject = h end)
      pcall(function() workspace.FallenPartsDestroyHeight = alturaVelha end)

      -- volta pro lugar de onde saiu, parado
      for _ = 1, 20 do
        local rr = root()
        if not rr then break end
        rr.CFrame = origem
        for _, d in ipairs(c:GetDescendants()) do
          if d:IsA("BasePart") then
            d.AssemblyLinearVelocity = Vector3.new()
            d.AssemblyAngularVelocity = Vector3.new()
          end
        end
        RunService.Heartbeat:Wait()
      end
      return true
    end

    -- ---------------------------------------------------------------
    -- FLING (igual ao Infinite Yield): seu corpo gira em alta velocidade no lugar
    -- e arremessa quem encostar em você. Você NÃO teleporta em ninguém.
    -- ---------------------------------------------------------------
    local iyFling = { on = false, died = nil }

    local function flingOff()
      iyFling.on = false
      if iyFling.died then iyFling.died:Disconnect() iyFling.died = nil end
      Aim.antiPause = false
      local c = Player.Character
      if not c then return end
      for _, v in ipairs(c:GetDescendants()) do
        if v:IsA("BasePart") then
          v.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
          v.Massless = false
          v.AssemblyLinearVelocity = Vector3.new()
          v.AssemblyAngularVelocity = Vector3.new()
        elseif v:IsA("BodyAngularVelocity") and v.Name == "NOVEX_Fling" then
          v:Destroy()
        end
      end
    end

    add("fling", "Gira rápido e arremessa quem você encostar (igual ao Infinite Yield). Ex: fling", "Jogadores", true, function(on, args)
      local cmd = CmdByName.fling
      unbind(cmd)
      flingOff()
      if not on then return end
      local c, r, h = Player.Character, root(), hum()
      if not (c and r and h) then fail("sem personagem") end
      local forca = math.clamp(num(args, 1, 99999), 1000, 1000000)

      -- a proteção (antifling) é pausada enquanto o seu fling estiver ligado
      Aim.antiPause = true
      if Aim.restoreCollide then pcall(Aim.restoreCollide) end

      for _, v in ipairs(c:GetDescendants()) do
        if v:IsA("BasePart") then
          v.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
        end
      end
      -- só o SEU corpo atravessa as coisas (assim você não prende em nada)
      track(cmd, RunService.Stepped:Connect(function()
        local ch = Player.Character
        if not ch then return end
        for _, d in ipairs(ch:GetDescendants()) do
          if d:IsA("BasePart") and d.CanCollide then d.CanCollide = false end
        end
      end))

      local bav = Instance.new("BodyAngularVelocity")
      bav.Name = "NOVEX_Fling"
      bav.AngularVelocity = Vector3.new(0, forca, 0)
      bav.MaxTorque = Vector3.new(0, math.huge, 0)
      bav.P = math.huge
      bav.Parent = r
      for _, v in ipairs(c:GetChildren()) do
        if v:IsA("BasePart") then
          v.Massless = true
          v.AssemblyLinearVelocity = Vector3.new()
        end
      end

      iyFling.on = true
      iyFling.died = h.Died:Connect(function()
        if cmd.state then setToggle(cmd, false) end
      end)

      -- gira forte por 0.2s e para por 0.1s (esse intervalo é o que evita você morrer)
      task.spawn(function()
        while iyFling.on and bav.Parent and GUI.Parent do
          bav.AngularVelocity = Vector3.new(0, forca, 0)
          task.wait(0.2)
          bav.AngularVelocity = Vector3.new()
          task.wait(0.1)
        end
      end)
    end, { arg = "força (opcional)", alias = { "spinfling", "fling360", "giro" } })

    add("flingplayer", "Teleporta no jogador e arremessa. Ex: flingplayer nome 4000 (o fling normal é só: fling)", "Jogadores", false, function(args)
      if flingBusy then fail("espere o fling anterior acabar") end
      local qual, forca = args and args[1], tonumber(args and args[2])
      if tonumber(qual) then forca, qual = tonumber(qual), "nearest" end
      forca = forca or 3000
      local alvos = {}
      for _, p in ipairs(getTargets(qual)) do
        if p ~= Player then table.insert(alvos, p) end
      end
      if #alvos == 0 then fail("jogador não encontrado") end
      eu()
      flingBusy, flingStop = true, false
      task.spawn(function()
        for _, p in ipairs(alvos) do
          if flingStop or not GUI.Parent then break end
          pcall(flingOne, p, forca)
        end
        Aim.antiPause = false
        flingBusy = false
        toast("Fling terminou.", C.green)
      end)
    end, { arg = "jogador força", need = true, alias = { "yeet" } })

    add("loopflingplayer", "Fica arremessando o jogador sem parar. Ex: loopflingplayer nome 4000", "Jogadores", true, function(on, args)
      local cmd = CmdByName.loopflingplayer
      cmd.gen = (cmd.gen or 0) + 1
      local gen = cmd.gen
      if not on then flingStop = true return end
      local alvo = getTarget(args and args[1])
      if alvo == Player then fail("escolha outro jogador") end
      local forca = tonumber(args and args[2]) or 3000
      eu()
      flingStop = false
      task.spawn(function()
        while cmd.gen == gen and GUI.Parent and alvo.Parent == Players do
          if not flingBusy then
            flingBusy = true
            pcall(flingOne, alvo, forca)
            Aim.antiPause = false
            flingBusy = false
          end
          task.wait(0.4)
        end
      end)
    end, { arg = "jogador força", need = true })

    add("stopfling", "Para o fling na hora", "Jogadores", false, function()
      flingStop = true
      local c = CmdByName.fling
      if c and c.state then setToggle(c, false) end
    end, { alias = { "nofling" } })

    -- ---------------------------------------------------------------
    -- MAIS COMANDOS (estilo Infinite Yield)
    -- ---------------------------------------------------------------
    add("loopjump", "Fica pulando sem parar", "Movimento", true, function(on)
      local cmd = CmdByName.loopjump
      unbind(cmd)
      if not on then return end
      track(cmd, RunService.Heartbeat:Connect(function()
        local h = hum()
        if h and h.FloorMaterial ~= Enum.Material.Air then h:ChangeState(Enum.HumanoidStateType.Jumping) end
      end))
    end, { alias = { "loopj" } })

    add("loopspeed", "Segura a velocidade mesmo se o jogo mudar. Ex: loopspeed 60", "Movimento", true, function(on, args)
      local cmd = CmdByName.loopspeed
      unbind(cmd)
      if not on then return end
      local v = num(args, 1, 50)
      track(cmd, RunService.Heartbeat:Connect(function()
        local h = hum()
        if h then h.WalkSpeed = v end
      end))
    end, { arg = "n", alias = { "loopws" } })

    add("maxslope", "Inclinação máxima que você sobe. Ex: maxslope 89", "Movimento", false, function(args)
      local h = hum()
      if not h then fail("sem personagem") end
      h.MaxSlopeAngle = math.clamp(num(args, 1, 89), 0, 89)
    end, { arg = "graus", alias = { "slope" } })

    add("headsit", "Senta na cabeça de um jogador. Ex: headsit nome", "Movimento", true, function(on, args)
      local cmd = CmdByName.headsit
      unbind(cmd)
      local h0 = hum()
      if h0 then h0.Sit = false end
      if not on then return end
      local alvo = getTarget(args and args[1])
      track(cmd, RunService.Heartbeat:Connect(function()
        local r, hh = root(), hum()
        local cab = alvo.Character and alvo.Character:FindFirstChild("Head")
        if r and hh and cab then
          hh.Sit = true
          r.CFrame = cab.CFrame * CFrame.new(0, 1.6, 0)
          r.AssemblyLinearVelocity = Vector3.new()
        end
      end))
    end, { arg = "jogador", need = true })

    add("stare", "Fica olhando pra um jogador. Ex: stare nome", "Movimento", true, function(on, args)
      local cmd = CmdByName.stare
      unbind(cmd)
      if not on then return end
      local alvo = getTarget(args and args[1])
      track(cmd, RunService.Heartbeat:Connect(function()
        local r = root()
        local tr = alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart")
        if r and tr then
          r.CFrame = CFrame.lookAt(r.Position, Vector3.new(tr.Position.X, r.Position.Y, tr.Position.Z))
        end
      end))
    end, { arg = "jogador", need = true, alias = { "lookat" } })

    add("breakvelocity", "Zera a sua velocidade (se ficou preso girando)", "Movimento", false, function()
      local c = Player.Character
      if not c then fail("sem personagem") end
      for _, d in ipairs(c:GetDescendants()) do
        if d:IsA("BasePart") then
          d.AssemblyLinearVelocity = Vector3.new()
          d.AssemblyAngularVelocity = Vector3.new()
        end
      end
    end, { alias = { "stopvel", "bv0" } })

    add("freecam", "Câmera livre: o personagem fica parado. Ex: freecam 3", "Câmera", true, function(on, args)
      local cmd = CmdByName.freecam
      unbind(cmd)
      local cam, h, r = workspace.CurrentCamera, hum(), root()
      if not on then
        if r then r.Anchored = false end
        if cam then
          cam.CameraType = Enum.CameraType.Custom
          if h then cam.CameraSubject = h end
        end
        return
      end
      if not (cam and h and r) then fail("sem personagem") end
      local vel = num(args, 1, 3)
      local pit, yaw = cam.CFrame:ToOrientation()
      local pos = cam.CFrame.Position
      r.Anchored = true
      cam.CameraType = Enum.CameraType.Scriptable
      track(cmd, UIS.InputChanged:Connect(function(i, processed)
        if processed then return end
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then
          yaw = yaw - i.Delta.X * 0.005
          pit = math.clamp(pit - i.Delta.Y * 0.005, -1.4, 1.4)
        end
      end))
      track(cmd, RunService.RenderStepped:Connect(function(dt)
        local hh = hum()
        if not hh then return end
        pos = pos + hh.MoveDirection * vel * 20 * dt
        if hh.Jump then pos = pos + Vector3.new(0, vel * 20 * dt, 0) end
        cam.CFrame = CFrame.new(pos) * CFrame.fromOrientation(pit, yaw, 0)
      end))
    end, { arg = "velocidade", alias = { "fc" } })

    add("reach", "Aumenta o alcance da arma na mão. Ex: reach 15", "Personagem", true, function(on, args)
      local cmd = CmdByName.reach
      unbind(cmd)
      for hd, s in pairs(cmd.orig or {}) do pcall(function() hd.Size = s end) end
      cmd.orig = {}
      if not on then return end
      local n = num(args, 1, 15)
      track(cmd, RunService.Heartbeat:Connect(function()
        local c = Player.Character
        if not c then return end
        for _, t in ipairs(c:GetChildren()) do
          if t:IsA("Tool") then
            local hd = t:FindFirstChild("Handle")
            if hd and hd:IsA("BasePart") then
              if not cmd.orig[hd] then cmd.orig[hd] = hd.Size end
              hd.Massless = true
              hd.Size = Vector3.new(hd.Size.X, hd.Size.Y, n)
            end
          end
        end
      end))
    end, { arg = "n" })

    add("notools", "Apaga todas as suas ferramentas", "Personagem", false, function()
      for _, t in ipairs(Player.Backpack:GetChildren()) do t:Destroy() end
      local c = Player.Character
      if c then
        for _, t in ipairs(c:GetChildren()) do
          if t:IsA("Tool") then t:Destroy() end
        end
      end
    end, { alias = { "removetools" } })

    add("nohats", "Tira os acessórios do seu personagem", "Personagem", false, function()
      local c = Player.Character
      if not c then fail("sem personagem") end
      for _, a in ipairs(c:GetChildren()) do
        if a:IsA("Accessory") then a:Destroy() end
      end
    end, { alias = { "removehats", "nohat" } })

    add("noface", "Tira o rosto do seu personagem", "Personagem", false, function()
      local c = Player.Character
      local hd = c and c:FindFirstChild("Head")
      local f = hd and hd:FindFirstChildOfClass("Decal")
      if not f then fail("sem rosto pra tirar") end
      f:Destroy()
    end)

    add("light", "Luz em volta de você. Ex: light 40", "Visual", true, function(on, args)
      local cmd = CmdByName.light
      if cmd.obj then cmd.obj:Destroy() cmd.obj = nil end
      if not on then return end
      local r = eu()
      local l = Instance.new("PointLight")
      l.Range = num(args, 1, 40)
      l.Brightness = 3
      l.Parent = r
      cmd.obj = l
    end, { arg = "alcance", alias = { "lamp" } })

    add("nosky", "Tira o céu", "Visual", true, function(on)
      local cmd = CmdByName.nosky
      if cmd.sky then cmd.sky.Parent = Lighting cmd.sky = nil end
      if not on then return end
      local s = Lighting:FindFirstChildOfClass("Sky")
      if not s then fail("esse jogo não tem céu") end
      cmd.sky = s
      s.Parent = nil
    end)

    add("nodecals", "Tira as texturas do mapa (menos lag)", "Visual", false, function()
      task.spawn(function()
        local n = 0
        for _, d in ipairs(workspace:GetDescendants()) do
          if d:IsA("Decal") or d:IsA("Texture") then pcall(function() d.Transparency = 1 end) end
          n = n + 1
          if n % 500 == 0 then task.wait() end
        end
        toast("Texturas tiradas.", C.green)
      end)
    end, { alias = { "notextures" } })

    add("noterrain", "Apaga o terreno (só pra você)", "Mundo", false, function()
      workspace.Terrain:Clear()
    end, { alias = { "removeterrain" } })

    add("tptool", "Te dá uma ferramenta que teleporta pro ponto que você tocar", "Ferramentas", false, function()
      local t = Instance.new("Tool")
      t.Name = "Teleport"
      t.RequiresHandle = false
      t.Parent = Player.Backpack
      t.Activated:Connect(function()
        local r = root()
        local m = Player:GetMouse()
        if r and m and m.Hit then r.CFrame = CFrame.new(m.Hit.Position + Vector3.new(0, 3, 0)) end
      end)
    end, { alias = { "tpt" } })

    local function emote(nome)
      local h = hum()
      if not h then fail("sem personagem") end
      local ok = pcall(function() h:PlayEmote(nome) end)
      if not ok then fail("esse jogo não aceita emotes") end
    end
    add("emote", "Faz um emote. Ex: emote dance", "Personagem", false, function(args)
      emote(string.lower(tostring(args and args[1] or "dance")))
    end, { arg = "nome" })
    for _, e in ipairs({ "dance", "wave" }) do
      add(e, "Faz o emote " .. e, "Personagem", false, function() emote(e) end, { exact = true })
    end

    -- ---------------------------------------------------------------
    -- PROTEÇÃO (antifling, antivoid, antikick) + AIM ASSIST + MELEE AIM
    -- ---------------------------------------------------------------
    do
      -- as versões novas de antifling/antivoid (abaixo) substituem as antigas
      for _, nome in ipairs({ "antifling", "antivoid" }) do
        local velho = CmdByName[nome]
        if velho then
          pcall(unbind, velho)
          CmdByName[nome] = nil
          for i, c in ipairs(Cmds) do
            if c == velho then table.remove(Cmds, i) break end
          end
        end
      end
      local tocados = setmetatable({}, { __mode = "k" })
      local function restaurarColisao()
        for parte in pairs(tocados) do
          if parte and parte.Parent then pcall(function() parte.CanCollide = true end) end
        end
        tocados = setmetatable({}, { __mode = "k" })
      end
      Aim.restoreCollide = restaurarColisao

      GUI.Destroying:Connect(function()
        pcall(function() RunService:UnbindFromRenderStep("NOVEX_Poder") end)
        pcall(function() RunService:UnbindFromRenderStep("NOVEX_NoRecoil") end)
        restaurarColisao()
        Aim.noKick = false
        pcall(function() RunService:UnbindFromRenderStep("NOVEX_Assist") end)
      end)

      add("antifling", "Ninguém te arremessa nem te empurra forte. Fica ligado mesmo se você morrer", "Proteção", true, function(on)
        local cmd = CmdByName.antifling
        unbind(cmd)
        restaurarColisao()
        if not on then return end
        local seguro = nil

        -- 1) seu personagem deixa de bater nas partes dos outros jogadores (perto de você)
        track(cmd, RunService.Stepped:Connect(function()
          if Aim.antiPause then return end
          local r = root()
          if not r then return end
          for _, p in ipairs(Players:GetPlayers()) do
            local ch = p ~= Player and p.Character
            local pr = ch and ch:FindFirstChild("HumanoidRootPart")
            if pr and (pr.Position - r.Position).Magnitude < 120 then
              for _, d in ipairs(ch:GetDescendants()) do
                if d:IsA("BasePart") and d.CanCollide then
                  tocados[d] = true
                  d.CanCollide = false
                end
              end
            end
          end
        end))

        -- 2) se mesmo assim você for lançado, para na hora e volta pro último lugar seguro
        track(cmd, RunService.Heartbeat:Connect(function()
          if Aim.antiPause then return end
          local r, h = root(), hum()
          if not (r and h) or h.SeatPart then return end
          local v, w = r.AssemblyLinearVelocity.Magnitude, r.AssemblyAngularVelocity.Magnitude
          if v > 400 or w > 80 then
            for _, d in ipairs(Player.Character:GetDescendants()) do
              if d:IsA("BasePart") then
                d.AssemblyLinearVelocity = Vector3.new()
                d.AssemblyAngularVelocity = Vector3.new()
              end
            end
            if seguro then r.CFrame = seguro end
          elseif v < 60 then
            seguro = r.CFrame
          end
        end))
      end, { alias = { "af" } })

      add("antivoid", "Se cair no vazio, volta pro último lugar seguro (liga/desliga)", "Proteção", true, function(on)
        local cmd = CmdByName.antivoid
        unbind(cmd)
        if not on then return end
        local seguro = nil
        track(cmd, RunService.Heartbeat:Connect(function()
          if Aim.antiPause then return end
          local r, h = root(), hum()
          if not (r and h) or h.Health <= 0 then return end
          if h.FloorMaterial ~= Enum.Material.Air and r.AssemblyLinearVelocity.Magnitude < 100 then
            seguro = r.CFrame
          end
          local limite = workspace.FallenPartsDestroyHeight
          local alt = -400
          if limite == limite and limite > -100000 then alt = limite + 60 end
          if seguro and r.Position.Y < alt then
            r.AssemblyLinearVelocity = Vector3.new()
            r.CFrame = seguro + Vector3.new(0, 4, 0)
          end
        end))
      end, { alias = { "av" } })

      add("antikick", "Bloqueia expulsão feita pelos scripts do jogo no seu lado (não segura kick do servidor)", "Proteção", true, function(on)
        if not (hookmetamethod and getnamecallmethod) then
          fail("seu executor não suporta o antikick")
        end
        Aim.noKick = on
        if Aim.kickHooked then return end
        Aim.kickHooked = true
        local antigo
        local function novoNamecall(self, ...)
          if Aim.noKick and self == Player and string.lower(tostring(getnamecallmethod())) == "kick" then
            return nil
          end
          return antigo(self, ...)
        end
        antigo = hookmetamethod(game, "__namecall", newcclosure and newcclosure(novoNamecall) or novoNamecall)
      end, { alias = { "ak" } })

      add("protecao", "Liga tudo de uma vez: antifling, antivoid e antikick", "Proteção", true, function(on)
        for _, n in ipairs({ "antifling", "antivoid", "antikick" }) do
          local c = CmdByName[n]
          if c and c.state ~= on then setToggle(c, on) end
        end
      end, { alias = { "protect", "shield" } })

      -- AIM ASSIST: ajuda leve de mira, pra jogos com arma
      add("aimassist", "Ajuda de mira (jogos com arma). Padrão: head 200 0.3. Ex: aimassist head 200 0.3", "Jogadores", true, function(on, args)
        pcall(function() RunService:UnbindFromRenderStep("NOVEX_Assist") end)
        local cmd = CmdByName.aimassist
        unbind(cmd)
        if not on then return end
        local parteNome, fov, suave = "Head", 200, 0.3
        for _, a in ipairs(args or {}) do
          local s = string.lower(tostring(a))
          if s == "torso" or s == "body" or s == "corpo" then
            parteNome = "HumanoidRootPart"
          elseif s == "head" or s == "cabeca" then
            parteNome = "Head"
          elseif tonumber(s) then
            local n = tonumber(s)
            if n <= 1 then suave = math.clamp(n, 0.02, 1) else fov = math.clamp(n, 20, 600) end
          end
        end
        local function melhorAlvo()
          local cam = workspace.CurrentCamera
          if not cam then return nil end
          local centro = cam.ViewportSize / 2
          local melhor, menor = nil, fov
          for _, p in ipairs(Players:GetPlayers()) do
            local ch = p.Character
            if p ~= Player and ch and not (Aim.teamAssist and Aim.mesmoTime(p)) then
              local h = ch:FindFirstChildOfClass("Humanoid")
              local parte = ch:FindFirstChild(parteNome) or ch:FindFirstChild("HumanoidRootPart")
              if h and h.Health > 0 and parte then
                local v, dentro = cam:WorldToViewportPoint(parte.Position)
                if dentro then
                  local d = (Vector2.new(v.X, v.Y) - centro).Magnitude
                  if d < menor and aimVisible(parte, ch) then melhor, menor = parte, d end
                end
              end
            end
          end
          return melhor
        end
        RunService:BindToRenderStep("NOVEX_Assist", Enum.RenderPriority.Last.Value, function()
          local cam = workspace.CurrentCamera
          local alvo = melhorAlvo()
          if cam and alvo then
            cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, alvo.Position), suave)
          end
        end)
        track(cmd, { Disconnect = function()
          pcall(function() RunService:UnbindFromRenderStep("NOVEX_Assist") end)
        end })
      end, { arg = "head|torso fov suavidade", alias = { "assist" } })

      -- MELEE AIM: jogos SEM arma (espada, soco). Vira o corpo pro inimigo mais perto
      add("meleeaim", "Jogos sem arma: vira seu corpo pro inimigo mais perto. Ex: meleeaim 15", "Jogadores", true, function(on, args)
        local cmd = CmdByName.meleeaim
        unbind(cmd)
        local h0 = hum()
        if h0 then h0.AutoRotate = true end
        if not on then return end
        local alcance = math.clamp(num(args, 1, 15), 3, 100)
        track(cmd, RunService.Heartbeat:Connect(function()
          local r, h = root(), hum()
          if not (r and h) or h.Health <= 0 then return end
          local melhor, menor = nil, alcance
          for _, p in ipairs(Players:GetPlayers()) do
            local ch = p.Character
            if p ~= Player and ch and not (Aim.team and Aim.mesmoTime(p)) then
              local tr = ch:FindFirstChild("HumanoidRootPart")
              local th = ch:FindFirstChildOfClass("Humanoid")
              if tr and th and th.Health > 0 then
                local d = (tr.Position - r.Position).Magnitude
                if d < menor then melhor, menor = tr, d end
              end
            end
          end
          if melhor then
            local alvo = Vector3.new(melhor.Position.X, r.Position.Y, melhor.Position.Z)
            if (alvo - r.Position).Magnitude > 0.1 then
              h.AutoRotate = false
              r.CFrame = r.CFrame:Lerp(CFrame.lookAt(r.Position, alvo), 0.35)
            end
          else
            h.AutoRotate = true
          end
        end))
      end, { arg = "alcance", alias = { "meleeassist", "faceaim" } })

      -- AIM PARA JOGOS DE PODERES: câmera e corpo viram pro inimigo mais perto, com previsão de movimento
      add("aimpoder", "Aim assist pra jogos de poderes: mira no inimigo mais perto com previsão. Padrão: alcance 60 e suavidade 0.3. Ex: aimpoder 60 0.3", "Jogadores", true, function(on, args)
        pcall(function() RunService:UnbindFromRenderStep("NOVEX_Poder") end)
        local cmd = CmdByName.aimpoder
        unbind(cmd)
        local h0 = hum()
        if h0 then h0.AutoRotate = true end
        if not on then return end
        local alcance = math.clamp(num(args, 1, 60), 5, 500)
        local suave = math.clamp(num(args, 2, 0.3), 0.03, 1)
        local previsao = 0.12
        RunService:BindToRenderStep("NOVEX_Poder", Enum.RenderPriority.Camera.Value + 1, function()
          local cam, r, h = workspace.CurrentCamera, root(), hum()
          if not (cam and r and h) or h.Health <= 0 then return end
          local melhor, menor = nil, alcance
          for _, p in ipairs(Players:GetPlayers()) do
            local ch = p.Character
            if p ~= Player and ch and not (Aim.team and Aim.mesmoTime(p)) then
              local tr = ch:FindFirstChild("HumanoidRootPart")
              local th = ch:FindFirstChildOfClass("Humanoid")
              if tr and th and th.Health > 0 then
                local d = (tr.Position - r.Position).Magnitude
                if d < menor then
                  local _, dentro = cam:WorldToViewportPoint(tr.Position)
                  if dentro then melhor, menor = tr, d end
                end
              end
            end
          end
          if melhor then
            local ponto = melhor.Position + melhor.AssemblyLinearVelocity * previsao
            cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, ponto), suave)
            local plano = Vector3.new(ponto.X, r.Position.Y, ponto.Z)
            if (plano - r.Position).Magnitude > 0.5 then
              h.AutoRotate = false
              r.CFrame = r.CFrame:Lerp(CFrame.lookAt(r.Position, plano), 0.3)
            end
          else
            h.AutoRotate = true
          end
        end)
        track(cmd, { Disconnect = function()
          pcall(function() RunService:UnbindFromRenderStep("NOVEX_Poder") end)
          local hh = hum()
          if hh then hh.AutoRotate = true end
        end })
      end, { arg = "alcance suavidade", alias = { "powerassist", "poderaim" } })

      -- NO RECOIL (melhor esforço): zera "recoil" guardado na arma e segura a câmera quando a arma puxa pra cima
      local NR = { undo = {}, seen = {}, drag = false, last = nil }
      local function nrMarcar(chave, sub)
        NR.seen[chave] = NR.seen[chave] or {}
        if NR.seen[chave][sub] then return false end
        NR.seen[chave][sub] = true
        return true
      end
      local function nrTabela(t, fundo)
        if type(t) ~= "table" or fundo > 3 then return end
        for k, v in pairs(t) do
          if type(v) == "number" and string.find(string.lower(tostring(k)), "recoil", 1, true) then
            if nrMarcar(t, k) then
              table.insert(NR.undo, function() pcall(function() t[k] = v end) end)
            end
            pcall(function() t[k] = 0 end)
          elseif type(v) == "table" then
            nrTabela(v, fundo + 1)
          end
        end
      end
      local function nrFerramenta(t)
        for _, d in ipairs(t:GetDescendants()) do
          if (d:IsA("NumberValue") or d:IsA("IntValue")) and string.find(string.lower(d.Name), "recoil", 1, true) then
            local velho = d.Value
            if nrMarcar(d, "v") then table.insert(NR.undo, function() pcall(function() d.Value = velho end) end) end
            d.Value = 0
          elseif d:IsA("ModuleScript") and require then
            local ok, m = pcall(require, d)
            if ok then nrTabela(m, 0) end
          end
        end
        for nome, v in pairs(t:GetAttributes()) do
          if type(v) == "number" and string.find(string.lower(nome), "recoil", 1, true) then
            if nrMarcar(t, nome) then table.insert(NR.undo, function() pcall(function() t:SetAttribute(nome, v) end) end) end
            t:SetAttribute(nome, 0)
          end
        end
      end

      add("norecoil", "Sem recuo de arma (melhor esforço, depende do jogo)", "Jogadores", true, function(on)
        pcall(function() RunService:UnbindFromRenderStep("NOVEX_NoRecoil") end)
        local cmd = CmdByName.norecoil
        unbind(cmd)
        for _, f in ipairs(NR.undo) do f() end
        NR.undo, NR.seen, NR.last, NR.drag = {}, {}, nil, false
        if not on then return end

        track(cmd, UIS.InputChanged:Connect(function(i, processed)
          if processed then return end
          if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then
            if i.Delta.Magnitude > 0 then NR.drag = true end
          end
        end))

        RunService:BindToRenderStep("NOVEX_NoRecoil", Enum.RenderPriority.Camera.Value + 2, function()
          local cam, c = workspace.CurrentCamera, Player.Character
          local arma = c and c:FindFirstChildOfClass("Tool")
          if not cam or not arma then NR.last, NR.drag = nil, false return end
          local pit, yaw = cam.CFrame:ToOrientation()
          if NR.drag or NR.last == nil then
            NR.last = pit
          elseif pit - NR.last > 0.0008 then
            cam.CFrame = CFrame.new(cam.CFrame.Position) * CFrame.fromOrientation(NR.last, yaw, 0)
          else
            NR.last = pit
          end
          NR.drag = false
        end)

        task.spawn(function()
          while cmd.gen == nil and GUI.Parent do
            local c = Player.Character
            if c then
              for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") then pcall(nrFerramenta, t) end end
            end
            for _, t in ipairs(Player.Backpack:GetChildren()) do
              if t:IsA("Tool") then pcall(nrFerramenta, t) end
            end
            task.wait(1)
            if not cmd.state and #cmd.conns == 0 then break end
          end
        end)

        track(cmd, { Disconnect = function()
          pcall(function() RunService:UnbindFromRenderStep("NOVEX_NoRecoil") end)
        end })
      end, { alias = { "nr", "semrecuo" } })

      -- ---------------------------------------------------------------
      -- VARREDOR DE VALORES (base de "forca", "danotiro", "semrecarga" e "buscavalor")
      -- Procura sozinho números com certos nomes: no seu personagem, nas suas armas,
      -- no seu jogador, no ReplicatedStorage e nos módulos que o jogo já carregou.
      -- Depois troca pelo número que você escolher (ou só testa, no buscavalor).
      -- IMPORTANTE: se o jogo guarda a força/dano só no servidor, nada disso vale.
      -- ---------------------------------------------------------------
      do
        local RepStorage = game:GetService("ReplicatedStorage")
        local painelBusca = nil

        local function novoVarredor(palavras)
          local V = { palavras = palavras, evitar = {}, undo = {}, seen = {}, achados = {}, lista = {} }
          local function bate(nome)
            nome = string.lower(tostring(nome))
            for _, w in ipairs(V.evitar) do
              if string.find(nome, w, 1, true) then return false end
            end
            for _, w in ipairs(V.palavras) do
              if string.find(nome, w, 1, true) then return true end
            end
            return false
          end
          local function marcar(chave, sub)
            V.seen[chave] = V.seen[chave] or {}
            if V.seen[chave][sub] then return false end
            V.seen[chave][sub] = true
            return true
          end
          -- guarda o achado (só na primeira vez) e, se tiver valor novo, grava ele
          local function achar(chave, sub, nome, tipo, velho, gravar, ler, valor)
            if marcar(chave, sub) then
              table.insert(V.achados, nome .. " = " .. tostring(velho))
              table.insert(V.lista, { nome = nome, tipo = tipo, orig = velho, gravar = gravar, ler = ler })
              if valor ~= nil then
                table.insert(V.undo, function() pcall(gravar, velho) end)
              end
            end
            if valor ~= nil then pcall(gravar, valor) end
          end
          local function tabela(t, caminho, fundo, valor, visto, tipo)
            if type(t) ~= "table" or fundo > 3 or visto[t] then return end
            visto[t] = true
            for k, v in pairs(t) do
              if type(v) == "number" and bate(k) then
                achar(t, k, caminho .. "." .. tostring(k), tipo, v,
                  function(x) t[k] = x end, function() return t[k] end, valor)
              elseif type(v) == "table" then
                tabela(v, caminho .. "." .. tostring(k), fundo + 1, valor, visto, tipo)
              end
            end
          end
          local function instancia(i, valor, modulos)
            if valor ~= nil and (i.Name == "leaderstats" or i:FindFirstAncestor("leaderstats")) then return end
            if (i:IsA("NumberValue") or i:IsA("IntValue")) and bate(i.Name) then
              achar(i, "v", i:GetFullName(), "valor", i.Value,
                function(x) i.Value = x end, function() return i.Value end, valor)
            elseif modulos and i:IsA("ModuleScript") and require then
              local ok, m = pcall(require, i)
              if ok then pcall(tabela, m, i.Name, 0, valor, {}, "modulo") end
            end
            for nome, v in pairs(i:GetAttributes()) do
              if type(v) == "number" and bate(nome) then
                achar(i, "@" .. nome, i:GetFullName() .. "@" .. nome, "atributo", v,
                  function(x) i:SetAttribute(nome, x) end, function() return i:GetAttribute(nome) end, valor)
              end
            end
          end
          -- completo = procura também no jogo todo (mais lento); bruto = olha toda a memória (mais lento ainda)
          function V.varrer(valor, completo, bruto)
            local raizes = {}
            if Player.Character then table.insert(raizes, Player.Character) end
            if Player:FindFirstChild("Backpack") then table.insert(raizes, Player.Backpack) end
            -- as pastas do jogador (placar, estatísticas) só são LIDAS (buscavalor), nunca alteradas
            if valor == nil then
              for _, f in ipairs(Player:GetChildren()) do
                if not f:IsA("PlayerGui") and f.Name ~= "PlayerScripts" and f.Name ~= "Backpack" then
                  table.insert(raizes, f)
                end
              end
              pcall(instancia, Player, valor, false)
            end
            for _, raiz in ipairs(raizes) do
              pcall(instancia, raiz, valor, true)
              for _, d in ipairs(raiz:GetDescendants()) do pcall(instancia, d, valor, true) end
            end
            if not completo then return end
            -- valores soltos no ReplicatedStorage (configuração de armas e itens)
            pcall(function()
              for n, d in ipairs(RepStorage:GetDescendants()) do
                pcall(instancia, d, valor, false)
                if n % 400 == 0 then task.wait() end
              end
            end)
            -- módulos que o próprio jogo já carregou (onde as armas costumam guardar o dano)
            if type(getloadedmodules) == "function" then
              local ok, mods = pcall(getloadedmodules)
              if ok and type(mods) == "table" then
                for n, m in ipairs(mods) do
                  pcall(function()
                    local caminho = m:GetFullName()
                    if string.find(caminho, "CoreGui", 1, true) or string.find(caminho, "RobloxGui", 1, true)
                      or string.find(caminho, "PlayerModule", 1, true) then return end
                    local okr, t = pcall(require, m)
                    if okr and type(t) == "table" then tabela(t, m.Name, 0, valor, {}, "modulo") end
                  end)
                  if n % 25 == 0 then task.wait() end
                end
              end
            end
            if bruto and type(getgc) == "function" then
              local ok, gc = pcall(getgc, true)
              if ok and type(gc) == "table" then
                for n, t in ipairs(gc) do
                  if type(t) == "table" then pcall(tabela, t, "gc", 2, valor, {}, "gc") end
                  if n % 1500 == 0 then task.wait() end
                end
              end
            end
          end
          function V.desfazer()
            for _, f in ipairs(V.undo) do f() end
            V.undo, V.seen, V.achados, V.lista = {}, {}, {}, {}
          end
          return V
        end

        local VForca = novoVarredor({})
        local VTiro = novoVarredor({})
        local VRecarga = novoVarredor({})
        X.scanners = {
          { V = VForca, cmd = "forcavalor", nome = "valor de força" },
          { V = VTiro, cmd = "danotiro", nome = "dano" },
          { V = VRecarga, cmd = "semrecarga", nome = "tempo de recarga" },
        }

        local function ligarVarredor(V, cmd, valor, palavras, rotulo, evitar, bruto)
          cmd.gen = (cmd.gen or 0) + 1
          local gen = cmd.gen
          V.desfazer()
          V.alvo = valor
          V.palavras = palavras
          V.evitar = evitar or {}
          toast("Procurando " .. rotulo .. "...", C.orange)
          task.spawn(function()
            V.varrer(valor, true, bruto)
            if cmd.gen ~= gen then V.desfazer() return end
            if #V.lista == 0 then
              toast("Não achei " .. rotulo .. " do seu lado. Use buscavalor", C.orange)
            else
              local soServidor = true
              for _, e in ipairs(V.lista) do
                if e.tipo ~= "valor" and e.tipo ~= "atributo" then soServidor = false break end
              end
              if soServidor then
                toast(#V.lista .. " achados, mas são do servidor (só na sua tela)", C.orange)
              else
                toast(#V.lista .. " valores de " .. rotulo .. " ajustados", C.green)
              end
            end
            while cmd.gen == gen and GUI.Parent do
              task.wait(1)
              if cmd.gen ~= gen then break end
              pcall(V.varrer, valor, false)
            end
          end)
        end

        -- lê os argumentos: número = valor, "bruto" = busca pesada, outra palavra = nome a procurar
        local function lerArgs(args)
          local valor, bruto, palavra
          for _, a in ipairs(args or {}) do
            local s = string.lower(tostring(a))
            if tonumber(s) then
              valor = tonumber(s)
            elseif s == "bruto" then
              bruto = true
            else
              palavra = s
            end
          end
          return valor, bruto, palavra
        end

        add("forcavalor", "Muda o valor de força guardado no jogo (só vale se o jogo ler do seu lado). Ex: forcavalor 500", "Personagem", true, function(on, args)
          local cmd = CmdByName.forcavalor
          if not on then
            cmd.gen = (cmd.gen or 0) + 1
            VForca.desfazer()
            return
          end
          local valor, bruto, palavra = lerArgs(args)
          local palavras = palavra and { palavra } or { "strength", "punch", "forca", "força", "power", "knockback" }
          local evitar = palavra and {} or { "jump", "cooldown", "delay", "range", "walk", "total", "level", "exp", "xp", "record", "best", "score", "rank" }
          ligarVarredor(VForca, cmd, valor or 100, palavras, "força", evitar, bruto)
        end, { arg = "número [bruto]", need = true, alias = { "strength", "punchpower" } })

        add("danotiro", "Aumenta o dano dos tiros e das armas (acha sozinho). Ex: danotiro 100 | danotiro 100 bruto", "Personagem", true, function(on, args)
          local cmd = CmdByName.danotiro
          if not on then
            cmd.gen = (cmd.gen or 0) + 1
            VTiro.desfazer()
            return
          end
          local valor, bruto, palavra = lerArgs(args)
          local palavras = palavra and { palavra } or { "damage", "dmg", "dano", "headshot" }
          local evitar = palavra and {} or { "reduc", "resist", "taken", "armor", "cooldown", "delay", "range", "speed", "rate", "time", "total", "dealt", "lifetime", "record", "best", "score", "session", "rank" }
          ligarVarredor(VTiro, cmd, valor or 100, palavras, "dano do tiro", evitar, bruto)
        end, { arg = "número [bruto]", need = true, alias = { "shotdamage", "tirodano" } })

        add("semrecarga", "Tira a recarga das habilidades e armas (melhor esforço). Ex: semrecarga | semrecarga 0 reload", "Personagem", true, function(on, args)
          local cmd = CmdByName.semrecarga
          if not on then
            cmd.gen = (cmd.gen or 0) + 1
            VRecarga.desfazer()
            return
          end
          local valor = num(args, 1, 0)
          local filtro = args and args[2] and string.lower(tostring(args[2]))
          local palavras = filtro and { filtro } or { "cooldown", "reload", "recarga", "delay" }
          ligarVarredor(VRecarga, cmd, valor, palavras, "recarga")
        end, { arg = "[número] [palavra]", alias = { "nocooldown", "nocd" } })

        -- BUSCAVALOR: acha os valores sozinho, TESTA cada um e diz se dá pra alterar
        -- Teste: troca o número, espera um instante e vê se o jogo/servidor devolveu o valor antigo.
        local function testarEntradas(V)
          local lista = V.lista
          local teste = {}
          for i, e in ipairs(lista) do
            local ok, antes = pcall(e.ler)
            e.antes = ok and antes or e.orig
            teste[i] = (tonumber(e.antes) or 0) * 2 + 7
            e.erro = not (pcall(e.gravar, teste[i]))
          end
          task.wait(0.6)
          for i, e in ipairs(lista) do
            local ok, agora = pcall(e.ler)
            e.ficou = (not e.erro) and ok and type(agora) == "number" and math.abs(agora - teste[i]) < 0.01
            pcall(e.gravar, e.antes)
          end
        end

        -- devolve: ícone, texto, cor e ordem de importância
        local function veredito(e)
          if e.erro then return "❌", "NÃO ALTERA (o jogo bloqueia)", C.red, 3 end
          if not e.ficou then return "❌", "NÃO ALTERA (o servidor desfaz)", C.red, 3 end
          if e.tipo == "valor" or e.tipo == "atributo" then
            return "⚠️", "SÓ NA SUA TELA (valor do servidor)", C.orange, 2
          end
          return "✅", "PODE ALTERAR (o jogo lê do seu lado)", C.green, 1
        end

        local function curto(nome)
          local s = (string.gsub(nome, "^Players%.[^%.]+%.", ""))
          if #s > 70 then s = "…" .. string.sub(s, -68) end
          return s
        end

        local function abrirPainel(titulo, linhas)
          if painelBusca then pcall(function() painelBusca:Destroy() end) end
          local f = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(0.92, 0, 0.7, 0), BackgroundColor3 = C.black,
            BackgroundTransparency = 0.05, BorderSizePixel = 0, ZIndex = 80,
          }, GUI)
          create("UISizeConstraint", { MaxSize = Vector2.new(440, 380) }, f)
          corner(f, 14)
          stroke(f, C.gold, 0.3, 1.5)
          painelBusca = f
          create("TextLabel", {
            Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -60, 0, 22), BackgroundTransparency = 1,
            Text = titulo, TextColor3 = C.gold, Font = BOLD, TextSize = 14, TextXAlignment = LEFT, ZIndex = 81,
          }, f)
          local x = create("TextButton", {
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 6), Size = UDim2.fromOffset(32, 26),
            BackgroundColor3 = C.card2, Text = "✕", TextColor3 = C.white, Font = BOLD, TextSize = 14,
            BorderSizePixel = 0, ZIndex = 82,
          }, f)
          corner(x, 8)
          x.MouseButton1Click:Connect(function()
            f:Destroy()
            if painelBusca == f then painelBusca = nil end
          end)
          local rolagem = create("ScrollingFrame", {
            Position = UDim2.fromOffset(10, 40), Size = UDim2.new(1, -20, 1, -50),
            BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 81,
          }, f)
          create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, rolagem)
          for i, l in ipairs(linhas) do
            create("TextLabel", {
              Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
              BackgroundTransparency = 1, Text = l[1], TextColor3 = l[2] or C.white,
              Font = GOTHAM, TextSize = 12, TextWrapped = true, TextXAlignment = LEFT,
              TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = i, ZIndex = 82,
            }, rolagem)
          end
        end

        -- AIMDIAG: mostra, jogador por jogador, por que a mira pega ou não pega
        add("aimdiag", "Mostra por que a mira pega ou não pega em cada jogador (use com o inimigo na tela)", "Utilidades", false, function()
          local cam = workspace.CurrentCamera
          if not cam then fail("sem câmera") end
          local centro = cam.ViewportSize / 2
          local nTimes = 0
          pcall(function() nTimes = #game:GetService("Teams"):GetTeams() end)
          local linhas = {
            { "Times no jogo: " .. nTimes .. "  |  Seu time: " .. (Player.Team and Player.Team.Name or "nenhum")
              .. "\nCírculo da mira: " .. Aim.fov .. "px"
              .. "\nAimbot só inimigos: " .. (Aim.teamBot and "sim" or "não")
              .. "  |  Assist só inimigos: " .. (Aim.teamAssist and "sim" or "não"), C.gray },
          }
          local outros = 0
          for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= Player then
              outros = outros + 1
              local ch = pl.Character
              local h = ch and ch:FindFirstChildOfClass("Humanoid")
              local parte = ch and (ch:FindFirstChild(Aim.part) or ch:FindFirstChild("HumanoidRootPart"))
              local time = Aim.mesmoTime(pl)
              local rotulo = time and "SEU TIME" or "INIMIGO"
              local motivo
              if not (ch and h and parte) then
                motivo = "sem personagem"
              elseif h.Health <= 0 then
                motivo = "morto"
              else
                local v, dentro = cam:WorldToViewportPoint(parte.Position)
                local d = (Vector2.new(v.X, v.Y) - centro).Magnitude
                if not dentro then
                  motivo = "fora da tela"
                elseif d > Aim.fov then
                  motivo = "fora do círculo (" .. math.floor(d) .. "px)"
                else
                  local bloq = aimBloqueio(parte, ch)
                  if bloq then motivo = "tem algo na frente: " .. curto(bloq:GetFullName()) end
                end
              end
              if motivo then
                table.insert(linhas, { "❌ " .. pl.DisplayName .. " [" .. rotulo .. "]: " .. motivo, C.red })
              elseif time and (Aim.teamBot or Aim.teamAssist) then
                table.insert(linhas, { "⚠️ " .. pl.DisplayName .. " [SEU TIME]: dá pra mirar, mas o 'só inimigos' ignora", C.orange })
              else
                table.insert(linhas, { "✅ " .. pl.DisplayName .. " [" .. rotulo .. "]: a mira pode pegar", C.green })
              end
            end
          end
          if outros == 0 then
            table.insert(linhas, { "Não tem mais ninguém no servidor além de você.", C.orange })
          end
          abrirPainel("DIAGNÓSTICO DA MIRA", linhas)
        end, { alias = { "diagmira", "miradiag" } })

        -- LERSERVER: lê o servidor e diz o que dá pra usar (dano, força, mira, movimento, giro)
        add("lerserver", "Lê o servidor e diz se aceita troca de dano/força e se a mira e outros comandos funcionam. Ex: lerserver | lerserver bruto", "Utilidades", false, function(args)
          local _, bruto = lerArgs(args)
          toast("Lendo o servidor... uns 5 segundos, fique parado", C.orange)
          task.spawn(function()
            local linhas = {}
            local function L(txt, cor) table.insert(linhas, { txt, cor or C.white }) end

            -- 1) dano e força: acha os valores, troca, espera e vê se o servidor devolveu
            local function varrerGrupo(palavras, evitar)
              local V = novoVarredor(palavras)
              V.evitar = evitar or {}
              pcall(V.varrer, nil, true, bruto)
              local total = #V.lista
              while #V.lista > 120 do table.remove(V.lista) end
              if #V.lista > 0 then pcall(testarEntradas, V) end
              local c, exemplos = { 0, 0, 0 }, {}
              for _, e in ipairs(V.lista) do
                local _, _, _, rank = veredito(e)
                c[rank] = c[rank] + 1
                if rank == 1 and #exemplos < 3 then
                  table.insert(exemplos, "   • " .. curto(e.nome) .. " = " .. tostring(e.orig))
                end
              end
              return total, c, exemplos
            end
            local function resumo(nome, total, c, exemplos)
              if total == 0 then
                L("❌ " .. nome .. ": não achei nada do seu lado. O jogo guarda tudo no servidor, trocar não adianta.", C.red)
              elseif c[1] > 0 then
                L("✅ " .. nome .. ": " .. c[1] .. " valor(es) o jogo lê do seu lado, provavelmente aceita a troca. (⚠️ " .. c[2] .. " só na tela, ❌ " .. c[3] .. " não alteram)", C.green)
                for _, ex in ipairs(exemplos) do L(ex, C.gray) end
              elseif c[2] > 0 then
                L("⚠️ " .. nome .. ": achei " .. c[2] .. " valor(es), mas vêm do servidor: muda só na sua tela, o real não muda.", C.orange)
              else
                L("❌ " .. nome .. ": achei " .. total .. " valor(es), mas o servidor desfez a troca.", C.red)
              end
            end

            L("DANO E FORÇA (danotiro, forca)", C.gold)
            local t1, c1, e1 = varrerGrupo({ "damage", "dmg", "dano", "headshot" },
              { "reduc", "resist", "taken", "armor", "cooldown", "delay", "range", "speed", "rate", "time", "total", "dealt", "lifetime", "record", "best", "score", "session", "rank" })
            resumo("Dano", t1, c1, e1)
            local t2, c2, e2 = varrerGrupo({ "strength", "punch", "forca", "força", "power", "knockback" },
              { "jump", "cooldown", "delay", "range", "walk", "total", "level", "exp", "xp", "record", "best", "score", "rank" })
            resumo("Força", t2, c2, e2)
            L("O teste só vê se o número aceita a troca. A prova final é bater em alguém no jogo.", C.gray)

            -- 2) mira
            L("MIRA (aimbot, aimassist, aimpoder)", C.gold)
            local cam = workspace.CurrentCamera
            if not cam then
              L("❌ sem câmera, a mira não funciona agora.", C.red)
            else
              local centro = cam.ViewportSize / 2
              local outros, vivos, naTela, noCirculo, pegaveis = 0, 0, 0, 0, 0
              for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= Player then
                  outros = outros + 1
                  local ch = pl.Character
                  local h = ch and ch:FindFirstChildOfClass("Humanoid")
                  local parte = ch and (ch:FindFirstChild(Aim.part) or ch:FindFirstChild("HumanoidRootPart"))
                  if h and h.Health > 0 and parte then
                    vivos = vivos + 1
                    local v, dentro = cam:WorldToViewportPoint(parte.Position)
                    if dentro then
                      naTela = naTela + 1
                      if (Vector2.new(v.X, v.Y) - centro).Magnitude <= Aim.fov then
                        noCirculo = noCirculo + 1
                        local alvoOk = not (Aim.teamBot and Aim.mesmoTime(pl))
                        if alvoOk and aimBloqueio(parte, ch) == nil then pegaveis = pegaveis + 1 end
                      end
                    end
                  end
                end
              end
              if cam.CameraType == Enum.CameraType.Scriptable then
                L("⚠️ o jogo controla a câmera (Scriptable): ele pode sobrescrever a mira.", C.orange)
              else
                L("✅ câmera livre, a mira consegue mexer nela.", C.green)
              end
              if outros == 0 then
                L("⚠️ ninguém além de você no servidor, não dá pra testar a mira.", C.orange)
              elseif pegaveis > 0 then
                L("✅ " .. pegaveis .. " alvo(s) que a mira pega agora (vivos " .. vivos .. ", na tela " .. naTela .. ", no círculo " .. noCirculo .. ").", C.green)
              else
                L("⚠️ nenhum alvo pegável agora (vivos " .. vivos .. ", na tela " .. naTela .. ", no círculo " .. noCirculo .. "). Aponte pra alguém e rode aimdiag.", C.orange)
              end
            end

            -- 3) movimento e giro: troca, espera 0.5s e vê se ficou
            L("MOVIMENTO E GIRO", C.gold)
            local h, r = hum(), root()
            if not (h and r) then
              L("⚠️ sem personagem agora, não testei movimento.", C.orange)
            else
              local testes = {
                { "Velocidade (speed, tpwalk, loopspeed)", h, "WalkSpeed", 4 },
                { h.UseJumpPower and "Pulo (jump, infjump, loopjump)" or "Pulo (jump, infjump, loopjump)", h,
                  h.UseJumpPower and "JumpPower" or "JumpHeight", h.UseJumpPower and 5 or 1 },
                { "Gravidade (gravity, lowgravity)", workspace, "Gravity", 1 },
                { "Altura do corpo (hipheight)", h, "HipHeight", 0.5 },
              }
              for _, t in ipairs(testes) do
                local ok, antes = pcall(function() return t[2][t[3]] end)
                t.antes = ok and type(antes) == "number" and antes or nil
                if t.antes then
                  t.alvo = t.antes + t[4]
                  t.erro = not pcall(function() t[2][t[3]] = t.alvo end)
                end
              end
              local rot0 = r.CFrame
              local giroOk = not r.Anchored
              if giroOk then pcall(function() r.CFrame = rot0 * CFrame.Angles(0, math.rad(20), 0) end) end
              task.wait(0.5)
              for _, t in ipairs(testes) do
                if t.antes then
                  local ok2, agora = pcall(function() return t[2][t[3]] end)
                  pcall(function() t[2][t[3]] = t.antes end)
                  if not t.erro and ok2 and math.abs(agora - t.alvo) < 0.01 then
                    L("✅ " .. t[1], C.green)
                  else
                    L("❌ " .. t[1] .. ": o jogo ou servidor desfaz.", C.red)
                  end
                end
              end
              if giroOk then
                local ang = 0
                pcall(function()
                  ang = math.deg(math.acos(math.clamp(rot0.LookVector:Dot(r.CFrame.LookVector), -1, 1)))
                  r.CFrame = CFrame.new(r.Position) * rot0.Rotation
                end)
                if ang > 8 then
                  L("✅ Girar o corpo (meleeaim, aimpoder, face, spin)", C.green)
                else
                  L("❌ Girar o corpo: o jogo desfez o giro (ou você estava andando). Fique parado e rode de novo.", C.red)
                end
              else
                L("⚠️ seu corpo está preso (Anchored), girar e andar não funcionam.", C.orange)
              end
            end

            -- 4) outros comandos
            L("OUTROS COMANDOS", C.gold)
            local qtdArmas = 0
            for _, pai in ipairs({ Player.Character, Player:FindFirstChild("Backpack") }) do
              if pai then
                for _, i in ipairs(pai:GetChildren()) do
                  if i:IsA("Tool") and i:FindFirstChild("Handle") then qtdArmas = qtdArmas + 1 end
                end
              end
            end
            L((qtdArmas > 0 and "✅ " or "⚠️ ") .. "reach: " .. qtdArmas .. " item(ns) com Handle (equipe o item antes de usar).",
              qtdArmas > 0 and C.green or C.orange)
            local nOutros = #Players:GetPlayers() - 1
            L((nOutros > 0 and "✅ " or "⚠️ ") .. "fling, walkfling, flingplayer: " .. nOutros .. " jogador(es) pra arremessar.",
              nOutros > 0 and C.green or C.orange)
            L("⚠️ invis e ghost: só você vê, o servidor não aceita sua transparência.", C.orange)

            -- 5) o que o seu executor consegue (muda o que o modo 'bruto' acha)
            local caps = {
              { "getgc", getgc }, { "getloadedmodules", getloadedmodules }, { "require", require },
              { "firetouchinterest", firetouchinterest }, { "fireproximityprompt", fireproximityprompt },
              { "hookfunction", hookfunction }, { "request", request or http_request },
              { "setclipboard", setclipboard or toclipboard },
            }
            local tem, falta = {}, {}
            for _, c in ipairs(caps) do
              table.insert(type(c[2]) == "function" and tem or falta, c[1])
            end
            L("EXECUTOR: tem " .. (#tem > 0 and table.concat(tem, ", ") or "nada") ..
              (#falta > 0 and (" | falta " .. table.concat(falta, ", ")) or ""), C.gray)

            -- 6) nomes suspeitos de anticheat (só um aviso, o nome não prova nada)
            local suspeitos = {}
            local palavras = { "anticheat", "anti_cheat", "anti-cheat", "cheat", "exploit", "detection" }
            local function olhar(raiz)
              if not raiz then return end
              local n = 0
              for _, d in ipairs(raiz:GetDescendants()) do
                n = n + 1
                if n % 500 == 0 then task.wait() end
                if #suspeitos < 6 and (d:IsA("LuaSourceContainer") or d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) then
                  local nm = string.lower(d.Name)
                  for _, w in ipairs(palavras) do
                    if string.find(nm, w, 1, true) then table.insert(suspeitos, curto(d:GetFullName())) break end
                  end
                end
              end
            end
            pcall(olhar, game:GetService("ReplicatedStorage"))
            pcall(olhar, Player:FindFirstChild("PlayerScripts"))
            pcall(olhar, game:GetService("StarterPlayer"))
            if #suspeitos > 0 then
              L("⚠️ nomes que parecem anticheat: " .. table.concat(suspeitos, " | "), C.orange)
            else
              L("Não vi nomes de anticheat do seu lado (ele pode estar só no servidor).", C.gray)
            end

            abrirPainel("LEITURA DO SERVIDOR", linhas)
            local plano = {}
            for _, l in ipairs(linhas) do table.insert(plano, l[1]) end
            pcall(copyText, table.concat(plano, "\n"))
            toast("Leitura pronta (copiada)", C.green)
          end)
        end, { arg = "[bruto]", alias = { "checkserver", "servercheck", "lerservidor", "testserver" } })

        add("buscavalor", "Acha sozinho os valores de força/dano do jogo e diz se dá pra alterar. Ex: buscavalor | buscavalor speed | buscavalor bruto", "Utilidades", false, function(args)
          local _, bruto, palavra = lerArgs(args)
          local V = novoVarredor(palavra and { palavra } or
            { "damage", "dmg", "dano", "strength", "punch", "forca", "força", "power", "knockback", "headshot" })
          if not palavra then V.evitar = { "jump", "walk" } end
          toast("Procurando valores do jogo... aguarde", C.orange)
          task.spawn(function()
            V.varrer(nil, true, bruto)
            if #V.lista == 0 then
              abrirPainel("BUSCA DE VALORES", {
                { "Não achei nenhum valor desse tipo do seu lado.", C.orange },
                { "Quase sempre isso quer dizer que o jogo guarda tudo no servidor, e aí não dá pra alterar. Pode tentar: buscavalor bruto", C.gray },
              })
              return
            end
            local total = #V.lista
            while #V.lista > 150 do table.remove(V.lista) end
            toast("Testando " .. #V.lista .. " valores...", C.orange)
            testarEntradas(V)

            local itens, cont = {}, { 0, 0, 0 }
            for _, e in ipairs(V.lista) do
              local icone, texto, cor, rank = veredito(e)
              cont[rank] = cont[rank] + 1
              table.insert(itens, { rank = rank, icone = icone, texto = texto, cor = cor, nome = e.nome, valor = e.orig })
            end
            table.sort(itens, function(a, b) return a.rank < b.rank end)

            local linhas = {
              { "✅ " .. cont[1] .. " podem ser alterados   ⚠️ " .. cont[2] .. " só na sua tela   ❌ " .. cont[3] .. " não alteram", C.white },
              { "✅ = o jogo lê esse número no seu celular, pode funcionar.\n⚠️ = o número vem do servidor: muda só na sua tela, o servidor ignora.\n❌ = o servidor ou o jogo devolve o valor antigo.", C.gray },
            }
            local copia = {}
            for i, it in ipairs(itens) do
              local txt = it.icone .. " " .. curto(it.nome) .. " = " .. tostring(it.valor) .. "\n" .. it.texto
              table.insert(copia, txt)
              if i <= 40 then table.insert(linhas, { txt, it.cor }) end
            end
            if #itens > 40 then
              table.insert(linhas, { "... e mais " .. (#itens - 40) .. " (a lista inteira foi copiada).", C.gray })
            end
            if total > #itens then
              table.insert(linhas, { "Achei " .. total .. " no total, testei só os primeiros " .. #itens .. ".", C.gray })
            end
            abrirPainel("BUSCA DE VALORES", linhas)
            copyText(table.concat(copia, "\n"))
            toast("✅ " .. cont[1] .. "  ⚠️ " .. cont[2] .. "  ❌ " .. cont[3] .. "  (lista copiada)", C.green)
          end)
        end, { arg = "[palavra] [bruto]", alias = { "findvalue", "achavalor" } })
      end

      -- ---------------------------------------------------------------
      -- QUEM ESTÁ OLHANDO PRA VOCÊ
      -- ---------------------------------------------------------------
      add("olhando", "Mostra quem está olhando pra você. Ex: olhando 120 20 (alcance e ângulo)", "Jogadores", true, function(on, args)
        local cmd = CmdByName.olhando
        cmd.gen = (cmd.gen or 0) + 1
        local gen = cmd.gen
        if cmd.gui then cmd.gui:Destroy() cmd.gui = nil end
        if not on then return end
        local alcance = math.clamp(num(args, 1, 120), 10, 1000)
        local angulo = math.clamp(num(args, 2, 20), 5, 90)
        local cosMin = math.cos(math.rad(angulo))

        local f = create("Frame", {
          Position = UDim2.fromOffset(10, 120), Size = UDim2.fromOffset(190, 0),
          AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.black,
          BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 20,
        }, GUI)
        corner(f, 12)
        stroke(f, C.red, 0.3, 1.4)
        create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, f)
        create("UIPadding", {
          PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
          PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
        }, f)
        local titulo = create("TextLabel", {
          Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "Olhando pra você: 0",
          TextColor3 = C.white, Font = BOLD, TextSize = 11, TextXAlignment = LEFT, LayoutOrder = 0, ZIndex = 21,
        }, f)
        cmd.gui = f

        local linhas, avisados = {}, {}
        task.spawn(function()
          while cmd.gen == gen and GUI.Parent do
            local r = root()
            local achados = {}
            if r then
              for _, p in ipairs(Players:GetPlayers()) do
                local ch = p ~= Player and p.Character
                local tr = ch and ch:FindFirstChild("HumanoidRootPart")
                if tr then
                  local ate = r.Position - tr.Position
                  local d = ate.Magnitude
                  if d <= alcance and d > 1 then
                    local dir = ate.Unit
                    local cab = ch:FindFirstChild("Head")
                    local olha = tr.CFrame.LookVector:Dot(dir) >= cosMin
                    if not olha and cab then olha = cab.CFrame.LookVector:Dot(dir) >= cosMin end
                    if olha then table.insert(achados, { p = p, d = d }) end
                  end
                end
              end
              table.sort(achados, function(a, b) return a.d < b.d end)
            end

            titulo.Text = "Olhando pra você: " .. #achados
            titulo.TextColor3 = #achados > 0 and C.red or C.white
            for i = 1, math.max(#linhas, #achados) do
              local a = achados[i]
              if a then
                if not linhas[i] then
                  linhas[i] = create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, TextColor3 = C.orange,
                    Font = GOTHAM, TextSize = 11, TextXAlignment = LEFT, LayoutOrder = i, ZIndex = 21,
                  }, f)
                end
                linhas[i].Text = string.format("%s  (%dm)", a.p.DisplayName, math.floor(a.d))
                linhas[i].Visible = true
              elseif linhas[i] then
                linhas[i].Visible = false
              end
            end

            local agora = {}
            for _, a in ipairs(achados) do
              agora[a.p] = true
              if not avisados[a.p] then toast(a.p.DisplayName .. " está olhando pra você!", C.orange) end
            end
            avisados = agora
            task.wait(0.25)
          end
        end)
      end, { arg = "alcance ângulo", alias = { "quemolha", "watchers", "lookalert" } })

      -- ---------------------------------------------------------------
      -- QUEM ESTÁ OLHANDO PRA VOCÊ
      -- ---------------------------------------------------------------

      -- ---------------------------------------------------------------
      -- FORÇA BRUTA: sem recarga e golpe/arma mais forte
      -- ---------------------------------------------------------------
      local function novoMod()
        local M = { orig = {}, undo = {} }
        local function guardar(chave, sub, valor, desfazer)
          M.orig[chave] = M.orig[chave] or {}
          if M.orig[chave][sub] == nil then
            M.orig[chave][sub] = valor
            table.insert(M.undo, desfazer)
          end
          return M.orig[chave][sub]
        end
        function M.restaurar()
          for _, f in ipairs(M.undo) do pcall(f) end
          M.undo, M.orig = {}, {}
        end
        function M.tabela(t, fundo, casa, mult)
          if type(t) ~= "table" or fundo > 3 then return end
          pcall(function()
            for k, v in pairs(t) do
              if type(v) == "number" and casa(k) then
                local o = guardar(t, k, v, function() t[k] = v end)
                t[k] = o * mult
              elseif type(v) == "table" then
                M.tabela(v, fundo + 1, casa, mult)
              end
            end
          end)
        end
        local function valor(inst, casa, mult)
          if (inst:IsA("NumberValue") or inst:IsA("IntValue")) and casa(inst.Name) then
            local velho = inst.Value
            local o = guardar(inst, "Value", velho, function() inst.Value = velho end)
            local novo = o * mult
            if inst:IsA("IntValue") then novo = math.floor(novo + 0.5) end
            inst.Value = novo
          end
          for nome, v in pairs(inst:GetAttributes()) do
            if type(v) == "number" and casa(nome) then
              local o = guardar(inst, "@" .. nome, v, function() inst:SetAttribute(nome, v) end)
              inst:SetAttribute(nome, o * mult)
            end
          end
        end
        function M.instancia(raiz, casa, mult)
          valor(raiz, casa, mult)
          for _, d in ipairs(raiz:GetDescendants()) do
            valor(d, casa, mult)
            if d:IsA("ModuleScript") and require then
              local ok, m = pcall(require, d)
              if ok then M.tabela(m, 0, casa, mult) end
            end
          end
        end
        function M.gc(casa, mult)
          if type(getgc) ~= "function" then return false end
          local ok, gc = pcall(getgc, true)
          if not ok or type(gc) ~= "table" then return false end
          for i, t in ipairs(gc) do
            if type(t) == "table" then M.tabela(t, 3, casa, mult) end
            if i % 1500 == 0 then task.wait() end
          end
          return true
        end
        return M
      end

      local function nomeCooldown(nome)
        local n = string.lower(tostring(nome))
        if n == "cd" then return true end
        return string.find(n, "cooldown", 1, true) ~= nil or string.find(n, "reloadtime", 1, true) ~= nil
          or string.find(n, "reload_time", 1, true) ~= nil
      end

      local function nomeForca(nome)
        local n = string.lower(tostring(nome))
        for _, ruim in ipairs({ "cooldown", "delay", "speed", "time", "rate", "range", "max", "min" }) do
          if string.find(n, ruim, 1, true) then return false end
        end
        for _, bom in ipairs({ "damage", "dano", "strength", "knockback", "hitpower", "punchpower", "attackpower", "atkpower" }) do
          if string.find(n, bom, 1, true) then return true end
        end
        return false
      end

      local function loopMod(cmd, gen, M, casa, mult, bruto)
        task.spawn(function()
          local ciclo = 0
          while cmd.gen == gen and GUI.Parent do
            for _, raiz in ipairs({ Player.Character, Player.Backpack }) do
              if raiz and cmd.gen == gen then pcall(M.instancia, raiz, casa, mult) end
            end
            ciclo = ciclo + 1
            if bruto and ciclo % 3 == 1 and cmd.gen == gen then pcall(M.gc, casa, mult) end
            task.wait(1)
          end
        end)
      end

      local ModCd, ModForca = novoMod(), novoMod()

      add("nocooldown", "Zera o tempo de recarga de habilidades/armas (força bruta, depende do jogo). Ex: nocooldown", "Jogadores", true, function(on, args)
        local cmd = CmdByName.nocooldown
        cmd.gen = (cmd.gen or 0) + 1
        ModCd.restaurar()
        if not on then return end
        local bruto = string.lower(tostring(args and args[1] or "")) ~= "leve"
        loopMod(cmd, cmd.gen, ModCd, nomeCooldown, 0, bruto)
      end, { arg = "leve (opcional)", alias = { "semrecarga", "nocd" } })

    end

    -- ---------------------------------------------------------------
    -- DANO E FORÇA DE VERDADE (multiplicam o golpe que o servidor recebe)
    -- Quando você ataca, o jogo avisa o servidor com um "remote". Estes comandos
    -- repetem esse aviso, então o servidor aplica o dano várias vezes.
    -- Também tem o aura (acerta quem está perto) e o espiaremote (descobre qual
    -- remote o jogo usa para o ataque).
    -- ---------------------------------------------------------------
    local Mh = {
      instalado = false, espiar = false, replay = false, regras = {}, log = {}, ordem = {},
      intervalo = 0.03, avisos = 0, pendente = 0, entrada = 0, aprendidos = {},
      atual = nil, vigia = false, cal = nil,
    }
    -- nomes de remotes que NUNCA são tratados como ataque (movimento, câmera, etc.)
    local MH_EVITAR = {
      "move", "walk", "run", "jump", "camera", "look", "pos", "update", "tick", "sync", "ping", "chat",
      "anim", "sound", "effect", "vfx", "replicate", "stamina", "sprint", "crouch", "equip", "reload",
      "ammo", "heartbeat",
    }

    local function mhResumo(...)
      local t = {}
      local n = select("#", ...)
      for i = 1, math.min(n, 6) do
        local v = select(i, ...)
        local tp = typeof(v)
        if tp == "number" or tp == "boolean" then
          t[i] = tostring(v)
        elseif tp == "string" then
          t[i] = '"' .. string.sub(v, 1, 20) .. '"'
        elseif tp == "Instance" then
          t[i] = "<" .. v.ClassName .. ":" .. v.Name .. ">"
        else
          t[i] = "<" .. tp .. ">"
        end
      end
      return table.concat(t, ", ")
    end

    local function mhMedia(t)
      local s = 0
      for _, v in ipairs(t) do s = s + v end
      return #t > 0 and s / #t or 0
    end

    -- fim da medição de um tiro: decide se a multiplicação está funcionando
    local function mhFinalizar(reg)
      local cal = Mh.cal
      if not cal or reg.dano <= 0 then return end
      if cal.fase == "base" then
        table.insert(cal.base, reg.dano)
        if #cal.base >= 3 then
          cal.fase = "mult"
          toast("Medi o dano normal. Agora atire mais 3 vezes em alguém.", C.green)
        end
      elseif cal.fase == "mult" then
        table.insert(cal.mult, reg.dano)
        if #cal.mult >= 3 then
          local razao = mhMedia(cal.mult) / math.max(mhMedia(cal.base), 0.0001)
          if razao >= 1.5 then
            cal.fase = "ok"
            toast(string.format("Funcionando! Dano cerca de %.1fx maior.", razao), C.green)
          elseif cal.modo == "lote" then
            cal.modo, cal.mult = "lento", {}
            toast("Não escalou. Tentando outro jeito: atire mais 3 vezes.", C.orange)
          else
            cal.fase = "falhou"
            toast("Esse jogo só aceita 1 golpe por tiro. Multiplicar não funciona aqui.", C.red)
            for _, n in ipairs({ "dano", "forca" }) do
              local c = CmdByName[n]
              if c and c.state then pcall(setToggle, c, false) end
            end
          end
        end
      end
    end

    -- o dano é "meu"? (a vítima está perto de você ou de onde você mirou; ignora briga do resto do servidor)
    local function mhEhMeu(h)
      local ok, res = pcall(function()
        local m = h.Parent
        if not m or m == Player.Character then return false end
        local alvo = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
        if not alvo then return false end
        local r = root()
        if r and (alvo.Position - r.Position).Magnitude <= 10 then return true end
        local cam = workspace.CurrentCamera
        if cam then
          local ate = alvo.Position - cam.CFrame.Position
          if ate.Magnitude > 1 and ate.Unit:Dot(cam.CFrame.LookVector) >= 0.97 then return true end
        end
        if UIS.MouseEnabled and not UIS.TouchEnabled then
          local mouse = Player:GetMouse()
          if mouse and mouse.Hit and (alvo.Position - mouse.Hit.Position).Magnitude <= 12 then return true end
        end
        return false
      end)
      return ok and res == true
    end

    -- texto de status do multiplicador (aparece no medidor)
    function Mh.textoVr()
      local vr = Mh.vr
      if not vr then return "" end
      if vr.estado == "ok" then
        return string.format('<font color="#6EFF96">✔ Funcionou: dano ≈ x%.1f maior</font>', vr.razao or 0)
      elseif vr.estado == "falhou" then
        return '<font color="#FF6B6B">✖ Não funcionou: o jogo só aceita 1 golpe por tiro</font>'
      end
      return '<font color="#FFB04A">' .. (vr.texto or "… acerte alguém pra eu medir") .. '</font>'
    end

    -- veredito automático: compara o dano de um tiro normal com o de um tiro multiplicado
    local function mhVeredito(reg)
      local vr = Mh.vr
      if not vr or vr.estado ~= "medindo" or not reg.vr then return end
      local morto = reg.h and (reg.h.Health <= 0 or not reg.h.Parent)
      if reg.dano <= 0 then
        vr.texto = "… nenhum dano registrado, acerte alguém"
        toast("Nenhum dano registrado nesse tiro (errou ou o alvo não leva dano). Acerte alguém.", C.orange)
      elseif reg.fase == "base" then
        vr.base = reg.dano
        vr.texto = "… medi o dano normal (" .. fmt(reg.dano) .. "), acerte de novo"
        toast("Dano normal: " .. fmt(reg.dano) .. ". Acerte de novo pra ver se o multiplicador funcionou.", C.green)
      else
        local razao = reg.dano / math.max(vr.base or 0, 0.0001)
        local limiar = math.min(1.5, 1 + (vr.valor - 1) * 0.3)
        if razao >= limiar then
          vr.estado, vr.razao = "ok", razao
          toast(string.format("Funcionou! O jogo registrou dano ≈ x%.1f maior.", razao), C.green)
        elseif morto then
          vr.texto = "… o alvo morreu, acerte outro pra medir"
          toast("O alvo morreu, não deu pra medir. Acerte outro.", C.orange)
        else
          vr.falhas = (vr.falhas or 0) + 1
          if vr.falhas >= 2 then
            vr.estado = "falhou"
            toast("Não funcionou: o jogo registrou o mesmo dano (só aceita 1 golpe por tiro). Deixei ligado; use o comando de novo pra desligar.", C.red)
          else
            vr.texto = "… dano igual ao normal, acerte mais uma vez pra confirmar"
            toast("Dano igual ao normal. Acerte mais uma vez pra confirmar.", C.orange)
          end
        end
      end
      if Mh.aoMudou then pcall(Mh.aoMudou) end
    end

    -- fica de olho na vida dos outros (jogadores e NPCs) e nos seus toques/cliques
    local function mhVigiar()
      if Mh.vigia then return end
      Mh.vigia = true
      local function prender(h)
        if not h:IsA("Humanoid") then return end
        local ultimo = h.Health
        h.HealthChanged:Connect(function(v)
          local d = ultimo - v
          ultimo = v
          local reg = Mh.atual
          if d > 0 and reg and h.Parent ~= Player.Character and os.clock() <= (reg.ate or (reg.t + 0.8)) and mhEhMeu(h) then
            reg.dano = reg.dano + d
            reg.h = h
          end
          if d > 0 and Mh.aoDano and h.Parent ~= Player.Character then pcall(Mh.aoDano, d, h) end
        end)
      end
      task.spawn(function()
        local n = 0
        for _, d in ipairs(workspace:GetDescendants()) do
          prender(d)
          n = n + 1
          if n % 500 == 0 then task.wait() end
        end
      end)
      workspace.DescendantAdded:Connect(prender)
      UIS.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
          Mh.entrada = os.clock()
          Mh.dedos = math.min((Mh.dedos or 0) + 1, 5)
        end
      end)
      UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
          Mh.dedos = math.max((Mh.dedos or 0) - 1, 0)
        end
      end)
    end

    -- ms atual (ping do servidor). Se o executor não deixar ler, devolve 0 (não freia)
    local function mhPing()
      local ok, v = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
      end)
      return ok and tonumber(v) or 0
    end
    Mh.msMax = Mh.msMax or 150

    local function mhInstalar()
      if Mh.instalado then return true end
      if not (hookmetamethod and getnamecallmethod) then return false end
      local ok = pcall(function()
        local antigo
        local function gancho(self, ...)
          local metodo = getnamecallmethod()
          if metodo == "FireServer" and not Mh.replay and typeof(self) == "Instance" and self.ClassName == "RemoteEvent"
            and not (checkcaller and checkcaller()) then
            local nome = self.Name
            local nl = string.lower(nome)
            local primeiro = select(1, ...)
            local acao = type(primeiro) == "string" and string.lower(primeiro) or nil
            -- marca que este disparo é um ataque seu (mexeu na tela agora, com ferramenta na mão)
            if os.clock() - Mh.entrada < 0.35 or (Mh.dedos or 0) > 0 then
              local ruimMeu = false
              for _, w in ipairs(MH_EVITAR) do
                if string.find(nl, w, 1, true) then ruimMeu = true break end
              end
              local chMeu = Player.Character
              if not ruimMeu and chMeu and chMeu:FindFirstChildOfClass("Tool") then Mh.meuAtaque = os.clock() end
            end
            if Mh.espiar then
              local chave = acao and (nome .. " [" .. acao .. "]") or nome
              local e = Mh.log[chave]
              if not e then
                e = { n = 0, nome = nome, caminho = self:GetFullName(), args = "" }
                Mh.log[chave] = e
                table.insert(Mh.ordem, chave)
                if Mh.avisos < 8 then
                  Mh.avisos = Mh.avisos + 1
                  task.defer(toast, "Remote: " .. chave, C.orange)
                end
              end
              e.n = e.n + 1
              e.args = mhResumo(...)
            end

            -- este remote é um ataque? (pelo nome, ou aprendido pelo momento em que você atacou)
            local copias, acertou = 0, false
            -- recarregar, equipar, trocar arma etc. nunca são multiplicados
            local naoAtaque = false
            if acao then
              for _, w in ipairs({ "reload", "equip", "unequip", "swap", "switch", "drop", "pick", "ammo" }) do
                if string.find(acao, w, 1, true) then naoAtaque = true break end
              end
            end
            for _, r in pairs(naoAtaque and {} or Mh.regras) do
              local acerta = r.auto and Mh.aprendidos[nome] or false
              if not acerta then
                for _, w in ipairs(r.palavras) do
                  if string.find(nl, w, 1, true) then acerta = true break end
                end
              end
              if not acerta and r.auto and os.clock() - Mh.entrada < 0.3 then
                local ruim = false
                for _, w in ipairs(MH_EVITAR) do
                  if string.find(nl, w, 1, true) then ruim = true break end
                end
                local char = Player.Character
                if not ruim and char and char:FindFirstChildOfClass("Tool") then
                  acerta = true
                  Mh.aprendidos[nome] = true
                  task.defer(toast, "Achei o ataque do jogo: " .. nome, C.green)
                end
              end
              if acerta then
                acertou = true
                copias = math.max(copias, r.mult - 1)
              end
            end

            if acertou and Mh.cal and (Mh.cal.fase == "base" or Mh.cal.fase == "mult") then
              local reg = { t = os.clock(), dano = 0 }
              Mh.atual = reg
              task.delay(0.85, mhFinalizar, reg)
              if Mh.cal.fase == "base" then copias = 0 end
            end

            -- ms já alto: não multiplica esse golpe (senão o ping sobe mais ainda)
            if copias > 0 and Mh.msMax > 0 and mhPing() > Mh.msMax then
              copias = 0
              if os.clock() - (Mh.avisoMs or 0) > 5 then
                Mh.avisoMs = os.clock()
                task.defer(toast, "Ms alto (" .. math.floor(mhPing()) .. "): multiplicador pausado até baixar", C.orange)
              end
            end

            -- medição automática: 1º golpe normal (referência), depois multiplicado, e eu comparo
            local vr = Mh.vr
            if acertou and not Mh.cal and vr and vr.estado == "medindo" then
              local ativo = Mh.atual and os.clock() < (Mh.atual.ate or 0)
              local novo, fase = false, "mult"
              if not vr.base then
                fase, copias = "base", 0
                novo = not ativo
              else
                novo = (not ativo) and copias > 0 and Mh.pendente <= copias
              end
              if novo then
                local est = 0
                if copias > 0 then
                  local lentoV = copias <= 60
                  local loteV = lentoV and 1 or math.clamp(math.floor(copias / 20), 5, 60)
                  est = math.min(2, math.ceil(copias / loteV) * (lentoV and Mh.intervalo or 0.02))
                end
                local reg = { t = os.clock(), dano = 0, vr = true, fase = fase, ate = os.clock() + 0.9 + est }
                Mh.atual = reg
                task.delay(1.0 + est, mhVeredito, reg)
              end
            end

            if copias > 0 then
              local lentoModo = Mh.cal and Mh.cal.modo == "lento"
              if lentoModo then copias = math.min(copias, 40) end
              -- se ainda tem golpes antigos na fila, não empilha mais (evita travar o jogo)
              if Mh.pendente <= copias then
                Mh.pendente = Mh.pendente + copias
                local args = table.pack(...)
                local alvo = self
                task.spawn(function()
                  local lento = lentoModo or copias <= 60
                  local lote = lento and 1 or math.clamp(math.floor(copias / 20), 5, 60)
                  local espera = lentoModo and 0.06 or Mh.intervalo
                  local inicioEnvio = os.clock()
                  for i = 1, copias do
                    Mh.replay = true
                    pcall(function() alvo:FireServer(table.unpack(args, 1, args.n)) end)
                    Mh.replay = false
                    Mh.meuAtaque = os.clock()
                    Mh.pendente = math.max(0, Mh.pendente - 1)
                    if i % lote == 0 then
                      if lento then task.wait(espera) else RunService.Heartbeat:Wait() end
                      -- ms subiu: espera baixar em vez de empilhar mais golpes
                      while Mh.msMax > 0 and mhPing() > Mh.msMax and next(Mh.regras) ~= nil and os.clock() - inicioEnvio < 4 do
                        task.wait(0.1)
                      end
                      -- desligou o comando, ou passou de 4s: para
                      if next(Mh.regras) == nil or os.clock() - inicioEnvio > 4 then
                        Mh.pendente = math.max(0, Mh.pendente - (copias - i))
                        break
                      end
                    end
                  end
                end)
              end
            end
          end
          return antigo(self, ...)
        end
        antigo = hookmetamethod(game, "__namecall", newcclosure and newcclosure(gancho) or gancho)
      end)
      Mh.instalado = ok
      return ok
    end

    -- argumentos: número = quantas vezes (o que você quiser), "calibrar" = (opcional) mede o dano antes, outra palavra = nome do remote
    local function ligarMulti(nome, args, padrao, rotulo)
      if not mhInstalar() then fail("seu executor não tem hookmetamethod (não dá pra multiplicar)") end
      local valor, filtro, calibrar
      for _, a in ipairs(args or {}) do
        local s = string.lower(tostring(a))
        if tonumber(s) then
          valor = tonumber(s)
        elseif s == "calibrar" then
          calibrar = true
        else
          filtro = s
        end
      end
      valor = valor or 5
      if valor ~= valor or valor == math.huge then valor = 1e9 end
      valor = math.max(1, math.floor(valor))
      mhVigiar()
      Mh.regras[nome] = { mult = valor, palavras = filtro and { filtro } or padrao, auto = filtro == nil }
      Mh.atual = nil
      if calibrar then
        Mh.vr = nil
        Mh.cal = { fase = "base", base = {}, mult = {}, modo = "lote" }
        toast(rotulo .. " x" .. valor .. ": calibrando. Atire 3 vezes em alguém (sem multiplicar), depois mais 3.", C.green)
      else
        Mh.cal = nil
        Mh.vr = valor > 1 and { estado = "medindo", falhas = 0, valor = valor } or nil
        toast(rotulo .. " x" .. valor .. " ligado. Ataque alguém que eu aviso se funcionou.", C.green)
      end
    end

    add("dano", "Multiplica o dano dos GOLPES (corpo a corpo), com o número que você quiser, sem limite. Avisa se o jogo registrou. Ex: dano 1000 | dano 1000 calibrar (opcional)", "Personagem", true, function(on, args)
      if not on then Mh.regras.dano = nil if next(Mh.regras) == nil then Mh.vr = nil end return end
      ligarMulti("dano", args, {
        "damage", "dmg", "hit", "attack", "slash", "swing", "strike", "punch", "kick", "fist", "sword", "m1", "combat", "melee",
      }, "Dano")
    end, { arg = "número [calibrar] [remote]", need = true, alias = { "damage", "multihit", "danox" } })

    add("msmax", "Freio de ms do multiplicador: se o ping passar desse valor, ele pausa até baixar. Padrão 150. msmax 0 desliga o freio. Ex: msmax 120", "Personagem", false, function(args)
      local n = tonumber(args and args[1])
      if not n then
        toast("Freio de ms: " .. (Mh.msMax > 0 and (Mh.msMax .. "ms") or "desligado") .. " (ping agora: " .. math.floor(mhPing()) .. "ms)", C.blue)
        return
      end
      Mh.msMax = math.clamp(math.floor(n), 0, 2000)
      toast(Mh.msMax > 0 and ("Freio de ms em " .. Mh.msMax .. "ms") or "Freio de ms desligado", C.green)
    end, { arg = "ms (0 = desligado)", alias = { "limitems", "pingmax" } })


    add("forca", "Aumenta a força do SOCO, com o número que você quiser, sem limite. Funciona igual ao dano (avisa se o jogo registrou). Ex: forca 1000 | forca 1000 calibrar (opcional)", "Personagem", true, function(on, args)
      if not on then Mh.regras.forca = nil if next(Mh.regras) == nil then Mh.vr = nil end return end
      ligarMulti("forca", args, {
        "punch", "hit", "attack", "strike", "swing", "slash", "m1", "combat", "melee", "soco", "golpe", "kick", "fist", "sword",
      }, "Força")
    end, { arg = "número [calibrar] [remote]", need = true, alias = { "strength", "punchpower", "forcax" } })

    add("espiaremote", "Anota os remotes que o jogo dispara (ataque, habilidade). Depois use: remotes", "Utilidades", true, function(on)
      if on and not mhInstalar() then fail("seu executor não tem hookmetamethod") end
      Mh.espiar = on
      if on then
        Mh.log, Mh.ordem, Mh.avisos = {}, {}, 0
        toast("Espiando. Ataque alguém e depois use: remotes", C.green)
      end
    end, { alias = { "spy", "remotespy" } })

    -- PAINEL DE REMOTES: uma lista na tela (dá pra tirar print, sem precisar copiar nada)
    local function mhEsc(t)
      t = string.gsub(tostring(t), "&", "&amp;")
      t = string.gsub(t, "<", "&lt;")
      t = string.gsub(t, ">", "&gt;")
      return t
    end

    local function mhPainel()
      if Mh.painel then pcall(function() Mh.painel:Destroy() end) Mh.painel = nil end
      local f = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0.94, 0, 0.84, 0), BackgroundColor3 = C.black, BackgroundTransparency = 0.03,
        BorderSizePixel = 0, ZIndex = 90,
      }, GUI)
      create("UISizeConstraint", { MaxSize = Vector2.new(600, 430) }, f)
      corner(f, 14)
      stroke(f, C.gold, 0.3, 1.5)
      Mh.painel = f

      local barra = create("Frame", {
        Position = UDim2.fromOffset(10, 8), Size = UDim2.new(1, -20, 0, 30), BackgroundTransparency = 1, ZIndex = 91,
      }, f)
      local titulo = create("TextLabel", {
        Size = UDim2.new(0.42, 0, 1, 0), BackgroundTransparency = 1, Text = "Remotes", TextColor3 = C.gold,
        Font = BOLD, TextSize = 14, TextXAlignment = LEFT, ZIndex = 92,
      }, barra)
      local botoes = create("Frame", {
        Position = UDim2.new(0.42, 0, 0, 0), Size = UDim2.new(0.58, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 92,
      }, barra)
      create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
      }, botoes)
      local function btn(txt, larg, cor, ordem)
        local b = create("TextButton", {
          Size = UDim2.fromOffset(larg, 26), BackgroundColor3 = cor, Text = txt, TextColor3 = C.white,
          Font = BOLD, TextSize = 11, AutoButtonColor = true, BorderSizePixel = 0, LayoutOrder = ordem, ZIndex = 93,
        }, botoes)
        corner(b, 13)
        return b
      end
      local bLimpar = btn("Limpar", 58, C.card2, 1)
      local bCopiar = btn("Copiar", 58, C.card2, 2)
      local bFechar = btn("Fechar", 58, C.red, 3)

      local lista = create("ScrollingFrame", {
        Position = UDim2.fromOffset(10, 46), Size = UDim2.new(1, -20, 1, -56), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = C.gold,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ZIndex = 91,
      }, f)
      create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, lista)

      local function preencher()
        local pos = lista.CanvasPosition
        for _, c in ipairs(lista:GetChildren()) do
          if c:IsA("TextLabel") then c:Destroy() end
        end
        titulo.Text = "Remotes (" .. #Mh.ordem .. ")" .. (Mh.espiar and "  ● espiando" or "")
        if #Mh.ordem == 0 then
          create("TextLabel", {
            Size = UDim2.new(1, -6, 0, 40), BackgroundTransparency = 1, TextColor3 = C.gray, Font = GOTHAM,
            TextSize = 12, TextWrapped = true, ZIndex = 92,
            Text = "Nada anotado ainda. Ataque alguém (atire ou bata) que os remotes do jogo aparecem aqui.",
          }, lista)
          return
        end
        local nomes = {}
        for _, n in ipairs(Mh.ordem) do table.insert(nomes, n) end
        table.sort(nomes, function(a, b) return Mh.log[a].n > Mh.log[b].n end)
        for i, nome in ipairs(nomes) do
          local e = Mh.log[nome]
          local marca = Mh.aprendidos[e.nome or nome] and '  <font color="#6EFF96">★ ataque</font>' or ""
          local caminho = string.gsub(e.caminho, "^ReplicatedStorage%.", "RS.")
          local row = create("TextLabel", {
            Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.card,
            BackgroundTransparency = 0.3, BorderSizePixel = 0, RichText = true, TextWrapped = true,
            TextXAlignment = LEFT, TextYAlignment = Enum.TextYAlignment.Top, Font = GOTHAM, TextSize = 12,
            TextColor3 = C.white, LayoutOrder = i, ZIndex = 92,
            Text = string.format('<b>%s</b>%s   <font color="#FFD54A">%dx</font>\n<font color="#9AA0B4" size="10">%s\nargs: %s</font>',
              mhEsc(nome), marca, e.n, mhEsc(caminho), mhEsc(e.args)),
          }, lista)
          corner(row, 8)
          create("UIPadding", {
            PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
          }, row)
        end
        lista.CanvasPosition = pos
      end
      preencher()

      bFechar.MouseButton1Click:Connect(function()
        Mh.painel = nil
        f:Destroy()
      end)
      bLimpar.MouseButton1Click:Connect(function()
        Mh.log, Mh.ordem, Mh.avisos = {}, {}, 0
        preencher()
      end)
      bCopiar.MouseButton1Click:Connect(function()
        local linhas = {}
        for _, nome in ipairs(Mh.ordem) do
          local e = Mh.log[nome]
          table.insert(linhas, string.format("%s | %dx | %s | args: %s", nome, e.n, e.caminho, e.args))
        end
        copyText(table.concat(linhas, "\n"))
        toast("Lista copiada.", C.green)
      end)

      -- atualiza sozinho enquanto o painel estiver aberto
      task.spawn(function()
        while Mh.painel == f and f.Parent and GUI.Parent do
          task.wait(2)
          if Mh.painel == f and f.Parent then pcall(preencher) end
        end
      end)
    end

    add("remotes", "Abre uma lista na tela com os remotes do jogo (tire print). Liga o espião sozinho", "Utilidades", false, function()
      if not mhInstalar() then fail("seu executor não tem hookmetamethod") end
      if not Mh.espiar then
        local c = CmdByName.espiaremote
        if c and not c.state then pcall(setToggle, c, true) else Mh.espiar = true end
      end
      mhPainel()
    end, { alias = { "listaremotes", "painelremotes" } })


    -- MEDIDOR DE DANO: mostra na tela quanto de dano você causou (medido pela vida de quem você acerta)
    local Med = { total = 0, golpes = 0, maior = 0, ultimo = 0, ultimoT = 0 }
    add("medidor", "Mostra na tela só o dano que VOCÊ causou (último golpe, total, média) e se o multiplicador funcionou. Toque nele para zerar", "Utilidades", true, function(on)
      local cmd = CmdByName.medidor
      if cmd.gui then cmd.gui:Destroy() cmd.gui = nil end
      Mh.aoDano = nil
      Mh.aoMudou = nil
      if not on then return end
      mhVigiar()
      pcall(mhInstalar)
      Med.total, Med.golpes, Med.maior, Med.ultimo, Med.ultimoT = 0, 0, 0, 0, 0
      local f = create("Frame", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 70), Size = UDim2.fromOffset(176, 0),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.black, BackgroundTransparency = 0.2,
        BorderSizePixel = 0, ZIndex = 20,
      }, GUI)
      corner(f, 12)
      stroke(f, C.gold, 0.35, 1.4)
      create("UIPadding", {
        PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
      }, f)
      local txt = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        RichText = true, TextWrapped = true, TextXAlignment = LEFT, TextYAlignment = Enum.TextYAlignment.Top,
        Font = GOTHAM, TextSize = 12, TextColor3 = C.white, AutoButtonColor = false, ZIndex = 21, Text = "",
      }, f)
      cmd.gui = f
      local function mostrar()
        local media = Med.golpes > 0 and Med.total / Med.golpes or 0
        txt.Text = string.format(
          '<b><font color="#FFD54A">Seu dano</font></b>\nÚltimo golpe: <b>%s</b>\nTotal: <b>%s</b>\nGolpes: %d   Média: %s\nMaior: %s\n%s<font size="10" color="#9AA0B4">toque para zerar • arraste para mover</font>',
          fmt(Med.ultimo), fmt(Med.total), Med.golpes, fmt(media), fmt(Med.maior),
          Mh.vr and (Mh.textoVr() .. "\n") or "")
      end
      mostrar()
      local function zerar()
        Med.total, Med.golpes, Med.maior, Med.ultimo, Med.ultimoT = 0, 0, 0, 0, 0
        mostrar()
      end
      -- arrastar com o dedo move o medidor; um toque rápido zera
      local sv = DATA.settings
      if type(sv.medX) == "number" and type(sv.medY) == "number" then
        f.Position = UDim2.new(1, sv.medX, 0, sv.medY)
      end
      local arrasto = nil
      local function ehToque(i)
        return i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1
      end
      txt.InputBegan:Connect(function(i)
        if ehToque(i) then arrasto = { ini = i.Position, x = f.Position.X.Offset, y = f.Position.Y.Offset, mexeu = false } end
      end)
      txt.InputChanged:Connect(function(i)
        if arrasto and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
          local d = i.Position - arrasto.ini
          if arrasto.mexeu or d.Magnitude > 10 then
            arrasto.mexeu = true
            local nx = math.clamp(arrasto.x + d.X, -(GUI.AbsoluteSize.X - f.AbsoluteSize.X), 0)
            local ny = math.clamp(arrasto.y + d.Y, 0, math.max(0, GUI.AbsoluteSize.Y - f.AbsoluteSize.Y))
            f.Position = UDim2.new(1, nx, 0, ny)
          end
        end
      end)
      txt.InputEnded:Connect(function(i)
        if arrasto and ehToque(i) then
          local a = arrasto
          arrasto = nil
          if a.mexeu then
            sv.medX, sv.medY = f.Position.X.Offset, f.Position.Y.Offset
            saveData()
          else
            zerar()
          end
        end
      end)
      Mh.aoMudou = mostrar
      -- só conta o SEU dano: você atacou agora há pouco E a vítima está perto de você ou de onde você mirou
      Mh.aoDano = function(d, h)
        local agora = os.clock()
        -- vale só até 0.7s depois do SEU disparo; se o jogo não deixa ver o disparo, usa o toque na tela
        local viuTiro = agora - (Mh.meuAtaque or -99) < 15
        local recente
        if viuTiro then recente = agora - Mh.meuAtaque < 0.7 else recente = agora - Mh.entrada < 0.5 end
        if not recente or not h or not mhEhMeu(h) then return end
        if agora - Med.ultimoT < 0.35 then
          Med.ultimo = Med.ultimo + d
        else
          Med.ultimo = d
          Med.golpes = Med.golpes + 1
        end
        Med.ultimoT = agora
        Med.total = Med.total + d
        Med.maior = math.max(Med.maior, Med.ultimo)
        mostrar()
      end
    end, { alias = { "dmg", "dpsmeter", "danomedidor" } })

    -- ---------------------------------------------------------------
    -- COMANDOS NOVOS: triggerbot, radar, espvida, coletar
    -- ---------------------------------------------------------------
    add("triggerbot", "Atira sozinho quando a mira está em cima de um inimigo. Ex: triggerbot 0.08", "Jogadores", true, function(on, args)
      local cmd = CmdByName.triggerbot
      cmd.gen = (cmd.gen or 0) + 1
      local gen = cmd.gen
      if not on then return end
      local atraso = math.clamp(num(args, 1, 0.08), 0, 2)
      task.spawn(function()
        local ultimo = 0
        while cmd.gen == gen and GUI.Parent do
          local cam, c = workspace.CurrentCamera, Player.Character
          local arma = c and c:FindFirstChildOfClass("Tool")
          if cam and arma then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { c }
            local centro = cam.ViewportSize / 2
            local raio = cam:ViewportPointToRay(centro.X, centro.Y)
            local res = workspace:Raycast(raio.Origin, raio.Direction * 1000, params)
            local modelo = res and res.Instance and res.Instance:FindFirstAncestorOfClass("Model")
            local h = modelo and modelo:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 and modelo ~= c then
              local dono = Players:GetPlayerFromCharacter(modelo)
              local amigo = dono and Aim.teamBot and Aim.mesmoTime and Aim.mesmoTime(dono)
              if not amigo and os.clock() - ultimo >= atraso then
                ultimo = os.clock()
                if mouse1click then
                  pcall(mouse1click)
                else
                  pcall(function() arma:Activate() end)
                end
              end
            end
          end
          task.wait(0.03)
        end
      end)
    end, { arg = "atraso", alias = { "autoshoot", "tbot" } })

    add("radar", "Mini mapa na tela com os jogadores perto de você. Ex: radar 150", "Visual", true, function(on, args)
      local cmd = CmdByName.radar
      cmd.gen = (cmd.gen or 0) + 1
      local gen = cmd.gen
      if cmd.gui then cmd.gui:Destroy() cmd.gui = nil end
      if not on then return end
      local alcance = math.clamp(num(args, 1, 150), 20, 1000)
      local tam = 130
      local f = create("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 10, 1, -90), Size = UDim2.fromOffset(tam, tam),
        BackgroundColor3 = C.black, BackgroundTransparency = 0.3, BorderSizePixel = 0, ZIndex = 20,
        ClipsDescendants = true,
      }, GUI)
      corner(f, tam / 2)
      stroke(f, C.gold, 0.35, 1.4)
      local eu0 = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = C.white, BorderSizePixel = 0, ZIndex = 22,
      }, f)
      corner(eu0, 3)
      cmd.gui = f
      local pontos = {}
      task.spawn(function()
        while cmd.gen == gen and GUI.Parent do
          local cam, r = workspace.CurrentCamera, root()
          local usados = 0
          if cam and r then
            local look = cam.CFrame.LookVector
            local plano = Vector3.new(look.X, 0, look.Z)
            if plano.Magnitude > 0.01 then
              local base = CFrame.lookAt(Vector3.new(), plano.Unit)
              for _, p in ipairs(Players:GetPlayers()) do
                local tr = p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if tr then
                  local v = base:VectorToObjectSpace(tr.Position - r.Position)
                  local px, py = v.X / alcance * (tam / 2), v.Z / alcance * (tam / 2)
                  if math.sqrt(px * px + py * py) <= tam / 2 - 3 then
                    usados = usados + 1
                    local d = pontos[usados]
                    if not d then
                      d = create("Frame", {
                        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(6, 6), BorderSizePixel = 0, ZIndex = 21,
                      }, f)
                      corner(d, 3)
                      pontos[usados] = d
                    end
                    local amigo = Aim.mesmoTime and Aim.mesmoTime(p)
                    d.BackgroundColor3 = amigo and C.green or C.red
                    d.Position = UDim2.new(0.5, px, 0.5, py)
                    d.Visible = true
                  end
                end
              end
            end
          end
          for i = usados + 1, #pontos do pontos[i].Visible = false end
          task.wait(0.1)
        end
      end)
    end, { arg = "alcance", alias = { "minimapa" } })

    add("espvida", "Mostra vida e distância em cima de cada jogador. Ex: espvida", "Visual", true, function(on)
      local cmd = CmdByName.espvida
      cmd.gen = (cmd.gen or 0) + 1
      local gen = cmd.gen
      for _, b in pairs(cmd.guis or {}) do pcall(function() b:Destroy() end) end
      cmd.guis = {}
      if not on then return end
      task.spawn(function()
        while cmd.gen == gen and GUI.Parent do
          local r = root()
          local vivos = {}
          for _, p in ipairs(Players:GetPlayers()) do
            local ch = p ~= Player and p.Character
            local cab = ch and ch:FindFirstChild("Head")
            local h = ch and ch:FindFirstChildOfClass("Humanoid")
            if cab and h then
              vivos[p] = true
              local b = cmd.guis[p]
              if not b or not b.Parent or b.Adornee ~= cab then
                if b then b:Destroy() end
                b = Instance.new("BillboardGui")
                b.AlwaysOnTop = true
                b.Size = UDim2.fromOffset(130, 30)
                b.StudsOffset = Vector3.new(0, 3, 0)
                b.Adornee = cab
                b.Parent = Parent
                local t = Instance.new("TextLabel")
                t.Name = "T"
                t.Size = UDim2.fromScale(1, 1)
                t.BackgroundTransparency = 1
                t.Font = BOLD
                t.TextSize = 12
                t.TextStrokeTransparency = 0.4
                t.Parent = b
                cmd.guis[p] = b
              end
              local t = b:FindFirstChild("T")
              local frac = h.MaxHealth > 0 and math.clamp(h.Health / h.MaxHealth, 0, 1) or 0
              local dist = r and math.floor((cab.Position - r.Position).Magnitude) or 0
              t.Text = string.format("%s\n%d/%d  •  %dm", p.DisplayName, math.floor(h.Health), math.floor(h.MaxHealth), dist)
              t.TextColor3 = Color3.fromHSV(frac * 0.33, 0.85, 1)
            end
          end
          for p, b in pairs(cmd.guis) do
            if not vivos[p] then
              pcall(function() b:Destroy() end)
              cmd.guis[p] = nil
            end
          end
          task.wait(0.3)
        end
        for _, b in pairs(cmd.guis) do pcall(function() b:Destroy() end) end
      end)
    end, { alias = { "healthesp", "vidaesp" } })

    add("coletar", "Pega sozinho itens que encostam (moedas, caixas...). Ex: coletar coin", "Mundo", true, function(on, args)
      local cmd = CmdByName.coletar
      cmd.gen = (cmd.gen or 0) + 1
      local gen = cmd.gen
      if not on then return end
      if not firetouchinterest then fail("seu executor não tem firetouchinterest") end
      local palavra = string.lower(tostring(args and args[1] or ""))
      if palavra == "" then fail("use: coletar coin (parte do nome do item)") end
      task.spawn(function()
        while cmd.gen == gen and GUI.Parent do
          local r = root()
          if r then
            local n = 0
            for _, d in ipairs(workspace:GetDescendants()) do
              if d:IsA("BasePart") and string.find(string.lower(d.Name), palavra, 1, true)
                and d:FindFirstChildOfClass("TouchTransmitter") then
                pcall(firetouchinterest, r, d, 0)
                pcall(firetouchinterest, r, d, 1)
                n = n + 1
                if n % 30 == 0 then task.wait() end
              end
            end
          end
          task.wait(2)
        end
      end)
    end, { arg = "parte do nome", need = true, alias = { "autocollect", "pegar" } })

    add("aura", "Acerta quem está perto usando a arma na mão. Ex: aura 15", "Jogadores", true, function(on, args)
      local cmd = CmdByName.aura
      cmd.gen = (cmd.gen or 0) + 1
      local gen = cmd.gen
      if not on then return end
      if not firetouchinterest then fail("seu executor não tem firetouchinterest") end
      local alcance = math.clamp(num(args, 1, 15), 3, 60)
      task.spawn(function()
        while cmd.gen == gen and GUI.Parent do
          local c, r = Player.Character, root()
          local arma = c and c:FindFirstChildOfClass("Tool")
          if arma and r then
            local alvos = {}
            for _, p in ipairs(Players:GetPlayers()) do
              local ch = p ~= Player and p.Character
              local tr = ch and ch:FindFirstChild("HumanoidRootPart")
              local th = ch and ch:FindFirstChildOfClass("Humanoid")
              if tr and th and th.Health > 0 and (tr.Position - r.Position).Magnitude <= alcance
                and not (Aim.teamBot and Aim.mesmoTime and Aim.mesmoTime(p)) then
                table.insert(alvos, tr)
              end
            end
            if #alvos > 0 then
              pcall(function() arma:Activate() end)
              local partes = {}
              for _, d in ipairs(arma:GetDescendants()) do
                if d:IsA("BasePart") then table.insert(partes, d) end
              end
              for _, tr in ipairs(alvos) do
                for _, pt in ipairs(partes) do
                  pcall(firetouchinterest, pt, tr, 0)
                  pcall(firetouchinterest, pt, tr, 1)
                end
              end
            end
          end
          task.wait(0.15)
        end
      end)
    end, { arg = "alcance", alias = { "killaura", "autohit" } })

    add("exit", "Fecha o NOVEX de vez", "Utilidades", false, function()
      GUI:Destroy()
    end, { alias = { "closenovex" } })
  end

 -- ================================================================
 -- Rodar linhas de comando (estilo Infinite Yield)
 -- ================================================================
 local function runOne(txt)
 local parts = {}
 for w in string.gmatch(txt, "%S+") do table.insert(parts, w) end
 if #parts == 0 then return false end
 local name = string.lower(table.remove(parts, 1))
 local cmd = CmdByName[name] or CmdByName[Alias[name] or ""]
 local forceOff = false
 if not cmd and OffAlias[name] then
 cmd, forceOff = CmdByName[OffAlias[name]], true
 end
 if not cmd then
 local base = string.match(name, "^un(.+)$") or string.match(name, "^no(.+)$")
 if base then
 local c = CmdByName[base] or CmdByName[Alias[base] or ""]
 if c and c.toggle then cmd, forceOff = c, true end
 end
 end
 if not cmd and #name >= 3 then
 for _, c in ipairs(Cmds) do
 if not c.exact and string.sub(c.name, 1, #name) == name then cmd = c break end
 end
 end
 if not cmd then
 toast("Comando não encontrado: " .. name, C.red)
 return false
 end

 if cmd.toggle then
 local v = not cmd.state
 local a = parts[1] and string.lower(parts[1])
 if forceOff then
 v = false
 elseif a == "on" or a == "1" then
 v = true
 table.remove(parts, 1)
 elseif a == "off" or a == "0" then
 v = false
 table.remove(parts, 1)
 elseif #parts > 0 then
 v = true
 end
 setToggle(cmd, v, parts)
 return true
 end

 local ok, err = pcall(cmd.fn, parts)
 if not ok then
 toast(cmd.name .. ": " .. string.sub(tostring(err), 1, 60), C.red)
 return false
 end
 return true
 end

 local function pushRecent(txt)
 table.insert(recent, 1, txt)
 while #recent > 6 do table.remove(recent) end
 if X.updateRecent then X.updateRecent() end
 end

 -- aceita: cmd1 \ cmd2 | 5^2^cmd (5 vezes, a cada 2s) | inf^1^cmd | cmd1 && cmd2
 function runLine(txt, noHistory)
 txt = tostring(txt or "")
 txt = txt:gsub("^%s+", "")
 txt = txt:gsub("%s+$", "")
 txt = txt:gsub("&&", "\\")
 if txt == "" then return end

 if string.find(txt, "\\", 1, true) then
 for piece in string.gmatch(txt, "[^\\]+") do
 runLine(piece, true)
 end
 if not noHistory then pushRecent(txt) end
 return
 end

 local count, delay, rest
 local a, b, r3 = string.match(txt, "^(%S+)%^(%S+)%^(.+)$")
 if a and (a == "inf" or tonumber(a)) and tonumber(b) then
 count, delay, rest = a, tonumber(b), r3
 else
 local a2, r2 = string.match(txt, "^(%S+)%^(.+)$")
 if a2 and (a2 == "inf" or tonumber(a2)) then count, delay, rest = a2, 0, r2 end
 end
 if count then
 local gen = loopGen
 task.spawn(function()
 local n = (count == "inf") and math.huge or tonumber(count)
 local i = 0
 while i < n and gen == loopGen and GUI.Parent do
 runLine(rest, true)
 i = i + 1
 task.wait(math.max(delay, 0.03))
 end
 end)
 if not noHistory then pushRecent(txt) end
 return
 end

 if runOne(txt) and not noHistory then pushRecent(txt) end
 end

 -- atalhos de teclado (bind)
 local bindConn = UIS.InputBegan:Connect(function(input, processed)
 if processed then return end
 local l = DATA.binds[string.lower(input.KeyCode.Name)]
 if l then runLine(l, true) end
 end)

 -- Desliga o que não faz sentido depois de renascer
 Player.CharacterAdded:Connect(function()
 task.wait(0.8)
 for _, n in ipairs({ "fly", "float", "airwalk", "anchor", "spin", "follow", "platformstand", "noanimate", "walkfling", "fling", "swim", "orbit" }) do
 if CmdByName[n] and CmdByName[n].state then setToggle(CmdByName[n], false) end
 end
 applyStats()
 end)

 task.spawn(function()
 while GUI.Parent do
 if Cfg.walkSpeed or Cfg.jumpPower then applyStats() end
 if Cfg.animSpeed then
 local h = hum()
 if h then
 for _, t in ipairs(h:GetPlayingAnimationTracks()) do pcall(function() t:AdjustSpeed(Cfg.animSpeed) end) end
 end
 end
 task.wait(0.4)
 end
 end)

 GUI.Destroying:Connect(function()
 bindConn:Disconnect()
 loopGen = loopGen + 1
 for _, cmd in ipairs(Cmds) do
 if cmd.state then pcall(cmd.fn, false) end
 unbind(cmd)
 end
 clearEsp()
 lreset()
 end)

 X.Cfg, X.Cmds, X.CmdByName, X.recent = Cfg, Cmds, CmdByName, recent
 X.setToggle, X.findPlayer, X.gotoPlayer = setToggle, findPlayer, gotoPlayer
 X.viewPlayer, X.unview, X.run = viewPlayer, unview, runLine
 X.hum, X.applyStats = hum, applyStats
end


------------------------------------------------------------------
-- BLOCO C: HOME
------------------------------------------------------------------
do
 local Home = Pages.Home

 local execName = "Executor"
 pcall(function() if identifyexecutor then execName = tostring((identifyexecutor())) end end)
 line(panel(Home, 840, 24, 110, 36, 18), "● " .. execName, 0, 0, 110, 36, C.white, BOLD, 11, CENTER)
 local ClockLbl = line(panel(Home, 958, 24, 118, 36, 18), "", 0, 0, 118, 36, C.white, BOLD, 11, CENTER)

 local function miniTile(parent, x, y, w, h, icon, text, color)
 local b = create("TextButton", {
 Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h),
 BackgroundColor3 = color, BackgroundTransparency = 0.75,
 Text = "", AutoButtonColor = true, BorderSizePixel = 0,
 }, parent)
 corner(b, 14)
 stroke(b, color, 0.6)
 line(b, icon, 10, 5, w - 14, 22, color, BLACK, 16)
 line(b, text, 10, h - 24, w - 12, 18, C.white, BOLD, 11)
 return b
 end

 -- Desempenho
 local fc = panel(Home, 93, 100, 174, 92)
 line(fc, "NOVEX", 16, 10, 120, 14, C.gray, BOLD, 10)
 local hFps = line(fc, "--", 16, 26, 80, 36, C.gold, BLACK, 30)
 line(fc, "FPS", 16, 66, 60, 14, C.gray, GOTHAM, 10)
 local hPing = line(fc, "--", 96, 34, 70, 24, C.white, BLACK, 16)
 line(fc, "PING", 96, 62, 60, 14, C.gray, GOTHAM, 10)

 -- Comandos rápidos (liga/desliga)
 local qc = panel(Home, 278, 100, 197, 92)
 line(qc, "Comandos rápidos", 14, 8, 170, 18, C.white, BOLD, 12)
 local function cmdTile(x, icon, name, cmdName, color)
 local b = miniTile(qc, x, 32, 84, 50, icon, name, color)
 local cmd = X.CmdByName[cmdName]
 local function paint(on) b.BackgroundTransparency = on and 0.35 or 0.75 end
 table.insert(cmd.syncs, paint)
 paint(cmd.state)
 b.MouseButton1Click:Connect(function() X.run(cmdName) end)
 end
 cmdTile(12, "✈", "Fly", "fly", C.orange)
 cmdTile(104, "◉", "ESP", "esp", C.red)

 -- Perfil (com foto)
 local pf = panel(Home, 93, 200, 174, 272)
 pf.ClipsDescendants = true
 local banner = create("Frame", {
 Size = UDim2.fromOffset(174, 76), BorderSizePixel = 0,
 BackgroundColor3 = Color3.fromHSV(hueFor(Player.UserId), 0.55, 0.6),
 }, pf)
 create("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(60, 60, 60)), Rotation = 90 }, banner)
 local pav = create("ImageLabel", {
 Position = UDim2.fromOffset(16, 40), Size = UDim2.fromOffset(72, 72),
 BackgroundColor3 = C.card2, BorderSizePixel = 0, Image = avatarUrl(Player.UserId),
 }, pf)
 corner(pav, 36)
 stroke(pav, C.panel, 0, 4)
 line(pf, Player.DisplayName, 16, 118, 142, 22, C.white, BLACK, 16)
 line(pf, "@" .. Player.Name, 16, 140, 142, 16, C.gray, GOTHAM, 11)

 local years = math.floor(Player.AccountAge / 365)
 local friendsVal = statText(pf, 16, 168, 52, "Amigos")
 local accVal = statText(pf, 72, 168, 44, "Conta")
 local onlineVal = statText(pf, 122, 168, 44, "Online")
 accVal.Text = years >= 1 and (years .. "a") or (Player.AccountAge .. "d")
 create("Frame", {
 Position = UDim2.fromOffset(16, 214), Size = UDim2.fromOffset(142, 1),
 BackgroundColor3 = C.white, BackgroundTransparency = 0.9, BorderSizePixel = 0,
 }, pf)
 local joinedLbl = label(pf, "", 16, 222, 142, 30, C.gray, GOTHAM, 10)
 label(pf, "Conta com " .. (years >= 1 and (years .. " anos") or (Player.AccountAge .. " dias")),
 16, 250, 142, 16, C.gray, GOTHAM, 10)

 -- Tocando agora
 local np = panel(Home, 278, 200, 197, 130)
 line(np, "Tocando agora", 14, 10, 150, 18, C.white, BOLD, 12)
 local npIcon = create("Frame", {
 Position = UDim2.fromOffset(14, 38), Size = UDim2.fromOffset(46, 46),
 BackgroundColor3 = C.card2, BorderSizePixel = 0,
 }, np)
 corner(npIcon, 12)
 label(npIcon, "♪", 0, 0, 46, 46, C.gray, BOLD, 20, CENTER)
 local npT = line(np, "Nada tocando", 68, 42, 120, 18, C.white, BOLD, 12)
 local npS = line(np, "Escolha uma música", 68, 62, 120, 14, C.gray, GOTHAM, 10)
 local npBtn = create("TextButton", {
 Position = UDim2.fromOffset(82, 90), Size = UDim2.fromOffset(34, 34), BackgroundColor3 = C.white,
 Text = "▶", TextColor3 = C.black, TextSize = 13, Font = BOLD, AutoButtonColor = true, BorderSizePixel = 0,
 }, np)
 corner(npBtn, 17)
 npBtn.MouseButton1Click:Connect(function()
 if X.musicToggle then X.musicToggle() else X.setPage("Music") end
 end)
 function X.setNow(t, s, playing)
 npT.Text = t
 npS.Text = s
 npBtn.Text = playing and "❚❚" or "▶"
 end

 -- Ações rápidas
 local qa = panel(Home, 278, 342, 197, 130)
 line(qa, "Ações rápidas", 14, 10, 170, 18, C.white, BOLD, 12)
 miniTile(qa, 12, 38, 55, 80, "⚡", "Cmds", C.blue).MouseButton1Click:Connect(function() X.setPage("Cmds") end)
 miniTile(qa, 71, 38, 55, 80, "</>", "Scripts", C.purple).MouseButton1Click:Connect(function() X.setPage("Scripts") end)
 miniTile(qa, 130, 38, 55, 80, "♪", "Música", C.green).MouseButton1Click:Connect(function() X.setPage("Music") end)

 -- Jogo (com foto de capa)
 local gc = panel(Home, 665, 200, 173, 272)
 gc.ClipsDescendants = true
 local gImg = create("ImageLabel", {
 Size = UDim2.fromOffset(173, 120), BackgroundColor3 = C.card2, BorderSizePixel = 0,
 ScaleType = CROP, Image = string.format("rbxthumb://type=GameIcon&id=%d&w=256&h=256", tonumber(game.GameId) or 0),
 }, gc)
 local gFade = create("Frame", { Size = UDim2.fromOffset(173, 120), BackgroundColor3 = C.panel, BorderSizePixel = 0 }, gc)
 create("UIGradient", {
 Rotation = 90,
 Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.05) }),
 }, gFade)
 local gIcon = create("ImageLabel", {
 Position = UDim2.fromOffset(12, 78), Size = UDim2.fromOffset(44, 44), BackgroundColor3 = C.card2,
 BorderSizePixel = 0, ScaleType = CROP, Image = gImg.Image,
 }, gc)
 corner(gIcon, 10)
 stroke(gIcon, C.white, 0.7)

 -- se a foto do Roblox não carregar, baixa o ícone do jogo
 task.delay(3, function()
 if gImg.Parent and not gImg.IsLoaded then
 placeIconUrl(game.PlaceId, function(u)
 if u then
 getImageAsset(u, function(a)
 if a and gImg.Parent then gImg.Image = a gIcon.Image = a end
 end)
 end
 end)
 end
 end)

 local gName = label(gc, game.Name ~= "" and game.Name or "Jogo", 12, 130, 149, 38, C.white, BLACK, 14)
 gName.TextYAlignment = Enum.TextYAlignment.Top
 gName.TextTruncate = Enum.TextTruncate.AtEnd
 local gBy = line(gc, "", 12, 168, 149, 16, C.gray, GOTHAM, 11)
 line(gc, "Place " .. tostring(game.PlaceId), 12, 192, 149, 16, C.gray, GOTHAM, 10)
 task.spawn(function()
 local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
 if ok and info then
 if info.Name and gName.Parent then gName.Text = info.Name end
 if info.Creator and info.Creator.Name and gBy.Parent then gBy.Text = "por " .. info.Creator.Name end
 end
 end)
 button(gc, "⧉ Link", 12, 226, 71, 32, C.card2, 11).MouseButton1Click:Connect(function()
 X.doCopy("https://www.roblox.com/games/" .. game.PlaceId, "Link do jogo copiado!")
 end)
 button(gc, "Job ID", 90, 226, 71, 32, C.card2, 11).MouseButton1Click:Connect(function()
 X.doCopy(tostring(game.JobId), "Job ID copiado!")
 end)

 -- Este servidor
 local sv = panel(Home, 850, 200, 226, 130)
 line(sv, "Este servidor", 16, 10, 190, 18, C.white, BOLD, 12)
 local sPlayers = statText(sv, 16, 34, 66, "Jogadores")
 local sPing = statText(sv, 90, 34, 62, "Ping")
 local sUp = statText(sv, 160, 34, 56, "Tempo")
 button(sv, "↻ Reentrar", 14, 86, 96, 34, C.card2, 11).MouseButton1Click:Connect(function() X.rejoin() end)
 button(sv, "⇄ Trocar server", 116, 86, 96, 34, C.card2, 10).MouseButton1Click:Connect(function() X.serverHop() end)

 -- Amigos online (com fotos)
 local fr = panel(Home, 850, 342, 226, 130)
 line(fr, "Amigos online", 16, 10, 150, 18, C.white, BOLD, 12)
 local frCount = line(fr, "--", 170, 10, 40, 18, C.gray, BOLD, 12, RIGHT)
 local frTxt = label(fr, "Carregando...", 16, 88, 194, 32, C.gray, GOTHAM, 11)
 local frRow = create("Frame", { Position = UDim2.fromOffset(16, 42), Size = UDim2.fromOffset(194, 36), BackgroundTransparency = 1 }, fr)

 task.spawn(function()
 local cnt = api("https://friends.roblox.com/v1/users/" .. Player.UserId .. "/friends/count")
 if cnt and cnt.count then friendsVal.Text = fmt(cnt.count) end

 local info = api("https://users.roblox.com/v1/users/" .. Player.UserId)
 if info and info.created then
 local y, m = string.match(tostring(info.created), "(%d+)-(%d+)")
 local months = { "janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho",
 "agosto", "setembro", "outubro", "novembro", "dezembro" }
 if y and m and months[tonumber(m)] then
 joinedLbl.Text = "Entrou no Roblox em " .. months[tonumber(m)] .. " de " .. y
 end
 end

 local ok, list = pcall(function() return Player:GetFriendsOnline(30) end)
 if ok and type(list) == "table" then
 onlineVal.Text = tostring(#list)
 frCount.Text = tostring(#list)
 local inGame = 0
 for i, f in ipairs(list) do
 if f.VisitorId and Players:GetPlayerByUserId(f.VisitorId) then inGame = inGame + 1 end
 if i <= 5 and f.VisitorId then
 local av = create("ImageLabel", {
 Position = UDim2.fromOffset((i - 1) * 38, 2), Size = UDim2.fromOffset(32, 32),
 BackgroundColor3 = C.card2, BorderSizePixel = 0, Image = avatarUrl(f.VisitorId),
 }, frRow)
 corner(av, 16)
 end
 end
 if #list == 0 then frTxt.Text = "Nenhum amigo online agora."
 elseif inGame > 0 then frTxt.Text = inGame .. " deles estão neste jogo."
 else frTxt.Text = "Nenhum deles está neste jogo." end
 else
 frCount.Text = "0"
 frTxt.Text = "Não consegui ver seus amigos."
 end
 end)

 local frames = 0
 local fpsConn = RunService.RenderStepped:Connect(function() frames = frames + 1 end)
 GUI.Destroying:Connect(function() fpsConn:Disconnect() end)

 table.insert(X.tick, function()
 hFps.Text = tostring(frames)
 frames = 0
 pcall(function()
 local ping = math.floor(Player:GetNetworkPing() * 1000) .. "ms"
 hPing.Text = ping
 sPing.Text = ping
 end)
 sPlayers.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
 sUp.Text = math.floor(workspace.DistributedGameTime / 60) .. "m"
 pcall(function() ClockLbl.Text = os.date("%H:%M %a %d") end)
 end)
end

------------------------------------------------------------------
-- BLOCO D: COMANDOS (interface)
------------------------------------------------------------------
do
 local Page = Pages.Cmds
 local Cmds, CmdByName = X.Cmds, X.CmdByName

 -- Velocidade / pulo / FOV (canto de cima)
 local function stepper(x, name, getter, setter, step)
 local f = panel(Page, x, 24, 110, 36, 18)
 line(f, name, 14, 3, 50, 12, C.gray, GOTHAM, 9)
 local val = line(f, "--", 14, 15, 44, 18, C.white, BLACK, 13)
 local m = button(f, "−", 60, 5, 22, 26, C.card2, 14)
 local p = button(f, "+", 84, 5, 22, 26, C.card2, 14)
 local function refresh() val.Text = tostring(math.floor(getter() + 0.5)) end
 m.MouseButton1Click:Connect(function() setter(getter() - step) refresh() end)
 p.MouseButton1Click:Connect(function() setter(getter() + step) refresh() end)
 table.insert(X.tick, refresh)
 end
 stepper(726, "Speed", function() return X.Cfg.walkSpeed or (X.hum() and X.hum().WalkSpeed) or 16 end,
 function(v) X.Cfg.walkSpeed = math.clamp(v, 0, 500) X.applyStats() end, 4)
 stepper(846, "Jump", function() return X.Cfg.jumpPower or (X.hum() and X.hum().JumpPower) or 50 end,
 function(v) X.Cfg.jumpPower = math.clamp(v, 0, 500) X.applyStats() end, 10)
 stepper(966, "FOV", function() return X.Cfg.fov or (workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView) or 70 end,
 function(v) X.Cfg.fov = math.clamp(v, 1, 120) X.applyStats() end, 5)

 -- Alternar rápido
 local qt = panel(Page, 93, 200, 227, 218)
 line(qt, "Alternar rápido", 14, 8, 160, 18, C.white, BOLD, 12)
 label(qt, "★", 190, 8, 24, 18, C.orange, BOLD, 14, RIGHT)
 for i, n in ipairs({ "fly", "noclip", "esp", "float", "infjump" }) do
 local cmd = CmdByName[n]
 local row = create("Frame", {
 Position = UDim2.fromOffset(8, 30 + (i - 1) * 36), Size = UDim2.fromOffset(211, 34), BackgroundTransparency = 1,
 }, qt)
 line(row, cmd.name, 6, 2, 130, 16, C.white, BOLD, 12)
 line(row, cmd.desc, 6, 18, 140, 13, C.gray, GOTHAM, 9)
 local sw
 sw = makeSwitch(row, 158, 4, false, function(v) X.setToggle(cmd, v) end)
 table.insert(cmd.syncs, function(s) sw.set(s) end)
 end

 -- Recentes
 local rc = panel(Page, 331, 200, 155, 218)
 line(rc, "Recentes", 14, 8, 120, 18, C.white, BOLD, 12)
 local recBox = create("Frame", { Position = UDim2.fromOffset(10, 34), Size = UDim2.fromOffset(135, 176), BackgroundTransparency = 1 }, rc)
 vlist(recBox, 4)
 function X.updateRecent()
 for _, c in ipairs(recBox:GetChildren()) do
 if c:IsA("GuiObject") then c:Destroy() end
 end
 if #X.recent == 0 then
 label(recBox, "Nada ainda\nOs comandos que você usar aparecem aqui.", 0, 0, 135, 70, C.gray, GOTHAM, 10, CENTER)
 return
 end
 for i, txt in ipairs(X.recent) do
 local b = create("TextButton", {
 Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = C.card, Text = " " .. txt, TextColor3 = C.white,
 TextSize = 11, Font = GOTHAM, TextXAlignment = LEFT, AutoButtonColor = true,
 BorderSizePixel = 0, LayoutOrder = i, TextTruncate = Enum.TextTruncate.AtEnd,
 }, recBox)
 corner(b, 8)
 b.MouseButton1Click:Connect(function() X.run(txt) end)
 end
 end
 X.updateRecent()

 -- Barra de comando
 local bar = panel(Page, 93, 430, 393, 42, 21)
 local CmdBox = create("TextBox", {
 Position = UDim2.fromOffset(18, 4), Size = UDim2.fromOffset(322, 34), BackgroundTransparency = 1,
 Text = "", ClearTextOnFocus = false, PlaceholderText = "Tente: esp • speed 50 • fling nome • 5^2^jump",
 PlaceholderColor3 = C.gray, TextColor3 = C.white, Font = GOTHAM, TextSize = 12, TextXAlignment = LEFT,
 }, bar)
 local sendBtn = button(bar, "▶", 350, 4, 34, 34, C.blue2, 13)

 -- Lista de todos os comandos
 local cl = panel(Page, 827, 200, 249, 272)
 local catBar = scroller(cl, 10, 10, 229, 28, true)
 create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, catBar)
 local cmdList = scroller(cl, 10, 46, 229, 218)
 vlist(cmdList, 6)
 create("UIPadding", { PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8) }, cmdList)

 local catIcon = {
 Movimento = "🏃", ["Câmera"] = "🎥", Visual = "👁", Interface = "🖥", Personagem = "🧍",
 Jogadores = "👥", Mundo = "🌍", Ferramentas = "🧰", Utilidades = "🛠",
 }
 local catColor = {
 Movimento = C.blue, ["Câmera"] = C.purple, Visual = C.purple, Interface = C.orange, Personagem = C.green,
 Jogadores = C.blue, Mundo = C.orange, Ferramentas = C.red, Utilidades = C.gray,
 }
 local rows, catButtons = {}, {}
 local cmdCat, cmdSearch = "Todos", ""

 local function applyFilter()
 for _, cmd in ipairs(Cmds) do
 local show = true
 if cmdCat == "Favoritos" then show = DATA.cmdFavs[cmd.name] == true
 elseif cmdCat == "Toggles" then show = cmd.toggle
 elseif cmdCat ~= "Todos" then show = cmd.cat == cmdCat end
 if show and cmdSearch ~= "" then
 show = string.find(cmd.name, cmdSearch, 1, true) ~= nil
 or string.find(string.lower(cmd.desc), cmdSearch, 1, true) ~= nil
 end
 rows[cmd.name].Visible = show
 end
 end

 for i, cmd in ipairs(Cmds) do
 local row = create("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = C.card, BorderSizePixel = 0, LayoutOrder = i }, cmdList)
 corner(row, 12)
 local ic = create("Frame", {
 Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(30, 30),
 BackgroundColor3 = catColor[cmd.cat] or C.gray, BackgroundTransparency = 0.75, BorderSizePixel = 0,
 }, row)
 corner(ic, 9)
 label(ic, catIcon[cmd.cat] or "•", 0, 0, 30, 30, C.white, BOLD, 13, CENTER)
 local nl = label(row, cmd.name, 44, 5, 90, 18, C.white, BOLD, 12)
 nl.TextWrapped = false
 local dl = label(row, cmd.desc, 44, 23, 90, 16, C.gray, GOTHAM, 9)
 dl.TextWrapped = false
 dl.TextTruncate = Enum.TextTruncate.AtEnd

 if cmd.toggle then
 local sw
 sw = makeSwitch(row, 138, 10, false, function(v)
 if v and cmd.need then
 CmdBox.Text = cmd.name .. " "
 CmdBox:CaptureFocus()
 toast("Digite o valor e envie na barra.", C.gray)
 else
 X.setToggle(cmd, v)
 end
 end)
 table.insert(cmd.syncs, function(s) sw.set(s) end)
 else
 local run = button(row, "▶", 142, 10, 38, 26, C.blue2, 11)
 run.MouseButton1Click:Connect(function()
 if cmd.need then
 CmdBox.Text = cmd.name .. " "
 CmdBox:CaptureFocus()
 toast("Digite o valor e envie na barra.", C.gray)
 else
 X.run(cmd.name)
 end
 end)
 end

 local star = create("TextButton", {
 Position = UDim2.new(1, -30, 0.5, -14), Size = UDim2.fromOffset(26, 28), BackgroundTransparency = 1,
 Text = DATA.cmdFavs[cmd.name] and "★" or "☆", TextColor3 = C.orange, TextSize = 17, Font = BOLD, AutoButtonColor = false,
 }, row)
 star.MouseButton1Click:Connect(function()
 if DATA.cmdFavs[cmd.name] then DATA.cmdFavs[cmd.name] = nil else DATA.cmdFavs[cmd.name] = true end
 star.Text = DATA.cmdFavs[cmd.name] and "★" or "☆"
 saveData()
 applyFilter()
 end)
 rows[cmd.name] = row
 end

 local function setCat(name)
 cmdCat = name
 for n, b in pairs(catButtons) do
 b.BackgroundColor3 = n == name and C.white or C.card2
 b.TextColor3 = n == name and C.black or C.gray
 end
 applyFilter()
 end

 local cats = { "Todos", "Favoritos", "Toggles", "Movimento", "Câmera", "Visual", "Interface",
 "Personagem", "Jogadores", "Mundo", "Ferramentas", "Proteção", "Utilidades" }
 for i, n in ipairs(cats) do
 local b = create("TextButton", {
 AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 26), LayoutOrder = i,
 BackgroundColor3 = C.card2, Text = n, TextColor3 = C.gray, TextSize = 11, Font = BOLD,
 AutoButtonColor = false, BorderSizePixel = 0,
 }, catBar)
 corner(b, 13)
 create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, b)
 catButtons[n] = b
 b.MouseButton1Click:Connect(function() setCat(n) end)
 end

 CmdBox:GetPropertyChangedSignal("Text"):Connect(function()
 cmdSearch = string.lower(string.match(CmdBox.Text, "^%s*(%S*)") or "")
 applyFilter()
 end)
 local function send()
 local t = CmdBox.Text
 CmdBox.Text = ""
 X.run(t)
 end
 sendBtn.MouseButton1Click:Connect(send)
 CmdBox.FocusLost:Connect(function(enter) if enter then send() end end)
 setCat("Todos")
end

------------------------------------------------------------------
-- BLOCO E: JOGADORES
------------------------------------------------------------------
do
 local Page = Pages.Players
 local countLbl = line(panel(Page, 956, 24, 120, 36, 18), "", 0, 0, 120, 36, C.white, BOLD, 11, CENTER)

 local pd = panel(Page, 93, 155, 393, 317)
 local pAv = create("ImageLabel", {
 Position = UDim2.fromOffset(16, 16), Size = UDim2.fromOffset(64, 64), BackgroundColor3 = C.card2, BorderSizePixel = 0,
 }, pd)
 corner(pAv, 32)
 local pName = line(pd, "Escolha um jogador", 92, 24, 285, 24, C.white, BLACK, 16)
 local pUser = line(pd, "Toque em alguém na lista ao lado", 92, 50, 285, 16, C.gray, GOTHAM, 11)

 local sel
 local function tile(x, y, icon, text, color, fn)
 local b = create("TextButton", {
 Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(117, 88), BackgroundColor3 = color,
 BackgroundTransparency = 0.75, Text = "", AutoButtonColor = true, BorderSizePixel = 0,
 }, pd)
 corner(b, 16)
 stroke(b, color, 0.6)
 line(b, icon, 12, 8, 60, 26, color, BLACK, 20)
 line(b, text, 12, 58, 100, 20, C.white, BOLD, 12)
 b.MouseButton1Click:Connect(fn)
 end
 local function need(fn)
 return function()
 if not sel then toast("Escolha um jogador primeiro.", C.red) return end
 fn()
 end
 end
 tile(14, 100, "➜", "Ir até", C.blue, need(function()
 if X.gotoPlayer(sel) then toast("Teleportado!", C.green) else toast("Jogador sem personagem.", C.red) end
 end))
 tile(138, 100, "◉", "Assistir", C.purple, need(function()
 if X.viewPlayer(sel) then toast("Assistindo " .. sel.DisplayName, C.green) else toast("Jogador sem personagem.", C.red) end
 end))
 tile(262, 100, "■", "Parar", C.gray, function() X.unview() toast("Câmera normal.", C.gray) end)
 tile(14, 200, "⧉", "Copiar nome", C.green, need(function() X.doCopy(sel.Name, "Nome copiado!") end))
 tile(138, 200, "#", "Copiar ID", C.orange, need(function() X.doCopy(tostring(sel.UserId), "ID copiado!") end))

 local pl = panel(Page, 827, 155, 249, 317)
 local search = create("TextBox", {
 Position = UDim2.fromOffset(12, 12), Size = UDim2.fromOffset(225, 32), BackgroundColor3 = C.card, BackgroundTransparency = 0.3,
 PlaceholderText = "Buscar jogador...", PlaceholderColor3 = C.gray, Text = "", TextColor3 = C.white,
 Font = GOTHAM, TextSize = 12, ClearTextOnFocus = false, TextXAlignment = LEFT, BorderSizePixel = 0,
 }, pl)
 corner(search, 16)
 create("UIPadding", { PaddingLeft = UDim.new(0, 14) }, search)
 local list = scroller(pl, 10, 52, 229, 255)
 vlist(list, 6)
 create("UIPadding", { PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8) }, list)

 local function select(p)
 sel = p
 pName.Text = p.DisplayName
 pUser.Text = "@" .. p.Name .. " • conta com " .. p.AccountAge .. " dias"
 pAv.Image = avatarUrl(p.UserId)
 end

 local function refresh()
 for _, c in ipairs(list:GetChildren()) do
 if c:IsA("GuiObject") then c:Destroy() end
 end
 countLbl.Text = #Players:GetPlayers() .. " jogadores"
 local q, n = string.lower(search.Text), 0
 for _, p in ipairs(Players:GetPlayers()) do
 if p ~= Player and (q == "" or string.find(string.lower(p.Name), q, 1, true)
 or string.find(string.lower(p.DisplayName), q, 1, true)) then
 n = n + 1
 local row = create("TextButton", {
 Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = C.card, Text = "", AutoButtonColor = true,
 BorderSizePixel = 0, LayoutOrder = n,
 }, list)
 corner(row, 14)
 local av = create("ImageLabel", {
 Position = UDim2.fromOffset(9, 7), Size = UDim2.fromOffset(36, 36), BackgroundColor3 = C.card2,
 BorderSizePixel = 0, Image = avatarUrl(p.UserId),
 }, row)
 corner(av, 18)
 line(row, p.DisplayName, 54, 7, 150, 18, C.white, BOLD, 12)
 line(row, "@" .. p.Name, 54, 26, 150, 14, C.gray, GOTHAM, 10)
 row.MouseButton1Click:Connect(function() select(p) end)
 end
 end
 if n == 0 then
 label(list, "Nenhum outro jogador no servidor.", 0, 10, 215, 40, C.gray, BOLD, 11, CENTER)
 end
 end

 search:GetPropertyChangedSignal("Text"):Connect(refresh)
 Players.PlayerAdded:Connect(function() if Pages.Players.Visible then refresh() end end)
 Players.PlayerRemoving:Connect(function()
 task.delay(0.2, function() if Pages.Players.Visible then refresh() end end)
 end)
 pageHooks.Players = refresh
 table.insert(X.tick, function() countLbl.Text = #Players:GetPlayers() .. " jogadores" end)
end


------------------------------------------------------------------
-- BLOCO F: MÚSICA
------------------------------------------------------------------
do
 local Page = Pages.Music
 local Sound = Instance.new("Sound")
 Sound.Name = "NOVEX_Musica"
 Sound.Volume = 0.5
 Sound.Parent = SoundService
 GUI.Destroying:Connect(function() pcall(function() Sound:Destroy() end) end)

 local mp = panel(Page, 93, 155, 393, 317)
 line(mp, "Tocando agora", 16, 10, 300, 18, C.white, BOLD, 12)
 local nowLbl = line(mp, "Nada tocando", 16, 32, 361, 26, C.white, BLACK, 18)
 local nowSub = line(mp, "Cole o ID de um áudio do Roblox abaixo.", 16, 60, 361, 16, C.gray, GOTHAM, 11)

 local idBox = create("TextBox", {
 Position = UDim2.fromOffset(16, 92), Size = UDim2.fromOffset(361, 36), BackgroundColor3 = C.card, BackgroundTransparency = 0.3,
 PlaceholderText = "ID do áudio (só números)", PlaceholderColor3 = C.gray, Text = "", TextColor3 = C.white,
 Font = GOTHAM, TextSize = 13, ClearTextOnFocus = false, TextXAlignment = LEFT, BorderSizePixel = 0,
 }, mp)
 corner(idBox, 18)
 create("UIPadding", { PaddingLeft = UDim.new(0, 16) }, idBox)

 local bPlay = button(mp, "▶ Tocar", 16, 138, 115, 38, C.white, 13, C.black)
 local bPause = button(mp, "Pausar", 139, 138, 115, 38, C.card2, 13)
 local bStop = button(mp, "Parar", 262, 138, 115, 38, C.red, 13)

 line(mp, "Volume", 16, 192, 80, 28, C.gray, BOLD, 12)
 local bMinus = button(mp, "−", 110, 188, 40, 32, C.card2, 16)
 local volVal = line(mp, "50%", 154, 190, 60, 28, C.white, BLACK, 15, CENTER)
 local bPlus = button(mp, "+", 218, 188, 40, 32, C.card2, 16)

 line(mp, "Repetir", 16, 238, 80, 28, C.gray, BOLD, 12)
 makeSwitch(mp, 110, 239, false, function(v) Sound.Looped = v end, true)
 local bSave = button(mp, "Salvar na biblioteca", 16, 272, 361, 36, C.card2, 13)

 local ml = panel(Page, 827, 155, 249, 317)
 line(ml, "Biblioteca", 16, 10, 200, 18, C.white, BOLD, 12)
 local mList = scroller(ml, 10, 38, 229, 269)
 vlist(mList, 6)
 create("UIPadding", { PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8) }, mList)

 local curId
 local function playMusic(id)
 id = tostring(id or ""):gsub("%D", "")
 if id == "" then toast("Digite um ID válido.", C.red) return end
 Sound:Stop()
 Sound.SoundId = "rbxassetid://" .. id
 Sound:Play()
 curId = id
 nowLbl.Text = "ID " .. id
 nowSub.Text = "Carregando..."
 bPause.Text = "Pausar"
 if X.setNow then X.setNow("ID " .. id, "Carregando...", true) end
 task.delay(3, function()
 if curId == id then
 local okLoad = Sound.TimeLength > 0
 nowSub.Text = okLoad and "Tocando" or "Não carregou (ID inválido ou bloqueado)"
 if X.setNow then X.setNow("ID " .. id, okLoad and "Tocando" or "Não carregou", okLoad) end
 end
 end)
 end

 local function refreshList()
 for _, c in ipairs(mList:GetChildren()) do
 if c:IsA("GuiObject") then c:Destroy() end
 end
 if #DATA.music == 0 then
 label(mList, "Biblioteca vazia.\nSalve IDs para tocar com um toque.", 0, 10, 215, 50, C.gray, GOTHAM, 11, CENTER)
 return
 end
 for i, id in ipairs(DATA.music) do
 local row = create("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = C.card, BorderSizePixel = 0, LayoutOrder = i }, mList)
 corner(row, 14)
 line(row, "♪ " .. id, 14, 0, 100, 44, C.white, BOLD, 12)
 button(row, "▶", 124, 7, 38, 30, C.white, 11, C.black).MouseButton1Click:Connect(function()
 idBox.Text = id
 playMusic(id)
 end)
 button(row, "X", 168, 7, 38, 30, C.card2, 11).MouseButton1Click:Connect(function()
 table.remove(DATA.music, i)
 saveData()
 refreshList()
 end)
 end
 end

 local function togglePause()
 if not curId then X.setPage("Music") return end
 if Sound.IsPlaying then
 Sound:Pause()
 bPause.Text = "Continuar"
 if X.setNow then X.setNow("ID " .. curId, "Pausado", false) end
 else
 Sound:Resume()
 bPause.Text = "Pausar"
 if X.setNow then X.setNow("ID " .. curId, "Tocando", true) end
 end
 end
 X.musicToggle = togglePause

 bPlay.MouseButton1Click:Connect(function() playMusic(idBox.Text) end)
 bPause.MouseButton1Click:Connect(togglePause)
 bStop.MouseButton1Click:Connect(function()
 Sound:Stop()
 curId = nil
 nowLbl.Text = "Nada tocando"
 nowSub.Text = "Cole o ID de um áudio do Roblox abaixo."
 bPause.Text = "Pausar"
 if X.setNow then X.setNow("Nada tocando", "Escolha uma música", false) end
 end)
 local function setVol(v)
 Sound.Volume = math.clamp(v, 0, 1)
 volVal.Text = math.floor(Sound.Volume * 100 + 0.5) .. "%"
 end
 bMinus.MouseButton1Click:Connect(function() setVol(Sound.Volume - 0.1) end)
 bPlus.MouseButton1Click:Connect(function() setVol(Sound.Volume + 0.1) end)
 bSave.MouseButton1Click:Connect(function()
 local id = tostring(idBox.Text):gsub("%D", "")
 if id == "" then toast("Digite um ID primeiro.", C.red) return end
 for _, v in ipairs(DATA.music) do
 if v == id then toast("Esse ID já está salvo.", C.gray) return end
 end
 table.insert(DATA.music, id)
 saveData()
 refreshList()
 toast("ID salvo!", C.green)
 end)
 refreshList()
end

------------------------------------------------------------------
-- BLOCO G: SCRIPTS (ScriptBlox + RScripts)
------------------------------------------------------------------
do
 local Page = Pages.Scripts
 local S = {
 source = "ScriptBlox", filter = "Todos", sort = "trending", keyless = false, query = "",
 list = {}, selected = nil, page = 1, totalPages = 1, loading = false, armed = nil,
 }
 local loadCatalog, refreshResults

 ---------------- normalização ----------------
 local function absUrl(u, base)
 if type(u) ~= "string" or u == "" then return nil end
 if string.sub(u, 1, 4) == "http" then return u end
 if string.sub(u, 1, 2) == "//" then return "https:" .. u end
 if string.sub(u, 1, 1) ~= "/" then u = "/" .. u end
 return base .. u
 end

 local function normSB(it)
 local g = it.game
 local imgs = {}
 local a = absUrl(it.image, "https://scriptblox.com")
 if a then table.insert(imgs, a) end
 local b = g and absUrl(g.imageUrl, "https://scriptblox.com")
 if b then table.insert(imgs, b) end
 return {
 _id = "sb:" .. tostring(it._id), src = "ScriptBlox", title = it.title,
 owner = it.owner and it.owner.username, game = g and g.name,
 verified = it.verified, key = it.key, keyLink = it.keyLink,
 views = it.views, likes = it.likeCount, universal = it.isUniversal, patched = it.isPatched,
 desc = it.description, updated = it.updatedAt, code = type(it.script) == "string" and it.script or nil,
 slug = it.slug, link = it.slug and ("https://scriptblox.com/script/" .. it.slug) or nil,
 imgs = imgs, placeId = g and g.gameId,
 }
 end

 local function normRS(it)
 local g, cr = it.game, it.creator
 local imgs = {}
 local function add(u)
 local a = absUrl(u, "https://rscripts.net")
 if a then table.insert(imgs, a) end
 end
 add(it.imageUrl)
 add(g and g.thumbnailUrl)
 add(g and g.logoUrl)
 return {
 _id = "rs:" .. tostring(it.id), src = "RScripts", title = it.title,
 owner = cr and cr.username, game = g and g.title, verified = cr and cr.isVerified,
 key = it.isKeySystem, keyLink = it.keySystemUrl, views = it.views, likes = it.likes,
 universal = (g == nil), patched = it.isPatched, mobile = it.isMobileReady,
 desc = it.description, updated = it.lastUpdatedAt or it.createdAt,
 code = type(it.script) == "string" and it.script or nil,
 raw = absUrl(it.rawScript, "https://rscripts.net"), slug = it.slug,
 link = it.slug and ("https://rscripts.net/script/" .. it.slug) or nil,
 risk = it.risk and it.risk.level, imgs = imgs, placeId = g and g.placeId,
 }
 end

 ---------------- buscas nas APIs ----------------
 local function fetchSB()
 local base = "https://scriptblox.com/api/script/"
 local trending = S.query == "" and S.sort == "trending" and S.filter ~= "Este jogo"
 local url
 if S.query ~= "" then
 url = base .. "search?q=" .. enc(S.query) .. "&page=" .. S.page .. "&max=20"
 elseif trending then
 url = base .. "trending"
 else
 url = base .. "fetch?page=" .. S.page .. "&max=20"
 end
 if not trending then
 if S.filter == "Universal" then url = url .. "&universal=1" end
 if S.keyless then url = url .. "&key=0" end
 if S.filter == "Este jogo" then url = url .. "&placeId=" .. tostring(game.PlaceId) end
 end
 local data, err = api(url)
 if data and data.result and data.result.scripts then
 local list = {}
 for _, it in ipairs(data.result.scripts) do table.insert(list, normSB(it)) end
 return list, trending and 1 or (tonumber(data.result.totalPages) or 1)
 end
 return nil, nil, (data and data.message) or err or "sem resposta"
 end

 -- API oficial do RScripts: https://api.rscripts.net/v1 (chave em rscripts.net/dashboard/api)
 local function fetchRS()
 local key = DATA.settings.rscriptsKey
 if not key or key == "" then return nil, nil, "NOKEY" end
 local headers = { Authorization = "Bearer " .. key }
 local list = {}

 if S.query == "" and S.sort == "trending" and S.filter ~= "Este jogo" then
 local data, err = api("https://api.rscripts.net/v1/trending", headers)
 if data and data.success and data.data then
 for _, grp in ipairs({ data.data.trending or {}, data.data.rising or {} }) do
 for _, it in ipairs(grp) do table.insert(list, normRS(it)) end
 end
 return list, 1
 end
 return nil, nil, err or "sem resposta"
 end

 local url = "https://api.rscripts.net/v1/scripts?page=" .. S.page .. "&limit=24&sort=" ..
 (S.sort == "latest" and "newest" or "most-views")
 if S.query ~= "" then url = url .. "&q=" .. enc(S.query) end
 if S.keyless then url = url .. "&noKeySystem=true" end
 if S.filter == "Este jogo" then url = url .. "&placeId=" .. tostring(game.PlaceId) end
 local data, err = api(url, headers)
 if data and data.success and type(data.data) == "table" then
 for _, it in ipairs(data.data) do table.insert(list, normRS(it)) end
 return list, tonumber(data.meta and data.meta.totalPages) or 1
 end
 return nil, nil, err or "sem resposta"
 end

 ---------------- painel da lista ----------------
 local lp = panel(Page, 93, 155, 393, 317)
 local head = create("TextLabel", {
 BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 10), Size = UDim2.fromOffset(150, 24),
 Text = "", TextColor3 = C.white, TextSize = 14, Font = BOLD, TextXAlignment = LEFT, RichText = true,
 }, lp)
 local sortBtn = button(lp, "🔥 Em alta", 170, 9, 82, 26, C.card2, 10)
 label(lp, "Sem key", 256, 10, 62, 24, C.gray, BOLD, 10, RIGHT)
 makeSwitch(lp, 324, 9, false, function(v)
 S.keyless = v
 S.page = 1
 loadCatalog(false)
 end, true)

 local tabsBar = create("Frame", {
 Position = UDim2.fromOffset(12, 42), Size = UDim2.fromOffset(369, 32),
 BackgroundColor3 = C.card, BackgroundTransparency = 0.3, BorderSizePixel = 0,
 }, lp)
 corner(tabsBar, 16)
 local tabBtns = {}
 for i, n in ipairs({ "Todos", "Universal", "Este jogo", "Favoritos" }) do
 local b = create("TextButton", {
 Size = UDim2.fromOffset(88, 26), Position = UDim2.fromOffset(4 + (i - 1) * 90, 3),
 BackgroundColor3 = C.white, BackgroundTransparency = 1, Text = n, TextColor3 = C.gray,
 TextSize = 11, Font = BOLD, AutoButtonColor = false, BorderSizePixel = 0,
 }, tabsBar)
 corner(b, 13)
 tabBtns[n] = b
 end

 local results = scroller(lp, 10, 84, 373, 223)
 create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8) }, results)
 create("UIGridLayout", { CellSize = UDim2.fromOffset(178, 108), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder }, results)

 local emptyLbl = label(lp, "Nada encontrado.", 20, 150, 353, 70, C.gray, BOLD, 12, CENTER)
 emptyLbl.Visible = false

 ---------------- topo: busca + fonte ----------------
 local search = create("TextBox", {
 Position = UDim2.fromOffset(713, 24), Size = UDim2.fromOffset(230, 36), BackgroundColor3 = C.panel,
 BackgroundTransparency = 0.1, PlaceholderText = "Buscar scripts ou jogos...", PlaceholderColor3 = C.gray,
 Text = "", TextColor3 = C.white, Font = GOTHAM, TextSize = 12, ClearTextOnFocus = false,
 TextXAlignment = LEFT, BorderSizePixel = 0,
 }, Page)
 corner(search, 18)
 stroke(search, C.white, 0.9)
 create("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 10) }, search)

 local seg = panel(Page, 948, 24, 128, 36, 18)
 local srcRS = button(seg, "RScripts", 3, 3, 58, 30, C.card2, 9)
 local srcSB = button(seg, "ScriptBlox", 62, 3, 63, 30, C.white, 9, C.black)

 ---------------- painel de detalhes ----------------
 local dp = panel(Page, 827, 155, 249, 317)
 dp.ClipsDescendants = true
 local dImg = create("ImageLabel", {
 Size = UDim2.fromOffset(249, 110), BackgroundColor3 = C.card2, BorderSizePixel = 0, ScaleType = CROP,
 }, dp)
 corner(dImg, 22)
 local dFade = create("Frame", { Size = UDim2.fromOffset(249, 110), BackgroundColor3 = C.panel, BorderSizePixel = 0, ZIndex = 2 }, dp)
 corner(dFade, 22)
 create("UIGradient", {
 Rotation = 90,
 Transparency = NumberSequence.new({
 NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.55, 0.75), NumberSequenceKeypoint.new(1, 0),
 }),
 }, dFade)

 local dTitle = line(dp, "Selecione um script", 14, 80, 200, 20, C.white, BLACK, 14)
 dTitle.ZIndex = 3
 local dVer = label(dp, "✔", 216, 80, 20, 20, C.blue, BOLD, 14, RIGHT)
 dVer.ZIndex = 3
 dVer.Visible = false
 local dOwner = line(dp, "", 14, 106, 220, 16, C.white, BOLD, 11)
 local dSub = line(dp, "Toque em um card da lista", 14, 122, 220, 14, C.gray, GOTHAM, 10)

 local vViews = statBox(dp, 12, 142, 71, 38, "Views")
 local vLikes = statBox(dp, 89, 142, 71, 38, "Curtidas")
 local vType = statBox(dp, 166, 142, 71, 38, "Tipo")

 local tagsRow = create("Frame", { Position = UDim2.fromOffset(12, 186), Size = UDim2.fromOffset(225, 22), BackgroundTransparency = 1 }, dp)
 create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, tagsRow)

 local function chip(text, color)
 local f = create("Frame", {
 AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 22),
 BackgroundColor3 = color, BackgroundTransparency = 0.82, BorderSizePixel = 0,
 }, tagsRow)
 corner(f, 11)
 create("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9) }, f)
 create("TextLabel", {
 AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 22), BackgroundTransparency = 1,
 Text = text, TextColor3 = color, TextSize = 10, Font = BOLD,
 }, f)
 end

 local descBox = scroller(dp, 12, 212, 225, 52)
 descBox.BackgroundTransparency = 0.3
 descBox.BackgroundColor3 = C.card
 corner(descBox, 12)
 create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 6) }, descBox)
 local dDesc = create("TextLabel", {
 BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, -6, 0, 0),
 Text = "Escolha um script na lista para ver as informações, rodar, copiar ou favoritar.",
 TextColor3 = C.gray, TextSize = 10, Font = GOTHAM, TextWrapped = true,
 TextXAlignment = LEFT, TextYAlignment = Enum.TextYAlignment.Top,
 }, descBox)

 local runBtn = button(dp, "▶ Rodar", 12, 270, 80, 38, C.white, 12, C.black)
 local copyCode = button(dp, "⧉", 98, 270, 30, 38, C.card2, 13)
 local copyLink = button(dp, "🔗", 132, 270, 30, 38, C.card2, 11)
 local favBtn = button(dp, "♡", 166, 270, 30, 38, C.card2, 14)
 local keyBtn = button(dp, "🔑", 200, 270, 30, 38, C.card2, 11)

 ---------------- lógica ----------------
 local cardStrokes, cardHearts = {}, {}

 local function isFav(id) return DATA.scriptFavs[tostring(id)] ~= nil end

 local function paintFav(btn, on)
 btn.Text = on and "♥" or "♡"
 btn.TextColor3 = on and C.red or C.white
 end

 local function updateRunBtn()
 local sel = S.selected and tostring(S.selected._id)
 if sel and S.armed == sel then
 runBtn.Text = "Confirmar ▶"
 runBtn.BackgroundColor3 = C.orange
 else
 runBtn.Text = "▶ Rodar"
 runBtn.BackgroundColor3 = C.white
 end
 end

 local function highlightSelected()
 local sel = S.selected and tostring(S.selected._id)
 for id, st in pairs(cardStrokes) do
 if id == sel then
 st.Transparency, st.Thickness = 0, 2
 else
 st.Transparency, st.Thickness = 0.9, 1
 end
 end
 end

 local function showDetails(item)
 S.selected = item
 dTitle.Text = item.title or "Sem título"
 dVer.Visible = item.verified and true or false
 dOwner.Text = "por " .. tostring(item.owner or "desconhecido")
 dSub.Text = (item.universal and "Universal" or tostring(item.game or "Jogo")) ..
 ", atualizado " .. string.sub(tostring(item.updated or "?"), 1, 10)
 vViews.Text = fmt(item.views)
 vLikes.Text = fmt(item.likes)
 vType.Text = item.universal and "Universal" or "Jogo"

 dImg.Image = ""
 dImg.BackgroundColor3 = Color3.fromHSV(hueFor(item._id), 0.6, 0.5)
 loadPicture(dImg, item, function() return S.selected == item end)

 for _, c in ipairs(tagsRow:GetChildren()) do
 if c:IsA("Frame") then c:Destroy() end
 end
 if item.verified then chip("Verified", C.blue) end
 chip(item.key and "Key system" or "Sem key", item.key and C.orange or C.green)
 chip(item.src or "?", C.gray)
 if item.mobile then chip("Mobile", C.purple) end
 if item.patched then chip("Patched", C.red) end
 if item.risk then chip("Risco: " .. tostring(item.risk), C.gray) end

 local desc = item.desc
 if type(desc) ~= "string" or desc == "" then desc = "Sem descrição." end
 if item.key and item.keyLink then desc = desc .. "\n\nLink da key: " .. tostring(item.keyLink) end
 dDesc.Text = desc
 dDesc.TextColor3 = C.white
 descBox.CanvasPosition = Vector2.new()

 paintFav(favBtn, isFav(item._id))
 keyBtn.TextTransparency = (item.key and item.keyLink) and 0 or 0.7
 highlightSelected()
 updateRunBtn()
 end
 X.showDetails = showDetails

 local function visibleList()
 local arr = {}
 if S.filter == "Favoritos" then
 local q = string.lower(S.query)
 for _, item in pairs(DATA.scriptFavs) do
 if (q == "" or string.find(string.lower(item.title or ""), q, 1, true))
 and not (S.keyless and item.key) then
 table.insert(arr, item)
 end
 end
 table.sort(arr, function(a, b) return (a.title or "") < (b.title or "") end)
 return arr
 end
 for _, item in ipairs(S.list) do
 local ok = true
 if S.filter == "Universal" and not item.universal then ok = false end
 if S.keyless and item.key then ok = false end
 if ok then table.insert(arr, item) end
 end
 return arr
 end

 local function updateHeader(count)
 local name
 if S.filter == "Favoritos" then name = "Favoritos"
 elseif S.query ~= "" then name = "Busca"
 else name = S.sort == "trending" and "Em alta" or "Recentes" end
 local info = S.loading and "carregando..." or (count .. " scripts")
 head.Text = name .. ' ' .. info .. " "
 if not S.loading and count == 0 and emptyLbl.Text == "" then emptyLbl.Text = "Nada encontrado." end
 emptyLbl.Visible = count == 0 and not S.loading
 end

 local function getCode(item)
 if type(item.code) == "string" and item.code ~= "" then return item.code end
 if item.src == "RScripts" then
 if item.raw then
 local b = httpGet(item.raw, nil, true)
 if type(b) == "string" and b ~= "" then return b end
 end
 local key = DATA.settings.rscriptsKey
 if key and key ~= "" and item.slug then
 local d = api("https://api.rscripts.net/v1/scripts/" .. item.slug, { Authorization = "Bearer " .. key })
 if d and d.data and type(d.data.script) == "string" then return d.data.script end
 end
 return nil
 end
 if item.slug then
 local d = api("https://scriptblox.com/api/script/" .. tostring(item.slug))
 if d and d.script and type(d.script.script) == "string" then return d.script.script end
 end
 return nil
 end

 local function runItem(item)
    task.spawn(function()
      toast("Baixando script...", C.gray)
      HTTPERR.msg = nil
      local code = getCode(item)
      if not code then
        toast("Não consegui pegar o código.", C.red)
        if X.aiEvent then X.aiEvent("baixar", item, HTTPERR.msg) end
        return
      end
      local fn, err = (loadstring or load)(code)
      if not fn then
        toast("Erro no script: " .. string.sub(tostring(err), 1, 50), C.red)
        if X.aiEvent then X.aiEvent("compilar", item, err) end
        return
      end
      toast("Rodando: " .. tostring(item.title or "script"), C.green)
      local snap = X.aiSnap and X.aiSnap() or nil
      local ok, e = pcall(fn)
      if not ok then toast("Erro: " .. string.sub(tostring(e), 1, 60), C.red) end
      if X.aiEvent then X.aiEvent(ok and "rodou" or "erro", item, e, snap) end
    end)
  end

  local function requestRun(item)
 local id = tostring(item._id)
 if DATA.settings.confirmRun and S.armed ~= id then
 S.armed = id
 updateRunBtn()
 toast("Toque em ▶ de novo para rodar", C.orange)
 task.delay(3, function()
 if S.armed == id then
 S.armed = nil
 updateRunBtn()
 end
 end)
 return
 end
 S.armed = nil
 updateRunBtn()
 runItem(item)
 end
 X.requestRun = requestRun

 local function toggleFav(item)
 local id = tostring(item._id)
 if DATA.scriptFavs[id] then
 DATA.scriptFavs[id] = nil
 else
 local copy = {}
 for k, v in pairs(item) do if k ~= "code" then copy[k] = v end end
 DATA.scriptFavs[id] = copy
 end
 saveData()
 if S.selected and tostring(S.selected._id) == id then paintFav(favBtn, isFav(id)) end
 if cardHearts[id] then cardHearts[id].TextColor3 = isFav(id) and C.red or C.white end
 if S.filter == "Favoritos" then refreshResults(true) end
 end

 function refreshResults(keepScroll)
 local oldPos = results.CanvasPosition
 for _, ch in ipairs(results:GetChildren()) do
 if ch:IsA("GuiObject") then ch:Destroy() end
 end
 cardStrokes, cardHearts = {}, {}

 local list = visibleList()
 for i, item in ipairs(list) do
 local id = tostring(item._id)
 local card = create("TextButton", {
 BackgroundColor3 = Color3.fromHSV(hueFor(id), 0.55, 0.45), Text = "",
 AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = i,
 }, results)
 corner(card, 18)
 cardStrokes[id] = stroke(card, C.white, 0.9)
 local img = cover(card, 18)
 loadPicture(img, item)

 local badge = create("Frame", {
 Position = UDim2.fromOffset(10, 8), Size = UDim2.fromOffset(66, 20),
 BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 3,
 }, card)
 corner(badge, 10)
 line(badge, item.key and "● Key" or "● Sem key", 0, 0, 66, 20, item.key and C.orange or C.green, BOLD, 10, CENTER).ZIndex = 4
 if item.verified then label(card, "✔", 80, 8, 18, 20, C.blue, BOLD, 13).ZIndex = 3 end

 local heart = create("TextButton", {
 Position = UDim2.fromOffset(142, 8), Size = UDim2.fromOffset(26, 26),
 BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35, Text = "♥", TextSize = 13,
 Font = BOLD, TextColor3 = isFav(id) and C.red or C.white, AutoButtonColor = true, BorderSizePixel = 0, ZIndex = 3,
 }, card)
 corner(heart, 13)
 cardHearts[id] = heart
 heart.MouseButton1Click:Connect(function() toggleFav(item) end)

 line(card, item.title or "Sem título", 12, 60, 120, 18, C.white, BOLD, 12).ZIndex = 3
 line(card, (item.universal and "Universal" or "Jogo") .. ", " .. fmt(item.views), 12, 80, 120, 14, C.white, GOTHAM, 10).ZIndex = 3

 local play = create("TextButton", {
 Position = UDim2.fromOffset(138, 70), Size = UDim2.fromOffset(30, 30), BackgroundColor3 = C.white,
 Text = "▶", TextColor3 = C.black, TextSize = 12, Font = BOLD, AutoButtonColor = true, BorderSizePixel = 0, ZIndex = 3,
 }, card)
 corner(play, 15)

 card.MouseButton1Click:Connect(function() showDetails(item) end)
 play.MouseButton1Click:Connect(function()
 showDetails(item)
 requestRun(item)
 end)
 end

 highlightSelected()
 updateHeader(#list)
 if keepScroll then
 task.defer(function() results.CanvasPosition = oldPos end)
 else
 results.CanvasPosition = Vector2.new()
 end
 end

 local requestId = 0
 function loadCatalog(append)
 if S.filter == "Favoritos" then refreshResults(false) return end
 requestId = requestId + 1
 local myId = requestId
 S.loading = true
 emptyLbl.Text = ""
 updateHeader(0)

 task.spawn(function()
 local list, pages, err
 if S.source == "ScriptBlox" then list, pages, err = fetchSB() else list, pages, err = fetchRS() end
 if myId ~= requestId then return end
 S.loading = false
 if list then
 if append then
 for _, it in ipairs(list) do table.insert(S.list, it) end
 else
 S.list = list
 end
 S.totalPages = pages or 1
 refreshResults(append)
 else
 local msg
 err = tostring(err)
 if err == "NOKEY" then
 msg = "O RScripts precisa de uma API key grátis.\nCrie em rscripts.net/dashboard/api e cole em Config > Scripts."
 elseif string.find(err, "401") then
 msg = "Chave do RScripts inválida (erro 401).\nConfira em Config > Scripts."
 elseif string.find(err, "429") then
 msg = "Muitas requisições. Espere um pouco."
 else
 msg = "Não foi possível carregar.\n" .. err
 end
 head.Text = "Erro"
 emptyLbl.Text = msg
 emptyLbl.Visible = true
 end
 end)
 end

 local function loadNextPage()
 if S.loading or S.filter == "Favoritos" then return end
 if S.page >= S.totalPages then return end
 S.page = S.page + 1
 loadCatalog(true)
 end
 results:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
 local maxY = results.AbsoluteCanvasSize.Y - results.AbsoluteSize.Y
 if maxY > 0 and results.CanvasPosition.Y >= maxY - 40 then loadNextPage() end
 end)

 local function paintTabs()
 for n, b in pairs(tabBtns) do
 local on = n == S.filter
 b.BackgroundTransparency = on and 0 or 1
 b.TextColor3 = on and C.black or C.gray
 end
 srcSB.BackgroundColor3 = S.source == "ScriptBlox" and C.white or C.card2
 srcSB.TextColor3 = S.source == "ScriptBlox" and C.black or C.gray
 srcRS.BackgroundColor3 = S.source == "RScripts" and C.white or C.card2
 srcRS.TextColor3 = S.source == "RScripts" and C.black or C.gray
 sortBtn.Text = S.sort == "trending" and "🔥 Em alta" or "🕒 Recentes"
 end

 for n, b in pairs(tabBtns) do
 b.MouseButton1Click:Connect(function()
 S.filter = n
 S.page = 1
 paintTabs()
 loadCatalog(false)
 end)
 end
 sortBtn.MouseButton1Click:Connect(function()
 S.sort = S.sort == "trending" and "latest" or "trending"
 S.page = 1
 paintTabs()
 loadCatalog(false)
 end)
 local function setSource(s)
 S.source = s
 S.page = 1
 S.list = {}
 paintTabs()
 loadCatalog(false)
 end
 srcSB.MouseButton1Click:Connect(function() setSource("ScriptBlox") end)
 srcRS.MouseButton1Click:Connect(function() setSource("RScripts") end)

 local debounce = 0
 search:GetPropertyChangedSignal("Text"):Connect(function()
 debounce = debounce + 1
 local cur = debounce
 task.delay(0.7, function()
 if cur ~= debounce then return end
 S.query = search.Text
 S.page = 1
 loadCatalog(false)
 end)
 end)

 runBtn.MouseButton1Click:Connect(function()
 if not S.selected then toast("Escolha um script primeiro.", C.gray) return end
 requestRun(S.selected)
 end)
 copyCode.MouseButton1Click:Connect(function()
 local item = S.selected
 if not item then return end
 task.spawn(function()
 local code = getCode(item)
 if code and copyText(code) then toast("Código copiado!", C.green) else toast("Não consegui copiar o código.", C.red) end
 end)
 end)
 copyLink.MouseButton1Click:Connect(function()
 local item = S.selected
 if not item then return end
 local url = item.link or item.raw
 if url then X.doCopy(url, "Link copiado!") else toast("Esse script não tem link.", C.red) end
 end)
 favBtn.MouseButton1Click:Connect(function()
 if S.selected then toggleFav(S.selected) end
 end)
 keyBtn.MouseButton1Click:Connect(function()
 local item = S.selected
 if not item then return end
 if item.key and item.keyLink then X.doCopy(tostring(item.keyLink), "Link da key copiado!")
 else toast("Esse script não precisa de key (ou não tem link).", C.gray) end
 end)
  function X.scriptsSearch(q)
    X.setPage("Scripts")
    search.Text = tostring(q or "")
  end


 function X.scriptsOpen(favs)
 S.filter = favs and "Favoritos" or (S.filter == "Favoritos" and "Todos" or S.filter)
 paintTabs()
 if S.filter == "Favoritos" then
 refreshResults(false)
 elseif #S.list == 0 and not S.loading then
 S.page = 1
 loadCatalog(false)
 else
 refreshResults(true)
 end
 end

 -- Destaque da Home
 X.featured = nil
 task.spawn(function()
 local data = api("https://scriptblox.com/api/script/trending")
 local it = data and data.result and data.result.scripts and data.result.scripts[1]
 if it then X.featured = normSB(it) end
 end)

 paintTabs()
end



------------------------------------------------------------------
-- BLOCO IA: NOVEX IA (aba ★)
-- Chat + avisos automáticos. Funciona sem chave (modo grátis) ou com
-- uma chave grátis colada na engrenagem (Groq, Gemini ou OpenRouter).
------------------------------------------------------------------
do
  local LogService = game:GetService("LogService")
  local StatsService = game:GetService("Stats")
  local Page = Pages.AI
  local S = DATA.settings
  local AI = { hist = {}, busy = false, logs = {}, lastAlert = {}, lastAny = 0, gameName = nil, events = {} }
  X.AI = AI

  local function trim(s)
    return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
  end

  ----------------------------------------------------------------
  -- Qual IA usar (pela chave colada)
  ----------------------------------------------------------------
  local function provider()
    local k = trim(S.aiKey)
    local p
    if k == "" then
      p = { id = "free", nome = "grátis (sem chave)", url = "https://text.pollinations.ai/openai",
        model = "openai-fast", headers = {}, extra = {} }
    elseif string.sub(k, 1, 4) == "gsk_" then
      p = { id = "groq", nome = "Groq", url = "https://api.groq.com/openai/v1/chat/completions",
        model = "openai/gpt-oss-20b", headers = { Authorization = "Bearer " .. k }, extra = { reasoning_effort = "low" } }
    elseif string.sub(k, 1, 4) == "AIza" then
      p = { id = "gemini", nome = "Gemini", url = "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions",
        model = "gemini-2.5-flash", headers = { Authorization = "Bearer " .. k }, extra = { reasoning_effort = "low" } }
    elseif string.sub(k, 1, 6) == "sk-or-" then
      p = { id = "openrouter", nome = "OpenRouter", url = "https://openrouter.ai/api/v1/chat/completions",
        model = "openrouter/free", headers = { Authorization = "Bearer " .. k }, extra = {} }
    end
    if p and type(S.aiModel) == "string" and S.aiModel ~= "" then p.model = S.aiModel end
    return p
  end

  ----------------------------------------------------------------
  -- Internet (POST)
  ----------------------------------------------------------------
  local function getHeader(res, nome)
    local h = res and (res.Headers or res.headers)
    if type(h) ~= "table" then return nil end
    for k, v in pairs(h) do
      if string.lower(tostring(k)) == nome then return v end
    end
    return nil
  end

  local function postJson(url, headers, body)
    local fn = (type(request) == "function" and request) or (type(http_request) == "function" and http_request)
      or (type(syn) == "table" and type(syn.request) == "function" and syn.request) or nil
    if not fn then return nil, "Seu executor não tem a função 'request', então a IA não consegue falar com a internet." end
    local h = { ["Content-Type"] = "application/json" }
    for k, v in pairs(headers or {}) do h[k] = v end
    local ok, res = pcall(fn, { Url = url, Method = "POST", Headers = h, Body = HttpService:JSONEncode(body) })
    if not ok then return nil, "Falhou ao conectar: " .. string.sub(tostring(res), 1, 80) end
    return res
  end

  ----------------------------------------------------------------
  -- Olhos da IA: nome do jogo, console e tela
  ----------------------------------------------------------------
  task.spawn(function()
    local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
    if ok and type(info) == "table" and info.Name then AI.gameName = tostring(info.Name) end
  end)

  local logConn
  pcall(function()
    logConn = LogService.MessageOut:Connect(function(msg, tipo)
      table.insert(AI.logs, {
        t = os.clock(), err = tipo == Enum.MessageType.MessageError,
        text = string.sub(tostring(msg), 1, 160),
      })
      if #AI.logs > 60 then table.remove(AI.logs, 1) end
    end)
  end)
  GUI.Destroying:Connect(function() if logConn then logConn:Disconnect() end end)

  local function errosDesde(t, max)
    local out = {}
    for i = #AI.logs, 1, -1 do
      local l = AI.logs[i]
      if l.t < t then break end
      if l.err then
        table.insert(out, 1, l.text)
        if #out >= max then break end
      end
    end
    return out
  end

  local function pingAtual()
    local ok, v = pcall(function() return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue() end)
    return ok and tonumber(v) or nil
  end

  local function lerTela()
    local textos, vistos = {}, {}
    pcall(function()
      for _, d in ipairs(PlayerGui:GetDescendants()) do
        if #textos >= 40 then break end
        if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Visible and d.AbsoluteSize.X > 0 and not d:IsDescendantOf(GUI) then
          local sg = d:FindFirstAncestorWhichIsA("ScreenGui")
          local t = trim(string.gsub(d.Text, "%s+", " "))
          if sg and sg.Enabled and #t > 1 and not vistos[t] then
            vistos[t] = true
            table.insert(textos, string.sub(t, 1, 40))
          end
        end
      end
    end)
    local janelas = {}
    pcall(function()
      local raiz = type(gethui) == "function" and gethui() or nil
      if raiz then
        for _, c in ipairs(raiz:GetChildren()) do
          if c.Name ~= "NOVEX" and #janelas < 10 then table.insert(janelas, c.Name) end
        end
      end
    end)
    return textos, janelas
  end

  local function nomesComandosLigados()
    local on = {}
    for _, c in ipairs(X.Cmds or {}) do
      if c.state then table.insert(on, c.name) end
    end
    return on
  end

  local function listaComandos()
    if AI.nomes then return AI.nomes end
    local t = {}
    for _, c in ipairs(X.Cmds or {}) do table.insert(t, c.name) end
    AI.nomes = table.concat(t, ",")
    return AI.nomes
  end

  local function comandosParecidos(texto)
    local palavras = {}
    for w in string.gmatch(string.lower(texto or ""), "[%a]+") do
      if #w >= 4 then table.insert(palavras, w) end
    end
    local pontos = {}
    for _, c in ipairs(X.Cmds or {}) do
      local alvo = string.lower(c.name .. " " .. tostring(c.desc))
      local p = 0
      for _, w in ipairs(palavras) do
        if string.find(alvo, w, 1, true) then p = p + 1 end
      end
      if p > 0 then table.insert(pontos, { c = c, p = p }) end
    end
    table.sort(pontos, function(a, b) return a.p > b.p end)
    local out = {}
    for i = 1, math.min(8, #pontos) do
      local c = pontos[i].c
      table.insert(out, c.name .. ": " .. string.sub(tostring(c.desc), 1, 70))
    end
    return out
  end

  local function montarSistema(texto, comTela)
    local L = {}
    local function add(s) table.insert(L, s) end
    add("Você é a NOVEX IA, a assistente que vive dentro do menu NOVEX (um hub de scripts de Roblox feito para celular, usado com o executor Delta).")
    add("REGRAS:")
    add("- Responda em português simples, curto (no máximo 6 linhas), sem jargão técnico. Sem markdown, sem asteriscos, sem títulos.")
    add("- NÃO concorde só para agradar. Se o pedido não vai funcionar (ex.: valor que fica só no servidor), for arriscado (ban de conta, script de fonte duvidosa) ou estiver errado, discorde com educação, explique o motivo e dê uma alternativa.")
    add("- Nunca invente. Se não tiver certeza, diga 'não tenho certeza'. Não prometa que um script vai funcionar.")
    add("- Para sugerir uma ação, use etiquetas exatas no fim da resposta: [[cmd:nome argumentos]] para um comando do NOVEX (só nomes que estão na lista abaixo) e [[script:termo]] para buscar um hub na aba Scripts (ex.: [[script:scp]]). No máximo 3 etiquetas. O usuário toca para executar, então nunca diga que você já executou.")
    add("- Quando falarem de um jogo, diga quais comandos ajudam nele e se vale mais a pena procurar um hub de script próprio do jogo.")
    add("- Dano e força: muitos jogos guardam isso no servidor. Se o comando buscavalor mostrar ❌, isso não dá para alterar; avise e não insista.")
    add("- Erro 404 ao baixar script quer dizer que o link do script morreu (o dono apagou ou o site tirou); não é culpa do usuário.")
    add("CONTEXTO ATUAL:")
    add("Jogo: " .. (AI.gameName or "desconhecido") .. " (PlaceId " .. tostring(game.PlaceId) .. "), " .. #Players:GetPlayers() .. " jogadores.")
    local exe = "desconhecido"
    pcall(function() if type(identifyexecutor) == "function" then exe = tostring((identifyexecutor())) end end)
    add("Executor: " .. exe)
    local ping = pingAtual()
    if ping then add("Ping: " .. math.floor(ping) .. " ms") end
    pcall(function()
      local ch = Player.Character
      local hum = ch and ch:FindFirstChildOfClass("Humanoid")
      if hum then add("Vida: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)) end
      local tool = ch and ch:FindFirstChildOfClass("Tool")
      if tool then add("Item na mão: " .. tool.Name) end
    end)
    local on = nomesComandosLigados()
    add("Comandos ligados agora: " .. (#on > 0 and table.concat(on, ", ") or "nenhum"))
    if #AI.events > 0 then add("Últimos avisos do NOVEX: " .. table.concat(AI.events, " | ")) end
    local erros = errosDesde(os.clock() - 120, 4)
    if #erros > 0 then add("Erros recentes no console do jogo: " .. table.concat(erros, " | ")) end
    if comTela then
      local textos, janelas = lerTela()
      add("TEXTOS VISÍVEIS NA TELA: " .. (#textos > 0 and table.concat(textos, " / ") or "(nenhum texto encontrado)"))
      if #janelas > 0 then add("Janelas de scripts abertas: " .. table.concat(janelas, ", ")) end
    end
    add("COMANDOS DO NOVEX: " .. listaComandos())
    local par = comandosParecidos(texto)
    if #par > 0 then add("Comandos parecidos com o pedido: " .. table.concat(par, " | ")) end
    return table.concat(L, "\n")
  end

  ----------------------------------------------------------------
  -- Chamada da IA
  ----------------------------------------------------------------
  local function limpar(txt)
    txt = tostring(txt or "")
    txt = string.gsub(txt, "%*%*", "")
    txt = string.gsub(txt, "`", "")
    txt = string.gsub(txt, "\n#+%s*", "\n")
    return trim(txt)
  end

  -- devolve: texto  |  nil, mensagem de erro
  local function chamar(texto, comTela)
    local p = provider()
    if not p then
      return nil, "Não reconheci essa chave. As do Groq começam com gsk_, as do Gemini com AIza e as do OpenRouter com sk-or-. Abra a engrenagem ⚙ e confira."
    end
    local msgs = { { role = "system", content = montarSistema(texto, comTela) } }
    for _, m in ipairs(AI.hist) do table.insert(msgs, m) end
    table.insert(msgs, { role = "user", content = string.sub(texto, 1, 700) })
    local body = { model = p.model, messages = msgs, max_tokens = 900, temperature = 0.6 }
    for k, v in pairs(p.extra) do body[k] = v end

    local res, err = postJson(p.url, p.headers, body)
    if not res then return nil, err end
    local status = tonumber(res.StatusCode or res.Status) or 0
    local corpo = res.Body or res.body or ""
    local okj, data = pcall(function() return HttpService:JSONDecode(corpo) end)
    if not okj then data = nil end

    if status >= 200 and status < 300 then
      local msg = data and data.choices and data.choices[1] and data.choices[1].message
      local conteudo = msg and msg.content
      if type(conteudo) == "string" and trim(conteudo) ~= "" then return limpar(conteudo) end
      return nil, "A IA respondeu vazio. Tente perguntar de novo."
    end

    local detalhe = ""
    if data and data.error then
      detalhe = type(data.error) == "table" and tostring(data.error.message or "") or tostring(data.error)
    elseif type(corpo) == "string" then
      detalhe = corpo
    end
    detalhe = string.sub(trim(detalhe), 1, 90)
    if status == 401 or status == 403 then
      return nil, "A chave foi recusada (" .. status .. "). Confira se colou inteira, ou apague e use o modo grátis."
    elseif status == 402 or status == 429 then
      local quanto = tonumber(getHeader(res, "retry-after"))
      if p.id == "free" then
        return nil, "O modo grátis sem chave só deixa 1 pergunta de cada vez por um tempo" ..
          (quanto and (" (espere uns " .. math.floor(quanto) .. "s)") or "") ..
          ". Para ficar rápida, cole uma chave grátis na engrenagem ⚙."
      end
      return nil, "Você chegou no limite grátis da " .. p.nome .. (quanto and (" (espere uns " .. math.floor(quanto) .. "s)") or ", espere um pouco") .. "."
    elseif status == 404 or status == 400 then
      return nil, "A IA recusou o pedido (" .. status .. "): " .. detalhe .. ". O modelo pode ter mudado de nome."
    end
    return nil, "A IA deu erro " .. tostring(status) .. ": " .. detalhe
  end

  ----------------------------------------------------------------
  -- Interface
  ----------------------------------------------------------------
  local box = panel(Page, 93, 100, 983, 372)
  line(box, "★ NOVEX IA", 16, 8, 160, 28, C.gold, BLACK, 16)
  local statusLbl = line(box, "", 150, 13, 300, 18, C.gray, GOTHAM, 10)

  local sc = scroller(box, 12, 44, 959, 262)
  vlist(sc, 8)
  create("UIPadding", { PaddingBottom = UDim.new(0, 6), PaddingRight = UDim.new(0, 8) }, sc)

  local ordem = 0
  local function rolarFim()
    task.delay(0.08, function()
      pcall(function()
        sc.CanvasPosition = Vector2.new(0, math.max(0, sc.AbsoluteCanvasSize.Y - sc.AbsoluteWindowSize.Y))
      end)
    end)
  end

  local function addChips(row, chips)
    if not chips or #chips == 0 then return end
    local f = create("Frame", {
      Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, LayoutOrder = 2,
    }, row)
    create("UIListLayout", {
      FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
    }, f)
    for i, ch in ipairs(chips) do
      local b = create("TextButton", {
        Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = i,
        BackgroundColor3 = C.card2, Text = string.sub(ch.label, 1, 40), TextColor3 = C.white, TextSize = 11, Font = BOLD,
        AutoButtonColor = true, BorderSizePixel = 0,
      }, f)
      corner(b, 14)
      create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, b)
      b.MouseButton1Click:Connect(function() pcall(ch.fn) end)
    end
  end

  -- cria um balão; devolve o texto (para editar depois) e a linha (para pôr botões)
  local function bubble(role, text, color, chips)
    ordem = ordem + 1
    local euSou = role == "user"
    local row = create("Frame", {
      Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = ordem,
    }, sc)
    create("UIListLayout", {
      Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
      HorizontalAlignment = euSou and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left,
    }, row)
    local b = create("Frame", {
      Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, LayoutOrder = 1, BorderSizePixel = 0,
      BackgroundColor3 = euSou and C.blue2 or C.card, BackgroundTransparency = 0.1,
    }, row)
    corner(b, 14)
    if not euSou then stroke(b, C.gold, 0.7) end
    create("UIPadding", {
      PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
    }, b)
    local t = create("TextLabel", {
      Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1,
      Text = text, TextColor3 = color or C.white, TextSize = 13, Font = GOTHAM, TextWrapped = true,
      TextXAlignment = LEFT, TextYAlignment = Enum.TextYAlignment.Top,
    }, b)
    create("UISizeConstraint", { MaxSize = Vector2.new(640, math.huge) }, t)
    addChips(row, chips)
    rolarFim()
    return t, row
  end

  -- separa as etiquetas [[cmd:...]] e [[script:...]] do texto
  local function separarEtiquetas(txt)
    local tags = {}
    txt = string.gsub(txt, "%[%[(%a+):([^%]]-)%]%]", function(tipo, arg)
      arg = trim(arg)
      if #tags < 3 and arg ~= "" then table.insert(tags, { tipo = string.lower(tipo), arg = arg }) end
      return ""
    end)
    return trim(txt), tags
  end

  local function chipsDasEtiquetas(tags)
    local out = {}
    for _, t in ipairs(tags) do
      if t.tipo == "cmd" then
        local nome = string.lower(string.match(t.arg, "^%S+") or "")
        if X.CmdByName and X.CmdByName[nome] then
          table.insert(out, { label = "▶ " .. t.arg, fn = function()
            toast("Rodando: " .. t.arg, C.green)
            X.run(t.arg, false)
          end })
        end
      elseif t.tipo == "script" then
        table.insert(out, { label = "🔎 Buscar script: " .. t.arg, fn = function()
          if X.scriptsSearch then X.scriptsSearch(t.arg) end
        end })
      end
    end
    return out
  end

  local function guardarHist(user, ia)
    table.insert(AI.hist, { role = "user", content = string.sub(user, 1, 400) })
    table.insert(AI.hist, { role = "assistant", content = string.sub(ia, 1, 500) })
    while #AI.hist > 8 do table.remove(AI.hist, 1) end
  end

  function AI.ask(texto, comTela, escondido)
    texto = trim(texto)
    if texto == "" then return end
    if AI.busy then toast("Espere a IA terminar de responder.", C.orange) return end
    AI.busy = true
    if not escondido then bubble("user", texto) end
    local lbl, row = bubble("ai", "● ● ●  pensando...", C.gray)
    task.spawn(function()
      local tela = comTela or string.find(string.lower(texto), "tela", 1, true) ~= nil
      local ok, resposta, erro = pcall(chamar, texto, tela)
      if not ok then resposta, erro = nil, "Algo deu errado aqui dentro: " .. string.sub(tostring(resposta), 1, 80) end
      AI.busy = false
      if not lbl.Parent then return end
      if resposta then
        local limpo, tags = separarEtiquetas(resposta)
        if limpo == "" then limpo = "(sem texto)" end
        lbl.Text = limpo
        lbl.TextColor3 = C.white
        addChips(row, chipsDasEtiquetas(tags))
        guardarHist(texto, resposta)
      else
        lbl.Text = "⚠️ " .. tostring(erro)
        lbl.TextColor3 = C.orange
      end
      rolarFim()
      if not Page.Visible then
        X.aiUnread = true
        if X.paintNav then X.paintNav() end
      end
    end)
  end

  -- aviso automático (a IA "fala sozinha")
  function AI.alert(chave, texto, cor, chips, forcar)
    if not forcar and not S.aiAlerts then return end
    local agora = os.clock()
    if not forcar then
      if AI.lastAlert[chave] and agora - AI.lastAlert[chave] < 90 then return end
      if agora - AI.lastAny < 8 then return end
    end
    AI.lastAlert[chave] = agora
    AI.lastAny = agora
    table.insert(AI.events, string.sub(texto, 1, 200))
    while #AI.events > 4 do table.remove(AI.events, 1) end
    chips = chips or {}
    table.insert(chips, { label = "🤖 Pedir ajuda da IA", fn = function()
      AI.ask("Explique esse aviso e me diga o que fazer: " .. texto, false)
    end })
    bubble("ai", texto, cor or C.orange, chips)
    if not Page.Visible then
      X.aiUnread = true
      if X.paintNav then X.paintNav() end
      toast("★ " .. string.sub(texto, 1, 60), cor or C.gold)
    end
    if S.aiAuto and not AI.busy then
      AI.ask("Explique em 3 linhas o que aconteceu e o que eu faço: " .. texto, false, true)
    end
  end

  -- barra de cima
  local function atualizarStatus()
    local p = provider()
    statusLbl.Text = p and ("Modo: " .. p.nome) or "Chave não reconhecida"
    statusLbl.TextColor3 = p and C.gray or C.orange
  end
  atualizarStatus()

  local bTela = button(box, "👁 Tela", 695, 8, 80, 28, C.card2, 11)
  local bJogo = button(box, "💡 Jogo", 781, 8, 86, 28, C.card2, 11)
  local bCfg = button(box, "⚙", 873, 8, 44, 28, C.card2, 13)
  local bLimpa = button(box, "🗑", 923, 8, 44, 28, C.card2, 13)

  -- entrada de texto
  local entrada = create("TextBox", {
    Position = UDim2.fromOffset(12, 316), Size = UDim2.fromOffset(800, 40), BackgroundColor3 = C.card,
    Text = "", PlaceholderText = "Pergunte sobre o jogo, os scripts ou os comandos...", PlaceholderColor3 = C.gray,
    TextColor3 = C.white, TextSize = 13, Font = GOTHAM, TextXAlignment = LEFT, ClearTextOnFocus = false,
    BorderSizePixel = 0,
  }, box)
  corner(entrada, 20)
  create("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) }, entrada)
  local bEnviar = button(box, "Enviar ➤", 820, 316, 151, 40, C.blue2, 13)

  local function enviar()
    local t = trim(entrada.Text)
    if t == "" then return end
    entrada.Text = ""
    AI.ask(t, false)
  end
  bEnviar.MouseButton1Click:Connect(enviar)
  entrada.FocusLost:Connect(function(enter) if enter then enviar() end end)

  bTela.MouseButton1Click:Connect(function()
    AI.ask("Olhe a minha tela agora e me diga o que está acontecendo e se algo parece errado.", true)
  end)
  bJogo.MouseButton1Click:Connect(function()
    AI.ask("Que comandos do NOVEX ou hub de script combinam com este jogo? Seja específica.", false)
  end)
  bLimpa.MouseButton1Click:Connect(function()
    for _, ch in ipairs(sc:GetChildren()) do
      if ch:IsA("Frame") then ch:Destroy() end
    end
    AI.hist = {}
    toast("Conversa limpa.", C.gray)
  end)

  ----------------------------------------------------------------
  -- Painel de configuração (engrenagem)
  ----------------------------------------------------------------
  local cfg = create("Frame", {
    Position = UDim2.fromOffset(12, 44), Size = UDim2.fromOffset(959, 262), BackgroundColor3 = C.black,
    BackgroundTransparency = 0.04, BorderSizePixel = 0, Visible = false,
  }, box)
  corner(cfg, 14)
  line(cfg, "Chave grátis (opcional)", 14, 8, 600, 22, C.gold, BOLD, 13)
  label(cfg, "Sem chave a IA funciona, mas só responde de vez em quando (o servidor grátis limita). Com uma chave grátis ela fica rápida. A mais fácil é a do Groq: abra console.groq.com, entre em API Keys e crie uma (começa com gsk_). Gemini (AIza...) e OpenRouter (sk-or-...) também servem.", 14, 30, 930, 44, C.gray, GOTHAM, 10)
  local keyBox = create("TextBox", {
    Position = UDim2.fromOffset(14, 82), Size = UDim2.fromOffset(700, 34), BackgroundColor3 = C.card,
    Text = "", PlaceholderText = "Cole a chave aqui (gsk_..., AIza... ou sk-or-...)", PlaceholderColor3 = C.gray,
    TextColor3 = C.white, TextSize = 12, Font = GOTHAM, TextXAlignment = LEFT, ClearTextOnFocus = false, BorderSizePixel = 0,
  }, cfg)
  corner(keyBox, 17)
  create("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, keyBox)
  local bSalvar = button(cfg, "Salvar", 724, 82, 110, 34, C.green, 12, C.black)
  local bApagar = button(cfg, "Apagar", 842, 82, 100, 34, C.red, 12)
  local keyInfo = line(cfg, "", 14, 122, 930, 16, C.gray, GOTHAM, 10)
  local function pintarKeyInfo()
    local k = trim(S.aiKey)
    keyInfo.Text = k == "" and "Nenhuma chave salva: usando o modo grátis." or ("Chave salva (termina em ..." .. string.sub(k, -4) .. "). Ela fica só no seu celular.")
  end
  pintarKeyInfo()

  local bLinkG = button(cfg, "Copiar site do Groq", 14, 146, 170, 30, C.card2, 11)
  local bLinkA = button(cfg, "Copiar site do Gemini", 192, 146, 180, 30, C.card2, 11)
  bLinkG.MouseButton1Click:Connect(function() X.doCopy("https://console.groq.com/keys", "Link do Groq copiado!") end)
  bLinkA.MouseButton1Click:Connect(function() X.doCopy("https://aistudio.google.com/api-keys", "Link do Gemini copiado!") end)

  bSalvar.MouseButton1Click:Connect(function()
    local k = trim(keyBox.Text)
    if k == "" then toast("Cole a chave primeiro.", C.orange) return end
    S.aiKey = k
    saveData()
    keyBox.Text = ""
    atualizarStatus()
    pintarKeyInfo()
    if provider() then toast("Chave salva!", C.green) else toast("Não reconheci essa chave.", C.orange) end
  end)
  bApagar.MouseButton1Click:Connect(function()
    S.aiKey = ""
    saveData()
    atualizarStatus()
    pintarKeyInfo()
    toast("Chave apagada. Voltou ao modo grátis.", C.gray)
  end)

  line(cfg, "Avisos automáticos (a IA fala sozinha quando algo falha)", 14, 190, 800, 20, C.white, BOLD, 12)
  makeSwitch(cfg, 900, 188, S.aiAlerts ~= false, function(v) S.aiAlerts = v saveData() end, true)
  line(cfg, "IA explica os avisos sozinha (gasta mais pedidos)", 14, 226, 800, 20, C.white, BOLD, 12)
  makeSwitch(cfg, 900, 224, S.aiAuto == true, function(v) S.aiAuto = v saveData() end, true)

  bCfg.MouseButton1Click:Connect(function() cfg.Visible = not cfg.Visible end)

  ----------------------------------------------------------------
  -- Avisos sobre scripts do ScriptBlox (rodou? deu erro? 404?)
  ----------------------------------------------------------------
  function X.aiSnap()
    local snap = { t = os.clock(), guis = {} }
    local function ver(raiz)
      if not raiz then return end
      for _, c in ipairs(raiz:GetChildren()) do snap.guis[c] = true end
    end
    pcall(function() ver(type(gethui) == "function" and gethui() or nil) end)
    pcall(function() ver(game:GetService("CoreGui")) end)
    pcall(function() ver(PlayerGui) end)
    return snap
  end

  function X.aiEvent(tipo, item, info, snap)
    local nome = tostring(item and (item.title or item.name) or "script")
    if #nome > 36 then nome = string.sub(nome, 1, 34) .. "…" end
    if tipo == "baixar" then
      local e = tostring(info or "sem resposta")
      local txt
      if string.find(e, "404", 1, true) then
        txt = "❌ \"" .. nome .. "\": erro 404. O link desse script não existe mais (o dono apagou ou o site tirou do ar). Não é culpa sua nem do NOVEX: escolha outro da lista."
      elseif string.find(e, "403", 1, true) or string.find(e, "429", 1, true) then
        txt = "❌ \"" .. nome .. "\": o site recusou o download (" .. e .. "). Pode ser limite de acessos; espere um minuto e tente de novo."
      elseif string.find(e, "HTTP 5", 1, true) then
        txt = "❌ \"" .. nome .. "\": o site do script está com problema (" .. e .. "). Tente mais tarde ou escolha outro."
      else
        txt = "❌ \"" .. nome .. "\": não consegui baixar (" .. string.sub(e, 1, 50) .. "). Pode ser internet ou o site fora do ar."
      end
      AI.alert("baixar", txt, C.red, nil, true)
    elseif tipo == "compilar" then
      AI.alert("compilar", "❌ \"" .. nome .. "\": o código está quebrado ou usa algo que o seu executor não entende (" .. string.sub(tostring(info), 1, 50) .. "). Escolha outro script.", C.red, nil, true)
    elseif tipo == "erro" then
      AI.alert("erro", "❌ \"" .. nome .. "\": deu erro ao rodar (" .. string.sub(tostring(info), 1, 60) .. "). Costuma ser script antigo ou feito para outro jogo.", C.red, nil, true)
    elseif tipo == "rodou" then
      task.delay(5, function()
        local novos = {}
        local snap2 = X.aiSnap()
        for inst in pairs(snap2.guis) do
          if not (snap and snap.guis[inst]) and inst ~= GUI and inst.Name ~= "NOVEX" and #novos < 3 then
            table.insert(novos, inst.Name)
          end
        end
        local errs = snap and errosDesde(snap.t, 2) or {}
        if #errs > 0 then
          AI.alert("rodou_erro", "⚠️ \"" .. nome .. "\" rodou, mas o jogo mostrou erro logo depois: " .. string.sub(errs[1], 1, 70) .. " (pode ser do próprio jogo, não só do script).", C.orange, nil, true)
        elseif #novos > 0 then
          AI.alert("rodou_ok", "✅ \"" .. nome .. "\" rodou e apareceu uma janela nova (" .. table.concat(novos, ", ") .. "). Deve ter funcionado.", C.green, nil, true)
        else
          AI.alert("rodou_semsinal", "🤔 \"" .. nome .. "\" rodou sem erro, mas não vi nada novo na tela. Pode funcionar sem janela, ou não ser compatível com este jogo. Teste no jogo; se nada mudou, tente outro.", C.orange, nil, true)
        end
      end)
    end
  end

  ----------------------------------------------------------------
  -- Vigia: avisa sozinha quando algo para de funcionar
  ----------------------------------------------------------------
  local seq = {}
  local function checarValores()
    for _, sv in ipairs(X.scanners or {}) do
      local V, cmd = sv.V, X.CmdByName[sv.cmd]
      if cmd and cmd.state and V.alvo ~= nil and #V.lista > 0 then
        local ruim, total = 0, 0
        for i, e in ipairs(V.lista) do
          if i > 40 then break end
          local ok, v = pcall(e.ler)
          if ok and type(v) == "number" then
            total = total + 1
            if math.abs(v - V.alvo) > 0.01 then ruim = ruim + 1 end
          end
        end
        if total > 0 and ruim * 2 >= total then seq[sv.cmd] = (seq[sv.cmd] or 0) + 1 else seq[sv.cmd] = 0 end
        if seq[sv.cmd] >= 3 then
          seq[sv.cmd] = -15
          AI.alert("val_" .. sv.cmd,
            "⚠️ O " .. sv.nome .. " parou de pegar: o jogo está devolvendo o valor original (" .. ruim .. " de " .. total .. " voltaram). Provavelmente o servidor desfaz a mudança.",
            C.orange, { { label = "🔍 Rodar buscavalor", fn = function() X.run("buscavalor", false) end } })
        end
      else
        seq[sv.cmd] = 0
      end
    end
  end

  local pingAlto = 0
  local function checarPing()
    local p = pingAtual()
    if p and p >= 450 then pingAlto = pingAlto + 1 else pingAlto = 0 end
    if pingAlto >= 3 then
      pingAlto = -10
      AI.alert("ping", "📶 Seu ping está alto (" .. math.floor(p) .. " ms). Scripts e comandos podem falhar ou atrasar. Tente trocar de servidor (comando rejoin) ou melhorar o Wi-Fi.", C.orange)
    end
  end

  task.spawn(function()
    while GUI.Parent do
      task.wait(4)
      pcall(checarValores)
      pcall(checarPing)
    end
  end)

  Player.CharacterAdded:Connect(function()
    task.delay(3, function()
      local on = nomesComandosLigados()
      if #on > 0 then
        AI.alert("respawn", "🔄 Você reapareceu. Comandos ligados: " .. table.concat(on, ", ", 1, math.min(#on, 6)) .. ". Se algum parou de funcionar, desligue e ligue de novo.", C.gray)
      end
    end)
  end)

  ----------------------------------------------------------------
  -- Abertura da aba
  ----------------------------------------------------------------
  pageHooks.AI = function()
    X.aiUnread = false
    if X.paintNav then X.paintNav() end
    atualizarStatus()
    rolarFim()
  end

  bubble("ai", "Oi, eu sou a NOVEX IA ★. Posso explicar comandos, sugerir o que usar no jogo em que você está, avisar quando um script não funcionar (e por quê) e discordar de você quando eu achar que não vai dar certo. Toque em \"👁 Tela\" para eu olhar o que está aparecendo, ou em \"💡 Jogo\" para sugestões.", C.white)
end

------------------------------------------------------------------
-- BLOCO H: CONFIGURAÇÕES
------------------------------------------------------------------
do
  local Page = Pages.Settings

  -- chip com seu perfil (topo)
  local chip = panel(Page, 840, 24, 236, 36, 18)
  local cav = create("ImageLabel", {
    Position = UDim2.fromOffset(5, 4), Size = UDim2.fromOffset(28, 28), BackgroundColor3 = C.card2,
    BorderSizePixel = 0, Image = avatarUrl(Player.UserId),
  }, chip)
  corner(cav, 14)
  line(chip, Player.DisplayName, 42, 3, 186, 16, C.white, BOLD, 12)
  line(chip, "@" .. Player.Name, 42, 18, 186, 14, C.gray, GOTHAM, 10)

  -- painel principal com abas
  local sp = panel(Page, 93, 100, 983, 372)
  local tabsBar = create("Frame", {
    Position = UDim2.fromOffset(16, 14), Size = UDim2.fromOffset(0, 32), AutomaticSize = Enum.AutomaticSize.X,
    BackgroundTransparency = 1, BorderSizePixel = 0,
  }, sp)
  create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
  }, tabsBar)

  local frames, tabBtns = {}, {}
  local tabNames = { "Geral", "Scripts", "Dados", "Sobre" }
  for i, n in ipairs(tabNames) do
    frames[n] = create("Frame", {
      Position = UDim2.fromOffset(16, 60), Size = UDim2.fromOffset(951, 300),
      BackgroundTransparency = 1, Visible = false,
    }, sp)
    local b = create("TextButton", {
      AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 32), LayoutOrder = i,
      BackgroundColor3 = C.card2, Text = n, TextColor3 = C.gray, TextSize = 12, Font = BOLD,
      AutoButtonColor = false, BorderSizePixel = 0,
    }, tabsBar)
    corner(b, 16)
    create("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) }, b)
    tabBtns[n] = b
  end

  local function showTab(name)
    for n, f in pairs(frames) do f.Visible = n == name end
    for n, b in pairs(tabBtns) do
      b.BackgroundColor3 = n == name and C.white or C.card2
      b.TextColor3 = n == name and C.black or C.gray
    end
  end
  for n, b in pairs(tabBtns) do
    b.MouseButton1Click:Connect(function() showTab(n) end)
  end

  -- linhas de configuração
  local function divider(parent, y)
    create("Frame", {
      Position = UDim2.fromOffset(4, y), Size = UDim2.fromOffset(940, 1),
      BackgroundColor3 = C.white, BackgroundTransparency = 0.92, BorderSizePixel = 0,
    }, parent)
  end

  local function rowText(parent, y, title, desc)
    line(parent, title, 4, y + 2, 700, 20, C.white, BOLD, 13)
    label(parent, desc, 4, y + 22, 700, 30, C.gray, GOTHAM, 10)
    divider(parent, y + 56)
  end

  local function rowButton(parent, y, title, desc, btnText, color, fn)
    rowText(parent, y, title, desc)
    local b = button(parent, btnText, 830, y + 8, 110, 34, color, 11)
    b.MouseButton1Click:Connect(fn)
    return b
  end

  -- Geral
  local G = frames.Geral
  rowText(G, 4, "Confirmar antes de rodar", "Pede um segundo toque no botão ▶ para não rodar um script sem querer.")
  makeSwitch(G, 894, 14, DATA.settings.confirmRun, function(v)
    DATA.settings.confirmRun = v
    saveData()
  end, true)

  rowText(G, 64, "Tamanho do menu", "Aumenta ou diminui o NOVEX inteiro. Também funciona com o comando guiscale.")
  local scaleVal = line(G, "", 800, 76, 60, 28, C.white, BLACK, 15, CENTER)
  local function paintScale()
    scaleVal.Text = string.format("%d%%", math.floor((tonumber(DATA.settings.guiScale) or 1) * 100 + 0.5))
  end
  paintScale()
  local function changeScale(d)
    DATA.settings.guiScale = math.clamp(math.floor(((tonumber(DATA.settings.guiScale) or 1) + d) * 10 + 0.5) / 10, 0.5, 1.5)
    saveData()
    resize()
    paintScale()
  end
  button(G, "−", 756, 72, 40, 32, C.card2, 16).MouseButton1Click:Connect(function() changeScale(-0.1) end)
  button(G, "+", 866, 72, 40, 32, C.card2, 16).MouseButton1Click:Connect(function() changeScale(0.1) end)

  rowText(G, 124, "Abrir e fechar o menu", "Toque na pastilha NOVEX no topo da tela (dá para arrastar). No PC, use a tecla K.")
  line(G, "Tema (cores)", 4, 186, 560, 20, C.white, BOLD, 13)
  label(G, "Escolha as cores do menu. Depois de trocar, feche o NOVEX (aba Sobre) e execute de novo.", 4, 206, 560, 30, C.gray, GOTHAM, 10)
  divider(G, 240)
  local temas = { { "ouro", "Ouro" }, { "roxo", "Roxo" }, { "azul", "Azul" } }
  for i, t in ipairs(temas) do
    local atual = (DATA.settings.theme or "ouro") == t[1]
    local tb = button(G, t[2], 590 + (i - 1) * 118, 192, 106, 34, atual and C.blue2 or C.card2, 11)
    tb.MouseButton1Click:Connect(function()
      DATA.settings.theme = t[1]
      saveData()
      toast("Tema " .. t[2] .. " salvo. Feche o NOVEX e abra de novo.", C.green)
    end)
  end

  -- Scripts
  local S2 = frames.Scripts
  rowText(S2, 4, "Chave do RScripts", "Crie grátis em rscripts.net/dashboard/api e cole aqui. Sem ela, só o ScriptBlox funciona.")
  local keyBox = create("TextBox", {
    Position = UDim2.fromOffset(4, 66), Size = UDim2.fromOffset(700, 36), BackgroundColor3 = C.card,
    BackgroundTransparency = 0.3, PlaceholderText = "Cole a chave aqui", PlaceholderColor3 = C.gray,
    Text = tostring(DATA.settings.rscriptsKey or ""), TextColor3 = C.white, Font = GOTHAM, TextSize = 12,
    ClearTextOnFocus = false, TextXAlignment = LEFT, BorderSizePixel = 0,
  }, S2)
  corner(keyBox, 18)
  create("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) }, keyBox)
  local keyState = line(S2, "", 4, 110, 700, 18, C.gray, GOTHAM, 11)
  local function paintKey()
    local k = tostring(DATA.settings.rscriptsKey or "")
    keyState.Text = k ~= "" and "Chave salva." or "Nenhuma chave salva."
    keyState.TextColor3 = k ~= "" and C.green or C.gray
  end
  paintKey()
  button(S2, "Salvar", 716, 66, 100, 36, C.blue2, 12).MouseButton1Click:Connect(function()
    DATA.settings.rscriptsKey = string.gsub(keyBox.Text, "%s", "")
    keyBox.Text = DATA.settings.rscriptsKey
    saveData()
    paintKey()
    toast("Chave salva!", C.green)
  end)
  button(S2, "Apagar", 826, 66, 100, 36, C.card2, 12).MouseButton1Click:Connect(function()
    DATA.settings.rscriptsKey = ""
    keyBox.Text = ""
    saveData()
    paintKey()
    toast("Chave apagada.", C.gray)
  end)

  -- Dados
  local D = frames.Dados
  rowButton(D, 4, "Favoritos de scripts", "Apaga a sua lista de scripts favoritos.", "Limpar", C.card2, function()
    DATA.scriptFavs = {}
    saveData()
    toast("Favoritos de scripts apagados.", C.green)
  end)
  rowButton(D, 62, "Favoritos de comandos", "Apaga as estrelas da lista de comandos.", "Limpar", C.card2, function()
    DATA.cmdFavs = {}
    saveData()
    toast("Favoritos de comandos apagados.", C.green)
  end)
  rowButton(D, 120, "Biblioteca de músicas", "Apaga os IDs de áudio que você salvou.", "Limpar", C.card2, function()
    DATA.music = {}
    saveData()
    toast("Biblioteca de músicas apagada.", C.green)
  end)
  rowButton(D, 178, "Atalhos e automáticos", "Apaga os comandos bind e autorun.", "Limpar", C.red, function()
    DATA.binds = {}
    DATA.autorun = {}
    saveData()
    toast("Atalhos e automáticos apagados.", C.green)
  end)
  rowButton(D, 236, "Fotos salvas", "Apaga as fotos baixadas dos scripts.", "Limpar", C.card2, function()
    local okDel = pcall(function()
      if isfolder and isfolder(IMG_DIR) and delfolder then delfolder(IMG_DIR) end
    end)
    imgCache, imgWait = {}, {}
    toast(okDel and "Fotos apagadas." or "Seu executor não deixa apagar.", okDel and C.green or C.red)
  end)

  -- Sobre
  local A = frames.Sobre
  local execName = "Executor"
  pcall(function() if identifyexecutor then execName = tostring((identifyexecutor())) end end)
  rowText(A, 4, "NOVEX HUB 5.0 GOLD", "Menu com comandos, jogadores, música e biblioteca de scripts.")
  rowText(A, 64, "Comandos", #X.Cmds .. " comandos prontos. Use a aba Comandos ou a barra de texto.")
  rowText(A, 124, "Executor", execName)
  rowButton(A, 184, "Fechar o NOVEX", "Desliga tudo e remove o menu da tela. Execute o script de novo para abrir.", "Fechar", C.red, function()
    GUI:Destroy()
  end)

  showTab("Geral")
end

------------------------------------------------------------------
-- BLOCO I: navegação, relógio das páginas e início
------------------------------------------------------------------
do
  local info = {
    Home = { "Bem-vindo de volta, " .. Player.DisplayName, "Seu hub de scripts está pronto." },
    Cmds = { "Comandos", #X.Cmds .. " comandos prontos" },
    Players = { "Jogadores", "Veja e interaja com quem está no servidor" },
    Music = { "Música", "Toque áudios do Roblox pelo ID" },
    Scripts = { "Scripts", "Descubra algo para o seu jogo" },
    AI = { "NOVEX IA", "Pergunte, peça sugestões e receba avisos" },
    Settings = { "Configurações", "Deixe o NOVEX do seu jeito" },
  }
  local defs = {
    { "Home", "⌂", "Home" }, { "Cmds", "⚡", "Comandos" }, { "Players", "👥", "Jogadores" },
    { "Music", "🎵", "Música" }, { "Scripts", "</>", "Scripts" }, { "AI", "★", "IA" }, { "Settings", "⚙", "Config" },
  }
  local navBtns = {}
  local current = "Home"

  local nav = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromOffset(CW / 2, 486),
    Size = UDim2.fromOffset(0, 44), AutomaticSize = Enum.AutomaticSize.X,
    BackgroundColor3 = C.black, BackgroundTransparency = 0.1, BorderSizePixel = 0, ZIndex = 30,
  }, Root)
  corner(nav, 22)
  stroke(nav, C.white, 0.85)
  create("UIPadding", {
    PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5),
  }, nav)
  create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center,
  }, nav)

  local function paintNav()
    for i, d in ipairs(defs) do
      local b = navBtns[d[1]]
      local on = d[1] == current
      b.Text = on and (d[2] .. " " .. d[3]) or d[2]
      b.BackgroundTransparency = on and 0 or 1
      b.TextColor3 = on and C.white or C.gray
      if d[1] == "AI" and X.aiUnread and not on then
        b.Text = d[2] .. "●"
        b.TextColor3 = C.gold
      end
    end
  end
  X.paintNav = paintNav

  function X.setPage(name, favs)
    if not info[name] then return end
    current = name
    for n, f in pairs(Pages) do f.Visible = n == name end
    TitleLbl.Text = info[name][1]
    SubLbl.Text = info[name][2]
    paintNav()
    if name == "Scripts" and X.scriptsOpen then X.scriptsOpen(favs) end
    if pageHooks[name] then pageHooks[name]() end
  end

  for i, d in ipairs(defs) do
    local b = create("TextButton", {
      AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 34), LayoutOrder = i,
      BackgroundColor3 = C.blue2, Text = d[2], TextColor3 = C.gray, TextSize = 13, Font = BOLD,
      AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 31,
    }, nav)
    corner(b, 17)
    create("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, b)
    navBtns[d[1]] = b
    b.MouseButton1Click:Connect(function() X.setPage(d[1]) end)
  end

  -- atualização contínua (FPS, ping, relógio...)
  task.spawn(function()
    while GUI.Parent do
      for _, f in ipairs(X.tick) do pcall(f) end
      task.wait(1)
    end
  end)

  X.setPage("Home")

  -- comandos automáticos (autorun): rodam toda vez que abrir o NOVEX
  task.delay(1.5, function()
    for _, l in ipairs(DATA.autorun) do
      if not GUI.Parent then return end
      X.run(l, true)
      task.wait(0.3)
    end
  end)

  -- bordas coloridas (barra de info e botão ✦ mudam de cor)
  task.spawn(function()
    local h, alvos, ultimo = 0, {}, 0
    while GUI.Parent do
      if os.clock() - ultimo > 3 then
        ultimo = os.clock()
        alvos = {}
        for _, d in ipairs(GUI:GetDescendants()) do
          if d:IsA("UIStroke") and math.abs(d.Thickness - 1.2) < 0.01 then table.insert(alvos, d) end
        end
      end
      h = (h + 0.004) % 1
      for i, st in ipairs(alvos) do
        pcall(function() st.Color = Color3.fromHSV((h + i * 0.18) % 1, 0.75, 1) end)
      end
      task.wait(0.04)
    end
  end)

  print("NOVEX HUB 5.0 GOLD + IA - iniciado com sucesso.")
end

