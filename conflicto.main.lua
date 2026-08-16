
-- CHRISS VIP | KEY SYSTEM V2 NEON 

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local HttpService = game:GetService("HttpService")
local RbxAnalytics = game:GetService("RbxAnalyticsService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local DatabaseURL = "https://chrisshub-database-default-rtdb.firebaseio.com/"

--  PETICIÓN HTTP 
local httprequest = request or http_request or (fluxus and fluxus.request)
if not httprequest then
    LocalPlayer:Kick("Tu ejecutor no soporta peticiones HTTP avanzadas.")
    return
end

-- OBTENER HWID 
local function GetHWID()
    local success, result = pcall(function() return RbxAnalytics:GetClientId() end)
    return success and result or tostring(LocalPlayer.UserId .. "-FALLBACK")
end
local MyHWID = GetHWID()

-- Efecto de Desenfoque Cinemático
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Parent = Lighting
TweenService:Create(BlurEffect, TweenInfo.new(0.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = 20}):Play()

-- INTERFAZ NEON🔥
local AuthGui = Instance.new("ScreenGui")
AuthGui.Name = "ChrissAuthSystemPremium"
AuthGui.ResetOnSpawn = false

--  PCALL PARA EVITAR BLOQUEOS 
local successParent = pcall(function() AuthGui.Parent = CoreGui end)
if not successParent then AuthGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 1
Overlay.BorderSizePixel = 0
Overlay.Parent = AuthGui
TweenService:Create(Overlay, TweenInfo.new(0.5), {BackgroundTransparency = 0.6}):Play()

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 0, 0, 0) 
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 13, 17)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = AuthGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(160, 80, 255)
UIStroke.Thickness = 2
UIStroke.Transparency = 1
UIStroke.Parent = MainFrame

local Glow = Instance.new("ImageLabel")
Glow.Size = UDim2.new(1, 60, 1, 60)
Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
Glow.AnchorPoint = Vector2.new(0.5, 0.5)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://5028857084"
Glow.ImageColor3 = Color3.fromRGB(160, 80, 255)
Glow.ImageTransparency = 1
Glow.ZIndex = 0
Glow.Parent = MainFrame

-- 🔥 TITULO DORADO CON ANIMACIÓN DE BRILLO 🔥
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 15)
Title.Text = "CHRISS VIP ⚡"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.TextTransparency = 1
Title.Parent = MainFrame

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 0))
})
TitleGradient.Rotation = 0
TitleGradient.Parent = Title

task.spawn(function()
    TitleGradient.Offset = Vector2.new(-0.8, 0)
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
    local gradientTween = TweenService:Create(TitleGradient, tweenInfo, {Offset = Vector2.new(0.8, 0)})
    gradientTween:Play()
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 10)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 24
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextTransparency = 1
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(Overlay, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(BlurEffect, TweenInfo.new(0.5), {Size = 0}):Play()
    task.wait(0.5)
    AuthGui:Destroy()
    BlurEffect:Destroy()
end)

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.85, 0, 0, 48)
KeyInput.Position = UDim2.new(0.5, 0, 0.42, 0)
KeyInput.AnchorPoint = Vector2.new(0.5, 0.5)
KeyInput.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
KeyInput.Text = ""
KeyInput.PlaceholderText = "Ingresa tu Licencia VIP..."
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 13
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextTransparency = 1
KeyInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = KeyInput

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(60, 65, 80)
InputStroke.Thickness = 1.5
InputStroke.Parent = KeyInput

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.5, 0, 0.62, 0)
StatusLabel.AnchorPoint = Vector2.new(0.5, 0.5)
StatusLabel.Text = "Estado: Esperando validación"
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 11
StatusLabel.TextColor3 = Color3.fromRGB(120, 125, 140)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextTransparency = 1
StatusLabel.Parent = MainFrame

