--[[
  NOVEX HUB 5.0  (sem IA, arquivo único, não depende de outros arquivos)
  Como usar: toque no botão ✦ para abrir o menu.
  - Toque num comando da lista para usar.
  - Se o comando precisa de valor (ex: speed), ele vai pra barra de baixo: complete e aperte ▶.
  - Pode digitar na barra de baixo: ela filtra a lista enquanto você escreve.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Player = Players.LocalPlayer
local G = (getgenv and getgenv()) or _G

if G.NOVEX_UNLOAD then pcall(G.NOVEX_UNLOAD) end

-- ============================================================
-- CORES (pode mudar os números R, G, B)
-- ============================================================
local C = {
  panel  = Color3.fromRGB(14, 9, 30),
  panel2 = Color3.fromRGB(26, 14, 52),
  card   = Color3.fromRGB(30, 19, 60),
  card2  = Color3.fromRGB(58, 36, 104),
  gray   = Color3.fromRGB(170, 160, 205),
  white  = Color3.fromRGB(245, 242, 255),
  gold   = Color3.fromRGB(255, 205, 64),
  gold2  = Color3.fromRGB(255, 142, 38),
  cyan   = Color3.fromRGB(0, 229, 255),
  pink   = Color3.fromRGB(255, 58, 212),
  violet = Color3.fromRGB(146, 66, 255),
  green  = Color3.fromRGB(0, 255, 140),
  red    = Color3.fromRGB(255, 48, 92),
  dark   = Color3.fromRGB(20, 12, 40),
}

local allConns = {}
local function keep(c) table.insert(allConns, c) return c end
local function fail(msg) error(msg, 0) end

local function new(class, props, parent)
  local o = Instance.new(class)
  for k, v in pairs(props or {}) do o[k] = v end
  if parent then o.Parent = parent end
  return o
end

-- ============================================================
-- JANELA
-- ============================================================
local gui = new("ScreenGui", {
  Name = "NOVEX", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999,
  ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
local okParent = pcall(function()
  gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not okParent or not gui.Parent then gui.Parent = Player:WaitForChild("PlayerGui") end

local vp = workspace.CurrentCamera.ViewportSize
local W = math.clamp(vp.X * 0.94, 300, 560)
local H = math.clamp(vp.Y * 0.74, 280, 420)

local Main = new("Frame", {
  Size = UDim2.fromOffset(W, H), Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2),
  BackgroundColor3 = C.panel, Visible = false, ClipsDescendants = true, Active = true,
}, gui)
new("UICorner", { CornerRadius = UDim.new(0, 16) }, Main)
local MainScale = new("UIScale", { Scale = 1 }, Main)
local mainStroke = new("UIStroke", { Thickness = 1.8, Color = C.gold }, Main)
new("UIGradient", {
  Rotation = 90,
  Color = ColorSequence.new(C.panel2, C.panel),
}, Main)

-- Cabeçalho
local Head = new("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, Active = true }, Main)
local title = new("TextLabel", {
  Text = "NOVEX", Font = Enum.Font.GothamBlack, TextSize = 22, TextColor3 = C.white,
  BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
  Position = UDim2.fromOffset(14, 0), Size = UDim2.fromOffset(90, 42),
}, Head)
new("UIGradient", {
  Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.gold),
    ColorSequenceKeypoint.new(0.6, C.gold2),
    ColorSequenceKeypoint.new(1, C.pink),
  }),
}, title)
new("TextLabel", {
  Text = "HUB 5.0", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.gray,
  BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
  Position = UDim2.fromOffset(94, 8), Size = UDim2.fromOffset(70, 28),
}, Head)
local fpsLbl = new("TextLabel", {
  Text = "-- FPS", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.gold,
  BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right,
  Position = UDim2.new(1, -112, 0, 0), Size = UDim2.fromOffset(70, 42),
}, Head)
local closeBtn = new("TextButton", {
  Text = "✕", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = C.white,
  BackgroundColor3 = C.card2, AutoButtonColor = false,
  Position = UDim2.new(1, -40, 0, 6), Size = UDim2.fromOffset(30, 30),
}, Head)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, closeBtn)
closeBtn.Activated:Connect(function() Main.Visible = false end)

-- Abas
local Tabs = new("ScrollingFrame", {
  Position = UDim2.fromOffset(0, 42), Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1,
  ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0),
  AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollingDirection = Enum.ScrollingDirection.X,
  BorderSizePixel = 0,
}, Main)
new("UIListLayout", {
  FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
  VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
}, Tabs)
new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, Tabs)

-- Lista
local List = new("ScrollingFrame", {
  Position = UDim2.fromOffset(10, 80), Size = UDim2.new(1, -20, 1, -80 - 50),
  BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
  ScrollBarImageColor3 = C.gold, CanvasSize = UDim2.new(0, 0, 0, 0),
  AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, Main)
new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, List)

-- Barra de baixo
local Bar = new("Frame", {
  Position = UDim2.new(0, 10, 1, -44), Size = UDim2.new(1, -20, 0, 36), BackgroundTransparency = 1,
}, Main)
local box = new("TextBox", {
  PlaceholderText = "comando... ex: fly, speed 50", PlaceholderColor3 = C.gray, Text = "",
  Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = C.white, ClearTextOnFocus = false,
  BackgroundColor3 = C.card, TextXAlignment = Enum.TextXAlignment.Left,
  Size = UDim2.new(1, -52, 1, 0),
}, Bar)
new("UICorner", { CornerRadius = UDim.new(0, 10) }, box)
new("UIPadding", { PaddingLeft = UDim.new(0, 10) }, box)
new("UIStroke", { Thickness = 1, Color = C.card2 }, box)
local runBtn = new("TextButton", {
  Text = "▶", Font = Enum.Font.GothamBlack, TextSize = 16, TextColor3 = C.dark,
  BackgroundColor3 = C.gold, AutoButtonColor = false,
  Position = UDim2.new(1, -44, 0, 0), Size = UDim2.fromOffset(44, 36),
}, Bar)
new("UICorner", { CornerRadius = UDim.new(0, 10) }, runBtn)
new("UIGradient", { Color = ColorSequence.new(C.gold, C.gold2), Rotation = 90 }, runBtn)

