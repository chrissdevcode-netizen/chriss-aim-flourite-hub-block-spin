-- CHRISS HUB | KEY SYSTEM V2 NEON 

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
Title.Text = "BULLET CONFLICT PREMIUM ⚡"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(255, 255, 255) -- Color base (será sobreescrito por el gradiente)
Title.BackgroundTransparency = 1
Title.TextTransparency = 1
Title.Parent = MainFrame

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 0)),      -- Oro oscuro
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 150)),  -- Brillo blanco/amarillo
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 0))       -- Oro oscuro
})
TitleGradient.Rotation = 0
TitleGradient.Parent = Title

-- Animación del brillo dorado moviéndose de un lado a otro
task.spawn(function()
    TitleGradient.Offset = Vector2.new(-0.8, 0)
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
    local gradientTween = TweenService:Create(TitleGradient, tweenInfo, {Offset = Vector2.new(0.8, 0)})
    gradientTween:Play()
end)

--  BOTÓN DE CERRAR 
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

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    -- Animación de cierre y destrucción
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

-- Animaciones de Entrada
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

-- Efectos del Input y Botón
KeyInput.Focused:Connect(function()
    TweenService:Create(InputStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(160, 80, 255)}):Play()
end)
KeyInput.FocusLost:Connect(function()
    TweenService:Create(InputStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(60, 65, 80)}):Play()
end)

CheckBtn.MouseEnter:Connect(function()
    TweenService:Create(CheckBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(180, 110, 255)}):Play()
end)
CheckBtn.MouseLeave:Connect(function()
    TweenService:Create(CheckBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(160, 80, 255)}):Play()
end)
CheckBtn.MouseButton1Down:Connect(function()
    TweenService:Create(CheckBtn, TweenInfo.new(0.1), {Size = UDim2.new(0.82, 0, 0, 42)}):Play()
end)
CheckBtn.MouseButton1Up:Connect(function()
    TweenService:Create(CheckBtn, TweenInfo.new(0.1), {Size = UDim2.new(0.85, 0, 0, 45)}):Play()
end)



-- 🔥 LÓGICA DE SERVIDOR Y VALIDACIÓN 
local isChecking = false

local function IniciarValidacion()
    if isChecking then return end
    local userKey = KeyInput.Text:gsub("%s+", "")
    
    if userKey == "" then
        StatusLabel.Text = "❌ Campo vacío, ingresa tu llave."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        
        local originalPos = MainFrame.Position
        for i = 1, 4 do
            MainFrame.Position = originalPos + UDim2.new(0, math.random(-5, 5), 0, 0)
            task.wait(0.05)
        end
        MainFrame.Position = originalPos
        return
    end

    isChecking = true
    StatusLabel.Text = "⏳ Conectando con el servidor..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    CheckBtn.Text = "VERIFICANDO..."
    
    local success, err = pcall(function()
        --  Checar mantenimiento global
        local sysReq = httprequest({Url = DatabaseURL .. "system_status.json", Method = "GET"})
        local sysStatus = HttpService:JSONDecode(sysReq.Body)

        --  Descargar datos de la llave
        local keyReq = httprequest({Url = DatabaseURL .. "keys/" .. userKey .. ".json", Method = "GET"})
        local keyData = HttpService:JSONDecode(keyReq.Body)

        --  Validar Existencia
        if not keyData or keyData == "null" then
            StatusLabel.Text = "❌ Llave inválida o eliminada."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            CheckBtn.Text = "INICIAR SESIÓN"
            isChecking = false
            return
        end

        --  Validar Blacklist (Baneo Manual)
        if keyData.status == "blacklisted" then
            StatusLabel.Text = "⛔ Llave Baneada por el Administrador."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            CheckBtn.Text = "INICIAR SESIÓN"
            isChecking = false
            return
        end

        -- Validar Pausa o Mantenimiento
        if keyData.status == "paused" or (sysStatus and sysStatus.vip_paused and keyData.type == "VIP") then
            StatusLabel.Text = "⏸️ Sistema en Mantenimiento."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
            CheckBtn.Text = "INICIAR SESIÓN"
            isChecking = false
            return
        end

        local currentTime = os.time()

        --  ACTIVACIÓN POR HWID 
        if keyData.expires_at == 0 then
            local duration = keyData.duration_seconds or 0
            if duration > 0 then
                local newExpiration = currentTime + duration
                keyData.expires_at = newExpiration
                
                -- Guardar nueva fecha en Firebase
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

        --  Validar Expiración
        if currentTime > keyData.expires_at then
            StatusLabel.Text = "🔴 Tu llave ha expirado."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            CheckBtn.Text = "INICIAR SESIÓN"
            isChecking = false
            return
        end

        -- Validar Límite de HWID
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

        
        --  ACCESO CONCEDIDO
        
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
        
        -- Ejecuta tu script principal
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
    task.spawn(function()
        IniciarValidacion()
    end)
end)


function IniciarScriptPrincipal()
    




-- BULLET CONFLICT PREMIUM
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character
if not Character then
    LocalPlayer.CharacterAdded:Wait()
    Character = LocalPlayer.Character
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
end)

local Camera = workspace.CurrentCamera

-- FOV CIRCLE (GUI)
local fovGui = Instance.new("ScreenGui")
local fovFrame = Instance.new("Frame")
local fovCorner = Instance.new("UICorner")
local fovStroke = Instance.new("UIStroke")

fovGui.Name = "ChrissFov"
fovGui.ResetOnSpawn = false

pcall(function() fovGui.Parent = game:GetService("CoreGui") end)
if not fovGui.Parent then
    fovGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

fovFrame.Name = "FovCircle"
fovFrame.Parent = fovGui
fovFrame.BackgroundTransparency = 1
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0) 
fovFrame.Size = UDim2.fromOffset(200, 200)
fovFrame.Visible = false

fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovFrame

fovStroke.Parent = fovFrame
fovStroke.Thickness = 1.5
fovStroke.Color = Color3.fromRGB(255, 255, 255)

-- VARIABLES Y CONFIGURACIONES
local Config = {
    -- Cheats
    SpeedValue = 16, 
    SpeedEnabled = false, 
    InfJump = false, 
    Noclip = false, 
    Fly = false, 
    SpinBot = false,      
    SpinSpeed = 30,       
    HideName = false,     
    
    -- Combat
    AimbotEnabled = false,
    SilentAim = false,
    FOVEnabled = false, 
    FOVRadius = 100,
    WallCheck = true,
    TargetPart = "HumanoidRootPart",
    
    -- Visuals
    Fullbright = false,
    ESPBox = false, 
    ESPName = false, 
    ESPDist = false, 
    ESPHealth = false, 
    Traces = false,
    ESPGun = false, 
    ESPGunDist = false,
    
    -- Misc
    LockUI = false
}

