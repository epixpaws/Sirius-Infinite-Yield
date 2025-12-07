-- Ensure the game is loaded 
if not game:IsLoaded() then
	game.Loaded:Wait()
end

-- Check License Tier
local Pro = true

-- Create Variables for Roblox Services
local coreGui = game:GetService("CoreGui")
local httpService = game:GetService("HttpService")
local lighting = game:GetService("Lighting")
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local guiService = game:GetService("GuiService")
local statsService = game:GetService("Stats")
local starterGui = game:GetService("StarterGui")
local teleportService = game:GetService("TeleportService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService('UserInputService')
local gameSettings = UserSettings():GetService("UserGameSettings")
local insertService = game:GetService("InsertService")

-- Variables
local camera = workspace.CurrentCamera
local getMessage = replicatedStorage:WaitForChild("DefaultChatSystemChatEvents", 1) and replicatedStorage.DefaultChatSystemChatEvents:WaitForChild("OnMessageDoneFiltering", 1)
local localPlayer = players.LocalPlayer
local notifications = {}
local friendsCooldown = 0
local mouse = localPlayer:GetMouse()
local promptedDisconnected = false
local smartBarOpen = false
local debounce = false
local searchingForPlayer = false
local lowerName = localPlayer.Name:lower()
local lowerDisplayName = localPlayer.DisplayName:lower()
local placeId = game.PlaceId
local jobId = game.JobId
local checkingForKey = false
local originalTextValues = {}
local creatorId = game.CreatorId
local noclipDefaults = {}
local movers = {}
local creatorType = game.CreatorType
local espContainer = Instance.new("Folder", gethui and gethui() or coreGui)
local PARENT = gethui and gethui() or coreGui
local oldVolume = gameSettings.MasterVolume
local hideCommandBar
local isLegacyChat = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
local iyflyspeed = 1
local vehicleflyspeed = 1
local floatName 
local CFloop
local Floating
local Noclipping
local Clip = true
local QEfly = true
local FLYING = false

local IYMouse = localPlayer:GetMouse()

function randomString()
	local length = math.random(10,20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

floatName = floatName or randomString()

function NOFLY()
	FLYING = false
	if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end
	if players.LocalPlayer.Character then
		if players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
			players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
		end
	end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

function sFLY(vfly)
	repeat wait() until players.LocalPlayer and players.LocalPlayer.Character and getRoot(players.LocalPlayer.Character) and players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	repeat wait() until IYMouse
	
	local T = getRoot(players.LocalPlayer.Character)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0
	
	local function FLY()
		FLYING = true
		local BG = Instance.new('BodyGyro', T)
		local BV = Instance.new('BodyVelocity', T)
		BG.P = 9e4
		BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.cframe = T.CFrame
		BV.velocity = Vector3.new(0, 0, 0)
		BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat wait()
				if not vfly and players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
					players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
				end
				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R, Q = CONTROL.Q, E = CONTROL.E}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + lCONTROL.Q + lCONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
				else
					BV.velocity = Vector3.new(0, 0, 0)
				end
				BG.cframe = workspace.CurrentCamera.CoordinateFrame
			until not FLYING
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:destroy()
			BV:destroy()
			if players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
				players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
			end
		end)
	end
	
	flyKeyDown = IYMouse.KeyDown:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 's' then
			CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 'a' then
			CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 'd' then 
			CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
		elseif QEfly and KEY:lower() == 'e' then
			CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
		elseif QEfly and KEY:lower() == 'q' then
			CONTROL.E = - (vfly and vehicleflyspeed or iyflyspeed)*2
		end
	end)
	
	flyKeyUp = IYMouse.KeyUp:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = 0
		elseif KEY:lower() == 's' then
			CONTROL.B = 0
		elseif KEY:lower() == 'a' then
			CONTROL.L = 0
		elseif KEY:lower() == 'd' then
			CONTROL.R = 0
		elseif KEY:lower() == 'e' then
			CONTROL.Q = 0
		elseif KEY:lower() == 'q' then
			CONTROL.E = 0
		end
	end)
	FLY()
end

cmds = cmds or {}
_G._siriusPendingCmds = _G._siriusPendingCmds or {}
currentArgs = {}

function findCmd(cmd_name)
	for i,v in pairs(cmds) do
		if v.NAME:lower()==cmd_name:lower() or FindInTable(v.ALIAS,cmd_name:lower()) then
			return v
		end
	end
	if customAlias and customAlias[cmd_name:lower()] then
		return customAlias[cmd_name:lower()]
	end
end

function getstring(i)
	local str = ''
	if currentArgs[i] then
		for n=i,#currentArgs do
			str = str..currentArgs[n]..' '
		end
		str = str:sub(1,#str-1)
	end
	return str
end

function execCmd(cmdStr, speaker)
	speaker = speaker or players.LocalPlayer
	local cmd = cmdStr
	local args = {}
	for w in string.gmatch(cmd, "[^%s]+") do
		table.insert(args, w)
	end
	if #args > 0 then
		local cmdName = table.remove(args, 1)
		local command = findCmd(cmdName)
		if command then
			local success, err = pcall(function()
				currentArgs = args
				command.FUNC(args, speaker)
			end)
			if not success then
				warn("Command Error: " .. tostring(err))
				if notify then notify("Error", "Command failed: " .. tostring(err)) end
			end
		end
	end
end

function addcmd(name, alias, func, plgn)
	cmds = cmds or {}
	table.insert(_G._siriusPendingCmds, {name, alias, func, plgn})
	table.insert(cmds, {
		NAME = name;
		ALIAS = alias or {};
		FUNC = func;
		PLUGIN = plgn;
	})
end

function isNumber(str)
	if tonumber(str) ~= nil or str == 'inf' then
		return true
	end
end

function getRoot(char)
	local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
	return rootPart
end

function tools(plr)
	if plr:FindFirstChildOfClass("Backpack"):FindFirstChildOfClass('Tool') or plr.Character:FindFirstChildOfClass('Tool') then
		return true
	end
end

function r15(plr)
	if plr.Character:FindFirstChildOfClass('Humanoid').RigType == Enum.HumanoidRigType.R15 then
		return true
	end
end

function toClipboard(txt)
    if setclipboard then
        setclipboard(tostring(txt))
        notify("Clipboard", "Copied to clipboard")
    elseif toclipboard then
        toclipboard(tostring(txt))
        notify("Clipboard", "Copied to clipboard")
    else
        notify("Clipboard", "Your exploit doesn't have the ability to use the clipboard")
    end
end

function getHierarchy(obj)
	local fullname
	local period

	if string.find(obj.Name,' ') then
		fullname = '["'..obj.Name..'"]'
		period = false
	else
		fullname = obj.Name
		period = true
	end

	local getS = obj
	local parent = obj
	local service = ''

	if getS.Parent ~= game then
		repeat
			getS = getS.Parent
			service = getS.ClassName
		until getS.Parent == game
	end

	if parent.Parent ~= getS then
		repeat
			parent = parent.Parent
			if string.find(tostring(parent),' ') then
				if period then
					fullname = '["'..parent.Name..'"].'..fullname
				else
					fullname = '["'..parent.Name..'"]'..fullname
				end
				period = false
			else
				if period then
					fullname = parent.Name..'.'..fullname
				else
					fullname = parent.Name..''..fullname
				end
				period = true
			end
		until parent.Parent == getS
	elseif string.find(tostring(parent),' ') then
		fullname = '["'..parent.Name..'"]'
		period = false
	end

	if period then
		return 'game:GetService("'..service..'").'..fullname
	else
		return 'game:GetService("'..service..'")'..fullname
	end
end

function notify(title, text)
    if game:GetService("StarterGui") then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = 3;
        })
    elseif print then
        print("[NOTIFY] " .. title .. ": " .. text)
    end
end

function chatMessage(str)
    str = tostring(str)
    if not isLegacyChat then
        if game:GetService("TextChatService").TextChannels.RBXGeneral then
            game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(str)
        end
    else
        if game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
        end
    end
end

function FindInTable(Table, Name)
	for i,v in pairs(Table) do
		if v == Name then
			return true
		end
	end
	return false
end

function splitString(str,delim)
	local broken = {}
	if delim == nil then delim = "," end
	for w in string.gmatch(str,"[^"..delim.."]+") do
		table.insert(broken,w)
	end
	return broken
end

function getPlayer(list, speaker)
	if list == nil then return {speaker.Name} end
	local nameList = splitString(list,",")
	local foundList = {}

	for _,name in pairs(nameList) do
		if name:lower() == "me" then
			table.insert(foundList, speaker)
		elseif name:lower() == "all" then
			for _,v in pairs(game:GetService("Players"):GetPlayers()) do table.insert(foundList,v) end
		elseif name:lower() == "others" then
			for _,v in pairs(game:GetService("Players"):GetPlayers()) do
				if v ~= speaker then table.insert(foundList,v) end
			end
		elseif name:lower() == "random" then
			local players = game:GetService("Players"):GetPlayers()
			table.insert(foundList, players[math.random(1, #players)])
		else
			for _,v in pairs(game:GetService("Players"):GetPlayers()) do
				if v.Name:lower():sub(1, #name) == name:lower() or v.DisplayName:lower():sub(1, #name) == name:lower() then
					table.insert(foundList, v)
				end
			end
		end
	end

	local foundNames = {}
	for i,v in pairs(foundList) do table.insert(foundNames,v.Name) end
	return foundNames
end

do

-- Basic Commands
addcmd('fly',{},function(args, speaker)
	NOFLY()
	wait()
	sFLY()
	if args[1] and isNumber(args[1]) then
		iyflyspeed = args[1]
	end
end)

addcmd('flyspeed',{'flysp'},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		iyflyspeed = speed
	end
end)

addcmd('unfly',{'nofly','novfly','unvehiclefly','novehiclefly','unvfly'},function(args, speaker)
	NOFLY()
end)

addcmd('vfly',{'vehiclefly'},function(args, speaker)
	NOFLY()
	wait()
	sFLY(true)
	if args[1] and isNumber(args[1]) then
		vehicleflyspeed = args[1]
	end
end)

addcmd('togglevfly',{},function(args, speaker)
	if FLYING then
		NOFLY()
	else
		sFLY(true)
	end
end)

addcmd('vflyspeed',{'vflysp','vehicleflyspeed','vehicleflysp'},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		vehicleflyspeed = speed
	end
end)

addcmd('qefly',{'flyqe'},function(args, speaker)
	if args[1] == 'false' then
		QEfly = false
	else
		QEfly = true
	end
end)

addcmd('togglefly',{},function(args, speaker)
	if FLYING then
		NOFLY()
	else
		sFLY()
	end
end)

addcmd('noclip',{},function(args, speaker)
	Clip = false
	wait(0.1)
	local function NoclipLoop()
		if Clip == false and speaker.Character ~= nil then
			for _, child in pairs(speaker.Character:GetDescendants()) do
				if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
					child.CanCollide = false
				end
			end
		end
	end
	Noclipping = runService.Stepped:Connect(NoclipLoop)
	if args[1] and args[1] == 'nonotify' then return end
	notify('Noclip','Noclip Enabled')
end)

addcmd('clip',{'unnoclip'},function(args, speaker)
	if Noclipping then
		Noclipping:Disconnect()
	end
	Clip = true
	if args[1] and args[1] == 'nonotify' then return end
	notify('Noclip','Noclip Disabled')
end)

addcmd('togglenoclip',{},function(args, speaker)
	if Clip then
		execCmd('noclip')
	else
		execCmd('clip')
	end
end)

addcmd("esp", {}, function(args, speaker)
    -- Simple ESP implementation
    for _, v in pairs(players:GetPlayers()) do
        if v ~= speaker and v.Character then
            local highlight = Instance.new("Highlight")
            highlight.Parent = v.Character
            highlight.FillColor = Color3.new(1, 0, 0)
            highlight.OutlineColor = Color3.new(1, 1, 1)
        end
    end
    if notify then notify("ESP", "ESP enabled") end
end)

addcmd("noesp", {"unesp"}, function(args, speaker)
    for _, v in pairs(players:GetPlayers()) do
        if v.Character then
            for _, child in pairs(v.Character:GetChildren()) do
                if child:IsA("Highlight") then
                    child:Destroy()
                end
            end
        end
    end
    if notify then notify("ESP", "Disabled") end
end)

addcmd("goto", {"to"}, function(args, speaker)
    local players = getPlayer(args[1], speaker)
    if players and players[1] then
        local target = game:GetService("Players")[players[1]]
        if target and target.Character and getRoot(target.Character) and speaker.Character and getRoot(speaker.Character) then
            getRoot(speaker.Character).CFrame = getRoot(target.Character).CFrame + Vector3.new(3, 1, 0)
        end
    end
end)

-- Additional Movement Commands
local CFspeed = 50
addcmd('cframefly', {'cfly'}, function(args, speaker)
	if args[1] and isNumber(args[1]) then
		CFspeed = args[1]
	end

	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
	local Head = speaker.Character:WaitForChild("Head")
	Head.Anchored = true
	if CFloop then CFloop:Disconnect() end
	CFloop = runService.Heartbeat:Connect(function(deltaTime)
		local moveDirection = speaker.Character:FindFirstChildOfClass('Humanoid').MoveDirection * (CFspeed * deltaTime)
		local headCFrame = Head.CFrame
		local camera = workspace.CurrentCamera
		local cameraCFrame = camera.CFrame
		local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
		cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
		local cameraPosition = cameraCFrame.Position
		local headPosition = headCFrame.Position

		local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
		Head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
	end)
end)

addcmd('uncframefly',{'uncfly'},function(args, speaker)
	if CFloop then
		CFloop:Disconnect()
		speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
		local Head = speaker.Character:WaitForChild("Head")
		Head.Anchored = false
	end
end)

addcmd('cframeflyspeed',{'cflyspeed'},function(args, speaker)
	if isNumber(args[1]) then
		CFspeed = args[1]
	end
end)

addcmd('float', {'platform'},function(args, speaker)
	Floating = true
	local pchar = speaker.Character
	if pchar and not pchar:FindFirstChild(floatName) then
		task.spawn(function()
			local Float = Instance.new('Part')
			Float.Name = floatName
			Float.Parent = pchar
			Float.Transparency = 1
			Float.Size = Vector3.new(2,0.2,1.5)
			Float.Anchored = true
			local FloatValue = -3.1
			Float.CFrame = getRoot(pchar).CFrame * CFrame.new(0,FloatValue,0)
			notify('Float','Float Enabled (Q = down & E = up)')
			local qUp, eUp, qDown, eDown, floatDied, FloatingFunc
			
			qUp = IYMouse.KeyUp:Connect(function(KEY)
				if KEY == 'q' then
					FloatValue = FloatValue + 0.5
				end
			end)
			eUp = IYMouse.KeyUp:Connect(function(KEY)
				if KEY == 'e' then
					FloatValue = FloatValue - 1.5
				end
			end)
			qDown = IYMouse.KeyDown:Connect(function(KEY)
				if KEY == 'q' then
					FloatValue = FloatValue - 0.5
				end
			end)
			eDown = IYMouse.KeyDown:Connect(function(KEY)
				if KEY == 'e' then
					FloatValue = FloatValue + 1.5
				end
			end)
			floatDied = speaker.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				FloatingFunc:Disconnect()
				Float:Destroy()
				qUp:Disconnect()
				eUp:Disconnect()
				qDown:Disconnect()
				eDown:Disconnect()
				floatDied:Disconnect()
			end)
			local function FloatPadLoop()
				if pchar:FindFirstChild(floatName) and getRoot(pchar) then
					Float.CFrame = getRoot(pchar).CFrame * CFrame.new(0,FloatValue,0)
				else
					FloatingFunc:Disconnect()
					Float:Destroy()
					qUp:Disconnect()
					eUp:Disconnect()
					qDown:Disconnect()
					eDown:Disconnect()
					floatDied:Disconnect()
				end
			end			
			FloatingFunc = runService.Heartbeat:Connect(FloatPadLoop)
		end)
	end
end)

addcmd('unfloat',{'nofloat','unplatform','noplatform'},function(args, speaker)
	Floating = false
	local pchar = speaker.Character
	notify('Float','Float Disabled')
	if pchar:FindFirstChild(floatName) then
		pchar:FindFirstChild(floatName):Destroy()
	end
end)

addcmd('togglefloat',{},function(args, speaker)
	if Floating then
		execCmd('unfloat')
	else
		execCmd('float')
	end
end)

addcmd('swim',{},function(args, speaker)
	if not swimming and speaker and speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid") then
		oldgrav = workspace.Gravity
		workspace.Gravity = 0
		local swimDied = function()
			workspace.Gravity = oldgrav
			swimming = false
		end
		local Humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
		local gravReset = Humanoid.Died:Connect(swimDied)
		local enums = Enum.HumanoidStateType:GetEnumItems()
		table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
		for i, v in pairs(enums) do
			Humanoid:SetStateEnabled(v, false)
		end
		Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		swimbeat = runService.Heartbeat:Connect(function()
			pcall(function()
				speaker.Character.HumanoidRootPart.Velocity = ((Humanoid.MoveDirection ~= Vector3.new() or userInputService:IsKeyDown(Enum.KeyCode.Space)) and speaker.Character.HumanoidRootPart.Velocity or Vector3.new())
			end)
		end)
		swimming = true
	end
end)

addcmd('unswim',{'noswim'},function(args, speaker)
	if speaker and speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid") then
		workspace.Gravity = oldgrav
		swimming = false
		if swimbeat ~= nil then
			swimbeat:Disconnect()
			swimbeat = nil
		end
		local Humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
		local enums = Enum.HumanoidStateType:GetEnumItems()
		table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
		for i, v in pairs(enums) do
			Humanoid:SetStateEnabled(v, true)
		end
	end
end)

addcmd('toggleswim',{},function(args, speaker)
	if swimming then
		execCmd('unswim')
	else
		execCmd('swim')
	end
end)

addcmd("jump", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
end)

addcmd("infjump", {"infinitejump"}, function(args, speaker)
	if infJump then infJump:Disconnect() end
	infJumpDebounce = false
	infJump = userInputService.JumpRequest:Connect(function()
		if not infJumpDebounce then
			infJumpDebounce = true
			speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
			wait()
			infJumpDebounce = false
		end
	end)
end)

addcmd("uninfjump", {"uninfinitejump", "noinfjump", "noinfinitejump"}, function(args, speaker)
	if infJump then infJump:Disconnect() end
	infJumpDebounce = false
end)

addcmd("flyjump", {}, function(args, speaker)
	if flyjump then flyjump:Disconnect() end
	flyjump = userInputService.JumpRequest:Connect(function()
		speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
	end)
end)

addcmd("unflyjump", {"noflyjump"}, function(args, speaker)
	if flyjump then flyjump:Disconnect() end
end)

local HumanModCons = {}
addcmd('autojump',{'ajump'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	local function autoJump()
		if Char and Human then
			local check1 = workspace:FindPartOnRay(Ray.new(Human.RootPart.Position-Vector3.new(0,1.5,0), Human.RootPart.CFrame.lookVector*3), Human.Parent)
			local check2 = workspace:FindPartOnRay(Ray.new(Human.RootPart.Position+Vector3.new(0,1.5,0), Human.RootPart.CFrame.lookVector*3), Human.Parent)
			if check1 or check2 then
				Human.Jump = true
			end
		end
	end
	autoJump()
	HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or runService.RenderStepped:Connect(autoJump)
	HumanModCons.ajCA = (HumanModCons.ajCA and HumanModCons.ajCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
		Char, Human = nChar, nChar:WaitForChild("Humanoid")
		autoJump()
		HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or runService.RenderStepped:Connect(autoJump)
	end)
end)

addcmd('unautojump',{'noautojump', 'noajump', 'unajump'},function(args, speaker)
	HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or nil
	HumanModCons.ajCA = (HumanModCons.ajCA and HumanModCons.ajCA:Disconnect() and false) or nil
end)

addcmd('edgejump',{'ejump'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	local state
	local laststate
	local lastcf
	local function edgejump()
		if Char and Human then
			laststate = state
			state = Human:GetState()
			if laststate ~= state and state == Enum.HumanoidStateType.Freefall and laststate ~= Enum.HumanoidStateType.Jumping then
				Char.HumanoidRootPart.CFrame = lastcf
				Char.HumanoidRootPart.Velocity = Vector3.new(Char.HumanoidRootPart.Velocity.X, Human.JumpPower or Human.JumpHeight, Char.HumanoidRootPart.Velocity.Z)
			end
			lastcf = Char.HumanoidRootPart.CFrame
		end
	end
	edgejump()
	HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or runService.RenderStepped:Connect(edgejump)
	HumanModCons.ejCA = (HumanModCons.ejCA and HumanModCons.ejCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
		Char, Human = nChar, nChar:WaitForChild("Humanoid")
		edgejump()
		HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or runService.RenderStepped:Connect(edgejump)
	end)
end)

addcmd('unedgejump',{'noedgejump', 'noejump', 'unejump'},function(args, speaker)
	HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or nil
	HumanModCons.ejCA = (HumanModCons.ejCA and HumanModCons.ejCA:Disconnect() and false) or nil
end)

addcmd('refresh',{'re'},function(args, speaker)
	refresh(speaker)
end)

addcmd('respawn',{},function(args, speaker)
	respawn(speaker)
end)

addcmd("copyanimationid", {"copyanimid", "copyemoteid"}, function(args, speaker)
    local copyAnimId = function(player)
        local found = "Animations Copied"
        for _, v in pairs(player.Character:FindFirstChildWhichIsA("Humanoid"):GetPlayingAnimationTracks()) do
            local animationId = v.Animation.AnimationId
            local assetId = animationId:find("rbxassetid://") and animationId:match("%d+")
            if not string.find(animationId, "507768375") and not string.find(animationId, "180435571") then
                if assetId then
                    found = found .. "\n\nAnimation Id: " .. animationId
                else
                    found = found .. "\n\nAnimation Id: " .. animationId
                end
            end
        end
        if found ~= "Animations Copied" then
            toClipboard(found)
        else
            notify("Animations", "No animations to copy")
        end
    end
    if args[1] then
        local players = getPlayer(args[1], speaker)
        if players[1] then
            copyAnimId(game:GetService("Players")[players[1]])
        end
    else
        copyAnimId(speaker)
    end
end)

addcmd('stopanimations',{'stopanims','stopanim'},function(args, speaker)
	local Char = speaker.Character
	local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
	for i,v in next, Hum:GetPlayingAnimationTracks() do
		v:Stop()
	end
end)

addcmd('refreshanimations', {'refreshanimation', 'refreshanims', 'refreshanim'}, function(args, speaker)
	local Char = speaker.Character or speaker.CharacterAdded:Wait()
	local Human = Char and Char:WaitForChild('Humanoid', 15)
	local Animate = Char and Char:WaitForChild('Animate', 15)
	if not Human or not Animate then
		return notify('Refresh Animations', 'Failed to get Animate/Humanoid')
	end
	Animate.Disabled = true
	for _, v in ipairs(Human:GetPlayingAnimationTracks()) do
		v:Stop()
	end
	Animate.Disabled = false
end)

addcmd('tpposition',{'tppos'},function(args, speaker)
	if #args < 3 then return end
	local tpX,tpY,tpZ = tonumber((args[1]:gsub(",", ""))),tonumber((args[2]:gsub(",", ""))),tonumber((args[3]:gsub(",", "")))
	local char = speaker.Character
	if char and getRoot(char) then
		getRoot(char).CFrame = CFrame.new(tpX,tpY,tpZ)
	end
end)

addcmd('offset',{},function(args, speaker)
	if #args < 3 then return end
	if speaker.Character then
		speaker.Character:TranslateBy(Vector3.new(tonumber(args[1]) or 0, tonumber(args[2]) or 0, tonumber(args[3]) or 0))
	end
end)

addcmd('getposition',{'getpos','notifypos','notifyposition'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		local char = game:GetService("Players")[v].Character
		local pos = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
		pos = pos and pos.Position
		if not pos then
			return notify('Getposition Error','Missing character')
		end
		local roundedPos = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
		notify('Current Position',roundedPos)
	end
end)

addcmd('copyposition',{'copypos'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		local char = game:GetService("Players")[v].Character
		local pos = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
		pos = pos and pos.Position
		if not pos then
			return notify('Getposition Error','Missing character')
		end
		local roundedPos = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
		toClipboard(roundedPos)
	end
end)

addcmd('speed',{'ws','walkspeed'},function(args, speaker)
    local speed = args[1] or 16
    if isNumber(speed) then
        speaker.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = speed
    end
end)

addcmd('jumppower',{'jp'},function(args, speaker)
    local power = args[1] or 50
    if isNumber(power) then
        if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
            speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = power
        else
            speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight = power
        end
    end
end)

addcmd('hipheight',{'hheight'},function(args, speaker)
    local height = args[1] or 0
    if isNumber(height) then
        speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight = height
    end
end)

addcmd('tools',{'gears'},function(args, speaker)
	local function copy(instance)
		for i,c in pairs(instance:GetChildren())do
			if c:IsA('Tool') or c:IsA('HopperBin') then
				c:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
			end
			copy(c)
		end
	end
	copy(game:GetService("Lighting"))
	copy(game:GetService("ReplicatedStorage"))
	notify('Tools','Copied tools from ReplicatedStorage and Lighting')
end)

addcmd('notools',{'rtools','clrtools','removetools','deletetools','dtools'},function(args, speaker)
	for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
end)

addcmd("console", {}, function(args, speaker)
    starterGui:SetCore("DevConsoleVisible", true)
end)

addcmd('oldconsole',{},function(args, speaker)
	
	notify("Loading",'Hold on a sec')
	local _, str = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/console.lua", true)
	end)

	local s, e = loadstring(str)
	if typeof(s) ~= "function" then
		return
	end

	local success, message = pcall(s)
	if (not success) then
		if printconsole then
			printconsole(message)
		elseif printoutput then
			printoutput(message)
		end
	end
	wait(1)
	notify('Console','Press F9 to open the console')
end)

addcmd("explorer", {"dex"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)

addcmd('olddex', {'odex'}, function(args, speaker)
	notify('Loading old explorer', 'Hold on a sec')

	local getobjects = function(a)
		local Objects = {}
		if a then
			local b = insertService:LoadLocalAsset(a)
			if b then 
				table.insert(Objects, b) 
			end
		end
		return Objects
	end

	local Dex = getobjects("rbxassetid://10055842438")[1]
	Dex.Parent = PARENT

	local function Load(Obj, Url)
		local function GiveOwnGlobals(Func, Script)
			local Fenv, RealFenv, FenvMt = {}, {
				script = Script,
				getupvalue = function(a, b)
					return nil
				end,
				getreg = function()
					return {}
				end,
				getprops = getprops or function(inst)
					if getproperties then
						local props = getproperties(inst)
						if props[1] and gethiddenproperty then
							local results = {}
							for _,name in pairs(props) do
								local success, res = pcall(gethiddenproperty, inst, name)
								if success then
									results[name] = res
								end
							end
							return results
						end
						return props
					end
					return {}
				end
			}, {}
			FenvMt.__index = function(a,b)
				return RealFenv[b] == nil and getgenv()[b] or RealFenv[b]
			end
			FenvMt.__newindex = function(a, b, c)
				if RealFenv[b] == nil then 
					getgenv()[b] = c 
				else 
					RealFenv[b] = c 
				end
			end
			setmetatable(Fenv, FenvMt)
			pcall(setfenv, Func, Fenv)
			return Func
		end

		local function LoadScripts(_, Script)
			if Script:IsA("LocalScript") then
				task.spawn(function()
					GiveOwnGlobals(loadstring(Script.Source,"="..Script:GetFullName()), Script)()
				end)
			end
			table.foreach(Script:GetChildren(), LoadScripts)
		end

		LoadScripts(nil, Obj)
	end

	Load(Dex)
end)

addcmd('remotespy',{'rspy'},function(args, speaker)
	notify("Loading",'Hold on a sec')
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
end)

addcmd('audiologger',{'alogger'},function(args, speaker)
	notify("Loading",'Hold on a sec')
	loadstring(game:HttpGet(('https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua'),true))()
end)

addcmd('discord', {'support', 'help'}, function(args, speaker)
	if everyClipboard or setclipboard or toclipboard then
		toClipboard('https://discord.gg/XVmJgHk3RG')
		notify('Discord Invite', 'Copied to clipboard!\nhttps://discord.gg/XVmJgHk3RG')
	else
		notify('Discord Invite', 'discord.gg/XVmJgHk3RG')
	end
	if httpRequest or httprequest or request or http_request then
		local reqfunc = httpRequest or httprequest or request or http_request
		pcall(function()
			reqfunc({
				Url = 'http://127.0.0.1:6463/rpc?v=1',
				Method = 'POST',
				Headers = {
					['Content-Type'] = 'application/json',
					Origin = 'https://discord.com'
				},
				Body = httpService:JSONEncode({
					cmd = 'INVITE_BROWSER',
					nonce = httpService:GenerateGUID(false),
					args = {code = 'XVmJgHk3RG'}
				})
			})
		end)
	end
end)

addcmd('chat',{'say'},function(args, speaker)
	local cString = getstring(1)
	chatMessage(cString)
end)

local spamming = false
local spamspeed = 1
addcmd('spam',{},function(args, speaker)
	spamming = true
	local spamstring = getstring(1)
	repeat wait(spamspeed)
		chatMessage(spamstring)
	until spamming == false
end)

addcmd('nospam',{'unspam'},function(args, speaker)
	spamming = false
end)

addcmd('spamspeed',{},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		spamspeed = speed
	end
end)

addcmd('friend',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		speaker:RequestFriendship(game:GetService("Players")[v])
	end
end)

addcmd('unfriend',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		speaker:RevokeFriendship(game:GetService("Players")[v])
	end
end)

addcmd('bringpart',{},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1):lower() and v:IsA("BasePart") then
			v.CFrame = getRoot(speaker.Character).CFrame
		end
	end
end)

addcmd('gotopart',{'topart'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1):lower() and v:IsA("BasePart") then
			getRoot(speaker.Character).CFrame = v.CFrame
		end
	end
end)

addcmd('notifyping',{'ping'},function(args, speaker)
	notify("Ping", math.round(speaker:GetNetworkPing() * 1000) .. "ms")
end)

addcmd("jobid", {}, function(args, speaker)
    toClipboard("roblox://placeId=" .. placeId .. "&gameInstanceId=" .. jobId)
    notify("JobId", "Copied to clipboard")
end)

addcmd('notifyjobid',{},function(args, speaker)
	notify('JobId / PlaceId', jobId..' / '..placeId)
end)

addcmd('gametp',{'gameteleport'},function(args, speaker)
	teleportService:Teleport(args[1])
end)

addcmd("rejoin", {"rj"}, function(args, speaker)
	if #players:GetPlayers() <= 1 then
		players.LocalPlayer:Kick("\nRejoining...")
		wait()
		teleportService:Teleport(placeId, players.LocalPlayer)
	else
		teleportService:TeleportToPlaceInstance(placeId, jobId, players.LocalPlayer)
	end
end)

addcmd("autorejoin", {"autorj"}, function(args, speaker)
	guiService.ErrorMessageChanged:Connect(function()
		execCmd("rejoin")
	end)
	notify("Auto Rejoin", "Auto rejoin enabled")
end)

addcmd("serverhop", {"shop"}, function(args, speaker)
    notify("Serverhop", "Searching for a server...")
    local servers = {}
    local req = game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
    local body = httpService:JSONDecode(req)

    if body and body.data then
        for i, v in next, body.data do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= jobId then
                table.insert(servers, 1, v.id)
            end
        end
    end

    if #servers > 0 then
        teleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], players.LocalPlayer)
    else
        notify("Serverhop", "Couldn't find a server.")
    end
end)

addcmd("exit", {}, function(args, speaker)
    game:Shutdown()
end)

addcmd("view", {"spectate", "watch"}, function(args, speaker)
    local p = getPlayer(args[1], speaker)
    if p[1] then
        local target = players[p[1]]
        if target and target.Character then
            workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
            notify("View", "Viewing " .. target.Name)
        end
    end
end)

addcmd("unview", {"unspectate", "unwatch"}, function(args, speaker)
    if speaker.Character then
        workspace.CurrentCamera.CameraSubject = speaker.Character:FindFirstChildOfClass("Humanoid")
        notify("View", "View reset")
    end
end)

addcmd('logs',{'chatlogs'},function(args, speaker)
    if writefile then
        local logs = ""
        if isLegacyChat then
            -- Legacy chat log collection (simplified)
            logs = "Chat logs not fully implemented for legacy chat in this version."
        else
             -- TextChatService log collection (simplified)
             logs = "Chat logs not fully implemented for TextChatService in this version."
        end
        notify('Chat Logs', 'Chat logging is not fully implemented yet.')
    else
        notify('Chat Logs','Your exploit does not support write file.')
    end
end)

local coreGuiTypeNames = {
	["inventory"] = Enum.CoreGuiType.Backpack,
	["leaderboard"] = Enum.CoreGuiType.PlayerList,
	["emotes"] = Enum.CoreGuiType.EmotesMenu,
    ["chat"] = Enum.CoreGuiType.Chat,
    ["all"] = Enum.CoreGuiType.All
}

addcmd('enable',{},function(args, speaker)
	local input = args[1] and args[1]:lower()
	if input then
		if input == "reset" then
			game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
		else
			local coreGuiType = coreGuiTypeNames[input]
			if coreGuiType then
				game:GetService("StarterGui"):SetCoreGuiEnabled(coreGuiType, true)
			end
		end
	end
end)

addcmd('disable',{},function(args, speaker)
	local input = args[1] and args[1]:lower()
	if input then
		if input == "reset" then
			game:GetService("StarterGui"):SetCore("ResetButtonCallback", false)
		else
			local coreGuiType = coreGuiTypeNames[input]
			if coreGuiType then
				game:GetService("StarterGui"):SetCoreGuiEnabled(coreGuiType, false)
			end
		end
	end
end)

local invisGUIS = {}
addcmd('showguis',{},function(args, speaker)
	for i,v in pairs(speaker.PlayerGui:GetDescendants()) do
		if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame")) and not v.Visible then
			v.Visible = true
			if not FindInTable(invisGUIS,v) then
				table.insert(invisGUIS,v)
			end
		end
	end
end)

addcmd('unshowguis',{},function(args, speaker)
	for i,v in pairs(invisGUIS) do
		v.Visible = false
	end
	invisGUIS = {}
end)

local hiddenGUIS = {}
addcmd('hideguis',{},function(args, speaker)
	for i,v in pairs(speaker.PlayerGui:GetDescendants()) do
		if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame")) and v.Visible then
			v.Visible = false
			if not FindInTable(hiddenGUIS,v) then
				table.insert(hiddenGUIS,v)
			end
		end
	end
end)

addcmd('unhideguis',{},function(args, speaker)
	for i,v in pairs(hiddenGUIS) do
		v.Visible = true
	end
	hiddenGUIS = {}
end)

local deleteGuiInput
addcmd('guidelete',{},function(args, speaker)
	deleteGuiInput = userInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if not gameProcessedEvent then
			if input.KeyCode == Enum.KeyCode.Backspace then
                local guisAtPosition = speaker.PlayerGui:GetGuiObjectsAtPosition(IYMouse.X, IYMouse.Y)
                for _, gui in pairs(guisAtPosition) do
                    if gui.Visible == true then
                        gui:Destroy()
                    end
                end
			end
		end
	end)
	notify('GUI Delete Enabled','Hover over a GUI and press backspace to delete it')
end)

addcmd('unguidelete',{'noguidelete'},function(args, speaker)
	if deleteGuiInput then deleteGuiInput:Disconnect() end
	notify('GUI Delete Disabled','GUI backspace delete has been disabled')
end)

addcmd('hideiy',{},function(args, speaker)
    if Holder then Holder.Visible = false end
    if Notification then Notification.Visible = false end
end)

addcmd('showiy',{'unhideiy'},function(args, speaker)
    if Holder then Holder.Visible = true end
    if Notification then Notification.Visible = true end
end)

addcmd('rec', {'record'}, function(args, speaker)
	game:GetService("CoreGui"):ToggleRecording()
end)

addcmd('screenshot', {'scrnshot'}, function(args, speaker)
	game:GetService("CoreGui"):TakeScreenshot()
end)

addcmd('togglefs', {'togglefullscreen'}, function(args, speaker)
	game:GetService("GuiService"):ToggleFullscreen()
end)

addcmd('inspect', {'examine'}, function(args, speaker)
	for _, v in ipairs(getPlayer(args[1], speaker)) do
		game:GetService("GuiService"):CloseInspectMenu()
		game:GetService("GuiService"):InspectPlayerFromUserId(players[v].UserId)
	end
end)

addcmd("savegame", {"saveplace"}, function(args, speaker)
    if saveinstance then
        notify("Loading", "Downloading game. This will take a while")
        saveinstance()
        notify("Saved", "Game saved")
    else
        notify("Error", "Your exploit does not support saveinstance")
    end
end)

addcmd('vehiclenoclip',{'vnoclip'},function(args, speaker)
	if speaker.Character then
		for i,v in pairs(speaker.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

addcmd('vehicleclip',{'vclip','unvnoclip'},function(args, speaker)
	if speaker.Character then
		for i,v in pairs(speaker.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = true
			end
		end
	end
end)

addcmd('antilag',{'boostfps','lowgraphics'},function(args, speaker)
    local terrain = workspace:FindFirstChildOfClass('Terrain')
    terrain.WaterWaveSize = 0
    terrain.WaterWaveSpeed = 0
    terrain.WaterReflectance = 0
    terrain.WaterTransparency = 0
    game:GetService("Lighting").GlobalShadows = false
    game:GetService("Lighting").FogEnd = 9e9
    game:GetService("Lighting").Brightness = 0
    settings().Rendering.QualityLevel = "Level01"
    for i,v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
            v.Material = "Plastic"
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("MeshPart") then
            v.Material = "Plastic"
            v.Reflectance = 0
            v.TextureID = 10385902758728957
        end
    end
    notify('Anti Lag','Low graphics enabled')
end)

addcmd('fixcam',{},function(args, speaker)
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    if speaker.Character and speaker.Character:FindFirstChildOfClass("Humanoid") then
        workspace.CurrentCamera.CameraSubject = speaker.Character:FindFirstChildOfClass("Humanoid")
    end
    workspace.CurrentCamera.FieldOfView = 70
end)

addcmd('clientbring',{'cbring'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if game:GetService("Players")[v].Character ~= nil then
			if game:GetService("Players")[v].Character:FindFirstChildOfClass('Humanoid') then
				game:GetService("Players")[v].Character:FindFirstChildOfClass('Humanoid').Sit = false
			end
			wait()
			getRoot(game:GetService("Players")[v].Character).CFrame = getRoot(speaker.Character).CFrame + Vector3.new(3,1,0)
		end
	end
end)

local bringT = {}
addcmd('loopbring',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			if game:GetService("Players")[v].Name ~= speaker.Name and not FindInTable(bringT, game:GetService("Players")[v].Name) then
				table.insert(bringT, game:GetService("Players")[v].Name)
				local plrName = game:GetService("Players")[v].Name
				local pchar=game:GetService("Players")[v].Character
				local distance = 3
				if args[2] and isNumber(args[2]) then
					distance = args[2]
				end
				local lDelay = 0
				if args[3] and isNumber(args[3]) then
					lDelay = args[3]
				end
				repeat
					for i,c in pairs(players) do
						if game:GetService("Players"):FindFirstChild(v) then
							pchar = game:GetService("Players")[v].Character
							if pchar~= nil and game:GetService("Players")[v].Character ~= nil and getRoot(pchar) and speaker.Character ~= nil and getRoot(speaker.Character) then
								getRoot(pchar).CFrame = getRoot(speaker.Character).CFrame + Vector3.new(distance,1,0)
							end
							wait(lDelay)
						else 
							for a,b in pairs(bringT) do if b == plrName then table.remove(bringT, a) end end
						end
					end
				until not FindInTable(bringT, plrName)
			end
		end)
	end
end)

addcmd('unloopbring',{'noloopbring'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			for a,b in pairs(bringT) do if b == game:GetService("Players")[v].Name then table.remove(bringT, a) end end
		end)
	end
end)

addcmd('freeze',{'fr'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, game:GetService("Players")[v].Character:GetDescendants() do
					if x:IsA("BasePart") and not x.Anchored then
						x.Anchored = true
					end
				end
			end)
		end
	end
end)

addcmd('thaw',{'unfreeze','unfr'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, game:GetService("Players")[v].Character:GetDescendants() do
					if x.Name ~= floatName and x:IsA("BasePart") and x.Anchored then
						x.Anchored = false
					end
				end
			end)
		end
	end
end)

local oofing = false
addcmd('loopoof',{},function(args, speaker)
	oofing = true
	repeat wait(0.1)
		for i,v in pairs(game:GetService("Players"):GetPlayers()) do
			if v.Character ~= nil and v.Character:FindFirstChild('Head') then
				for _,x in pairs(v.Character.Head:GetChildren()) do
					if x:IsA'Sound' then x.Playing = true end
				end
			end
		end
	until oofing == false
end)

addcmd('unloopoof',{},function(args, speaker)
	oofing = false
end)

addcmd('muteboombox',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, game:GetService("Players")[v].Character:GetDescendants() do
					if x:IsA("Sound") and x.Playing == true then
						x.Playing = false
					end
				end
				for i, x in next, game:GetService("Players")[v]:FindFirstChildOfClass("Backpack"):GetDescendants() do
					if x:IsA("Sound") and x.Playing == true then
						x.Playing = false
					end
				end
			end)
		end
	end
end)

addcmd('unmuteboombox',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, game:GetService("Players")[v].Character:GetDescendants() do
					if x:IsA("Sound") and x.Playing == false then
						x.Playing = true
					end
				end
			end)
		end
	end
end)

addcmd("reset", {}, function(args, speaker)
    local humanoid = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Dead)
    else
        speaker.Character:BreakJoints()
    end
end)

addcmd('freezeanims',{},function(args, speaker)
	local Humanoid = speaker.Character:FindFirstChildOfClass("Humanoid") or speaker.Character:FindFirstChildOfClass("AnimationController")
	local ActiveTracks = Humanoid:GetPlayingAnimationTracks()
	for _, v in pairs(ActiveTracks) do
		v:AdjustSpeed(0)
	end
end)

addcmd('unfreezeanims',{},function(args, speaker)
	local Humanoid = speaker.Character:FindFirstChildOfClass("Humanoid") or speaker.Character:FindFirstChildOfClass("AnimationController")
	local ActiveTracks = Humanoid:GetPlayingAnimationTracks()
	for _, v in pairs(ActiveTracks) do
		v:AdjustSpeed(1)
	end
end)

local orbit1, orbit2, orbit3, orbit4
addcmd("orbit", {}, function(args, speaker)
    execCmd("unorbit nonotify")
    local target = game:GetService("Players"):FindFirstChild(getPlayer(args[1], speaker)[1])
    local root = getRoot(speaker.Character)
    local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
    if target and target.Character and getRoot(target.Character) and root and humanoid then
        local rotation = 0
        local speed = tonumber(args[2]) or 0.2
        local distance = tonumber(args[3]) or 6
        orbit1 = runService.Heartbeat:Connect(function()
            pcall(function()
                rotation = rotation + speed
                root.CFrame = CFrame.new(getRoot(target.Character).Position) * CFrame.Angles(0, math.rad(rotation), 0) * CFrame.new(distance, 0, 0)
            end)
        end)
        orbit2 = runService.RenderStepped:Connect(function()
            pcall(function()
                root.CFrame = CFrame.new(root.Position, getRoot(target.Character).Position)
            end)
        end)
        orbit3 = humanoid.Died:Connect(function() execCmd("unorbit") end)
        orbit4 = humanoid.Seated:Connect(function(value) if value then execCmd("unorbit") end end)
        notify("Orbit", "Started orbiting " .. target.Name)
    end
end)

addcmd("unorbit", {}, function(args, speaker)
    if orbit1 then orbit1:Disconnect() end
    if orbit2 then orbit2:Disconnect() end
    if orbit3 then orbit3:Disconnect() end
    if orbit4 then orbit4:Disconnect() end
    if args[1] ~= "nonotify" then notify("Orbit", "Stopped orbiting player") end
end)

local invisRunning = false
addcmd('invisible',{'invis'},function(args, speaker)
	if invisRunning then return end
	invisRunning = true
	local Player = speaker
	repeat wait(.1) until Player.Character
	local Character = Player.Character
	Character.Archivable = true
	local IsInvis = false
	local IsRunning = true
	local InvisibleCharacter = Character:Clone()
	InvisibleCharacter.Parent = game:GetService("Lighting")
	local Void = workspace.FallenPartsDestroyHeight
	InvisibleCharacter.Name = ""
	local CF

	local invisFix = runService.Stepped:Connect(function()
		pcall(function()
			local IsInteger
			if tostring(Void):find'-' then
				IsInteger = true
			else
				IsInteger = false
			end
			local Pos = Player.Character.HumanoidRootPart.Position
			local Pos_String = tostring(Pos)
			local Pos_Seperate = Pos_String:split(', ')
			local X = tonumber(Pos_Seperate[1])
			local Y = tonumber(Pos_Seperate[2])
			local Z = tonumber(Pos_Seperate[3])
			if IsInteger == true then
				if Y <= Void then
					Respawn()
				end
			elseif IsInteger == false then
				if Y >= Void then
					Respawn()
				end
			end
		end)
	end)

	for i,v in pairs(InvisibleCharacter:GetDescendants())do
		if v:IsA("BasePart") then
			if v.Name == "HumanoidRootPart" then
				v.Transparency = 1
			else
				v.Transparency = .5
			end
		end
	end

	function Respawn()
		IsRunning = false
		if IsInvis == true then
			pcall(function()
				Player.Character = Character
				wait()
				Character.Parent = workspace
				Character:FindFirstChildWhichIsA'Humanoid':Destroy()
				IsInvis = false
				InvisibleCharacter.Parent = nil
				invisRunning = false
			end)
		elseif IsInvis == false then
			pcall(function()
				Player.Character = Character
				wait()
				Character.Parent = workspace
				Character:FindFirstChildWhichIsA'Humanoid':Destroy()
				TurnVisible()
			end)
		end
	end

	local invisDied
	invisDied = InvisibleCharacter:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
		Respawn()
		invisDied:Disconnect()
	end)

	if IsInvis == true then return end
	IsInvis = true
	CF = workspace.CurrentCamera.CFrame
	local CF_1 = Player.Character.HumanoidRootPart.CFrame
	Character:MoveTo(Vector3.new(0,math.pi*1000000,0))
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	wait(.2)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	InvisibleCharacter = InvisibleCharacter
	Character.Parent = game:GetService("Lighting")
	InvisibleCharacter.Parent = workspace
	InvisibleCharacter.HumanoidRootPart.CFrame = CF_1
	Player.Character = InvisibleCharacter
	execCmd('fixcam')
	Player.Character.Animate.Disabled = true
	Player.Character.Animate.Disabled = false

	function TurnVisible()
		if IsInvis == false then return end
		invisFix:Disconnect()
		invisDied:Disconnect()
		CF = workspace.CurrentCamera.CFrame
		Character = Character
		local CF_1 = Player.Character.HumanoidRootPart.CFrame
		Character.HumanoidRootPart.CFrame = CF_1
		InvisibleCharacter:Destroy()
		Player.Character = Character
		Character.Parent = workspace
		IsInvis = false
		Player.Character.Animate.Disabled = true
		Player.Character.Animate.Disabled = false
		invisDied = Character:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
			Respawn()
			invisDied:Disconnect()
		end)
	end
end)

addcmd('visible',{},function(args, speaker)
    if TurnVisible then
        TurnVisible()
    end
end)

addcmd('bang',{},function(args, speaker)
    local players = getPlayer(args[1], speaker)
    for i,v in pairs(players) do
        local target = game:GetService("Players")[v]
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://148840371"
        local track = speaker.Character.Humanoid:LoadAnimation(anim)
        track:Play(.1, 1, 1)
        local bangLoop
        bangLoop = runService.Heartbeat:Connect(function()
            if not track.IsPlaying then bangLoop:Disconnect() end
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") and speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart") then
                speaker.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,1.1)
            else
                bangLoop:Disconnect()
            end
        end)
    end
end)

addcmd('unbang',{},function(args, speaker)
    for i,v in pairs(speaker.Character.Humanoid:GetPlayingAnimationTracks()) do
        if v.Animation.AnimationId == "rbxassetid://148840371" then
            v:Stop()
        end
    end
end)

addcmd('kill',{},function(args, speaker)
    local players = getPlayer(args[1], speaker)
    for i,v in pairs(players) do
        local target = game:GetService("Players")[v]
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            if speaker.Backpack:FindFirstChildOfClass("Tool") or speaker.Character:FindFirstChildOfClass("Tool") then
                local tool = speaker.Character:FindFirstChildOfClass("Tool") or speaker.Backpack:FindFirstChildOfClass("Tool")
                tool.Parent = speaker.Character
                tool:Activate()
                local oldPos = speaker.Character.HumanoidRootPart.CFrame
                local killLoop
                local startTime = tick()
                killLoop = runService.Heartbeat:Connect(function()
                    if tick() - startTime > 5 or not target.Character or not target.Character:FindFirstChild("Humanoid") or target.Character.Humanoid.Health <= 0 then
                        killLoop:Disconnect()
                        speaker.Character.HumanoidRootPart.CFrame = oldPos
                    else
                        speaker.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,1)
                    end
                end)
            else
                notify("Kill", "You need a tool to kill players")
            end
        end
    end
end)

local tweenSpeed = 1
addcmd('tweenspeed',{'tspeed'},function(args, speaker)
	local newSpeed = args[1] or 1
	if tonumber(newSpeed) then
		tweenSpeed = tonumber(newSpeed)
	end
end)

addcmd('tweentpposition',{'tweentppos'},function(args, speaker)
	if #args < 3 then return end
	local tpX,tpY,tpZ = tonumber((args[1]:gsub(",", ""))),tonumber((args[2]:gsub(",", ""))),tonumber((args[3]:gsub(",", "")))
	local char = speaker.Character
	if char and getRoot(char) then
		game:GetService("TweenService"):Create(getRoot(char), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(tpX,tpY,tpZ)}):Play()
	end
end)

addcmd('tweenoffset',{'toffset'},function(args, speaker)
	if #args < 3 then return end
	if speaker.Character and getRoot(speaker.Character) then
        local currentPos = getRoot(speaker.Character).Position
        local offset = Vector3.new(tonumber(args[1]) or 0, tonumber(args[2]) or 0, tonumber(args[3]) or 0)
		game:GetService("TweenService"):Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(currentPos + offset)}):Play()
	end
end)

addcmd("copyanimationid", {"copyanimid", "copyemoteid"}, function(args, speaker)
    local copyAnimId = function(player)
        local found = "Animations Copied"
        if player.Character and player.Character:FindFirstChildWhichIsA("Humanoid") then
            for _, v in pairs(player.Character:FindFirstChildWhichIsA("Humanoid"):GetPlayingAnimationTracks()) do
                local animationId = v.Animation.AnimationId
                local assetId = animationId:find("rbxassetid://") and animationId:match("%d+")
                found = found .. "\n\nAnimation Id: " .. animationId
            end
        end

        if found ~= "Animations Copied" then
            toClipboard(found)
            notify("Animations", "Copied to clipboard")
        else
            notify("Animations", "No animations to copy")
        end
    end

    if args[1] then
        local p = getPlayer(args[1], speaker)
        if p[1] then
            copyAnimId(game:GetService("Players")[p[1]])
        end
    else
        copyAnimId(speaker)
    end
end)

addcmd('stopanimations',{'stopanims','stopanim'},function(args, speaker)
	local Char = speaker.Character
	local Hum = Char and (Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController"))
    if Hum then
        for i,v in next, Hum:GetPlayingAnimationTracks() do
            v:Stop()
        end
    end
end)

addcmd('refreshanimations', {'refreshanimation', 'refreshanims', 'refreshanim'}, function(args, speaker)
	local Char = speaker.Character or speaker.CharacterAdded:Wait()
	local Human = Char and Char:WaitForChild('Humanoid', 15)
	local Animate = Char and Char:WaitForChild('Animate', 15)
	if not Human or not Animate then
		return notify('Refresh Animations', 'Failed to get Animate/Humanoid')
	end
	Animate.Disabled = true
	for _, v in ipairs(Human:GetPlayingAnimationTracks()) do
		v:Stop()
	end
	Animate.Disabled = false
end)

addcmd('tpposition',{'tppos'},function(args, speaker)
	if #args < 3 then return end
	local tpX,tpY,tpZ = tonumber((args[1]:gsub(",", ""))),tonumber((args[2]:gsub(",", ""))),tonumber((args[3]:gsub(",", "")))
	local char = speaker.Character
	if char and getRoot(char) then
		getRoot(char).CFrame = CFrame.new(tpX,tpY,tpZ)
	end
end)

addcmd('offset',{},function(args, speaker)
	if #args < 3 then
		return 
	end
	if speaker.Character then
		speaker.Character:TranslateBy(Vector3.new(tonumber(args[1]) or 0, tonumber(args[2]) or 0, tonumber(args[3]) or 0))
	end
end)

addcmd('getposition',{'getpos','notifypos','notifyposition'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		local char = game:GetService("Players")[v].Character
		local pos = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
		pos = pos and pos.Position
		if not pos then
			return notify('Getposition Error','Missing character')
		end
		local roundedPos = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
		notify('Current Position',roundedPos)
	end
end)

addcmd('copyposition',{'copypos'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		local char = game:GetService("Players")[v].Character
		local pos = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
		pos = pos and pos.Position
		if not pos then
			return notify('Getposition Error','Missing character')
		end
		local roundedPos = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
		toClipboard(roundedPos)
        notify("Position", "Copied to clipboard")
	end
end)

addcmd('speed',{'ws','walkspeed'},function(args, speaker)
	if args[2] then
		local speed = args[2] or 16
		if isNumber(speed) then
			speaker.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = speed
		end
	else
		local speed = args[1] or 16
		if isNumber(speed) then
			speaker.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = speed
		end
	end
end)

addcmd('jumppower',{'jp'},function(args, speaker)
	local jpower = args[1] or 50
	if isNumber(jpower) then
		if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = jpower
		else
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight  = jpower
		end
	end
end)

addcmd('hipheight',{'hheight'},function(args, speaker)
	local height = args[1] or 0
	if isNumber(height) then
		speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight = height
	end
end)

addcmd('tools',{'gears'},function(args, speaker)
	local function copy(instance)
		for i,c in pairs(instance:GetChildren())do
			if c:IsA('Tool') or c:IsA('HopperBin') then
				c:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
			end
			copy(c)
		end
	end
	copy(game:GetService("Lighting"))
	local function copy(instance)
		for i,c in pairs(instance:GetChildren())do
			if c:IsA('Tool') or c:IsA('HopperBin') then
				c:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
			end
			copy(c)
		end
	end
	copy(game:GetService("ReplicatedStorage"))
	notify('Tools','Copied tools from ReplicatedStorage and Lighting')
end)

addcmd('notools',{'rtools','clrtools','removetools','deletetools','dtools'},function(args, speaker)
	for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
end)

addcmd('light',{},function(args, speaker)
	local light = Instance.new("PointLight")
	light.Parent = getRoot(speaker.Character)
	light.Range = 30
	if args[1] then
		light.Brightness = args[2]
		light.Range = args[1]
	else
		light.Brightness = 5
	end
end)

addcmd('unlight',{'nolight'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.ClassName == "PointLight" then
			v:Destroy()
		end
	end
end)

addcmd('fullbright',{'fb','fullbrightness'},function(args, speaker)
	game:GetService("Lighting").Brightness = 2
	game:GetService("Lighting").ClockTime = 14
	game:GetService("Lighting").FogEnd = 100000
	game:GetService("Lighting").GlobalShadows = false
	game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end)

addcmd('day',{},function(args, speaker)
	game:GetService("Lighting").ClockTime = 14
end)

addcmd('night',{},function(args, speaker)
	game:GetService("Lighting").ClockTime = 0
end)

addcmd('nofog',{},function(args, speaker)
	game:GetService("Lighting").FogEnd = 100000
	for i,v in pairs(game:GetService("Lighting"):GetDescendants()) do
		if v:IsA("Atmosphere") then
			v:Destroy()
		end
	end
end)

addcmd('drophats',{'drophat'},function(args, speaker)
	if speaker.Character then
		for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
			v.Parent = workspace
		end
	end
end)

addcmd('deletehats',{'nohats','rhats'},function(args, speaker)
	for i,v in next, speaker.Character:GetDescendants() do
		if v:IsA("Accessory") then
			v:Destroy()
		end
	end
end)

addcmd('droptools',{'droptool'},function(args, speaker)
	for i,v in pairs(speaker.Backpack:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = speaker.Character
		end
	end
	wait()
	for i,v in pairs(speaker.Character:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = workspace
		end
	end
end)

addcmd('equiptools',{},function(args, speaker)
	for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
		if v:IsA("Tool") or v:IsA("HopperBin") then
			v.Parent = speaker.Character
		end
	end
end)

addcmd('unequiptools',{},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
end)

addcmd('spawnpoint',{'spawn'},function(args, speaker)
    local spawnpos = getRoot(speaker.Character).CFrame
    local spDelay = tonumber(args[1]) or 0.1
    notify('Spawn Point','Spawn point created at '..tostring(spawnpos))
    task.spawn(function()
        while true do
            wait(spDelay)
            if speaker.Character and speaker.Character:FindFirstChild("Humanoid") and speaker.Character.Humanoid.Health <= 0 then
                speaker.CharacterAdded:Wait()
                wait(0.1)
                getRoot(speaker.Character).CFrame = spawnpos
            end
        end
    end)
end)

addcmd('flashback',{'diedtp'},function(args, speaker)
    notify("Flashback", "Not fully implemented yet")
end)

end -- End of SPLIT SCOPE 1: Command Definitions

local siriusValues = {
	siriusVersion = "1.26",
	siriusName = "Sirius",
	releaseType = "Stable",
	siriusFolder = "Sirius",
	settingsFile = "settings.srs",
	interfaceAsset = 14183548964,
	cdn = "https://cdn.sirius.menu/SIRIUS-SCRIPT-CORE-ASSETS/",
	icons = "https://cdn.sirius.menu/SIRIUS-SCRIPT-CORE-ASSETS/Icons/",
	enableExperienceSync = false, -- Games are no longer available due to a lack of whitelisting, they may be made open source at a later date, however they are patched as of now and are useless to the end user. Turning this on may introduce "fake functionality".
	games = {
		BreakingPoint = {
			name = "Breaking Point",
			description = "Players are seated around a table. Their only goal? To be the last one standing. Execute this script to gain an unfair advantage.",
			id = 648362523,
			enabled = true,
			raw = "BreakingPoint",
			minimumTier = "Free",
		},
		MurderMystery2 = {
			name = "Murder Mystery 2",
			description = "A murder has occured, will you be the one to find the murderer, or kill your next victim? Execute this script to gain an unfair advantage.",
			id = 142823291,
			enabled = true,
			raw = "MurderMystery2",
			minimumTier = "Free",
		},
		TowerOfHell = {
			name = "Tower Of Hell",
			description = "A difficult popular parkouring game, with random levels and modifiers. Execute this script to gain an unfair advantage.",
			id = 1962086868,
			enabled = true,
			raw = "TowerOfHell",
			minimumTier = "Free",
		},
		Strucid = {
			name = "Strucid",
			description = "Fight friends and enemies in Strucid with building mechanics! Execute this script to gain an unfair advantage.",
			id = 2377868063,
			enabled = true,
			raw = "Strucid",
			minimumTier = "Free",
		},
		PhantomForces = {
			name = "Phantom Forces",
			description = "One of the most popular FPS shooters from the team at StyLiS Studios. Execute this script to gain an unfair advantage.",
			id = 292439477,
			enabled = true,
			raw = "PhantomForces",
			minimumTier = "Pro",
		},
	},
	rawTree = "https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/Sirius/games/",
	neonModule = "https://raw.githubusercontent.com/shlexware/Sirius/request/library/neon.lua",
	senseRaw = "https://raw.githubusercontent.com/shlexware/Sirius/request/library/sense/source.lua",
	executors = {"synapse x", "script-ware", "krnl", "scriptware", "comet", "valyse", "fluxus", "electron", "hydrogen"},
	disconnectTypes = { {"ban", {"ban", "perm"}}, {"network", {"internet connection", "network"}} },
	nameGeneration = {
		adjectives = {"Cool", "Awesome", "Epic", "Ninja", "Super", "Mystic", "Swift", "Golden", "Diamond", "Silver", "Mint", "Roblox", "Amazing"},
		nouns = {"Player", "Gamer", "Master", "Legend", "Hero", "Ninja", "Wizard", "Champion", "Warrior", "Sorcerer"}
	},
	administratorRoles = {"mod","admin","staff","dev","founder","owner","supervis","manager","management","executive","president","chairman","chairwoman","chairperson","director"},
	transparencyProperties = {
		UIStroke = {'Transparency'},
		Frame = {'BackgroundTransparency'},
		TextButton = {'BackgroundTransparency', 'TextTransparency'},
		TextLabel = {'BackgroundTransparency', 'TextTransparency'},
		TextBox = {'BackgroundTransparency', 'TextTransparency'},
		ImageLabel = {'BackgroundTransparency', 'ImageTransparency'},
		ImageButton = {'BackgroundTransparency', 'ImageTransparency'},
		ScrollingFrame = {'BackgroundTransparency', 'ScrollBarImageTransparency'}
	},
	buttonPositions = {Character = UDim2.new(0.5, -155, 1, -29), Scripts = UDim2.new(0.5, -122, 1, -29), Playerlist = UDim2.new(0.5, -68, 1, -29)},
	chatSpy = {
		enabled = true,
		visual = {
			Color = Color3.fromRGB(26, 148, 255),
			Font = Enum.Font.SourceSansBold,
			TextSize = 18
		},
	},
	pingProfile = {
		recentPings = {},
		adaptiveBaselinePings = {},
		pingNotificationCooldown = 0,
		maxSamples = 12, -- max num of recent pings stored
		spikeThreshold = 1.75, -- high Ping in comparison to average ping (e.g 100 avg would be high at 150)
		adaptiveBaselineSamples = 30, -- how many samples Sirius takes before deciding on a fixed high ping value
		adaptiveHighPingThreshold = 120 -- default value
	},
	frameProfile = {
		frameNotificationCooldown = 0,
		fpsQueueSize = 10,
		lowFPSThreshold = 20, -- what's low fps!??!?!
		totalFPS = 0,
		fpsQueue = {},
	},
	actions = {
		{
			name = "Noclip",
			images = {14385986465, 9134787693},
			color = Color3.fromRGB(0, 170, 127),
			enabled = false,
			rotateWhileEnabled = false,
			callback = function() end,
		},
		{
			name = "Flight",
			images = {9134755504, 14385992605},
			color = Color3.fromRGB(170, 37, 46),
			enabled = false,
			rotateWhileEnabled = false,
			callback = function(value)
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.PlatformStand = value
				end
			end,
		},
		{
			name = "Refresh",
			images = {9134761478, 9134761478},
			color = Color3.fromRGB(61, 179, 98),
			enabled = false,
			rotateWhileEnabled = true,
			disableAfter = 3,
			callback = function()
				task.spawn(function()
					local character = localPlayer.Character
					if character then
						local cframe = character:GetPivot()
						local humanoid = character:FindFirstChildOfClass("Humanoid")
						if humanoid then
							humanoid:ChangeState(Enum.HumanoidStateType.Dead)
						end
						character = localPlayer.CharacterAdded:Wait()
						task.defer(character.PivotTo, character, cframe)
					end
				end)
			end,
		},
		{
			name = "Respawn",
			images = {9134762943, 9134762943},
			color = Color3.fromRGB(49, 88, 193),
			enabled = false,
			rotateWhileEnabled = true,
			disableAfter = 2,
			callback = function()
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				end
			end,
		},
		{
			name = "Invulnerability",
			images = {9134765994, 14386216487},
			color = Color3.fromRGB(193, 46, 90),
			enabled = false,
			rotateWhileEnabled = false,
			callback = function() end,
		},
		{
			name = "Fling",
			images = {9134785384, 14386226155},
			color = Color3.fromRGB(184, 85, 61),
			enabled = false,
			rotateWhileEnabled = true,
			callback = function(value)
				local character = localPlayer.Character
				local primaryPart = character and character.PrimaryPart
				if primaryPart then
					for _, part in ipairs(character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Massless = value
							part.CustomPhysicalProperties = PhysicalProperties.new(value and math.huge or 0.7, 0.3, 0.5)
						end
					end

					primaryPart.Anchored = true
					primaryPart.AssemblyLinearVelocity = Vector3.zero
					primaryPart.AssemblyAngularVelocity = Vector3.zero

					movers[3].Parent = value and primaryPart or nil

					task.delay(0.5, function() primaryPart.Anchored = false end)
				end
			end,
		},
		{
			name = "Extrasensory Perception",
			images = {9134780101, 14386232387},
			color = Color3.fromRGB(214, 182, 19),
			enabled = false,
			rotateWhileEnabled = false,
			callback = function(value)
				for _, highlight in ipairs(espContainer:GetChildren()) do
					highlight.Enabled = value
				end
			end,
		},
		{
			name = "Night and Day",
			images = {9134778004, 10137794784},
			color = Color3.fromRGB(102, 75, 190),
			enabled = false,
			rotateWhileEnabled = false,
			callback = function(value)
				tweenService:Create(lighting, TweenInfo.new(0.5), { ClockTime = value and 12 or 24 }):Play()
			end,
		},
		{
			name = "Global Audio",
			images = {9134774810, 14386246782},
			color = Color3.fromRGB(202, 103, 58),
			enabled = false,
			rotateWhileEnabled = false,
			callback = function(value)
				if value then
					oldVolume = gameSettings.MasterVolume
					gameSettings.MasterVolume = 0
				else
					gameSettings.MasterVolume = oldVolume
				end
			end,
		},
		{
			name = "Visibility",
			images = {14386256326, 9134770786},
			color = Color3.fromRGB(62, 94, 170),
			enabled = false,
			rotateWhileEnabled = false,
			callback = function() end,
		},
	},
	sliders = {
		{
			name = "player speed",
			color = Color3.fromRGB(44, 153, 93),
			values = {0, 300},
			default = 16,
			value = 16,
			active = false,
			callback = function(value)
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if character then
					humanoid.WalkSpeed = value
				end
			end,
		},
		{
			name = "jump power",
			color = Color3.fromRGB(59, 126, 184),
			values = {0, 350},
			default = 50,
			value = 16,
			active = false,
			callback = function(value)
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if character then
					if humanoid.UseJumpPower then
						humanoid.JumpPower = value
					else
						humanoid.JumpHeight = value
					end
				end
			end,
		},
		{
			name = "flight speed",
			color = Color3.fromRGB(177, 45, 45),
			values = {1, 25},
			default = 3,
			value = 3,
			active = false,
			callback = function(value) end,
		},
		{
			name = "field of view",
			color = Color3.fromRGB(198, 178, 75),
			values = {45, 120},
			default = 70,
			value = 16,
			active = false,
			callback = function(value)
				tweenService:Create(camera, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { FieldOfView = value }):Play()
			end,
		},
	}
}

local siriusSettings = {
	{
		name = 'General',
		description = 'The general settings for Sirius, from simple to unique features.',
		color = Color3.new(0.117647, 0.490196, 0.72549),
		minimumLicense = 'Free',
		categorySettings = {
			{
				name = 'Anonymous Client',
				description = 'Randomise your username in real-time in any CoreGui parented interface, including Sirius. You will still appear as your actual name to others in-game. This setting can be performance intensive.',
				settingType = 'Boolean',
				current = false,

				id = 'anonmode'
			},
			{
				name = 'Chat Spy',
				description = 'This will only work on the legacy Roblox chat system. Sirius will display whispers usually hidden from you in the chat box.',
				settingType = 'Boolean',
				current = true,

				id = 'chatspy'
			},
			{
				name = 'Hide Toggle Button',
				description = 'This will remove the option to open the smartBar with the toggle button.',
				settingType = 'Boolean',
				current = false,

				id = 'hidetoggle'
			},
			{
				name = 'Now Playing Notifications',
				description = 'When active, Sirius will notify you when the next song in your Music queue plays.',
				settingType = 'Boolean',
				current = true,

				id = 'nowplaying'
			},
			{
				name = 'Friend Notifications',
				settingType = 'Boolean', 
				current = true,

				id = 'friendnotifs'
			},
			{
				name = 'Load Hidden',
				settingType = 'Boolean',
				current = false,

				id = 'loadhidden'
			}, 
			{
				name = 'Startup Sound Effect',
				settingType = 'Boolean',
				current = true,

				id = 'startupsound'
			}, 
			{
				name = 'Anti Idle',
				description = 'Remove all callbacks and events linked to the LocalPlayer Idled state. This may prompt detection from Adonis or similar anti-cheats.',
				settingType = 'Boolean',
				current = true,

				id = 'antiidle'
			},
			{
				name = 'Client-Based Anti Kick',
				description = 'Cancel any kick request involving you sent by the client. This may prompt detection from Adonis or similar anti-cheats. You will need to rejoin and re-run Sirius to toggle.',
				settingType = 'Boolean',
				current = false,

				id = 'antikick'
			},
			{
				name = 'Muffle audio while unfocused',
				settingType = 'Boolean', 
				current = true,

				id = 'muffleunfocused'
			},
		}
	},
	{
		name = 'Keybinds',
		description = 'Assign keybinds to actions or change keybinds such as the one to open/close Sirius.',
		color = Color3.new(0.0941176, 0.686275, 0.509804),
		minimumLicense = 'Free',
		categorySettings = {
			{
				name = 'Toggle Search',
				settingType = 'Key',
				current = "F",
				id = 'togglesearch',
				callback = function()
					local core = gethui and gethui() or game:GetService("CoreGui")
					local searchContainer = core:FindFirstChild("SiriusRebornInput", true)
					if searchContainer then
						local searchInput = searchContainer:FindFirstChildOfClass("TextBox")
						if searchInput then
							if searchInput:IsFocused() then
								searchInput:ReleaseFocus()
							else
								searchInput:CaptureFocus()
								task.wait()
								searchInput.Text = ""
							end
						end
					end
				end
			},
			{
				name = 'Toggle smartBar',
				settingType = 'Key',
				current = "K",
				id = 'smartbar'
			},
			{
				name = 'Open ScriptSearch',
				settingType = 'Key',
				current = "T",
				id = 'scriptsearch'
			},
			{
				name = 'NoClip',
				settingType = 'Key',
				current = nil,
				id = 'noclip',
				callback = function()
					local noclip = siriusValues.actions[1]
					noclip.enabled = not noclip.enabled
					noclip.callback(noclip.enabled)
				end
			},
			{
				name = 'Flight',
				settingType = 'Key',
				current = nil,
				id = 'flight',
				callback = function()
					local flight = siriusValues.actions[2]
					flight.enabled = not flight.enabled
					flight.callback(flight.enabled)
				end
			},
			{
				name = 'Refresh',
				settingType = 'Key',
				current = nil,
				id = 'refresh',
				callback = function()
					local refresh = siriusValues.actions[3]
					if not refresh.enabled then
						refresh.enabled = true
						refresh.callback()
					end
				end
			},
			{
				name = 'Respawn',
				settingType = 'Key',
				current = nil,
				id = 'respawn',
				callback = function()
					local respawn = siriusValues.actions[4]
					if not respawn.enabled then
						respawn.enabled = true
						respawn.callback()
					end
				end
			},
			{
				name = 'Invulnerability',
				settingType = 'Key',
				current = nil,
				id = 'invulnerability',
				callback = function()
					local invulnerability = siriusValues.actions[5]
					invulnerability.enabled = not invulnerability.enabled
					invulnerability.callback(invulnerability.enabled)
				end
			},
			{
				name = 'Fling',
				settingType = 'Key',
				current = nil,
				id = 'fling',
				callback = function()
					local fling = siriusValues.actions[6]
					fling.enabled = not fling.enabled
					fling.callback(fling.enabled)
				end
			},
			{
				name = 'ESP',
				settingType = 'Key',
				current = nil,
				id = 'esp',
				callback = function()
					local esp = siriusValues.actions[7]
					esp.enabled = not esp.enabled
					esp.callback(esp.enabled)
				end
			},
			{
				name = 'Night and Day',
				settingType = 'Key',
				current = nil,
				id = 'nightandday',
				callback = function()
					local nightandday = siriusValues.actions[8]
					nightandday.enabled = not nightandday.enabled
					nightandday.callback(nightandday.enabled)
				end
			},
			{
				name = 'Global Audio',
				settingType = 'Key',
				current = nil,
				id = 'globalaudio',
				callback = function()
					local globalaudio = siriusValues.actions[9]
					globalaudio.enabled = not globalaudio.enabled
					globalaudio.callback(globalaudio.enabled)
				end
			},
			{
				name = 'Visibility',
				settingType = 'Key',
				current = nil,
				id = 'visibility',
				callback = function()
					local visibility = siriusValues.actions[10]
					visibility.enabled = not visibility.enabled
					visibility.callback(visibility.enabled)
				end
			},
		}
	},
	{
		name = 'Performance',
		description = 'Tweak and test your performance settings for Roblox in Sirius.',
		color = Color3.new(1, 0.376471, 0.168627),
		minimumLicense = 'Free',
		categorySettings = {
			{
				name = 'Artificial FPS Limit',
				description = 'Sirius will automatically set your FPS to this number when you are tabbed-in to Roblox.',
				settingType = 'Number',
				values = {20, 5000},
				current = 240,

				id = 'fpscap'
			},
			{
				name = 'Limit FPS while unfocused',
				description = 'Sirius will automatically set your FPS to 60 when you tab-out or unfocus from Roblox.',
				settingType = 'Boolean', -- number for the cap below!! with min and max val
				current = true,

				id = 'fpsunfocused'
			},
			{
				name = 'Adaptive Latency Warning',
				description = 'Sirius will check your average latency in the background and notify you if your current latency significantly goes above your average latency.',
				settingType = 'Boolean',
				current = true,

				id = 'latencynotif'
			},
			{
				name = 'Adaptive Performance Warning',
				description = 'Sirius will check your average FPS in the background and notify you if your current FPS goes below a specific number.',
				settingType = 'Boolean',
				current = true,

				id = 'fpsnotif'
			},
		}
	},
	{
		name = 'Detections',
		description = 'Sirius detects and prevents anything malicious or possibly harmful to your wellbeing.',
		color = Color3.new(0.705882, 0, 0),
		minimumLicense = 'Free',
		categorySettings = {
			{
				name = 'Spatial Shield',
				description = 'Suppress loud sounds played from any audio source in-game, in real-time with Spatial Shield.',
				settingType = 'Boolean',
				minimumLicense = 'Pro',
				current = true,

				id = 'spatialshield'
			},
			{
				name = 'Spatial Shield Threshold',
				description = 'How loud a sound needs to be to be suppressed.',
				settingType = 'Number',
				minimumLicense = 'Pro',
				values = {100, 1000},
				current = 300,

				id = 'spatialshieldthreshold'
			},
			{
				name = 'Moderator Detection',
				description = 'Be notified whenever Sirius detects a player joins your session that could be a game moderator.',
				settingType = 'Boolean', 
				minimumLicense = 'Pro',
				current = true,

				id = 'moddetection'
			},
			{
				name = 'Intelligent HTTP Interception',
				description = 'Block external HTTP/HTTPS requests from being sent/recieved and ask you before allowing it to run.',
				settingType = 'Boolean',
				minimumLicense = 'Essential',
				current = true,

				id = 'intflowintercept'
			},
			{
				name = 'Intelligent Clipboard Interception',
				description = 'Block your clipboard from being set and ask you before allowing it to set your clipboard.',
				settingType = 'Boolean',
				minimumLicense = 'Essential',
				current = true,

				id = 'intflowinterceptclip'
			},
		},
	},
	{
		name = 'Chat Safety',
		description = 'Reduce chat spam and keep things clean.',
		color = Color3.fromRGB(140, 82, 255),
		minimumLicense = 'Free',
		categorySettings = {
			{
				name = 'Anti-Spam Bot',
				description = 'Detect common spam/scam bot messages and hide them from chat.',
				settingType = 'Boolean',
				current = true,
				id = 'antispam'
			},
			{
				name = 'Auto-Report Spam',
				description = 'Automatically submit a Roblox report for spam/scam when detected.',
				settingType = 'Boolean',
				current = false,
				id = 'autoreportspam'
			},
			{
				name = 'Spam Notifications',
				description = 'Show a Sirius toast when spam is filtered.',
				settingType = 'Boolean',
				current = true,
				id = 'spamnotifs'
			},
		}
	},
	{
		name = 'Logging',
		description = 'Send logs to your specified webhook URL of things like player joins and leaves and messages.',
		color = Color3.new(0.905882, 0.780392, 0.0666667),
		minimumLicense = 'Free',
		categorySettings = {
			{
				name = 'Log Messages',
				description = 'Log messages sent by any player to your webhook.',
				settingType = 'Boolean',
				current = false,

				id = 'logmsg'
			},
			{
				name = 'Message Webhook URL',
				description = 'Discord Webhook URL',
				settingType = 'Input',
				current = 'No Webhook',

				id = 'logmsgurl'
			},
			{
				name = 'Log PlayerAdded and PlayerRemoving',
				description = 'Log whenever any player leaves or joins your session.',
				settingType = 'Boolean',
				current = false,

				id = 'logplrjoinleave'
			},
			{
				name = 'Player Added and Removing Webhook URL',
				description = 'Discord Webhook URL',
				settingType = 'Input',
				current = 'No Webhook',

				id = 'logplrjoinleaveurl'
			},
		}
	},
}

-- Generate random username
local randomAdjective = siriusValues.nameGeneration.adjectives[math.random(1, #siriusValues.nameGeneration.adjectives)]
local randomNoun = siriusValues.nameGeneration.nouns[math.random(1, #siriusValues.nameGeneration.nouns)]
local randomNumber = math.random(100, 3999) -- You can customize the range
local randomUsername = randomAdjective .. randomNoun .. randomNumber

-- Initialise Sirius Client Interface
local guiParent = gethui and gethui() or coreGui
local sirius = guiParent:FindFirstChild("Sirius")
if sirius then
	sirius:Destroy()
end

local UI = game:GetObjects('rbxassetid://'..siriusValues.interfaceAsset)[1]
UI.Name = siriusValues.siriusName
UI.Parent = guiParent
UI.Enabled = false

-- Create Variables for Interface Elements
local characterPanel = UI.Character
local customScriptPrompt = UI.CustomScriptPrompt
local securityPrompt = UI.SecurityPrompt
local disconnectedPrompt = UI.Disconnected
local gameDetectionPrompt = UI.GameDetection
local homeContainer = UI.Home
local moderatorDetectionPrompt = UI.ModeratorDetectionPrompt
local notificationContainer = UI.Notifications
local playerlistPanel = UI.Playerlist
local scriptSearch = UI.ScriptSearch
-- local musicPanel = UI.Music -- legacy Sirius music panel disabled
local scriptsPanel = UI.Scripts
local settingsPanel = UI.Settings
local smartBar = UI.SmartBar
local toggle = UI.Toggle
local starlight = UI.Starlight
local toastsContainer = UI.Toasts

-- Search Bar Injection (Native)
local SearchContainer = Instance.new("Frame")
SearchContainer.Name = "SiriusRebornInput"
SearchContainer.Size = UDim2.new(0, 180, 0, 32)
SearchContainer.Position = UDim2.new(1, -85, 0.5, 0) -- Right side
SearchContainer.AnchorPoint = Vector2.new(1, 0.5)
SearchContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SearchContainer.BackgroundTransparency = 0.2
SearchContainer.BorderSizePixel = 0
SearchContainer.ZIndex = 10000
SearchContainer.Parent = smartBar -- Parent directly to smartBar

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(1, 0) -- Pill shape
Corner.Parent = SearchContainer

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(100, 100, 100)
Stroke.Thickness = 1
Stroke.Transparency = 0.5
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = SearchContainer

-- Icon
local Icon = Instance.new("ImageLabel")
Icon.Size = UDim2.new(0, 16, 0, 16)
Icon.Position = UDim2.new(0, 12, 0.5, 0)
Icon.AnchorPoint = Vector2.new(0, 0.5)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://6031154871" -- Material Search Icon
Icon.ImageColor3 = Color3.fromRGB(200, 200, 200)
Icon.ZIndex = 10002
Icon.Parent = SearchContainer

local Input = Instance.new("TextBox")
Input.Size = UDim2.new(1, -34, 1, 0) -- Less width to account for icon
Input.Position = UDim2.new(0, 34, 0, 0) -- Moved right
Input.BackgroundTransparency = 1
Input.Text = ""
Input.PlaceholderText = "Search command..."
Input.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
Input.TextColor3 = Color3.fromRGB(255, 255, 255)
Input.Font = Enum.Font.GothamMedium
Input.TextSize = 14
Input.TextXAlignment = Enum.TextXAlignment.Left
Input.ZIndex = 10001
Input.Parent = SearchContainer

-- Suggestion Frame (Positioned Above)
local SuggestionFrame = Instance.new("ScrollingFrame")
SuggestionFrame.Name = "SuggestionFrame"
SuggestionFrame.AnchorPoint = Vector2.new(0, 1) -- Anchor at bottom-left
SuggestionFrame.Size = UDim2.new(1, 0, 0, 0) -- Start height 0
SuggestionFrame.Position = UDim2.new(0, 0, 0, -8) -- Above search bar
SuggestionFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Match SmartBar (Dark)
SuggestionFrame.BackgroundTransparency = 1 -- Start transparent
SuggestionFrame.BorderSizePixel = 0
SuggestionFrame.ScrollBarThickness = 0
SuggestionFrame.ScrollBarImageTransparency = 1
SuggestionFrame.Visible = false
SuggestionFrame.ZIndex = 10005
SuggestionFrame.Parent = SearchContainer

-- Rounded Corners for Suggestions
local SuggestionCorner = Instance.new("UICorner")
SuggestionCorner.CornerRadius = UDim.new(0, 12) -- More rounded
SuggestionCorner.Parent = SuggestionFrame

local SuggestionList = Instance.new("UIListLayout")
SuggestionList.SortOrder = Enum.SortOrder.LayoutOrder
SuggestionList.Padding = UDim.new(0, 2)
SuggestionList.Parent = SuggestionFrame

local SuggestionPadding = Instance.new("UIPadding")
SuggestionPadding.PaddingTop = UDim.new(0, 8)
SuggestionPadding.PaddingBottom = UDim.new(0, 8)
SuggestionPadding.PaddingLeft = UDim.new(0, 8)
SuggestionPadding.PaddingRight = UDim.new(0, 8)
SuggestionPadding.Parent = SuggestionFrame

-- Infinite Yield Commands
local dummyCmds = {
    "discord", "support", "help", "guiscale", "console", "oldconsole", "explorer", "dex", "olddex", "odex", 
    "remotespy", "rspy", "audiologger", "alogger", "serverinfo", "info", "jobid", "notifyjobid", "rejoin", "rj", 
    "autorejoin", "autorj", "serverhop", "shop", "gameteleport", "gametp", "antiidle", "antiafk", "datalimit", 
    "replicationlag", "backtrack", "creatorid", "creator", "copycreatorid", "copycreator", "setcreatorid", "setcreator", 
    "noprompts", "showprompts", "enable", "disable", "showguis", "unshowguis", "hideguis", "unhideguis", "guidelete", 
    "unguidelete", "noguidelete", "hideiy", "showiy", "unhideiy", "keepiy", "unkeepiy", "togglekeepiy", "savegame", 
    "saveplace", "clearerror", "clientantikick", "antikick", "clientantiteleport", "antiteleport", "allowrejoin", "allowrj", 
    "cancelteleport", "canceltp", "volume", "vol", "antilag", "boostfps", "lowgraphics", "record", "rec", "screenshot", 
    "scrnshot", "togglefullscreen", "togglefs", "notify", "lastcommand", "lastcmd", "exit",
    "noclip", "unnoclip", "clip", "fly", "unfly", "flyspeed", "vehiclefly", "vfly", "unvehiclefly", "unvfly", 
    "vehicleflyspeed", "vflyspeed", "cframefly", "cfly", "uncframefly", "uncfly", "cframeflyspeed", "cflyspeed", 
    "qefly", "vehiclenoclip", "vnoclip", "vehicleclip", "vclip", "unvnoclip", "float", "platform", "unfloat", 
    "noplatform", "swim", "unswim", "noswim", "toggleswim",
    "setwaypoint", "swp", "waypointpos", "wpp", "waypoints", "showwaypoints", "showwp", "hidewaypoints", "hidewp", 
    "waypoint", "wp", "tweenwaypoint", "twp", "walktowaypoint", "wtwp", "deletewaypoint", "dwp", "clearwaypoints", 
    "cwp", "cleargamewaypoints", "cgamewp",
    "goto", "tweengoto", "tgoto", "tweenspeed", "tspeed", "vehiclegoto", "vgoto", "loopgoto", "unloopgoto", "pulsetp", 
    "ptp", "clientbring", "cbring", "loopbring", "unloopbring", "freeze", "fr", "freezeanims", "unfreezeanims", "thaw", 
    "unfr", "tpposition", "tppos", "tweentpposition", "ttppos", "offset", "tweenoffset", "toffset", "notifyposition", 
    "notifypos", "copyposition", "copypos", "walktoposition", "walktopos", "spawnpoint", "spawn", "nospawnpoint", 
    "nospawn", "flashback", "diedtp", "walltp", "nowalltp", "unwalltp", "teleporttool", "tptool",
    "logs", "chatlogs", "clogs", "joinlogs", "jlogs", "chatlogswebhook", "logswebhook", "antichatlogs", "antichatlogger", 
    "chat", "say", "spam", "unspam", "whisper", "pm", "pmspam", "unpmspam", "spamspeed", "bubblechat", "unbubblechat", 
    "nobubblechat", "chatwindow", "unchatwindow", "nochatwindow",
    "esp", "espteam", "noesp", "unesp", "unespteam", "esptransparency", "partesp", "unpartesp", "nopartesp", "chams", 
    "nochams", "unchams", "locate", "unlocate", "nolocate", "xray", "unxray", "noxray", "loopxray", "unloopxray", "togglexray",
    "spectate", "view", "viewpart", "viewp", "unspectate", "unview", "freecam", "fc", "freecampos", "fcpos", 
    "freecamwaypoint", "fcwp", "freecamgoto", "fcgoto", "fctp", "unfreecam", "unfc", "freecamspeed", "fcspeed", 
    "notifyfreecamposition", "notifyfcpos", "copyfreecamposition", "copyfcpos", "gotocamera", "gotocam", "tweengotocam", 
    "tgotocam", "firstp", "thirdp", "noclipcam", "nccam", "maxzoom", "minzoom", "camdistance", "fov", "fixcam", 
    "restorecam", "enableshiftlock", "enablesl", "lookat",
    "btools", "f3x", "partname", "partpath", "delete", "deleteclass", "dc", "lockworkspace", "lockws", "unlockworkspace", 
    "unlockws", "invisibleparts", "invisparts", "uninvisibleparts", "uninvisparts", "deleteinvisparts", "dip", "gotopart", 
    "tweengotopart", "tgotopart", "gotopartclass", "gpc", "tweengotopartclass", "tgpc", "gotomodel", "tweengotomodel", 
    "tgotomodel", "gotopartdelay", "gotomodeldelay", "bringpart", "bringpartclass", "bpc", "noclickdetectorlimits", 
    "nocdlimits", "fireclickdetectors", "firecd", "firetouchinterests", "touchinterests", "noproximitypromptlimits", 
    "nopplimits", "fireproximityprompts", "firepp", "instantproximityprompts", "instantpp", "uninstantproximityprompts", 
    "uninstantpp", "tpunanchored", "tpua", "animsunanchored", "freezeua", "thawunanchored", "thawua", "unfreezeua", 
    "removeterrain", "rterrain", "noterrain", "clearnilinstances", "nonilinstances", "cni", "destroyheight", "dh", 
    "fakeout", "antivoid", "unantivoid", "noantivoid",
    "fullbright", "fb", "loopfullbright", "loopfb", "unloopfullbright", "unloopfb", "ambient", "day", "night", "nofog", 
    "brightness", "globalshadows", "gshadows", "noglobalshadows", "nogshadows", "restorelighting", "rlighting", "light", 
    "nolight", "unlight",
    "inspect", "examine", "age", "chatage", "joindate", "jd", "chatjoindate", "cjd", "copyname", "copyuser", "userid", 
    "id", "copyplaceid", "placeid", "copygameid", "gameid", "copyuserid", "copyid", "appearanceid", "aid", 
    "copyappearanceid", "caid", "bang", "unbang", "carpet", "uncarpet", "friend", "unfriend", "headsit", "walkto", 
    "follow", "pathfindwalkto", "pathfindfollow", "pathfindwalktowaypoint", "pathfindwalktowp", "unwalkto", "unfollow", 
    "orbit", "unorbit", "stareat", "stare", "unstareat", "unstare", "rolewatch", "rolewatchstop", "unrolewatch", 
    "rolewatchleave", "staffwatch", "unstaffwatch", "handlekill", "hkill", "fling", "unfling", "flyfling", "unflyfling", 
    "walkfling", "unwalkfling", "nowalkfling", "invisfling", "antifling", "unantifling", "loopoof", "unloopoof", 
    "muteboombox", "unmuteboombox", "hitbox", "headsize",
    "reset", "respawn", "refresh", "re", "god", "permadeath", "invisible", "invis", "visible", "vis", "toolinvisible", 
    "toolinvis", "tinvis", "speed", "ws", "walkspeed", "spoofspeed", "spoofws", "loopspeed", "loopws", "unloopspeed", 
    "unloopws", "hipheight", "hheight", "jumppower", "jpower", "jp", "spoofjumppower", "spoofjp", "loopjumppower", 
    "loopjp", "unloopjumppower", "unloopjp", "maxslopeangle", "msa", "gravity", "grav", "sit", "lay", "laydown", 
    "sitwalk", "nosit", "unnosit", "jump", "infinitejump", "infjump", "uninfinitejump", "uninfjump", "flyjump", 
    "unflyjump", "autojump", "ajump", "unautojump", "unajump", "edgejump", "ejump", "unedgejump", "unejump", 
    "platformstand", "stun", "unplatformstand", "unstun", "norotate", "noautorotate", "unnorotate", "autorotate", 
    "enablestate", "disablestate", "team", "nobillboardgui", "nobgui", "noname", "loopnobgui", "loopnoname", 
    "unloopnobgui", "unloopnoname", "noarms", "nolegs", "nolimbs", "naked", "noface", "removeface", "blockhead", 
    "blockhats", "blocktool", "creeper", "drophats", "nohats", "deletehats", "rhats", "hatspin", "spinhats", "unhatspin", 
    "unspinhats", "clearhats", "cleanhats", "chardelete", "cd", "chardeleteclass", "cdc", "deletevelocity", "dv", 
    "removeforces", "weaken", "unweaken", "strengthen", "unstrengthen", "breakvelocity", "spin", "unspin", "split", 
    "nilchar", "unnilchar", "nonilchar", "noroot", "removeroot", "rroot", "replaceroot", "clearcharappearance", 
    "clearchar", "clrchar",
    "animation", "anim", "emote", "em", "dance", "undance", "spasm", "unspasm", "headthrow", "noanim", "reanim", 
    "animspeed", "copyanimation", "copyanim", "copyemote", "copyanimationid", "copyanimid", "copyemoteid", 
    "loopanimation", "loopanim", "stopanimations", "stopanims", "refreshanimations", "refreshanims", "allowcustomanim", 
    "allowcustomanimations", "unallowcustomanim", "unallowcustomanimations",
    "autoclick", "unautoclick", "noautoclick", "autokeypress", "unautokeypress", "hovername", "unhovername", 
    "nohovername", "mousesensitivity", "ms", "clickdelete", "clickteleport", "mouseteleport", "mousetp",
    "tools", "notools", "removetools", "deletetools", "deleteselectedtool", "dst", "grabtools", "ungrabtools", 
    "nograbtools", "copytools", "dupetools", "clonetools", "droptools", "droppabletools", "equiptools", "unequiptools", 
    "removespecifictool", "unremovespecifictool", "clearremovespecifictool", "reach", "boxreach", "unreach", "noreach", 
    "grippos", "usetools",
    "addalias", "removealias", "clraliases",
    "addplugin", "plugin", "removeplugin", "deleteplugin", "reloadplugin", "addallplugins", "loadallplugins",
    "breakloops", "break", "removecmd", "deletecmd", "tpwalk", "teleportwalk", "untpwalk", "unteleportwalk", 
    "notifyping", "ping", "trip", "norender", "render", "use2022materials", "2022materials", "unuse2022materials", 
    "un2022materials", "promptr6", "promptr15", "wallwalk", "walkonwalls", "removeads", "adblock", "scare", "spook", 
    "alignmentkeys", "unalignmentkeys", "noalignmentkeys", "ctrllock", "unctrllock", "listento", "unlistento", "jerk", 
    "unsuspendchat", "unsuspendvc", "muteallvcs", "unmuteallvcs", "mutevc", "unmutevc", "phonebook", "call"
}

local function UpdateSuggestions(filterText)
    for _, v in pairs(SuggestionFrame:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    
    local count = 0
    for i, cmd in ipairs(dummyCmds) do
        if filterText == "" or cmd:lower():find(filterText:lower()) then
            count = count + 1
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 28) -- Slightly taller
            btn.BackgroundTransparency = 1
            btn.Text = "  " .. cmd
            btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.ZIndex = 10006
            btn.Parent = SuggestionFrame
            btn.TextTransparency = 1 -- Start invisible
            
            -- Animate in with stagger (Ultra Smooth Exponential)
            task.delay(count * 0.01, function()
                tweenService:Create(btn, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
            end)
            
            btn.MouseButton1Click:Connect(function()
                Input.Text = cmd
                Input:CaptureFocus()
            end)
        end
    end
    
    -- Adjust frame height based on count
    local newHeight = math.min(count * 30 + 16, 250) -- Max height 250
    if count == 0 then newHeight = 0 end
    
    -- Frame Animation (Ultra Smooth Exponential)
    tweenService:Create(SuggestionFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, newHeight),
        BackgroundTransparency = 0 -- Opaque
    }):Play()
end

-- Set global CmdInput
CmdInput = Input

-- Filtering
Input:GetPropertyChangedSignal("Text"):Connect(function()
    if Input:IsFocused() and Input.Text ~= "" then
        UpdateSuggestions(Input.Text)
        SuggestionFrame.Visible = true
    else
        -- Hide if empty or not focused
        tweenService:Create(SuggestionFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        
        for _, btn in pairs(SuggestionFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                tweenService:Create(btn, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            end
        end
        
        task.delay(0.3, function()
            SuggestionFrame.Visible = false
        end)
    end
end)

Input.Focused:Connect(function()
    -- Block input when closed
	if not smartBarOpen then
		Input:ReleaseFocus()
		return
	end
	tweenService:Create(SearchContainer, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
    tweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 255, 255)}):Play()
end)

Input.FocusLost:Connect(function(enter)
    tweenService:Create(SearchContainer, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
    tweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(100, 100, 100)}):Play()
    
    -- Fade out suggestions
    tweenService:Create(SuggestionFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    
    for _, btn in pairs(SuggestionFrame:GetChildren()) do
        if btn:IsA("TextButton") then
            tweenService:Create(btn, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        end
    end
    
    task.delay(0.3, function()
        SuggestionFrame.Visible = false
    end)
    
    if enter and Input.Text ~= "" then
        print("Executing command:", Input.Text)
        if execCmd then
            execCmd(Input.Text)
        else
            warn("execCmd not defined")
        end
        Input.Text = ""
    end
end)

-- Sync with SmartBar
local function updateState()
    local targetBar = smartBar
    if not targetBar then return end
    
    local isVisible = targetBar.Visible
    local transparency = targetBar.BackgroundTransparency
    
    
    local fadeFactor, tweenDuration
    
    if transparency > 0.5 then
        
        fadeFactor = 3.0
        tweenDuration = 0.1
        SearchContainer.Visible = false
    else
        
        fadeFactor = 1.5
        tweenDuration = 0.2
        if isVisible then
            SearchContainer.Visible = true
        end
    end
    
    local targetTransparency = transparency * fadeFactor
    
    
    if transparency == 0 then targetTransparency = 0.2 end 
    
    if targetTransparency > 1 then targetTransparency = 1 end

    tweenService:Create(SearchContainer, TweenInfo.new(tweenDuration), {BackgroundTransparency = targetTransparency}):Play()
    tweenService:Create(Stroke, TweenInfo.new(tweenDuration), {Transparency = targetTransparency}):Play()
    tweenService:Create(Icon, TweenInfo.new(tweenDuration), {ImageTransparency = targetTransparency}):Play()
    tweenService:Create(Input, TweenInfo.new(tweenDuration), {TextTransparency = targetTransparency, PlaceholderColor3 = Color3.fromRGB(180, 180, 180)}):Play()
    
    if targetTransparency >= 1 then
            SuggestionFrame.Visible = false
    end
end

if smartBar then
    smartBar:GetPropertyChangedSignal("Visible"):Connect(updateState)
    smartBar:GetPropertyChangedSignal("BackgroundTransparency"):Connect(updateState)
    updateState()
end

-- Interface Caching
if not getgenv().cachedInGameUI then getgenv().cachedInGameUI = {} end
if not getgenv().cachedCoreUI then getgenv().cachedCoreUI = {} end

-- Malicious Behavior Prevention
local indexSetClipboard = "setclipboard"
local originalSetClipboard = getgenv()[indexSetClipboard]

local index = http_request and "http_request" or "request"
local originalRequest = getgenv()[index]

-- put this into siriusValues, like the fps and ping shit
local suppressedSounds = {}
local soundSuppressionNotificationCooldown = 0
local soundInstances = {}
local cachedIds = {}
local cachedText = {}

if not getMessage then siriusValues.chatSpy.enabled = false end

-- Call External Modules

-- httpRequest
local httpRequest = originalRequest

-- Neon Module
--local neonModule = (function() -- Open sourced neon module
--	local module = {}
--	do
--		local function IsNotNaN(x)
--			return x == x
--		end
--		local continued = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
--		while not continued do
--			runService.RenderStepped:wait()
--			continued = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
--		end
--	end

--	local RootParent = camera
--	local root
--	local binds = {}

--	local function getRoot()
--		if root then 
--			return root
--		else
--			root = Instance.new('Folder', RootParent)
--			root.Name = 'neon'
--			return root
--		end
--	end

--	local function destroyRoot()
--		if root then 
--			root:Destroy()
--			root = nil
--		end
--	end

--	local GenUid; do
--		local id = 0
--		function GenUid()
--			id = id + 1
--			return 'neon::'..tostring(id)
--		end
--	end

--	local DrawQuad; do
--		local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
--		local sz = 0.2

--		local function DrawTriangle(v1, v2, v3, p0, p1)
--			local s1 = (v1 - v2).magnitude
--			local s2 = (v2 - v3).magnitude
--			local s3 = (v3 - v1).magnitude
--			local smax = max(s1, s2, s3)
--			local A, B, C
--			if s1 == smax then
--				A, B, C = v1, v2, v3
--			elseif s2 == smax then
--				A, B, C = v2, v3, v1
--			elseif s3 == smax then
--				A, B, C = v3, v1, v2
--			end

--			local para = ( (B-A).x*(C-A).x + (B-A).y*(C-A).y + (B-A).z*(C-A).z ) / (A-B).magnitude
--			local perp = sqrt((C-A).magnitude^2 - para*para)
--			local dif_para = (A - B).magnitude - para

--			local st = CFrame.new(B, A)
--			local za = CFrame.Angles(pi/2,0,0)

--			local cf0 = st

--			local Top_Look = (cf0 * za).lookVector
--			local Mid_Point = A + CFrame.new(A, B).LookVector * para
--			local Needed_Look = CFrame.new(Mid_Point, C).LookVector
--			local dot = Top_Look.x*Needed_Look.x + Top_Look.y*Needed_Look.y + Top_Look.z*Needed_Look.z

--			local ac = CFrame.Angles(0, 0, acos(dot))

--			cf0 = cf0 * ac
--			if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
--				cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot))
--			end
--			cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))

--			local cf1 = st * ac * CFrame.Angles(0, pi, 0)
--			if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
--				cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
--			end
--			cf1 = cf1 * CFrame.new(0, perp/2, dif_para/2)

--			if not p0 then
--				p0 = Instance.new('Part')
--				p0.FormFactor = 'Custom'
--				p0.TopSurface = 0
--				p0.BottomSurface = 0
--				p0.Anchored = true
--				p0.CanCollide = false
--				p0.Material = 'Glass'
--				p0.Size = Vector3.new(sz, sz, sz)
--				local mesh = Instance.new('SpecialMesh', p0)
--				mesh.MeshType = 2
--				mesh.Name = 'WedgeMesh'
--			end
--			p0.WedgeMesh.Scale = Vector3.new(0, perp/sz, para/sz)
--			p0.CFrame = cf0

--			if not p1 then
--				p1 = p0:clone()
--			end
--			p1.WedgeMesh.Scale = Vector3.new(0, perp/sz, dif_para/sz)
--			p1.CFrame = cf1

--			return p0, p1
--		end

--		function DrawQuad(v1, v2, v3, v4, parts)
--			parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
--			parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
--		end
--	end

--	function module:BindFrame(frame, properties)
--		if binds[frame] then
--			return binds[frame].parts
--		end

--		local uid = GenUid()
--		local parts = {}
--		local f = Instance.new('Folder', getRoot())
--		f.Name = frame.Name

--		local parents = {}
--		do
--			local function add(child)
--				if child:IsA'GuiObject' then
--					parents[#parents + 1] = child
--					add(child.Parent)
--				end
--			end
--			add(frame)
--		end

--		local function UpdateOrientation(fetchProps)
--			local zIndex = 1 - 0.05*frame.ZIndex
--			local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
--			local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
--			do
--				local rot = 0
--				for _, v in ipairs(parents) do
--					rot = rot + v.Rotation
--				end
--				if rot ~= 0 and rot%180 ~= 0 then
--					local mid = tl:lerp(br, 0.5)
--					local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
--					local vec = tl
--					tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid
--					tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid
--					bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid
--					br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid
--				end
--			end
--			DrawQuad(
--				camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin, 
--				camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin, 
--				camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin, 
--				camera:ScreenPointToRay(br.x, br.y, zIndex).Origin, 
--				parts
--			)
--			if fetchProps then
--				for _, pt in pairs(parts) do
--					pt.Parent = f
--				end
--				for propName, propValue in pairs(properties) do
--					for _, pt in pairs(parts) do
--						pt[propName] = propValue
--					end
--				end
--			end
--		end

--		UpdateOrientation(true)
--		runService:BindToRenderStep(uid, 2000, UpdateOrientation)

--		binds[frame] = {
--			uid = uid,
--			parts = parts
--		}
--		return binds[frame].parts
--	end

--	function module:Modify(frame, properties)
--		local parts = module:GetBoundParts(frame)
--		if parts then
--			for propName, propValue in pairs(properties) do
--				for _, pt in pairs(parts) do
--					pt[propName] = propValue
--				end
--			end
--		end
--	end

--	function module:UnbindFrame(frame)
--		if RootParent == nil then return end
--		local cb = binds[frame]
--		if cb then
--			runService:UnbindFromRenderStep(cb.uid)
--			for _, v in pairs(cb.parts) do
--				v:Destroy()
--			end
--			binds[frame] = nil
--		end
--		if getRoot():FindFirstChild(frame.Name) then
--			getRoot()[frame.Name]:Destroy()
--		end
--	end

--	function module:HasBinding(frame)
--		return binds[frame] ~= nil
--	end

--	function module:GetBoundParts(frame)
--		return binds[frame] and binds[frame].parts
--	end

--	return module

--end)()

-- Sirius Functions
local function checkSirius() return UI.Parent end
local function getPing() return math.clamp(statsService.Network.ServerStatsItem["Data Ping"]:GetValue(), 10, 700) end
local function checkFolder()
	if not isfolder then return end
	if not isfolder(siriusValues.siriusFolder) then makefolder(siriusValues.siriusFolder) end
	if not isfolder(siriusValues.siriusFolder.."/Assets/Icons") then makefolder(siriusValues.siriusFolder.."/Assets/Icons") end
	if not isfolder(siriusValues.siriusFolder.."/Assets") then makefolder(siriusValues.siriusFolder.."/Assets") end
end
local function isPanel(name) return not table.find({"Home", "Settings"}, name) end

local function fetchFromCDN(path, write, savePath)
	pcall(function()
		checkFolder()

		local file = game:HttpGet(siriusValues.cdn..path) or nil
		if not file then return end
		if not write then return file end

		writefile(siriusValues.siriusFolder.."/"..savePath, file)

		return
	end)
end

-- Forward declarations (defined later in script)
local checkSetting
local queueNotification

-- Chat Safety (spamGuard)
local spamGuard = {
	keywords = {
		{"blox", "pink", "robux"},
		{"blox", "pink", "reward"},
		{"friend used", "blox", "robux"},
		{"your friend", "robux", "reward"},
	},
	setup = false,
	lastNotify = 0,
	processedObjects = setmetatable({}, {__mode = "k"}),
	recentSpamTime = 0,
}

function spamGuard:notify()
	-- Check if notifications are disabled (default to enabled if checkSetting unavailable)
	if checkSetting then
		local spamNotifs = checkSetting("Spam Notifications")
		if spamNotifs and not spamNotifs.current then return end
	end
	local now = os.clock()
	if now - self.lastNotify < 0.4 then return end
	self.lastNotify = now
	
	-- Use forward-declared queueNotification (assigned at line 4168)
	task.defer(function()
		if queueNotification then
			queueNotification("Chat Spam Blocked", "Filtered a suspected spam bot message.")
		end
	end)
end

function spamGuard:isSpam(msg)
	-- Note: caller already checks if Anti-Spam Bot is enabled
	local lower = string.lower(msg or "")
	if lower == "" then return false end
	if lower:find("blox%.pink") and (lower:find("robux") or lower:find("reward")) then
		return true
	end
	local normalized = lower:gsub("[%p%c]", " "):gsub("%s+", " ")
	local tokens = {}
	for word in string.gmatch(normalized, "%S+") do
		tokens[word] = true
	end
	local function hasAll(words)
		for _, w in ipairs(words) do
			if not tokens[w] then return false end
		end
		return true
	end
	if hasAll({"blox", "pink"}) and (tokens["robux"] or tokens["reward"]) then
		return true
	end
	for _, trio in ipairs(self.keywords) do
		if hasAll(trio) then return true end
	end
	return false
end

function spamGuard:destroy(obj)
	if not obj then return false end
	
	-- check if already processed
	if self.processedObjects[obj] then return false end
	self.processedObjects[obj] = true
	
	pcall(function()
		local parent = obj.Parent
		if parent and parent:IsA("Frame") then
			self.processedObjects[parent] = true
			parent.Visible = false
		else
			obj.Visible = false
		end
	end)
	return true
end

function spamGuard:inspect(obj)
	if not obj then return false end
	-- Check if Anti-Spam Bot is enabled (allows dynamic toggle)
	if checkSetting then
		local antiSpam = checkSetting("Anti-Spam Bot")
		if not antiSpam or not antiSpam.current then return false end
	end
	
	-- Check the object itself
	if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) and self:isSpam(obj.Text or "") then
		return self:destroy(obj)
	end
	
	-- Check descendants
	for _, d in ipairs(obj:GetDescendants()) do
		if (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")) and self:isSpam(d.Text or "") then
			if self:destroy(d) then
				return true
			end
		end
	end
	return false
end

function spamGuard:scrub()
	-- Check if Anti-Spam Bot is enabled (allows dynamic toggle)
	if checkSetting then
		local antiSpam = checkSetting("Anti-Spam Bot")
		if not antiSpam or not antiSpam.current then return end
	end
	
	-- Check both legacy Chat and TextChatService ExperienceChat GUIs
	local chatGuis = {}
	local legacyChat = coreGui:FindFirstChild("Chat")
	local experienceChat = coreGui:FindFirstChild("ExperienceChat")
	if legacyChat then table.insert(chatGuis, legacyChat) end
	if experienceChat then table.insert(chatGuis, experienceChat) end
	
	local foundSpam = false
	for _, chatGui in ipairs(chatGuis) do
		for _, desc in ipairs(chatGui:GetDescendants()) do
			if (desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox")) and desc.Text and self:isSpam(desc.Text) then
				self:destroy(desc)
				foundSpam = true
			end
		end
	end
	
	-- Removed: notify is called by the main event handlers, not here
	-- if foundSpam then
	-- 	self:notify()
	-- end
end

function spamGuard:clearChat()
	-- Removed: was breaking chat
	return
end

function spamGuard:report(userId)
	if not checkSetting then return end
	local reportSetting = checkSetting("Auto-Report Spam")
	if not reportSetting or not reportSetting.current then return end
	if not userId then return end
	local target = players:GetPlayerByUserId(userId)
	if not target then return end
	pcall(function()
		players:ReportAbuse(target, "Scamming", "Auto-report: spam/scam message detected.")
	end)
end

function spamGuard:setupScrubber()
	if self.setup then return end
	self.setup = true
	
	-- hook chat gui
	local function hookChatGui(chatGui)
		if not chatGui then return end
		chatGui.DescendantAdded:Connect(function(desc)
			if not checkSetting then return end
			local antiSpam = checkSetting("Anti-Spam Bot")
			if not antiSpam or not antiSpam.current then return end
			
			if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
				task.defer(function()
					if self:isSpam(desc.Text or "") then
						if self:destroy(desc) then
							self:notify()
						end
					end
				end)
			end
		end)
	end
	
	-- Hook legacy chat (if exists)
	task.spawn(function()
		local legacyChat = coreGui:WaitForChild("Chat", 5)
		hookChatGui(legacyChat)
	end)
	
	-- Hook TextChatService chat (ExperienceChat)
	task.spawn(function()
		local experienceChat = coreGui:WaitForChild("ExperienceChat", 5)
		hookChatGui(experienceChat)
	end)
end

-- setup hooks
task.spawn(function()
	spamGuard:setupScrubber()
end)

-- Filter spam via chat event (legacy chat pipeline)
if getMessage then
	getMessage.OnClientEvent:Connect(function(packet, channel)
		if not checkSetting then return end
		local antiSpam = checkSetting("Anti-Spam Bot")
		if not (antiSpam and antiSpam.current) then return end

		local text = (packet and packet.Message) or ""
		if text == "" or not spamGuard:isSpam(text) then return end

		-- notify and scrub
		spamGuard:notify()
		task.spawn(function()
			spamGuard:scrub()
		end)
	end)
end

-- Filter spam via TextChatService (new chat) - using safe MessageReceived event only
do
	local tcs = game:FindFirstChildOfClass("TextChatService")
	if tcs then
		tcs.MessageReceived:Connect(function(message)
			if not checkSetting then return end
			local antiSpam = checkSetting("Anti-Spam Bot")
			if not (antiSpam and antiSpam.current) or not message then return end
			local text = message.Text or ""
			if not spamGuard:isSpam(text) then return end

			-- notify and scrub
			spamGuard:notify()
			task.spawn(function()
				spamGuard:scrub()
			end)
		end)
	end
end

-- Load shared Spotify & Dynamic Island UI
local SiriusSpotifyModule
-- Use table to avoid adding to local variable count (Lua 200 limit)
local spotifyState = {panel = nil, open = false, buttonConnected = false, moduleLoaded = false}

local function cleanupLegacySpotifyUI()
	local function destroyIfExists(container, name)
		if container then
			local obj = container:FindFirstChild(name)
			if obj then
				pcall(function()
					obj:Destroy()
				end)
			end
		end
	end

	destroyIfExists(UI, "SiriusSpotifyMusicPanel")
	destroyIfExists(UI, "SpotifyMusicPanel")

	local coreGui = game:GetService("CoreGui")
	local hui = coreGui:FindFirstChild("HUI")
	if hui then
		destroyIfExists(hui, "SiriusSpotifyMusicPanel")
		destroyIfExists(hui, "SpotifyMusicPanel")
	end

	local existingIsland = (gethui and gethui() or coreGui):FindFirstChild("SiriusDynamicIslandGui")
	if existingIsland then
		existingIsland:Destroy()
	end
end

local function ensureSpotifyPanel()
	print("[Sirius] ensureSpotifyPanel called")
	if spotifyState.panel then 
		print("[Sirius] ensureSpotifyPanel: returning existing panel")
		return spotifyState.panel 
	end
    
    -- Check local upvalue first, then global
    local module = SiriusSpotifyModule or _G.SiriusSpotifyModule

	if module and module.getMusicPanel then
		print("[Sirius] ensureSpotifyPanel: getting panel from module")
		spotifyState.panel = module.getMusicPanel()
		if spotifyState.panel then
			print("[Sirius] ensureSpotifyPanel: panel retrieved successfully")
			spotifyState.panel.Visible = false
			spotifyState.panel.GroupTransparency = 1

		else
			warn("[Sirius] ensureSpotifyPanel: getMusicPanel returned nil")
		end
	else
		warn("[Sirius] ensureSpotifyPanel: SiriusSpotifyModule or getMusicPanel missing", module)
	end
	return spotifyState.panel
end

local function openSpotifyPanel()
	print("[Sirius] openSpotifyPanel called, open:", spotifyState.open)
	local panel = ensureSpotifyPanel()
	if not panel then 
		warn("[Sirius] openSpotifyPanel: panel is nil")
		return 
	end
	if spotifyState.open then 
		print("[Sirius] openSpotifyPanel: already open, skipping")
		return 
	end
	spotifyState.open = true
	panel.Visible = true
	panel.GroupTransparency = 1
	panel.Size = UDim2.new(0, 550, 0, 310)

	local tokenSection = panel:FindFirstChild("TokenSection")
	local contentArea = panel:FindFirstChild("ContentArea")
	local inputElements = {}

	if tokenSection then
		local submitButton = tokenSection:FindFirstChild("SubmitButton")
		local tokenInput = tokenSection:FindFirstChild("TokenInput")
		local howButton = tokenSection:FindFirstChild("HowButton")
		if submitButton then table.insert(inputElements, submitButton) end
		if tokenInput then table.insert(inputElements, tokenInput) end
		if howButton then table.insert(inputElements, howButton) end
	end

	for _, element in ipairs(inputElements) do
		element.Visible = false
		if element:IsA("TextButton") or element:IsA("TextBox") then
			element.BackgroundTransparency = 1
			element.TextTransparency = 1
		end
	end

	tweenService:Create(panel, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 350)}):Play()
	tweenService:Create(panel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()

	local module = SiriusSpotifyModule or _G.SiriusSpotifyModule
	local isAuthenticated = module and module.isAuthenticated and module.isAuthenticated()
	
	if isAuthenticated and contentArea then
		if tokenSection then tokenSection.Visible = false end
		contentArea.Visible = true
	else
		if contentArea then contentArea.Visible = false end
		if tokenSection then tokenSection.Visible = true end
		task.delay(0.3, function()
			for _, element in ipairs(inputElements) do
				element.Visible = true
				local targetBg = 0
				if element.Name == "HowButton" then
					targetBg = 1
				end
				tweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = targetBg,
					TextTransparency = 0
				}):Play()
			end
		end)
	end
	print("[Sirius] openSpotifyPanel finished, open:", spotifyState.open)
end

local function closeSpotifyPanel()
	print("[Sirius] closeSpotifyPanel called, open:", spotifyState.open)
	local panel = ensureSpotifyPanel()
	if not panel then return end
	if not spotifyState.open then 
		print("[Sirius] closeSpotifyPanel: already closed, skipping")
		return 
	end
	spotifyState.open = false
	local tokenSection = panel:FindFirstChild("TokenSection")
	local contentArea = panel:FindFirstChild("ContentArea")
	if tokenSection then tokenSection.Visible = false end
	if contentArea then contentArea.Visible = false end
	tweenService:Create(panel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 520, 0, 0),
		GroupTransparency = 1
	}):Play()
	task.delay(0.5, function()
		if not spotifyState.open and panel then
			panel.Visible = false
			panel.Size = UDim2.new(0, 600, 0, 350)
		end
	end)
	print("[Sirius] closeSpotifyPanel finished, open:", spotifyState.open)
end

local function toggleSpotifyPanel()
	local panel = ensureSpotifyPanel()
	if not panel then return end
	-- Check actual panel visibility, not the flag (flag can desync)
	local isActuallyVisible = panel.Visible and panel.GroupTransparency < 0.5
	print("[Sirius] toggleSpotifyPanel - Visible:", panel.Visible, "Transparency:", panel.GroupTransparency, "isActuallyVisible:", isActuallyVisible)
	if isActuallyVisible then
		closeSpotifyPanel()
	else
		openSpotifyPanel()
	end
end

local function initSpotifyModule()
	print("[Sirius] initSpotifyModule called (Music button clicked)")
	
	-- Only load once
	if not spotifyState.moduleLoaded then
		local module = SiriusSpotifyModule or _G.SiriusSpotifyModule
		if not module then
			print("[Sirius] Module not loaded yet, loading from GitHub...")
			
			-- Create UI Container
			local MusicGui = Instance.new("ScreenGui")
			MusicGui.Name = "SiriusMusicGui"
			MusicGui.ResetOnSpawn = false
			if gethui then
				MusicGui.Parent = gethui()
			elseif game:GetService("CoreGui") then
				MusicGui.Parent = game:GetService("CoreGui")
			else
				MusicGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
			end

			-- Mock siriusValues
			local mockSiriusValues = {
				loaded = true,
				settings = {
					dynamicisland = true
				}
			}

			-- Wrap Notification
			local function mockQueueNotification(title, desc, icon)
				if notify then
					notify(title, desc)
				else
					warn("[SiriusMusic]", title, desc)
				end
			end

			-- Load Module from GitHub
			local success, SiriusSpotify = pcall(function()
				return loadstring(game:HttpGet("https://raw.githubusercontent.com/epixpaws/Sirius-Infinite-Yield/refs/heads/main/SiriusSpotify.lua"))()
			end)

			if success and SiriusSpotify and type(SiriusSpotify) == "table" then
				SiriusSpotifyModule = SiriusSpotify
				_G.SiriusSpotifyModule = SiriusSpotify
				SiriusSpotify.init({
					httpService = game:GetService("HttpService"),
					httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request,
					tweenService = game:GetService("TweenService"),
					userInputService = game:GetService("UserInputService"),
					UI = MusicGui,
					siriusValues = mockSiriusValues,
					queueNotification = mockQueueNotification,
					getcustomasset = getcustomasset or getsynasset or gethui
				})
				SiriusSpotify.buildSpotifyUI()
				spotifyState.moduleLoaded = true
				if notify then notify("Spotify Module", "Loaded successfully") end
				print("[Sirius] Spotify module loaded from GitHub SUCCESS")
			else
				warn("[Sirius] Failed to load SiriusSpotify module:", SiriusSpotify)
				if notify then notify("Spotify Module", "Failed to load module") end
				return
			end
		else
			-- Module already exists in global, mark as loaded
			spotifyState.moduleLoaded = true
		end
	end
	
	toggleSpotifyPanel()
end

local function fetchIcon(iconName)
	pcall(function()
		checkFolder()

		local pathCDN = siriusValues.icons..iconName..".png"
		local path = siriusValues.siriusFolder.."/Assets/"..iconName..".png"

		if not isfile(path) then
			local file = game:HttpGet(pathCDN)
			if not file then return end

			writefile(path, file)
		end

		local imageToReturn = getcustomasset(path)

		return imageToReturn
	end)
end

local function storeOriginalText(element)
	originalTextValues[element] = element.Text
end

local function undoAnonymousChanges()
	for element, originalText in pairs(originalTextValues) do
		element.Text = originalText
	end
end

local function createEsp(player)
	if player == localPlayer or not checkSirius() then 
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 0
	highlight.OutlineColor = Color3.new(1,1,1)
	highlight.Adornee = player.Character
	highlight.Name = player.Name
	highlight.Enabled = siriusValues.actions[7].enabled
	highlight.Parent = espContainer

	player.CharacterAdded:Connect(function(character)
		if not checkSirius() then return end
		task.wait()
		highlight.Adornee = character
	end)
end

local function makeDraggable(object)
	local dragging = false
	local relative = nil

	local offset = Vector2.zero
	local screenGui = object:FindFirstAncestorWhichIsA("ScreenGui")
	if screenGui and screenGui.IgnoreGuiInset then
		offset += guiService:GetGuiInset()
	end

	object.InputBegan:Connect(function(input, processed)
		if processed then return end

		local inputType = input.UserInputType.Name
		if inputType == "MouseButton1" or inputType == "Touch" then
			relative = object.AbsolutePosition + object.AbsoluteSize * object.AnchorPoint - userInputService:GetMouseLocation()
			dragging = true
		end
	end)

	local inputEnded = userInputService.InputEnded:Connect(function(input)
		if not dragging then return end

		local inputType = input.UserInputType.Name
		if inputType == "MouseButton1" or inputType == "Touch" then
			dragging = false
		end
	end)

	local renderStepped = runService.RenderStepped:Connect(function()
		if dragging then
			local position = userInputService:GetMouseLocation() + relative + offset
			object.Position = UDim2.fromOffset(position.X, position.Y)
		end
	end)

	object.Destroying:Connect(function()
		inputEnded:Disconnect()
		renderStepped:Disconnect()
	end)
end

local function checkAction(target)
	local toReturn = {}

	for _, action in ipairs(siriusValues.actions) do
		if action.name == target then
			toReturn.action = action
			break
		end
	end

	for _, action in ipairs(characterPanel.Interactions.Grid:GetChildren()) do
		if action.name == target then
			toReturn.object = action
			break
		end
	end

	return toReturn
end

checkSetting = function(settingTarget, categoryTarget)
	for _, category in ipairs(siriusSettings) do
		if categoryTarget then
			if category.name == categoryTarget then
				for _, setting in ipairs(category.categorySettings) do
					if setting.name == settingTarget then
						return setting
					end
				end
			end
			return
		else
			for _, setting in ipairs(category.categorySettings) do
				if setting.name == settingTarget then
					return setting
				end
			end
		end
	end
end

local function wipeTransparency(ins, target, checkSelf, tween, duration)
	local transparencyProperties = siriusValues.transparencyProperties

	local function applyTransparency(obj)
		local properties = transparencyProperties[obj.className]

		if properties then
			local tweenProperties = {}

			for _, property in ipairs(properties) do
				tweenProperties[property] = target
			end

			for property, transparency in pairs(tweenProperties) do
				if tween then
					tweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {[property] = transparency}):Play()
				else
					obj[property] = transparency
				end

			end
		end
	end

	if checkSelf then
		applyTransparency(ins)
	end

	for _, descendant in ipairs(ins:getDescendants()) do
		applyTransparency(descendant)
	end
end

local function blurSignature(value)
	if not value then
		if lighting:FindFirstChild("SiriusBlur") then
			lighting:FindFirstChild("SiriusBlur"):Destroy()
		end
	else
		if not lighting:FindFirstChild("SiriusBlur") then
			local blurLight = Instance.new("DepthOfFieldEffect", lighting)
			blurLight.Name = "SiriusBlur"
			blurLight.Enabled = true
			blurLight.FarIntensity = 0
			blurLight.FocusDistance = 51.6
			blurLight.InFocusRadius = 50
			blurLight.NearIntensity = 0.8
		end
	end
end

local function figureNotifications()
	if checkSirius() then
		local notificationsSize = 0

		if #notifications > 0 then
			blurSignature(true)
		else
			blurSignature(false)
		end

		for i = #notifications, 0, -1 do
			local notification = notifications[i]
			if notification then
				if notificationsSize == 0 then
					notificationsSize = notification.Size.Y.Offset + 2
				else
					notificationsSize += notification.Size.Y.Offset + 5
				end
				local desiredPosition = UDim2.new(0.5, 0, 0, notificationsSize)
				if notification.Position ~= desiredPosition then
					notification:TweenPosition(desiredPosition, "Out", "Quint", 0.8, true)
				end
			end
		end	
	end
end

local contentProvider = game:GetService("ContentProvider")

queueNotification = function(Title, Description, Image)
	task.spawn(function()		
		if checkSirius() then
			local newNotification = notificationContainer.Template:Clone()
			newNotification.Parent = notificationContainer
			newNotification.Name = Title or "Unknown Title"
			newNotification.Visible = true

			newNotification.Title.Text = Title or "Unknown Title"
			newNotification.Description.Text = Description or "Unknown Description"
			newNotification.Time.Text = "now"

			-- Prepare for animation
			newNotification.AnchorPoint = Vector2.new(0.5, 1)
			newNotification.Position = UDim2.new(0.5, 0, -1, 0)
			newNotification.Size = UDim2.new(0, 320, 0, 500)
			newNotification.Description.Size = UDim2.new(0, 241, 0, 400)
			wipeTransparency(newNotification, 1, true)

			newNotification.Description.Size = UDim2.new(0, 241, 0, newNotification.Description.TextBounds.Y)
			newNotification.Size = UDim2.new(0, 100, 0, newNotification.Description.TextBounds.Y + 50)

			table.insert(notifications, newNotification)
			figureNotifications()

			local notificationSound = Instance.new("Sound")
			notificationSound.Parent = UI
			notificationSound.SoundId = "rbxassetid://255881176"
			notificationSound.Name = "notificationSound"
			notificationSound.Volume = 0.65
			notificationSound.PlayOnRemove = true
			notificationSound:Destroy()

			if not tonumber(Image) then
				newNotification.Icon.Image = 'rbxassetid://14317577326'
			else
				newNotification.Icon.Image = 'rbxassetid://'..Image or 0
			end

			newNotification:TweenPosition(UDim2.new(0.5, 0, 0, newNotification.Size.Y.Offset + 2), "Out", "Quint", 0.9, true)
			task.wait(0.1)
			tweenService:Create(newNotification, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 320, 0, newNotification.Description.TextBounds.Y + 50)}):Play()
			task.wait(0.05)
			tweenService:Create(newNotification, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.35}):Play()
			tweenService:Create(newNotification.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0.7}):Play()
			task.wait(0.05)
			tweenService:Create(newNotification.Icon, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
			task.wait(0.04)
			tweenService:Create(newNotification.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			task.wait(0.04)
			tweenService:Create(newNotification.Description, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0.15}):Play()
			tweenService:Create(newNotification.Time, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0.5}):Play()

			--neonModule:BindFrame(newNotification.BlurModule, {
			--	Transparency = 0.98,
			--	BrickColor = BrickColor.new("Institutional white")
			--})

			newNotification.Interact.MouseButton1Click:Connect(function()
				local foundNotification = table.find(notifications, newNotification)
				if foundNotification then table.remove(notifications, foundNotification) end

				tweenService:Create(newNotification, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, 0, newNotification.Position.Y.Offset)}):Play()

				task.wait(0.4)
				newNotification:Destroy()
				figureNotifications()
				return
			end)

			local waitTime = (#newNotification.Description.Text*0.1)+2
			if waitTime <= 1 then waitTime = 2.5 elseif waitTime > 10 then waitTime = 10 end

			task.wait(waitTime)

			local foundNotification = table.find(notifications, newNotification)
			if foundNotification then table.remove(notifications, foundNotification) end

			tweenService:Create(newNotification, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, 0, newNotification.Position.Y.Offset)}):Play()

			task.wait(1.2)
			--neonModule:UnbindFrame(newNotification.BlurModule)
			newNotification:Destroy()
			figureNotifications()
		end
	end)
end

local function checkLastVersion()
	checkFolder()

	local lastVersion = isfile and isfile(siriusValues.siriusFolder.."/".."version.srs") and readfile(siriusValues.siriusFolder.."/".."version.srs") or nil

	if lastVersion then
		if lastVersion ~= siriusValues.siriusVersion then queueNotification("Sirius has been updated", "Sirius has been updated to version "..siriusValues.siriusVersion..", check our Discord for all new features and changes.", 4400701828)  end
	end

	if writefile then writefile(siriusValues.siriusFolder.."/".."version.srs", siriusValues.siriusVersion) end
end

local function removeReverbs(timing)
	timing = timing or 0.65

	for index, sound in next, soundInstances do
		if sound:FindFirstChild("SiriusAudioProfile") then
			local reverb = sound:FindFirstChild("SiriusAudioProfile")
			tweenService:Create(reverb, TweenInfo.new(timing, Enum.EasingStyle.Exponential), {HighGain = 0}):Play()
			tweenService:Create(reverb, TweenInfo.new(timing, Enum.EasingStyle.Exponential), {LowGain = 0}):Play()
			tweenService:Create(reverb, TweenInfo.new(timing, Enum.EasingStyle.Exponential), {MidGain = 0}):Play()

			task.delay(timing + 0.03, reverb.Destroy, reverb)
		end
	end
end

local function createReverb(timing)
	for index, sound in next, soundInstances do
		if not sound:FindFirstChild("SiriusAudioProfile") then
			local reverb = Instance.new("EqualizerSoundEffect")

			reverb.Name = "SiriusAudioProfile"
			reverb.Parent = sound

			reverb.Enabled = false

			reverb.HighGain = 0
			reverb.LowGain = 0
			reverb.MidGain = 0
			reverb.Enabled = true

			if timing then
				tweenService:Create(reverb, TweenInfo.new(timing, Enum.EasingStyle.Exponential), {HighGain = -20}):Play()
				tweenService:Create(reverb, TweenInfo.new(timing, Enum.EasingStyle.Exponential), {LowGain = 5}):Play()
				tweenService:Create(reverb, TweenInfo.new(timing, Enum.EasingStyle.Exponential), {MidGain = -20}):Play()
			end
		end
	end
end

local function runScript(raw)
	loadstring(game:HttpGet(raw))()
end

local function syncExperienceInformation()
	siriusValues.currentCreator = creatorId

	if creatorType == Enum.CreatorType.Group then
		siriusValues.currentGroup = creatorId
		siriusValues.currentCreator = "group"
	end

	for _, gameFound in pairs(siriusValues.games) do
		if gameFound.id == placeId and gameFound.enabled then

			local minimumTier = gameFound.minimumTier

			if minimumTier == "Essential" then
				if not (Essential or Pro) then
					return
				end
			elseif minimumTier == "Pro" then
				if not Pro then
					return
				end
			end

			local rawFile = siriusValues.rawTree..gameFound.raw
			siriusValues.currentGame = gameFound

			gameDetectionPrompt.ScriptTitle.Text = gameFound.name
			gameDetectionPrompt.Layer.ScriptSubtitle.Text = gameFound.description
			gameDetectionPrompt.Thumbnail.Image = "https://assetgame.roblox.com/Game/Tools/ThumbnailAsset.ashx?aid="..tostring(placeId).."&fmt=png&wd=420&ht=420"

			gameDetectionPrompt.Size = UDim2.new(0, 550, 0, 0)
			gameDetectionPrompt.Position = UDim2.new(0.5, 0, 0, 120)
			gameDetectionPrompt.UICorner.CornerRadius = UDim.new(0, 9)
			gameDetectionPrompt.Thumbnail.UICorner.CornerRadius = UDim.new(0, 9)
			gameDetectionPrompt.ScriptTitle.Position = UDim2.new(0, 30, 0.5, 0)
			gameDetectionPrompt.Layer.Visible = false
			gameDetectionPrompt.Warning.Visible = false

			wipeTransparency(gameDetectionPrompt, 1, true)

			gameDetectionPrompt.Visible = true

			tweenService:Create(gameDetectionPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
			tweenService:Create(gameDetectionPrompt.Thumbnail, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {ImageTransparency = 0.4}):Play()
			tweenService:Create(gameDetectionPrompt.ScriptTitle, TweenInfo.new(0.6, Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()

			tweenService:Create(gameDetectionPrompt, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 587, 0, 44)}):Play()
			tweenService:Create(gameDetectionPrompt, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5, 0, 0, 150)}):Play()

			task.wait(1)

			wipeTransparency(gameDetectionPrompt.Layer, 1, true)

			gameDetectionPrompt.Layer.Visible = true

			tweenService:Create(gameDetectionPrompt, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 473, 0, 154)}):Play()
			tweenService:Create(gameDetectionPrompt.ScriptTitle, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 23, 0.352, 0)}):Play()
			tweenService:Create(gameDetectionPrompt, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5, 0, 0, 200)}):Play()
			tweenService:Create(gameDetectionPrompt.UICorner, TweenInfo.new(1, Enum.EasingStyle.Exponential), {CornerRadius = UDim.new(0, 13)}):Play()
			tweenService:Create(gameDetectionPrompt.Thumbnail.UICorner, TweenInfo.new(1, Enum.EasingStyle.Exponential), {CornerRadius = UDim.new(0, 13)}):Play()
			tweenService:Create(gameDetectionPrompt.Thumbnail, TweenInfo.new(1, Enum.EasingStyle.Exponential), {ImageTransparency = 0.5}):Play()

			task.wait(0.3)
			tweenService:Create(gameDetectionPrompt.Layer.ScriptSubtitle, TweenInfo.new(0.6, Enum.EasingStyle.Quint),  {TextTransparency = 0.3}):Play()
			tweenService:Create(gameDetectionPrompt.Layer.Run, TweenInfo.new(0.6, Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()
			tweenService:Create(gameDetectionPrompt.Layer.Run.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint),  {Transparency = 0.85}):Play()
			tweenService:Create(gameDetectionPrompt.Layer.Run, TweenInfo.new(0.6, Enum.EasingStyle.Quint),  {BackgroundTransparency = 0.6}):Play()

			task.wait(0.2)

			tweenService:Create(gameDetectionPrompt.Layer.Close, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()

			task.wait(0.3)

			local function closeGameDetection()
				tweenService:Create(gameDetectionPrompt.Layer.ScriptSubtitle, TweenInfo.new(0.3, Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
				tweenService:Create(gameDetectionPrompt.Layer.Run, TweenInfo.new(0.3, Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
				tweenService:Create(gameDetectionPrompt.Layer.Run, TweenInfo.new(0.3, Enum.EasingStyle.Quint),  {BackgroundTransparency = 1}):Play()
				tweenService:Create(gameDetectionPrompt.Layer.Close, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
				tweenService:Create(gameDetectionPrompt.Thumbnail, TweenInfo.new(0.3, Enum.EasingStyle.Quint),  {ImageTransparency = 1}):Play()
				tweenService:Create(gameDetectionPrompt.ScriptTitle, TweenInfo.new(0.3, Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
				tweenService:Create(gameDetectionPrompt.Layer.Run.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint),  {Transparency = 1}):Play()
				task.wait(0.05)
				tweenService:Create(gameDetectionPrompt, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 400, 0, 0)}):Play()
				tweenService:Create(gameDetectionPrompt.UICorner, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {CornerRadius = UDim.new(0, 5)}):Play()
				tweenService:Create(gameDetectionPrompt.Thumbnail.UICorner, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {CornerRadius = UDim.new(0, 5)}):Play()
				task.wait(0.41)
				gameDetectionPrompt.Visible = false
			end

			gameDetectionPrompt.Layer.Run.MouseButton1Click:Connect(function()
				closeGameDetection()
				queueNotification("Running "..gameFound.name, "Now running Sirius' "..gameFound.name.." script, this may take a moment.", 4400701828)
				runScript(rawFile)

			end)

			gameDetectionPrompt.Layer.Close.MouseButton1Click:Connect(function()
				closeGameDetection()
			end)

			break
		end
	end
end

local function updateSliderPadding()
	for _, v in pairs(siriusValues.sliders) do
		v.padding = {
			v.object.Interact.AbsolutePosition.X,
			v.object.Interact.AbsolutePosition.X + v.object.Interact.AbsoluteSize.X
		}
	end
end

local function updateSlider(data, setValue, forceValue)
	local inverse_interpolation

	if setValue then
		setValue = math.clamp(setValue, data.values[1], data.values[2])
		inverse_interpolation = (setValue - data.values[1]) / (data.values[2] - data.values[1])
		local posX = data.padding[1] + (data.padding[2] - data.padding[1]) * inverse_interpolation
	else
		local posX = math.clamp(mouse.X, data.padding[1], data.padding[2])
		inverse_interpolation = (posX - data.padding[1]) / (data.padding[2] - data.padding[1])
	end

	tweenService:Create(data.object.Progress, TweenInfo.new(.5, Enum.EasingStyle.Quint), {Size = UDim2.new(inverse_interpolation, 0, 1, 0)}):Play()

	local value = math.floor(data.values[1] + (data.values[2] - data.values[1]) * inverse_interpolation + .5)
	data.object.Information.Text = value.." "..data.name
	data.value = value

	if data.callback and not setValue or forceValue then
		data.callback(value)
	end
end

local function resetSliders()
	for _, v in pairs(siriusValues.sliders) do
		updateSlider(v, v.default, true)
	end
end

local function sortActions()	
	characterPanel.Interactions.Grid.Template.Visible = false
	characterPanel.Interactions.Sliders.Template.Visible = false

	for _, action in ipairs(siriusValues.actions) do
		local newAction = characterPanel.Interactions.Grid.Template:Clone()
		newAction.Name = action.name
		newAction.Parent = characterPanel.Interactions.Grid
		newAction.BackgroundColor3 = action.color
		newAction.UIStroke.Color = action.color
		newAction.Icon.Image = "rbxassetid://"..action.images[2]
		newAction.Visible = true

		newAction.BackgroundTransparency = 0.8
		newAction.Transparency = 0.7

		newAction.MouseEnter:Connect(function()
			characterPanel.Interactions.ActionsTitle.Text = string.upper(action.name)
			if action.enabled or debounce then return end
			tweenService:Create(newAction, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.4}):Play()
			tweenService:Create(newAction.UIStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Transparency = 0.6}):Play()
		end)

		newAction.MouseLeave:Connect(function()
			if action.enabled or debounce then return end
			tweenService:Create(newAction, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.55}):Play()
			tweenService:Create(newAction.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.4}):Play()
		end)

		characterPanel.Interactions.Grid.MouseLeave:Connect(function()
			characterPanel.Interactions.ActionsTitle.Text = "PLAYER ACTIONS"
		end)

		newAction.Interact.MouseButton1Click:Connect(function()
			local success, response = pcall(function()
				action.enabled = not action.enabled
				action.callback(action.enabled)

				if action.enabled then
					newAction.Icon.Image = "rbxassetid://"..action.images[1]
					tweenService:Create(newAction, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.1}):Play()
					tweenService:Create(newAction.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
					tweenService:Create(newAction.Icon, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {ImageTransparency = 0.1}):Play()

					if action.disableAfter then
						task.delay(action.disableAfter, function()
							action.enabled = false
							newAction.Icon.Image = "rbxassetid://"..action.images[2]
							tweenService:Create(newAction, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.55}):Play()
							tweenService:Create(newAction.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.4}):Play()
							tweenService:Create(newAction.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.5}):Play()
						end)
					end

					if action.rotateWhileEnabled then
						repeat
							newAction.Icon.Rotation = 0
							tweenService:Create(newAction.Icon, TweenInfo.new(0.75, Enum.EasingStyle.Quint), {Rotation = 360}):Play()
							task.wait(1)
						until not action.enabled
						newAction.Icon.Rotation = 0
					end
				else
					newAction.Icon.Image = "rbxassetid://"..action.images[2]
					tweenService:Create(newAction, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.55}):Play()
					tweenService:Create(newAction.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.4}):Play()
					tweenService:Create(newAction.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.5}):Play()
				end
			end)

			if not success then
				queueNotification("Action Error", "This action ('"..(action.name).."') had an error while running, please report this to the Sirius team at discord.gg/XVmJgHk3RG", 4370336704)
				action.enabled = false
				newAction.Icon.Image = "rbxassetid://"..action.images[2]
				tweenService:Create(newAction, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.55}):Play()
				tweenService:Create(newAction.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.4}):Play()
				tweenService:Create(newAction.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.5}):Play()
			end
		end)
	end

	if localPlayer.Character then
		if not localPlayer.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
			siriusValues.sliders[2].name = "jump height"
			siriusValues.sliders[2].default = 7.2
			siriusValues.sliders[2].values = {0, 120}
		end
	end

	for _, slider in ipairs(siriusValues.sliders) do
		local newSlider = characterPanel.Interactions.Sliders.Template:Clone()
		newSlider.Name = slider.name.." Slider"
		newSlider.Parent = characterPanel.Interactions.Sliders
		newSlider.BackgroundColor3 = slider.color
		newSlider.Progress.BackgroundColor3 = slider.color
		newSlider.UIStroke.Color = slider.color
		newSlider.Information.Text = slider.name
		newSlider.Visible = true

		slider.object = newSlider

		slider.padding = {
			newSlider.Interact.AbsolutePosition.X,
			newSlider.Interact.AbsolutePosition.X + newSlider.Interact.AbsoluteSize.X
		}

		newSlider.MouseEnter:Connect(function()
			if debounce or slider.active then return end
			tweenService:Create(newSlider, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.85}):Play()
			tweenService:Create(newSlider.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.6}):Play()
			tweenService:Create(newSlider.Information, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
		end)

		newSlider.MouseLeave:Connect(function()
			if debounce or slider.active then return end
			tweenService:Create(newSlider, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.8}):Play()
			tweenService:Create(newSlider.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
			tweenService:Create(newSlider.Information, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0.3}):Play()
		end)

		newSlider.Interact.MouseButton1Down:Connect(function()
			if debounce or not checkSirius() then return end

			slider.active = true
			updateSlider(slider)

			tweenService:Create(slider.object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.9}):Play()
			tweenService:Create(slider.object.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
			tweenService:Create(slider.object.Information, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0.05}):Play()
		end)

		updateSlider(slider, slider.default)
	end
end

local function getAdaptiveHighPingThreshold()
	local adaptiveBaselinePings = siriusValues.pingProfile.adaptiveBaselinePings

	if #adaptiveBaselinePings == 0 then
		return siriusValues.pingProfile.adaptiveHighPingThreshold
	end

	table.sort(adaptiveBaselinePings)
	local median
	if #adaptiveBaselinePings % 2 == 0 then
		median = (adaptiveBaselinePings[#adaptiveBaselinePings/2] + adaptiveBaselinePings[#adaptiveBaselinePings/2 + 1]) / 2
	else
		median = adaptiveBaselinePings[math.ceil(#adaptiveBaselinePings/2)]
	end

	return median * siriusValues.pingProfile.spikeThreshold
end

local function checkHighPing()
	local recentPings = siriusValues.pingProfile.recentPings
	local adaptiveBaselinePings = siriusValues.pingProfile.adaptiveBaselinePings

	local currentPing = getPing()
	table.insert(recentPings, currentPing)

	if #recentPings > siriusValues.pingProfile.maxSamples then
		table.remove(recentPings, 1)
	end

	if #adaptiveBaselinePings < siriusValues.pingProfile.adaptiveBaselineSamples then
		if currentPing >= 350 then currentPing = 300 end

		table.insert(adaptiveBaselinePings, currentPing)

		return false
	end

	local averagePing = 0
	for _, ping in ipairs(recentPings) do
		averagePing = averagePing + ping
	end
	averagePing = averagePing / #recentPings

	if averagePing > getAdaptiveHighPingThreshold() then
		return true
	end

	return false
end

local function checkTools()
	task.wait(0.03)
	if localPlayer.Backpack and localPlayer.Character then
		if localPlayer.Backpack:FindFirstChildOfClass('Tool') or localPlayer.Character:FindFirstChildOfClass('Tool') then
			return true
		end
	else
		return false
	end
end

local function closePanel(panelName, openingOther)
	debounce = true

	local button = smartBar.Buttons:FindFirstChild(panelName)
	local panel = UI:FindFirstChild(panelName)

	if not isPanel(panelName) then return end
	if not (panel and button) then return end

	local panelSize = UDim2.new(0, 581, 0, 246)

	if not openingOther then
		if panel.Name == "Character" then -- Character Panel Animation

			tweenService:Create(characterPanel.Interactions.PropertiesTitle, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()

			for _, slider in ipairs(characterPanel.Interactions.Sliders:GetChildren()) do
				if slider.ClassName == "Frame" then 
					tweenService:Create(slider, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
					tweenService:Create(slider.Progress, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
					tweenService:Create(slider.UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
					tweenService:Create(slider.Shadow, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
					tweenService:Create(slider.Information, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play() -- tween the text after
				end
			end

			tweenService:Create(characterPanel.Interactions.Reset, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
			tweenService:Create(characterPanel.Interactions.ActionsTitle, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()

			for _, gridButton in ipairs(characterPanel.Interactions.Grid:GetChildren()) do
				if gridButton.ClassName == "Frame" then 
					tweenService:Create(gridButton, TweenInfo.new(0.21, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
					tweenService:Create(gridButton.UIStroke, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					tweenService:Create(gridButton.Icon, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
					tweenService:Create(gridButton.Shadow, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
				end
			end

			tweenService:Create(characterPanel.Interactions.Serverhop, TweenInfo.new(.15,Enum.EasingStyle.Quint),  {BackgroundTransparency = 1}):Play()
			tweenService:Create(characterPanel.Interactions.Serverhop.Title, TweenInfo.new(.15,Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
			tweenService:Create(characterPanel.Interactions.Serverhop.UIStroke, TweenInfo.new(.15,Enum.EasingStyle.Quint),  {Transparency = 1}):Play()

			tweenService:Create(characterPanel.Interactions.Rejoin, TweenInfo.new(.15,Enum.EasingStyle.Quint),  {BackgroundTransparency = 1}):Play()
			tweenService:Create(characterPanel.Interactions.Rejoin.Title, TweenInfo.new(.15,Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
			tweenService:Create(characterPanel.Interactions.Rejoin.UIStroke, TweenInfo.new(.15,Enum.EasingStyle.Quint),  {Transparency = 1}):Play()

		elseif panel.Name == "Scripts" then -- Scripts Panel Animation

			for _, scriptButton in ipairs(scriptsPanel.Interactions.Selection:GetChildren()) do
				if scriptButton.ClassName == "Frame" then
					tweenService:Create(scriptButton, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
					if scriptButton:FindFirstChild('Icon') then tweenService:Create(scriptButton.Icon, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play() end
					tweenService:Create(scriptButton.Title, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
					if scriptButton:FindFirstChild('Subtitle') then	tweenService:Create(scriptButton.Subtitle, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play() end
					tweenService:Create(scriptButton.UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
				end
			end

		elseif panel.Name == "Playerlist" then -- Playerlist Panel Animation

			for _, playerIns in ipairs(playerlistPanel.Interactions.List:GetDescendants()) do
				if playerIns.ClassName == "Frame" then
					tweenService:Create(playerIns, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
				elseif playerIns.ClassName == "TextLabel" or playerIns.ClassName == "TextButton" then
					if playerIns.Name == "DisplayName" then
						tweenService:Create(playerIns, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
					else
						tweenService:Create(playerIns, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
					end
				elseif playerIns.ClassName == "ImageLabel" or playerIns.ClassName == "ImageButton" then
					tweenService:Create(playerIns, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
					if playerIns.Name == "Avatar" then tweenService:Create(playerIns, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play() end
				elseif playerIns.ClassName == "UIStroke" then
					tweenService:Create(playerIns, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
				end
			end

			tweenService:Create(playerlistPanel.Interactions.SearchFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
			tweenService:Create(playerlistPanel.Interactions.SearchFrame.Icon, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
			tweenService:Create(playerlistPanel.Interactions.SearchFrame.SearchBox, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
			tweenService:Create(playerlistPanel.Interactions.SearchFrame.UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
			tweenService:Create(playerlistPanel.Interactions.List, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {ScrollBarImageTransparency = 1}):Play()

		end

		tweenService:Create(panel.Icon, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		tweenService:Create(panel.Title, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		tweenService:Create(panel.UIStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
		tweenService:Create(panel.Shadow, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		task.wait(0.03)

		tweenService:Create(panel, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
		tweenService:Create(panel, TweenInfo.new(1.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = button.Size}):Play()
		tweenService:Create(panel, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position = siriusValues.buttonPositions[panelName]}):Play()
		tweenService:Create(toggle, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 1, -85)}):Play()
	end

	-- Animate interactive elements
	if openingOther then
		tweenService:Create(panel, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 350, 1, -90)}):Play()
		wipeTransparency(panel, 1, true, true, 0.3)
	end

	task.wait(0.5)
	panel.Size = panelSize
	panel.Visible = false

	debounce = false
end

local function openPanel(panelName)
	if debounce then return end
	debounce = true

	local button = smartBar.Buttons:FindFirstChild(panelName)
	local panel = UI:FindFirstChild(panelName)

	if not isPanel(panelName) then return end
	if not (panel and button) then return end

	for _, otherPanel in ipairs(UI:GetChildren()) do
		if smartBar.Buttons:FindFirstChild(otherPanel.Name) then
			if isPanel(otherPanel.Name) and otherPanel.Visible then
				task.spawn(closePanel, otherPanel.Name, true)
				task.wait()
			end
		end
	end

	local panelSize = UDim2.new(0, 581, 0, 246)

	panel.Size = button.Size
	panel.Position = siriusValues.buttonPositions[panelName]

	wipeTransparency(panel, 1, true)

	panel.Visible = true

	tweenService:Create(toggle, TweenInfo.new(0.65, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 1, -(panelSize.Y.Offset + 95))}):Play()

	tweenService:Create(panel, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
	tweenService:Create(panel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {Size = panelSize}):Play()
	tweenService:Create(panel, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 1, -90)}):Play()
	task.wait(0.1)
	tweenService:Create(panel.Shadow, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {ImageTransparency = 0.7}):Play()
	tweenService:Create(panel.Icon, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
	task.wait(0.05)
	tweenService:Create(panel.Title, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(panel.UIStroke, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Transparency = 0.95}):Play()
	task.wait(0.05)

	-- Animate interactive elements
	if panel.Name == "Character" then -- Character Panel Animation

		tweenService:Create(characterPanel.Interactions.PropertiesTitle, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0.65}):Play()

		local sliderInfo = {}
		for _, slider in ipairs(characterPanel.Interactions.Sliders:GetChildren()) do
			if slider.ClassName == "Frame" then 
				table.insert(sliderInfo, {slider.Name, slider.Progress.Size, slider.Information.Text})
				slider.Progress.Size = UDim2.new(0, 0, 1, 0)
				slider.Progress.BackgroundTransparency = 0

				tweenService:Create(slider, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.8}):Play()
				tweenService:Create(slider.UIStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Transparency = 0.5}):Play()
				tweenService:Create(slider.Shadow, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {ImageTransparency = 0.6}):Play()
				tweenService:Create(slider.Information, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0.3}):Play()
			end
		end

		for _, sliderV in pairs(sliderInfo) do
			if characterPanel.Interactions.Sliders:FindFirstChild(sliderV[1]) then
				local slider = characterPanel.Interactions.Sliders:FindFirstChild(sliderV[1])
				local tweenValue = Instance.new("IntValue", UI)
				local tweenTo
				local name

				for _, sliderFound in ipairs(siriusValues.sliders) do
					if sliderFound.name.." Slider" == slider.Name then
						tweenTo = sliderFound.value
						name = sliderFound.name
						break
					end
				end

				tweenService:Create(slider.Progress, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Size = sliderV[2]}):Play()

				local function animateNumber(n)
					tweenService:Create(tweenValue, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {Value = n}):Play()
					task.delay(0.4, tweenValue.Destroy, tweenValue)
				end

				tweenValue:GetPropertyChangedSignal("Value"):Connect(function()
					slider.Information.Text = tostring(tweenValue.Value).." "..name
				end)

				animateNumber(tweenTo)
			end
		end

		tweenService:Create(characterPanel.Interactions.Reset, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {ImageTransparency = 0.7}):Play()
		tweenService:Create(characterPanel.Interactions.ActionsTitle, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0.65}):Play()

		for _, gridButton in ipairs(characterPanel.Interactions.Grid:GetChildren()) do
			if gridButton.ClassName == "Frame" then 
				for _, action in ipairs(siriusValues.actions) do
					if action.name == gridButton.Name then
						if action.enabled then
							tweenService:Create(gridButton, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.1}):Play()
							tweenService:Create(gridButton.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
							tweenService:Create(gridButton.Icon, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {ImageTransparency = 0.1}):Play()
						else
							tweenService:Create(gridButton, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.55}):Play()
							tweenService:Create(gridButton.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.4}):Play()
							tweenService:Create(gridButton.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.5}):Play()
						end
						break
					end
				end

				tweenService:Create(gridButton.Shadow, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageTransparency = 0.6}):Play()
			end
		end

		tweenService:Create(characterPanel.Interactions.Serverhop, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
		tweenService:Create(characterPanel.Interactions.Serverhop.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.5}):Play()
		tweenService:Create(characterPanel.Interactions.Serverhop.UIStroke, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Transparency = 0}):Play()

		tweenService:Create(characterPanel.Interactions.Rejoin, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
		tweenService:Create(characterPanel.Interactions.Rejoin.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.5}):Play()
		tweenService:Create(characterPanel.Interactions.Rejoin.UIStroke, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Transparency = 0}):Play()

	elseif panel.Name == "Scripts" then -- Scripts Panel Animation

		for _, scriptButton in ipairs(scriptsPanel.Interactions.Selection:GetChildren()) do
			if scriptButton.ClassName == "Frame" then
				tweenService:Create(scriptButton, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
				if scriptButton:FindFirstChild('Icon') then tweenService:Create(scriptButton.Icon, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play() end
				tweenService:Create(scriptButton.Title, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
				if scriptButton:FindFirstChild('Subtitle') then	tweenService:Create(scriptButton.Subtitle, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {TextTransparency = 0.3}):Play() end
				tweenService:Create(scriptButton.UIStroke, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Transparency = 0.2}):Play()
			end
		end

	elseif panel.Name == "Playerlist" then -- Playerlist Panel Animation

		for _, playerIns in ipairs(playerlistPanel.Interactions.List:GetDescendants()) do
			if playerIns.Name ~= "Interact" and playerIns.Name ~= "Role" then 
				if playerIns.ClassName == "Frame" then
					tweenService:Create(playerIns, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
				elseif playerIns.ClassName == "TextLabel" or playerIns.ClassName == "TextButton" then
					tweenService:Create(playerIns, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
				elseif playerIns.ClassName == "ImageLabel" or playerIns.ClassName == "ImageButton" then
					tweenService:Create(playerIns, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
					if playerIns.Name == "Avatar" then tweenService:Create(playerIns, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play() end
				elseif playerIns.ClassName == "UIStroke" then
					tweenService:Create(playerIns, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
				end
			end
		end

		tweenService:Create(playerlistPanel.Interactions.SearchFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
		tweenService:Create(playerlistPanel.Interactions.SearchFrame.Icon, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
		task.wait(0.01)
		tweenService:Create(playerlistPanel.Interactions.SearchFrame.SearchBox, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
		tweenService:Create(playerlistPanel.Interactions.SearchFrame.UIStroke, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Transparency = 0.2}):Play()
		task.wait(0.05)
		tweenService:Create(playerlistPanel.Interactions.List, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {ScrollBarImageTransparency = 0.7}):Play()

	end

	task.wait(0.45)
	debounce = false
end

local function rejoin()
	queueNotification("Rejoining Session", "We're queueing a rejoin to this session, give us a moment.", 4400696294)

	if #players:GetPlayers() <= 1 then
		task.wait()
		teleportService:Teleport(placeId, localPlayer)
	else
		teleportService:TeleportToPlaceInstance(placeId, jobId, localPlayer)
	end
end

local function serverhop()
	local highestPlayers = 0
	local servers = {}

	for _, v in ipairs(httpService:JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
		if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= jobId then
			if v.playing > highestPlayers then
				highestPlayers = v.playing
				servers[1] = v.id
			end
		end
	end

	if #servers > 0 then
		queueNotification("Teleporting", "We're now moving you to the new session, this may take a few seconds.", 4335479121)
		task.wait(0.3)
		teleportService:TeleportToPlaceInstance(placeId, servers[1])
	else
		return queueNotification("No Servers Found", "We couldn't find another server, this may be the only server.", 4370317928)
	end

end

local function ensureFrameProperties()
	UI.Enabled = true
	characterPanel.Visible = false
	customScriptPrompt.Visible = false
	disconnectedPrompt.Visible = false
	playerlistPanel.Interactions.List.Template.Visible = false
	gameDetectionPrompt.Visible = false
	homeContainer.Visible = false
	moderatorDetectionPrompt.Visible = false
	notificationContainer.Visible = true
	playerlistPanel.Visible = false
	scriptSearch.Visible = false
	scriptsPanel.Visible = false
	settingsPanel.Visible = false
	smartBar.Visible = false
	toastsContainer.Visible = true
	makeDraggable(settingsPanel)
	if smartBar.Buttons:FindFirstChild("Music") and not spotifyState.buttonConnected then
		spotifyState.buttonConnected = true
		smartBar.Buttons.Music.Visible = true
		smartBar.Buttons.Music.Interact.Active = true
		smartBar.Buttons.Music.Interact.MouseButton1Click:Connect(initSpotifyModule)
	end
end

local function checkFriends()
	if friendsCooldown == 0 then

		friendsCooldown = 25

		local playersFriends = {}
		local success, page = pcall(players.GetFriendsAsync, players, localPlayer.UserId)

		if success then
			repeat
				local info = page:GetCurrentPage()
				for i, friendInfo in pairs(info) do
					table.insert(playersFriends, friendInfo)
				end
				if not page.IsFinished then 
					page:AdvanceToNextPageAsync()
				end
			until page.IsFinished
		end

		local friendsInTotal = 0
		local onlineFriends = 0 
		local friendsInGame = 0 

		for i,v in pairs(playersFriends) do
			friendsInTotal  = friendsInTotal + 1

			if v.IsOnline then
				onlineFriends = onlineFriends + 1
			end

			if players:FindFirstChild(v.Username) then
				friendsInGame = friendsInGame + 1
			end
		end

		if not checkSirius() then return end

		homeContainer.Interactions.Friends.All.Value.Text = tostring(friendsInTotal).." friends"
		homeContainer.Interactions.Friends.Offline.Value.Text = tostring(friendsInTotal - onlineFriends).." friends"
		homeContainer.Interactions.Friends.Online.Value.Text = tostring(onlineFriends).." friends"
		homeContainer.Interactions.Friends.InGame.Value.Text = tostring(friendsInGame).." friends"

	else
		friendsCooldown -= 1
	end
end

function promptModerator(player, role)
	local serversAvailable = false
	local promptClosed = false

	if moderatorDetectionPrompt.Visible then return end

	moderatorDetectionPrompt.Size = UDim2.new(0, 283, 0, 175)
	moderatorDetectionPrompt.UIGradient.Offset = Vector2.new(0, 1)
	wipeTransparency(moderatorDetectionPrompt, 1, true)

	moderatorDetectionPrompt.DisplayName.Text = player.DisplayName
	moderatorDetectionPrompt.Rank.Text = role
	moderatorDetectionPrompt.Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"

	moderatorDetectionPrompt.Visible = true

	for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
		if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId then
			serversAvailable = true
		end
	end

	if not serversAvailable then
		moderatorDetectionPrompt.Serverhop.Visible = false
	else
		moderatorDetectionPrompt.ServersAvailableFade.Visible = true
	end

	tweenService:Create(moderatorDetectionPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
	tweenService:Create(moderatorDetectionPrompt, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 300, 0, 186)}):Play()
	tweenService:Create(moderatorDetectionPrompt.UIGradient, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Offset = Vector2.new(0, 0.65)}):Play()
	tweenService:Create(moderatorDetectionPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(moderatorDetectionPrompt.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(moderatorDetectionPrompt.Avatar, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.7}):Play()
	tweenService:Create(moderatorDetectionPrompt.Avatar, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
	tweenService:Create(moderatorDetectionPrompt.DisplayName, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(moderatorDetectionPrompt.Rank, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(moderatorDetectionPrompt.Serverhop, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.7}):Play()
	tweenService:Create(moderatorDetectionPrompt.Leave, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.7}):Play()
	task.wait(0.2)
	tweenService:Create(moderatorDetectionPrompt.Serverhop, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(moderatorDetectionPrompt.Leave, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	task.wait(0.3)
	tweenService:Create(moderatorDetectionPrompt.Close, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0.6}):Play()

	local function closeModPrompt()
		tweenService:Create(moderatorDetectionPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 283, 0, 175)}):Play()
		tweenService:Create(moderatorDetectionPrompt.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Offset = Vector2.new(0, 1)}):Play()
		tweenService:Create(moderatorDetectionPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Avatar, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Avatar, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.DisplayName, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Rank, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Serverhop, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Leave, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Serverhop, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Leave, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Close, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		task.wait(0.5)
		moderatorDetectionPrompt.Visible = false
	end

	moderatorDetectionPrompt.Leave.MouseButton1Click:Connect(function()
		closeModPrompt()
		game:Shutdown()
	end)

	moderatorDetectionPrompt.Serverhop.MouseEnter:Connect(function()
		tweenService:Create(moderatorDetectionPrompt.ServersAvailableFade, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
	end)

	moderatorDetectionPrompt.Serverhop.MouseLeave:Connect(function()
		tweenService:Create(moderatorDetectionPrompt.ServersAvailableFade, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
	end)

	moderatorDetectionPrompt.Serverhop.MouseButton1Click:Connect(function()
		if promptClosed then return end
		serverhop()
		closeModPrompt()
	end)

	moderatorDetectionPrompt.Close.MouseButton1Click:Connect(function()
		closeModPrompt()
		promptClosed = true
	end)
end

local function UpdateHome()
	if not checkSirius() then return end

	local function format(Int)
		return string.format("%02i", Int)
	end

	local function convertToHMS(Seconds)
		local Minutes = (Seconds - Seconds%60)/60
		Seconds = Seconds - Minutes*60
		local Hours = (Minutes - Minutes%60)/60
		Minutes = Minutes - Hours*60
		return format(Hours)..":"..format(Minutes)..":"..format(Seconds)
	end

	-- Home Title
	homeContainer.Title.Text = "Welcome home, "..localPlayer.DisplayName

	-- Players
	homeContainer.Interactions.Server.Players.Value.Text = #players:GetPlayers().." playing"
	homeContainer.Interactions.Server.MaxPlayers.Value.Text = players.MaxPlayers.." players can join this server"

	-- Ping
	homeContainer.Interactions.Server.Latency.Value.Text = math.floor(getPing()).."ms"

	-- Time
	homeContainer.Interactions.Server.Time.Value.Text = convertToHMS(time())

	-- Region
	homeContainer.Interactions.Server.Region.Value.Text = "Unable to retrieve region"

	-- Player Information
	homeContainer.Interactions.User.Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..localPlayer.UserId.."&width=420&height=420&format=png"
	homeContainer.Interactions.User.Title.Text = localPlayer.DisplayName
	homeContainer.Interactions.User.Subtitle.Text = localPlayer.Name

	-- Update Executor
	homeContainer.Interactions.Client.Title.Text = identifyexecutor()
	if not table.find(siriusValues.executors, string.lower(identifyexecutor())) then
		homeContainer.Interactions.Client.Subtitle.Text = "This executor is not verified as supported - but may still work just fine."
	end

	-- Update Friends Statuses
	checkFriends()
end

local function openHome()
	if debounce then return end
	debounce = true
	homeContainer.Visible = true

	local homeBlur = Instance.new("BlurEffect", lighting)
	homeBlur.Size = 0
	homeBlur.Name = "HomeBlur"

	homeContainer.BackgroundTransparency = 1
	homeContainer.Title.TextTransparency = 1
	homeContainer.Subtitle.TextTransparency = 1

	for _, homeItem in ipairs(homeContainer.Interactions:GetChildren()) do

		wipeTransparency(homeItem, 1, true)

		homeItem.Position = UDim2.new(0, homeItem.Position.X.Offset - 20, 0, homeItem.Position.Y.Offset - 20)
		homeItem.Size = UDim2.new(0, homeItem.Size.X.Offset + 30, 0, homeItem.Size.Y.Offset + 20)

		if homeItem.UIGradient.Offset.Y > 0 then
			homeItem.UIGradient.Offset = Vector2.new(0, homeItem.UIGradient.Offset.Y + 3)
			homeItem.UIStroke.UIGradient.Offset = Vector2.new(0, homeItem.UIStroke.UIGradient.Offset.Y + 3)
		else
			homeItem.UIGradient.Offset = Vector2.new(0, homeItem.UIGradient.Offset.Y - 3)
			homeItem.UIStroke.UIGradient.Offset = Vector2.new(0, homeItem.UIStroke.UIGradient.Offset.Y - 3)
		end
	end

	tweenService:Create(homeContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.9}):Play()
	tweenService:Create(homeBlur, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = 5}):Play()

	tweenService:Create(camera, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {FieldOfView = camera.FieldOfView + 5}):Play()

	task.wait(0.25)

	for _, inGameUI in ipairs(localPlayer:FindFirstChildWhichIsA("PlayerGui"):GetChildren()) do
		if inGameUI:IsA("ScreenGui") then
			if inGameUI.Enabled then
				if not table.find(getgenv().cachedInGameUI, inGameUI.Name) then
					table.insert(getgenv().cachedInGameUI, #getgenv().cachedInGameUI+1, inGameUI.Name)
				end

				inGameUI.Enabled = false
			end
		end
	end

	table.clear(getgenv().cachedCoreUI)

	for _, coreUI in pairs({"PlayerList", "Chat", "EmotesMenu", "Health", "Backpack"}) do
		if game:GetService("StarterGui"):GetCoreGuiEnabled(coreUI) then
			table.insert(getgenv().cachedCoreUI, #getgenv().cachedCoreUI+1, coreUI)
		end
	end

	for _, coreUI in pairs(getgenv().cachedCoreUI) do
		game:GetService("StarterGui"):SetCoreGuiEnabled(coreUI, false)
	end

	createReverb(0.8)

	tweenService:Create(camera, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {FieldOfView = camera.FieldOfView - 40}):Play()

	tweenService:Create(homeContainer, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.7}):Play()
	tweenService:Create(homeContainer.Title, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(homeContainer.Subtitle, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
	tweenService:Create(homeBlur, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Size = 20}):Play()

	for _, homeItem in ipairs(homeContainer.Interactions:GetChildren()) do
		for _, otherHomeItem in ipairs(homeItem:GetDescendants()) do
			if otherHomeItem.ClassName == "Frame" then
				tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.7}):Play()
			elseif otherHomeItem.ClassName == "TextLabel" then
				if otherHomeItem.Name == "Title" then
					tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
				else
					tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0.3}):Play()
				end
			elseif otherHomeItem.ClassName == "ImageLabel" then
				tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.8}):Play()
				tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
			end
		end

		tweenService:Create(homeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
		tweenService:Create(homeItem.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
		tweenService:Create(homeItem, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0, homeItem.Position.X.Offset + 20, 0, homeItem.Position.Y.Offset + 20)}):Play()
		tweenService:Create(homeItem, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, homeItem.Size.X.Offset - 30, 0, homeItem.Size.Y.Offset - 20)}):Play()

		task.delay(0.03, function()
			if homeItem.UIGradient.Offset.Y > 0 then
				tweenService:Create(homeItem.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Offset = Vector2.new(0, homeItem.UIGradient.Offset.Y - 3)}):Play()
				tweenService:Create(homeItem.UIStroke.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Offset = Vector2.new(0, homeItem.UIStroke.UIGradient.Offset.Y - 3)}):Play()
			else
				tweenService:Create(homeItem.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Offset = Vector2.new(0, homeItem.UIGradient.Offset.Y + 3)}):Play()
				tweenService:Create(homeItem.UIStroke.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Offset = Vector2.new(0, homeItem.UIStroke.UIGradient.Offset.Y + 3)}):Play()
			end
		end)

		task.wait(0.02)
	end

	task.wait(0.85)

	debounce = false
end

local function closeHome()
	if debounce then return end
	debounce = true

	tweenService:Create(camera, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {FieldOfView = camera.FieldOfView + 35}):Play()

	for _, obj in ipairs(lighting:GetChildren()) do
		if obj.Name == "HomeBlur" then
			tweenService:Create(obj, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Size = 0}):Play()
			task.delay(0.6, obj.Destroy, obj)
		end
	end

	tweenService:Create(homeContainer, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
	tweenService:Create(homeContainer.Title, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
	tweenService:Create(homeContainer.Subtitle, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()

	for _, homeItem in ipairs(homeContainer.Interactions:GetChildren()) do
		for _, otherHomeItem in ipairs(homeItem:GetDescendants()) do
			if otherHomeItem.ClassName == "Frame" then
				tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
			elseif otherHomeItem.ClassName == "TextLabel" then
				if otherHomeItem.Name == "Title" then
					tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
				else
					tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
				end
			elseif otherHomeItem.ClassName == "ImageLabel" then
				tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
				tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
			end
		end
		tweenService:Create(homeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
		tweenService:Create(homeItem.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
	end

	task.wait(0.2)

	for _, cachedInGameUIObject in pairs(getgenv().cachedInGameUI) do
		for _, currentPlayerUI in ipairs(localPlayer:FindFirstChildWhichIsA("PlayerGui"):GetChildren()) do
			if table.find(getgenv().cachedInGameUI, currentPlayerUI.Name) then
				currentPlayerUI.Enabled = true
			end 
		end
	end

	for _, coreUI in pairs(getgenv().cachedCoreUI) do
		game:GetService("StarterGui"):SetCoreGuiEnabled(coreUI, true)
	end

	removeReverbs(0.5)

	task.wait(0.52)

	homeContainer.Visible = false
	debounce = false
end

local function openScriptSearch()
	debounce = true

	scriptSearch.Size = UDim2.new(0, 480, 0, 23)
	scriptSearch.Position = UDim2.new(0.5, 0, 0.5, 0)
	scriptSearch.SearchBox.Position = UDim2.new(0.509, 0, 0.5, 0)
	scriptSearch.Icon.Position = UDim2.new(0.04, 0, 0.5, 0)
	scriptSearch.SearchBox.Text = ""
	scriptSearch.UIGradient.Offset = Vector2.new(0, 2)
	scriptSearch.SearchBox.PlaceholderText = "Search ScriptBlox.com"
	scriptSearch.List.Template.Visible = false
	scriptSearch.List.Visible = false
	scriptSearch.Visible = true

	wipeTransparency(scriptSearch, 1, true)

	tweenService:Create(scriptSearch, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
	tweenService:Create(scriptSearch, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Size = UDim2.new(0, 580, 0, 43)}):Play()
	tweenService:Create(scriptSearch.Shadow, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {ImageTransparency = 0.85}):Play()
	task.wait(0.03)
	tweenService:Create(scriptSearch.Icon, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {ImageTransparency = 0}):Play()
	task.wait(0.02)
	tweenService:Create(scriptSearch.SearchBox, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()

	task.wait(0.3)
	scriptSearch.SearchBox:CaptureFocus()
	task.wait(0.2)
	debounce = false
end

local function closeScriptSearch()
	debounce = true

	wipeTransparency(scriptSearch, 1, false)

	task.wait(0.1)

	scriptSearch.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	scriptSearch.UIGradient.Enabled = false
	tweenService:Create(scriptSearch, TweenInfo.new(0.4, Enum.EasingStyle.Quint),  {Size = UDim2.new(0, 520, 0, 0)}):Play()
	scriptSearch.SearchBox:ReleaseFocus()

	task.wait(0.5)

	for _, createdScript in ipairs(scriptSearch.List:GetChildren()) do
		if createdScript.Name ~= "Placeholder" and createdScript.Name ~= "Template" and createdScript.ClassName == "Frame" then
			createdScript:Destroy()
		end
	end

	task.wait(0.1)
	scriptSearch.BackgroundColor3 = Color3.fromRGB(255 ,255, 255)
	scriptSearch.Visible = false
	scriptSearch.UIGradient.Enabled = true
	debounce = false
end

local function createScript(result)
	local newScript = UI.ScriptSearch.List.Template:Clone()
	newScript.Name = result.title
	newScript.Parent = UI.ScriptSearch.List
	newScript.Visible = true

	for _, tag in ipairs(newScript.Tags:GetChildren()) do
		if tag.ClassName == "Frame" then
			tag.Shadow.ImageTransparency = 1
			tag.BackgroundTransparency = 1
			tag.Title.TextTransparency = 1
		end
	end

	task.spawn(function()
		local response

		local success, ErrorStatement = pcall(function()
			local responseRequest = httpRequest({
				Url = "https://www.scriptblox.com/api/script/"..result['slug'],
				Method = "GET"
			})

			response = httpService:JSONDecode(responseRequest.Body)
		end)

		newScript.ScriptDescription.Text = response.script.features

		local likes = response.script.likeCount
		local dislikes = response.script.dislikeCount

		if likes ~= dislikes then
			newScript.Tags.Review.Title.Text = (likes > dislikes) and "Positive Reviews" or "Negative Reviews"
			newScript.Tags.Review.BackgroundColor3 = (likes > dislikes) and Color3.fromRGB(0, 139, 102) or Color3.fromRGB(180, 0, 0)
			newScript.Tags.Review.Size = (likes > dislikes) and UDim2.new(0, 145, 1, 0) or UDim2.new(0, 150, 1, 0)
		elseif likes > 0 then
			newScript.Tags.Review.Title.Text = "Mixed Reviews"
			newScript.Tags.Review.BackgroundColor3 = Color3.fromRGB(198, 132, 0)
			newScript.Tags.Review.Size = UDim2.new(0, 130, 1, 0)
		else
			newScript.Tags.Review.Visible = false
		end

		newScript.ScriptAuthor.Text = "uploaded by "..response.script.owner.username
		newScript.Tags.Verified.Visible = response.script.owner.verified or false

		tweenService:Create(newScript, TweenInfo.new(.5, Enum.EasingStyle.Quint),  {BackgroundTransparency = 0.8}):Play()
		tweenService:Create(newScript.ScriptName, TweenInfo.new(.5, Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()
		tweenService:Create(newScript.Execute, TweenInfo.new(.5, Enum.EasingStyle.Quint),  {BackgroundTransparency = 0.8}):Play()
		tweenService:Create(newScript.Execute, TweenInfo.new(.5, Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()

		newScript.Tags.Visible = true

		tweenService:Create(newScript.ScriptDescription, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.3}):Play()
		tweenService:Create(newScript.ScriptAuthor, TweenInfo.new(.5, Enum.EasingStyle.Quint),  {TextTransparency = 0.7}):Play()

		for _, tag in ipairs(newScript.Tags:GetChildren()) do
			if tag.ClassName == "Frame" then
				tweenService:Create(tag.Shadow, TweenInfo.new(.5, Enum.EasingStyle.Quint),  {ImageTransparency = 0.7}):Play()
				tweenService:Create(tag, TweenInfo.new(.5, Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
				tweenService:Create(tag.Title, TweenInfo.new(.5, Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()
			end
		end
	end)

	wipeTransparency(newScript, 1, true)

	newScript.ScriptName.Text = result.title

	newScript.Tags.Visible = false
	newScript.Tags.Patched.Visible = result.isPatched or false

	newScript.Execute.MouseButton1Click:Connect(function()
		queueNotification("ScriptSearch", "Running "..result.title.. " via ScriptSearch" , 4384403532)
		closeScriptSearch()
		loadstring(result.script)()
	end)
end

local function extractDomain(link)
	local domainToReturn = link:match("([%w-_]+%.[%w-_%.]+)")
	return domainToReturn
end

local function securityDetection(title, content, link, gradient, actions)
	if not checkSirius() then return end

	local domain = extractDomain(link) or link
	checkFolder()
	local currentAllowlist = isfile and isfile(siriusValues.siriusFolder.."/".."allowedLinks.srs") and readfile(siriusValues.siriusFolder.."/".."allowedLinks.srs") or nil
	if currentAllowlist then currentAllowlist = httpService:JSONDecode(currentAllowlist) if table.find(currentAllowlist, domain) then return true end end

	local newSecurityPrompt = securityPrompt:Clone()

	newSecurityPrompt.Parent = UI
	newSecurityPrompt.Name = link

	wipeTransparency(newSecurityPrompt, 1, true)
	newSecurityPrompt.Size = UDim2.new(0, 478, 0, 150)

	newSecurityPrompt.Title.Text = title
	newSecurityPrompt.Subtitle.Text = content
	newSecurityPrompt.FoundLink.Text = domain

	newSecurityPrompt.Visible = true
	newSecurityPrompt.UIGradient.Color = gradient

	newSecurityPrompt.Buttons.Template.Visible = false

	local function closeSecurityPrompt()
		tweenService:Create(newSecurityPrompt, TweenInfo.new(0.52, Enum.EasingStyle.Quint),  {Size = UDim2.new(0, 500, 0, 165)}):Play()
		tweenService:Create(newSecurityPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {BackgroundTransparency = 1}):Play()
		tweenService:Create(newSecurityPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
		tweenService:Create(newSecurityPrompt.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
		tweenService:Create(newSecurityPrompt.FoundLink, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()

		for _, button in ipairs(newSecurityPrompt.Buttons:GetChildren()) do
			if button.Name ~= "Template" and button.ClassName == "TextButton" then
				tweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint),  {BackgroundTransparency = 1}):Play()
				tweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
			end
		end
		task.wait(0.55)
		newSecurityPrompt:Destroy()
	end

	local decision

	for _, action in ipairs(actions) do
		local newAction = newSecurityPrompt.Buttons.Template:Clone()
		newAction.Name = action[1]
		newAction.Text = action[1]
		newAction.Parent = newSecurityPrompt.Buttons
		newAction.Visible = true
		newAction.Size = UDim2.new(0, newAction.TextBounds.X + 50, 0, 36) -- textbounds

		newAction.MouseButton1Click:Connect(function()
			if action[2] then
				if action[3] then
					checkFolder()
					if currentAllowlist then
						table.insert(currentAllowlist, domain)
						writefile(siriusValues.siriusFolder.."/".."allowedLinks.srs", httpService:JSONEncode(currentAllowlist))
					else
						writefile(siriusValues.siriusFolder.."/".."allowedLinks.srs", httpService:JSONEncode({domain}))
					end
				end
				decision = true
			else
				decision = false
			end

			closeSecurityPrompt()
		end)
	end

	tweenService:Create(newSecurityPrompt, TweenInfo.new(0.4, Enum.EasingStyle.Quint),  {Size = UDim2.new(0, 576, 0, 181)}):Play()
	tweenService:Create(newSecurityPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
	tweenService:Create(newSecurityPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()
	tweenService:Create(newSecurityPrompt.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 0.3}):Play()
	task.wait(0.03)
	tweenService:Create(newSecurityPrompt.FoundLink, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 0.2}):Play()

	task.wait(0.1)

	for _, button in ipairs(newSecurityPrompt.Buttons:GetChildren()) do
		if button.Name ~= "Template" and button.ClassName == "TextButton" then
			tweenService:Create(button, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {BackgroundTransparency = 0.7}):Play()
			tweenService:Create(button, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 0.05}):Play()
			task.wait(0.1)
		end
	end

	newSecurityPrompt.FoundLink.MouseEnter:Connect(function()
		newSecurityPrompt.FoundLink.Text = link
		tweenService:Create(newSecurityPrompt.FoundLink, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 0.4}):Play()
	end)

	newSecurityPrompt.FoundLink.MouseLeave:Connect(function()
		newSecurityPrompt.FoundLink.Text = domain
		tweenService:Create(newSecurityPrompt.FoundLink, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 0.2}):Play()
	end)

	repeat task.wait() until decision
	return decision
end

if Essential or Pro then
	getgenv()[index] = function(data)
		if checkSirius() and checkSetting("Intelligent HTTP Interception").current then
			local title = "Do you trust this source?"
			local content = "Sirius has prevented data from being sent off-client, would you like to allow data to be sent or retrieved from this source?"
			local url = data.Url or "Unknown Link"
			local gradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1, Color3.new(0.764706, 0.305882, 0.0941176))})
			local actions = {{"Always Allow", true, true}, {"Allow just this once", true}, {"Don't Allow", false}}

			if url == "http://127.0.0.1:6463/rpc?v=1" then
				local bodyDecoded = httpService:JSONDecode(data.Body)

				if bodyDecoded.cmd == "INVITE_BROWSER" then
					title = "Would you like to join this Discord server?"
					content = "Sirius has prevented your Discord client from automatically joining this Discord server, would you like to continue and join, or block it?"
					url = bodyDecoded.args and "discord.gg/"..bodyDecoded.args.code or "Unknown Invite"
					gradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1, Color3.new(0.345098, 0.396078, 0.94902))})
					actions = {{"Allow", true}, {"Don't Allow", false}}
				end
			end

			local answer = securityDetection(title, content, url, gradient, actions)

			if answer then 
				return originalRequest(data)
			else
				return
			end
		else
			return originalRequest(data)
		end
	end

	getgenv()[indexSetClipboard] = function(data)
		if checkSirius() and checkSetting("Intelligent Clipboard Interception").current then
			local title = "Would you like to copy this to your clipboard?"
			local content = "Sirius has prevented a script from setting the below text to your clipboard, would you like to allow this, or prevent it from copying?"
			local url = data or "Unknown Clipboard"
			local gradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1, Color3.new(0.776471, 0.611765, 0.529412))})
			local actions = {{"Allow", true}, {"Don't Allow", false}}

			local answer = securityDetection(title, content, url, gradient, actions)

			if answer then 
				return originalSetClipboard(data)
			else
				return
			end
		else
			return originalSetClipboard(data)
		end
	end
end

local function searchScriptBlox(query)
	local response

	local success, ErrorStatement = pcall(function()
		local responseRequest = httpRequest({
			Url = "https://scriptblox.com/api/script/search?q="..httpService:UrlEncode(query).."&mode=free&max=20&page=1",
			Method = "GET"
		})

		response = httpService:JSONDecode(responseRequest.Body)
	end)

	if not success then
		queueNotification("ScriptSearch", "ScriptSearch backend encountered an error, try again later", 4384402990)
		closeScriptSearch()
		return
	end

	tweenService:Create(scriptSearch.NoScriptsTitle, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
	tweenService:Create(scriptSearch.NoScriptsDesc, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()

	for _, createdScript in ipairs(scriptSearch.List:GetChildren()) do
		if createdScript.Name ~= "Placeholder" and createdScript.Name ~= "Template" and createdScript.ClassName == "Frame" then
			wipeTransparency(createdScript, 1, true)
		end
	end

	scriptSearch.List.Visible = true
	task.wait(0.5)

	scriptSearch.List.CanvasPosition = Vector2.new(0,0)

	for _, createdScript in ipairs(scriptSearch.List:GetChildren()) do
		if createdScript.Name ~= "Placeholder" and createdScript.Name ~= "Template" and createdScript.ClassName == "Frame" then
			createdScript:Destroy()
		end
	end

	tweenService:Create(scriptSearch, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Size = UDim2.new(0, 580, 0, 529)}):Play()
	tweenService:Create(scriptSearch.Icon, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Position = UDim2.new(0.054, 0, 0.056, 0)}):Play()
	tweenService:Create(scriptSearch.SearchBox, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Position = UDim2.new(0.523, 0, 0.056, 0)}):Play()
	tweenService:Create(scriptSearch.UIGradient, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Offset = Vector2.new(0, 0.6)}):Play()

	if response then
		local scriptCreated = false
		for _, scriptResult in pairs(response.result.scripts) do
			local success, response = pcall(function()
				createScript(scriptResult)
			end)

			scriptCreated = true
		end

		if not scriptCreated then
			task.wait(0.2)
			tweenService:Create(scriptSearch.NoScriptsTitle, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()
			task.wait(0.1)
			tweenService:Create(scriptSearch.NoScriptsDesc, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()
		else
			tweenService:Create(scriptSearch.List, TweenInfo.new(.3,Enum.EasingStyle.Quint),  {ScrollBarImageTransparency = 0}):Play()
		end
	else
		queueNotification("ScriptSearch", "ScriptSearch backend encountered an error, try again later", 4384402990)
		closeScriptSearch()
		return
	end
end

local function openSmartBar()
	smartBarOpen = true

	coreGui.RobloxGui.Backpack.Position = UDim2.new(0,0,0,0)

	-- Set Values for frame properties
	smartBar.BackgroundTransparency = 1
	smartBar.Time.TextTransparency = 1
	smartBar.UIStroke.Transparency = 1
	smartBar.Shadow.ImageTransparency = 1
	smartBar.Visible = true
	smartBar.Position = UDim2.new(0.5, 0, 1.05, 0)
	smartBar.Size = UDim2.new(0, 531, 0, 64)
	toggle.Rotation = 180
	toggle.Visible = not checkSetting("Hide Toggle Button").current

	if checkTools() then
		toggle.Position = UDim2.new(0.5,0,1,-68)
	else
		toggle.Position = UDim2.new(0.5, 0, 1, -5)
	end

	for _, button in ipairs(smartBar.Buttons:GetChildren()) do
		button.UIGradient.Rotation = -120
		button.UIStroke.UIGradient.Rotation = -120
		button.Size = UDim2.new(0,30,0,30)
		button.Position = UDim2.new(button.Position.X.Scale, 0, 1.3, 0)
		button.BackgroundTransparency = 1
		button.UIStroke.Transparency = 1
		button.Icon.ImageTransparency = 1
	end

	tweenService:Create(coreGui.RobloxGui.Backpack, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Position = UDim2.new(-0.325,0,0,0)}):Play()

	tweenService:Create(toggle, TweenInfo.new(0.82, Enum.EasingStyle.Quint), {Rotation = 0}):Play()
	tweenService:Create(smartBar, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 1, -12)}):Play()
	tweenService:Create(toastsContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 1, -110)}):Play()
	tweenService:Create(toggle, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 1, -85)}):Play()
	tweenService:Create(smartBar, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Size = UDim2.new(0,581,0,70)}):Play()
	tweenService:Create(smartBar, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
	tweenService:Create(smartBar.Shadow, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {ImageTransparency = 0.7}):Play()
	tweenService:Create(smartBar.Time, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(smartBar.UIStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Transparency = 0.95}):Play()
	tweenService:Create(toggle, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()

	for _, button in ipairs(smartBar.Buttons:GetChildren()) do
		tweenService:Create(button.UIStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
		tweenService:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 36, 0, 36)}):Play()
		tweenService:Create(button.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Quint), {Rotation = 50}):Play()
		tweenService:Create(button.UIStroke.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Quint), {Rotation = 50}):Play()
		tweenService:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {Position = UDim2.new(button.Position.X.Scale, 0, 0.5, 0)}):Play()
		tweenService:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
		tweenService:Create(button.Icon, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
		task.wait(0.03)
	end
end

local function closeSmartBar()
	smartBarOpen = false
	if hideCommandBar then
		hideCommandBar(true)
	end
	if hideCommandBar then
		hideCommandBar()
	end

	for _, otherPanel in ipairs(UI:GetChildren()) do
		if smartBar.Buttons:FindFirstChild(otherPanel.Name) then
			if isPanel(otherPanel.Name) and otherPanel.Visible then
				task.spawn(closePanel, otherPanel.Name, true)
				task.wait()
			end
		end
	end

	tweenService:Create(smartBar.Time, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
	for _, Button in ipairs(smartBar.Buttons:GetChildren()) do
		tweenService:Create(Button.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
		tweenService:Create(Button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 30, 0, 30)}):Play()
		tweenService:Create(Button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
		tweenService:Create(Button.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
	end

	tweenService:Create(coreGui.RobloxGui.Backpack, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()

	tweenService:Create(smartBar, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
	tweenService:Create(smartBar.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
	tweenService:Create(smartBar.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
	tweenService:Create(smartBar, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0,531,0,64)}):Play()
	tweenService:Create(smartBar, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0,1, 73)}):Play()

	-- If tools, move the toggle
	if checkTools() then
		tweenService:Create(toggle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5,0,1,-68)}):Play()
		tweenService:Create(toastsContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 1, -90)}):Play()
		tweenService:Create(toggle, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Rotation = 180}):Play()
	else
		tweenService:Create(toastsContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 1, -28)}):Play()
		tweenService:Create(toggle, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 1, -5)}):Play()
		tweenService:Create(toggle, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Rotation = 180}):Play()
	end
end

local function windowFocusChanged(value)
	if checkSirius() then
		if value then -- Window Focused
			setfpscap(tonumber(checkSetting("Artificial FPS Limit").current))
			removeReverbs(0.5)
		else          -- Window unfocused
			if checkSetting("Muffle audio while unfocused").current then createReverb(0.7) end
			if checkSetting("Limit FPS while unfocused").current then setfpscap(60) end
		end
	end
end

local function onChatted(player, message)
	local enabled = checkSetting("Chat Spy").current and siriusValues.chatSpy.enabled
	local chatSpyVisuals = siriusValues.chatSpy.visual

	if not message or not checkSirius() then return end

	if enabled and player ~= localPlayer then
		local message2 = message:gsub("[\n\r]",''):gsub("\t",' '):gsub("[ ]+",' ')
		local hidden = true

		local get = getMessage.OnClientEvent:Connect(function(packet, channel)
			if packet.SpeakerUserId == player.UserId and packet.Message == message2:sub(#message2-#packet.Message+1) and (channel=="All" or (channel=="Team" and players[packet.FromSpeaker].Team == localPlayer.Team)) then
				hidden = false
			end
		end)

		task.wait(1)

		get:Disconnect()

		if hidden and enabled then
			chatSpyVisuals.Text = "Sirius Spy - [".. player.Name .."]: "..message2
			starterGui:SetCore("ChatMakeSystemMessage", chatSpyVisuals)
		end
	end

	if checkSetting("Log Messages").current then
		local logData = {
			["content"] = message,
			["avatar_url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png",
			["username"] = player.DisplayName,
			["allowed_mentions"] = {parse = {}}
		}

		logData = httpService:JSONEncode(logData)

		pcall(function()
			local req = originalRequest({
				Url = checkSetting("Message Webhook URL").current,
				Method = 'POST',
				Headers = {
					['Content-Type'] = 'application/json',
				},
				Body = logData
			})
		end)
	end
end

local function sortPlayers()
	local newTable = playerlistPanel.Interactions.List:GetChildren()

	for index, player in ipairs(newTable) do
		if player.ClassName ~= "Frame" or player.Name == "Placeholder" then
			table.remove(newTable, index)
		end
	end

	table.sort(newTable, function(playerA, playerB)
		return playerA.Name < playerB.Name
	end)

	for index, frame in ipairs(newTable) do
		if frame.ClassName == "Frame" then
			if frame.Name ~= "Placeholder" then
				frame.LayoutOrder = index 
			end
		end
	end
end

local function kill(player)
	-- kill
end

local function teleportTo(player)
	if players:FindFirstChild(player.Name) then
		queueNotification("Teleportation", "Teleporting to "..player.DisplayName..".")

		local target = workspace:FindFirstChild(player.Name).HumanoidRootPart
		localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(target.Position.X, target.Position.Y, target.Position.Z)
	else
		queueNotification("Teleportation Error", player.DisplayName.." has left this server.")
	end
end

local function createPlayer(player)
	if not checkSirius() then return end

	if playerlistPanel.Interactions.List:FindFirstChild(player.DisplayName) then return end

	local newPlayer = playerlistPanel.Interactions.List.Template:Clone()
	newPlayer.Name = player.DisplayName
	newPlayer.Parent = playerlistPanel.Interactions.List
	newPlayer.Visible = not searchingForPlayer

	newPlayer.NoActions.Visible = false
	newPlayer.PlayerInteractions.Visible = false
	newPlayer.Role.Visible = false

	newPlayer.Size = UDim2.new(0, 539, 0, 45)
	newPlayer.DisplayName.Position = UDim2.new(0, 53, 0.5, 0)
	newPlayer.DisplayName.Size = UDim2.new(0, 224, 0, 16)
	newPlayer.Avatar.Size = UDim2.new(0, 30, 0, 30)

	sortPlayers()

	newPlayer.DisplayName.TextTransparency = 0
	newPlayer.DisplayName.TextScaled = true
	newPlayer.DisplayName.FontFace.Weight = Enum.FontWeight.Medium
	newPlayer.DisplayName.Text = player.DisplayName
	newPlayer.Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"

	if creatorType == Enum.CreatorType.Group then
		task.spawn(function()
			local role = player:GetRoleInGroup(creatorId)
			if role == "Guest" then
				newPlayer.Role.Text = "Group Rank: None"
			else
				newPlayer.Role.Text = "Group Rank: "..role
			end

			newPlayer.Role.Visible = true
			newPlayer.Role.TextTransparency = 1
		end)
	end

	local function openInteractions()
		if newPlayer.PlayerInteractions.Visible then return end

		newPlayer.PlayerInteractions.BackgroundTransparency = 1
		for _, interaction in ipairs(newPlayer.PlayerInteractions:GetChildren()) do
			if interaction.ClassName == "Frame" and interaction.Name ~= "Placeholder" then
				interaction.BackgroundTransparency = 1
				interaction.Shadow.ImageTransparency = 1
				interaction.Icon.ImageTransparency = 1
				interaction.UIStroke.Transparency = 1
			end
		end

		newPlayer.PlayerInteractions.Visible = true

		for _, interaction in ipairs(newPlayer.PlayerInteractions:GetChildren()) do
			if interaction.ClassName == "Frame" and interaction.Name ~= "Placeholder" then
				tweenService:Create(interaction.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
				tweenService:Create(interaction.Icon, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
				tweenService:Create(interaction.Shadow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0.7}):Play()
				tweenService:Create(interaction, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
			end
		end
	end

	local function closeInteractions()
		if not newPlayer.PlayerInteractions.Visible then return end
		for _, interaction in ipairs(newPlayer.PlayerInteractions:GetChildren()) do
			if interaction.ClassName == "Frame" and interaction.Name ~= "Placeholder" then
				tweenService:Create(interaction.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
				tweenService:Create(interaction.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
				tweenService:Create(interaction.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
				tweenService:Create(interaction, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
			end
		end
		task.wait(0.35)
		newPlayer.PlayerInteractions.Visible = false
	end

	newPlayer.MouseEnter:Connect(function()
		if debounce or not playerlistPanel.Visible then return end
		tweenService:Create(newPlayer.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
		tweenService:Create(newPlayer.DisplayName, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0.3}):Play()
	end)

	newPlayer.MouseLeave:Connect(function()
		if debounce or not playerlistPanel.Visible then return end
		task.spawn(closeInteractions)
		tweenService:Create(newPlayer.DisplayName, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 53, 0.5, 0)}):Play()
		tweenService:Create(newPlayer, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 539, 0, 45)}):Play()
		tweenService:Create(newPlayer.Avatar, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 30, 0, 30)}):Play()
		tweenService:Create(newPlayer.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
		tweenService:Create(newPlayer.DisplayName, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
		tweenService:Create(newPlayer.Role, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
	end)

	newPlayer.Interact.MouseButton1Click:Connect(function()
		if debounce or not playerlistPanel.Visible then return end
		if creatorType == Enum.CreatorType.Group then
			tweenService:Create(newPlayer.DisplayName, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 73, 0.39, 0)}):Play()
			tweenService:Create(newPlayer.Role, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0.3}):Play()
		else
			tweenService:Create(newPlayer.DisplayName, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 73, 0.5, 0)}):Play()
		end

		if player ~= localPlayer then openInteractions() end

		tweenService:Create(newPlayer, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 539, 0, 75)}):Play()

		tweenService:Create(newPlayer.DisplayName, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
		tweenService:Create(newPlayer.Avatar, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 50, 0, 50)}):Play()
		tweenService:Create(newPlayer.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
	end)

	newPlayer.PlayerInteractions.Kill.Interact.MouseButton1Click:Connect(function()
		queueNotification("Simulation Notification","Simulating Kill Notification for "..player.DisplayName..".")
		tweenService:Create(newPlayer.PlayerInteractions.Kill, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(0, 124, 89)}):Play()
		tweenService:Create(newPlayer.PlayerInteractions.Kill.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(220, 220, 220)}):Play()
		tweenService:Create(newPlayer.PlayerInteractions.Kill.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(0, 134, 96)}):Play()
		kill(player)
		task.wait(1)
		tweenService:Create(newPlayer.PlayerInteractions.Kill, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
		tweenService:Create(newPlayer.PlayerInteractions.Kill.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
		tweenService:Create(newPlayer.PlayerInteractions.Kill.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(60, 60, 60)}):Play()
	end)

	newPlayer.PlayerInteractions.Teleport.Interact.MouseButton1Click:Connect(function()
		tweenService:Create(newPlayer.PlayerInteractions.Teleport, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(0, 152, 111)}):Play()
		tweenService:Create(newPlayer.PlayerInteractions.Teleport.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(220, 220, 220)}):Play()
		tweenService:Create(newPlayer.PlayerInteractions.Teleport.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(0, 152, 111)}):Play()
		teleportTo(player)
		task.wait(0.5)
		tweenService:Create(newPlayer.PlayerInteractions.Teleport, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
		tweenService:Create(newPlayer.PlayerInteractions.Teleport.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
		tweenService:Create(newPlayer.PlayerInteractions.Teleport.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(60, 60, 60)}):Play()
	end)

	newPlayer.PlayerInteractions.Spectate.Interact.MouseButton1Click:Connect(function()
		queueNotification("Simulation Notification","Simulating Spectate Notification for "..player.DisplayName..".")
		-- Spectate
	end)

	newPlayer.PlayerInteractions.Locate.Interact.MouseButton1Click:Connect(function()
		queueNotification("Simulation Notification","Simulating Locate ESP Notification for "..player.DisplayName..".")
		-- ESP for that user only
	end)
end

local function removePlayer(player)
	if not checkSirius() then return end

	if playerlistPanel.Interactions.List:FindFirstChild(player.Name) then
		playerlistPanel.Interactions.List:FindFirstChild(player.Name):Destroy()
	end
end

local function openSettings()
	debounce = true

	settingsPanel.BackgroundTransparency = 1
	settingsPanel.Title.TextTransparency = 1
	settingsPanel.Subtitle.TextTransparency = 1
	settingsPanel.Back.ImageTransparency = 1
	settingsPanel.Shadow.ImageTransparency = 1

	wipeTransparency(settingsPanel.SettingTypes, 1, true)

	settingsPanel.Visible = true
	settingsPanel.UIGradient.Enabled = true
	settingsPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	settingsPanel.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.0470588, 0.0470588, 0.0470588)),ColorSequenceKeypoint.new(1, Color3.new(0.0470588, 0.0470588, 0.0470588))})
	settingsPanel.UIGradient.Offset = Vector2.new(0, 1.7)
	settingsPanel.SettingTypes.Visible = true
	settingsPanel.SettingLists.Visible = false
	settingsPanel.Size = UDim2.new(0, 550, 0, 340)
	settingsPanel.Title.Position = UDim2.new(0.045, 0, 0.057, 0)

	settingsPanel.Title.Text = "Settings"
	settingsPanel.Subtitle.Text = "Adjust your preferences, set new keybinds, test out new features and more."

	tweenService:Create(settingsPanel, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 613, 0, 384)}):Play()
	tweenService:Create(settingsPanel, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
	tweenService:Create(settingsPanel.Shadow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0.7}):Play()
	tweenService:Create(settingsPanel.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(settingsPanel.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()

	task.wait(0.1)

	for _, settingType in ipairs(settingsPanel.SettingTypes:GetChildren()) do
		if settingType.ClassName == "Frame" then
			local gradientRotation = math.random(78, 95)

			tweenService:Create(settingType.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Rotation = gradientRotation}):Play()
			tweenService:Create(settingType.Shadow.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Rotation = gradientRotation}):Play()
			tweenService:Create(settingType.UIStroke.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Rotation = gradientRotation}):Play()
			tweenService:Create(settingType, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
			tweenService:Create(settingType.Shadow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0.7}):Play()
			tweenService:Create(settingType.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
			tweenService:Create(settingType.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0.2}):Play()

			task.wait(0.02)
		end
	end

	for _, settingList in ipairs(settingsPanel.SettingLists:GetChildren()) do
		if settingList.ClassName == "ScrollingFrame" then
			for _, setting in ipairs(settingList:GetChildren()) do
				if setting.ClassName == "Frame" then
					setting.Visible = true
				end
			end
		end
	end

	debounce = false
end

local function closeSettings()
	debounce = true

	for _, settingType in ipairs(settingsPanel.SettingTypes:GetChildren()) do
		if settingType.ClassName == "Frame" then
			tweenService:Create(settingType, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
			tweenService:Create(settingType.Shadow, TweenInfo.new(0.05, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
			tweenService:Create(settingType.UIStroke, TweenInfo.new(0.05, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
			tweenService:Create(settingType.Title, TweenInfo.new(0.05, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		end
	end

	tweenService:Create(settingsPanel.Shadow, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
	tweenService:Create(settingsPanel.Back, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
	tweenService:Create(settingsPanel.Title, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
	tweenService:Create(settingsPanel.Subtitle, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()

	for _, settingList in ipairs(settingsPanel.SettingLists:GetChildren()) do
		if settingList.ClassName == "ScrollingFrame" then
			for _, setting in ipairs(settingList:GetChildren()) do
				if setting.ClassName == "Frame" then
					setting.Visible = false
				end
			end
		end
	end

	tweenService:Create(settingsPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 520, 0, 0)}):Play()
	tweenService:Create(settingsPanel, TweenInfo.new(0.55, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()

	task.wait(0.55)

	settingsPanel.Visible = false
	debounce = false
end

local function saveSettings()
	checkFolder()

	if isfile and isfile(siriusValues.siriusFolder.."/"..siriusValues.settingsFile) then
		writefile(siriusValues.siriusFolder.."/"..siriusValues.settingsFile, httpService:JSONEncode(siriusSettings))
	end
end

local function assembleSettings()
	if isfile and isfile(siriusValues.siriusFolder.."/"..siriusValues.settingsFile) then
		local currentSettings

		local success, response = pcall(function()
			currentSettings = httpService:JSONDecode(readfile(siriusValues.siriusFolder.."/"..siriusValues.settingsFile))
		end)

		if success then
			for _, liveCategory in ipairs(siriusSettings) do
				for _, liveSetting in ipairs(liveCategory.categorySettings) do
					for _, category in ipairs(currentSettings) do
						for _, setting in ipairs(category.categorySettings) do
							if liveSetting.id == setting.id then
								liveSetting.current = setting.current
							end
						end
					end
				end
			end

			writefile(siriusValues.siriusFolder.."/"..siriusValues.settingsFile, httpService:JSONEncode(siriusSettings)) -- Update file with any new settings added
		end
	else
		if writefile then
			checkFolder()
			if not isfile(siriusValues.siriusFolder.."/"..siriusValues.settingsFile) then
				writefile(siriusValues.siriusFolder.."/"..siriusValues.settingsFile, httpService:JSONEncode(siriusSettings))
			end
		end 
	end

	for _, category in siriusSettings do
		local newCategory = settingsPanel.SettingTypes.Template:Clone()
		newCategory.Name = category.name
		newCategory.Title.Text = string.upper(category.name)
		newCategory.Parent = settingsPanel.SettingTypes
		newCategory.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.0392157, 0.0392157, 0.0392157)),ColorSequenceKeypoint.new(1, category.color)})

		newCategory.Visible = true

		local hue, sat, val = Color3.toHSV(category.color)

		hue = math.clamp(hue + 0.01, 0, 1) sat = math.clamp(sat + 0.1, 0, 1) val = math.clamp(val + 0.2, 0, 1)

		local newColor = Color3.fromHSV(hue, sat, val)
		newCategory.UIStroke.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.117647, 0.117647, 0.117647)),ColorSequenceKeypoint.new(1, newColor)})
		newCategory.Shadow.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.117647, 0.117647, 0.117647)),ColorSequenceKeypoint.new(1, newColor)})

		local newList = settingsPanel.SettingLists.Template:Clone()
		newList.Name = category.name
		newList.Parent = settingsPanel.SettingLists

		newList.Visible = true

		for _, obj in ipairs(newList:GetChildren()) do if obj.Name ~= "Placeholder" and obj.Name ~= "UIListLayout" then obj:Destroy() end end 

		settingsPanel.Back.MouseButton1Click:Connect(function()
			tweenService:Create(settingsPanel.Back, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
			tweenService:Create(settingsPanel.Back, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0.002, 0, 0.052, 0)}):Play()
			tweenService:Create(settingsPanel.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0.045, 0, 0.057, 0)}):Play()
			tweenService:Create(settingsPanel.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Offset = Vector2.new(0, 1.3)}):Play()
			settingsPanel.Title.Text = "Settings"
			settingsPanel.Subtitle.Text = "Adjust your preferences, set new keybinds, test out new features and more"
			settingsPanel.SettingTypes.Visible = true
			settingsPanel.SettingLists.Visible = false
		end)

		newCategory.Interact.MouseButton1Click:Connect(function()
			if settingsPanel.SettingLists:FindFirstChild(category.name) then
				settingsPanel.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.0470588, 0.0470588, 0.0470588)),ColorSequenceKeypoint.new(1, category.color)})
				settingsPanel.SettingTypes.Visible = false
				settingsPanel.SettingLists.Visible = true
				settingsPanel.SettingLists.UIPageLayout:JumpTo(settingsPanel.SettingLists[category.name])
				settingsPanel.Subtitle.Text = category.description
				settingsPanel.Back.Visible = true
				settingsPanel.Title.Text = category.name

				local gradientRotation = math.random(78, 95)
				settingsPanel.UIGradient.Rotation = gradientRotation
				tweenService:Create(settingsPanel.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Offset = Vector2.new(0, 0.65)}):Play()
				tweenService:Create(settingsPanel.Back, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
				tweenService:Create(settingsPanel.Back, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0.041, 0, 0.052, 0)}):Play()
				tweenService:Create(settingsPanel.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0.091, 0, 0.057, 0)}):Play()
			else
				-- error
				closeSettings()
			end
		end)

		newCategory.MouseEnter:Connect(function()
			tweenService:Create(newCategory.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
			tweenService:Create(newCategory.UIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Offset = Vector2.new(0, 0.4)}):Play()
			tweenService:Create(newCategory.UIStroke.UIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Offset = Vector2.new(0, 0.2)}):Play()
			tweenService:Create(newCategory.Shadow.UIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Offset = Vector2.new(0, 0.2)}):Play()
		end)

		newCategory.MouseLeave:Connect(function()
			tweenService:Create(newCategory.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0.2}):Play()
			tweenService:Create(newCategory.UIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Offset = Vector2.new(0, 0.65)}):Play()
			tweenService:Create(newCategory.UIStroke.UIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Offset = Vector2.new(0, 0.4)}):Play()
			tweenService:Create(newCategory.Shadow.UIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Offset = Vector2.new(0, 0.4)}):Play()
		end)

		for _, setting in ipairs(category.categorySettings) do
			if not setting.hidden then
				local settingType = setting.settingType
				local minimumLicense = setting.minimumLicense
				local object = nil

				if settingType == "Boolean" then
					local newSwitch = settingsPanel.SettingLists.Template.SwitchTemplate:Clone()
					object = newSwitch
					newSwitch.Name = setting.name
					newSwitch.Parent = newList
					newSwitch.Visible = true
					newSwitch.Title.Text = setting.name

					if setting.current == true then
						newSwitch.Switch.Indicator.Position = UDim2.new(1, -20, 0.5, 0)
						newSwitch.Switch.Indicator.UIStroke.Color = Color3.fromRGB(220, 220, 220)
						newSwitch.Switch.Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)			
						newSwitch.Switch.Indicator.BackgroundTransparency = 0.6
					end

					if minimumLicense then
						if (minimumLicense == "Pro" and not Pro) or (minimumLicense == "Essential" and not (Pro or Essential)) then
							newSwitch.Switch.Indicator.Position = UDim2.new(1, -40, 0.5, 0)
							newSwitch.Switch.Indicator.UIStroke.Color = Color3.fromRGB(255, 255, 255)
							newSwitch.Switch.Indicator.BackgroundColor3 = Color3.fromRGB(235, 235, 235)			
							newSwitch.Switch.Indicator.BackgroundTransparency = 0.75
						end
					end

					newSwitch.Interact.MouseButton1Click:Connect(function()
						if minimumLicense then
							if (minimumLicense == "Pro" and not Pro) or (minimumLicense == "Essential" and not (Pro or Essential)) then
								queueNotification("This feature is locked", "You must be "..minimumLicense.." or higher to use "..setting.name..". \n\nUpgrade at https://sirius.menu.", 4483345875)
								return
							end
						end

						setting.current = not setting.current
						saveSettings()
						if setting.current == true then
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 0.5, 0)}):Play()
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,12,0,12)}):Play()
							tweenService:Create(newSwitch.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Color3.fromRGB(200, 200, 200)}):Play()
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
							tweenService:Create(newSwitch.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 0.5}):Play()
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.6}):Play()
							task.wait(0.05)
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,17,0,17)}):Play()							
						else
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -40, 0.5, 0)}):Play()
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,12,0,12)}):Play()
							tweenService:Create(newSwitch.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Color3.fromRGB(255, 255, 255)}):Play()
							tweenService:Create(newSwitch.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 0.7}):Play()
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(235, 235, 235)}):Play()
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.75}):Play()
							task.wait(0.05)
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,17,0,17)}):Play()
						end
					end)

				elseif settingType == "Input" then
					local newInput = settingsPanel.SettingLists.Template.InputTemplate:Clone()
					object = newInput

					newInput.Name = setting.name
					newInput.InputFrame.InputBox.Text = setting.current
					newInput.InputFrame.InputBox.PlaceholderText = setting.placeholder or "input"
					newInput.Parent = newList

					if string.len(setting.current) > 19 then
						newInput.InputFrame.InputBox.Text = string.sub(tostring(setting.current), 1,17)..".."
					else
						newInput.InputFrame.InputBox.Text = setting.current
					end

					newInput.Visible = true
					newInput.Title.Text = setting.name
					newInput.InputFrame.InputBox.TextWrapped = false
					newInput.InputFrame.Size = UDim2.new(0, newInput.InputFrame.InputBox.TextBounds.X + 24, 0, 30)

					newInput.InputFrame.InputBox.FocusLost:Connect(function()
						if minimumLicense then
							if (minimumLicense == "Pro" and not Pro) or (minimumLicense == "Essential" and not (Pro or Essential)) then
								queueNotification("This feature is locked", "You must be "..minimumLicense.." or higher to use "..setting.name..". \n\nUpgrade at https://sirius.menu.", 4483345875)
								newInput.InputFrame.InputBox.Text = setting.current
								return
							end
						end

						if newInput.InputFrame.InputBox.Text ~= nil or "" then
							setting.current = newInput.InputFrame.InputBox.Text
							saveSettings()
						end
						if string.len(setting.current) > 24 then
							newInput.InputFrame.InputBox.Text = string.sub(tostring(setting.current), 1,22)..".."
						else
							newInput.InputFrame.InputBox.Text = setting.current
						end
					end)

					newInput.InputFrame.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
						tweenService:Create(newInput.InputFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, newInput.InputFrame.InputBox.TextBounds.X + 24, 0, 30)}):Play()
					end)

				elseif settingType == "Number" then
					local newInput = settingsPanel.SettingLists.Template.InputTemplate:Clone()
					object = newInput

					newInput.Name = setting.name
					newInput.InputFrame.InputBox.Text = tostring(setting.current)
					newInput.InputFrame.InputBox.PlaceholderText = setting.placeholder or "number"
					newInput.Parent = newList

					if string.len(setting.current) > 19 then
						newInput.InputFrame.InputBox.Text = string.sub(tostring(setting.current), 1,17)..".."
					else
						newInput.InputFrame.InputBox.Text = setting.current
					end

					newInput.Visible = true
					newInput.Title.Text = setting.name
					newInput.InputFrame.InputBox.TextWrapped = false
					newInput.InputFrame.Size = UDim2.new(0, newInput.InputFrame.InputBox.TextBounds.X + 24, 0, 30)

					newInput.InputFrame.InputBox.FocusLost:Connect(function()

						if minimumLicense then
							if (minimumLicense == "Pro" and not Pro) or (minimumLicense == "Essential" and not (Pro or Essential)) then
								queueNotification("This feature is locked", "You must be "..minimumLicense.." or higher to use "..setting.name..". \n\nUpgrade at https://sirius.menu.", 4483345875)
								newInput.InputFrame.InputBox.Text = setting.current
								return
							end
						end

						local inputValue = tonumber(newInput.InputFrame.InputBox.Text)

						if inputValue then
							if setting.values then
								local minValue = setting.values[1]
								local maxValue = setting.values[2]

								if inputValue < minValue then
									setting.current = minValue
								elseif inputValue > maxValue then
									setting.current = maxValue
								else
									setting.current = inputValue
								end

								saveSettings()
							else
								setting.current = inputValue
								saveSettings()
							end
						else
							newInput.InputFrame.InputBox.Text = tostring(setting.current)
						end

						if string.len(setting.current) > 24 then
							newInput.InputFrame.InputBox.Text = string.sub(tostring(setting.current), 1,22)..".."
						else
							newInput.InputFrame.InputBox.Text = tostring(setting.current)
						end
					end)

					newInput.InputFrame.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
						tweenService:Create(newInput.InputFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, newInput.InputFrame.InputBox.TextBounds.X + 24, 0, 30)}):Play()
					end)

				elseif settingType == "Key" then
					local newKeybind = settingsPanel.SettingLists.Template.InputTemplate:Clone()
					object = newKeybind
					newKeybind.Name = setting.name
					newKeybind.InputFrame.InputBox.PlaceholderText = setting.placeholder or "listening.."
					newKeybind.InputFrame.InputBox.Text = setting.current or "No Keybind"
					newKeybind.Parent = newList

					newKeybind.Visible = true
					newKeybind.Title.Text = setting.name
					newKeybind.InputFrame.InputBox.TextWrapped = false
					newKeybind.InputFrame.Size = UDim2.new(0, newKeybind.InputFrame.InputBox.TextBounds.X + 24, 0, 30)

					newKeybind.InputFrame.InputBox.FocusLost:Connect(function()
						checkingForKey = false

						if minimumLicense then
							if (minimumLicense == "Pro" and not Pro) or (minimumLicense == "Essential" and not (Pro or Essential)) then
								queueNotification("This feature is locked", "You must be "..minimumLicense.." or higher to use "..setting.name..". \n\nUpgrade at https://sirius.menu.", 4483345875)
								newKeybind.InputFrame.InputBox.Text = setting.current
								return
							end
						end

						if newKeybind.InputFrame.InputBox.Text == nil or newKeybind.InputFrame.InputBox.Text == "" then
							newKeybind.InputFrame.InputBox.Text = "No Keybind"
							setting.current = nil
							newKeybind.InputFrame.InputBox:ReleaseFocus()
							saveSettings()
						end
					end)

					newKeybind.InputFrame.InputBox.Focused:Connect(function()
						checkingForKey = {data = setting, object = newKeybind}
						newKeybind.InputFrame.InputBox.Text = ""
					end)

					newKeybind.InputFrame.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
						tweenService:Create(newKeybind.InputFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, newKeybind.InputFrame.InputBox.TextBounds.X + 24, 0, 30)}):Play()
					end)

				end

				if object then
					if setting.description then
						object.Description.Visible = true
						object.Description.TextWrapped = true
						object.Description.Size = UDim2.new(0, 333, 5, 0)
						object.Description.Size = UDim2.new(0, 333, 0, 999)
						object.Description.Text = setting.description
						object.Description.Size = UDim2.new(0, 333, 0, object.Description.TextBounds.Y + 10)
						object.Size = UDim2.new(0, 558, 0, object.Description.TextBounds.Y + 44)
					end

					if minimumLicense then
						object.LicenseDisplay.Visible = true
						object.Title.Position = UDim2.new(0, 18, 0, 26)
						object.Description.Position = UDim2.new(0, 18, 0, 43)
						object.Size = UDim2.new(0, 558, 0, object.Size.Y.Offset + 13)
						object.LicenseDisplay.Text = string.upper(minimumLicense).." FEATURE"
					end

					local objectTouching
					object.MouseEnter:Connect(function()
						objectTouching = true
						tweenService:Create(object.UIStroke, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 0.45}):Play()
						tweenService:Create(object, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.83}):Play()
					end)

					object.MouseLeave:Connect(function()
						objectTouching = false
						tweenService:Create(object.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 0.6}):Play()
						tweenService:Create(object, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.9}):Play()
					end)

					if object:FindFirstChild('Interact') then
						object.Interact.MouseButton1Click:Connect(function()
							tweenService:Create(object.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 1}):Play()
							tweenService:Create(object, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.8}):Play()
							task.wait(0.1)
							if objectTouching then
								tweenService:Create(object.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 0.45}):Play()
								tweenService:Create(object, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.83}):Play()
							else
								tweenService:Create(object.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 0.6}):Play()
								tweenService:Create(object, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.9}):Play()
							end
						end)
					end
				end
			end
		end
	end
end

local function initialiseAntiKick()
	if checkSetting("Client-Based Anti Kick").current then
		if hookmetamethod then 
			local originalIndex
			local originalNamecall

			originalIndex = hookmetamethod(game, "__index", function(self, method)
				if self == localPlayer and method:lower() == "kick" and checkSetting("Client-Based Anti Kick").current and checkSirius() then
					queueNotification("Kick Prevented", "Sirius has prevented you from being kicked by the client.", 4400699701)
					return error("Expected ':' not '.' calling member function Kick", 2)
				end
				return originalIndex(self, method)
			end)

			originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
				if self == localPlayer and getnamecallmethod():lower() == "kick" and checkSetting("Client-Based Anti Kick").current and checkSirius() then
					queueNotification("Kick Prevented", "Sirius has prevented you from being kicked by the client.", 4400699701)
					return
				end
				return originalNamecall(self, ...)
			end)
		end
	end
end

local function boost()
	-- Disabled remote boost script to avoid runtime errors in stripped environments
	warn("Boost skipped: external loader disabled.")
end

local function start()
	if siriusValues.releaseType == "Experimental" then -- Make this more secure.
		if not Pro then localPlayer:Kick("This is an experimental release, you must be Pro to run this. \n\nUpgrade at https://sirius.menu/") return end
	end
	windowFocusChanged(true)

	UI.Enabled = true

	assembleSettings()
	ensureFrameProperties()
	sortActions()
	initialiseAntiKick()
	checkLastVersion()
	task.spawn(boost)

	smartBar.Time.Text = os.date("%H")..":"..os.date("%M")

	toggle.Visible = not checkSetting("Hide Toggle Button").current

	if not checkSetting("Load Hidden").current then 
		--if checkSetting("Startup Sound Effect").current then
		--	local startupPath = siriusValues.siriusFolder.."/Assets/startup.wav"
		--	local startupAsset

		--	if isfile(startupPath) then
		--		startupAsset = getcustomasset(startupPath) or nil
		--	else
		--		startupAsset = fetchFromCDN("startup.wav", true, "Assets/startup.wav")
		--		startupAsset = isfile(startupPath) and getcustomasset(startupPath) or nil
		--	end

		--	if not startupAsset then return end

		--	local startupSound = Instance.new("Sound")
		--	startupSound.Parent = UI
		--	startupSound.SoundId = startupAsset
		--	startupSound.Name = "startupSound"
		--	startupSound.Volume = 0.85
		--	startupSound.PlayOnRemove = true
		--	startupSound:Destroy()	
		--end

		openSmartBar()
	else 
		closeSmartBar() 
	end

	if script_key and not (Essential or Pro) then
		queueNotification("License Error", "We've detected a key being placed above Sirius loadstring, however your key seems to be invalid. Make a support request at discord.gg/XVmJgHk3RG to get this solved within minutes.", "document-minus")
	end

	if siriusValues.enableExperienceSync then
		task.spawn(syncExperienceInformation) 
	end
end

-- Sirius Events

start()

toggle.MouseButton1Click:Connect(function()
	if smartBarOpen then
		closeSmartBar()
	else
		openSmartBar()
	end
end)

characterPanel.Interactions.Reset.MouseButton1Click:Connect(function()
	resetSliders()

	characterPanel.Interactions.Reset.Rotation = 360
	queueNotification("Slider Values Reset","Successfully reset all character panel sliders", 4400696294)
	tweenService:Create(characterPanel.Interactions.Reset, TweenInfo.new(.5,Enum.EasingStyle.Back),  {Rotation = 0}):Play()
end)

characterPanel.Interactions.Reset.MouseEnter:Connect(function() if debounce then return end tweenService:Create(characterPanel.Interactions.Reset, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {ImageTransparency = 0}):Play() end)
characterPanel.Interactions.Reset.MouseLeave:Connect(function() if debounce then return end tweenService:Create(characterPanel.Interactions.Reset, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {ImageTransparency = 0.7}):Play() end)

local playerSearch = playerlistPanel.Interactions.SearchFrame.SearchBox -- move this up to Variables once finished

playerSearch:GetPropertyChangedSignal("Text"):Connect(function()
	local query = string.lower(playerSearch.Text)

	for _, player in ipairs(playerlistPanel.Interactions.List:GetChildren()) do
		if player.ClassName == "Frame" and player.Name ~= "Placeholder" and player.Name ~= "Template" then
			if string.find(player.Name, playerSearch.Text) then
				player.Visible = true
			else
				player.Visible = false
			end
		end
	end

	if #playerSearch.Text == 0 then
		searchingForPlayer = false
		for _, player in ipairs(playerlistPanel.Interactions.List:GetChildren()) do
			if player.ClassName == "Frame" and player.Name ~= "Placeholder" and player.Name ~= "Template" then
				player.Visible = true
			end
		end
	else
		searchingForPlayer = true
	end
end)

characterPanel.Interactions.Serverhop.MouseEnter:Connect(function()
	if debounce then return end
	tweenService:Create(characterPanel.Interactions.Serverhop, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0.5}):Play()
	tweenService:Create(characterPanel.Interactions.Serverhop.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.1}):Play()
	tweenService:Create(characterPanel.Interactions.Serverhop.UIStroke, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Transparency = 1}):Play()
end)

characterPanel.Interactions.Serverhop.MouseLeave:Connect(function()
	if debounce then return end
	tweenService:Create(characterPanel.Interactions.Serverhop, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
	tweenService:Create(characterPanel.Interactions.Serverhop.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.5}):Play()
	tweenService:Create(characterPanel.Interactions.Serverhop.UIStroke, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Transparency = 0}):Play()
end)

characterPanel.Interactions.Rejoin.MouseEnter:Connect(function()
	if debounce then return end
	tweenService:Create(characterPanel.Interactions.Rejoin, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0.5}):Play()
	tweenService:Create(characterPanel.Interactions.Rejoin.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.1}):Play()
	tweenService:Create(characterPanel.Interactions.Rejoin.UIStroke, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Transparency = 1}):Play()
end)

characterPanel.Interactions.Rejoin.MouseLeave:Connect(function()
	if debounce then return end
	tweenService:Create(characterPanel.Interactions.Rejoin, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
	tweenService:Create(characterPanel.Interactions.Rejoin.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.5}):Play()
	tweenService:Create(characterPanel.Interactions.Rejoin.UIStroke, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Transparency = 0}):Play()
end)

characterPanel.Interactions.Rejoin.Interact.MouseButton1Click:Connect(rejoin)
characterPanel.Interactions.Serverhop.Interact.MouseButton1Click:Connect(serverhop)

homeContainer.Interactions.Server.JobId.Interact.MouseButton1Click:Connect(function()
	if setclipboard then 
		originalSetClipboard([[
-- This script will teleport you to ' ]]..game:GetService("MarketplaceService"):GetProductInfo(placeId).Name..[['
-- If it doesn't work after a few seconds, try going into the same game, and then run the script to join ]]..localPlayer.DisplayName.. [['s specific server

game:GetService("TeleportService"):TeleportToPlaceInstance(']]..placeId..[[', ']]..jobId..[[')]]
		)
		queueNotification("Copied Join Script","Successfully set clipboard to join script, players can use this script to join your specific server.", 4335479121)
	else
		queueNotification("Unable to copy join script","Missing setclipboard() function, can't set data to your clipboard.", 4335479658)
	end
end)

homeContainer.Interactions.Discord.Interact.MouseButton1Click:Connect(function()
	if setclipboard then 
		originalSetClipboard("https://discord.gg/XVmJgHk3RG")
		queueNotification("Discord Invite Copied", "We've set your clipboard to the Sirius discord invite.", 4335479121)
	else
		queueNotification("Unable to copy Discord invite", "Missing setclipboard() function, can't set data to your clipboard.", 4335479658)
	end
end)

for _, button in ipairs(scriptsPanel.Interactions.Selection:GetChildren()) do
	local origsize = button.Size

	button.MouseEnter:Connect(function()
		if not debounce then
			tweenService:Create(button, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
			tweenService:Create(button, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Size = UDim2.new(0, button.Size.X.Offset - 5, 0, button.Size.Y.Offset - 3)}):Play()
			tweenService:Create(button.UIStroke, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Transparency = 1}):Play()
			tweenService:Create(button.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.1}):Play()
		end
	end)

	button.MouseLeave:Connect(function()
		if not debounce then
			tweenService:Create(button, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
			tweenService:Create(button, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Size = origsize}):Play()
			tweenService:Create(button.UIStroke, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Transparency = 0}):Play()
			tweenService:Create(button.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()
		end
	end)

	button.Interact.MouseButton1Click:Connect(function()
		tweenService:Create(button, TweenInfo.new(.4,Enum.EasingStyle.Quint),  {Size = UDim2.new(0, origsize.X.Offset - 9, 0, origsize.Y.Offset - 6)}):Play()
		task.wait(0.1)
		tweenService:Create(button, TweenInfo.new(.25,Enum.EasingStyle.Quint),  {Size = origsize}):Play()

		if button.Name == "Library" then
			if not scriptSearch.Visible and not debounce then openScriptSearch() end
		end
		-- run action
	end)
end

-- smartBar.Buttons.Music.Interact.MouseButton1Click:Connect(function()
-- 	if debounce then return end
-- 	if musicPanel.Visible then closeMusic() else openMusic() end
-- end)

smartBar.Buttons.Home.Interact.MouseButton1Click:Connect(function()
	if debounce then return end
	if homeContainer.Visible then closeHome() else openHome() end
end)

smartBar.Buttons.Settings.Interact.MouseButton1Click:Connect(function()
	if debounce then return end
	if settingsPanel.Visible then closeSettings() else openSettings() end
end)

for _, button in ipairs(smartBar.Buttons:GetChildren()) do
	if UI:FindFirstChild(button.Name) and button:FindFirstChild("Interact") then
		button.Interact.MouseButton1Click:Connect(function()
			if button.Name == "Music" then
				if not debounce then
					toggleSpotifyPanel()
				end
			elseif isPanel(button.Name) then
				local panelInstance = UI:FindFirstChild(button.Name)
				if panelInstance then
					if not debounce and panelInstance.Visible then
						task.spawn(closePanel, button.Name)
					else
						task.spawn(openPanel, button.Name)
					end
				end
			end

			tweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Size = UDim2.new(0,28,0,28)}):Play()
			tweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
			tweenService:Create(button.Icon, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {ImageTransparency = 0.6}):Play()
			task.wait(0.15)
			tweenService:Create(button, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(0,36,0,36)}):Play()
			tweenService:Create(button, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
			tweenService:Create(button.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.02}):Play()
		end)

		button.MouseEnter:Connect(function()
			tweenService:Create(button.UIGradient, TweenInfo.new(1.4, Enum.EasingStyle.Quint), {Rotation = 360}):Play()
			tweenService:Create(button.UIStroke.UIGradient, TweenInfo.new(1.4, Enum.EasingStyle.Quint), {Rotation = 360}):Play()
			tweenService:Create(button.UIStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
			tweenService:Create(button.Icon, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
			tweenService:Create(button.UIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Offset = Vector2.new(0,-0.5)}):Play()
		end)

		button.MouseLeave:Connect(function()
			tweenService:Create(button.UIStroke.UIGradient, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Rotation = 50}):Play()
			tweenService:Create(button.UIGradient, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Rotation = 50}):Play()
			tweenService:Create(button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
			tweenService:Create(button.Icon, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {ImageTransparency = 0.05}):Play()
			tweenService:Create(button.UIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Offset = Vector2.new(0,0)}):Play()
		end)
	end
end

userInputService.InputBegan:Connect(function(input, processed)
	if not checkSirius() then return end

	if checkingForKey then
		if input.KeyCode ~= Enum.KeyCode.Unknown then
			local splitMessage = string.split(tostring(input.KeyCode), ".")
			local newKeyNoEnum = splitMessage[3]
			checkingForKey.object.InputFrame.InputBox.Text = tostring(newKeyNoEnum)
			checkingForKey.data.current = tostring(newKeyNoEnum)
			checkingForKey.object.InputFrame.InputBox:ReleaseFocus()
			saveSettings()
		end

		return
	end

	for _, category in ipairs(siriusSettings) do
		for _, setting in ipairs(category.categorySettings) do
			if setting.settingType == "Key" then
				if setting.current ~= nil and setting.current ~= "" then
					if input.KeyCode == Enum.KeyCode[setting.current] and not processed then
						if setting.callback then
							task.spawn(setting.callback)

							local action = checkAction(setting.name) or nil
							if action then
								local object = action.object
								action = action.action

								if action.enabled then
									object.Icon.Image = "rbxassetid://"..action.images[1]
									tweenService:Create(object, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.1}):Play()
									tweenService:Create(object.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
									tweenService:Create(object.Icon, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {ImageTransparency = 0.1}):Play()

									if action.disableAfter then
										task.delay(action.disableAfter, function()
											action.enabled = false
											object.Icon.Image = "rbxassetid://"..action.images[2]
											tweenService:Create(object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.55}):Play()
											tweenService:Create(object.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.4}):Play()
											tweenService:Create(object.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.5}):Play()
										end)
									end

									if action.rotateWhileEnabled then
										repeat
											object.Icon.Rotation = 0
											tweenService:Create(object.Icon, TweenInfo.new(0.75, Enum.EasingStyle.Quint), {Rotation = 360}):Play()
											task.wait(1)
										until not action.enabled
										object.Icon.Rotation = 0
									end
								else
									object.Icon.Image = "rbxassetid://"..action.images[2]
									tweenService:Create(object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.55}):Play()
									tweenService:Create(object.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.4}):Play()
									tweenService:Create(object.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.5}):Play()
								end
							end
						end
					end
				end
			end
		end
	end

	if input.KeyCode == Enum.KeyCode[checkSetting("Open ScriptSearch").current] and not processed and not debounce then
		if scriptSearch.Visible then
			closeScriptSearch()
		else
			openScriptSearch()
		end
	end

	if input.KeyCode == Enum.KeyCode[checkSetting("Toggle smartBar").current] and not processed and not debounce then
		if hideCommandBar then
			hideCommandBar(false)
		end
		if smartBarOpen then 
			closeSmartBar()
		else
			openSmartBar()
		end
	end
end)

userInputService.InputEnded:Connect(function(input, processed)
	if not checkSirius() then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		for _, slider in pairs(siriusValues.sliders) do
			slider.active = false

			if characterPanel.Visible and not debounce and slider.object and checkSirius() then
				tweenService:Create(slider.object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.8}):Play()
				tweenService:Create(slider.object.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
				tweenService:Create(slider.object.Information, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0.3}):Play()
			end
		end
	end
end)

camera:GetPropertyChangedSignal('ViewportSize'):Connect(function()
	task.wait(.5)
	updateSliderPadding()
end)

scriptSearch.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	if #scriptSearch.SearchBox.Text > 0 then
		tweenService:Create(scriptSearch.Icon, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		tweenService:Create(scriptSearch.SearchBox, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	else
		tweenService:Create(scriptSearch.Icon, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play()
		tweenService:Create(scriptSearch.SearchBox, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
	end
end)

scriptSearch.SearchBox.FocusLost:Connect(function(enterPressed)
	tweenService:Create(scriptSearch.Icon, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play()
	tweenService:Create(scriptSearch.SearchBox, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()

	if #scriptSearch.SearchBox.Text > 0 then
		if enterPressed then
			local success, response = pcall(function()
				searchScriptBlox(scriptSearch.SearchBox.Text)
			end)
		end
	else
		closeScriptSearch()
	end
end)

scriptSearch.SearchBox.Focused:Connect(function()
	if #scriptSearch.SearchBox.Text > 0 then
		tweenService:Create(scriptSearch.Icon, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		tweenService:Create(scriptSearch.SearchBox, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end
end)

mouse.Move:Connect(function()
	for _, slider in pairs(siriusValues.sliders) do
		if slider.active then
			updateSlider(slider)
		end
	end
end)

userInputService.WindowFocusReleased:Connect(function() windowFocusChanged(false) end)
userInputService.WindowFocused:Connect(function() windowFocusChanged(true) end)

for index, player in ipairs(players:GetPlayers()) do
	createPlayer(player)
	createEsp(player)
	player.Chatted:Connect(function(message) onChatted(player, message) end)
end

players.PlayerAdded:Connect(function(player)
	if not checkSirius() then return end

	createPlayer(player)
	createEsp(player)

	player.Chatted:Connect(function(message) onChatted(player, message) end)

	if checkSetting("Log PlayerAdded and PlayerRemoving").current then
		local logData = {
			["content"] = player.DisplayName.." (@"..player.Name..") left the server.",
			["avatar_url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png",
			["username"] = player.DisplayName,
			["allowed_mentions"] = {parse = {}}
		}

		logData = httpService:JSONEncode(logData)

		pcall(function()
			local req = originalRequest({
				Url = checkSetting("Player Added and Removing Webhook URL").current,
				Method = 'POST',
				Headers = {
					['Content-Type'] = 'application/json',
				},
				Body = logData
			})
		end)

	end

	if checkSetting("Moderator Detection").current and Pro then
		local roleFound = player:GetRoleInGroup(creatorId)

		if siriusValues.currentCreator == "group" then
			for _, role in pairs(siriusValues.administratorRoles) do 
				if string.find(string.lower(roleFound), role) then
					promptModerator(player, roleFound)
					queueNotification("Administrator Joined", siriusValues.currentGroup .." "..roleFound.." ".. player.DisplayName .." has joined your session", 3944670656) -- change to group name
				end
			end
		end
	end

	if checkSetting("Friend Notifications").current then
		if localPlayer:IsFriendsWith(player.UserId) then
			queueNotification("Friend Joined", "Your friend "..player.DisplayName.." has joined your server.", 4370335364)
		end
	end
end)

players.PlayerRemoving:Connect(function(player)
	if checkSetting("Log PlayerAdded and PlayerRemoving").current then
		local logData = {
			["content"] = player.DisplayName.." (@"..player.Name..") joined the server.",
			["avatar_url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png",
			["username"] = player.DisplayName,
			["allowed_mentions"] = {parse = {}}
		}

		logData = httpService:JSONEncode(logData)

		pcall(function()
			local req = originalRequest({
				Url = checkSetting("Player Added and Removing Webhook URL").current,
				Method = 'POST',
				Headers = {
					['Content-Type'] = 'application/json',
				},
				Body = logData
			})
		end)
	end

	removePlayer(player)

	local highlight = espContainer:FindFirstChild(player.Name)
	if highlight then
		highlight:Destroy()
	end
end)

runService.RenderStepped:Connect(function(frame)
	if not checkSirius() then return end
	local fps = math.round(1/frame)

	table.insert(siriusValues.frameProfile.fpsQueue, fps)
	siriusValues.frameProfile.totalFPS += fps

	if #siriusValues.frameProfile.fpsQueue > siriusValues.frameProfile.fpsQueueSize then
		siriusValues.frameProfile.totalFPS -= siriusValues.frameProfile.fpsQueue[1]
		table.remove(siriusValues.frameProfile.fpsQueue, 1)
	end
end)

runService.Stepped:Connect(function()
	if not checkSirius() then return end

	local character = localPlayer.Character
	if character then
		-- No Clip
		local noclipEnabled = siriusValues.actions[1].enabled
		local flingEnabled = siriusValues.actions[6].enabled

		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				if noclipDefaults[part] == nil then
					task.wait()
					noclipDefaults[part] = part.CanCollide
				else
					if noclipEnabled or flingEnabled then
						part.CanCollide = false
					else
						part.CanCollide = noclipDefaults[part]
					end
				end
			end
		end
	end
end)

runService.Heartbeat:Connect(function()
	if not checkSirius() then return end

	local character = localPlayer.Character
	local primaryPart = character and character.PrimaryPart
	if primaryPart then
		local bodyVelocity, bodyGyro = unpack(movers)
		if not bodyVelocity then
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.one * 9e9

			bodyGyro = Instance.new("BodyGyro")
			bodyGyro.MaxTorque = Vector3.one * 9e9
			bodyGyro.P = 9e4

			local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
			bodyAngularVelocity.AngularVelocity = Vector3.yAxis * 9e9
			bodyAngularVelocity.MaxTorque = Vector3.yAxis * 9e9
			bodyAngularVelocity.P = 9e9

			movers = { bodyVelocity, bodyGyro, bodyAngularVelocity }
		end

		-- Fly
		if siriusValues.actions[2].enabled then
			local camCFrame = camera.CFrame
			local velocity = Vector3.zero
			local rotation = camCFrame.Rotation

			if userInputService:IsKeyDown(Enum.KeyCode.W) then
				velocity += camCFrame.LookVector
				rotation *= CFrame.Angles(math.rad(-40), 0, 0)
			end
			if userInputService:IsKeyDown(Enum.KeyCode.S) then
				velocity -= camCFrame.LookVector
				rotation *= CFrame.Angles(math.rad(40), 0, 0)
			end
			if userInputService:IsKeyDown(Enum.KeyCode.D) then
				velocity += camCFrame.RightVector
				rotation *= CFrame.Angles(0, 0, math.rad(-40))
			end
			if userInputService:IsKeyDown(Enum.KeyCode.A) then
				velocity -= camCFrame.RightVector
				rotation *= CFrame.Angles(0, 0, math.rad(40))
			end
			if userInputService:IsKeyDown(Enum.KeyCode.Space) then
				velocity += Vector3.yAxis
			end
			if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				velocity -= Vector3.yAxis
			end

			local tweenInfo = TweenInfo.new(0.5)
			tweenService:Create(bodyVelocity, tweenInfo, { Velocity = velocity * siriusValues.sliders[3].value * 45 }):Play()
			bodyVelocity.Parent = primaryPart

			if not siriusValues.actions[6].enabled then
				tweenService:Create(bodyGyro, tweenInfo, { CFrame = rotation }):Play()
				bodyGyro.Parent = primaryPart
			end
		else
			bodyVelocity.Parent = nil
			bodyGyro.Parent = nil
		end
	end
end)

runService.Heartbeat:Connect(function(frame)
	if not checkSirius() then return end
	if Pro then
		if checkSetting("Spatial Shield").current and tonumber(checkSetting("Spatial Shield Threshold").current) then
			for index, sound in next, soundInstances do
				if not sound then
					table.remove(soundInstances, index)
				elseif gameSettings.MasterVolume * sound.PlaybackLoudness * sound.Volume >= tonumber(checkSetting("Spatial Shield Threshold").current) then
					if sound.Volume > 0.55 then 
						suppressedSounds[sound.SoundId] = "S"
						sound.Volume = 0.5 	
					elseif sound.Volume > 0.2 and sound.Volume < 0.55 then
						suppressedSounds[sound.SoundId] = "S2"
						sound.Volume = 0.1
					elseif sound.Volume < 0.2 then
						suppressedSounds[sound.SoundId] = "Mute"
						sound.Volume = 0
					end
					if soundSuppressionNotificationCooldown == 0 then
						queueNotification("Spatial Shield","A high-volume audio is being played ("..sound.Name..") and it has been suppressed.", 4483362458) 
						soundSuppressionNotificationCooldown = 15
					end
					table.remove(soundInstances, index)
				end
			end
		end
	end

	if checkSetting("Anonymous Client").current then
		for _, text in ipairs(cachedText) do
			local lowerText = string.lower(text.Text)
			if string.find(lowerText, lowerName, 1, true) or string.find(lowerText, lowerDisplayName, 1, true) then

				storeOriginalText(text)

				local newText = string.gsub(string.gsub(lowerText, lowerName, randomUsername), lowerDisplayName, randomUsername)
				text.Text = string.gsub(newText, "^%l", string.upper)
			end
		end
	else
		undoAnonymousChanges()
	end
end)

for _, instance in next, game:GetDescendants() do
	if instance:IsA("Sound") then
		if suppressedSounds[instance.SoundId] then
			if suppressedSounds[instance.SoundId] == "S" then
				instance.Volume = 0.5
			elseif suppressedSounds[instance.SoundId] == "S2" then
				instance.Volume = 0.1
			else
				instance.Volume = 0
			end
		else
			if not table.find(cachedIds, instance.SoundId) then
				table.insert(soundInstances, instance)
				table.insert(cachedIds, instance.SoundId)
			end
		end
	elseif instance:IsA("TextLabel") or instance:IsA("TextButton") then
		if not table.find(cachedText, instance) then
			table.insert(cachedText, instance)
		end
	end
end

game.DescendantAdded:Connect(function(instance)
	if checkSirius() then
		if instance:IsA("Sound") then
			if suppressedSounds[instance.SoundId] then
				if suppressedSounds[instance.SoundId] == "S" then
					instance.Volume = 0.5
				elseif suppressedSounds[instance.SoundId] == "S2" then
					instance.Volume = 0.1
				else
					instance.Volume = 0
				end
			else
				if not table.find(cachedIds, instance.SoundId) then
					table.insert(soundInstances, instance)
					table.insert(cachedIds, instance.SoundId)
				end
			end
		elseif instance:IsA("TextLabel") or instance:IsA("TextButton") then
			if not table.find(cachedText, instance) then
				table.insert(cachedText, instance)
			end
		end
	end
end)

while task.wait(1) do
	if not checkSirius() then
		if espContainer then espContainer:Destroy() end
		undoAnonymousChanges()
		break
	end

	smartBar.Time.Text = os.date("%H")..":"..os.date("%M")
	task.spawn(UpdateHome)

	if getconnections then
		for _, connection in getconnections(localPlayer.Idled) do
			if not checkSetting("Anti Idle").current then connection:Enable() else connection:Disable() end
		end
	end

	toggle.Visible = not checkSetting("Hide Toggle Button").current

	-- Disconnected Check
	local disconnectedRobloxUI = coreGui.RobloxPromptGui.promptOverlay:FindFirstChild("ErrorPrompt")

	if disconnectedRobloxUI and not promptedDisconnected then
		local reasonPrompt = disconnectedRobloxUI.MessageArea.ErrorFrame.ErrorMessage.Text

		promptedDisconnected = true
		disconnectedPrompt.Parent = coreGui.RobloxPromptGui

		local disconnectType
		local foundString

		for _, preDisconnectType in ipairs(siriusValues.disconnectTypes) do
			for _, typeString in pairs(preDisconnectType[2]) do
				if string.find(reasonPrompt, typeString) then
					disconnectType = preDisconnectType[1]
					foundString = true
					break
				end
			end
		end

		if not foundString then disconnectType = "kick" end

		wipeTransparency(disconnectedPrompt, 1, true)
		disconnectedPrompt.Visible = true

		if disconnectType == "ban" then
			disconnectedPrompt.Content.Text = "You've been banned, would you like to leave this server?"
			disconnectedPrompt.Action.Text = "Leave"
			disconnectedPrompt.Action.Size = UDim2.new(0, 77, 0, 36) -- use textbounds

			disconnectedPrompt.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
				ColorSequenceKeypoint.new(1, Color3.new(0.819608, 0.164706, 0.164706))
			})
		elseif disconnectType == "kick" then
			disconnectedPrompt.Content.Text = "You've been kicked, would you like to serverhop?"
			disconnectedPrompt.Action.Text = "Serverhop"
			disconnectedPrompt.Action.Size = UDim2.new(0, 114, 0, 36)

			disconnectedPrompt.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
				ColorSequenceKeypoint.new(1, Color3.new(0.0862745, 0.596078, 0.835294))
			})
		elseif disconnectType == "network" then
			disconnectedPrompt.Content.Text = "You've lost connection, would you like to rejoin?"
			disconnectedPrompt.Action.Text = "Rejoin"
			disconnectedPrompt.Action.Size = UDim2.new(0, 82, 0, 36)

			disconnectedPrompt.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
				ColorSequenceKeypoint.new(1, Color3.new(0.862745, 0.501961, 0.0862745))
			})
		end

		tweenService:Create(disconnectedPrompt, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
		tweenService:Create(disconnectedPrompt.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()
		tweenService:Create(disconnectedPrompt.Content, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.3}):Play()
		tweenService:Create(disconnectedPrompt.Action, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0.7}):Play()
		tweenService:Create(disconnectedPrompt.Action, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()

		disconnectedPrompt.Action.MouseButton1Click:Connect(function()
			if disconnectType == "ban" then
				game:Shutdown() -- leave
			elseif disconnectType == "kick" then
				serverhop()
			elseif disconnectType == "network" then
				rejoin()
			end
		end)
	end

	if Pro then
		-- all Pro checks here!

		-- Two-Way Adaptive Latency Checks
		if checkHighPing() then
			if siriusValues.pingProfile.pingNotificationCooldown <= 0 then
				if checkSetting("Adaptive Latency Warning").current then
					queueNotification("High Latency Warning","We've noticed your latency has reached a higher value than usual, you may find that you are lagging or your actions are delayed in-game. Consider checking for any background downloads on your machine.", 4370305588)
					siriusValues.pingProfile.pingNotificationCooldown = 120
				end
			end
		end

		if siriusValues.pingProfile.pingNotificationCooldown > 0 then
			siriusValues.pingProfile.pingNotificationCooldown -= 1
		end

		-- Adaptive frame time checks
		if siriusValues.frameProfile.frameNotificationCooldown <= 0 then
			if #siriusValues.frameProfile.fpsQueue > 0 then
				local avgFPS = siriusValues.frameProfile.totalFPS / #siriusValues.frameProfile.fpsQueue

				if avgFPS < siriusValues.frameProfile.lowFPSThreshold then
					if checkSetting("Adaptive Performance Warning").current then
						queueNotification("Degraded Performance","We've noticed your client's frames per second have decreased. Consider checking for any background tasks or programs on your machine.", 4384400106)
						siriusValues.frameProfile.frameNotificationCooldown = 120	
					end
				end
			end
		end

		if siriusValues.frameProfile.frameNotificationCooldown > 0 then
			siriusValues.frameProfile.frameNotificationCooldown -= 1
		end
	end
end

-- IY Exploit Compatibility Polyfills
function missing(t, f, fallback)
    if type(f) == t then return f end
    return fallback
end

cloneref = missing("function", cloneref, function(...) return ... end)
sethidden =  missing("function", sethiddenproperty or set_hidden_property or set_hidden_prop)
gethidden =  missing("function", gethiddenproperty or get_hidden_property or get_hidden_prop)
queueteleport =  missing("function", queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))
httprequest =  missing("function", request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))
everyClipboard = missing("function", setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set))
firetouchinterest = missing("function", firetouchinterest)
waxwritefile, waxreadfile = writefile, readfile
writefile = missing("function", waxwritefile) and function(file, data, safe)
    if safe == true then return pcall(waxwritefile, file, data) end
    waxwritefile(file, data)
end
readfile = missing("function", waxreadfile) and function(file, safe)
    if safe == true then return pcall(waxreadfile, file) end
    return waxreadfile(file)
end
isfile = missing("function", isfile, readfile and function(file)
    local success, result = pcall(function()
        return readfile(file)
    end)
    return success and result ~= nil and result ~= ""
end)
makefolder = missing("function", makefolder)
isfolder = missing("function", isfolder)
waxgetcustomasset = missing("function", getcustomasset or getsynasset)
hookfunction = missing("function", hookfunction)
hookmetamethod = missing("function", hookmetamethod)
getnamecallmethod = missing("function", getnamecallmethod or get_namecall_method)
checkcaller = missing("function", checkcaller, function() return false end)
newcclosure = missing("function", newcclosure)
getgc = missing("function", getgc or get_gc_objects)
setthreadidentity = missing("function", setthreadidentity or (syn and syn.set_thread_identity) or syn_context_set or setthreadcontext)
replicatesignal = missing("function", replicatesignal)
getconnections = missing("function", getconnections or get_signal_cons)

-- IY Services & Globals
local Services = setmetatable({}, {
    __index = function(t, name)
        local success, service = pcall(game.GetService, game, name)
        if success and service then
            return service
        end
        return nil
    end
})

local Players = Services.Players
local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local HttpService = Services.HttpService
local MarketplaceService = Services.MarketplaceService
local RunService = Services.RunService
local TeleportService = Services.TeleportService
local StarterGui = Services.StarterGui
local GuiService = Services.GuiService
local Lighting = Services.Lighting
local TextChatService = Services.TextChatService
local ReplicatedStorage = Services.ReplicatedStorage
local CoreGui = Services.CoreGui
local COREGUI = CoreGui
local LocalPlayer = Players.LocalPlayer
local Workspace = Services.Workspace
local Camera = Workspace.CurrentCamera
local mouse = LocalPlayer:GetMouse()
local IYMouse = {
    X = 0,
    Y = 0,
    KeyDown = Instance.new("BindableEvent"),
    KeyUp = Instance.new("BindableEvent"),
    Button1Down = Instance.new("BindableEvent"),
    Button1Up = Instance.new("BindableEvent"),
    Button2Down = Instance.new("BindableEvent"),
    Button2Up = Instance.new("BindableEvent"),
    Move = Instance.new("BindableEvent"),
    Target = nil,
    Hit = CFrame.new()
}

-- Map UserInputService to IYMouse events
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        IYMouse.Button1Down:Fire()
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        IYMouse.Button2Down:Fire()
    elseif input.UserInputType == Enum.UserInputType.Keyboard then
        IYMouse.KeyDown:Fire(input.KeyCode.Name:lower())
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        IYMouse.Button1Up:Fire()
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        IYMouse.Button2Up:Fire()
    elseif input.UserInputType == Enum.UserInputType.Keyboard then
        IYMouse.KeyUp:Fire(input.KeyCode.Name:lower())
    end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        IYMouse.X = input.Position.X
        IYMouse.Y = input.Position.Y
        IYMouse.Move:Fire()
        -- Update Target and Hit (approximate)
        IYMouse.Target = mouse.Target
        IYMouse.Hit = mouse.Hit
    end
end)

-- Proxy metatable to fallback to original mouse
setmetatable(IYMouse, {
    __index = function(t, k)
        return mouse[k]
    end,
    __newindex = function(t, k, v)
        rawset(t, k, v)
    end
})
local gethui = gethui or function() return COREGUI or game:GetService("CoreGui") end
do -- Start IY Scope
print("Starting IY Scope...")
-- IY CORE UTILITIES --
ViewportTextBox = (function()
	local TextService = game:GetService("TextService")
	local funcs = {}
	funcs.Update = function(self)
		local cursorPos = self.TextBox.CursorPosition
		local text = self.TextBox.Text
		if text == "" then self.TextBox.Position = UDim2.new(0,2,0,0) return end
		if cursorPos == -1 then return end

		local cursorText = text:sub(1,cursorPos-1)
		local pos = nil
		local leftEnd = -self.TextBox.Position.X.Offset
		local rightEnd = leftEnd + self.View.AbsoluteSize.X

		local totalTextSize = TextService:GetTextSize(text,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X
		local cursorTextSize = TextService:GetTextSize(cursorText,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X

		if cursorTextSize > rightEnd then
			pos = math.max(-2,cursorTextSize - self.View.AbsoluteSize.X + 2)
		elseif cursorTextSize < leftEnd then
			pos = math.max(-2,cursorTextSize-2)
		elseif totalTextSize < rightEnd then
			pos = math.max(-2,totalTextSize - self.View.AbsoluteSize.X + 2)
		end

		if pos then
			self.TextBox.Position = UDim2.new(0,-pos,0,0)
			self.TextBox.Size = UDim2.new(1,pos,1,0)
		end
	end

	local mt = {}
	mt.__index = funcs

	local function convert(textbox)
		local obj = setmetatable({OffsetX = 0, TextBox = textbox},mt)

		local view = Instance.new("Frame")
		view.BackgroundTransparency = textbox.BackgroundTransparency
		view.BackgroundColor3 = textbox.BackgroundColor3
		view.BorderSizePixel = textbox.BorderSizePixel
		view.BorderColor3 = textbox.BorderColor3
		view.Position = textbox.Position
		view.Size = textbox.Size
		view.ClipsDescendants = true
		view.Name = textbox.Name
		view.ZIndex = 10
		textbox.BackgroundTransparency = 1
		textbox.Position = UDim2.new(0,4,0,0)
		textbox.Size = UDim2.new(1,-8,1,0)
		textbox.TextXAlignment = Enum.TextXAlignment.Left
		textbox.Name = "Input"
		table.insert(text1,textbox)
		table.insert(shade2,view)

		obj.View = view

		textbox.Changed:Connect(function(prop)
			if prop == "Text" or prop == "CursorPosition" or prop == "AbsoluteSize" then
				obj:Update()
			end
		end)

		obj:Update()

		view.Parent = textbox.Parent
		textbox.Parent = view

		return obj
	end

	return {convert = convert}
end)()

function writefileExploit()
	if writefile then
		return true
	end
end

function readfileExploit()
	if readfile then
		return true
	end
end

function isNumber(str)
	if tonumber(str) ~= nil or str == 'inf' then
		return true
	end
end

function vtype(o, t)
    if o == nil then return false end
    if type(o) == "userdata" then return typeof(o) == t end
    return type(o) == t
end

function getRoot(char)
	local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
	return rootPart
end

function tools(plr)
	if plr:FindFirstChildOfClass("Backpack"):FindFirstChildOfClass('Tool') or plr.Character:FindFirstChildOfClass('Tool') then
		return true
	end
end

function r15(plr)
	if plr.Character:FindFirstChildOfClass('Humanoid').RigType == Enum.HumanoidRigType.R15 then
		return true
	end
end

function toClipboard(txt)
    if everyClipboard then
        everyClipboard(tostring(txt))
        notify("Clipboard", "Copied to clipboard")
    else
        notify("Clipboard", "Your exploit doesn't have the ability to use the clipboard")
    end
end

function chatMessage(str)
	if isLegacyChat then
		game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
	else
		TextChatService.TextChannels.RBXGeneral:SendAsync(str)
	end
end

function getHierarchy(obj)
	local fullname
	local period

	if string.find(obj.Name,' ') then
		fullname = '["'..obj.Name..'"]'
		period = false
	else
		fullname = obj.Name
		period = true
	end

	local getS = obj
	local parent = obj.Parent

	if parent ~= game then
		repeat
			getS = getS.Parent
			parent = getS.Parent
			if string.find(getS.Name,' ') then
				if period then
					fullname = '["'..getS.Name..'"].'..fullname
				else
					fullname = '["'..getS.Name..'"]'..fullname
				end
				period = false
			else
				if period then
					fullname = getS.Name..'.'..fullname
				else
					fullname = getS.Name..fullname
				end
				period = true
			end
		until parent == game
	end

	if period then
		return 'game.'..fullname
	else
		return 'game'..fullname
	end
end

AllWaypoints = {}

local cooldown = false
function writefileCooldown(name,data)
	task.spawn(function()
		if not cooldown then
			cooldown = true
			writefile(name, data, true)
		else
			repeat wait() until cooldown == false
			writefileCooldown(name,data)
		end
		wait(3)
		cooldown = false
	end)
end

function dragGUI(gui)
	if not gui then return end
	task.spawn(function()
		local dragging
		local dragInput
		local dragStart = Vector3.new(0,0,0)
		local startPos
		local function update(input)
			local delta = input.Position - dragStart
			local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
		end
		gui.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		gui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end)
end

dragGUI(logs)
dragGUI(KeybindEditor)
dragGUI(PluginEditor)
dragGUI(ToPartFrame)

-- IY CORE COMMAND PROCESSOR
function splitString(str,delim)
	local broken = {}
	if delim == nil then delim = "," end
	for w in string.gmatch(str,"[^"..delim.."]+") do
		table.insert(broken,w)
	end
	return broken
end

cmdHistory = cmdHistory or {}
lastCmds = lastCmds or {}
historyCount = historyCount or 0
lastBreakTime = lastBreakTime or 0
function removecmd(cmd)
	if cmd ~= " " then
		cmds = cmds or {}
		for i = #cmds,1,-1 do
			if cmds[i].NAME == cmd or FindInTable(cmds[i].ALIAS,cmd) then
				table.remove(cmds, i)
				for _,c in pairs(CMDsF:GetChildren()) do
					if c.Text and (c.Text:match("^"..cmd.."$") or c.Text:match("^"..cmd.." ") or c.Text:match(" "..cmd.."$") or c.Text:match(" "..cmd.." ")) then
						c.TextTransparency = 0.7
						safeClick(c, function()
							notify(c.Text, "Command has been disabled by you or a plugin")
						end)
					end
				end
			end
		end
	end
end

function overridecmd(name, func)
    local cmd = findCmd(name)
    if cmd and cmd.FUNC then cmd.FUNC = func end
end

function addbind(cmd,key,iskeyup,toggle)
	if type(binds) ~= "table" then binds = {} end
	if toggle then
		table.insert(binds, {
			COMMAND=cmd;
			KEY=key;
			ISKEYUP=iskeyup;
			TOGGLE = toggle;
		})
	else
		table.insert(binds, {
			COMMAND=cmd;
			KEY=key;
			ISKEYUP=iskeyup;
		})
	end
end

function addcmdtext(text,name,desc)
	local newcmd = Example:Clone()
	local tooltipText = tostring(text)
	local tooltipDesc = tostring(desc)
	newcmd.Parent = CMDsF
	newcmd.Visible = false
	newcmd.Text = text
	newcmd.Name = 'PLUGIN_'..name
	table.insert(text1,newcmd)
	if desc and desc ~= '' then
		newcmd:SetAttribute("Title", tooltipText)
		newcmd:SetAttribute("Desc", tooltipDesc)
		newcmd.MouseButton1Down:Connect(function()
			if newcmd.Visible and newcmd.TextTransparency == 0 then
				Cmdbar:CaptureFocus()
				autoComplete(newcmd.Text)
				maximizeHolder()
			end
		end)
	end
end

-- Lightweight cursor helper to avoid register bloat
function GetClosestPlayerFromCursor()
	return nil
end

SpecialPlayerCases = {
	["all"] = function(speaker) return Players:GetPlayers() end,
	["others"] = function(speaker)
		local plrs = {}
		for i,v in pairs(Players:GetPlayers()) do
			if v ~= speaker then
				table.insert(plrs,v)
			end
		end
		return plrs
	end,
	["me"] = function(speaker)return {speaker} end,
	["#(%d+)"] = function(speaker,args,currentList)
		local returns = {}
		local randAmount = tonumber(args[1])
		local players = {unpack(currentList)}
		for i = 1,randAmount do
			if #players == 0 then break end
			local randIndex = math.random(1,#players)
			table.insert(returns,players[randIndex])
			table.remove(players,randIndex)
		end
		return returns
	end,
	["random"] = function(speaker,args,currentList)
		local players = Players:GetPlayers()
		local localplayer = Players.LocalPlayer
		table.remove(players, table.find(players, localplayer))
		return {players[math.random(1,#players)]}
	end,
	["%%(.+)"] = function(speaker,args)
		local returns = {}
		local team = args[1]
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team and string.sub(string.lower(plr.Team.Name),1,#team) == string.lower(team) then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["allies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["enemies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["team"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonteam"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["friends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonfriends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if not plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["guests"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Guest then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["bacons"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character:FindFirstChild('Pal Hair') or plr.Character:FindFirstChild('Kate Hair') then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["age(%d+)"] = function(speaker,args)
		local returns = {}
		local age = tonumber(args[1])
		if not age == nil then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.AccountAge <= age then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nearest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local lowest = math.huge
		local NearestPlayer = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance < lowest then
					lowest = distance
					NearestPlayer = {plr}
				end
			end
		end
		return NearestPlayer
	end,
	["farthest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local highest = 0
		local Farthest = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance > highest then
					highest = distance
					Farthest = {plr}
				end
			end
		end
		return Farthest
	end,
	["group(%d+)"] = function(speaker,args)
		local returns = {}
		local groupID = tonumber(args[1])
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsInGroup(groupID) then  
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["alive"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["dead"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if (not plr.Character or not plr.Character:FindFirstChildOfClass("Humanoid")) or plr.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["rad(%d+)"] = function(speaker,args)
		local returns = {}
		local radius = tonumber(args[1])
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and getRoot(plr.Character) then
				local magnitude = (getRoot(plr.Character).Position-getRoot(speakerChar).Position).magnitude
				if magnitude <= radius then table.insert(returns,plr) end
			end
		end
		return returns
	end,
	["cursor"] = function(speaker)
		local plrs = {}
		local v = GetClosestPlayerFromCursor()
		if v ~= nil then table.insert(plrs, v) end
		return plrs
	end,
	["npcs"] = function(speaker,args)
		local returns = {}
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("Model") and getRoot(v) and v:FindFirstChildWhichIsA("Humanoid") and Players:GetPlayerFromCharacter(v) == nil then
				local clone = Instance.new("Player")
				clone.Name = v.Name .. " - " .. v:FindFirstChildWhichIsA("Humanoid").DisplayName
				clone.Character = v
				table.insert(returns, clone)
			end
		end
		return returns
	end,
}

end do -- Split Scope 9

function toTokens(str)
	local tokens = {}
	for op,name in string.gmatch(str,"([+-])([^+-]+)") do
		table.insert(tokens,{Operator = op,Name = name})
	end
	return tokens
end

function onlyIncludeInTable(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function removeTableMatches(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if not matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function getPlayersByName(Name)
	local Name,Len,Found = string.lower(Name),#Name,{}
	for _,v in pairs(Players:GetPlayers()) do
		if Name:sub(0,1) == '@' then
			if string.sub(string.lower(v.Name),1,Len-1) == Name:sub(2) then
				table.insert(Found,v)
			end
		else
			if string.sub(string.lower(v.Name),1,Len) == Name or string.sub(string.lower(v.DisplayName),1,Len) == Name then
				table.insert(Found,v)
			end
		end
	end
	return Found
end

function getPlayer(list,speaker)
	if list == nil then return {speaker.Name} end
	local nameList = splitString(list,",")

	local foundList = {}

	for _,name in pairs(nameList) do
		if string.sub(name,1,1) ~= "+" and string.sub(name,1,1) ~= "-" then name = "+"..name end
		local tokens = toTokens(name)
		local initialPlayers = Players:GetPlayers()

		for i,v in pairs(tokens) do
			if v.Operator == "+" then
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = onlyIncludeInTable(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = onlyIncludeInTable(initialPlayers,getPlayersByName(tokenContent))
				end
			else
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = removeTableMatches(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = removeTableMatches(initialPlayers,getPlayersByName(tokenContent))
				end
			end
		end

		for i,v in pairs(initialPlayers) do table.insert(foundList,v) end
	end

	local foundNames = {}
	for i,v in pairs(foundList) do table.insert(foundNames,v.Name) end

	return foundNames
end

function formatUsername(player)
    if player.DisplayName ~= player.Name then
        return string.format("%s (%s)", player.Name, player.DisplayName)
    end
    return player.Name
end

getprfx=function(strn)
	if strn:sub(1,string.len(prefix))==prefix then return{'cmd',string.len(prefix)+1}
	end return
end

function do_exec(str, plr)
	str = str:gsub('/e ', '')
	local t = getprfx(str)
	if not t then return end
	str = str:sub(t[2])
	if t[1]=='cmd' then
		execCmd(str, plr, true)
		IndexContents('',true,false,true)
		CMDsF.CanvasPosition = canvasPos
	end
end

lastTextBoxString,lastTextBoxCon,lastEnteredString = nil,nil,nil

UserInputService.TextBoxFocused:Connect(function(obj)
	if lastTextBoxCon then lastTextBoxCon:Disconnect() end
	if obj == Cmdbar then lastTextBoxString = nil return end
	lastTextBoxString = obj.Text
	lastTextBoxCon = obj:GetPropertyChangedSignal("Text"):Connect(function()
		if not (UserInputService:IsKeyDown(Enum.KeyCode.Return) or UserInputService:IsKeyDown(Enum.KeyCode.KeypadEnter)) then
			lastTextBoxString = obj.Text
		end
	end)
end)

UserInputService.InputBegan:Connect(function(input,gameProcessed)
	if gameProcessed then
		if Cmdbar and Cmdbar:IsFocused() then
			if input.KeyCode == Enum.KeyCode.Up then
				historyCount = historyCount + 1
				if historyCount > #cmdHistory then historyCount = #cmdHistory end
				Cmdbar.Text = cmdHistory[historyCount] or ""
				Cmdbar.CursorPosition = 1020
			elseif input.KeyCode == Enum.KeyCode.Down then
				historyCount = historyCount - 1
				if historyCount < 0 then historyCount = 0 end
				Cmdbar.Text = cmdHistory[historyCount] or ""
				Cmdbar.CursorPosition = 1020
			end
		elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
			lastEnteredString = lastTextBoxString
		end
	end
end)

Players.LocalPlayer.Chatted:Connect(function()
	wait()
	if lastEnteredString then
		local message = lastEnteredString
		lastEnteredString = nil
		do_exec(message, Players.LocalPlayer)
	end
end)

ESPenabled = false
CHMSenabled = false

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function ESP(plr, logic)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_ESP' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_ESP') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_ESP'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					if logic == true then
						a.Color = BrickColor.new(plr.TeamColor == Players.LocalPlayer.TeamColor and "Bright green" or "Bright red")
					else
						a.Color = plr.TeamColor
					end
				end
			end
			if plr.Character and plr.Character:FindFirstChild('Head') then
				local BillboardGui = Instance.new("BillboardGui")
				local TextLabel = Instance.new("TextLabel")
				BillboardGui.Adornee = plr.Character.Head
				BillboardGui.Name = plr.Name
				BillboardGui.Parent = ESPholder
				BillboardGui.Size = UDim2.new(0, 100, 0, 150)
				BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
				BillboardGui.AlwaysOnTop = true
				TextLabel.Parent = BillboardGui
				TextLabel.BackgroundTransparency = 1
				TextLabel.Position = UDim2.new(0, 0, 0, -50)
				TextLabel.Size = UDim2.new(0, 100, 0, 100)
				TextLabel.Font = Enum.Font.SourceSansSemibold
				TextLabel.TextSize = 20
				TextLabel.TextColor3 = Color3.new(1, 1, 1)
				TextLabel.TextStrokeTransparency = 0
				TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
				TextLabel.Text = 'Name: '..plr.Name
				TextLabel.ZIndex = 10
				local espLoopFunc
				local teamChange
				local addedFunc
				addedFunc = plr.CharacterAdded:Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						teamChange:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						ESP(plr, logic)
						addedFunc:Disconnect()
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
					end
				end)
				teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						addedFunc:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						ESP(plr, logic)
						teamChange:Disconnect()
					else
						teamChange:Disconnect()
					end
				end)
				local function espLoop()
					if COREGUI:FindFirstChild(plr.Name..'_ESP') then
						if plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid") and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
							local pos = math.floor((getRoot(Players.LocalPlayer.Character).Position - getRoot(plr.Character).Position).magnitude)
							TextLabel.Text = 'Name: '..plr.Name..' | Health: '..round(plr.Character:FindFirstChildOfClass('Humanoid').Health, 1)..' | Studs: '..pos
						end
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
						espLoopFunc:Disconnect()
					end
				end
				espLoopFunc = RunService.RenderStepped:Connect(espLoop)
			end
		end
	end)
end

function CHMS(plr)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_CHMS' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_CHMS') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_CHMS'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					a.Color = plr.TeamColor
				end
			end
			local addedFunc
			local teamChange
			local CHMSremoved
			addedFunc = plr.CharacterAdded:Connect(function()
				if CHMSenabled then
					ESPholder:Destroy()
					teamChange:Disconnect()
					repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
					CHMS(plr)
					addedFunc:Disconnect()
				else
					teamChange:Disconnect()
					addedFunc:Disconnect()
				end
			end)
			teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
				if CHMSenabled then
					ESPholder:Destroy()
					addedFunc:Disconnect()
					repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
					CHMS(plr)
					teamChange:Disconnect()
				else
					teamChange:Disconnect()
				end
			end)
			CHMSremoved = ESPholder.AncestryChanged:Connect(function()
				teamChange:Disconnect()
				addedFunc:Disconnect()
				CHMSremoved:Disconnect()
			end)
		end
	end)
end

function Locate(plr)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_LC' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_LC') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_LC'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					a.Color = plr.TeamColor
				end
			end
			if plr.Character and plr.Character:FindFirstChild('Head') then
				local BillboardGui = Instance.new("BillboardGui")
				local TextLabel = Instance.new("TextLabel")
				BillboardGui.Adornee = plr.Character.Head
				BillboardGui.Name = plr.Name
				BillboardGui.Parent = ESPholder
				BillboardGui.Size = UDim2.new(0, 100, 0, 150)
				BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
				BillboardGui.AlwaysOnTop = true
				TextLabel.Parent = BillboardGui
				TextLabel.BackgroundTransparency = 1
				TextLabel.Position = UDim2.new(0, 0, 0, -50)
				TextLabel.Size = UDim2.new(0, 100, 0, 100)
				TextLabel.Font = Enum.Font.SourceSansSemibold
				TextLabel.TextSize = 20
				TextLabel.TextColor3 = Color3.new(1, 1, 1)
				TextLabel.TextStrokeTransparency = 0
				TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
				TextLabel.Text = 'Name: '..plr.Name
				TextLabel.ZIndex = 10
				local lcLoopFunc
				local addedFunc
				local teamChange
				addedFunc = plr.CharacterAdded:Connect(function()
					if ESPholder ~= nil and ESPholder.Parent ~= nil then
						lcLoopFunc:Disconnect()
						teamChange:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						Locate(plr)
						addedFunc:Disconnect()
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
					end
				end)
				teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
					if ESPholder ~= nil and ESPholder.Parent ~= nil then
						lcLoopFunc:Disconnect()
						addedFunc:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						Locate(plr)
						teamChange:Disconnect()
					else
						teamChange:Disconnect()
					end
				end)
				local function lcLoop()
					if COREGUI:FindFirstChild(plr.Name..'_LC') then
						if plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid") and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
							local pos = math.floor((getRoot(Players.LocalPlayer.Character).Position - getRoot(plr.Character).Position).magnitude)
							TextLabel.Text = 'Name: '..plr.Name..' | Health: '..round(plr.Character:FindFirstChildOfClass('Humanoid').Health, 1)..' | Studs: '..pos
						end
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
						lcLoopFunc:Disconnect()
					end
				end
				lcLoopFunc = RunService.RenderStepped:Connect(lcLoop)
			end
		end
	end)
end

local bindsGUI = KeybindEditor
local awaitingInput = false
local keySelected = false

function refreshbinds()
	if Holder_2 then
		Holder_2:ClearAllChildren()
		Holder_2.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i = 1, #binds do
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newbind = Example_2:Clone()
			newbind.Parent = Holder_2
			newbind.Visible = true
			newbind.Position = UDim2.new(0,0,0, Position + 5)
			table.insert(shade2,newbind)
			table.insert(shade2,newbind.Text)
			table.insert(text1,newbind.Text)
			table.insert(shade3,newbind.Text.Delete)
			table.insert(text2,newbind.Text.Delete)
			local input = tostring(binds[i].KEY)
			local key
			if input == 'RightClick' or input == 'LeftClick' then
				key = input
			else
				key = input:sub(14)
			end
			if binds[i].TOGGLE then
				newbind.Text.Text = key.." > "..binds[i].COMMAND.." / "..binds[i].TOGGLE
			else
				newbind.Text.Text = key.." > "..binds[i].COMMAND.."  "..(binds[i].ISKEYUP and "(keyup)" or "(keydown)")
			end
			Holder_2.CanvasSize = UDim2.new(0,0,0, Position + 30)
			safeClick(newbind.Text:FindFirstChild("Delete"),function()
				unkeybind(binds[i].COMMAND,binds[i].KEY)
			end)
		end
	end
end

refreshbinds()

toggleOn = {}

function unkeybind(cmd,key)
	for i = #binds,1,-1 do
		if binds[i].COMMAND == cmd and binds[i].KEY == key then
			toggleOn[binds[i]] = nil
			table.remove(binds, i)
		end
	end
	refreshbinds()
	updatesaves()
	if key == 'RightClick' or key == 'LeftClick' then
		notify('Keybinds Updated','Unbinded '..key..' from '..cmd)
	else
		notify('Keybinds Updated','Unbinded '..key:sub(14)..' from '..cmd)
	end
end

end do -- Split Scope 3

-- Safely bind the clear-waypoints button if it exists
local function bindPositionsFrameDelete()
	local frame = PositionsFrame
	local deleteButton = frame and frame:FindFirstChild("Delete")
	if deleteButton and deleteButton.MouseButton1Click then
		deleteButton.MouseButton1Click:Connect(function()
			execCmd('cpos')
		end)
		return true
	end
	return false
end

-- Keep trying to hook the delete button until the UI is built
task.spawn(function()
	for _ = 1, 30 do
		if bindPositionsFrameDelete() then
			break
		end
		task.wait(0.2)
	end
end)

function Locate(plr)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_LC' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_LC') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_LC'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					a.Color = plr.TeamColor
				end
			end
			if plr.Character and plr.Character:FindFirstChild('Head') then
				local BillboardGui = Instance.new("BillboardGui")
				local TextLabel = Instance.new("TextLabel")
				BillboardGui.Adornee = plr.Character.Head
				BillboardGui.Name = plr.Name
				BillboardGui.Parent = ESPholder
				BillboardGui.Size = UDim2.new(0, 100, 0, 150)
				BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
				BillboardGui.AlwaysOnTop = true
				TextLabel.Parent = BillboardGui
				TextLabel.BackgroundTransparency = 1
				TextLabel.Position = UDim2.new(0, 0, 0, -50)
				TextLabel.Size = UDim2.new(0, 100, 0, 100)
				TextLabel.Font = Enum.Font.SourceSansSemibold
				TextLabel.TextSize = 20
				TextLabel.TextColor3 = Color3.new(1, 1, 1)
				TextLabel.TextStrokeTransparency = 0
				TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
				TextLabel.Text = 'Name: '..plr.Name
				TextLabel.ZIndex = 10
				local lcLoopFunc
				local addedFunc
				local teamChange
				addedFunc = plr.CharacterAdded:Connect(function()
					if ESPholder ~= nil and ESPholder.Parent ~= nil then
						lcLoopFunc:Disconnect()
						teamChange:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						Locate(plr)
						addedFunc:Disconnect()
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
					end
				end)
				teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
					if ESPholder ~= nil and ESPholder.Parent ~= nil then
						lcLoopFunc:Disconnect()
						addedFunc:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						Locate(plr)
						teamChange:Disconnect()
					else
						teamChange:Disconnect()
					end
				end)
				local function lcLoop()
					if COREGUI:FindFirstChild(plr.Name..'_LC') then
						if plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid") and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
							local pos = math.floor((getRoot(Players.LocalPlayer.Character).Position - getRoot(plr.Character).Position).magnitude)
							TextLabel.Text = 'Name: '..plr.Name..' | Health: '..round(plr.Character:FindFirstChildOfClass('Humanoid').Health, 1)..' | Studs: '..pos
						end
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
						lcLoopFunc:Disconnect()
					end
				end
				lcLoopFunc = RunService.RenderStepped:Connect(lcLoop)
			end
		end
	end)
end
-- ========================================
-- SPLIT SCOPE 2: UI Elements and Event Handlers
-- This do...end block prevents UI variables from counting
-- against the previous scope's local variable limit
-- ========================================
do

-- DUMMY UI FOR IY COMPATIBILITY --
if not ScaledHolder then
	ScaledHolder = Instance.new('ScreenGui')
	ScaledHolder.Name = 'ScaledHolder'
	ScaledHolder.Parent = nil -- Hidden, used only for internal references
end
Holder = Instance.new('Frame')
CMDsF = Instance.new('ScrollingFrame')
CMDsF_Holder = Instance.new('Frame', CMDsF)
Settings = Instance.new('Frame')
SettingsHolder = Instance.new('ScrollingFrame')
Holder_3 = Instance.new('ScrollingFrame') -- Aliases
Example_3 = Instance.new('Frame') -- Alias Example
Holder_4 = Instance.new('ScrollingFrame') -- Waypoints
Example_4 = Instance.new('Frame') -- Waypoint Example
Holder_5 = Instance.new('ScrollingFrame') -- Plugins
Example_5 = Instance.new('Frame') -- Plugin Example
PluginEditor = PluginEditor
-- Preserve existing references if they were populated by the UI; otherwise create safe fallbacks
shade1 = shade1 or {}
shade2 = shade2 or {}
shade3 = shade3 or {}
text1 = text1 or {}
text2 = text2 or {}
scroll = scroll or {}
binds = binds or {}

if not BindTo then BindTo = Instance.new("TextButton") end
if not BindTriggerSelect then BindTriggerSelect = Instance.new("TextButton") end
if not On_2 then On_2 = Instance.new("TextButton") end
if not Add_2 then Add_2 = Instance.new("TextButton") end
if not Exit_2 then Exit_2 = Instance.new("TextButton") end
if not Cmdbar_2 then Cmdbar_2 = Instance.new("TextBox") end
if not Cmdbar_3 then Cmdbar_3 = Instance.new("TextBox") end
if Cmdbar_3 and not Cmdbar_3.Parent then Cmdbar_3.Parent = Instance.new("Frame") end
if not ClickTP then ClickTP = Instance.new("Frame") end
if not ClickDelete then ClickDelete = Instance.new("Frame") end

currentShade1 = currentShade1 or Color3.new(0,0,0)
currentText1 = currentText1 or Color3.new(1,1,1)

-- Ensure PluginEditor scaffold exists to avoid nil indexing
-- Removed ensurePluginEditor to reduce local register pressure; stub FileName for compatibility
if not FileName then
	FileName = Instance.new("TextBox")
	FileName.Name = "FileName"
	FileName.Text = ""
end

-- Provide fallback frames so missing UI elements don't break runtime logic
-- Removed ensureDummyFrame to reduce locals; provide minimal stubs if missing
KeybindsFrame = KeybindsFrame or Instance.new('Frame')
AliasesFrame = AliasesFrame or Instance.new('Frame')
PluginsFrame = PluginsFrame or Instance.new('Frame')
PositionsFrame = PositionsFrame or Instance.new('Frame')

-- Helper to safely hook buttons when template children may be missing
-- Slimmed down to avoid local register pressure
safeClick = safeClick or function(button, callback)
	if button and button.MouseButton1Click then
		return button.MouseButton1Click:Connect(callback)
	end
end

-- Removed waypoint GUI rebuild here to reduce locals in this scope

refreshwaypoints()

function refreshaliases()
	if #aliases > 0 then
		AliasHint:Destroy()
	end
	if Holder_3 then
		Holder_3:ClearAllChildren()
		Holder_3.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i = 1, #aliases do
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newalias = Example_3:Clone()
			newalias.Parent = Holder_3
			newalias.Visible = true
			newalias.Position = UDim2.new(0,0,0, Position + 5)
			newalias.Text.Text = aliases[i].CMD.." > "..aliases[i].ALIAS
			table.insert(shade2,newalias)
			table.insert(shade2,newalias.Text)
			table.insert(text1,newalias.Text)
			if newalias.Text:FindFirstChild("Delete") then
				table.insert(shade3,newalias.Text.Delete)
				table.insert(text2,newalias.Text.Delete)
				safeClick(newalias.Text.Delete,function()
					execCmd('removealias '..aliases[i].ALIAS)
				end)
			end
			Holder_3.CanvasSize = UDim2.new(0,0,0, Position + 30)
		end
	end
end

local bindChosenKeyUp = false

safeClick(BindTo, function()
	awaitingInput = true
	BindTo.Text = 'Press something'
end)

safeClick(BindTriggerSelect, function()
	bindChosenKeyUp = not bindChosenKeyUp
	BindTriggerSelect.Text = bindChosenKeyUp and "KeyUp" or "KeyDown"
end)

newToggle = false
Cmdbar_3.Parent.Visible = false
safeClick(On_2, function()
	if newToggle == false then newToggle = true
		On_2.BackgroundTransparency = 0
		Cmdbar_3.Parent.Visible = true
		BindTriggerSelect.Visible = false
else newToggle = false
		On_2.BackgroundTransparency = 1
		Cmdbar_3.Parent.Visible = false
		BindTriggerSelect.Visible = true
	end
end)

safeClick(Add_2, function()
	if keySelected then
		if (Cmdbar_2.Text and string.find(Cmdbar_2.Text, "\\\\")) or (Cmdbar_3.Text and string.find(Cmdbar_3.Text, "\\\\")) then
			notify('Keybind Error','Only use one backslash to keybind multiple commands into one keybind or command')
		else
			if newToggle and Cmdbar_3.Text ~= '' and Cmdbar_2.Text ~= '' then
				addbind(Cmdbar_2.Text,keyPressed,false,Cmdbar_3.Text)
			elseif not newToggle and Cmdbar_2.Text ~= '' then
				addbind(Cmdbar_2.Text,keyPressed,bindChosenKeyUp)
			else
				return
			end
			refreshbinds()
			updatesaves()
			if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
				notify('Keybinds Updated','Binded '..keyPressed..' to '..Cmdbar_2.Text..(newToggle and " / "..Cmdbar_3.Text or ""))
			else
				notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to '..Cmdbar_2.Text..(newToggle and " / "..Cmdbar_3.Text or ""))
			end
		end
	end
end)

Exit_2.MouseButton1Click:Connect(function()
	Cmdbar_2.Text = 'Command'
	Cmdbar_3.Text = 'Command 2'
	BindTo.Text = 'Click to bind'
	bindChosenKeyUp = false
	BindTriggerSelect.Text = "KeyDown"
	keySelected = false
	KeybindEditor:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
end)

function onInputBegan(input,gameProcessed)
	if awaitingInput then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			keyPressed = tostring(input.KeyCode)
			if BindTo then BindTo.Text = keyPressed:sub(14) end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			keyPressed = 'LeftClick'
			if BindTo then BindTo.Text = 'LeftClick' end
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			keyPressed = 'RightClick'
			if BindTo then BindTo.Text = 'RightClick' end
		end
		awaitingInput = false
		keySelected = true
	end
	local activeBinds = type(binds)=="table" and binds or {}
	if not gameProcessed and #activeBinds > 0 then
		for i,v in pairs(activeBinds) do
			if not v.ISKEYUP then
				if (input.UserInputType == Enum.UserInputType.Keyboard and v.KEY:lower()==tostring(input.KeyCode):lower()) or (input.UserInputType == Enum.UserInputType.MouseButton1 and v.KEY:lower()=='leftclick') or (input.UserInputType == Enum.UserInputType.MouseButton2 and v.KEY:lower()=='rightclick') then
					if v.TOGGLE then
						local isOn = toggleOn[v] == true
						toggleOn[v] = not isOn
						if isOn then
							execCmd(v.TOGGLE,Players.LocalPlayer)
						else
							execCmd(v.COMMAND,Players.LocalPlayer)
						end
					else
						execCmd(v.COMMAND,Players.LocalPlayer)
					end
				end
			end
		end
	end
end

function onInputEnded(input,gameProcessed)
	local activeBinds = type(binds)=="table" and binds or {}
	if not gameProcessed and #activeBinds > 0 then
		for i,v in pairs(activeBinds) do
			if v.ISKEYUP then
				if (input.UserInputType == Enum.UserInputType.Keyboard and v.KEY:lower()==tostring(input.KeyCode):lower()) or (input.UserInputType == Enum.UserInputType.MouseButton1 and v.KEY:lower()=='leftclick') or (input.UserInputType == Enum.UserInputType.MouseButton2 and v.KEY:lower()=='rightclick') then
					execCmd(v.COMMAND,Players.LocalPlayer)
				end
			end
		end
	end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)

safeClick(ClickTP and ClickTP:FindFirstChild("Select"), function()
	if not keySelected then return end
	addbind('clicktp',keyPressed,bindChosenKeyUp)
	refreshbinds()
	updatesaves()
	if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
		notify('Keybinds Updated','Binded '..keyPressed..' to click tp')
	else
		notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to click tp')
	end
end)

safeClick(ClickDelete and ClickDelete:FindFirstChild("Select"), function()
	if not keySelected then return end
	addbind('clickdel',keyPressed,bindChosenKeyUp)
	refreshbinds()
	updatesaves()
	if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
		notify('Keybinds Updated','Binded '..keyPressed..' to click delete')
	else
		notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to click delete')
	end
end)

local function clicktpFunc()
	pcall(function()
		local character = Players.LocalPlayer.Character
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.SeatPart then
			humanoid.Sit = false
			wait(0.1)
		end

		local hipHeight = humanoid and humanoid.HipHeight > 0 and (humanoid.HipHeight + 1)
		local rootPart = getRoot(character)
		local rootPartPosition = rootPart.Position
		local hitPosition = IYMouse.Hit.Position
		local newCFrame = CFrame.new(
			hitPosition, 
			Vector3.new(rootPartPosition.X, hitPosition.Y, rootPartPosition.Z)
		) * CFrame.Angles(0, math.pi, 0)

		rootPart.CFrame = newCFrame + Vector3.new(0, hipHeight or 4, 0)
	end)
end

local function connectBindable(eventObj, handler)
	if not eventObj then return end

	-- Direct RBXScriptSignal
	if typeof(eventObj) == "RBXScriptSignal" then
		return eventObj:Connect(handler)
	end

	-- BindableEvent or objects exposing an Event signal
	local evSignal = eventObj.Event
	if typeof(evSignal) == "RBXScriptSignal" then
		return evSignal:Connect(handler)
	end

	return nil
end

connectBindable(IYMouse.Button1Down,function()
	for i,v in pairs(binds) do
		if v.COMMAND == 'clicktp' then
			local input = v.KEY
			if input == 'RightClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and Players.LocalPlayer.Character then
				clicktpFunc()
			elseif input == 'LeftClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and Players.LocalPlayer.Character then
				clicktpFunc()
			elseif UserInputService:IsKeyDown(Enum.KeyCode[input:sub(14)]) and Players.LocalPlayer.Character then
				clicktpFunc()
			end
		elseif v.COMMAND == 'clickdel' then
			local input = v.KEY
			if input == 'RightClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				pcall(function() IYMouse.Target:Destroy() end)
			elseif input == 'LeftClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				pcall(function() IYMouse.Target:Destroy() end)
			elseif UserInputService:IsKeyDown(Enum.KeyCode[input:sub(14)]) then
				pcall(function() IYMouse.Target:Destroy() end)
			end
		end
	end
end)

-- Plugin editor safeguards
PluginsGUI = (PluginEditor and PluginEditor:FindFirstChild("background")) or nil
if not PluginsGUI then
	PluginsGUI = {FileName = Instance.new("TextBox")}
	PluginsGUI.FileName.Text = ""
end

function addPlugin(name)
	if name:lower() == 'plugin file name' or name:lower() == 'iy_fe.iy' or name == 'iy_fe' then
		notify('Plugin Error','Please enter a valid plugin')
	else
		local file
		local fileName
		if name:sub(-3) == '.iy' then
			pcall(function() file = readfile(name) end)
			fileName = name
		else
			pcall(function() file = readfile(name..'.iy') end)
			fileName = name..'.iy'
		end
		if file then
			if not FindInTable(PluginsTable, fileName) then
				table.insert(PluginsTable, fileName)
				LoadPlugin(fileName)
				refreshplugins()
				pcall(eventEditor.Refresh)
			else
				notify('Plugin Error','This plugin is already added')
			end
		else
			notify('Plugin Error','Cannot locate file "'..fileName..'". Is the file in the correct folder?')
		end
	end
end

function deletePlugin(name)
	local pName = name..'.iy'
	if name:sub(-3) == '.iy' then
		pName = name
	end
	for i = #cmds,1,-1 do
		if cmds[i].PLUGIN == pName then
			table.remove(cmds, i)
		end
	end
	for i,v in pairs(CMDsF:GetChildren()) do
		if v.Name == 'PLUGIN_'..pName then
			v:Destroy()
		end
	end
	for i,v in pairs(PluginsTable) do
		if v == pName then
			table.remove(PluginsTable, i)
			notify('Removed Plugin',pName..' was removed')
		end
	end
	IndexContents('',true)
	refreshplugins()
end

function refreshplugins(dontSave)
	if #PluginsTable > 0 then
		PluginsHint:Destroy()
	end
	if Holder_5 then
		Holder_5:ClearAllChildren()
		Holder_5.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i,v in pairs(PluginsTable) do
			local pName = v
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newplugin = Example_5:Clone()
			newplugin.Parent = Holder_5
			newplugin.Visible = true
			newplugin.Position = UDim2.new(0,0,0, Position + 5)
			newplugin.Text.Text = pName
			table.insert(shade2,newplugin)
			table.insert(shade2,newplugin.Text)
			table.insert(text1,newplugin.Text)
			table.insert(shade3,newplugin.Text.Delete)
			table.insert(text2,newplugin.Text.Delete)
			Holder_5.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newplugin.Text.Delete.MouseButton1Click:Connect(function()
				deletePlugin(pName)
			end)
		end
		if not dontSave then
			updatesaves()
		end
	end
end

local PluginCache
function LoadPlugin(val,startup)
	local plugin

	function CatchedPluginLoad()
		plugin = loadfile(val)()
	end

	function handlePluginError(plerror)
		notify('Plugin Error','An error occurred with the plugin, "'..val..'" and it could not be loaded')
		if FindInTable(PluginsTable,val) then
			for i,v in pairs(PluginsTable) do
				if v == val then
					table.remove(PluginsTable,i)
				end
			end
		end
		updatesaves()

		print("Original Error: "..tostring(plerror))
		print("Plugin Error, stack traceback: "..tostring(debug.traceback()))

		plugin = nil

		return false
	end

	xpcall(CatchedPluginLoad, handlePluginError)

	if plugin ~= nil then
		if not startup then
			notify('Loaded Plugin',"Name: "..plugin["PluginName"].."\n".."Description: "..plugin["PluginDescription"])
		end
		addcmdtext('',val)
		addcmdtext(string.upper('--'..plugin["PluginName"]),val,plugin["PluginDescription"])
		if plugin["Commands"] then
			for i,v in pairs(plugin["Commands"]) do 
				local cmdExt = ''
				local cmdName = i
				local function handleNames()
					cmdName = i
					if findCmd(cmdName..cmdExt) then
						if isNumber(cmdExt) then
							cmdExt = cmdExt+1
						else
							cmdExt = 1
						end
						handleNames()
					else
						cmdName = cmdName..cmdExt
					end
				end
				handleNames()
				addcmd(cmdName, v["Aliases"], v["Function"], val)
				if v["ListName"] then
					local newName = v.ListName
					local cmdNames = {i,unpack(v.Aliases)}
					for i,v in pairs(cmdNames) do
						newName = newName:gsub(v,v..cmdExt)
					end
					addcmdtext(newName,val,v["Description"])
				else
					addcmdtext(cmdName,val,v["Description"])
				end
			end
		end
		IndexContents('',true)
	elseif plugin == nil then
		plugin = nil
	end
end

function FindPlugins()
	-- Disabled plugin auto-loader for stability in this environment
end

safeClick(AddPlugin, function()
	local nameBox = (PluginsGUI and PluginsGUI.FileName) or FileName
	-- No-op plugin add to avoid parsing external files
	notify('Plugins Disabled','Plugin loader is disabled in this environment.')
end)

safeClick(Exit_3, function()
	if PluginEditor then
		PluginEditor:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
	end
	if FileName then FileName.Text = 'Plugin File Name' end
end)

safeClick(Add_3, function()
	if PluginEditor then
		PluginEditor:TweenPosition(UDim2.new(0.5, -180, 0, 310), "InOut", "Quart", 0.5, true, nil)
	end
end)

safeClick(Plugins, function()
	if writefileExploit() and PluginsFrame then
		PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
		wait(0.5)
		if SettingsHolder then SettingsHolder.Visible = false end
	else
		notify('Incompatible Exploit','Your exploit is unable to use plugins (missing read/writefile)')
	end
end)

safeClick(Close_4, function()
	if SettingsHolder then SettingsHolder.Visible = true end
	if PluginsFrame then
		PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
	end
end)

local TeleportCheck = false
Players.LocalPlayer.OnTeleport:Connect(function(State)
	if KeepSirius and (not TeleportCheck) and queueteleport then
		TeleportCheck = true
		queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()")
	end
end)

end do -- Split Scope 10

-- Ensure randomString remains available outside previous scoped definition
if not randomString then
	if HttpService and HttpService.GenerateGUID then
		randomString = function() return HttpService:GenerateGUID(false) end
	else
		randomString = function() return tostring(math.random(1, 1e9)) end
	end
end

addcmd('addalias',{},function(args, speaker)
	if #args < 2 then return end
	local cmd = string.lower(args[1])
	local alias = string.lower(args[2])
	for i,v in pairs(cmds) do
		if v.NAME:lower()==cmd or FindInTable(v.ALIAS,cmd) then
			customAlias[alias] = v
			aliases[#aliases + 1] = {CMD = cmd, ALIAS = alias}
			notify('Aliases Modified',"Added "..alias.." as an alias to "..cmd)
			updatesaves()
			refreshaliases()
			break
		end
	end
end)

addcmd('removealias',{},function(args, speaker)
	if #args < 1 then return end
	local alias = string.lower(args[1])
	if customAlias[alias] then
		local cmd = customAlias[alias].NAME
		customAlias[alias] = nil
		for i = #aliases,1,-1 do
			if aliases[i].ALIAS == tostring(alias) then
				table.remove(aliases, i)
			end
		end
		notify('Aliases Modified',"Removed the alias "..alias.." from "..cmd)
		updatesaves()
		refreshaliases()
	end
end)

addcmd('clraliases',{},function(args, speaker)
	customAlias = {}
	aliases = {}
	notify('Aliases Modified','Removed all aliases')
	updatesaves()
	refreshaliases()
end)

addcmd('discord', {'support', 'help'}, function(args, speaker)
	if everyClipboard then
		toClipboard('https://discord.com/invite/dYHag43eeU')
		notify('Discord Invite', 'Copied to clipboard!\ndiscord.gg/dYHag43eeU')
	else
		notify('Discord Invite', 'discord.gg/dYHag43eeU')
	end
	if httprequest then
		httprequest({
			Url = 'http://127.0.0.1:6463/rpc?v=1',
			Method = 'POST',
			Headers = {
				['Content-Type'] = 'application/json',
				Origin = 'https://discord.com'
			},
			Body = HttpService:JSONEncode({
				cmd = 'INVITE_BROWSER',
				nonce = HttpService:GenerateGUID(false),
				args = {code = 'dYHag43eeU'}
			})
		})
	end
end)

addcmd('keepsirius', {}, function(args, speaker)
	if queueteleport then
		KeepSirius = true
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

addcmd('unkeepsirius', {}, function(args, speaker)
	if queueteleport then
		KeepSirius = false
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

addcmd('togglekeepsirius', {}, function(args, speaker)
	if queueteleport then
		KeepSirius = not KeepSirius
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

local canOpenServerinfo = true
addcmd('serverinfo',{'info','sinfo'},function(args, speaker)
	if not canOpenServerinfo then return end
	canOpenServerinfo = false
	task.spawn(function()
		local FRAME = Instance.new("Frame")
		local shadow = Instance.new("Frame")
		local PopupText = Instance.new("TextLabel")
		local Exit = Instance.new("TextButton")
		local ExitImage = Instance.new("ImageLabel")
		local background = Instance.new("Frame")
		local TextLabel = Instance.new("TextLabel")
		local TextLabel2 = Instance.new("TextLabel")
		local TextLabel3 = Instance.new("TextLabel")
		local Time = Instance.new("TextLabel")
		local appearance = Instance.new("TextLabel")
		local maxplayers = Instance.new("TextLabel")
		local name = Instance.new("TextLabel")
		local placeid = Instance.new("TextLabel")
		local playerid = Instance.new("TextLabel")
		local players = Instance.new("TextLabel")
		local CopyApp = Instance.new("TextButton")
		local CopyPlrID = Instance.new("TextButton")
		local CopyPlcID = Instance.new("TextButton")
		local CopyPlcName = Instance.new("TextButton")

		FRAME.Name = randomString()
		FRAME.Parent = ScaledHolder
		FRAME.Active = true
		FRAME.BackgroundTransparency = 1
		FRAME.Position = UDim2.new(0.5, -130, 0, -500)
		FRAME.Size = UDim2.new(0, 250, 0, 20)
		FRAME.ZIndex = 10
		dragGUI(FRAME)

		shadow.Name = "shadow"
		shadow.Parent = FRAME
		shadow.BackgroundColor3 = currentShade2
		shadow.BorderSizePixel = 0
		shadow.Size = UDim2.new(0, 250, 0, 20)
		shadow.ZIndex = 10
		table.insert(shade2,shadow)

		PopupText.Name = "PopupText"
		PopupText.Parent = shadow
		PopupText.BackgroundTransparency = 1
		PopupText.Size = UDim2.new(1, 0, 0.95, 0)
		PopupText.ZIndex = 10
		PopupText.Font = Enum.Font.SourceSans
		PopupText.TextSize = 14
		PopupText.Text = "Server"
		PopupText.TextColor3 = currentText1
		PopupText.TextWrapped = true
		table.insert(text1,PopupText)

		Exit.Name = "Exit"
		Exit.Parent = shadow
		Exit.BackgroundTransparency = 1
		Exit.Position = UDim2.new(1, -20, 0, 0)
		Exit.Size = UDim2.new(0, 20, 0, 20)
		Exit.Text = ""
		Exit.ZIndex = 10

		ExitImage.Parent = Exit
		ExitImage.BackgroundColor3 = Color3.new(1, 1, 1)
		ExitImage.BackgroundTransparency = 1
		ExitImage.Position = UDim2.new(0, 5, 0, 5)
		ExitImage.Size = UDim2.new(0, 10, 0, 10)
		ExitImage.Image = getcustomasset("infiniteyield/assets/close.png")
		ExitImage.ZIndex = 10

		background.Name = "background"
		background.Parent = FRAME
		background.Active = true
		background.BackgroundColor3 = currentShade1
		background.BorderSizePixel = 0
		background.Position = UDim2.new(0, 0, 1, 0)
		background.Size = UDim2.new(0, 250, 0, 250)
		background.ZIndex = 10
		table.insert(shade1,background)

		TextLabel.Name = "Text Label"
		TextLabel.Parent = background
		TextLabel.BackgroundTransparency = 1
		TextLabel.BorderSizePixel = 0
		TextLabel.Position = UDim2.new(0, 5, 0, 80)
		TextLabel.Size = UDim2.new(0, 100, 0, 20)
		TextLabel.ZIndex = 10
		TextLabel.Font = Enum.Font.SourceSansLight
		TextLabel.TextSize = 20
		TextLabel.Text = "Run Time:"
		TextLabel.TextColor3 = currentText1
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel)

		TextLabel2.Name = "Text Label2"
		TextLabel2.Parent = background
		TextLabel2.BackgroundTransparency = 1
		TextLabel2.BorderSizePixel = 0
		TextLabel2.Position = UDim2.new(0, 5, 0, 130)
		TextLabel2.Size = UDim2.new(0, 100, 0, 20)
		TextLabel2.ZIndex = 10
		TextLabel2.Font = Enum.Font.SourceSansLight
		TextLabel2.TextSize = 20
		TextLabel2.Text = "Statistics:"
		TextLabel2.TextColor3 = currentText1
		TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel2)

		TextLabel3.Name = "Text Label3"
		TextLabel3.Parent = background
		TextLabel3.BackgroundTransparency = 1
		TextLabel3.BorderSizePixel = 0
		TextLabel3.Position = UDim2.new(0, 5, 0, 10)
		TextLabel3.Size = UDim2.new(0, 100, 0, 20)
		TextLabel3.ZIndex = 10
		TextLabel3.Font = Enum.Font.SourceSansLight
		TextLabel3.TextSize = 20
		TextLabel3.Text = "Local Player:"
		TextLabel3.TextColor3 = currentText1
		TextLabel3.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel3)

		Time.Name = "Time"
		Time.Parent = background
		Time.BackgroundTransparency = 1
		Time.BorderSizePixel = 0
		Time.Position = UDim2.new(0, 5, 0, 105)
		Time.Size = UDim2.new(0, 100, 0, 20)
		Time.ZIndex = 10
		Time.Font = Enum.Font.SourceSans
		Time.FontSize = Enum.FontSize.Size14
		Time.Text = "LOADING"
		Time.TextColor3 = currentText1
		Time.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,Time)

		appearance.Name = "appearance"
		appearance.Parent = background
		appearance.BackgroundTransparency = 1
		appearance.BorderSizePixel = 0
		appearance.Position = UDim2.new(0, 5, 0, 55)
		appearance.Size = UDim2.new(0, 100, 0, 20)
		appearance.ZIndex = 10
		appearance.Font = Enum.Font.SourceSans
		appearance.FontSize = Enum.FontSize.Size14
		appearance.Text = "Appearance: LOADING"
		appearance.TextColor3 = currentText1
		appearance.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,appearance)

		maxplayers.Name = "maxplayers"
		maxplayers.Parent = background
		maxplayers.BackgroundTransparency = 1
		maxplayers.BorderSizePixel = 0
		maxplayers.Position = UDim2.new(0, 5, 0, 175)
		maxplayers.Size = UDim2.new(0, 100, 0, 20)
		maxplayers.ZIndex = 10
		maxplayers.Font = Enum.Font.SourceSans
		maxplayers.FontSize = Enum.FontSize.Size14
		maxplayers.Text = "LOADING"
		maxplayers.TextColor3 = currentText1
		maxplayers.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,maxplayers)

		name.Name = "name"
		name.Parent = background
		name.BackgroundTransparency = 1
		name.BorderSizePixel = 0
		name.Position = UDim2.new(0, 5, 0, 215)
		name.Size = UDim2.new(0, 240, 0, 30)
		name.ZIndex = 10
		name.Font = Enum.Font.SourceSans
		name.FontSize = Enum.FontSize.Size14
		name.Text = "Place Name: LOADING"
		name.TextColor3 = currentText1
		name.TextWrapped = true
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.TextYAlignment = Enum.TextYAlignment.Top
		table.insert(text1,name)

		placeid.Name = "placeid"
		placeid.Parent = background
		placeid.BackgroundTransparency = 1
		placeid.BorderSizePixel = 0
		placeid.Position = UDim2.new(0, 5, 0, 195)
		placeid.Size = UDim2.new(0, 100, 0, 20)
		placeid.ZIndex = 10
		placeid.Font = Enum.Font.SourceSans
		placeid.FontSize = Enum.FontSize.Size14
		placeid.Text = "Place ID: LOADING"
		placeid.TextColor3 = currentText1
		placeid.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,placeid)

		playerid.Name = "playerid"
		playerid.Parent = background
		playerid.BackgroundTransparency = 1
		playerid.BorderSizePixel = 0
		playerid.Position = UDim2.new(0, 5, 0, 35)
		playerid.Size = UDim2.new(0, 100, 0, 20)
		playerid.ZIndex = 10
		playerid.Font = Enum.Font.SourceSans
		playerid.FontSize = Enum.FontSize.Size14
		playerid.Text = "Player ID: LOADING"
		playerid.TextColor3 = currentText1
		playerid.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,playerid)

		players.Name = "players"
		players.Parent = background
		players.BackgroundTransparency = 1
		players.BorderSizePixel = 0
		players.Position = UDim2.new(0, 5, 0, 155)
		players.Size = UDim2.new(0, 100, 0, 20)
		players.ZIndex = 10
		players.Font = Enum.Font.SourceSans
		players.FontSize = Enum.FontSize.Size14
		players.Text = "LOADING"
		players.TextColor3 = currentText1
		players.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,players)

		CopyApp.Name = "CopyApp"
		CopyApp.Parent = background
		CopyApp.BackgroundColor3 = currentShade2
		CopyApp.BorderSizePixel = 0
		CopyApp.Position = UDim2.new(0, 210, 0, 55)
		CopyApp.Size = UDim2.new(0, 35, 0, 20)
		CopyApp.Font = Enum.Font.SourceSans
		CopyApp.TextSize = 14
		CopyApp.Text = "Copy"
		CopyApp.TextColor3 = currentText1
		CopyApp.ZIndex = 10
		table.insert(shade2,CopyApp)
		table.insert(text1,CopyApp)

		CopyPlrID.Name = "CopyPlrID"
		CopyPlrID.Parent = background
		CopyPlrID.BackgroundColor3 = currentShade2
		CopyPlrID.BorderSizePixel = 0
		CopyPlrID.Position = UDim2.new(0, 210, 0, 35)
		CopyPlrID.Size = UDim2.new(0, 35, 0, 20)
		CopyPlrID.Font = Enum.Font.SourceSans
		CopyPlrID.TextSize = 14
		CopyPlrID.Text = "Copy"
		CopyPlrID.TextColor3 = currentText1
		CopyPlrID.ZIndex = 10
		table.insert(shade2,CopyPlrID)
		table.insert(text1,CopyPlrID)

		CopyPlcID.Name = "CopyPlcID"
		CopyPlcID.Parent = background
		CopyPlcID.BackgroundColor3 = currentShade2
		CopyPlcID.BorderSizePixel = 0
		CopyPlcID.Position = UDim2.new(0, 210, 0, 195)
		CopyPlcID.Size = UDim2.new(0, 35, 0, 20)
		CopyPlcID.Font = Enum.Font.SourceSans
		CopyPlcID.TextSize = 14
		CopyPlcID.Text = "Copy"
		CopyPlcID.TextColor3 = currentText1
		CopyPlcID.ZIndex = 10
		table.insert(shade2,CopyPlcID)
		table.insert(text1,CopyPlcID)

		CopyPlcName.Name = "CopyPlcName"
		CopyPlcName.Parent = background
		CopyPlcName.BackgroundColor3 = currentShade2
		CopyPlcName.BorderSizePixel = 0
		CopyPlcName.Position = UDim2.new(0, 210, 0, 215)
		CopyPlcName.Size = UDim2.new(0, 35, 0, 20)
		CopyPlcName.Font = Enum.Font.SourceSans
		CopyPlcName.TextSize = 14
		CopyPlcName.Text = "Copy"
		CopyPlcName.TextColor3 = currentText1
		CopyPlcName.ZIndex = 10
		table.insert(shade2,CopyPlcName)
		table.insert(text1,CopyPlcName)

		local SINFOGUI = background
		FRAME:TweenPosition(UDim2.new(0.5, -130, 0, 100), "InOut", "Quart", 0.5, true, nil) 
		wait(0.5)
		Exit.MouseButton1Click:Connect(function()
			FRAME:TweenPosition(UDim2.new(0.5, -130, 0, -500), "InOut", "Quart", 0.5, true, nil) 
			wait(0.6)
			FRAME:Destroy()
			canOpenServerinfo = true
		end)
		local Asset = MarketplaceService:GetProductInfo(PlaceId)
		SINFOGUI.name.Text = "Place Name: " .. Asset.Name
		SINFOGUI.playerid.Text = "Player ID: " ..speaker.UserId
		SINFOGUI.maxplayers.Text = Players.MaxPlayers.. " Players Max"
		SINFOGUI.placeid.Text = "Place ID: " ..PlaceId

		CopyApp.MouseButton1Click:Connect(function()
			toClipboard(speaker.CharacterAppearanceId)
		end)
		CopyPlrID.MouseButton1Click:Connect(function()
			toClipboard(speaker.UserId)
		end)
		CopyPlcID.MouseButton1Click:Connect(function()
			toClipboard(PlaceId)
		end)
		CopyPlcName.MouseButton1Click:Connect(function()
			toClipboard(Asset.Name)
		end)

		repeat
			players = Players:GetPlayers()
			SINFOGUI.players.Text = #players.. " Player(s)"
			SINFOGUI.appearance.Text = "Appearance: " ..speaker.CharacterAppearanceId
			local seconds = math.floor(workspace.DistributedGameTime)
			local minutes = math.floor(workspace.DistributedGameTime / 60)
			local hours = math.floor(workspace.DistributedGameTime / 60 / 60)
			local seconds = seconds - (minutes * 60)
			local minutes = minutes - (hours * 60)
			if hours < 1 then if minutes < 1 then
					SINFOGUI.Time.Text = seconds .. " Second(s)" else
					SINFOGUI.Time.Text = minutes .. " Minute(s), " .. seconds .. " Second(s)"
				end
			else
				SINFOGUI.Time.Text = hours .. " Hour(s), " .. minutes .. " Minute(s), " .. seconds .. " Second(s)"
			end
			wait(1)
		until SINFOGUI.Parent == nil
	end)
end)

addcmd("jobid", {}, function(args, speaker)
    toClipboard("roblox://placeId=" .. PlaceId .. "&gameInstanceId=" .. JobId)
end)

addcmd('notifyjobid',{},function(args, speaker)
	notify('JobId / PlaceId',JobId..' / '..PlaceId)
end)

addcmd('breakloops',{'break'},function(args, speaker)
	lastBreakTime = tick()
end)

addcmd('gametp',{'gameteleport'},function(args, speaker)
	TeleportService:Teleport(args[1])
end)

addcmd("rejoin", {"rj"}, function(args, speaker)
	if #Players:GetPlayers() <= 1 then
		Players.LocalPlayer:Kick("\nRejoining...")
		wait()
		TeleportService:Teleport(PlaceId, Players.LocalPlayer)
	else
		TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer)
	end
end)

addcmd("autorejoin", {"autorj"}, function(args, speaker)
	GuiService.ErrorMessageChanged:Connect(function()
		execCmd("rejoin")
	end)
	notify("Auto Rejoin", "Auto rejoin enabled")
end)

addcmd("serverhop", {"shop"}, function(args, speaker)
    -- thanks to Amity for fixing
    local servers = {}
    local req = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
    local body = HttpService:JSONDecode(req)

    if body and body.data then
        for i, v in next, body.data do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
                table.insert(servers, 1, v.id)
            end
        end
    end

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
    else
        return notify("Serverhop", "Couldn't find a server.")
    end
end)

addcmd("exit", {}, function(args, speaker)
    game:Shutdown()
end)

local Noclipping = nil
addcmd('noclip',{},function(args, speaker)
	Clip = false
	wait(0.1)
	local function NoclipLoop()
		if Clip == false and speaker.Character ~= nil then
			for _, child in pairs(speaker.Character:GetDescendants()) do
				if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
					child.CanCollide = false
				end
			end
		end
	end
	Noclipping = RunService.Stepped:Connect(NoclipLoop)
	if args[1] and args[1] == 'nonotify' then return end
	notify('Noclip','Noclip Enabled')
end)

end do -- Split Scope 4

addcmd('clip',{'unnoclip'},function(args, speaker)
	if Noclipping then
		Noclipping:Disconnect()
	end
	Clip = true
	if args[1] and args[1] == 'nonotify' then return end
	notify('Noclip','Noclip Disabled')
end)

addcmd('togglenoclip',{},function(args, speaker)
	if Clip then
		execCmd('noclip')
	else
		execCmd('clip')
	end
end)

FLYING = false
QEfly = true
iyflyspeed = 1
vehicleflyspeed = 1
function sFLY(vfly)
	local plr = Players.LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		repeat task.wait() until char:FindFirstChildOfClass("Humanoid")
		humanoid = char:FindFirstChildOfClass("Humanoid")
	end

	if flyKeyDown or flyKeyUp then
		flyKeyDown:Disconnect()
		flyKeyUp:Disconnect()
	end

	local T = getRoot(char)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local function FLY()
		FLYING = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.CFrame = T.CFrame
		BV.Velocity = Vector3.new(0, 0, 0)
		BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat task.wait()
				local camera = workspace.CurrentCamera
				if not vfly and humanoid then
					humanoid.PlatformStand = true
				end

				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
				else
					BV.Velocity = Vector3.new(0, 0, 0)
				end
				BG.CFrame = camera.CFrame
			until not FLYING
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()

			if humanoid then humanoid.PlatformStand = false end
		end)
	end

	flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
		if input.KeyCode == Enum.KeyCode.W then
			CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.S then
			CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.A then
			CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.D then
			CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.E and QEfly then
			CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
		elseif input.KeyCode == Enum.KeyCode.Q and QEfly then
			CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
		end
		pcall(function() camera.CameraType = Enum.CameraType.Track end)
	end)

	flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
		if input.KeyCode == Enum.KeyCode.W then
			CONTROL.F = 0
		elseif input.KeyCode == Enum.KeyCode.S then
			CONTROL.B = 0
		elseif input.KeyCode == Enum.KeyCode.A then
			CONTROL.L = 0
		elseif input.KeyCode == Enum.KeyCode.D then
			CONTROL.R = 0
		elseif input.KeyCode == Enum.KeyCode.E then
			CONTROL.Q = 0
		elseif input.KeyCode == Enum.KeyCode.Q then
			CONTROL.E = 0
		end
	end)
	FLY()
end

function NOFLY()
	FLYING = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
		Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

local velocityHandlerName = randomString()
local gyroHandlerName = randomString()
local mfly1
local mfly2

local unmobilefly = function(speaker)
	pcall(function()
		FLYING = false
		local root = speaker.Character and getRoot(speaker.Character)
		if root then
			local vel = root:FindFirstChild(velocityHandlerName)
			local gyro = root:FindFirstChild(gyroHandlerName)
			if vel then vel:Destroy() end
			if gyro then gyro:Destroy() end
		end
		local hum = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
		if hum then hum.PlatformStand = false end
		if mfly1 then mfly1:Disconnect() end
		if mfly2 then mfly2:Disconnect() end
	end)
end

local mobilefly = function(speaker, vfly)
	unmobilefly(speaker)
	FLYING = true

	local root = getRoot(speaker.Character)
	local camera = workspace.CurrentCamera
	local v3none = Vector3.new()
	local v3zero = Vector3.new(0, 0, 0)
	local v3inf = Vector3.new(9e9, 9e9, 9e9)

	local controlModule = require(speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
	local bv = Instance.new("BodyVelocity")
	bv.Name = velocityHandlerName
	bv.Parent = root
	bv.MaxForce = v3zero
	bv.Velocity = v3zero

	local bg = Instance.new("BodyGyro")
	bg.Name = gyroHandlerName
	bg.Parent = root
	bg.MaxTorque = v3inf
	bg.P = 1000
	bg.D = 50

	mfly1 = speaker.CharacterAdded:Connect(function()
		local bv = Instance.new("BodyVelocity")
		bv.Name = velocityHandlerName
		bv.Parent = root
		bv.MaxForce = v3zero
		bv.Velocity = v3zero

		local bg = Instance.new("BodyGyro")
		bg.Name = gyroHandlerName
		bg.Parent = root
		bg.MaxTorque = v3inf
		bg.P = 1000
		bg.D = 50
	end)

	mfly2 = RunService.RenderStepped:Connect(function()
		root = getRoot(speaker.Character)
		camera = workspace.CurrentCamera
		if speaker.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
			local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
			local VelocityHandler = root:FindFirstChild(velocityHandlerName)
			local GyroHandler = root:FindFirstChild(gyroHandlerName)

			VelocityHandler.MaxForce = v3inf
			GyroHandler.MaxTorque = v3inf
			if not vfly then humanoid.PlatformStand = true end
			GyroHandler.CFrame = camera.CoordinateFrame
			VelocityHandler.Velocity = v3none

			local direction = controlModule:GetMoveVector()
			if direction.X > 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.X < 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.Z > 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.Z < 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
		end
	end)
end

addcmd('fly',{},function(args, speaker)
	if not IsOnMobile then
		NOFLY()
		wait()
		sFLY()
	else
		mobilefly(speaker)
	end
	if args[1] and isNumber(args[1]) then
		iyflyspeed = args[1]
	end
end)

addcmd('flyspeed',{'flysp'},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		iyflyspeed = speed
	end
end)

addcmd('unfly',{'nofly','novfly','unvehiclefly','novehiclefly','unvfly'},function(args, speaker)
	if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
end)

addcmd('vfly',{'vehiclefly'},function(args, speaker)
	if not IsOnMobile then
		NOFLY()
		wait()
		sFLY(true)
	else
		mobilefly(speaker, true)
	end
	if args[1] and isNumber(args[1]) then
		vehicleflyspeed = args[1]
	end
end)

addcmd('togglevfly',{},function(args, speaker)
	if FLYING then
		if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
	else
		if not IsOnMobile then sFLY(true) else mobilefly(speaker, true) end
	end
end)

addcmd('vflyspeed',{'vflysp','vehicleflyspeed','vehicleflysp'},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		vehicleflyspeed = speed
	end
end)

addcmd('qefly',{'flyqe'},function(args, speaker)
	if args[1] == 'false' then
		QEfly = false
	else
		QEfly = true
	end
end)

addcmd('togglefly',{},function(args, speaker)
	if FLYING then
		if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
	else
		if not IsOnMobile then sFLY() else mobilefly(speaker) end
	end
end)

CFspeed = 50
addcmd('cframefly', {'cfly'}, function(args, speaker)
	if args[1] and isNumber(args[1]) then
		CFspeed = args[1]
	end

	-- Full credit to peyton#9148 (apeyton)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
	local Head = speaker.Character:WaitForChild("Head")
	Head.Anchored = true
	if CFloop then CFloop:Disconnect() end
	CFloop = RunService.Heartbeat:Connect(function(deltaTime)
		local moveDirection = speaker.Character:FindFirstChildOfClass('Humanoid').MoveDirection * (CFspeed * deltaTime)
		local headCFrame = Head.CFrame
		local camera = workspace.CurrentCamera
		local cameraCFrame = camera.CFrame
		local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
		cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
		local cameraPosition = cameraCFrame.Position
		local headPosition = headCFrame.Position

		local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
		Head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
	end)
end)

addcmd('uncframefly',{'uncfly'},function(args, speaker)
	if CFloop then
		CFloop:Disconnect()
		speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
		local Head = speaker.Character:WaitForChild("Head")
		Head.Anchored = false
	end
end)

addcmd('cframeflyspeed',{'cflyspeed'},function(args, speaker)
	if isNumber(args[1]) then
		CFspeed = args[1]
	end
end)

Floating = false
floatName = randomString()
addcmd('float', {'platform'},function(args, speaker)
	Floating = true
	local pchar = speaker.Character
	if pchar and not pchar:FindFirstChild(floatName) then
		task.spawn(function()
			local Float = Instance.new('Part')
			Float.Name = floatName
			Float.Parent = pchar
			Float.Transparency = 1
			Float.Size = Vector3.new(2,0.2,1.5)
			Float.Anchored = true
			local FloatValue = -3.1
			Float.CFrame = getRoot(pchar).CFrame * CFrame.new(0,FloatValue,0)
			notify('Float','Float Enabled (Q = down & E = up)')
			qUp = connectBindable(IYMouse.KeyUp,function(KEY)
				if KEY == 'q' then
					FloatValue = FloatValue + 0.5
				end
			end)
			eUp = connectBindable(IYMouse.KeyUp,function(KEY)
				if KEY == 'e' then
					FloatValue = FloatValue - 1.5
				end
			end)
			qDown = connectBindable(IYMouse.KeyDown,function(KEY)
				if KEY == 'q' then
					FloatValue = FloatValue - 0.5
				end
			end)
			eDown = connectBindable(IYMouse.KeyDown,function(KEY)
				if KEY == 'e' then
					FloatValue = FloatValue + 1.5
				end
			end)
			floatDied = speaker.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				FloatingFunc:Disconnect()
				Float:Destroy()
				qUp:Disconnect()
				eUp:Disconnect()
				qDown:Disconnect()
				eDown:Disconnect()
				floatDied:Disconnect()
			end)
			local function FloatPadLoop()
				if pchar:FindFirstChild(floatName) and getRoot(pchar) then
					Float.CFrame = getRoot(pchar).CFrame * CFrame.new(0,FloatValue,0)
				else
					FloatingFunc:Disconnect()
					Float:Destroy()
					qUp:Disconnect()
					eUp:Disconnect()
					qDown:Disconnect()
					eDown:Disconnect()
					floatDied:Disconnect()
				end
			end			
			FloatingFunc = RunService.Heartbeat:Connect(FloatPadLoop)
		end)
	end
end)

addcmd('unfloat',{'nofloat','unplatform','noplatform'},function(args, speaker)
	Floating = false
	local pchar = speaker.Character
	notify('Float','Float Disabled')
	if pchar:FindFirstChild(floatName) then
		pchar:FindFirstChild(floatName):Destroy()
	end
	if floatDied then
		FloatingFunc:Disconnect()
		qUp:Disconnect()
		eUp:Disconnect()
		qDown:Disconnect()
		eDown:Disconnect()
		floatDied:Disconnect()
	end
end)

addcmd('togglefloat',{},function(args, speaker)
	if Floating then
		execCmd('unfloat')
	else
		execCmd('float')
	end
end)

swimming = false
local oldgrav = workspace.Gravity
local swimbeat = nil
addcmd('swim',{},function(args, speaker)
	if not swimming and speaker and speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid") then
		oldgrav = workspace.Gravity
		workspace.Gravity = 0
		local swimDied = function()
			workspace.Gravity = oldgrav
			swimming = false
		end
		local Humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
		gravReset = Humanoid.Died:Connect(swimDied)
		local enums = Enum.HumanoidStateType:GetEnumItems()
		table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
		for i, v in pairs(enums) do
			Humanoid:SetStateEnabled(v, false)
		end
		Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		swimbeat = RunService.Heartbeat:Connect(function()
			pcall(function()
				speaker.Character.HumanoidRootPart.Velocity = ((Humanoid.MoveDirection ~= Vector3.new() or UserInputService:IsKeyDown(Enum.KeyCode.Space)) and speaker.Character.HumanoidRootPart.Velocity or Vector3.new())
			end)
		end)
		swimming = true
	end
end)

addcmd('unswim',{'noswim'},function(args, speaker)
	if speaker and speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid") then
		workspace.Gravity = oldgrav
		swimming = false
		if gravReset then
			gravReset:Disconnect()
		end
		if swimbeat ~= nil then
			swimbeat:Disconnect()
			swimbeat = nil
		end
		local Humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
		local enums = Enum.HumanoidStateType:GetEnumItems()
		table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
		for i, v in pairs(enums) do
			Humanoid:SetStateEnabled(v, true)
		end
	end
end)

addcmd('toggleswim',{},function(args, speaker)
	if swimming then
		execCmd('unswim')
	else
		execCmd('swim')
	end
end)

addcmd('setwaypoint',{'swp','setwp','spos','saveposition','savepos'},function(args, speaker)
	local WPName = tostring(getstring(1))
	if getRoot(speaker.Character) then
		notify('Modified Waypoints',"Created waypoint: "..getstring(1))
		local torso = getRoot(speaker.Character)
		WayPoints[#WayPoints + 1] = {NAME = WPName, COORD = {math.floor(torso.Position.X), math.floor(torso.Position.Y), math.floor(torso.Position.Z)}, GAME = PlaceId}
		if AllWaypoints ~= nil then
			AllWaypoints[#AllWaypoints + 1] = {NAME = WPName, COORD = {math.floor(torso.Position.X), math.floor(torso.Position.Y), math.floor(torso.Position.Z)}, GAME = PlaceId}
		end
	end	
	refreshwaypoints()
	updatesaves()
end)

addcmd('waypointpos',{'wpp','setwaypointposition','setpos','setwaypoint','setwaypointpos'},function(args, speaker)
	local WPName = tostring(getstring(1))
	if getRoot(speaker.Character) then
		notify('Modified Waypoints',"Created waypoint: "..getstring(1))
		WayPoints[#WayPoints + 1] = {NAME = WPName, COORD = {args[2], args[3], args[4]}, GAME = PlaceId}
		if AllWaypoints ~= nil then
			AllWaypoints[#AllWaypoints + 1] = {NAME = WPName, COORD = {args[2], args[3], args[4]}, GAME = PlaceId}
		end
	end	
	refreshwaypoints()
	updatesaves()
end)

addcmd('waypoints',{'positions'},function(args, speaker)
	if SettingsOpen == false then SettingsOpen = true
		if Settings then
			Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.5, true, nil)
		end
		CMDsF.Visible = false
	end
	if KeybindsFrame then
		KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
	end
	if AliasesFrame then
		AliasesFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
	end
	if PluginsFrame then
		PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
	end
	if PositionsFrame then
		PositionsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	end
	wait(0.5)
	SettingsHolder.Visible = false
	maximizeHolder()
end)

waypointParts = {}
addcmd('showwaypoints',{'showwp','showwps'},function(args, speaker)
	execCmd('hidewaypoints')
	wait()
	for i,_ in pairs(WayPoints) do
		local x = WayPoints[i].COORD[1]
		local y = WayPoints[i].COORD[2]
		local z = WayPoints[i].COORD[3]
		local part = Instance.new("Part")
		part.Size = Vector3.new(5,5,5)
		part.CFrame = CFrame.new(x,y,z)
		part.Parent = workspace
		part.Anchored = true
		part.CanCollide = false
		table.insert(waypointParts,part)
		local view = Instance.new("BoxHandleAdornment")
		view.Adornee = part
		view.AlwaysOnTop = true
		view.ZIndex = 10
		view.Size = part.Size
		view.Parent = part
	end
	for i,v in pairs(pWayPoints) do
		local view = Instance.new("BoxHandleAdornment")
		view.Adornee = pWayPoints[i].COORD[1]
		view.AlwaysOnTop = true
		view.ZIndex = 10
		view.Size = pWayPoints[i].COORD[1].Size
		view.Parent = pWayPoints[i].COORD[1]
		table.insert(waypointParts,view)
	end
end)

addcmd('hidewaypoints',{'hidewp','hidewps'},function(args, speaker)
	for i,v in pairs(waypointParts) do
		v:Destroy()
	end
	waypointParts = {}
end)

addcmd('waypoint',{'wp','lpos','loadposition','loadpos'},function(args, speaker)
	local WPName = tostring(getstring(1))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				local x = WayPoints[i].COORD[1]
				local y = WayPoints[i].COORD[2]
				local z = WayPoints[i].COORD[3]
				getRoot(speaker.Character).CFrame = CFrame.new(x,y,z)
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				getRoot(speaker.Character).CFrame = CFrame.new(pWayPoints[i].COORD[1].Position)
			end
		end
	end
end)

tweenSpeed = 1
addcmd('tweenspeed',{'tspeed'},function(args, speaker)
	local newSpeed = args[1] or 1
	if tonumber(newSpeed) then
		tweenSpeed = tonumber(newSpeed)
	end
end)

addcmd('tweenwaypoint',{'twp'},function(args, speaker)
	local WPName = tostring(getstring(1))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(x,y,z)}):Play()
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pWayPoints[i].COORD[1].Position)}):Play()
			end
		end
	end
end)

addcmd('walktowaypoint',{'wtwp'},function(args, speaker)
	local WPName = tostring(getstring(1))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(x,y,z)
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(pWayPoints[i].COORD[1].Position)
			end
		end
	end
end)

addcmd('deletewaypoint',{'dwp','dpos','deleteposition','deletepos'},function(args, speaker)
	for i,v in pairs(WayPoints) do
		if v.NAME:lower() == tostring(getstring(1)):lower() then
			notify('Modified Waypoints',"Deleted waypoint: " .. v.NAME)
			table.remove(WayPoints, i)
		end
	end
	if AllWaypoints ~= nil and #AllWaypoints > 0 then
		for i,v in pairs(AllWaypoints) do
			if v.NAME:lower() == tostring(getstring(1)):lower() then
				if not v.GAME or v.GAME == PlaceId then
					table.remove(AllWaypoints, i)
				end
			end
		end
	end
	for i,v in pairs(pWayPoints) do
		if v.NAME:lower() == tostring(getstring(1)):lower() then
			notify('Modified Waypoints',"Deleted waypoint: " .. v.NAME)
			table.remove(pWayPoints, i)
		end
	end
	refreshwaypoints()
	updatesaves()
end)

addcmd('clearwaypoints',{'cwp','clearpositions','cpos','clearpos'},function(args, speaker)
	WayPoints = {}
	pWayPoints = {}
	refreshwaypoints()
	updatesaves()
	AllWaypoints = {}
	notify('Modified Waypoints','Removed all waypoints')
end)

addcmd('cleargamewaypoints',{'cgamewp'},function(args, speaker)
	for i,v in pairs(WayPoints) do
		if v.GAME == PlaceId then
			table.remove(WayPoints, i)
		end
	end
	if AllWaypoints ~= nil and #AllWaypoints > 0 then
		for i,v in pairs(AllWaypoints) do
			if v.GAME == PlaceId then
				table.remove(AllWaypoints, i)
			end
		end
	end
	for i,v in pairs(pWayPoints) do
		if v.GAME == PlaceId then
			table.remove(pWayPoints, i)
		end
	end
	refreshwaypoints()
	updatesaves()
	notify('Modified Waypoints','Deleted game waypoints')
end)

end do -- Split Scope 11

local coreGuiTypeNames = {
	-- predefined aliases
	["inventory"] = Enum.CoreGuiType.Backpack,
	["leaderboard"] = Enum.CoreGuiType.PlayerList,
	["emotes"] = Enum.CoreGuiType.EmotesMenu
}

-- Load the full list of enums
for _, enumItem in ipairs(Enum.CoreGuiType:GetEnumItems()) do
	coreGuiTypeNames[enumItem.Name:lower()] = enumItem
end

addcmd('enable',{},function(args, speaker)
	local input = args[1] and args[1]:lower()
	if input then
		if input == "reset" then
			StarterGui:SetCore("ResetButtonCallback", true)
		else
			local coreGuiType = coreGuiTypeNames[input]
			if coreGuiType then
				StarterGui:SetCoreGuiEnabled(coreGuiType, true)
			end
		end
	end
end)

addcmd('disable',{},function(args, speaker)
	local input = args[1] and args[1]:lower()
	if input then
		if input == "reset" then
			StarterGui:SetCore("ResetButtonCallback", false)
		else
			local coreGuiType = coreGuiTypeNames[input]
			if coreGuiType then
				StarterGui:SetCoreGuiEnabled(coreGuiType, false)
			end
		end
	end
end)

local invisGUIS = {}
addcmd('showguis',{},function(args, speaker)
	for i,v in pairs(PlayerGui:GetDescendants()) do
		if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame")) and not v.Visible then
			v.Visible = true
			if not FindInTable(invisGUIS,v) then
				table.insert(invisGUIS,v)
			end
		end
	end
end)

addcmd('unshowguis',{},function(args, speaker)
	for i,v in pairs(invisGUIS) do
		v.Visible = false
	end
	invisGUIS = {}
end)

local hiddenGUIS = {}
addcmd('hideguis',{},function(args, speaker)
	for i,v in pairs(PlayerGui:GetDescendants()) do
		if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame")) and v.Visible then
			v.Visible = false
			if not FindInTable(hiddenGUIS,v) then
				table.insert(hiddenGUIS,v)
			end
		end
	end
end)

addcmd('unhideguis',{},function(args, speaker)
	for i,v in pairs(hiddenGUIS) do
		v.Visible = true
	end
	hiddenGUIS = {}
end)

function deleteGuisAtPos()
	pcall(function()
		local guisAtPosition = PlayerGui:GetGuiObjectsAtPosition(IYMouse.X, IYMouse.Y)
		for _, gui in pairs(guisAtPosition) do
			if gui.Visible == true then
				gui:Destroy()
			end
		end
	end)
end

local deleteGuiInput
addcmd('guidelete',{},function(args, speaker)
	deleteGuiInput = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if not gameProcessedEvent then
			if input.KeyCode == Enum.KeyCode.Backspace then
				deleteGuisAtPos()
			end
		end
	end)
	notify('GUI Delete Enabled','Hover over a GUI and press backspace to delete it')
end)

addcmd('unguidelete',{'noguidelete'},function(args, speaker)
	if deleteGuiInput then deleteGuiInput:Disconnect() end
	notify('GUI Delete Disabled','GUI backspace delete has been disabled')
end)

local wasStayOpen = StayOpen
addcmd('hideiy',{},function(args, speaker)
	isHidden = true
	wasStayOpen = StayOpen
	if StayOpen == true then
		StayOpen = false
		On.BackgroundTransparency = 1
	end
	minimizeNum = 0
	minimizeHolder()
	if not (args[1] and tostring(args[1]) == 'nonotify') then notify('IY Hidden','You can press the prefix key to access the command bar') end
end)

addcmd('showiy',{'unhideiy'},function(args, speaker)
	isHidden = false
	minimizeNum = -20
	if wasStayOpen then
		maximizeHolder()
		StayOpen = true
		On.BackgroundTransparency = 0
	else
		minimizeHolder()
	end
end)

addcmd('rec', {'record'}, function(args, speaker)
	return COREGUI:ToggleRecording()
end)

addcmd('screenshot', {'scrnshot'}, function(args, speaker)
	return COREGUI:TakeScreenshot()
end)

addcmd('togglefs', {'togglefullscreen'}, function(args, speaker)
	return GuiService:ToggleFullscreen()
end)

addcmd('inspect', {'examine'}, function(args, speaker)
	for _, v in ipairs(getPlayer(args[1], speaker)) do
		GuiService:CloseInspectMenu()
		GuiService:InspectPlayerFromUserId(Players[v].UserId)
	end
end)

addcmd("savegame", {"saveplace"}, function(args, speaker)
    if saveinstance then
        notify("Loading", "Downloading game. This will take a while")
        saveinstance()
        notify("Game Saved", "Saved place to the workspace folder within your exploit folder.")
    else
        notify("Incompatible Exploit", "Your exploit does not support this command (missing saveinstance)")
    end
end)

addcmd('clearerror',{'clearerrors'},function(args, speaker)
	GuiService:ClearError()
end)

addcmd('clientantikick',{'antikick'},function(args, speaker)
	if not hookmetamethod then 
	    return notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
	end
	local LocalPlayer = Players.LocalPlayer
	local oldhmmi
	local oldhmmnc
	local oldKickFunction
	if hookfunction then
	    oldKickFunction = hookfunction(LocalPlayer.Kick, function() end)
	end
	oldhmmi = hookmetamethod(game, "__index", function(self, method)
	    if self == LocalPlayer and method:lower() == "kick" then
	        return error("Expected ':' not '.' calling member function Kick", 2)
	    end
	    return oldhmmi(self, method)
	end)
	oldhmmnc = hookmetamethod(game, "__namecall", function(self, ...)
	    if self == LocalPlayer and getnamecallmethod():lower() == "kick" then
	        return
	    end
	    return oldhmmnc(self, ...)
	end)
	
	notify('Client Antikick','Client anti kick is now active (only effective on localscript kick)')
end)

allow_rj = true
addcmd('clientantiteleport',{'antiteleport'},function(args, speaker)
	if not hookmetamethod then 
		return notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
	end
	local TeleportService = TeleportService
	local oldhmmi
	local oldhmmnc
	oldhmmi = hookmetamethod(game, "__index", function(self, method)
		if self == TeleportService then
			if method:lower() == "teleport" then
				return error("Expected ':' not '.' calling member function Kick", 2)
			elseif method == "TeleportToPlaceInstance" then
				return error("Expected ':' not '.' calling member function TeleportToPlaceInstance", 2)
			end
		end
		return oldhmmi(self, method)
	end)
	oldhmmnc = hookmetamethod(game, "__namecall", function(self, ...)
		if self == TeleportService and getnamecallmethod():lower() == "teleport" or getnamecallmethod() == "TeleportToPlaceInstance" then
			return
		end
		return oldhmmnc(self, ...)
	end)

	notify('Client AntiTP','Client anti teleport is now active (only effective on localscript teleport)')
end)

addcmd('allowrejoin',{'allowrj'},function(args, speaker)
	if args[1] and args[1] == 'false' then
		allow_rj = false
		notify('Client AntiTP','Allow rejoin set to false')
	else
		allow_rj = true
		notify('Client AntiTP','Allow rejoin set to true')
	end
end)

addcmd("cancelteleport", {"canceltp"}, function(args, speaker)
    TeleportService:TeleportCancel()
end)

addcmd("volume",{ "vol"}, function(args, speaker)
    UserSettings():GetService("UserGameSettings").MasterVolume = args[1]/10
end)

addcmd("antilag", {"boostfps", "lowgraphics"}, function(args, speaker)
	local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
	Terrain.WaterWaveSize = 0
	Terrain.WaterWaveSpeed = 0
	Terrain.WaterReflectance = 0
	Terrain.WaterTransparency = 1
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9e9
	Lighting.FogStart = 9e9
	settings().Rendering.QualityLevel = 1
	for _, v in pairs(game:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CastShadow = false
			v.Material = "Plastic"
			v.Reflectance = 0
			v.BackSurface = "SmoothNoOutlines"
			v.BottomSurface = "SmoothNoOutlines"
			v.FrontSurface = "SmoothNoOutlines"
			v.LeftSurface = "SmoothNoOutlines"
			v.RightSurface = "SmoothNoOutlines"
			v.TopSurface = "SmoothNoOutlines"
		elseif v:IsA("Decal") then
			v.Transparency = 1
			v.Texture = ""
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
			v.Lifetime = NumberRange.new(0)
		end
	end
	for _, v in pairs(Lighting:GetDescendants()) do
		if v:IsA("PostEffect") then
			v.Enabled = false
		end
	end
	workspace.DescendantAdded:Connect(function(child)
		task.spawn(function()
			if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
				RunService.Heartbeat:Wait()
				child:Destroy()
			elseif child:IsA("BasePart") then
				child.CastShadow = false
			end
		end)
	end)
end)

addcmd("setfpscap", {"fpscap", "maxfps"}, function(args, speaker)
    if fpscaploop then
        task.cancel(fpscaploop)
        fpscaploop = nil
    end

    local fpsCap = 60
    local num = tonumber(args[1]) or 1e6
    if num == "none" then
        return
    elseif num > 0 then
        fpsCap = num
    else
        return notify("Invalid argument", "Please provide a number above 0 or 'none'.")
    end

    if setfpscap and type(setfpscap) == "function" then
        setfpscap(fpsCap)
    else
        fpscaploop = task.spawn(function()
            local timer = os.clock()
            while true do
                if os.clock() >= timer + 1 / fpsCap then
                    timer = os.clock()
                    task.wait()
                end
            end
        end)
    end
end)

addcmd('notify',{},function(args, speaker)
	notify(getstring(1))
end)

addcmd('lastcommand',{'lastcmd'},function(args, speaker)
	if cmdHistory[1]:sub(1,11) ~= 'lastcommand' and cmdHistory[1]:sub(1,7) ~= 'lastcmd' then
		execCmd(cmdHistory[1])
	end
end)

addcmd('esp',{},function(args, speaker)
	if not CHMSenabled then
		ESPenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				ESP(v)
			end
		end
	else
		notify('ESP','Disable chams (nochams) before using esp')
	end
end)

addcmd('espteam',{},function(args, speaker)
	if not CHMSenabled then
		ESPenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				ESP(v, true)
			end
		end
	else
		notify('ESP','Disable chams (nochams) before using esp')
	end
end)

addcmd('noesp',{'unesp','unespteam'},function(args, speaker)
	ESPenabled = false
	for i,c in pairs(COREGUI:GetChildren()) do
		if string.sub(c.Name, -4) == '_ESP' then
			c:Destroy()
		end
	end
end)

addcmd('esptransparency',{},function(args, speaker)
	espTransparency = (args[1] and isNumber(args[1]) and args[1]) or 0.3
	updatesaves()
end)

local espParts = {}
local partEspTrigger = nil
function partAdded(part)
	if #espParts > 0 then
		if FindInTable(espParts,part.Name:lower()) then
			local a = Instance.new("BoxHandleAdornment")
			a.Name = part.Name:lower().."_PESP"
			a.Parent = part
			a.Adornee = part
			a.AlwaysOnTop = true
			a.ZIndex = 0
			a.Size = part.Size
			a.Transparency = espTransparency
			a.Color = BrickColor.new("Lime green")
		end
	else
		partEspTrigger:Disconnect()
		partEspTrigger = nil
	end
end

addcmd('partesp',{},function(args, speaker)
	local partEspName = getstring(1):lower()
	if not FindInTable(espParts,partEspName) then
		table.insert(espParts,partEspName)
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") and v.Name:lower() == partEspName then
				local a = Instance.new("BoxHandleAdornment")
				a.Name = partEspName.."_PESP"
				a.Parent = v
				a.Adornee = v
				a.AlwaysOnTop = true
				a.ZIndex = 0
				a.Size = v.Size
				a.Transparency = espTransparency
				a.Color = BrickColor.new("Lime green")
			end
		end
	end
	if partEspTrigger == nil then
		partEspTrigger = workspace.DescendantAdded:Connect(partAdded)
	end
end)

addcmd('unpartesp',{'nopartesp'},function(args, speaker)
	if args[1] then
		local partEspName = getstring(1):lower()
		if FindInTable(espParts,partEspName) then
			table.remove(espParts, GetInTable(espParts, partEspName))
		end
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BoxHandleAdornment") and v.Name == partEspName..'_PESP' then
				v:Destroy()
			end
		end
	else
		partEspTrigger:Disconnect()
		partEspTrigger = nil
		espParts = {}
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BoxHandleAdornment") and v.Name:sub(-5) == '_PESP' then
				v:Destroy()
			end
		end
	end
end)

addcmd('chams',{},function(args, speaker)
	if not ESPenabled then
		CHMSenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				CHMS(v)
			end
		end
	else
		notify('Chams','Disable ESP (noesp) before using chams')
	end
end)

addcmd('nochams',{'unchams'},function(args, speaker)
	CHMSenabled = false
	for i,v in pairs(Players:GetPlayers()) do
		local chmsplr = v
		for i,c in pairs(COREGUI:GetChildren()) do
			if c.Name == chmsplr.Name..'_CHMS' then
				c:Destroy()
			end
		end
	end
end)

addcmd('locate',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		Locate(Players[v])
	end
end)

addcmd('nolocate',{'unlocate'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if args[1] then
		for i,v in pairs(players) do
			for i,c in pairs(COREGUI:GetChildren()) do
				if c.Name == Players[v].Name..'_LC' then
					c:Destroy()
				end
			end
		end
	else
		for i,c in pairs(COREGUI:GetChildren()) do
			if string.sub(c.Name, -3) == '_LC' then
				c:Destroy()
			end
		end
	end
end)

viewing = nil
addcmd('view',{'spectate'},function(args, speaker)
	StopFreecam()
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if viewDied then
			viewDied:Disconnect()
			viewChanged:Disconnect()
		end
		viewing = Players[v]
		workspace.CurrentCamera.CameraSubject = viewing.Character
		notify('Spectate','Viewing ' .. Players[v].Name)
		local function viewDiedFunc()
			repeat wait() until Players[v].Character ~= nil and getRoot(Players[v].Character)
			workspace.CurrentCamera.CameraSubject = viewing.Character
		end
		viewDied = Players[v].CharacterAdded:Connect(viewDiedFunc)
		local function viewChangedFunc()
			workspace.CurrentCamera.CameraSubject = viewing.Character
		end
		viewChanged = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(viewChangedFunc)
	end
end)

end do -- Split Scope 1

addcmd('viewpart',{'viewp'},function(args, speaker)
	StopFreecam()
	if args[1] then
		for i,v in pairs(workspace:GetDescendants()) do
			if v.Name:lower() == getstring(1):lower() and v:IsA("BasePart") then
				wait(0.1)
				workspace.CurrentCamera.CameraSubject = v
			end
		end
	end
end)

addcmd('unview',{'unspectate'},function(args, speaker)
	StopFreecam()
	if viewing ~= nil then
		viewing = nil
		notify('Spectate','View turned off')
	end
	if viewDied then
		viewDied:Disconnect()
		viewChanged:Disconnect()
	end
	workspace.CurrentCamera.CameraSubject = speaker.Character
end)

fcRunning = false
Camera = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local newCamera = workspace.CurrentCamera
	if newCamera then
		Camera = newCamera
	end
end)

local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value

Spring = {} do
	Spring.__index = Spring

	function Spring.new(freq, pos)
		local self = setmetatable({}, Spring)
		self.f = freq
		self.p = pos
		self.v = pos*0
		return self
	end

	function Spring:Update(dt, goal)
		local f = self.f*2*math.pi
		local p0 = self.p
		local v0 = self.v

		local offset = goal - p0
		local decay = math.exp(-f*dt)

		local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
		local v1 = (f*dt*(offset*f - v0) + v0)*decay

		self.p = p1
		self.v = v1

		return p1
	end

	function Spring:Reset(pos)
		self.p = pos
		self.v = pos*0
	end
end

local cameraPos = Vector3.new()
local cameraRot = Vector2.new()

local velSpring = Spring.new(5, Vector3.new())
local panSpring = Spring.new(5, Vector2.new())

Input = {} do

	keyboard = {
		W = 0,
		A = 0,
		S = 0,
		D = 0,
		E = 0,
		Q = 0,
		Up = 0,
		Down = 0,
		LeftShift = 0,
	}

	mouse = {
		Delta = Vector2.new(),
	}

	NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
	PAN_MOUSE_SPEED = Vector2.new(1, 1)*(math.pi/64)
	NAV_ADJ_SPEED = 0.75
	NAV_SHIFT_MUL = 0.25

	navSpeed = 1

	function Input.Vel(dt)
		navSpeed = math.clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)

		local kKeyboard = Vector3.new(
			keyboard.D - keyboard.A,
			keyboard.E - keyboard.Q,
			keyboard.S - keyboard.W
		)*NAV_KEYBOARD_SPEED

		local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)

		return (kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
	end

	function Input.Pan(dt)
		local kMouse = mouse.Delta*PAN_MOUSE_SPEED
		mouse.Delta = Vector2.new()
		return kMouse
	end

	do
		function Keypress(action, state, input)
			keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
			return Enum.ContextActionResult.Sink
		end

		function MousePan(action, state, input)
			local delta = input.Delta
			mouse.Delta = Vector2.new(-delta.y, -delta.x)
			return Enum.ContextActionResult.Sink
		end

		function Zero(t)
			for k, v in pairs(t) do
				t[k] = v*0
			end
		end

		function Input.StartCapture()
			ContextActionService:BindActionAtPriority("FreecamKeyboard",Keypress,false,INPUT_PRIORITY,
				Enum.KeyCode.W,
				Enum.KeyCode.A,
				Enum.KeyCode.S,
				Enum.KeyCode.D,
				Enum.KeyCode.E,
				Enum.KeyCode.Q,
				Enum.KeyCode.Up,
				Enum.KeyCode.Down
			)
			ContextActionService:BindActionAtPriority("FreecamMousePan",MousePan,false,INPUT_PRIORITY,Enum.UserInputType.MouseMovement)
		end

		function Input.StopCapture()
			navSpeed = 1
			Zero(keyboard)
			Zero(mouse)
			ContextActionService:UnbindAction("FreecamKeyboard")
			ContextActionService:UnbindAction("FreecamMousePan")
		end
	end
end

function GetFocusDistance(cameraFrame)
	local znear = 0.1
	local viewport = Camera.ViewportSize
	local projy = 2*math.tan(cameraFov/2)
	local projx = viewport.x/viewport.y*projy
	local fx = cameraFrame.rightVector
	local fy = cameraFrame.upVector
	local fz = cameraFrame.lookVector

	local minVect = Vector3.new()
	local minDist = 512

	for x = 0, 1, 0.5 do
		for y = 0, 1, 0.5 do
			local cx = (x - 0.5)*projx
			local cy = (y - 0.5)*projy
			local offset = fx*cx - fy*cy + fz
			local origin = cameraFrame.p + offset*znear
			local _, hit = workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))
			local dist = (hit - origin).magnitude
			if minDist > dist then
				minDist = dist
				minVect = offset.unit
			end
		end
	end

	return fz:Dot(minVect)*minDist
end

local function StepFreecam(dt)
	local vel = velSpring:Update(dt, Input.Vel(dt))
	local pan = panSpring:Update(dt, Input.Pan(dt))

	local zoomFactor = math.sqrt(math.tan(math.rad(70/2))/math.tan(math.rad(cameraFov/2)))

	cameraRot = cameraRot + pan*Vector2.new(0.75, 1)*8*(dt/zoomFactor)
	cameraRot = Vector2.new(math.clamp(cameraRot.x, -math.rad(90), math.rad(90)), cameraRot.y%(2*math.pi))

	local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*Vector3.new(1, 1, 1)*64*dt)
	cameraPos = cameraCFrame.p

	Camera.CFrame = cameraCFrame
	Camera.Focus = cameraCFrame*CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
	Camera.FieldOfView = cameraFov
end

local PlayerState = {} do
	mouseBehavior = ""
	mouseIconEnabled = ""
	cameraType = ""
	cameraFocus = ""
	cameraCFrame = ""
	cameraFieldOfView = ""

	function PlayerState.Push()
		cameraFieldOfView = Camera.FieldOfView
		Camera.FieldOfView = 70

		cameraType = Camera.CameraType
		Camera.CameraType = Enum.CameraType.Custom

		cameraCFrame = Camera.CFrame
		cameraFocus = Camera.Focus

		mouseIconEnabled = UserInputService.MouseIconEnabled
		UserInputService.MouseIconEnabled = true

		mouseBehavior = UserInputService.MouseBehavior
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	function PlayerState.Pop()
		Camera.FieldOfView = 70

		Camera.CameraType = cameraType
		cameraType = nil

		Camera.CFrame = cameraCFrame
		cameraCFrame = nil

		Camera.Focus = cameraFocus
		cameraFocus = nil

		UserInputService.MouseIconEnabled = mouseIconEnabled
		mouseIconEnabled = nil

		UserInputService.MouseBehavior = mouseBehavior
		mouseBehavior = nil
	end
end

function StartFreecam(pos)
	if fcRunning then
		StopFreecam()
	end
	local cameraCFrame = Camera.CFrame
	if pos then
		cameraCFrame = pos
	end
	cameraRot = Vector2.new()
	cameraPos = cameraCFrame.p
	cameraFov = Camera.FieldOfView

	velSpring:Reset(Vector3.new())
	panSpring:Reset(Vector2.new())

	PlayerState.Push()
	RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
	Input.StartCapture()
	fcRunning = true
end

function StopFreecam()
	if not fcRunning then return end
	Input.StopCapture()
	RunService:UnbindFromRenderStep("Freecam")
	PlayerState.Pop()
	workspace.Camera.FieldOfView = 70
	fcRunning = false
end

addcmd('freecam',{'fc'},function(args, speaker)
	StartFreecam()
end)

addcmd('freecampos',{'fcpos','fcp','freecamposition','fcposition'},function(args, speaker)
	if not args[1] then return end
	local freecamPos = CFrame.new(args[1],args[2],args[3])
	StartFreecam(freecamPos)
end)

addcmd('freecamwaypoint',{'fcwp'},function(args, speaker)
	local WPName = tostring(getstring(1))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				StartFreecam(CFrame.new(x,y,z))
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				StartFreecam(CFrame.new(pWayPoints[i].COORD[1].Position))
			end
		end
	end
end)

addcmd('freecamgoto',{'fcgoto','freecamtp','fctp'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		StartFreecam(getRoot(Players[v].Character).CFrame)
	end
end)

addcmd('unfreecam',{'nofreecam','unfc','nofc'},function(args, speaker)
	StopFreecam()
end)

addcmd('freecamspeed',{'fcspeed'},function(args, speaker)
	local FCspeed = args[1] or 1
	if isNumber(FCspeed) then
		NAV_KEYBOARD_SPEED = Vector3.new(FCspeed, FCspeed, FCspeed)
	end
end)

addcmd('notifyfreecamposition',{'notifyfcpos'},function(args, speaker)
	if fcRunning then
		local X,Y,Z = workspace.CurrentCamera.CFrame.Position.X,workspace.CurrentCamera.CFrame.Position.Y,workspace.CurrentCamera.CFrame.Position.Z
		local Format, Round = string.format, math.round
		notify("Current Position", Format("%s, %s, %s", Round(X), Round(Y), Round(Z)))
	end
end)

addcmd('copyfreecamposition',{'copyfcpos'},function(args, speaker)
	if fcRunning then
		local X,Y,Z = workspace.CurrentCamera.CFrame.Position.X,workspace.CurrentCamera.CFrame.Position.Y,workspace.CurrentCamera.CFrame.Position.Z
		local Format, Round = string.format, math.round
		toClipboard(Format("%s, %s, %s", Round(X), Round(Y), Round(Z)))
	end
end)

addcmd('gotocamera',{'gotocam','tocam'},function(args, speaker)
	getRoot(speaker.Character).CFrame = workspace.Camera.CFrame
end)

addcmd('tweengotocamera',{'tweengotocam','tgotocam','ttocam'},function(args, speaker)
	TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = workspace.Camera.CFrame}):Play()
end)

addcmd('fov',{},function(args, speaker)
	local fov = args[1] or 70
	if isNumber(fov) then
		workspace.CurrentCamera.FieldOfView = fov
	end
end)

local preMaxZoom = Players.LocalPlayer.CameraMaxZoomDistance
local preMinZoom = Players.LocalPlayer.CameraMinZoomDistance
addcmd('lookat',{},function(args, speaker)
	if speaker.CameraMaxZoomDistance ~= 0.5 then
		preMaxZoom = speaker.CameraMaxZoomDistance
		preMinZoom = speaker.CameraMinZoomDistance
	end
	speaker.CameraMaxZoomDistance = 0.5
	speaker.CameraMinZoomDistance = 0.5
	wait()
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local target = Players[v].Character
		if target and target:FindFirstChild('Head') then
			workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.p, target.Head.CFrame.p)
			wait(0.1)
		end
	end
	speaker.CameraMaxZoomDistance = preMaxZoom
	speaker.CameraMinZoomDistance = preMinZoom
end)

addcmd('fixcam',{'restorecam'},function(args, speaker)
	StopFreecam()
	execCmd('unview')
	workspace.CurrentCamera:remove()
	wait(.1)
	repeat wait() until speaker.Character ~= nil
	workspace.CurrentCamera.CameraSubject = speaker.Character:FindFirstChildWhichIsA('Humanoid')
	workspace.CurrentCamera.CameraType = "Custom"
	speaker.CameraMinZoomDistance = 0.5
	speaker.CameraMaxZoomDistance = 400
	speaker.CameraMode = "Classic"
	speaker.Character.Head.Anchored = false
end)

end do -- Split Scope 12

addcmd("enableshiftlock", {"enablesl", "shiftlock"}, function(args, speaker)
    local function enableShiftlock() 
        speaker.DevEnableMouseLock = true 
    end
    speaker:GetPropertyChangedSignal("DevEnableMouseLock"):Connect(enableShiftlock)
    enableShiftlock()
    notify("Shiftlock", "Shift lock should now be available")
end)

addcmd('firstp',{},function(args, speaker)
	speaker.CameraMode = "LockFirstPerson"
end)

addcmd('thirdp',{},function(args, speaker)
	speaker.CameraMode = "Classic"
end)

addcmd('noclipcam', {'nccam'}, function(args, speaker)
	local sc = (debug and debug.setconstant) or setconstant
	local gc = (debug and debug.getconstants) or getconstants
	if not sc or not getgc or not gc then
		return notify('Incompatible Exploit', 'Your exploit does not support this command (missing setconstant or getconstants or getgc)')
	end
	local pop = speaker.PlayerScripts.PlayerModule.CameraModule.ZoomController.Popper
	for _, v in pairs(getgc()) do
		if type(v) == 'function' and getfenv(v).script == pop then
			for i, v1 in pairs(gc(v)) do
				if tonumber(v1) == .25 then
					sc(v, i, 0)
				elseif tonumber(v1) == 0 then
					sc(v, i, .25)
				end
			end
		end
	end
end)

addcmd('maxzoom',{},function(args, speaker)
	speaker.CameraMaxZoomDistance = args[1]
end)

addcmd('minzoom',{},function(args, speaker)
	speaker.CameraMinZoomDistance = args[1]
end)

addcmd('camdistance',{},function(args, speaker)
	local camMax = speaker.CameraMaxZoomDistance
	local camMin = speaker.CameraMinZoomDistance
	if camMax < tonumber(args[1]) then
		camMax = args[1]
	end
	speaker.CameraMaxZoomDistance = args[1]
	speaker.CameraMinZoomDistance = args[1]
	wait()
	speaker.CameraMaxZoomDistance = camMax
	speaker.CameraMinZoomDistance = camMin
end)

addcmd('unlockws',{'unlockworkspace'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Locked = false
		end
	end
end)

addcmd('lockws',{'lockworkspace'},function(args, speaker) 
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Locked = true
		end
	end
end)

addcmd('delete',{'remove'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted ' ..getstring(1))
end)

addcmd('deleteclass',{'removeclass','deleteclassname','removeclassname','dc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted items with ClassName ' ..getstring(1))
end)

addcmd('chardelete',{'charremove','cd'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.Name:lower() == getstring(1):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted ' ..getstring(1))
end)

addcmd('chardeleteclass',{'charremoveclass','chardeleteclassname','charremoveclassname','cdc'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.ClassName:lower() == getstring(1):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted items with ClassName ' ..getstring(1))
end)

addcmd('deletevelocity',{'dv','removevelocity','removeforces'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("RocketPropulsion") or v:IsA("BodyThrust") or v:IsA("BodyAngularVelocity") or v:IsA("AngularVelocity") or v:IsA("BodyForce") or v:IsA("VectorForce") or v:IsA("LineForce") then
			v:Destroy()
		end
	end
end)

addcmd('deleteinvisparts',{'deleteinvisibleparts','dip'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency == 1 and v.CanCollide then
			v:Destroy()
		end
	end
end)

local shownParts = {}
addcmd('invisibleparts',{'invisparts'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency == 1 then
			if not table.find(shownParts,v) then
				table.insert(shownParts,v)
			end
			v.Transparency = 0
		end
	end
end)

addcmd('uninvisibleparts',{'uninvisparts'},function(args, speaker)
	for i,v in pairs(shownParts) do
		v.Transparency = 1
	end
	shownParts = {}
end)

addcmd("btools", {}, function(args, speaker)
    for i = 1, 4 do
        local Tool = Instance.new("HopperBin")
        Tool.BinType = i
        Tool.Name = randomString()
        Tool.Parent = speaker:FindFirstChildWhichIsA("Backpack")
    end
end)

addcmd("f3x", {"fex"}, function(args, speaker)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/f3x.lua"))()
end)

addcmd("partpath", {"partname"}, function(args, speaker)
    selectPart()
end)

addcmd("antiafk", {"antiidle"}, function(args, speaker)
    if getconnections then
        for _, connection in pairs(getconnections(speaker.Idled)) do
            if connection["Disable"] then
                connection["Disable"](connection)
            elseif connection["Disconnect"] then
                connection["Disconnect"](connection)
            end
        end
    else
        speaker.Idled:Connect(function()
            Services.VirtualUser:CaptureController()
            Services.VirtualUser:ClickButton2(Vector2.new())
        end)
    end
    if not (args[1] and tostring(args[1]) == "nonotify") then notify("Anti Idle", "Anti idle is enabled") end
end)

addcmd("datalimit", {}, function(args, speaker)
    local kbps = tonumber(args[1])
    if kbps then
        Services.NetworkClient:SetOutgoingKBPSLimit(kbps)
    end
end)

addcmd("replicationlag", {"backtrack"}, function(args, speaker)
	if tonumber(args[1]) then
		settings():GetService("NetworkSettings").IncomingReplicationLag = args[1]
	end
end)

addcmd("noprompts", {"nopurchaseprompts"}, function(args, speaker)
	COREGUI.PurchasePromptApp.Enabled = false
end)

addcmd("showprompts", {"showpurchaseprompts"}, function(args, speaker)
	COREGUI.PurchasePromptApp.Enabled = true
end)

promptNewRig = function(speaker, rig)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		AvatarEditorService:PromptSaveAvatar(humanoid.HumanoidDescription, Enum.HumanoidRigType[rig])
		local result = AvatarEditorService.PromptSaveAvatarCompleted:Wait()
		if result == Enum.AvatarPromptResult.Success then
			execCmd("reset")
		end
	end
end

addcmd("promptr6", {}, function(args, speaker)
	promptNewRig(speaker, "R6")
end)

addcmd("promptr15", {}, function(args, speaker)
	promptNewRig(speaker, "R15")
end)

addcmd("wallwalk", {"walkonwalls"}, function(args, speaker)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/wallwalker.lua"))()
end)

addcmd('age',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local ages = {}
	for i,v in pairs(players) do
		local p = Players[v]
		table.insert(ages, p.Name.."'s age is: "..p.AccountAge)
	end
	notify('Account Age',table.concat(ages, ',\n'))
end)

addcmd('chatage',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local ages = {}
	for i,v in pairs(players) do
		local p = Players[v]
		table.insert(ages, p.Name.."'s age is: "..p.AccountAge)
	end
	local chatString = table.concat(ages, ', ')
	chatMessage(chatString)
end)

addcmd('joindate',{'jd'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local dates = {}
	for i,v in pairs(players) do
		local p = Players[v]

		local secondsOld = p.AccountAge * 24 * 60 * 60
		local now = os.time()
		local dateJoined  = p.Name .. " joined: " .. os.date("%m/%d/%y", now - secondsOld)

		table.insert(dates, dateJoined)
	end
	notify('Join Date (Month/Day/Year)',table.concat(dates, ',\n'))
end)

addcmd('chatjoindate',{'cjd'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local dates = {}
	for i,v in pairs(players) do
		local p = Players[v]

		local secondsOld = p.AccountAge * 24 * 60 * 60
		local now = os.time()
		local dateJoined  = p.Name .. " joined: " .. os.date("%m/%d/%y", now - secondsOld)

		table.insert(dates, dateJoined)
	end
	local chatString = table.concat(dates, ', ')
	chatMessage(chatString)
end)

addcmd('copyname',{'copyuser'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local name = tostring(Players[v].Name)
		toClipboard(name)
	end
end)

addcmd('userid',{'id'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local id = tostring(Players[v].UserId)
		notify('User ID',id)
	end
end)

addcmd("copyplaceid", {"placeid"}, function(args, speaker)
    toClipboard(PlaceId)
end)

addcmd("copygameid", {"gameid"}, function(args, speaker)
    toClipboard(game.GameId)
end)

addcmd('copyid',{'copyuserid'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local id = tostring(Players[v].UserId)
		toClipboard(id)
	end
end)

addcmd('creatorid',{'creator'},function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		notify('Creator ID',game.CreatorId)
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
		speaker.UserId = OwnerID
		notify('Creator ID',OwnerID)
	end
end)

addcmd('copycreatorid',{'copycreator'},function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		toClipboard(game.CreatorId)
		notify('Copied ID','Copied creator ID to clipboard')
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
		toClipboard(OwnerID)
		notify('Copied ID','Copied creator ID to clipboard')
	end
end)

addcmd('setcreatorid',{'setcreator'},function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		speaker.UserId = game.CreatorId
		notify('Set ID','Set UserId to '..game.CreatorId)
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
		speaker.UserId = OwnerID
		notify('Set ID','Set UserId to '..OwnerID)
	end
end)

addcmd('appearanceid',{'aid'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local aid = tostring(Players[v].CharacterAppearanceId)
		notify('Appearance ID',aid)
	end
end)

addcmd('copyappearanceid',{'caid'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local aid = tostring(Players[v].CharacterAppearanceId)
		toClipboard(aid)
	end
end)

addcmd('norender',{},function(args, speaker)
	RunService:Set3dRenderingEnabled(false)
end)

addcmd('render',{},function(args, speaker)
	RunService:Set3dRenderingEnabled(true)
end)

addcmd('2022materials',{'use2022materials'},function(args, speaker)
	if sethidden then
		sethidden(MaterialService, "Use2022Materials", true)
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing sethiddenproperty)')
	end
end)

addcmd('un2022materials',{'unuse2022materials'},function(args, speaker)
	if sethidden then
		sethidden(MaterialService, "Use2022Materials", false)
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing sethiddenproperty)')
	end
end)

addcmd('goto',{'to'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(3,1,0)
		end
	end
	execCmd('breakvelocity')
end)

addcmd('tweengoto',{'tgoto','tto','tweento'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(3,1,0)}):Play()
		end
	end
	execCmd('breakvelocity')
end)

end do -- Split Scope 5

addcmd('vehiclegoto',{'vgoto','vtp','vehicletp'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			local seat = speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart
			local vehicleModel = seat:FindFirstAncestorWhichIsA("Model")
			vehicleModel:MoveTo(getRoot(Players[v].Character).Position)
		end
	end
end)

addcmd('pulsetp',{'ptp'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			local startPos = getRoot(speaker.Character).CFrame
			local seconds = args[2] or 1
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(3,1,0)
			wait(seconds)
			getRoot(speaker.Character).CFrame = startPos
		end
	end
	execCmd('breakvelocity')
end)

local vnoclipParts = {}
addcmd('vehiclenoclip',{'vnoclip'},function(args, speaker)
	vnoclipParts = {}
	local seat = speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart
	local vehicleModel = seat.Parent
	repeat
		if vehicleModel.ClassName ~= "Model" then
			vehicleModel = vehicleModel.Parent
		end
	until vehicleModel.ClassName == "Model"
	wait(0.1)
	execCmd('noclip')
	for i,v in pairs(vehicleModel:GetDescendants()) do
		if v:IsA("BasePart") and v.CanCollide then
			table.insert(vnoclipParts,v)
			v.CanCollide = false
		end
	end
end)

addcmd("vehicleclip", {"vclip", "unvnoclip", "unvehiclenoclip"}, function(args, speaker)
	execCmd("clip")
	for i, v in pairs(vnoclipParts) do
		v.CanCollide = true
	end
	vnoclipParts = {}
end)

addcmd("togglevnoclip", {}, function(args, speaker)
	execCmd(Clip and "vnoclip" or "vclip")
end)

addcmd('clientbring',{'cbring'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if Players[v].Character:FindFirstChildOfClass('Humanoid') then
				Players[v].Character:FindFirstChildOfClass('Humanoid').Sit = false
			end
			wait()
			getRoot(Players[v].Character).CFrame = getRoot(speaker.Character).CFrame + Vector3.new(3,1,0)
		end
	end
end)

local bringT = {}
addcmd('loopbring',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			if Players[v].Name ~= speaker.Name and not FindInTable(bringT, Players[v].Name) then
				table.insert(bringT, Players[v].Name)
				local plrName = Players[v].Name
				local pchar=Players[v].Character
				local distance = 3
				if args[2] and isNumber(args[2]) then
					distance = args[2]
				end
				local lDelay = 0
				if args[3] and isNumber(args[3]) then
					lDelay = args[3]
				end
				repeat
					for i,c in pairs(players) do
						if Players:FindFirstChild(v) then
							pchar = Players[v].Character
							if pchar~= nil and Players[v].Character ~= nil and getRoot(pchar) and speaker.Character ~= nil and getRoot(speaker.Character) then
								getRoot(pchar).CFrame = getRoot(speaker.Character).CFrame + Vector3.new(distance,1,0)
							end
							wait(lDelay)
						else 
							for a,b in pairs(bringT) do if b == plrName then table.remove(bringT, a) end end
						end
					end
				until not FindInTable(bringT, plrName)
			end
		end)
	end
end)

addcmd('unloopbring',{'noloopbring'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			for a,b in pairs(bringT) do if b == Players[v].Name then table.remove(bringT, a) end end
		end)
	end
end)

local walkto = false
local waypointwalkto = false
addcmd('walkto',{'follow'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			walkto = true
			repeat wait()
				speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(getRoot(Players[v].Character).Position)
			until Players[v].Character == nil or not getRoot(Players[v].Character) or walkto == false
		end
	end
end)

addcmd('pathfindwalkto',{'pathfindfollow'},function(args, speaker)
	walkto = false
	wait()
	local players = getPlayer(args[1], speaker)
	local hum = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local path = PathService:CreatePath()
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			walkto = true
			repeat wait()
				local success, response = pcall(function()
					path:ComputeAsync(getRoot(speaker.Character).Position, getRoot(Players[v].Character).Position)
					local waypoints = path:GetWaypoints()
					local distance 
					for waypointIndex, waypoint in pairs(waypoints) do
						local waypointPosition = waypoint.Position
						hum:MoveTo(waypointPosition)
						repeat 
							distance = (waypointPosition - hum.Parent.PrimaryPart.Position).magnitude
							wait()
						until
						distance <= 5
					end	 
				end)
				if not success then
					speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(getRoot(Players[v].Character).Position)
				end
			until Players[v].Character == nil or not getRoot(Players[v].Character) or walkto == false
		end
	end
end)

addcmd('pathfindwalktowaypoint',{'pathfindwalktowp'},function(args, speaker)
	waypointwalkto = false
	wait()
	local WPName = tostring(getstring(1))
	local hum = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local path = PathService:CreatePath()
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				local TrueCoords = Vector3.new(WayPoints[i].COORD[1], WayPoints[i].COORD[2], WayPoints[i].COORD[3])
				waypointwalkto = true
				repeat wait()
					local success, response = pcall(function()
						path:ComputeAsync(getRoot(speaker.Character).Position, TrueCoords)
						local waypoints = path:GetWaypoints()
						local distance 
						for waypointIndex, waypoint in pairs(waypoints) do
							local waypointPosition = waypoint.Position
							hum:MoveTo(waypointPosition)
							repeat 
								distance = (waypointPosition - hum.Parent.PrimaryPart.Position).magnitude
								wait()
							until
							distance <= 5
						end
					end)
					if not success then
						speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(TrueCoords)
					end
				until not speaker.Character or waypointwalkto == false
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				local TrueCoords = pWayPoints[i].COORD[1].Position
				waypointwalkto = true
				repeat wait()
					local success, response = pcall(function()
						path:ComputeAsync(getRoot(speaker.Character).Position, TrueCoords)
						local waypoints = path:GetWaypoints()
						local distance 
						for waypointIndex, waypoint in pairs(waypoints) do
							local waypointPosition = waypoint.Position
							hum:MoveTo(waypointPosition)
							repeat 
								distance = (waypointPosition - hum.Parent.PrimaryPart.Position).magnitude
								wait()
							until
							distance <= 5
						end
					end)
					if not success then
						speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(TrueCoords)
					end
				until not speaker.Character or waypointwalkto == false
			end
		end
	end
end)

addcmd('unwalkto',{'nowalkto','unfollow','nofollow'},function(args, speaker)
	walkto = false
	waypointwalkto = false
end)

addcmd("orbit", {}, function(args, speaker)
    execCmd("unorbit nonotify")
    local target = Players:FindFirstChild(getPlayer(args[1], speaker)[1])
    local root = getRoot(speaker.Character)
    local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
    if target and target.Character and getRoot(target.Character) and root and humanoid then
        local rotation = 0
        local speed = tonumber(args[2]) or 0.2
        local distance = tonumber(args[3]) or 6
        orbit1 = RunService.Heartbeat:Connect(function()
            pcall(function()
                rotation = rotation + speed
                root.CFrame = CFrame.new(getRoot(target.Character).Position) * CFrame.Angles(0, math.rad(rotation), 0) * CFrame.new(distance, 0, 0)
            end)
        end)
        orbit2 = RunService.RenderStepped:Connect(function()
            pcall(function()
                root.CFrame = CFrame.new(root.Position, getRoot(target.Character).Position)
            end)
        end)
        orbit3 = humanoid.Died:Connect(function() execCmd("unorbit") end)
        orbit4 = humanoid.Seated:Connect(function(value) if value then execCmd("unorbit") end end)
        notify("Orbit", "Started orbiting " .. formatUsername(target))
    end
end)

addcmd("unorbit", {}, function(args, speaker)
    if orbit1 then orbit1:Disconnect() end
    if orbit2 then orbit2:Disconnect() end
    if orbit3 then orbit3:Disconnect() end
    if orbit4 then orbit4:Disconnect() end
    if args[1] ~= "nonotify" then notify("Orbit", "Stopped orbiting player") end
end)

addcmd('freeze',{'fr'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x:IsA("BasePart") and not x.Anchored then
						x.Anchored = true
					end
				end
			end)
		end
	end
end)

addcmd('thaw',{'unfreeze','unfr'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x.Name ~= floatName and x:IsA("BasePart") and x.Anchored then
						x.Anchored = false
					end
				end
			end)
		end
	end
end)

oofing = false
addcmd('loopoof',{},function(args, speaker)
	oofing = true
	repeat wait(0.1)
		for i,v in pairs(Players:GetPlayers()) do
			if v.Character ~= nil and v.Character:FindFirstChild'Head' then
				for _,x in pairs(v.Character.Head:GetChildren()) do
					if x:IsA'Sound' then x.Playing = true end
				end
			end
		end
	until oofing == false
end)

addcmd('unloopoof',{},function(args, speaker)
	oofing = false
end)

local notifiedRespectFiltering = false
addcmd('muteboombox',{},function(args, speaker)
	if not notifiedRespectFiltering and SoundService.RespectFilteringEnabled then notifiedRespectFiltering = true notify('RespectFilteringEnabled','RespectFilteringEnabled is set to true (the command will still work but may only be clientsided)') end
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x:IsA("Sound") and x.Playing == true then
						x.Playing = false
					end
				end
				for i, x in next, Players[v]:FindFirstChildOfClass("Backpack"):GetDescendants() do
					if x:IsA("Sound") and x.Playing == true then
						x.Playing = false
					end
				end
			end)
		end
	end
end)

addcmd('unmuteboombox',{},function(args, speaker)
	if not notifiedRespectFiltering and SoundService.RespectFilteringEnabled then notifiedRespectFiltering = true notify('RespectFilteringEnabled','RespectFilteringEnabled is set to true (the command will still work but may only be clientsided)') end
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x:IsA("Sound") and x.Playing == false then
						x.Playing = true
					end
				end
			end)
		end
	end
end)

addcmd("reset", {}, function(args, speaker)
    local humanoid = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
    if replicatesignal then
        replicatesignal(speaker.Kill)
    elseif humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Dead)
    else
        speaker.Character:BreakJoints()
    end
end)

addcmd('freezeanims',{},function(args, speaker)
	local Humanoid = speaker.Character:FindFirstChildOfClass("Humanoid") or speaker.Character:FindFirstChildOfClass("AnimationController")
	local ActiveTracks = Humanoid:GetPlayingAnimationTracks()
	for _, v in pairs(ActiveTracks) do
		v:AdjustSpeed(0)
	end
end)

addcmd('unfreezeanims',{},function(args, speaker)
	local Humanoid = speaker.Character:FindFirstChildOfClass("Humanoid") or speaker.Character:FindFirstChildOfClass("AnimationController")
	local ActiveTracks = Humanoid:GetPlayingAnimationTracks()
	for _, v in pairs(ActiveTracks) do
		v:AdjustSpeed(1)
	end
end)

addcmd("respawn", {}, function(args, speaker)
    respawn(speaker)
end)

addcmd("refresh", {"re"}, function(args, speaker)
    refresh(speaker)
end)

addcmd("god", {}, function(args, speaker)
    permadeath(speaker)
    local Cam = workspace.CurrentCamera
    local Char, Pos = speaker.Character, Cam.CFrame
    local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
    local nHuman = Human:Clone()
    nHuman.Parent = char
    speaker.Character = nil
    nHuman:SetStateEnabled(15, false)
    nHuman:SetStateEnabled(1, false)
    nHuman:SetStateEnabled(0, false)
    nHuman.BreakJointsOnDeath = true
    Human:Destroy()
    speaker.Character = char
    Cam.CameraSubject = nHuman
    Cam.CFrame = task.wait() and pos
    nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    local Script = Char:FindFirstChild("Animate")
    if Script then
        Script.Disabled = true
        task.wait()
        Script.Disabled = false
    end
    nHuman.Health = nHuman.MaxHealth
end)

invisRunning = false
addcmd('invisible',{'invis'},function(args, speaker)
	if invisRunning then return end
	invisRunning = true
	-- Full credit to AmokahFox @V3rmillion
	local Player = speaker
	repeat wait(.1) until Player.Character
	local Character = Player.Character
	Character.Archivable = true
	local IsInvis = false
	local IsRunning = true
	local InvisibleCharacter = Character:Clone()
	InvisibleCharacter.Parent = Lighting
	local Void = workspace.FallenPartsDestroyHeight
	InvisibleCharacter.Name = ""
	local CF

	local invisFix = RunService.Stepped:Connect(function()
		pcall(function()
			local IsInteger
			if tostring(Void):find'-' then
				IsInteger = true
			else
				IsInteger = false
			end
			local Pos = Player.Character.HumanoidRootPart.Position
			local Pos_String = tostring(Pos)
			local Pos_Seperate = Pos_String:split(', ')
			local X = tonumber(Pos_Seperate[1])
			local Y = tonumber(Pos_Seperate[2])
			local Z = tonumber(Pos_Seperate[3])
			if IsInteger == true then
				if Y <= Void then
					Respawn()
				end
			elseif IsInteger == false then
				if Y >= Void then
					Respawn()
				end
			end
		end)
	end)

	for i,v in pairs(InvisibleCharacter:GetDescendants())do
		if v:IsA("BasePart") then
			if v.Name == "HumanoidRootPart" then
				v.Transparency = 1
			else
				v.Transparency = .5
			end
		end
	end

	function Respawn()
		IsRunning = false
		if IsInvis == true then
			pcall(function()
				Player.Character = Character
				wait()
				Character.Parent = workspace
				Character:FindFirstChildWhichIsA'Humanoid':Destroy()
				IsInvis = false
				InvisibleCharacter.Parent = nil
				invisRunning = false
			end)
		elseif IsInvis == false then
			pcall(function()
				Player.Character = Character
				wait()
				Character.Parent = workspace
				Character:FindFirstChildWhichIsA'Humanoid':Destroy()
				TurnVisible()
			end)
		end
	end

	local invisDied
	invisDied = InvisibleCharacter:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
		Respawn()
		invisDied:Disconnect()
	end)

	if IsInvis == true then return end
	IsInvis = true
	CF = workspace.CurrentCamera.CFrame
	local CF_1 = Player.Character.HumanoidRootPart.CFrame
	Character:MoveTo(Vector3.new(0,math.pi*1000000,0))
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	wait(.2)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	InvisibleCharacter = InvisibleCharacter
	Character.Parent = Lighting
	InvisibleCharacter.Parent = workspace
	InvisibleCharacter.HumanoidRootPart.CFrame = CF_1
	Player.Character = InvisibleCharacter
	execCmd('fixcam')
	Player.Character.Animate.Disabled = true
	Player.Character.Animate.Disabled = false

	function TurnVisible()
		if IsInvis == false then return end
		invisFix:Disconnect()
		invisDied:Disconnect()
		CF = workspace.CurrentCamera.CFrame
		Character = Character
		local CF_1 = Player.Character.HumanoidRootPart.CFrame
		Character.HumanoidRootPart.CFrame = CF_1
		InvisibleCharacter:Destroy()
		Player.Character = Character
		Character.Parent = workspace
		IsInvis = false
		Player.Character.Animate.Disabled = true
		Player.Character.Animate.Disabled = false
		invisDied = Character:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
			Respawn()
			invisDied:Disconnect()
		end)
		invisRunning = false
	end
	notify('Invisible','You now appear invisible to other players')
end)

addcmd("visible", {"vis","uninvisible"}, function(args, speaker)
	TurnVisible()
end)

addcmd("toggleinvis", {}, function(args, speaker)
	execCmd(invisRunning and "visible" or "invisible")
end)

end do -- Split Scope 13

addcmd('toolinvisible',{'toolinvis','tinvis'},function(args, speaker)
	local Char  = Players.LocalPlayer.Character
	local touched = false
	local tpdback = false
	local box = Instance.new('Part')
	box.Anchored = true
	box.CanCollide = true
	box.Size = Vector3.new(10,1,10)
	box.Position = Vector3.new(0,10000,0)
	box.Parent = workspace
	local boxTouched = box.Touched:connect(function(part)
		if (part.Parent.Name == Players.LocalPlayer.Name) then
			if touched == false then
				touched = true
				local function apply()
					local no = Char.HumanoidRootPart:Clone()
					wait(.25)
					Char.HumanoidRootPart:Destroy()
					no.Parent = Char
					Char:MoveTo(loc)
					touched = false
				end
				if Char then
					apply()
				end
			end
		end
	end)
	repeat wait() until Char
	local cleanUp
	cleanUp = Players.LocalPlayer.CharacterAdded:connect(function(char)
		boxTouched:Disconnect()
		box:Destroy()
		cleanUp:Disconnect()
	end)
	loc = Char.HumanoidRootPart.Position
	Char:MoveTo(box.Position + Vector3.new(0,.5,0))
end)

addcmd("strengthen", {}, function(args, speaker)
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child.ClassName == "Part" then
			if args[1] then
				child.CustomPhysicalProperties = PhysicalProperties.new(args[1], 0.3, 0.5)
			else
				child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
			end
		end
	end
end)

addcmd("weaken", {}, function(args, speaker)
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child.ClassName == "Part" then
			if args[1] then
				child.CustomPhysicalProperties = PhysicalProperties.new(-args[1], 0.3, 0.5)
			else
				child.CustomPhysicalProperties = PhysicalProperties.new(0, 0.3, 0.5)
			end
		end
	end
end)

addcmd("unweaken", {"unstrengthen"}, function(args, speaker)
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child.ClassName == "Part" then
			child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
		end
	end
end)

addcmd("breakvelocity", {}, function(args, speaker)
	local BeenASecond, V3 = false, Vector3.new(0, 0, 0)
	delay(1, function()
		BeenASecond = true
	end)
	while not BeenASecond do
		for _, v in ipairs(speaker.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Velocity, v.RotVelocity = V3, V3
			end
		end
		wait()
	end
end)

addcmd('jpower',{'jumppower','jp'},function(args, speaker)
	local jpower = args[1] or 50
	if isNumber(jpower) then
		if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = jpower
		else
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight  = jpower
		end
	end
end)

addcmd("maxslopeangle", {"msa"}, function(args, speaker)
	local sangle = args[1] or 89
	if isNumber(sangle) then
		speaker.Character:FindFirstChildWhichIsA("Humanoid").MaxSlopeAngle = sangle
	end
end)

addcmd("gravity", {"grav"}, function(args, speaker)
	local grav = args[1] or oldgrav
	if isNumber(grav) then
		workspace.Gravity = grav
	end
end)

addcmd("hipheight", {"hheight"}, function(args, speaker)
    local hipHeight = args[1] or (r15(speaker) and 2.1 or 0)
    if isNumber(hipHeight) then
        speaker.Character:FindFirstChildWhichIsA("Humanoid").HipHeight = hipHeight
    end
end)

addcmd("dance", {}, function(args, speaker)
	pcall(execCmd, "undance")
	local dances = {"27789359", "30196114", "248263260", "45834924", "33796059", "28488254", "52155728"}
	if r15(speaker) then
		dances = {"3333432454", "4555808220", "4049037604", "4555782893", "10214311282", "10714010337", "10713981723", "10714372526", "10714076981", "10714392151", "11444443576"}
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. dances[math.random(1, #dances)]
	danceTrack = speaker.Character:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(animation)
	danceTrack.Looped = true
	danceTrack:Play()
end)

addcmd("undance", {"nodance"}, function(args, speaker)
	danceTrack:Stop()
	danceTrack:Destroy()
end)

addcmd('nolimbs',{'rlimbs'},function(args, speaker)
	if r15(speaker) then
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "RightUpperLeg" or
				v.Name == "LeftUpperLeg" or
				v.Name == "RightUpperArm" or
				v.Name == "LeftUpperArm" then
				v:Destroy()
			end
		end
	else
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "Right Leg" or
				v.Name == "Left Leg" or
				v.Name == "Right Arm" or
				v.Name == "Left Arm" then
				v:Destroy()
			end
		end
	end
end)

addcmd('noarms',{'rarms'},function(args, speaker)
	if r15(speaker) then
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "RightUpperArm" or
				v.Name == "LeftUpperArm" then
				v:Destroy()
			end
		end
	else
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "Right Arm" or
				v.Name == "Left Arm" then
				v:Destroy()
			end
		end
	end
end)

addcmd('nolegs',{'rlegs'},function(args, speaker)
	if r15(speaker) then
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "RightUpperLeg" or
				v.Name == "LeftUpperLeg" then
				v:Destroy()
			end
		end
	else
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "Right Leg" or
				v.Name == "Left Leg" then
				v:Destroy()
			end
		end
	end
end)

addcmd("sit", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid").Sit = true
end)

addcmd("lay", {"laydown"}, function(args, speaker)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	humanoid.Sit = true
	task.wait(0.1)
	humanoid.RootPart.CFrame = humanoid.RootPart.CFrame * CFrame.Angles(math.pi * 0.5, 0, 0)
	for _, v in ipairs(humanoid:GetPlayingAnimationTracks()) do
		v:Stop()
	end
end)

addcmd("sitwalk", {}, function(args, speaker)
	local anims = speaker.Character.Animate
	local sit = anims.sit:FindFirstChildWhichIsA("Animation").AnimationId
	anims.idle:FindFirstChildWhichIsA("Animation").AnimationId = sit
	anims.walk:FindFirstChildWhichIsA("Animation").AnimationId = sit
	anims.run:FindFirstChildWhichIsA("Animation").AnimationId = sit
	anims.jump:FindFirstChildWhichIsA("Animation").AnimationId = sit
	speaker.Character:FindFirstChildWhichIsA("Humanoid").HipHeight = not r15(speaker) and -1.5 or 0.5
end)

addcmd("nosit", {}, function(args, speaker)
    speaker.Character:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, false)
end)

addcmd("unnosit", {}, function(args, speaker)
    speaker.Character:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, true)
end)

addcmd("jump", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
end)

local infJump
infJumpDebounce = false
addcmd("infjump", {"infinitejump"}, function(args, speaker)
	if infJump then infJump:Disconnect() end
	infJumpDebounce = false
	infJump = UserInputService.JumpRequest:Connect(function()
		if not infJumpDebounce then
			infJumpDebounce = true
			speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
			wait()
			infJumpDebounce = false
		end
	end)
end)

addcmd("uninfjump", {"uninfinitejump", "noinfjump", "noinfinitejump"}, function(args, speaker)
	if infJump then infJump:Disconnect() end
	infJumpDebounce = false
end)

local flyjump
addcmd("flyjump", {}, function(args, speaker)
	if flyjump then flyjump:Disconnect() end
	flyjump = UserInputService.JumpRequest:Connect(function()
		speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
	end)
end)

addcmd("unflyjump", {"noflyjump"}, function(args, speaker)
	if flyjump then flyjump:Disconnect() end
end)

local HumanModCons = {}
addcmd('autojump',{'ajump'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	local function autoJump()
		if Char and Human then
			local check1 = workspace:FindPartOnRay(Ray.new(Human.RootPart.Position-Vector3.new(0,1.5,0), Human.RootPart.CFrame.lookVector*3), Human.Parent)
			local check2 = workspace:FindPartOnRay(Ray.new(Human.RootPart.Position+Vector3.new(0,1.5,0), Human.RootPart.CFrame.lookVector*3), Human.Parent)
			if check1 or check2 then
				Human.Jump = true
			end
		end
	end
	autoJump()
	HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or RunService.RenderStepped:Connect(autoJump)
	HumanModCons.ajCA = (HumanModCons.ajCA and HumanModCons.ajCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
		Char, Human = nChar, nChar:WaitForChild("Humanoid")
		autoJump()
		HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or RunService.RenderStepped:Connect(autoJump)
	end)
end)

addcmd('unautojump',{'noautojump', 'noajump', 'unajump'},function(args, speaker)
	HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or nil
	HumanModCons.ajCA = (HumanModCons.ajCA and HumanModCons.ajCA:Disconnect() and false) or nil
end)

addcmd('edgejump',{'ejump'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	-- Full credit to NoelGamer06 @V3rmillion
	local state
	local laststate
	local lastcf
	local function edgejump()
		if Char and Human then
			laststate = state
			state = Human:GetState()
			if laststate ~= state and state == Enum.HumanoidStateType.Freefall and laststate ~= Enum.HumanoidStateType.Jumping then
				Char.HumanoidRootPart.CFrame = lastcf
				Char.HumanoidRootPart.Velocity = Vector3.new(Char.HumanoidRootPart.Velocity.X, Human.JumpPower or Human.JumpHeight, Char.HumanoidRootPart.Velocity.Z)
			end
			lastcf = Char.HumanoidRootPart.CFrame
		end
	end
	edgejump()
	HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or RunService.RenderStepped:Connect(edgejump)
	HumanModCons.ejCA = (HumanModCons.ejCA and HumanModCons.ejCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
		Char, Human = nChar, nChar:WaitForChild("Humanoid")
		edgejump()
		HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or RunService.RenderStepped:Connect(edgejump)
	end)
end)

addcmd('unedgejump',{'noedgejump', 'noejump', 'unejump'},function(args, speaker)
	HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or nil
	HumanModCons.ejCA = (HumanModCons.ejCA and HumanModCons.ejCA:Disconnect() and false) or nil
end)

addcmd("team", {}, function(args, speaker)
    local teamName = getstring(1)
    local team = nil
    local root = speaker.Character and getRoot(speaker.Character)
    for _, v in ipairs(Teams:GetChildren()) do
        if v.Name:lower():match(teamName:lower()) then
            team = v
            break
        end
    end
    if not team then
        return notify("Invalid Team", teamName .. " is not a valid team")
    end
    if root and firetouchinterest then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("SpawnLocation") and v.BrickColor == team.TeamColor and v.AllowTeamChangeOnTouch == true then
                firetouchinterest(v, root, 0)
                firetouchinterest(v, root, 1)
                break
            end
        end
    else
        speaker.Team = team
    end
end)

addcmd('nobgui',{'unbgui','nobillboardgui','unbillboardgui','noname','rohg'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants())do
		if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
			v:Destroy()
		end
	end
end)

addcmd('loopnobgui',{'loopunbgui','loopnobillboardgui','loopunbillboardgui','loopnoname','looprohg'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants())do
		if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
			v:Destroy()
		end
	end
	local function charPartAdded(part)
		if part:IsA("BillboardGui") or part:IsA("SurfaceGui") then
			wait()
			part:Destroy()
		end
	end
	charPartTrigger = speaker.Character.DescendantAdded:Connect(charPartAdded)
end)

addcmd('unloopnobgui',{'unloopunbgui','unloopnobillboardgui','unloopunbillboardgui','unloopnoname','unlooprohg'},function(args, speaker)
	if charPartTrigger then
		charPartTrigger:Disconnect()
	end
end)

addcmd('spasm',{},function(args, speaker)
	if not r15(speaker) then
		local pchar=speaker.Character
		local AnimationId = "33796059"
		SpasmAnim = Instance.new("Animation")
		SpasmAnim.AnimationId = "rbxassetid://"..AnimationId
		Spasm = pchar:FindFirstChildOfClass('Humanoid'):LoadAnimation(SpasmAnim)
		Spasm:Play()
		Spasm:AdjustSpeed(99)
	else
		notify('R6 Required','This command requires the r6 rig type')
	end
end)

addcmd('unspasm',{'nospasm'},function(args, speaker)
	Spasm:Stop()
	SpasmAnim:Destroy()
end)

addcmd('headthrow',{},function(args, speaker)
	if not r15(speaker) then
		local AnimationId = "35154961"
		local Anim = Instance.new("Animation")
		Anim.AnimationId = "rbxassetid://"..AnimationId
		local k = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(Anim)
		k:Play(0)
		k:AdjustSpeed(1)
	else
		notify('R6 Required','This command requires the r6 rig type')
	end
end)

local function anim2track(asset_id)
    local objs = game:GetObjects(asset_id)
    for i = 1, #objs do
        if objs[i]:IsA("Animation") then
            return objs[i].AnimationId
        end
    end
    return asset_id
end

addcmd("animation", {"anim"}, function(args, speaker)
    local animid = tostring(args[1])
    if not animid:find("rbxassetid://") then
        animid = "rbxassetid://" .. animid
    end
    animid = anim2track(animid)
    local animation = Instance.new("Animation")
    animation.AnimationId = animid
    local anim = speaker.Character:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(animation)
    anim.Priority = Enum.AnimationPriority.Movement
    anim:Play()
    if args[2] then anim:AdjustSpeed(tostring(args[2])) end
end)

addcmd("emote", {"em"}, function(args, speaker)
    local anim = humanoid:PlayEmoteAndGetAnimTrackById(args[1])
    if args[2] then anim:AdjustSpeed(tostring(args[2])) end
end)

end do -- Split Scope 6

addcmd('noanim',{},function(args, speaker)
	speaker.Character.Animate.Disabled = true
end)

addcmd('reanim',{},function(args, speaker)
	speaker.Character.Animate.Disabled = false
end)

addcmd('animspeed',{},function(args, speaker)
	local Char = speaker.Character
	local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

	for i,v in next, Hum:GetPlayingAnimationTracks() do
		v:AdjustSpeed(tonumber(args[1] or 1))
	end
end)

addcmd('copyanimation',{'copyanim','copyemote'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for _,v in ipairs(players)do
		local char = Players[v].Character
		for _, v1 in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetPlayingAnimationTracks()) do
			v1:Stop()
		end
		for _, v1 in pairs(Players[v].Character:FindFirstChildOfClass('Humanoid'):GetPlayingAnimationTracks()) do
			if not string.find(v1.Animation.AnimationId, "507768375") then
				local ANIM = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(v1.Animation)
				ANIM:Play(.1, 1, v1.Speed)
				ANIM.TimePosition = v1.TimePosition
				task.spawn(function()
					v1.Stopped:Wait()
					ANIM:Stop()
					ANIM:Destroy()
				end)
			end
		end
	end
end)

addcmd("copyanimationid", {"copyanimid", "copyemoteid"}, function(args, speaker)
    local copyAnimId = function(player)
        local found = "Animations Copied"

        for _, v in pairs(player.Character:FindFirstChildWhichIsA("Humanoid"):GetPlayingAnimationTracks()) do
            local animationId = v.Animation.AnimationId
            local assetId = animationId:find("rbxassetid://") and animationId:match("%d+")

            if not string.find(animationId, "507768375") and not string.find(animationId, "180435571") then
                if assetId then
                    local success, result = pcall(function()
                        return MarketplaceService:GetProductInfo(tonumber(assetId)).Name
                    end)
                    local name = success and result or "Failed to get name"
                    found = found .. "\n\nName: " .. name .. "\nAnimation Id: " .. animationId
                else
                    found = found .. "\n\nAnimation Id: " .. animationId
                end
            end
        end

        if found ~= "Animations Copied" then
            toClipboard(found)
        else
            notify("Animations", "No animations to copy")
        end
    end

    if args[1] then
        copyAnimId(Players[getPlayer(args[1], speaker)[1]])
    else
        copyAnimId(speaker)
    end
end)

addcmd('stopanimations',{'stopanims','stopanim'},function(args, speaker)
	local Char = speaker.Character
	local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

	for i,v in next, Hum:GetPlayingAnimationTracks() do
		v:Stop()
	end
end)

addcmd('refreshanimations', {'refreshanimation', 'refreshanims', 'refreshanim'}, function(args, speaker)
	local Char = speaker.Character or speaker.CharacterAdded:Wait()
	local Human = Char and Char:WaitForChild('Humanoid', 15)
	local Animate = Char and Char:WaitForChild('Animate', 15)
	if not Human or not Animate then
		return notify('Refresh Animations', 'Failed to get Animate/Humanoid')
	end
	Animate.Disabled = true
	for _, v in ipairs(Human:GetPlayingAnimationTracks()) do
		v:Stop()
	end
	Animate.Disabled = false
end)

addcmd('allowcustomanim', {'allowcustomanimations'}, function(args, speaker)
	StarterPlayer.AllowCustomAnimations = true
	execCmd('refreshanimations')
end)

addcmd('unallowcustomanim', {'unallowcustomanimations'}, function(args, speaker)
	StarterPlayer.AllowCustomAnimations = false
	execCmd('refreshanimations')
end)

addcmd('loopanimation', {'loopanim'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char.FindFirstChildWhichIsA(Char, "Humanoid")
	for _, v in ipairs(Human.GetPlayingAnimationTracks(Human)) do
		v.Looped = true
	end
end)

addcmd('tpposition',{'tppos'},function(args, speaker)
	if #args < 3 then return end
	local tpX,tpY,tpZ = tonumber((args[1]:gsub(",", ""))),tonumber((args[2]:gsub(",", ""))),tonumber((args[3]:gsub(",", "")))
	local char = speaker.Character
	if char and getRoot(char) then
		getRoot(char).CFrame = CFrame.new(tpX,tpY,tpZ)
	end
end)

addcmd('tweentpposition',{'ttppos'},function(args, speaker)
	if #args < 3 then return end
	local tpX,tpY,tpZ = tonumber((args[1]:gsub(",", ""))),tonumber((args[2]:gsub(",", ""))),tonumber((args[3]:gsub(",", "")))
	local char = speaker.Character
	if char and getRoot(char) then
		TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(tpX,tpY,tpZ)}):Play()
	end
end)

addcmd('offset',{},function(args, speaker)
	if #args < 3 then
		return 
	end
	if speaker.Character then
		speaker.Character:TranslateBy(Vector3.new(tonumber(args[1]) or 0, tonumber(args[2]) or 0, tonumber(args[3]) or 0))
	end
end)

addcmd('tweenoffset',{'toffset'},function(args, speaker)
	if #args < 3 then return end
	local tpX,tpY,tpZ = tonumber(args[1]),tonumber(args[2]),tonumber(args[3])
	local char = speaker.Character
	if char and getRoot(char) then
		TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(tpX,tpY,tpZ)}):Play()
	end
end)

addcmd('clickteleport',{},function(args, speaker)
	if speaker == Players.LocalPlayer then
		notify('Click TP','Go to Settings > Keybinds > Add to set up click teleport')
	end
end)

addcmd("mouseteleport", {"mousetp"}, function(args, speaker)
    local root = getRoot(speaker.Character)
    local pos = IYMouse.Hit
    if root and pos then
        root.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z, select(4, root.CFrame:components()))
    end
end)

addcmd('tptool', {'teleporttool'}, function(args, speaker)
	local TpTool = Instance.new("Tool")
	TpTool.Name = "Teleport Tool"
	TpTool.RequiresHandle = false
	TpTool.Parent = speaker.Backpack
	TpTool.Activated:Connect(function()
		local Char = speaker.Character or workspace:FindFirstChild(speaker.Name)
		local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
		if not Char or not HRP then
			return warn("Failed to find HumanoidRootPart")
		end
		HRP.CFrame = CFrame.new(IYMouse.Hit.X, IYMouse.Hit.Y + 3, IYMouse.Hit.Z, select(4, HRP.CFrame:components()))
	end)
end)

addcmd('clickdelete',{},function(args, speaker)
	if speaker == Players.LocalPlayer then
		notify('Click Delete','Go to Settings > Keybinds > Add to set up click delete')
	end
end)

addcmd('getposition',{'getpos','notifypos','notifyposition'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		local char = Players[v].Character
		local pos = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
		pos = pos and pos.Position
		if not pos then
			return notify('Getposition Error','Missing character')
		end
		local roundedPos = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
		notify('Current Position',roundedPos)
	end
end)

addcmd('copyposition',{'copypos'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		local char = Players[v].Character
		local pos = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
		pos = pos and pos.Position
		if not pos then
			return notify('Getposition Error','Missing character')
		end
		local roundedPos = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
		toClipboard(roundedPos)
	end
end)

addcmd('walktopos',{'walktoposition'},function(args, speaker)
	if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
		speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
		wait(.1)
	end
	speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(args[1],args[2],args[3])
end)

addcmd('speed',{'ws','walkspeed'},function(args, speaker)
	if args[2] then
		local speed = args[2] or 16
		if isNumber(speed) then
			speaker.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = speed
		end
	else
		local speed = args[1] or 16
		if isNumber(speed) then
			speaker.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = speed
		end
	end
end)

addcmd('spoofspeed',{'spoofws','spoofwalkspeed'},function(args, speaker)
	if args[1] and isNumber(args[1]) then
		if hookmetamethod then
			local char = speaker.Character
			local setspeed;
			local index; index = hookmetamethod(game, "__index", function(self, key)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "WalkSpeed" or key == "walkSpeed") and self:IsDescendantOf(char) then
					return setspeed or args[1]
				end
				return index(self, key)
			end)
			local newindex; newindex = hookmetamethod(game, "__newindex", function(self, key, value)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "WalkSpeed" or key == "walkSpeed") and self:IsDescendantOf(char) then
					setspeed = tonumber(value)
				end
				return newindex(self, key, value)
			end)
		else
			notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
		end
	end
end)

addcmd('loopspeed',{'loopws'},function(args, speaker)
	local speed = args[1] or 16
	if args[2] then
		speed = args[2] or 16
	end
	if isNumber(speed) then
		local Char = speaker.Character or workspace:FindFirstChild(speaker.Name)
		local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
		local function WalkSpeedChange()
			if Char and Human then
				Human.WalkSpeed = speed
			end
		end
		WalkSpeedChange()
		HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
		HumanModCons.wsCA = (HumanModCons.wsCA and HumanModCons.wsCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
			Char, Human = nChar, nChar:WaitForChild("Humanoid")
			WalkSpeedChange()
			HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
		end)
	end
end)

addcmd('unloopspeed',{'unloopws'},function(args, speaker)
	HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or nil
	HumanModCons.wsCA = (HumanModCons.wsCA and HumanModCons.wsCA:Disconnect() and false) or nil
end)

addcmd('spoofjumppower',{'spoofjp'},function(args, speaker)
	if args[1] and isNumber(args[1]) then
		if hookmetamethod then
			local char = speaker.Character
			local setpower;
			local index; index = hookmetamethod(game, "__index", function(self, key)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "JumpPower" or key == "jumpPower") and self:IsDescendantOf(char) then
					return setpower or args[1]
				end
				return index(self, key)
			end)
			local newindex; newindex = hookmetamethod(game, "__newindex", function(self, key, value)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "JumpPower" or key == "jumpPower") and self:IsDescendantOf(char) then
					setpower = tonumber(value)
				end
				return newindex(self, key, value)
			end)
		else
			notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
		end
	end
end)

addcmd('loopjumppower',{'loopjp','loopjpower'},function(args, speaker)
	local jpower = args[1] or 50
	if isNumber(jpower) then
		local Char = speaker.Character or workspace:FindFirstChild(speaker.Name)
		local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
		local function JumpPowerChange()
			if Char and Human then
				if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
					speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = jpower
				else
					speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight  = jpower
				end
			end
		end
		JumpPowerChange()
		HumanModCons.jpLoop = (HumanModCons.jpLoop and HumanModCons.jpLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("JumpPower"):Connect(JumpPowerChange)
		HumanModCons.jpCA = (HumanModCons.jpCA and HumanModCons.jpCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
			Char, Human = nChar, nChar:WaitForChild("Humanoid")
			JumpPowerChange()
			HumanModCons.jpLoop = (HumanModCons.jpLoop and HumanModCons.jpLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("JumpPower"):Connect(JumpPowerChange)
		end)
	end
end)

addcmd('unloopjumppower',{'unloopjp','unloopjpower'},function(args, speaker)
	local Char = speaker.Character or workspace:FindFirstChild(speaker.Name)
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	HumanModCons.jpLoop = (HumanModCons.jpLoop and HumanModCons.jpLoop:Disconnect() and false) or nil
	HumanModCons.jpCA = (HumanModCons.jpCA and HumanModCons.jpCA:Disconnect() and false) or nil
	if Char and Human then
		if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = 50
		else
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight  = 50
		end
	end
end)

addcmd('tools',{'gears'},function(args, speaker)
	local function copy(instance)
		for i,c in pairs(instance:GetChildren())do
			if c:IsA('Tool') or c:IsA('HopperBin') then
				c:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
			end
			copy(c)
		end
	end
	copy(Lighting)
	local function copy(instance)
		for i,c in pairs(instance:GetChildren())do
			if c:IsA('Tool') or c:IsA('HopperBin') then
				c:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
			end
			copy(c)
		end
	end
	copy(ReplicatedStorage)
	notify('Tools','Copied tools from ReplicatedStorage and Lighting')
end)

addcmd('notools',{'rtools','clrtools','removetools','deletetools','dtools'},function(args, speaker)
	for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
end)

addcmd('deleteselectedtool',{'dst'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
end)

addcmd("console", {}, function(args, speaker)
    StarterGui:SetCore("DevConsoleVisible", true)
end)

addcmd('oldconsole',{},function(args, speaker)
	
	notify("Loading",'Hold on a sec')
	local _, str = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/console.lua", true)
	end)

	local s, e = loadstring(str)
	if typeof(s) ~= "function" then
		return
	end

	local success, message = pcall(s)
	if (not success) then
		if printconsole then
			printconsole(message)
		elseif printoutput then
			printoutput(message)
		end
	end
	wait(1)
	notify('Console','Press F9 to open the console')
end)

addcmd("explorer", {"dex"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)

addcmd('olddex', {'odex'}, function(args, speaker)
	notify('Loading old explorer', 'Hold on a sec')

	local getobjects = function(a)
		local Objects = {}
		if a then
			local b = InsertService:LoadLocalAsset(a)
			if b then 
				table.insert(Objects, b) 
			end
		end
		return Objects
	end

	local Dex = getobjects("rbxassetid://10055842438")[1]
	Dex.Parent = PARENT

	local function Load(Obj, Url)
		local function GiveOwnGlobals(Func, Script)
			
			local Fenv, RealFenv, FenvMt = {}, {
				script = Script,
				getupvalue = function(a, b)
					return nil -- force it to use globals
				end,
				getreg = function() -- It loops registry for some idiotic reason so stop it from doing that and just use a global
					return {} -- force it to use globals
				end,
				getprops = getprops or function(inst)
					if getproperties then
						local props = getproperties(inst)
						if props[1] and gethiddenproperty then
							local results = {}
							for _,name in pairs(props) do
								local success, res = pcall(gethiddenproperty, inst, name)
								if success then
									results[name] = res
								end
							end

							return results
						end

						return props
					end

					return {}
				end
			}, {}
			FenvMt.__index = function(a,b)
				return RealFenv[b] == nil and getgenv()[b] or RealFenv[b]
			end
			FenvMt.__newindex = function(a, b, c)
				if RealFenv[b] == nil then 
					getgenv()[b] = c 
				else 
					RealFenv[b] = c 
				end
			end
			setmetatable(Fenv, FenvMt)
			pcall(setfenv, Func, Fenv)
			return Func
		end

		local function LoadScripts(_, Script)
			if Script:IsA("LocalScript") then
				task.spawn(function()
					GiveOwnGlobals(loadstring(Script.Source,"="..Script:GetFullName()), Script)()
				end)
			end
			table.foreach(Script:GetChildren(), LoadScripts)
		end

		LoadScripts(nil, Obj)
	end

	Load(Dex)
end)

end do -- Split Scope 14

addcmd('remotespy',{'rspy'},function(args, speaker)
	notify("Loading",'Hold on a sec')
	
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
end)

addcmd('audiologger',{'alogger'},function(args, speaker)
	notify("Loading",'Hold on a sec')
	loadstring(game:HttpGet(('https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua'),true))()
end)

local loopgoto = nil
addcmd('loopgoto',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		loopgoto = nil
		if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
			speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
			wait(.1)
		end
		loopgoto = Players[v]
		local distance = 3
		if args[2] and isNumber(args[2]) then
			distance = args[2]
		end
		local lDelay = 0
		if args[3] and isNumber(args[3]) then
			lDelay = args[3]
		end
		repeat
			if Players:FindFirstChild(v) then
				if Players[v].Character ~= nil then
					getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(distance,1,0)
				end
				wait(lDelay)
			else
				loopgoto = nil
			end
		until loopgoto ~= Players[v]
	end
end)

addcmd('unloopgoto',{'noloopgoto'},function(args, speaker)
	loopgoto = nil
end)

addcmd('headsit',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if headSit then headSit:Disconnect() end
	for i,v in pairs(players)do
		speaker.Character:FindFirstChildOfClass('Humanoid').Sit = true
		headSit = RunService.Heartbeat:Connect(function()
			if Players:FindFirstChild(Players[v].Name) and Players[v].Character ~= nil and getRoot(Players[v].Character) and getRoot(speaker.Character) and speaker.Character:FindFirstChildOfClass('Humanoid').Sit == true then
				getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame * CFrame.Angles(0,math.rad(0),0)* CFrame.new(0,1.6,0.4)
			else
				headSit:Disconnect()
			end
		end)
	end
end)

addcmd('chat',{'say'},function(args, speaker)
	local cString = getstring(1)
	chatMessage(cString)
end)

spamming = false
spamspeed = 1
addcmd('spam',{},function(args, speaker)
	spamming = true
	local spamstring = getstring(1)
	repeat wait(spamspeed)
		chatMessage(spamstring)
	until spamming == false
end)

addcmd('nospam',{'unspam'},function(args, speaker)
	spamming = false
end)

addcmd('whisper',{'pm'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			local plrName = Players[v].Name
			local pmstring = getstring(2)
			chatMessage("/w "..plrName.." "..pmstring)
		end)
	end
end)

pmspamming = {}
addcmd('pmspam',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			local plrName = Players[v].Name
			if FindInTable(pmspamming, plrName) then return end
			table.insert(pmspamming, plrName)
			local pmspamstring = getstring(2)
			repeat
				if Players:FindFirstChild(v) then
					wait(spamspeed)
					chatMessage("/w "..plrName.." "..pmspamstring)
				else
					for a,b in pairs(pmspamming) do if b == plrName then table.remove(pmspamming, a) end end
				end
			until not FindInTable(pmspamming, plrName)
		end)
	end
end)

addcmd('nopmspam',{'unpmspam'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			for a,b in pairs(pmspamming) do
				if b == Players[v].Name then
					table.remove(pmspamming, a)
				end
			end
		end)
	end
end)

addcmd('spamspeed',{},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		spamspeed = speed
	end
end)

addcmd('bubblechat',{},function(args, speaker)
	if isLegacyChat then
		ChatService.BubbleChatEnabled = true
	else
		TextChatService.BubbleChatConfiguration.Enabled = true
	end
end)

addcmd('unbubblechat',{'nobubblechat'},function(args, speaker)
	if isLegacyChat then
		ChatService.BubbleChatEnabled = false
	else
		TextChatService.BubbleChatConfiguration.Enabled = false
	end
end)

addcmd("chatwindow", {}, function(args, speaker)
    TextChatService.ChatWindowConfiguration.Enabled = true
end)

addcmd("unchatwindow", {"nochatwindow"}, function(args, speaker)
    TextChatService.ChatWindowConfiguration.Enabled = false
end)

addcmd('blockhead',{},function(args, speaker)
	speaker.Character.Head:FindFirstChildOfClass("SpecialMesh"):Destroy()
end)

addcmd('blockhats',{},function(args, speaker)
	for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
		for i,c in pairs(v:GetDescendants()) do
			if c:IsA("SpecialMesh") then
				c:Destroy()
			end
		end
	end
end)

addcmd('blocktool',{},function(args, speaker)
	for _,v in pairs(speaker.Character:GetChildren()) do
		if v:IsA("Tool") or v:IsA("HopperBin") then
			for i,c in pairs(v:GetDescendants()) do
				if c:IsA("SpecialMesh") then
					c:Destroy()
				end
			end
		end
	end
end)

addcmd('creeper',{},function(args, speaker)
	if r15(speaker) then
		speaker.Character.Head:FindFirstChildOfClass("SpecialMesh"):Destroy()
		speaker.Character.LeftUpperArm:Destroy()
		speaker.Character.RightUpperArm:Destroy()
		speaker.Character:FindFirstChildOfClass("Humanoid"):RemoveAccessories()
	else
		speaker.Character.Head:FindFirstChildOfClass("SpecialMesh"):Destroy()
		speaker.Character["Left Arm"]:Destroy()
		speaker.Character["Right Arm"]:Destroy()
		speaker.Character:FindFirstChildOfClass("Humanoid"):RemoveAccessories()
	end
end)

function getTorso(x)
	x = x or Players.LocalPlayer.Character
	return x:FindFirstChild("Torso") or x:FindFirstChild("UpperTorso") or x:FindFirstChild("LowerTorso") or x:FindFirstChild("HumanoidRootPart")
end

addcmd("bang", {"rape"}, function(args, speaker)
	execCmd("unbang")
	wait()
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	bangAnim = Instance.new("Animation")
	bangAnim.AnimationId = not r15(speaker) and "rbxassetid://148840371" or "rbxassetid://5918726674"
	bang = humanoid:LoadAnimation(bangAnim)
	bang:Play(0.1, 1, 1)
	bang:AdjustSpeed(args[2] or 3)
	bangDied = humanoid.Died:Connect(function()
		bang:Stop()
		bangAnim:Destroy()
		bangDied:Disconnect()
		bangLoop:Disconnect()
	end)
	if args[1] then
		local players = getPlayer(args[1], speaker)
		for _, v in pairs(players) do
			local bangplr = Players[v].Name
			local bangOffet = CFrame.new(0, 0, 1.1)
			bangLoop = RunService.Stepped:Connect(function()
				pcall(function()
					local otherRoot = getTorso(Players[bangplr].Character)
					getRoot(speaker.Character).CFrame = otherRoot.CFrame * bangOffet
				end)
			end)
		end
	end
end)

addcmd("unbang", {"unrape"}, function(args, speaker)
	if bangDied then
		bangDied:Disconnect()
		bang:Stop()
		bangAnim:Destroy()
		bangLoop:Disconnect()
	end
end)

addcmd('carpet',{},function(args, speaker)
	if not r15(speaker) then
		execCmd('uncarpet')
		wait()
		local players = getPlayer(args[1], speaker)
		for i,v in pairs(players)do
			carpetAnim = Instance.new("Animation")
			carpetAnim.AnimationId = "rbxassetid://282574440"
			carpet = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(carpetAnim)
			carpet:Play(.1, 1, 1)
			local carpetplr = Players[v].Name
			carpetDied = speaker.Character:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
				carpetLoop:Disconnect()
				carpet:Stop()
				carpetAnim:Destroy()
				carpetDied:Disconnect()
			end)
			carpetLoop = RunService.Heartbeat:Connect(function()
				pcall(function()
					getRoot(Players.LocalPlayer.Character).CFrame = getRoot(Players[carpetplr].Character).CFrame
				end)
			end)
		end
	else
		notify('R6 Required','This command requires the r6 rig type')
	end
end)

addcmd('uncarpet',{'nocarpet'},function(args, speaker)
	if carpetLoop then
		carpetLoop:Disconnect()
		carpetDied:Disconnect()
		carpet:Stop()
		carpetAnim:Destroy()
	end
end)

addcmd('friend',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		speaker:RequestFriendship(Players[v])
	end
end)

addcmd('unfriend',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		speaker:RevokeFriendship(Players[v])
	end
end)

addcmd('bringpart',{},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1):lower() and v:IsA("BasePart") then
			v.CFrame = getRoot(speaker.Character).CFrame
		end
	end
end)

addcmd('bringpartclass',{'bpc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1):lower() and v:IsA("BasePart") then
			v.CFrame = getRoot(speaker.Character).CFrame
		end
	end
end)

gotopartDelay = 0.1
addcmd('gotopart',{'topart'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			getRoot(speaker.Character).CFrame = v.CFrame
		end
	end
end)

addcmd('tweengotopart',{'tgotopart','ttopart'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = v.CFrame}):Play()
		end
	end
end)

addcmd('gotopartclass',{'gpc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			getRoot(speaker.Character).CFrame = v.CFrame
		end
	end
end)

addcmd('tweengotopartclass',{'tgpc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = v.CFrame}):Play()
		end
	end
end)

addcmd('gotomodel',{'tomodel'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1):lower() and v:IsA("Model") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			getRoot(speaker.Character).CFrame = v:GetModelCFrame()
		end
	end
end)

addcmd('tweengotomodel',{'tgotomodel','ttomodel'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1):lower() and v:IsA("Model") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = v:GetModelCFrame()}):Play()
		end
	end
end)

addcmd('gotopartdelay',{},function(args, speaker)
	local gtpDelay = args[1] or 0.1
	if isNumber(gtpDelay) then
		gotopartDelay = gtpDelay
	end
end)

addcmd('noclickdetectorlimits',{'nocdlimits','removecdlimits'},function(args, speaker)
	for i,v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ClickDetector") then
			v.MaxActivationDistance = math.huge
		end
	end
end)

addcmd('fireclickdetectors',{'firecd','firecds'}, function(args, speaker)
	if fireclickdetector then
		if args[1] then
			local name = getstring(1)
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ClickDetector") and descendant.Name == name or descendant.Parent.Name == name then
					fireclickdetector(descendant)
				end
			end
		else
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ClickDetector") then
					fireclickdetector(descendant)
				end
			end
		end
	else
		notify("Incompatible Exploit", "Your exploit does not support this command (missing fireclickdetector)")
	end
end)

addcmd('noproximitypromptlimits',{'nopplimits','removepplimits'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			v.MaxActivationDistance = math.huge
		end
	end
end)

addcmd('fireproximityprompts',{'firepp'},function(args, speaker)
	if fireproximityprompt then
		if args[1] then
			local name = getstring(1)
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ProximityPrompt") and descendant.Name == name or descendant.Parent.Name == name then
					fireproximityprompt(descendant)
				end
			end
		else
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ProximityPrompt") then
					fireproximityprompt(descendant)
				end
			end
		end
	else
		notify("Incompatible Exploit", "Your exploit does not support this command (missing fireproximityprompt)")
	end
end)

local PromptButtonHoldBegan = nil
addcmd('instantproximityprompts',{'instantpp'},function(args, speaker)
	if fireproximityprompt then
		execCmd("uninstantproximityprompts")
		wait(0.1)
		PromptButtonHoldBegan = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
			fireproximityprompt(prompt)
		end)
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing fireproximityprompt)')
	end
end)

addcmd('uninstantproximityprompts',{'uninstantpp'},function(args, speaker)
	if PromptButtonHoldBegan ~= nil then
		PromptButtonHoldBegan:Disconnect()
		PromptButtonHoldBegan = nil
	end
end)

addcmd('notifyping',{'ping'},function(args, speaker)
	notify("Ping", math.round(speaker:GetNetworkPing() * 1000) .. "ms")
end)

addcmd('grabtools', {}, function(args, speaker)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	for _, child in ipairs(workspace:GetChildren()) do
		if speaker.Character and child:IsA("BackpackItem") and child:FindFirstChild("Handle") then
			humanoid:EquipTool(child)
		end
	end

	if grabtoolsFunc then 
		grabtoolsFunc:Disconnect() 
	end

	grabtoolsFunc = workspace.ChildAdded:Connect(function(child)
		if speaker.Character and child:IsA("BackpackItem") and child:FindFirstChild("Handle") then
			humanoid:EquipTool(child)
		end
	end)

	notify("Grabtools", "Picking up any dropped tools")
end)

end do -- Split Scope 7

addcmd('nograbtools',{'ungrabtools'},function(args, speaker)
	if grabtoolsFunc then 
		grabtoolsFunc:Disconnect() 
	end

	notify("Grabtools", "Grabtools has been disabled")
end)

local specifictoolremoval = {}
addcmd('removespecifictool',{},function(args, speaker)
	if args[1] and speaker:FindFirstChildOfClass("Backpack") then
		local tool = string.lower(getstring(1))
		local RST = RunService.RenderStepped:Connect(function()
			if speaker:FindFirstChildOfClass("Backpack") then
				for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
					if v.Name:lower() == tool then
						v:Remove()
					end
				end
			end
		end)
		specifictoolremoval[tool] = RST
	end
end)

addcmd('unremovespecifictool',{},function(args, speaker)
	if args[1] then
		local tool = string.lower(getstring(1))
		if specifictoolremoval[tool] ~= nil then
			specifictoolremoval[tool]:Disconnect()
			specifictoolremoval[tool] = nil
		end
	end
end)

addcmd('clearremovespecifictool',{},function(args, speaker)
	for obj in pairs(specifictoolremoval) do
		specifictoolremoval[obj]:Disconnect()
		specifictoolremoval[obj] = nil
	end
end)

addcmd('light',{},function(args, speaker)
	local light = Instance.new("PointLight")
	light.Parent = getRoot(speaker.Character)
	light.Range = 30
	if args[1] then
		light.Brightness = args[2]
		light.Range = args[1]
	else
		light.Brightness = 5
	end
end)

addcmd('unlight',{'nolight'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.ClassName == "PointLight" then
			v:Destroy()
		end
	end
end)

addcmd('copytools',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			for i,v in pairs(Players[v]:FindFirstChildOfClass("Backpack"):GetChildren()) do
				if v:IsA('Tool') or v:IsA('HopperBin') then
					v:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
				end
			end
		end)
	end
end)

addcmd('naked',{},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Clothing") or v:IsA("ShirtGraphic") then
			v:Destroy()
		end
	end
end)

addcmd('noface',{'removeface'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Decal") and v.Name == 'face' then
			v:Destroy()
		end
	end
end)

addcmd('spawnpoint',{'spawn'},function(args, speaker)
	spawnpos = getRoot(speaker.Character).CFrame
	spawnpoint = true
	spDelay = tonumber(args[1]) or 0.1
	notify('Spawn Point','Spawn point created at '..tostring(spawnpos))
end)

addcmd('nospawnpoint',{'nospawn','removespawnpoint'},function(args, speaker)
	spawnpoint = false
	notify('Spawn Point','Removed spawn point')
end)

addcmd('flashback',{'diedtp'},function(args, speaker)
	if lastDeath ~= nil then
		if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
			speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
			wait(.1)
		end
		getRoot(speaker.Character).CFrame = lastDeath
	end
end)

addcmd('hatspin',{'spinhats'},function(args, speaker)
	execCmd('unhatspin')
	wait(.5)
	for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
		local keep = Instance.new("BodyPosition") keep.Name = randomString() keep.Parent = v.Handle
		local spin = Instance.new("BodyAngularVelocity") spin.Name = randomString() spin.Parent = v.Handle
		v.Handle:FindFirstChildOfClass("Weld"):Destroy()
		if args[1] then
			spin.AngularVelocity = Vector3.new(0, args[1], 0)
			spin.MaxTorque = Vector3.new(0, args[1] * 2, 0)
		else
			spin.AngularVelocity = Vector3.new(0, 100, 0)
			spin.MaxTorque = Vector3.new(0, 200, 0)
		end
		keep.P = 30000
		keep.D = 50
		spinhats = RunService.Stepped:Connect(function()
			pcall(function()
				keep.Position = Players.LocalPlayer.Character.Head.Position
			end)
		end)
	end
end)

addcmd('unhatspin',{'unspinhats'},function(args, speaker)
	if spinhats then
		spinhats:Disconnect()
	end
	for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
		v.Parent = workspace
		for i,c in pairs(v.Handle) do
			if c:IsA("BodyPosition") or c:IsA("BodyAngularVelocity") then
				c:Destroy()
			end
		end
		wait()
		v.Parent = speaker.Character
	end
end)

addcmd('clearhats',{'cleanhats'},function(args, speaker)
	if firetouchinterest then
		local Player = Players.LocalPlayer
		local Character = Player.Character
		local Old = Character:FindFirstChild("HumanoidRootPart").CFrame
		local Hats = {}

		for _, child in ipairs(workspace:GetChildren()) do
			if child:IsA("Accessory") then
				table.insert(Hats, child)
			end
		end

		for _, accessory in ipairs(Character:FindFirstChildOfClass("Humanoid"):GetAccessories()) do
			accessory:Destroy()
		end

		for i = 1, #Hats do
			repeat RunService.Heartbeat:wait() until Hats[i]
			firetouchinterest(Hats[i].Handle,Character:FindFirstChild("HumanoidRootPart"),0)
			repeat RunService.Heartbeat:wait() until Character:FindFirstChildOfClass("Accessory")
			Character:FindFirstChildOfClass("Accessory"):Destroy()
			repeat RunService.Heartbeat:wait() until not Character:FindFirstChildOfClass("Accessory")
		end

		execCmd("reset")

		Player.CharacterAdded:Wait()

		for i = 1,20 do 
			RunService.Heartbeat:Wait()
			if Player.Character:FindFirstChild("HumanoidRootPart") then
				Player.Character:FindFirstChild("HumanoidRootPart").CFrame = Old
			end
		end
	else
		notify("Incompatible Exploit","Your exploit does not support this command (missing firetouchinterest)")
	end
end)

addcmd('split',{},function(args, speaker)
	if r15(speaker) then
		speaker.Character.UpperTorso.Waist:Destroy()
	else
		notify('R15 Required','This command requires the r15 rig type')
	end
end)

addcmd('nilchar',{},function(args, speaker)
	if speaker.Character ~= nil then
		speaker.Character.Parent = nil
	end
end)

addcmd('unnilchar',{'nonilchar'},function(args, speaker)
	if speaker.Character ~= nil then
		speaker.Character.Parent = workspace
	end
end)

addcmd('noroot',{'removeroot','rroot'},function(args, speaker)
	if speaker.Character ~= nil then
		local char = Players.LocalPlayer.Character
		char.Parent = nil
		char.HumanoidRootPart:Destroy()
		char.Parent = workspace
	end
end)

addcmd('replaceroot',{'replacerootpart'},function(args, speaker)
	if speaker.Character ~= nil and speaker.Character:FindFirstChild("HumanoidRootPart") then
		local Char = speaker.Character
		local OldParent = Char.Parent
		local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
		local OldPos = HRP.CFrame
		Char.Parent = game
		local HRP1 = HRP:Clone()
		HRP1.Parent = Char
		HRP = HRP:Destroy()
		HRP1.CFrame = OldPos
		Char.Parent = OldParent
	end
end)

addcmd('clearcharappearance',{'clearchar','clrchar'},function(args, speaker)
	speaker:ClearCharacterAppearance()
end)

addcmd('equiptools',{},function(args, speaker)
	for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
		if v:IsA("Tool") or v:IsA("HopperBin") then
			v.Parent = speaker.Character
		end
	end
end)

addcmd('unequiptools',{},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
end)

local function GetHandleTools(p)
	p = p or Players.LocalPlayer
	local r = {}
	for _, v in ipairs(p.Character and p.Character:GetChildren() or {}) do
		if v.IsA(v, "BackpackItem") and v.FindFirstChild(v, "Handle") then
			r[#r + 1] = v
		end
	end
	for _, v in ipairs(p.Backpack:GetChildren()) do
		if v.IsA(v, "BackpackItem") and v.FindFirstChild(v, "Handle") then
			r[#r + 1] = v
		end
	end
	return r
end
addcmd('dupetools', {'clonetools'}, function(args, speaker)
	local LOOP_NUM = tonumber(args[1]) or 1
	local OrigPos = speaker.Character.HumanoidRootPart.Position
	local Tools, TempPos = {}, Vector3.new(math.random(-2e5, 2e5), 2e5, math.random(-2e5, 2e5))
	for i = 1, LOOP_NUM do
		local Human = speaker.Character:WaitForChild("Humanoid")
		wait(.1, Human.Parent:MoveTo(TempPos))
		Human.RootPart.Anchored = speaker:ClearCharacterAppearance(wait(.1)) or true
		local t = GetHandleTools(speaker)
		while #t > 0 do
			for _, v in ipairs(t) do
				task.spawn(function()
					for _ = 1, 25 do
						v.Parent = speaker.Character
						v.Handle.Anchored = true
					end
					for _ = 1, 5 do
						v.Parent = workspace
					end
					table.insert(Tools, v.Handle)
				end)
			end
			t = GetHandleTools(speaker)
		end
		wait(.1)
		speaker.Character = speaker.Character:Destroy()
		speaker.CharacterAdded:Wait():WaitForChild("Humanoid").Parent:MoveTo(LOOP_NUM == i and OrigPos or TempPos, wait(.1))
		if i == LOOP_NUM or i % 5 == 0 then
			local HRP = speaker.Character.HumanoidRootPart
			if type(firetouchinterest) == "function" then
				for _, v in ipairs(Tools) do
					v.Anchored = not firetouchinterest(v, HRP, 1, firetouchinterest(v, HRP, 0)) and false or false
				end
			else
				for _, v in ipairs(Tools) do
					task.spawn(function()
						local x = v.CanCollide
						v.CanCollide = false
						v.Anchored = false
						for _ = 1, 10 do
							v.CFrame = HRP.CFrame
							wait()
						end
						v.CanCollide = x
					end)
				end
			end
			wait(.1)
			Tools = {}
		end
		TempPos = TempPos + Vector3.new(10, math.random(-5, 5), 0)
	end
end)

local RS = RunService.RenderStepped

addcmd('touchinterests', {'touchinterest', 'firetouchinterests', 'firetouchinterest'}, function(args, speaker)
	if not firetouchinterest then
		notify("Incompatible Exploit", "Your exploit does not support this command (missing firetouchinterest)")
		return
	end

	local root = getRoot(speaker.Character) or speaker.Character:FindFirstChildWhichIsA("BasePart")

	local function touch(x)
		x = x:FindFirstAncestorWhichIsA("Part")
		if x then
			if firetouchinterest then
				task.spawn(function()
					firetouchinterest(x, root, 1)
					wait()
					firetouchinterest(x, root, 0)
				end)
			end
			x.CFrame = root.CFrame
		end
	end

	if args[1] then
		local name = getstring(1)
		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant:IsA("TouchTransmitter") and descendant.Name == name or descendant.Parent.Name == name then
				touch(descendant)
			end
		end
	else
		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant:IsA("TouchTransmitter") then
				touch(descendant)
			end
		end
	end
end)

addcmd('fullbright',{'fb','fullbrightness'},function(args, speaker)
	Lighting.Brightness = 2
	Lighting.ClockTime = 14
	Lighting.FogEnd = 100000
	Lighting.GlobalShadows = false
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end)

addcmd('loopfullbright',{'loopfb'},function(args, speaker)
	if brightLoop then
		brightLoop:Disconnect()
	end
	local function brightFunc()
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	end

	brightLoop = RunService.RenderStepped:Connect(brightFunc)
end)

addcmd('unloopfullbright',{'unloopfb'},function(args, speaker)
	if brightLoop then
		brightLoop:Disconnect()
	end
end)

addcmd('ambient',{},function(args, speaker)
	Lighting.Ambient = Color3.new(args[1],args[2],args[3])
	Lighting.OutdoorAmbient = Color3.new(args[1],args[2],args[3])
end)

addcmd('day',{},function(args, speaker)
	Lighting.ClockTime = 14
end)

addcmd('night',{},function(args, speaker)
	Lighting.ClockTime = 0
end)

addcmd('nofog',{},function(args, speaker)
	Lighting.FogEnd = 100000
	for i,v in pairs(Lighting:GetDescendants()) do
		if v:IsA("Atmosphere") then
			v:Destroy()
		end
	end
end)

addcmd('brightness',{},function(args, speaker)
	Lighting.Brightness = args[1]
end)

addcmd('globalshadows',{'gshadows'},function(args, speaker)
	Lighting.GlobalShadows = true
end)

addcmd('unglobalshadows',{'nogshadows','ungshadows','noglobalshadows'},function(args, speaker)
	Lighting.GlobalShadows = false
end)

origsettings = {abt = Lighting.Ambient, oabt = Lighting.OutdoorAmbient, brt = Lighting.Brightness, time = Lighting.ClockTime, fe = Lighting.FogEnd, fs = Lighting.FogStart, gs = Lighting.GlobalShadows}

addcmd('restorelighting',{'rlighting'},function(args, speaker)
	Lighting.Ambient = origsettings.abt
	Lighting.OutdoorAmbient = origsettings.oabt
	Lighting.Brightness = origsettings.brt
	Lighting.ClockTime = origsettings.time
	Lighting.FogEnd = origsettings.fe
	Lighting.FogStart = origsettings.fs
	Lighting.GlobalShadows = origsettings.gs
end)

addcmd('stun',{'platformstand'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
end)

addcmd('unstun',{'nostun','unplatformstand','noplatformstand'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
end)

addcmd('norotate',{'noautorotate'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').AutoRotate  = false
end)

addcmd('unnorotate',{'autorotate'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').AutoRotate  = true
end)

addcmd('enablestate',{},function(args, speaker)
	local x = args[1]
	if not tonumber(x) then
		local x = Enum.HumanoidStateType[args[1]]
	end
	speaker.Character:FindFirstChildOfClass("Humanoid"):SetStateEnabled(x, true)
end)

addcmd('disablestate',{},function(args, speaker)
	local x = args[1]
	if not tonumber(x) then
		local x = Enum.HumanoidStateType[args[1]]
	end
	speaker.Character:FindFirstChildOfClass("Humanoid"):SetStateEnabled(x, false)
end)

addcmd('drophats',{'drophat'},function(args, speaker)
	if speaker.Character then
		for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
			v.Parent = workspace
		end
	end
end)

addcmd('deletehats',{'nohats','rhats'},function(args, speaker)
	for i,v in next, speaker.Character:GetDescendants() do
		if v:IsA("Accessory") then
			for i,p in next, v:GetDescendants() do
				if p:IsA("Weld") then
					p:Destroy()
				end
			end
		end
	end
end)

addcmd('droptools',{'droptool'},function(args, speaker)
	for i,v in pairs(Players.LocalPlayer.Backpack:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = Players.LocalPlayer.Character
		end
	end
	wait()
	for i,v in pairs(Players.LocalPlayer.Character:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = workspace
		end
	end
end)

addcmd('droppabletools',{},function(args, speaker)
	if speaker.Character then
		for _,obj in pairs(speaker.Character:GetChildren()) do
			if obj:IsA("Tool") then
				obj.CanBeDropped = true
			end
		end
	end
	if speaker:FindFirstChildOfClass("Backpack") then
		for _,obj in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
			if obj:IsA("Tool") then
				obj.CanBeDropped = true
			end
		end
	end
end)

local currentToolSize = ""
local currentGripPos = ""
addcmd('reach',{},function(args, speaker)
	execCmd('unreach')
	wait()
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			if args[1] then
				currentToolSize = v.Handle.Size
				currentGripPos = v.GripPos
				local a = Instance.new("SelectionBox")
				a.Name = "SelectionBoxCreated"
				a.Parent = v.Handle
				a.Adornee = v.Handle
				v.Handle.Massless = true
				v.Handle.Size = Vector3.new(0.5,0.5,args[1])
				v.GripPos = Vector3.new(0,0,0)
				speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
			else
				currentToolSize = v.Handle.Size
				currentGripPos = v.GripPos
				local a = Instance.new("SelectionBox")
				a.Name = "SelectionBoxCreated"
				a.Parent = v.Handle
				a.Adornee = v.Handle
				v.Handle.Massless = true
				v.Handle.Size = Vector3.new(0.5,0.5,60)
				v.GripPos = Vector3.new(0,0,0)
				speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
			end
		end
	end
end)

addcmd("boxreach", {}, function(args, speaker)
    execCmd("unreach")
    wait()
    for i, v in pairs(speaker.Character:GetDescendants()) do
        if v:IsA("Tool") then
            local size = tonumber(args[1]) or 60
            currentToolSize = v.Handle.Size
            currentGripPos = v.GripPos
            local a = Instance.new("SelectionBox")
            a.Name = "SelectionBoxCreated"
            a.Parent = v.Handle
            a.Adornee = v.Handle
            v.Handle.Massless = true
            v.Handle.Size = Vector3.new(size, size, size)
            v.GripPos = Vector3.new(0, 0, 0)
            speaker.Character:FindFirstChildOfClass("Humanoid"):UnequipTools()
        end
    end
end)

addcmd('unreach',{'noreach','unboxreach'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			v.Handle.Size = currentToolSize
			v.GripPos = currentGripPos
			v.Handle.SelectionBoxCreated:Destroy()
		end
	end
end)

addcmd('grippos',{},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			v.Parent = speaker:FindFirstChildOfClass("Backpack")
			v.GripPos = Vector3.new(args[1],args[2],args[3])
			v.Parent = speaker.Character
		end
	end
end)

addcmd('usetools', {}, function(args, speaker)
	local Backpack = speaker:FindFirstChildOfClass("Backpack")
	local amount = tonumber(args[1]) or 1
	local delay_ = tonumber(args[2]) or false
	for _, v in ipairs(Backpack:GetChildren()) do
		v.Parent = speaker.Character
		task.spawn(function()
			for _ = 1, amount do
				v:Activate()
				if delay_ then
					wait(delay_)
				end
			end
			v.Parent = Backpack
		end)
	end
end)

addcmd("logs", {}, function(args, speaker)
    logsEnabled = true
    jLogsEnabled = true
    Toggle.Text = "Enabled"
    Toggle_2.Text = "Enabled"
    logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
end)

addcmd("chatlogs", {"clogs"}, function(args, speaker)
    logsEnabled = true
    join.Visible = false
    chat.Visible = true
    table.remove(shade3, table.find(shade3, selectChat))
    table.remove(shade2, table.find(shade2, selectJoin))
    table.insert(shade2, selectChat)
    table.insert(shade3, selectJoin)
    selectJoin.BackgroundColor3 = currentShade3
    selectChat.BackgroundColor3 = currentShade2
    Toggle.Text = "Enabled"
    logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
end)

addcmd("joinlogs", {"jlogs"}, function(args, speaker)
    jLogsEnabled = true
    chat.Visible = false
    join.Visible = true	
    table.remove(shade3, table.find(shade3, selectJoin))
    table.remove(shade2, table.find(shade2, selectChat))
    table.insert(shade2, selectJoin)
    table.insert(shade3, selectChat)
    selectChat.BackgroundColor3 = currentShade3
    selectJoin.BackgroundColor3 = currentShade2
    Toggle_2.Text = "Enabled"
    logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
end)

addcmd("chatlogswebhook", {"logswebhook"}, function(args, speaker)
    if not httprequest then
        return notify("Incompatible Exploit", "Your exploit does not support this command (missing request)")
    end
    logsWebhook = args[1] or nil
    updatesaves()
end)

addcmd("antichatlogs", {"antichatlogger"}, function(args, speaker)
    if not isLegacyChat then
        return notify("antichatlogs", "Game needs the legacy chat")
    end
    local MessagePosted, _ = pcall(function()
        rawset(require(speaker:FindFirstChild("PlayerScripts"):FindFirstChild("ChatScript").ChatMain), "MessagePosted", {
            ["fire"] = function(msg)
                return msg
            end,
            ["wait"] = function()
                return
            end,
            ["connect"] = function()
                return
            end
        })
    end)
    notify("antichatlogs", MessagePosted and "Enabled" or "Failed to enable antichatlogs")
end)

end do -- Split Scope 15

flinging = false
addcmd('fling',{},function(args, speaker)
	flinging = false
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child:IsA("BasePart") then
			child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
		end
	end
	execCmd('noclip')
	wait(.1)
	local bambam = Instance.new("BodyAngularVelocity")
	bambam.Name = randomString()
	bambam.Parent = getRoot(speaker.Character)
	bambam.AngularVelocity = Vector3.new(0,99999,0)
	bambam.MaxTorque = Vector3.new(0,math.huge,0)
	bambam.P = math.huge
	local Char = speaker.Character:GetChildren()
	for i, v in next, Char do
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.Massless = true
			v.Velocity = Vector3.new(0, 0, 0)
		end
	end
	flinging = true
	local function flingDiedF()
		execCmd('unfling')
	end
	flingDied = speaker.Character:FindFirstChildOfClass('Humanoid').Died:Connect(flingDiedF)
	repeat
		bambam.AngularVelocity = Vector3.new(0,99999,0)
		wait(.2)
		bambam.AngularVelocity = Vector3.new(0,0,0)
		wait(.1)
	until flinging == false
end)

addcmd('unfling',{'nofling'},function(args, speaker)
	execCmd('clip')
	if flingDied then
		flingDied:Disconnect()
	end
	flinging = false
	wait(.1)
	local speakerChar = speaker.Character
	if not speakerChar or not getRoot(speakerChar) then return end
	for i,v in pairs(getRoot(speakerChar):GetChildren()) do
		if v.ClassName == 'BodyAngularVelocity' then
			v:Destroy()
		end
	end
	for _, child in pairs(speakerChar:GetDescendants()) do
		if child.ClassName == "Part" or child.ClassName == "MeshPart" then
			child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
		end
	end
end)

addcmd('togglefling',{},function(args, speaker)
	if flinging then
		execCmd('unfling')
	else
		execCmd('fling')
	end
end)

addcmd("flyfling", {}, function(args, speaker)
    execCmd("unvehiclefly\\unwalkfling")
    task.wait()
    vehicleflyspeed = tonumber(args[1]) or vehicleflyspeed
    execCmd("vehiclefly\\walkfling")
end)

addcmd("unflyfling", {}, function(args, speaker)
    execCmd("unvehiclefly\\unwalkfling\\breakvelocity")
end)

addcmd("toggleflyfling", {}, function(args, speaker)
    execCmd(flinging and "unflyfling" or "flyfling")
end)

walkflinging = false
addcmd("walkfling", {}, function(args, speaker)
    execCmd("unwalkfling")
    local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            execCmd("unwalkfling")
        end)
    end

    execCmd("noclip nonotify")
    walkflinging = true
    repeat RunService.Heartbeat:Wait()
        local character = speaker.Character
        local root = getRoot(character)
        local vel, movel = nil, 0.1

        while not (character and character.Parent and root and root.Parent) do
            RunService.Heartbeat:Wait()
            character = speaker.Character
            root = getRoot(character)
        end

        vel = root.Velocity
        root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)

        RunService.RenderStepped:Wait()
        if character and character.Parent and root and root.Parent then
            root.Velocity = vel
        end

        RunService.Stepped:Wait()
        if character and character.Parent and root and root.Parent then
            root.Velocity = vel + Vector3.new(0, movel, 0)
            movel = movel * -1
        end
    until walkflinging == false
end)

addcmd("unwalkfling", {"nowalkfling"}, function(args, speaker)
    walkflinging = false
    execCmd("unnoclip nonotify")
end)

addcmd("togglewalkfling", {}, function(args, speaker)
    execCmd(walkflinging and "unwalkfling" or "walkfling")
end)

addcmd('invisfling',{},function(args, speaker)
	local ch = speaker.Character
	ch:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	local prt=Instance.new("Model")
	prt.Parent = speaker.Character
	local z1 = Instance.new("Part")
	z1.Name="Torso"
	z1.CanCollide = false
	z1.Anchored = true
	local z2 = Instance.new("Part")
	z2.Name="Head"
	z2.Parent = prt
	z2.Anchored = true
	z2.CanCollide = false
	local z3 =Instance.new("Humanoid")
	z3.Name="Humanoid"
	z3.Parent = prt
	z1.Position = Vector3.new(0,9999,0)
	speaker.Character=prt
	wait(3)
	speaker.Character=ch
	wait(3)
	local Hum = Instance.new("Humanoid")
	z2:Clone()
	Hum.Parent = speaker.Character
	local root =  getRoot(speaker.Character)
	for i,v in pairs(speaker.Character:GetChildren()) do
		if v ~= root and  v.Name ~= "Humanoid" then
			v:Destroy()
		end
	end
	root.Transparency = 0
	root.Color = Color3.new(1, 1, 1)
	local invisflingStepped
	invisflingStepped = RunService.Stepped:Connect(function()
		if speaker.Character and getRoot(speaker.Character) then
			getRoot(speaker.Character).CanCollide = false
		else
			invisflingStepped:Disconnect()
		end
	end)
	sFLY()
	workspace.CurrentCamera.CameraSubject = root
	local bambam = Instance.new("BodyThrust")
	bambam.Parent = getRoot(speaker.Character)
	bambam.Force = Vector3.new(99999,99999*10,99999)
	bambam.Location = getRoot(speaker.Character).Position
end)

addcmd("antifling", {}, function(args, speaker)
    if antifling then
        antifling:Disconnect()
        antifling = nil
    end
    antifling = RunService.Stepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= speaker and player.Character then
                for _, v in pairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end
    end)
end)

addcmd("unantifling", {}, function(args, speaker)
    if antifling then
        antifling:Disconnect()
        antifling = nil
    end
end)

addcmd("toggleantifling", {}, function(args, speaker)
    execCmd(antifling and "unantifling" or "antifling")
end)

function attach(speaker,target)
	if tools(speaker) then
		local char = speaker.Character
		local tchar = target.Character
		local hum = speaker.Character:FindFirstChildOfClass("Humanoid")
		local hrp = getRoot(speaker.Character)
		local hrp2 = getRoot(target.Character)
		hum.Name = "1"
		local newHum = hum:Clone()
		newHum.Parent = char
		newHum.Name = "Humanoid"
		wait()
		hum:Destroy()
		workspace.CurrentCamera.CameraSubject = char
		newHum.DisplayDistanceType = "None"
		local tool = speaker:FindFirstChildOfClass("Backpack"):FindFirstChildOfClass("Tool") or speaker.Character:FindFirstChildOfClass("Tool")
		tool.Parent = char
		hrp.CFrame = hrp2.CFrame * CFrame.new(0, 0, 0) * CFrame.new(math.random(-100, 100)/200,math.random(-100, 100)/200,math.random(-100, 100)/200)
		local n = 0
		repeat
			wait(.1)
			n = n + 1
			hrp.CFrame = hrp2.CFrame
		until (tool.Parent ~= char or not hrp or not hrp2 or not hrp.Parent or not hrp2.Parent or n > 250) and n > 2
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

function kill(speaker,target,fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			attach(speaker,target)
			repeat
				wait()
				hrp.CFrame = CFrame.new(999999, workspace.FallenPartsDestroyHeight + 5,999999)
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			speaker.CharacterAdded:Wait():WaitForChild("HumanoidRootPart").CFrame = NormPos
		end
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

addcmd("handlekill", {"hkill"}, function(args, speaker)
	if not firetouchinterest then
		return notify("Incompatible Exploit", "Your exploit does not support this command (missing firetouchinterest)")
	end
	if not speaker.Character then return end
	local tool = speaker.Character:FindFirstChildWhichIsA("Tool")
	local handle = tool and tool:FindFirstChild("Handle")
	if not handle then
		return notify("Handle Kill", "You need to hold a \"Tool\" that does damage on touch. For example a common Sword tool.")
	end
	local range = tonumber(args[2]) or math.huge
    if range ~= math.huge then notify("Handle Kill", ("Started!\nRadius: %s"):format(tostring(range):upper())) end

	while task.wait() and speaker.Character and tool.Parent and tool.Parent == speaker.Character do
		for _, plr in next, getPlayer(args[1], speaker) do
			plr = Players[plr]
			if plr ~= speaker and plr.Character then
				local hum = plr.Character:FindFirstChildWhichIsA("Humanoid")
				local root = hum and getRoot(plr.Character)

				if root and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead and speaker:DistanceFromCharacter(root.Position) <= range then
					firetouchinterest(handle, root, 1)
					firetouchinterest(handle, root, 0)
				end
			end
		end
	end

	notify("Handle Kill", "Stopped!")
end)

local hb = RunService.Heartbeat
addcmd('tpwalk', {'teleportwalk'}, function(args, speaker)
	tpwalking = true
	local chr = speaker.Character
	local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
	while tpwalking and chr and hum and hum.Parent do
		local delta = hb:Wait()
		if hum.MoveDirection.Magnitude > 0 then
			if args[1] and isNumber(args[1]) then
				chr:TranslateBy(hum.MoveDirection * tonumber(args[1]) * delta * 10)
			else
				chr:TranslateBy(hum.MoveDirection * delta * 10)
			end
		end
	end
end)

addcmd('untpwalk', {'unteleportwalk'}, function(args, speaker)
	tpwalking = false
end)

function bring(speaker,target,fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			attach(speaker,target)
			repeat
				wait()
				hrp.CFrame = NormPos
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			speaker.CharacterAdded:Wait():WaitForChild("HumanoidRootPart").CFrame = NormPos
		end
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

function teleport(speaker,target,target2,fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			local hrp2 = getRoot(target2.Character)
			attach(speaker,target)
			repeat
				wait()
				hrp.CFrame = hrp2.CFrame
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			wait(1)
			speaker.CharacterAdded:Wait():WaitForChild("HumanoidRootPart").CFrame = NormPos
		end
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

addcmd('spin',{},function(args, speaker)
	local spinSpeed = 20
	if args[1] and isNumber(args[1]) then
		spinSpeed = args[1]
	end
	for i,v in pairs(getRoot(speaker.Character):GetChildren()) do
		if v.Name == "Spinning" then
			v:Destroy()
		end
	end
	local Spin = Instance.new("BodyAngularVelocity")
	Spin.Name = "Spinning"
	Spin.Parent = getRoot(speaker.Character)
	Spin.MaxTorque = Vector3.new(0, math.huge, 0)
	Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)
end)

addcmd('unspin',{},function(args, speaker)
	for i,v in pairs(getRoot(speaker.Character):GetChildren()) do
		if v.Name == "Spinning" then
			v:Destroy()
		end
	end
end)

xrayEnabled = false
function xray()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChildWhichIsA("Humanoid") and not v.Parent.Parent:FindFirstChildWhichIsA("Humanoid") then
            v.LocalTransparencyModifier = xrayEnabled and 0.5 or 0
        end
    end
end

addcmd("xray", {}, function(args, speaker)
    xrayEnabled = true
    xray()
end)

addcmd("unxray", {"noxray"}, function(args, speaker)
    xrayEnabled = false
    xray()
end)

addcmd("togglexray", {}, function(args, speaker)
    xrayEnabled = not xrayEnabled
    xray()
end)

addcmd("loopxray", {}, function(args, speaker)
    pcall(function() xrayLoop:Disconnect() end)
    xrayLoop = RunService.RenderStepped:Connect(function()
        xrayEnabled = true
        xray()
    end)
end)

addcmd("unloopxray", {}, function(args, speaker)
    pcall(function() xrayLoop:Disconnect() end)
    xrayEnabled = false
    xray()
end)

local walltpTouch = nil
addcmd('walltp',{},function(args, speaker)
	local torso
	if r15(speaker) then
		torso = speaker.Character.UpperTorso
	else
		torso = speaker.Character.Torso
	end
	local function touchedFunc(hit)
		local Root = getRoot(speaker.Character)
		if hit:IsA("BasePart") and hit.Position.Y > Root.Position.Y - speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight then
			local hitP = getRoot(hit.Parent)
			if hitP ~= nil then
				Root.CFrame = hit.CFrame * CFrame.new(Root.CFrame.lookVector.X,hitP.Size.Z/2 + speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight,Root.CFrame.lookVector.Z)
			elseif hitP == nil then
				Root.CFrame = hit.CFrame * CFrame.new(Root.CFrame.lookVector.X,hit.Size.Y/2 + speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight,Root.CFrame.lookVector.Z)
			end
		end
	end
	walltpTouch = torso.Touched:Connect(touchedFunc)
end)

addcmd('unwalltp',{'nowalltp'},function(args, speaker)
	if walltpTouch then
		walltpTouch:Disconnect()
	end
end)

autoclicking = false
addcmd('autoclick',{},function(args, speaker)
	if mouse1press and mouse1release then
		execCmd('unautoclick')
		wait()
		local clickDelay = 0.1
		local releaseDelay = 0.1
		if args[1] and isNumber(args[1]) then clickDelay = args[1] end
		if args[2] and isNumber(args[2]) then releaseDelay = args[2] end
		autoclicking = true
		cancelAutoClick = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
			if not gameProcessedEvent then
				if (input.KeyCode == Enum.KeyCode.Backspace and UserInputService:IsKeyDown(Enum.KeyCode.Equals)) or (input.KeyCode == Enum.KeyCode.Equals and UserInputService:IsKeyDown(Enum.KeyCode.Backspace)) then
					autoclicking = false
					cancelAutoClick:Disconnect()
				end
			end
		end)
		notify('Auto Clicker',"Press [backspace] and [=] at the same time to stop")
		repeat wait(clickDelay)
			mouse1press()
			wait(releaseDelay)
			mouse1release()
		until autoclicking == false
	else
		notify('Auto Clicker',"Your exploit doesn't have the ability to use the autoclick")
	end
end)

addcmd('unautoclick',{'noautoclick'},function(args, speaker)
	autoclicking = false
	if cancelAutoClick then cancelAutoClick:Disconnect() end
end)

addcmd('hovername',{},function(args, speaker)
	wait()
	nameBox = Instance.new("TextLabel")
	nameBox.Name = randomString()
	nameBox.Parent = ScaledHolder
	nameBox.BackgroundTransparency = 1
	nameBox.Size = UDim2.new(0,200,0,30)
	nameBox.Font = Enum.Font.Code
	nameBox.TextSize = 16
	nameBox.Text = ""
	nameBox.TextColor3 = Color3.new(1, 1, 1)
	nameBox.TextStrokeTransparency = 0
	nameBox.TextXAlignment = Enum.TextXAlignment.Left
	nameBox.ZIndex = 10
	nbSelection = Instance.new('SelectionBox')
	nbSelection.Name = randomString()
	nbSelection.LineThickness = 0.03
	nbSelection.Color3 = Color3.new(1, 1, 1)
	local function updateNameBox()
		local t
		local target = IYMouse.Target

		if target then
			local humanoid = target.Parent:FindFirstChildOfClass("Humanoid") or target.Parent.Parent:FindFirstChildOfClass("Humanoid")
			if humanoid then
				t = humanoid.Parent
			end
		end

		if t ~= nil then
			local x = IYMouse.X
			local y = IYMouse.Y
			local xP
			local yP
			if IYMouse.X > 200 then
				xP = x - 205
				nameBox.TextXAlignment = Enum.TextXAlignment.Right
			else
				xP = x + 25
				nameBox.TextXAlignment = Enum.TextXAlignment.Left
			end
			nameBox.Position = UDim2.new(0, xP, 0, y)
			nameBox.Text = t.Name
			nameBox.Visible = true
			nbSelection.Parent = t
			nbSelection.Adornee = t
		else
			nameBox.Visible = false
			nbSelection.Parent = nil
			nbSelection.Adornee = nil
		end
	end
	nbUpdateFunc = connectBindable(IYMouse.Move,updateNameBox)
end)

addcmd('unhovername',{'nohovername'},function(args, speaker)
	if nbUpdateFunc then
		nbUpdateFunc:Disconnect()
		nameBox:Destroy()
		nbSelection:Destroy()
	end
end)

addcmd('headsize',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if Players[v] ~= speaker and Players[v].Character:FindFirstChild('Head') then
			local sizeArg = tonumber(args[2])
			local Size = Vector3.new(sizeArg,sizeArg,sizeArg)
			local Head = Players[v].Character:FindFirstChild('Head')
			if Head:IsA("BasePart") then
				Head.CanCollide = false
				if not args[2] or sizeArg == 1 then
					Head.Size = Vector3.new(2,1,1)
				else
					Head.Size = Size
				end
			end
		end
	end
end)

addcmd('hitbox',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local transparency = args[3] and tonumber(args[3]) or 0.4
	for i,v in pairs(players) do
		if Players[v] ~= speaker and Players[v].Character:FindFirstChild('HumanoidRootPart') then
			local sizeArg = tonumber(args[2])
			local Size = Vector3.new(sizeArg,sizeArg,sizeArg)
			local Root = Players[v].Character:FindFirstChild('HumanoidRootPart')
			if Root:IsA("BasePart") then
				Root.CanCollide = false
				if not args[2] or sizeArg == 1 then
					Root.Size = Vector3.new(2,1,1)
					Root.Transparency = transparency
				else
					Root.Size = Size
					Root.Transparency = transparency
				end
			end
		end
	end
end)

addcmd('stareat',{'stare'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if stareLoop then
			stareLoop:Disconnect()
		end
		if not Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Players[v].Character:FindFirstChild("HumanoidRootPart") then return end
		local function stareFunc()
			if Players.LocalPlayer.Character.PrimaryPart and Players:FindFirstChild(v) and Players[v].Character ~= nil and Players[v].Character:FindFirstChild("HumanoidRootPart") then
				local chrPos=Players.LocalPlayer.Character.PrimaryPart.Position
				local tPos=Players[v].Character:FindFirstChild("HumanoidRootPart").Position
				local modTPos=Vector3.new(tPos.X,chrPos.Y,tPos.Z)
				local newCF=CFrame.new(chrPos,modTPos)
				Players.LocalPlayer.Character:SetPrimaryPartCFrame(newCF)
			elseif not Players:FindFirstChild(v) then
				stareLoop:Disconnect()
			end
		end

		stareLoop = RunService.RenderStepped:Connect(stareFunc)
	end
end)

addcmd('unstareat',{'unstare','nostare','nostareat'},function(args, speaker)
	if stareLoop then
		stareLoop:Disconnect()
	end
end)

RolewatchData = {Group = 0, Role = "", Leave = false}
RolewatchConnection = Players.PlayerAdded:Connect(function(player)
	if RolewatchData.Group == 0 then return end
	if player:IsInGroup(RolewatchData.Group) then
		if tostring(player:GetRoleInGroup(RolewatchData.Group)):lower() == RolewatchData.Role:lower() then
			if RolewatchData.Leave == true then
				Players.LocalPlayer:Kick("\n\nRolewatch\nPlayer \"" .. tostring(player.Name) .. "\" has joined with the Role \"" .. RolewatchData.Role .. "\"\n")
			else
				notify("Rolewatch", "Player \"" .. tostring(player.Name) .. "\" has joined with the Role \"" .. RolewatchData.Role .. "\"")
			end
		end
	end
end)

addcmd("rolewatch", {}, function(args, speaker)
    local groupId = tonumber(args[1] or 0)
    local roleName = args[2] and tostring(getstring(2))
    if groupId and roleName then
        RolewatchData.Group = groupId
        RolewatchData.Role = roleName
        notify("Rolewatch", "Watching Group ID \"" .. tostring(groupId) .. "\" for Role \"" .. roleName .. "\"")
    end
end)

addcmd("rolewatchstop", {}, function(args, speaker)
    RolewatchData.Group = 0
    RolewatchData.Role = ""
    RolewatchData.Leave = false
    notify("Rolewatch", "Disabled")
end)

addcmd("rolewatchleave", {"unrolewatch"}, function(args, speaker)
    RolewatchData.Leave = not RolewatchData.Leave
    notify("Rolewatch", RolewatchData.Leave and "Leave has been Enabled" or "Leave has been Disabled")
end)

staffRoles = {"mod", "admin", "staff", "dev", "founder", "owner", "supervis", "manager", "management", "executive", "president", "chairman", "chairwoman", "chairperson", "director"}

getStaffRole = function(player)
    local playerRole = player:GetRoleInGroup(game.CreatorId)
    local result = {Role = playerRole, Staff = false}
    if player:IsInGroup(1200769) then
        result.Role = "Roblox Employee"
        result.Staff = true
    end
    for _, role in pairs(staffRoles) do
        if string.find(string.lower(playerRole), role) then
            result.Staff = true
        end
    end
    return result
end

addcmd("staffwatch", {}, function(args, speaker)
    if staffwatchjoin then
        staffwatchjoin:Disconnect()
    end
    if game.CreatorType == Enum.CreatorType.Group then
        local found = {}
        staffwatchjoin = Players.PlayerAdded:Connect(function(player)
            local result = getStaffRole(player)
            if result.Staff then
                notify("Staffwatch", formatUsername(player) .. " is a " .. result.Role)
            end
        end)
        for _, player in pairs(Players:GetPlayers()) do
            local result = getStaffRole(player)
            if result.Staff then
                table.insert(found, formatUsername(player) .. " is a " .. result.Role)
            end
        end
        if #found > 0 then
            notify("Staffwatch", table.concat(found, ",\n"))
        else
            notify("Staffwatch", "Enabled")
        end
    else
        notify("Staffwatch", "Game is not owned by a Group")
    end
end)

addcmd("unstaffwatch", {}, function(args, speaker)
    if staffwatchjoin then
        staffwatchjoin:Disconnect()
    end
    notify("Staffwatch", "Disabled")
end)

addcmd('removeterrain',{'rterrain','noterrain'},function(args, speaker)
	workspace:FindFirstChildOfClass('Terrain'):Clear()
end)

addcmd('clearnilinstances',{'nonilinstances','cni'},function(args, speaker)
	if getnilinstances then
		for i,v in pairs(getnilinstances()) do
			v:Destroy()
		end
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing getnilinstances)')
	end
end)

addcmd('destroyheight',{'dh'},function(args, speaker)
	local dh = args[1] or -500
	if isNumber(dh) then
		workspace.FallenPartsDestroyHeight = dh
	end
end)

OrgDestroyHeight = workspace.FallenPartsDestroyHeight
addcmd("antivoid", {}, function(args, speaker)
    execCmd("unantivoid nonotify")
    task.wait()
    antivoidloop = RunService.Stepped:Connect(function()
        local root = getRoot(speaker.Character)
        if root and root.Position.Y <= OrgDestroyHeight + 25 then
            root.Velocity = root.Velocity + Vector3.new(0, 250, 0)
        end
    end)
    if args[1] ~= "nonotify" then notify("antivoid", "Enabled") end
end)

addcmd("unantivoid", {"noantivoid"}, function(args, speaker)
    pcall(function() antivoidloop:Disconnect() end)
    antivoidloop = nil
    if args[1] ~= "nonotify" then notify("antivoid", "Disabled") end
end)

antivoidWasEnabled = false
addcmd("fakeout", {}, function(args, speaker)
    local root = getRoot(speaker.Character)
    local oldpos = root.CFrame
    if antivoidloop then
        execCmd("unantivoid nonotify")
        antivoidWasEnabled = true
    end
    workspace.FallenPartsDestroyHeight = 0/1/0
    root.CFrame = CFrame.new(Vector3.new(0, OrgDestroyHeight - 25, 0))
    task.wait(1)
    root.CFrame = oldpos
    workspace.FallenPartsDestroyHeight = OrgDestroyHeight
    if antivoidWasEnabled then
        execCmd("antivoid nonotify")
        antivoidWasEnabled = false
    end
end)

addcmd("trip", {}, function(args, speaker)
    local humanoid = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
    local root = speaker.Character and getRoot(speaker.Character)
    if humanoid and root then
        humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
        root.Velocity = root.CFrame.LookVector * 30
    end
end)

addcmd("removeads", {"adblock"}, function(args, speaker)
    while wait() do
        pcall(function()
            for i, v in pairs(workspace:GetDescendants()) do
                if v:IsA("PackageLink") then
                    if v.Parent:FindFirstChild("ADpart") then
                        v.Parent:Destroy()
                    end
                    if v.Parent:FindFirstChild("AdGuiAdornee") then
                        v.Parent.Parent:Destroy()
                    end
                end
            end
        end)
    end
end)

addcmd("scare", {"spook"}, function(args, speaker)
    local players = getPlayer(args[1], speaker)
    local oldpos = nil

    for _, v in pairs(players) do
        local root = speaker.Character and getRoot(speaker.Character)
        local target = Players[v]
        local targetRoot = target and target.Character and getRoot(target.Character)

        if root and targetRoot and target ~= speaker then
            oldpos = root.CFrame
            root.CFrame = targetRoot.CFrame + targetRoot.CFrame.lookVector * 2
            root.CFrame = CFrame.new(root.Position, targetRoot.Position)
            task.wait(0.5)
            root.CFrame = oldpos
        end
    end
end)

end do -- Split Scope 8

addcmd("alignmentkeys", {}, function(args, speaker)
    alignmentKeys = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Comma then workspace.CurrentCamera:PanUnits(-1) end
        if input.KeyCode == Enum.KeyCode.Period then workspace.CurrentCamera:PanUnits(1) end
    end)
    alignmentKeysEmotes = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
end)

addcmd("unalignmentkeys", {"noalignmentkeys"}, function(args, speaker)
    if type(alignmentKeysEmotes) == "boolean" then
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, alignmentKeysEmotes)
    end
    alignmentKeys:Disconnect()
end)

addcmd("ctrllock", {}, function(args, speaker)
    local mouseLockController = speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
    local boundKeys = mouseLockController:FindFirstChild("BoundKeys")

    if boundKeys then
        boundKeys.Value = "LeftControl"
    else
        boundKeys = Instance.new("StringValue")
        boundKeys.Name = "BoundKeys"
        boundKeys.Value = "LeftControl"
        boundKeys.Parent = mouseLockController
    end
end)

addcmd("unctrllock", {}, function(args, speaker)
    local mouseLockController = speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
    local boundKeys = mouseLockController:FindFirstChild("BoundKeys")

    if boundKeys then
        boundKeys.Value = "LeftShift"
    else
        boundKeys = Instance.new("StringValue")
        boundKeys.Name = "BoundKeys"
        boundKeys.Value = "LeftShift"
        boundKeys.Parent = mouseLockController
    end
end)

addcmd("listento", {}, function(args, speaker)
    execCmd("unlistento")
    if not args[1] then return end

    local player = Players:FindFirstChild(getPlayer(args[1], speaker)[1])
    local root = player and player.Character and getRoot(player.Character)

    if root then
        SoundService:SetListener(Enum.ListenerType.ObjectPosition, root)
        listentoChar = player.CharacterAdded:Connect(function()
            repeat task.wait() until Players[player.Name].Character ~= nil and getRoot(Players[player.Name].Character)
            SoundService:SetListener(Enum.ListenerType.ObjectPosition, getRoot(Players[player.Name].Character))
        end)
    end
end)

addcmd("unlistento", {}, function(args, speaker)
    SoundService:SetListener(Enum.ListenerType.Camera)
    listentoChar:Disconnect()
end)

addcmd("jerk", {}, function(args, speaker)
    local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
    local backpack = speaker:FindFirstChildWhichIsA("Backpack")
    if not humanoid or not backpack then return end

    local tool = Instance.new("Tool")
    tool.Name = "Jerk Off"
    tool.ToolTip = "in the stripped club. straight up \"jorking it\" . and by \"it\" , haha, well. let's justr say. My peanits."
    tool.RequiresHandle = false
    tool.Parent = backpack

    local jorkin = false
    local track = nil

    local function stopTomfoolery()
        jorkin = false
        if track then
            track:Stop()
            track = nil
        end
    end

    tool.Equipped:Connect(function() jorkin = true end)
    tool.Unequipped:Connect(stopTomfoolery)
    humanoid.Died:Connect(stopTomfoolery)

    while task.wait() do
        if not jorkin then continue end

        local isR15 = r15(speaker)
        if not track then
            local anim = Instance.new("Animation")
            anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
            track = humanoid:LoadAnimation(anim)
        end

        track:Play()
        track:AdjustSpeed(isR15 and 0.7 or 0.65)
        track.TimePosition = 0.6
        task.wait(0.1)
        while track and track.TimePosition < (not isR15 and 0.65 or 0.7) do task.wait(0.1) end
        if track then
            track:Stop()
            track = nil
        end
    end
end)

addcmd("guiscale", {}, function(args, speaker)
    if args[1] and isNumber(args[1]) then
        local scale = tonumber(args[1])
        if scale % 1 == 0 then scale = scale / 100 end
        -- me when i divide and it explodes
        if scale == 0.01 then scale = 1 end
        if scale == 0.02 then scale = 2 end

        if scale >= 0.4 and scale <= 2 then
            guiScale = scale
        end
    else
        guiScale = defaultGuiScale
    end

    Scale.Scale = math.max(Holder.AbsoluteSize.X / 1920, guiScale)
    updatesaves()
end)

addcmd("unsuspendchat", {}, function(args, speaker)
	if replicatesignal then
        replicatesignal(TextChatService.UpdateChatTimeout, speaker.UserId, 0, 10)
    else
        notify("Incompatible Exploit", "Your exploit does not support this command (missing replicatesignal)")
    end
end)

addcmd("unsuspendvc", {}, function(args, speaker)
	if replicatesignal then
    	replicatesignal(VoiceChatService.ClientRetryJoin)

    	if typeof(onVoiceModerated) ~= "RBXScriptConnection" then
        	onVoiceModerated = Services.VoiceChatInternal.LocalPlayerModerated:Connect(function()
            	task.wait(1)
            	replicatesignal(VoiceChatService.ClientRetryJoin)
        	end)
    	end
    else
        notify("Incompatible Exploit", "Your exploit does not support this command (missing replicatesignal)")
    end
end)

addcmd("muteallvcs", {}, function(args, speaker)
    Services.VoiceChatInternal:SubscribePauseAll(true)
end)

addcmd("unmuteallvcs", {}, function(args, speaker)
    Services.VoiceChatInternal:SubscribePauseAll(false)
end)

addcmd("mutevc", {}, function(args, speaker)
    for _, plr in getPlayer(args[1], speaker) do
        if Players[plr] == speaker then continue end
        Services.VoiceChatInternal:SubscribePause(Players[plr].UserId, true)
    end
end)

addcmd("unmutevc", {}, function(args, speaker)
    for _, plr in getPlayer(args[1], speaker) do
        if Players[plr] == speaker then continue end
        Services.VoiceChatInternal:SubscribePause(Players[plr].UserId, false)
    end
end)

addcmd("phonebook", {"call"}, function(args, speaker)
    local success, canInvite = pcall(function()
        return SocialService:CanSendCallInviteAsync(speaker)
    end)
    if success and canInvite then
        SocialService:PromptPhoneBook(speaker, "")
    else
        notify("Phonebook", "It seems you're not able to call anyone. Sorry!")
    end
end)

addcmd("permadeath", {}, function(args, speaker)
    if replicatesignal then
        permadeath(speaker)
        notify("Permadeath", "Enabled")
    else
        notify("Incompatible Exploit", "Your exploit does not support this command (missing replicatesignal)")
    end
end)

local freezingua = nil
frozenParts = {}
addcmd('freezeunanchored',{'freezeua'},function(args, speaker)
    local badnames = {
        "Head",
        "UpperTorso",
        "LowerTorso",
        "RightUpperArm",
        "LeftUpperArm",
        "RightLowerArm",
        "LeftLowerArm",
        "RightHand",
        "LeftHand",
        "RightUpperLeg",
        "LeftUpperLeg",
        "RightLowerLeg",
        "LeftLowerLeg",
        "RightFoot",
        "LeftFoot",
        "Torso",
        "Right Arm",
        "Left Arm",
        "Right Leg",
        "Left Leg",
        "HumanoidRootPart"
    }
    local function FREEZENOOB(v)
        if v:IsA("BasePart" or "UnionOperation") and v.Anchored == false then
            local BADD = false
            for i = 1,#badnames do
                if v.Name == badnames[i] then
                    BADD = true
                end
            end
            if speaker.Character and v:IsDescendantOf(speaker.Character) then
                BADD = true
            end
            if BADD == false then
                for i,c in pairs(v:GetChildren()) do
                    if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
                        c:Destroy()
                    end
                end
                local bodypos = Instance.new("BodyPosition")
                bodypos.Parent = v
                bodypos.Position = v.Position
                bodypos.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                local bodygyro = Instance.new("BodyGyro")
                bodygyro.Parent = v
                bodygyro.CFrame = v.CFrame
                bodygyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
                if not table.find(frozenParts,v) then
                    table.insert(frozenParts,v)
                end
            end
        end
    end
    for i,v in pairs(workspace:GetDescendants()) do
        FREEZENOOB(v)
    end
    freezingua = workspace.DescendantAdded:Connect(FREEZENOOB)
end)

addcmd('thawunanchored',{'thawua','unfreezeunanchored','unfreezeua'},function(args, speaker)
    if freezingua then
        freezingua:Disconnect()
    end
    for i,v in pairs(frozenParts) do
        for i,c in pairs(v:GetChildren()) do
            if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
                c:Destroy()
            end
        end
    end
    frozenParts = {}
end)

addcmd('tpunanchored',{'tpua'},function(args, speaker)
    local players = getPlayer(args[1], speaker)
    for i,v in pairs(players) do
        local Forces = {}
        for _,part in pairs(workspace:GetDescendants()) do
            if Players[v].Character:FindFirstChild('Head') and part:IsA("BasePart" or "UnionOperation" or "Model") and part.Anchored == false and not part:IsDescendantOf(speaker.Character) and part.Name == "Torso" == false and part.Name == "Head" == false and part.Name == "Right Arm" == false and part.Name == "Left Arm" == false and part.Name == "Right Leg" == false and part.Name == "Left Leg" == false and part.Name == "HumanoidRootPart" == false then
                for i,c in pairs(part:GetChildren()) do
                    if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
                        c:Destroy()
                    end
                end
                local ForceInstance = Instance.new("BodyPosition")
                ForceInstance.Parent = part
                ForceInstance.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                table.insert(Forces, ForceInstance)
                if not table.find(frozenParts,part) then
                    table.insert(frozenParts,part)
                end
            end
        end
        for i,c in pairs(Forces) do
            c.Position = Players[v].Character.Head.Position
        end
    end
end)

keycodeMap = {
	["0"] = 0x30,
	["1"] = 0x31,
	["2"] = 0x32,
	["3"] = 0x33,
	["4"] = 0x34,
	["5"] = 0x35,
	["6"] = 0x36,
	["7"] = 0x37,
	["8"] = 0x38,
	["9"] = 0x39,
	["a"] = 0x41,
	["b"] = 0x42,
	["c"] = 0x43,
	["d"] = 0x44,
	["e"] = 0x45,
	["f"] = 0x46,
	["g"] = 0x47,
	["h"] = 0x48,
	["i"] = 0x49,
	["j"] = 0x4A,
	["k"] = 0x4B,
	["l"] = 0x4C,
	["m"] = 0x4D,
	["n"] = 0x4E,
	["o"] = 0x4F,
	["p"] = 0x50,
	["q"] = 0x51,
	["r"] = 0x52,
	["s"] = 0x53,
	["t"] = 0x54,
	["u"] = 0x55,
	["v"] = 0x56,
	["w"] = 0x57,
	["x"] = 0x58,
	["y"] = 0x59,
	["z"] = 0x5A,
	["enter"] = 0x0D,
	["shift"] = 0x10,
	["ctrl"] = 0x11,
	["alt"] = 0x12,
	["pause"] = 0x13,
	["capslock"] = 0x14,
	["spacebar"] = 0x20,
	["space"] = 0x20,
	["pageup"] = 0x21,
	["pagedown"] = 0x22,
	["end"] = 0x23,
	["home"] = 0x24,
	["left"] = 0x25,
	["up"] = 0x26,
	["right"] = 0x27,
	["down"] = 0x28,
	["insert"] = 0x2D,
	["delete"] = 0x2E,
	["f1"] = 0x70,
	["f2"] = 0x71,
	["f3"] = 0x72,
	["f4"] = 0x73,
	["f5"] = 0x74,
	["f6"] = 0x75,
	["f7"] = 0x76,
	["f8"] = 0x77,
	["f9"] = 0x78,
	["f10"] = 0x79,
	["f11"] = 0x7A,
	["f12"] = 0x7B,
}
autoKeyPressing = false
cancelAutoKeyPress = nil

addcmd('autokeypress',{'keypress'},function(args, speaker)
	if keypress and keyrelease and args[1] then
		local code = keycodeMap[args[1]:lower()]
		if not code then notify('Auto Key Press',"Invalid key") return end
		execCmd('unautokeypress')
		wait()
		local clickDelay = 0.1
		local releaseDelay = 0.1
		if args[2] and isNumber(args[2]) then clickDelay = args[2] end
		if args[3] and isNumber(args[3]) then releaseDelay = args[3] end
		autoKeyPressing = true
		cancelAutoKeyPress = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
			if not gameProcessedEvent then
				if (input.KeyCode == Enum.KeyCode.Backspace and UserInputService:IsKeyDown(Enum.KeyCode.Equals)) or (input.KeyCode == Enum.KeyCode.Equals and UserInputService:IsKeyDown(Enum.KeyCode.Backspace)) then
					autoKeyPressing = false
					cancelAutoKeyPress:Disconnect()
				end
			end
		end)
		notify('Auto Key Press',"Press [backspace] and [=] at the same time to stop")
		repeat wait(clickDelay)
			keypress(code)
			wait(releaseDelay)
			keyrelease(code)
		until autoKeyPressing == false
		if cancelAutoKeyPress then cancelAutoKeyPress:Disconnect() keyrelease(code) end
	else
		notify('Auto Key Press',"Your exploit doesn't have the ability to use auto key press")
	end
end)

addcmd('unautokeypress',{'noautokeypress','unkeypress','nokeypress'},function(args, speaker)
	autoKeyPressing = false
	if cancelAutoKeyPress then cancelAutoKeyPress:Disconnect() end
end)

addcmd('addplugin',{'plugin'},function(args, speaker)
	addPlugin(getstring(1))
end)

addcmd('removeplugin',{'deleteplugin'},function(args, speaker)
	deletePlugin(getstring(1))
end)

addcmd('reloadplugin',{},function(args, speaker)
	local pluginName = getstring(1)
	deletePlugin(pluginName)
	wait(1)
	addPlugin(pluginName)
end)

addcmd("addallplugins", {"loadallplugins"}, function(args, speaker)
    if not listfiles or not isfolder then
        notify("Incompatible Exploit", "Your exploit does not support this command (missing listfiles/isfolder)")
        return
    end

    for _, filePath in ipairs(listfiles("")) do
        local fileName = filePath:match("([^/\\]+%.iy)$")

        if fileName and
            fileName:lower() ~= "iy_fe.iy" and
            not isfolder(fileName) and
            not table.find(PluginsTable, fileName)
        then
            addPlugin(fileName)
        end
    end
end)

addcmd('removecmd',{'deletecmd'},function(args, speaker)
	removecmd(args[1])
end)

-- UI & Dev Tools Commands
addcmd("explorer", {"dex"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)

addcmd('olddex', {'odex'}, function(args, speaker)
	notify('Loading old explorer', 'Hold on a sec')
	
	local getobjects = function(a)
		local Objects = {}
		if a then
			local b = InsertService:LoadLocalAsset(a)
			if b then 
				table.insert(Objects, b) 
			end
		end
		return Objects
	end

	local Dex = getobjects("rbxassetid://10055842438")
	if Dex[1] then
		local function Load(Obj, Parent)
			local name = Obj.Name
			if not Parent then
				Parent = Dex[1]
			end
			for i,v in pairs(Obj:GetChildren()) do
				Load(v, Parent[v.Name])
			end
			if Obj:IsA("LocalScript") then
				local script = Parent
				local require = function(obj)
					local mt = getrawmetatable(obj)
					local namecall = mt.__namecall
					setreadonly(mt, false)
					mt.__namecall = function(self, ...)
						if getnamecallmethod() == "Destroy" and self == script then
						end
						return namecall(self, ...)
					end
					setreadonly(mt, true)
					return loadstring(obj.Source, obj:GetFullName())()
				end
				pcall(loadstring(Obj.Source, Obj:GetFullName()))
			end
		end
		Load(Dex[1])
		Dex[1].Parent = coreGui
	end
end)

addcmd('remotespy',{'rspy'},function(args, speaker)
	notify("Loading",'Hold on a sec')
	
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
end)

addcmd("console", {}, function(args, speaker)
    starterGui:SetCore("DevConsoleVisible", true)
end)

addcmd('oldconsole',{},function(args, speaker)
	
	notify("Loading",'Hold on a sec')
	local _, str = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/console.lua", true)
	end)

	local s, e = loadstring(str)
	if typeof(s) ~= "function" then
		return
	end

	local success, message = pcall(s)
	if (not success) then
		if printconsole then
			printconsole(message)
		elseif printoutput then
			printoutput(message)
		end
	end
	wait(1)
end)

addcmd('audiologger',{'alogger'},function(args, speaker)
	notify("Loading",'Hold on a sec')
	loadstring(game:HttpGet(('https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua'),true))()
end)

addcmd('discord', {'support', 'help'}, function(args, speaker)
	if everyClipboard or setclipboard or toclipboard then
		toClipboard('https://discord.gg/XVmJgHk3RG')
		notify('Discord Invite', 'Copied to clipboard!\nhttps://discord.gg/XVmJgHk3RG')
	else
		notify('Discord Invite', 'discord.gg/XVmJgHk3RG')
	end
	if httpRequest or httprequest or request or http_request then
		local reqfunc = httpRequest or httprequest or request or http_request
		reqfunc({
			Url = 'http://127.0.0.1:6463/rpc?v=1',
			Method = 'POST',
			Headers = {
				['Content-Type'] = 'application/json',
				Origin = 'https://discord.com'
			},
			Body = httpService:JSONEncode({
				cmd = 'INVITE_BROWSER',
				nonce = httpService:GenerateGUID(false),
				args = {code = 'XVmJgHk3RG'}
			})
		})
	end
end)

addcmd("console", {}, function(args, speaker)
    starterGui:SetCore("DevConsoleVisible", true)
end)

addcmd('oldconsole',{},function(args, speaker)
	
	notify("Loading",'Hold on a sec')
	local _, str = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/console.lua", true)
	end)

	local s, e = loadstring(str)
	if typeof(s) ~= "function" then
		return
	end

	local success, message = pcall(s)
	if (not success) then
		if printconsole then
			printconsole(message)
		elseif printoutput then
			printoutput(message)
		end
	end
	wait(1)
	notify('Console','Press F9 to open the console')
end)

addcmd("explorer", {"dex"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)

addcmd('olddex', {'odex'}, function(args, speaker)
	notify('Loading old explorer', 'Hold on a sec')

	local getobjects = function(a)
		local Objects = {}
		if a then
			local b = insertService:LoadLocalAsset(a)
			if b then 
				table.insert(Objects, b) 
			end
		end
		return Objects
	end

	local Dex = getobjects("rbxassetid://10055842438")[1]
	Dex.Parent = PARENT or coreGui

	local function Load(Obj, Url)
		local function GiveOwnGlobals(Func, Script)
			-- Fix for this edit of dex being poorly made
			local Fenv, RealFenv, FenvMt = {}, {
				script = Script,
				getupvalue = function(a, b)
					return nil -- force it to use globals
				end,
				getreg = function()
					return {} -- force it to use globals
				end,
				getprops = getprops or function(inst)
					if getproperties then
						local props = getproperties(inst)
						if props[1] and gethiddenproperty then
							local results = {}
							for _,name in pairs(props) do
								local success, res = pcall(gethiddenproperty, inst, name)
								if success then
									results[name] = res
								end
							end

							return results
						end

						return props
					end

					return {}
				end
			}, {}
			FenvMt.__index = function(a,b)
				return RealFenv[b] == nil and getgenv()[b] or RealFenv[b]
			end
			FenvMt.__newindex = function(a, b, c)
				if RealFenv[b] == nil then 
					getgenv()[b] = c 
				else 
					RealFenv[b] = c 
				end
			end
			setmetatable(Fenv, FenvMt)
			pcall(setfenv, Func, Fenv)
			return Func
		end

		local function LoadScripts(_, Script)
			if Script:IsA("LocalScript") then
				task.spawn(function()
					GiveOwnGlobals(loadstring(Script.Source,"="..Script:GetFullName()), Script)()
				end)
			end
			table.foreach(Script:GetChildren(), LoadScripts)
		end

		LoadScripts(nil, Obj)
	end

	Load(Dex)
end)

addcmd('remotespy',{'rspy'},function(args, speaker)
	notify("Loading",'Hold on a sec')
	
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
end)

addcmd('audiologger',{'alogger'},function(args, speaker)
	notify("Loading",'Hold on a sec')
	loadstring(game:HttpGet(('https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua'),true))()
end)

addcmd('discord', {'support', 'help'}, function(args, speaker)
	if everyClipboard or setclipboard or toclipboard then
		toClipboard('https://discord.gg/XVmJgHk3RG')
		notify('Discord Invite', 'Copied to clipboard!\nhttps://discord.gg/XVmJgHk3RG')
	else
		notify('Discord Invite', 'discord.gg/XVmJgHk3RG')
	end
	if httpRequest or httprequest or request or http_request then
		local reqfunc = httpRequest or httprequest or request or http_request
		pcall(function()
			reqfunc({
				Url = 'http://127.0.0.1:6463/rpc?v=1',
				Method = 'POST',
				Headers = {
					['Content-Type'] = 'application/json',
					Origin = 'https://discord.com'
				},
				Body = httpService:JSONEncode({
					cmd = 'INVITE_BROWSER',
					nonce = httpService:GenerateGUID(false),
					args = {code = 'XVmJgHk3RG'}
				})
			})
		end)
	end
end)

if IsOnMobile then
	local QuickCapture = Instance.new("TextButton")
	local UICorner = Instance.new("UICorner")
	QuickCapture.Name = randomString()
	QuickCapture.Parent = PARENT
	QuickCapture.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
	QuickCapture.BackgroundTransparency = 0.14
	QuickCapture.Position = UDim2.new(0.489, 0, 0, 0)
	QuickCapture.Size = UDim2.new(0, 32, 0, 33)
	QuickCapture.Font = Enum.Font.SourceSansBold
	QuickCapture.Text = "IY"
	QuickCapture.TextColor3 = Color3.fromRGB(255, 255, 255)
	QuickCapture.TextSize = 20
	QuickCapture.TextWrapped = true
	QuickCapture.ZIndex = 10
	QuickCapture.Draggable = true
	UICorner.Name = randomString()
	UICorner.CornerRadius = UDim.new(0.5, 0)
	UICorner.Parent = QuickCapture
	QuickCapture.MouseButton1Click:Connect(function()
		Cmdbar:CaptureFocus()
		maximizeHolder()
	end)
end

-- Ensure UIScale exists before use
if not Scale then
	Scale = Instance.new("UIScale")
end
pcall(function() Scale.Scale = math.max(Holder.AbsoluteSize.X / 1920, guiScale) end)
if ScaledHolder then Scale.Parent = ScaledHolder end

-- Disabled: ScreenGuis don't have a Size property; this was for IY's old UI structure
--[[
ScaledHolder.Size = UDim2.fromScale(1 / Scale.Scale, 1 / Scale.Scale)
Scale:GetPropertyChangedSignal("Scale"):Connect(function()
    ScaledHolder.Size = UDim2.fromScale(1 / Scale.Scale, 1 / Scale.Scale)
    for _, v in ScaledHolder:GetDescendants() do
        if v:IsA("GuiObject") and v.Visible then
            v.Visible = false
            v.Visible = true
        end
    end
end)
--]]

-- Dummy updateColors for IY compatibility (Sirius UI handles its own theming)
local function updateColors(color, ctype)
	-- No-op: Sirius UI uses its own color system
end

updateColors(currentShade1,shade1)
updateColors(currentShade2,shade2)
updateColors(currentShade3,shade3)
updateColors(currentText1,text1)
updateColors(currentText2,text2)
updateColors(currentScroll,scroll)

if PluginsTable ~= nil or PluginsTable ~= {} then
	FindPlugins(PluginsTable)
end

-- Lightweight EventEditor (Logic Only, No GUI)
eventEditor = (function()
	local events = {}
	local function registerEvent(name, sets)
		events[name] = {
			commands = {},
			sets = sets or {}
		}
	end

	local function fireEvent(name, ...)
		local args = {...}
		local event = events[name]
		if event then
			for i, cmd in pairs(event.commands) do
				local metCondition = true
				for idx, set in pairs(event.sets) do
					local argVal = args[idx]
					local cmdSet = cmd[2][idx]
					local condType = set.Type
					if condType == "Player" then
						if cmdSet == 0 then
							metCondition = metCondition and (tostring(Players.LocalPlayer) == argVal)
						elseif cmdSet ~= 1 then
							metCondition = metCondition and table.find(getPlayer(cmdSet, Players.LocalPlayer), argVal)
						end
					elseif condType == "String" then
						if cmdSet ~= 0 then
							metCondition = metCondition and string.find(argVal:lower(), cmdSet:lower())
						end
					elseif condType == "Number" then
						if cmdSet ~= 0 then
							metCondition = metCondition and tonumber(argVal) <= tonumber(cmdSet)
						end
					end
					if not metCondition then break end
				end

				if metCondition then
					task.spawn(function()
						local cmdStr = cmd[1]
						for count, arg in pairs(args) do
							cmdStr = cmdStr:gsub("%$" .. count, arg)
						end
						if cmd[3] then task.wait(cmd[3]) end
						execCmd(cmdStr)
					end)
				end
			end
		end
	end

	local function addCmd(eventName, cmdData)
		if events[eventName] then
			table.insert(events[eventName].commands, cmdData)
		end
	end

	local function loadData(data)
		if data then
			for name, eventData in pairs(data) do
				if events[name] then
					events[name].commands = eventData.commands or {}
				end
			end
		end
	end

	return {
		RegisterEvent = registerEvent,
		FireEvent = fireEvent,
		AddCmd = addCmd,
		LoadData = loadData,
		Refresh = function() end, -- No-op
		SaveData = function() return "" end, -- Dummy
		SetOnEdited = function() end -- Dummy
	}
end)()

-- Events
eventEditor.RegisterEvent("OnExecute")
eventEditor.RegisterEvent("OnSpawn",{
	{Type="Player",Name="Player Filter ($1)"}
})
eventEditor.RegisterEvent("OnDied",{
	{Type="Player",Name="Player Filter ($1)"}
})
eventEditor.RegisterEvent("OnDamage",{
	{Type="Player",Name="Player Filter ($1)"},
	{Type="Number",Name="Below Health ($2)"}
})
eventEditor.RegisterEvent("OnKilled",{
	{Type="Player",Name="Victim Player ($1)"},
	{Type="Player",Name="Killer Player ($2)",Default = 1}
})
eventEditor.RegisterEvent("OnJoin",{
	{Type="Player",Name="Player Filter ($1)",Default = 1}
})
eventEditor.RegisterEvent("OnLeave",{
	{Type="Player",Name="Player Filter ($1)",Default = 1}
})
eventEditor.RegisterEvent("OnChatted",{
	{Type="Player",Name="Player Filter ($1)",Default = 1},
	{Type="String",Name="Message Filter ($2)"}
})

function hookCharEvents(plr,instant)
	task.spawn(function()
		local char = plr.Character
		if not char then return end

		local humanoid = char:WaitForChild("Humanoid",10)
		if not humanoid then return end

		local oldHealth = humanoid.Health
		humanoid.HealthChanged:Connect(function(health)
			local change = math.abs(oldHealth - health)
			if oldHealth > health then
				eventEditor.FireEvent("OnDamage",plr.Name,tonumber(health))
			end
			oldHealth = health
		end)

		humanoid.Died:Connect(function()
			eventEditor.FireEvent("OnDied",plr.Name)

			local killedBy = humanoid:FindFirstChild("creator")
			if killedBy and killedBy.Value and killedBy.Value.Parent then
				eventEditor.FireEvent("OnKilled",plr.Name,killedBy.Name)
			end
		end)
	end)
end

Players.PlayerAdded:Connect(function(plr)
	eventEditor.FireEvent("OnJoin",plr.Name)
	if isLegacyChat then plr.Chatted:Connect(function(msg) eventEditor.FireEvent("OnChatted",tostring(plr),msg) end) end
	plr.CharacterAdded:Connect(function() eventEditor.FireEvent("OnSpawn",tostring(plr)) hookCharEvents(plr) end)
	JoinLog(plr)
	if isLegacyChat then ChatLog(plr) end
	if ESPenabled then
		repeat wait(1) until plr.Character and getRoot(plr.Character)
		ESP(plr)
	end
	if CHMSenabled then
		repeat wait(1) until plr.Character and getRoot(plr.Character)
		CHMS(plr)
	end
end)

if not isLegacyChat then
    TextChatService.MessageReceived:Connect(function(message)
        if message.TextSource then
            local player = Players:GetPlayerByUserId(message.TextSource.UserId)
            if not player then return end

            if logsEnabled == true then
                CreateLabel(player.Name, message.Text)
            end
            if player.UserId == Players.LocalPlayer.UserId then
                do_exec(message.Text, Players.LocalPlayer)
            end
            eventEditor.FireEvent("OnChatted", player.Name, message.Text)
            sendChatWebhook(player, message.Text)
        end
    end)
end

for _,plr in pairs(Players:GetPlayers()) do
	pcall(function()
		plr.CharacterAdded:Connect(function() eventEditor.FireEvent("OnSpawn",tostring(plr)) hookCharEvents(plr) end)
		hookCharEvents(plr)
	end)
end

if loadedEventData then eventEditor.LoadData(loadedEventData) end
eventEditor.Refresh()

eventEditor.FireEvent("OnExecute")

if aliases and #aliases > 0 then
	local cmdMap = {}
	for i,v in pairs(cmds) do
		cmdMap[v.NAME:lower()] = v
		for _,alias in pairs(v.ALIAS) do
			cmdMap[alias:lower()] = v
		end
	end
	for i = 1, #aliases do
		local cmd = string.lower(aliases[i].CMD)
		local alias = string.lower(aliases[i].ALIAS)
		if cmdMap[cmd] then
			customAlias[alias] = cmdMap[cmd]
		end
	end
	-- refreshaliases()
end

function create(data)
local insts = {}
for i,v in pairs(data) do insts[v[1]] = Instance.new(v[2]) end
for i,v in pairs(data) do
local p = insts[v[1]]
for prop,val in pairs(v[3]) do
if prop ~= 'Parent' then
p[prop] = val
end
end
if v[3].Parent then
local parent = v[3].Parent
if type(parent) == 'table' and insts[parent[1]] then
p.Parent = insts[parent[1]]
else
p.Parent = parent
end
end
end
return insts[1]
end

ViewportTextBox = (function()
	local TextService = game:GetService("TextService")
	local funcs = {}
	funcs.Update = function(self)
		local cursorPos = self.TextBox.CursorPosition
		local text = self.TextBox.Text
		if text == "" then self.TextBox.Position = UDim2.new(0,2,0,0) return end
		if cursorPos == -1 then return end

		local cursorText = text:sub(1,cursorPos-1)
		local pos = nil
		local leftEnd = -self.TextBox.Position.X.Offset
		local rightEnd = leftEnd + self.View.AbsoluteSize.X

		local totalTextSize = TextService:GetTextSize(text,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X
		local cursorTextSize = TextService:GetTextSize(cursorText,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X

		if cursorTextSize > rightEnd then
			pos = math.max(-2,cursorTextSize - self.View.AbsoluteSize.X + 2)
		elseif cursorTextSize < leftEnd then
			pos = math.max(-2,cursorTextSize-2)
		elseif totalTextSize < rightEnd then
			pos = math.max(-2,totalTextSize - self.View.AbsoluteSize.X + 2)
		end

		if pos then
			self.TextBox.Position = UDim2.new(0,-pos,0,0)
			self.TextBox.Size = UDim2.new(1,pos,1,0)
		end
	end

	local mt = {}
	mt.__index = funcs

	local function convert(textbox)
		local obj = setmetatable({OffsetX = 0, TextBox = textbox},mt)

		local view = Instance.new("Frame")
		view.BackgroundTransparency = textbox.BackgroundTransparency
		view.BackgroundColor3 = textbox.BackgroundColor3
		view.BorderSizePixel = textbox.BorderSizePixel
		view.BorderColor3 = textbox.BorderColor3
		view.Position = textbox.Position
		view.Size = textbox.Size
		view.ClipsDescendants = true
		view.Name = textbox.Name
		view.ZIndex = 10
		textbox.BackgroundTransparency = 1
		textbox.Position = UDim2.new(0,4,0,0)
		textbox.Size = UDim2.new(1,-8,1,0)
		textbox.TextXAlignment = Enum.TextXAlignment.Left
		textbox.Name = "Input"
		table.insert(text1,textbox)
		table.insert(shade2,view)

		obj.View = view

		textbox.Changed:Connect(function(prop)
			if prop == "Text" or prop == "CursorPosition" or prop == "AbsoluteSize" then
				obj:Update()
			end
		end)

		obj:Update()

		view.Parent = textbox.Parent
	textbox.Parent = view

	return obj
end

	return {convert = convert}
end)()

local defaultGuiScale = 1
local defaultsettings = {
	prefix = '!',
	StayOpen = false,
	guiScale = defaultGuiScale,
	keepIY = true,
	espTransparency = 0.3,
	logsEnabled = false,
	jLogsEnabled = false,
	logsWebhook = nil,
	aliases = {},
	binds = {},
	WayPoints = {},
	PluginsTable = {},
	currentShade1 = {0,0,0},
	currentShade2 = {0,0,0},
	currentShade3 = {0,0,0},
	currentText1 = {255,255,255},
	currentText2 = {255,255,255},
	currentScroll = {0,0,0}
}
defaults = HttpService:JSONEncode(defaultsettings)
nosaves = false
jsonAttempts = jsonAttempts or 0
useFactorySettings = function()
    prefix = '!'
    StayOpen = false
    guiScale = defaultGuiScale
    KeepSirius = true
    espTransparency = 0.3
    logsEnabled = false
    jLogsEnabled = false
    logsWebhook = nil
    aliases = {}
    binds = {}
    WayPoints = {}
    PluginsTable = {}
end
function saves()
	jsonAttempts = jsonAttempts or 0
    print("[Sirius] saves() called. Attempt:", jsonAttempts)
    if writefileExploit() and readfileExploit() and jsonAttempts < 10 then
        local readSuccess, out = readfile("Sirius_FE.iy", true)
        if readSuccess then
            if out ~= nil and tostring(out):gsub("%s", "") ~= "" then
                local success, response = pcall(function()
                    local json = HttpService:JSONDecode(out)
                    if vtype(json.prefix, "string") then prefix = json.prefix else prefix = '!' end
                    if vtype(json.StayOpen, "boolean") then StayOpen = json.StayOpen else StayOpen = false end
                    if vtype(json.guiScale, "number") then guiScale = json.guiScale else guiScale = defaultGuiScale end
                    if vtype(json.keepIY, "boolean") then KeepSirius = json.keepIY else KeepSirius = true end
                    if vtype(json.espTransparency, "number") then espTransparency = json.espTransparency else espTransparency = 0.3 end
                    if vtype(json.logsEnabled, "boolean") then logsEnabled = json.logsEnabled else logsEnabled = false end
                    if vtype(json.jLogsEnabled, "boolean") then jLogsEnabled = json.jLogsEnabled else jLogsEnabled = false end
                    if vtype(json.logsWebhook, "string") then logsWebhook = json.logsWebhook else logsWebhook = nil end
                    if vtype(json.aliases, "table") then aliases = json.aliases else aliases = {} end
                    if vtype(json.binds, "table") then binds = json.binds else binds = {} end
                    if vtype(json.spawnCmds, "table") then spawnCmds = json.spawnCmds end
                    if vtype(json.WayPoints, "table") then AllWaypoints = json.WayPoints else WayPoints = {} AllWaypoints = {} end
                    if vtype(json.PluginsTable, "table") then PluginsTable = json.PluginsTable else PluginsTable = {} end
                    if vtype(json.currentShade1, "table") then currentShade1 = Color3.new(json.currentShade1[1],json.currentShade1[2],json.currentShade1[3]) end
                    if vtype(json.currentShade2, "table") then currentShade2 = Color3.new(json.currentShade2[1],json.currentShade2[2],json.currentShade2[3]) end
                    if vtype(json.currentShade3, "table") then currentShade3 = Color3.new(json.currentShade3[1],json.currentShade3[2],json.currentShade3[3]) end
                    if vtype(json.currentText1, "table") then currentText1 = Color3.new(json.currentText1[1],json.currentText1[2],json.currentText1[3]) end
                    if vtype(json.currentText2, "table") then currentText2 = Color3.new(json.currentText2[1],json.currentText2[2],json.currentText2[3]) end
                    if vtype(json.currentScroll, "table") then currentScroll = Color3.new(json.currentScroll[1],json.currentScroll[2],json.currentScroll[3]) end
                    if vtype(json.eventBinds, "string") then loadedEventData = json.eventBinds end
                end)
                if not success then
                    jsonAttempts = jsonAttempts + 1
                    warn("Save Json Error:", response)
                    warn("Overwriting Save File")
                    writefile("Sirius_FE.iy", defaults, true)
                    wait()
                    saves()
                end
            else
                writefile("Sirius_FE.iy", defaults, true)
                wait()
                local dReadSuccess, dOut = readfile("Sirius_FE.iy", true)
                if dReadSuccess and dOut ~= nil and tostring(dOut):gsub("%s", "") ~= "" then
                    saves()
                else
                    nosaves = true
                    useFactorySettings()
                    warn("There was a problem writing a save file to your PC. Check console for details.")
                    notify("Save Error", "Problem writing save file. Check console.")
                end
            end
        else
            writefile("Sirius_FE.iy", defaults, true)
            wait()
            local dReadSuccess, dOut = readfile("Sirius_FE.iy", true)
            if dReadSuccess and dOut ~= nil and tostring(dOut):gsub("%s", "") ~= "" then
                saves()
            else
                nosaves = true
                useFactorySettings()
                createPopup("There was a problem writing a save file to your PC.\n\nPlease contact the developer/support team for your exploit and tell them writefile/readfile is not working.\n\nYour settings, keybinds, waypoints, and aliases will not save if you continue.\n\nThings to try:\n> Make sure a 'workspace' folder is located in the same folder as your exploit\n> If your exploit is inside of a zip/rar file, extract it.\n> Rejoin the game and try again or restart your PC and try again.")
            end
        end
    else
        if jsonAttempts >= 10 then
            nosaves = true
            useFactorySettings()
            warn("Sorry, we have attempted to parse your save file, but it is unreadable! Using factory settings.")
            notify("Save Error", "Save file unreadable. Using factory settings.")
        else
            nosaves = true
            useFactorySettings()
        end
    end
end

print("[Sirius] Calling saves()...")
saves()
print("[Sirius] saves() finished.")

function updatesaves()
	if nosaves == false and writefileExploit() then
		local update = {
			prefix = prefix;
			StayOpen = StayOpen;
			guiScale = guiScale;
			keepIY = KeepSirius;
			espTransparency = espTransparency;
			logsEnabled = logsEnabled;
			jLogsEnabled = jLogsEnabled;
			logsWebhook = logsWebhook;
			aliases = aliases;
			binds = binds or {};
			WayPoints = AllWaypoints;
			PluginsTable = PluginsTable;
			currentShade1 = {currentShade1.R,currentShade1.G,currentShade1.B};
			currentShade2 = {currentShade2.R,currentShade2.G,currentShade2.B};
			currentShade3 = {currentShade3.R,currentShade3.G,currentShade3.B};
			currentText1 = {currentText1.R,currentText1.G,currentText1.B};
			currentText2 = {currentText2.R,currentText2.G,currentText2.B};
			currentScroll = {currentScroll.R,currentScroll.G,currentScroll.B};
			eventBinds = eventEditor.SaveData()
		}
		writefileCooldown("Sirius_FE.iy", HttpService:JSONEncode(update))
	end
end

	-- Apply any saved spawn commands now that saves() has populated spawnCmds
	if spawnCmds and #spawnCmds > 0 then
		for i,v in pairs(spawnCmds) do
			eventEditor.AddCmd("OnSpawn",{v.COMMAND or "",{0},v.DELAY or 0})
		end
		updatesaves()
	end

	eventEditor.SetOnEdited(updatesaves)



end -- End IY Scope

-- Sirius Command Bar Implementation
print("Creating Sirius Command Bar...")
UserInputService = UserInputService or game:GetService('UserInputService')
TweenService = TweenService or game:GetService('TweenService')
Players = Players or game:GetService('Players')
LocalPlayer = LocalPlayer or Players.LocalPlayer
Mouse = Mouse or LocalPlayer:GetMouse()
local cmdFadeDuration = 0.08

SiriusCmdGui = SiriusCmdGui or Instance.new('ScreenGui')
SiriusCmdGui.Name = 'SiriusCommandBar'
SiriusCmdGui.Parent = gethui()
SiriusCmdGui.Enabled = false

CmdFrame = CmdFrame or Instance.new('Frame')
CmdFrame.Name = 'CmdFrame'
CmdFrame.Parent = SiriusCmdGui
CmdFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CmdFrame.BorderSizePixel = 0
CmdFrame.Position = UDim2.new(0.5, -250, 0.8, 0) -- Bottom center
CmdFrame.Size = UDim2.new(0, 500, 0, 40)
CmdFrame.AnchorPoint = Vector2.new(0.5, 0.5)

CmdFrameCorner = CmdFrameCorner or Instance.new('UICorner')
CmdFrameCorner.CornerRadius = UDim.new(0, 8)
CmdFrameCorner.Parent = CmdFrame

CmdInput = CmdInput or Instance.new('TextBox')
CmdInput.Name = 'CmdInput'
CmdInput.Parent = CmdFrame
CmdInput.BackgroundTransparency = 1
CmdInput.Position = UDim2.new(0, 10, 0, 0)
CmdInput.Size = UDim2.new(1, -20, 1, 0)
CmdInput.Font = Enum.Font.Gotham
CmdInput.Text = ''
CmdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CmdInput.TextSize = 18
CmdInput.PlaceholderText = 'Command...'
CmdInput.TextXAlignment = Enum.TextXAlignment.Left

-- Define Cmdbar for IY compatibility
Cmdbar = CmdInput

SuggestionFrame = SuggestionFrame or Instance.new('ScrollingFrame')
SuggestionFrame.Name = 'SuggestionFrame'
SuggestionFrame.Parent = CmdFrame
SuggestionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SuggestionFrame.BorderSizePixel = 0
SuggestionFrame.Position = UDim2.new(0, 0, 0, -160) -- Above the input
SuggestionFrame.Size = UDim2.new(1, 0, 0, 150)
SuggestionFrame.Visible = false
SuggestionFrame.ScrollBarThickness = 4
SuggestionFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
SuggestionFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

SuggestionLayout = SuggestionLayout or Instance.new('UIListLayout')
SuggestionLayout.Parent = SuggestionFrame
SuggestionLayout.SortOrder = Enum.SortOrder.LayoutOrder

SuggestionCorner = SuggestionCorner or Instance.new('UICorner')
SuggestionCorner.CornerRadius = UDim.new(0, 8)
SuggestionCorner.Parent = SuggestionFrame

local function updateSuggestions()
    local text = CmdInput.Text
    for _, child in pairs(SuggestionFrame:GetChildren()) do
        if child:IsA('TextButton') then child:Destroy() end
    end

    if text == '' then
        SuggestionFrame.Visible = false
        return
    end

    local matches = {}
    local lowerText = text:lower()

    for _, cmd in pairs(cmds) do
        if cmd.NAME:lower():find(lowerText, 1, true) then
            table.insert(matches, cmd.NAME)
        else
            for _, alias in pairs(cmd.ALIAS) do
                if alias:lower():find(lowerText, 1, true) then
                    table.insert(matches, alias)
                end
            end
        end
    end

    -- Remove duplicates
    local uniqueMatches = {}
    local hash = {}
    for _, v in ipairs(matches) do
        if not hash[v] then
            uniqueMatches[#uniqueMatches + 1] = v
            hash[v] = true
        end
    end
    matches = uniqueMatches

    table.sort(matches)

    if #matches > 0 then
        SuggestionFrame.Visible = true
        local count = 0
        for _, match in ipairs(matches) do
            if count >= 10 then break end -- Limit to 10 suggestions
            count = count + 1
            
            local btn = Instance.new('TextButton')
            btn.Parent = SuggestionFrame
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.BackgroundTransparency = 1
            btn.Text = '  ' .. match
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            
            btn.MouseButton1Click:Connect(function()
                CmdInput.Text = match .. ' '
                CmdInput:CaptureFocus()
                SuggestionFrame.Visible = false
            end)
        end
        SuggestionFrame.CanvasSize = UDim2.new(0, 0, 0, count * 25)
        -- Adjust height if fewer than max items
        local height = math.min(count * 25, 150)
        SuggestionFrame.Size = UDim2.new(1, 0, 0, height)
        SuggestionFrame.Position = UDim2.new(0, 0, 0, -height - 5)
    else
        SuggestionFrame.Visible = false
    end
end

CmdInput:GetPropertyChangedSignal('Text'):Connect(updateSuggestions)

-- Toggle Key
local ToggleKey = Enum.KeyCode.F

--[[
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == ToggleKey then
        SiriusCmdGui.Enabled = not SiriusCmdGui.Enabled
        if SiriusCmdGui.Enabled then
            CmdInput:CaptureFocus()
        else
            SuggestionFrame.Visible = false
        end
    end
end)
--]]

CmdInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local text = CmdInput.Text
        if text ~= '' then
            execCmd(text, LocalPlayer)
        end
        CmdInput.Text = ''
        SiriusCmdGui.Enabled = false
        SuggestionFrame.Visible = false
    end
end)

-- Hide command bar
hideCommandBar = function()
	if not Input or not SearchContainer then return end
	Input:ReleaseFocus()
	SuggestionFrame.Visible = false
	SearchContainer.Visible = false
end

-- Keybind to open command bar
--[[
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Check if the input is the prefix key (semicolon by default)
    if input.KeyCode == Enum.KeyCode.F or (input.UserInputType == Enum.UserInputType.Keyboard and string.char(input.KeyCode.Value):lower() == prefix:lower()) then
        SiriusCmdGui.Enabled = not SiriusCmdGui.Enabled
        if SiriusCmdGui.Enabled then
            CmdInput:CaptureFocus()
        else
            CmdInput:ReleaseFocus()
            SuggestionFrame.Visible = false
        end
    end
end)
--]]

-- xylex & europa
local iyassets = {
    ["infiniteyield/assets/bindsandplugins.png"] = "rbxassetid://5147695474",
    ["infiniteyield/assets/close.png"] = "rbxassetid://5054663650",
    ["infiniteyield/assets/editaliases.png"] = "rbxassetid://5147488658",
    ["infiniteyield/assets/editkeybinds.png"] = "rbxassetid://129697930",
    ["infiniteyield/assets/edittheme.png"] = "rbxassetid://4911962991",
    ["infiniteyield/assets/editwaypoints.png"] = "rbxassetid://5147488592",
    ["infiniteyield/assets/imgstudiopluginlogo.png"] = "rbxassetid://4113050383",
    ["infiniteyield/assets/logo.png"] = "rbxassetid://1352543873",
    ["infiniteyield/assets/minimize.png"] = "rbxassetid://2406617031",
    ["infiniteyield/assets/pin.png"] = "rbxassetid://6234691350",
    ["infiniteyield/assets/reference.png"] = "rbxassetid://3523243755",
    ["infiniteyield/assets/settings.png"] = "rbxassetid://1204397029"
}

local function getcustomasset(asset)
    if waxgetcustomasset then
        local success, result = pcall(function()
            return waxgetcustomasset(asset)
        end)
        if success and result ~= nil and result ~= "" then
            return result
        end
    end
    return iyassets[asset]
end

pWayPoints = {}
WayPoints = {}
AllWaypoints = AllWaypoints or {}
PlaceId = game.PlaceId

if AllWaypoints and #AllWaypoints > 0 then
	for i = 1, #AllWaypoints do
		if not AllWaypoints[i].GAME or AllWaypoints[i].GAME == PlaceId then
			WayPoints[#WayPoints + 1] = {NAME = AllWaypoints[i].NAME, COORD = {AllWaypoints[i].COORD[1], AllWaypoints[i].COORD[2], AllWaypoints[i].COORD[3]}, GAME = AllWaypoints[i].GAME}
		end
	end
end

if type(binds) ~= "table" then binds = {} end

if type(PluginsTable) == "table" then
    for i = #PluginsTable, 1, -1 do
        if string.sub(PluginsTable[i], -3) ~= ".iy" then
            table.remove(PluginsTable, i)
        end
    end
end

function Time()
	local HOUR = math.floor((tick() % 86400) / 3600)
	local MINUTE = math.floor((tick() % 3600) / 60)
	local SECOND = math.floor(tick() % 60)
	local AP = HOUR > 11 and 'PM' or 'AM'
	HOUR = (HOUR % 12 == 0 and 12 or HOUR % 12)
	HOUR = HOUR < 10 and '0' .. HOUR or HOUR
	MINUTE = MINUTE < 10 and '0' .. MINUTE or MINUTE
	SECOND = SECOND < 10 and '0' .. SECOND or SECOND
	return HOUR .. ':' .. MINUTE .. ':' .. SECOND .. ' ' .. AP
end

-- UI Implementation (reuse globals to stay under local limit)
	SiriusGui = SiriusGui or Instance.new("ScreenGui")
	SiriusGui.Name = "SiriusUI"
	SiriusParent = SiriusParent or (gethui and gethui()) or CoreGui
	if not SiriusParent then SiriusParent = CoreGui end
	SiriusGui.Parent = SiriusParent
	SiriusGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	SiriusGui.ResetOnSpawn = false

-- Notifications Setup
NotifyContainer = NotifyContainer or Instance.new("Frame")
NotifyContainer.Name = "NotifyContainer"
NotifyContainer.Size = UDim2.new(0, 300, 1, 0)
NotifyContainer.Position = UDim2.new(1, -310, 0, 0)
NotifyContainer.AnchorPoint = Vector2.new(0, 0)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.Parent = SiriusGui

NotifyContainer.AnchorPoint = Vector2.new(0, 1)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.Parent = SiriusGui
NotifyLayout.Parent = NotifyContainer
NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifyLayout.Padding = UDim.new(0, 10)

-- Custom Notify Function
function notify(title, text, duration)
    duration = duration or 4
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 0) -- Start height 0 for animation
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.BackgroundTransparency = 1
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = NotifyContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(50, 50, 50)
    Stroke.Thickness = 1
    Stroke.Transparency = 1
    Stroke.Parent = Frame
    
    local Title = Instance.new("TextLabel")
    Title.Text = title or "Notification"
    Title.Size = UDim2.new(1, -20, 0, 20)
    Title.Position = UDim2.new(0, 12, 0, 8)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextTransparency = 1
    Title.Parent = Frame
    
    local Desc = Instance.new("TextLabel")
    Desc.Text = text or ""
    Desc.Size = UDim2.new(1, -20, 0, 30)
    Desc.Position = UDim2.new(0, 12, 0, 28)
    Desc.BackgroundTransparency = 1
    Desc.TextColor3 = Color3.fromRGB(200, 200, 200)
    Desc.Font = Enum.Font.Gotham
    Desc.TextSize = 13
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.TextWrapped = true
    Desc.TextTransparency = 1
    Desc.Parent = Frame
    
    -- Animate In
    local targetHeight = 70
    TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight), BackgroundTransparency = 0.1}):Play()
    TweenService:Create(Stroke, TweenInfo.new(0.4), {Transparency = 0}):Play()
    task.wait(0.1)
    TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(Desc, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    
    -- Animate Out
    task.delay(duration, function()
        TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(Desc, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}):Play()
        task.wait(0.4)
        Frame:Destroy()
    end)
end

-- queueNotification is already defined at line 4168 with proper Sirius notification

-- Overwrite global aliases
Cmdbar = CmdInput
Cmdbar_2 = CmdInput
Cmdbar_3 = CmdInput

pWayPoints = {}
WayPoints = {}
AllWaypoints = AllWaypoints or {}
PlaceId = game.PlaceId

if AllWaypoints and #AllWaypoints > 0 then
	for i = 1, #AllWaypoints do
		if not AllWaypoints[i].GAME or AllWaypoints[i].GAME == PlaceId then
			WayPoints[#WayPoints + 1] = {NAME = AllWaypoints[i].NAME, COORD = {AllWaypoints[i].COORD[1], AllWaypoints[i].COORD[2], AllWaypoints[i].COORD[3]}, GAME = AllWaypoints[i].GAME}
		end
	end
end

print('Sirius Loaded')

if not eventEditor then
	warn("Sirius: eventEditor is nil!")
	notify("Error", "eventEditor failed to load")
else
	notify("Sirius Loaded", "Press 'ff in the chat!!!!' to open command bar")
end

-- [[ Sirius Music Player Integration ]] --
-- NOTE: Spotify module is loaded on-demand when the Music button is clicked.
-- See initSpotifyModule() function for the loading logic.



end
