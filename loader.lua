-- NOVEX HUB 5.0 | LOADER VIVO + ASSISTENTE
-- Mantem o NOVEX.lua como base; aplica apenas cores e adiciona o painel auxiliar.
-- O assistente funciona por regras locais: nao e uma IA online generativa.

local URL = "https://raw.githubusercontent.com/mrcoswzz/Novex-Lua/main/NOVEX.lua"

local okHttp, codigo = pcall(function()
    return game:HttpGet(URL)
end)
if not okHttp or type(codigo) ~= "string" or #codigo < 1000 then
    warn("NOVEX LOADER: nao foi possivel baixar NOVEX.lua: " .. tostring(codigo))
    return
end

local function patch(padrao, novo)
    local r, n = codigo:gsub(padrao, type(novo) == "function" and novo or function() return novo end)
    if n == 0 then warn("NOVEX LOADER: patch nao encontrado: " .. padrao) end
    codigo = r
end

-- Compatibilidade com separadores e com a chave que contem acento.
codigo = codigo:gsub("\n([ \t]*)(==+)", "\n%1--%2")
codigo = codigo:gsub("([%s,{])Câmera%s*=", '%1["Câmera"] =')

-- Paleta viva: azul eletrico, violeta, ciano e acentos neon.
local TEMA = {
    { "blue",   "88, 142, 255", "0, 200, 255" },
    { "blue2",  "54, 102, 225", "112, 72, 255" },
    { "purple", "162, 112, 255", "205, 75, 255" },
    { "green",  "52, 211, 153", "0, 245, 160" },
    { "red",    "244, 63, 94",  "255, 65, 105" },
    { "orange", "251, 146, 60", "255, 175, 65" },
    { "panel",  "13, 15, 22",   "12, 14, 25" },
    { "card",   "22, 25, 36",   "22, 25, 43" },
    { "card2",  "34, 39, 54",   "38, 43, 70" },
}
for _, t in ipairs(TEMA) do
    local nums = t[2]:gsub(", ", ",%%s*")
    patch(t[1] .. "%s*=%s*Color3%.fromRGB%(" .. nums .. "%)",
        t[1] .. " = Color3.fromRGB(" .. t[3] .. ")")
end