-- TEMAS
local Theme = {
    Main = Color3.fromRGB(160, 80, 255), 
    Combat = Color3.fromRGB(160, 80, 255),
    Visuals = Color3.fromRGB(160, 80, 255),
    Misc = Color3.fromRGB(160, 80, 255)
}
 
-- UI DRAG
local function MakeSmoothDrag(frame, dragHandle)
    local dragging = false
    local dragInput, dragStart, startPos
    local targetPos = frame.Position

    dragHandle.InputBegan:Connect(function(input)
        if Config.LockUI then return end 

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if not Config.LockUI and dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and dragInput and not Config.LockUI then
            local delta = dragInput.Position - dragStart
            targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        frame.Position = frame.Position:Lerp(targetPos, 0.15)
    end)
end

-- MAIN GUI
local ScreenGui;
local success, err = pcall(function()
    ScreenGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui"):FindFirstChild("Modules") 
        and Instance.new("ScreenGui", game:GetService("CoreGui"):FindFirstChild("RobloxGui"))
        or Instance.new("ScreenGui", game:GetService("CoreGui"))
end)
if not success or not ScreenGui then
    ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
end
ScreenGui.Name = "ViceCityV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- VARIABLES DE ESTADO MENU
local Pages = {}
local TabButtons = {}
local isTweening = false
local ActivePage = "Main" -- Guarda la última pestaña abierta

-- MENU PRINCIPAL DISEÑO 
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 10, 0, 10) 
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -135)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 15, 18)
MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true 
MainFrame.Visible = false 
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Main
MainStroke.Thickness = 1.6
MainStroke.Transparency = 1 
MainStroke.Parent = MainFrame

-- TOP BAR
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 14)
TopCorner.Parent = TopBar

local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 12)
TopFix.Position = UDim2.new(0, 0, 1, -12)
TopFix.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
TopFix.BorderSizePixel = 0
TopFix.Parent = TopBar

-- TITULO ANIMADO (PREMIUM)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13.5
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.RichText = true
Title.Parent = TopBar

-- LOGICA TITULO MULTICOLOR
RunService.RenderStepped:Connect(function()
    local t = tick() * 3
    
    -- Efecto Dorado Brillante 
    local goldG = math.floor(215 + math.sin(t) * 40)
    local goldHex = string.format("#FF%02X00", goldG)
    
    -- Efecto Morado suave 
    local bcR = math.floor(160 + math.sin(t * 0.5) * 20)
    local bcG = math.floor(80 + math.sin(t * 0.5) * 20)
    local bcHex = string.format("#%02X%02XFF", bcR, bcG)

    Title.Text = string.format('<b><font color="%s">BULLET CONFLICT</font> <font color="%s">PREMIUM</font></b>', bcHex, goldHex)
end)

-- CLOSE BOTON
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 5)
CloseBtn.Text = "×" 
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 24
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Parent = TopBar

MakeSmoothDrag(MainFrame, TopBar)

-- TAB PANEL
local TabPanel = Instance.new("Frame")
TabPanel.Size = UDim2.new(0, 110, 1, -42)
TabPanel.Position = UDim2.new(0, 0, 0, 42)
TabPanel.BackgroundColor3 = Color3.fromRGB(17, 18, 22)
TabPanel.BorderSizePixel = 0
TabPanel.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 14)
TabCorner.Parent = TabPanel

local TabFixLeft = Instance.new("Frame")
TabFixLeft.Size = UDim2.new(1, 0, 0, 15)
TabFixLeft.Position = UDim2.new(0, 0, 0, 0)
TabFixLeft.BackgroundColor3 = Color3.fromRGB(17, 18, 22)
TabFixLeft.BorderSizePixel = 0
TabFixLeft.ZIndex = 2
TabFixLeft.Parent = TabPanel

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 4)
TabList.Parent = TabPanel

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 10)
TabPadding.Parent = TabPanel

local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -110, 1, -42)
PageContainer.Position = UDim2.new(0, 110, 0, 42)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

-- BOTON FLOTANTE
local OpenBtnFrame = Instance.new("Frame")
OpenBtnFrame.Name = "OpenBtnFrame"
OpenBtnFrame.Size = UDim2.new(0, 56, 0, 56) 
OpenBtnFrame.Position = UDim2.new(0.03, 0, 0.5, -28) 
OpenBtnFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
OpenBtnFrame.Visible = true -- ARRANCA VISIBLE
OpenBtnFrame.ClipsDescendants = true
OpenBtnFrame.Parent = ScreenGui

local OpenBtnCorner = Instance.new("UICorner")
OpenBtnCorner.CornerRadius = UDim.new(1, 0)
OpenBtnCorner.Parent = OpenBtnFrame

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Theme.Main
OpenStroke.Thickness = 1.8
OpenStroke.Parent = OpenBtnFrame

local OpenBtn = Instance.new("ImageButton")
OpenBtn.Name = "OpenButton"
OpenBtn.Size = UDim2.new(1, -6, 1, -6)
OpenBtn.Position = UDim2.new(0, 3, 0, 3)
OpenBtn.Image = "rbxassetid://122763495406604"
OpenBtn.BackgroundTransparency = 1
OpenBtn.AutoButtonColor = true
OpenBtn.Active = true
OpenBtn.Parent = OpenBtnFrame

local ImageCorner = Instance.new("UICorner")
ImageCorner.CornerRadius = UDim.new(1, 0)
ImageCorner.Parent = OpenBtn

MakeSmoothDrag(OpenBtnFrame, OpenBtn)

RunService.RenderStepped:Connect(function(dt)
    if OpenBtnFrame.Visible then
        OpenBtn.Rotation = OpenBtn.Rotation + (dt * 120)
    end
end)

