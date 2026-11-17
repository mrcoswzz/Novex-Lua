-- NOVEX HUB 5.0 | ARQUIVO UNICO INTEGRADO: MENU + ASSISTENTE + PAINEL VIVO
-- Assistente IA via OpenRouter (requer endpoint proxy configurado).
-- NOVEX HUB 5.0 | visual estilo Novoline + fotos + comandos estilo Infinite Yield | feito para celular (Delta)
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
  panel = Color3.fromRGB(12, 14, 25),
  card = Color3.fromRGB(22, 25, 43),
  card2 = Color3.fromRGB(38, 43, 70),
  white = Color3.fromRGB(244, 246, 252),
  gray = Color3.fromRGB(138, 146, 168),
  blue = Color3.fromRGB(0, 200, 255),
  blue2 = Color3.fromRGB(112, 72, 255),
  purple = Color3.fromRGB(205, 75, 255),
  green = Color3.fromRGB(0, 245, 160),
  red = Color3.fromRGB(255, 65, 105),
  orange = Color3.fromRGB(255, 175, 65),
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
  settings = { confirmRun = true, rscriptsKey = "", guiScale = 1 },
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
-- Internet
------------------------------------------------------------------
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
label(Pill, "▲", 14, 0, 26, 36, C.red, BLACK, 18, CENTER).ZIndex = 51
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

        -- Janela do assistente: historico sem limite artificial por quantidade de mensagens.
        local Janela = panel(GUI, 0, 0, 310, 300, 16)
        Janela.AnchorPoint = Vector2.new(1, 0.5)
        Janela.Position = UDim2.new(1, -12, 0.5, 0)
        Janela.ZIndex = 70
        Janela.Visible = false

        local topo = create("Frame", {Size = UDim2.fromOffset(310, 36), BackgroundTransparency = 1, Active = true}, Janela)
        line(topo, "✦ Assistente NOVEX", 13, 0, 220, 34, C.white, BOLD, 13)
        local fechar = button(Janela, "✕", 276, 5, 26, 25, C.card2, 11)
        local mensagens = scroller(Janela, 8, 40, 294, 204)
        vlist(mensagens, 6)
        local caixa = create("TextBox", {
            Position = UDim2.fromOffset(8, 252), Size = UDim2.fromOffset(224, 36),
            BackgroundColor3 = C.card2, TextColor3 = C.white, PlaceholderText = "Pergunte sobre comandos ou scripts...",
            PlaceholderColor3 = C.gray, Text = "", Font = GOTHAM, TextSize = 11,
            ClearTextOnFocus = false, TextXAlignment = LEFT, BorderSizePixel = 0,
        }, Janela)
        corner(caixa, 15)
        create("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 8)}, caixa)
        local enviarBtn = button(Janela, "Enviar", 238, 252, 64, 36, C.blue2, 10)

        local ordem = 0
        local function msg(txt, eu)
            ordem = ordem + 1
            local b = create("TextLabel", {
                Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = eu and C.blue2 or C.card2,
                BackgroundTransparency = eu and 0.28 or 0.12, BorderSizePixel = 0,
                Text = (eu and "" or "✦ ") .. tostring(txt), TextColor3 = C.white,
                TextSize = 11, Font = GOTHAM, TextWrapped = true, TextXAlignment = LEFT,
                TextYAlignment = Enum.TextYAlignment.Top, RichText = true, LayoutOrder = ordem,
            }, mensagens)
            corner(b, 9)
            create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6)}, b)
            task.defer(function()
                mensagens.CanvasPosition = Vector2.new(0, math.max(0, mensagens.AbsoluteCanvasSize.Y))
            end)
            return b
        end

        -- Assistente com IA generativa via proxy OpenRouter (chave protegida no servidor).
        -- Configure a URL do seu Cloudflare Worker antes de publicar o arquivo.
        local NOVEX_AI_ENDPOINT = "https://solitary-pond-d9b4.marcosviniciusdesouza5432.workers.dev"
        local historicoIA = {}
        local IA_MAX_MENSAGENS = 12
        local iaOcupada = false

        local function postJson(url, payload)
            local funcs = {}
            if type(request) == "function" then table.insert(funcs, request) end
            if type(http_request) == "function" then table.insert(funcs, http_request) end
            if type(syn) == "table" and type(syn.request) == "function" then
                table.insert(funcs, syn.request)
            end
            if #funcs == 0 then
                return nil, "Este executor não disponibilizou uma função HTTP POST compatível."
            end

            local encoded = HttpService:JSONEncode(payload)
            local ultimoErro = "sem resposta do servidor"
            for _, fn in ipairs(funcs) do
                local ok, res = pcall(fn, {
                    Url = url,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["Accept"] = "application/json",
                    },
                    Body = encoded,
                })
                if ok and type(res) == "table" then
                    local body = res.Body or res.body or ""
                    local status = tonumber(res.StatusCode or res.Status) or 200
                    if status >= 200 and status < 300 then
                        local decoded, data = pcall(function()
                            return HttpService:JSONDecode(body)
                        end)
                        if decoded and type(data) == "table" then return data end
                        return nil, "O servidor retornou JSON inválido."
                    end
                    local decoded, data = pcall(function()
                        return HttpService:JSONDecode(body)
                    end)
                    if decoded and type(data) == "table" and data.error then
                        ultimoErro = tostring(data.error)
                    else
                        ultimoErro = "HTTP " .. tostring(status)
                    end
                elseif not ok then
                    ultimoErro = tostring(res)
                end
            end
            return nil, ultimoErro
        end

        local function contextoIA()
            local linhas = {}
            local catalogo = X and X.Cmds
            if type(catalogo) == "table" then
                for _, c in ipairs(catalogo) do
                    table.insert(linhas, string.format(
                        "%s | categoria: %s | %s | %s",
                        tostring(c.name or "?"), tostring(c.cat or "Outros"),
                        tostring(c.desc or "sem descrição"),
                        c.toggle and "alternável" or "execução única"
                    ))
                end
            end
            return table.concat({
                "Contexto atual do NOVEX HUB 5.0:",
                "Jogo: " .. tostring(jogo),
                "FPS: " .. tostring(fps) .. "; ping: " .. tostring(ping) .. " ms",
                "Jogadores: " .. tostring(#Players:GetPlayers()) .. "/" .. tostring(Players.MaxPlayers),
                "Comandos realmente registrados no arquivo:",
                #linhas > 0 and table.concat(linhas, "\n") or "Catálogo ainda não disponível.",
            }, "\n")
        end

        local function montarMensagens()
            local mensagensIA = {
                {
                    role = "system",
                    content = table.concat({
                        "Você é o Assistente NOVEX, um assistente conversacional integrado a um menu Roblox.",
                        "Responda em português brasileiro, naturalmente, com clareza e sem respostas engessadas.",
                        "Use o histórico para manter contexto. Não invente comandos, funções, estados ou resultados.",
                        "O catálogo abaixo é a única fonte confiável sobre os comandos deste NOVEX; se algo não estiver nele, diga isso.",
                        "Você apenas conversa e explica: não consegue executar ações no jogo, ativar comandos ou inspecionar código externo automaticamente.",
                        "Não ensine bypass de anticheat, exploração de vulnerabilidades, roubo de contas, abuso contra jogadores ou formas de prejudicar terceiros.",
                        "Quando receber código, explique riscos e erros; não afirme que testou em Roblox/Delta se não testou.",
                        contextoIA(),
                    }, "\n\n"),
                },
            }
            for _, item in ipairs(historicoIA) do
                table.insert(mensagensIA, { role = item.role, content = item.content })
            end
            return mensagensIA
        end

        local function perguntarIA(pergunta)
            if NOVEX_AI_ENDPOINT == "COLE_A_URL_DO_SEU_WORKER_AQUI" or NOVEX_AI_ENDPOINT == "" then
                return nil, "A IA ainda não foi conectada. Primeiro publique o Worker do OpenRouter e cole a URL dele em NOVEX_AI_ENDPOINT."
            end
            local mensagensIA = montarMensagens()
            table.insert(mensagensIA, { role = "user", content = pergunta })
            local data, err = postJson(NOVEX_AI_ENDPOINT, {
                clientId = tostring(Player.UserId),
                messages = mensagensIA,
            })
            if not data then return nil, err end
            local resposta = data.reply or data.text
            if type(resposta) ~= "string" or resposta:gsub("%s", "") == "" then
                return nil, "O modelo não retornou uma resposta válida."
            end
            table.insert(historicoIA, { role = "user", content = pergunta })
            table.insert(historicoIA, { role = "assistant", content = resposta })
            while #historicoIA > IA_MAX_MENSAGENS do table.remove(historicoIA, 1) end
            return resposta
        end

        local function enviar()
            local txt = caixa.Text
            if txt:gsub("%s", "") == "" or iaOcupada then return end
            caixa.Text = ""
            msg(txt, true)
            iaOcupada = true
            enviarBtn.Text = "..."
            local aguardando = msg("Pensando...", false)
            task.spawn(function()
                local okResp, resposta, erro = pcall(function()
                    local r, e = perguntarIA(txt)
                    return r, e
                end)
                if okResp and resposta then
                    aguardando.Text = "✦ " .. tostring(resposta)
                else
                    local detalhe = okResp and erro or resposta
                    aguardando.Text = "✦ Não consegui falar com a IA: " .. tostring(detalhe)
                end
                iaOcupada = false
                enviarBtn.Text = "Enviar"
                task.defer(function()
                    mensagens.CanvasPosition = Vector2.new(0, math.max(0, mensagens.AbsoluteCanvasSize.Y))
                end)
            end)
        end
        enviarBtn.MouseButton1Click:Connect(enviar)
        caixa.FocusLost:Connect(function(enter) if enter then enviar() end end)
        fechar.MouseButton1Click:Connect(function() Janela.Visible = false end)
        msg("Olá! Sou o Assistente NOVEX com IA. Assim que o endpoint OpenRouter for configurado, poderei conversar e usar o catálogo real de comandos como contexto.", false)

        local Botao = create("TextButton", {
            Position = UDim2.new(0, 10, 0.5, -20), Size = UDim2.fromOffset(42, 42),
            BackgroundColor3 = C.blue2, BackgroundTransparency = 0.08, Text = "✦",
            TextSize = 22, Font = BOLD, TextColor3 = C.white, BorderSizePixel = 0,
            ZIndex = 65, Visible = false,
        }, GUI)
        corner(Botao, 21)
        stroke(Botao, C.white, 0.55, 1.2)
        arrastavel(Botao, Botao, function() Janela.Visible = not Janela.Visible end)

        local function sincroniza()
            Info.Visible = infoLigada and Shell.Visible
            Botao.Visible = Shell.Visible
            if not Shell.Visible then Janela.Visible = false end
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
local TitleLbl = line(Root, "Home", 93, 22, 400, 34, C.white, BLACK, 24)
local SubLbl = line(Root, "", 94, 58, 400, 18, C.gray, GOTHAM, 12)

for _, n in ipairs({ "Home", "Cmds", "Players", "Music", "Scripts", "Settings" }) do
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
    toast(#out == 0 and "Nenhum atalho." or table.concat(out, "  •  "), C.white)
  end)

  addCmd("autorun", "Roda um comando sempre que abrir o NOVEX. Ex: autorun antiafk", "Ferramentas", false, function(args)
    if not args or #args < 1 then fail("use: autorun antiafk") end
    local l = table.concat(args, " ")
    table.insert(DATA.autorun, l)
    saveData()
    toast("Vai rodar ao abrir: " .. l, C.green)
  end, { arg = "comando", need = true })

  addCmd("autorunlist", "Lista os comandos automáticos", "Ferramentas", false, function()
    toast(#DATA.autorun == 0 and "Nenhum comando automático." or table.concat(DATA.autorun, "  •  "), C.white)
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

  -- aceita:  cmd1 \ cmd2   |   5^2^cmd (5 vezes, a cada 2s)   |   inf^1^cmd   |   cmd1 && cmd2
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
    for _, n in ipairs({ "fly", "float", "airwalk", "anchor", "spin", "follow", "platformstand", "noanimate" }) do
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
  local hFps = line(fc, "--", 16, 26, 80, 36, C.white, BLACK, 30)
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
    Text = "", ClearTextOnFocus = false, PlaceholderText = "Tente: esp • speed 50 • 5^2^jump • fly \\ esp",
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
    "Personagem", "Jogadores", "Mundo", "Ferramentas", "Utilidades" }
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
      local code = getCode(item)
      if not code then toast("Não consegui pegar o código.", C.red) return end
      local fn, err = (loadstring or load)(code)
      if not fn then toast("Erro no script: " .. string.sub(tostring(err), 1, 50), C.red) return end
      toast("Rodando: " .. tostring(item.title or "script"), C.green)
      local ok, e = pcall(fn)
      if not ok then toast("Erro: " .. string.sub(tostring(e), 1, 60), C.red) end
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
  line(chip, Player.DisplayName, 42, 3, 184, 16, C.white, BOLD, 12)
  line(chip, "@" .. Player.Name, 42, 19, 184, 13, C.gray, GOTHAM, 10)

  local catP = panel(Page, 93, 155, 150, 317)
  line(catP, "Categorias", 16, 10, 120, 18, C.white, BOLD, 12)
  local contP = panel(Page, 253, 155, 233, 317)

  local frames, catBtns = {}, {}
  local function rowText(parent, y, title, desc)
    line(parent, title, 14, y, 140, 18, C.white, BOLD, 12)
    local d = label(parent, desc, 14, y + 19, 140, 38, C.gray, GOTHAM, 9)
    d.TextYAlignment = Enum.TextYAlignment.Top
  end
  local function rowButton(parent, y, title, desc, text, color, fn)
    rowText(parent, y, title, desc)
    button(parent, text, 160, y + 6, 58, 30, color, 10).MouseButton1Click:Connect(fn)
  end

  for i, name in ipairs({ "Geral", "Scripts", "Dados" }) do
    frames[name] = create("Frame", {
      Position = UDim2.fromOffset(0, 12), Size = UDim2.fromOffset(233, 300), BackgroundTransparency = 1, Visible = false,
    }, contP)
    local b = create("TextButton", {
      Position = UDim2.fromOffset(10, 36 + (i - 1) * 44), Size = UDim2.fromOffset(130, 38),
      BackgroundColor3 = C.card, BackgroundTransparency = 0.3, Text = " " .. name, TextColor3 = C.gray,
      TextSize = 12, Font = BOLD, TextXAlignment = LEFT, AutoButtonColor = false, BorderSizePixel = 0,
    }, catP)
    corner(b, 19)
    catBtns[name] = b
    b.MouseButton1Click:Connect(function()
      for n, fr in pairs(frames) do fr.Visible = n == name end
      for n, bb in pairs(catBtns) do
        bb.BackgroundColor3 = n == name and C.card2 or C.card
        bb.BackgroundTransparency = n == name and 0 or 0.3
        bb.TextColor3 = n == name and C.white or C.gray
      end
    end)
  end

  -- Geral
  local G = frames.Geral
  rowText(G, 4, "Confirmar antes de rodar", "Pede um segundo toque no botão ▶ para não rodar sem querer.")
  makeSwitch(G, 164, 10, DATA.settings.confirmRun, function(v)
    DATA.settings.confirmRun = v
    saveData()
  end, true)

  rowText(G, 64, "Tamanho do menu", "Aumente ou diminua tudo de uma vez.")
  local function bumpScale(d)
    DATA.settings.guiScale = math.clamp(math.floor(((tonumber(DATA.settings.guiScale) or 1) + d) * 10 + 0.5) / 10, 0.5, 1.5)
    saveData()
    resize()
  end
  button(G, "−", 160, 70, 28, 30, C.card2, 14).MouseButton1Click:Connect(function() bumpScale(-0.1) end)
  button(G, "+", 192, 70, 28, 30, C.card2, 14).MouseButton1Click:Connect(function() bumpScale(0.1) end)

  rowButton(G, 124, "Fechar NOVEX", "Remove o menu da tela por completo.", "Fechar", C.red, function() GUI:Destroy() end)
  label(G, "Versão 5.0\nBibliotecas: ScriptBlox e RScripts\n\nAbra e feche o menu na pastilha NOVEX do topo (PC: tecla K).\n\nCuidado: os scripts vêm de outras pessoas. Prefira os verificados.",
    14, 184, 205, 110, C.gray, GOTHAM, 10).TextYAlignment = Enum.TextYAlignment.Top

  -- Scripts (chave do RScripts)
  local Sc = frames.Scripts
  rowText(Sc, 4, "API key do RScripts", "Grátis. Entre em rscripts.net, abra Dashboard > API e crie sua chave (rsc_live_...).")
  local keyBox = create("TextBox", {
    Position = UDim2.fromOffset(14, 78), Size = UDim2.fromOffset(205, 34), BackgroundColor3 = C.card,
    BackgroundTransparency = 0.3, PlaceholderText = "rsc_live_...", PlaceholderColor3 = C.gray,
    Text = DATA.settings.rscriptsKey or "", TextColor3 = C.white, Font = GOTHAM, TextSize = 11,
    ClearTextOnFocus = false, TextXAlignment = LEFT, BorderSizePixel = 0,
  }, Sc)
  corner(keyBox, 17)
  create("UIPadding", { PaddingLeft = UDim.new(0, 12) }, keyBox)
  button(Sc, "Salvar chave", 14, 120, 205, 34, C.blue2, 11).MouseButton1Click:Connect(function()
    DATA.settings.rscriptsKey = string.gsub(keyBox.Text, "%s", "")
    saveData()
    toast("Chave salva!", C.green)
  end)
  button(Sc, "Copiar link da página da API", 14, 162, 205, 34, C.card2, 11).MouseButton1Click:Connect(function()
    X.doCopy("https://rscripts.net/dashboard/api", "Link copiado! Abra no navegador.")
  end)
  label(Sc, "Página da chave: rscripts.net/dashboard/api\nEndereço da API: https://api.rscripts.net/v1",
    14, 204, 205, 40, C.gray, GOTHAM, 9).TextYAlignment = Enum.TextYAlignment.Top

  -- Dados
  local D = frames.Dados
  rowButton(D, 4, "Favoritos de scripts", "Apaga os scripts favoritos.", "Limpar", C.red, function()
    DATA.scriptFavs = {}
    saveData()
    toast("Favoritos apagados.", C.green)
  end)
  rowButton(D, 62, "Estrelas de comandos", "Apaga as estrelas dos comandos.", "Limpar", C.red, function()
    DATA.cmdFavs = {}
    saveData()
    toast("Estrelas apagadas. Reabra o NOVEX.", C.green)
  end)
  rowButton(D, 120, "Atalhos e automáticos", "Apaga os comandos bind e autorun.", "Limpar", C.red, function()
    DATA.binds = {}
    DATA.autorun = {}
    saveData()
    toast("Atalhos e automáticos apagados.", C.green)
  end)
  rowButton(D, 178, "Fotos salvas", "Apaga as fotos baixadas dos scripts.", "Limpar", C.card2, function()
    local n = 0
    pcall(function()
      if listfiles and delfile and isfolder and isfolder(IMG_DIR) then
        for _, f in ipairs(listfiles(IMG_DIR)) do delfile(f) n = n + 1 end
      end
    end)
    imgCache = {}
    toast(n .. " fotos apagadas.", C.green)
  end)

  catBtns.Geral.BackgroundColor3 = C.card2
  catBtns.Geral.BackgroundTransparency = 0
  catBtns.Geral.TextColor3 = C.white
  frames.Geral.Visible = true

  -- Ajustes rápidos
  local qs = panel(Page, 827, 155, 249, 150)
  line(qs, "Ajustes rápidos", 16, 10, 200, 18, C.white, BOLD, 12)
  local function qTile(x, icon, name, color, cmdName)
    local b = create("TextButton", {
      Position = UDim2.fromOffset(x, 40), Size = UDim2.fromOffset(70, 96), BackgroundColor3 = color,
      BackgroundTransparency = 0.75, Text = "", AutoButtonColor = true, BorderSizePixel = 0,
    }, qs)
    corner(b, 16)
    stroke(b, color, 0.6)
    line(b, icon, 10, 8, 50, 24, color, BLACK, 18)
    line(b, name, 10, 54, 56, 16, C.white, BOLD, 10)
    local st = line(b, "", 10, 72, 56, 14, C.gray, GOTHAM, 9)
    b.MouseButton1Click:Connect(function() X.run(cmdName) end)
    return st
  end
  qTile(12, "⚡", "Liberar FPS", C.purple, "fpscap").Text = "Toque"
  local afkSt = qTile(88, "☾", "Anti-AFK", C.green, "antiafk")
  local espSt = qTile(164, "◉", "ESP", C.red, "esp")
  afkSt.Text, espSt.Text = "Desligado", "Desligado"
  table.insert(X.CmdByName.antiafk.syncs, function(s) afkSt.Text = s and "Ligado" or "Desligado" end)
  table.insert(X.CmdByName.esp.syncs, function(s) espSt.Text = s and "Ligado" or "Desligado" end)

  -- Atalhos
  local sc = panel(Page, 827, 317, 249, 155)
  line(sc, "Atalhos", 16, 10, 200, 18, C.white, BOLD, 12)
  local function sRow(y, title, desc, key)
    line(sc, title, 16, y, 130, 16, C.white, BOLD, 12)
    line(sc, desc, 16, y + 17, 130, 14, C.gray, GOTHAM, 9)
    local k = create("TextLabel", {
      Position = UDim2.fromOffset(150, y + 2), Size = UDim2.fromOffset(86, 28), BackgroundColor3 = C.card2,
      Text = key, TextColor3 = C.white, TextSize = 11, Font = BOLD, BorderSizePixel = 0,
    }, sc)
    corner(k, 14)
  end
  sRow(38, "Abrir / fechar", "Mostra ou esconde o menu", "▲ / K")
  sRow(84, "Barra de comando", "Digite na aba Comandos", "Cmds")
  sRow(114, "Mais comandos", "Veja a lista completa", "Cmds")
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
    Settings = { "Configurações", "Deixe o NOVEX do seu jeito" },
  }
  local defs = {
    { "Home", "⌂", "Home" }, { "Cmds", "⚡", "Comandos" }, { "Players", "👥", "Jogadores" },
    { "Music", "🎵", "Música" }, { "Scripts", "</>", "Scripts" }, { "Settings", "⚙", "Config" },
  }
  local navBtns = {}
  local current = "Home"

  local nav = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromOffset(CW / 2, 484),
    Size = UDim2.fromOffset(0, 42), AutomaticSize = Enum.AutomaticSize.X,
    BackgroundColor3 = C.panel, BackgroundTransparency = 0.1, BorderSizePixel = 0, Active = true,
  }, Root)
  corner(nav, 21)
  stroke(nav, C.white, 0.9)
  create("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 4) }, nav)
  create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
  }, nav)

  local function paintNav()
    for _, d in ipairs(defs) do
      local b = navBtns[d[1]]
      local on = d[1] == current
      b.Text = on and (d[2] .. " " .. d[3]) or d[2]
      b.BackgroundTransparency = on and 0 or 1
      b.TextColor3 = on and C.white or C.gray
    end
  end

  function X.setPage(name, favs)
    current = name
    for n, f in pairs(Pages) do f.Visible = n == name end
    TitleLbl.Text = info[name][1]
    SubLbl.Text = info[name][2]
    paintNav()
    if name == "Scripts" then X.scriptsOpen(favs) end
    if pageHooks[name] then pageHooks[name]() end
  end

  for i, d in ipairs(defs) do
    local b = create("TextButton", {
      AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 34), LayoutOrder = i,
      BackgroundColor3 = C.card2, BackgroundTransparency = 1, Text = d[2], TextColor3 = C.gray,
      TextSize = 13, Font = BOLD, AutoButtonColor = false, BorderSizePixel = 0,
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

  print("NOVEX HUB 5.0 - iniciado com sucesso.")
end