local CheckBtn = Instance.new("TextButton")
CheckBtn.Size = UDim2.new(0.85, 0, 0, 45)
CheckBtn.Position = UDim2.new(0.5, 0, 0.82, 0)
CheckBtn.AnchorPoint = Vector2.new(0.5, 0.5)
CheckBtn.BackgroundColor3 = Color3.fromRGB(160, 80, 255)
CheckBtn.Text = "INICIAR SESIÓN"
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.TextSize = 14
CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckBtn.TextTransparency = 1
CheckBtn.AutoButtonColor = false
CheckBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = CheckBtn

local OpenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
TweenService:Create(MainFrame, OpenInfo, {Size = UDim2.new(0, 380, 0, 260)}):Play()
TweenService:Create(UIStroke, TweenInfo.new(0.8), {Transparency = 0}):Play()
TweenService:Create(Glow, TweenInfo.new(1), {ImageTransparency = 0.7}):Play()

task.wait(0.3)
local FadeInfo = TweenInfo.new(0.4)
TweenService:Create(Title, FadeInfo, {TextTransparency = 0}):Play()
TweenService:Create(CloseBtn, FadeInfo, {TextTransparency = 0}):Play()
TweenService:Create(KeyInput, FadeInfo, {TextTransparency = 0}):Play()
TweenService:Create(StatusLabel, FadeInfo, {TextTransparency = 0}):Play()
TweenService:Create(CheckBtn, FadeInfo, {TextTransparency = 0}):Play()

local isChecking = false

local function IniciarValidacion()
    if isChecking then return end
    local userKey = KeyInput.Text:gsub("%s+", "")
    
    if userKey == "" then
        StatusLabel.Text = "❌ Campo vacío, ingresa tu llave."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end

    isChecking = true
    StatusLabel.Text = "⏳ Conectando con el servidor..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    CheckBtn.Text = "VERIFICANDO..."
    
    local success, err = pcall(function()
        local sysReq = httprequest({Url = DatabaseURL .. "system_status.json", Method = "GET"})
        local sysStatus = HttpService:JSONDecode(sysReq.Body)

        local keyReq = httprequest({Url = DatabaseURL .. "keys/" .. userKey .. ".json", Method = "GET"})
        local keyData = HttpService:JSONDecode(keyReq.Body)

        if not keyData or keyData == "null" then
            StatusLabel.Text = "❌ Llave inválida o eliminada."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            CheckBtn.Text = "INICIAR SESIÓN"
            isChecking = false
            return
        end

        if keyData.status == "blacklisted" then
            StatusLabel.Text = "⛔ Llave Baneada por el Administrador."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            CheckBtn.Text = "INICIAR SESIÓN"
            isChecking = false
            return
        end

        local currentTime = os.time()
        if keyData.expires_at == 0 then
            local duration = keyData.duration_seconds or 0
            if duration > 0 then
                local newExpiration = currentTime + duration
                keyData.expires_at = newExpiration
                httprequest({
                    Url = DatabaseURL .. "keys/" .. userKey .. "/expires_at.json",
                    Method = "PUT",
                    Body = HttpService:JSONEncode(newExpiration),
                    Headers = {["Content-Type"] = "application/json"}
                })
            else
                StatusLabel.Text = "❌ Error en los datos de duración."
                StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                CheckBtn.Text = "INICIAR SESIÓN"
                isChecking = false
                return
            end
        end

        if currentTime > keyData.expires_at then
            StatusLabel.Text = "🔴 Tu llave ha expirado."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            CheckBtn.Text = "INICIAR SESIÓN"
            isChecking = false
            return
        end

        local used_hwids = keyData.used_hwids or {}
        local hwidEncontrado = false

        for _, v in pairs(used_hwids) do
            if v == MyHWID then
                hwidEncontrado = true
                break
            end
        end

        if not hwidEncontrado then
            if #used_hwids < keyData.hwid_limit then
                table.insert(used_hwids, MyHWID)
                local updateReq = httprequest({
                    Url = DatabaseURL .. "keys/" .. userKey .. "/used_hwids.json",
                    Method = "PUT",
                    Body = HttpService:JSONEncode(used_hwids),
                    Headers = {["Content-Type"] = "application/json"}
                })
                
                if updateReq.StatusCode ~= 200 then
                    StatusLabel.Text = "❌ Error al enlazar PC."
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                    CheckBtn.Text = "INICIAR SESIÓN"
                    isChecking = false
                    return
                end
            else
                StatusLabel.Text = "❌ Límite de HWID alcanzado."
                StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                CheckBtn.Text = "INICIAR SESIÓN"
                isChecking = false
                return
            end
        end

        StatusLabel.Text = "✅ ¡Acceso Concedido! Cargando sistema..."
        StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
        CheckBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 120)
        CheckBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        CheckBtn.Text = "ACCESO PERMITIDO"
        
        task.wait(1)
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        TweenService:Create(Overlay, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(BlurEffect, TweenInfo.new(0.5), {Size = 0}):Play()
        
        task.wait(0.5)
        AuthGui:Destroy()
        BlurEffect:Destroy()
        
        IniciarScriptPrincipal()
    end)

    if not success then
        StatusLabel.Text = "❌ Error de conexión."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        CheckBtn.Text = "INICIAR SESIÓN"
        isChecking = false
    end
