--!native
--!nolint BuiltinGlobalWrite
--!nolint UnknownGlobal

-- Sasware utility / testing software for use in Sasware Places only.
-- Not for use in other games, always check terms of service before using.
-- Usage is permitted in supported games by developers.
-- This software is developed and sanctioned for use in Sasware games only.

--[[
    NOTICE: This script is strictly for personal use and educational purposes.
    It is intended for testing and development within my own private Roblox game or server.
    The code herein is not designed for use in public games, nor to violate Roblox's Terms of Service.
    This is a custom tool created to explore game mechanics, debug features, or enhance my own game design.
    Any assistance provided in developing this script is understood to be for learning and private experimentation only.
    By reviewing or contributing to this code, you acknowledge that it is not intended for malicious use or exploitation.
--]]

repeat
	task.wait()
until game:IsLoaded()

if not LPH_OBFUSCATED then
	LPH_ENCNUM = function(toEncrypt, ...)
		assert(
			type(toEncrypt) == "number" and #{ ... } == 0,
			"LPH_ENCNUM only accepts a single constant double or integer as an argument."
		)
		return toEncrypt
	end
	LPH_NUMENC = LPH_ENCNUM

	LPH_ENCSTR = function(toEncrypt, ...)
		assert(
			type(toEncrypt) == "string" and #{ ... } == 0,
			"LPH_ENCSTR only accepts a single constant string as an argument."
		)
		return toEncrypt
	end
	LPH_STRENC = LPH_ENCSTR

	LPH_ENCFUNC = function(toEncrypt, encKey, decKey, ...)
		assert(
			type(toEncrypt) == "function" and type(encKey) == "string" and #{ ... } == 0,
			"LPH_ENCFUNC accepts a constant function, constant string, and string variable as arguments."
		)
		return toEncrypt
	end
	LPH_FUNCENC = LPH_ENCFUNC

	LPH_JIT = function(f, ...)
		assert(
			type(f) == "function" and #{ ... } == 0,
			"LPH_JIT only accepts a single constant function as an argument."
		)
		return f
	end
	LPH_JIT_MAX = LPH_JIT

	LPH_NO_VIRTUALIZE = function(f, ...)
		assert(
			type(f) == "function" and #{ ... } == 0,
			"LPH_NO_VIRTUALIZE only accepts a single constant function as an argument."
		)
		return f
	end

	LPH_NO_UPVALUES = function(f, ...)
		assert(type(setfenv) == "function", "LPH_NO_UPVALUES can only be used on Lua versions with getfenv & setfenv")
		assert(
			type(f) == "function" and #{ ... } == 0,
			"LPH_NO_UPVALUES only accepts a single constant function as an argument."
		)
		return f
	end

	LPH_CRASH = function(...)
		warn("LPH_CRASH INVOKED")
		assert(#{ ... } == 0, "LPH_CRASH does not accept any arguments.")
	end

	getgenv().Key = "BLACKLISTED"
end

local type = type
local typeof = typeof
local pairs = pairs
local ipairs = ipairs
local table = table
local next = next
local string = string
local math = math
local math_max = math.max
local math_min = math.min
local math_sin = math.sin
local math_floor = math.floor
local os = os
local coroutine = coroutine
local coroutine_create = coroutine.create
local coroutine_resume = coroutine.resume
local coroutine_yield = coroutine.yield
local _coroutine_close = coroutine.close
local task = task
local task_wait = task.wait
local task_spawn = task.spawn
local task_defer = task.defer

local SecureRequest = require("./modules/secure_request.luau")
local Success, SafeHook = require("./modules/bypasses.luau")

--#endregion

local Storage = {
	Connections = {},
	Routines = {},
	Anti_Aim_Animation = nil,
	OldHipHeight = nil,
	LastDeathCFrame = nil,
	RemoteInventoryUI = nil,
	RemoteInventoryUIRefs = nil,
	TeleportLocations = {
		["Pawn Shop"] = Vector3.new(117.93998718261719, 5.509997844696045, 809.8400268554688),
		["Convenience Store"] = Vector3.new(187.75999450683594, 5.459999084472656, 841.4600830078125),
		["Car Dealership"] = Vector3.new(800.3800659179688, 5.6000285148620605, 448.74005126953125),
		["Hospital"] = Vector3.new(550.5601196289062, 5.6000285148620605, 289.2201232910156),
		["Ammo City"] = Vector3.new(463.4001159667969, 5.600028038024902, 402.81036376953125),
		["Clothing Store"] = Vector3.new(393.3001403808594, 5.600028038024902, 408.54034423828125),
		["Gas Station"] = Vector3.new(191.01992797851562, 5.459999084472656, 139.78005981445312),
		["Gas Station 2"] = Vector3.new(1314, 6, 1278),
		["Crate Job"] = Vector3.new(25.260055541992188, 5.019999027252197, 225.16004943847656),
		["Jewlery Store"] = Vector3.new(-311.76007080078125, 5.600033760070801, 192.7801513671875),
		["Mopping Job"] = Vector3.new(531.8800048828125, 5.6000285148620605, 103.86014556884766),
		["Housing"] = Vector3.new(1052.6199951171875, 5.074656009674072, 635.03173828125),
	},
	Vehicle_Attributes = {
		{ Name = "acceleration", Type = "number", Min = 5, Max = 100, DisplayName = "Acceleration" },
		-- { Name = "forwardMaxSpeed", Type = "number", Min = 5, Max = 120, DisplayName = "Max Speed" },
		-- { Name = "maxSpeedTorque", Type = "number", Min = 1000, Max = 100000, DisplayName = "Max Speed Torque" },
		-- { Name = "minSpeedTorque", Type = "number", Min = 1000, Max = 100000, DisplayName = "Min. Speed Torque" },
		-- { Name = "slipThreshold", Type = "number", Min = 1, Max = 100, DisplayName = "Slip Threshold" }
	},
}

-- Expose Storage globally for auxiliary modules/utilities
getgenv().BS_Storage = Storage

-- Name generator and helpers will be defined once below (single implementation in file)
local CurrentDate = os.date("*t")
local ExpirationDate = { year = 2026, month = 2, day = 15 }
local ExpirationTime = os.time(ExpirationDate)
local CurrentTime = os.time(CurrentDate)
local Executor = identifyexecutor()

-- Unique name generator for Storage registries
Storage.Connections.__counters = Storage.Connections.__counters or {}
Storage.Routines.__counters = Storage.Routines.__counters or {}
local function _nextKey(tbl: { [any]: any }, base: string): string
	local counters = rawget(tbl, "__counters")
	local n = (counters[base] or 0) + 1
	local key = base
	if rawget(tbl, base) ~= nil then
		key = (`%s#%d`):format(base, n)
	end
	while rawget(tbl, key) ~= nil do
		n += 1
		key = (`%s#%d`):format(base, n)
	end
	counters[base] = n
	return key
end

Storage.Routines[_nextKey(Storage.Routines, "ClockIntegrityCheck")] = task_spawn(function()
	-- To ensure os.clock hasn't been tampered with, we run it and wait to see if it's changed by the time we return.
	local StartTime = os.clock()
	task_wait(10)
	local EndTime = os.clock()

	if EndTime - StartTime < 5 then
		LPH_CRASH()
	end
end)

-- if CurrentTime >= ExpirationTime then
-- 	print("This script has expired. Please contact the developer for a new version.")
-- 	error("Script expired.")
-- 	return
-- end

local START_TIME = os.clock()

local Version = "2.1.0"
local SubVersion = (not FREE_BUILD) and "Release [Paid]" or "Release [Free]"

shared.HOOKING_ENABLED = true

--#region Initializing core functionality

local T = function(...)
	return ...
end

if not rconsoleprint then
	rconsoleprint = function(...) end
end

if not rconsolewarn then
	rconsolewarn = function(...) end
end

if not rconsoledestroy then
	rconsoledestroy = function(...) end
end

local function G_Toggle(ToggleName: string): boolean
	if not getgenv().Library then
		repeat
			wait()
		until getgenv().Library
	end

	if not getgenv().Library.Toggles then
		repeat
			wait()
		until getgenv().Library.Toggles
	end

	if not getgenv().Library.Toggles[ToggleName] then
		return false
	end

	return getgenv().Library.Toggles[ToggleName].Value
end

local function G_Option(OptionName: string): any
	if not getgenv().Library then
		repeat
			wait()
		until getgenv().Library
	end

	if not getgenv().Library.Options then
		repeat
			wait()
		until getgenv().Library.Options
	end

	if not getgenv().Library.Options[OptionName] then
		repeat
			wait()
		until getgenv().Library.Options[OptionName]
	end

	return getgenv().Library.Options[OptionName].Value
end

local function G_Option_NYield(OptionName: string): any
	return getgenv().Library.Options[OptionName].Value
end

local function G_Toggle_NYield(ToggleName: string): any
	return getgenv().Library.Toggles[ToggleName].Value
end

local function UpdateStatus(Text)
	shared.StatusText.Text = Text
	task_wait(0.05)
end

local function SafeRequire(...)
	local OldThreadContext = getthreadcontext()
	setthreadcontext(2)
	local Result = require(...)
	setthreadcontext(OldThreadContext)
	return Result
end

local function dbgprint(...)
	if DEBUGGING then
		print("[DEBUGGING]", ...)
	end
end

local function dbgwarn(...)
	if DEBUGGING then
		warn("[DEBUGGING]", ...)
	end
end

local function __Stub(a: never)
	return warn("Stub function called with argument:", a)
end

local function flen(Table): number
	local Count = 0
	for _ in next, Table do
		Count += 1
	end
	return Count
end

--#endregion

--#region Initializing services and Instances

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local LocalUserId = LocalPlayer.UserId
local Camera = workspace.CurrentCamera
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")

local Data = SafeRequire(ReplicatedStorage.Modules.Packages.Replion).Client:WaitReplion("Data")
local Net = SafeRequire(ReplicatedStorage.Modules.Packages.Net)
local Movement = SafeRequire(ReplicatedStorage.Modules.Client.Controllers.Movement)

--#endregion

--#region Checking executor environment

---@diagnostic disable-next-line: undefined-global
if not (hookfunction and hookmetamethod and isexecutorclosure and getgc and debug and restorefunction) then
	shared.HOOKING_ENABLED = false
	warn("Hooking is disabled due to the executor environment not supporting it.")
end

--#endregion

UpdateStatus(T("Initializing libraries..."))

--#region Loading libraries

UpdateStatus("Loading modules...")

if Executor:match("Delta") then
	UpdateStatus("Loading modules/drawing2")
	require("modules/Drawing2.luau")
end

UpdateStatus(T("Loading modules/esp"))
local ESP_Library = require("modules/esp2.luau")

UpdateStatus(T("Loading modules/aiminglib"))
local Aiming_Library = require("modules/aiminglib.luau")

UpdateStatus(T("Loading modules/itemviewlib"))
local ItemView = require("modules/itemviewlib.luau")

ItemView:Init()

UpdateStatus(T("Loading modules/pathmodule"))
local PathLib = require("modules/pathmodule")

UpdateStatus(T("Loading modules/teleportdata"))
local TeleportData = require("modules/teleportdata.luau")

UpdateStatus(T("Loading modules/identifier"))
local Identifier = require("modules/identifier.luau")

UpdateStatus(T("Loading modules/freecamera"))
local ToggleFreeCamera = require("modules/freecamera.luau")

UpdateStatus(T("Loading modules/gizmo"))
local Gizmo = require("modules/gizmo_init.luau")

UpdateStatus(T("Loading modules/secure_call"))
local secure_call = require("modules/secure_call.luau")

UpdateStatus(T("Loading modules/Cleaner"))
local Cleaner = require("./modules/Cleaner.luau")

UpdateStatus(T("Loading modules/HookMgr"))
local HookMgr = require("./modules/HookMgr.luau")

UpdateStatus(T("Loading modules/Utils"))
local Utils = require("./modules/Utils.luau")

UpdateStatus(T("Loading user interface..."))
local Repository = "https://raw.githubusercontent.com/centerepic/Obsidian/refs/heads/main/"
local Library = loadstring(SecureRequest:HttpGet(Repository .. "Library.lua"))()
local ThemeManager = loadstring(SecureRequest:HttpGet(Repository .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(SecureRequest:HttpGet(Repository .. "addons/SaveManager.lua"))()

local Repr: (any, { [string]: any }?) -> string =
	loadstring(SecureRequest:HttpGet("https://raw.githubusercontent.com/Ozzypig/repr/refs/heads/master/repr.lua"))()

local ErrorHandler = require("modules/error_notif_lib.luau")

--#endregion

pcall(function()
	local Exec, ExVersion = identifyexecutor()
	local ExecutorData = table.concat({ Exec, ExVersion }, " ")

	SecureRequest.request({
		Url = "https://example.com/checkin",
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json",
		},
		Body = game:GetService("HttpService"):JSONEncode({
			Version = Version,
			SubVersion = SubVersion,
			Executor = ExecutorData,
			UserID = LocalPlayer.UserId,
		}),
	})

	LocalPlayer.PlayerGui.TeleportingGui.Enabled = false
end)

--#region Main closure
xpcall(function()
	--#region Enviroment Scanning

	if not replaceclosure then
		replaceclosure = hookfunction
	end

	if not getallthreads then
		function getallthreads()
			local threads = {}

			for _, item in getreg() do
				if type(item) == "thread" then
					table.insert(threads, item)
				end
			end

			return threads
		end
	end

	if not setthreadcontext then
		setthreadcontext = setthreadidentity
	end

	local function SafeNotify(...)
		local Args = { ... }
		coroutine.wrap(function()
			setthreadcontext(8)
			Library:Notify(unpack(Args))
		end)()
	end

	local MessageShown = FREE_BUILD or isfile("NoticeShown")

	if not MessageShown then
		local Root, Button1, Button2 = ErrorHandler.InteractiveToast(
			T("Important notice"),
			T(
				"Important notice: If you have bought this script from an unauthorized reseller or website,"
					.. "\nplease be aware that you are at a high risk of the key you are using being disabled at any time.\n"
					.. "By continuing, you affirm that you have purchased this script from an official source.\nMore information @ https://discord.gg/6qCymXqa2u"
			),
			T("Proceed"),
			""
		)

		local Pressed = false

		Button1.Activated:Once(function()
			Pressed = true
			Root:Destroy()
			if not FREE_BUILD then
				writefile("NoticeShown", "")
			end
		end)

		Button2:Destroy()
		Button1.BackgroundColor3 = Color3.new(0.533333, 0.533333, 0.533333)
		Root.Parent = CoreGui
		Root.Enabled = true

		repeat
			task_wait(0.1)
		until Pressed
	end

	local AssertCharacter = LPH_NO_VIRTUALIZE(function(): Model
		if LocalPlayer.Character then
			return LocalPlayer.Character
		else
			repeat
				task.wait()
			until LocalPlayer.Character
			return LocalPlayer.Character
		end
	end)

	local function WaitForPing()
		local NetworkPing = LocalPlayer:GetNetworkPing()
		return task.wait(math.max(0.2, NetworkPing))
	end

	local function VisualizeRay(Origin, Target)
		local RayBind = "VisRayBind" .. HttpService:GenerateGUID(false)

		local RayData = {
			Hit = false,
		}

		RunService:BindToRenderStep(RayBind, 500, function()
			Gizmo.PushProperty("Color3", RayData.Hit and Color3.new(0.082353, 1, 0) or Color3.new(1, 0, 0))
			Gizmo.Line:Draw(CFrame.lookAt((Origin + Target) / 2, Target), (Origin - Target).Magnitude)
		end)

		task.delay(LPH_OBFUSCATED and 5 or 60, function()
			RunService:UnbindFromRenderStep(RayBind)
		end)

		return RayData
	end

	--#endregion

	UpdateStatus("Done!")

	RunService:UnbindFromRenderStep("Overlay")
	shared.OverlayImage:Remove()
	shared.StatusText:Remove()
	shared.DarkOverlay:Destroy()

	Storage.Connections[_nextKey(Storage.Connections, "RunService_PreRender")] =
		Cleaner(RunService.PreRender:Connect(LPH_JIT_MAX(function()
			if G_Toggle("Anonymizer") then
				local Character = AssertCharacter()
				local NameTag = Character:WaitForChild("Head"):WaitForChild("NameTag", 5):WaitForChild("NameTag", 5)

				if NameTag then
					local Mask = "Sasware"
					local String = ""
					local maskIndex = 1
					for i = 1, 12 do
						if math.random() > 0.2 and maskIndex <= #Mask and i > 2 then
							String = String .. Mask:sub(maskIndex, maskIndex)
							maskIndex = maskIndex + 1
						else
							String = String .. string.char(math.random(33, 126))
						end
					end

					NameTag.Label.Text = String
					NameTag.Shadow.Text = String

					String = ""
					maskIndex = 1
					for i = 1, 12 do
						if math.random() > 0.2 and maskIndex <= #Mask and i > 2 then
							String = String .. Mask:sub(maskIndex, maskIndex)
							maskIndex = maskIndex + 1
						else
							String = String .. string.char(math.random(33, 126))
						end
					end

					NameTag.RealName.Text = `@{String}`
					NameTag.RealNameShadow.Text = `@{String}`
				end
			end
		end)))

	local JumpDown = false
	local TouchGui = LocalPlayer.PlayerGui:WaitForChild("TouchGui", 1)
	local TouchControlFrame = TouchGui and TouchGui:FindFirstChild("TouchControlFrame")
	local JumpButton = TouchControlFrame and TouchControlFrame:FindFirstChild("JumpButton")

	Storage.Connections[_nextKey(Storage.Connections, "Input_InputBegan")] =
		Cleaner(UserInputService.InputBegan:Connect(function(Input, GameProcessed)
			if GameProcessed then
				return
			end
			if not G_Toggle("FlyJump") then
				return
			end
			if Input.UserInputType == Enum.UserInputType.Keyboard then
				if Input.KeyCode == Enum.KeyCode.Space then
					JumpDown = true
				end
			end
		end))

	Storage.Connections[_nextKey(Storage.Connections, "Input_InputEnded")] =
		Cleaner(UserInputService.InputEnded:Connect(function(Input, GameProcessed)
			if GameProcessed then
				return
			end
			if Input.UserInputType == Enum.UserInputType.Keyboard then
				if Input.KeyCode == Enum.KeyCode.Space then
					JumpDown = false
				end
			end
		end))

	if JumpButton then
		Storage.Connections[_nextKey(Storage.Connections, "JumpButton_InputBegan")] =
			Cleaner(JumpButton.InputBegan:Connect(function(Input, GameProcessed)
				if GameProcessed then
					return
				end
				if not G_Toggle("FlyJump") then
					return
				end
				if Input.UserInputType == Enum.UserInputType.Touch then
					JumpDown = true
				end
			end))

		Storage.Connections[_nextKey(Storage.Connections, "JumpButton_InputEnded")] =
			Cleaner(JumpButton.InputEnded:Connect(function(Input, GameProcessed)
				if GameProcessed then
					return
				end
				if Input.UserInputType == Enum.UserInputType.Touch then
					JumpDown = false
				end
			end))
	end

	local LastImpulse = os.clock()
	Storage.Connections[_nextKey(Storage.Connections, "RunService_PreSimulation")] =
		Cleaner(RunService.PreSimulation:Connect(LPH_JIT_MAX(function()
			if JumpDown and G_Toggle("FlyJump") then
				-- print('auto jump')
				if os.clock() - LastImpulse < 0.1 then
					return
				end

				LastImpulse = os.clock()

				local Character = AssertCharacter()
				local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
				if not Humanoid then
					return
				end

				for _, BasePart: BasePart in next, Character:GetDescendants() do
					if BasePart:IsA("BasePart") then
						-- print("applying impulse")
						if Humanoid.FloorMaterial == Enum.Material.Air then
							-- Make sure the part's vertical velocity is less than 50

							if BasePart.AssemblyLinearVelocity.Y < 50 then
								BasePart:ApplyImpulse(Vector3.yAxis * (7 / 1.2))
							end
						end

						-- BasePart.AssemblyLinearVelocity = (BasePart.AssemblyAngularVelocity * Vector3.new(1, 0, 1)) + Vector3.yAxis * 25
					end
				end
			end
		end)))

	Storage.Connections[_nextKey(Storage.Connections, "AntiAFK_Idled")] =
		Cleaner(Players.LocalPlayer.Idled:Connect(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end))

	Storage.Connections[_nextKey(Storage.Connections, "AntiUnload_Cars")] =
		Cleaner(workspace:WaitForChild("Cars").ChildAdded:Connect(function(Car : Instance)
			if not Car:IsA("Model") then
				return
			end
			Car.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
		end))

	Storage.Routines[_nextKey(Storage.Routines, "Anti-Kill")] = Cleaner(task_spawn(LPH_JIT_MAX(function()

		local KnockedController = SafeRequire(ReplicatedStorage.Modules.Client.Controllers.KnockedController)

		while RunService.Heartbeat:Wait() do
			if not G_Toggle("Panic") then
				continue
			end

			if KnockedController.Downed then
				local RunService = game:GetService("RunService")
				local Character = AssertCharacter()
				local Origin = Character:GetPivot().Position
				local PanicPosition = math.random() > 0.5 and Vector3.new(1513, 6, 1403) or Vector3.new(886, 15, 1564) -- Far away from combat zones
				
				Utils.TP(CFrame.new(PanicPosition))

				repeat
					RunService.Heartbeat:Wait()
					RunService:Set3dRenderingEnabled(false)
					Character.HumanoidRootPart.Velocity = Vector3.new(0, 1, 0)
					Character:PivotTo(CFrame.new(PanicPosition))
				until not KnockedController.Downed

				Utils.TP(CFrame.new(Origin))

				RunService:Set3dRenderingEnabled(true)

			end

		end
	end)))

	Storage.Routines[_nextKey(Storage.Routines, "KillAura")] = Cleaner(task_spawn(LPH_JIT_MAX(function()
		local CombatRemote = Net:RemoteEvent("Combat")
		local CombatData = nil

		-- Try to get combat data safely
		pcall(function()
			CombatData = SafeRequire(ReplicatedStorage.Values.ToolData).Combat
		end)

		local v3 = SafeRequire(ReplicatedStorage.Modules.ClientFramework)
		local l_CombatAnims_0 = ReplicatedStorage.Assets.Animations.CombatAnims
		local v12 = 0

		while RunService.Heartbeat:Wait() do
			if not G_Toggle("KillAura") then
				continue
			end

			local Character = AssertCharacter()
			local Tool = Character:FindFirstChildOfClass("Tool")
			local Pivot = Character:GetPivot()
			local HitPlayers = {}

			if not Tool then
				continue
			end

			if Tool:GetAttribute("ToolScript") ~= "Melee" then
				continue
			end
			-- Get weapon's combo data and determine if we should use finisher
			local UseFinisher = false
			if G_Toggle("KillAuraFinisher") and CombatData then
				local l_Combat_0 = SafeRequire(ReplicatedStorage.Values.ToolData).Combat
				local v32 = SafeRequire(ReplicatedStorage.Modules.Client.Controllers.ToolController).ToSendToTools
				local v33 = l_Combat_0[v32.GetTool().Name]
				local v34 = v12 == v33.TotalCombo
				v12 = v12 + 1
				if v12 > v33.TotalCombo then
					v12 = 1
				end

				if v34 then
					UseFinisher = true
				end

				local v37 = v3.Local.Animator:LoadAnimation(l_CombatAnims_0[(v33.Anims or "") .. v12]) :: AnimationTrack
				v37:Play()
				Debris:AddItem(v37, v37.Length)
			end

			for _, Player in next, Players:GetPlayers() do
				if
					Player ~= LocalPlayer
					and Player.Character
					and Player.Character:FindFirstChild("HumanoidRootPart")
				then
					local OtherPivot = Player.Character:GetPivot()

					if (OtherPivot.Position - Pivot.Position).Magnitude <= 10 then
						table.insert(HitPlayers, Player)
					end
				end
			end

			if #HitPlayers == 0 then
				continue
			end

			CombatRemote:FireServer("Swing")

			task_wait()

			for _, HitPlayer in next, HitPlayers do
				local Humanoid = HitPlayer.Character:FindFirstChild("Humanoid")

				if not Humanoid or Humanoid.Health <= 0 then
					continue
				end

				local HitPart = HitPlayer.Character:FindFirstChild("HumanoidRootPart")
					or HitPlayer.Character:FindFirstChild("Head")
					or HitPlayer.Character:FindFirstChildWhichIsA("BasePart")
				if HitPart then
					local CombatArgs = {
						"Dmg",
						Humanoid,
						UseFinisher,
					}

					CombatRemote:FireServer(unpack(CombatArgs))
				end
			end

			task_wait(0.5)
		end
	end)))

	Storage.Routines[_nextKey(Storage.Routines, "InfiniteStamina")] = Cleaner(task_spawn(LPH_JIT_MAX(function()
		while RunService.Heartbeat:Wait() do
			if not G_Toggle("InfiniteStamina") then
				continue
			end
			debug.setupvalue(Movement.DecreaseStamina, 1, debug.getupvalue(Movement.DecreaseStamina, 2))
		end
	end)))

	Storage.Routines[_nextKey(Storage.Routines, "WalkFling")] = Cleaner(task_spawn(LPH_JIT_MAX(function()
		local Flip = 1
		while true do
			RunService.Heartbeat:Wait()

			if not (G_Toggle("WalkFling") or G_Toggle("Anti-Aimbot")) then
				continue
			end

			local Character = AssertCharacter()
			local Root = Character:WaitForChild("HumanoidRootPart") :: Part
			local Velocity = Root.AssemblyLinearVelocity

			if G_Toggle("Anti-Aimbot") and Velocity.Magnitude < 5 then
				-- Anti aimbot relies on always having some velocity
				-- So just make up some horizontal velocity
				local function GetHorizontalComponent()
					local Sign = (math.random(0, 1) * 2 - 1)
					return Sign * (10 + math.random(0, 5))
				end
				Velocity = Vector3.new(GetHorizontalComponent(), math.random(-5, 5), GetHorizontalComponent())
			end

			Root.AssemblyLinearVelocity = Velocity * 10000 + Vector3.yAxis * 10000

			RunService.RenderStepped:Wait()

			Root.AssemblyLinearVelocity = Velocity

			RunService.Stepped:Wait()

			Root.AssemblyLinearVelocity += Vector3.yAxis * Flip * 0.1
			Flip *= -1
		end
	end)))

	Storage.Routines[_nextKey(Storage.Routines, "Invisibility")] = Cleaner(task_spawn(LPH_JIT_MAX(function()
		local function ResolveAnimationId(rawId: any): string
			local id = tostring(rawId)
			if not id:find("rbxassetid://") then
				id = "rbxassetid://" .. id
			end

			local resolved = id
			local ok, objects = pcall(game.GetObjects, game, id)
			if ok and type(objects) == "table" then
				for _, obj in ipairs(objects) do
					if typeof(obj) == "Instance" then
						local anim: Animation? = nil
						if obj:IsA("Animation") then
							anim = obj
						else
							anim = obj:FindFirstChildWhichIsA("Animation", true)
						end
						if anim and type(anim.AnimationId) == "string" and anim.AnimationId ~= "" then
							resolved = anim.AnimationId
							break
						end
					end
				end
			end

			return resolved
		end

		local function LoadResolvedAnimationTrack(humanoid: Humanoid, rawId: any): AnimationTrack?
			local anim = Instance.new("Animation")
			anim.AnimationId = ResolveAnimationId(rawId)

			local track: AnimationTrack? = nil
			local ok = pcall(function()
				track = (humanoid :: any):LoadAnimation(anim)
			end)
			if ok and track then
				return track
			end

			local animator = humanoid:FindFirstChildOfClass("Animator")
			if not animator then
				animator = humanoid:WaitForChild("Animator", 2) :: any
			end
			if animator and typeof(animator) == "Instance" and animator:IsA("Animator") then
				pcall(function()
					track = (animator :: Animator):LoadAnimation(anim)
				end)
			end
			return track
		end

		while true do
			RunService.PreSimulation:Wait()

			if not G_Toggle("Invisibility") then
				continue
			end

			local Character = AssertCharacter()
			local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid

			if Humanoid then
				-- local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart") :: BasePart

				local Track = Storage.Anti_Aim_Animation

				if not Track then
					Track = LoadResolvedAnimationTrack(Humanoid, 94292601332790)
					if Track then
						Track.Priority = Enum.AnimationPriority.Action4
						Track:Play(0, 255, 1)
						task_wait()
						Track.TimePosition = 0.837
						task_wait()
						Track:AdjustSpeed(0)
						Storage.Anti_Aim_Animation = Track
					end
				end

				for _, Connection in next, getconnections(Humanoid:GetPropertyChangedSignal("HipHeight")) do
					if Connection.Function then
						Connection:Disable()
					end
				end

				Humanoid.HipHeight = 1
			end
		end
	end)))

	Storage.Routines[_nextKey(Storage.Routines, "AutoTrinket")] = Cleaner(task_spawn(LPH_JIT_MAX(function()
		local Remote = Net:RemoteFunction("Trinket")
		local PawnShopZone = workspace:WaitForChild("GunIgnore"):WaitForChild("Pawn Shop") :: Part

		while task.wait(10) do
			if not G_Toggle("TrinketFarm") then
				continue
			end

			local Trinkets = workspace:WaitForChild("Dropped"):WaitForChild("Trinkets"):GetChildren()

			for _, Trinket in next, Trinkets do
				if Trinket.Transparency ~= 1 then
					task.defer(function()
						print("Picking up trinket:", Trinket.Name)
						Remote:InvokeServer(Trinket)
					end)
				end
			end

			local TrinketInventoryItems = Utils.GetItemsByName("Trinket")

			if #TrinketInventoryItems > 0 then
				-- Check how far we are from the pawn shop
				local Character = AssertCharacter()
				local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: Part
				if (HumanoidRootPart.Position - PawnShopZone.Position).Magnitude > 50 then
					Utils.TP(PawnShopZone)
				end

				for _, Trinket in next, TrinketInventoryItems do
					print("Selling trinket:", Trinket.Value)
					Utils.PawnItem(Trinket)
				end
			end
		end
	end)))

	Storage.Routines[_nextKey(Storage.Routines, "CrateMoverFarm")] = Cleaner(task_spawn(LPH_JIT_MAX(function()
		local Remote = Net:RemoteEvent("Job")

		local function HasJob()
			return AssertCharacter():FindFirstChild("Construction")
		end

		local function HasCrate()
			-- Check if we have "Crate" in our character or backpack
			local Character = AssertCharacter()
			if Character:FindFirstChild("Crate") then
				return true
			end
			local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
			if Backpack and Backpack:FindFirstChild("Crate") then
				return true
			end
			return false
		end

		local function EquipCrate()
			local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
			if Backpack then
				local Crate = Backpack:FindFirstChild("Crate")
				if Crate then
					local Humanoid = AssertCharacter():FindFirstChildOfClass("Humanoid")
					if Humanoid then
						Humanoid:EquipTool(Crate)
						return true
					end
				end
			end
			return false
		end

		local function IsCrateEquipped()
			local Character = AssertCharacter()
			return Character:FindFirstChild("Crate") ~= nil
		end

		local JobStart = Vector3.new(21, 6, 237)
		local CratePickup = Vector3.new(10, 6, 231)
		local CrateDropoff = Vector3.new(-55, 6, 208)

		while task.wait() do
			if not G_Toggle("CrateMoverFarm") then
				continue
			end

			-- Printer/Baker farm has priority: disable CrateMover auto-deposit while money-printing farms are running.
			if G_Toggle("CrateMoverFarmAutoDeposit") and not ((G_Toggle("PrinterFarm") and G_Toggle("PrinterFarmAutoDeposit")) or (G_Toggle("BakerFarm") and G_Toggle("BakerFarmAutoDeposit"))) then
				local Cash = Utils.GetCash()
				if Cash and Cash > 0 then
					Utils.Deposit(Cash)
				end
			end

			if not HasJob() then
				Utils.TP(JobStart)
				task.wait(1)
				Remote:FireServer("Start", "Crate")
				continue
			end

			local Character = AssertCharacter()
			local Pivot = Character:GetPivot()

			if (Pivot.Position - JobStart).Magnitude > 50 and (Pivot.Position - CrateDropoff).Magnitude > 50 then
				Utils.TP(JobStart)
				task.wait(1)
				continue
			end

			if HasCrate() then
				-- Ensure crate is equipped before dropping off
				if not IsCrateEquipped() then
					if EquipCrate() then
						task.wait(0.5) -- Wait for the tool to equip
					else
						continue
					end
				end

				Utils.LerpTP(CrateDropoff, (Pivot.Position - CrateDropoff).Magnitude / 35)
				WaitForPing()
				Remote:FireServer("Event", "Crate", "Truck")
			else
				Utils.LerpTP(CratePickup, (Pivot.Position - CratePickup).Magnitude / 35)
				WaitForPing()
				Remote:FireServer("Event", "Crate", "TakeCrate")
			end
		end
	end)))

	Storage.Routines[_nextKey(Storage.Routines, "PrinterFarm")] = Cleaner(task_spawn(LPH_JIT_MAX(function()
		local PrinterEvent = Net:RemoteEvent("PrinterEvent")
		local ShopEvent = Net:RemoteFunction("NormalShopFunction")
		local InventoryEvent = Net:RemoteEvent("InventoryEvent")
		local IllegalShopDataTable =
			require(ReplicatedStorage.Modules.Client.Controllers.ShopController.Shops.Illegal :: ModuleScript)

		while task.wait(1) do
			if not G_Toggle("PrinterFarm") then
				continue
			end

			local CooldownTime = Data:Get({
				"Printer",
				"CooldownTime",
			})

			local CooldownStart = Data:Get({
				"Printer",
				"CooldownStart",
			})

			if os.time() - CooldownTime < CooldownStart then
				if Storage["PrinterStatusLabel"] then
					Storage["PrinterStatusLabel"]:SetText(
						"Printer is on cooldown (" .. tostring(math.round(CooldownTime - (os.time() - CooldownStart))) .. "s left)"
					)
				end
				continue
			end

			local InkNames = {
				[1] = "Large Ink",
				[2] = "Medium Ink",
				[3] = "Small Ink",
			}

			local HasInk = false
			for _, InkName in next, InkNames do
				local Items = Utils.GetItemsByName(InkName)
				if #Items > 0 then
					HasInk = true
					break
				end
			end
			if not HasInk then
				for _, v in ipairs(InkNames) do
					local Cost = IllegalShopDataTable.Items[v].Cost
					local Cash = Utils.GetCash()
					if Cash < Cost then
						local Bank = Utils.GetBank()
						if Bank and Bank > 0 then
							local Needed = Cost - Cash
							local ToWithdraw = math.min(Needed, Bank)
							Utils.Withdraw(ToWithdraw)
							WaitForPing()
							Cash = Utils.GetCash()
						end
					end
					if Cash >= Cost then
						local Result = ShopEvent:InvokeServer("Illegal", v)
						if Result == "Success" then
							break
						end
					end
				end
			end

			HasInk = false
			for _, InkName in next, InkNames do
				local Items = Utils.GetItemsByName(InkName)
				if #Items > 0 then
					HasInk = true
					break
				end
			end
			if not HasInk then
				continue
			end

			local Printer = LocalPlayer:FindFirstChild("Printer")
			if not Printer then
				continue
			end

			local PrinterSlot = Printer["1"] :: StringValue

			if not PrinterSlot.Value or PrinterSlot.Value == "" then
				for _, InkName in next, InkNames do
					local Items = Utils.GetItemsByName(InkName)
					if #Items > 0 then
						InventoryEvent:FireServer("Transfer", Items[1], Printer)
					end
				end
			end

			if PrinterSlot.Value and PrinterSlot.Value ~= "" then
				if Storage["PrinterStatusLabel"] then
					Storage["PrinterStatusLabel"]:SetText("Printing!")
				end
				PrinterEvent:FireServer("Use")
				task.wait(0.5)
				for i = 1, 5 do
					PrinterEvent:FireServer("Print", true)
					task.wait(0.3)
				end
			end

			if G_Toggle("PrinterFarmAutoDeposit") then
				local Cash = Utils.GetCash()
				if Cash and Cash > 0 then
					Utils.Deposit(Cash)
				end
			end
		end
	end)))

	Storage.Routines[_nextKey(Storage.Routines, "BakerFarm")] = Cleaner(task_spawn(LPH_JIT_MAX(function()
		local BakerEvent = Net:RemoteFunction("BakerEvent")
		local ShopEvent = Net:RemoteFunction("NormalShopFunction")
		local IllegalShopDataTable =
			require(ReplicatedStorage.Modules.Client.Controllers.ShopController.Shops.Illegal :: ModuleScript)

		local FlourPriority = {
			"Luxurious Flour",
			"Premium Flour",
			"High-Quality Flour",
			"Standard Flour",
		}

		local function HasCookiePacket(): boolean
			local Items = Utils.GetItemsByName("Cookie Packet")
			return #Items > 0
		end

		local function HasAnyFlour(): boolean
			local Inventory = LocalPlayer:FindFirstChild("Inventory")
			if not Inventory then
				return false
			end
			for _, item in ipairs(Inventory:GetChildren()) do
				local val = (item :: any).Value
				if type(val) == "string" and string.sub(val, -5) == "Flour" then
					return true
				end
			end
			return false
		end

		local function TryBuy(itemName: string): boolean
			local shopItem = IllegalShopDataTable.Items[itemName]
			if not shopItem then
				return false
			end
			local cost = shopItem.Cost
			local cash = Utils.GetCash()
			if cash < cost then
				local bank = Utils.GetBank()
				if bank and bank > 0 then
					local needed = cost - cash
					local toWithdraw = math.min(needed, bank)
					Utils.Withdraw(toWithdraw)
					WaitForPing()
					cash = Utils.GetCash()
				end
			end
			if cash >= cost then
				local result = ShopEvent:InvokeServer("Illegal", itemName)
				return result == "Success"
			end
			return false
		end

		while task.wait(1) do
			if not G_Toggle("BakerFarm") then
				continue
			end

			-- Respect cooldown if present in Data
			local ok, cooldownTime = pcall(function()
				return Data:Get({ "Baker", "CooldownTime" })
			end)
			local ok2, cooldownStart = pcall(function()
				return Data:Get({ "Baker", "CooldownStart" })
			end)
			if ok and ok2 and type(cooldownTime) == "number" and type(cooldownStart) == "number" then
				if os.time() - cooldownTime < cooldownStart then
					if Storage["BakerStatusLabel"] then
						Storage["BakerStatusLabel"]:SetText(
							"Baker is on cooldown (" .. tostring(math.round(cooldownTime - (os.time() - cooldownStart))) .. "s left)"
						)
					end
					continue
				end
			end

			-- Ensure ingredients: Cookie Packet + any Flour
			if not HasCookiePacket() then
				if not TryBuy("Cookie Packet") then
					if Storage["BakerStatusLabel"] then
						Storage["BakerStatusLabel"]:SetText("Failed to buy Cookie Packet")
					end
					continue
				end
			end

			if not HasAnyFlour() then
				local bought = false
				for _, flour in ipairs(FlourPriority) do
					if TryBuy(flour) then
						bought = true
						break
					end
				end
				if not bought then
					if Storage["BakerStatusLabel"] then
						Storage["BakerStatusLabel"]:SetText("Failed to buy Flour")
					end
					continue
				end
			end

			-- Start -> Finish -> End sequence
			if Storage["BakerStatusLabel"] then
				Storage["BakerStatusLabel"]:SetText("Cooking!")
			end
			local started = BakerEvent:InvokeServer("Start")
			if not started then
				if Storage["BakerStatusLabel"] then
					Storage["BakerStatusLabel"]:SetText("Start failed")
				end
				continue
			end

			task.wait(10) -- Wait for cooking time

			-- Emulate in-minigame behavior: Finish may be fired multiple times rapidly as the
			-- client crosses the package completion threshold across frames.
			for i = 1, 10 do
				BakerEvent:InvokeServer("Finish")
				task.wait()
			end

			-- Close out the job slightly after finishes
			task.wait(0.3)

			task.spawn(function()
				pcall(function()
					BakerEvent:InvokeServer("End")
				end)
			end)

			if G_Toggle("BakerFarmAutoDeposit") then
				local Cash = Utils.GetCash()
				if Cash and Cash > 0 then
					Utils.Deposit(Cash)
				end
			end
		end
	end)))

	Storage.Connections[_nextKey(Storage.Connections, "Heartbeat_MoveBoost")] =
		Cleaner(RunService.Heartbeat:Connect(LPH_JIT_MAX(function(DeltaTime)
			local Character = AssertCharacter()
			local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
			local MoveDirection = Humanoid and Humanoid.MoveDirection or Vector3.zero

			if Humanoid then
				if Humanoid:GetState() == Enum.HumanoidStateType.Climbing then
					MoveDirection = Vector3.zero
				end

				if MoveDirection.Magnitude > 0 then
					local SpeedBoost = G_Option("SpeedBoost")
					if SpeedBoost > 0 then
						Character:TranslateBy(MoveDirection * DeltaTime * SpeedBoost * 2.5)
					end
				end
			end
		end)))

	Storage.Connections[_nextKey(Storage.Connections, "Stepped_Noclip")] = Cleaner(RunService.Stepped:Connect(function()
		local Character = AssertCharacter()

		if G_Toggle("Noclip") then
			for _, Descendant in next, Character:GetDescendants() do
				if Descendant:IsA("BasePart") then
					Descendant.CanCollide = false
				end
			end
		elseif G_Toggle("Invisibility") then
			for _, Descendant in next, Character:GetDescendants() do
				if Descendant:IsA("BasePart") and Descendant.Name ~= "HumanoidRootPart" then
					Descendant.CanCollide = false
				end
			end
		else
			local Torso = Character:FindFirstChild("UpperTorso")
			if Torso then
				Torso.CanCollide = true
			end
		end
	end))

	--#endregion

	HookMgr.RegisterHook("NamecallHook", HookMgr.GameMT.__namecall, function(Old, ...)
		-- Intercept all RemoteEvent:FireServer calls to adjust gun shots for silent aim
		if checkcaller() then
			-- Avoid recursion on our own calls
			return Old(...)
		end

		local Method = getnamecallmethod()

		local Args = { ... }
		local Self = table.remove(Args, 1)

		if Method == "FireServer" then
			local RemoteName = (Self :: any).Name
			local Kind = Args[1]
			local isGunRemote = RemoteName == "RE/GunRemote"

			-- print(isGunRemote, RemoteName, Kind)

			if isGunRemote and Kind == "Shoot" and G_Toggle("SilentAimEnabled") then
				local Target: Model? = Aiming_Library.CurrentTarget
				if Target then
					-- print("Silent aim engaged on target:", Target.Name)
					-- Hit chance handling
					local miss = false

					pcall(function()
						miss = Aiming_Library.ShouldMiss and Aiming_Library.ShouldMiss() or false
					end)

					if not miss then
						-- Choose target part from setting
						local desired = nil
						pcall(function()
							desired = G_Option_NYield("SilentAimPart")
						end)
						desired = desired or "UpperTorso"
						local hitPart: BasePart? = game.FindFirstChild((Target :: any), desired) :: BasePart
						if not hitPart then
							hitPart = (
								game.FindFirstChild((Target :: any), "HumanoidRootPart")
								or game.FindFirstChild((Target :: any), "UpperTorso")
								or game.FindFirstChild((Target :: any), "Head")
							) :: BasePart
						end

						if hitPart then
							local hitPos = (hitPart :: BasePart).Position

							local finalNormal: Vector3? = nil
							local finalMaterial: Enum.Material? = nil
							local origin = (Camera and Camera.CFrame.Position) or Vector3.new()

							-- Approximate surface normal for the contact
							local function approxNormal(part: BasePart, point: Vector3): Vector3
								local cf, size = part.CFrame, part.Size
								if size.Magnitude <= 0 then
									return (point - cf.Position).Unit
								end
								local rel = cf.PointToObjectSpace(cf, point)
								local hx, hy, hz = size.X * 0.5, size.Y * 0.5, size.Z * 0.5
								local dx, dy, dz =
									math.abs(rel.X / (hx > 0 and hx or 1)),
									math.abs(rel.Y / (hy > 0 and hy or 1)),
									math.abs(rel.Z / (hz > 0 and hz or 1))
								if dx >= dy and dx >= dz then
									return cf.RightVector * (rel.X >= 0 and 1 or -1)
								elseif dy >= dx and dy >= dz then
									return cf.UpVector * (rel.Y >= 0 and 1 or -1)
								else
									return cf.LookVector * (rel.Z >= 0 and 1 or -1)
								end
							end

							local normal = finalNormal or approxNormal(hitPart :: BasePart, hitPos)
							local material = finalMaterial or (hitPart :: BasePart).Material

							-- Rewrite payload indices: 2..5 are (Part, Position, Normal, Material)
							Args[2] = hitPart
							Args[3] = hitPos
							Args[4] = normal
							Args[5] = material

							if G_Toggle("Wallbang") then
								-- print('wallbang override')
								Args[3] = Vector3.new(0 / 0, 0 / 0, 0 / 0)
							end

							-- Optional visualization
							pcall(function()
								if G_Toggle_NYield("VisualizeBullets") then
									local origin = Camera and Camera.CFrame.Position or Vector3.new()
									task.spawn(VisualizeRay, origin, hitPos)
								end
							end)
						end
					end
				end
			end

			return Old(Self, unpack(Args))
		elseif G_Toggle("VehicleModificationEnabled") and (Method == "GetAttribute") then
			-- dbgprint("GetAttribute called with", ...)
			local AttributeName = Args[2]
			if Self.Parent and game.HasTag(Self.Parent, "Vehicle") then
				for _, Attribute in next, Storage.Vehicle_Attributes do
					if AttributeName == Attribute.Name and Attribute.Type == "number" then
						return G_Option("VehicleMods_" .. AttributeName)
					end
				end
			end
		end

		return Old(...)
	end)

	--#region Hooks

	-- Crate unbox hook
	do
		local CrateUnboxModule = SafeRequire(ReplicatedStorage.Modules.Client.Modules.ShopHandler.Crates.CrateUnbox)
		local Notify = SafeRequire(ReplicatedStorage.Modules.Client.Modules.Notify)

		HookMgr.RegisterHook(
			"CrateUnboxHook",
			CrateUnboxModule.CrateUnbox,
			function(Original, CrateModel, ItemWon, isTerminated, CrateData)
				-- Check if the user has enabled the skip feature.
				if G_Toggle and G_Toggle("SkipCrate") then
					-- Immediately notify the player of the item they won.
					-- The ItemWon argument contains the name of the item.
					secure_call(Notify.bottom, "You unboxed: " .. ItemWon)

					-- By returning here, we skip the original function's entire animation sequence.
					-- The calling script (ShopHandler) will then proceed with its cleanup logic
					-- as if the animation had finished instantly.
					return
				end

				-- If the skip toggle is off, run the original CrateUnbox function.
				return Original(CrateModel, ItemWon, isTerminated, CrateData)
			end
		)
	end

	--#endregion

	--#region UI Initialization

	Library.RiskColor = Color3.new(0.960784, 0.592157, 0.376471)

	Library.Scheme = {
		BackgroundColor = Color3.fromRGB(29, 29, 46),
		MainColor = Color3.fromRGB(48, 45, 65),
		AccentColor = Color3.fromRGB(159, 120, 149),
		OutlineColor = Color3.fromRGB(67, 61, 87),
		FontColor = Color3.fromRGB(217, 224, 238),
		Font = Font.fromEnum(Enum.Font.BuilderSans),
		Red = Color3.new(0.960784, 0.592157, 0.376471),
		Dark = Color3.new(0, 0, 0),
		White = Color3.new(1, 1, 1),
	}

	Cleaner.GetCleanEvent():Connect(function()
		Library:Unload()
		ESP_Library.Unload()
		pcall(sethiddenproperty, Lighting, "Technology", Enum.Technology.Future)
		Lighting.GlobalShadows = true
	end)

	local Window = Library:CreateWindow({
		Title = "Sasware",
		Center = true,
		AutoShow = true,
		Footer = T("Version: " .. Version .. " | " .. SubVersion),
		Icon = 113209211300754,
		DisableSearch = true,
		CornerRadius = 12,
	})

	local Tabs = {
		Main = Window:AddTab(T("Main"), "combine", T("General features and utilities")),
		Automation = Window:AddTab(T("Automation"), "git-compare-arrows", T("Automated jobs and tasks")),
		Combat = Window:AddTab(T("Combat"), "crosshair", T("Combat features and utilities")),
		Teleports = Window:AddTab(T("Teleports"), "milestone", T("Teleport locations and server utilities")),
		Visuals = Window:AddTab(T("Visuals"), "eye", T("Visual enhancements and effects")),
		InventoryViewer = Window:AddTab(T("Inventory Viewer"), "package-open", T("View and manage your inventory")),
		Settings = Window:AddTab(T("Settings"), "cog", T("Configure your preferences and settings")),
	}

	if DEBUGGING or true then
		Tabs.Debug = Window:AddTab("Debug", "bug", T("Debugging tools and information"))
	end

	if FREE_BUILD then
		Tabs.Full_Build = Window:AddTab(T("Unlock Features"))
		local PurchaseInformation = Tabs.Full_Build:AddLeftGroupbox(T("Information"))
		PurchaseInformation:AddLabel(T("This is a free build of Sasware."))
		PurchaseInformation:AddLabel(T("It has limited features."))
		PurchaseInformation:AddLabel(T("If you want the full build,"))
		PurchaseInformation:AddLabel(T("You can donate to unlock it."))
		local PurchaseSites = Tabs.Full_Build:AddRightGroupbox(T("Get Full Build"))
		PurchaseSites:AddLabel(T("Get the full build at:"))
		PurchaseSites:AddLabel("https://blockspinscript.com/script")
		PurchaseSites:AddLabel(T("Or join the discord at:"))
		PurchaseSites:AddLabel("https://discord.gg/6qCymXqa2u")
	end

	-- Main tab

	local UtilitiesGroup = Tabs.Main:AddLeftGroupbox(T("Utilities"))
	local AssetsGroup = Tabs.Main:AddLeftGroupbox(T("Assets"))

	local function FormatMoney(value: any): string
		if type(value) ~= "number" then
			return "N/A"
		end
		local negative = value < 0
		local n = math.floor(math.abs(value))
		local s = tostring(n)
		local rev = string.reverse(s)
		local withCommas = rev:gsub("(%d%d%d)", "%1,")
		withCommas = string.reverse(withCommas)
		withCommas = withCommas:gsub("^,", "")
		return (negative and "-" or "") .. withCommas
	end

	local function CountContainerItems(container: Instance?): number
		if not container then
			return 0
		end
		local count = 0
		for _, child in ipairs(container:GetChildren()) do
			if child:IsA("StringValue") then
				local value = child.Value
				if value and value ~= "" and value ~= "Fists" then
					count += 1
				end
			end
		end
		return count
	end

	local function HasEmptySlotInContainer(container: Instance?): boolean
		if not container then
			return false
		end

		local attrNames = { "Slots", "MaxSlots", "Capacity", "MaxItems" }
		for _, attrName in ipairs(attrNames) do
			local attrValue = container:GetAttribute(attrName)
			if type(attrValue) == "number" and attrValue > 0 then
				return CountContainerItems(container) < math.floor(attrValue)
			end
		end

		local sawSlot = false
		for _, child in ipairs(container:GetChildren()) do
			if child:IsA("StringValue") then
				sawSlot = true
				local value = child.Value
				if value == nil or value == "" or value == "Fists" then
					return true
				end
			end
		end

		if not sawSlot then
			return true
		end
		return false
	end

	local InventoryEventRemote: RemoteEvent? = nil
	pcall(function()
		InventoryEventRemote = Net:RemoteEvent("InventoryEvent")
	end)

	local function GetTransferAmount(): number?
		local raw: any = nil
		pcall(function()
			if Library and Library.Options and Library.Options.AssetsTransferAmount then
				raw = Library.Options.AssetsTransferAmount.Value
			end
		end)

		local amount = nil
		if type(raw) == "number" then
			amount = raw
		elseif type(raw) == "string" then
			amount = tonumber(raw)
		end

		if type(amount) ~= "number" then
			return nil
		end

		amount = math.floor(amount)
		if amount <= 0 then
			return nil
		end
		return amount
	end

	Storage.AssetsCashLabel = AssetsGroup:AddLabel(T("Cash: ") .. "N/A")
	Storage.AssetsBankLabel = AssetsGroup:AddLabel(T("Bank: ") .. "N/A")
	Storage.SafeInfoLabel = AssetsGroup:AddLabel(T("Inventory items: 0 | Safe items: 0"))

	AssetsGroup:AddDivider()

	AssetsGroup:AddInput("AssetsTransferAmount", {
		Text = T("Amount"),
		Default = "0",
		Numeric = true,
		Finished = true,
		Tooltip = T("Amount to deposit/withdraw"),
		Placeholder = T("0"),
	})

	AssetsGroup:AddButton({
		Text = T("Deposit Amount"),
		Func = function()
			local amount = GetTransferAmount()
			if not amount then
				SafeNotify(T("Enter a valid deposit amount."))
				return
			end

			local cash = Utils.GetCash()
			if type(cash) ~= "number" or cash <= 0 then
				SafeNotify(T("You have no cash to deposit."))
				return
			end

			amount = math.min(amount, math.floor(cash))
			pcall(function()
				Utils.Deposit(amount)
			end)
			WaitForPing()
		end,
	})

	AssetsGroup:AddButton({
		Text = T("Withdraw Amount"),
		Func = function()
			local amount = GetTransferAmount()
			if not amount then
				SafeNotify(T("Enter a valid withdraw amount."))
				return
			end

			local bank = Utils.GetBank()
			if type(bank) ~= "number" or bank <= 0 then
				SafeNotify(T("You have no bank balance to withdraw."))
				return
			end

			amount = math.min(amount, math.floor(bank))
			pcall(function()
				Utils.Withdraw(amount)
			end)
			WaitForPing()
		end,
	})

	AssetsGroup:AddDivider()

	AssetsGroup:AddButton({
		Text = T("Deposit All Cash"),
		Func = function()
			local cash = Utils.GetCash()
			if type(cash) ~= "number" or cash <= 0 then
				SafeNotify(T("You have no cash to deposit."))
				return
			end
			pcall(function()
				Utils.Deposit(math.floor(cash))
			end)
			WaitForPing()
		end,
	})

	AssetsGroup:AddButton({
		Text = T("Withdraw All Bank"),
		Func = function()
			local bank = Utils.GetBank()
			if type(bank) ~= "number" or bank <= 0 then
				SafeNotify(T("You have no bank balance to withdraw."))
				return
			end
			pcall(function()
				Utils.Withdraw(math.floor(bank))
			end)
			WaitForPing()
		end,
	})

	Storage.Routines[_nextKey(Storage.Routines, "AssetsBalanceLabels")] = Cleaner(task_spawn(LPH_JIT_MAX(function()
		while task_wait(0.5) do
			local cash = nil
			local bank = nil
			pcall(function()
				cash = Utils.GetCash()
				bank = Utils.GetBank()
			end)
			if Storage.AssetsCashLabel then
				Storage.AssetsCashLabel:SetText(T("Cash: ") .. FormatMoney(cash))
			end
			if Storage.AssetsBankLabel then
				Storage.AssetsBankLabel:SetText(T("Bank: ") .. FormatMoney(bank))
			end
			local inventory = LocalPlayer:FindFirstChild("Inventory")
			local safe = LocalPlayer:FindFirstChild("Safe")
			local invCount = CountContainerItems(inventory)
			local safeCount = CountContainerItems(safe)
			if Storage.SafeInfoLabel then
				Storage.SafeInfoLabel:SetText(T("Inventory items: ") .. tostring(invCount) .. T(" | Safe items: ") .. tostring(safeCount))
			end
		end
	end)))

	local RefreshRemoteInventoryUI
	local ToggleRemoteInventoryUI
	local ProcessRemoteInventoryQueue
	local ClearRemoteInventoryQueue
	local EnsureSafeCheckoutLocation

	Storage.RemoteInventoryQueue = Storage.RemoteInventoryQueue or {}
	Storage.RemoteInventoryLastCounts = Storage.RemoteInventoryLastCounts or { Inventory = 0, Safe = 0 }
	Storage.RemoteInventoryReturnPivot = Storage.RemoteInventoryReturnPivot or nil
	Storage.SafeCheckoutLocation = Storage.SafeCheckoutLocation or nil
	Storage.SafeCheckoutModel = Storage.SafeCheckoutModel or nil
	Storage.SafeCheckoutApartment = Storage.SafeCheckoutApartment or nil

	local function ResolveSafePivot(instance: Instance?): CFrame?
		if not instance then
			return nil
		end
		if instance:IsA("Model") then
			local ok, pivot = pcall(function()
				return instance:GetPivot()
			end)
			if ok then
				return pivot
			end
			local primary = instance.PrimaryPart
			if primary then
				return primary.CFrame
			end
		elseif instance:IsA("BasePart") then
			return instance.CFrame
		end
		local basePart = instance:FindFirstChildWhichIsA("BasePart")
		if basePart then
			return basePart.CFrame
		end
		return nil
	end

	local function LocateOwnedSafe()
		local apartments = workspace:FindFirstChild("Apartments")
		if not apartments then
			return nil, nil
		end
		for _, apartment in ipairs(apartments:GetChildren()) do
			local ownerValue = apartment:FindFirstChild("Owner")
			if ownerValue and ownerValue:IsA("StringValue") then
				local ownerName = ownerValue.Value
				if ownerName and (ownerName == LocalPlayer.Name or ownerName == LocalPlayer.DisplayName) then
					local safeInstance = apartment:FindFirstChild("Safe")
					if safeInstance then
						return safeInstance, apartment
					end
				end
			end
		end
		return nil, nil
	end

	EnsureSafeCheckoutLocation = function(): CFrame?
		local pivot = ResolveSafePivot(Storage.SafeCheckoutModel)
		if not pivot then
			local safeInstance, apartment = LocateOwnedSafe()
			if safeInstance then
				pivot = ResolveSafePivot(safeInstance)
				if pivot then
					Storage.SafeCheckoutModel = safeInstance
					Storage.SafeCheckoutApartment = apartment
				end
			end
		end
		if pivot then
			Storage.SafeCheckoutLocation = pivot
			return pivot
		end
		Storage.SafeCheckoutModel = nil
		Storage.SafeCheckoutApartment = nil
		Storage.SafeCheckoutLocation = nil
		return nil
	end

	local function GetRemoteInventoryQueue()
		local queue = Storage.RemoteInventoryQueue
		if not queue then
			queue = {}
			Storage.RemoteInventoryQueue = queue
		end
		return queue
	end

	local function IsSlotAlreadyQueued(slot: Instance?): boolean
		local queue = Storage.RemoteInventoryQueue
		if not queue or not slot then
			return false
		end
		for _, entry in ipairs(queue) do
			if entry.Slot == slot then
				return true
			end
		end
		return false
	end

	local function UpdateRemoteInventoryStatusText(invCount: number?, safeCount: number?)
		if invCount ~= nil then
			Storage.RemoteInventoryLastCounts.Inventory = invCount
		end
		if safeCount ~= nil then
			Storage.RemoteInventoryLastCounts.Safe = safeCount
		end
		local refs = Storage.RemoteInventoryUIRefs
		if refs and refs.StatusLabel then
			local safeReady = Storage.SafeCheckoutLocation ~= nil
			if not safeReady then
				safeReady = EnsureSafeCheckoutLocation() ~= nil
			end
			local queueCount = #(Storage.RemoteInventoryQueue or {})
			local invDisplay = Storage.RemoteInventoryLastCounts.Inventory or 0
			local safeDisplay = Storage.RemoteInventoryLastCounts.Safe or 0
			local safeText = safeReady and T("Ready") or T("Missing")
			refs.StatusLabel.Text = string.format(
				T("Inventory: %d  |  Safe: %d  |  Queue: %d  |  Safe Ready: %s"),
				invDisplay,
				safeDisplay,
				queueCount,
				safeText
			)
		end
	end

	local function QueueTransferRequest(slot: StringValue, itemName: string, sourceContainer: Instance?, destinationContainer: Instance?)
		if not slot or not sourceContainer or not destinationContainer then
			SafeNotify(T("Inventory containers unavailable."))
			return
		end
		local destinationName = destinationContainer.Name
		local destinationLabel = destinationName
		if destinationName == "Safe" then
			destinationLabel = T("Safe")
		elseif destinationName == "Inventory" then
			destinationLabel = T("Inventory")
		end
		if IsSlotAlreadyQueued(slot) then
			SafeNotify(T("That item is already queued."))
			return
		end
		local queue = GetRemoteInventoryQueue()
		table.insert(queue, {
			Slot = slot,
			ItemName = itemName,
			SourceName = sourceContainer.Name,
			DestinationName = destinationName,
			Processed = false,
		})
		UpdateRemoteInventoryStatusText()
		SafeNotify(string.format(T("Queued %s for %s."), itemName, destinationLabel))
	end

	local function ResolveQueuedSlot(entry)
		local slot = entry.Slot
		if slot and slot.Parent then
			return slot
		end
		local sourceContainer = LocalPlayer:FindFirstChild(entry.SourceName)
		if not sourceContainer then
			return nil
		end
		for _, child in ipairs(sourceContainer:GetChildren()) do
			if child:IsA("StringValue") and child.Value == entry.ItemName then
				return child
			end
		end
		return nil
	end

	local function CollectContainerSlots(container: Instance?): { { Slot: StringValue, Name: string, Container: Instance } }
		local items = {}
		if not container then
			return items
		end
		local children = container:GetChildren()
		table.sort(children, function(a, b)
			return tostring(a.Name) < tostring(b.Name)
		end)
		for _, child in ipairs(children) do
			if child:IsA("StringValue") then
				local value = child.Value
				if value and value ~= "" and value ~= "Fists" then
					table.insert(items, {
						Slot = child,
						Name = value,
						Container = container,
					})
				end
			end
		end
		return items
	end

	local function TransferSlotToContainer(slot: StringValue, destination: Instance, destinationLabel: string)
		if not InventoryEventRemote then
			SafeNotify(T("Inventory remote unavailable."))
			return false
		end
		if not slot or not destination then
			SafeNotify(T("Transfer destination unavailable."))
			return false
		end
		local ok, err = pcall(function()
			InventoryEventRemote:FireServer("Transfer", slot, destination)
		end)
		if not ok then
			warn("Inventory transfer failed:", err)
			SafeNotify(T("Failed to transfer item to ") .. destinationLabel .. ".")
			return false
		end
		return true
	end

	ProcessRemoteInventoryQueue = function()
		local queue = GetRemoteInventoryQueue()
		if #queue == 0 then
			SafeNotify(T("No queued transfers."))
			return
		end
		local safeLocation = EnsureSafeCheckoutLocation()
		if not safeLocation then
			SafeNotify(T("Unable to locate your safe automatically. Make sure you own an apartment."))
			return
		end
		local character = AssertCharacter()
		local returnPivot = Utils.CastToCFrame(character:GetPivot())
		Storage.RemoteInventoryReturnPivot = returnPivot
		Utils.TP(safeLocation)
		WaitForPing()
		local processed = 0
		local pending = {}
		for _, entry in ipairs(queue) do
			entry.Processed = false
			table.insert(pending, entry)
		end
		while #pending > 0 do
			local progressed = false
			for i = #pending, 1, -1 do
				local entry = pending[i]
				local sourceContainer = LocalPlayer:FindFirstChild(entry.SourceName)
				local destinationContainer = LocalPlayer:FindFirstChild(entry.DestinationName)
				if not (sourceContainer and destinationContainer) then
					table.remove(pending, i)
					progressed = true
					continue
				end
				if not HasEmptySlotInContainer(destinationContainer) then
					continue
				end
				local slotInstance = ResolveQueuedSlot(entry)
				if slotInstance and TransferSlotToContainer(slotInstance, destinationContainer, entry.DestinationName) then
					entry.Processed = true
					processed += 1
					progressed = true
					table.remove(pending, i)
					task.wait(0.15)
				end
			end
			if not progressed then
				SafeNotify(T("Checkout halted: remaining queued items don't have space yet. Remove items manually or clear the queue."))
				break
			end
		end
		local fallbackPivot = Storage.RemoteInventoryReturnPivot or returnPivot
		Utils.TP(fallbackPivot)
		WaitForPing()
		for i = #queue, 1, -1 do
			if queue[i].Processed then
				table.remove(queue, i)
			end
		end
		UpdateRemoteInventoryStatusText()
		RefreshRemoteInventoryUI()
		if processed > 0 then
			local remaining = #queue
			if remaining > 0 then
				SafeNotify(string.format(T("Checkout moved %d item(s); %d still queued."), processed, remaining))
			else
				SafeNotify(string.format(T("Checkout complete: %d item(s) moved."), processed))
			end
		else
			SafeNotify(T("No queued transfers could be completed."))
		end
	end

	ClearRemoteInventoryQueue = function()
		local queue = GetRemoteInventoryQueue()
		if #queue == 0 then
			return
		end
		table.clear(queue)
		UpdateRemoteInventoryStatusText()
		RefreshRemoteInventoryUI()
		SafeNotify(T("Cleared queued transfers."))
	end

	local function DetermineGuiParent(): Instance
		local ok, result = pcall(function()
			if gethui then
				return gethui()
			end
			return nil
		end)
		if ok and typeof(result) == "Instance" then
			return result
		end
		return CoreGui
	end

	local function EnsureRemoteInventoryUI()
		if Storage.RemoteInventoryUI and Storage.RemoteInventoryUI.Parent then
			return Storage.RemoteInventoryUI
		end

		local parent = DetermineGuiParent()
		local gui = Instance.new("ScreenGui")
		gui.Name = "RemoteInventoryManager"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.Enabled = false
		gui.Parent = parent

		local frame = Instance.new("Frame")
		frame.Name = "Window"
		frame.Size = UDim2.new(0, 540, 0, 360)
		frame.Position = UDim2.new(0.5, -270, 0.4, -180)
		frame.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
		frame.BorderSizePixel = 0
		frame.Active = true
		frame.Draggable = true
		frame.Parent = gui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = frame

		local header = Instance.new("Frame")
		header.Name = "Header"
		header.Size = UDim2.new(1, 0, 0, 36)
		header.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
		header.BorderSizePixel = 0
		header.Parent = frame

		local headerCorner = Instance.new("UICorner")
		headerCorner.CornerRadius = UDim.new(0, 8)
		headerCorner.Parent = header

		local title = Instance.new("TextLabel")
		title.Name = "Title"
		title.Size = UDim2.new(1, -40, 1, 0)
		title.Position = UDim2.new(0, 12, 0, 0)
		title.BackgroundTransparency = 1
		title.Text = T("Remote Inventory Manager")
		title.Font = Enum.Font.BuilderSansBold
		title.TextColor3 = Color3.new(1, 1, 1)
		title.TextSize = 18
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = header

		local close = Instance.new("TextButton")
		close.Name = "Close"
		close.Size = UDim2.new(0, 32, 0, 24)
		close.Position = UDim2.new(1, -36, 0.5, -12)
		close.BackgroundColor3 = Color3.fromRGB(55, 55, 78)
		close.Text = "X"
		close.Font = Enum.Font.BuilderSansBold
		close.TextColor3 = Color3.new(1, 1, 1)
		close.TextSize = 14
		close.Parent = header
		close.MouseButton1Click:Connect(function()
			gui.Enabled = false
		end)

		local body = Instance.new("Frame")
		body.Name = "Body"
		body.BackgroundTransparency = 1
		body.Position = UDim2.new(0, 0, 0, 40)
		body.Size = UDim2.new(1, 0, 1, -96)
		body.Parent = frame

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 8)
		layout.Parent = body

		local function createColumn(titleText: string)
			local column = Instance.new("Frame")
			column.BackgroundColor3 = Color3.fromRGB(38, 38, 54)
			column.Size = UDim2.new(0.5, -12, 1, 0)
			column.BorderSizePixel = 0
			column.Parent = body

			local colCorner = Instance.new("UICorner")
			colCorner.CornerRadius = UDim.new(0, 8)
			colCorner.Parent = column

			local headerLabel = Instance.new("TextLabel")
			headerLabel.Size = UDim2.new(1, -10, 0, 26)
			headerLabel.Position = UDim2.new(0, 8, 0, 6)
			headerLabel.BackgroundTransparency = 1
			headerLabel.Text = titleText
			headerLabel.Font = Enum.Font.BuilderSans
			headerLabel.TextSize = 16
			headerLabel.TextColor3 = Color3.new(1, 1, 1)
			headerLabel.TextXAlignment = Enum.TextXAlignment.Left
			headerLabel.Parent = column

			local list = Instance.new("ScrollingFrame")
			list.Name = "List"
			list.Size = UDim2.new(1, -16, 1, -48)
			list.Position = UDim2.new(0, 8, 0, 38)
			list.BackgroundTransparency = 1
			list.BorderSizePixel = 0
			list.ScrollBarThickness = 4
			list.CanvasSize = UDim2.new(0, 0, 0, 0)
			list.Parent = column

			local listLayout = Instance.new("UIListLayout")
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.Padding = UDim.new(0, 4)
			listLayout.Parent = list

			return list
		end

		local inventoryList = createColumn(T("Inventory"))
		local safeList = createColumn(T("Safe"))

		local statusLabel = Instance.new("TextLabel")
		statusLabel.Name = "StatusLabel"
		statusLabel.Size = UDim2.new(1, -16, 0, 20)
		statusLabel.Position = UDim2.new(0, 8, 1, -60)
		statusLabel.BackgroundTransparency = 1
		statusLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
		statusLabel.TextSize = 14
		statusLabel.Font = Enum.Font.BuilderSans
		statusLabel.TextXAlignment = Enum.TextXAlignment.Left
		statusLabel.Text = ""
		statusLabel.Parent = frame

		local controls = Instance.new("Frame")
		controls.Name = "Controls"
		controls.Size = UDim2.new(1, -16, 0, 40)
		controls.Position = UDim2.new(0, 8, 1, -36)
		controls.BackgroundTransparency = 1
		controls.Parent = frame

		local controlsLayout = Instance.new("UIListLayout")
		controlsLayout.FillDirection = Enum.FillDirection.Horizontal
		controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		controlsLayout.Padding = UDim.new(0, 6)
		controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		controlsLayout.Parent = controls

		local function createControlButton(text: string, callback: () -> ())
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(0, 180, 1, -6)
			button.BackgroundColor3 = Color3.fromRGB(55, 55, 78)
			button.TextColor3 = Color3.new(1, 1, 1)
			button.Font = Enum.Font.BuilderSans
			button.TextSize = 14
			button.Text = text
			button.AutoButtonColor = true
			button.Parent = controls
			local buttonCorner = Instance.new("UICorner")
			buttonCorner.CornerRadius = UDim.new(0, 6)
			buttonCorner.Parent = button
			button.Activated:Connect(function()
				callback()
			end)
			return button
		end

		createControlButton(T("Checkout Transfers"), function()
			ProcessRemoteInventoryQueue()
		end)

		createControlButton(T("Clear Queue"), function()
			ClearRemoteInventoryQueue()
		end)

		Storage.RemoteInventoryUI = gui
		Storage.RemoteInventoryUIRefs = {
			Gui = gui,
			InventoryList = inventoryList,
			SafeList = safeList,
			StatusLabel = statusLabel,
		}

		UpdateRemoteInventoryStatusText()

		return gui
	end

	local function PopulateItemList(list: ScrollingFrame, items: { { Slot: StringValue, Name: string, Container: Instance } }, actionText: string, sourceContainer: Instance?, destinationContainer: Instance?, destinationName: string)
		for _, child in ipairs(list:GetChildren()) do
			if not child:IsA("UIListLayout") then
				child:Destroy()
			end
		end

		if #items == 0 then
			local empty = Instance.new("TextLabel")
			empty.Size = UDim2.new(1, 0, 0, 20)
			empty.BackgroundTransparency = 1
			empty.Text = T("No items available.")
			empty.TextColor3 = Color3.fromRGB(170, 170, 190)
			empty.TextSize = 14
			empty.Font = Enum.Font.BuilderSans
			empty.Parent = list
			return
		end

		for _, entry in ipairs(items) do
			local slot = entry.Slot
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1, 0, 0, 28)
			button.BackgroundColor3 = Color3.fromRGB(55, 55, 78)
			button.TextColor3 = Color3.new(1, 1, 1)
			button.Font = Enum.Font.BuilderSans
			button.TextSize = 14
			button.AutoButtonColor = true
			button.TextXAlignment = Enum.TextXAlignment.Left
			button.Text = entry.Name
			button.Parent = list

			local padding = Instance.new("UIPadding")
			padding.PaddingLeft = UDim.new(0, 8)
			padding.PaddingRight = UDim.new(0, 4)
			padding.Parent = button

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 6)
			corner.Parent = button

			local function markQueued()
				button.Text = entry.Name .. T(" (Queued)")
				button.BackgroundColor3 = Color3.fromRGB(45, 45, 64)
				button.AutoButtonColor = false
			end

			if IsSlotAlreadyQueued(slot) then
				markQueued()
			end

			button.Activated:Connect(function()
				if IsSlotAlreadyQueued(slot) then
					SafeNotify(T("That item is already queued."))
					return
				end
				local slotInstance = slot
				if not slotInstance or not sourceContainer or not destinationContainer or slotInstance.Parent ~= sourceContainer then
					SafeNotify(T("Item slot is no longer available."))
					return
				end
				QueueTransferRequest(slotInstance, entry.Name, sourceContainer, destinationContainer)
				markQueued()
			end)
		end

		list.CanvasSize = UDim2.new(0, 0, 0, math.max(0, (#items * 32)))
	end

	RefreshRemoteInventoryUI = function()
		local refs = Storage.RemoteInventoryUIRefs
		if not refs then
			return
		end
		local gui = refs.Gui
		if not (gui and gui.Enabled) then
			return
		end
		local playerInventory = LocalPlayer:FindFirstChild("Inventory")
		local playerSafe = LocalPlayer:FindFirstChild("Safe")
		local inventoryItems = CollectContainerSlots(playerInventory)
		local safeItems = CollectContainerSlots(playerSafe)
		if refs.InventoryList then
			PopulateItemList(refs.InventoryList, inventoryItems, T("Click to send to Safe"), playerInventory, playerSafe, "Safe")
		end
		if refs.SafeList then
			PopulateItemList(refs.SafeList, safeItems, T("Click to send to Inventory"), playerSafe, playerInventory, "Inventory")
		end
		UpdateRemoteInventoryStatusText(#inventoryItems, #safeItems)
	end

	ToggleRemoteInventoryUI = function()
		local gui = EnsureRemoteInventoryUI()
		if not gui then
			return
		end
		gui.Enabled = not gui.Enabled
		if gui.Enabled then
			if not EnsureSafeCheckoutLocation() then
				SafeNotify(T("Unable to auto-locate your safe. Make sure you own an apartment."))
			end
			RefreshRemoteInventoryUI()
		end
	end

	Storage.Routines[_nextKey(Storage.Routines, "RemoteInventoryUIRefresh")] = Cleaner(task_spawn(LPH_JIT_MAX(function()
		while task_wait(1) do
			if Storage.RemoteInventoryUI and Storage.RemoteInventoryUI.Enabled then
				RefreshRemoteInventoryUI()
			end
		end
	end)))

	UtilitiesGroup:AddDivider()

	UtilitiesGroup:AddToggle("Anonymizer", {
		Text = T("Anonymize Name"),
		Default = false,
		Tooltip = T("Hides your name (Your screen only!)"),
		Callback = function(Value)
			if Value == false then
				local NameTag =
					AssertCharacter():WaitForChild("Head"):WaitForChild("NameTag", 5):WaitForChild("NameTag", 5)
				if NameTag then
					NameTag.Label.Text = LocalPlayer.DisplayName
					NameTag.Shadow.Text = LocalPlayer.DisplayName
					NameTag.RealName.Text = `@{LocalPlayer.Name}`
					NameTag.RealNameShadow.Text = `@{LocalPlayer.Name}`
				end
			end
		end,
	})

	UtilitiesGroup:AddToggle("SkipCrate", {
		Text = T("Skip Crate Unboxing"),
		Default = false,
		Tooltip = T("Skips the unboxing animation for crates."),
	})

	UtilitiesGroup:AddToggle("PromptSkip", {
		Text = T("Faster Prompts"),
		Default = false,
		Tooltip = T("Makes prompts slightly faster."),
	})

	UtilitiesGroup:AddDivider()

	local CharacterGroup = Tabs.Main:AddRightGroupbox(T("Character"))

	CharacterGroup:AddToggle("Anti-Aimbot", {
		Text = T("Anti-Aimbot"),
		Default = false,
		Tooltip = T("Spoofs your velocity to prevent aimbots from hitting you."),
	}):AddKeyPicker("Anti-Aimbot", {
		Default = "C",
		SyncToggleState = true,
		Mode = "Toggle",
		Text = T("Toggle Anti-Aimbot"),
		NoUI = false,
	})

	CharacterGroup:AddToggle("Noclip", {
		Text = T("Noclip"),
		Default = false,
		Tooltip = T("Enables noclip for the player"),
	})
	CharacterGroup:AddLabel(T("WARNING: Noclip can break anti-aim!"))

	CharacterGroup:AddToggle("FlyJump", {
		Text = T("Fly-Jump"),
		Default = false,
		Tooltip = T("Allows you to jump infinitely"),
	})

	CharacterGroup:AddToggle("WalkFling", {
		Text = T("Walk-Fling"),
		Default = false,
		Tooltip = T("Flings vehicles when you walk into them"),
	}):AddKeyPicker("WalkFling", {
		Default = "Z",
		SyncToggleState = true,
		Mode = "Toggle",
		Text = T("Toggle Walk-Fling"),
		NoUI = false,
	})

	CharacterGroup:AddToggle("Invisibility", {
		Text = T("Invisibility"),
		Default = false,
		Tooltip = T("Makes you invisible."),
		Risky = true,
		Callback = function(Value)
			if not Value then
				local Character = AssertCharacter()
				local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

				if Storage.Anti_Aim_Animation then
					Storage.Anti_Aim_Animation:Stop()
					Storage.Anti_Aim_Animation:Destroy()
					Storage.Anti_Aim_Animation = nil
				end

				if Storage.OldHipHeight then
					Humanoid.HipHeight = Storage.OldHipHeight
					Character:PivotTo(Character:GetPivot() + Vector3.yAxis * (Storage.OldHipHeight - 1))
					Storage.OldHipHeight = nil
				end
			else
				-- Get the difference between the current HipHeight and 1 and teleport down by that much
				local Character = AssertCharacter()
				local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
				local CurrentHipHeight = Humanoid.HipHeight
				Storage.OldHipHeight = CurrentHipHeight
				local Difference = CurrentHipHeight - 1
				Humanoid.HipHeight = 1
				Character:PivotTo(Character:GetPivot() - Vector3.new(0, Difference, 0))
			end
		end,
	}):AddKeyPicker("Invisibility", {
		Default = "X",
		SyncToggleState = true,
		Mode = "Toggle",
		Text = T("Toggle Invisibility"),
		NoUI = false,
	})

	CharacterGroup:AddToggle("RespawnFlashback", {
		Text = T("Respawn Flashback"),
		Default = false,
		Tooltip = T("Automatically teleports you back to where you died after respawning."),
	})

	CharacterGroup:AddToggle("Panic", {
		Text = T("Anti-Kill"),
		Default = false,
		Tooltip = T("Attempts to prevent you from being killed"),
		Risky = true,
	})

	CharacterGroup:AddToggle("InfiniteStamina", {
		Text = T("Infinite Stamina"),
		Default = false,
		Tooltip = T("Prevents your stamina from decreasing"),
	})

	CharacterGroup:AddSlider("SpeedBoost", {
		Text = T("Speed Boost"),
		Default = 0,
		Min = 0,
		Max = 10,
		Rounding = 1,
		Tooltip = T("Sets the player speed"),
	})

	local VehicleModificationsGroup = Tabs.Main:AddRightGroupbox(T("Vehicle Mods"))

	VehicleModificationsGroup:AddToggle("NoCrash", {
		Text = T("Anti-Crash"),
		Default = false,
		Tooltip = T("Disables vehicle crash detection"),
		Disabled = FREE_BUILD,
	})

	VehicleModificationsGroup:AddToggle("VehicleModificationEnabled", {
		Text = T("Enabled"),
		Default = false,
		Tooltip = T("Enables vehicle modification features"),
	})

	for _, Attribute in next, Storage.Vehicle_Attributes do
		if Attribute.Type == "number" then
			VehicleModificationsGroup:AddSlider("VehicleMods_" .. Attribute.Name, {
				Text = T(Attribute.DisplayName),
				Default = Attribute.Min,
				Min = Attribute.Min,
				Max = Attribute.Max,
				Rounding = 2,
				Tooltip = T("Sets the " .. Attribute.Name .. " for vehicles"),
				Callback = function(Value)
					local Vehicles = workspace:FindFirstChild("Cars")
					for _, Vehicle in next, Vehicles:GetChildren() do
						if Vehicle:GetAttribute("owner") == LocalUserId then
							Vehicle.Motors:SetAttribute(Attribute.Name, Value)
						end
					end
				end,
			})
		end
	end

	-- Automation tab

	local InventoryManagementGroup = Tabs.Automation:AddLeftGroupbox(T("Inventory Management"))

	InventoryManagementGroup:AddButton({
		Text = T("Open Remote Inventory Manager"),
		Func = function()
			ToggleRemoteInventoryUI()
		end,
	})

	InventoryManagementGroup:AddButton({
		Text = T("Checkout Queued Transfers"),
		Func = function()
			ProcessRemoteInventoryQueue()
		end,
	})

	InventoryManagementGroup:AddButton({
		Text = T("Clear Transfer Queue"),
		Func = function()
			ClearRemoteInventoryQueue()
		end,
	})

	local AutomationGroup = Tabs.Automation:AddRightGroupbox(T("Automation"))

	AutomationGroup:AddDropdown("SelectedAutofarm", {
		Text = T("Farm Method"),
		Tooltip = T("Select Auto-Farm method."),
		Values = {
			"Crate Mover",
			"Printer Farm",
			"Baker Farm",
		},
		Multi = false,
		Default = 1,
	})

	AutomationGroup:AddToggle("StaminaFarm", {
		Text = T("Stamina-Farm"),
		Default = false,
		Tooltip = T("Uses stamina while farming."),
	})

	local MiscellaneousAutomationGroup = Tabs.Automation:AddRightGroupbox(T("Miscellaneous"))

	MiscellaneousAutomationGroup:AddToggle("TrinketFarm", {
		Text = T("Trinket Farm"),
		Default = false,
		Tooltip = T("Automatically collects and sells trinkets."),
		Disabled = FREE_BUILD,
	})

	--#region Crate Mover options

	local Crate_Mover_Depbox = AutomationGroup:AddDependencyBox(T("Crate Mover"))
	Crate_Mover_Depbox:SetupDependencies({
		{ Library.Options.SelectedAutofarm, "Crate Mover" },
	})

	Crate_Mover_Depbox:AddToggle("CrateMoverFarm", {
		Text = T("Enabled"),
		Default = false,
		Tooltip = T("Automatically does the crate mover job."),
	})

	Crate_Mover_Depbox:AddToggle("CrateMoverFarmAutoDeposit", {
		Text = T("Auto-Deposit"),
		Default = true,
		Tooltip = T("Automatically deposits money earned into the bank."),
	})

	--#endregion

	--#region Printer Farm options

	local Print_Depbox = AutomationGroup:AddDependencyBox(T("Printer Farm"))
	Print_Depbox:SetupDependencies({
		{ Library.Options.SelectedAutofarm, "Printer Farm" },
	})

	Storage.PrinterStatusLabel = Print_Depbox:AddLabel("Printer status: N/A")

	Print_Depbox:AddToggle("PrinterFarm", {
		Text = T("Enabled"),
		Default = false,
		Tooltip = T("Automatically does the printer farm job."),
	})

	Print_Depbox:AddToggle("PrinterFarmAutoDeposit", {
		Text = T("Auto-Deposit"),
		Default = true,
		Tooltip = T("Automatically deposits money earned into the bank."),
	})

	--#endregion

	--#region Baker Farm options

	local Baker_Depbox = AutomationGroup:AddDependencyBox(T("Baker Farm"))
	Baker_Depbox:SetupDependencies({
		{ Library.Options.SelectedAutofarm, "Baker Farm" },
	})

	Storage.BakerStatusLabel = Baker_Depbox:AddLabel("Baker status: N/A")

	Baker_Depbox:AddToggle("BakerFarm", {
		Text = T("Enabled"),
		Default = false,
		Tooltip = T("Automatically does the baker job."),
	})

	Baker_Depbox:AddToggle("BakerFarmAutoDeposit", {
		Text = T("Auto-Deposit"),
		Default = true,
		Tooltip = T("Automatically deposits money earned into the bank."),
	})

	--#endregion

	-- Combat tab

	-- local GunModificationsGroup = Tabs.Combat:AddRightGroupbox(T("Gun Mods"))

	-- local CurrentGun = GunModificationsGroup:AddLabel(T("Current: None"))

	-- GunModificationsGroup:AddToggle("GunModificationEnabled", {
	-- 	Text = T("Enabled"),
	-- 	Default = false,
	-- 	Tooltip = T("Enables gun modification features"),
	-- })

	local MeleeModificationsGroup = Tabs.Combat:AddLeftGroupbox(T("Melee Mods"))

	-- MeleeModificationsGroup:AddToggle("AutoFinish", {
	-- 	Text = "Auto-Finish",
	-- 	Default = false,
	-- 	Tooltip = "Automatically finishes downed players",
	-- 	Disabled = FREE_BUILD,
	-- })

	MeleeModificationsGroup:AddToggle("KillAura", {
		Text = T("Kill-Aura"),
		Default = false,
		Tooltip = T("Automatically attacks players in range"),
	})

	MeleeModificationsGroup:AddToggle("KillAuraFinisher", {
		Text = T("Use Finishers"),
		Default = false,
		Tooltip = T("Randomly uses finisher attacks for extra damage"),
	})

	local SilentAimGroup = Tabs.Combat:AddLeftGroupbox(T("Silent Aim"))

	SilentAimGroup:AddToggle("SilentAimEnabled", {
		Text = T("Enabled"),
		Default = false,
		Tooltip = T("Enables silent aim features"),
		Callback = function(Value)
			if Value then
				Aiming_Library.Enabled = true
			else
				Aiming_Library.Enabled = false
			end
		end,
		Disabled = FREE_BUILD,
		DisabledTooltip = "Silent aim is not available in the free build.",
	})

	SilentAimGroup:AddToggle("Wallbang", {
		Text = T("Wallbang"),
		Default = false,
		Tooltip = T("Enables shooting people through walls"),
		Disabled = FREE_BUILD,
		DisabledTooltip = "Wallbang is not available in the free build.",
	})

	SilentAimGroup:AddToggle("SilentAimFilterFriends", {
		Text = T("Ignore Friends"),
		Default = true,
		Tooltip = T("Ignores friends in aim checks."),
		Callback = function(Value)
			Aiming_Library.FilterFriends = Value
		end,
		Disabled = FREE_BUILD,
		DisabledTooltip = "Silent aim is not available in the free build.",
	})

	SilentAimGroup:AddToggle("SilentAimUseClosest", {
		Text = T("Use Closest to Camera"),
		Default = false,
		Tooltip = T("Uses the closest player to the camera."),
		Callback = function(Value)
			Aiming_Library.ClosestToCamera = Value
		end,
		Disabled = FREE_BUILD,
		DisabledTooltip = "Silent aim is not available in the free build.",
	})

	SilentAimGroup:AddSlider("SilentAimHitChance", {
		Text = T("Hit Chance"),
		Default = 100,
		Min = 0,
		Max = 100,
		Rounding = 0,
		Tooltip = T("Sets the hit chance for silent aim"),
		Callback = function(Value)
			Aiming_Library.HitChance = Value
		end,
		Disabled = FREE_BUILD,
		DisabledTooltip = "Silent aim is not available in the free build.",
	})

	SilentAimGroup:AddSlider("SilentAimFOV", {
		Text = T("Field of View"),
		Default = 60,
		Min = 0,
		Max = 360,
		Rounding = 0,
		Tooltip = T("Sets the field of view for silent aim"),
		Callback = function(Value)
			Aiming_Library.FOV = Value
		end,
		Disabled = FREE_BUILD,
		DisabledTooltip = "Silent aim is not available in the free build.",
	})

	SilentAimGroup:AddToggle("SilentAimCenterFOV", {
		Text = T("Center Field of View"),
		Default = UserInputService:GetDeviceType() == Enum.DeviceType.Phone,
		Tooltip = T("Useful for mobile."),
		Callback = function(Value)
			Aiming_Library.CenterLockFOV = Value
		end,
		Disabled = FREE_BUILD,
		DisabledTooltip = "Silent aim is not available in the free build.",
	})

	SilentAimGroup:AddDropdown("SilentAimPart", {
		Text = T("Part"),
		Default = "Head",
		Values = { "HumanoidRootPart", "UpperTorso", "Head" },
		Tooltip = T("Sets the part to aim at"),
		Disabled = FREE_BUILD,
		DisabledTooltip = "Silent aim is not available in the free build.",
	})

	SilentAimGroup:AddToggle("VisualizeBullets", {
		Text = T("Visualize Bullets"),
		Default = false,
		Disabled = FREE_BUILD,
		DisabledTooltip = "Silent aim is not available in the free build.",
	})

	-- Teleports tab

	local TargetPosition = Vector3.new(0, 0, 0)
	local TeleportsGroup = Tabs.Teleports:AddLeftGroupbox(T("Teleports"))
	local TeleportsList = {}

	for TeleportName, _ in next, Storage.TeleportLocations do
		table.insert(TeleportsList, TeleportName)
	end

	TeleportsGroup:AddDropdown("TeleportPosition", {
		Text = T("Teleport Position"),
		Default = 1,
		Values = TeleportsList,
		Tooltip = T("Select a teleport position"),
		Callback = function(Value)
			local Position = Storage.TeleportLocations[Value]
			if Position then
				TargetPosition = Position
			end
		end,
		Disabled = FREE_BUILD,
	})

	TeleportsGroup:AddButton({
		Text = T("Teleport"),
		Func = function()
			if TargetPosition then
				Utils.TP(TargetPosition)
			end
		end,
		Disabled = FREE_BUILD,
	})

	local SubPlaceTeleportsGroup = Tabs.Teleports:AddRightGroupbox(T("Sub-Place Teleports"))

	SubPlaceTeleportsGroup:AddButton({
		Text = T("Escape Server 2"),
		Func = function()
			game:GetService("TeleportService"):SetTeleportGui(nil :: any)
			settings():GetService("NetworkSettings").IncomingReplicationLag = 1
			queue_on_teleport([[
				local Start = tick()
				while task.wait() do
					pcall(function()
						game:GetService('TeleportService'):SetTeleportGui(
							game:GetService("UserInputService")
						)
						game:GetService('TeleportService'):TeleportCancel()
					end)
					if tick() - Start > 10 then
						break
					end
				end
				game:GetService("NetworkSettings").IncomingReplicationLag = 0
				game:GetService('TeleportService'):SetTeleportGui(nil)
			]])
			TeleportService:Teleport(97809623078844, LocalPlayer)
		end,
		Disabled = (game.PlaceId ~= 96753233087555) or FREE_BUILD,
	})

	-- SubPlaceTeleportsGroup:AddButton({
	-- 	Text = T("Generate Private Server"),
	-- 	Func = function()
	-- 		game:GetService('TeleportService'):SetTeleportGui(nil :: any)
	-- 		settings():GetService("NetworkSettings").IncomingReplicationLag = 1
	-- 		queue_on_teleport([[
	-- 			local Start = tick()
	-- 			while task.wait() do
	-- 				pcall(function()
	-- 					game:GetService('TeleportService'):SetTeleportGui(
	-- 						game:GetService("UserInputService")
	-- 					)
	-- 					game:GetService('TeleportService'):TeleportCancel()
	-- 				end)
	-- 				if tick() - Start > 10 then
	-- 					break
	-- 				end
	-- 			end
	-- 			game:GetService("NetworkSettings").IncomingReplicationLag = 0
	-- 			game:GetService('TeleportService'):SetTeleportGui(nil)
	-- 		]])
	-- 		require('./modules/RS_Gen.luau')()
	-- 	end,
	-- 	Disabled = FREE_BUILD
	-- })

	-- Visuals tab

	local OptimizationsGroup = Tabs.Visuals:AddRightGroupbox(T("Optimizations"))

	OptimizationsGroup:AddToggle("OptimizedLighting", {
		Text = T("Optimize Lighting"),
		Default = false,
		Tooltip = T("Switches lighting technology to a faster preset."),
		Callback = function(Value)
			if Value then
				pcall(sethiddenproperty, Lighting, "Technology", Enum.Technology.Compatibility)
				pcall(sethiddenproperty, Lighting, "LightingStyle", Enum.LightingStyle.Soft)
				pcall(sethiddenproperty, Lighting, "PrioritizeLightingQuality", false)
				Lighting.GlobalShadows = false
			else
				pcall(sethiddenproperty, Lighting, "Technology", Enum.Technology.Future)
				pcall(sethiddenproperty, Lighting, "LightingStyle", Enum.LightingStyle.Realistic)
				pcall(sethiddenproperty, Lighting, "PrioritizeLightingQuality", true)
				Lighting.GlobalShadows = true
			end
		end,
	})

	OptimizationsGroup:AddToggle("LowMeshDetail", {
		Text = T("Optimize Mesh Detail"),
		Default = false,
		Tooltip = T("Switches mesh detail to a lower preset."),
		Callback = function(Value)
			if Value then
				for _, Mesh: MeshPart in next, game:GetDescendants() :: any do
					if Mesh:IsA("MeshPart") then
						Mesh:SetAttribute("OriginalRenderFidelity", tostring(Mesh.RenderFidelity.Name))
						Mesh.RenderFidelity = Enum.RenderFidelity.Performance
						if Mesh.CollisionFidelity == Enum.CollisionFidelity.Default then
							Mesh:SetAttribute("OriginalCollisionFidelity", tostring(Mesh.CollisionFidelity.Name))
							Mesh.CollisionFidelity = Enum.CollisionFidelity.Hull
						end
					end
				end
			else
				for _, Mesh: MeshPart in next, game:GetDescendants() :: any do
					if Mesh:IsA("MeshPart") then
						if Mesh:GetAttribute("OriginalRenderFidelity") then
							local OriginalRenderFidelity = Mesh:GetAttribute("OriginalRenderFidelity") :: string

							if OriginalRenderFidelity then
								Mesh.RenderFidelity = Enum.RenderFidelity[OriginalRenderFidelity] :: Enum.RenderFidelity
								Mesh:SetAttribute("OriginalRenderFidelity", nil)
							end

							local OriginalCollisionFidelity = Mesh:GetAttribute("OriginalCollisionFidelity")
							if OriginalCollisionFidelity then
								Mesh.CollisionFidelity =
									Enum.CollisionFidelity[OriginalCollisionFidelity] :: Enum.CollisionFidelity
								Mesh:SetAttribute("OriginalCollisionFidelity", nil)
							end
						end
					end
				end
			end
		end,
	})

	OptimizationsGroup:AddToggle("RemoveDetail", {
		Text = T("Remove Details"),
		Default = false,
		Tooltip = T("Removes unnecessary details from the environment."),
		Callback = function(Value)
			for _, Descendant in next, workspace:GetDescendants() do
				if Descendant:IsA("MeshPart") and Descendant.CanCollide == false then
					Descendant.LocalTransparencyModifier = Value and 1 or 0
				end
			end
		end,
	})

	local MiscVisualsGroup = Tabs.Visuals:AddLeftGroupbox(T("Misc Visuals"))

	MiscVisualsGroup:AddToggle("VisualizeHitReg", {
		Text = T("Visualize Hit Registration [LAGGY]"),
		Default = false,
		Tooltip = T("Displays hit registration information."),
	})

	MiscVisualsGroup:AddToggle("Freecam", {
		Text = T("Enable Freecam"),
		Default = false,
		Tooltip = T("Enables the freecam feature."),
		Callback = function(Value)
			ToggleFreeCamera(Value)
		end,
	}):AddKeyPicker("Freecam", {
		Default = "V",
		SyncToggleState = true,
		Mode = "Toggle",
		Text = T("Toggle Freecam"),
		NoUI = false,
	})

	local ESPGroup = Tabs.Visuals:AddLeftGroupbox("ESP")

	ESPGroup:AddToggle("ESPEnabled", {
		Text = T("Enabled"),
		Default = false,
		Tooltip = T("Enables ESP features"),
		Callback = function(Value)
			ESP_Library.Config.Enabled = Value
			-- Keep ItemView state synced with ESP master toggle and Inventory toggle
			local ok = pcall(function()
				if getgenv().Library and getgenv().Library.Toggles and getgenv().Library.Toggles["ESPItems"] then
					ItemView.Enabled = getgenv().Library.Toggles["ESPItems"].Value and Value
				else
					ItemView.Enabled = G_Toggle("ESPItems") and Value
				end
			end)
			if not ok then
				-- Best-effort fallback
				ItemView.Enabled = Value
			end
		end,
	})

	local FontList = {}
	for Font, _ in next, Drawing.Fonts do
		table.insert(FontList, Font)
	end

	ESPGroup:AddDropdown("ESPFont", {
		Text = T("ESP Font"),
		Default = 1,
		Values = FontList,
		Tooltip = T("Select a font"),
		Callback = function(Value)
			ESP_Library.Config.Font = Drawing.Fonts[Value] or Drawing.Fonts.UI
		end,
	})

	ESPGroup:AddSlider("ESPRange", {
		Text = T("Range"),
		Default = 500,
		Min = 0,
		Max = 1500,
		Rounding = 0,
		Tooltip = T("Sets the maximum distance for ESP"),
		Callback = function(Value)
			ESP_Library.Config.MaxDistance = Value
		end,
	})

	ESPGroup:AddSlider("ESPFade", {
		Text = T("Fade"),
		Default = 100,
		Min = 0,
		Max = 500,
		Rounding = 0,
		Tooltip = T("Sets the fade distance for ESP"),
		Callback = function(Value)
			ESP_Library.Config.FadeDistance = Value
		end,
	})

	ESPGroup:AddToggle("ESPPlayers", {
		Text = T("Players"),
		Default = true,
		Tooltip = T("Shows ESP for players"),
		Callback = function(Value)
			ESP_Library.Config.Players = Value
		end,
	})

	ESPGroup:AddDropdown("ESPFont", {
		Text = T("ESP Font"),
		Default = 1,
		Values = FontList,
		Tooltip = T("Select a font"),
		Callback = function(Value)
			ESP_Library.Config.Font = Drawing.Fonts[Value] or Drawing.Fonts.UI
		end,
	})

	ESPGroup:AddToggle("ESPBoxes", {
		Text = T("Boxes"),
		Default = false,
		Tooltip = T("Shows boxes around players"),
		Callback = function(Value)
			ESP_Library.Config.Boxes = Value
		end,
	})

	ESPGroup:AddDropdown("BoxType", {
		Text = T("Box Type"),
		Default = "2D",
		Values = { "3DFull", "3D", "2D" },
		Tooltip = T("Sets the box type for ESP"),
		Callback = function(Value)
			ESP_Library.Config.BoxType = Value
		end,
	})

	ESPGroup:AddToggle("ESPTracers", {
		Text = T("Tracers"),
		Default = false,
		Tooltip = T("Shows tracers to players"),
		Callback = function(Value)
			ESP_Library.Config.Tracers = Value
		end,
	}):AddColorPicker("TracerColor", {
		Default = Color3.new(1, 1, 1),
		Title = T("Tracer Color"),
		Transparency = nil,
		Callback = function(Value)
			ESP_Library.Config.TracerColor = Value
		end,
	})

	ESPGroup:AddToggle("ESPText", {
		Text = T("Text"),
		Default = false,
		Tooltip = T("Shows text labels for ESP"),
		Callback = function(Value)
			ESP_Library.Config.Text = Value
		end,
	}):AddColorPicker("TextColor", {
		Default = Color3.new(1, 1, 1),
		Title = T("Text Color"),
		Transparency = nil,

		Callback = function(Value)
			ESP_Library.Config.TextColor = Value
		end,
	})

	ESPGroup:AddToggle("ESPItems", {
		Text = T("Inventory"),
		Default = false,
		Tooltip = T("Shows ESP for inventory"),
		Callback = function(Value)
			ItemView.Enabled = Value and ESP_Library.Config.Enabled
		end,
	}):AddColorPicker("ItemESPColor", {
		Default = Color3.new(1, 1, 1),
		Title = T("Item ESP Color"),
		Transparency = nil,
		Callback = function(Value)
			ItemView.Color = Value
		end,
	})

	--#region InventoryViewer Tab

	local InventoryGroup = Tabs.InventoryViewer:AddLeftGroupbox(T("Player Select"))

	InventoryGroup:AddDropdown("InventoryViewerTarget", {
		SpecialType = "Player",
		ExcludeLocalPlayer = false,
		Text = T("Target Player"),
		Tooltip = T("Player who is being viewed"),
	})

	-- Lazy-load the catalog once for this tab
	local ItemCatalog: any = nil
	pcall(function()
		ItemCatalog = SafeRequire(ReplicatedStorage.Values.Inventory)
	end)

	local function NormalizeImageId(id: any): string?
		if not id then
			return nil
		end
		if type(id) == "number" then
			return "rbxassetid://" .. tostring(id)
		end
		if type(id) == "string" then
			if id:find("rbxassetid://") or id:find("rbxthumb://") or id:find("http") then
				return id
			end
			-- Heuristic: numeric string
			local n = tonumber(id)
			if n then
				return "rbxassetid://" .. id
			end
			return id
		end
		return nil
	end

	local function ResolveItemData(name: string): { Image: string?, Price: number? }?
		if not ItemCatalog then
			return nil
		end
		local data = ItemCatalog[name]
		if not data and ItemCatalog.Items then
			data = ItemCatalog.Items[name]
		end
		if not data then
			return nil
		end
		local image = NormalizeImageId(data.Image or data.ImageId or data.Icon)
		local price = tonumber(data.Price or data.Value or 0) or 0
		return { Image = image, Price = price }
	end

	local InventoryContainers = {
		{ Name = "Inventory" },
		{ Name = "Safe" },
	}

	local function sortContainerChildren(a: Instance, b: Instance): boolean
		local na, nb = tonumber(a.Name), tonumber(b.Name)
		if na and nb then
			return na < nb
		end
		return tostring(a.Name) < tostring(b.Name)
	end

	local function CollectContainerItems(player: Player, containerName: string): ({ [number]: { Slot: StringValue, Name: string, Container: Instance } }, Instance?)
		local container = player:FindFirstChild(containerName)
		if not container then
			return {}, nil
		end
		local children = container:GetChildren()
		table.sort(children, sortContainerChildren)
		local items = {}
		for _, child in ipairs(children) do
			if child:IsA("StringValue") then
				local value = child.Value
				if value and value ~= "" and value ~= "Fists" then
					table.insert(items, {
						Slot = child,
						Name = value,
						Container = container,
					})
				end
			end
		end
		return items, container
	end

	local function GetPlayerItemNames(player: Player): { string }
		local names = {}
		for _, definition in ipairs(InventoryContainers) do
			local items = CollectContainerItems(player, definition.Name)
			for _, info in ipairs(items) do
				table.insert(names, info.Name)
			end
		end
		return names
	end

	local function HasEmptySlot(container: Instance?): boolean
		if not container then
			return false
		end
		for _, child in ipairs(container:GetChildren()) do
			if child:IsA("StringValue") then
				local value = child.Value
				if value == nil or value == "" or value == "Fists" then
					return true
				end
			end
		end
		return false
	end

	InventoryGroup:AddButton(T("Select Highest Value"), function()
		local highestValue = -math.huge
		local highestPlayer: Player? = nil

		-- Defensive helpers
		-- Use item rarity as the value metric instead of price. We try several fields
		-- that may contain rarity information (numeric or named). If no rarity is
		-- available we fall back to the catalog price/value as a last resort.
		local function safePriceOf(itemName: string): number
			-- helper to get raw catalog entry if present
			local function getCatalogEntry()
				if not ItemCatalog then
					return nil
				end
				local d = ItemCatalog[itemName]
				if not d and ItemCatalog.Items then
					d = ItemCatalog.Items[itemName]
				end
				return d
			end

			local ok, entry = pcall(getCatalogEntry)
			if ok and entry and type(entry) == "table" then
				-- Try numeric rarity fields first
				local rarity = nil
				if entry.Rarity ~= nil then
					rarity = tonumber(entry.Rarity)
				end
				if not rarity and entry.RarityValue ~= nil then
					rarity = tonumber(entry.RarityValue)
				end
				if not rarity and entry.RarityId ~= nil then
					rarity = tonumber(entry.RarityId)
				end

				-- Try named rarity (e.g. "Common", "Rare")
				if not rarity and entry.RarityName then
					local name = tostring(entry.RarityName):lower()
					local map = {
						common = 1,
						uncommon = 2,
						rare = 3,
						epic = 4,
						legendary = 5,
						mythic = 5,
					}
					rarity = map[name] or tonumber(entry.RarityName)
				end

				if rarity then
					-- clamp to reasonable range and use rarity as the value
					rarity = math.clamp(tonumber(rarity) or 1, 1, 5)
					return rarity
				end

				-- Fallback: try catalog price/value fields
				local price = tonumber(entry.Price or entry.Value or entry.RarityPrice) or 0
				return price
			end

			-- Final fallback: try ResolveItemData (older format)
			local ok2, data = pcall(ResolveItemData, itemName)
			if ok2 and data and typeof(data) == "table" then
				-- If a numeric rarity was encoded into Price previously, try that
				if tonumber(data.Price) then
					return tonumber(data.Price) or 0
				end
			end

			return 0
		end

		for _, player in next, Players:GetPlayers() do
			-- Include local player? (Design choice: include; remove this condition to exclude local)
			if player.Character then
				local total = 0
				for _, name in next, GetPlayerItemNames(player) do
					total += safePriceOf(name)
				end
				if total > highestValue then
					highestValue = total
					highestPlayer = player
				end
			end
		end

		if highestPlayer and Library and Library.Options and Library.Options.InventoryViewerTarget then
			Library.Options.InventoryViewerTarget:SetValue(highestPlayer)
			if Library.Notify then
				Library:Notify(
					string.format("Selected %s (Total Value: %s)", highestPlayer.Name, tostring(highestValue))
				)
			end
		else
			if Library and Library.Notify then
				Library:Notify("Failed to select highest value player")
			end
		end
	end)

	local InventoryViewerGroup = Tabs.InventoryViewer:AddRightGroupbox(T("Inventory"))
	local TargetPlayerText = InventoryViewerGroup:AddLabel(T("Inventory of " .. LocalPlayer.Name))

	local ItemGridColumns = 4
	local ItemTileSize = 60
	local ItemGridPadding = 6
	local ItemButtonBaseColor = Color3.fromRGB(48, 45, 65)

	local InventoryUpdateRoutine = Cleaner(coroutine_create(LPH_JIT_MAX(function()
		while task_wait(1) do
			local Container = TargetPlayerText.Container
			if not Container then
				continue
			end
			local TargetPlayer: Player? = nil
			pcall(function()
				TargetPlayer = Library.Options.InventoryViewerTarget and Library.Options.InventoryViewerTarget.Value
					or nil
			end)

			local oldInventory = Container:FindFirstChild("InventoryImageContainer")
			if oldInventory then
				oldInventory:Destroy()
			end
			local oldHotbar = Container:FindFirstChild("HotbarContainer")
			if oldHotbar then
				oldHotbar:Destroy()
			end

			local layout = Container:FindFirstChild("InventoryLayout")
			if not layout then
				layout = Instance.new("UIListLayout")
				layout.Name = "InventoryLayout"
				layout.SortOrder = Enum.SortOrder.LayoutOrder
				layout.Padding = UDim.new(0, 6)
				layout.Parent = Container
			end

			for order, definition in ipairs(InventoryContainers) do
				local sectionName = definition.Name .. "Section"
				local section = Container:FindFirstChild(sectionName)
				if not section then
					section = Instance.new("Frame")
					section.Name = sectionName
					section.BackgroundTransparency = 1
					section.AutomaticSize = Enum.AutomaticSize.Y
					section.Size = UDim2.new(1, 0, 0, 0)
					section.Parent = Container

					local header = Instance.new("TextLabel")
					header.Name = "Header"
					header.Size = UDim2.new(1, 0, 0, 24)
					header.BackgroundTransparency = 1
					header.TextColor3 = Color3.new(1, 1, 1)
					header.Font = Enum.Font.BuilderSans
					header.TextScaled = true
					header.LayoutOrder = 1
					header.Parent = section

					local grid = Instance.new("Frame")
					grid.Name = "Grid"
					grid.BackgroundTransparency = 1
					grid.Size = UDim2.new(1, 0, 0, 0)
					grid.LayoutOrder = 2
					grid.Parent = section

					local gridLayout = Instance.new("UIGridLayout")
					gridLayout.Name = "GridLayout"
					gridLayout.CellPadding = UDim2.new(0, ItemGridPadding, 0, ItemGridPadding)
					gridLayout.FillDirectionMaxCells = ItemGridColumns
					gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
					gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
					gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
					gridLayout.Parent = grid
				end

				local sectionLayout = section:FindFirstChild("SectionLayout") :: UIListLayout
				if not sectionLayout then
					sectionLayout = Instance.new("UIListLayout")
					sectionLayout.Name = "SectionLayout"
					sectionLayout.FillDirection = Enum.FillDirection.Vertical
					sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
					sectionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
					sectionLayout.Padding = UDim.new(0, 4)
					sectionLayout.Parent = section
				end

				section.LayoutOrder = order
				local header = section:FindFirstChild("Header") :: TextLabel
				local grid = section:FindFirstChild("Grid") :: Frame
				local gridLayout = grid:FindFirstChild("GridLayout") :: UIGridLayout

				for _, child in ipairs(grid:GetChildren()) do
					if not child:IsA("UIGridLayout") then
						child:Destroy()
					end
				end

				local items, containerInstance = {}, nil
				if TargetPlayer then
					local collected, container = CollectContainerItems(TargetPlayer, definition.Name)
					items = collected
					containerInstance = container
				end

				header.Text = T(definition.Name) .. string.format(" (%d)", #items)

				if #items == 0 then
					grid.Size = UDim2.new(1, 0, 0, 28)
					local emptyLabel = Instance.new("TextLabel")
					emptyLabel.Name = "EmptyLabel"
					emptyLabel.Size = UDim2.new(1, -8, 0, 20)
					emptyLabel.Position = UDim2.new(0, 4, 0, 4)
					emptyLabel.BackgroundTransparency = 1
					emptyLabel.Text = T("No items found.")
					emptyLabel.TextColor3 = Color3.new(1, 1, 1)
					emptyLabel.TextScaled = true
					emptyLabel.Parent = grid
					continue
				end

				local tileSize = ItemTileSize
				local gridWidth = grid.AbsoluteSize.X
				if gridWidth > 0 then
					local candidate = math_floor(gridWidth / ItemGridColumns) - ItemGridPadding
					if candidate > 0 then
						tileSize = math_min(ItemTileSize, math_max(32, candidate))
					end
				end
				gridLayout.CellSize = UDim2.new(0, tileSize, 0, tileSize)
				local rows = math.ceil(#items / ItemGridColumns)
				local height = math_max(tileSize + ItemGridPadding, rows * (tileSize + ItemGridPadding) + ItemGridPadding)
				grid.Size = UDim2.new(1, 0, 0, height)

				for index, info in ipairs(items) do
					local itemData = ResolveItemData(info.Name)
					local button = Instance.new("ImageButton")
					button.Name = "Item" .. tostring(index)
					button.Size = UDim2.new(0, tileSize, 0, tileSize)
					button.BackgroundColor3 = ItemButtonBaseColor
					button.BackgroundTransparency = 0.15
					button.ClipsDescendants = true
					button.AutoButtonColor = false
					button.Image = itemData and itemData.Image or ""
					button.ScaleType = Enum.ScaleType.Fit
					button.Active = false
					button.Selectable = false
					button.Parent = grid
				end
			end

			if TargetPlayer then
				TargetPlayerText:SetText(T("Inventory of " .. TargetPlayer.Name))
			else
				TargetPlayerText:SetText(T("Inventory"))
			end
		end
	end)))
	coroutine_resume(InventoryUpdateRoutine)

	--#endregion

	-- Settings tab

	local MenuGroup = Tabs.Settings:AddLeftGroupbox(T("Menu"))

	MenuGroup:AddToggle("Identifier", {
		Text = T("Sasware Identification"),
		Default = true,
		Tooltip = T("Enables sending and receiving identifier data to see other Sasware users."),
		Callback = function(Value)
			Identifier:ToggleIdentify(Value)
		end,
	})

	MenuGroup:AddButton("Unload", function()
		print("Cleaning up.")
		HookMgr.ClearHooks()
		Cleaner.Clean()
		ESP_Library.Unload()
		Aiming_Library.Unload()
		rconsoledestroy()
	end)

	ThemeManager:SetLibrary(Library)
	SaveManager:SetLibrary(Library)

	ThemeManager:SetDefaultTheme({
		BackgroundColor = Color3.fromRGB(29, 29, 46),
		MainColor = Color3.fromRGB(48, 45, 65),
		AccentColor = Color3.fromRGB(159, 120, 149),
		OutlineColor = Color3.fromRGB(67, 61, 87),
		FontColor = Color3.fromRGB(217, 224, 238),
		FontFace = Enum.Font.BuilderSans,
	})

	SaveManager:IgnoreThemeSettings()

	SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

	ThemeManager:SetFolder("sasware_blockspin")
	SaveManager:SetFolder("sasware_crashouts/main")

	local function SyncESPConfigFromUI()
		local library = rawget(getgenv(), "Library")
		if not library then
			return
		end

		local toggles = library.Toggles or {}
		local options = library.Options or {}

		local function toggleValue(name: string)
			local toggle = toggles[name]
			if toggle ~= nil then
				return toggle.Value
			end
			return nil
		end

		local function optionValue(name: string)
			local option = options[name]
			if option ~= nil then
				return option.Value
			end
			return nil
		end

		local highlightFill = optionValue("HighlightColor")
		if highlightFill ~= nil then
			ESP_Library.Config.HighlightFillColor = highlightFill
		end

		local highlightOutline = optionValue("HighlightOutlineColor")
		if highlightOutline ~= nil then
			ESP_Library.Config.HighlightOutlineColor = highlightOutline
		end

		local highlightFillTransparency = optionValue("HighlightFillTransparency")
		if highlightFillTransparency ~= nil then
			ESP_Library.Config.HighlightFillTransparency = highlightFillTransparency
		end

		local highlightOutlineTransparency = optionValue("HighlightOutlineTransparency")
		if highlightOutlineTransparency ~= nil then
			ESP_Library.Config.HighlightOutlineTransparency = highlightOutlineTransparency
		end

		local fontIndex = optionValue("ESPFont")
		if fontIndex ~= nil then
			ESP_Library.Config.Font = Drawing.Fonts[fontIndex] or Drawing.Fonts.UI
		end

		local espEnabled = toggleValue("ESPEnabled")
		if espEnabled ~= nil then
			ESP_Library.Config.Enabled = espEnabled
		end

		local maxDistance = optionValue("ESPRange")
		if maxDistance ~= nil then
			ESP_Library.Config.MaxDistance = maxDistance
		end

		local fadeDistance = optionValue("ESPFade")
		if fadeDistance ~= nil then
			ESP_Library.Config.FadeDistance = fadeDistance
		end

		local espPlayers = toggleValue("ESPPlayers")
		if espPlayers ~= nil then
			ESP_Library.Config.Players = espPlayers
		end

		local espBoxes = toggleValue("ESPBoxes")
		if espBoxes ~= nil then
			ESP_Library.Config.Boxes = espBoxes
		end

		local boxType = optionValue("BoxType")
		if boxType ~= nil then
			ESP_Library.Config.BoxType = boxType
		end

		local espTracers = toggleValue("ESPTracers")
		if espTracers ~= nil then
			ESP_Library.Config.Tracers = espTracers
		end

		local tracerColor = optionValue("TracerColor")
		if tracerColor ~= nil then
			ESP_Library.Config.TracerColor = tracerColor
		end

		local espText = toggleValue("ESPText")
		if espText ~= nil then
			ESP_Library.Config.Text = espText
		end

		local textColor = optionValue("TextColor")
		if textColor ~= nil then
			ESP_Library.Config.TextColor = textColor
		end

		local espItems = toggleValue("ESPItems")
		if espItems ~= nil then
			ItemView.Enabled = (espItems == true) and (ESP_Library.Config.Enabled == true)
		end
	end

	Storage.SyncESPConfigFromUI = SyncESPConfigFromUI

	do
		local originalLoad = SaveManager.Load
		if type(originalLoad) == "function" then
			SaveManager.Load = function(self, ...)
				local results = { originalLoad(self, ...) }
				if results[1] == true then
					task.defer(SyncESPConfigFromUI)
					task.delay(0.1, SyncESPConfigFromUI)
					task.delay(0.5, SyncESPConfigFromUI)
				end
				return table.unpack(results)
			end
		end

		local originalLoadAutoloadConfig = SaveManager.LoadAutoloadConfig
		if type(originalLoadAutoloadConfig) == "function" then
			SaveManager.LoadAutoloadConfig = function(self, ...)
				local results = { originalLoadAutoloadConfig(self, ...) }
				task.defer(SyncESPConfigFromUI)
				task.delay(0.1, SyncESPConfigFromUI)
				task.delay(0.5, SyncESPConfigFromUI)
				return table.unpack(results)
			end
		end
	end

	SaveManager:BuildConfigSection(Tabs.Settings)
	ThemeManager:ApplyToTab(Tabs.Settings)

	SyncESPConfigFromUI()
	SaveManager:LoadAutoloadConfig()

	local function TrackDeathLocation(Character: Model)
		local function bindHumanoid(Humanoid: Humanoid)
			if not Humanoid then
				return
			end
			Storage.Connections[_nextKey(Storage.Connections, "RespawnFlashback_Died")] = Cleaner(Humanoid.Died:Connect(function()
				local deathFrame = nil
				local Root = Character:FindFirstChild("HumanoidRootPart")
				if Root then
					deathFrame = Root.CFrame
				else
					local ok, pivot = pcall(function()
						return Character:GetPivot()
					end)
					if ok then
						deathFrame = pivot
					end
				end
				if deathFrame then
					Storage.LastDeathCFrame = deathFrame
				end
			end))
		end

		task.defer(function()
			local Humanoid = Character:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				bindHumanoid(Humanoid)
				return
			end

			local Connection
			Connection = Character.ChildAdded:Connect(function(child)
				if child:IsA("Humanoid") then
					Connection:Disconnect()
					bindHumanoid(child)
				end
			end)
			Storage.Connections[_nextKey(Storage.Connections, "RespawnFlashback_HumanoidWait")] = Cleaner(Connection)
		end)
	end

	local function AttemptRespawnFlashback(Character: Model)
		if not G_Toggle("RespawnFlashback") then
			return
		end
		local DeathCFrame = Storage.LastDeathCFrame
		if not DeathCFrame then
			return
		end
		task.spawn(function()
			local Root = Character:WaitForChild("HumanoidRootPart", 5)
			if not Root then
				return
			end
			if not G_Toggle("RespawnFlashback") then
				return
			end
			task_wait(0.15)
			local ok = pcall(function()
				Character:PivotTo(DeathCFrame)
			end)
			if ok then
				Storage.LastDeathCFrame = nil
			end
		end)
	end

	local function BindCharacterFlashback(Character: Model)
		if not Character then
			return
		end
		TrackDeathLocation(Character)
		AttemptRespawnFlashback(Character)
	end

	local ChildAddedConnection, ChildRemovedConnection = nil, nil

	Storage.Connections[_nextKey(Storage.Connections, "UI_LocalPlayer_CharacterAdded")] =
		Cleaner(LocalPlayer.CharacterAdded:Connect(function(Character)
			BindCharacterFlashback(Character)
			if ChildAddedConnection then
				Cleaner.CleanOne(ChildAddedConnection)
				ChildAddedConnection = nil
			end
			if ChildRemovedConnection then
				Cleaner.CleanOne(ChildRemovedConnection)
				ChildRemovedConnection = nil
			end
			Storage.Connections[_nextKey(Storage.Connections, "UI_Character_ChildRemoved")] = ChildRemovedConnection
		end))

	if LocalPlayer.Character then
		BindCharacterFlashback(LocalPlayer.Character)
		if ChildAddedConnection then
			Cleaner.CleanOne(ChildAddedConnection)
			ChildAddedConnection = nil
		end
		if ChildRemovedConnection then
			Cleaner.CleanOne(ChildRemovedConnection)
			ChildRemovedConnection = nil
		end
		Storage.Connections[_nextKey(Storage.Connections, "UI_LocalCharacter_ChildRemoved")] = ChildRemovedConnection
	end

	if not LPH_OBFUSCATED then
		local _DebugGroup = Tabs.Debug:AddLeftGroupbox("Debug")
	end

	local TestGroup = Tabs.Debug:AddRightGroupbox("Testing")

	TestGroup:AddButton("Test Drawing Library", function()
		local Drawings = {}

		-- Box type
		for i = 1, 5 do
			local Box = Drawing.new("Square")
			Box.Size = Vector2.new(100, 100)
			Box.Position = Vector2.new(i * 110, 100)
			Box.Color = BrickColor.Random().Color
			Box.Visible = true
			Box.Filled = math.random() > 0.5
			table.insert(Drawings, Box)
		end

		-- Quad type
		for i = 1, 5 do
			local Quad = Drawing.new("Quad")
			Quad.Size = Vector2.new(100, 100)
			Quad.PointA = Vector2.new(i * 110, 200)
			Quad.PointB = Vector2.new(i * 110 + 100, 200)
			Quad.PointC = Vector2.new(i * 110 + 50, 300)
			Quad.PointD = Vector2.new(i * 110 - 50, 300)
			Quad.Color = BrickColor.Random().Color
			Quad.Filled = math.random() > 0.5
			Quad.Visible = true
			table.insert(Drawings, Quad)
		end

		-- Triangle type
		for i = 1, 5 do
			local Triangle = Drawing.new("Triangle")
			Triangle.Size = Vector2.new(100, 100)
			Triangle.PointA = Vector2.new(i * 110, 300)
			Triangle.PointB = Vector2.new(i * 110 + 100, 300)
			Triangle.PointC = Vector2.new(i * 110 + 50, 400)
			Triangle.Color = BrickColor.Random().Color
			Triangle.Filled = math.random() > 0.5
			Triangle.Visible = true
			table.insert(Drawings, Triangle)
		end

		-- Text type
		for i = 1, 5 do
			local Text = Drawing.new("Text")
			Text.Size = 20
			Text.Position = Vector2.new(i * 110, 400)
			Text.Color = BrickColor.Random().Color
			Text.Visible = true
			Text.Text = "Hello World"
			table.insert(Drawings, Text)
		end

		-- Circle type
		for i = 1, 5 do
			local Circle = Drawing.new("Circle")
			Circle.Radius = 50
			Circle.Position = Vector2.new(i * 110, 500)
			Circle.Color = BrickColor.Random().Color
			Circle.Visible = true
			Circle.Filled = math.random() > 0.5
			table.insert(Drawings, Circle)
		end

		task_wait(5)

		for _, Drawing in next, Drawings do
			Drawing:Remove()
		end
	end)

	--#endregion

	--#region Update values with the UI toggles as they do not sometimes.

	Aiming_Library.FilterFriends = G_Toggle("SilentAimFilterFriends")
	Aiming_Library.CenterLockFOV = G_Toggle("SilentAimCenterFOV")
	SyncESPConfigFromUI()

	--#endregion

	--#region Pull in teleport data if it exists.

	-- local _Data = TeleportData:ReadWipe("TeleportState")

	Identifier:ToggleIdentify(G_Toggle("Identifier"))
end, function(Error)
	warn("An error occurred during execution:", Error)
	warn(debug.traceback())
	local _, AbortSignal, UI =
		ErrorHandler.Throw("0x01", `An error occured during exection: {Error}\n{debug.traceback()}`, false)

	HookMgr.ClearHooks()
	Cleaner.Clean()
	ESP_Library.Unload()
	Aiming_Library.Unload()

	AbortSignal:Once(function()
		rconsoledestroy()
		UI:Destroy()
	end)
end)

--#endregion
