local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Cargar Interfaz WindUI
local WindUILibrary = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local MainWindow = WindUILibrary:CreateWindow({
    Title = "💎 CHRISS VIP",
    Icon = "",
    Author = "By Chriss",
    Folder = "ChrissVIP",
    Size = UDim2.fromOffset(650, 400),
    Theme = "Dark",
    Transparent = true,
    Resizable = true,
    KeyCode = Enum.KeyCode.G
})

MainWindow:EditOpenButton({
    Title = "💎 CHRISS VIP",
    Icon = "",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("#1a1a1a"), Color3.fromHex("#FFD700")),
    Enabled = true,
    Draggable = true,
})

-- Configuración Global
local Config = {
    SpeedEnabled = false,
    SpeedValue = 2,
    SuperJump = false,
    Noclip = false,
    HideName = false,
    FOVEnabled = false,
    FOVRadius = 100,
    ESPBox = false,
    ESPName = false,
    ESPDist = false,
    ESPHealth = false,
    ESPGun = false,
    Traces = false,
    AutoAttack = false,
    GunMods = false,
    Fullbright = false
}

-- Pestañas del Menú
local TabCombat = MainWindow:Tab({Title = "Combat", Icon = "crosshair"})
local TabVisuals = MainWindow:Tab({Title = "Visuals", Icon = "eye"})
local TabPlayer = MainWindow:Tab({Title = "Player", Icon = "user"})
local TabMisc = MainWindow:Tab({Title = "Misc", Icon = "warehouse"})

-- Opciones de Combate
TabCombat:Section({Title = "Aimbot & FOV"})
TabCombat:Toggle({
    Title = "Show FOV Circle",
    Default = false,
    Callback = function(value) Config.FOVEnabled = value end
})
TabCombat:Slider({
    Title = "FOV Radius",
    Step = 1,
    Value = {Min = 30, Max = 300, Default = 100},
    Callback = function(value) Config.FOVRadius = value end
})
TabCombat:Section({Title = "Mods & Aura"})
TabCombat:Toggle({
    Title = "Auto Attack (Melee)",
    Default = false,
    Callback = function(value) Config.AutoAttack = value end
})
TabCombat:Toggle({
    Title = "Gun Mods (FireRate, No Recoil)",
    Default = false,
    Callback = function(value) Config.GunMods = value end
})

-- Opciones de Visuales (ESP)
TabVisuals:Section({Title = "ESP Jugadores"})
TabVisuals:Toggle({
    Title = "ESP Box",
    Default = false,
    Callback = function(value) Config.ESPBox = value end
})
TabVisuals:Toggle({
    Title = "ESP Nombres",
    Default = false,
    Callback = function(value) Config.ESPName = value end
})
TabVisuals:Toggle({
    Title = "ESP Distancia",
    Default = false,
    Callback = function(value) Config.ESPDist = value end
})
TabVisuals:Toggle({
    Title = "ESP Vida",
    Default = false,
    Callback = function(value) Config.ESPHealth = value end
})
TabVisuals:Toggle({
    Title = "ESP Armas",
    Default = false,
    Callback = function(value) Config.ESPGun = value end
})
TabVisuals:Toggle({
    Title = "ESP Traces (Líneas)",
    Default = false,
    Callback = function(value) Config.Traces = value end
})

-- Opciones del Jugador
TabPlayer:Section({Title = "Movimiento"})
TabPlayer:Toggle({
    Title = "Speed Hack",
    Default = false,
    Callback = function(value) Config.SpeedEnabled = value end
})
TabPlayer:Slider({
    Title = "Velocidad Máxima",
    Step = 0.5,
    Value = {Min = 1, Max = 5, Default = 2},
    Callback = function(value) Config.SpeedValue = value end
})
TabPlayer:Toggle({
    Title = "Super Jump (x4)",
    Default = false,
    Callback = function(value) Config.SuperJump = value end
})
TabPlayer:Toggle({
    Title = "Noclip (Atravesar paredes)",
    Default = false,
    Callback = function(value) Config.Noclip = value end
})
TabPlayer:Toggle({
    Title = "Ocultar Mi Nombre",
    Default = false,
    Callback = function(value) Config.HideName = value end
})