-- Extras inseridos no ponto em que Pill e Shell ja existem.
local EXTRA = [==[
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
        end

        local function normaliza(s)
            s = string.lower(tostring(s or ""))
            local mapa = {["á"]="a",["à"]="a",["â"]="a",["ã"]="a",["é"]="e",["ê"]="e",
                ["í"]="i",["ó"]="o",["ô"]="o",["õ"]="o",["ú"]="u",["ç"]="c"}
            for k,v in pairs(mapa) do s = s:gsub(k,v) end
            return s
        end

        local PARADA = {como=true, uso=true, usar=true, usa=true, faz=true, fazer=true, que=true,
            qual=true, quais=true, para=true, pra=true, ativa=true, ativar=true, liga=true, ligar=true,
            desliga=true, desligar=true, comando=true, comandos=true, jogo=true, voce=true, meu=true,
            minha=true, tem=true, pode=true, executar=true, roda=true, rodar=true, ajuda=true,
            explica=true, explicar=true, sobre=true, lista=true, me=true, de=true, do=true, da=true,
            um=true, uma=true, o=true, a=true, no=true, na=true, funciona=true, serve=true}
        local SIN = {voar="fly", voo="fly", atravessar="noclip", parede="noclip", paredes="noclip",
            pular="infjump", pulo="infjump", wallhack="esp", flutuar="float", velocidade="speed", correr="speed"}

        local function explicar(c)
            local s = "<b>" .. tostring(c.name) .. "</b>: " .. tostring(c.desc or "sem descrição")
            if c.need then
                s = s .. "\nPrecisa de argumento. Exemplo: <b>" .. c.name .. " valor</b>."
            elseif c.toggle then
                s = s .. "\nÉ liga/desliga. Peça <b>liga " .. c.name .. "</b> ou <b>desliga " .. c.name .. "</b>."
            else
                s = s .. "\nÉ um comando de execução única. Exemplo: <b>" .. c.name .. "</b>."
            end
            return s
        end

        local function resposta(pergunta)
            local t = normaliza(pergunta)
            local palavras, set = {}, {}
            for w in t:gmatch("[%w_]+") do
                set[w] = true
                if not PARADA[w] then table.insert(palavras, w) end
            end
            local function tem(...)
                for _,w in ipairs({...}) do if set[w] then return true end end
                return false
            end

            local cmds = X and X.CmdByName
            if tem("ajuda", "oi", "ola", "opa", "eai", "menu") then
                return "Olá! Sou o assistente local do NOVEX. Posso explicar comandos, mostrar categorias, orientar sobre a biblioteca Scripts e informar FPS, ping, jogadores, servidor e horário.\nExemplos: <b>como uso fly</b>, <b>comandos movimento</b>, <b>ping</b>, <b>scripts</b>."
            end
            if tem("ping", "fps", "lag", "lagado") then
                return "Agora: <b>" .. fps .. " FPS</b> e <b>" .. ping .. " ms</b> de ping."
            end
            if tem("hora", "horas", "data", "dia") then
                return "Hoje é <b>" .. dataPt() .. "</b>. Horário local do dispositivo: <b>" .. os.date("%H:%M:%S") .. "</b>."
            end
            if tem("jogadores", "players", "pessoas") then
                return "Há <b>" .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers .. "</b> jogadores nesta partida."
            end
            if tem("servidor", "server", "placeid", "jobid", "jogo", "mapa") then
                return "Jogo: <b>" .. jogo .. "</b>\nPlaceId: <b>" .. game.PlaceId .. "</b>\nJobId: <b>" .. tostring(game.JobId) .. "</b>\nJogadores: <b>" .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers .. "</b>."
            end
            if tem("scripts", "scriptblox", "rscripts", "biblioteca") then
                return "A aba <b>Scripts</b> reúne resultados de bibliotecas externas, como ScriptBlox e RScripts. Escolha um script e leia a descrição antes de executar. Posso explicar comandos do NOVEX; para explicar um script externo específico, envie o nome e a descrição que aparecem na biblioteca. Não consigo ler automaticamente o código de todo script externo por esta janela."
            end
            if type(cmds) == "table" then
                if tem("comandos", "comando", "lista", "cmds", "cmd") then
                    local cats, total = {}, 0
                    for nome,c in pairs(cmds) do
                        total = total + 1
                        local cat = tostring(c.cat or "Outros")
                        cats[cat] = cats[cat] or {}
                        table.insert(cats[cat], nome)
                    end
                    for cat,itens in pairs(cats) do
                        if t:find(normaliza(cat), 1, true) then
                            table.sort(itens)
                            return "<b>" .. cat .. "</b> (" .. #itens .. "): " .. table.concat(itens, ", ", 1, math.min(#itens, 35))
                        end
                    end
                    local nomes = {}
                    for cat,itens in pairs(cats) do table.insert(nomes, cat .. " (" .. #itens .. ")") end
                    table.sort(nomes)
                    return "Tenho <b>" .. total .. "</b> comandos registrados. Categorias: " .. table.concat(nomes, ", ") .. ". Pergunte, por exemplo: <b>comandos movimento</b>."
                end

                local escolhido
                for _,w in ipairs(palavras) do
                    local alvo = SIN[w] or w
                    if cmds[alvo] then escolhido = cmds[alvo] break end
                end
                if not escolhido then
                    for _,w in ipairs(palavras) do
                        if #w >= 4 then
                            for nome,c in pairs(cmds) do
                                if nome:sub(1,#w) == w then escolhido = c break end
                            end
                        end
                        if escolhido then break end
                    end
                end
                if escolhido then
                    local ligar = tem("liga", "ligar", "ativar", "ativa", "on")
                    local desligar = tem("desliga", "desligar", "desativar", "off")
                    if (ligar or desligar) and not escolhido.need then
                        local okRun = pcall(function()
                            if escolhido.toggle then X.setToggle(escolhido, ligar and not desligar)
                            else X.run(escolhido.name) end
                        end)
                        if okRun then return (ligar and not desligar and "Ativei " or "Executei ") .. "<b>" .. escolhido.name .. "</b>." end
                        return "Não consegui executar agora. Tente pela aba <b>Cmds</b>."
                    end
                    return explicar(escolhido)
                end
            end
            return "Não encontrei esse comando na lista do NOVEX. Tente <b>comandos</b> para ver as categorias, ou pergunte <b>como uso fly</b>. Para scripts externos, diga o nome e cole a descrição."
        end

        local function enviar()
            local txt = caixa.Text
            if txt:gsub("%s", "") == "" then return end
            caixa.Text = ""
            msg(txt, true)
            local okResp, r = pcall(resposta, txt)
            msg(okResp and r or ("O assistente encontrou um erro: " .. tostring(r)), false)
        end
        enviarBtn.MouseButton1Click:Connect(enviar)
        caixa.FocusLost:Connect(function(enter) if enter then enviar() end end)
        fechar.MouseButton1Click:Connect(function() Janela.Visible = false end)
        msg("Olá! Sou o assistente local do NOVEX. Digite <b>ajuda</b> para começar. O histórico não tem um limite fixo de mensagens durante esta sessão.", false)

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
]==]

local ancora = "Pill%.MouseButton1Click:Connect%(function%(%) Shell%.Visible = not Shell%.Visible end%)"
local resultado, n = codigo:gsub(ancora, function()
    return EXTRA
end, 1)

if n == 0 then
    warn("NOVEX LOADER: nao encontrei o ponto de insercao. O NOVEX sera executado sem extras.")
    resultado = codigo
end

local fn, erro = loadstring(resultado)
if not fn then
    warn("NOVEX LOADER: erro de compilacao: " .. tostring(erro))
    return
end

local okRun, errRun = pcall(fn)
if not okRun then
    warn("NOVEX LOADER: erro ao iniciar: " .. tostring(errRun))
end