end

CheckBtn.MouseButton1Click:Connect(function()
    task.spawn(function() IniciarValidacion() end)
end)


function IniciarScriptPrincipal()
    -- VARIABLES GLOBALES
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Camera = workspace.CurrentCamera

    local Config = {
        SpeedEnabled = false, 
        SpeedValue = 2, -- Máximo ajustado a 5
        SuperJump = false, 
        Noclip = false, 
        HideName = false,     
        AimbotEnabled = false,
        SilentAim = false,
        FOVEnabled = false, 
        FOVRadius = 100,
        ESPBox = false, 
        ESPName = false, 
        ESPDist = false, 
        ESPHealth = false, 
        ESPGun = false, 
        ESPGunDist = false
    }

    -- =============================================
    -- CARGA DE INTERFAZ WINDUI (ESTILO JUIX HUB)
    -- =============================================
    local WindUILibrary
    pcall(function()
        WindUILibrary = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)

    local MainWindow
    if WindUILibrary then
        MainWindow = WindUILibrary:CreateWindow({
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
    else
        return -- Si falla la librería, detenemos para evitar errores
    end

    -- =============================================
    -- TABS Y MENÚS
    -- =============================================
    local TabCombat = MainWindow:Tab({Title = "Combat", Icon = "crosshair"})
    local TabPlayer = MainWindow:Tab({Title = "Player", Icon = "user"})
    local TabVisuals = MainWindow:Tab({Title = "Visuals", Icon = "eye"})

    -- COMBATE
    TabCombat:Section({Title = "AIMBOT Y FOV"})
    TabCombat:Toggle({Title = "Show FOV Anillo", Default = false, Callback = function(v) Config.FOVEnabled = v end})
    TabCombat:Slider({Title = "FOV Radio", Step = 1, Value = {Min = 30, Max = 300, Default = 100}, Callback = function(v) Config.FOVRadius = v end})
    TabCombat:Toggle({Title = "Aimbot", Default = false, Callback = function(v) Config.AimbotEnabled = v end})
    TabCombat:Toggle({Title = "Silent Aim", Default = false, Callback = function(v) Config.SilentAim = v end})

    -- PLAYER
    TabPlayer:Section({Title = "MOVIMIENTO"})
    TabPlayer:Toggle({Title = "Speed Hack", Default = false, Callback = function(v) Config.SpeedEnabled = v end})
    TabPlayer:Slider({Title = "Multiplicador de Velocidad", Step = 0.5, Value = {Min = 1, Max = 5, Default = 2}, Callback = function(v) Config.SpeedValue = v end})
    TabPlayer:Toggle({Title = "Super Jump (x4)", Default = false, Callback = function(v) Config.SuperJump = v end})
    TabPlayer:Toggle({Title = "Noclip", Default = false, Callback = function(v) Config.Noclip = v end})
    TabPlayer:Toggle({Title = "Hide Name", Default = false, Callback = function(v) Config.HideName = v end})

    -- VISUALS
    TabVisuals:Section({Title = "ESP (EXTRASENSORY PERCEPTION)"})
    TabVisuals:Toggle({Title = "ESP Box", Default = false, Callback = function(v) Config.ESPBox = v end})
    TabVisuals:Toggle({Title = "ESP Name", Default = false, Callback = function(v) Config.ESPName = v end})
    TabVisuals:Toggle({Title = "ESP Vida", Default = false, Callback = function(v) Config.ESPHealth = v end})
    TabVisuals:Toggle({Title = "ESP Distancia", Default = false, Callback = function(v) Config.ESPDist = v end})

    -- =============================================
    -- AQUÍ LÓGICA DE SILENT AA
    -- =============================================
    -- (Inserta tu código de hook y redirección aquí)
    
    
    -- =============================================
    -- LÓGICA DEL JUGADOR (SPEED, JUMP, NOCLIP)
    -- =============================================
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local RootPart = Character:WaitForChild("HumanoidRootPart")

    LocalPlayer.CharacterAdded:Connect(function(char)
        Character = char
        Humanoid = char:WaitForChild("Humanoid")
        RootPart = char:WaitForChild("HumanoidRootPart")
    end)

    -- SPEED HACK SEGURO (MÁXIMO 5)
    RunService.Heartbeat:Connect(function()
        if Character and Humanoid and RootPart and Config.SpeedEnabled then
            local MoveDirection = Humanoid.MoveDirection
            if MoveDirection.Magnitude > 0 then
                -- Se ajusta la velocidad según el slider (Max 5)
                local safeSpeed = math.clamp(Config.SpeedValue, 1, 5)
                RootPart.CFrame = RootPart.CFrame + (MoveDirection * (safeSpeed / 10))
            end
        end
    end)

    -- SUPER JUMP (X4)
    UserInputService.JumpRequest:Connect(function()
        if Config.SuperJump and Character and Humanoid then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = 200 -- 4 veces el salto normal
        elseif Character and Humanoid then
            Humanoid.JumpPower = 50 -- Salto por defecto
        end
    end)

    -- NOCLIP
    RunService.Stepped:Connect(function()
        if Config.Noclip and Character then
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)

    -- HIDE NAME
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

    
    -- LÓGICA FOV CIRCLE VISUAL
    local fovGui = Instance.new("ScreenGui")
    local fovFrame = Instance.new("Frame")
    local fovCorner = Instance.new("UICorner")
    local fovStroke = Instance.new("UIStroke")

    fovGui.Name = "ChrissFov"
    fovGui.ResetOnSpawn = false
    pcall(function() fovGui.Parent = game:GetService("CoreGui") end)
    if not fovGui.Parent then fovGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    fovFrame.Name = "FovCircle"
    fovFrame.Parent = fovGui
    fovFrame.BackgroundTransparency = 1
    fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0) 
    fovFrame.Visible = false

    fovCorner.CornerRadius = UDim.new(1, 0)
    fovCorner.Parent = fovFrame

    fovStroke.Parent = fovFrame
    fovStroke.Thickness = 1.5
    fovStroke.Color = Color3.fromRGB(255, 255, 255)

    RunService.RenderStepped:Connect(function()
        if Config.FOVEnabled then
            fovFrame.Visible = true
            fovFrame.Size = UDim2.fromOffset(Config.FOVRadius * 2, Config.FOVRadius * 2)
        else
            fovFrame.Visible = false
        end
    end)
    
    print("💎 CHRISS VIP CARGADO CON ÉXITO")
end