-- Botão flutuante ✦
local Open = new("TextButton", {
  Text = "✦", Font = Enum.Font.GothamBlack, TextSize = 24, TextColor3 = C.gold,
  BackgroundColor3 = C.panel, AutoButtonColor = false,
  Position = UDim2.new(0, 12, 0.3, 0), Size = UDim2.fromOffset(48, 48),
}, gui)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, Open)
local openStroke = new("UIStroke", { Thickness = 2, Color = C.gold }, Open)

-- Aviso (toast)
local toastF = new("Frame", {
  Size = UDim2.fromOffset(300, 36), Position = UDim2.new(0.5, -150, 0, 18),
  BackgroundColor3 = C.panel, Visible = false,
}, gui)
new("UICorner", { CornerRadius = UDim.new(0, 12) }, toastF)
local toastStroke = new("UIStroke", { Thickness = 1.5, Color = C.gold }, toastF)
local toastLbl = new("TextLabel", {
  Text = "", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.white,
  BackgroundTransparency = 1, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(8, 0),
  TextTruncate = Enum.TextTruncate.AtEnd,
}, toastF)
local toastId = 0
local function toast(msg, cor)
  toastId = toastId + 1
  local id = toastId
  cor = cor or C.white
  toastLbl.Text = tostring(msg)
  toastLbl.TextColor3 = cor
  toastStroke.Color = cor
  toastF.Visible = true
  task.delay(2.6, function() if id == toastId then toastF.Visible = false end end)
end

-- Arrastar
local function draggable(handle, target, onTap)
  local dragging, dragInput, startPos, startMouse, moved = false, nil, nil, nil, false
  handle.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging = true; moved = false; startMouse = i.Position; startPos = target.Position
      i.Changed:Connect(function()
        if i.UserInputState == Enum.UserInputState.End then
          dragging = false
          if not moved and onTap then onTap() end
        end
      end)
    end
  end)
  handle.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then
      dragInput = i
    end
  end)
  keep(UIS.InputChanged:Connect(function(i)
    if dragging and i == dragInput then
      local d = i.Position - startMouse
      if d.Magnitude > 6 then moved = true end
      if moved then
        target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
      end
    end
  end))
end
draggable(Head, Main)
draggable(Open, Open, function() Main.Visible = not Main.Visible end)

-- Borda colorida + FPS
do
  local hue, acc, frames, tFps = 0, 0, 0, 0
  keep(RunService.Heartbeat:Connect(function(dt)
    acc = acc + dt
    if acc >= 0.05 then
      hue = (hue + acc * 0.12) % 1
      acc = 0
      local cor = Color3.fromHSV(hue, 0.7, 1)
      mainStroke.Color = cor
      openStroke.Color = cor
    end
    frames = frames + 1
    tFps = tFps + dt
    if tFps >= 0.5 then
      fpsLbl.Text = math.floor(frames / tFps + 0.5) .. " FPS"
      frames, tFps = 0, 0
    end
  end))
end

-- ============================================================
-- SISTEMA DE COMANDOS
-- ============================================================
local Cmds, CmdByName, Alias = {}, {}, {}
local curTab = "Todos"
local applyFilter

local function track(cmd, conn)
  cmd.conns = cmd.conns or {}
  table.insert(cmd.conns, conn)
  return conn
end
local function unbind(cmd)
  for _, c in ipairs(cmd.conns or {}) do pcall(function() c:Disconnect() end) end
  cmd.conns = {}
end

local function add(name, desc, cat, isToggle, fn, opt)
  if CmdByName[name] then return end
  opt = opt or {}
  local cmd = {
    name = name, desc = desc, cat = cat, toggle = isToggle, fn = fn, on = false,
    arg = opt.arg, need = opt.need, alias = {}, conns = {},
  }
  for _, a in ipairs(opt.alias or {}) do
    if not CmdByName[a] and not Alias[a] then
      table.insert(cmd.alias, a)
      Alias[a] = cmd
    end
  end
  CmdByName[name] = cmd
  table.insert(Cmds, cmd)

  local row = new("TextButton", {
    Text = "", AutoButtonColor = false, BackgroundColor3 = C.card,
    Size = UDim2.new(1, -4, 0, 46), Visible = false,
  }, List)
  new("UICorner", { CornerRadius = UDim.new(0, 10) }, row)
  local nm = name
  if cmd.arg then nm = nm .. ' <font color="#AAA0CD">' .. cmd.arg .. "</font>" end
  new("TextLabel", {
    Text = nm, RichText = true, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.gold,
    BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.fromOffset(12, 5), Size = UDim2.new(1, -54, 0, 18),
  }, row)
  new("TextLabel", {
    Text = desc, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.gray,
    BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    Position = UDim2.fromOffset(12, 24), Size = UDim2.new(1, -54, 0, 18),
  }, row)
  if isToggle then
    local dot = new("Frame", {
      BackgroundColor3 = C.card2, Size = UDim2.fromOffset(14, 14),
      Position = UDim2.new(1, -28, 0.5, -7),
    }, row)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, dot)
    cmd.dot = dot
  else
    new("TextLabel", {
      Text = "›", Font = Enum.Font.GothamBlack, TextSize = 22, TextColor3 = C.gold2,
      BackgroundTransparency = 1, Position = UDim2.new(1, -34, 0, 0), Size = UDim2.fromOffset(24, 46),
    }, row)
  end
  cmd.row = row
  cmd.rowClick = row
  return cmd
end

local function refreshDot(cmd)
  if cmd.dot then cmd.dot.BackgroundColor3 = cmd.on and C.green or C.card2 end
end

local function execute(cmd, args)
  args = args or {}
  if cmd.toggle then
    local novo
    local a1 = args[1] and tostring(args[1]):lower()
    if a1 == "on" or a1 == "ligar" then novo = true; table.remove(args, 1)
    elseif a1 == "off" or a1 == "desligar" then novo = false; table.remove(args, 1)
    elseif a1 and tonumber(a1) and cmd.on then novo = true
    else novo = not cmd.on end
    local ok, err = pcall(cmd.fn, novo, args)
    if ok then
      cmd.on = novo
      refreshDot(cmd)
      toast(cmd.name .. (novo and " ligado" or " desligado"), novo and C.green or C.gray)
    else
      toast(tostring(err), C.red)
    end
  else
    local ok, err = pcall(cmd.fn, args)
    if not ok then toast(tostring(err), C.red) end
  end