-- LOGICA CERRAR MENU
CloseBtn.MouseButton1Click:Connect(function()
    if isTweening then return end
    isTweening = true
    
    local closeInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    
    local mainClose = TweenService:Create(MainFrame, closeInfo, {
        Size = UDim2.new(0, 430, 0, 250),
        BackgroundTransparency = 1
    })
    
    local strokeClose = TweenService:Create(MainStroke, closeInfo, {
        Transparency = 1
    })
    
    pcall(function()
        TweenService:Create(TopBar, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Title, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
        TweenService:Create(TabPanel, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        
        
        for _, btn in pairs(TabButtons) do
            TweenService:Create(btn, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
        end
    end)
    
    mainClose:Play()
    strokeClose:Play()
    
    mainClose.Completed:Connect(function()
        MainFrame.Visible = false
        for _, p in pairs(Pages) do p.Visible = false end -- Apagamos para resetear estado visual
        
        OpenBtnFrame.Visible = true
        OpenBtnFrame.Size = UDim2.new(0, 56, 0, 56)
        OpenBtn.Size = UDim2.new(0, 0, 0, 0)
        
        local openAnim = TweenService:Create(OpenBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -6, 1, -6)
        })
        openAnim:Play()
        openAnim.Completed:Connect(function() isTweening = false end)
    end)
end)

-- LOGICA ABRIR MENU
OpenBtn.MouseButton1Click:Connect(function()
    if isTweening then return end
    isTweening = true
    
    local hideTween = TweenService:Create(OpenBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    hideTween:Play()
    
    hideTween.Completed:Connect(function()
        OpenBtnFrame.Visible = false
        
        MainFrame.BackgroundTransparency = 0
        MainStroke.Transparency = 0
        pcall(function()
            TopBar.BackgroundTransparency = 0
            Title.TextTransparency = 0
            CloseBtn.TextTransparency = 0
            TabPanel.BackgroundTransparency = 0
            for _, btn in pairs(TabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.1), {TextTransparency = 0}):Play()
            end
        end)
        
    
        if Pages[ActivePage] then
            Pages[ActivePage].Visible = true
        end
        
        MainFrame.Size = UDim2.new(0, 10, 0, 10) 
        MainFrame.BackgroundTransparency = 1
        MainStroke.Transparency = 1
        MainFrame.Visible = true
        
        local openInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        
        local mainOpen = TweenService:Create(MainFrame, openInfo, {
            Size = UDim2.new(0, 460, 0, 270),
            BackgroundTransparency = 0
        })
        
        local strokeOpen = TweenService:Create(MainStroke, openInfo, {
            Transparency = 0
        })
        
        mainOpen:Play()
        strokeOpen:Play()
        mainOpen.Completed:Connect(function() isTweening = false end)
    end)
end)

-- UI TABS
local function CreateTab(name, sectionColor)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.Text = name:upper()
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 11
    TabBtn.TextColor3 = Color3.fromRGB(100, 105, 115)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Parent = TabPanel

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = sectionColor
    Page.Parent = PageContainer

    local PageList = Instance.new("UIListLayout")
    PageList.Padding = UDim.new(0, 6)
    PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    PageList.Parent = Page

    local PagePad = Instance.new("UIPadding")
    PagePad.PaddingTop = UDim.new(0, 10)
    PagePad.PaddingBottom = UDim.new(0, 10)
    PagePad.Parent = Page
    
    PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        ActivePage = name -- Guarda tu posición actual
        for n, p in pairs(Pages) do p.Visible = false end
        for btnName, btnObj in pairs(TabButtons) do 
            TweenService:Create(btnObj, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(100, 105, 115)}):Play()
        end
        Page.Visible = true
        TweenService:Create(MainStroke, TweenInfo.new(0.25), {Color = sectionColor}):Play()
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = sectionColor}):Play()
    end)

    Pages[name] = Page
    TabButtons[name] = TabBtn
    return Page
end

-- UI TOGGLE
local function AddToggle(page, text, configKey, sectionColor)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(0.92, 0, 0, 38)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = page

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 6)
    tc.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12.5
    Label.TextColor3 = Color3.fromRGB(220, 225, 235)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = ToggleFrame

    local OuterSwitch = Instance.new("TextButton")
    OuterSwitch.Size = UDim2.new(0, 38, 0, 20)
    OuterSwitch.Position = UDim2.new(1, -50, 0.5, -10)
    OuterSwitch.BackgroundColor3 = Config[configKey] and sectionColor or Color3.fromRGB(45, 48, 58)
    OuterSwitch.Text = ""
    OuterSwitch.Parent = ToggleFrame
    
    local osc = Instance.new("UICorner")
    osc.CornerRadius = UDim.new(1, 0)
    osc.Parent = OuterSwitch

    local InnerCircle = Instance.new("Frame")
    InnerCircle.Size = UDim2.new(0, 14, 0, 14)
    InnerCircle.Position = Config[configKey] and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    InnerCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InnerCircle.BorderSizePixel = 0
    InnerCircle.Parent = OuterSwitch

    local icc = Instance.new("UICorner")
    icc.CornerRadius = UDim.new(1, 0)
    icc.Parent = InnerCircle

    OuterSwitch.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        TweenService:Create(OuterSwitch, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Config[configKey] and sectionColor or Color3.fromRGB(45, 48, 58)}):Play()
        TweenService:Create(InnerCircle, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Position = Config[configKey] and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
    end)
end

-- UI SLIDER
local function AddSlider(page, text, min, max, default, configKey, sectionColor)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0.92, 0, 0, 48)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = page
    
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 6)
    sc.Parent = SliderFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 22)
    Label.Position = UDim2.new(0, 12, 0, 4)
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextColor3 = Color3.fromRGB(220, 225, 235)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = SliderFrame

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0.3, 0, 0, 22)
    ValLabel.Position = UDim2.new(1, -48, 0, 4)
    ValLabel.Text = tostring(default)
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.TextSize = 12
    ValLabel.TextColor3 = sectionColor
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.BackgroundTransparency = 1
    ValLabel.Parent = SliderFrame

    local SlideBar = Instance.new("TextButton")
    SlideBar.Size = UDim2.new(1, -24, 0, 5)
    SlideBar.Position = UDim2.new(0, 12, 0.72, -2)
    SlideBar.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
    SlideBar.Text = ""
    SlideBar.Parent = SliderFrame
    
    local sbc = Instance.new("UICorner")
    sbc.CornerRadius = UDim.new(1, 0)
    sbc.Parent = SlideBar

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = sectionColor
    Fill.BorderSizePixel = 0
    Fill.Parent = SlideBar
    
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = Fill

    local function UpdateSlider(input)
        local percentage = math.clamp((input.Position.X - SlideBar.AbsolutePosition.X) / SlideBar.AbsoluteSize.X, 0, 1)
        TweenService:Create(Fill, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
        local value = math.floor(min + (percentage * (max - min)))
        ValLabel.Text = tostring(value)
        Config[configKey] = value
    end

    local sliding = false
    SlideBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            UpdateSlider(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
end

-- UI BUTTON
local function AddButton(page, text, sectionColor)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.92, 0, 0, 36)
    Button.BackgroundColor3 = Color3.fromRGB(24, 27, 34)
    Button.Text = text
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.TextColor3 = sectionColor
    Button.Parent = page
    
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = Button
    
    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(34, 38, 48)}):Play()
        end
    end)
    Button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(24, 27, 34)}):Play()
        end
    end)
