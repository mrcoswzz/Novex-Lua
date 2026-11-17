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

