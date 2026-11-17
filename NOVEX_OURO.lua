local URL = "https://raw.githubusercontent.com/mrcoswzz/Novex-Lua/main/NOVEX_OpenRouter_CONFIGURADO.lua"
local ok, codigo = pcall(function() return game:HttpGet(URL) end)
if not ok or type(codigo) ~= "string" or #codigo < 1000 then
  warn("NOVEX: não consegui baixar o arquivo: " .. tostring(codigo))
  return
end

local function patch(padrao, novo)
  local r, n = codigo:gsub(padrao, type(novo) == "function" and novo or function() return novo end)
  if n == 0 then warn("NOVEX: não achei -> " .. padrao) end
  codigo = r
  return n
end

-- CORES (nome, cor atual, cor nova) - pode mudar os números da 3ª coluna
local TEMA = {
  { "panel",  "12, 14, 25",    "14, 9, 30" },
  { "card",   "22, 25, 43",    "30, 19, 60" },
  { "card2",  "38, 43, 70",    "58, 36, 104" },
  { "gray",   "138, 146, 168", "170, 160, 205" },
  { "blue",   "0, 200, 255",   "0, 229, 255" },
  { "blue2",  "112, 72, 255",  "146, 66, 255" },
  { "purple", "205, 75, 255",  "255, 58, 212" },
  { "green",  "0, 245, 160",   "0, 255, 140" },
  { "red",    "255, 65, 105",  "255, 48, 92" },
  { "orange", "255, 175, 65",  "255, 196, 40" },
}
for _, t in ipairs(TEMA) do
  local num = (t[2]:gsub(", ", ",%%s*"))
  patch(t[1] .. "%s*=%s*Color3%.fromRGB%(" .. num .. "%)",
        t[1] .. " = Color3.fromRGB(" .. t[3] .. ")")
end

-- DOURADO nos títulos, no FPS e na setinha
local ouro = patch("black%s*=%s*Color3%.fromRGB%(8,%s*9,%s*13%),",
  "black = Color3.fromRGB(8, 9, 13), gold = Color3.fromRGB(255, 205, 64), gold2 = Color3.fromRGB(255, 142, 38),") > 0
if ouro then
  patch('line%(Root, "Home", 93, 22, 400, 34, C%.white, BLACK, 24%)', 'line(Root, "Home", 93, 22, 400, 34, C.gold, BLACK, 24)')
  patch('line%(fc, "%-%-", 16, 26, 80, 36, C%.white, BLACK, 30%)', 'line(fc, "--", 16, 26, 80, 36, C.gold, BLACK, 30)')
  patch('label%(Pill, "▲", 14, 0, 26, 36, C%.red, BLACK, 18, CENTER%)', 'label(Pill, "▲", 14, 0, 26, 36, C.gold, BLACK, 18, CENTER)')
end