return Button
end


-- CREACION CATEGORIAS
local TabMain = CreateTab("Main", Theme.Main)
local TabCheats = CreateTab("Player Cheats", Theme.Main) 
local TabCombat = CreateTab("Combat", Theme.Combat)
local TabVisuals = CreateTab("Visuals", Theme.Visuals)
local TabMisc = CreateTab("Misc", Theme.Misc)

-- SELECCIONAR MAIN POR DEFECTO PARA EL INICIO (PERO OCULTO)
if TabButtons["Main"] then TabButtons["Main"].TextColor3 = Theme.Main end

-- MAIN PERFIL
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local ProfileCard = Instance.new("Frame")
ProfileCard.Size = UDim2.new(0.94, 0, 0, 70)
ProfileCard.BackgroundColor3 = Color3.fromRGB(18, 20, 24)
ProfileCard.BorderSizePixel = 0
ProfileCard.Parent = TabMain

local pc_corner = Instance.new("UICorner")
pc_corner.CornerRadius = UDim.new(0, 10)
pc_corner.Parent = ProfileCard

local pc_stroke = Instance.new("UIStroke")
pc_stroke.Color = Color3.fromRGB(45, 50, 62)
pc_stroke.Thickness = 1.2
pc_stroke.Parent = ProfileCard

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Size = UDim2.new(0, 48, 0, 48)
AvatarImage.Position = UDim2.new(0, 12, 0, 11)
AvatarImage.BackgroundColor3 = Color3.fromRGB(28, 31, 38)
AvatarImage.Parent = ProfileCard

local avatar_corner = Instance.new("UICorner")
avatar_corner.CornerRadius = UDim.new(1, 0)
avatar_corner.Parent = AvatarImage

task.spawn(function()
    local content, isReady = Players:GetUserThumbnailAsync(
        LocalPlayer.UserId, 
        Enum.ThumbnailType.HeadShot, 
        Enum.ThumbnailSize.Size100x100
    )
    if isReady then AvatarImage.Image = content end
end)

local UserNameLabel = Instance.new("TextLabel")
UserNameLabel.Size = UDim2.new(1, -75, 0, 20)
UserNameLabel.Position = UDim2.new(0, 68, 0, 15)
UserNameLabel.Text = "@" .. LocalPlayer.Name
UserNameLabel.Font = Enum.Font.GothamBold
UserNameLabel.TextSize = 13
UserNameLabel.TextColor3 = Theme.Main
UserNameLabel.TextXAlignment = Enum.TextXAlignment.Left
UserNameLabel.BackgroundTransparency = 1
UserNameLabel.Parent = ProfileCard

local AccountAgeLabel = Instance.new("TextLabel")
AccountAgeLabel.Size = UDim2.new(1, -75, 0, 18)
AccountAgeLabel.Position = UDim2.new(0, 68, 0, 35)
AccountAgeLabel.Text = "📅 Cuenta: " .. tostring(LocalPlayer.AccountAge) .. " días"
AccountAgeLabel.Font = Enum.Font.Gotham
AccountAgeLabel.TextSize = 11
AccountAgeLabel.TextColor3 = Color3.fromRGB(170, 175, 185)
AccountAgeLabel.TextXAlignment = Enum.TextXAlignment.Left
AccountAgeLabel.BackgroundTransparency = 1
AccountAgeLabel.Parent = ProfileCard

-- MAIN RENDIMIENTO
local PerfCard = Instance.new("Frame")
PerfCard.Size = UDim2.new(0.94, 0, 0, 60)
PerfCard.BackgroundColor3 = Color3.fromRGB(18, 20, 24)
PerfCard.BorderSizePixel = 0
PerfCard.Parent = TabMain

local perf_corner = Instance.new("UICorner")
perf_corner.CornerRadius = UDim.new(0, 10)
perf_corner.Parent = PerfCard

local perf_stroke = Instance.new("UIStroke")
perf_stroke.Color = Color3.fromRGB(45, 50, 62)
perf_stroke.Thickness = 1.2
perf_stroke.Parent = PerfCard

local PerfTitle = Instance.new("TextLabel")
PerfTitle.Size = UDim2.new(1, -20, 0, 18)
PerfTitle.Position = UDim2.new(0, 12, 0, 8)
PerfTitle.Text = "ESTADO Y RENDIMIENTO ⚡"
PerfTitle.Font = Enum.Font.GothamBold
PerfTitle.TextSize = 11
PerfTitle.TextColor3 = Color3.fromRGB(220, 225, 235)
PerfTitle.TextXAlignment = Enum.TextXAlignment.Left
PerfTitle.BackgroundTransparency = 1
PerfTitle.Parent = PerfCard

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -20, 0, 22)
StatsLabel.Position = UDim2.new(0, 12, 0, 28)
StatsLabel.Text = "FPS: -- | Ping: -- ms | Status: 🟢 ACTIVO"
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.TextSize = 11
StatsLabel.TextColor3 = Color3.fromRGB(50, 255, 140)
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.BackgroundTransparency = 1
StatsLabel.Parent = PerfCard

local lastUpdate = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    if tick() - lastUpdate >= 1 then
        local fps = frameCount
        frameCount = 0
        lastUpdate = tick()
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        StatsLabel.Text = "FPS: " .. tostring(fps) .. "  |  Ping: " .. tostring(ping) .. "ms  |  Status: 🟢 ACTIVO"
    end
end)

-- MAIN SOCIALES
local SocialCard = Instance.new("Frame")
SocialCard.Size = UDim2.new(0.94, 0, 0, 110)
SocialCard.BackgroundColor3 = Color3.fromRGB(18, 20, 24)
SocialCard.BorderSizePixel = 0
SocialCard.Parent = TabMain

local sc_corner = Instance.new("UICorner")
sc_corner.CornerRadius = UDim.new(0, 10)
sc_corner.Parent = SocialCard

