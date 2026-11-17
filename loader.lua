local url = "https://raw.githubusercontent.com/mrcoswzz/Novex-Lua/main/NOVEX_5.0_completo%20(1).lua"
local codigo = game:HttpGet(url)

local function patch(padrao, novo)
  local r, n = codigo:gsub(padrao, type(novo) == "function" and novo or function() return novo end)
  if n == 0 then warn("NOVEX: não achei -> " .. padrao) end
  codigo = r
end

-- consertos antigos
codigo = codigo:gsub("\n([ \t]*)(==+)", "\n%1--%2")
codigo = codigo:gsub("([%s,{])Câmera%s*=", '%1["Câmera"] =')

-- CORES VIVAS (nome, cor antiga, cor nova) - pode mudar os números novos
local TEMA = {
  { "blue",   "88, 142, 255",  "0, 200, 255" },
  { "blue2",  "54, 102, 225",  "139, 61, 255" },
  { "purple", "162, 112, 255", "255, 60, 200" },
  { "green",  "52, 211, 153",  "0, 255, 140" },
  { "red",    "244, 63, 94",   "255, 45, 85" },
  { "orange", "251, 146, 60",  "255, 160, 0" },
  { "panel",  "13, 15, 22",    "14, 9, 30" },
  { "card",   "22, 25, 36",    "28, 18, 54" },
  { "card2",  "34, 39, 54",    "52, 34, 96" },
}
for _, t in ipairs(TEMA) do
  local num = (t[2]:gsub(", ", ",%%s*"))
  patch(t[1] .. "%s*=%s*Color3%.fromRGB%(" .. num .. "%)", t[1] .. " = Color3.fromRGB(" .. t[3] .. ")")
end
-- brilho mais forte no topo dos painéis
patch("(BackgroundColor3 = C%.blue,%s*BackgroundTransparency = )0%.92", function(a) return a .. "0.78" end)

-- BOTÃO NOVEX MÓVEL + BARRA DE INFO DO JOGO
local EXTRA = [==[
do
  local arrastando, moveu, inicio, posInicial = false, false, nil, nil
  local function eToque(i)
    return i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1
  end
  Pill.InputBegan:Connect(function(i)
    if eToque(i) then
      arrastando, moveu = true, false
      inicio, posInicial = i.Position, Pill.Position
    end
  end)
  UIS.InputChanged:Connect(function(i)
    if arrastando and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
      local d = i.Position - inicio
      if d.Magnitude > 8 then moveu = true end
      if moveu then
        Pill.Position = UDim2.new(posInicial.X.Scale, posInicial.X.Offset + d.X, posInicial.Y.Scale, posInicial.Y.Offset + d.Y)
      end
    end
  end)
  UIS.InputEnded:Connect(function(i)
    if eToque(i) then arrastando = false end
  end)
  Pill.MouseButton1Click:Connect(function()
    if not moveu then Shell.Visible = not Shell.Visible end
  end)

  -- borda do botão mudando de cor
  task.spawn(function()
    local st = Pill:FindFirstChildOfClass("UIStroke")
    local h = 0
    while GUI.Parent do
      h = (h + 0.006) % 1
      if st then st.Color = Color3.fromHSV(h, 0.85, 1) st.Transparency = 0.1 end
      task.wait(0.03)
    end
  end)

  -- barra de informações (anda junto com o botão)
  local Info = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, 6),
    Size = UDim2.fromOffset(270, 40), BackgroundColor3 = C.black,
    BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 50,
  }, Pill)
  corner(Info, 12)
  stroke(Info, C.blue, 0.4)
  local nomeLbl = line(Info, "🎮 " .. game.Name, 0, 3, 270, 16, C.white, BOLD, 11, CENTER)
  local statLbl = line(Info, "", 0, 20, 270, 16, C.white, BOLD, 11, CENTER)
  statLbl.RichText = true

  task.spawn(function()
    local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
    if ok and info and info.Name then nomeLbl.Text = "🎮 " .. info.Name end
  end)

  local frames, ultimo = 0, os.clock()
  local rs = RunService.RenderStepped:Connect(function() frames = frames + 1 end)
  GUI.Destroying:Connect(function() rs:Disconnect() end)
  task.spawn(function()
    while GUI.Parent do
      task.wait(1)
      local agora = os.clock()
      local fps = math.floor(frames / (agora - ultimo) + 0.5)
      frames, ultimo = 0, agora
      local ping = 0
      pcall(function() ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
      statLbl.Text = string.format(
        '<font color="#00FF9C">%d FPS</font>  <font color="#FFD400">%d ms</font>  <font color="#FF5FD2">👥 %d/%d</font>  <font color="#00D4FF">%s</font>',
        fps, ping, #Players:GetPlayers(), Players.MaxPlayers, os.date("%H:%M"))
    end
  end)
end
]==]
patch("Pill%.MouseButton1Click:Connect%(function%(%) Shell%.Visible = not Shell%.Visible end%)", EXTRA)

local f, erro = loadstring(codigo)
if f then f() else warn("NOVEX erro: " .. tostring(erro)) end
