
-- 🚀 JUIX HUB

-- Servicios de Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local ContextActionService = game:GetService("ContextActionService")

-- Módulos e Rutas del Juego
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CoreUtil = require(ReplicatedStorage.Modules.Core.Util)
local BuyPromptUI = require(ReplicatedStorage.Modules.Game.UI.BuyPromptUI)
local EmotesUI = require(ReplicatedStorage.Modules.Game.Emotes.EmotesUI)
local EmotesList = require(ReplicatedStorage.Modules.Game.Emotes.EmotesList)
local CoreUI = require(ReplicatedStorage.Modules.Core.UI)
local CharModule = require(ReplicatedStorage.Modules.Core.Char)

local ItemsFolder = ReplicatedStorage:WaitForChild("Items")
local MeleeFolder = ItemsFolder:WaitForChild("melee")

-- Jugador Local y Personaje
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local DroppedItemsFolder = Workspace:WaitForChild("DroppedItems")
local Camera = Workspace.CurrentCamera

-- Detectar si el usuario está en Dispositivo Móvil (Teléfono / Tablet)
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- =============================================
-- 🎨 CARGA DE LA INTERFAZ (WindUI)
-- =============================================
local WindUI Library
pcall(function()
    WindUILibrary = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

local MainWindow

if WindUILibrary then
    MainWindow = WindUILibrary:CreateWindow({
        Title = "🫐 Juix Hub",
        Icon = "",
        Author = "By Jui",
        Folder = "JuixHub",
        Size = UDim2.fromOffset(650, 400),
        Theme = "Dark",
        Transparent = true,
        Resizable = true,
        KeyCode = Enum.KeyCode.G
    })

    MainWindow:EditOpenButton({
        Title = "🫐 JUIX HUB",
        Icon = "",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("#1a1a1a"),
            Color3.fromHex("#FFD700")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    })

    MainWindow:Tag({
        Title = "Juix Hub | Premium",
        Icon = "",
        Color = Color3.fromHex("#FFD700"),
        Radius = 13,
    })
else
    -- Fallback por si falla la carga de WindUI (evita que el script truene)
    MainWindow = {
        Tab = function()
            return {
                Section = function() end,
                Toggle = function() end,
                Slider = function() end,
                Button = function() end,
                Input = function() return {} end,
                Divider = function() end
            }
        end
    }
end

-- Administrador de Configuraciones Guardadas
local ConfigManager = MainWindow.ConfigManager
local SavedConfig = ConfigManager and ConfigManager:CreateConfig("JuixHubConfig")

-- Remote Principal para Enviar Datos al Servidor
local RemoteSend
pcall(function()
    RemoteSend = ReplicatedStorage:WaitForChild("Remotes", 5):WaitForChild("Send", 5)
end)

-- =============================================
-- ⚔️ JUIX HUB - PARTE 2: SISTEMA DE COMBATE Y APUNTADO
-- =============================================

-- Variables Principales del Aim
local SilentAimActivado = false
local BloqueoLineaRoja = false
local RadioFOV = 120
local ObjetivoActual = nil
local CirculoFOV = nil

-- Dibujos en Pantalla (ESP y Líneas)
local LineaApuntado = Drawing.new("Line")
LineaApuntado.Thickness = 1
LineaApuntado.Color = Color3.fromRGB(255, 50, 50)
LineaApuntado.Transparency = 1
LineaApuntado.Visible = false

local ListaAmigos = {}

-- =============================================
-- 📡 FUNCIONES DE RED Y PING
-- =============================================
local function ObtenerPing()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return 0.2 end
    
    local NetworkStats = PlayerGui:FindFirstChild("NetworkStats")
    if not NetworkStats then return 0.2 end
    
    local PingLabel = NetworkStats:FindFirstChild("PingLabel")
    if not PingLabel then return 0.2 end
    
    local TextoPing = PingLabel.Text
    if typeof(TextoPing) ~= "string" then return 0.2 end
    
    local ValorPing = tonumber(TextoPing:match("%d+"))
    if not ValorPing then return 0.2 end
    
    -- Convertir a segundos para la predicción del Aim
    local PingEnSegundos = ValorPing / 1000
    if PingEnSegundos < 0 or PingEnSegundos > 2 then PingEnSegundos = 0.2 end
    
    return PingEnSegundos
end

-- =============================================
-- 🛡️ SISTEMA DE AMIGOS (WHITELIST)
-- =============================================
local function EsJugadorAmigo(NombreJugador)
    for _, NombreAmigo in ipairs(ListaAmigos) do
        if NombreAmigo ~= "" and string.find(string.lower(NombreJugador), string.lower(NombreAmigo)) then
            return true
        end
    end
    return false
end

-- =============================================
-- 🎯 BÚSQUEDA DE OBJETIVO (FOV)
-- =============================================
local function ObtenerObjetivoMasCercano()
    local MejorObjetivo = nil
    local DistanciaMinima = RadioFOV
    local CentroPantalla = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, Jugador in ipairs(Players:GetPlayers()) do
        if Jugador ~= LocalPlayer and Jugador.Character then
            local Cabeza = Jugador.Character:FindFirstChild("Head")
            local HumanoideEnemigo = Jugador.Character:FindFirstChild("Humanoid")
            local RaizEnemigo = Jugador.Character:FindFirstChild("HumanoidRootPart")
            
            if Cabeza and HumanoideEnemigo and HumanoideEnemigo.Health > 0 and RaizEnemigo then
                local PosicionPantalla, EnPantalla = Camera:WorldToViewportPoint(Cabeza.Position)
                
                if EnPantalla then
                    local PosicionVector2 = Vector2.new(PosicionPantalla.X, PosicionPantalla.Y)
                    local DistanciaAlCentro = (PosicionVector2 - CentroPantalla).Magnitude
                    
                    -- Si está dentro del círculo y no es amigo, es un blanco válido
                    if DistanciaAlCentro <= RadioFOV and not EsJugadorAmigo(Jugador.Name) then
                        if DistanciaAlCentro < DistanciaMinima then
                            DistanciaMinima = DistanciaAlCentro
                            MejorObjetivo = Jugador
                        end
                    end
                end
            end
        end
    end
    
    return MejorObjetivo
end

-- =============================================
-- 🔥 JUIX HUB - PARTE 3: PREDICCIÓN, SILENT AIM Y AUTO-ATAQUE
-- =============================================

-- =============================================
-- 🔮 PREDICCIÓN DE MOVIMIENTO (VELOCITY)
-- =============================================
local MultiplicadorPrediccion = 1.2

local function PredecirPosicion(ParteObjetivo, JugadorObjetivo)
    -- Si no hay objetivo, no hacemos cálculos
    if not ParteObjetivo then return Vector3.zero end
    if not JugadorObjetivo then return ParteObjetivo.Position end
    
    -- CalcularVelocidad es una función (descodificada más adelante) que rastrea los últimos movimientos
    local VelocidadEnemigo = CalcularVelocidad(JugadorObjetivo) or Vector3.zero
    local Ping = ObtenerPing()
    
    -- Fórmula maestra: Posición Actual + (Velocidad * Ping * Multiplicador)
    return ParteObjetivo.Position + (VelocidadEnemigo * Ping * MultiplicadorPrediccion)
end

-- =============================================
-- 🎯 HOOK DEL SILENT AIM (LA MAGIA PURA)
-- =============================================
local HookOriginal
if RemoteSend and RemoteSend.FireServer then
    pcall(function()
        -- Interceptamos todo lo que sale del cliente al servidor
        HookOriginal = hookfunction(RemoteSend.FireServer, function(InstanciaRemote, ...)
            
            -- Si el evento no es el de disparar/acciones, lo dejamos pasar normal
            if InstanciaRemote ~= RemoteSend then
                return HookOriginal(InstanciaRemote, ...)
            end
            
            local Argumentos = {...}
            
            -- Condición: Silent Aim ON, la acción es "shoot_gun", y tenemos un blanco
            if SilentAimActivado and Argumentos[2] == "shoot_gun" and ObjetivoActual then
                
                local CabezaEnemigo = ObjetivoActual.Character and ObjetivoActual.Character:FindFirstChild("Head")
                local RaizEnemigo = ObjetivoActual.Character and ObjetivoActual.Character:FindFirstChild("HumanoidRootPart")
                local HumanoideEnemigo = ObjetivoActual.Character and ObjetivoActual.Character:FindFirstChild("Humanoid")
                
                if CabezaEnemigo and RaizEnemigo and HumanoideEnemigo then
                    -- Calculamos dónde va a estar la cabeza en base a su movimiento y nuestro lag
                    local PosicionCalculada = PredecirPosicion(CabezaEnemigo, ObjetivoActual)
                    
                    local MiCabeza = Character and Character:FindFirstChild("Head")
                    local MiPosicion = MiCabeza and MiCabeza.Position or nil
                    
                    -- Hackeamos los argumentos de disparo:
                    -- Wallbang 100% efectivo: Enviamos impacto directo sin raycast de paredes
                    Argumentos[4] = CFrame.new(MiPosicion, PosicionCalculada)
                    Argumentos[5] = {
                        [1] = {
                            [1] = {
                                Instance = CabezaEnemigo,
                                Normal = Vector3.new(0, 1, 0), -- Impacto perfecto desde arriba
                                Position = PosicionCalculada
                            }
                        }
                    }
                    
                    -- (Aquí iría la función visual que dibuja el láser de neón rojo a verde)
                    -- DibujarLaserNeon(MiPosicion, PosicionCalculada, HumanoideEnemigo, ObjetivoActual.Character)
                end
            end
            
            -- Enviamos el disparo modificado al servidor de Roblox
            return HookOriginal(InstanciaRemote, unpack(Argumentos))
        end)
    end)
end

-- =============================================
-- ⚔️ AUTO ATAQUE CUERPO A CUERPO (MELEE AURA)
-- =============================================
local AutoAtaqueActivado = false
local DistanciaAtaque = 20

local function AtacarCercanos()
    if not RemoteSend then return end
    
    local ArmaEquipada = ObtenerArmaActiva()
    if not ArmaEquipada or not EsArmaCuerpoACuerpo(ArmaEquipada) then return end
    
    local JugadoresCercanos = ObtenerJugadoresEnRango(DistanciaAtaque)
    if #JugadoresCercanos == 0 then return end
    
    local MiRaiz = Character and Character.PrimaryPart
    if not MiRaiz then return end
    
    local ObjetivosValidos = {}
    local PosicionesObjetivos = {}
    
    for _, Enemigo in pairs(JugadoresCercanos) do
        local CabezaEnemigo = Enemigo.Character and Enemigo.Character:FindFirstChild("Head")
        local RaizEnemigo = Enemigo.Character and Enemigo.Character.PrimaryPart
        
        if CabezaEnemigo and RaizEnemigo then
            -- Predecimos también los golpes a melee para que no fallen si el enemigo corre
            local PosicionGolpe = PredecirPosicion(CabezaEnemigo, Enemigo)
            table.insert(ObjetivosValidos, Enemigo)
            table.insert(PosicionesObjetivos, PosicionGolpe)
        end
    end
    
    if #ObjetivosValidos == 0 then return end
    
    local PosPrincipal = PosicionesObjetivos[1]
    local CFrameAtaque = CFrame.lookAt(MiRaiz.Position, PosPrincipal)
    
    -- Empaquetamos los datos del ataque y los enviamos
    local DatosAtaque = {"melee_attack", ArmaEquipada, ObjetivosValidos, CFrameAtaque, 0.75}
    pcall(function()
        RemoteSend:FireServer(unpack(DatosAtaque))
    end)
end

-- Bucle infinito para golpear en automático usando la API moderna (task.spawn)
task.spawn(function()
    while true do
        task.wait(0.4) -- Frecuencia de los golpes (Cooldown)
        if AutoAtaqueActivado and Character and Character.PrimaryPart then
            pcall(AtacarCercanos)
        end
    end
end)


-- =============================================
-- 👁️ JUIX HUB - PARTE 4: EFECTOS VISUALES Y RENDERIZADO DEL SILENT AIM
-- =============================================

-- =============================================
-- ✨ EFECTOS VISUALES DEL IMPACTO (NEÓN)
-- =============================================
local function DibujarEfectoDisparo(PosicionInicial, PosicionFinal, HumanoideEnemigo, PersonajeEnemigo)
    -- Creamos el láser rojo temporal
    local Exito, Laser = pcall(function()
        local NuevoLaser = Instance.new("Part")
        NuevoLaser.Anchored = true
        NuevoLaser.CanCollide = false
        NuevoLaser.Size = Vector3.new(0.08, 0.08, (PosicionFinal - PosicionInicial).Magnitude)
        NuevoLaser.CFrame = CFrame.new(PosicionInicial, PosicionFinal) * CFrame.new(0, 0, -NuevoLaser.Size.Z / 2)
        NuevoLaser.Material = Enum.Material.Neon
        NuevoLaser.Transparency = 0.35
        NuevoLaser.Color = Color3.fromRGB(255, 0, 0) -- Rojo (Fallado o en vuelo)
        NuevoLaser.Parent = Workspace
        Debris:AddItem(NuevoLaser, 4) -- Se elimina solo en 4 seg
        return NuevoLaser
    end)
    
    if HumanoideEnemigo then
        local VidaAntes = HumanoideEnemigo.Health
        
        -- Chequeamos si el disparo acertó
        task.spawn(function()
            task.wait(0.1)
            if HumanoideEnemigo and HumanoideEnemigo.Health < VidaAntes then
                -- ¡Hit Confirmado! El láser se vuelve Verde
                if Exito and Laser then
                    Laser.Color = Color3.fromRGB(0, 255, 0)
                end
                
                -- Dibujar esferas rojas en las partes del enemigo al morir/recibir daño
                local CabezaEnemigo = PersonajeEnemigo:FindFirstChild("Head")
                if CabezaEnemigo then
                    local EsferaHit = Instance.new("Part")
                    EsferaHit.Size = Vector3.new(0.2, 0.2, 0.2)
                    EsferaHit.Shape = Enum.PartType.Ball
                    EsferaHit.Material = Enum.Material.Neon
                    EsferaHit.Color = Color3.fromRGB(255, 0, 0)
                    EsferaHit.CFrame = CFrame.new(CabezaEnemigo.Position)
                    EsferaHit.Anchored = false
                    EsferaHit.CanCollide = false
                    EsferaHit.Parent = Workspace
                    
                    local Propulsor = Instance.new("BodyVelocity")
                    Propulsor.Velocity = Vector3.new(math.random(-5, 5), math.random(5, 10), math.random(-5, 5))
                    Propulsor.P = 5000
                    Propulsor.MaxForce = Vector3.new(4000, 4000, 4000)
                    Propulsor.Parent = EsferaHit
                    Debris:AddItem(EsferaHit, 1)
                end
            end
        end)
    end
end

-- =============================================
-- 🔄 BUCLE PRINCIPAL (RENDER STEPPED)
-- =============================================
-- Este bucle corre cada frame. Si tu pantalla es de 60Hz, corre 60 veces por segundo.
RunService.RenderStepped:Connect(function()
    pcall(function()
        
        -- Actualizar el objetivo si tenemos activado el bloqueo o el Silent Aim
        if BloqueoLineaRoja then ObjetivoActual = ObtenerObjetivoMasCercano() end
        ObjetivoActual = (SilentAimActivado or BloqueoLineaRoja) and ObtenerObjetivoMasCercano() or nil
        
        -- 🎯 1. ACTUALIZAR EL CÍRCULO FOV (Adaptado para Móvil y PC)
        if CirculoFOV then
            CirculoFOV.Visible = SilentAimActivado
            if SilentAimActivado then
                if IsMobile then
                    -- Lógica táctil: Usar Frame de interfaz (UIStroke)
                    CirculoFOV.Position = UDim2.fromScale(0.5, 0.5)
                    CirculoFOV.Size = UDim2.fromOffset(RadioFOV * 2, RadioFOV * 2)
                else
                    -- Lógica PC: Usar Drawing API
                    CirculoFOV.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    CirculoFOV.Radius = RadioFOV
                end
            end
        end
        
        -- 🎯 2. ACTUALIZAR LÍNEAS HACIA EL OBJETIVO
        if ObjetivoActual and ObjetivoActual.Character then
            local Humanoide = ObjetivoActual.Character:FindFirstChild("Humanoid")
            local ParteApuntada = ObjetivoActual.Character:FindFirstChild("Head") -- Por defecto apunta a la cabeza
            
            if Humanoide and Humanoide.Health > 0 and ParteApuntada then
                local CentroPantalla = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                
                -- Suavizado de cámara/línea (Lerp) para que no sea un movimiento robótico brusco
                local PosicionMundial = ParteApuntada.Position
                PosicionSuavizada = PosicionSuavizada:Lerp(PosicionMundial, 0.75) 
                
                local PosPantalla, EnPantalla = Camera:WorldToViewportPoint(PosicionSuavizada)
                
                if EnPantalla then
                    -- Línea Roja desde el centro hasta el enemigo
                    LineaApuntado.Visible = true
                    LineaApuntado.From = CentroPantalla
                    LineaApuntado.To = Vector2.new(PosPantalla.X, PosPantalla.Y)
                    
                    -- Caja 3D (TracerBox) alrededor de la cabeza del objetivo
                    if not CajaMarcadorESP then
                        CajaMarcadorESP = {}
                        for i = 1, 4 do
                            CajaMarcadorESP[i] = Drawing.new("Line")
                            CajaMarcadorESP[i].Color = Color3.fromRGB(255, 255, 255)
                            CajaMarcadorESP[i].Thickness = 1.2
                        end
                    end
                    
                    -- (Cálculo matemático para dibujar las 4 esquinas de la cajita en la cabeza)
                    local P1 = Camera:WorldToViewportPoint(ParteApuntada.Position + Vector3.new(0, 0.5, 0))
                    local P2 = Camera:WorldToViewportPoint(ParteApuntada.Position - Vector3.new(0, 0.5, 0))
                    local Tamano = math.clamp((P1 - P2).Magnitude / 2, 8, 25)
                    
                    local Arriba = Vector2.new(PosPantalla.X, PosPantalla.Y - Tamano)
                    local Abajo = Vector2.new(PosPantalla.X, PosPantalla.Y + Tamano)
                    local Izquierda = Vector2.new(PosPantalla.X - Tamano, PosPantalla.Y)
                    local Derecha = Vector2.new(PosPantalla.X + Tamano, PosPantalla.Y)
                    
                    CajaMarcadorESP[1].From, CajaMarcadorESP[1].To = Arriba, Derecha
                    CajaMarcadorESP[2].From, CajaMarcadorESP[2].To = Derecha, Abajo
                    CajaMarcadorESP[3].From, CajaMarcadorESP[3].To = Abajo, Izquierda
                    CajaMarcadorESP[4].From, CajaMarcadorESP[4].To = Izquierda, Arriba
                    
                    for i = 1, 4 do CajaMarcadorESP[i].Visible = true end
                else
                    -- Apagar dibujos si el enemigo sale de la pantalla
                    LineaApuntado.Visible = false
                    if CajaMarcadorESP then for i=1,4 do CajaMarcadorESP[i].Visible = false end end
                end
            end
        else
            -- Si no hay objetivo, nos aseguramos de ocultar todo
            LineaApuntado.Visible = false
            if CajaMarcadorESP then for i=1,4 do CajaMarcadorESP[i].Visible = false end end
        end
    end)
end)


-- =============================================
-- 🔫 JUIX HUB - PARTE 5: GUN MODS, ANTI-KILL Y PERSONAJE
-- =============================================

-- =============================================
-- ⚙️ VARIABLES GLOBALES (Para guardar configuración)
-- =============================================
local ObtenerEntorno = getgenv or function() return _G end

ObtenerEntorno().CadenciaDisparo = 1000
ObtenerEntorno().Precision = 1
ObtenerEntorno().Retroceso = 0
ObtenerEntorno().Durabilidad = 999999999
ObtenerEntorno().ModoAutomatico = true
ObtenerEntorno().AplicarModsAutomatico = false
ObtenerEntorno().AntiLockActivado = false
ObtenerEntorno().FuerzaAntiLock = 1000

local AntiKillActivado = false

-- =============================================
-- 🛡️ SISTEMA ANTI-KILL Y ANTI-LOCK (SPINBOT)
-- =============================================
-- Bucle de latido (Heartbeat): Corre después de calcular las físicas
RunService.Heartbeat:Connect(function()
    
    -- 🌪️ 1. ANTI-LOCK (Gira tu personaje a velocidades extremas para romper el aimbot enemigo)
    if ObtenerEntorno().AntiLockActivado and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local Raiz = LocalPlayer.Character.HumanoidRootPart
        local VelocidadOriginal = Raiz.Velocity
        
        -- Matemáticas circulares extremas para mover la hitbox erráticamente
        local Angulo = math.rad(tick() * 1500 % 360)
        local X = math.cos(Angulo) * ObtenerEntorno().FuerzaAntiLock
        local Z = math.sin(Angulo) * ObtenerEntorno().FuerzaAntiLock
        local Y = math.random(280, 480) -- Saltos aleatorios
        
        Raiz.Velocity = Vector3.new(X, Y, Z)
        RunService.RenderStepped:Wait() -- Espera un frame
        Raiz.Velocity = VelocidadOriginal -- Restaura para que tú no te marees
    end
end)

-- Bucle de supervivencia subterránea
RunService.Heartbeat:Connect(function()
    if not AntiKillActivado then return end
    
    -- Si tu personaje es derribado (lanzado/noqueado), te esconde debajo del mapa
    if EstaDerribado() then
        local Raiz = ObtenerRaizPersonaje()
        if Raiz and not PosicionSubterranea then
            TeletransportarBajoTierra()
        end
        ParpadearYMoverseAbajo() -- Evita que mueras por daño de zona subterránea
    else
        -- Si revives o te levantas, te devuelve a la superficie
        if PosicionSubterranea then
            local Raiz = ObtenerRaizPersonaje()
            if Raiz then
                Raiz.CFrame = PosicionSubterranea + Vector3.new(0, -Profundidad, 0)
            end
        end
        PosicionSubterranea = nil
    end
end)

-- =============================================
-- 🔫 GUN MODS (MODIFICACIÓN DE ARMAS EN TIEMPO REAL)
-- =============================================
local CarpetaArmas = ItemsFolder:WaitForChild("gun")

-- Verifica si la herramienta equipada es un arma de fuego
local function EsArmaDeFuego(Herramienta)
    if not Herramienta or not Herramienta:IsA("Tool") then return false end
    return CarpetaArmas:FindFirstChild(Herramienta.Name) ~= nil or Herramienta.Name:match("Gun") or Herramienta:FindFirstChild("Handle")
end

-- Función inyectora de atributos divinos
local function AplicarArmaDios(Arma)
    if not Arma or not EsArmaDeFuego(Arma) then return end
    
    -- Forzamos las estadísticas del arma a nivel Dios
    pcall(function()
        Arma:SetAttribute("fire_rate", ObtenerEntorno().CadenciaDisparo)
        Arma:SetAttribute("accuracy", ObtenerEntorno().Precision)
        Arma:SetAttribute("Recoil", ObtenerEntorno().Retroceso)
        Arma:SetAttribute("Durability", ObtenerEntorno().Durabilidad)
        Arma:SetAttribute("automatic", ObtenerEntorno().ModoAutomatico)
    end)
    
    -- Truco del desarrollador para evadir comprobaciones locales
    task.spawn(function()
        for i = 1, 20 do
            local Atributos = Arma:GetAttributes()
            local ListaAtributos = {}
            for Nombre, Valor in pairs(Atributos) do
                table.insert(ListaAtributos, Nombre)
            end
            table.sort(ListaAtributos)
            
            -- Este bloque actualiza forzosamente el atributo 11 del arma para obligar al juego a leer los nuevos stats
            if #ListaAtributos >= 11 then
                local AtributoClave = ListaAtributos[11]
                for j = 1, 5 do
                    pcall(function() Arma:SetAttribute(AtributoClave, true) end)
                    task.wait(0.01)
                end
            end
            task.wait(0.1)
        end
    end)
end

-- Bucle que revisa constantemente si equipaste un arma nueva para hackearla al instante
RunService.Heartbeat:Connect(function()
    if not ObtenerEntorno().AplicarModsAutomatico then return end
    
    local MiPersonaje = LocalPlayer.Character
    if not MiPersonaje then return end
    
    for _, Objeto in ipairs(MiPersonaje:GetChildren()) do
        if Objeto:IsA("Tool") and EsArmaDeFuego(Objeto) then
            pcall(AplicarArmaDios, Objeto)
        end
    end
end)

-- =============================================
-- 👁️ JUIX HUB - PARTE 6: ESP DE JUGADORES Y RASTREADOR DE LOOT
-- =============================================

-- Variables Globales de Configuración ESP
local MostrarNombres = false
local MostrarDistancia = false
local MostrarVida = false
local ResaltarJugador = false -- (Highlight)

-- Caché para no redibujar cosas innecesarias y evitar lag
local CacheESPJugadores = {}
local CacheHighlights = {}
local CacheObjetosTirados = {}

-- Colores según la rareza del objeto
local ColoresRareza = {
    Common = Color3.fromRGB(255, 255, 255),
    Uncommon = Color3.fromRGB(99, 255, 52),
    Rare = Color3.fromRGB(51, 170, 255),
    Epic = Color3.fromRGB(237, 44, 255),
    Legendary = Color3.fromRGB(255, 150, 0),
    Omega = Color3.fromRGB(255, 20, 51)
}

-- =============================================
-- 🧑‍🤝‍🧑 ESP DE JUGADORES (Cajas, Vida y Nombres)
-- =============================================
local function CrearESP_Jugador(JugadorEnemigo)
    -- Si ya le estamos dibujando el ESP, no lo duplicamos
    if CacheESPJugadores[JugadorEnemigo] then return end
    
    -- Textos
    local DibujoNombre = Drawing.new("Text")
    DibujoNombre.Size = 16
    DibujoNombre.Center = true
    DibujoNombre.Outline = true
    DibujoNombre.Color = EsJugadorAmigo(JugadorEnemigo.Name) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
    DibujoNombre.Font = 4
    
    local DibujoDistancia = Drawing.new("Text")
    DibujoDistancia.Size = 14
    DibujoDistancia.Center = true
    DibujoDistancia.Outline = true
    DibujoDistancia.Color = Color3.fromRGB(255, 255, 255)
    DibujoDistancia.Font = 4
    
    -- Barras de Vida
    local FondoVida = Drawing.new("Square")
    FondoVida.Filled = false
    FondoVida.Thickness = 1
    FondoVida.Color = Color3.fromRGB(0, 0, 0)
    FondoVida.Transparency = 0.9
    FondoVida.Visible = false
    
    local BarraVida = Drawing.new("Square")
    BarraVida.Filled = true
    BarraVida.Transparency = 0.9
    BarraVida.Visible = false
    
    local ListaDibujos = {DibujoNombre, DibujoDistancia, FondoVida, BarraVida}
    
    -- Conectar al ciclo de renderizado
    local ConexionRender = RunService.RenderStepped:Connect(function()
        if not JugadorEnemigo or not JugadorEnemigo.Character or not JugadorEnemigo.Character:FindFirstChild("HumanoidRootPart") then
            for _, Dibujo en pairs(ListaDibujos) do Dibujo.Visible = false end
            return
        end
        
        local RaizEnemigo = JugadorEnemigo.Character.HumanoidRootPart
        local HumanoideEnemigo = JugadorEnemigo.Character:FindFirstChild("Humanoid")
        local Distancia = 0
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Distancia = (RaizEnemigo.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        end
        
        -- Convertir posición 3D a 2D en tu pantalla
        local Pos2D, EnPantalla = Camera:WorldToViewportPoint(RaizEnemigo.Position)
        if not EnPantalla or Pos2D.Z <= 0 then
            for _, Dibujo en pairs(ListaDibujos) do Dibujo.Visible = false end
            return
        end
        
        local PosX = Pos2D.X
        local PosY = Pos2D.Y - 15
        
        -- DIBUJAR VIDA
        if MostrarVida and HumanoideEnemigo and HumanoideEnemigo.Health > 0 then
            local PorcentajeVida = HumanoideEnemigo.Health / (HumanoideEnemigo.MaxHealth > 0 and HumanoideEnemigo.MaxHealth or 1)
            local AltoBarra = 4
            local AnchoBarra = 60
            local InicioX = PosX - AnchoBarra / 2
            
            FondoVida.Position = Vector2.new(InicioX, PosY - AltoBarra - 2)
            FondoVida.Size = Vector2.new(AnchoBarra, AltoBarra)
            FondoVida.Visible = true
            
            BarraVida.Position = Vector2.new(InicioX, PosY - AltoBarra - 2)
            BarraVida.Size = Vector2.new(AnchoBarra * PorcentajeVida, AltoBarra)
            -- Cambia de verde a rojo según la vida
            BarraVida.Color = Color3.fromHSV(PorcentajeVida * 0.333, 0.8, 0.9) 
            BarraVida.Visible = true
            
            PosY = PosY - AltoBarra - 6
        else
            FondoVida.Visible = false
            BarraVida.Visible = false
        end
        
        -- DIBUJAR NOMBRE
        if MostrarNombres then
            DibujoNombre.Text = JugadorEnemigo.Name
            DibujoNombre.Color = EsJugadorAmigo(JugadorEnemigo.Name) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
            DibujoNombre.Position = Vector2.new(PosX, PosY - 16)
            DibujoNombre.Visible = true
        else
            DibujoNombre.Visible = false
        end
        
        -- DIBUJAR DISTANCIA
        DibujoDistancia.Text = MostrarDistancia and string.format("%.0f studs", Distancia) or ""
        DibujoDistancia.Position = Vector2.new(PosX, Pos2D.Y + 20)
        DibujoDistancia.Visible = MostrarDistancia
    end)
    
    CacheESPJugadores[JugadorEnemigo] = {Conexion = ConexionRender, Dibujos = ListaDibujos}
end

-- =============================================
-- 🌟 HIGHLIGHT (RESALTADO DEL CUERPO ENTERO)
-- =============================================
local function ActualizarHighlight(JugadorEnemigo)
    if JugadorEnemigo == Players.LocalPlayer then return end
    if not JugadorEnemigo.Character then return end
    
    -- Limpiar Highlight viejo
    if CacheHighlights[JugadorEnemigo] then 
        CacheHighlights[JugadorEnemigo]:Destroy() 
        CacheHighlights[JugadorEnemigo] = nil 
    end
    
    if ResaltarJugador then
        local NuevoHighlight = Instance.new("Highlight")
        NuevoHighlight.Name = "ResaltadoHack"
        NuevoHighlight.Adornee = JugadorEnemigo.Character
        NuevoHighlight.FillColor = Color3.fromRGB(0, 170, 255) -- Azul Neón
        NuevoHighlight.OutlineColor = Color3.fromRGB(0, 170, 255)
        NuevoHighlight.Parent = Workspace
        CacheHighlights[JugadorEnemigo] = NuevoHighlight
    end
end

-- =============================================
-- 🎒 RASTREADOR DE LOOT (DROPPED ITEMS)
-- =============================================
local function LimpiarLootDesaparecido()
    for Objeto, Dibujos in pairs(CacheObjetosTirados) do
        -- Si el objeto ya no existe en el mapa (alguien lo recogió), borramos sus dibujos
        if not Objeto or not Objeto.Parent then
            pcall(function() Dibujos.Circulo:Remove() end)
            pcall(function() Dibujos.CirculoInterno:Remove() end)
            pcall(function() Dibujos.TextoNombre:Remove() end)
            CacheObjetosTirados[Objeto] = nil
        end
    end
end

RunService.RenderStepped:Connect(function()
    LimpiarLootDesaparecido()
    
    if not DroppedItemsFolder then return end
    
    local MiRaiz = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not MiRaiz then return end
    
    local ObjetosCercanos = {}
    
    -- Escaneamos todos los objetos tirados en el mapa
    for _, ObjetoModelo in ipairs(DroppedItemsFolder:GetChildren()) do
        if ObjetoModelo:IsA("Model") and ObjetoModelo:FindFirstChild("PickUpZone") then
            local PosicionLoot = ObjetoModelo.PickUpZone.Position
            local DistanciaLoot = (PosicionLoot - MiRaiz.Position).Magnitude
            table.insert(ObjetosCercanos, {Item = ObjetoModelo, Distancia = DistanciaLoot})
        end
    end
    
    -- Ordenamos para procesar solo los 20 más cercanos y no causar lag
    table.sort(ObjetosCercanos, function(a, b) return a.Distancia < b.Distancia end)
    
    for i = 1, math.min(20, #ObjetosCercanos) do
        local ItemActual = ObjetosCercanos[i].Item
        local DibujosItem = CacheObjetosTirados[ItemActual]
        
        -- Si el item no tiene dibujos asignados, se los creamos
        if not DibujosItem then
            DibujosItem = {
                Circulo = Drawing.new("Circle"),
                CirculoInterno = Drawing.new("Circle"),
                TextoNombre = Drawing.new("Text")
            }
            -- Formato de los círculos de loot
            DibujosItem.Circulo.Thickness = 2
            DibujosItem.Circulo.Transparency = 0.7
            DibujosItem.TextoNombre.Size = 16
            DibujosItem.TextoNombre.Center = true
            DibujosItem.TextoNombre.Outline = true
            CacheObjetosTirados[ItemActual] = DibujosItem
        end
        
        -- Convertimos la ubicación del item al 2D de la cámara
        local Pos2DLoot, EnPantallaLoot = Camera:WorldToViewportPoint(ItemActual.PickUpZone.Position)
        
        if EnPantallaLoot then
            local ColorRareza = ObtenerColorRareza(ItemActual)
            -- El círculo se hace más pequeño entre más lejos esté el objeto
            local EscalaDistancia = math.clamp(100 / Pos2DLoot.Z, 3, 6)
            
            DibujosItem.Circulo.Position = Vector2.new(Pos2DLoot.X, Pos2DLoot.Y)
            DibujosItem.Circulo.Radius = EscalaDistancia + 5
            DibujosItem.Circulo.Color = ColorRareza
            DibujosItem.Circulo.Visible = true
            
            DibujosItem.TextoNombre.Position = Vector2.new(Pos2DLoot.X, Pos2DLoot.Y - EscalaDistancia - 20)
            DibujosItem.TextoNombre.Text = ItemActual.Name
            DibujosItem.TextoNombre.Color = ColorRareza
            DibujosItem.TextoNombre.Visible = true
        else
            DibujosItem.Circulo.Visible = false
            DibujosItem.TextoNombre.Visible = false
        end
    end
end)