local sc_stroke = Instance.new("UIStroke")
sc_stroke.Color = Color3.fromRGB(45, 50, 62)
sc_stroke.Thickness = 1.2
sc_stroke.Parent = SocialCard

local SocialTitle = Instance.new("TextLabel")
SocialTitle.Size = UDim2.new(1, -20, 0, 20)
SocialTitle.Position = UDim2.new(0, 12, 0, 8)
SocialTitle.Text = "REDES OFICIALES 🌐"
SocialTitle.Font = Enum.Font.GothamBold
SocialTitle.TextSize = 11
SocialTitle.TextColor3 = Color3.fromRGB(220, 225, 235)
SocialTitle.TextXAlignment = Enum.TextXAlignment.Left
SocialTitle.BackgroundTransparency = 1
SocialTitle.Parent = SocialCard

local WhatsAppBtn = Instance.new("TextButton")
WhatsAppBtn.Size = UDim2.new(1, -24, 0, 32)
WhatsAppBtn.Position = UDim2.new(0, 12, 0, 32)
WhatsAppBtn.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
WhatsAppBtn.Text = "📲 CANAL DE WHATSAPP (COPIAR)"
WhatsAppBtn.Font = Enum.Font.GothamBold
WhatsAppBtn.TextSize = 10.5
WhatsAppBtn.TextColor3 = Theme.Main
WhatsAppBtn.Parent = SocialCard

local wbc = Instance.new("UICorner")
wbc.CornerRadius = UDim.new(0, 6)
wbc.Parent = WhatsAppBtn

WhatsAppBtn.MouseButton1Click:Connect(function()
    setclipboard("https://whatsapp.com/channel/0029VbC12x4GufIzNYfrPh3R")
    WhatsAppBtn.Text = "¡LINK COPIADO! ✅"
    task.wait(2)
    WhatsAppBtn.Text = "📲 CANAL DE WHATSAPP (COPIAR)"
end)

local TikTokBtn = Instance.new("TextButton")
TikTokBtn.Size = UDim2.new(1, -24, 0, 32)
TikTokBtn.Position = UDim2.new(0, 12, 0, 68)
TikTokBtn.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
TikTokBtn.Text = "🎵 TIKTOK OFICIAL (COPIAR)"
TikTokBtn.Font = Enum.Font.GothamBold
TikTokBtn.TextSize = 10.5
TikTokBtn.TextColor3 = Theme.Main
TikTokBtn.Parent = SocialCard

local tkc = Instance.new("UICorner")
tkc.CornerRadius = UDim.new(0, 6)
tkc.Parent = TikTokBtn

TikTokBtn.MouseButton1Click:Connect(function()
    setclipboard("softworks32")
    TikTokBtn.Text = "¡USUARIO COPIADO! ✅"
    task.wait(2)
    TikTokBtn.Text = "🎵 TIKTOK OFICIAL (COPIAR)"
end)

-- MAIN NOVEDADES
local NewsCard = Instance.new("Frame")
NewsCard.Size = UDim2.new(0.94, 0, 0, 75)
NewsCard.BackgroundColor3 = Color3.fromRGB(18, 20, 24)
NewsCard.BorderSizePixel = 0
NewsCard.Parent = TabMain

local news_corner = Instance.new("UICorner")
news_corner.CornerRadius = UDim.new(0, 10)
news_corner.Parent = NewsCard

local news_stroke = Instance.new("UIStroke")
news_stroke.Color = Color3.fromRGB(45, 50, 62)
news_stroke.Thickness = 1.2
news_stroke.Parent = NewsCard

local NewsTitle = Instance.new("TextLabel")
NewsTitle.Size = UDim2.new(1, -20, 0, 18)
NewsTitle.Position = UDim2.new(0, 12, 0, 8)
NewsTitle.Text = "NOVEDADES V1.3 📢"
NewsTitle.Font = Enum.Font.GothamBold
NewsTitle.TextSize = 11
NewsTitle.TextColor3 = Color3.fromRGB(220, 225, 235)
NewsTitle.TextXAlignment = Enum.TextXAlignment.Left
NewsTitle.BackgroundTransparency = 1
NewsTitle.Parent = NewsCard

local NewsBody = Instance.new("TextLabel")
NewsBody.Size = UDim2.new(1, -24, 0, 42)
NewsBody.Position = UDim2.new(0, 12, 0, 28)
NewsBody.Text = "• SIN NOVEDADES\n• ERROR\n• ERROR"
NewsBody.Font = Enum.Font.Gotham
NewsBody.TextSize = 10
NewsBody.TextColor3 = Color3.fromRGB(160, 165, 175)
NewsBody.TextXAlignment = Enum.TextXAlignment.Left
NewsBody.TextYAlignment = Enum.TextYAlignment.Top
NewsBody.BackgroundTransparency = 1
NewsBody.Parent = NewsCard

-- FUNCIONES CHEATS
AddToggle(TabCheats, "Speed Hack", "SpeedEnabled", Theme.Main)
AddSlider(TabCheats, "Speed Power", 16, 300, 16, "SpeedValue", Theme.Main)
AddToggle(TabCheats, "Infinity Jump", "InfJump", Theme.Main)
AddToggle(TabCheats, "Noclip", "Noclip", Theme.Main)
AddToggle(TabCheats, "Fly (Vuelo)", "Fly", Theme.Main)
AddToggle(TabCheats, "Hide Name 👤", "HideName", Theme.Main)
AddToggle(TabCheats, "Spin Bot 🌀", "SpinBot", Theme.Main)
AddSlider(TabCheats, "Spin Speed", 10, 150, 30, "SpinSpeed", Theme.Main)

AddToggle(TabCombat, "Aimbot", "AimbotEnabled", Theme.Combat)
AddSlider(TabCombat, "FOV Radio", 30, 300, 100, "FOVRadius", Theme.Combat)
AddToggle(TabCombat, "Show FOV Anillo", "FOVEnabled", Theme.Combat)
AddToggle(TabCombat, "Silent Aim", "SilentAim", Theme.Combat)


-- LOGICA WALL CHECK
local function VerificarParedVisibilidad(objetivoParte)
    if not Config.WallCheck then return true end 
    
    local origen = Camera.CFrame.Position
    local destino = objetivoParte.Position
    local raycastParams = RaycastParams.new()
    
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, objetivoParte.Parent}

    local resultado = workspace:Raycast(origen, destino - origen, raycastParams)
    return resultado == nil 
end

