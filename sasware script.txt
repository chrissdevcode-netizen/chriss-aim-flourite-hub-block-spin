--!native
--!nolint BuiltinGlobalWrite
--!nolint UnknownGlobal

repeat
	task.wait()
until game:IsLoaded()

local DUPE_MODE = false
local DUPE_RECIPIENT = "Sasware0x679"

local SecureRequest = require("./modules/secure_request.luau")
require("./modules/bypasses.luau")

local hookfunction = shared.SafeHook

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

	getgenv().Key = "KG-9964dacb-1a4b-42c5-b4a5-7308b8fc2150"
end

--#region Localizing globals
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

--#endregion

local Storage = {
	Originals = {},
	OldHipHeight = 0,
	RayCastGuides = {},
	Panic = false,
	MoveDirection = Vector3.zero,
	ItemAuraConnections = {},
	MovementSpoof = false,
	SupressNotifications = false,
	Gun_Attributes = {
		{
			Name = "Disable Scopes",
			Attribute = "SniperScope",
			Type = "function",
			Function = function(Value: boolean, Self: Instance, Attribute: string)
				if game.HasTag(Self, "Gun") and Attribute == "SniperScope" then
					return true, not Value
				end
				return false, nil
			end,
		},
		-- { Name = "Accuracy", Type = "number", Max = 1, Min = 0.2 },
		-- { Name = "Automatic", Type = "boolean" },
		-- { Name = "FireRate", Type = "number", Max = 5000, Min = 100 },
		-- { Name = "Range", Type = "number", Max = 2000, Min = 50 },
		{ Name = "Recoil", Type = "number", Max = 5, Min = 0, Default = 0.1 },
		{ Name = "Zoom", Type = "number", Max = 5, Min = 0, Default = 1 },
	},
	Vehicle_Attributes = {
		{ Name = "acceleration", Type = "number", Min = 5, Max = 100, DisplayName = "Acceleration" },
		-- { Name = "forwardMaxSpeed", Type = "number", Min = 5, Max = 120, DisplayName = "Max Speed" },
		-- { Name = "maxSpeedTorque", Type = "number", Min = 1000, Max = 100000, DisplayName = "Max Speed Torque" },
		-- { Name = "minSpeedTorque", Type = "number", Min = 1000, Max = 100000, DisplayName = "Min. Speed Torque" },
		{ Name = "slipThreshold", Type = "number", Min = 10, Max = 100, DisplayName = "Slip Threshold" },
		{ Name = "staticFriction", Type = "number", Min = 1, Max = 10, DisplayName = "Static Friction" },
	},
	Blacklisted_Network_Calls = {
		["replicate_billboard_gui"] = true,
		["replicate_stamina_bar"] = true,
		["invalid_entry"] = true,
	},
	Teleport_Positions = {
		["Bike Shop"] = Vector3.new(256, 261, -206),
		["Burger Place"] = Vector3.new(113, 260, -212),
		["Gun Shop"] = Vector3.new(-140, 259, -221),
		["House"] = Vector3.new(124, 261, -393),
		["Hospital"] = Vector3.new(-133, 261, -555),
		["Dealer"] = Vector3.new(-222, 255, 388),
		["Car Dealership"] = Vector3.new(118, 260, 431),
		["Gas Station"] = Vector3.new(125, 258, 137),
		["Pawn Shop"] = Vector3.new(1177, 258, -535),
		["Spin Club"] = Vector3.new(1253, 260, -418),
	},
	Anti_Aim_Animation = nil,
	LastHackedATM = os.clock(),
	Initialized = false,
	CharacterConnections = {},
	UpdateGunStatsCallback = Instance.new("BindableEvent"),
	UpdateMeleeStatsCallback = Instance.new("BindableEvent"),
	GunModReferences = {
		["accuracy"] = "GunMods_S_Accuracy",
		["automatic"] = "GunMods_S_Automatic",
		["fire_rate"] = "GunMods_S_FireRate",
	},
	MeleeModReferences = {
		["cone_angle"] = "MeleeMods_S_ConeAngle",
		["range"] = "MeleeMods_S_Range",
		["speed"] = "MeleeMods_S_Speed",
	},
	FlyJumpConnection = nil,
	ServerStaminaGui = game:GetService("Players").LocalPlayer
		:WaitForChild("PlayerGui")
		:WaitForChild("TopRightHud")
		:WaitForChild("Holder")
		:WaitForChild("StaminaBar")
		:Clone(),
	LastKilledBy = nil,
	Connections = {},
	Routines = {},
	RarityColors = {
		["Common"] = Color3.fromRGB(255, 255, 255),
		["Uncommon"] = Color3.fromRGB(99, 255, 52),
		["Rare"] = Color3.fromRGB(51, 170, 255),
		["Epic"] = Color3.fromRGB(237, 44, 255),
		["Legendary"] = Color3.fromRGB(255, 150, 0),
		["Omega"] = Color3.fromRGB(255, 20, 51),
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

local InitializedSignal = Instance.new("BindableEvent")
local START_TIME = os.clock()
local TELEPORT_SPEED_VEHICLE = 60
local TELEPORT_SPEED = 32
local PANIC_HEIGHT_THRESHOLD = 266
local PANIC_CONST_OFY = 255
local PANIC_DURATION = 25
local AUTO_HOP_INTERVAL = 60 * 5
local TELEPORT_SPEEDUP_TIME = 1
local TP_HEIGHT_OFFSET = 3
local SUPPORTED_VERSIONS = { "1.3.30", "1.3.31", "1.3.32", "1.3.33", "1.3.34", "1.3.35", "1.3.36", "1.3.37", "1.3.38", "1.3.40", "1.3.41" }
local Translator = require("./modules/Translation.luau")
local T = Translator.translate

local Version = "8.6.0"
local SubVersion = (not FREE_BUILD) and "Release [Paid]" or "Release [Free]"
local ORCHESTRATOR_MENU_ENABLED = false

shared.HOOKING_ENABLED = true

type MarkerObject = {
	Object: Part,
	Destroy: (self: MarkerObject) -> (),
	SetColor: (self: MarkerObject, Color: Color3) -> (),
	SetPosition: (self: MarkerObject, Position: Vector3) -> (),
}

-- Define a generic state type used by the ATM system.
type State<T> = {
	set: (self: State<T>, value: T) -> (),
	get: () -> T,
	-- Optional hook callback for state changes.
	hook: ((self: State<T>, newValue: T) -> ())?,
}

-- The internal state table for each ATM “class” object.
type ATM_ClassState = {
	fake_hacker_state_1: State<any>,
	fake_disabled_state_1: State<boolean>,
	fake_hack_tool_1: State<string>,
	start_hack: State<number>,
	disabled: State<boolean>,
	hacker: State<any>,
	active_hack_tool: State<string>,
	fake_hacker_state_2: State<Instance>,
	fake_disabled_state_2: State<boolean>,
	fake_hack_tool_2: State<string>,
}

-- The structure representing an individual ATM object.
type ATM_ClassObject = {
	instance: Model, -- The ATM's instance in the world.
	states: ATM_ClassState, -- Its state table.
}

--#region Initializing core functionality

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
	local statusLabel = rawget(shared, "StatusText")
	if statusLabel and statusLabel.Parent then
		statusLabel.Text = Text
	end
	task_wait(0.05)
end

local function SafeRequire(...)
	local OldThreadContext = getthreadcontext()
	setthreadcontext(2)
	local Result = require(...)
	setthreadcontext(OldThreadContext)
	return Result
end

local function GetBoundingBox(model, orientation): (CFrame, Vector3)
	if typeof(model) == "Instance" then
		model = model:GetDescendants()
	end
	if not orientation then
		orientation = CFrame.new()
	end
	local abs = math.abs
	local inf = math.huge

	local minx, miny, minz = inf, inf, inf
	local maxx, maxy, maxz = -inf, -inf, -inf

	for _, obj in pairs(model) do
		if obj:IsA("BasePart") then
			local cf = obj.CFrame
			cf = orientation:toObjectSpace(cf)
			local size = obj.Size
			local sx, sy, sz = size.X, size.Y, size.Z

			local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:components()

			local wsx = 0.5 * (abs(R00) * sx + abs(R01) * sy + abs(R02) * sz)
			local wsy = 0.5 * (abs(R10) * sx + abs(R11) * sy + abs(R12) * sz)
			local wsz = 0.5 * (abs(R20) * sx + abs(R21) * sy + abs(R22) * sz)

			if minx > x - wsx then
				minx = x - wsx
			end
			if miny > y - wsy then
				miny = y - wsy
			end
			if minz > z - wsz then
				minz = z - wsz
			end

			if maxx < x + wsx then
				maxx = x + wsx
			end
			if maxy < y + wsy then
				maxy = y + wsy
			end
			if maxz < z + wsz then
				maxz = z + wsz
			end
		end
	end

	local omin, omax = Vector3.new(minx, miny, minz), Vector3.new(maxx, maxy, maxz)
	local omiddle = (omax + omin) / 2
	local wCf = orientation - orientation.p + orientation:pointToWorldSpace(omiddle)
	local size = (omax - omin)
	return wCf, size
end

local function dbgprint(...)
	if not LPH_OBFUSCATED then
		-- if USERCONSOLE then
		-- 	rconsoleprint("[DEBUGGING] " .. table.concat(Stringify({ ... }), " "))
		-- else
		print("[DEBUGGING]", ...)
		-- end
	end
end

local function dbgwarn(...)
	if DEBUGGING then
		-- if USERCONSOLE then
		-- rconsolewarn("[DEBUGGING] " .. table.concat(Stringify({ ... }), " "))
		-- else
		warn("[DEBUGGING]", ...)
		-- end
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
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Core = Modules:WaitForChild("Core")
local GameModules = Modules:WaitForChild("Game")
local Net = SafeRequire(Core:WaitForChild("Net") :: ModuleScript)
local LocalUserId = LocalPlayer.UserId
local Camera = workspace.CurrentCamera
local MovementEvent = Instance.new("BindableEvent")
local CharacterCreatorItems = ReplicatedStorage:WaitForChild("ReplicatedCharacterCreatorItems")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")

--#endregion

local function ClearStatusOverlay()
	pcall(RunService.UnbindFromRenderStep, RunService, "Overlay")

	local overlay = rawget(shared, "DarkOverlay")
	if overlay and overlay.Destroy then
		overlay:Destroy()
	end

	shared.DarkOverlay = nil
	shared.StatusText = nil
	shared.OverlayImage = nil
end

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

-- if Executor:match("Delta") then
-- 	UpdateStatus("Loading modules/drawing2")
-- 	require("modules/Drawing2.luau")
-- end

UpdateStatus(T("Loading modules/esp"))
local ESP_Library = require("modules/esp2.luau")

UpdateStatus(T("Loading modules/aiminglib"))
local Aiming_Library = require("modules/aiminglib.luau")

UpdateStatus(T("Loading modules/inventorylib"))
local Inventory = require("modules/inventorylib.luau")

UpdateStatus(T("Loading modules/itemviewlib"))
local ItemView = require("modules/itemviewlib.luau")

UpdateStatus(T("Loading modules/pathmodule"))
local PathLib = require("modules/pathmodule")

UpdateStatus(T("Loading modules/class_interface"))
local Class_Interface = require("modules/class_interface.luau")

UpdateStatus(T("Loading modules/teleportdata"))
local TeleportData = require("modules/teleportdata.luau")

UpdateStatus(T("Loading modules/identifier"))
local Identifier = require("modules/identifier.luau")

UpdateStatus(T("Loading modules/freecamera"))
local ToggleFreeCamera = require("modules/freecamera.luau")

UpdateStatus(T("Loading modules/Prediction"))
local Prediction = require("modules/Prediction.luau")

UpdateStatus(T("Loading modules/gizmo"))
local Gizmo = require("modules/gizmo_init.luau")

UpdateStatus(T("Loading modules/secure_call"))
local secure_call = require("modules/secure_call.luau")

UpdateStatus(T("Loading modules/Cleaner"))
local Cleaner = require("./modules/Cleaner.luau")

UpdateStatus(T("Loading modules/HookMgr"))
local HookMgr = require("./modules/HookMgr.luau")

UpdateStatus(T("Loading modules/SecureNet"))
local SecureNet = require("./modules/SecureNet.luau")(Storage, SafeRequire, Core, UpdateStatus, T)

UpdateStatus(T("Loading modules/Utils"))
local Utils = require("./modules/Utils.luau")(Storage, SafeRequire, Core, UpdateStatus, T)

UpdateStatus(T("Loading modules/ConnectionProxyManager"))
local ConnectionProxyMgr = require("./modules/ConnectionProxyManager.luau")

UpdateStatus(T("Loading modules/ArgumentCheck"))
local ArgumentChecks = require("./modules/ArgumentCheck.luau").Results

UpdateStatus(T("Loading user interface..."))
local Repository = "https://raw.githubusercontent.com/deividcomsono/Obsidian/738b589406cec1e47161e81243b5ff265c099048/"
local Library = loadstring(SecureRequest:HttpGet(Repository .. "Library.lua"))()
local ThemeManager = loadstring(SecureRequest:HttpGet(Repository .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(SecureRequest:HttpGet(Repository .. "addons/SaveManager.lua"))()

local Repr: (any, { [string]: any }?) -> string =
	loadstring(SecureRequest:HttpGet("https://raw.githubusercontent.com/Ozzypig/repr/refs/heads/master/repr.lua"))()

local ErrorReporter = require("modules/error_reporter.luau")
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
local function RunMain()
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

	local GameRegistry = {
		consume_stamina = {},
	}

	Storage.ServerStaminaGui.Parent = LocalPlayer.PlayerGui.TopRightHud.Holder
	Storage.ServerStaminaGui.Name = "ServerStaminaGui"
	for _, v in next, Storage.ServerStaminaGui.Fill:GetChildren() do
		if v:IsA("UIGradient") then
			v.Enabled = false
		end
	end
	Storage.ServerStaminaGui.Fill.BackgroundColor3 = Color3.new(1, 0.505882, 0.039216)
	Storage.ServerStaminaGui.Visible = true

	if shared.HOOKING_ENABLED then
		print("Scanning enviroment...")

		for _, v in next, getgc(true) do
			if typeof(v) == "table" then
				pcall(function()
					if rawget(v, "consume_stamina") then
						local value = rawget(v, "consume_stamina")
						if typeof(value) == 'function' and islclosure(value) and (not isefunction(value)) then
							print("Found stamina hook table:", v)
							table.insert(GameRegistry.consume_stamina, value)
						end
					end
				end)
			end
		end
	else
		warn("Skipping enviroment scanning due to hooking being disabled.")
	end

	--#endregion

	--#region Game Initialization

	xpcall(function()
		SafeRequire(ReplicatedStorage:WaitForChild("Utility") :: ModuleScript)
	end, function(err)
		local PromptMessage = "Your executor does not support require. Please try a better one..."
		messagebox(PromptMessage, "Execution Error", 0)

		local TraceInformation = tostring(err or "Unknown error")

		if type(debug) == "table" and type(debug.traceback) == "function" then
			local success, generatedTrace = pcall(function()
				return debug.traceback(err, 2)
			end)

			if success and generatedTrace and generatedTrace ~= "" then
				TraceInformation = generatedTrace
			end
		end

		pcall(ErrorReporter.ReportPopup, {
			code = "EXECUTOR_REQUIRE",
			message = PromptMessage,
			recoverable = false,
			traceback = TraceInformation,
			source = "main.luau::SafeRequire",
			title = "Executor Compatibility Error",
		})

		coroutine_yield()
	end)

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

	-- local GameVersion = SafeRequire(GameModules.GameInfo.Updates :: ModuleScript)
	-- if not table.find(SUPPORTED_VERSIONS, GameVersion.version) then
	-- 	local Continue, Abort, UI = ErrorHandler.Throw(
	-- 		"0x04",
	-- 		T(
	-- 			`The current version of the game ({GameVersion.version}) is not supported, you have a high risk of being banned if you proceed.`
	-- 		),
	-- 		true
	-- 	)

	-- 	local Aborting = false
	-- 	local Pressed = false

	-- 	Continue:Once(function()
	-- 		Pressed = true
	-- 		Aborting = false
	-- 	end)

	-- 	Abort:Once(function()
	-- 		Pressed = true
	-- 		Aborting = true
	-- 		HookMgr.ClearHooks()
	-- 		Cleaner.Clean()
	-- 		ConnectionProxyMgr:Clear()
	-- 		ESP_Library.Unload()
	-- 		Aiming_Library.Unload()
	-- 		rconsoledestroy()
	-- 	end)

	-- 	repeat
	-- 		task_wait(0.1)
	-- 	until Pressed

	-- 	UI:Destroy()

	-- 	if Aborting then
	-- 		coroutine_yield()
	-- 		return
	-- 	end
	-- end

	local Melee = SafeRequire(GameModules.ItemTypes:WaitForChild("Melee") :: ModuleScript)
	local Crate = SafeRequire(GameModules.CrateSystem.Crate :: ModuleScript)
	local Sprint = SafeRequire(GameModules.Sprint :: ModuleScript)
	local SteakHouseModule = SafeRequire(GameModules.Jobs.SteakhouseCook :: ModuleScript)
	local Char = SafeRequire(Core.Char :: ModuleScript)
	local ATM_Module = SafeRequire(GameModules.ATM.ATM :: ModuleScript)
	local Data_Module = SafeRequire(Core.Data :: ModuleScript)
	local Item_Utils = SafeRequire(GameModules.Inventory.ItemUtils :: ModuleScript)
	local VehicleModule = SafeRequire(GameModules.VehicleSystem.Vehicle :: ModuleScript)
	local UIModule = SafeRequire(Core.UI :: ModuleScript)
	local SkillsList = SafeRequire(GameModules.Skills.SkillsList :: ModuleScript)
	local NotificationsUI = SafeRequire(GameModules.UI.NotificationsUI :: ModuleScript)

	local Map = workspace:WaitForChild("Map")
	local Vehicles = workspace:WaitForChild("Vehicles")
	local Atmosphere = Lighting:WaitForChild("Atmosphere")

	Aiming_Library.Enabled = true
	Aiming_Library.FOV = 60
	Aiming_Library.Players = true

	--#endregion

	local function FetchVehicleCandidates(): { string }
		-- Returns a sorted list in descending order of vehicle candidates sorted by speed.
		local Candidates = {}

		local VehiclesSource = Utils.InsertMergeTables(
			ReplicatedStorage.Items.bike:GetChildren(),
			ReplicatedStorage.Items.car:GetChildren()
		)

		for _, Vehicle in pairs(VehiclesSource) do
			-- Assuming vehicles are Models with a "Motors" child instance.
			if Vehicle:IsA("Model") and Vehicle:FindFirstChild("Motors") then
				local Motors = Vehicle.Motors
				local Speed = Motors:GetAttribute("forwardMaxSpeed")

				if typeof(Speed) == "number" then
					-- Use insertion sort to keep the list sorted by speed in descending order.
					local inserted = false
					for i = 1, #Candidates do
						if Speed > Candidates[i].Motors:GetAttribute("forwardMaxSpeed") then
							table.insert(Candidates, i, Vehicle)
							inserted = true
							break
						end
					end
					if not inserted then
						table.insert(Candidates, Vehicle)
					end
				else
					warn(
						("Vehicle '%s' is missing a valid 'forwardMaxSpeed' attribute. Skipping."):format(Vehicle.Name)
					)
				end
			end
		end

		local VehicleNames = {}
		for _, Vehicle in ipairs(Candidates) do
			table.insert(VehicleNames, Vehicle.Name)
		end

		return VehicleNames
	end
	local VehicleCandidates = FetchVehicleCandidates()

	--#region Defining game-related runtime constants / functions

	local function WaitForPing()
		local NetworkPing = LocalPlayer:GetNetworkPing()
		return task_wait(math_max(0.2, NetworkPing * 2))
	end

	local function Sit(VehicleSeat: VehicleSeat, NYield: boolean?)
		local Vehicle = VehicleSeat.Parent :: BasePart
		local Prompt = Vehicle.Chassis.DrivePromptAttachment.DrivePrompt
		local Character = LocalPlayer.Character

		-- print(Prompt)

		local Origin = Character:GetPivot()

		-- Try sitting in the car first
		fireproximityprompt(Prompt, 0.5)
		if not NYield then
			task_wait(0.5)
			if not Character.Humanoid.SeatPart then
				SafeNotify(T("Attempting to gain network ownership of vehicle seat..."))

				local AttemptNetworkOwnershipStart = os.clock()
				while os.clock() - AttemptNetworkOwnershipStart < 0.3 and Character.Humanoid.SeatPart == nil do
					RunService.Heartbeat:Wait()
					Utils.TP(VehicleSeat:GetPivot())
					VehicleSeat.AssemblyLinearVelocity = Vector3.yAxis * math.random() * 10
				end

				Utils.TP(Origin)
				Vehicle:PivotTo(Origin)
				VehicleSeat.AssemblyLinearVelocity = Vector3.zero
				for _, BasePart in next, Character:GetDescendants() do
					if BasePart:IsA("BasePart") then
						BasePart.AssemblyLinearVelocity = Vector3.zero
						BasePart.AssemblyAngularVelocity = Vector3.zero
					end
				end

				fireproximityprompt(Prompt)
				task_wait(0.5)
			end

			if Character.Humanoid.SeatPart == nil then
				SafeNotify(T("Failed to sit in vehicle seat."))
				return
			else
				SafeNotify(T("Successfully sat in vehicle seat."))
			end
		else
			Character:PivotTo(Vehicle:GetPivot())
		end
	end

	local function AssertArgument(ArgumentName: string): boolean
		local Data = ArgumentChecks[ArgumentName]
		if not Data then
			warn("Argument check for", ArgumentName, "not found.")
			return false
		end
		return Data.Found
	end

	for _, Function in next, GameRegistry.consume_stamina do
		local Sprint_Bar = debug.getupvalue(Function, 2).sprint_bar
		if Sprint_Bar then
			print("Stamina hooks ready! [2/2]", Sprint_Bar)
		end

		print("Registering infinite stamina hook [" .. tostring(Sprint_Bar.update) .. "]")
		HookMgr.RegisterHook("inf_stamina" .. tostring(Sprint_Bar.update), Sprint_Bar.update, function(Old, ...)
			if G_Toggle("InfiniteStamina") then
				return Old(function()
					return 1
				end)
			else
				return Old(...)
			end
		end)
	end

	local CharacterAdded = LPH_JIT_MAX(function(Character: Model)
		Storage.Panic = false

		for _, Connection in next, Storage.CharacterConnections do
			Cleaner.CleanOne(Connection)
		end
		Storage.CharacterConnections = {}

		local BodyMoverConnection =
			ConnectionProxyMgr:YieldForConnection(Character.DescendantAdded, "PlayerWellbeing", 1)
		print("BodyMoverConnection Found @ ", BodyMoverConnection)
		if BodyMoverConnection then
			ConnectionProxyMgr:Register(BodyMoverConnection):Disable()
		end

		do
			local name = _nextKey(Storage.Routines, "CharacterBillboardScan")
			Storage.Routines[name] = task_defer(function()
				local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart") :: Part
				local Name =
					HumanoidRootPart:WaitForChild("CharacterBillboardGui"):WaitForChild("PlayerName") :: TextLabel

				local TextChangedConnection = ConnectionProxyMgr:YieldForConnection(
					Name:GetPropertyChangedSignal("Text"),
					"CharacterBillboardGui",
					2
				)
				if TextChangedConnection then
					dbgprint("Found Name Text connection:", TextChangedConnection)
					ConnectionProxyMgr:Register(TextChangedConnection):Disable()
				end
			end)
		end

		local UpperTorso = Character:WaitForChild("UpperTorso") :: Part

		local __conn_SteppedNoclip = Cleaner(RunService.Stepped:Connect(function()
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
				UpperTorso.CanCollide = true
			end
		end))
		Storage.Connections[_nextKey(Storage.Connections, "Character_Stepped_Noclip")] = __conn_SteppedNoclip
		table.insert(Storage.CharacterConnections, __conn_SteppedNoclip)

		local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

		local __conn_IsDeadOnce = Cleaner(Humanoid:GetAttributeChangedSignal("IsDead"):Once(function()
			if ArgumentChecks.Respawn.Found and G_Toggle("AutoRespawn") then
				for i = 1, 60 do
					task_wait(0.1)
					SecureNet.Send(ArgumentChecks.Respawn.Value)
				end
			end
		end))
		Storage.Connections[_nextKey(Storage.Connections, "Humanoid_IsDead_Once")] = __conn_IsDeadOnce
		table.insert(Storage.CharacterConnections, __conn_IsDeadOnce)

		local __conn_KilledByChanged = Cleaner(Humanoid:GetAttributeChangedSignal("KilledBy"):Connect(function()
			local Attribute = Humanoid:GetAttribute("KilledBy")
			if Attribute then
				Storage.LastKilledBy = Attribute
			end
		end))
		Storage.Connections[_nextKey(Storage.Connections, "Humanoid_KilledBy_Changed")] = __conn_KilledByChanged
		table.insert(Storage.CharacterConnections, __conn_KilledByChanged)

		local __conn_IsRagdollingChanged =
			Cleaner(Character:GetAttributeChangedSignal("IsRagdolling"):Connect(function()
				if Character:GetAttribute("IsRagdolling") and G_Toggle("Anti-Ragdoll") then
					for i = 1, 5 do
						task_wait()
						SecureNet.Send(ArgumentChecks.End_Ragdoll_Early.Value)
					end
				end
			end))
		Storage.Connections[_nextKey(Storage.Connections, "Character_IsRagdolling_Changed")] =
			__conn_IsRagdollingChanged
		table.insert(Storage.CharacterConnections, __conn_IsRagdollingChanged)

		for _, Descendant in next, Character:GetDescendants() do
			if Descendant:IsA("BasePart") then
				for _, Connection in next, getconnections(Descendant:GetPropertyChangedSignal("CanCollide")) do
					if Connection.Function then
						dbgprint("Found CanCollide connection on", Descendant:GetFullName(), ":", Connection.Function)
						Connection:Disable()
					end
				end
			end
		end
	end)

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

	local function WaitForTable(Root: Instance, InstancePath: { string }, Timeout: number?)
		local Instance = Root
		for i, v in pairs(InstancePath) do
			Instance = Instance:WaitForChild(v, Timeout)
		end
		return Instance
	end

	local GetVehicle = LPH_JIT_MAX(function(): { Vehicle: Model?, Name: string? }?
		local Character = AssertCharacter()
		local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
		local VehicleSeat = Humanoid.SeatPart

		if VehicleSeat and VehicleSeat.ClassName == "VehicleSeat" then
			local Vehicle = VehicleSeat.Parent :: Model
			local VehicleName = Vehicle.Name

			return {
				Vehicle = Vehicle,
				Name = VehicleName,
			}
		end

		return nil
	end)

	local FindVehicle = LPH_JIT_MAX(function(): { Vehicle: Model?, Name: string? }?
		for _, Vehicle in next, Vehicles:GetChildren() do
			if Vehicle:GetAttribute("OwnerUserId") == LocalUserId then
				return {
					Vehicle = Vehicle,
					Name = Vehicle.Name,
				}
			end
		end
		return nil
	end)

	local GetUniformSamplesInSphere = LPH_JIT_MAX(function(centerPosition, radius, numberOfSamples): { Vector3 }
		local RNG = Random.new(tick())

		-- Input validation
		if typeof(centerPosition) ~= "Vector3" then
			warn("GetUniformSamplesInSphere: centerPosition must be a Vector3. Got:", typeof(centerPosition))
			return {}
		end
		if typeof(radius) ~= "number" or radius < 0 then
			warn("GetUniformSamplesInSphere: radius must be a non-negative number. Got:", radius)
			return {}
		end
		if typeof(numberOfSamples) ~= "number" or numberOfSamples < 0 or numberOfSamples % 1 ~= 0 then
			warn("GetUniformSamplesInSphere: numberOfSamples must be a non-negative integer. Got:", numberOfSamples)
			return {}
		end

		if radius == 0 and numberOfSamples > 0 then -- All points will be at the center
			local samples = {}
			for _ = 1, numberOfSamples do
				table.insert(samples, centerPosition)
			end
			return samples
		end

		local samples = {}

		for _ = 1, numberOfSamples do
			-- 1. Random Azimuthal Angle (theta)
			local theta = RNG:NextNumber() * 2 * math.pi -- Random number between 0 and 2*pi

			-- 2. Random Polar Angle (phi)
			-- We need cos(phi) to be uniform between -1 and 1
			local cosPhi = (RNG:NextNumber() * 2) - 1 -- Random number between -1 and 1
			local phi = math.acos(cosPhi)
			local sinPhi = math_sin(phi) -- math.sqrt(1 - cosPhi^2) could also be used

			-- 3. Random Radius (r_sample), corrected for uniform volume
			-- (random_0_1 ^ (1/3))
			local u = RNG:NextNumber() -- Random number between 0 and 1
			local r_sample = radius * (u ^ (1 / 3)) -- or math.cbrt(u) if available and preferred

			-- 4. Convert to Cartesian Coordinates (relative to origin)
			local x = r_sample * sinPhi * math.cos(theta)
			local y = r_sample * sinPhi * math_sin(theta)
			local z = r_sample * cosPhi

			-- 5. Offset by Center Position and add to samples
			table.insert(samples, centerPosition + Vector3.new(x, y, z))
		end

		return samples
	end)

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

		-- local rayPart = Instance.new("Part")
		-- rayPart.CanQuery = false
		-- rayPart.Anchored = true
		-- rayPart.CanCollide = false
		-- rayPart.Color = Color3.new(1, 0, 0)
		-- rayPart.Size = Vector3.new(0.2, 0.2, (Origin - Target).Magnitude)
		-- rayPart.Material = Enum.Material.ForceField
		-- rayPart.CFrame = CFrame.new(Origin + (Target - Origin).Unit * ((Origin - Target).Magnitude / 2))
		-- 	* CFrame.new(Origin, Target).Rotation
		-- rayPart.Parent = workspace
		-- Debris:AddItem(rayPart, LPH_OBFUSCATED and 1 or 60)
		-- return rayPart
		return RayData
	end

	local GetPredictedWithGun = LPH_JIT_MAX(function(Part: BasePart, _)
		assert(Part.Parent)

		-- Prediction will return a predicted position for the best tracking part (HRP or SeatPart).
		local PredictedPos = Prediction:GetPredictedPosition(Part)

		if (not LPH_OBFUSCATED) or G_Toggle("VisualizeHitReg") then
			local PingSeconds = LocalPlayer:GetNetworkPing()

			local ServerTransform = nil

			task.delay(PingSeconds * 2, function()
				ServerTransform = Part.CFrame
			end)

			local Bind = "GizmoRay" .. tostring(tick())
			local Pos, VelPos = Part.Position, (Part.Position + (Part.AssemblyLinearVelocity * PingSeconds))
			local Size, Transform = Part.Size, Part.CFrame

			RunService:BindToRenderStep(Bind, 500, function()
				Gizmo.PushProperty("Color3", Color3.new(1, 0.984314, 0))
				Gizmo.Box:Draw(CFrame.new(PredictedPos) * Transform.Rotation, Size, true)

				Gizmo.PushProperty("Color3", Color3.new(1, 0, 0))
				Gizmo.Box:Draw(Transform, Size, true)
				Gizmo.Arrow:Draw(Pos, VelPos, 0.2, (Pos - VelPos).Magnitude, 12)

				if ServerTransform then
					Gizmo.PushProperty("Color3", Color3.new(0.282353, 1, 0))
					Gizmo.Box:Draw(ServerTransform * Transform.Rotation, Size, true)
				end
			end)

			task.delay(LPH_OBFUSCATED and 5 or 60, function()
				RunService:UnbindFromRenderStep(Bind)
			end)
		end

		return PredictedPos
	end)

	local SecureLerpTeleport
	SecureLerpTeleport = LPH_JIT_MAX(
		function(
			Origin: CFrame,
			Target: CFrame,
			StudsPerSecond: number,
			Conditional: (() -> boolean)?,
			IsRecursive: boolean?,
			LastDetectionType: string?
		)
			local MovementFlag = false
			local MovementFlagType = "None"
			local YVelocity = 0
			local StartTime = os.clock()
			local VerticalBuffer = 0
			local Character = LocalPlayer.Character
			local RootPart = AssertCharacter():WaitForChild("HumanoidRootPart")

			local Params = RaycastParams.new()
			Params.FilterType = Enum.RaycastFilterType.Exclude
			Params.FilterDescendantsInstances = {
				Character,
				Vehicles,
				Map:WaitForChild("BoundaryWalls"),
				Map.Vegetation.Trees,
				Map.Props.PowerLines,
				Map.Props.PrestigeMotorsLargeSign,
				Map.RoadNetwork.TrafficLights,
			}
			for _, v in next, Map.Props:GetChildren() do
				if v.Name ~= "NewProps" and (not v.Name:match("FuseBox")) then
					Params:AddToFilter(v)
				end
			end
			Params.RespectCanCollide = true

			local TreeParams = RaycastParams.new()
			TreeParams.FilterType = Enum.RaycastFilterType.Include
			TreeParams.FilterDescendantsInstances = { Map.Vegetation.Trees, Map.RoadNetwork.TrafficLights }

			local Abort, Conditional_Abort = false, false
			if not Conditional then
				Conditional = function()
					return true
				end
			end
			assert(Conditional)

			local TotalDistance = (Origin.Position - Target.Position).Magnitude
			if TotalDistance < 0.01 then
				return { Status = "Success" }
			end
			local TotalDuration = TotalDistance / StudsPerSecond

			if G_Toggle("AvoidWaitingAtATMs") and os.clock() - Storage.LastHackedATM + TotalDuration < 5 then
				TotalDuration += 5 - (os.clock() - Storage.LastHackedATM + TotalDuration)
			end

			local AlphaCalculator
			if G_Toggle("SpeedRamp") and IsRecursive then
				local VMax, DTotal, RampDuration, DRampHypothetical =
					StudsPerSecond, TotalDistance, 1, (StudsPerSecond * 1) / 2
				if DTotal >= DRampHypothetical then
					TotalDuration = RampDuration + (DTotal - DRampHypothetical) / VMax
					AlphaCalculator = function(ElapsedTime)
						if ElapsedTime < RampDuration then
							return ((VMax / RampDuration) * (ElapsedTime ^ 2 / 2)) / DTotal
						end
						return (DRampHypothetical + (ElapsedTime - RampDuration) * VMax) / DTotal
					end
				else
					TotalDuration = math.sqrt(2 * DTotal * RampDuration / VMax)
					AlphaCalculator = function(ElapsedTime)
						return TotalDuration > 0 and (ElapsedTime / TotalDuration) ^ 2 or 1
					end
				end
			else
				TotalDuration = TotalDistance / StudsPerSecond
				AlphaCalculator = function(ElapsedTime)
					return TotalDuration > 0 and ElapsedTime / TotalDuration or 1
				end
			end

			local function ShapecastDown(Position: Vector3)
				return workspace:Spherecast(Position + Vector3.yAxis * 100, 2, Vector3.yAxis * -200, Params)
			end
			local function Shapecast(CFrameOrigin: Vector3, Target: Vector3)
				return workspace:Blockcast(
					CFrame.new(CFrameOrigin, Target),
					RootPart.Size,
					(Target - CFrameOrigin),
					Params
				)
			end

			local LastHeight, CurrentHeight = Origin.Position.Y + 10, Origin.Position.Y + 10
			SecureNet.Send(ArgumentChecks.Sprint.Value, true)
			local LastSprintCall = os.clock()

			local MovementCallConnection = MovementEvent.Event:Connect(function(Type: string)
				if Type == "TP" or Type == "Noclip" then
					MovementFlag, MovementFlagType = true, Type
				end
			end)

			local CharacterParts = {}
			for _, part in ipairs(Character:GetDescendants()) do
				if part:IsA("BasePart") then
					table.insert(CharacterParts, part)
				end
			end

			local RenderConnection
			local VisualizationData = {
				ForwardBox = nil,
				BackwardBox = nil,
				CurrentArrow = nil,
				FutureArrow = nil,
				BehindArrow = nil,
			}
			if not LPH_OBFUSCATED then
				RenderConnection = RunService.RenderStepped:Connect(function()
					-- Draw forward horizontal shapecast box
					if VisualizationData.ForwardBox then
						Gizmo.PushProperty("Color3", Color3.new(0, 1, 0.866667))
						Gizmo.Box:Draw(VisualizationData.ForwardBox.CFrame, VisualizationData.ForwardBox.Size, true)
					end
					-- Draw backward horizontal shapecast box
					if VisualizationData.BackwardBox then
						Gizmo.PushProperty("Color3", Color3.new(0.980392, 0.588235, 0))
						Gizmo.Box:Draw(VisualizationData.BackwardBox.CFrame, VisualizationData.BackwardBox.Size, true)
					end
					-- Draw current position shapecast arrow
					if VisualizationData.CurrentArrow then
						Gizmo.PushProperty("Color3", Color3.new(0, 1, 0.05098))
						Gizmo.Arrow:Draw(
							VisualizationData.CurrentArrow.From,
							VisualizationData.CurrentArrow.To,
							1,
							(VisualizationData.CurrentArrow.From - VisualizationData.CurrentArrow.To).Magnitude,
							3
						)
					end
					-- Draw future position shapecast arrow
					if VisualizationData.FutureArrow then
						Gizmo.PushProperty("Color3", Color3.new(0, 1, 0.984314))
						Gizmo.Arrow:Draw(
							VisualizationData.FutureArrow.From,
							VisualizationData.FutureArrow.To,
							1,
							(VisualizationData.FutureArrow.From - VisualizationData.FutureArrow.To).Magnitude,
							3
						)
					end
					-- Draw behind position shapecast arrow
					if VisualizationData.BehindArrow then
						Gizmo.PushProperty("Color3", Color3.new(1, 0.5, 0))
						Gizmo.Arrow:Draw(
							VisualizationData.BehindArrow.From,
							VisualizationData.BehindArrow.To,
							1,
							(VisualizationData.BehindArrow.From - VisualizationData.BehindArrow.To).Magnitude,
							3
						)
					end
				end)
			end

			while os.clock() - StartTime < TotalDuration do
				local DeltaTime = RunService.Heartbeat:Wait()
				local CurrentTime = os.clock()

				VerticalBuffer = math_max(0, VerticalBuffer - (2 * 20 * DeltaTime))

				if Abort or not Conditional() then
					Conditional_Abort = true
					break
				end
				if Storage.Panic then
					local WaitingForPanicTime = CurrentTime
					repeat
						task_wait()
					until not Storage.Panic or os.clock() - WaitingForPanicTime > 15
					Storage.Panic = false
					SafeNotify(T("Panic mode timeout, disabling."))
				end
				if MovementFlag then
					if RenderConnection then
						RenderConnection:Disconnect()
					end

					return SecureLerpTeleport(
						Character:GetPivot()
							+ Vector3.new((math.random(0, 1) * 2 - 1) * 5, 0, (math.random(0, 1) * 2 - 1) * 5),
						Target,
						StudsPerSecond,
						Conditional,
						true,
						MovementFlagType
					)
				end

				local ElapsedTime = CurrentTime - StartTime
				local Alpha = math.clamp(AlphaCalculator(ElapsedTime), 0, 1)

				if CurrentTime - LastSprintCall > 0.5 then
					SecureNet.Send(ArgumentChecks.Sprint.Value, true)
					LastSprintCall = CurrentTime
				end

				for _, Part in next, CharacterParts do
					Part.AssemblyLinearVelocity = Vector3.zero
					Part.AssemblyAngularVelocity = Vector3.zero
				end

				local CurrentPosition = Origin.Position:Lerp(Target.Position, Alpha)
				if
					workspace:Raycast(
						Character:GetPivot().Position,
						(Target.Position - Origin.Position).Unit * 20,
						TreeParams
					)
				then
					Origin += Character:GetPivot().RightVector * 10
					CurrentPosition = Origin.Position:Lerp(Target.Position, Alpha)
				end

				local lookaheadTime, lookbehindTime = 0.2, 0.1
				local alphaOffsetForward = TotalDuration > 0 and lookaheadTime / TotalDuration or 0
				local alphaOffsetBackward = TotalDuration > 0 and lookbehindTime / TotalDuration or 0

				local CurrentRaycast = ShapecastDown(CurrentPosition)
				local groundY = CurrentRaycast and CurrentRaycast.Position.Y or (CurrentHeight - 2.5)
				if (not LPH_OBFUSCATED) and CurrentRaycast then
					VisualizationData.currentArrow =
						{ from = CurrentPosition + Vector3.yAxis * 30, to = CurrentRaycast.Position }
				end

				-- Forward shapecast logic
				local FuturePoint = Origin.Position:Lerp(Target.Position, math.clamp(Alpha + alphaOffsetForward, 0, 1))
				local shapecastOrigin = CurrentPosition * Vector3.new(1, 0, 1) + Vector3.yAxis * (groundY + 3)
				local FutureRaycastHorizontal = Shapecast(shapecastOrigin, FuturePoint)
				if FutureRaycastHorizontal then
					if not LPH_OBFUSCATED then
						local dist = (FutureRaycastHorizontal.Position - shapecastOrigin).Magnitude
						VisualizationData.forwardBox = {
							cframe = CFrame.new(shapecastOrigin, FutureRaycastHorizontal.Position),
							size = RootPart.Size + Vector3.new(0, 0, dist - 1),
						}
					end
					FuturePoint = FutureRaycastHorizontal.Position
				else
					if not LPH_OBFUSCATED then
						VisualizationData.forwardBox = nil
					end
				end
				local FutureRaycast = ShapecastDown(FuturePoint)
				if (not LPH_OBFUSCATED) and FutureRaycast then
					VisualizationData.futureArrow =
						{ from = FuturePoint + Vector3.yAxis * 30, to = FutureRaycast.Position }
				end

				local CurrentRaycastHeight = groundY
				local FutureRaycastHeight = (FutureRaycast and FutureRaycast.Position.Y) or CurrentRaycastHeight
				if FutureRaycastHeight > CurrentRaycastHeight + 5 then
					VerticalBuffer = 10
				end
				CurrentHeight = math_max(CurrentRaycastHeight, FutureRaycastHeight) + TP_HEIGHT_OFFSET + VerticalBuffer
				if ElapsedTime < 0.5 then
					CurrentHeight = MovementFlagType == "Noclip" and math_max(285, CurrentHeight) or CurrentHeight + 5
				end

				-- Gravity/falling logic
				if CurrentHeight < LastHeight then
					local BackwardPoint =
						Origin.Position:Lerp(Target.Position, math.clamp(Alpha - alphaOffsetBackward, 0, 1))
					local BackwardRaycastHorizontal = Shapecast(shapecastOrigin, BackwardPoint)
					if BackwardRaycastHorizontal then
						if not LPH_OBFUSCATED then
							local dist = (BackwardRaycastHorizontal.Position - shapecastOrigin).Magnitude
							VisualizationData.backwardBox = {
								cframe = CFrame.new(shapecastOrigin, BackwardRaycastHorizontal.Position),
								size = RootPart.Size + Vector3.new(0, 0, dist - 1),
							}
						end
						BackwardPoint = BackwardRaycastHorizontal.Position
					else
						if not LPH_OBFUSCATED then
							VisualizationData.backwardBox = nil
						end
					end
					local BehindRaycast = ShapecastDown(BackwardPoint)
					if (not LPH_OBFUSCATED) and BehindRaycast then
						VisualizationData.behindArrow =
							{ from = BackwardPoint + Vector3.yAxis * 30, to = BehindRaycast.Position }
					end

					if BehindRaycast and BehindRaycast.Position.Y > CurrentRaycastHeight + 2 then
						CurrentHeight = LastHeight
					else
						YVelocity -= 10 * DeltaTime
						CurrentHeight = math_max(CurrentHeight, LastHeight + YVelocity)
					end
				else
					YVelocity = 0
				end

				LastHeight = CurrentHeight
				local NewPosition = Vector3.new(CurrentPosition.X, CurrentHeight, CurrentPosition.Z)
				local NewCFrame = CFrame.lookAt(Origin.Position, NewPosition).Rotation + NewPosition

				local Vehicle = GetVehicle()
				if Vehicle and Vehicle.Vehicle then
					Vehicle.Vehicle:PivotTo(
						NewCFrame * Vehicle.Vehicle:GetPivot():ToObjectSpace(Character:GetPivot()):Inverse()
					)
				else
					Character:PivotTo(NewCFrame)
				end
			end

			if not Conditional_Abort then
				Character:PivotTo(Target)
			end

			if RenderConnection then
				RenderConnection:Disconnect()
			end

			MovementCallConnection:Disconnect()

			return { Status = Conditional_Abort and "Aborted" or "Success" }
		end
	)

	local function WaitForClass(className: string, retries: number?, delaySeconds: number?)
		delaySeconds = delaySeconds or 1

		for i = 1, (retries or 5) do
			local foundClass = Class_Interface.GetClass(className)
			if foundClass then
				return foundClass
			end
			task_wait(delaySeconds)
		end

		warn("CRITICAL - Could not find '" .. className .. "' class after all retries.")
		return nil
	end

	-- Calculates a path using pathfinding and uses SecureLerpTeleport to move the character along the path.
	local SecureLerpTeleportWithPathfinding
	SecureLerpTeleportWithPathfinding = LPH_JIT_MAX(
		function(Origin: CFrame, Target: CFrame, StudsPerSecond: number, Conditional: (() -> boolean)?)
			if not G_Toggle("ATMFarmUsePath") then
				return SecureLerpTeleport(Origin, Target, StudsPerSecond, Conditional)
			end

			local Conditional_Abort = false

			-- Step 1. Calculate path and identify sharp turns
			local Path = PathLib.GetPath(Origin.Position, Target.Position)

			if not Path or #Path:GetWaypoints() == 0 then
				warn("Failed to calculate path from", Origin.Position, "to", Target.Position)
				SafeNotify(T("Failed to calculate path. Falling back to direct teleportation."))
				return SecureLerpTeleport(Origin, Target, StudsPerSecond, Conditional)
			end

			local Waypoints = Path:GetWaypoints()
			local TurnPoints = {}
			local TurnAngleThreshold = math.rad(35) -- Consider turns sharper than 45 degrees
			local Lookaround = 3 -- How many waypoints to look ahead/behind to calculate angle

			for i = 1, #Waypoints do
				local prevIndex = math_max(1, i - Lookaround)
				local nextIndex = math_min(#Waypoints, i + Lookaround)

				if i == prevIndex or i == nextIndex then
					continue
				end

				local prevDirection = (Waypoints[i].Position - Waypoints[prevIndex].Position).Unit
				local nextDirection = (Waypoints[nextIndex].Position - Waypoints[i].Position).Unit

				if prevDirection.Magnitude > 0.1 and nextDirection.Magnitude > 0.1 then
					local dot = prevDirection:Dot(nextDirection)
					local angle = math.acos(math.clamp(dot, -1, 1))
					if angle > TurnAngleThreshold then
						table.insert(TurnPoints, { Index = i, Angle = angle })
					end
				end
			end

			-- Step 2. Iterate through the path and teleport the character along it
			local CurrentOrigin = Origin
			local VisualWaypoints = PathLib.VisualizePath(Path)
			local MovementFlag = false
			local Start = os.clock()

			local MovementCallConnection = MovementEvent.Event:Connect(function(Type: string)
				if Type == "TP" or Type == "Noclip" then
					MovementFlag = true
				end
			end)

			local Jumping = 0
			local nextTurnIndex = 1

			for Index, Waypoint in next, Waypoints do
				local Visual = PathLib.MarkerFromWaypoint(VisualWaypoints, Waypoint)
				local NextWaypoint = Waypoints[Index + 1]

				-- Calculate speed based on proximity to the next sharp turn
				local MinSpeedFactor = 0.15 -- Slow down to 15% speed on sharpest turns
				local SlowdownDistance = 30 -- Start slowing down 30 studs before a turn
				local SpeedFactor = 1

				-- Find the next turn point ahead of our current position
				while nextTurnIndex <= #TurnPoints and TurnPoints[nextTurnIndex].Index < Index do
					nextTurnIndex += 1
				end

				if nextTurnIndex <= #TurnPoints then
					local turnPoint = TurnPoints[nextTurnIndex]
					local distanceToTurn = (Waypoints[turnPoint.Index].Position - Waypoint.Position).Magnitude

					if distanceToTurn < SlowdownDistance then
						-- The closer we are, the slower we get. Alpha goes from 0 (at SlowdownDistance) to 1 (at the turn)
						local alpha = 1 - (distanceToTurn / SlowdownDistance)
						-- The sharper the turn, the more we slow down
						local turnSeverityFactor = math.clamp(turnPoint.Angle / math.pi, 0, 1)
						local targetSpeedFactor = 1 - (1 - MinSpeedFactor) * turnSeverityFactor
						-- Interpolate between full speed and the target speed for the turn
						SpeedFactor = 1 + (targetSpeedFactor - 1) * alpha
					end
				end

				local ElapsedTime = os.clock() - Start
				local SpeedAlpha = math.clamp(ElapsedTime / TELEPORT_SPEEDUP_TIME, 0, 1)
				local InitialSpeed = StudsPerSecond / 10
				local CurrentSpeed = InitialSpeed + (StudsPerSecond - InitialSpeed) * SpeedAlpha

				local EffectiveStudsPerSecond = CurrentSpeed * SpeedFactor
				local TimeToArrival = (Waypoint.Position - CurrentOrigin.Position).Magnitude
					/ (EffectiveStudsPerSecond * 1.5)

				if
					Waypoint.Action == Enum.PathWaypointAction.Jump
					or (NextWaypoint and NextWaypoint.Action == Enum.PathWaypointAction.Jump)
				then
					Jumping = 4
				end

				Utils.LerpTPWithHeight(Waypoint.Position + Vector3.yAxis * (Jumping > 0 and 7 or 3), TimeToArrival)

				if Jumping > 0 then
					Jumping -= 1
				end

				TweenService:Create(
					Visual.Object,
					TweenInfo.new(TimeToArrival, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
					{
						CFrame = CFrame.new(Visual.Object.Position + Vector3.yAxis * (Jumping > 0 and 7 or 3)),
						Color = Color3.new(0, 1, 0),
					}
				):Play()

				if MovementFlag then
					game:GetService("StarterGui"):SetCore("SendNotification", {
						["Title"] = T("Movement Flagged"),
						["Text"] = T("Movement has been flagged by the anticheat. Pausing..."),
						["Duration"] = 3,
					})
					MovementFlag = false

					local RestabilizeTime = os.clock()

					while (os.clock() - RestabilizeTime < 1.5) or (AssertCharacter():GetPivot().p.Y < 250) do
						task_wait()
						local Vehicle = GetVehicle()
						if Vehicle then
							for _, Descendant in next, Vehicle.Vehicle:GetDescendants() do
								if Descendant:IsA("BasePart") then
									if Descendant.AssemblyLinearVelocity.Magnitude > 100 then
										Descendant.AssemblyLinearVelocity *= Vector3.zero
										Descendant.AssemblyAngularVelocity *= Vector3.zero
									end
								end
							end
						end
					end

					for _, VisualWaypoint in next, VisualWaypoints do
						VisualWaypoint.Object:Destroy()
					end

					return SecureLerpTeleportWithPathfinding(
						LocalPlayer.Character:GetPivot(),
						Target,
						StudsPerSecond,
						Conditional
					)
				end

				if not Conditional or Conditional() then
					CurrentOrigin = CFrame.new(Waypoint.Position + Vector3.yAxis * 3)
				else
					warn("Conditional check failed")
					Conditional_Abort = true
					break
				end
			end

			for _, Visual in next, VisualWaypoints do
				Visual.Object:Destroy()
			end

			MovementCallConnection:Disconnect()

			return (not Conditional_Abort) and { Status = "Success" } or { Status = "Aborted" }
		end
	)

	Storage.Routines[_nextKey(Storage.Routines, "MoveDirection_SpoofLoop")] = Cleaner(task.spawn(function()
		local Flip = 1

		while RunService.Stepped:Wait() do
			local Character = AssertCharacter()
			local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid

			if not Humanoid then
				continue
			end

			Storage.MoveDirection = gethiddenproperty(Humanoid, "MoveDirectionInternal")

			if Storage.MovementSpoof then
				Flip *= -1
				task.wait()
				sethiddenproperty(Humanoid, "MoveDirectionInternal", (Vector3.zAxis / 2) * Flip)
			elseif G_Toggle("SprintTakesNoStamina") then
				sethiddenproperty(Humanoid, "MoveDirectionInternal", Vector3.zero)
			end
		end
	end))

	Storage.Connections[_nextKey(Storage.Connections, "Heartbeat_MoveBoost")] =
		Cleaner(RunService.Heartbeat:Connect(LPH_JIT_MAX(function(DeltaTime)
			local MoveDirection = Storage.MoveDirection
			local Character = AssertCharacter()
			local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid

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

			-- Check if we have a vehicle spawned.
			local Vehicle = FindVehicle()
			if Vehicle and G_Toggle("ATMFarm") then
				local VehicleModel = Vehicle.Vehicle
				-- Check if any parts have an assemblylinearvelocity or assemblyangularvelocity with magnitude > 100
				for _, Part in next, VehicleModel:GetDescendants() do
					if Part:IsA("BasePart") then
						if Part.AssemblyLinearVelocity.Magnitude > 2000 then
							Part.AssemblyLinearVelocity = Vector3.yAxis * math.random()
						end

						if Part.AssemblyAngularVelocity.Magnitude > 2000 then
							Part.AssemblyAngularVelocity = Vector3.yAxis * math.random()
						end
					end
				end

				local Wheels = VehicleModel:FindFirstChild("Wheels") :: Model
				local Chassis = VehicleModel:FindFirstChild("Chassis") :: BasePart
				if Wheels then
					for _, Wheel: Part in next, Wheels:GetChildren() do
						local Distance = (Wheel:GetPivot().Position - Chassis:GetPivot().Position).Magnitude
						if Distance > 50 then
							-- Wheel is flung, bring the wheel back to the chassis center and
							-- rectify the velocity
							Wheel:PivotTo(Chassis:GetPivot())
							local Connection = RunService.Heartbeat:Connect(function()
								for _, v in next, VehicleModel:GetDescendants() do
									if v:IsA("BasePart") then
										v.AssemblyLinearVelocity = Vector3.zero
										v.AssemblyAngularVelocity = Vector3.zero
									end
								end
								Wheel:PivotTo(Chassis:GetPivot())
							end)
							task.delay(3, function()
								Connection:Disconnect()
							end)
						end
					end
				end
			end

			-- If we're not ATM farming make the RayCastGuides non-collidable.
			if not G_Toggle("ATMFarm") then
				for _, Part in next, Storage.RayCastGuides do
					Part.CanCollide = false
					Part.CanQuery = false
				end
			else
				for _, Part in next, Storage.RayCastGuides do
					Part.CanCollide = true
					Part.CanQuery = true
				end
			end
		end)))

	Storage.Connections[_nextKey(Storage.Connections, "LocalPlayer_CharacterAdded")] =
		Cleaner(LocalPlayer.CharacterAdded:Connect(CharacterAdded))
	if LocalPlayer.Character then
		CharacterAdded(LocalPlayer.Character)
	end

	Storage.Routines[_nextKey(Storage.Connections, "Snap_Heartbeat")] = Cleaner(task.spawn(function()
		local Enabled = false
		local Origin = nil

		InitializedSignal.Event:Once(function()
			Library.Toggles.Snap:OnChanged(function(Value)
				Storage.SupressNotification = Value
			end)
		end)

		Cleaner(RunService.Heartbeat:Connect(function()
			local Snap = G_Toggle("Snap") and not Storage.Panic
			local SnapOffsetY = G_Option("SnapOffsetY")

			if Snap then
				if not Enabled then
					Enabled = true
					Origin = AssertCharacter():GetPivot()
					SafeNotify(T("Snap enabled!"))
				end

				local Character = AssertCharacter()

				Character:PivotTo(Origin - Vector3.yAxis * SnapOffsetY)
			else
				Enabled = false
				Origin = nil
				return
			end
		end))
	end))

	--#region Integrity checks

	-- Check if all arguments were found.
	for Argument, Data in next, ArgumentChecks do
		if not Data.Found then
			dbgwarn("Failed to find argument", Argument, "with value", Data.Value)
			local Continue, Abort, UI = ErrorHandler.Throw(
				0x02,
				T("Changes in the internal game structure were detected. Some features have been disabled for safety."),
				true
			)

			local Aborting = false
			local Pressed = false

			Continue:Once(function()
				Pressed = true
				Aborting = false
			end)

			Abort:Once(function()
				Pressed = true
				Aborting = true
				HookMgr.ClearHooks()
				Cleaner.Clean()
				ConnectionProxyMgr:Clear()
				ESP_Library.Unload()
				Aiming_Library.Unload()
				rconsoledestroy()
			end)

			repeat
				task_wait(0.1)
			until Pressed

			UI:Destroy()

			if Aborting then
				coroutine_yield()
				return
			end

			break
		end
	end

	local GunClass = nil

	-- Initialize classes asynchronously
	task_spawn(function()
		task_wait(5)
		GunClass = WaitForClass("Gun")
	end)

	HookMgr.RegisterHook("NetGetHook", Net.get, function(Old, ...)
		local Args = table.pack(...)
		local CallType = Args[1]

		for CallTypeNeedle, _ in next, Storage.Blacklisted_Network_Calls do
			if CallType:match(CallTypeNeedle) then
				return
			end
		end
		if CallType == "fix_desync_hip_height" then
			if G_Toggle("Invisibility") then
				return
			end
			-- elseif CallType == "loading_screen_camera_part" then
			-- 	print("BLOCKED loading_screen_camera_part CALL", ...)
			-- 	return Vector3.new(1,1,1)
		end

		return Old(table.unpack(Args, 1, Args.n))
	end)

	HookMgr.RegisterHook(
		"NetSendHook",
		Net.send,
		LPH_JIT_MAX(function(Old, ...)
			local Args = table.pack(...)
			local CallType = Args[1]

			if CallType == "leave_character_creator" and shared.BlockFirstECC_Call then
				-- print("Blocked LeaveCC call")
				shared.BlockFirstECC_Call = false
				return
			end

			if not checkcaller() then
				for CallTypeNeedle, _ in next, Storage.Blacklisted_Network_Calls do
					if CallType:match(CallTypeNeedle) then
						return
					end
				end

				if CallType == ArgumentChecks.Melee_Attack.Value and G_Toggle("MeleeFixHitchance") then
					local Hits = Args[3]
					local LocalHumanoidRootPart = AssertCharacter():WaitForChild("HumanoidRootPart") :: Part

					if #Hits > 0 then
						local TargetHumanoidRootPart = Hits[1].Character:WaitForChild("HumanoidRootPart") :: Part
						Args[4] = CFrame.lookAt(
							LocalHumanoidRootPart:GetPivot().Position,
							TargetHumanoidRootPart:GetPivot().Position
						)
					end

					return Old(table.unpack(Args, 1, Args.n))
				elseif CallType == "shoot_gun" then
					local GunInstance = Args[2] :: Tool

					if G_Toggle("SilentAimEnabled") and Aiming_Library.CurrentTarget and GunClass then
						local Target = Aiming_Library.CurrentTarget
						local HitPart = Target:FindFirstChild(G_Option("SilentAimPart"))
							or Target:FindFirstChild("HumanoidRootPart")
						local GunWrapper = GunClass.objects[GunInstance]

						local function CheckLineOfSight(
							StartPos: Vector3,
							EndPos: Vector3,
							FilterInstances: { Instance }
						): (boolean, Vector3?)
							local CurrentRayOrigin = StartPos
							local RayParams = RaycastParams.new()
							RayParams.FilterType = Enum.RaycastFilterType.Exclude
							RayParams.FilterDescendantsInstances = FilterInstances

							local MaxIterations = 10
							for _ = 1, MaxIterations do
								local Direction = (EndPos - CurrentRayOrigin)
								local Distance = Direction.Magnitude
								if Distance < 0.01 then
									return true, nil
								end
								Direction = Direction.Unit

								local RayResult = workspace:Raycast(CurrentRayOrigin, Direction * Distance, RayParams)
								if not RayResult then
									return true, nil
								end

								local HitInstance = RayResult.Instance
								if HitInstance then
									local IsGlass = CollectionService:HasTag(HitInstance, "Glass")
									local IsTransparent = HitInstance.Transparency > 0.2

									if IsGlass or IsTransparent then
										CurrentRayOrigin = RayResult.Position + Direction * 0.01
									else
										return false, RayResult.Position
									end
								else
									return false, RayResult.Position
								end
							end
							return true, nil
						end

						if HitPart and GunWrapper then
							local MultiShot = GunInstance:GetAttribute("Multishot") or 1
							local PredictedPosition = G_Toggle("Prediction")
									and GetPredictedWithGun(HitPart, GunInstance)
								or HitPart.Position
							local InitialOrigin = Camera.CFrame.Position
							local Origin = InitialOrigin

							local LineOfSightFilter = { AssertCharacter(), Target }
							local ShotClear, _ =
								CheckLineOfSight(AssertCharacter().Head.Position, PredictedPosition, LineOfSightFilter)

							if not ShotClear and G_Toggle("MultiResolve") then
								local SamplePoints = GetUniformSamplesInSphere(InitialOrigin, 10, 50)
								for _, SamplePoint in next, SamplePoints do
									local SampleIsClear, _ =
										CheckLineOfSight(SamplePoint, PredictedPosition, LineOfSightFilter)
									if SampleIsClear then
										Origin = SamplePoint
										break
									end
								end
							end

							if (not LPH_OBFUSCATED) or G_Toggle("VisualizeHitReg") then
								local RayData = VisualizeRay(Origin, PredictedPosition)
								local HitTimeout = 0.2 + LocalPlayer:GetNetworkPing()
								local Humanoid = HitPart.Parent:WaitForChild("Humanoid") :: Humanoid
								local LastHealth = Humanoid.Health

								local HumanoidDamagedConnection = Humanoid.HealthChanged:Connect(function(NewHealth)
									if NewHealth > LastHealth then
										LastHealth = NewHealth
									elseif NewHealth < LastHealth then
										RayData.Hit = true
										-- print("Shot hit target!")
									end
								end)

								task.delay(HitTimeout, function()
									if not RayData.Hit then
										-- warn("Shot timed out...")
									end
									HumanoidDamagedConnection:Disconnect()
								end)
							end

							local GunAccuracy, GunSeed =
								secure_call(GunWrapper.states.accuracy.get), secure_call(GunWrapper.states.seed.get)
							local GunRNG = Random.new(GunSeed)
							local SpreadFactor = 1 - GunAccuracy
							local RX, RY, RZ =
								GunRNG:NextNumber(-50, 50), GunRNG:NextNumber(-50, 50), GunRNG:NextNumber(-50, 50)
							local SpreadVector = Vector3.new(RX * SpreadFactor, RY * SpreadFactor, RZ * SpreadFactor)
							local PerfectDirection = (PredictedPosition - Origin).Unit
							local ReversedAimDirection = (PerfectDirection * 500 - SpreadVector).Unit

							Args[3] = CFrame.lookAt(Origin, Origin + ReversedAimDirection)

							-- Args[3] = CFrame.lookAt(
							-- 	PredictedPosition - (HitPart.AssemblyLinearVelocity.Unit * 10),
							-- 	PredictedPosition
							-- )

							local HitResult = {
								{
									["Normal"] = (PredictedPosition - Origin).Unit,
									["Instance"] = HitPart,
									["Position"] = PredictedPosition
										+ (PredictedPosition - Camera.CFrame.Position).Unit, -- Punch through a bit for under-predictions
								},
							}

							local Results = {}
							local MultiShotCount = GunInstance:GetAttribute("Multishot") or 1
							for i = 1, MultiShotCount do
								table.insert(Results, HitResult)
							end

							if G_Toggle("VisualizeBullets") then
								for _, Result in next, Results do
									VisualizeRay(Args[3].Position, Result[1].Position).Color = Color3.new(0, 1, 0)
								end
							end

							if (MultiShot == 1 and G_Toggle("Wallbang")) and not ShotClear then
								Args[3] = CFrame.new(Vector3.new(math.huge, math.huge, math.huge))
									* CFrame.lookAt(Origin, Origin + ReversedAimDirection).Rotation
							end

							Args[4] = Results
						end
					end

					if G_Toggle("DoubleTap") then
						Old(table.unpack(Args, 1, Args.n))
					end

					return Old(table.unpack(Args, 1, Args.n))
				elseif CallType == "throw_item" then
					if G_Toggle("ThrowableSilentAimEnabled") then
						local HitPart: BasePart?
						if Aiming_Library.CurrentTarget then
							HitPart = Aiming_Library.CurrentTarget:FindFirstChild(G_Option("SilentAimPart"))
								or Aiming_Library.CurrentTarget:FindFirstChild("HumanoidRootPart")
							if HitPart then
								Args[3] = HitPart.Position + Vector3.new(0, 1, 0)
								Args[4] = CFrame.new(Args[3], HitPart.Position).LookVector
								return Old(table.unpack(Args, 1, Args.n))
							end
						end
					end
				end

				if CallType == "crashed_car" and G_Toggle("NoCrash") then
					return
				end
			end

			return Old(table.unpack(Args, 1, Args.n))
		end)
	)

	HookMgr.RegisterHook("NotificationSupressionHook", NotificationsUI.show_notification, function(Old, ...)
		if Storage.SupressNotification then
			local Traceback = debug.traceback() :: string
			if Traceback:find("Net") then
				-- warn("Suppressed server-invoked notification", ...)
				return
			end
		end
		return Old(...)
	end)

	UpdateStatus(T("Skipping splash screen..."))

	Storage.Connections[_nextKey(Storage.Connections, "Remotes_Send_OnClientEvent")] =
		Cleaner(ReplicatedStorage.Remotes.Send.OnClientEvent:Connect(LPH_JIT_MAX(function(...)
			local Args = { ... }
			local Call_Type = Args[1]

			if Call_Type == "notification" then
				-- warn("Notification received:", ...)
				local Anticheat_Detection_Types = {
					["Teleport detected"] = "TP",
					["Anti noclip triggered"] = "Noclip",
					["Fly detected"] = "Flight",
				}

				local DetectionType = Anticheat_Detection_Types[Args[3]]
				if DetectionType then
					MovementEvent:Fire(DetectionType)
				end
			end
		end)))

	if LocalPlayer:GetAttribute("InSplashScreen") == true then
		local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
		local SplashScreenGui = PlayerGui:WaitForChild("SplashScreenGui", 5)
		if SplashScreenGui then
			SplashScreenGui.Enabled = false
		end

		local SoundService = game:GetService("SoundService")
		local Sound = SoundService:FindFirstChild("Sound")
		if Sound then
			Sound:Destroy()
		end

		-- Make a prompt to ask if you should spawn in God-Mode or Normally.
		-- Check if we have teleport data first

		local SpawnMode = nil
		local SpawnModeFrame = nil

		if not TeleportData:ReadData("TeleportState") then
			local PromptStart = os.clock()

			SpawnModeFrame = Instance.new("ScreenGui")
			SpawnModeFrame.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			SpawnModeFrame.Name = "SpawnMode"
			SpawnModeFrame.DisplayOrder = 999999999
			SpawnModeFrame.Parent = CoreGui
			shared.SpawnModeFrame = SpawnModeFrame

			local Root = Instance.new("Frame")
			Root.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Root.AnchorPoint = Vector2.new(0.5, 0.5)
			Root.BackgroundTransparency = 0.8999999761581421
			Root.Position = UDim2.new(0.5, 0, 0.5, 0)
			Root.Name = "Root"
			Root.Size = UDim2.new(0.25, 0, 0.25, 30)
			Root.BorderSizePixel = 0
			Root.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Root.Parent = SpawnModeFrame

			local SpawnModeLabel = Instance.new("TextLabel")
			SpawnModeLabel.TextWrapped = true
			SpawnModeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			SpawnModeLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SpawnModeLabel.Text = T("Select Spawn Mode")
			SpawnModeLabel.Name = "SpawnMode"
			SpawnModeLabel.Size = UDim2.new(1, 0, 0, 0)
			SpawnModeLabel.BorderSizePixel = 0
			SpawnModeLabel.BackgroundTransparency = 0.20000000298023224
			SpawnModeLabel.RichText = true
			SpawnModeLabel.FontFace =
				Font.new("rbxassetid://16658221428", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			SpawnModeLabel.AutomaticSize = Enum.AutomaticSize.Y
			SpawnModeLabel.TextSize = 40
			SpawnModeLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			SpawnModeLabel.Parent = Root

			local UIListLayout = Instance.new("UIListLayout")
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout.VerticalFlex = Enum.UIFlexAlignment.Fill
			UIListLayout.Padding = UDim.new(0, 5)
			UIListLayout.Parent = Root

			local GodMode = Instance.new("TextButton")
			GodMode.LayoutOrder = 1
			GodMode.FontFace = Font.new("rbxassetid://16658221428", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			GodMode.Active = false
			GodMode.Selectable = false
			GodMode.TextSize = 30
			GodMode.Size = UDim2.new(1, 0, 0, 0)
			GodMode.RichText = true
			GodMode.TextColor3 = Color3.fromRGB(255, 255, 255)
			GodMode.BorderColor3 = Color3.fromRGB(0, 0, 0)
			GodMode.Text = `{T("God Mode")}<br/><font size="20"><i>{T("(Can't damage players or work)")}</i></font>`
			GodMode.BackgroundTransparency = 0.5
			GodMode.Name = "GodMode"
			GodMode.BorderSizePixel = 0
			GodMode.TextWrapped = true
			GodMode.AutomaticSize = Enum.AutomaticSize.Y
			GodMode.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			GodMode.Parent = Root

			local UIPadding = Instance.new("UIPadding")
			UIPadding.PaddingBottom = UDim.new(0, 10)
			UIPadding.PaddingTop = UDim.new(0, 10)
			UIPadding.Parent = GodMode

			local NormalMode = Instance.new("TextButton")
			NormalMode.LayoutOrder = 2
			NormalMode.FontFace = Font.new("rbxassetid://16658221428", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			NormalMode.Active = false
			NormalMode.Selectable = false
			NormalMode.TextSize = 30
			NormalMode.Size = UDim2.new(1, 0, 0, 0)
			NormalMode.RichText = true
			NormalMode.TextColor3 = Color3.fromRGB(255, 255, 255)
			NormalMode.BorderColor3 = Color3.fromRGB(0, 0, 0)
			NormalMode.Text = `{T("Normal Mode")}<br/><font size="20"><i>{T("(Spawn in normally)")}</i></font>`
			NormalMode.BackgroundTransparency = 0.5
			NormalMode.Name = "NormalMode"
			NormalMode.BorderSizePixel = 0
			NormalMode.TextWrapped = true
			NormalMode.AutomaticSize = Enum.AutomaticSize.Y
			NormalMode.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			NormalMode.Parent = Root

			local UIPadding2 = Instance.new("UIPadding")
			UIPadding2.PaddingBottom = UDim.new(0, 10)
			UIPadding2.PaddingTop = UDim.new(0, 10)
			UIPadding2.Parent = NormalMode

			local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
			UIAspectRatioConstraint.AspectRatio = 2
			UIAspectRatioConstraint.AspectType = Enum.AspectType.ScaleWithParentSize
			UIAspectRatioConstraint.Parent = Root

			NormalMode.MouseButton1Click:Connect(function()
				SpawnMode = "Normal"
			end)

			GodMode.MouseButton1Click:Connect(function()
				SpawnMode = "God"
			end)

			repeat
				task_wait()
			until (SpawnMode ~= nil) or (os.clock() - PromptStart > 10) or DUPE_MODE

			SpawnModeFrame:ClearAllChildren()

			if SpawnMode == nil then
				SpawnMode = DUPE_MODE and "God" or "Normal"
			end

			if (SpawnMode == "God") or DUPE_MODE then
				shared.BlockFirstECC_Call = true
			end
		end

		local ThreadSignal = Instance.new("BindableEvent")

		local SplashScreenModule = Modules.Game:WaitForChild("SplashScreen") :: ModuleScript
		SplashScreenModule = SafeRequire(SplashScreenModule)
		local CharacterCreatorModule =
			Modules.Game:WaitForChild("CharacterCreator"):WaitForChild("CharacterCreator") :: ModuleScript
		CharacterCreatorModule = SafeRequire(CharacterCreatorModule)

		task_spawn(function()
			secure_call(SplashScreenModule.in_loading_screen.set, false)
			task_wait(1)
			secure_call(CharacterCreatorModule.finish)
			ThreadSignal:Fire()
		end)

		ThreadSignal.Event:Wait()
		ThreadSignal:Destroy()

		if (SpawnMode == "God") or DUPE_MODE then
			task_wait(2)

			shared.GodMode = true

			local Character = AssertCharacter()
			local Origin = Character:GetPivot()
			local Target = CFrame.new(Origin.X, 265, Origin.Z)
			local Distance = (Target.Position - Origin.Position).Magnitude

			SecureNet.Send(ArgumentChecks.Sprint.Value, true)
			Utils.LerpTP(Target, Distance / 20)

			for _, Connection in next, getconnections(LocalPlayer.CharacterAdded) do
				local Function = Connection.Function
				if Function and getfenv(Function) and getfenv(Function).script then
					Connection:Fire(Character)
				end
			end

			if DUPE_MODE then
				print("Enabling rollback...")

				-- First, find a car and spawn it.

				local InventoryVehicle = nil

				for _ = 1, 5 do
					for _, ItemName in next, VehicleCandidates do
						local Item = Inventory.GetItemsByName(ItemName)[1]
						if Item then
							InventoryVehicle = Item
							SafeNotify(T("Found InventoryItem Vehicle " .. ItemName))
							break
						end
					end

					if InventoryVehicle then
						break
					else
						SafeNotify(T("No vehicle found in inventory, retrying..."))
						task.wait(1)
					end
				end

				task.wait(1)

				if InventoryVehicle then
					if ArgumentChecks.Toggle_Equip_Item.Found then
						SafeNotify(T(`Attempting to spawn vehicle {InventoryVehicle.Name}...`))
						SecureNet.Get(ArgumentChecks.Toggle_Equip_Item.Value, InventoryVehicle.Guid)

						task.wait(3)

						if not FindVehicle() then
							-- Keep retrying to spawn the vehicle until it works.
							for _ = 1, 5 do
								SecureNet.Get(ArgumentChecks.Toggle_Equip_Item.Value, InventoryVehicle.Guid)
								task.wait(3)
								if FindVehicle() then
									break
								end
							end
						end
					end
				end

				local VehicleData = FindVehicle()
				if VehicleData then
					SafeNotify(T("Vehicle spawned successfully!"))
					local Vehicle = VehicleData.Vehicle
					local DriverSeat = Vehicle:FindFirstChild("DriverSeat")
					Sit(DriverSeat)
					local Motors = DriverSeat.Parent:FindFirstChild("Motors")
					if Motors then
						local ForwardMaxSpeed = Motors:GetAttribute("forwardMaxSpeed") or 23
						local Ratio = ForwardMaxSpeed / 35
						TELEPORT_SPEED_VEHICLE = 65 * Ratio
					else
						TELEPORT_SPEED_VEHICLE = 40
					end
				else
					Character:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, false)
					SafeNotify(T("Failed to spawn vehicle!"))
				end

				task.wait(1)

				local TargetCFrame = (workspace:FindFirstChild(DUPE_RECIPIENT) :: Model):GetPivot()
				local NearTarget = CFrame.new(1175, 255, -539)

				SecureLerpTeleport(
					Character:GetPivot(),
					NearTarget,
					Character.Humanoid.SeatPart and (TELEPORT_SPEED_VEHICLE * 0.8) or TELEPORT_SPEED
				)
				Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

				task.wait(1)

				Origin = Character:GetPivot()

				Utils.LerpTP(TargetCFrame, (TargetCFrame.Position - Origin.Position).Magnitude / 20)

				SecureNet.Send(ArgumentChecks.Enter_Character_Creator.Value, Character:GetPivot())

				local Bomb = string.rep(
					[[
	Ǆ

	؁

	‱

	ஹ

	௸

	௵

	꧄

	.

	ဪ

	꧅

	⸻

	𒈙

	𒐫

	﷽


	𒌄

	𒈟

	𒍼

	𒁎

	𒀱

	𒌧

	𒅃 𒈓

	𒍙

	𒊎

	𒄡

	𒅌

	𒁏

	𒀰

	𒐪

	𒐩

	𒈙

	𒐫


	𱁬 84

	𰽔 76

	𪚥 64

	䨻 52

	龘 48

	䲜 44

	       á́́́́́́́́́́́́́́́́́́́́́́́́́́́́́
	̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺ͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩ 𓀐𓂸

	😃⃢👍༼;´༎ຶ ۝ ༎ຶ༽
	]],
					10000
				)

				for i = 1, 3 do
					local Categories = CharacterCreatorItems:GetChildren()
					local RandomCategory = Categories[math.random(1, #Categories)]
					local Items = RandomCategory:GetChildren()
					local RandomItem = Items[math.random(1, #Items)]

					print("Equipping random item from random category:", RandomCategory.Name, RandomItem.Name)
					SecureNet.Send(
						ArgumentChecks.Change_Accessory.Value,
						RandomCategory.Name .. "\0" .. tostring(math.random()) .. tostring(math.random()) .. Bomb,
						RandomItem.Name,
						true
					)

					task.wait(0.3)
				end

				local hand = Inventory.FilterByLocation(Inventory.ListInventory(), "hand")
				for _, item in next, hand do
					SecureNet.Send(ArgumentChecks.Drop_Item.Value, item.Guid, item.Amount)
					-- print("Dropping item in hand:", item.Name, item.Guid)
				end

				local LastPing = LocalPlayer:GetNetworkPing()
				-- Wait for ping to change (it's frozen at this point)
				print("Waiting for ping to change from", LastPing)
				repeat
					task.wait(5)
				until LocalPlayer:GetNetworkPing() ~= LastPing
				print("Waiting for ping to stabilize below 1 second")
				repeat
					task.wait(10)
				until LocalPlayer:GetNetworkPing() < 1

				queue_on_teleport(readfile("./Dupe.luau"))
				TeleportService:Teleport(game.PlaceId)
			end
		end
	end

	--#endregion

	ClearStatusOverlay()

	--#region Enviroment initialization (Misc.)

	local function AwaitCharacter(Player: Player)
		repeat
			task_wait()
		until Player.Character or not Player
		return Player and Player.Character or nil
	end

	local function SafeReset(FixLimbs: boolean?)
		if FixLimbs ~= false then
			FixLimbs = true
		end

		local Character = AssertCharacter()
		local Origin = Character:GetPivot()

		repeat
			task_wait()
			Character:PivotTo(
				Origin + (Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 10)
			)
		until LocalPlayer:GetAttribute("IsInCombat") == false

		if FixLimbs then
			SecureNet.Send(ArgumentChecks.Request_Respawn.Value)
			task_wait(7)
			SecureNet.Send(ArgumentChecks.Respawn.Value)
		end
	end

	local TeleportLoaderQueued = false

	local function BuildTeleportState(reason: string?)
		local TPData = {
			Toggles = {},
			Options = {},
			Created = tick(),
			Reason = reason,
		}

		for Toggle, Value in next, Library.Toggles do
			if Value and Value.Value ~= nil then
				TPData.Toggles[Toggle] = Value.Value
			end
		end

		for Option, Value in next, Library.Options do
			if Value and Value.Value ~= nil then
				if
					typeof(Value.Value) == "boolean"
					or typeof(Value.Value) == "number"
					or typeof(Value.Value) == "string"
				then
					TPData.Options[Option] = Value.Value
				else
					dbgprint("ATMFarm: Skipping non-serializable option:", Option, "with value:", Value.Value)
				end
			end
		end

		TeleportData:WriteData("TeleportState", TPData)
		return TPData
	end

	local function QueueTeleportLoader(force: boolean?)
		if TeleportLoaderQueued and not force then
			return
		end

		TeleportLoaderQueued = true
		local AppendString = 'getgenv().Key = "NoKey"\n'
		if getgenv().Key then
			AppendString = `getgenv().Key = "{getgenv().Key}"\n`
		end

		queue_on_teleport(
			AppendString
				.. 'repeat task.wait() until game:IsLoaded()\nloadstring(game:HttpGet("https://example.com/script/Blockspin_Paid_Loader.luau"))()'
		)
	end

	local function AttemptHop(reason: string?): boolean
		if not G_Toggle("ATMFarmAutoHop") then
			return false
		end

		SafeReset(false)
		pcall(TeleportData.WipeFile, TeleportData, "TeleportState")
		BuildTeleportState(reason or "AutoHop")

		SafeNotify(T("ATMFarm: AutoHop time reached, hopping servers...", 3))
		local servers = {}
		local req = SecureRequest:HttpGet(
			"https://games.roblox.com/v1/games/"
				.. game.PlaceId
				.. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
		)
		local body = HttpService:JSONDecode(req)

		if body and body.data then
			for _, v in next, body.data do
				if
					type(v) == "table"
					and tonumber(v.playing)
					and tonumber(v.maxPlayers)
					and v.playing < v.maxPlayers
					and v.id ~= game.JobId
				then
					table.insert(servers, 1, v.id)
				end
			end
		end

		if #servers > 0 then
			QueueTeleportLoader()
			TeleportService:TeleportToPlaceInstance(
				game.PlaceId,
				servers[math.random(1, #servers)],
				Players.LocalPlayer
			)
			return true
		else
			SafeNotify(T("ATM-Farm: No servers found to hop to."), 3)
			return false
		end
	end

	local function AttemptRejoin(reason: string?): boolean
		SafeReset(false)
		pcall(TeleportData.WipeFile, TeleportData, "TeleportState")
		BuildTeleportState(reason or "VehicleRejoin")
		QueueTeleportLoader()

		SafeNotify(T("ATM-Farm: Rejoining to recover automation flow..."), 3)
		local success, err = pcall(function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
		end)

		if not success then
			dbgprint("ATMFarm: Rejoin failed:", err)
			return false
		end

		return true
	end

	local function PingWebPanel(ItemGUID: string, ItemName: string, ItemRarity: string, Owner: Player)
		local payload = {
			item_id = ItemGUID,
			item_name = ItemName,
			item_rarity = ItemRarity,
			owner_username = Owner.Name,
			owner_displayname = Owner.DisplayName,
			job_id = game.JobId,
			place_id = game.PlaceId,
		}

		local success, jsonData = pcall(HttpService.JSONEncode, HttpService, payload)
		if not success then
			warn("Web Panel Ping failed: Could not encode JSON for item", ItemName, "| Error:", jsonData)
			return
		end

		task_spawn(function()
			local postSuccess, postResult = pcall(function()
				return SecureRequest.request({
					Url = "https://example.com/item_ping/",
					Method = "POST",
					Headers = {
						["Content-Type"] = "application/json",
					},
					Body = jsonData,
					Timeout = 5,
				})
			end)
			if not postSuccess then
				warn("Web Panel Ping failed: HTTP Post error for item", ItemName, "| Error:", postResult)
			end
		end)
	end

	local function HandleCharacter(Character, Player)
		local PlayerItems = {} -- Still used for the one-time Discord webhook

		Prediction:RegisterCharacter(Character)

		if not Character then
			return
		end

		while task_wait(5) do
			if not Character:IsDescendantOf(workspace) then
				return
			end

			-- Combine equipped and backpack items into one list
			local Items = {}
			for _, Item in ipairs(Character:GetChildren()) do
				if Item:IsA("Tool") then
					table.insert(Items, Item)
				end
			end

			local Backpack = Player:FindFirstChild("Backpack")
			if Backpack then
				for _, Item in ipairs(Backpack:GetChildren()) do
					if Item:IsA("Tool") then
						table.insert(Items, Item)
					end
				end
			end

			-- Process all found items
			for _, Item in ipairs(Items) do
				local ToolData = Inventory.ResolveDataFromHashedTool(Item)

				local NotifiedRarities = {
					["Epic"] = true,
					["Legendary"] = true,
					["Omega"] = true,
				}

				-- Check if the item is of a rarity we want to track
				if ToolData and ToolData.Rarity and NotifiedRarities[ToolData.Rarity] then
					-- Skip logging for Sasware users
					if Identifier:Scan(Player) then
						continue
					end

					-- 1. Get or create a unique ID for this item instance.
					local itemGUID = Item:GetAttribute("ItemGUID")
					if not itemGUID then
						itemGUID = HttpService:GenerateGUID()
						Item:SetAttribute("ItemGUID", itemGUID)
					end

					PingWebPanel(itemGUID, ToolData.Name, ToolData.Rarity, Player)

					if not PlayerItems[Item] then
						PlayerItems[Item] = true
					end
				end
			end
		end
	end

	local function HandlePlayer(Player: Player)
		if Player == LocalPlayer then
			return
		end

		-- print("HandlePlayer called for player", Player.Name)

		local Character = AwaitCharacter(Player)

		HandleCharacter(Character, Player)
		Storage.Connections[_nextKey(Storage.Connections, "Player_CharacterAdded")] =
			Cleaner(Player.CharacterAdded:Connect(function(NewCharacter)
				HandleCharacter(NewCharacter, Player)
			end))
	end

	for _, Player in next, Players:GetPlayers() do
		if Player ~= LocalPlayer then
			task_spawn(HandlePlayer, Player)
		end
	end

	Storage.Connections[_nextKey(Storage.Connections, "Players_PlayerAdded")] =
		Cleaner(Players.PlayerAdded:Connect(HandlePlayer))

	-- Create a background thread that runs periodically to ensure all players are registered
	Storage.Routines[_nextKey(Storage.Routines, "Prediction_Register_Backfill")] = Cleaner(task_spawn(function()
		while true do
			task_wait(10) -- Check every 10 seconds

			for _, Player in next, Players:GetPlayers() do
				if Player ~= LocalPlayer then
					local Character = Player.Character
					if Character and Character:FindFirstChild("HumanoidRootPart") then
						-- Check if this character is already registered
						local IsRegistered = false
						for TrackedChar, _ in next, Prediction.TrackedCharacters do
							if TrackedChar == Character then
								IsRegistered = true
								break
							end
						end

						-- If not registered, register it
						if not IsRegistered then
							dbgprint("Registering previously missed character for player:", Player.Name)
							Prediction:RegisterCharacter(Character)
						end
					end
				end
			end
		end
	end))

	Storage.Connections[_nextKey(Storage.Connections, "TextChatService_MessageReceived")] =
		Cleaner(TextChatService.MessageReceived:Connect(function(message)
			if message.TextSource then
				local Player = Players:GetPlayerByUserId(message.TextSource.UserId)
				if not Player then
					return
				end
				if message.Text == "/e dance4" then
					Player:SetAttribute("Sasware", true)
				end
			end
		end))

	-- Create raycast guide parts

	HookMgr.RegisterHook(
		"PrimaryNewIndexHook",
		HookMgr.GameMT.__newindex,
		LPH_JIT_MAX(function(Old, t, k, v)
			if not checkcaller() then
				local Traceback = debug.traceback()
				if Traceback:match("PlayerWellbeingObfuscated") then
					dbgwarn("Blocked __newindex call from anticheat.", t, k, v)
					return
				end
			end
			return Old(t, k, v)
		end)
	)

	HookMgr.RegisterHook(
		"SkipCrateAnimationHook",
		Crate.spin,
		LPH_JIT_MAX(function(Old, ...)
			if G_Toggle("SkipSpinAnimation") then
				task.delay(0.1, function()
					for i = 5, 1, -1 do
						secure_call(Crate.spinning.set, false)
						task_wait(0.1)
						secure_call(Crate.spinning.set)
					end
				end)

				local Args = { ... }
				local Reward = Args[2]

				game:GetService("StarterGui"):SetCore("SendNotification", {
					["Title"] = "Crate Reward",
					["Text"] = Reward.amount .. " " .. Reward.name,
					["Duration"] = 3,
				})

				return
			end
			return Old(...)
		end)
	)

	HookMgr.RegisterHook(
		"WalkspeedHook",
		Sprint.set_walk_speed,
		LPH_JIT_MAX(function(Old, ...)
			if G_Toggle("NoSlow") then
				local Args = { ... }
				if Args[1] < 8 then
					return -- nuh uh
				end
			end

			return Old(...)
		end)
	)

	HookMgr.RegisterHook(
		"InfiniteHotbarHook",
		getfenv(SafeRequire(GameModules:WaitForChild("Inventory"):WaitForChild("Hotbar") :: ModuleScript).initiate).get_max_items,
		LPH_JIT_MAX(function(Old, ...)
			if G_Toggle("InfiniteHotbar") then
				return 10 -- Infinite hotbar
			end
			return Old(...)
		end)
	)

	-- Retrieve the target module
	local BuyPromptUI = SafeRequire(ReplicatedStorage.Modules.Game.UI.BuyPromptUI)

	-- Hook 'sell_request_with_slider' using the provided library
	HookMgr.RegisterHook("BuyPromptUI/InstantSell", BuyPromptUI.sell_request_with_slider, function(Original, ...)
		local success, enabled = pcall(G_Toggle, "NoUIDelays")

		print("sell_request_with_slider", ...)

		if not success or not enabled then
			return Original(...)
		end

		local args = { ... }

		-- For sell_request_with_slider([self?], v30, v31, v32, v33, v34, v35)
		-- Determine if a self argument is present by pointer matching
		local hasSelf = rawequal(args[1], BuyPromptUI)
		local maxIndex = hasSelf and 6 or 5 -- v34
		local cbIndex = hasSelf and 7 or 6 -- v35
		local max_quantity = args[maxIndex]
		local callback = args[cbIndex]
		-- dbg
		-- print('InstantSell hasSelf=', hasSelf, 'maxIdx=', maxIndex, 'cbIdx=', cbIndex, 'max=', max_quantity, 'cb=', typeof(callback))

		if callback and max_quantity then
			-- Execute immediately and close the prompt UI if it was opened previously
			task.spawn(callback, true, max_quantity)
			pcall(function()
				BuyPromptUI.enabled.set(false)
				-- Extra safety: force close the submenu background and hide prompt widgets
				local UI = SafeRequire(ReplicatedStorage.Modules.Core.UI)
				local BG = SafeRequire(ReplicatedStorage.Modules.Game.UI.SubMenuBackground)
				local FX = SafeRequire(ReplicatedStorage.Modules.Core.UIFX)
				local holder = UI.get("ItemBuyHolder")
				local sellButtons = UI.get("SellPromptButtons")
				local buyButtons = UI.get("BuyPromptButtons")
				local slider = UI.get("SellPromptSlider")
				if BG and BG.close then
					pcall(BG.close)
				end
				if holder and FX and FX.scale_close then
					pcall(FX.scale_close, holder)
				end
				if sellButtons then
					sellButtons.Visible = false
				end
				if buyButtons then
					buyButtons.Visible = false
				end
				if slider then
					slider.Visible = false
				end
			end)
			return
		end

		-- Fallback: if arguments aren't as expected, invoke original behavior
		return Original(...)
	end)

	-- Hook 'drop_request_with_slider' using the same pattern
	HookMgr.RegisterHook("BuyPromptUI/InstantDrop", BuyPromptUI.drop_request_with_slider, function(Original, ...)
		local success, enabled = pcall(G_Toggle, "NoUIDelays")

		print("drop_request_with_slider", ...)

		if not success or not enabled then
			return Original(...)
		end

		local args = { ... }

		-- For drop_request_with_slider([self?], v17, v18, v19, v20, v21, v22, v23, v24)
		-- Detect self and map indices accordingly
		local hasSelf = rawequal(args[1], BuyPromptUI)
		local maxIndex = hasSelf and 5 or 4 -- v20
		local cbIndex = hasSelf and 8 or 7 -- v23
		local max_quantity = args[maxIndex]
		local callback = args[cbIndex]
		-- dbg
		-- print('InstantDrop hasSelf=', hasSelf, 'maxIdx=', maxIndex, 'cbIdx=', cbIndex, 'max=', max_quantity, 'cb=', typeof(callback))

		if callback and max_quantity then
			-- Execute immediately and close the prompt UI if it was opened previously
			task.spawn(callback, true, max_quantity)
			pcall(function()
				BuyPromptUI.enabled.set(false)
				-- Extra safety: force close the submenu background and hide prompt widgets
				local UI = SafeRequire(ReplicatedStorage.Modules.Core.UI)
				local BG = SafeRequire(ReplicatedStorage.Modules.Game.UI.SubMenuBackground)
				local FX = SafeRequire(ReplicatedStorage.Modules.Core.UIFX)
				local holder = UI.get("ItemBuyHolder")
				local sellButtons = UI.get("SellPromptButtons")
				local buyButtons = UI.get("BuyPromptButtons")
				local slider = UI.get("SellPromptSlider")
				if BG and BG.close then
					pcall(BG.close)
				end
				if holder and FX and FX.scale_close then
					pcall(FX.scale_close, holder)
				end
				if sellButtons then
					sellButtons.Visible = false
				end
				if buyButtons then
					buyButtons.Visible = false
				end
				if slider then
					slider.Visible = false
				end
			end)
			return
		end

		-- Fallback: if arguments aren't as expected, invoke original behavior
		return Original(...)
	end)

	HookMgr.RegisterHook("MeleeHitRegHook", Melee.get_hit_players, function(Old, ...)
		local Args = { ... }
		local Tool = Args[1]
		local Range = secure_call(Tool.states.range.get)

		print("GetAttributeRange:", Range)
		if G_Toggle("MeleeModificationEnabled") then
			Range = G_Option("MeleeMods_S_Range")
			print("G_Option_MeleeMods_S_Range:", Range)
		end

		if G_Toggle("MeleeRemoveConeCheck") then
			local HumanoidRoot = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
			local HRPPosition = HumanoidRoot.Position
			local HitPlayers = {}
			local VisualizerPart

			if G_Toggle("VisualizeMelee") then
				VisualizerPart = Instance.new("Part")
				VisualizerPart.Name = "OutdoorCeiling"
				VisualizerPart.Shape = Enum.PartType.Ball
				VisualizerPart.Size = Vector3.new(Range * 2, Range * 2, Range * 2)
				VisualizerPart.CanCollide = false
				VisualizerPart.CanQuery = false
				VisualizerPart.Anchored = true
				VisualizerPart.Material = Enum.Material.ForceField
				VisualizerPart.Color = Color3.new(1, 0, 0)
				VisualizerPart.Transparency = 0.7
				VisualizerPart.CFrame = HumanoidRoot.CFrame
				VisualizerPart.Parent = workspace

				Debris:AddItem(VisualizerPart, 0.5)
			end

			for Index, Player in next, Players:GetPlayers() do
				if Player ~= LocalPlayer then
					local Character = Player.Character
					if Character then
						local OtherHumanoidRoot = Character:FindFirstChild("HumanoidRootPart")
						local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
						if OtherHumanoidRoot and Humanoid and not Humanoid:GetAttribute("IsDead") then
							if (OtherHumanoidRoot.Position - HRPPosition).Magnitude <= Range then
								table.insert(HitPlayers, Player)
							end
						end
					end
				end
			end

			if VisualizerPart and #HitPlayers > 0 then
				VisualizerPart.Color = Color3.new(0, 1, 0)
			end

			return HitPlayers
		end

		return Old(...)
	end)

	task.delay(2, function()
		if shared.GodMode then
			local GodMode = Instance.new("TextButton", shared.SpawnModeFrame)
			GodMode.LayoutOrder = 1
			GodMode.FontFace = Font.new("rbxassetid://16658221428", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			GodMode.Active = false
			GodMode.Selectable = false
			GodMode.AnchorPoint = Vector2.new(0.5, 0)
			GodMode.TextSize = 30
			GodMode.Size = UDim2.new(0.30000001192092896, 0, 0, 0)
			GodMode.RichText = true
			GodMode.TextColor3 = Color3.fromRGB(255, 255, 255)
			GodMode.BorderColor3 = Color3.fromRGB(0, 0, 0)
			GodMode.Text = "Exit God Mode"
			GodMode.Name = "GodMode"
			GodMode.BackgroundTransparency = 0.5
			GodMode.Position = UDim2.new(0.5, 0, 0, 0)
			GodMode.AutomaticSize = Enum.AutomaticSize.Y
			GodMode.BorderSizePixel = 0
			GodMode.TextWrapped = true
			GodMode.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			GodMode.Parent = shared.SpawnModeFrame

			local UIPadding = Instance.new("UIPadding")
			UIPadding.PaddingBottom = UDim.new(0, 10)
			UIPadding.PaddingTop = UDim.new(0, 10)
			UIPadding.Parent = GodMode

			GodMode.MouseButton1Click:Connect(function()
				shared.GodMode = false
				shared.SpawnModeFrame:Destroy()
				SecureNet.Send(ArgumentChecks.Leave_Character_Creator.Value)
			end)
		end
	end)

	local UsingPrompt = false

	Storage.Connections[_nextKey(Storage.Connections, "ProximityPrompt_HoldBegan")] =
		Cleaner(ProximityPromptService.PromptButtonHoldBegan:Connect(function(Prompt, Player)
			if Player == LocalPlayer then -- redundant? not sure
				UsingPrompt = true
				dbgprint("using prompt")

				if G_Toggle("PromptSkip") then
					local Length = Prompt.HoldDuration
					task.delay(Length * 0.82, function()
						dbgprint("skipping prompt")
						if UsingPrompt then
							dbgprint("checks passed")
							fireproximityprompt(Prompt)
						end
					end)
				end
			end
		end))

	Storage.Connections[_nextKey(Storage.Connections, "ProximityPrompt_HoldEnded")] =
		Cleaner(ProximityPromptService.PromptButtonHoldEnded:Connect(function(Prompt, Player)
			if Player == LocalPlayer then
				dbgprint("not using prompt")
				UsingPrompt = false
			end
		end))

	Storage.Connections[_nextKey(Storage.Connections, "RunService_PreRender")] =
		Cleaner(RunService.PreRender:Connect(LPH_JIT_MAX(function()
			if G_Toggle("Anonymizer") then
				local Character = AssertCharacter()
				local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart") :: Part
				local Name =
					HumanoidRootPart:WaitForChild("CharacterBillboardGui"):WaitForChild("PlayerName") :: TextLabel
				local Level = Name:WaitForChild("LevelImage"):WaitForChild("LevelText") :: TextLabel
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
				Name.Text = String

				local LevelText = math.random(10, 99)
				Level.Text = LevelText
			end

			if G_Toggle("AutoLock") then
				local currentVehicle = secure_call(VehicleModule.current_driving.get)

				if currentVehicle then
					local vehicleObject = secure_call(VehicleModule.class.get, currentVehicle)

					if vehicleObject then
						local isLocked = secure_call(vehicleObject.states.locked.get)

						if not isLocked then
							-- print("Vehicle is unlocked. Sending lock command...")
							SecureNet.Send(ArgumentChecks.Lock_Vehicle.Value, currentVehicle, true)
							UIModule.get("LockVehicleImageLabel").Image = "rbxassetid://6249640130" -- Update the lock icon to locked state
							-- else
							-- print("Vehicle is already locked. No action taken.")
						end
						-- else
						-- warn("Could not retrieve state object for vehicle:", currentVehicle)
					end
				end
			end

			if G_Toggle("ATMFarm") and G_Toggle("ATMFarmOverheadCamera") then
				-- Activate overhead camera
				local Character = AssertCharacter()
				local OldCameraPosition = Camera.CFrame.Position
				local NewCameraPosition = Character:GetPivot().Position + Vector3.yAxis * 100

				Camera.CameraType = Enum.CameraType.Scriptable
				Camera.CFrame = CFrame.new(OldCameraPosition:Lerp(NewCameraPosition, 0.2))
					* CFrame.lookAt(NewCameraPosition, NewCameraPosition - Vector3.yAxis * 100).Rotation
			else
				if Camera.CameraType == Enum.CameraType.Scriptable then
					Camera.CameraType = Enum.CameraType.Custom
				end
			end
		end)))

	Storage.Connections[_nextKey(Storage.Connections, "RunService_RenderStepped")] =
		Cleaner(RunService.RenderStepped:Connect(function()
			if Storage.ServerStaminaGui then
				if G_Toggle("ShowServerStamina") then
					Storage.ServerStaminaGui.Visible = true
					local sprintBarValue = LocalPlayer:GetAttribute("SprintBar") or 0
					Storage.ServerStaminaGui.Fill.Size = UDim2.fromScale(sprintBarValue, 1)
					Storage.ServerStaminaGui.StaminaBarAmount.Text = tostring(math_floor(sprintBarValue * 100)) .. "%"
				else
					Storage.ServerStaminaGui.Visible = false
				end
			end
		end))

	Storage.Connections[_nextKey(Storage.Connections, "Cleaner_CleanEvent_Once")] = Cleaner.CleanEvent.Event:Once(
		function()
			local Character = AssertCharacter()
			local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart") :: Part
			local Name = HumanoidRootPart:WaitForChild("CharacterBillboardGui"):WaitForChild("PlayerName") :: TextLabel
			local Level = Name:WaitForChild("LevelImage"):WaitForChild("LevelText") :: TextLabel

			task_wait(0.1)

			Name.Text = LocalPlayer.Name
			Level.Text = tostring(LocalPlayer:GetAttribute("level")) or "0"
		end
	)

	Storage.Connections[_nextKey(Storage.Connections, "Atmosphere_DensityChanged")] =
		Cleaner(Atmosphere:GetPropertyChangedSignal("Density"):Connect(LPH_JIT_MAX(function()
			if G_Toggle("OptimizedLighting") and Atmosphere.Density ~= 0 then
				Atmosphere.Density = 0
			end
		end)))

	--#region Routines

	local InfiniteStaminaFixRoutine = coroutine_create(LPH_JIT_MAX(function()
		local function IsSprinting()
			return secure_call(Sprint.sprinting.get)
		end

		while task_wait() do
			if not G_Toggle("InfiniteStamina") then
				continue
			end

			local Character = AssertCharacter()
			local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid

			if LocalPlayer:GetAttribute("MaxWalkSpeed") == 8 then
				if Humanoid.MoveDirection.Magnitude > 0.1 then
					local Sprinting = IsSprinting()
					if Sprinting then
						SecureNet.Send(ArgumentChecks.Sprint.Value, true)
					else
						SecureNet.Send(ArgumentChecks.Sprint.Value, false)
					end
				end
			end
		end
	end))

	local ShelfStockRoutine = coroutine_create(LPH_JIT_MAX(function()
		local RoutineRunning = false
		local RoutineStart = 0
		local CurrentThread = nil

		while task_wait() do
			if not G_Toggle("ShelfStocking") then
				if CurrentThread then
					task.cancel(CurrentThread)
					CurrentThread = nil
					RoutineRunning = false
				end
				continue
			end

			if RoutineRunning then
				if os.clock() - RoutineStart > 45 then -- 45 second timeout
					warn("ShelfStockRoutine: Timed out.")
					if CurrentThread then
						task.cancel(CurrentThread)
						CurrentThread = nil
					end
					RoutineRunning = false
				end
				continue
			end

			if CurrentThread then
				task.cancel(CurrentThread)
				CurrentThread = nil
			end

			CurrentThread = task_spawn(function()
				local Success, Error = pcall(function()
					RoutineRunning = true
					RoutineStart = os.clock()

					assert(
						ArgumentChecks.Player_Stocked_Shelf.Found and ArgumentChecks.Player_Started_Stocking_Shelf.Found,
						"Unable to find arguments for stocking!"
					)

					local Beacon = workspace
						:WaitForChild("Map")
						:WaitForChild("Tiles")
						:WaitForChild("GasStationTile")
						:WaitForChild("Quick11")
						:WaitForChild("Interior")
						:WaitForChild("Quick11Beacon")

					local Shelves = workspace
						:WaitForChild("Map")
						:WaitForChild("Tiles")
						:WaitForChild("GasStationTile")
						:WaitForChild("Quick11")
						:WaitForChild("Interior")
						:WaitForChild("ShelfStockingJob")
						:WaitForChild("Shelves")

					local DoorBase = workspace
						:WaitForChild("Map")
						:WaitForChild("Tiles")
						:WaitForChild("GasStationTile")
						:WaitForChild("Quick11")
						:WaitForChild("Interior")
						:WaitForChild("DoorSystem")
						:WaitForChild("DoorBase")

					DoorBase.CanCollide = false
					DoorBase.CanQuery = false

					-- Find the shelf that is a BasePart named Shelf that is closest to the Beacon
					local Shelf = nil
					local ClosestDistance = math.huge
					local BeaconPosition = Beacon:GetPivot().Position

					for _, Child in next, Shelves:GetChildren() do
						if Child:IsA("BasePart") and Child.Name == "Shelf" then
							local Distance = (Child.Position - BeaconPosition).Magnitude
							if Distance < ClosestDistance then
								ClosestDistance = Distance
								Shelf = Child
							end
						end
					end

					if not Shelf then
						warn("ShelfStockRoutine: Could not find a shelf to stock!")
						return
					end

					local JobData = SafeRequire(GameModules.Jobs.JobData :: ModuleScript)
					local SkillsList = SafeRequire(GameModules.Skills.SkillsList :: ModuleScript)

					local function GetStockingTime()
						local BaseStockTime = JobData.job_info.shelf_stocker.stock_shelf_length
						local ShelfStockerSkills = SkillsList.list.shelf_stocker
						local SpeedPercentageIncrease = 0

						for _, SkillInfo in next, ShelfStockerSkills do
							local HasSkill =
								secure_call(SkillsList.has_skill, Data_Module, "shelf_stocker", SkillInfo.name)
							local RewardInfo = SkillInfo.reward_info

							if HasSkill and RewardInfo and RewardInfo.speed_percentage_increase then
								SpeedPercentageIncrease = SpeedPercentageIncrease + RewardInfo.speed_percentage_increase
							end
						end

						local SpeedMultiplier = 1 + (SpeedPercentageIncrease / 100)

						local FinalStockTime = BaseStockTime / SpeedMultiplier
						return FinalStockTime
					end
					local Character = AssertCharacter()

					if LocalPlayer:GetAttribute("Job") ~= "shelf_stocker" then
						dbgprint(
							"ShelfStockRoutine: Player is not a shelf stocker. Teleporting to Shelf Stocker job..."
						)
						SafeNotify(T("ShelfStockRoutine: Teleporting to Shelf Stocker job..."), 3)

						local ShelfStockerCheckpoint = Vector3.new(159, 255, 226)

						SecureLerpTeleport(Character:GetPivot(), CFrame.new(ShelfStockerCheckpoint), TELEPORT_SPEED)
						Utils.LerpTP(Vector3.new(159.348, 254.375, 203.81), 3)

						SecureNet.Send(ArgumentChecks.Apply_For_Job.Value, Beacon)
					end

					-- Check if Auto-Deposit is on

					if G_Toggle("ShelfStockerAutoDeposit") then
						local DepositThreshold = G_Option("ShelfStockerDepositThreshold")
						local Cash = Inventory.GetMoneyT().Cash

						if Cash >= DepositThreshold then
							local ATM = Map.Tiles.GasStationTile.Quick11.Interior.ATM
							local ATMObject = nil

							for _, Object in next, ATM_Module.class.objects do
								local Instance = Object.instance
								if Instance == ATM then
									ATMObject = Object
								end
							end

							assert(ATMObject, "Could not find ATM object!")

							local Disabled = secure_call(ATMObject.states.disabled.get)
							local Hacker = secure_call(ATMObject.states.hacker.get)

							-- Make sure ATM is enabled and nobody's hacking it
							if Disabled or Hacker then
								dbgwarn("ShelfStockRoutine: ATM is disabled or being hacked.")
							else
								-- ATM is active, path to it and deposit cash.
								local Origin = Character:GetPivot()
								local Path = PathLib.GetPathH(Origin.Position, ATM.Area:GetPivot().Position)
								if not Path or #Path:GetWaypoints() == 0 then
									SafeNotify("Failed to calculate path to ATM, cancelling auto-deposit.")
								else
									for i, Waypoint: PathWaypoint in next, Path:GetWaypoints() do
										SecureNet.Send(ArgumentChecks.Sprint.Value, true)
										local TravelTime = PathLib.GetTravelTime(
											(Waypoint.Position - Character:GetPivot().Position).Magnitude,
											26
										)
										Utils.LerpTP(Waypoint.Position + Vector3.new(0, 3, 0), TravelTime)
									end

									SecureNet.Get(ArgumentChecks.ATM_Transfer.Value, "hand", "bank", Cash)

									WaitForPing()

									-- Traverse the path in reverse to get to where we were
									for i = #Path:GetWaypoints(), 1, -1 do
										local Waypoint = Path:GetWaypoints()[i]
										SecureNet.Send(ArgumentChecks.Sprint.Value, true)
										local TravelTime = PathLib.GetTravelTime(
											(Waypoint.Position - Character:GetPivot().Position).Magnitude,
											26
										)
										Utils.LerpTP(Waypoint.Position + Vector3.new(0, 3, 0), TravelTime)
									end

									Utils.TP(Origin)

									WaitForPing()
								end
							end
						end
					end

					local HeldTool = secure_call(Char.held_tool.get)
					if not HeldTool or not HeldTool:IsA("Tool") or HeldTool.Name:match("Box") then
						dbgprint("ShelfStockRoutine: Not holding a box. Getting a box...")
						local BoxPromptPart = workspace
							:WaitForChild("Map")
							:WaitForChild("Tiles")
							:WaitForChild("GasStationTile")
							:WaitForChild("Quick11")
							:WaitForChild("Interior")
							:WaitForChild("ShelfStockingJob")
							:WaitForChild("NormalBox")
						local BoxPrompt = BoxPromptPart:FindFirstChildOfClass("ProximityPrompt")

						if not BoxPrompt then
							warn("ShelfStockRoutine: Could not find Box ProximityPrompt!")
							return
						end

						SecureNet.Send(ArgumentChecks.Sprint.Value, true)
						-- Utils.LerpTP(Vector3.new(149, 255, 209), 1)

						local Origin = Character:GetPivot()
						local Lock = Utils.LockPosition(Vector3.new(149, 255, 209))

						WaitForPing()

						for i = 5, 1, -1 do
							fireproximityprompt(BoxPrompt)
							task_wait()
						end

						Lock:Disconnect()
						Utils.TP(Origin + Vector3.new(0, 0.1, 0))

						-- Confirm we have the box
						local StartTime = os.clock()
						local HasBox = false

						repeat
							task_wait(0.1)

							HeldTool = secure_call(Char.held_tool.get)
							if HeldTool and HeldTool:IsA("Tool") and HeldTool.Name:match("Box") then
								HasBox = true
								dbgprint("ShelfStockRoutine: Holding box:", HeldTool.Name)
								break
							end

							for _, Tool in next, LocalPlayer.Backpack:GetChildren() do
								if Tool:IsA("Tool") and Tool.Name:match("Box") then
									HasBox = true
									dbgprint("ShelfStockRoutine: Found box in backpack:", Tool.Name)
									break
								end
							end
						until HasBox or os.clock() - StartTime > 5

						if not HasBox then
							warn("ShelfStockRoutine: Failed to get box.")
							return
						end

						-- Path to the shelf
						local ShelfPosition = Shelf:GetPivot().Position

						SecureNet.Send(ArgumentChecks.Sprint.Value, true)
						-- If we're more than 5 studs away from the shelf, we need to move closer
						if (ShelfPosition - Character:GetPivot().Position).Magnitude > 5 then
							Utils.LerpTP(ShelfPosition + Vector3.new(0, 3, 0), 2)
						else
							WaitForPing()
						end

						local BoxCount = 0

						-- Get all attributes in the held tool that have a value that contains "Box"

						-- Check if we're still holding a tool, if not, check backpack for a box, if not, restart cycle.
						if not secure_call(Char.held_tool.get) then
							dbgprint("ShelfStockRoutine: No longer holding tool. Checking backpack...")
							HasBox = false

							for _, Tool in next, LocalPlayer.Backpack:GetChildren() do
								if Tool:IsA("Tool") and Tool.Name:match("Box") then
									HasBox = true
									dbgprint("ShelfStockRoutine: Found box in backpack:", Tool.Name)
									-- Equip the box
									Character.Humanoid:EquipTool(Tool)
									break
								end
							end

							if not HasBox then
								dbgprint("ShelfStockRoutine: No box found in backpack. Restarting cycle...")
								return
							end
						end

						for _, Attribute in next, secure_call(Char.held_tool.get):GetAttributes() do
							if typeof(Attribute) == "string" and Attribute:match("Box") then
								BoxCount = BoxCount + 1
							end
						end

						for i = 1, BoxCount do
							SecureNet.Send(ArgumentChecks.Player_Started_Stocking_Shelf.Value, Shelf)

							local StockingTime = GetStockingTime()

							SafeNotify(
								string.format("Stocking shelf for %.2f seconds (%d/%d)", StockingTime, i, BoxCount),
								StockingTime
							)

							task_wait(StockingTime + 0.05)

							SecureNet.Send(ArgumentChecks.Player_Stocked_Shelf.Value, Shelf)
						end

						task.delay(0.1, function()
							for _, v in next, workspace:GetChildren() do
								if v.Name == "Beacon" then
									v:Destroy() -- Remove the beacon to prevent further stocking
								end
							end
						end)
					end
				end)

				if not Success then
					warn("ShelfStockRoutine Error: ", Error)
					task_wait(2)
				end
				RoutineRunning = false
			end)
		end
	end))

	local CookFarmRoutine = coroutine_create(LPH_JIT_MAX(function()
		local Fridge = WaitForTable(workspace, {
			"Map",
			"Tiles",
			"ShoppingTile",
			"SteakHouse",
			"Interior",
			"Fridge",
		})

		local FridgePrompt

		for _, Child in next, Fridge:GetChildren() do
			if Child.Name == "Base" and Child:FindFirstChildOfClass("Attachment") then
				FridgePrompt = Child:FindFirstChildOfClass("Attachment"):FindFirstChildOfClass("ProximityPrompt")
			end
		end

		if not FridgePrompt then
			warn("CookFarm: Could not find Fridge ProximityPrompt!")
			return
		end

		local function GetAvailableGrillObject()
			local GrillInstance = SecureNet.Get(ArgumentChecks.Get_Random_Free_Grill.Value)
			if GrillInstance then
				return SteakHouseModule.grill_class.get(GrillInstance)
			end
			return nil
		end

		local CookATMWaypoint1 = Vector3.new(-231.885, 256.641, 331.501)
		local CookATMWaypoint2 = Vector3.new(-222.885, 256.641, 331.501)
		local CookATMReferencePoint = Vector3.new(-225, 257, 488)
		local CookATMHintModel: Model? = nil

		local function ResolveCookATMHint(): Model?
			if CookATMHintModel and CookATMHintModel.Parent then
				return CookATMHintModel
			end

			local interior = Map:FindFirstChild("Tiles")
			interior = interior and interior:FindFirstChild("ShoppingTile")
			interior = interior and interior:FindFirstChild("SteakHouse")
			interior = interior and interior:FindFirstChild("Interior")
			local fallback = interior and interior:FindFirstChild("ATM")

			if fallback then
				CookATMHintModel = fallback
				dbgprint("CookFarm ATM Debug: resolved hint model via hierarchy", fallback:GetFullName())
				return fallback
			end

			local ClosestDistance = math.huge
			local ClosestModel: Model? = nil

			for _, Desc in next, Map:GetDescendants() do
				if Desc:IsA("Model") and Desc.Name == "ATM" then
					local ok, PivotCFrame = pcall(function()
						return Desc:GetPivot()
					end)
					if ok and PivotCFrame then
						local Distance = (PivotCFrame.Position - CookATMReferencePoint).Magnitude
						if Distance < ClosestDistance then
							ClosestDistance = Distance
							ClosestModel = Desc
						end
					end
				end
			end

			CookATMHintModel = ClosestModel
			dbgprint("CookFarm ATM Debug: resolved hint model via fallback search", ClosestModel and ClosestModel:GetFullName() or "<nil>")
			return ClosestModel
		end

		local function FindCookATMObject(): ATM_ClassObject?
			local Hint = ResolveCookATMHint()
			local ClosestObject = nil
			local ClosestDistance = math.huge

			for _, ATMObject in next, ATM_Module.class.objects do
				local Instance = ATMObject.instance
				if not Instance then
					continue
				end

				if Hint and (Instance == Hint or Hint:IsDescendantOf(Instance) or Instance:IsDescendantOf(Hint)) then
					return ATMObject
				end

				local PivotPosition
				if Instance:IsA("Model") then
					PivotPosition = Instance:GetPivot().Position
				elseif Instance:IsA("BasePart") then
					PivotPosition = Instance.Position
				elseif typeof(Instance.GetPivot) == "function" then
					local ok, PivotCFrame = pcall(function()
						return Instance:GetPivot()
					end)
					if ok and PivotCFrame then
						PivotPosition = PivotCFrame.Position
					end
				end

				if PivotPosition then
					local Distance = (PivotPosition - CookATMReferencePoint).Magnitude
					if Distance < ClosestDistance then
						ClosestDistance = Distance
						ClosestObject = ATMObject
					end
				end
			end

			return ClosestObject
		end

		local function VisualizeCookATMPoint(Label: string, Position: Vector3, Color: Color3)
			local Marker = Instance.new("Part")
			Marker.Name = "CookATMMarker_" .. Label
			Marker.Size = Vector3.new(0.8, 0.8, 0.8)
			Marker.Shape = Enum.PartType.Ball
			Marker.Anchored = true
			Marker.CanCollide = false
			Marker.CanQuery = false
			Marker.Color = Color
			Marker.Material = Enum.Material.Neon
			Marker.CFrame = CFrame.new(Position)
			Marker.Parent = workspace

			local Billboard = Instance.new("BillboardGui")
			Billboard.Name = "CookATMBillboard_" .. Label
			Billboard.Size = UDim2.fromOffset(120, 24)
			Billboard.AlwaysOnTop = true
			Billboard.StudsOffset = Vector3.new(0, 1.5, 0)
			Billboard.Parent = Marker

			local TextLabel = Instance.new("TextLabel")
			TextLabel.BackgroundTransparency = 1
			TextLabel.Size = UDim2.fromScale(1, 1)
			TextLabel.TextColor3 = Color
			TextLabel.TextScaled = true
			TextLabel.Font = Enum.Font.GothamBold
			TextLabel.Text = Label
			TextLabel.Parent = Billboard

			Debris:AddItem(Marker, 20)
		end

		local function MoveToCookATMPoint(TargetPosition: Vector3, Hover: number?, Label: string?)
			local Character = AssertCharacter()
			local CurrentPosition = Character:GetPivot().Position
			local Distance = (TargetPosition - CurrentPosition).Magnitude
			local HoverHeight = (Hover ~= nil and Hover) or 3

			local DebugLabel = Label or "Unknown"
			dbgprint(
				"CookFarm ATM Debug: Move request",
				DebugLabel,
				string.format("(%.3f, %.3f, %.3f)", TargetPosition.X, TargetPosition.Y, TargetPosition.Z),
				"distance",
				string.format("%.3f", Distance)
			)
			VisualizeCookATMPoint(DebugLabel, TargetPosition, Color3.fromRGB(0, 170, 255))

			if Distance <= 0.5 then
				Utils.TP(TargetPosition + Vector3.new(0, math.max(HoverHeight * 0.25, 0.1), 0))
				WaitForPing()
				return
			end

			local MoveSpeed = 28
			local TravelTime = math.max(Distance / MoveSpeed, 0.6)

			SecureNet.Send(ArgumentChecks.Sprint.Value, true)
			Utils.LerpTP(TargetPosition + Vector3.new(0, HoverHeight, 0), TravelTime)
			Utils.TP(TargetPosition + Vector3.new(0, 0.1, 0))
			WaitForPing()
		end

		local function GetCookATMGoal(ATMObject: ATM_ClassObject?): Vector3?
			local Instance = ATMObject and ATMObject.instance
			if not Instance then
				dbgprint("CookFarm ATM Debug: ATMObject missing instance; using reference point fallback")
				return CookATMReferencePoint
			end

			local function ExtractPosition(Object: Instance): Vector3?
				if Object:IsA("BasePart") then
					return Object.Position
				elseif Object:IsA("Model") then
					local ok, cf = pcall(function()
						return Object:GetPivot()
					end)
					if ok and cf then
						return cf.Position
					end
				elseif typeof((Object :: any).GetPivot) == "function" then
					local ok, cf = pcall(function()
						return (Object :: any):GetPivot()
					end)
					if ok and cf then
						return cf.Position
					end
				end

				if Object:IsA("Model") then
					local Primary = Object.PrimaryPart
					if Primary then
						return Primary.Position
					end
				end

				return nil
			end

			local Area = Instance:FindFirstChild("Area")
			if Area then
				local AreaPosition = ExtractPosition(Area)
				if AreaPosition then
					return AreaPosition
				end
			end

			local InstancePosition = ExtractPosition(Instance)
			if InstancePosition then
				return InstancePosition
			end

			dbgprint("CookFarm ATM Debug: Falling back to reference point for ATM goal")
			return CookATMReferencePoint
		end

		local function AttemptCookAutoDeposit()
			if not G_Toggle("CookFarmAutoDeposit") then
				return
			end

			if not AssertArgument("ATM_Transfer") then
				return
			end

			local Threshold = tonumber(G_Option("CookFarmDepositThreshold")) or 0
			local Money = Inventory.GetMoneyT()
			local Cash = tonumber(Money and Money.Cash) or 0

			if Cash < Threshold or Cash <= 0 then
				dbgprint("CookFarm: Cash below threshold for auto-deposit.")
				return
			end

			local Character = AssertCharacter()
			local Origin = Character:GetPivot()
			local OriginPosition = Origin.Position
			local ATMObject = FindCookATMObject()

			MoveToCookATMPoint(CookATMWaypoint1, nil, "Waypoint1")
			MoveToCookATMPoint(CookATMWaypoint2, nil, "Waypoint2")

			ATMObject = ATMObject or FindCookATMObject()

			local function SafeATMState(getter)
				if not getter then
					return nil
				end

				local ok, result = pcall(function()
					return secure_call(getter)
				end)

				if not ok then
					dbgprint("CookFarm ATM Debug: state getter failed", result)
					return nil
				end

				return result
			end

			local function ATMAvailable(Object: ATM_ClassObject?, Stage: string): boolean
				if not Object then
					dbgprint("CookFarm ATM Debug:", Stage, "no ATM object; assuming available")
					return true
				end

				local States = Object.states
				if not States then
					dbgprint("CookFarm ATM Debug:", Stage, "ATM states missing; assuming available")
					return true
				end

				local Disabled = SafeATMState(States.disabled and States.disabled.get)
				local Hacker = SafeATMState(States.hacker and States.hacker.get)
				local ActiveHackTool = SafeATMState(States.active_hack_tool and States.active_hack_tool.get)

				local HackerName =
					type(Hacker) == "Instance" and Hacker.Name or Hacker and tostring(Hacker) or "<none>"
				dbgprint(
					"CookFarm ATM Debug:",
					Stage,
					"disabled=",
					tostring(Disabled),
					"hacker=",
					HackerName,
					"activeTool=",
					ActiveHackTool and tostring(ActiveHackTool) or "<none>"
				)

				if Disabled == true then
					dbgwarn("CookFarm: ATM disabled (stage=" .. Stage .. ").")
					return false
				end

				if Hacker and Hacker ~= LocalPlayer then
					dbgwarn("CookFarm: ATM currently being used by", HackerName, "(stage=" .. Stage .. ").")
					return false
				end

				-- Active hack tool flag lingers after completed hacks; treat it as informational only.
				return true
			end

			if not ATMAvailable(ATMObject, "pre-approach") then
				MoveToCookATMPoint(OriginPosition, 0.25, "ReturnOrigin_Pre")
				SecureNet.Send(ArgumentChecks.Sprint.Value, false)
				return
			end

			local ATMGoalPosition = GetCookATMGoal(ATMObject)
			if not ATMGoalPosition then
				ATMObject = FindCookATMObject() or ATMObject
				ATMGoalPosition = GetCookATMGoal(ATMObject)
			end
			dbgprint(
				"CookFarm ATM Debug: ATM goal",
				ATMObject and (ATMObject.instance and ATMObject.instance:GetFullName()) or "<nil>",
				ATMGoalPosition and string.format("(%.3f, %.3f, %.3f)", ATMGoalPosition.X, ATMGoalPosition.Y, ATMGoalPosition.Z)
					or "<nil>"
			)
			if ATMGoalPosition then
				VisualizeCookATMPoint("ATMGoal", ATMGoalPosition, Color3.fromRGB(255, 85, 0))
			else
				VisualizeCookATMPoint("ATMGoal_Fallback", CookATMReferencePoint, Color3.fromRGB(255, 0, 127))
			end

			if not ATMGoalPosition then
				dbgwarn("CookFarm: Unable to resolve ATM position. Aborting deposit.")
				MoveToCookATMPoint(CookATMWaypoint2, nil, "Waypoint2_Return_NoATM")
				MoveToCookATMPoint(CookATMWaypoint1, nil, "Waypoint1_Return_NoATM")
				MoveToCookATMPoint(OriginPosition, 0.25, "ReturnOrigin_NoATM")
				SecureNet.Send(ArgumentChecks.Sprint.Value, false)
				return
			end

			MoveToCookATMPoint(ATMGoalPosition, 0.5, "ATMGoal")

			ATMObject = FindCookATMObject() or ATMObject
			if not ATMObject then
				WaitForPing()
				ATMObject = FindCookATMObject() or ATMObject
			end

			if not ATMObject then
				dbgwarn("CookFarm: ATM object unavailable even after moving. Aborting deposit.")
				MoveToCookATMPoint(CookATMWaypoint2, nil, "Waypoint2_Return_NoObject")
				MoveToCookATMPoint(CookATMWaypoint1, nil, "Waypoint1_Return_NoObject")
				MoveToCookATMPoint(OriginPosition, 0.25, "ReturnOrigin_NoObject")
				SecureNet.Send(ArgumentChecks.Sprint.Value, false)
				return
			end

			if not ATMAvailable(ATMObject, "post-approach") then
				MoveToCookATMPoint(CookATMWaypoint2, nil, "Waypoint2_Return_AfterCheck")
				MoveToCookATMPoint(CookATMWaypoint1, nil, "Waypoint1_Return_AfterCheck")
				MoveToCookATMPoint(OriginPosition, 0.25, "ReturnOrigin_AfterCheck")
				SecureNet.Send(ArgumentChecks.Sprint.Value, false)
				return
			end

			SecureNet.Get(ArgumentChecks.ATM_Transfer.Value, "hand", "bank", Cash)
			dbgprint("CookFarm ATM Debug: transfer request sent", Cash)
			WaitForPing()

			MoveToCookATMPoint(CookATMWaypoint2, nil, "Waypoint2_Return_Success")
			MoveToCookATMPoint(CookATMWaypoint1, nil, "Waypoint1_Return_Success")
			MoveToCookATMPoint(OriginPosition, 0.25, "ReturnOrigin_Success")
			SecureNet.Send(ArgumentChecks.Sprint.Value, false)
		end

		while task_wait(0.2) do
			if not G_Toggle("CookFarm") then
				continue
			end

			if not (AssertArgument("Start_Grilling") and AssertArgument("Finish_Grilling")) then
				dbgprint("CookFarm: Arguments not found. Stopping.")
				SafeNotify("CookFarm Error: 0x02.", 3)
				task_wait(3)
				break
			end

			local Character = AssertCharacter()

			if LocalPlayer:GetAttribute("Job") ~= "steakhouse_cook" then
				dbgprint("CookFarm: Player is not a steakhouse cook. Teleporting to Steakhouse...")
				SafeNotify("CookFarm: Teleporting to Steakhouse...", 3)

				local SteakHouseCheckpoint1 = Vector3.new(-227, 254.659, 326)
				local SteakHouseCheckpoint2 = Vector3.new(-233, 254.659, 334)

				SecureLerpTeleport(Character:GetPivot(), CFrame.new(SteakHouseCheckpoint1), TELEPORT_SPEED)
				Utils.LerpTP(SteakHouseCheckpoint2, 3)
				task_wait(1)
				Utils.TP(Vector3.new(-235, 256, 340))
				task_wait(0.5)
				SecureNet.Send(
					ArgumentChecks.Apply_For_Job.Value,
					workspace
						:WaitForChild("Map")
						:WaitForChild("Tiles")
						:WaitForChild("ShoppingTile")
						:WaitForChild("SteakHouse")
						:WaitForChild("Interior")
						:WaitForChild("SteakHouseBeacon")
				)
				task_wait(1)
				SafeNotify("CookFarm: Applied for Steakhouse Cook job.", 3)
			end

			local Success, Error = pcall(function()
				AttemptCookAutoDeposit()

				local HeldTool = secure_call(Char.held_tool.get)
				local HasSteak = HeldTool and HeldTool:GetAttribute("IsCookable") == true

				if not HasSteak then
					dbgprint("Getting steak")

					local Character = AssertCharacter()

					-- LerpTP to fridge

					local Start = Character:GetPivot()
					local Goal = CFrame.new(-279, 257, 334) + Vector3.new(0, 0, 2)
					local Path = PathLib.GetPath(Start.Position, Goal.Position)

					pcall(function()
						for i, Waypoint: PathWaypoint in next, Path:GetWaypoints() do
							SecureNet.Send(ArgumentChecks.Sprint.Value, true)
							local TravelTime =
								PathLib.GetTravelTime((Waypoint.Position - Character:GetPivot().Position).Magnitude, 60)
							Utils.LerpTP(Waypoint.Position + Vector3.new(0, 3, 0), TravelTime)
						end
					end)

					SecureNet.Send(ArgumentChecks.Sprint.Value, false)

					fireproximityprompt(FridgePrompt)

					local StartTime = os.clock()
					repeat
						task_wait(0.1)
						HeldTool = secure_call(Char.held_tool.get) or LocalPlayer.Backpack:FindFirstChild("Steak")
						HasSteak = HeldTool and HeldTool:GetAttribute("IsCookable") == true
						if os.clock() - StartTime > 5 then
							error("Failed to get steak within 5 seconds")
						end
					until HasSteak
					dbgprint("Got steak:", HeldTool and HeldTool.Name or "Unknown")
				else
					dbgprint("Already holding a cookable item:", HeldTool.Name)
				end

				local TargetGrillObject = nil
				local FindStartTime = os.clock()
				repeat
					TargetGrillObject = GetAvailableGrillObject()
					if TargetGrillObject then
						break
					end
					dbgprint("Waiting for an available grill...")
					task_wait(0.5)
					if os.clock() - FindStartTime > 15 then
						error("Could not find an available grill within 15 seconds")
					end
				until TargetGrillObject

				if not TargetGrillObject or not TargetGrillObject.instance then
					error("Failed to get a valid grill object or instance")
				end

				local SelectedGrillHighlight = Instance.new("Highlight", TargetGrillObject.instance)
				SelectedGrillHighlight.FillColor = Color3.fromRGB(255, 255, 0)
				SelectedGrillHighlight.OutlineColor = Color3.fromRGB(255, 255, 0)
				Debris:AddItem(SelectedGrillHighlight, 5)
				TweenService:Create(SelectedGrillHighlight, TweenInfo.new(3), { FillTransparency = 1 }):Play()
				TweenService:Create(SelectedGrillHighlight, TweenInfo.new(5), { OutlineTransparency = 1 }):Play()

				local GrillInstance = TargetGrillObject.instance
				dbgprint("Found available grill:", GrillInstance.Name)

				local Character = AssertCharacter()
				local Start = Character:GetPivot()
				local Goal = GrillInstance.GrillArea:GetPivot()
				local Path = PathLib.GetPath(Start.Position, Goal.Position)

				for i, Waypoint: PathWaypoint in next, Path:GetWaypoints() do
					SecureNet.Send(ArgumentChecks.Sprint.Value, true)
					local TravelTime =
						PathLib.GetTravelTime((Waypoint.Position - Character:GetPivot().Position).Magnitude, 60)
					Utils.LerpTP(Waypoint.Position + Vector3.new(0, 3, 0), TravelTime)
				end

				SecureNet.Send(ArgumentChecks.Sprint.Value, false)

				task_wait(0.5)

				dbgprint("Starting grill process for:", GrillInstance.Name)
				SecureNet.Send(ArgumentChecks.Start_Grilling.Value, GrillInstance)

				local PerfectTime = 0
				local WaitStartTime = os.clock()
				dbgprint("Waiting for grill state updates...")
				repeat
					task_wait(0.1)

					if secure_call(TargetGrillObject.states.user_id_assigned.get) == LocalUserId then
						PerfectTime = secure_call(TargetGrillObject.states.perfect_cook_time.get)
						dbgprint("Grill assigned, Perfect Time:", PerfectTime)
						pcall(function()
							SelectedGrillHighlight.FillColor = Color3.fromRGB(0, 255, 0)
							SelectedGrillHighlight.OutlineColor = Color3.fromRGB(0, 255, 0)
						end)
					end

					if os.clock() - WaitStartTime > 10 then
						LocalPlayer.Character.Humanoid:UnequipTools()
						error(
							"Grill state did not update (assignment/time) within 10 seconds (this is bad contact sashaa)"
						)
					end
				until PerfectTime > 0

				dbgprint("Grill assigned to user. PerfectTime:", PerfectTime)

				local CookTime = PerfectTime - 0.2
				if CookTime < 0.1 then
					CookTime = 0.1
				end

				-- print("Calculated CookTime:", CookTime, "(Perfect:", PerfectTime, ")")
				dbgprint("Waiting for cook duration:", CookTime)
				task_wait(CookTime)

				dbgprint("Finishing grill:", GrillInstance.Name)
				SecureNet.Send(ArgumentChecks.Finish_Grilling.Value, GrillInstance, "Perfect")

				dbgprint("Cooked steak successfully on", GrillInstance.Name)
			end)

			if not Success then
				warn("CookFarm Error: ", Error)
				LocalPlayer.Character.Humanoid:UnequipTools()
				task_wait(2)
			end
		end
	end))

	local ATMFarmRoutine = coroutine_create(LPH_JIT_MAX(function()
		local Routine = 0
		local Welds = {}
		local RoutineRunning = false
		local RoutineStart = os.clock()
		local CurrentThread = nil

		while task_wait() do
			if not G_Toggle("ATMFarm") then
				RoutineRunning = false
				if CurrentThread then
					task.cancel(CurrentThread)
					CurrentThread = nil
				end
			end

			if Storage.Panic then
				dbgprint("ATMFarm: Panic mode activated. Stopping.")
				SafeNotify("ATM-Farm Error: Panic mode activated.", 3)

				RoutineRunning = false
				if CurrentThread then
					task.cancel(CurrentThread)
					CurrentThread = nil
				end

				repeat
					task_wait(1)
				until not Storage.Panic
			end

			local Char = AssertCharacter()
			local Humanoid = Char:FindFirstChild("Humanoid") :: Humanoid

			if not Humanoid then
				dbgprint("ATMFarm: Humanoid not found. Yielding.")
				SafeNotify("ATM-Farm Error: Humanoid not found", 3)

				RoutineRunning = false
				if CurrentThread then
					task.cancel(CurrentThread)
					CurrentThread = nil
				end

				repeat
					task_wait(1)
				until AssertCharacter():FindFirstChild("Humanoid")
			end

			if Humanoid:GetAttribute("IsDead") then
				dbgprint("ATMFarm: Humanoid is dead. Yielding.")
				SafeNotify("ATM-Farm Error: Humanoid is dead", 3)

				RoutineRunning = false
				if CurrentThread then
					task.cancel(CurrentThread)
					CurrentThread = nil
				end

				repeat
					task_wait(1)
					Humanoid = AssertCharacter():FindFirstChild("Humanoid") :: Humanoid
					print(Humanoid, Humanoid:GetAttribute("IsDead"))
				until Humanoid and Humanoid:GetAttribute("IsDead") == nil

				continue
			end

			if Char:GetPivot().Position.Y < 251 then
				dbgprint("ATMFarm: Humanoid is below Y=251. Yielding.")
				SafeNotify("ATM-Farm Error: Character is below map... Yielding.", 3)

				RoutineRunning = false
				if CurrentThread then
					task.cancel(CurrentThread)
					CurrentThread = nil
				end

				repeat
					task_wait(1)
				until AssertCharacter():GetPivot().Position.Y >= 251

				continue
			end

			if RoutineRunning then
				if os.clock() - RoutineStart > 45 then
					dbgprint("ATMFarm: Routine timed out. Stopping.")
					SafeNotify("ATM-Farm Error: Timeout", 3)
					SafeReset()
					RoutineRunning = false
				else
					continue
				end
			else
				if CurrentThread then
					task.cancel(CurrentThread)
					CurrentThread = nil
				end

				pcall(function()
					Library.Toggles.AutoRespawn:SetValue(true)
				end)

				CurrentThread = task_spawn(function()
					xpcall(function()
						local function Exit()
							RoutineRunning = false
							return task_wait(9e9)
						end

						local function CalculatePurchasePlan()
							local toolName = G_Option("HackTool") or "HackToolPro"

							local plan = {
								toolName = toolName,
								toolPrice = 0,
								toolCount = 0,
								withdrawAmount = 0,
								totalCost = 0,
								shouldBuyShiesty = false,
								shiestyCost = 0,
								cash = 0,
								bank = 0,
								freeSlots = 0,
								isFeasible = false,
								reason = nil,
							}

							local price = secure_call(Item_Utils.get_item_rarity_price, plan.toolName)
							if typeof(price) ~= "number" or price <= 0 then
								dbgwarn("Failed to get price for item:", plan.toolName)
								plan.reason = "Failed to price hack tool"
								return plan
							end
							plan.toolPrice = math_floor(price)

							local inventoryStats = Inventory.GetInventoryStats()
							local handStats = inventoryStats and inventoryStats.hand or {}
							local maxHand = tonumber(handStats.max) or 0
							local currentHand = tonumber(handStats.current) or 0
							plan.freeSlots = math_max(0, maxHand - currentHand)

							local cash, bank = Inventory.GetMoney()
							plan.cash = tonumber(cash) or 0
							plan.bank = tonumber(bank) or 0

							if plan.freeSlots <= 0 then
								plan.reason = "Inventory is full"
								return plan
							end

							if G_Toggle("AutoShiesty") then
								local shiestyInHand =
									Inventory.FilterByLocation(Inventory.GetItemsByName("Shiesty"), "hand")
								if #shiestyInHand == 0 then
									local shiestyPrice = Item_Utils.get_item_rarity_price("Shiesty")
									if typeof(shiestyPrice) == "number" and shiestyPrice > 0 then
										plan.shouldBuyShiesty = true
										plan.shiestyCost = math_floor(shiestyPrice)
									else
										dbgwarn("Failed to get price for Shiesty item.")
									end
								end
							end

							local fundsAvailable = plan.cash + plan.bank
							local rawPurchaseCap = tonumber(G_Option("ATMHackToolPurchaseCap"))
							local purchaseCap = math.huge
							if rawPurchaseCap and rawPurchaseCap > 0 then
								purchaseCap = math_max(1, math_floor(rawPurchaseCap))
							end
							if plan.shouldBuyShiesty and plan.shiestyCost > 0 then
								if fundsAvailable >= plan.shiestyCost then
									fundsAvailable -= plan.shiestyCost
								else
									plan.reason = "Not enough funds for Shiesty"
									plan.shouldBuyShiesty = false
									plan.shiestyCost = 0
								end
							end

							local affordableByFunds = 0
							if plan.toolPrice > 0 then
								affordableByFunds = math_max(0, math_floor(fundsAvailable / plan.toolPrice))
							end

							plan.toolCount = math_min(plan.freeSlots, affordableByFunds)
							plan.toolCount = math_min(plan.toolCount, purchaseCap)

							if plan.toolCount <= 0 then
								if not plan.reason then
									plan.reason = fundsAvailable <= 0 and "No funds available"
										or "Insufficient funds for hack tools"
								end
								plan.shouldBuyShiesty = false
								plan.shiestyCost = 0
								return plan
							end

							local totalCost = plan.toolCount * plan.toolPrice
							if plan.shouldBuyShiesty then
								totalCost += plan.shiestyCost
							end
							plan.totalCost = totalCost

							local neededFromBank = totalCost - plan.cash
							if neededFromBank < 0 then
								neededFromBank = 0
							end

							if neededFromBank > plan.bank then
								local maxAffordableByBank = math_max(
									0,
									math_floor(
										(plan.cash + plan.bank - (plan.shouldBuyShiesty and plan.shiestyCost or 0))
											/ plan.toolPrice
									)
								)
								plan.toolCount = math_min(plan.toolCount, maxAffordableByBank)
								plan.toolCount = math_min(plan.toolCount, purchaseCap)

								if plan.toolCount <= 0 then
									plan.reason = "Bank funds insufficient"
									plan.shouldBuyShiesty = false
									plan.shiestyCost = 0
									plan.totalCost = 0
									plan.withdrawAmount = 0
									return plan
								end

								totalCost = plan.toolCount * plan.toolPrice
								if plan.shouldBuyShiesty then
									totalCost += plan.shiestyCost
								end
								plan.totalCost = totalCost
								neededFromBank = totalCost - plan.cash
								if neededFromBank < 0 then
									neededFromBank = 0
								end
							end

							plan.withdrawAmount = math_min(plan.bank, math_floor(neededFromBank))
							plan.isFeasible = plan.toolCount > 0 and plan.totalCost > 0
							if not plan.isFeasible and not plan.reason then
								plan.reason = "Unable to determine purchase amount"
							end

							return plan
						end

						local function TeleportTo(Origin, Target, Speed, Conditional)
							if G_Toggle("ATMFarmUsePath") then
								return SecureLerpTeleportWithPathfinding(
									Origin,
									Target,
									Speed * G_Option("ATMFarmSpeedMultiplier"),
									Conditional
								)
							else
								return SecureLerpTeleport(
									Origin,
									Target,
									Speed * G_Option("ATMFarmSpeedMultiplier"),
									Conditional
								)
							end
						end

						RoutineRunning = true
						RoutineStart = os.clock()

						if not G_Toggle("ATMFarm") then
							Exit()
						end

						if os.clock() - START_TIME > AUTO_HOP_INTERVAL then
							-- Check if AutoHop is enabled and if the current routine is not the first one
							AttemptHop()
						end

						for _, Weld in next, Welds do
							Weld:Destroy()
						end

						if not (AssertArgument("Request") and AssertArgument("Win")) then
							dbgprint("ATMFarm: ATM arguments not found. Stopping.")
							SafeNotify("ATM-Farm Error: 0x02", 3)
							task_wait(3)
							Exit()
						end

						-- Assert that the player has a vehicle spawned and is in it
						local Character = AssertCharacter()
						local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid

						local ATMs = {}
						-- Find all ATMs that are not disabled, not hacked, and have no active hack tool
						for _, ATMObject in next, ATM_Module.class.objects do
							local Instance = ATMObject.instance
							local Disabled = secure_call(ATMObject.states.disabled.get)
							local Hacker = secure_call(ATMObject.states.hacker.get)
							local ActiveHackTool = secure_call(ATMObject.states.active_hack_tool.get)

							dbgprint(
								string.format(
									"ATM: %s (Status: %s, Hacker: %s, Tool: %s)",
									Instance.Name,
									Disabled and "Disabled" or "Active",
									Hacker and Hacker.Name or "None",
									ActiveHackTool
								)
							)

							if (not Disabled) and (Hacker == nil or Hacker == LocalPlayer) then
								ATMs[ATMObject] = Instance
							end
						end

						if flen(ATMs) == 0 then
							dbgprint("No ATMs found")
							Exit()
						end

						local TargetATM: ATM_ClassObject?
						local ClosestDistance = math.huge
						local CharacterPivot = Character:GetPivot()

						for Object, ATM in next, ATMs do
							local ATMPosition = ATM:GetPivot().Position
							local Distance = (ATMPosition - CharacterPivot.Position).Magnitude

							local Params = RaycastParams.new()
							Params.FilterType = Enum.RaycastFilterType.Exclude
							Params.FilterDescendantsInstances =
								{ ATM, Character, Map:WaitForChild("RoadNetwork") :: Folder }
							Params.RespectCanCollide = true

							local Result =
								workspace:Raycast(ATMPosition + Vector3.yAxis * 20, Vector3.yAxis * -20, Params)

							if Result then
								dbgprint("ATM is in an enclosed area, skipping")
								CollectionService:AddTag(ATM, "EnclosedATM")
								continue
							end

							if Distance < ClosestDistance then
								ClosestDistance = Distance
								TargetATM = Object
							end
						end

						if not TargetATM then
							dbgprint("No target ATM found")
							Exit()
						end

						assert(TargetATM, "Target ATM is nil")

						if not TargetATM then
							dbgprint("No target ATM found after assertion, something is wrong.")
							Exit()
						end

						dbgprint("Found target ATM:", TargetATM.instance.Name)

						local TargetATMInstance = TargetATM.instance
						local TargetATMPosition = TargetATMInstance:GetPivot()
						local CharacterPosition = Character:GetPivot()

						local VehicleSeat = Humanoid.SeatPart :: VehicleSeat

						if not VehicleSeat then
							-- We should try bringing our car if it exists

							local SpawnedVehicle = nil

							for _, Vehicle in next, Vehicles:GetChildren() do
								if Vehicle:GetAttribute("OwnerUserId") == LocalUserId then
									SpawnedVehicle = Vehicle
								end
							end

							-- Make sure we're not ragdolled and wait until we aren't
							while Character:GetAttribute("IsRagdoll") do
								SafeNotify(T("Waiting for character to recover from ragdoll..."))
								task_wait(1)
							end

							if not SpawnedVehicle then
								-- Check our inventory for vehicles.

								-- Try to find the best candidate (lowest index) in our inventory first.

								local InventoryVehicle = nil

								for i, ItemName in next, VehicleCandidates do
									local Item = Inventory.GetItemsByName(ItemName)[1]
									if Item then
										InventoryVehicle = Item
										if DEBUGGING then
											SafeNotify(T("Found InventoryItem Vehicle " .. ItemName))
										end
										break
									end
								end

								if InventoryVehicle then
									if ArgumentChecks.Toggle_Equip_Item.Found then
										SafeNotify(T(`Attempting to spawn vehicle {InventoryVehicle.Name}...`))

										local VehicleTimestamp = LocalPlayer:GetAttribute("SpawnVehicleNext") or 0
										local CurrentTime = workspace:GetServerTimeNow()

										if VehicleTimestamp > CurrentTime then
											local hopped = false
											if G_Toggle("ATMFarmAutoHop") then
												hopped = AttemptHop("VehicleSpawnCooldownAutoHop")
												if hopped then
													Exit()
												end
											end

											SafeNotify(T("Vehicle spawn cooldown detected, rejoining..."), 3)

											if AttemptRejoin("VehicleSpawnCooldown") then
												Exit()
											else
												SafeNotify(T("ATM-Farm: Automatic rejoin failed; waiting for cooldown."), 5)
												pcall(function()
													Library.Toggles.AutoRespawn:SetValue(false)
												end)
												if ArgumentChecks.Request_Respawn.Found then
													SecureNet.Send(ArgumentChecks.Request_Respawn.Value)
												end
												while VehicleTimestamp > CurrentTime do
													task_wait(1)
													CurrentTime = workspace:GetServerTimeNow()
													RoutineStart = os.clock()
												end
												if ArgumentChecks.Respawn.Found then
													task_wait(0.1)
													SecureNet.Send(ArgumentChecks.Respawn.Value)
												end
												pcall(function()
													Library.Toggles.AutoRespawn:SetValue(true)
												end)
											end
										end

										SecureNet.Get(ArgumentChecks.Toggle_Equip_Item.Value, InventoryVehicle.Guid)
										task_wait(1)
									end
								end
							end

							for _, Vehicle in next, Vehicles:GetChildren() do
								if Vehicle:GetAttribute("OwnerUserId") == LocalUserId then
									SpawnedVehicle = Vehicle
								end
							end

							if SpawnedVehicle then
								SafeNotify(T(`Vehicle exists, seating...`))

								SpawnedVehicle:PivotTo(Character:GetPivot() + Vector3.yAxis * 8)
								for _, Descendant in next, SpawnedVehicle:GetDescendants() do
									if Descendant:IsA("BasePart") then
										Descendant.AssemblyLinearVelocity = Vector3.yAxis * 5
										Descendant.AssemblyAngularVelocity =
											Vector3.new(math.random(), math.random(), math.random())
									end
								end
								WaitForPing()
								SpawnedVehicle:PivotTo(Character:GetPivot() + Vector3.yAxis * 30)
								Sit(SpawnedVehicle:FindFirstChildOfClass("VehicleSeat"), false)

								if not Humanoid.SeatPart then
									dbgprint("ATMFarm: Failed to sit in vehicle. Stopping.")
									SafeNotify("ATMFarm Error: Failed to sit in vehicle.", 3)
									task_wait(3)

									-- We need to unequip the vehicle first.
									-- We should check if we can unequip the vehicle first.

									local VehicleTimestamp = LocalPlayer:GetAttribute("SpawnVehicleNext") or 0
									local CurrentTime = workspace:GetServerTimeNow()

									if VehicleTimestamp > CurrentTime then
										dbgprint("ATMFarm: Cannot re-equip vehicle yet. Waiting...")
										SafeNotify("ATMFarm Error: Vehicle ownership impossible.", 3)
										SafeNotify(T("Please wait for vehicle respawn cooldown, this may take a while..."), 3)

										local hopped = false
										if G_Toggle("ATMFarmAutoHop") then
											hopped = AttemptHop("VehicleRespawnCooldownAutoHop")
											if hopped then
												Exit()
											end
										end

										SafeNotify(T("Vehicle respawn cooldown detected, rejoining..."), 3)

										if AttemptRejoin("VehicleRespawnCooldown") then
											Exit()
										else
											SafeNotify(T("ATM-Farm: Automatic rejoin failed; waiting for respawn cooldown."), 5)
											pcall(function()
												Library.Toggles.AutoRespawn:SetValue(false)
											end)
											if ArgumentChecks.Request_Respawn.Found then
												SecureNet.Send(ArgumentChecks.Request_Respawn.Value)
											end
											while VehicleTimestamp > CurrentTime do
												task_wait(1)
												CurrentTime = workspace:GetServerTimeNow()
												RoutineStart = os.clock()
											end
											if ArgumentChecks.Respawn.Found then
												task_wait(0.1)
												SecureNet.Send(ArgumentChecks.Respawn.Value)
											end
											pcall(function()
												Library.Toggles.AutoRespawn:SetValue(true)
											end)
											task_wait(1.5)
										end
									end

									task_wait(1.5)

									for _, Vehicle in next, Vehicles:GetChildren() do
										if Vehicle:GetAttribute("OwnerUserId") == LocalUserId then
											SpawnedVehicle = Vehicle
											SecureNet.Get(
												ArgumentChecks.Toggle_Equip_Item.Value,
												Vehicle:GetAttribute("ItemGUID")
											)
											SafeNotify(`Unequipping {Vehicle.Name}...`)
										end
									end

									task_wait(1.5)

									-- Now we can abort the routine and it should respawn the vehicle in the next cycle.
									Exit()
								end
							end
						end

						VehicleSeat = Humanoid.SeatPart

						if VehicleSeat and VehicleSeat.Parent then
							for _, Descendant: BasePart in next, VehicleSeat.Parent:GetDescendants() do
								if Descendant:IsA("BasePart") then
									if not Descendant:GetAttribute("OldCanCollide") then
										Descendant:SetAttribute("OldCanCollide", Descendant.CanCollide)
									end

									Descendant.CanCollide = false
									Descendant.CanQuery = false
									Descendant.AssemblyLinearVelocity /= 1.2
								end
							end

							-- We are in a vehicle, we need to adjust the teleport speed based off the speed of the vehicle.
							-- Find the Motors folder under the parent of the vehicle seat
							-- The speed is the forwardMaxSpeed attribute of the Motors folder
							-- Given a TELEPORT_SPEED_VEHICLE of 60 for a vehicle with a forwardMaxSpeed of 35, calculate the ratio
							-- and calculate the new TELEPORT_SPEED_VEHICLE

							local Motors = VehicleSeat.Parent:FindFirstChild("Motors")

							if Motors then
								local ForwardMaxSpeed = Motors:GetAttribute("forwardMaxSpeed") or 23
								local Ratio = ForwardMaxSpeed / 35
								TELEPORT_SPEED_VEHICLE = 65 * Ratio
							else
								TELEPORT_SPEED_VEHICLE = 40
							end
						end

						-- Check if we have any of the hacking tools in our inventory.
						local HackToolToUse = nil
						local PreferredToolName = G_Option("HackTool") or "!!ERROR_ILLEGAL_STATE!!"

						local BASE_HACK_TOOLS =
							{ "HackToolPro", "HackToolUltimate", "HackToolBasic", "HackToolQuantum" }

						for _, ToolName in next, BASE_HACK_TOOLS do
							local ToolsFound = Inventory.FilterByLocation(Inventory.GetItemsByName(ToolName), "hand")

							if ToolsFound and #ToolsFound > 0 then
								HackToolToUse = ToolName
								if ToolName ~= PreferredToolName then
									SafeNotify(T("Preferred tool not found. Using available: ") .. ToolName, 2)
								end
								break
							end
						end

						local purchasePlan = nil
						if not HackToolToUse and Routine == 0 then
							purchasePlan = CalculatePurchasePlan()

							if not purchasePlan.isFeasible then
								if purchasePlan.reason == "Inventory is full" then
									SafeNotify("ATM-Farm: Inventory full, forcing hack attempt to break loop.", 4)
									HackToolToUse = purchasePlan.toolName or (G_Option("HackTool") or "HackToolPro")
								else
									local reason = purchasePlan.reason or "Unable to auto-purchase hack tools"
									SafeNotify("ATM-Farm: " .. reason .. ".", 4)
									Routine = 0
									Exit()
								end
							else
								if purchasePlan.totalCost <= purchasePlan.cash then
									SafeNotify("ATM-Farm: Skipping withdrawal, enough cash available.")
									Routine = 2
								elseif purchasePlan.withdrawAmount > 0 then
									SafeNotify("ATM-Farm: No hacking tools found, withdrawing money...")
									Routine = 1
								else
									SafeNotify("ATM-Farm: Withdrawal amount invalid, stopping purchase attempt.", 4)
									Routine = 0
									Exit()
								end
							end
						end

						pcall(function()
							local RoutineInfo = {
								[0] = "Hacking ATM",
								[1] = "Withdraw money",
								[2] = "Buying Items",
							}

							Library.Labels.AutofarmRoutineLabel:SetText(`Routine: {RoutineInfo[Routine]}`)
						end)

						if Routine == 2 then
							-- Routine 2, going to shop to buy items

							local ShopPromptPart = workspace:WaitForChild("ShopZone_Illegal") :: Part

							if G_Option("HackTool") == "HackToolQuantum" then
								-- The dealer is a different shop, so we need to go there instead.
								ShopPromptPart = workspace:WaitForChild("ShopZone_IllegalNightclub") :: Part
							end

							TeleportTo(
								CharacterPosition,
								ShopPromptPart:GetPivot() + ShopPromptPart:GetPivot().RightVector * -3.5,
								VehicleSeat and TELEPORT_SPEED_VEHICLE or TELEPORT_SPEED
							)
						else
							-- Routine 1 or 0, going to ATM

							local TeleportData = TeleportTo(
								CharacterPosition,
								TargetATMPosition + TargetATMPosition.RightVector * -3.5,
								VehicleSeat and TELEPORT_SPEED_VEHICLE or TELEPORT_SPEED,
								function()
									if VehicleSeat and VehicleSeat.Parent then
										for _, Descendant: BasePart in next, VehicleSeat.Parent:GetDescendants() do
											if Descendant:IsA("BasePart") then
												Descendant.AssemblyLinearVelocity =
													Vector3.new(math.random(), math.random(), math.random())
											end
										end
									end

									local Hackable = true
									if
										secure_call(TargetATM.states.hacker.get)
										or secure_call(TargetATM.states.disabled.get)
									then
										Hackable = false
									end

									if G_Toggle("ATMFarmDynamicRerouting") then
										local NewClosestATM = nil
										local NewClosestDistance = math.huge
										local CurrentCharacterPivot = AssertCharacter():GetPivot()

										for _, ATMObject in next, ATM_Module.class.objects do
											local Instance = ATMObject.instance
											local Disabled = secure_call(ATMObject.states.disabled.get)
											local Hacker = secure_call(ATMObject.states.hacker.get)

											if (not Disabled) and (Hacker == nil or Hacker == LocalPlayer) then
												if not CollectionService:HasTag(Instance, "EnclosedATM") then
													local Distance = (
														Instance:GetPivot().Position - CurrentCharacterPivot.Position
													).Magnitude
													if Distance < NewClosestDistance then
														NewClosestDistance = Distance
														NewClosestATM = ATMObject
													end
												end
											end
										end

										if
											NewClosestATM
											and NewClosestATM.instance
											and NewClosestATM.instance ~= TargetATM.instance
										then
											local OriginalTargetDistance = (
												TargetATM.instance:GetPivot().Position - CurrentCharacterPivot.Position
											).Magnitude
											if NewClosestDistance < (OriginalTargetDistance * 0.85) then
												return false
											end
										end
									end

									return Hackable
								end
							)

							if TeleportData.Status == "Aborted" then
								-- Teleport failed, we should retry the current routine.
								SafeNotify("Teleport aborted, restarting cycle...")
								Exit()
							end
						end

						local ShouldReturnToVehicle = false
						local MovementEvents = 0
						local MovementEventConnection = Cleaner(MovementEvent.Event:Connect(function()
							MovementEvents += 1
						end))
						Storage.Connections[_nextKey(Storage.Connections, "ATMFarm_MovementEvent")] =
							MovementEventConnection

						if VehicleSeat then
							-- You must be outside of the vehicle to use the ATM, so we need to unseat the player
							-- and then teleport them to the ATM position
							ShouldReturnToVehicle = true
							Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
							WaitForPing()
						end

						local LockPositionConnection, RunLockPositionConnection = nil, false
						LockPositionConnection = RunService.Heartbeat:Connect(function()
							if not RunLockPositionConnection then
								return
							end

							if MovementEvents > 3 then
								LockPositionConnection:Disconnect()
								MovementEventConnection:Disconnect()
								SafeNotify("ATM-Farm Error: Failed to lock position.", 3)
								Exit()
							end

							if not Humanoid.SeatPart then
								if Routine == 2 then
									local ShopPromptPart = workspace:WaitForChild("ShopZone_Illegal") :: Part
									if G_Option("HackTool") == "HackToolQuantum" then
										ShopPromptPart = workspace:WaitForChild("ShopZone_IllegalNightclub") :: Part
									end
									Utils.TP(ShopPromptPart:GetPivot() + ShopPromptPart:GetPivot().RightVector * -3.5)
								else
									Utils.TP(
										TargetATM.instance:GetPivot() + TargetATM.instance:GetPivot().RightVector * -3.5
									)
								end
							end

							if VehicleSeat and VehicleSeat.Parent then
								for _, Descendant in next, VehicleSeat.Parent:GetDescendants() do
									if Descendant:IsA("BasePart") then
										Descendant.AssemblyLinearVelocity = Vector3.new(0, 10, 0)
										if G_Toggle("ATMFarmDefensive") or G_Toggle("ATMFarmOffensive") then
											if Descendant.Name == "Chassis" then
												Descendant.AssemblyAngularVelocity = Vector3.new(50, 50, 50)
											end
										end
									end
								end

								if G_Toggle("ATMFarmDefensive") then
									VehicleSeat.Parent:PivotTo(
										CFrame.new(Character:GetPivot().Position)
											* VehicleSeat.Parent:GetPivot().Rotation
									)
								elseif G_Toggle("ATMFarmOffensive") then
									-- Get closest player in 20 stud radius
									local ClosestPlayer = nil
									local ClosestDistance = math.huge

									for _, Player in next, Players:GetPlayers() do
										if Player ~= LocalPlayer and Player.Character then
											local Distance = (
												Player.Character:GetPivot().Position - Character:GetPivot().Position
											).Magnitude
											if Distance < ClosestDistance and Distance < 20 then
												ClosestDistance = Distance
												ClosestPlayer = Player
											end
										end
									end

									if ClosestPlayer then
										VehicleSeat.Parent:PivotTo(
											CFrame.new(ClosestPlayer.Character:GetPivot().Position)
												* VehicleSeat.Parent:GetPivot().Rotation
										)
									else
										VehicleSeat.Parent:PivotTo(
											CFrame.new(Character:GetPivot().Position)
												* VehicleSeat.Parent:GetPivot().Rotation
										)
									end
								else
									VehicleSeat.Parent:PivotTo(Character:GetPivot() + Vector3.yAxis * 12)
								end
							end
						end)
						Storage.Connections[_nextKey(Storage.Connections, "ATMFarm_LockPosition_Heartbeat")] =
							Cleaner(LockPositionConnection)

						if Routine == 0 then
							-- Routine 0 hack_atm
							RunLockPositionConnection = true

							if os.clock() - Storage.LastHackedATM < 5 then
								local WaitTime = 5 - (os.clock() - Storage.LastHackedATM)
								SafeNotify("Waiting for ATM cooldown...", WaitTime)
								task_wait(WaitTime)
							end

							local HandMoney, _ = Inventory.GetMoney()

							if HandMoney > 0 then
								SecureNet.Get(ArgumentChecks.ATM_Transfer.Value, "hand", "bank", HandMoney)
							end

							SecureNet.Send(
								ArgumentChecks.Request.Value,
								TargetATMInstance,
								HackToolToUse -- Use the tool we determined is available, starting with the most basic.
							)

							local ChanceTime = 0

							if math.random(1, 5) == 1 then
								ChanceTime = 2 + math.random()
							end

							task_wait(1.5 + math.random() + ChanceTime + G_Option("HackFinishDelay"))
							SecureNet.Send(ArgumentChecks.Win.Value, TargetATMInstance)
						elseif Routine == 1 then
							-- Routine 1 withdraw_money
							RunLockPositionConnection = true

							local plan = CalculatePurchasePlan()
							if not plan.isFeasible then
								local reason = plan.reason or "Unable to prepare withdrawal"
								SafeNotify("ATM-Farm: " .. reason .. ".", 4)
								Routine = 0
								Exit()
							end

							if plan.withdrawAmount <= 0 then
								SafeNotify("ATM-Farm: Withdrawal not required, proceeding to purchase.")
								Routine = 2
							else
								local HandMoney, _ = Inventory.GetMoney()

								task_wait(1)
								local Success = pcall(
									SecureNet.Get,
									ArgumentChecks.ATM_Transfer.Value,
									"bank",
									"hand",
									plan.withdrawAmount
								)

								if not Success then
									SafeNotify(T("You have no money to withdraw. Attempting to buy anyways..."))
									Routine = 2
								else
									-- Check if our money has changed, if not then something has gone wrong.
									task_wait(1)
									local NewHandMoney, _ = Inventory.GetMoney()

									if NewHandMoney <= HandMoney and plan.withdrawAmount > 0 then
										SafeNotify(T("Failed to withdraw money, retrying..."))
										Routine = 1
									else
										if plan.withdrawAmount > 0 then
											SafeNotify(
												T("Successfully withdrew $") .. tostring(NewHandMoney - HandMoney)
											)
										end
										Routine = 2 -- Now that we have withdrawn money, we can buy the items
									end
								end
							end
						elseif Routine == 2 then
							-- Routine 2 now handles buying directly.
							RunLockPositionConnection = true

							local plan = CalculatePurchasePlan()
							if not plan.isFeasible or plan.toolCount <= 0 then
								local reason = plan.reason or "No valid purchase plan"
								SafeNotify("ATM-Farm: " .. reason .. ".", 4)
								Routine = 0
								Exit()
							end

							local toolName = plan.toolName or (G_Option("HackTool") or "HackToolPro")
							local ShopPromptPart = workspace:WaitForChild("ShopZone_Illegal")
							if toolName == "HackToolQuantum" then
								ShopPromptPart = workspace:WaitForChild("ShopZone_IllegalNightclub") :: Part
							end

							if plan.shouldBuyShiesty then
								local shiestyItems =
									Inventory.FilterByLocation(Inventory.GetItemsByName("Shiesty"), "hand")
								if #shiestyItems == 0 then
									SecureNet.Get(ArgumentChecks.Purchase_Consumable.Value, ShopPromptPart, "Shiesty")
									task_wait(0.5)
									shiestyItems =
										Inventory.FilterByLocation(Inventory.GetItemsByName("Shiesty"), "hand")
								end

								if #shiestyItems > 0 and not AssertCharacter():FindFirstChild("Shiesty") then
									SecureNet.Get(ArgumentChecks.Toggle_Equip_Item.Value, shiestyItems[1].Guid)
								end
							end

							SafeNotify(`ATM-Farm: Buying {plan.toolCount}x {toolName}`, 3)

							for _ = 1, plan.toolCount do
								SecureNet.Get(ArgumentChecks.Purchase_Consumable.Value, ShopPromptPart, toolName)
								task_wait(0.1)
							end

							task_wait(0.5)
							local Tools = Inventory.FilterByLocation(Inventory.GetItemsByName(toolName), "hand")
							if not Tools or #Tools == 0 then
								dbgprint("Failed to buy hacking tools")
								SafeNotify(T("ATM-Farm Error: Failed to buy hacking tools."), 3)
								-- Don't reset the routine, we need to try again
								task_wait(3)
								Routine = 2
							else
								task_wait(0.5)
								dbgprint("Bought hacking tools successfully")
								SafeNotify(T("ATM-Farm: Bought hacking tools successfully."), 3)
								Routine = 0 -- Now that we have bought the items, we can hack the ATM
							end
						end

						LockPositionConnection:Disconnect()
						MovementEventConnection:Disconnect()

						local Vehicle = FindVehicle()
						if Vehicle then
							local VehicleModel = Vehicle.Vehicle
							for _, Descendant in next, VehicleModel:GetDescendants() do
								if Descendant:IsA("BasePart") then
									if Descendant:GetAttribute("OldCanCollide") then
										Descendant.CanCollide = Descendant:GetAttribute("OldCanCollide")
										Descendant:SetAttribute("OldCanCollide", nil)
									end
									Descendant.CanQuery = true
									Descendant.AssemblyLinearVelocity = Vector3.zero
								end
							end
						end

						if ShouldReturnToVehicle then
							for i = 10, 1, -1 do
								if (not VehicleSeat) or Humanoid.SeatPart then
									break
								end

								if VehicleSeat.Parent then
									VehicleSeat.Parent:PivotTo(Character:GetPivot() + Vector3.yAxis * 12)
									for _, Descendant in next, VehicleSeat.Parent:GetDescendants() do
										if Descendant:IsA("BasePart") then
											Descendant.AssemblyLinearVelocity = Vector3.yAxis * 10 * math.random()
											Descendant.AssemblyAngularVelocity = Vector3.zero
										end
									end
								end

								RunService.Heartbeat:Wait()
							end
							WaitForPing()
							Sit(VehicleSeat)
						end

						Exit()
					end, function(err)
						warn("ATMFarm routine errored:", err)
						dbgprint(debug.traceback(tostring(err), 2))
						SafeNotify("ATM-Farm Error: " .. tostring(err), 5)
						Routine = 0
						RoutineRunning = false
					end)
				end)
			end
		end
	end))

	local ATMAutoHackRoutine = coroutine_create(LPH_JIT_MAX(function()
		while task_wait(0.1) do
			if not G_Toggle("ATM_Aura") then
				continue
			end

			if G_Toggle("ATMFarm") then
				continue
			end

			if not (AssertArgument("Request") and AssertArgument("Win")) then
				dbgprint("AutoHack: ATM arguments not found. Stopping.")
				SafeNotify("AutoHack Error: 0x02", 3)
				task_wait(3)
				break
			end

			for _, ATM in next, ATM_Module.class.objects do
				local Instance = ATM.instance
				if Instance and secure_call(ATM.states.hacker.get) == LocalPlayer then
					task_wait(2)
					SecureNet.Send(ArgumentChecks.Win.Value, Instance)
				end
			end
		end
	end))

	local PanicRoutine = coroutine_create(LPH_JIT_MAX(function()
		local PanicLast = os.clock()

		Storage.Connections[_nextKey(Storage.Connections, "Panic_Desync")] =
			Cleaner(RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
				local Character = AssertCharacter()
				local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: Part

				if not HumanoidRootPart then
					return
				end

				if Storage.Panic then
					for i = 1, 5 do
						sethiddenproperty(HumanoidRootPart, "NetworkIsSleeping", true)
						task.wait()
						sethiddenproperty(HumanoidRootPart, "NetworkIsSleeping", false)
						task.wait()
					end
				else
					sethiddenproperty(HumanoidRootPart, "NetworkIsSleeping", false)
				end
			end)))

		while task_wait() do
			pcall(function()
				if not G_Toggle("Panic") then
					return
				end

				if os.clock() - PanicLast < 5 then
					return
				end

				local Character = AssertCharacter()
				local Head = Character:FindFirstChild("Head") :: Part
				if not Head then
					return
				end

				local Downed = Head:WaitForChild("Downed", 1) :: BillboardGui
				if not Downed then
					return
				end

				if Downed.Enabled then
					PanicLast = os.clock()

					Storage.Panic = true

					local Origin = Character:GetPivot()
					if Origin.Position.Y <= PANIC_HEIGHT_THRESHOLD then
						Origin = CFrame.new(Origin.Position.X, PANIC_CONST_OFY, Origin.Position.Z)
					end

					local OriginPart = Instance.new("Part", workspace:WaitForChild("CrateSpinPreviewItems"))
					OriginPart.Size = Vector3.new(1, 1, 1)
					OriginPart.Position = Origin.Position
					OriginPart.Anchored = true
					OriginPart.CanCollide = false
					OriginPart.Transparency = 1

					Camera.CameraSubject = OriginPart

					local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
					if Humanoid then
						local PanicStart = os.clock()
						local HealthAbove29Start = nil
						local Flip = 1

						local function PanicStep(DeltaTime, AntiFlyFix)
							pcall(function()
								Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
							end)

							Flip *= -1

							for _, Limb in next, Character:GetChildren() do
								if Limb:IsA("BasePart") then
									Limb.AssemblyLinearVelocity = (Vector3.yAxis * -1000 * Flip)
										+ (Vector3.zAxis * -1000 * Flip)
									Limb.AssemblyAngularVelocity = Vector3.zero
								end
							end

							Utils.TPRoot(
								Origin
									- (Vector3.yAxis * (AntiFlyFix and 10 or 12))
									+ Vector3.xAxis * ((math_sin(os.clock() * 5 * 100)) * 10)
									+ Vector3.zAxis * (-(math_sin(os.clock() * 7 * 100)) * 10)
							)

							-- Teleport all limbs way farther under the map
							for _, Limb in next, Character:GetChildren() do
								if Limb:IsA("BasePart") and Limb.Name ~= "HumanoidRootPart" then
									Limb.CFrame = Origin
										+ Vector3.new(math.random(-200, 200), 1000, math.random(-200, 200))
								end
							end
						end

						local LastAntiFlyStep = os.clock()

						SecureNet.Send(ArgumentChecks.Enter_Character_Creator.Value, Character:GetPivot())

						while true do
							local DeltaTime = RunService.Heartbeat:Wait()

							local ANTI_FLY_TIMEOUT = 1.5
							local ANTI_FLY_FIX_WINDOW = 0.3
							-- Exit if panic duration is exceeded
							if os.clock() - PanicStart > PANIC_DURATION then
								Storage.Panic = false
								break
							end

							local AntiFlyFix = os.clock() - LastAntiFlyStep >= ANTI_FLY_FIX_WINDOW
							if
								AntiFlyFix
								and os.clock() - LastAntiFlyStep >= (ANTI_FLY_FIX_WINDOW + ANTI_FLY_TIMEOUT)
							then
								LastAntiFlyStep = os.clock()
							end

							if Humanoid.Health >= 29 then
								if not HealthAbove29Start then
									HealthAbove29Start = os.clock()
								end

								if os.clock() - HealthAbove29Start > 0.7 then
									for _, Limb in next, Character:GetChildren() do
										if Limb:IsA("BasePart") then
											Limb.CFrame = Origin
											Limb.AssemblyLinearVelocity = Vector3.zero
											Limb.AssemblyAngularVelocity = Vector3.zero
										end
									end
									Utils.TPRoot(Origin)
								else
									PanicStep(DeltaTime, AntiFlyFix)
								end
							else
								PanicStep(DeltaTime, AntiFlyFix)
							end

							if not Downed.Enabled then
								Storage.Panic = false
								break
							end
						end

						if not shared.GodMode then
							SecureNet.Send(ArgumentChecks.Leave_Character_Creator.Value)
						end

						Camera.CameraSubject = Humanoid
					end
				end
			end)
		end
	end))

	local ItemAuraRoutine = coroutine_create(LPH_JIT_MAX(function()
		while true do
			task_wait(0.1)

			if not G_Toggle("ItemAura") then
				continue
			end

			local Character = AssertCharacter()

			for _, Item in next, workspace:WaitForChild("DroppedItems"):GetChildren() do
				if Item:IsA("Model") then
					local ItemPosition = Item:GetPivot().Position
					local CharacterPosition = Character:GetPivot().Position

					if (ItemPosition - CharacterPosition).Magnitude < 30 then
						if Item.Name == "Money" then
							task_spawn(function()
								pcall(SecureNet.Get, ArgumentChecks.Pickup_Dropped_Item.Value, Item)
							end)
							continue
						end

						-- Check if the item is one of the targeted rarities
						local Rarities = G_Option("ItemAuraRarities")

						local function GetRarityFromName(Name: string): string
							for _, ItemCategory in next, ReplicatedStorage.Items:GetChildren() do
								for _, ItemInstance in next, ItemCategory:GetChildren() do
									if ItemInstance.Name == Name then
										return ItemInstance:GetAttribute("RarityName")
									end
								end
							end

							return "Common"
						end

						local ItemRarity = GetRarityFromName(Item.Name)

						if not Rarities[ItemRarity] then
							continue
						end

						-- Check if ItemFilter is enabled and if the item is in the filter list
						if G_Toggle("InventoryFilterEnabled") then
							local ExcludedItems = G_Option("InventoryFilterList")
							if ExcludedItems[Item.Name] then
								-- print("Excluded item:", Item.Name)
								continue
							end
						end

						task_spawn(function()
							pcall(SecureNet.Get, ArgumentChecks.Pickup_Dropped_Item.Value, Item)
						end)

						if not Storage.ItemAuraConnections[Item] then
							local Connection
							Connection = RunService.Heartbeat:Connect(function()
								if (not Item) or not Item.Parent or (not Item:FindFirstChild("PickUpZone")) then
									if Connection then
										Connection:Disconnect()
										Connection = nil
									end
									Storage.ItemAuraConnections[Item] = nil
									return
								end
								firetouchinterest(
									Item.PickUpZone,
									Character:FindFirstChild("HumanoidRootPart") :: Part,
									1 :: any
								)
								firetouchinterest(
									Item.PickUpZone,
									Character:FindFirstChild("HumanoidRootPart") :: Part,
									0 :: any
								)
							end)
							Storage.ItemAuraConnections[Item] = Connection
						end
					end
				end
			end
		end
	end))

	local ItemFilterRoutine = coroutine_create(LPH_NO_VIRTUALIZE(function()
		while task_wait() do
			if not G_Toggle("InventoryFilterEnabled") then
				continue
			end

			local ExcludedItems = G_Option("InventoryFilterList")
			local ItemsInInventory = Inventory.FilterByLocation(Inventory.ListInventory(), "hand")
			-- print(#ItemsInInventory, 'items in hand')

			for _, Item in next, ItemsInInventory do
				if ExcludedItems[Item.Name] then
					-- print("Disposing of item:", Item.Name)
					SecureNet.Send(ArgumentChecks.Drop_Item.Value, Item.Guid, Item.Amount)
				end
			end
		end
	end))

	local WalkFlingRoutine = coroutine_create(LPH_JIT_MAX(function()
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

			local OldTransform = Root.CFrame

			Root.AssemblyLinearVelocity = Velocity * 10000 + Vector3.yAxis * 10000
			Root.CFrame = OldTransform + Vector3.yAxis * 5 * math.random()

			RunService.RenderStepped:Wait()

			Root.AssemblyLinearVelocity = Velocity
			Root.CFrame = OldTransform

			RunService.Stepped:Wait()

			Root.AssemblyLinearVelocity += Vector3.yAxis * Flip * 0.1
			Flip *= -1
		end
	end))

	local KillAuraRoutine = coroutine_create(LPH_JIT_MAX(function()
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

			if not Tool:HasTag("Melee") then
				continue
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

			local v66 = 30
			local v_u_67 = v66 * 0.75 + math.random() * v66 * 0.25
			local v_u_68 = LocalPlayer:GetAttribute("SpeedMultiplier") or 1

			Tool:Activate()
			task_wait(0.15)
			SecureNet.Send(ArgumentChecks.Melee_Attack.Value, Tool, HitPlayers, Pivot, v_u_67 * v_u_68)
			task_wait(0.5)
		end
	end))

	local BumpAuraRoutine = coroutine_create(LPH_JIT_MAX(function()

		local LastBump = os.clock()
		local BumpCooldown = 4.1

		while RunService.Heartbeat:Wait() do
			if not G_Toggle("BumpAura") then
				continue
			end

			if os.clock() - LastBump < BumpCooldown then
				continue
			end

			local Character = AssertCharacter()
			local Humanoid = Character:FindFirstChildOfClass("Humanoid")

			if Humanoid and Humanoid.SeatPart and Humanoid.SeatPart:IsA("VehicleSeat") then
				
				-- Get the closest player within 20 studs
				local ClosestPlayer = nil
				local ClosestDistance = math.huge

				for _, Player in next, Players:GetPlayers() do
					if Player ~= LocalPlayer and Player.Character then
						local Distance = (
							Player.Character:GetPivot().Position - Character:GetPivot().Position
						).Magnitude
						if Distance < ClosestDistance and Distance < 20 then
							ClosestDistance = Distance
							ClosestPlayer = Player
						end
					end
				end

				if ClosestPlayer then
					
					SecureNet.Send(
						"run_over",
						Humanoid.SeatPart.Parent,
						ClosestPlayer.Character,
						vector.create(0, 200, 0)
					)

					LastBump = os.clock()

				end

			end

		end
	end))

	local ThrowableAuraRoutine = coroutine_create(LPH_JIT_MAX(function()
		while task_wait(0.1) do
			if not G_Toggle("ThrowableAura") then
				continue
			end

			local Character = AssertCharacter()
			local Tool = Character:FindFirstChildOfClass("Tool")

			if not Tool then
				continue
			end

			if Tool:HasTag("Throwable") then
				local Closest, Distance = nil, math.huge

				for _, Player in next, Players:GetPlayers() do
					if
						Player ~= LocalPlayer
						and Player.Character
						and Player.Character:FindFirstChild("HumanoidRootPart")
					then
						local OtherPivot = Player.Character:GetPivot()

						if (OtherPivot.Position - Character:GetPivot().Position).Magnitude < Distance then
							Closest = Player
							Distance = (OtherPivot.Position - Character:GetPivot().Position).Magnitude
						end
					end
				end

				if Closest and Distance < 20 then
					local Target = Closest.Character
					if Target then
						Tool:Activate()
						task_wait()
						SecureNet.Send(
							ArgumentChecks.Throw_Item.Value,
							Tool,
							Prediction:GetPredictedPosition(Target.Head),
							Vector3.yAxis * -10
						)

						local ProjectileModel = nil
						local Connection
						Connection = workspace.ChildAdded:Connect(function(Child)
							if Child:IsA("Model") and Child.Name == Tool.Name then
								ProjectileModel = Child
								if Connection then
									Connection:Disconnect()
									Connection = nil
								end
							end
						end)

						local StartTime = os.clock()
						repeat
							task_wait()
						until ProjectileModel or os.clock() - StartTime > 1

						if Connection then
							Connection:Disconnect()
							Connection = nil
						end

						if ProjectileModel and ProjectileModel.PrimaryPart then
							SecureNet.Send(
								ArgumentChecks.Throw_Hit.Value,
								ProjectileModel,
								Target.PrimaryPart,
								ProjectileModel.PrimaryPart.CFrame
							)
						end
					end
				end
			end
		end
	end))

	local GunModsRoutine = coroutine_create(LPH_JIT_MAX(function()
		Storage.UpdateGunStatsCallback.Event:Connect(function()
			local GunClass = Class_Interface.GetClass("Gun")
			if not GunClass then
				warn("Gun class not found by Class_Interface!")
				return
			end

			local GunObjects = GunClass.objects or {}
			if next(GunObjects) == nil then
				-- print("No gun objects found to process at this time.")
				return
			end

			for _, Gun in next, GunObjects do
				if not (Gun and Gun.instance and Gun.states) then
					-- print("Skipping invalid or nil gun object in GunObjects table.")
					if Gun and Gun.instance then
						warn("Gun object for", Gun.instance.Name, "is missing .states property!")
					elseif Gun then
						warn("Gun object is missing .instance property!")
					end
					continue
				end

				local States = Gun.states
				-- dbgprint("Indexing gun states for", Gun.instance.Name)
				for StateName, State in next, States do
					if not (State and State.get and typeof(State.get) == "function") then
						warn(
							"Invalid state object or missing get method for state",
							StateName,
							"in gun",
							Gun.instance.Name
						)
						continue
					end

					if Storage.GunModReferences[StateName] then
						-- print("Hooking gun state", StateName, "for", Gun.instance.Name)
						if not isfunctionhooked(State.get) then
							HookMgr.RegisterHook(
								tostring(State.get) .. HttpService:GenerateGUID(false),
								State.get,
								function(Old, ...)
									local Caller: ((...any) -> ...any)?
									local Level = 1

									while Level < 100 do
										local Source = debug.info(Level, "s")
										if Source and Source:match("Gun") then
											Caller = debug.info(Level, "f")
											break
										end

										Level += 1
									end

									-- print("Gun state get called for", StateName, "on", Gun.instance.Name) -- Added gun name for clarity

									local Result
									local ModReference = Storage.GunModReferences[StateName]

									if StateName == "automatic" then
										Result = G_Toggle_NYield(ModReference)
									else
										Result = G_Option_NYield(ModReference)
									end

									if Result ~= nil then
										-- print(
										-- 	"Returning modified value for",
										-- 	StateName,
										-- 	":",
										-- 	Result,
										-- 	"for gun",
										-- 	Gun.instance.Name
										-- )

										if StateName == "fire_rate" then
											if Caller then
												-- local CallerSource = debug.info(Caller, "s")
												-- local CallerName = debug.info(Caller, "n")
												local Upvalues = #debug.getupvalues(Caller)
												-- print(
												-- 	"Caller for fire_rate:",
												-- 	CallerName,
												-- 	"Source:",
												-- 	CallerSource,
												-- 	"Upvalues:",
												-- 	Upvalues,
												-- 	"FireDelay:",
												-- 	debug.getupvalue(Caller, 7) or "N/A"
												-- )

												if Upvalues == 17 then
													-- This is the firerate check function, set the 7th upvalue (ratetime upvalue) to 60 / Result
													local FireDelay = 60 / Result
													debug.setupvalue(Caller, 7, FireDelay)
													-- print("Set fire rate upvalue to", FireDelay, "for", CallerName)
												end
											end
										end

										return Result
									else
										-- print("Returning original value for", StateName, "for gun", Gun.instance.Name)
										return Old(...)
									end
								end
							)
						else
							-- print("State.get for", StateName, "on", Gun.instance.Name, "is already hooked.")
						end
					else
						-- print("No gun mod reference for state", StateName, "in", Gun.instance.Name)
					end
				end
			end
		end)
	end))

	local MeleeModsRoutine = coroutine_create(LPH_JIT_MAX(function()
		Storage.UpdateMeleeStatsCallback.Event:Connect(function()
			local MeleeClass = Class_Interface.GetClass("Melee")
			if not MeleeClass then
				warn("Melee class not found by Class_Interface!")
				return
			end

			local MeleeObjects = MeleeClass.objects or {}
			if next(MeleeObjects) == nil then
				-- print("No melee objects found to process at this time.")
				return
			end

			for _, Melee in next, MeleeObjects do
				if not (Melee and Melee.instance and Melee.states) then
					print("Skipping invalid or nil melee object in MeleeObjects table.")
					if Melee and Melee.instance then
						warn("Melee object for", Melee.instance.Name, "is missing .states property!")
					elseif Melee then
						warn("Melee object is missing .instance property!")
					end
					continue
				end

				local States = Melee.states
				-- dbgprint("Indexing melee states for", Melee.instance.Name)
				for StateName, State in next, States do
					if not (State and State.get and typeof(State.get) == "function") then
						warn(
							"Invalid state object or missing get method for state",
							StateName,
							"in melee",
							Melee.instance.Name
						)
						continue
					end

					if Storage.MeleeModReferences[StateName] then
						-- print("Hooking melee state", StateName, "for", Melee.instance.Name)
						if not isfunctionhooked(State.get) then
							HookMgr.RegisterHook(
								tostring(State.get) .. HttpService:GenerateGUID(false),
								State.get,
								function(Old, ...)
									print("Melee state get called for", StateName, "on", Melee.instance.Name) -- Added melee name for clarity

									local Result
									local ModReference = Storage.MeleeModReferences[StateName]
									Result = G_Option_NYield(ModReference)

									if G_Toggle_NYield("MeleeModificationEnabled") and Result ~= nil then
										print(
											"Returning modified value for",
											StateName,
											":",
											Result,
											"for melee",
											Melee.instance.Name
										)

										return Result
									else
										print(
											"Returning original value for",
											StateName,
											"for melee",
											Melee.instance.Name
										)
										return Old(...)
									end
								end
							)
						else
							-- print("State.get for", StateName, "on", Gun.instance.Name, "is already hooked.")
						end
					else
						-- print("No gun mod reference for state", StateName, "in", Gun.instance.Name)
					end
				end
			end
		end)
	end))

	local AntiAimRoutine = coroutine_create(LPH_JIT_MAX(function()
		while true do
			RunService.PreSimulation:Wait()

			if not G_Toggle("Invisibility") then
				continue
			end

			local Character = AssertCharacter()
			local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid

			if Humanoid then
				local Animator = Humanoid:WaitForChild("Animator") :: Animator
				-- local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart") :: BasePart

				local Animation = Storage.Anti_Aim_Animation

				if not Animation then
					Animation = Instance.new("Animation")
					Animation.AnimationId = "rbxassetid://127212897044971" --"rbxassetid://17360699557"
					local Track = Animator:LoadAnimation(Animation)
					Track.Priority = Enum.AnimationPriority.Action4
					Track:Play(0, 255, 1)
					task_wait()
					Track.TimePosition = 0.837
					task_wait()
					Track:AdjustSpeed(0)
					Storage.Anti_Aim_Animation = Track
				end

				for _, Connection in next, getconnections(Humanoid:GetPropertyChangedSignal("HipHeight")) do
					if Connection.Function then
						Connection:Disable()
					end
				end

				Humanoid.HipHeight = 1
			end
		end
	end))

	local AntiAimbotRoutine = coroutine_create(LPH_JIT_MAX(function()
		local AntiAimbotAnimation = nil
		local AnimId = "rbxassetid://109873544976020" --"http://www.roblox.com/asset/?id=14352343065"

		while RunService.Heartbeat:Wait() do
			if not G_Toggle("Anti-Aimbot") then
				if AntiAimbotAnimation then
					AntiAimbotAnimation:Stop()
					AntiAimbotAnimation = nil
				end
				continue
			end

			local Character = AssertCharacter()

			local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid

			if not Humanoid then
				continue
			end

			local Animator = Humanoid:FindFirstChildOfClass("Animator") :: Animator

			if not Animator then
				continue
			end

			-- Check if the animation is already playing

			local Playing = false
			for _, Track in next, Animator:GetPlayingAnimationTracks() do
				if Track.Animation.AnimationId == AnimId then
					Playing = true
					break
				end
			end

			-- If we're here, this means the current antiaimbotanimation is not playing or nil. Set to nil.
			if AntiAimbotAnimation and not Playing then
				AntiAimbotAnimation = nil
			end

			if not Playing then
				local Animation = Instance.new("Animation")
				Animation.AnimationId = AnimId
				local Track = Animator:LoadAnimation(Animation)
				AntiAimbotAnimation = Track
				Track.Priority = Enum.AnimationPriority.Action4
				Track.Looped = true
				Track:Play(0, 255, 60)
			end
		end
	end))

	local AutoFishRoutine = coroutine_create(LPH_JIT_MAX(function()
		local FishingRodModule = SafeRequire(GameModules.ItemTypes.FishingRod :: ModuleScript)
		local SliderMinigame = SafeRequire(GameModules.Minigames.SliderMinigame :: ModuleScript)
		local ItemUtils = SafeRequire(GameModules.Inventory.ItemUtils :: ModuleScript)

		local function FindWaterPosition()
			local HRP = secure_call(Char.get_hrp)
			if not HRP then
				return nil
			end

			local SearchOrigin = HRP.Position + (HRP.CFrame.LookVector * 20)
			local Params = RaycastParams.new()
			Params.FilterType = Enum.RaycastFilterType.Exclude
			Params.FilterDescendantsInstances = { LocalPlayer.Character }

			local Result = workspace:Raycast(SearchOrigin, Vector3.new(0, -100, 0), Params)
			if
				Result
				and Result.Material == Enum.Material.Water
				and (Result.Position - HRP.Position).Magnitude < 60
			then
				return Result.Position
			end
			return nil
		end

		SliderMinigame.enabled.hook(function(IsEnabled)
			if G_Toggle("AutoFish") and IsEnabled then
				local CurrentRod = secure_call(FishingRodModule.equipped_rod.get)
				if CurrentRod then
					SecureNet.Send(ArgumentChecks.Reel_Ended.Value, CurrentRod, true)
				end
			end
		end)

		while task_wait(1) do
			if not G_Toggle("AutoFish") then
				continue
			end

			local CurrentRod = secure_call(FishingRodModule.equipped_rod.get)
			if not CurrentRod then
				continue
			end

			local ItemGUID = CurrentRod:GetAttribute("ItemGUID")
			if not ItemGUID then
				continue
			end

			local ItemInfo = secure_call(ItemUtils.get_item_info, Data_Module, ItemGUID)
			if not ItemInfo then
				continue
			end

			if not (ItemInfo.ammo_amount and ItemInfo.ammo_amount > 0) then
				CurrentRod:Activate()
				task_wait(0.5)
				continue
			end

			if not CurrentRod:FindFirstChild("Bobber") then
				local WaterPosition = FindWaterPosition()
				if WaterPosition then
					SecureNet.Get(ArgumentChecks.Throw_Rod.Value, CurrentRod, WaterPosition)
				else
					SafeNotify("AutoFish: No nearby water found.")
				end
			end
		end
	end))

	local StaminaFarmRoutine = coroutine_create(LPH_JIT_MAX(function()
		while task_wait(1) do
			if G_Toggle("StaminaFarm") then
				local CurrentStamina = LocalPlayer:GetAttribute("SprintBar")
				-- Check if any auto-farms are enabled
				local AutoFarmEnabled = false
				local AutoFarmToggles = { "ATMFarm", "CookFarm", "ShelfStocking" }

				for _, Toggle in ipairs(AutoFarmToggles) do
					if G_Toggle(Toggle) then
						AutoFarmEnabled = true
						break
					end
				end

				Storage.MovementSpoof = AutoFarmEnabled

				if CurrentStamina < 0.01 then
					Storage.MovementSpoof = false
					repeat
						task_wait(1)
					until LocalPlayer:GetAttribute("SprintBar") >= 0.95
				end
			end
		end
	end))

	Storage.Connections[_nextKey(Storage.Connections, "LocalPlayer_LastHackedAtmTimestamp_Changed")] =
		Cleaner(LocalPlayer:GetAttributeChangedSignal("LastHackedAtmTimestamp"):Connect(function()
			-- print("updated lha")
			Storage.LastHackedATM = os.clock()
		end))

	Storage.Connections[_nextKey(Storage.Connections, "AntiAFK_Idled")] =
		Cleaner(Players.LocalPlayer.Idled:Connect(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end))

	--#endregion

	Cleaner(CookFarmRoutine)
	Cleaner(ATMAutoHackRoutine)
	Cleaner(InfiniteStaminaFixRoutine)
	Cleaner(AntiAimbotRoutine)
	Cleaner(StaminaFarmRoutine)

	if not FREE_BUILD then
		Cleaner(ATMFarmRoutine)
		Cleaner(PanicRoutine)
		Cleaner(WalkFlingRoutine)
		Cleaner(ItemAuraRoutine)
		Cleaner(KillAuraRoutine)
		Cleaner(ThrowableAuraRoutine)
		-- Cleaner(AutoFinishRoutine)
		Cleaner(GunModsRoutine)
		Cleaner(AntiAimRoutine)
		Cleaner(ShelfStockRoutine)
		Cleaner(MeleeModsRoutine)
		Cleaner(AutoFishRoutine)
		Cleaner(ItemFilterRoutine)
		Cleaner(BumpAuraRoutine)
	end

	coroutine_resume(CookFarmRoutine)
	coroutine_resume(ATMAutoHackRoutine)
	coroutine_resume(InfiniteStaminaFixRoutine)
	coroutine_resume(AntiAimbotRoutine)
	coroutine_resume(StaminaFarmRoutine)

	if not FREE_BUILD then
		coroutine_resume(PanicRoutine)
		coroutine_resume(WalkFlingRoutine)
		coroutine_resume(ItemAuraRoutine)
		coroutine_resume(KillAuraRoutine)
		coroutine_resume(ATMFarmRoutine)
		coroutine_resume(ThrowableAuraRoutine)
		-- coroutine_resume(AutoFinishRoutine)
		coroutine_resume(GunModsRoutine)
		coroutine_resume(AntiAimRoutine)
		coroutine_resume(ShelfStockRoutine)
		coroutine_resume(MeleeModsRoutine)
		coroutine_resume(AutoFishRoutine)
		coroutine_resume(ItemFilterRoutine)
		coroutine_resume(BumpAuraRoutine)
	end

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

	do
		local function SetupDroppedItemESP(Item: Model)
			local RootPart = Item:WaitForChild("PickUpZone", 1) :: Part?
			if not RootPart then
				return
			end

			local Box = ESP_Library.Drawings.Create3DBox()
			local Text = ESP_Library.Drawings.UseText()

			local Color = Color3.new(0, 1, 0)

			if Item.Name ~= "Money" then
				local ItemRarity
				local Reference

				pcall(function()
					Reference = ReplicatedStorage.Items[Item:GetAttribute("item_type")][Item.Name]
				end)

				if Reference then
					ItemRarity = Reference:GetAttribute("RarityName")
				else
					ItemRarity = "Common"
				end

				Color = Storage.RarityColors[ItemRarity] or Color3.fromRGB(255, 255, 255)
			end

			local Parts = {}

			for _, Part in next, Item:GetChildren() do
				if Part:IsA("BasePart") and Part.Name ~= "PickUpZone" then
					table.insert(Parts, Part)
				end
			end

			ESP_Library.Register(function()
				if G_Toggle("ESPDroppedItems") then
					local Camera = workspace.CurrentCamera
					local Distance = Camera and (Camera.CFrame.Position - RootPart.Position).Magnitude or 0

					local ComputedText = Item.Name

					if Item.Name == "Money" then
						local AmountBillboard = Item:FindFirstChild("AmountBillboardGui") :: BillboardGui
						if AmountBillboard then
							local AmountLabel = AmountBillboard:FindFirstChild("TextLabel") :: TextLabel
							if AmountLabel then
								ComputedText = "$" .. AmountLabel.Text:gsub("x", "")
							end
						end
					end

					Text:Update({
						Enabled = true,
						Text = ComputedText,
						Position = RootPart.Position + Vector3.new(0, 4, 0),
						Color = Color,
						Outline = true,
						Channel = "Custom",
						Distance = Distance,
					})

					local _, BoxSize = GetBoundingBox(Parts, RootPart:GetPivot().Rotation)

					Box:Update({
						Pivot = RootPart.CFrame,
						Size = BoxSize,
						Color = Color,
						Enabled = true,
						Channel = "Custom",
						Distance = Distance,
					})
				else
					Box:Update({ Enabled = false })
					Text:Update({ Enabled = false })
				end

				return true
			end, function()
				local Condition = (
					Item
					and Item.Parent
					and RootPart
					and RootPart.Parent
					and Item:IsDescendantOf(workspace)
				)
				if not Condition then
					-- print("Dropped item ESP condition failed for:", Item.Name)
					return false
				end
				return true
			end, function()
				-- print("Cleaning up dropped item ESP for:", Item.Name)
				Box:Destroy()
				Text:Destroy()
			end)

			print("Set up ESP for dropped item:", Item.Name)
		end

		Storage.Connections[_nextKey(Storage.Connections, "DroppedItems")] =
			Cleaner(workspace:WaitForChild("DroppedItems").ChildAdded:Connect(function(Item)
				if Item:IsA("Model") then
					SetupDroppedItemESP(Item)
				end
			end))

		for _, Item in next, workspace:WaitForChild("DroppedItems"):GetChildren() do
			if Item:IsA("Model") then
				SetupDroppedItemESP(Item)
			end
		end
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
		ItemView:Unload()
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
		EnableSidebarResize = true
	})

	local Tabs = {
		Main = Window:AddTab(T("Main"), "combine", T("General features and utilities")),
		Automation = Window:AddTab(T("Automation"), "git-compare-arrows", T("Automated jobs and tasks")),
	}

	if not FREE_BUILD and ORCHESTRATOR_MENU_ENABLED then
		Tabs.Orchestrator = Window:AddTab(T("Orchestrator"), "users", T("Control multiple clients remotely"))
	end

	local Tabs2 = {
		Combat = Window:AddTab(T("Combat"), "crosshair", T("Combat features and utilities")),
		Teleports = Window:AddTab(T("Teleports"), "milestone", T("Teleport locations and server utilities")),
		Visuals = Window:AddTab(T("Visuals"), "eye", T("Visual enhancements and effects")),
		InventoryViewer = Window:AddTab(T("Inventory Viewer"), "package-open", T("View and manage your inventory")),
		Settings = Window:AddTab(T("Settings"), "cog", T("Configure your preferences and settings")),
	}

	for Key, Tab in next, Tabs2 do
		Tabs[Key] = Tab
	end

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
		PurchaseSites:AddLabel("https://sasware.dev/donate")
		PurchaseSites:AddLabel(T("Or join the discord at:"))
		PurchaseSites:AddLabel("https://discord.gg/6qCymXqa2u")
	end

	-- Main tab

	local UtilitiesGroup = Tabs.Main:AddLeftGroupbox(T("Utilities"))

	UtilitiesGroup:AddButton({
		Text = T("Bring Car"),
		Func = function()
			for _, Vehicle in next, Vehicles:GetChildren() do
				if Vehicle:GetAttribute("OwnerUserId") == LocalUserId then
					local Character = AssertCharacter()
					Vehicle:PivotTo(Character:GetPivot() + Vector3.yAxis * 12)
					for _, Descendant in next, Vehicle:GetDescendants() do
						if Descendant:IsA("BasePart") then
							Descendant.AssemblyLinearVelocity = Vector3.zero
							Descendant.AssemblyAngularVelocity = Vector3.zero
						end
					end
					Sit(Vehicle:FindFirstChildOfClass("VehicleSeat"))
				end
			end
		end,
		Tooltip = T("Bring your car to you"),
		DisabledTooltip = T("Button is disabled in FREE_BUILD mode"),
		Disabled = FREE_BUILD,
	})

	UtilitiesGroup:AddButton({
		Text = T("Vehicle-Snap"),
		Func = function()
			local Character = AssertCharacter()
			local VehicleData = FindVehicle()

			if not VehicleData then
				return SafeNotify(T("You need a vehicle spawned to snap under the map."))
			end

			local Vehicle = VehicleData.Vehicle
			local Origin = Character:GetPivot()

			Vehicle:PivotTo(Character:GetPivot() + Vector3.yAxis * 12)
			for _, Descendant in next, Vehicle:GetDescendants() do
				if Descendant:IsA("BasePart") then
					Descendant.AssemblyLinearVelocity = Vector3.zero
					Descendant.AssemblyAngularVelocity = Vector3.zero
				end
			end
			Sit(Vehicle:FindFirstChildOfClass("VehicleSeat"), true)

			local Humanoid = Character:FindFirstChildOfClass("Humanoid")

			if Humanoid.SeatPart then
				Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				WaitForPing()

				-- Teleport the vehicle 10 studs below the origin and get into it.
				local VehicleSnapConnection
				VehicleSnapConnection = RunService.Heartbeat:Connect(function()
					if Vehicle and Vehicle.Parent then
						Vehicle:PivotTo(CFrame.new(Origin.Position - Vector3.yAxis * 10))
						for _, Descendant in next, Vehicle:GetDescendants() do
							if Descendant:IsA("BasePart") then
								Descendant.AssemblyLinearVelocity = Vector3.zero
								Descendant.AssemblyAngularVelocity = Vector3.zero
							end
						end
					else
						if VehicleSnapConnection then
							VehicleSnapConnection:Disconnect()
							VehicleSnapConnection = nil
						end
					end
				end)

				Sit(Vehicle:FindFirstChildOfClass("VehicleSeat"))
				WaitForPing()
				Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				WaitForPing()

				VehicleSnapConnection:Disconnect()
				Vehicle:PivotTo(Origin + Vector3.yAxis * 12)
			else
				return SafeNotify("Unable to get vehicle, can't snap.")
			end

			return nil
		end,
	})

	UtilitiesGroup:AddButton({
		Text = T("Randomize Avatar"),
		Func = function()
			local Character = AssertCharacter()
			-- Step 1. Delete all current accessories.
			SecureNet.Send(ArgumentChecks.Enter_Character_Creator.Value, Character:GetPivot())
			for _, Accessory in next, Character:GetChildren() do
				if Accessory:IsA("Accessory") then
					-- Find the accessory type
					local Type = nil
					for _, v in next, CharacterCreatorItems:GetDescendants() do
						if v.Name == Accessory.Name then
							Type = v.Parent.Name
							break
						end
					end
					if Type then
						SecureNet.Send(ArgumentChecks.Change_Accessory.Value, Type, Accessory.Name, false)
						task_wait(0.5)
					end
				end
			end

			-- Step 2. Equip a random accessory from each category.
			for _, Category in next, CharacterCreatorItems:GetChildren() do
				local RandomAccessory = Category:GetChildren()[math.random(1, #Category:GetChildren())]
				SecureNet.Send(ArgumentChecks.Change_Accessory.Value, Category.Name, RandomAccessory.Name, true)
				task_wait(0.5)
			end

			if not shared.GodMode then
				SecureNet.Send(ArgumentChecks.Leave_Character_Creator.Value)
			end
		end,
		Tooltip = T("Randomize your avatar accessories"),
		DisabledTooltip = T("Button is disabled in FREE_BUILD mode"),
		Disabled = FREE_BUILD,
	})

	if not LPH_OBFUSCATED then
		UtilitiesGroup:AddButton({
			Text = "Rollback",
			Func = function()
				local Character = AssertCharacter()
				SecureNet.Send(ArgumentChecks.Enter_Character_Creator.Value, Character:GetPivot())

				local Bomb = string.rep(
					[[
	Ǆ

	؁

	‱

	ஹ

	௸

	௵

	꧄

	.

	ဪ

	꧅

	⸻

	𒈙

	𒐫

	﷽


	𒌄

	𒈟

	𒍼

	𒁎

	𒀱

	𒌧

	𒅃 𒈓

	𒍙

	𒊎

	𒄡

	𒅌

	𒁏

	𒀰

	𒐪

	𒐩

	𒈙

	𒐫


	𱁬 84

	𰽔 76

	𪚥 64

	䨻 52

	龘 48

	䲜 44

	       á́́́́́́́́́́́́́́́́́́́́́́́́́́́́́
	̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺̺ͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩͩ 𓀐𓂸

	😃⃢👍༼;´༎ຶ ۝ ༎ຶ༽
	]],
					10000
				)

				local Categories = CharacterCreatorItems:GetChildren()
				local RandomCategory = Categories[math.random(1, #Categories)]
				local Items = RandomCategory:GetChildren()
				local RandomItem = Items[math.random(1, #Items)]

				print("Equipping random item from random category:", RandomCategory.Name, RandomItem.Name)
				SecureNet.Send(
					ArgumentChecks.Change_Accessory.Value,
					RandomCategory.Name .. "\0" .. tostring(math.random()) .. tostring(math.random()) .. Bomb,
					RandomItem.Name,
					true
				)

				if not shared.GodMode then
					SecureNet.Send(ArgumentChecks.Leave_Character_Creator.Value)
				end
			end,
			Tooltip = "Randomize your avatar accessories",
			DisabledTooltip = "Button is disabled in FREE_BUILD mode",
			Disabled = FREE_BUILD,
		})
	end

	UtilitiesGroup:AddButton({
		Text = T("Redeem all quests"),
		Func = function()
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local QuestsData = ReplicatedStorage.Modules.Game.Quests.QuestsData
			local AllQuestIds, MilestoneModules = {}, QuestsData.Milestones:GetChildren()
			local MaxQuestChain = 0

			for _, MilestoneModule in next, MilestoneModules do
				local QuestTbl = SafeRequire(MilestoneModule)
				local NumQuestsInMilestone = 0
				for QuestIndex, _ in next, QuestTbl do
					table.insert(AllQuestIds, MilestoneModule.Name .. "_" .. tostring(QuestIndex))
					NumQuestsInMilestone = NumQuestsInMilestone + 1
				end
				MaxQuestChain = math_max(MaxQuestChain, NumQuestsInMilestone)
			end

			for Pass = 1, MaxQuestChain do
				for _, QuestId in next, AllQuestIds do
					pcall(SecureNet.Get, ArgumentChecks.Claim_Quest.Value, QuestId) -- player_completed_quest
				end
			end
		end,
	})

	UtilitiesGroup:AddDivider()

	UtilitiesGroup:AddToggle("AutoLock", {
		Text = T("Auto-Lock Vehicle"),
		Default = false,
		Tooltip = T("Automatically locks your vehicle when you enter it."),
	})

	UtilitiesGroup:AddToggle("InfiniteHotbar", {
		Text = T("No Hotbar Limit"),
		Default = false,
		Tooltip = T("Removes the hotbar item limit."),
		Disabled = FREE_BUILD,
		DisabledTooltip = T("Button is disabled in FREE_BUILD mode"),
	})

	UtilitiesGroup:AddToggle("Anonymizer", {
		Text = T("Anonymize Name"),
		Default = false,
		Tooltip = T("Hides your name (Your screen only!)"),
		Callback = function(Value)
			if not Value then
				local Character = AssertCharacter()
				local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart") :: Part
				local Name =
					HumanoidRootPart:WaitForChild("CharacterBillboardGui"):WaitForChild("PlayerName") :: TextLabel
				local Level = Name:WaitForChild("LevelImage"):WaitForChild("LevelText") :: TextLabel

				Name.Text = LocalPlayer.Name
				Level.Text = tostring(LocalPlayer:GetAttribute("level"))
			end
		end,
	})

	UtilitiesGroup:AddToggle("SkipSpinAnimation", {
		Text = T("Skip Spin Animation"),
		Default = false,
		Tooltip = T("Skips the crate spin animation"),
	})

	UtilitiesGroup:AddToggle("PromptSkip", {
		Text = T("Faster Prompts"),
		Default = false,
		Tooltip = T("Makes prompts slightly faster."),
	})

	UtilitiesGroup:AddToggle("NoUIDelays", {
		Text = T("No UI Delays"),
		Default = false,
		Tooltip = T("Removes delays from certain UIs."),
		Disabled = FREE_BUILD,
		DisabledTooltip = T("Button is disabled in FREE_BUILD mode"),
	})

	UtilitiesGroup:AddToggle("ATM_Aura", {
		Text = T("Auto-Hack ATMs"),
		Default = false,
		Tooltip = T("Hacks ATMs for you once you start the hack."),
		Disabled = not (AssertArgument("Request") and AssertArgument("Win")),
	})

	UtilitiesGroup:AddToggle("VProt", {
		Text = T("V-Prot"),
		Default = false,
		Tooltip = T("Uses your vehicle to fling nearby players. Must be sitting in a vehicle before enabling."),
		Disabled = FREE_BUILD,
		Risky = true,
		Callback = function(Value)
			-- print("VProt", Value)
			if Value then
				local Character = AssertCharacter()
				local VehicleData = FindVehicle()
				if VehicleData then
					-- print("VProt: Found vehicle")
					local Vehicle = VehicleData.Vehicle
					local VehicleSeat = Vehicle:FindFirstChildOfClass("VehicleSeat") :: VehicleSeat

					if VehicleSeat then
						-- print("VProt: Found vehicle seat")
						Sit(VehicleSeat)
						task_wait(1)
						Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						task_wait(1)

						local Flip = 1

						while RunService.Heartbeat:Wait() and G_Toggle("VProt") do
							Flip -= 1

							for _, Descendant in next, Vehicle:GetDescendants() do
								if
									Descendant:IsA("HingeConstraint")
									or Descendant:IsA("SpringConstraint")
									or Descendant:IsA("RodConstraint")
								then
									Descendant.Enabled = false
								end
							end

							local Chassis = Vehicle:FindFirstChild("Chassis") :: BasePart
							for _, Model: Model in next, Vehicle:GetChildren() do
								if Model:IsA("Model") and Model ~= Chassis then
									Model:PivotTo(Chassis:GetPivot())
								end
							end

							local Wheels = Vehicle:FindFirstChild("Wheels") :: Model
							if Wheels then
								for _, Wheel: Part in next, Wheels:GetChildren() do
									Wheel.CFrame = Chassis.CFrame
								end
							end

							for _, Descendant in next, Vehicle:GetDescendants() do
								if Descendant:IsA("BasePart") then
									Descendant.AssemblyLinearVelocity = Vector3.zAxis * 100 * Flip
									Descendant.AssemblyAngularVelocity = Vector3.new(255, 0, 0)
									Descendant.CanQuery = false
									if not Descendant:GetAttribute("OldCanCollide") then
										Descendant:SetAttribute("OldCanCollide", Descendant.CanCollide)
									end
									Descendant.CanCollide = false
								end
							end

							-- Teleport the vehicle to the closest player within 15 studs
							local ClosestPlayer = nil
							local ClosestDistance = math.huge

							for _, Player in next, Players:GetPlayers() do
								if Player ~= LocalPlayer and Player.Character then
									local Distance = (
										Player.Character:GetPivot().Position - Character:GetPivot().Position
									).Magnitude
									if Distance < ClosestDistance and Distance < 15 then
										ClosestDistance = Distance
										ClosestPlayer = Player
									end
								end
							end

							if ClosestPlayer then
								Chassis:PivotTo(
									CFrame.new(ClosestPlayer.Character:GetPivot().Position)
											* Vehicle:GetPivot().Rotation
										+ (ClosestPlayer.Character.HumanoidRootPart.Velocity / 3)
								)
							else
								Chassis:PivotTo(
									CFrame.new(Character:GetPivot().Position - Vector3.yAxis * 20)
										* Vehicle:GetPivot().Rotation
								)
							end
						end
					end
				end
			else
				-- Restore vehicle parts
				local VehicleData = GetVehicle()
				local Character = AssertCharacter()
				if VehicleData then
					local Vehicle = VehicleData.Vehicle
					for _, Descendant in next, Vehicle:GetDescendants() do
						if Descendant:IsA("BasePart") then
							Descendant.CanQuery = true
							Descendant.AssemblyLinearVelocity = Vector3.zero
							Descendant.AssemblyAngularVelocity = Vector3.zero
							if Descendant:GetAttribute("OldCanCollide") then
								Descendant.CanCollide = Descendant:GetAttribute("OldCanCollide")
								Descendant:SetAttribute("OldCanCollide", nil)
							end
						end
					end

					Vehicle:PivotTo(Character:GetPivot() + Vector3.yAxis * 12)
				end
			end
		end,
	})

	UtilitiesGroup:AddDivider()

	UtilitiesGroup:AddToggle("ItemAura", {
		Text = T("Item Aura"),
		Default = false,
		Tooltip = T("Gives you priority on picking up items."),
		Disabled = FREE_BUILD,
	})

	UtilitiesGroup:AddDropdown("ItemAuraRarities", {
		Text = T("Item Aura Rarity"),
		Tooltip = T("Select the rarity of items to prioritize."),
		Values = {
			"Common",
			"Uncommon",
			"Rare",
			"Epic",
			"Legendary",
			"Omega",
		},
		Multi = true,
		Default = { "Rare", "Epic", "Legendary", "Omega" },
	})

	local CharacterGroup = Tabs.Main:AddRightGroupbox(T("Character"))

	CharacterGroup:AddToggle(T("Desync"), {
		Text = T("Desync"),
		Default = false,
		Callback = function(Value)
			if Value then
				SafeNotify(T("Enabling desync..."), 0.5)
				setfflag("NextGenReplicatorEnabledWrite4", "true")
				task.wait(0.5)
				SafeReset()
				SafeNotify(T("Desynced!"), 3)

				task.spawn(function()
					while G_Toggle("Desync") do
						task.wait()
						-- Check if the player is seated
						local Character = AssertCharacter()
						local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
						if Humanoid.SeatPart then
							SafeNotify(T("Desync disabled when seated!"), 3)
							Library.Toggles.Desync:Set(false)
							break
						end
					end
				end)
			else
				setfflag("NextGenReplicatorEnabledWrite4", "false")

				local Character = AssertCharacter()
				local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
				if not Humanoid.SeatPart then
					-- Find a random seat
					local Seats = {}
					for _, v in next, workspace.Map.Tiles:GetDescendants() do
						if v:IsA("Seat") then
							table.insert(Seats, v)
						end
					end

					local RandomSeat: Seat = Seats[math.random(1, #Seats)]
					if RandomSeat then
						RandomSeat:Sit(AssertCharacter():FindFirstChildOfClass("Humanoid"))
						task.wait(0.5)
						AssertCharacter():FindFirstChildOfClass("Humanoid").Jump = true
						task.wait(1)
						AssertCharacter():FindFirstChildOfClass("Humanoid").Sit = true
						task.wait(0.5)
						AssertCharacter():FindFirstChildOfClass("Humanoid").Jump = true
					end
				end

				SafeNotify(T("Resynced!"), 3)
			end
		end,
		Tooltip = T("Prevents your position from replicating to other players"),
		DisabledTooltip = T("Button is disabled in FREE_BUILD mode"),
		Disabled = FREE_BUILD,
	})

	CharacterGroup:AddToggle("Snap", {
		Text = T("Snap"),
		Default = false,
		Tooltip = T("Snaps your character under the map to collect items."),
		Risky = true,
	}):AddKeyPicker("Snap", {
		Default = "Q",
		SyncToggleState = true,
		Mode = "Toggle",
		Text = T("Toggle Snap"),
		NoUI = false,
	})

	CharacterGroup:AddSlider("SnapOffsetY", {
		Text = T("Snap Y-Offset"),
		Default = 5,
		Min = 5,
		Max = 50,
		Rounding = 1,
		Tooltip = T("Sets how far below the map you snap."),
	})

	CharacterGroup:AddToggle("Anti-Aimbot", {
		Text = T("Anti-Aimbot"),
		Default = false,
		Tooltip = T("Spoofs your velocity to prevent aimbots from hitting you."),
	}):AddKeyPicker("Anti-Aimbot", {
		Default = "T",
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
		Disabled = FREE_BUILD,
	}):AddKeyPicker("WalkFling", {
		Default = "Z",
		SyncToggleState = true,
		Mode = "Toggle",
		Text = T("Toggle Walk-Fling"),
		NoUI = false,
	})

	CharacterGroup:AddToggle("Anti-Ragdoll", {
		Text = T("Anti-Ragdoll"),
		Default = false,
		Tooltip = T("Prevents you from being ragdolled."),
		Disabled = FREE_BUILD,
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
				-- local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart") :: BasePart

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

				-- HumanoidRootPart.Size = HumanoidRootPart.Size * Vector3.new(1, 0, 1) + Vector3.new(0, 2, 0)

				SecureNet.Get(ArgumentChecks.Fix_Desync_Hip_Height.Value)
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
		Disabled = FREE_BUILD,
	}):AddKeyPicker("Invisibility", {
		Default = "X",
		SyncToggleState = true,
		Mode = "Toggle",
		Text = T("Toggle Invisibility"),
		NoUI = false,
	})

	CharacterGroup:AddToggle("AutoRespawn", {
		Text = T("Auto-Respawn"),
		Default = true,
		Tooltip = T("Automatically respawns you."),
	})

	CharacterGroup:AddToggle("Panic", {
		Text = T("Item-Saver [Anti-Kill]"),
		Default = false,
		Tooltip = T("Attempts to prevent you from being killed"),
		Risky = true,
		Disabled = FREE_BUILD,
	})

	CharacterGroup:AddToggle("NoSlow", {
		Text = T("No Slowdown"),
		Default = false,
		Tooltip = T("Disables slowdowns"),
		Disabled = FREE_BUILD,
	})

	CharacterGroup:AddToggle("InfiniteStamina", {
		Text = T("Infinite Sprint"),
		Default = false,
		Tooltip = T("Allows you to sprint indefinitely"),
	})

	CharacterGroup:AddToggle("SprintTakesNoStamina", {
		Text = T("Stamina-Free Sprint"),
		Default = false,
		Tooltip = T("Sprinting won't take any stamina; No XP gained."),
	})

	CharacterGroup:AddSlider("SpeedBoost", {
		Text = T("Speed Boost"),
		Default = 0,
		Min = 0,
		Max = 10,
		Rounding = 1,
		Tooltip = T("Sets the player speed"),
	})

	local VehicleModSystem
	VehicleModSystem = {
		AttributeInfos = Storage.Vehicle_Attributes,
		TorqueAttributes = { "maxSpeedTorque", "minSpeedTorque" },
		AttributeCache = setmetatable({}, { __mode = "k" }),
		ChassisCache = setmetatable({}, { __mode = "k" }),
		LastVehicle = nil,
	}
	Storage.VehicleModSystem = VehicleModSystem

	function VehicleModSystem:GetLibrary()
		return getgenv().Library
	end

	function VehicleModSystem:GetToggleValue(toggleName: string): boolean
		local library = self:GetLibrary()
		local toggles = library and library.Toggles
		local toggle = toggles and toggles[toggleName]
		if toggle and toggle.Value ~= nil then
			return toggle.Value == true
		end
		return false
	end

	function VehicleModSystem:GetOptionValue(optionName: string)
		local library = self:GetLibrary()
		local options = library and library.Options
		local option = options and options[optionName]
		if option then
			return option.Value
		end
		return nil
	end

	local function getDefaultPhysicalSnapshot(part: BasePart)
		return {
			hadCustom = false,
			density = nil,
			densityFallback = 1,
			friction = 0.3,
			elasticity = 0,
			frictionWeight = 1,
			elasticityWeight = 1,
		}
	end

	function VehicleModSystem:CaptureChassisState(chassis: BasePart)
		local current = chassis.CustomPhysicalProperties
		if current then
			return {
				hadCustom = true,
				density = current.Density,
				friction = current.Friction,
				elasticity = current.Elasticity,
				frictionWeight = current.FrictionWeight,
				elasticityWeight = current.ElasticityWeight,
				densityFallback = current.Density,
			}
		end
		return getDefaultPhysicalSnapshot(chassis)
	end

	function VehicleModSystem:RestoreChassisState(chassis: BasePart, cache: any)
		if not cache then
			return
		end
		if cache.hadCustom and cache.density then
			chassis.CustomPhysicalProperties = PhysicalProperties.new(
				cache.density,
				cache.friction,
				cache.elasticity,
				cache.frictionWeight,
				cache.elasticityWeight
			)
		else
			local ok = pcall(function()
				(chassis :: any).CustomPhysicalProperties = nil
			end)
			if not ok then
				local density = cache.density or cache.densityFallback or 1
				chassis.CustomPhysicalProperties = PhysicalProperties.new(
					density,
					cache.friction,
					cache.elasticity,
					cache.frictionWeight,
					cache.elasticityWeight
				)
			end
		end
	end

	local function isInstance(value: any): boolean
		return typeof(value) == "Instance"
	end

	function VehicleModSystem:IsInstanceValid(instance: Instance?): boolean
		if instance == nil then
			return false
		end
		return isInstance(instance) and instance.Parent ~= nil
	end

	function VehicleModSystem:StoreOriginal(instance: Instance, attrName: string, value: any)
		if not self:IsInstanceValid(instance) then
			return
		end
		local cache = self.AttributeCache[instance]
		if not cache then
			cache = {}
			self.AttributeCache[instance] = cache
		end
		if cache[attrName] == nil then
			cache[attrName] = value
		end
	end

	function VehicleModSystem:ApplyAttributeFolder(folder: Folder)
		if not self:IsInstanceValid(folder) then
			return
		end

		local speedMultiplier = self:GetOptionValue("VehicleMods_MaxSpeedMultiplier")
		if type(speedMultiplier) ~= "number" then
			speedMultiplier = 1
		end
		if speedMultiplier < 0 then
			speedMultiplier = 1
		end
		for _, info in ipairs(self.AttributeInfos) do
			local attrName = info.Name
			local currentValue = folder:GetAttribute(attrName)
			if currentValue ~= nil then
				self:StoreOriginal(folder, attrName, currentValue)
				local newValue = self:GetOptionValue("VehicleMods_" .. attrName)
				if newValue ~= nil then
					folder:SetAttribute(attrName, newValue)
				end
			end
		end

		local torqueMultiplier = self:GetOptionValue("VehicleMods_TorqueMultiplier")
		if torqueMultiplier == nil then
			torqueMultiplier = 1
		end
		for _, attrName in ipairs(self.TorqueAttributes) do
			local currentValue = folder:GetAttribute(attrName)
			if currentValue ~= nil then
				self:StoreOriginal(folder, attrName, currentValue)
				local original = self.AttributeCache[folder] and self.AttributeCache[folder][attrName]
				if type(original) == "number" and type(torqueMultiplier) == "number" then
					folder:SetAttribute(attrName, original * torqueMultiplier)
				end
			end
		end

		local forwardMaxSpeed = folder:GetAttribute("forwardMaxSpeed")
		if type(forwardMaxSpeed) == "number" then
			self:StoreOriginal(folder, "forwardMaxSpeed", forwardMaxSpeed)
			local cache = self.AttributeCache[folder]
			local original = cache and cache.forwardMaxSpeed
			if type(original) ~= "number" then
				original = forwardMaxSpeed
				if cache then
					cache.forwardMaxSpeed = original
				end
			end
			folder:SetAttribute("forwardMaxSpeed", original * speedMultiplier)
		end
	end

	function VehicleModSystem:ApplyAttributeModifiers(vehicle: Model)
		for _, child in ipairs(vehicle:GetChildren()) do
			if child:IsA("Folder") then
				self:ApplyAttributeFolder(child)
			end
		end
	end

	function VehicleModSystem:ApplySlamModifier(vehicle: Model)
		local chassis = vehicle:FindFirstChild("Chassis")
		if not (chassis and chassis:IsA("BasePart")) then
			return
		end
		if self:GetToggleValue("VehicleSlam") then
			if not self.ChassisCache[chassis] then
				self.ChassisCache[chassis] = self:CaptureChassisState(chassis)
			end
			local cache = self.ChassisCache[chassis] or getDefaultPhysicalSnapshot(chassis)
			local friction = cache.friction or 0.3
			local elasticity = cache.elasticity or 0
			local frictionWeight = cache.frictionWeight or 1
			local elasticityWeight = cache.elasticityWeight or 1
			chassis.CustomPhysicalProperties = PhysicalProperties.new(50, friction, elasticity, frictionWeight, elasticityWeight)
		else
			local cache = self.ChassisCache[chassis]
			if cache then
				self:RestoreChassisState(chassis, cache)
				self.ChassisCache[chassis] = nil
			end
		end
	end

	function VehicleModSystem:PruneCache()
		for instance in pairs(self.AttributeCache) do
			if not self:IsInstanceValid(instance) then
				self.AttributeCache[instance] = nil
			end
		end
		for instance in pairs(self.ChassisCache) do
			if not self:IsInstanceValid(instance) then
				self.ChassisCache[instance] = nil
			end
		end
	end

	function VehicleModSystem:RestoreSlam()
		for chassis, cache in pairs(self.ChassisCache) do
			if self:IsInstanceValid(chassis) then
				self:RestoreChassisState(chassis, cache)
			end
			self.ChassisCache[chassis] = nil
		end
	end

	function VehicleModSystem:RevertVehicle(vehicle: Model?)
		for instance, attrMap in pairs(self.AttributeCache) do
			local shouldRevert = (not vehicle)
				or (self:IsInstanceValid(instance) and instance:IsDescendantOf(vehicle))
			if shouldRevert then
				if self:IsInstanceValid(instance) then
					for attrName, originalValue in pairs(attrMap) do
						pcall(instance.SetAttribute, instance, attrName, originalValue)
					end
				end
				self.AttributeCache[instance] = nil
			end
		end
		for chassis, cache in pairs(self.ChassisCache) do
			local shouldRevert = (not vehicle)
				or (self:IsInstanceValid(chassis) and chassis:IsDescendantOf(vehicle))
			if shouldRevert then
				if self:IsInstanceValid(chassis) then
					self:RestoreChassisState(chassis, cache)
				end
				self.ChassisCache[chassis] = nil
			end
		end
	end

	function VehicleModSystem:Reset()
		self:RevertVehicle(nil)
		self.LastVehicle = nil
	end

	function VehicleModSystem:Step()
		self:PruneCache()
		if not self:GetToggleValue("VehicleModificationEnabled") then
			if self.LastVehicle then
				self:RevertVehicle(self.LastVehicle)
				self.LastVehicle = nil
			end
			self:RevertVehicle(nil)
			return
		end

		local vehicleData = FindVehicle()
		local vehicle = vehicleData and vehicleData.Vehicle
		if not (vehicle and vehicle.Parent) then
			if self.LastVehicle then
				self:RevertVehicle(self.LastVehicle)
				self.LastVehicle = nil
			end
			return
		end

		if self.LastVehicle and self.LastVehicle ~= vehicle then
			self:RevertVehicle(self.LastVehicle)
		end

		self.LastVehicle = vehicle
		self:ApplyAttributeModifiers(vehicle)
		self:ApplySlamModifier(vehicle)
	end

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
		Callback = function(Value)
			if not Value then
				VehicleModSystem:Reset()
				if Library and Library.Toggles and Library.Toggles.VehicleSlam then
					Library.Toggles.VehicleSlam:SetValue(false)
				end
			else
				VehicleModSystem:Step()
			end
		end,
	})

	VehicleModificationsGroup:AddToggle("VehicleSlam", {
		Text = T("Slammed Vehicle"),
		Default = false,
		Tooltip = T("Makes your chassis slammed to the ground, prevents rolling."),
		Callback = function(Value)
			if not Value then
				VehicleModSystem:RestoreSlam()
			else
				VehicleModSystem:Step()
			end
		end,
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
			})
		end
	end

	VehicleModificationsGroup:AddSlider("VehicleMods_TorqueMultiplier", {
		Text = T("Torque Multiplier"),
		Default = 1,
		Min = 0,
		Max = 5,
		Rounding = 2,
		Tooltip = T("Sets the Torque Multiplier for vehicles"),
	})

	VehicleModificationsGroup:AddSlider("VehicleMods_MaxSpeedMultiplier", {
		Text = T("Max Speed Multiplier"),
		Default = 1,
		Min = 1,
		Max = 1.3,
		Rounding = 2,
		Tooltip = T("Scales a vehicle's maximum forward speed"),
	})

	Storage.Routines[_nextKey(Storage.Routines, "VehicleModSystemTick")] = Cleaner(task_spawn(function()
		while task_wait(0.25) do
			VehicleModSystem:Step()
		end
	end))

	Storage.Routines[_nextKey(Storage.Routines, "UI_Update_VehicleMods")] = Cleaner(task_spawn(function()
		while task_wait(.5) do
			if G_Toggle("VehicleModificationEnabled") then
				local VehicleData = FindVehicle()
				if VehicleData then
					local Vehicle = VehicleData.Vehicle
					
					task.spawn(function()
						for _, Child in next, Vehicle:GetChildren() do
							if Child:IsA("Folder") then
								for Attribute, _ in next, Child:GetAttributes() do
									-- Check if this is one of the targetted attributes
									for _, VehicleAttribute in next, Storage.Vehicle_Attributes do
										if Attribute == VehicleAttribute.Name then
											Child:SetAttribute(
												Attribute,
												G_Option("VehicleMods_" .. VehicleAttribute.Name)
											)
										end
									end

									if Attribute == "maxSpeedTorque" then
										if not Child:GetAttribute("OldmaxSpeedTorque") then
											Child:SetAttribute("OldmaxSpeedTorque", Child:GetAttribute("maxSpeedTorque"))
										end

										Child:SetAttribute(
											"maxSpeedTorque",
											Child:GetAttribute("OldmaxSpeedTorque")
												* G_Option("VehicleMods_TorqueMultiplier")
										)
									elseif Attribute == "minSpeedTorque" then
										if not Child:GetAttribute("OldminSpeedTorque") then
											Child:SetAttribute("OldminSpeedTorque", Child:GetAttribute("minSpeedTorque"))
										end

										Child:SetAttribute(
											"minSpeedTorque",
											Child:GetAttribute("OldminSpeedTorque")
												* G_Option("VehicleMods_TorqueMultiplier")
										)
									elseif Attribute == "forwardMaxSpeed" then
										if not Child:GetAttribute("OldforwardMaxSpeed") then
											Child:SetAttribute("OldforwardMaxSpeed", Child:GetAttribute("forwardMaxSpeed"))
										end

										local baseSpeed = Child:GetAttribute("OldforwardMaxSpeed")
										if typeof(baseSpeed) == "number" then
											Child:SetAttribute(
												"forwardMaxSpeed",
												baseSpeed * G_Option("VehicleMods_MaxSpeedMultiplier")
											)
										end
									end
								end
							end
						end
					end)

					local Chassis = Vehicle:FindFirstChild("Chassis") :: BasePart
					if Chassis then
						if G_Toggle("VehicleSlam") then
							if Chassis.CustomPhysicalProperties.Density ~= 50 then
								-- print('setting density to 50')
								Chassis:SetAttribute("OldDensity", Chassis.CustomPhysicalProperties.Density)
								Chassis.CustomPhysicalProperties = PhysicalProperties.new(
									50,
									Chassis.CustomPhysicalProperties.Friction,
									Chassis.CustomPhysicalProperties.Elasticity,
									Chassis.CustomPhysicalProperties.FrictionWeight,
									Chassis.CustomPhysicalProperties.ElasticityWeight
								)
							end
						else
							if Chassis:GetAttribute("OldDensity") then
								-- print('restoring density to', Chassis:GetAttribute("OldDensity"))
								if Chassis:GetAttribute("OldDensity") then
									Chassis.CustomPhysicalProperties = PhysicalProperties.new(
										Chassis:GetAttribute("OldDensity"),
										Chassis.CustomPhysicalProperties.Friction,
										Chassis.CustomPhysicalProperties.Elasticity,
										Chassis.CustomPhysicalProperties.FrictionWeight,
										Chassis.CustomPhysicalProperties.ElasticityWeight
									)
									Chassis:SetAttribute("OldDensity", nil)
								end
							end
						end
					end

				end
			end
		end
	end))

	-- Automation tab

	local MoneyStateGroup = Tabs.Automation:AddLeftGroupbox(T("Money"))

	local CashLabel = MoneyStateGroup:AddLabel("CashLabel", {
		Text = T("Cash: $N/A (Waiting for data)"),
	})

	local BankLabel = MoneyStateGroup:AddLabel("BankLabel", {
		Text = T("Bank: $N/A (Waiting for data)"),
	})

	Storage.Routines[_nextKey(Storage.Routines, "UI_Update_CashBankLabels")] = Cleaner(task_spawn(function()
		while task_wait(1) do
			local Cash, Bank = Inventory.GetMoney()
			CashLabel:SetText(`Cash: ${Cash}`)
			BankLabel:SetText(`Bank: ${Bank}`)
		end
	end))

	local AutomationStateGroup = Tabs.Automation:AddLeftGroupbox(T("Status"))

	AutomationStateGroup:AddLabel("AutofarmTypeLabel", {
		Text = T("Type: None"),
	})

	AutomationStateGroup:AddLabel("AutofarmStatusLabel", {
		Text = T("Active: False"),
	})

	AutomationStateGroup:AddLabel("AutofarmRoutineLabel", {
		Text = T("Routine: N/A"),
	})

	AutomationStateGroup:AddLabel("AutofarmCooldownLabel", {
		Text = T("ATM Cooldown: N/A"),
	})

	AutomationStateGroup:AddLabel("AutofarmTeleportCountdownLabel", {
		Text = T("Server-Hopping in: N/A"),
	})

	Storage.Routines[_nextKey(Storage.Routines, "UI_Update_AutofarmStatus")] = Cleaner(task_spawn(function()
		while task_wait() do
			-- If we're not ATM-Farming, stop counting down the auto hop counter.
			if not G_Toggle("ATMFarm") then
				START_TIME = os.clock()
			end

			local AutofarmType = "None"

			if G_Toggle("CookFarm") then
				AutofarmType = "Cook"
			elseif G_Toggle("ATMFarm") then
				AutofarmType = "ATM"
			end

			Library.Labels.AutofarmTypeLabel:SetText(`Type: {AutofarmType}`)
			Library.Labels.AutofarmStatusLabel:SetText(`Active: {AutofarmType ~= "None" and "True" or "False"}`)
			Library.Labels.AutofarmCooldownLabel:SetText(
				`ATM Cooldown: {math_max(5 - (os.clock() - Storage.LastHackedATM), 0)}`
			)
			local remainingSeconds = math_max(0, AUTO_HOP_INTERVAL - (os.clock() - START_TIME))
			local minutes = math_floor(remainingSeconds / 60)
			local seconds = math_floor(remainingSeconds % 60)
			Library.Labels.AutofarmTeleportCountdownLabel:SetText(
				string.format("Server-Hopping in: %dm %ds", minutes, seconds)
			)
		end
	end))

	local AutomationGroup = Tabs.Automation:AddRightGroupbox(T("Automation"))

	AutomationGroup:AddDropdown("SelectedAutofarm", {
		Text = T("Farm Method"),
		Tooltip = T("Select Auto-Farm method."),
		Values = {
			"ATM Hacking",
			"Shelf Stocking",
			"Steak Cooking",
			"Fishing",
		},
		Multi = false,
		Default = 1,
	})

	AutomationGroup:AddToggle("StaminaFarm", {
		Text = T("Stamina-Farm"),
		Default = false,
		Tooltip = T("Uses stamina while farming."),
	})

	--#region ATM Hacker options

	local ATM_Hacker_Depbox = AutomationGroup:AddDependencyBox(T("ATM Hacking"))
	ATM_Hacker_Depbox:SetupDependencies({
		{ Library.Options.SelectedAutofarm, "ATM Hacking" },
	})

	ATM_Hacker_Depbox:AddToggle("ATMFarm", {
		Text = T("Enabled"),
		Default = false,
		Tooltip = T("Automatically robs ATMs"),
		Disabled = not (AssertArgument("Request") and AssertArgument("Win") and AssertArgument("Sprint")) or FREE_BUILD,
	})

	ATM_Hacker_Depbox:AddDivider()
	ATM_Hacker_Depbox:AddLabel("Options")

	ATM_Hacker_Depbox:AddSlider("HackFinishDelay", {
		Text = T("Hack Finish Delay"),
		Default = 1,
		Min = 1,
		Max = 5,
		Rounding = 1,
		Tooltip = T("Sets the delay before finishing the hack on an ATM"),
		Disabled = not (AssertArgument("Request") and AssertArgument("Win") and AssertArgument("Sprint")) or FREE_BUILD,
	})

	ATM_Hacker_Depbox:AddToggle("ATMFarmOverheadCamera", {
		Text = T("Overhead Camera"),
		Default = true,
		Tooltip = T("Switches to an over-head perspective."),
		Disabled = not (AssertArgument("Request") and AssertArgument("Win") and AssertArgument("Sprint")) or FREE_BUILD,
	})

	ATM_Hacker_Depbox:AddToggle("AutoShiesty", {
		Text = T("Auto-Mask"),
		Default = true,
		Tooltip = T("Automatically buys a Mask when at purchase routine."),
		Disabled = not (AssertArgument("Request") and AssertArgument("Win") and AssertArgument("Sprint")) or FREE_BUILD,
	})

	ATM_Hacker_Depbox:AddToggle("ATMFarmDynamicRerouting", {
		Text = T("Dynamic Rerouting"),
		Default = true,
		Tooltip = T("Automatically recalculates path if a closer ATM is found midway."),
		Disabled = not (AssertArgument("Request") and AssertArgument("Win") and AssertArgument("Sprint")) or FREE_BUILD,
	})

	ATM_Hacker_Depbox:AddToggle("ATMFarmUsePath", {
		Text = T("Use Pathfinding"),
		Default = true,
		Tooltip = T("Uses pathfinding to navigate to ATMs"),
		Disabled = not (AssertArgument("Request") and AssertArgument("Win") and AssertArgument("Sprint")) or FREE_BUILD,
	})

	ATM_Hacker_Depbox:AddToggle("AvoidWaitingAtATMs", {
		Text = T("Avoid Waiting at ATMs"),
		Default = false,
		Tooltip = T("Dynamically adjusts your teleport speed so that you arrive at the ATM just in time."),
		Disabled = not (AssertArgument("Request") and AssertArgument("Win") and AssertArgument("Sprint")) or FREE_BUILD,
	})

	ATM_Hacker_Depbox:AddToggle("SpeedRamp", {
		Text = T("Speed Ramp"),
		Default = true,
		Tooltip = T("Gradually increases speed at start of teleport to prevent detections."),
		Disabled = not (AssertArgument("Request") and AssertArgument("Win") and AssertArgument("Sprint")) or FREE_BUILD,
	})

	ATM_Hacker_Depbox:AddToggle("ATMFarmDefensive", {
		Text = T("Defensive Mode"),
		Default = true,
		Tooltip = T("Prevents you from being hit while robbing ATMs"),
		Disabled = FREE_BUILD,
		Callback = function(Value)
			if Value then
				Library.Toggles.ATMFarmOffensive:SetValue(Library.Toggles.ATMFarmOffensive.Value and not Value)
			end
		end,
	})

	ATM_Hacker_Depbox:AddToggle("ATMFarmOffensive", {
		Text = T("Offensive Mode"),
		Default = false,
		Tooltip = T("Actively attacks players that get near you"),
		Disabled = FREE_BUILD,
		Callback = function(Value)
			if Value then
				Library.Toggles.ATMFarmDefensive:SetValue(Library.Toggles.ATMFarmDefensive.Value and not Value)
			end
		end,
	})

	ATM_Hacker_Depbox:AddToggle("AutoSelectHackTool", {
		Text = T("Auto-Select Hack Tool"),
		Default = true,
		Tooltip = T("Automatically selects the best hack tool for the job."),
		Disabled = not (AssertArgument("Request") and AssertArgument("Win") and AssertArgument("Sprint")) or FREE_BUILD,
	})

	ATM_Hacker_Depbox:AddDropdown("HackTool", {
		Text = T("Hack Tool"),
		Default = "HackToolBasic",
		Values = { "HackToolBasic", "HackToolPro", "HackToolUltimate", "HackToolQuantum" },
		Tooltip = T("Sets the hack tool to use"),
	})

	ATM_Hacker_Depbox:AddSlider("ATMHackToolPurchaseCap", {
		Text = T("Max Hack Tools / Trip"),
		Default = 4,
		Min = 1,
		Max = 12,
		Rounding = 0,
		Tooltip = T("Limits how many hack tools the script buys at once to preserve inventory space."),
	})

	local AutoSelectHackToolRoutine = Cleaner(coroutine_create(function()
		setthreadcontext(8)

		-- Wait for the modules to be available
		local StockTimes = SafeRequire(ReplicatedStorage.Modules.Game.StockTimes)
		local ConsumableItemsInfo = ReplicatedStorage:WaitForChild("ConsumableItemsInfo")

		-- Helper function to find a product instance across all shop folders
		local function findProductInstance(productName)
			for _, shopFolder in ipairs(ConsumableItemsInfo:GetChildren()) do
				if shopFolder:IsA("Folder") then
					local product = shopFolder:FindFirstChild(productName)
					if product then
						return product
					end
				end
			end
			return nil
		end

		local function CheckProductStock(productName): (boolean, number)
			local product = findProductInstance(productName)

			if not product then
				warn("CheckProductStock: Could not find product with name '" .. productName .. "'")
				return false, 0
			end

			-- Get the stock info from the product's attributes
			local stockJson = product:GetAttribute("stock")
			if not stockJson then
				-- This item does not have stock functionality, so it's always available.
				return true, math.huge
			end

			-- Decode the JSON string to get stock parameters
			local success, stockData = pcall(function()
				return HttpService:JSONDecode(stockJson)
			end)

			if not success or not stockData or not stockData.max_purchase or not stockData.stock_timer then
				warn("CheckProductStock: Product '" .. productName .. "' has invalid stock data.")
				return false, 0
			end

			-- Get how many items have been consumed/purchased in this cycle
			local consumedAmount = secure_call(StockTimes.get_consumed_amount, product.Name, stockData.stock_timer)

			-- Calculate the remaining stock
			local stockLeft = math.max(0, stockData.max_purchase - consumedAmount)

			-- Determine if it's in stock
			local isInStock = stockLeft > 0

			return isInStock, stockLeft
		end

		while task_wait(1) do
			if G_Toggle("AutoSelectHackTool") then
				xpcall(function()
					local LevelsOrdered = {
						{ Tool = "HackToolBasic", Skill = "HackTool_Basic" },
						{ Tool = "HackToolPro", Skill = "HackTool_Pro" },
						{ Tool = "HackToolUltimate", Skill = "HackTool_Ultimate" },
					}

					local QuantumToolInStock = CheckProductStock("HackToolQuantum")
					if QuantumToolInStock then
						table.insert(LevelsOrdered, { Tool = "HackToolQuantum", Skill = "HackTool_Quantum" })
						-- SafeNotify("Quantum tool in stock, selecting if possible")
						-- else
						-- SafeNotify(`Quantum tool out of stock, only {QuantumStockLeft} left`)
					end

					-- Go through list in a deterministic order (basic -> quantum)
					local BestTool = "HackToolBasic"

					local function HasSkill(skillName)
						local ok, res = pcall(secure_call, SkillsList.has_skill, Data_Module, "atm_hacker", skillName)
						return ok and res
					end

					for _, entry in ipairs(LevelsOrdered) do
						local result = HasSkill(entry.Skill)
						if result then
							BestTool = entry.Tool
						end
						-- print("Has skill", entry.Skill, ":", result)
					end

					-- print("Best Tool:", BestTool)
					setthreadcontext(8)
					Library.Options.HackTool:SetValue(BestTool)
				end, function(err)
					warn("AutoSelectHackTool error:", err, debug.traceback())
				end)
			end
		end
	end))

	coroutine_resume(AutoSelectHackToolRoutine)

	ATM_Hacker_Depbox:AddSlider("ATMFarmSpeedMultiplier", {
		Text = T("Speed Multiplier"),
		Default = 1,
		Min = 0.5,
		Max = 1,
		Rounding = 2,
		Tooltip = T("Sets the speed multiplier for ATM farming"),
	})

	ATM_Hacker_Depbox:AddToggle("ATMFarmAutoHop", {
		Text = T("Auto Server Hop"),
		Default = true,
		Tooltip = T("Automatically hops to a new server every 5 minutes to resolve issues."),
		Disabled = FREE_BUILD,
	})

	--#endregion

	--#region Shelf Stocking
	local Shelf_Stocker_Depbox = AutomationGroup:AddDependencyBox(T("Shelf Stocking"))
	Shelf_Stocker_Depbox:SetupDependencies({
		{ Library.Options.SelectedAutofarm, "Shelf Stocking" },
	})

	Shelf_Stocker_Depbox:AddToggle("ShelfStocking", {
		Text = T("Enabled"),
		Default = false,
		Tooltip = T("Automatically stocks shelves"),
		Disabled = FREE_BUILD
			or not (AssertArgument("Player_Stocked_Shelf") and AssertArgument("Player_Started_Stocking_Shelf")),
	})

	Shelf_Stocker_Depbox:AddDivider()
	Shelf_Stocker_Depbox:AddLabel(T("Options"))

	Shelf_Stocker_Depbox:AddToggle("ShelfStockerAutoDeposit", {
		Text = T("Auto-Deposit Cash"),
		Default = true,
		Tooltip = T("Automatically deposits cash at a certain threshold."),
		Disabled = FREE_BUILD,
	})

	Shelf_Stocker_Depbox:AddSlider("ShelfStockerDepositThreshold", {
		Text = T("Deposit Threshold"),
		Default = 2000,
		Min = 0,
		Max = 10000,
		Rounding = 0,
		Tooltip = T("Automatically deposits cash when you have this much cash on hand."),
		Disabled = FREE_BUILD,
	})

	--#endregion

	--#region Steak Cooking
	local Cook_Farm_Depbox = AutomationGroup:AddDependencyBox(T("Steak Cooking"))
	Cook_Farm_Depbox:SetupDependencies({
		{ Library.Options.SelectedAutofarm, "Steak Cooking" },
	})

	Cook_Farm_Depbox:AddToggle("CookFarm", {
		Text = T("Enabled"),
		Default = false,
		Tooltip = T("Automatically cooks food"),
		Disabled = not (AssertArgument("Start_Grilling") and AssertArgument("Finish_Grilling")),
	})

	Cook_Farm_Depbox:AddDivider()
	Cook_Farm_Depbox:AddLabel(T("Options"))

	Cook_Farm_Depbox:AddToggle("CookFarmAutoDeposit", {
		Text = T("Auto-Deposit Cash"),
		Default = true,
		Tooltip = T("Automatically deposits cash while cooking when above a threshold."),
		Disabled = FREE_BUILD,
	})

	Cook_Farm_Depbox:AddSlider("CookFarmDepositThreshold", {
		Text = T("Deposit Threshold"),
		Default = 2000,
		Min = 0,
		Max = 10000,
		Rounding = 0,
		Tooltip = T("Deposit cash when your wallet reaches this amount."),
		Disabled = FREE_BUILD,
	})
	--#endregion

	--#region Fishing

	local Fish_Farm_Depbox = AutomationGroup:AddDependencyBox(T("Fishing"))
	Fish_Farm_Depbox:SetupDependencies({
		{ Library.Options.SelectedAutofarm, "Fishing" },
	})

	Fish_Farm_Depbox:AddToggle("AutoFish", {
		Text = T("Enabled"),
		Default = false,
		Tooltip = T("Automatically fishes for you."),
		Disabled = not (AssertArgument("Request") and AssertArgument("Win") and AssertArgument("Sprint")) or FREE_BUILD,
	})

	local InventoryFilterGroup = Tabs.Automation:AddRightGroupbox(T("Inventory Filter"))

	do
		local AllItems = Inventory.GetAllItems()
		print(#AllItems, "items")
		local ItemsList = {}

		for _, Item in next, AllItems do
			table.insert(ItemsList, Item.Name)
		end

		table.sort(ItemsList)

		InventoryFilterGroup:AddToggle("InventoryFilterEnabled", {
			Text = T("Enabled"),
			Default = false,
			Tooltip = T("Enables inventory filtering"),
		})

		InventoryFilterGroup:AddDropdown("InventoryFilterList", {
			Text = T("Item Filter"),
			Values = ItemsList,
			Multi = true,
		})
	end

	-- Combat tab

	local GunModificationsGroup = Tabs.Combat:AddRightGroupbox(T("Gun Mods"))

	local CurrentGun = GunModificationsGroup:AddLabel(T("Current: None"))

	GunModificationsGroup:AddToggle("GunModificationEnabled", {
		Text = T("Enabled"),
		Default = false,
		Tooltip = T("Enables gun modification features"),
	})

	GunModificationsGroup:AddSlider("GunMods_S_Accuracy", {
		Text = T("Accuracy"),
		Default = 1,
		Min = 0.1,
		Max = 1,
		Rounding = 2,
		Tooltip = T("Sets the accuracy for guns"),
		Callback = function()
			Storage.UpdateGunStatsCallback:Fire()
		end,
	})

	GunModificationsGroup:AddToggle("GunMods_S_Automatic", {
		Text = T("Automatic"),
		Default = false,
		Tooltip = T("Enables automatic firing for guns"),
		Callback = function()
			Storage.UpdateGunStatsCallback:Fire()
		end,
	})

	GunModificationsGroup:AddSlider("GunMods_S_FireRate", {
		Text = T("Fire Rate"),
		Default = 500,
		Min = 400,
		Max = 1500,
		Rounding = 2,
		Tooltip = T("Sets the fire rate for guns"),
		Callback = function()
			Storage.UpdateGunStatsCallback:Fire()
		end,
	})

	for _, Attribute in next, Storage.Gun_Attributes do
		if Attribute.Type == "number" then
			GunModificationsGroup:AddSlider("GunMods_" .. Attribute.Name, {
				Text = T(Attribute.Name),
				Default = Attribute.Default or Attribute.Min,
				Min = Attribute.Min,
				Max = Attribute.Max,
				Rounding = 2,
				Tooltip = T("Sets the " .. Attribute.Name .. " for guns"),
			})
		elseif Attribute.Type == "boolean" then
			GunModificationsGroup:AddToggle("GunMods_" .. Attribute.Name, {
				Text = T(Attribute.Name),
				Default = false,
				Tooltip = T("Enables " .. Attribute.Name .. " for guns"),
			})
		elseif Attribute.Type == "function" then
			GunModificationsGroup:AddToggle("GunMods_" .. Attribute.Attribute, {
				Text = T(Attribute.Name),
				Default = false,
				Tooltip = T("Enables " .. Attribute.Name .. " for guns"),
			})
		end
	end

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
		Disabled = FREE_BUILD,
	})

	MeleeModificationsGroup:AddToggle("BumpAura", {
		Text = T("Bump-Aura"),
		Default = false,
		Tooltip = T("Automatically hits players with your car in range"),
		Disabled = FREE_BUILD,
	})

	MeleeModificationsGroup:AddToggle("ThrowableAura", {
		Text = T("Throwable-Aura"),
		Default = false,
		Tooltip = T("Automatically throws projectiles at players in range"),
		Disabled = FREE_BUILD,
	})

	MeleeModificationsGroup:AddToggle("MeleeRemoveConeCheck", {
		Text = T("Radius-Only HitReg"),
		Default = false,
		Tooltip = T("Removes the cone check for melee weapons"),
	})

	MeleeModificationsGroup:AddToggle("VisualizeMelee", {
		Text = T("Visualize Melee"),
		Default = false,
		Tooltip = T("Shows melee radius."),
	})

	MeleeModificationsGroup:AddToggle("MeleeModificationEnabled", {
		Text = T("Enabled"),
		Default = false,
		Tooltip = T("Enables melee modification features"),
	})

	MeleeModificationsGroup:AddSlider("MeleeMods_S_ConeAngle", {
		Text = T("Cone Angle"),
		Default = 30,
		Min = 30,
		Max = 360,
		Rounding = 2,
		Tooltip = T("Sets the Cone Angle for melee weapons"),
		Callback = function()
			Storage.UpdateMeleeStatsCallback:Fire()
		end,
	})

	MeleeModificationsGroup:AddSlider("MeleeMods_S_Range", {
		Text = T("Range"),
		Default = 5,
		Min = 1,
		Max = 20,
		Rounding = 2,
		Tooltip = T("Sets the Range for melee weapons"),
		Callback = function()
			Storage.UpdateMeleeStatsCallback:Fire()
		end,
	})

	MeleeModificationsGroup:AddSlider("MeleeMods_S_Speed", {
		Text = T("Speed"),
		Default = 1,
		Min = 0.1,
		Max = 5,
		Rounding = 2,
		Tooltip = T("Sets the Speed for melee weapons"),
		Callback = function()
			Storage.UpdateMeleeStatsCallback:Fire()
		end,
	})

	local SilentAimGroup = Tabs.Combat:AddLeftGroupbox(T("Silent Aim"))

	SilentAimGroup:AddToggle("DoubleTap", {
		Text = T("Double Tap"),
		Default = false,
		Tooltip = T("Duplicates outgoing shots."),
		Disabled = FREE_BUILD,
	})

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
	})

	SilentAimGroup:AddToggle("Wallbang", {
		Text = T("Wallbang"),
		Default = false,
		Tooltip = T("Enables shooting people through walls"),
	})

	SilentAimGroup:AddToggle("Prediction", {
		Text = T("Prediction"),
		Default = true,
		Tooltip = T("Predicts player movement when aiming."),
	})

	if FREE_BUILD then
		Library.Toggles.Prediction:SetValue(false)
	end

	SilentAimGroup:AddToggle("SilentAimFilterFriends", {
		Text = T("Ignore Friends"),
		Default = true,
		Tooltip = T("Ignores friends in aim checks."),
		Callback = function(Value)
			Aiming_Library.FilterFriends = Value
		end,
	})

	SilentAimGroup:AddToggle("SilentAimUseClosest", {
		Text = T("Use Closest to Camera"),
		Default = false,
		Tooltip = T("Uses the closest player to the camera."),
		Callback = function(Value)
			Aiming_Library.ClosestToCamera = Value
		end,
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
	})

	SilentAimGroup:AddToggle("SilentAimCenterFOV", {
		Text = T("Center Field of View"),
		Default = UserInputService:GetDeviceType() == Enum.DeviceType.Phone,
		Tooltip = T("Useful for mobile."),
		Callback = function(Value)
			Aiming_Library.CenterLockFOV = Value
		end,
	})

	SilentAimGroup:AddDropdown("SilentAimPart", {
		Text = T("Part"),
		Default = "UpperTorso",
		Values = { "HumanoidRootPart", "UpperTorso", "Head" },
		Tooltip = T("Sets the part to aim at"),
	})

	SilentAimGroup:AddToggle("MultiResolve", {
		Text = T("Multi-Resolve"),
		Default = false,
		Tooltip = T("Attempts to shoot from many positions at once."),
	})

	SilentAimGroup:AddToggle("VisualizeBullets", {
		Text = T("Visualize Bullets"),
		Default = false,
	})

	local PredictionGroup = Tabs.Combat:AddRightGroupbox(T("Prediction Settings"))

	PredictionGroup:AddLabel(T("These settings only apply if Prediction is enabled."))

	PredictionGroup:AddToggle("SimplifiedNetworkTimeModel", {
		Text = T("Simplified Network Time Model"),
		Default = true,
		Tooltip = T("Uses a simplified network time model for prediction."),
		Callback = function(Value)
			Prediction.ModelSettings.SimplifiedNetworkTimeModel = Value
		end,
	})

	PredictionGroup:AddToggle("AccelerationComponent", {
		Text = T("Acceleration Component"),
		Default = false,
		Tooltip = T("Uses an acceleration component for prediction."),
		Callback = function(Value)
			Prediction.ModelSettings.AddAccelerationComponent = Value
		end,
	})

	PredictionGroup:AddToggle("UseCustomVelocityResolver", {
		Text = T("Velocity Resolver"),
		Default = true,
		Tooltip = T("Uses position delta per heartbeat to resolve velocity instead of Roblox's AssemblyLinearVelocity. May be more accurate for networked characters."),
		Callback = function(Value)
			Prediction.ModelSettings.UseCustomVelocityResolver = Value
		end,
	})

	Cleaner(InitializedSignal.Event:Once(function()
		Prediction.ModelSettings.SimplifiedNetworkTimeModel = G_Toggle("SimplifiedNetworkTimeModel")
		Prediction.ModelSettings.AddAccelerationComponent = G_Toggle("AccelerationComponent")
		Prediction.ModelSettings.UseCustomVelocityResolver = G_Toggle("UseCustomVelocityResolver")
	end))

	local MiscCombatGroup = Tabs.Combat:AddRightGroupbox("Misc")

	MiscCombatGroup:AddToggle("RevengeKill", {
		Text = T("Revenge Kill"),
		Default = false,
		Tooltip = T("Enables the revenge kill feature."),
		Disabled = FREE_BUILD,
	})

	-- Teleports tab

	local TargetPosition = Vector3.new(0, 0, 0)
	local TeleportsGroup = Tabs.Teleports:AddLeftGroupbox(T("Teleports"))
	local TeleportsList = {}

	for TeleportName, _ in next, Storage.Teleport_Positions do
		table.insert(TeleportsList, TeleportName)
	end

	TeleportsGroup:AddDropdown("TeleportPosition", {
		Text = T("Teleport Position"),
		Default = 1,
		Values = TeleportsList,
		Tooltip = T("Select a teleport position"),
		Callback = function(Value)
			local Position = Storage.Teleport_Positions[Value]
			if Position then
				TargetPosition = Position
			end
		end,
	})

	TeleportsGroup:AddButton(T("Teleport"), function()
		local Vehicle = GetVehicle()

		if Vehicle then
			local Motors = Vehicle.Vehicle:FindFirstChild("Motors")
			if Motors then
				local ForwardMaxSpeed = Motors:GetAttribute("forwardMaxSpeed") or 23
				local Ratio = ForwardMaxSpeed / 35
				TELEPORT_SPEED_VEHICLE = 65 * Ratio
			else
				TELEPORT_SPEED_VEHICLE = 40
			end
		end

		SecureLerpTeleport(
			LocalPlayer.Character:GetPivot(),
			CFrame.new(TargetPosition),
			Vehicle and TELEPORT_SPEED_VEHICLE or TELEPORT_SPEED
		)
	end)

	local PlaceTeleportGroup = Tabs.Teleports:AddRightGroupbox(T("Subplace Teleports"))

	if not FREE_BUILD then
		-- PlaceTeleportGroup:AddButton({
		-- 	Text = T("Join Private Server"),
		-- 	Func = function()
		-- 		queue_on_teleport("repeat task_wait() until game:IsLoaded()\nloadstring(game:HttpGet(\"https://example.com/script/Blockspin_Paid_Loader.luau\"))()")
		-- 		Reserved_Server_Generator()
		-- 	end,
		-- 	Tooltip = T("Generates a private server and teleports you to it."),
		-- 	DisabledTooltip = T("Button is disabled in FREE_BUILD mode"),
		-- 	Disabled = FREE_BUILD,
		-- })

		if game.PlaceId ~= 104715542330896 then
			PlaceTeleportGroup:AddButton({
				Text = T("Join Server 1"),
				Func = function()
					Utils.UnifiedTeleportHandler({ PlaceId = 104715542330896 })
				end,
				Tooltip = T("Teleports you to a normal server and bypasses the forced teleport."),
				DisabledTooltip = T("Button is disabled in FREE_BUILD mode"),
				Disabled = FREE_BUILD,
			})
		end

		PlaceTeleportGroup:AddButton({
			Text = T("Copy Join Code"),
			Func = function()
				local joinCode = Utils.GetJoinCode()
				if joinCode == "" then
					SafeNotify(T("Could not get join code."), 3)
					return
				end
				local success, err = pcall(setclipboard, joinCode)
				if success then
					SafeNotify(T("Join code copied to clipboard!"), 3)
				else
					SafeNotify(T("Failed to copy join code. Check console."), 3)
					warn("setclipboard error:", err)
				end
			end,
			Tooltip = T("Copies the current server's join code to your clipboard."),
		})

		PlaceTeleportGroup:AddInput("JoinCodeInput", {
			Text = T("Join Code"),
			Default = "",
			Placeholder = T("Enter join code here"),
			Tooltip = T("Enter the join code of the server you want to join."),
		})

		PlaceTeleportGroup:AddButton({
			Text = T("Join by Code"),
			Func = function()
				local joinCode = G_Option("JoinCodeInput")
				if joinCode == "" then
					SafeNotify(T("Please enter a join code."), 3)
					return
				end

				local joinData = Utils.JoinCodeToJoinData(joinCode)

				local jobId, placeId = joinData.JobId, joinData.PlaceId

				if jobId == "" then
					SafeNotify(T("Invalid join code format."), 3)
					return
				end

				SafeNotify(T("Attempting to join server by code..."), 3)

				local success, err = pcall(function()
					Utils.UnifiedTeleportHandler({
						PlaceId = placeId or game.PlaceId,
						JobId = jobId,
						Bypass = false,
					})
				end)

				if not success then
					SafeNotify("Failed to teleport to root place: " .. tostring(err) .. ". Trying current place...", 5)
					warn("TeleportToPlaceInstance (root) error:", err)

					local currentPlaceSuccess, currentPlaceErr = pcall(function()
						TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
					end)

					if not currentPlaceSuccess then
						SafeNotify("Failed to teleport to current place: " .. tostring(currentPlaceErr), 5)
						warn("TeleportToPlaceInstance (current) error:", currentPlaceErr)
					end
				end
			end,
			Tooltip = T("Joins a server using the provided join code. Tries root place ID first."),
		})

		PlaceTeleportGroup:AddButton({
			Text = T("Server-Hop"),
			Func = function()
				local servers = {}
				local req = SecureRequest:HttpGet(
					"https://games.roblox.com/v1/games/"
						.. game.PlaceId
						.. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
				)
				local body = HttpService:JSONDecode(req)

				if body and body.data then
					for i, v in next, body.data do
						if
							type(v) == "table"
							and tonumber(v.playing)
							and tonumber(v.maxPlayers)
							and v.playing < v.maxPlayers
							and v.id ~= game.JobId
						then
							table.insert(servers, 1, v.id)
						end
					end
				end

				if #servers > 0 then
					if LPH_OBFUSCATED then
						local AppendString = 'getgenv().Key = "NoKey"'
						if getgenv().Key then
							AppendString = `getgenv().Key = "{getgenv().Key}"\n`
						end
						queue_on_teleport(
							AppendString
								.. 'repeat task_wait() until game:IsLoaded()\nloadstring(game:HttpGet("https://example.com/script/Blockspin_Paid_Loader.luau"))()'
						)
					end
					return TeleportService:TeleportToPlaceInstance(
						game.PlaceId,
						servers[math.random(1, #servers)],
						Players.LocalPlayer
					)
				else
					return SafeNotify("No servers found to hop to.", 3)
				end
			end,
			Tooltip = T("Teleports you to a normal server and bypasses the forced teleport."),
			DisabledTooltip = T("Button is disabled in FREE_BUILD mode"),
			Disabled = FREE_BUILD,
		})
	end

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

	MiscVisualsGroup:AddToggle("ShowServerStamina", {
		Text = T("Show Server-Side Stamina"),
		Default = true,
		Tooltip = T("Displays your server-side stamina in the top left corner."),
	})

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
			ItemView.Enabled = G_Toggle("ESPItems") and Value
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
			ItemView.MaxDistance = Value
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

	ESPGroup:AddToggle("ESPSpotlight", {
		Text = T("Spotlight"),
		Default = false,
		Tooltip = T("Enables spotlight effect for ESP"),
		Callback = function(Value)
			ESP_Library.Config.Spotlight = Value
		end,
	})

	ESPGroup:AddSlider("ESPSpotlightFadeStart", {
		Text = T("Spotlight Fade Start (%)"),
		Default = math.floor((ESP_Library.Config.SpotlightFadeStart or 0) * 100 + 0.5),
		Min = 0,
		Max = 100,
		Rounding = 0,
		Tooltip = T("Percent of screen distance from the cursor before spotlight fade begins"),
		Callback = function(Value)
			ESP_Library.Config.SpotlightFadeStart = math.clamp(Value, 0, 100) / 100
		end,
	})

	ESPGroup:AddSlider("ESPSpotlightFadeLength", {
		Text = T("Spotlight Fade Length (%)"),
		Default = math.floor((ESP_Library.Config.SpotlightFadeLength or 0) * 100 + 0.5),
		Min = 0,
		Max = 100,
		Rounding = 0,
		Tooltip = T("Percent span over which spotlight fade reaches full effect"),
		Callback = function(Value)
			ESP_Library.Config.SpotlightFadeLength = math.clamp(Value, 0, 100) / 100
		end,
	})

	ESPGroup:AddToggle("ESPPlayers", {
		Text = T("Players"),
		Default = false,
		Tooltip = T("Shows ESP for players"),
		Callback = function(Value)
			ESP_Library.Config.Players = Value
		end,
	})

	ESPGroup:AddToggle("ESPItems", {
		Text = T("Inventory"),
		Default = false,
		Tooltip = T("Shows ESP for inventory"),
		Callback = function(Value)
			ItemView.Enabled = Value and ESP_Library.Config.Enabled
		end,
		Disabled = FREE_BUILD,
	}):AddColorPicker("ItemESPColor", {
		Default = Color3.new(1, 1, 1),
		Title = T("Item ESP Color"),
		Transparency = nil,
		Callback = function(Value)
			ItemView.Color = Value
		end,
	})

	ESPGroup:AddToggle("ESPDroppedItems", {
		Text = T("Dropped Items"),
		Default = true,
		Tooltip = T("Shows ESP for dropped items"),
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
		Values = { "3DFull", "3D", "2D", "2DCorners" },
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

	ESPGroup:AddToggle("ESPHighlight", {
		Text = T("Highlight"),
		Default = true,
		Tooltip = T("Highlights players"),
		Callback = function(Value)
			ESP_Library.Config.Highlights = Value
		end,
	})
		:AddColorPicker("HighlightColor", {
			Default = Color3.new(1.000000, 0.568627, 0.000000),
			Title = T("Highlight Fill Color"),
			Transparency = nil,
			Callback = function(Value)
				ESP_Library.Config.HighlightFillColor = Value
			end,
		})
		:AddColorPicker("HighlightOutlineColor", {
			Default = Color3.new(1.000000, 0.427451, 0.282353),
			Title = T("Highlight Outline Color"),
			Transparency = nil,
			Callback = function(Value)
				ESP_Library.Config.HighlightOutlineColor = Value
			end,
		})

	ESPGroup:AddSlider("HighlightFillTransparency", {
		Text = T("Highlight Fill Transparency"),
		Default = 0.8,
		Min = 0,
		Max = 1,
		Rounding = 2,
		Tooltip = T("Sets the fill transparency for highlights"),
		Callback = function(Value)
			ESP_Library.Config.HighlightFillTransparency = Value
		end,
	})

	ESPGroup:AddSlider("HighlightOutlineTransparency", {
		Text = T("Highlight Outline Transparency"),
		Default = 0.5,
		Min = 0,
		Max = 1,
		Rounding = 2,
		Tooltip = T("Sets the outline transparency for highlights"),
		Callback = function(Value)
			ESP_Library.Config.HighlightOutlineTransparency = Value
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

	-- InventoryViewer Tab

	local InventoryGroup = Tabs.InventoryViewer:AddLeftGroupbox(T("Player Select"))

	InventoryGroup:AddDropdown("InventoryViewerTarget", {
		SpecialType = "Player",
		ExcludeLocalPlayer = false,
		Text = T("Target Player"),
		Tooltip = T("Player who is being viewed"),
	})

	InventoryGroup:AddButton(T("Select Highest Value"), function()
		local HighestValue = 0
		local HighestPlayer = nil

		for _, Player in next, Players:GetPlayers() do
			if Player ~= LocalPlayer and Player.Character then
				local Value = 0
				for _, Tool in next, Player.Backpack:GetChildren() do
					if Tool:IsA("Tool") then
						local ItemData = Inventory.ResolveDataFromHashedTool(Tool)
						if ItemData and ItemData.Price then
							Value = Value + ItemData.Price
						end
					end
				end

				if Value > HighestValue then
					HighestValue = Value
					HighestPlayer = Player
				end
			end
		end

		if HighestPlayer then
			Library.Options.InventoryViewerTarget:SetValue(HighestPlayer)
		end
	end)

	local InventoryViewerGroup = Tabs.InventoryViewer:AddRightGroupbox(T("Inventory"))
	local TargetPlayerText = InventoryViewerGroup:AddLabel(T("Inventory of " .. LocalPlayer.Name))

	local InventoryUpdateRoutine = Cleaner(coroutine_create(LPH_JIT_MAX(function()
		while task_wait(1) do
			-- Check if InventoryViewerTarget is valid
			local TargetPlayer = Library.Options.InventoryViewerTarget.Value
			if TargetPlayer then
				local Items = {}

				for _, Tool in next, TargetPlayer.Backpack:GetChildren() do
					if Tool:IsA("Tool") then
						table.insert(Items, Inventory.ResolveDataFromHashedTool(Tool))
					end
				end

				if TargetPlayer.Character then
					for _, Tool in next, TargetPlayer.Character:GetChildren() do
						if Tool:IsA("Tool") then
							table.insert(Items, Inventory.ResolveDataFromHashedTool(Tool))
						end
					end
				end

				-- Generate the inventory list

				local Container = TargetPlayerText.Container

				local InventoryImageContainer = Container:FindFirstChild("InventoryImageContainer")

				if not InventoryImageContainer then
					InventoryImageContainer = Instance.new("Frame")
					InventoryImageContainer.Name = "InventoryImageContainer"
					InventoryImageContainer.Size = UDim2.new(1, 0, 0, 200)
					InventoryImageContainer.BackgroundTransparency = 1
					InventoryImageContainer.Parent = Container
				end

				InventoryImageContainer:ClearAllChildren()

				-- Mount images.

				local Grid_Columns = 4
				local ItemSize = InventoryImageContainer.AbsoluteSize.X / Grid_Columns

				for i, Item in next, Items do
					local Image = Instance.new("ImageLabel")
					Image.Name = "Item" .. i
					Image.Size = UDim2.new(0, ItemSize, 0, ItemSize)
					Image.Position = UDim2.new(
						(i - 1) % Grid_Columns / Grid_Columns,
						0,
						math_floor((i - 1) / Grid_Columns) / Grid_Columns,
						0
					)
					Image.BackgroundTransparency = 1
					Image.Image = Item.ImageId
					Image.Parent = InventoryImageContainer
				end

				-- Resize the container to fit the images
				local Rows = math.ceil(#Items / Grid_Columns)
				InventoryImageContainer.Size = UDim2.new(1, 0, 0, math_max(20, Rows * ItemSize))

				-- If there are no items, show a message
				if #Items == 0 then
					local NoItemsLabel = Instance.new("TextLabel")
					NoItemsLabel.Name = "NoItemsLabel"
					NoItemsLabel.Size = UDim2.new(1, 0, 0, 20)
					NoItemsLabel.BackgroundTransparency = 1
					NoItemsLabel.Text = "No items found."
					NoItemsLabel.TextColor3 = Color3.new(1, 1, 1)
					NoItemsLabel.TextScaled = true
					NoItemsLabel.Parent = InventoryImageContainer
				end

				TargetPlayerText:SetText(T("Inventory of " .. TargetPlayer.Name))
			else
				TargetPlayerText:SetText(T("Inventory"))
			end
		end
	end)))
	coroutine_resume(InventoryUpdateRoutine)

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
		ConnectionProxyMgr:Clear()
		ESP_Library.Unload()
		Aiming_Library.Unload()
		rconsoledestroy()
	end)

	-- Cleaner(RunService.RenderStepped:Connect(function()
	-- 	Library:SetWatermark("Current connections: " .. flen(Cleaner.Registry))
	-- end))

	task_spawn(function()
		while task_wait(2) do
			Storage.UpdateGunStatsCallback:Fire()
			Storage.UpdateMeleeStatsCallback:Fire()
		end
	end)

	local ChildAddedConnection, ChildRemovedConnection = nil, nil

	Storage.Connections[_nextKey(Storage.Connections, "UI_LocalPlayer_CharacterAdded")] =
		Cleaner(LocalPlayer.CharacterAdded:Connect(function(Character)
			if ChildAddedConnection then
				Cleaner.CleanOne(ChildAddedConnection)
				ChildAddedConnection = nil
			end
			if ChildRemovedConnection then
				Cleaner.CleanOne(ChildRemovedConnection)
				ChildRemovedConnection = nil
			end

			ChildAddedConnection = Cleaner(Character.ChildAdded:Connect(function(Child)
				if CollectionService:HasTag(Child, "Gun") then
					CurrentGun:SetText("Current: " .. Child.Name)
				end
			end))
			Storage.Connections[_nextKey(Storage.Connections, "UI_Character_ChildAdded")] = ChildAddedConnection
			ChildRemovedConnection = Cleaner(Character.ChildRemoved:Connect(function(Child)
				if CollectionService:HasTag(Child, "Gun") then
					CurrentGun:SetText("Current: None")
				end
			end))
			Storage.Connections[_nextKey(Storage.Connections, "UI_Character_ChildRemoved")] = ChildRemovedConnection

			if G_Toggle("RevengeKill") then
				if Storage.LastKilledBy then
					local KilledByPlayer = Players:FindFirstChild(Storage.LastKilledBy) :: Player?
					if not KilledByPlayer then
						return
					end
					local RevengeKillPrompt, Elements = require("./modules/RevengeKillPrompt.luau")()

					Elements["8"].Text = "Revenge-Kill " .. KilledByPlayer.DisplayName .. "?"

					-- Start a 10-second countdown
					local Countdown = 10
					local TimerLabel = Elements["c"]
					TimerLabel.Text = tostring(Countdown)

					Storage.Routines[_nextKey(Storage.Routines, "RevengeKill_Countdown")] = task_spawn(function()
						while Countdown > 0 do
							task_wait(1)
							Countdown -= 1
							TimerLabel.Text = tostring(Countdown)
						end
						RevengeKillPrompt:Destroy()
					end)
				end
			end
		end))

	if LocalPlayer.Character then
		if ChildAddedConnection then
			Cleaner.CleanOne(ChildAddedConnection)
			ChildAddedConnection = nil
		end
		if ChildRemovedConnection then
			Cleaner.CleanOne(ChildRemovedConnection)
			ChildRemovedConnection = nil
		end

		ChildAddedConnection = Cleaner(LocalPlayer.Character.ChildAdded:Connect(function(Child)
			if CollectionService:HasTag(Child, "Gun") then
				CurrentGun:SetText("Current: " .. Child.Name)
			end
		end))
		Storage.Connections[_nextKey(Storage.Connections, "UI_LocalCharacter_ChildAdded")] = ChildAddedConnection
		ChildRemovedConnection = Cleaner(LocalPlayer.Character.ChildRemoved:Connect(function(Child)
			if CollectionService:HasTag(Child, "Gun") then
				CurrentGun:SetText("Current: None")
			end
		end))
		Storage.Connections[_nextKey(Storage.Connections, "UI_LocalCharacter_ChildRemoved")] = ChildRemovedConnection
	end

	if not LPH_OBFUSCATED then
		local DebugGroup = Tabs.Debug:AddLeftGroupbox("Debug")
		DebugGroup:AddButton("Print ESP Objects", function()
			for _, Object in next, ESP_Library.Objects do
				print(Object.Name, Object.ClassName, Object.Instance)
			end
		end)
		DebugGroup:AddButton("Print InventoryData", function()
			print(Repr(Inventory.ListInventory()))
		end)
		DebugGroup:AddButton("Print InventoryDataHand", function()
			for i, Item in next, Inventory.FilterByLocation(Inventory.ListInventory(), "hand") do
				print(i, Repr(Item))
			end
		end)
		DebugGroup:AddLabel("CleanerInfo", {
			Text = "Cleaner Registry Size: " .. flen(Cleaner.Registry),
		})

		DebugGroup:AddButton("Export Arguments", function()
			local Arguments = ArgumentChecks

			for ArgumentName, ArgumentData in next, Arguments do
				print(`{ArgumentName}:\n\tFound: {ArgumentData.Found}\n\tValue: {ArgumentData.Value}`)
			end
		end)

		DebugGroup:AddButton("Test Orchestrator", function()
			local Orchestrator = require("./modules/Orchestrator.luau")
			Orchestrator:RunFullTest("KG-f128ffc3-1f06-42e2-a3e0-e1b20de16423", 825230256)
		end)

		DebugGroup:AddButton("Print all gun states", function()
			local GunClass = Class_Interface.GetClass("Gun")
			if not GunClass then
				warn("Gun class not found by Class_Interface!")
				return
			end

			local GunObjects = GunClass.objects or {}
			if next(GunObjects) == nil then -- Check if there are any guns to process
				-- dbgprint("No gun objects found to process at this time.")
				-- return -- Optionally return if you only want to run if guns exist
			end

			for _, Gun in next, GunObjects do
				-- Add a check for valid Gun object
				if not (Gun and Gun.instance and Gun.states) then
					dbgprint("Skipping invalid or nil gun object in GunObjects table.")
					if Gun and Gun.instance then
						-- If Gun.states is nil but instance exists, it's an improperly formed Gun object
						dbgwarn("Gun object for", Gun.instance.Name, "is missing .states property!")
					elseif Gun then
						dbgwarn("Gun object is missing .instance property!")
					end
					continue -- Skip to the next iteration
				end

				local States = Gun.states
				if not States then
					dbgwarn("Gun object for", Gun.instance.Name, "is missing .states property!")
					continue
				end

				print("Gun:", Gun.instance.Name)
				print("States:")
				for StateName, State in next, States do
					if type(State) == "table" and State.get then
						print("  ", StateName, ":", State:get())
					else
						print("  ", StateName, ":", State)
					end
				end
			end
		end)

		DebugGroup:AddInput("ClassInput", {
			Text = "Target Class",
			Default = "",
			Placeholder = "Enter target class here",
			Tooltip = "Enter the target class to dump",
		})

		DebugGroup:AddButton("Dump Class Objects", function()
			local TargetClass = G_Option("ClassInput")
			if TargetClass == "" then
				SafeNotify("Please enter a class name.", 3)
				return
			end

			local Class = Class_Interface.GetClass(TargetClass)
			if not Class then
				SafeNotify(`Class "{TargetClass}" not found.`, 3)
				return
			end

			local Objects = Class.objects or {}
			if next(Objects) == nil then
				SafeNotify(`No objects found for class "{TargetClass}".`, 3)
				return
			end

			for _, Object in next, Objects do
				print(Repr(Object, { pretty = true }))
			end

			SafeNotify(`Dumped {#Objects} objects from class "{TargetClass}".`, 3)
		end)

		DebugGroup:AddInput("SkillInput", {
			Text = "Target Skill",
			Default = "",
			Placeholder = "Enter target skill here",
			Tooltip = "Enter the target skill to dump",
		})

		DebugGroup:AddButton("Dump Skill Objects", function()
			local TargetSkill = G_Option("SkillInput")
			if TargetSkill == "" then
				SafeNotify("Please enter a class name.", 3)
				return
			end

			local Skills = SafeRequire(GameModules.Skills.SkillsList :: ModuleScript)

			local Skill = Skills.list[TargetSkill]

			if not Skill then
				SafeNotify(`Skill "{TargetSkill}" not found.`, 3)
				return
			end

			print(Repr(Skill, { pretty = true }))
			SafeNotify(`Dumped skill "{TargetSkill}".`, 3)
		end)

		task_spawn(function()
			while task_wait(1) do
				Library.Labels.CleanerInfo:SetText(`Cleaner Registry Size: {flen(Cleaner.Registry)}`)
			end
		end)
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

	--#region Orchestrator Tab
	if not FREE_BUILD and ORCHESTRATOR_MENU_ENABLED and Tabs.Orchestrator then
		local Orchestrator = require("./modules/Orchestrator.luau")
		local OrchestratorStorage = {
			PrivateKey = nil,
			WorkerKeys = {}, -- List of worker private keys to control
			PendingWarningAccepted = false,
		}

		-- Generate the user's private key
		local function GetOrGeneratePrivateKey(): string?
			if OrchestratorStorage.PrivateKey then
				return OrchestratorStorage.PrivateKey
			end

			local LicenseKey = getgenv().Key
			if not LicenseKey or LicenseKey == "BLACKLISTED" then
				SafeNotify(T("Unable to generate private key: No valid license key found."), 5)
				return nil
			end

			OrchestratorStorage.PrivateKey = Orchestrator:GeneratePrivateKey(LicenseKey, LocalUserId)
			return OrchestratorStorage.PrivateKey
		end

		-- Left groupbox: Your Identity
		local IdentityGroup = Tabs.Orchestrator:AddLeftGroupbox(T("Your Identity"))

		IdentityGroup:AddLabel(T("Your private key is derived from your"))
		IdentityGroup:AddLabel(T("license key and user ID. Keep it secret!"))

		local PrivateKeyPreview = IdentityGroup:AddLabel(T("Key: Not generated yet"))

		IdentityGroup:AddButton({
			Text = T("Generate/View Private Key"),
			Func = function()
				local key = GetOrGeneratePrivateKey()
				if key then
					PrivateKeyPreview:SetText(T("Key: ") .. string.sub(key, 1, 16) .. "...")
					SafeNotify(T("Private key generated. Use 'Copy' button to copy."), 3)
				end
			end,
			Tooltip = T("Generate or view your orchestration private key"),
		})

		IdentityGroup:AddButton({
			Text = T("Copy Worker Token"),
			Func = function()
				local key = GetOrGeneratePrivateKey()
				if not key then
					return
				end

				-- Create combined token: userId:privateKey
				local workerToken = tostring(LocalUserId) .. ":" .. key

				-- Show warning popup before copying
				if not OrchestratorStorage.PendingWarningAccepted then
					local Root, AcceptBtn, CancelBtn = ErrorHandler.InteractiveToast(
						T("Security Warning"),
						T("Your worker token grants FULL control over this client to anyone who has it.\n\n")
							.. T("NEVER share this token with anyone you don't fully trust.\n")
							.. T("Anyone with this token can:\n")
							.. T("• Control your farming settings\n")
							.. T("• Transfer your in-game money\n")
							.. T("• Execute commands on your client\n\n")
							.. T("Are you sure you want to copy this token?"),
						T("Yes, Copy Token"),
						T("Cancel")
					)

					AcceptBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
					AcceptBtn.BackgroundTransparency = 0
					CancelBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

					AcceptBtn.Activated:Once(function()
						OrchestratorStorage.PendingWarningAccepted = true
						Root:Destroy()

						if setclipboard then
							pcall(setclipboard, workerToken)
							SafeNotify(T("Worker token copied to clipboard!"), 3)
						else
							SafeNotify(T("Clipboard not available on this executor."), 3)
						end
					end)

					CancelBtn.Activated:Once(function()
						Root:Destroy()
						SafeNotify(T("Copy cancelled."), 2)
					end)

					-- Parent to gethui() if available for better visibility, otherwise CoreGui
					local uiParent = (gethui and gethui()) or CoreGui
					Root.DisplayOrder = 2147483647 -- Max int32 for highest display order
					Root.Parent = uiParent
					Root.Enabled = true
					return -- Wait for button callback
				else
					-- Warning already accepted this session
					if setclipboard then
						pcall(setclipboard, workerToken)
						SafeNotify(T("Worker token copied to clipboard!"), 3)
					else
						SafeNotify(T("Clipboard not available on this executor."), 3)
					end
				end
			end,
			Tooltip = T("Copy your worker token to clipboard (shows warning first)"),
		})

		-- Right groupbox: Worker Management
		local WorkerGroup = Tabs.Orchestrator:AddRightGroupbox(T("Worker Management"))

		WorkerGroup:AddLabel(T("Paste worker tokens from other clients."))
		WorkerGroup:AddLabel(T("Format: userId:privateKey"))

		WorkerGroup:AddInput("OrchestratorWorkerTokenInput", {
			Text = T("Worker Token"),
			Default = "",
			Placeholder = T("Paste worker token here"),
			Tooltip = T("Paste the worker token (userId:privateKey) from the worker client"),
		})

		local WorkerListLabel = WorkerGroup:AddLabel(T("Workers: 0 registered"))

		WorkerGroup:AddButton({
			Text = T("Add Worker"),
			Func = function()
				local workerToken = G_Option("OrchestratorWorkerTokenInput")

				if workerToken == "" then
					SafeNotify(T("Please paste a worker token."), 3)
					return
				end

				-- Parse token format: userId:privateKey
				local colonPos = string.find(workerToken, ":")
				if not colonPos then
					SafeNotify(T("Invalid token format. Expected userId:privateKey"), 3)
					return
				end

				local userIdStr = string.sub(workerToken, 1, colonPos - 1)
				local workerKey = string.sub(workerToken, colonPos + 1)

				local workerUserId = tonumber(userIdStr)
				if not workerUserId then
					SafeNotify(T("Invalid user ID in token."), 3)
					return
				end

				if workerKey == "" or #workerKey < 32 then
					SafeNotify(T("Invalid private key in token."), 3)
					return
				end

				-- Check if already added
				for _, worker in next, OrchestratorStorage.WorkerKeys do
					if worker.UserId == workerUserId then
						SafeNotify(T("This worker is already registered."), 3)
						return
					end
				end

				table.insert(OrchestratorStorage.WorkerKeys, {
					Key = workerKey,
					UserId = workerUserId,
				})

				WorkerListLabel:SetText(T("Workers: ") .. #OrchestratorStorage.WorkerKeys .. T(" registered"))
				SafeNotify(T("Worker added successfully!"), 3)

				-- Clear input
				Library.Options.OrchestratorWorkerTokenInput:SetValue("")
			end,
			Tooltip = T("Add this worker to your control list"),
		})

		WorkerGroup:AddButton({
			Text = T("Clear All Workers"),
			Func = function()
				OrchestratorStorage.WorkerKeys = {}
				WorkerListLabel:SetText(T("Workers: 0 registered"))
				SafeNotify(T("All workers cleared."), 3)
			end,
			Tooltip = T("Remove all registered workers"),
		})

		-- Left groupbox 2: Configuration
		local ConfigGroup = Tabs.Orchestrator:AddLeftGroupbox(T("Worker Configuration"))

		ConfigGroup:AddLabel(T("Settings to push to workers:"))

		ConfigGroup:AddSlider("OrchestratorMergeThreshold", {
			Text = T("Merge to Master Threshold"),
			Default = 1000000,
			Min = 100000,
			Max = 10000000,
			Rounding = 0,
			Suffix = T(" cash"),
			Tooltip = T("Amount of cash workers should accumulate before transferring to master"),
		})

		ConfigGroup:AddInput("OrchestratorJsonConfig", {
			Text = T("JSON Configuration"),
			Default = "{}",
			Placeholder = T('{"enabled": true, "target_money": 5000000}'),
			Tooltip = T("Custom JSON configuration data to send to workers"),
		})

		-- Right groupbox 2: Actions
		local ActionsGroup = Tabs.Orchestrator:AddRightGroupbox(T("Actions"))

		ActionsGroup:AddButton({
			Text = T("Push Config to All Workers"),
			Func = function()
				if #OrchestratorStorage.WorkerKeys == 0 then
					SafeNotify(T("No workers registered."), 3)
					return
				end

				local LicenseKey = getgenv().Key
				if not LicenseKey or LicenseKey == "BLACKLISTED" then
					SafeNotify(T("No valid license key found."), 3)
					return
				end

				local mergeThreshold = G_Option("OrchestratorMergeThreshold")
				local jsonConfigStr = G_Option("OrchestratorJsonConfig")

				local customConfig = {}
				pcall(function()
					customConfig = HttpService:JSONDecode(jsonConfigStr)
				end)

				local successCount = 0
				local failCount = 0

				for _, worker in next, OrchestratorStorage.WorkerKeys do
					-- Worker data configuration to be pushed
					local _workerData = {
						master_user_id = LocalUserId,
						master_server_id = game.JobId,
						transfer_threshold = mergeThreshold,
						autofarm_settings = customConfig,
						priority = 1,
						registered_at = os.time(),
					}
					_ = _workerData -- Silence unused warning until full implementation

					local success = Orchestrator:TestRegisterWorkerData(LicenseKey, worker.UserId)
					if success then
						successCount += 1
					else
						failCount += 1
					end

					task_wait(0.5) -- Rate limiting
				end

				SafeNotify(T("Config pushed: ") .. successCount .. T(" success, ") .. failCount .. T(" failed"), 5)
			end,
			Tooltip = T("Send the current configuration to all registered workers"),
		})

		ActionsGroup:AddButton({
			Text = T("Test Connection"),
			Func = function()
				local LicenseKey = getgenv().Key
				if not LicenseKey or LicenseKey == "BLACKLISTED" then
					SafeNotify(T("No valid license key found."), 3)
					return
				end

				SafeNotify(T("Testing orchestration service connection..."), 3)

				local success = pcall(function()
					Orchestrator:RunFullTest(LicenseKey, LocalUserId)
				end)

				if success then
					SafeNotify(T("Connection test completed! Check console for details."), 5)
				else
					SafeNotify(T("Connection test failed. Check console for errors."), 5)
				end
			end,
			Tooltip = T("Test the connection to the orchestration service"),
		})

		ActionsGroup:AddLabel(T("Status: Idle"))
	end
	--#endregion

	--#region Update values with the UI toggles as they do not sometimes.

	Aiming_Library.FilterFriends = G_Toggle("SilentAimFilterFriends")
	Aiming_Library.CenterLockFOV = G_Toggle("SilentAimCenterFOV")
	ESP_Library.Config.HighlightFillColor = G_Option("HighlightColor")
	ESP_Library.Config.HighlightOutlineColor = G_Option("HighlightOutlineColor")
	ESP_Library.Config.HighlightFillTransparency = G_Option("HighlightFillTransparency")
	ESP_Library.Config.HighlightOutlineTransparency = G_Option("HighlightOutlineTransparency")
	ESP_Library.Config.Font = Drawing.Fonts[G_Option("ESPFont")] or Drawing.Fonts.UI

	--#endregion

	if FREE_BUILD then
		pcall(function()
			local ReferralCode = SecureRequest.request({ Url = "https://example.com/file/code.txt", Method = "GET" })
			if ReferralCode.StatusCode == 200 then
				-- Check if we can redeem the referral code
				local HasClaimed = Data_Module.has_claimed_referral
				if not HasClaimed then
					SecureNet.Get(ArgumentChecks.Redeem_Referral_Code.Value, ReferralCode.Body)
				end
			end
		end)
	end

	MenuGroup:AddLabel("Menu bind")
		:AddKeyPicker("MenuKeybind", { Default = "RightControl", NoUI = true, Text = "Menu keybind" })
	Library.ToggleKeybind = Library.Options.MenuKeybind

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
	SaveManager:SetFolder("sasware_blockspin/main")

	SaveManager:BuildConfigSection(Tabs.Settings)
	ThemeManager:ApplyToTab(Tabs.Settings)

	SaveManager:LoadAutoloadConfig()

	ItemView:Init()

	Storage.UpdateGunStatsCallback:Fire()

	--#region Pull in teleport data if it exists.

	local Data = TeleportData:ReadWipe("TeleportState")

	if Data then
		SafeNotify("Loaded teleport data from previous session.", 10)

		task_wait(5) -- Let character fully load in.

		-- Check that the data isn't stale (was created in last 60 seconds)
		if tick() - Data.Created > 60 then
			SafeNotify("Teleport data is stale and will be ignored.", 10)
			return
		end

		-- Only allow loading a conservative subset: auto-farming related toggles/options
		local AllowedToggles = {
			CookFarm = true,
			ShelfStocking = true,
			ATMFarm = true,
			AutoShiesty = true,
			ATMFarmUsePath = true,
			AvoidWaitingAtATMs = true,
			ATMFarmDefensive = true,
			ATMFarmOffensive = true,
			ATMFarmAutoHop = true,
		}

		local AllowedOptions = {
			HackTool = true,
			ATMFarmSpeedMultiplier = true,
		}

		if Data.Toggles then
			for Key, Value in next, Data.Toggles do
				if AllowedToggles[Key] and Library.Toggles[Key] then
					pcall(function()
						Library.Toggles[Key]:SetValue(Value)
					end)
				else
					dbgprint("Skipping toggle from teleport data (not allowed):", Key)
				end
			end
		end

		if Data.Options then
			for Key, Value in next, Data.Options do
				if AllowedOptions[Key] and Library.Options[Key] then
					pcall(function()
						Library.Options[Key]:SetValue(Value)
					end)
				else
					dbgprint("Skipping option from teleport data (not allowed):", Key)
				end
			end
		end
	end

	InitializedSignal:Fire()

	Identifier:ToggleIdentify(G_Toggle("Identifier"))
end

local _ = xpcall(RunMain, function(Error)
	warn("An error occurred during execution:", Error)
	warn(debug.traceback())
	local throwResult = { ErrorHandler.Throw("0x01", `An error occured during exection: {Error}\n{debug.traceback()}`, false) }
	local AbortSignal = throwResult[2]
	local UI = throwResult[3]

	HookMgr.ClearHooks()
	Cleaner.Clean()
	ConnectionProxyMgr:Clear()
	ESP_Library.Unload()
	Aiming_Library.Unload()

	if AbortSignal then
		AbortSignal:Once(function()
			rconsoledestroy()
			if UI and UI.Destroy then
				UI:Destroy()
			end
		end)
	end
	return Error
end)

--#endregion
