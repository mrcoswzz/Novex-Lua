local url = "https://raw.githubusercontent.com/mrcoswzz/Novex-Lua/main/NOVEX_5.0_completo%20(1).lua"
local codigo = game:HttpGet(url)
codigo = codigo:gsub("\n([ \t]*)(==+)", "\n%1--%2")
codigo = codigo:gsub("([%s,{])Câmera%s*=", '%1["Câmera"] =')
local f, erro = loadstring(codigo)
if f then f() else warn("NOVEX erro: " .. tostring(erro)) end