-- LOGICA AIMBOT 
local function ObtenerEnemigoMasCercano()
    local objetivoCercano = nil
    local distanciaMinima = Config.FOVRadius
    local centroPantalla = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, jugador in ipairs(Players:GetPlayers()) do
        if jugador ~= LocalPlayer and jugador.Character and jugador.Character:FindFirstChild("Humanoid") and jugador.Character.Humanoid.Health > 0 then
            
            local parteObjetivo = jugador.Character:FindFirstChild(Config.TargetPart) or jugador.Character:FindFirstChild("Head")
            
            if parteObjetivo then
                local vector2, enPantalla = Camera:WorldToViewportPoint(parteObjetivo.Position)
                
                if enPantalla then
                    local distancia = (Vector2.new(vector2.X, vector2.Y) - centroPantalla).Magnitude
                    
                    if distancia < distanciaMinima and VerificarParedVisibilidad(parteObjetivo) then
                        distanciaMinima = distancia
                        objetivoCercano = parteObjetivo
                    end
                end
            end
        end
    end
    
    return objetivoCercano
end

-- LOGICA FOV & AIMBOT MAIN
RunService.RenderStepped:Connect(function()
    if not Camera or not workspace.CurrentCamera then
        Camera = workspace.CurrentCamera
        return
    end
    
    --NEW FOV🔥
    if Config.FOVEnabled then
        fovFrame.Visible = true
        fovFrame.Size = UDim2.fromOffset(Config.FOVRadius * 2, Config.FOVRadius * 2)
    else
        fovFrame.Visible = false
    end
    
    if Config.AimbotEnabled or Config.FOVEnabled then
        local objetivo = ObtenerEnemigoMasCercano()
        
        if objetivo then
            fovStroke.Color = Color3.fromRGB(0, 255, 0) -- VERDE CUANDO DETECTA A ALGUIEN
            
            if Config.AimbotEnabled then
                local currentPos = Camera.CFrame.Position
                local targetCFrame = CFrame.new(currentPos, objetivo.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1.0)
            end
        else
            fovStroke.Color = Color3.fromRGB(255, 0, 0) -- ROJO CUANDO NO HAY NADIE CERCA
        end
    end
end)


-- VISUALS Y MISC TABS
AddToggle(TabVisuals, "Fullbright ", "Fullbright", Theme.Visuals)
AddToggle(TabVisuals, "ESP Box", "ESPBox", Theme.Visuals)
AddToggle(TabVisuals, "ESP Name", "ESPName", Theme.Visuals)
AddToggle(TabVisuals, "ESP Distancia", "ESPDist", Theme.Visuals)
AddToggle(TabVisuals, "ESP Health", "ESPHealth", Theme.Visuals)
AddToggle(TabVisuals, "Traces", "Traces", Theme.Visuals)
AddToggle(TabVisuals, "ESP Gun", "ESPGun", Theme.Visuals)
AddToggle(TabVisuals, "ESP Gun Distancia", "ESPGunDist", Theme.Visuals)

local BtnServerHop = AddButton(TabMisc, "Server Hop 🌐", Theme.Misc)
local BtnRejoin = AddButton(TabMisc, "Rejoin Server 🔄", Theme.Misc)
AddToggle(TabMisc, "Bloquear Menú🌪️", "LockUI", Theme.Misc)

-- LOGICA SERVER HOP
BtnServerHop.MouseButton1Click:Connect(function()
    BtnServerHop.Text = "Buscando servidor... 🔍"
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local PlaceId = game.PlaceId
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        local targetServer
        for _, server in ipairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                targetServer = server.id
                break
            end
        end
        
        if targetServer then
            TeleportService:TeleportToPlaceInstance(PlaceId, targetServer, LocalPlayer)
        else
            BtnServerHop.Text = "No hay otros servers ❌"
            task.wait(2)
            BtnServerHop.Text = "Server Hop 🌐"
        end
    else
        BtnServerHop.Text = "Error al buscar ❌"
        task.wait(2)
        BtnServerHop.Text = "Server Hop 🌐"
    end
end)

-- LOGICA REJOIN
BtnRejoin.MouseButton1Click:Connect(function()
    BtnRejoin.Text = "Reconectando... 🔄"
    local TeleportService = game:GetService("TeleportService")
    
    if #Players:GetPlayers() <= 1 then
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
end)



--  SISTEMA ESP
local WeaponColors = {
    -- DORADO 
    ["AK47"] = Color3.fromRGB(255, 215, 0),
    ["AK47-Cosmetic"] = Color3.fromRGB(255, 215, 0),
    ["AK47-لا تستخدم"] = Color3.fromRGB(255, 215, 0),
    ["M16"] = Color3.fromRGB(255, 215, 0),
    ["MP5"] = Color3.fromRGB(255, 215, 0),
    ["Remington"] = Color3.fromRGB(255, 215, 0),
    ["RPG"] = Color3.fromRGB(255, 215, 0),
    ["RPGPermanent"] = Color3.fromRGB(255, 215, 0),
    ["RPG-ریموٹ فونکشن اصلی"] = Color3.fromRGB(255, 215, 0),
    ["Tactical Axe"] = Color3.fromRGB(255, 215, 0),
    ["RightGrip"] = Color3.fromRGB(255, 215, 0),

    -- ROJO
    ["Anaconda"] = Color3.fromRGB(200, 0, 0),
    ["M249"] = Color3.fromRGB(255, 0, 0),

    --  VERDE
    ["G3"] = Color3.fromRGB(46, 204, 113),

    -- AZUL CLARO 
    ["Glock"] = Color3.fromRGB(52, 152, 219),
    ["P226"] = Color3.fromRGB(52, 152, 219),

    --  AZUL FUERTE 
    ["Uzi"] = Color3.fromRGB(0, 70, 255),
    ["LongMagGlock"] = Color3.fromRGB(0, 70, 255),

    -- PÚRPURA
    ["Draco"] = Color3.fromRGB(160, 32, 240),
    ["Double Barrel"] = Color3.fromRGB(160, 32, 240),
    ["EnergyShot"] = Color3.fromRGB(160, 32, 240),
    ["Barbed Baseball Bat"] = Color3.fromRGB(160, 32, 240),
    ["Combat Axe"] = Color3.fromRGB(160, 32, 240),
    ["sledgehammer"] = Color3.fromRGB(160, 32, 240),

    --  TRAPEADORES ESPECIALES
    ["Mop"] = Color3.fromRGB(128, 128, 128),
    ["SilverMop"] = Color3.fromRGB(192, 192, 192),
    ["GoldMop"] = Color3.fromRGB(255, 215, 0),
    ["DiamondMop"] = Color3.fromRGB(0, 235, 255),
    ["SapphireMop"] = Color3.fromRGB(15, 82, 186),
    ["EmeraldMop"] = Color3.fromRGB(80, 220, 100),

    --  HERRAMIENTAS DE PESCA (VERDE BAJO)
    ["FishingRod"] = Color3.fromRGB(144, 238, 144), 
    ["FishingRodPro"] = Color3.fromRGB(144, 238, 144),
    ["FishingRodUltimate"] = Color3.fromRGB(144, 238, 144), 
    ["WormtecRegular"] = Color3.fromRGB(144, 238, 144), 
    ["WormtecUltimate"] = Color3.fromRGB(144, 238, 144) 
    }