-- Opciones Misceláneas
TabMisc:Section({Title = "Utilidades del Servidor"})
TabMisc:Button({
    Title = "Claim All Quests",
    Callback = function()
        pcall(function()
            for _, req in ipairs(getgc(true)) do
                if type(req) == "table" and rawget(req, "func") then
                    req.func = req.func + 1
                    ReplicatedStorage.Remotes.Get:InvokeServer(req.func, "claim_quest", "All")
                end
            end
        end)
    end
})
TabMisc:Button({
    Title = "Robar Vehículo (Pull Car)",
    Callback = function()
        local vehiculos = Workspace:FindFirstChild("Vehicles")
        local raiz = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if vehiculos and raiz then
            for _, v in pairs(vehiculos:GetChildren()) do
                if v:IsA("Model") and v:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
                    if v.PrimaryPart then 
                        v:SetPrimaryPartCFrame(raiz.CFrame * CFrame.new(0, 3, -8)) 
                    end
                end
            end
        end
    end
})
TabMisc:Button({
    Title = "Server Hop",
    Callback = function()
        local res = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100"))
        for _, s in ipairs(res.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                break
            end
        end
    end
})

-- AQUÍ LÓGICA DE SILENT AA
-- (Pega todo tu código del silent aim, aimbot y predicción aquí)


-- Variables del Personaje
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Lógica de Movimiento (Speed Hack seguro y Noclip)
RunService.Heartbeat:Connect(function()
    if Character and Humanoid and RootPart then
        if Config.SpeedEnabled then
            local MoveDirection = Humanoid.MoveDirection
            if MoveDirection.Magnitude > 0 then
                local safeSpeed = math.clamp(Config.SpeedValue, 1, 5)
                RootPart.CFrame = RootPart.CFrame + (MoveDirection * (safeSpeed / 10))
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if Config.Noclip and Character then
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Lógica de Super Jump
UserInputService.JumpRequest:Connect(function()
    if Config.SuperJump and Character and Humanoid then
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = 200
    elseif Character and Humanoid then
        Humanoid.JumpPower = 50
    end
end)

-- Lógica Hide Name
RunService.RenderStepped:Connect(function()
    if Character then
        local hum = Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if Config.HideName then
                hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            else
                hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            end
        end
    end
end)

-- Lógica Gun Mods
RunService.Heartbeat:Connect(function()
    if not Config.GunMods or not Character then return end
    for _, tool in ipairs(Character:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:match("Gun") or tool:FindFirstChild("Handle")) then
            pcall(function()
                tool:SetAttribute("fire_rate", 1000)
                tool:SetAttribute("accuracy", 1)
                tool:SetAttribute("Recoil", 0)
                tool:SetAttribute("Durability", 99999)
                tool:SetAttribute("automatic", true)
            end)
        end
    end
end)

-- Lógica Auto Ataque Melee
task.spawn(function()
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local RemoteSend = Remotes and Remotes:FindFirstChild("Send")
    
    while true do
        task.wait(0.4)
        if Config.AutoAttack and RemoteSend and Character and Character.PrimaryPart then
            local arma = Character:FindFirstChildOfClass("Tool")
            if arma then
                local targets = {}
                for _, j in ipairs(Players:GetPlayers()) do
                    if j ~= LocalPlayer and j.Character and j.Character.PrimaryPart then
                        if (j.Character.PrimaryPart.Position - Character.PrimaryPart.Position).Magnitude <= 20 then
                            table.insert(targets, j)
                        end
                    end
                end
                if #targets > 0 then
                    pcall(function() 
                        RemoteSend:FireServer("melee_attack", arma, targets, CFrame.new(), 0.75) 
                    end)
                end
            end
        end
    end
end)

-- Dibujo del Círculo FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 1

RunService.RenderStepped:Connect(function()
    if Config.FOVEnabled then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = Config.FOVRadius
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

-- Sistema ESP Completo
local espCache = {}

local function CreateESPElement(class, properties)
    local element = Drawing.new(class)
    for k, v in pairs(properties) do
        element[k] = v
    end
    return element
end

local function AddESP(player)
    if player == LocalPlayer or espCache[player] then return end

    local cache = {}
    espCache[player] = cache

    cache.Box = CreateESPElement("Square", {
        Color = Color3.fromRGB(255, 0, 0),
        Thickness = 1.5,
        Filled = false,
        Visible = false
    })

    cache.Name = CreateESPElement("Text", {
        Color = Color3.fromRGB(255, 255, 255),
        Size = 14,
        Center = true,
        Outline = true,
        Visible = false
    })

    cache.Dist = CreateESPElement("Text", {
        Color = Color3.fromRGB(220, 220, 220),
        Size = 13,
        Center = true,
        Outline = true,
        Visible = false
    })

    cache.Gun = CreateESPElement("Text", {
        Color = Color3.fromRGB(255, 255, 255),
        Size = 13,
        Center = true,
        Outline = true,
        Visible = false
    })

    cache.HealthBg = CreateESPElement("Square", {
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 1,
        Filled = true,
        Visible = false
    })

    cache.HealthFill = CreateESPElement("Square", {
        Color = Color3.fromRGB(0, 255, 0),
        Thickness = 1,
        Filled = true,
        Visible = false
    })

    cache.Trace = CreateESPElement("Line", {
        Color = Color3.fromRGB(255, 0, 0),
        Thickness = 1.5,
        Visible = false
    })
end

local function RemoveESP(player)
    if espCache[player] then
        for _, element in pairs(espCache[player]) do
            element:Remove()
        end
        espCache[player] = nil
    end
end

Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in pairs(Players:GetPlayers()) do
    AddESP(p)
end

RunService.RenderStepped:Connect(function()
    local screenBottomCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

    for player, cache in pairs(espCache) do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")

        if not char or not hum or hum.Health <= 0 or not root or not head then
            cache.Box.Visible = false
            cache.Name.Visible = false
            cache.Dist.Visible = false
            cache.Gun.Visible = false
            cache.HealthBg.Visible = false
            cache.HealthFill.Visible = false
            cache.Trace.Visible = false
            continue
        end

        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)

        if onScreen then
            local distance = (Camera.CFrame.Position - root.Position).Magnitude
            local topPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

            local boxHeight = math.abs(topPos.Y - bottomPos.Y)
            local boxWidth = boxHeight * 0.6
            local boxPosition = Vector2.new(rootPos.X - (boxWidth / 2), topPos.Y)

            if Config.ESPBox then
                cache.Box.Size = Vector2.new(boxWidth, boxHeight)
                cache.Box.Position = boxPosition
                cache.Box.Visible = true
            else
                cache.Box.Visible = false
            end

            if Config.ESPName then
                cache.Name.Text = player.Name
                cache.Name.Position = Vector2.new(rootPos.X, topPos.Y - 18)
                cache.Name.Visible = true
            else
                cache.Name.Visible = false
            end

            local currentYOffset = bottomPos.Y + 4

            if Config.ESPDist then
                cache.Dist.Text = math.floor(distance) .. " studs"
                cache.Dist.Position = Vector2.new(rootPos.X, currentYOffset)
                cache.Dist.Visible = true
                currentYOffset = currentYOffset + 14
            else
                cache.Dist.Visible = false
            end

            if Config.ESPGun then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    cache.Gun.Text = tool.Name
                    cache.Gun.Position = Vector2.new(rootPos.X, currentYOffset)
                    cache.Gun.Visible = true
                else
                    cache.Gun.Visible = false
                end
            else
                cache.Gun.Visible = false
            end

            if Config.ESPHealth then
                local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                cache.HealthBg.Size = Vector2.new(4, boxHeight)
                cache.HealthBg.Position = Vector2.new(boxPosition.X - 6, boxPosition.Y)
                cache.HealthBg.Visible = true

                cache.HealthFill.Size = Vector2.new(2, boxHeight * hpPercent)
                cache.HealthFill.Position = Vector2.new(boxPosition.X - 5, boxPosition.Y + (boxHeight - (boxHeight * hpPercent)))
                cache.HealthFill.Color = Color3.fromHSV((hpPercent * 120) / 360, 1, 1)
                cache.HealthFill.Visible = true
            else
                cache.HealthBg.Visible = false
                cache.HealthFill.Visible = false
            end

            if Config.Traces then
                cache.Trace.From = screenBottomCenter
                cache.Trace.To = Vector2.new(rootPos.X, bottomPos.Y)
                cache.Trace.Visible = true
            else
                cache.Trace.Visible = false
            end
        else
            cache.Box.Visible = false
            cache.Name.Visible = false
            cache.Dist.Visible = false
            cache.Gun.Visible = false
            cache.HealthBg.Visible = false
            cache.HealthFill.Visible = false
            cache.Trace.Visible = false
        end
    end
end)