end

local function runText(text)
  local parts = {}
  for w in tostring(text):gmatch("%S+") do parts[#parts + 1] = w end
  local name = table.remove(parts, 1)
  if not name then return end
  name = name:lower()
  local cmd = CmdByName[name] or Alias[name]
  if not cmd then toast("Esse comando não existe: " .. name, C.red) return end
  execute(cmd, parts)
end

-- ============================================================
-- AJUDANTES
-- ============================================================
local function hum() local c = Player.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function root()
  local c = Player.Character
  return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso"))
end
local function eu() local r = root() if not r then fail("sem personagem") end return r end
local function euH() local h = hum() if not h then fail("sem personagem") end return h end
local function num(args, i, padrao) return tonumber(args and args[i or 1]) or padrao end
local function must(args, ex)
  local n = tonumber(args and args[1])
  if not n then fail("use: " .. ex) end
  return n
end

local function getTarget(s)
  if not s or s == "" then fail("diga o nome do jogador") end
  s = s:lower()
  if s == "me" or s == "eu" then return Player end
  if s == "random" or s == "aleatorio" then
    local l = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= Player then l[#l + 1] = p end end
    if #l == 0 then fail("não tem mais ninguém no servidor") end
    return l[math.random(#l)]
  end
  local melhor, contem
  for _, p in ipairs(Players:GetPlayers()) do
    local n, d = p.Name:lower(), p.DisplayName:lower()
    if n == s or d == s then return p end
    if not melhor and (n:sub(1, #s) == s or d:sub(1, #s) == s) then melhor = p end
    if not contem and (n:find(s, 1, true) or d:find(s, 1, true)) then contem = p end
  end
  if melhor or contem then return melhor or contem end
  fail("não achei o jogador: " .. s)
end

local function otherPlayers()
  local l = {}
  for _, p in ipairs(Players:GetPlayers()) do if p ~= Player then l[#l + 1] = p end end
  return l
end

local function doCopy(texto, msg)
  local f = setclipboard or toclipboard
  if not f then fail("seu executor não consegue copiar") end
  pcall(f, texto)
  toast(msg or "Copiado!", C.green)
end

local lOrig = {}
local function lset(p, v)
  if lOrig[p] == nil then lOrig[p] = Lighting[p] end
  Lighting[p] = v
end
local function lrestore(p)
  if lOrig[p] ~= nil then pcall(function() Lighting[p] = lOrig[p] end) lOrig[p] = nil end
end

-- Mantém velocidade/pulo definidos
local speedVal, jumpVal, hipVal
keep(RunService.Heartbeat:Connect(function()
  local h = hum()
  if not h then return end
  if speedVal then h.WalkSpeed = speedVal end
  if jumpVal then h.UseJumpPower = true h.JumpPower = jumpVal end
  if hipVal then h.HipHeight = hipVal end
end))

-- ============================================================
-- MOVIMENTO
-- ============================================================
add("speed", "Muda a velocidade. Ex: speed 50", "Movimento", false, function(args)
  speedVal = math.clamp(must(args, "speed 50"), 0, 1000)
  local h = hum() if h then h.WalkSpeed = speedVal end
end, { arg = "n", need = true, alias = { "ws", "walkspeed" } })

add("resetspeed", "Velocidade normal de volta", "Movimento", false, function()
  speedVal = nil
  local h = hum() if h then h.WalkSpeed = 16 end
end, { alias = { "rspeed" } })

add("jumppower", "Muda a força do pulo. Ex: jumppower 100", "Movimento", false, function(args)
  jumpVal = math.clamp(must(args, "jumppower 100"), 0, 1000)
end, { arg = "n", need = true, alias = { "jp", "jump" } })

add("resetjump", "Pulo normal de volta", "Movimento", false, function()
  jumpVal = nil
  local h = hum() if h then h.UseJumpPower = true h.JumpPower = 50 end
end, { alias = { "rjump" } })

add("hipheight", "Muda a altura do corpo. Ex: hipheight 10", "Movimento", false, function(args)
  hipVal = must(args, "hipheight 10")
  local h = hum() if h then h.HipHeight = hipVal end
end, { arg = "n", need = true })

add("resethip", "Altura do corpo normal", "Movimento", false, function()
  hipVal = nil
  local h = hum() if h then h.HipHeight = 2 end
end)

local flySpeed = 60
local function stopFly()
  local r = root()
  if r then
    for _, n in ipairs({ "NOVEX_FLY_V", "NOVEX_FLY_G" }) do
      local o = r:FindFirstChild(n)
      if o then o:Destroy() end
    end
  end
  local h = hum()
  if h then h.PlatformStand = false end
end

add("fly", "Voa. Pule = sobe. Ex: fly 80", "Movimento", true, function(on, args)
  local cmd = CmdByName.fly
  unbind(cmd)
  stopFly()
  if not on then return end
  flySpeed = num(args, 1, flySpeed)
  local r, h = eu(), euH()
  local bv = new("BodyVelocity", { Name = "NOVEX_FLY_V", MaxForce = Vector3.new(1e9, 1e9, 1e9), Velocity = Vector3.new(0, 0, 0) }, r)
  local bg = new("BodyGyro", { Name = "NOVEX_FLY_G", MaxTorque = Vector3.new(1e9, 1e9, 1e9), P = 9e4, CFrame = r.CFrame }, r)
  h.PlatformStand = true
  local upUntil = 0
  track(cmd, UIS.JumpRequest:Connect(function() upUntil = os.clock() + 0.25 end))
  track(cmd, RunService.RenderStepped:Connect(function()
    local rr, hh = root(), hum()
    if not rr or not hh or not bv.Parent then return end
    local cam = workspace.CurrentCamera.CFrame
    local md = hh.MoveDirection
    local vel = md * flySpeed
    local flat = Vector3.new(cam.LookVector.X, 0, cam.LookVector.Z)
    if md.Magnitude > 0 and flat.Magnitude > 0 then
      vel = vel + Vector3.new(0, cam.LookVector.Y * md:Dot(flat.Unit) * flySpeed, 0)
    end
    if os.clock() < upUntil then vel = vel + Vector3.new(0, flySpeed, 0) end
    bv.Velocity = vel
    if flat.Magnitude > 0 then bg.CFrame = CFrame.new(rr.Position, rr.Position + flat) end
  end))
end, { arg = "velocidade", alias = { "voar" } })

add("flyspeed", "Muda a velocidade do fly. Ex: flyspeed 100", "Movimento", false, function(args)
  flySpeed = must(args, "flyspeed 100")
end, { arg = "n", need = true })

add("noclip", "Atravessa paredes", "Movimento", true, function(on)
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
end, { alias = { "nc", "clip" } })

add("infjump", "Pulo infinito no ar", "Movimento", true, function(on)
  local cmd = CmdByName.infjump
  unbind(cmd)
  if not on then return end
  track(cmd, UIS.JumpRequest:Connect(function()
    local h = hum()
    if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
  end))
end, { alias = { "ij", "infinitejump" } })

add("bhop", "Pula sozinho enquanto você anda", "Movimento", true, function(on)
  local cmd = CmdByName.bhop
  unbind(cmd)
  if not on then return end
  track(cmd, RunService.Heartbeat:Connect(function()
    local h = hum()
    if h and h.MoveDirection.Magnitude > 0 and h.FloorMaterial ~= Enum.Material.Air then h.Jump = true end
  end))
end, { alias = { "bunnyhop" } })

add("spin", "Gira seu personagem. Ex: spin 20", "Movimento", true, function(on, args)
  local r = root()
  if r then local o = r:FindFirstChild("NOVEX_SPIN") if o then o:Destroy() end end
  if not on then return end
  new("BodyAngularVelocity", {
    Name = "NOVEX_SPIN", MaxTorque = Vector3.new(0, 1e9, 0),
    AngularVelocity = Vector3.new(0, num(args, 1, 20), 0), P = 1e5,
  }, eu())
end, { arg = "velocidade", alias = { "girar" } })

add("dash", "Impulso pra frente. Ex: dash 120", "Movimento", false, function(args)
  local r = eu()
  r.AssemblyLinearVelocity = r.CFrame.LookVector * num(args, 1, 100) + Vector3.new(0, 15, 0)
end, { arg = "n" })

add("launch", "Impulso pra cima. Ex: launch 150", "Movimento", false, function(args)
  local r = eu()
  local v = r.AssemblyLinearVelocity
  r.AssemblyLinearVelocity = Vector3.new(v.X, num(args, 1, 120), v.Z)
end, { arg = "n" })

add("clicktp", "Toque no chão pra teleportar até lá", "Movimento", true, function(on)
  local cmd = CmdByName.clicktp
  unbind(cmd)
  if not on then return end
  track(cmd, UIS.TouchTapInWorld:Connect(function(pos, usadoPelaUI)
    if usadoPelaUI then return end
    local cam = workspace.CurrentCamera
    local raio = cam:ScreenPointToRay(pos.X, pos.Y)
    local pr = RaycastParams.new()
    pr.FilterType = Enum.RaycastFilterType.Exclude
    pr.FilterDescendantsInstances = { Player.Character }
    local hit = workspace:Raycast(raio.Origin, raio.Direction * 1000, pr)
    local r = root()
    if hit and r then r.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0)) end
  end))
end, { alias = { "taptp" } })

add("antivoid", "Te salva se você cair no vazio", "Movimento", true, function(on)
  local cmd = CmdByName.antivoid
  unbind(cmd)
  if not on then return end
  local seguro
  track(cmd, RunService.Heartbeat:Connect(function()
    local r, h = root(), hum()
    if not r or not h then return end
    if h.FloorMaterial ~= Enum.Material.Air then seguro = r.CFrame end
    if seguro and r.Position.Y < workspace.FallenPartsDestroyHeight + 40 then
      r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
      r.CFrame = seguro + Vector3.new(0, 4, 0)
    end
  end))
end, { alias = { "novoid" } })

add("tp", "Teleporta pra coordenadas. Ex: tp 0 50 0", "Movimento", false, function(args)
  local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
  if not (x and y and z) then fail("use: tp 0 50 0") end
  eu().CFrame = CFrame.new(x, y, z)
end, { arg = "x y z", need = true })

local salvos = {}
add("savepos", "Salva sua posição. Ex: savepos casa", "Movimento", false, function(args)
  local nome = args[1] or "1"
  salvos[nome] = eu().CFrame
  toast("Posição '" .. nome .. "' salva", C.green)
end, { arg = "nome", alias = { "sp" } })

add("loadpos", "Volta pra posição salva. Ex: loadpos casa", "Movimento", false, function(args)
  local nome = args[1] or "1"
  if not salvos[nome] then fail("não tem posição salva com esse nome") end
  eu().CFrame = salvos[nome]
end, { arg = "nome", alias = { "lp" } })

-- ============================================================
-- JOGADORES
-- ============================================================
add("goto", "Vai até um jogador. Ex: goto nome", "Jogadores", false, function(args)
  local p = getTarget(args[1])
  local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
  if not pr then fail("esse jogador não tem personagem") end
  eu().CFrame = pr.CFrame * CFrame.new(0, 0, 3)
end, { arg = "jogador", need = true, alias = { "to", "tpto" } })

add("gotonearest", "Vai até o jogador mais próximo", "Jogadores", false, function()
  local r = eu()
  local melhor, dmin
  for _, p in ipairs(otherPlayers()) do
    local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if pr then
      local d = (pr.Position - r.Position).Magnitude
      if not dmin or d < dmin then melhor, dmin = pr, d end
    end
  end
  if not melhor then fail("ninguém por perto") end
  r.CFrame = melhor.CFrame * CFrame.new(0, 0, 3)
end, { alias = { "gtn" } })

add("view", "Vê pela câmera de outro jogador. Ex: view nome", "Jogadores", false, function(args)
  local p = getTarget(args[1])
  local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
  if not h then fail("esse jogador não tem personagem") end
  workspace.CurrentCamera.CameraSubject = h
  toast("Vendo " .. p.DisplayName, C.gold)
end, { arg = "jogador", need = true, alias = { "spectate", "spec" } })

add("unview", "Volta a câmera pra você", "Jogadores", false, function()
  workspace.CurrentCamera.CameraSubject = euH()
end, { alias = { "unspectate", "unspec" } })

add("follow", "Anda atrás de um jogador. Ex: follow nome", "Jogadores", true, function(on, args)
  local cmd = CmdByName.follow
  unbind(cmd)
  if not on then return end
  local p = getTarget(args[1])
  track(cmd, RunService.Heartbeat:Connect(function()
    local h = hum()
    local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if h and pr then h:MoveTo(pr.Position) end
  end))
end, { arg = "jogador", need = true, alias = { "seguir" } })

add("orbit", "Gira em volta de um jogador. Ex: orbit nome 8", "Jogadores", true, function(on, args)
  local cmd = CmdByName.orbit
  unbind(cmd)
  if not on then return end
  local p = getTarget(args[1])
  local raio = num(args, 2, 8)
  local ang = 0
  track(cmd, RunService.Heartbeat:Connect(function(dt)
    local r = root()
    local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if not (r and pr) then return end
    ang = ang + dt * 3
    r.CFrame = CFrame.new(pr.Position + Vector3.new(math.cos(ang) * raio, 0, math.sin(ang) * raio), pr.Position)
  end))
end, { arg = "jogador raio", need = true })

-- FLING (gira rápido e arremessa o outro jogador)
local flingCancel = false
local function flingOne(alvo)
  local r, h = root(), hum()
  local tc = alvo.Character
  local tr = tc and tc:FindFirstChild("HumanoidRootPart")
  local th = tc and tc:FindFirstChildOfClass("Humanoid")
  if not (r and h and tr and th) or th.Health <= 0 then return false end
  local origem = r.CFrame
  pcall(function() workspace.FallenPartsDestroyHeight = 0 / 0 end)
  local t0 = os.clock()
  local conn = RunService.Heartbeat:Connect(function()
    if not (r.Parent and tr.Parent) then return end
    local prev = r.AssemblyLinearVelocity
    local alvoPos = tr.Position + tr.AssemblyLinearVelocity * 0.12
    r.CFrame = CFrame.new(alvoPos) * CFrame.Angles(math.rad(math.random(0, 360)), 0, 0)
    r.AssemblyLinearVelocity = Vector3.new(1e7, 1e7, 1e7)
    r.AssemblyAngularVelocity = Vector3.new(1e7, 1e7, 1e7)
    RunService.RenderStepped:Wait()
    r.AssemblyLinearVelocity = prev
  end)
  while os.clock() - t0 < 3 and not flingCancel do
    if not (tr.Parent and r.Parent) then break end
    if tr.AssemblyLinearVelocity.Magnitude > 600 or th.Health <= 0 then break end
    task.wait()
  end
  conn:Disconnect()
  for _ = 1, 8 do
    if r.Parent then
      r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
      r.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
      r.CFrame = origem
    end
    task.wait()
  end
  pcall(function() workspace.FallenPartsDestroyHeight = -500 end)
  return true
end

local flinging = false
add("fling", "Arremessa um jogador girando. Ex: fling nome", "Jogadores", false, function(args)
  if flinging then fail("já tem um fling rodando (use unfling)") end
  local p = getTarget(args[1])
  if p == Player then fail("não dá pra fazer fling em você mesmo") end
  flinging, flingCancel = true, false
  toast("Fling em " .. p.DisplayName .. "...", C.gold)
  task.spawn(function()
    local ok, err = pcall(flingOne, p)
    flinging = false
    if not ok then toast("fling falhou: " .. tostring(err), C.red) end
  end)
end, { arg = "jogador", need = true })

add("flingall", "Arremessa todo mundo, um por vez", "Jogadores", false, function()
  if flinging then fail("já tem um fling rodando (use unfling)") end
  flinging, flingCancel = true, false
  toast("Fling em todos...", C.gold)
  task.spawn(function()
    for _, p in ipairs(otherPlayers()) do
      if flingCancel then break end
      pcall(flingOne, p)
    end
    flinging = false
    toast("Fling em todos terminou", C.gray)
  end)
end, { alias = { "flingothers" } })

add("unfling", "Para o fling", "Jogadores", false, function()
  flingCancel = true
  toast("Fling cancelado", C.gray)
end)

add("walkfling", "Arremessa quem encostar em você enquanto anda", "Jogadores", true, function(on)
  local cmd = CmdByName.walkfling
  unbind(cmd)
  if not on then return end
  track(cmd, RunService.Heartbeat:Connect(function()
    local r = root()
    if not r then return end
    local vel = r.AssemblyLinearVelocity
    r.AssemblyLinearVelocity = vel * 1e4 + Vector3.new(0, 1e4, 0)
    RunService.RenderStepped:Wait()
    r.AssemblyLinearVelocity = vel
  end))
end, { alias = { "wfling" } })

add("esp", "Mostra os jogadores através das paredes", "Jogadores", true, function(on)
  local cmd = CmdByName.esp
  unbind(cmd)
  for _, p in ipairs(Players:GetPlayers()) do
    local c = p.Character
    if c then
      for _, o in ipairs(c:GetChildren()) do if o.Name == "NOVEX_ESP" then o:Destroy() end end
    end
  end
  if not on then return end
  local acc = 0.5
  track(cmd, RunService.Heartbeat:Connect(function(dt)
    acc = acc + dt
    if acc < 0.5 then return end
    acc = 0
    for _, p in ipairs(Players:GetPlayers()) do
      local c = p.Character
      if p ~= Player and c and not c:FindFirstChild("NOVEX_ESP") then
        new("Highlight", {
          Name = "NOVEX_ESP", FillColor = C.gold, OutlineColor = C.white, FillTransparency = 0.65,
          DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        }, c)
        local head = c:FindFirstChild("Head")
        if head then
          local b = new("BillboardGui", {
            Name = "NOVEX_ESP", Size = UDim2.fromOffset(140, 20), StudsOffset = Vector3.new(0, 2.6, 0),
            AlwaysOnTop = true, Adornee = head,
          }, c)
          new("TextLabel", {
            Text = p.DisplayName, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.gold,
            TextStrokeTransparency = 0.3, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
          }, b)
        end
      end
    end
  end))
end, { alias = { "chams", "wallhack" } })

add("inspect", "Mostra info de um jogador. Ex: inspect nome", "Jogadores", false, function(args)
  local p = getTarget(args[1])
  local r = root()
  local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
  local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
  local dist = (r and pr) and math.floor((r.Position - pr.Position).Magnitude) or "?"
  toast(string.format("%s (@%s) | %s dias | %s studs | vida %s",
    p.DisplayName, p.Name, tostring(p.AccountAge), tostring(dist), h and tostring(math.floor(h.Health)) or "?"), C.white)
end, { arg = "jogador", need = true, alias = { "whois" } })

add("copyid", "Copia o UserId de um jogador. Ex: copyid nome", "Jogadores", false, function(args)
  doCopy(tostring(getTarget(args[1]).UserId), "UserId copiado!")
end, { arg = "jogador", need = true })

add("players", "Mostra quantos jogadores tem e copia a lista", "Jogadores", false, function()
  local nomes = {}
  for _, p in ipairs(Players:GetPlayers()) do nomes[#nomes + 1] = p.Name end
  toast(#nomes .. " jogadores no servidor", C.white)
  pcall(doCopy, table.concat(nomes, ", "), #nomes .. " jogadores (lista copiada)")
end, { alias = { "playerlist" } })

-- ============================================================
-- PERSONAGEM
-- ============================================================
add("reset", "Reinicia seu personagem", "Personagem", false, function()
  euH().Health = 0
end, { alias = { "respawn", "re" } })

add("heal", "Enche sua vida (funciona em alguns jogos)", "Personagem", false, function()
  local h = euH()
  h.Health = h.MaxHealth
end)

add("god", "Tenta ficar com vida infinita (alguns jogos)", "Personagem", true, function(on)
  local cmd = CmdByName.god
  unbind(cmd)
  if not on then
    local h = hum() if h then h.MaxHealth = 100 h.Health = 100 end
    return
  end
  track(cmd, RunService.Heartbeat:Connect(function()
    local h = hum()
    if h then h.MaxHealth = math.huge h.Health = math.huge end
  end))
end, { alias = { "godmode" } })

add("ghost", "Fica transparente só pra você", "Personagem", true, function(on)
  local cmd = CmdByName.ghost
  unbind(cmd)
  local function aplica(v)
    local c = Player.Character
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
      if p:IsA("BasePart") then p.LocalTransparencyModifier = v end
    end
  end
  if not on then aplica(0) return end
  track(cmd, RunService.RenderStepped:Connect(function() aplica(0.7) end))
end)

add("sit", "Senta", "Personagem", false, function() euH().Sit = true end)

add("freeze", "Trava você no lugar", "Personagem", true, function(on)
  eu().Anchored = on
end, { alias = { "anchor" } })

add("nohats", "Tira os acessórios do seu personagem", "Personagem", false, function()
  local c = Player.Character
  if not c then fail("sem personagem") end
  for _, a in ipairs(c:GetChildren()) do
    if a:IsA("Accessory") then a:Destroy() end
  end
end, { alias = { "removehats" } })

add("noanim", "Desliga as animações do seu personagem", "Personagem", true, function(on)
  local c = Player.Character
  local an = c and c:FindFirstChild("Animate")
  if not an then fail("não achei o script de animação") end
  an.Disabled = on
end)

-- ============================================================
-- VISUAL
-- ============================================================
add("fullbright", "Tudo bem iluminado", "Visual", true, function(on)
  if on then
    lset("Brightness", 2) lset("ClockTime", 14) lset("FogEnd", 1e6)
    lset("GlobalShadows", false)
    lset("Ambient", Color3.fromRGB(178, 178, 178)) lset("OutdoorAmbient", Color3.fromRGB(178, 178, 178))
  else
    for _, p in ipairs({ "Brightness", "ClockTime", "FogEnd", "GlobalShadows", "Ambient", "OutdoorAmbient" }) do lrestore(p) end
  end
end, { alias = { "fb", "light" } })

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
efeito("vivid", "Cores do jogo mais vivas", "ColorCorrectionEffect", { Saturation = 0.4, Contrast = 0.12, Brightness = 0.02 }, { "vivo" })
efeito("grayscale", "Jogo em preto e branco", "ColorCorrectionEffect", { Saturation = -1 }, { "bw" })
efeito("bloom", "Brilho suave nas luzes", "BloomEffect", { Intensity = 0.7, Size = 30, Threshold = 0.85 })
efeito("sunrays", "Raios de sol", "SunRaysEffect", { Intensity = 0.2, Spread = 0.8 })
efeito("blur", "Desfoca a tela", "BlurEffect", { Size = 14 })

add("day", "Deixa de dia", "Visual", false, function() Lighting.ClockTime = 14 end)
add("night", "Deixa de noite", "Visual", false, function() Lighting.ClockTime = 0 end)

add("fov", "Muda o campo de visão. Ex: fov 100", "Visual", false, function(args)
  workspace.CurrentCamera.FieldOfView = math.clamp(must(args, "fov 100"), 1, 120)
end, { arg = "n", need = true })

add("zoom", "Deixa afastar mais a câmera. Ex: zoom 200", "Visual", false, function(args)
  Player.CameraMaxZoomDistance = must(args, "zoom 200")
  Player.CameraMinZoomDistance = 0.5
end, { arg = "n", need = true, alias = { "maxzoom" } })

add("nofog", "Tira a neblina", "Visual", true, function(on)
  if on then lset("FogEnd", 1e6) else lrestore("FogEnd") end
end)

add("noshadows", "Tira as sombras", "Visual", true, function(on)
  if on then lset("GlobalShadows", false) else lrestore("GlobalShadows") end
end)

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

local xrayOrig = {}
add("xray", "Deixa as paredes transparentes", "Visual", true, function(on)
  if on then
    for _, p in ipairs(workspace:GetDescendants()) do
      if p:IsA("BasePart") and not p:IsDescendantOf(Player.Character or workspace) then
        local ehJogador = false
        for _, pl in ipairs(Players:GetPlayers()) do
          if pl.Character and p:IsDescendantOf(pl.Character) then ehJogador = true break end
        end
        if not ehJogador and p.Transparency < 0.6 then
          xrayOrig[p] = p.Transparency
          p.Transparency = 0.6
        end
      end
    end
  else
    for p, t in pairs(xrayOrig) do pcall(function() p.Transparency = t end) end
    xrayOrig = {}
  end
end, { alias = { "xr" } })

add("fpsboost", "Deixa o jogo mais leve (menos gráficos)", "Visual", false, function()
  pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
  Lighting.GlobalShadows = false
  for _, d in ipairs(workspace:GetDescendants()) do
    if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
      d.Enabled = false
    end
  end
  toast("Gráficos reduzidos", C.green)
end, { alias = { "lowgfx", "boost" } })

-- ============================================================
-- MUNDO
-- ============================================================
local gravPadrao = workspace.Gravity
add("gravity", "Gravidade do mapa. Ex: gravity 50", "Mundo", false, function(args)
  workspace.Gravity = math.clamp(must(args, "gravity 50"), 0, 1000)
end, { arg = "n", need = true, alias = { "grav" } })

add("resetgravity", "Gravidade normal de volta", "Mundo", false, function()
  workspace.Gravity = gravPadrao
end, { alias = { "rgrav" } })

add("lowgravity", "Gravidade baixa (pule alto e flutue)", "Mundo", true, function(on)
  workspace.Gravity = on and gravPadrao * 0.25 or gravPadrao
end, { alias = { "moon" } })

add("time", "Define a hora do dia (0 a 24). Ex: time 18", "Mundo", false, function(args)
  Lighting.ClockTime = must(args, "time 18") % 24
end, { arg = "hora", need = true })

add("timeloop", "O dia passa rápido. Ex: timeloop 1", "Mundo", true, function(on, args)
  local cmd = CmdByName.timeloop
  unbind(cmd)
  if not on then return end
  local v = num(args, 1, 1)
  track(cmd, RunService.Heartbeat:Connect(function(dt)
    Lighting.ClockTime = (Lighting.ClockTime + dt * v) % 24
  end))
end, { arg = "velocidade" })

add("rainbow", "Ambiente do mapa com cores que mudam", "Mundo", true, function(on)
  local cmd = CmdByName.rainbow
  unbind(cmd)
  if not on then lrestore("Ambient") lrestore("OutdoorAmbient") return end
  local h = 0
  track(cmd, RunService.Heartbeat:Connect(function(dt)
    h = (h + dt * 0.1) % 1
    local cor = Color3.fromHSV(h, 0.6, 1)
    lset("Ambient", cor)
    lset("OutdoorAmbient", cor)
  end))
end, { alias = { "disco" } })

add("fog", "Define a neblina. Ex: fog 200", "Mundo", false, function(args)
  lset("FogEnd", math.max(1, must(args, "fog 200")))
end, { arg = "n", need = true })

add("fogcolor", "Cor da neblina. Ex: fogcolor 255 100 200", "Mundo", false, function(args)
  local r, g, b = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
  if not (r and g and b) then fail("use: fogcolor 255 100 200") end
  lset("FogColor", Color3.fromRGB(r, g, b))
end, { arg = "r g b", need = true })

add("partcount", "Conta quantas peças tem no mapa", "Mundo", false, function()
  local n = 0
  for _, d in ipairs(workspace:GetDescendants()) do
    if d:IsA("BasePart") then n = n + 1 end
  end
  toast("Peças no mapa: " .. n, C.white)
end)

-- ============================================================
-- UTILIDADES
-- ============================================================
add("rejoin", "Entra de novo no mesmo servidor", "Utilidades", false, function()
  if #Players:GetPlayers() <= 1 then
    TeleportService:Teleport(game.PlaceId, Player)
  else
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
  end
end, { alias = { "rj" } })

add("serverhop", "Vai pra outro servidor do mesmo jogo", "Utilidades", false, function()
  local ok, corpo = pcall(function()
    return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
  end)
  if not ok then fail("não consegui a lista de servidores") end
  local ok2, dados = pcall(function() return HttpService:JSONDecode(corpo) end)
  if not ok2 or not dados or not dados.data then fail("lista de servidores inválida") end
  for _, s in ipairs(dados.data) do
    if s.id ~= game.JobId and s.playing and s.maxPlayers and s.playing < s.maxPlayers then
      toast("Indo pra outro servidor...", C.gold)
      TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player)
      return
    end
  end
  fail("não achei servidor com vaga")
end, { alias = { "hop", "shop" } })

add("ping", "Mostra seu ping", "Utilidades", false, function()
  local ms = "?"
  pcall(function() ms = math.floor(Player:GetNetworkPing() * 2000) end)
  toast("Ping: " .. tostring(ms) .. " ms", C.white)
end)

add("antiafk", "Não deixa o jogo te expulsar por ficar parado", "Utilidades", true, function(on)
  local cmd = CmdByName.antiafk
  unbind(cmd)
  if not on then return end
  track(cmd, Player.Idled:Connect(function()
    pcall(function()
      VirtualUser:CaptureController()
      VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
  end))
end, { alias = { "afk" } })

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

add("fpscap", "Limita ou libera o FPS. Ex: fpscap 60", "Utilidades", false, function(args)
  if not setfpscap then fail("seu executor não tem fpscap") end
  setfpscap(must(args, "fpscap 60"))
end, { arg = "n", need = true })

local inicio = os.clock()
add("uptime", "Há quanto tempo o NOVEX está aberto", "Utilidades", false, function()
  local s = math.floor(os.clock() - inicio)
  toast(string.format("Aberto há %dmin %ds", math.floor(s / 60), s % 60), C.white)
end)

add("serverage", "Há quanto tempo o servidor está aberto", "Utilidades", false, function()
  local s = math.floor(workspace.DistributedGameTime)
  toast(string.format("Servidor aberto há %dh %dmin", math.floor(s / 3600), math.floor((s % 3600) / 60)), C.white)
end, { alias = { "serveruptime" } })

add("copypos", "Copia suas coordenadas", "Utilidades", false, function()
  local p = eu().Position
  doCopy(string.format("%d, %d, %d", p.X, p.Y, p.Z), "Posição copiada!")
end)

add("copyplaceid", "Copia o Place ID do jogo", "Utilidades", false, function()
  doCopy(tostring(game.PlaceId), "Place ID copiado!")
end)

add("dado", "Rola um dado. Ex: dado 20", "Utilidades", false, function(args)
  local n = math.max(2, math.floor(num(args, 1, 6)))
  toast("Deu " .. math.random(1, n) .. " (d" .. n .. ")", C.gold)
end, { arg = "lados" })

add("moeda", "Cara ou coroa", "Utilidades", false, function()
  toast(math.random(2) == 1 and "Cara" or "Coroa", C.gold)
end)

add("timer", "Avisa depois de alguns segundos. Ex: timer 30", "Utilidades", false, function(args)
  local s = must(args, "timer 30")
  toast("Timer de " .. s .. "s iniciado.", C.gray)
  task.delay(s, function() toast("Acabou o tempo (" .. s .. "s)!", C.gold) end)
end, { arg = "segundos", need = true })

add("calc", "Faz uma conta. Ex: calc 2*(3+4)", "Utilidades", false, function(args)
  local expr = table.concat(args, " ")
  if not expr:match("^[%d%s%+%-%*/%%%^%(%)%.]+$") then fail("só números e + - * / ^ ( )") end
  local f = loadstring("return " .. expr)
  if not f then fail("conta inválida") end
  local ok, r = pcall(f)
  if not ok then fail("conta inválida") end
  toast(expr .. " = " .. tostring(r), C.green)
end, { arg = "conta", need = true })

-- ============================================================
-- FERRAMENTAS
-- ============================================================
add("lua", "Executa um código Lua. Ex: lua print('oi')", "Ferramentas", false, function(args)
  local fonte = table.concat(args, " ")
  if fonte == "" then fail("use: lua print('oi')") end
  local f, e = loadstring(fonte)
  if not f then fail(tostring(e)) end
  f()
end, { arg = "código", need = true })

add("loadurl", "Roda um script de um link. Ex: loadurl https://...", "Ferramentas", false, function(args)
  local url = args[1]
  if not url then fail("use: loadurl https://...") end
  local ok, src = pcall(function() return game:HttpGet(url) end)
  if not ok then fail("não consegui baixar") end
  local f = loadstring(src)
  if not f then fail("script inválido") end
  f()
end, { arg = "link", need = true })

add("copy", "Copia um texto. Ex: copy olá", "Ferramentas", false, function(args)
  doCopy(table.concat(args, " "), "Texto copiado!")
end, { arg = "texto", need = true })

add("guiscale", "Muda o tamanho do menu. Ex: guiscale 0.8", "Ferramentas", false, function(args)
  MainScale.Scale = math.clamp(must(args, "guiscale 0.8"), 0.5, 1.5)
end, { arg = "n", need = true, alias = { "scale" } })

add("cmds", "Mostra quantos comandos existem", "Ferramentas", false, function()
  toast(#Cmds .. " comandos disponíveis", C.gold)
end, { alias = { "help", "ajuda" } })

add("unload", "Fecha o NOVEX e desliga tudo", "Ferramentas", false, function()
  if G.NOVEX_UNLOAD then G.NOVEX_UNLOAD() end
end, { alias = { "fechar", "exit" } })

-- ============================================================
-- LISTA, ABAS E BARRA
-- ============================================================
table.sort(Cmds, function(a, b) return a.name < b.name end)
for i, cmd in ipairs(Cmds) do
  cmd.row.LayoutOrder = i
  cmd.row.Activated:Connect(function()
    if cmd.need then
      box.Text = cmd.name .. " "
      box:CaptureFocus()
    else
      execute(cmd, {})
    end
  end)
end

local chips = {}
function applyFilter()
  local q = (box.Text or ""):lower():match("^%s*(%S*)") or ""
  for _, cmd in ipairs(Cmds) do
    local show
    if q ~= "" then
      show = cmd.name:find(q, 1, true) ~= nil
      if not show then
        for _, a in ipairs(cmd.alias) do
          if a:find(q, 1, true) then show = true break end
        end
      end
    else
      show = (curTab == "Todos") or cmd.cat == curTab
    end
    cmd.row.Visible = show
  end
  List.CanvasPosition = Vector2.new(0, 0)
end

local function selectTab(nome)
  curTab = nome
  for n, chip in pairs(chips) do
    local ativo = (n == nome)
    chip.BackgroundColor3 = ativo and C.gold or C.card
    chip.TextColor3 = ativo and C.dark or C.gray
  end
  applyFilter()
end

for i, nome in ipairs({ "Todos", "Movimento", "Jogadores", "Personagem", "Visual", "Mundo", "Utilidades", "Ferramentas" }) do
  local chip = new("TextButton", {
    Text = nome, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.gray,
    BackgroundColor3 = C.card, AutoButtonColor = false, LayoutOrder = i,
    Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X,
  }, Tabs)
  new("UICorner", { CornerRadius = UDim.new(1, 0) }, chip)
  new("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, chip)
  chip.Activated:Connect(function() box.Text = "" selectTab(nome) end)
  chips[nome] = chip
end

box:GetPropertyChangedSignal("Text"):Connect(applyFilter)
box.FocusLost:Connect(function(enter)
  if enter and box.Text ~= "" then
    runText(box.Text)
    box.Text = ""
  end
end)
runBtn.Activated:Connect(function()
  if box.Text ~= "" then
    runText(box.Text)
    box.Text = ""
  end
end)

selectTab("Todos")
Main.Visible = true

-- Desligar tudo
G.NOVEX_UNLOAD = function()
  for _, cmd in ipairs(Cmds) do
    if cmd.toggle and cmd.on then pcall(cmd.fn, false, {}) end
    unbind(cmd)
  end
  speedVal, jumpVal, hipVal = nil, nil, nil
  for _, c in ipairs(allConns) do pcall(function() c:Disconnect() end) end
  pcall(function() gui:Destroy() end)
  G.NOVEX_UNLOAD = nil
end

toast("NOVEX carregado: " .. #Cmds .. " comandos", C.gold)