-- COMANDOS NOVOS (compilados à parte: se der erro, só eles falham)
local CMDS_EXTRA = [==[
local H = ...
local fail, hum, root, must, track, unbind = H.fail, H.hum, H.root, H.must, H.track, H.unbind
local toast, C, Player, Players = H.toast, H.C, H.Player, H.Players
local CmdByName, Alias, lset, lreset, getTarget, X = H.CmdByName, H.Alias or {}, H.lset, H.lreset, H.getTarget, H.X
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local function add(name, desc, cat, isToggle, fn, opt)
  if CmdByName[name] then return end
  opt = opt or {}
  local livres = {}
  for _, a in ipairs(opt.alias or {}) do
    if not CmdByName[a] and not Alias[a] then table.insert(livres, a) end
  end
  opt.alias = livres
  return H.addCmd(name, desc, cat, isToggle, fn, opt)
end
local function num(args, i, padrao) return tonumber(args and args[i or 1]) or padrao end
local function eu()
  local r = root()
  if not r then fail("sem personagem") end
  return r
end

-- MOVIMENTO
add("bhop", "Pula sozinho enquanto você anda", "Movimento", true, function(on)
  local cmd = CmdByName.bhop
  unbind(cmd)
  if not on then return end
  track(cmd, RunService.Heartbeat:Connect(function()
    local h = hum()
    if h and h.MoveDirection.Magnitude > 0 and h.FloorMaterial ~= Enum.Material.Air then h.Jump = true end
  end))
end, { alias = { "bunnyhop" } })

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
add("gravity", "Gravidade do mapa. Ex: gravity 50", "Mundo", false, function(args)
  workspace.Gravity = math.clamp(must(args, "gravity 50"), 0, 1000)
end, { arg = "n", need = true, alias = { "grav" } })
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

add("partcount", "Conta quantas peças tem no mapa", "Mundo", false, function()
  local n = 0
  for _, d in ipairs(workspace:GetDescendants()) do
    if d:IsA("BasePart") then n = n + 1 end
  end
  toast("Peças no mapa: " .. n, C.white)
end)

-- JOGADORES
add("inspect", "Mostra info de um jogador. Ex: inspect nome", "Jogadores", false, function(args)
  local p = getTarget(args and args[1])
  local r = root()
  local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
  local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
  local dist = (r and pr) and math.floor((r.Position - pr.Position).Magnitude) or "?"
  toast(string.format("%s (@%s) | %s dias | %s studs | vida %s",
    p.DisplayName, p.Name, tostring(p.AccountAge), tostring(dist), h and tostring(math.floor(h.Health)) or "?"), C.white)
end, { arg = "jogador", need = true, alias = { "whois" } })

add("copyid", "Copia o UserId de um jogador. Ex: copyid nome", "Jogadores", false, function(args)
  local p = getTarget(args and args[1])
  X.doCopy(tostring(p.UserId), "UserId copiado!")
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

add("copypos", "Copia suas coordenadas", "Utilidades", false, function()
  local p = eu().Position
  X.doCopy(string.format("%d, %d, %d", p.X, p.Y, p.Z), "Posição copiada!")
end)

add("copyplaceid", "Copia o Place ID do jogo", "Utilidades", false, function()
  X.doCopy(tostring(game.PlaceId), "Place ID copiado!")
end)

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

add("dado", "Rola um dado. Ex: dado 20", "Utilidades", false, function(args)
  local n = math.max(2, math.floor(num(args, 1, 6)))
  toast("Deu " .. math.random(1, n) .. " (d" .. n .. ")", C.orange)
end, { arg = "lados" })

add("moeda", "Cara ou coroa", "Utilidades", false, function()
  toast(math.random(2) == 1 and "Cara" or "Coroa", C.orange)
end)

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
]==]

local G = (getgenv and getgenv()) or _G
G.NOVEX_CMDS_EXTRA = CMDS_EXTRA

local INJECAO = [==[
do
  local __ok, __e = pcall(function()
    local __g = (getgenv and getgenv()) or _G
    local __f, __err = loadstring(__g.NOVEX_CMDS_EXTRA or "")
    if not __f then error(__err, 0) end
    __f({ addCmd = addCmd, fail = fail, hum = hum, root = root, must = must, track = track, unbind = unbind,
      toast = toast, C = C, Player = Player, Players = Players, CmdByName = CmdByName, Alias = Alias,
      lset = lset, lreset = lreset, getTarget = getTarget, X = X })
  end)
  if not __ok then warn("NOVEX comandos extras: " .. tostring(__e)) end
end
]==]
patch('addCmd%("guiscale",', INJECAO .. 'addCmd("guiscale",')

-- BORDAS COLORIDAS (barra de info e botão ✦ mudam de cor)
task.spawn(function()
  local function achaGui()
    local lugares = {}
    pcall(function() if gethui then table.insert(lugares, gethui()) end end)
    pcall(function() table.insert(lugares, game:GetService("CoreGui")) end)
    pcall(function() table.insert(lugares, game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 5)) end)
    for _, l in ipairs(lugares) do
      local g = l and l:FindFirstChild("NOVEX")
      if g then return g end
    end
  end
  local gui
  for _ = 1, 40 do
    gui = achaGui()
    if gui then break end
    task.wait(0.25)
  end
  if not gui then return end
  local h, alvos, ultimo = 0, {}, 0
  while gui.Parent do
    if os.clock() - ultimo > 3 then
      ultimo = os.clock()
      alvos = {}
      for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("UIStroke") and math.abs(d.Thickness - 1.2) < 0.01 then table.insert(alvos, d) end
      end
    end
    h = (h + 0.004) % 1
    for i, s in ipairs(alvos) do
      pcall(function() s.Color = Color3.fromHSV((h + i * 0.18) % 1, 0.75, 1) end)
    end
    task.wait(0.04)
  end
end)

local f, erro = loadstring(codigo)
if f then f() else warn("NOVEX erro: " .. tostring(erro)) end
