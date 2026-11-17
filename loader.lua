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

-- CORES VIVAS (nome, cor antiga, cor nova)
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
patch("(BackgroundColor3 = C%.blue,%s*BackgroundTransparency = )0%.92", function(a) return a .. "0.78" end)

-- BOTÃO NOVEX MENOR/MÓVEL + BARRA DE INFO + ASSISTENTE
local EXTRA = [==[
do
  local function eToque(i)
    return i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1
  end

  local function arrastavel(alvo, alca, aoClicar)
    local arr, mov, ini, pos = false, false, nil, nil
    alca.InputBegan:Connect(function(i)
      if eToque(i) then
        arr, mov = true, false
        ini, pos = i.Position, alvo.Position
      end
    end)
    UIS.InputChanged:Connect(function(i)
      if arr and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = i.Position - ini
        if d.Magnitude > 8 then mov = true end
        if mov then
          alvo.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
        end
      end
    end)
    UIS.InputEnded:Connect(function(i)
      if eToque(i) then arr = false end
    end)
    if aoClicar then
      alca.MouseButton1Click:Connect(function()
        if not mov then aoClicar() end
      end)
    end
  end

  -- pastilha NOVEX menor
  pcall(function()
    for _, f in ipairs(Pill:GetChildren()) do
      if f:IsA("TextLabel") then
        if f.Text == "▲" then
          f.Position = UDim2.fromOffset(8, 0) f.Size = UDim2.fromOffset(22, 28) f.TextSize = 14
        elseif f.Text == "NOVEX" then
          f.Position = UDim2.fromOffset(32, 0) f.Size = UDim2.fromOffset(76, 28) f.TextSize = 14
        end
      end
    end
    Pill.Size = UDim2.fromOffset(112, 28)
    Pill.Position = UDim2.new(0.5, 0, 0, 6)
    Pill.BackgroundTransparency = 0.2
    local cn = Pill:FindFirstChildOfClass("UICorner")
    if cn then cn.CornerRadius = UDim.new(0, 14) end
  end)

  arrastavel(Pill, Pill, function() Shell.Visible = not Shell.Visible end)

  local ok, e = pcall(function()
    local fpsAtual, pingAtual, nomeJogo = 60, 0, game.Name
    local infoLigada = true

    -- borda da pastilha mudando de cor
    task.spawn(function()
      local st = Pill:FindFirstChildOfClass("UIStroke")
      local h = 0
      while GUI.Parent do
        h = (h + 0.006) % 1
        if st then st.Color = Color3.fromHSV(h, 0.85, 1) st.Transparency = 0.1 end
        task.wait(0.03)
      end
    end)

    -- barra de informações (anda junto com a pastilha)
    local Info = create("Frame", {
      AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, 4),
      Size = UDim2.fromOffset(250, 36), BackgroundColor3 = C.black,
      BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 50, Visible = false,
    }, Pill)
    corner(Info, 12)
    stroke(Info, C.blue, 0.4)
    local nomeLbl = line(Info, "🎮 " .. nomeJogo, 0, 2, 250, 16, C.white, BOLD, 11, CENTER)
    local statLbl = line(Info, "", 0, 18, 250, 16, C.white, BOLD, 11, CENTER)
    statLbl.RichText = true

    task.spawn(function()
      local okInfo, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
      if okInfo and info and info.Name then
        nomeJogo = info.Name
        nomeLbl.Text = "🎮 " .. nomeJogo
      end
    end)

    local frames, ultimo = 0, os.clock()
    local rs = RunService.RenderStepped:Connect(function() frames = frames + 1 end)
    GUI.Destroying:Connect(function() rs:Disconnect() end)
    task.spawn(function()
      while GUI.Parent do
        task.wait(1)
        local agora = os.clock()
        fpsAtual = math.floor(frames / (agora - ultimo) + 0.5)
        frames, ultimo = 0, agora
        pcall(function()
          pingAtual = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        statLbl.Text = string.format(
          '<font color="#00FF9C">%d FPS</font>  <font color="#FFD400">%d ms</font>  <font color="#FF5FD2">👥 %d/%d</font>  <font color="#00D4FF">%s</font>',
          fpsAtual, pingAtual, #Players:GetPlayers(), Players.MaxPlayers, os.date("%H:%M"))
      end
    end)

    -------------------------------------------------------------
    -- JANELA DO ASSISTENTE
    -------------------------------------------------------------
    local Janela = panel(GUI, 0, 0, 290, 250, 16)
    Janela.Position = UDim2.new(1, -300, 0.5, -125)
    Janela.ZIndex = 60
    Janela.Visible = false

    local barra = create("Frame", { Size = UDim2.fromOffset(290, 32), BackgroundTransparency = 1, Active = true }, Janela)
    line(barra, "🤖 Assistente NOVEX", 14, 0, 200, 32, C.white, BOLD, 13)
    local fechar = button(Janela, "✕", 256, 4, 28, 24, C.card2, 12)
    arrastavel(Janela, barra)

    local mensagens = scroller(Janela, 8, 34, 274, 168)
    vlist(mensagens, 6)

    local caixa = create("TextBox", {
      Position = UDim2.fromOffset(8, 208), Size = UDim2.fromOffset(212, 34),
      BackgroundColor3 = C.card2, TextColor3 = C.white, PlaceholderText = "Ex: como uso o fly",
      PlaceholderColor3 = C.gray, Text = "", Font = GOTHAM, TextSize = 12,
      ClearTextOnFocus = false, TextXAlignment = LEFT, BorderSizePixel = 0,
    }, Janela)
    corner(caixa, 17)
    create("UIPadding", { PaddingLeft = UDim.new(0, 12) }, caixa)
    local enviarBtn = button(Janela, "Enviar", 226, 208, 58, 34, C.blue2, 11)

    local ordem = 0
    local function msg(texto, eu)
      ordem = ordem + 1
      local b = create("TextLabel", {
        Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = eu and C.blue2 or C.card2, BackgroundTransparency = eu and 0.35 or 0.1,
        BorderSizePixel = 0, Text = (eu and "" or "🤖 ") .. texto, TextColor3 = C.white,
        TextSize = 12, Font = GOTHAM, TextWrapped = true, TextXAlignment = LEFT,
        RichText = not eu, LayoutOrder = ordem,
      }, mensagens)
      corner(b, 10)
      create("UIPadding", {
        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
      }, b)
      task.delay(0.05, function() mensagens.CanvasPosition = Vector2.new(0, 99999) end)
    end

    -------------------------------------------------------------
    -- CÉREBRO (regras simples)
    -------------------------------------------------------------
    local function norm(s)
      s = s:lower()
      local m = { ["á"]="a", ["à"]="a", ["â"]="a", ["ã"]="a", ["é"]="e", ["ê"]="e", ["í"]="i", ["ó"]="o", ["ô"]="o", ["õ"]="o", ["ú"]="u", ["ç"]="c" }
      for k, v in pairs(m) do s = s:gsub(k, v) end
      return s
    end

    local SIN = { voar="fly", voo="fly", atravessar="noclip", parede="noclip", paredes="noclip", clip="noclip",
      pular="infjump", pulo="infjump", wallhack="esp", flutuar="float", resetar="reset", reiniciar="reset",
      esconder="hide", velocidade="speed", correr="speed" }
    local PARADA = { como=1, uso=1, usar=1, usa=1, faz=1, fazer=1, faco=1, que=1, qual=1, quais=1, para=1, pra=1,
      ativa=1, ativar=1, liga=1, ligar=1, desliga=1, desligar=1, desativa=1, desativar=1, comando=1, comandos=1,
      jogo=1, mapa=1, voce=1, meu=1, minha=1, tem=1, pode=1, executa=1, executar=1, roda=1, rodar=1, ajuda=1,
      explica=1, explicar=1, sobre=1, lista=1, me=1, de=1, do=1, da=1, um=1, uma=1, o=1, a=1, no=1, na=1, funciona=1, serve=1 }
    local LIGA = { ativa=1, ativar=1, liga=1, ligar=1, executa=1, executar=1, roda=1, rodar=1, on=1 }
    local DESLIGA = { desativa=1, desativar=1, desliga=1, desligar=1, off=1, apaga=1 }

    local function achaCmd(t)
      local cmds = X.CmdByName
      if type(cmds) ~= "table" then return nil end
      local palavras = {}
      for w in t:gmatch("[%w_]+") do
        if not PARADA[w] then table.insert(palavras, w) end
      end
      for _, w in ipairs(palavras) do
        local alvo = SIN[w] or w
        if cmds[alvo] then return cmds[alvo] end
      end
      for _, w in ipairs(palavras) do
        if #w >= 4 then
          for nome, c in pairs(cmds) do
            if nome:sub(1, #w) == w then return c end
          end
        end
      end
      return nil
    end

    local function explica(c)
      local s = "<b>" .. c.name .. "</b>: " .. tostring(c.desc or "sem descrição")
      if c.need then
        s = s .. "\nPrecisa de um valor (" .. tostring(c.arg or "número") .. "). Digite na aba <b>Cmds</b>: <b>" .. c.name .. " valor</b>."
      elseif c.toggle then
        s = s .. "\nÉ de liga/desliga. Diga <b>liga " .. c.name .. "</b> aqui, ou use a chave na aba <b>Cmds</b>."
        s = s .. (c.state and "\nAgora está: ligado." or "\nAgora está: desligado.")
      else
        s = s .. "\nDiga <b>roda " .. c.name .. "</b> aqui, ou toque no ▶ na aba <b>Cmds</b>."
      end
      return s
    end

    local function sincroniza() end -- redefinida mais abaixo

    local function responde(texto)
      local t = norm(texto)
      local set = {}
      for w in t:gmatch("[%w_]+") do set[w] = true end
      local function tem(...)
        for _, w in ipairs({ ... }) do if set[w] then return true end end
        return false
      end

      -- lista de comandos
      if tem("comandos", "comando", "lista", "cmds", "cmd") then
        local cmds = X.CmdByName
        if type(cmds) ~= "table" then return "Os comandos ainda estão carregando, tenta de novo." end
        local grupos, total = {}, 0
        for nome, c in pairs(cmds) do
          total = total + 1
          local cat = norm(tostring(c.cat or "outros"))
          grupos[cat] = grupos[cat] or { nome = tostring(c.cat or "Outros"), itens = {} }
          table.insert(grupos[cat].itens, nome)
        end
        for w in pairs(set) do
          if grupos[w] then
            table.sort(grupos[w].itens)
            local n = math.min(#grupos[w].itens, 30)
            return "<b>" .. grupos[w].nome .. "</b> (" .. #grupos[w].itens .. "): " .. table.concat(grupos[w].itens, ", ", 1, n) .. (#grupos[w].itens > n and "..." or "")
          end
        end
        local cats = {}
        for _, g in pairs(grupos) do table.insert(cats, g.nome .. " (" .. #g.itens .. ")") end
        table.sort(cats)
        return "Tenho <b>" .. total .. "</b> comandos. Categorias: " .. table.concat(cats, ", ") .. ".\nDiga, por exemplo: <b>comandos movimento</b>."
      end

      local c = achaCmd(t)

      if c then
        local liga, desliga = false, false
        for w in pairs(set) do
          if LIGA[w] then liga = true end
          if DESLIGA[w] then desliga = true end
        end
        local querExplicar = tem("como", "explica", "explicar", "funciona", "serve", "faz", "faco", "que", "qual")
        if (liga or desliga) and not querExplicar then
          if c.need then
            return "O <b>" .. c.name .. "</b> precisa de um valor. Digite na aba <b>Cmds</b>: <b>" .. c.name .. " valor</b>."
          end
          local quer = liga and not desliga
          local feito = pcall(function()
            if c.toggle then X.setToggle(c, quer) else X.run(c.name) end
          end)
          if feito then
            if c.toggle then return (quer and "Liguei" or "Desliguei") .. " o <b>" .. c.name .. "</b> ✅" end
            return "Rodei o <b>" .. c.name .. "</b> ✅"
          end
          return "Não consegui rodar o <b>" .. c.name .. "</b> agora. Tenta pela aba <b>Cmds</b>."
        end
        return explica(c)
      end

      -- informações
      if t:find("ping", 1, true) or tem("fps", "lag", "lagado") then
        return "FPS: <b>" .. fpsAtual .. "</b> · Ping: <b>" .. pingAtual .. " ms</b>"
      end
      if tem("hora", "horas", "relogio") then
        return "Agora são <b>" .. os.date("%H:%M:%S") .. "</b>."
      end
      if tem("jogadores", "players", "quem", "pessoas") then
        local nomes = {}
        for _, p in ipairs(Players:GetPlayers()) do table.insert(nomes, p.DisplayName) end
        return "Tem <b>" .. #nomes .. "/" .. Players.MaxPlayers .. "</b> jogadores: " .. table.concat(nomes, ", ", 1, math.min(#nomes, 20)) .. (#nomes > 20 and "..." or "")
      end
      if tem("jogo", "mapa", "lugar", "servidor", "server", "jobid", "placeid") then
        local min = math.floor(workspace.DistributedGameTime / 60)
        return "Jogo: <b>" .. nomeJogo .. "</b>\nPlaceId: " .. game.PlaceId .. "\nJogadores: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers .. "\nServidor aberto há " .. min .. " min.\nJobId: " .. tostring(game.JobId)
      end
      if tem("conta", "perfil", "eu", "meu", "minha", "nome") then
        return "Você é <b>" .. Player.DisplayName .. "</b> (@" .. Player.Name .. "), conta com <b>" .. Player.AccountAge .. "</b> dias."
      end
      if tem("barra") or (tem("info") and not tem("jogo")) then
        infoLigada = not infoLigada
        sincroniza()
        return infoLigada and "Barra de info ligada (aparece com o menu aberto)." or "Barra de info escondida. Diga <b>barra</b> pra voltar."
      end
      if tem("tamanho", "menor", "pequeno", "grande", "dpi", "tela", "atrapalha", "zoom") then
        return "Pra deixar o NOVEX menor: <b>Config → Tamanho do menu → −</b>, ou na aba <b>Cmds</b> digite <b>guiscale 0.7</b>.\nA pastilha NOVEX do topo você arrasta pra onde quiser, e a barra de info some quando o menu fecha."
      end
      if tem("oi", "ola", "eai", "opa", "ajuda", "help", "menu") or t:find("quem e voce", 1, true) then
        return "Oi! Sou o assistente do NOVEX (funciono por regras, sem internet). Posso:\n• explicar comandos: <b>como uso o fly</b>\n• ligar/desligar: <b>liga noclip</b>, <b>desliga esp</b>\n• listar: <b>comandos movimento</b>\n• infos: <b>ping</b>, <b>jogadores</b>, <b>jogo</b>, <b>hora</b>, <b>conta</b>\n• <b>barra</b> esconde/mostra a barra de info\n• <b>tamanho</b> ajuda com o tamanho do menu"
      end

      -- sugestões parecidas
      local cmds = X.CmdByName
      if type(cmds) == "table" then
        local achados = {}
        for w in t:gmatch("[%w_]+") do
          if #w >= 3 and not PARADA[w] then
            for nome in pairs(cmds) do
              if nome:find(w, 1, true) and #achados < 6 then table.insert(achados, nome) end
            end
          end
        end
        if #achados > 0 then
          table.sort(achados)
          return "Não tenho certeza, mas talvez seja um destes: <b>" .. table.concat(achados, "</b>, <b>") .. "</b>. Pergunte, por exemplo: <b>como uso " .. achados[1] .. "</b>."
        end
      end
     