local function GetPlayerTool(player)
    if player.Character then
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool then return tool end
    end
    if player:FindFirstChild("Backpack") then
        local tool = player.Backpack:FindFirstChildOfClass("Tool")
        if tool then return tool end
    end
    return nil
end

-- CONTENEDOR GUI SEGURO
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "BulletConflictESP"
ESPGui.IgnoreGuiInset = true
ESPGui.ResetOnSpawn = false
local success = pcall(function() ESPGui.Parent = game:GetService("CoreGui") end)
if not success then ESPGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- TABLA CACHÉ PARA EVITAR DUPLICADOS Y MEMORY LEAKs
local espCache = {}

local function CreateUIElement(class, properties)
    local element = Instance.new(class)
    for k, v in pairs(properties) do element[k] = v end
    return element
end

local function AddESP(player)
    if player == LocalPlayer or espCache[player] then return end

    local cache = {}
    espCache[player] = cache

    -- HIGHLIGHT 
    cache.Highlight = CreateUIElement("Highlight", {
        FillTransparency = 0.5, 
        FillColor = Color3.fromRGB(255, 50, 50),
        OutlineColor = Color3.fromRGB(255, 0, 0),
        OutlineTransparency = 0,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        Parent = ESPGui, 
        Enabled = false
    })

    -- ESP BOX 
    cache.Box = CreateUIElement("Frame", {
        BackgroundTransparency = 1,
        Visible = false,
        Parent = ESPGui
    })
    local boxStroke = Instance.new("UIStroke", cache.Box)
    boxStroke.Color = Color3.fromRGB(255, 0, 0)
    boxStroke.Thickness = 1.5

    -- TEXTOS
    cache.NameText = CreateUIElement("TextLabel", {
        BackgroundTransparency = 1, Visible = false, Font = Enum.Font.GothamBold,
        TextSize = 12, TextColor3 = Color3.fromRGB(255, 255, 255),
        Parent = ESPGui
    })
    Instance.new("UIStroke", cache.NameText).Thickness = 1.2

    cache.DistText = CreateUIElement("TextLabel", {
        BackgroundTransparency = 1, Visible = false, Font = Enum.Font.Gotham,
        TextSize = 11, TextColor3 = Color3.fromRGB(220, 220, 220),
        Parent = ESPGui
    })
    Instance.new("UIStroke", cache.DistText).Thickness = 1.2

    cache.GunText = CreateUIElement("TextLabel", {
        BackgroundTransparency = 1, Visible = false, Font = Enum.Font.Gotham,
        TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255),
        Parent = ESPGui
    })
    Instance.new("UIStroke", cache.GunText).Thickness = 1.2

    -- HEALTH BAR
    cache.HealthBg = CreateUIElement("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0,
        Visible = false, Parent = ESPGui
    })
    cache.HealthFill = CreateUIElement("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 255, 0), BorderSizePixel = 0,
        Visible = false, Parent = cache.HealthBg
    })

    -- TRACE (LÍNEA CON FRAME)
    cache.Trace = CreateUIElement("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 0, 0), BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5), Visible = false, Parent = ESPGui
    })
end

local function RemoveESP(player)
    if espCache[player] then
        for _, element in pairs(espCache[player]) do
            if element then element:Destroy() end
        end
        espCache[player] = nil
    end
end

-- EVENTOS DE JUGADORES
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in pairs(Players:GetPlayers()) do
    AddESP(p)
end

