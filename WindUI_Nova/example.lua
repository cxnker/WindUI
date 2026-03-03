local WindUI = loadstring(game:HttpGet("raw_url_de_tu_archivo"))()
-- O si lo tienes local:
-- local WindUI = loadstring(readfile("WindUI_Deminfied.lua"))()

-- Ahora puedes usar WindUI como siempre
local Window = WindUI:CreateWindow({
    Title = "Mi Ventana",
    Author = "Yo",
    Size = UDim2.fromOffset(600, 500)
})