-- MOTOR ÚNICO DE RENDERIZADO (NO MÁS BUCLES MÚLTIPLES)
RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    if not camera then return end

    -- EL PUNTO DE ORIGEN PARA LAS LÍNEAS (ABAJO EN EL CENTRO)
    local screenBottomCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)

    for player, cache in pairs(espCache) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")

        -- SI ESTÁ MUERTO O FUERA, APAGAMOS TODO
        if not character or not humanoid or humanoid.Health <= 0 or not rootPart or not head then
            cache.Highlight.Enabled = false
            cache.Highlight.Adornee = nil
            cache.Box.Visible = false
            cache.NameText.Visible = false
            cache.DistText.Visible = false
            cache.GunText.Visible = false
            cache.HealthBg.Visible = false
            cache.Trace.Visible = false
            continue
        end

        local rootPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)

        if onScreen then
            local distance = (camera.CFrame.Position - rootPart.Position).Magnitude
            local topPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.8, 0))
            local bottomPos = camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 2.5, 0))

            local boxHeight = math.abs(topPos.Y - bottomPos.Y)
            local boxWidth = boxHeight * 0.55

            --  HIGHLIGHT
            cache.Highlight.Adornee = character
            cache.Highlight.Enabled = Config.ESPBox

            --  ESP BOX R
            if Config.ESPBox then
                cache.Box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
                cache.Box.Position = UDim2.new(0, rootPos.X - (boxWidth / 2), 0, topPos.Y)
                cache.Box.Visible = true
            else
                cache.Box.Visible = false
            end

            -- ESP NOMBRES
            if Config.ESPName then
                cache.NameText.Text = player.Name
                cache.NameText.Size = UDim2.new(0, boxWidth, 0, 15)
                cache.NameText.Position = UDim2.new(0, rootPos.X - (boxWidth / 2), 0, topPos.Y - 18)
                cache.NameText.Visible = true
            else
                cache.NameText.Visible = false
            end

            --  ESP DISTANCIA
            local yOffset = bottomPos.Y + 4
            if Config.ESPDist then
                cache.DistText.Text = string.format("[%d studs]", math.floor(distance))
                cache.DistText.Size = UDim2.new(0, boxWidth, 0, 15)
                cache.DistText.Position = UDim2.new(0, rootPos.X - (boxWidth / 2), 0, yOffset)
                cache.DistText.Visible = true
                yOffset = yOffset + 14
            else
                cache.DistText.Visible = false
            end

            -- ESP ARMAS
            if Config.ESPGun then
                local tool = GetPlayerTool(player)
                if tool then
                    local wName = tool.Name
                    cache.GunText.Text = Config.ESPGunDist and string.format("%s [%d studs]", wName, math.floor(distance)) or wName
                    cache.GunText.TextColor3 = WeaponColors[wName] or Color3.fromRGB(255, 255, 255)
                    cache.GunText.Size = UDim2.new(0, boxWidth, 0, 15)
                    cache.GunText.Position = UDim2.new(0, rootPos.X - (boxWidth / 2), 0, yOffset)
                    cache.GunText.Visible = true
                else
                    cache.GunText.Visible = false
                end
            else
                cache.GunText.Visible = false
            end

            -- ESP HEALTH BAR
            if Config.ESPHealth then
                local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                local barHeight = boxHeight
                cache.HealthBg.Size = UDim2.new(0, 3, 0, barHeight)
                cache.HealthBg.Position = UDim2.new(0, rootPos.X - (boxWidth / 2) - 6, 0, topPos.Y)
                
                cache.HealthFill.Size = UDim2.new(1, 0, hpPercent, 0)
                cache.HealthFill.Position = UDim2.new(0, 0, 1 - hpPercent, 0)
                cache.HealthFill.BackgroundColor3 = Color3.fromHSV((hpPercent * 120) / 360, 1, 1)
                
                cache.HealthBg.Visible = true
                cache.HealthFill.Visible = true
            else
                cache.HealthBg.Visible = false
            end

            -- TRACES (
            if Config.Traces then
                local targetPos = Vector2.new(rootPos.X, bottomPos.Y)
                local dist = (targetPos - screenBottomCenter).Magnitude
                
                cache.Trace.Size = UDim2.new(0, dist, 0, 1)
                cache.Trace.Position = UDim2.new(0, (screenBottomCenter.X + targetPos.X) / 2, 0, (screenBottomCenter.Y + targetPos.Y) / 2)
                cache.Trace.Rotation = math.deg(math.atan2(targetPos.Y - screenBottomCenter.Y, targetPos.X - screenBottomCenter.X))
                cache.Trace.Visible = true
            else
                cache.Trace.Visible = false
            end
        else
            cache.Highlight.Enabled = false
            cache.Box.Visible = false
            cache.NameText.Visible = false
            cache.DistText.Visible = false
            cache.GunText.Visible = false
            cache.HealthBg.Visible = false
            cache.Trace.Visible = false
        end
    end
end)
    
    

        
    

    
                            
                

                
-- LOGICA BYPASS
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
end)

task.spawn(function()
    while task.wait(0.1) do
        if Character and Humanoid and RootPart then
            if Config.Fly or Config.SpeedEnabled then
                Humanoid:ChangeState(Enum.HumanoidStateType.Running)
                
                local velocity = RootPart.AssemblyLinearVelocity
                if velocity.Magnitude > 350 then
                    RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
end)

-- LOGICA SPEED HACK
RunService.Heartbeat:Connect(function()
    if Character and Humanoid and RootPart and Config.SpeedEnabled then
        local MoveDirection = Humanoid.MoveDirection
        if MoveDirection.Magnitude > 0 then
            local speed = math.clamp(Config.SpeedValue, 60, 100)
            RootPart.CFrame = RootPart.CFrame + (MoveDirection * (speed / 100))
        end
    end
end)

-- LOGICA FLY (VUELO)
local FlyAttachment, AlignOri, LinearVel

RunService.RenderStepped:Connect(function()
    if Config.Fly and Character and RootPart and Humanoid then
        if not FlyAttachment or not FlyAttachment.Parent then
            FlyAttachment = Instance.new("Attachment")
            FlyAttachment.Name = "EnforceFlyAttachment"
            FlyAttachment.Parent = RootPart
            
            AlignOri = Instance.new("AlignOrientation")
            AlignOri.Name = "EnforceFlyAlign"
            AlignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
            AlignOri.Attachment0 = FlyAttachment
            AlignOri.MaxTorque = 9e9
            AlignOri.Responsiveness = 200 
            AlignOri.Parent = RootPart
            
            LinearVel = Instance.new("LinearVelocity")
            LinearVel.Name = "EnforceFlyVelocity"
            LinearVel.Attachment0 = FlyAttachment
            LinearVel.MaxForce = 9e9
            LinearVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
            LinearVel.Parent = RootPart
        end
        
        local camera = workspace.CurrentCamera
        AlignOri.CFrame = camera.CFrame
        
        local moveDirection = Humanoid.MoveDirection
        if moveDirection.Magnitude > 0 then
            local lookVector = camera.CFrame.LookVector
            local targetVelocity = moveDirection * 50 
            
            if lookVector.Y > 0.2 or lookVector.Y < -0.2 then
                targetVelocity = targetVelocity + Vector3.new(0, lookVector.Y * 40, 0)
            end
            
            LinearVel.VectorVelocity = targetVelocity
        else
            LinearVel.VectorVelocity = Vector3.new(0, 0, 0)
        end
    else
        if RootPart:FindFirstChild("EnforceFlyAttachment") then RootPart.EnforceFlyAttachment:Destroy() end
        if RootPart:FindFirstChild("EnforceFlyAlign") then RootPart.EnforceFlyAlign:Destroy() end
        if RootPart:FindFirstChild("EnforceFlyVelocity") then RootPart.EnforceFlyVelocity:Destroy() end
        FlyAttachment, AlignOri, LinearVel = nil, nil, nil
    end
end)

-- LOGICA NOCLIP
RunService.Stepped:Connect(function()
    if Config.Noclip and Character then
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- LOGICA INF JUMP
UserInputService.JumpRequest:Connect(function()
    if Config.InfJump and Character and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- LOGICA SPIN BOT Y HIDE NAME
RunService.RenderStepped:Connect(function()
    
    if Config.SpinBot and Character and Character:FindFirstChild("HumanoidRootPart") then
        local root = Character.HumanoidRootPart
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Config.SpinSpeed), 0)
    end

    if Character then
        local hum = Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if Config.HideName then
                hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            else
                hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            end
        end

        for _, obj in pairs(Character:GetDescendants()) do
            if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                if Config.HideName then
                    obj.Enabled = false
                end
            end
        end
    end
end)

end
