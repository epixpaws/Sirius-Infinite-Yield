local SiriusSpotify = {}

local httpService
local tweenService
local userInputService
local runService
local guiService
local contentProvider
local players
local lighting

local httpRequest
local UI
local siriusValues
local queueNotification
local getcustomasset
local teleportService

local spotifyEnabled = true
local spotifyInterval = 0.3
local userToken = nil
local currentCover = ""
local currentArtistCover = ""
local shuffleEnabled = false
local loopEnabled = false
local isPlaying = false
local isSeeking = false
local durationMs = 0
local spotifyUpdateRoutine = nil
local musicPanel = nil

local spotifyMain = nil
local playlistBrowser = nil
local dynamicIsland = nil
local dynamicIslandControls = nil
local dynamicIslandProgress = nil
local dynamicIslandTitle = nil
local dynamicIslandArtist = nil
local dynamicIslandArt = nil
local dynamicIslandPlay = nil
local dynamicIslandPlayIcon = nil
local dynamicIslandState = {expanded = false, hasSong = false}
local dynamicIslandShow = nil

local startSpotifyUpdateLoop
local updateSpotifyUI
local updateDynamicIsland

local function encode(a)
	return httpService:JSONEncode(a)
end

local function decode(a)
	return httpService:JSONDecode(a)
end

local function round(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

local function convertMs(ms)
	local seconds = round(ms / 1000, 2)
	local minutes = math.floor(seconds / 60)
	seconds = math.floor(seconds - (minutes * 60))

	if #tostring(seconds) < 2 then
		seconds = "0"..seconds
	end

	return string.format("%s:%s", minutes, seconds)
end

local function checkSirius()
	return UI ~= nil and UI.Parent ~= nil
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

local function smoothDrag(frame)
	local dragging, dragInput, dragStart, startPos
	local dragSpeed = 0.15

	local function update(input)
		local delta = input.Position - dragStart
		local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		tweenService:Create(frame, TweenInfo.new(dragSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
	end

	frame.InputBegan:Connect(function(input)
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

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	userInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

local function enableSmoothScroll(scrollFrame)
	local targetPos = scrollFrame.CanvasPosition.Y
	local currentPos = scrollFrame.CanvasPosition.Y
	
	scrollFrame.ScrollingEnabled = false
	
	scrollFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local maxScroll = math.max(0, scrollFrame.AbsoluteCanvasSize.Y - scrollFrame.AbsoluteWindowSize.Y)
			local scrollAmount = 120
			if input.Position.Z > 0 then
				targetPos = math.max(0, targetPos - scrollAmount)
			else
				targetPos = math.min(maxScroll, targetPos + scrollAmount)
			end
		end
	end)
	
	local connection
	connection = runService.RenderStepped:Connect(function(dt)
		if not scrollFrame or not scrollFrame.Parent then
			connection:Disconnect()
			return
		end
		
		local maxScroll = math.max(0, scrollFrame.AbsoluteCanvasSize.Y - scrollFrame.AbsoluteWindowSize.Y)
		targetPos = math.clamp(targetPos, 0, maxScroll)
		
		currentPos = currentPos + (targetPos - currentPos) * 15 * dt
		scrollFrame.CanvasPosition = Vector2.new(0, currentPos)
	end)
end

local function makeSpotifyRequest(token, url, method, body)
	local requestData = {
		Url = "https://api.spotify.com/v1/"..url,
		Method = method ~= nil and method:upper() or "GET",
		Headers = {
			['Authorization'] = "Bearer "..(token or userToken),
			['Content-Type'] = "application/json"
		}
	}

	if method == "POST" or method == "PUT" then
		requestData.Body = body or ""
	end

	local success, response = pcall(function()
		return httpRequest(requestData)
	end)

	if not success then
		return nil
	end

	local parsedBody = response.Body ~= nil and response.Body ~= "" and decode(response.Body) or nil

	if parsedBody and parsedBody.error then
		if parsedBody.error.message == "The access token expired" then
			if userToken then
				if queueNotification then
					queueNotification("Spotify Session Expired", "Please re-enter your token.", 9622474485)
				end
				userToken = nil
				
				if musicPanel then
					local contentArea = musicPanel:FindFirstChild("ContentArea")
					local tokenSection = musicPanel:FindFirstChild("TokenSection")
					local glowFrame = musicPanel:FindFirstChild("GlowFrame")
					
					if contentArea then contentArea.Visible = false end
					if tokenSection then tokenSection.Visible = true end
					if glowFrame then glowFrame.Visible = false end
				end
			end
			return nil
		else
			if queueNotification then
				queueNotification("Spotify Error", parsedBody.error.message, 9622474485)
			end
			return nil
		end
	end

	return parsedBody or ""
end

local function checkSpotifyToken(token)
	local data = makeSpotifyRequest(token, "me")
	if data == nil then return false end
	return rawget(data, "display_name") ~= nil
end

local function getArtistCover(token, id)
	local data = makeSpotifyRequest(token, "artists/"..id)
	if not data or not data.images or #data.images == 0 then return nil end
	return data.images[2] and data.images[2].url or data.images[1].url
end

local function getCurrentlyPlaying(token)
	local data = makeSpotifyRequest(token, "me/player/currently-playing")
	if not data or not data.item then return nil end

	local artists = {}
	local artistNames = {}

	if data.item.artists then
		for _, v in pairs(data.item.artists) do
			table.insert(artists, {name = v.name, id = v.id})
			table.insert(artistNames, v.name)
		end
	end

	local images = {
		songCover = data.item.album.images[2] and data.item.album.images[2].url or data.item.album.images[1].url,
		artistCover = getArtistCover(token, artists[1].id)
	}

	durationMs = data.item.duration_ms

	return {
		token = token,
		artists = artists,
		artistNames = artistNames,
		images = images,
		song = {name = data.item.name, id = data.item.id},
		playback = {current = data.progress_ms, total = data.item.duration_ms, playing = data.is_playing},
		album = {id = data.item.album.id}
	}
end

local function getCurrentState(token)
	local data = makeSpotifyRequest(token, "me/player")
	if not data or not data.device then return nil end

	return {
		shuffle = data.shuffle_state,
		loop = data.repeat_state,
		volume = data.device.volume_percent,
		playing = data.is_playing
	}
end

local function getUserPlaylists(token)
	local data = makeSpotifyRequest(token, "me/playlists?limit=50")
	if not data or not data.items then return {} end
	return data.items
end

local function getPlaylistTracks(token, playlistId)
	local data = makeSpotifyRequest(token, "playlists/"..playlistId.."/tracks?limit=100")
	if not data or not data.items then return {} end
	return data.items
end

local function spotifyPrevious()
	makeSpotifyRequest(userToken, "me/player/previous", "POST")
end

local function spotifyNext()
	makeSpotifyRequest(userToken, "me/player/next", "POST")
end

local function spotifyResume()
	makeSpotifyRequest(userToken, "me/player/play", "PUT")
end

local function spotifyPause()
	makeSpotifyRequest(userToken, "me/player/pause", "PUT")
end

local function spotifyShuffle(enabled)
	makeSpotifyRequest(userToken, "me/player/shuffle?state="..tostring(enabled), "PUT")
end

local function spotifyRepeat(enabled)
	makeSpotifyRequest(userToken, "me/player/repeat?state="..(enabled and "context" or "off"), "PUT")
end

local function spotifySeek(ms)
	makeSpotifyRequest(userToken, "me/player/seek?position_ms="..ms, "PUT")
end

local function spotifyPlayTrack(uri)
	local body = encode({uris = {uri}})
	makeSpotifyRequest(userToken, "me/player/play", "PUT", body)
end

local dynamicIslandConnection

local function createDynamicIsland()
	local guiParent = gethui and gethui() or game:GetService("CoreGui")
	local existingGui = guiParent:FindFirstChild("SiriusDynamicIslandGui")
	if existingGui then existingGui:Destroy() end
	
	if dynamicIslandConnection then
		dynamicIslandConnection:Disconnect()
		dynamicIslandConnection = nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SiriusDynamicIslandGui"
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = guiParent

	local localState = {
		isPlaying = false,
		duration = 0,
		position = 0,
		lastUpdate = tick(),
		hasSong = false
	}

	local Spring = {}
	Spring.__index = Spring

	function Spring.new(damping, speed)
		local self = setmetatable({}, Spring)
		self.Target = 0
		self.Position = 0
		self.Velocity = 0
		self.Damping = damping or 0.8
		self.Speed = speed or 15
		return self
	end

	function Spring:Update(dt)
		local force = (self.Target - self.Position) * (self.Speed ^ 2)
		local damping = -self.Velocity * 2 * self.Damping * self.Speed
		local acceleration = force + damping
		self.Velocity = self.Velocity + acceleration * dt
		self.Position = self.Position + self.Velocity * dt
		return self.Position
	end

	function Spring:SetTarget(target)
		self.Target = target
	end

	function Spring:SnapTo(value)
		self.Position = value
		self.Target = value
		self.Velocity = 0
	end

	local hiddenPos = UDim2.new(0.5, 0, -0.15, 0)
	local shownPos = UDim2.new(0.5, 0, 0.02, 0)

	dynamicIsland = Instance.new("Frame")
	dynamicIsland.Name = "DynamicIsland"
	dynamicIsland.AnchorPoint = Vector2.new(0.5, 0)
	dynamicIsland.Position = hiddenPos
	dynamicIsland.Size = UDim2.fromOffset(400, 54)
	dynamicIsland.BackgroundColor3 = Color3.new(0, 0, 0)
	dynamicIsland.BackgroundTransparency = 0.06
	dynamicIsland.ClipsDescendants = true
	dynamicIsland.Visible = false
	dynamicIsland.ZIndex = 1000
	dynamicIsland.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = dynamicIsland

	local uiScale = Instance.new("UIScale")
	uiScale.Scale = 1
	uiScale.Parent = dynamicIsland

	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.Position = UDim2.new(0.5, 0, 0.5, 8)
	shadow.Size = UDim2.new(2.0, 0, 3.3, 0)
	shadow.Image = "rbxassetid://8805129536"
	shadow.ImageColor3 = Color3.new(0, 0, 0)
	shadow.ImageTransparency = 0.42
	shadow.ZIndex = 999
	shadow.Parent = dynamicIsland

	local compactContainer = Instance.new("CanvasGroup")
	compactContainer.Name = "CompactContainer"
	compactContainer.BackgroundTransparency = 1
	compactContainer.GroupTransparency = 0
	compactContainer.Size = UDim2.new(1, 0, 1, 0)
	compactContainer.ZIndex = 1001
	compactContainer.Parent = dynamicIsland

	local compactArt = Instance.new("ImageLabel")
	compactArt.Name = "CompactArt"
	compactArt.AnchorPoint = Vector2.new(0, 0.5)
	compactArt.Position = UDim2.new(0, 6, 0.5, 0)
	compactArt.Size = UDim2.fromOffset(42, 42)
	compactArt.BackgroundTransparency = 1
	compactArt.Image = ""
	compactArt.ScaleType = Enum.ScaleType.Crop
	compactArt.Parent = compactContainer
	local cac = Instance.new("UICorner"); cac.CornerRadius = UDim.new(0, 8); cac.Parent = compactArt

	local compactInfo = Instance.new("Frame")
	compactInfo.Name = "CompactInfo"
	compactInfo.AnchorPoint = Vector2.new(0, 0.5)
	compactInfo.Position = UDim2.new(0, 60, 0.5, 0)
	compactInfo.Size = UDim2.new(1, -120, 1, 0)
	compactInfo.BackgroundTransparency = 1
	compactInfo.Parent = compactContainer

	local compactTitle = Instance.new("TextLabel")
	compactTitle.Name = "Title"
	compactTitle.BackgroundTransparency = 1
	compactTitle.Position = UDim2.new(0, 0, 0.25, 0)
	compactTitle.Size = UDim2.new(1, 0, 0.25, 0)
	compactTitle.Font = Enum.Font.GothamBold
	compactTitle.Text = "Not Playing"
	compactTitle.TextColor3 = Color3.new(1, 1, 1)
	compactTitle.TextSize = 14
	compactTitle.TextXAlignment = Enum.TextXAlignment.Left
	compactTitle.TextTruncate = Enum.TextTruncate.AtEnd
	compactTitle.Parent = compactInfo

	local compactArtist = Instance.new("TextLabel")
	compactArtist.Name = "Artist"
	compactArtist.BackgroundTransparency = 1
	compactArtist.Position = UDim2.new(0, 0, 0.5, 0)
	compactArtist.Size = UDim2.new(1, 0, 0.25, 0)
	compactArtist.Font = Enum.Font.Gotham
	compactArtist.Text = ""
	compactArtist.TextColor3 = Color3.fromRGB(180, 180, 180)
	compactArtist.TextSize = 12
	compactArtist.TextXAlignment = Enum.TextXAlignment.Left
	compactArtist.TextTruncate = Enum.TextTruncate.AtEnd
	compactArtist.Parent = compactInfo

	local compactLogo = Instance.new("ImageLabel")
	compactLogo.Name = "CompactLogo"
	compactLogo.AnchorPoint = Vector2.new(1, 0.5)
	compactLogo.Position = UDim2.new(1, -12, 0.5, 0)
	compactLogo.Size = UDim2.fromOffset(24, 24)
	compactLogo.BackgroundTransparency = 1
	compactLogo.Image = "rbxassetid://9622474485"
	compactLogo.Parent = compactContainer

	local expandedContainer = Instance.new("CanvasGroup")
	expandedContainer.Name = "ExpandedContainer"
	expandedContainer.BackgroundTransparency = 1
	expandedContainer.GroupTransparency = 1
	expandedContainer.Size = UDim2.new(1, 0, 1, 0)
	expandedContainer.Visible = true
	local hitbox = Instance.new("Frame")
	hitbox.Name = "Hitbox"
	hitbox.AnchorPoint = Vector2.new(0.5, 0)
	hitbox.Position = UDim2.new(0.5, 0, 0, 0)
	hitbox.Size = UDim2.new(0, 500, 0, 250)
	hitbox.BackgroundTransparency = 1
	hitbox.ZIndex = 999
	hitbox.Parent = screenGui
	expandedContainer.ZIndex = 1001
	expandedContainer.Parent = dynamicIsland

	local expandedLogo = Instance.new("ImageLabel")
	expandedLogo.Name = "ExpandedLogo"
	expandedLogo.AnchorPoint = Vector2.new(1, 0)
	expandedLogo.Position = UDim2.new(1, -20, 0, 20)
	expandedLogo.Size = UDim2.fromOffset(24, 24)
	expandedLogo.BackgroundTransparency = 1
	expandedLogo.Image = "rbxassetid://9622474485"
	expandedLogo.Parent = expandedContainer

	local expandedArt = Instance.new("ImageLabel")
	expandedArt.Name = "ExpandedArt"
	expandedArt.Position = UDim2.new(0, 20, 0, 20)
	expandedArt.Size = UDim2.fromOffset(60, 60)
	expandedArt.BackgroundTransparency = 1
	expandedArt.Image = ""
	expandedArt.ScaleType = Enum.ScaleType.Crop
	expandedArt.Parent = expandedContainer
	local eac = Instance.new("UICorner"); eac.CornerRadius = UDim.new(0, 8); eac.Parent = expandedArt

	local expandedInfo = Instance.new("Frame")
	expandedInfo.Name = "ExpandedInfo"
	expandedInfo.Position = UDim2.new(0, 95, 0, 20)
	expandedInfo.Size = UDim2.new(1, -100, 0, 60)
	expandedInfo.BackgroundTransparency = 1
	expandedInfo.Parent = expandedContainer

	local expandedTitle = Instance.new("TextLabel")
	expandedTitle.Name = "Title"
	expandedTitle.BackgroundTransparency = 1
	expandedTitle.Position = UDim2.new(0, 0, 0.1, 0)
	expandedTitle.Size = UDim2.new(1, 0, 0.4, 0)
	expandedTitle.Font = Enum.Font.GothamBold
	expandedTitle.Text = "Not Playing"
	expandedTitle.TextColor3 = Color3.new(1, 1, 1)
	expandedTitle.TextSize = 18
	expandedTitle.TextXAlignment = Enum.TextXAlignment.Left
	expandedTitle.TextTruncate = Enum.TextTruncate.AtEnd
	expandedTitle.Parent = expandedInfo

	local expandedArtist = Instance.new("TextLabel")
	expandedArtist.Name = "Artist"
	expandedArtist.BackgroundTransparency = 1
	expandedArtist.Position = UDim2.new(0, 0, 0.5, 0)
	expandedArtist.Size = UDim2.new(1, 0, 0.3, 0)
	expandedArtist.Font = Enum.Font.Gotham
	expandedArtist.Text = ""
	expandedArtist.TextColor3 = Color3.fromRGB(180, 180, 180)
	expandedArtist.TextSize = 14
	expandedArtist.TextXAlignment = Enum.TextXAlignment.Left
	expandedArtist.TextTruncate = Enum.TextTruncate.AtEnd
	expandedArtist.Parent = expandedInfo

	local progressContainer = Instance.new("Frame")
	progressContainer.Name = "ProgressContainer"
	progressContainer.Position = UDim2.new(0, 20, 0, 95)
	progressContainer.Size = UDim2.new(1, -40, 0, 20)
	progressContainer.BackgroundTransparency = 1
	progressContainer.Parent = expandedContainer

	local progressBarBg = Instance.new("Frame")
	progressBarBg.Name = "ProgressBarBg"
	progressBarBg.AnchorPoint = Vector2.new(0.5, 0.5)
	progressBarBg.Position = UDim2.new(0.5, 0, 0.5, 0)
	progressBarBg.Size = UDim2.new(1, -70, 0, 4)
	progressBarBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	progressBarBg.BorderSizePixel = 0
	progressBarBg.Parent = progressContainer
	local pbbc = Instance.new("UICorner"); pbbc.CornerRadius = UDim.new(1, 0); pbbc.Parent = progressBarBg

	local progressBarFill = Instance.new("Frame")
	progressBarFill.Name = "BarFill"
	progressBarFill.Size = UDim2.new(0, 0, 1, 0)
	progressBarFill.BackgroundColor3 = Color3.new(1, 1, 1)
	progressBarFill.BorderSizePixel = 0
	progressBarFill.Parent = progressBarBg
	local pbfc = Instance.new("UICorner"); pbfc.CornerRadius = UDim.new(1, 0); pbfc.Parent = progressBarFill

	local seekBtn = Instance.new("TextButton")
	seekBtn.Name = "SeekButton"
	seekBtn.BackgroundTransparency = 1
	seekBtn.Text = ""
	seekBtn.Size = UDim2.new(1, 0, 3, 0)
	seekBtn.Position = UDim2.new(0, 0, -1, 0)
	seekBtn.Parent = progressBarBg
	
	seekBtn.MouseButton1Click:Connect(function()
		if not localState.hasSong or not localState.duration or localState.duration <= 0 then return end
		
		local mouse = game:GetService("Players").LocalPlayer:GetMouse()
		local barAbsPos = progressBarBg.AbsolutePosition.X
		local barAbsSize = progressBarBg.AbsoluteSize.X
		local mouseX = mouse.X
		
		local relativeX = math.clamp(mouseX - barAbsPos, 0, barAbsSize)
		local percentage = relativeX / barAbsSize
		local seekTime = percentage * localState.duration
		
		localState.position = seekTime
		progressBarFill.Size = UDim2.new(percentage, 0, 1, 0)
		
		spotifySeek(math.floor(seekTime * 1000))
	end)

	local timeStart = Instance.new("TextLabel")
	timeStart.Name = "TimeStart"
	timeStart.BackgroundTransparency = 1
	timeStart.Position = UDim2.new(0, 0, 0, 0)
	timeStart.Size = UDim2.new(0, 30, 1, 0)
	timeStart.Font = Enum.Font.Gotham
	timeStart.Text = "0:00"
	timeStart.TextColor3 = Color3.fromRGB(150, 150, 150)
	timeStart.TextSize = 10
	timeStart.TextXAlignment = Enum.TextXAlignment.Left
	timeStart.Parent = progressContainer

	local timeEnd = Instance.new("TextLabel")
	timeEnd.Name = "TimeEnd"
	timeEnd.BackgroundTransparency = 1
	timeEnd.AnchorPoint = Vector2.new(1, 0)
	timeEnd.Position = UDim2.new(1, 0, 0, 0)
	timeEnd.Size = UDim2.new(0, 30, 1, 0)
	timeEnd.Font = Enum.Font.Gotham
	timeEnd.Text = "0:00"
	timeEnd.TextColor3 = Color3.fromRGB(150, 150, 150)
	timeEnd.TextSize = 10
	timeEnd.TextXAlignment = Enum.TextXAlignment.Right
	timeEnd.Parent = progressContainer

	local controlsContainer = Instance.new("Frame")
	controlsContainer.Name = "Controls"
	controlsContainer.Position = UDim2.new(0, 20, 0, 120)
	controlsContainer.Size = UDim2.new(1, -40, 0, 30)
	controlsContainer.BackgroundTransparency = 1
	controlsContainer.Parent = expandedContainer

	local function makeBtn(name, icon, pos, size, callback)
		local btn = Instance.new("ImageButton")
		btn.Name = name
		btn.BackgroundTransparency = 1
		btn.Position = pos
		btn.Size = size
		btn.AnchorPoint = Vector2.new(0.5, 0.5)
		btn.Image = icon
		btn.ImageColor3 = Color3.new(1, 1, 1)
		btn.Parent = controlsContainer
		
		if callback then
			btn.MouseButton1Click:Connect(callback)
		end
		return btn
	end

	local pinnedContainer = Instance.new("CanvasGroup")
	pinnedContainer.Name = "PinnedContainer"
	pinnedContainer.BackgroundTransparency = 1
	pinnedContainer.GroupTransparency = 1
	pinnedContainer.Size = UDim2.new(1, 0, 1, 0)
	pinnedContainer.ZIndex = 1002
	pinnedContainer.Parent = dynamicIsland
	
	local pinnedLayout = Instance.new("UIListLayout")
	pinnedLayout.FillDirection = Enum.FillDirection.Horizontal
	pinnedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	pinnedLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	pinnedLayout.Padding = UDim.new(0, 15)
	pinnedLayout.Parent = pinnedContainer
	
	local function makePinnedBtn(name, icon, size, callback)
		local btn = Instance.new("ImageButton")
		btn.Name = name
		btn.BackgroundTransparency = 1
		btn.Size = size
		btn.Image = icon
		btn.ImageColor3 = Color3.new(1, 1, 1)
		btn.Parent = pinnedContainer
		if callback then btn.MouseButton1Click:Connect(callback) end
		return btn
	end
	
	local pinnedPrev = makePinnedBtn("Prev", "rbxassetid://138415720834412", UDim2.fromOffset(20, 20), spotifyPrevious)
	
	local pinnedPlay = makePinnedBtn("PlayPause", "rbxassetid://136341313090125", UDim2.fromOffset(24, 24), function()
		if isPlaying then spotifyPause() else spotifyResume() end
	end)

	local pinnedNext = makePinnedBtn("Next", "rbxassetid://88365123525975", UDim2.fromOffset(20, 20), spotifyNext)
	
	local pinnedPin = makePinnedBtn("PinButton", "rbxassetid://108346394273892", UDim2.fromOffset(18, 18), function()
		localState.isPinned = false
		if siriusValues and siriusValues.settings then siriusValues.settings.dynamicislandpinned = false end
	end)
	pinnedPin.ImageColor3 = Color3.fromRGB(30, 215, 96) 

	local playBtn = makeBtn("PlayPause", "rbxassetid://136341313090125", UDim2.new(0.5, 0, 0.5, 0), UDim2.fromOffset(24, 24), function()
		if isPlaying then spotifyPause() else spotifyResume() end
	end)
	makeBtn("Prev", "rbxassetid://138415720834412", UDim2.new(0.5, -45, 0.5, 0), UDim2.fromOffset(24, 24), spotifyPrevious)
	makeBtn("Next", "rbxassetid://88365123525975", UDim2.new(0.5, 45, 0.5, 0), UDim2.fromOffset(24, 24), spotifyNext)

	local pinBtn = Instance.new("ImageButton")
	pinBtn.Name = "PinButton"
	pinBtn.Size = UDim2.fromOffset(20, 20)
	pinBtn.Position = UDim2.new(1, -30, 1, -12) -- Lowered
	pinBtn.AnchorPoint = Vector2.new(0.5, 0.5)
	pinBtn.BackgroundTransparency = 1
	pinBtn.Image = "rbxassetid://108346394273892"
	pinBtn.ImageColor3 = Color3.fromRGB(180, 180, 180)
	pinBtn.ZIndex = 1005 -- High ZIndex
	pinBtn.Parent = dynamicIsland -- Moved out of expandedContainer
	
	pinBtn.MouseButton1Click:Connect(function()
		localState.isPinned = not localState.isPinned
		if localState.isPinned then
			pinBtn.ImageColor3 = Color3.fromRGB(30, 215, 96)
			if siriusValues and siriusValues.settings then siriusValues.settings.dynamicislandpinned = true end
		else
			pinBtn.ImageColor3 = Color3.fromRGB(180, 180, 180)
			if siriusValues and siriusValues.settings then siriusValues.settings.dynamicislandpinned = false end
		end
	end)

	local shapes = {
		[1] = { -- Compact
			width = 400,
			height = 54,
			corner = 12,
			scale = 1,
			compactTrans = 0,
			expandedTrans = 1,
			pinnedTrans = 1,
		},
		[2] = { -- Expanded
			width = 340,
			height = 160,
			corner = 32,
			scale = 1.02,
			compactTrans = 1,
			expandedTrans = 0,
			pinnedTrans = 1,
		},
		[3] = { -- Pinned
			width = 230,
			height = 44,
			corner = 22,
			scale = 1,
			compactTrans = 1,
			expandedTrans = 1,
			pinnedTrans = 0,
		}
	}

	local widthSpring = Spring.new(1, 17)
	local heightSpring = Spring.new(1, 17)
	local cornerSpring = Spring.new(1, 20)
	local scaleSpring = Spring.new(1, 22)
	local compactTransSpring = Spring.new(1, 25)
	local expandedTransSpring = Spring.new(1, 25)
	local pinnedTransSpring = Spring.new(1, 25)
	local positionYSpring = Spring.new(1, 17) -- For vertical position animation

	widthSpring:SnapTo(400)
	heightSpring:SnapTo(54)
	cornerSpring:SnapTo(12)
	scaleSpring:SnapTo(1)
	compactTransSpring:SnapTo(0)
	expandedTransSpring:SnapTo(1)
	pinnedTransSpring:SnapTo(1)
	positionYSpring:SnapTo(0.02)

	local function setShape(state)
		local s = shapes[state]
		if not s then return end
		
		widthSpring:SetTarget(s.width)
		heightSpring:SetTarget(s.height)
		cornerSpring:SetTarget(s.corner)
		scaleSpring:SetTarget(s.scale)
		compactTransSpring:SetTarget(s.compactTrans)
		expandedTransSpring:SetTarget(s.expandedTrans)
		pinnedTransSpring:SetTarget(s.pinnedTrans)
		
		if state == 3 then
			positionYSpring:SetTarget(0) -- Top
		else
			positionYSpring:SetTarget(0.02)
		end
		
		if state == 2 then
			hitbox.Size = UDim2.new(0, 500, 0, 250)
		elseif state == 3 then
			hitbox.Size = UDim2.new(0, 160, 0, 50)
		else
			hitbox.Size = UDim2.new(0, 500, 0, 120)
		end
	end

	hitbox.MouseEnter:Connect(function() 
		if not localState.isPinned then setShape(2) end 
	end)
	hitbox.MouseLeave:Connect(function() 
		if not localState.isPinned then setShape(1) end 
	end)

	dynamicIslandConnection = runService.RenderStepped:Connect(function(dt)
		if not dynamicIsland or not dynamicIsland.Parent then return end
		
		local isEnabled = true
		if siriusValues and siriusValues.settings and siriusValues.settings.dynamicisland ~= nil then
			isEnabled = siriusValues.settings.dynamicisland
		end

		if localState.hasSong and isEnabled then
			dynamicIsland.Visible = true
		else
			dynamicIsland.Visible = false
		end
		
		-- Check Pinned State
		if localState.isPinned then
			setShape(3)
		elseif shapes[2].expandedTrans == 0 then -- currently expanded (checking value from previous loop?) 
			-- Actually setShape handles targets. We need to respect mouse hover if NOT pinned.
			-- MouseEnter/Leave handles it.
			-- But if we just unpinned, we should revert to... Expanded if mouse over?
			-- We'll let MouseLeave handle it if we move away.
			-- If unpinned while mouse is over, it might stay pinned shape until mouse move?
			-- We can force check mouse overlap here but maybe overkill.
		else
			-- setShape(1) handled by default or mouse events
		end
		
		local newWidth = widthSpring:Update(dt)
		local newHeight = heightSpring:Update(dt)
		local newCorner = cornerSpring:Update(dt)
		local newScale = scaleSpring:Update(dt)
		local newCompactTrans = compactTransSpring:Update(dt)
		local newExpandedTrans = expandedTransSpring:Update(dt)
		local newPinnedTrans = pinnedTransSpring:Update(dt)
		local newPosY = positionYSpring:Update(dt)

		dynamicIsland.Size = UDim2.fromOffset(newWidth, newHeight)
		dynamicIsland.Position = UDim2.new(0.5, 0, newPosY, 0)
		corner.CornerRadius = UDim.new(0, newCorner)
		uiScale.Scale = newScale
		compactContainer.GroupTransparency = newCompactTrans
		expandedContainer.GroupTransparency = newExpandedTrans
		pinnedContainer.GroupTransparency = newPinnedTrans
		shadow.Size = UDim2.new(2.0, 0, 3.3, 0)

		-- Sync Pin Button Visibility (Manual since it's outside containers)
		if pinBtn then
			pinBtn.ImageTransparency = newExpandedTrans
			pinBtn.Visible = (newExpandedTrans < 0.99)
		end
		
		if localState.isPlaying and localState.duration > 0 then
			local elapsed = tick() - localState.lastUpdate
			local current = math.clamp(localState.position + elapsed, 0, localState.duration)
			local ratio = math.clamp(current / localState.duration, 0, 1)
			
			local progCont = dynamicIsland:FindFirstChild("ExpandedContainer")
			if progCont then
				progCont = progCont:FindFirstChild("ProgressContainer")
				if progCont then
					local barBg = progCont:FindFirstChild("ProgressBarBg")
					if barBg then
						local barFill = barBg:FindFirstChild("BarFill")
						if barFill then
							barFill.Size = UDim2.new(ratio, 0, 1, 0)
						end
					end
					
					local tStart = progCont:FindFirstChild("TimeStart")
					local tEnd = progCont:FindFirstChild("TimeEnd")
					
					local function fmt(s)
						return string.format("%d:%02d", math.floor(s/60), s%60)
					end
					
					if tStart then tStart.Text = fmt(math.floor(current)) end
					if tEnd then tEnd.Text = "-"..fmt(math.floor(localState.duration - current)) end
				end
			end
		else
			local progCont = dynamicIsland:FindFirstChild("ExpandedContainer")
			if progCont then
				progCont = progCont:FindFirstChild("ProgressContainer")
				if progCont then
					local barBg = progCont:FindFirstChild("ProgressBarBg")
					if barBg then
						local barFill = barBg:FindFirstChild("BarFill")
						if barFill then
							barFill.Size = UDim2.new(0, 0, 1, 0)
						end
					end

					
					local tStart = progCont:FindFirstChild("TimeStart")
					local tEnd = progCont:FindFirstChild("TimeEnd")
					if tStart then tStart.Text = "0:00" end
					if tEnd then tEnd.Text = "0:00" end
				end
			end
		end
	end)

	dynamicIsland.MouseEnter:Connect(function() setShape(2) end)
	dynamicIsland.MouseLeave:Connect(function() setShape(1) end)

	local function show(hasSong)
		localState.hasSong = hasSong or false
		local targetPos = localState.hasSong and shownPos or hiddenPos
		
		if localState.hasSong then
			dynamicIsland.Visible = true
		end

		tweenService:Create(dynamicIsland, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = targetPos
		}):Play()
	end

	dynamicIslandShow = show
	dynamicIslandState = localState
end

updateDynamicIsland = function(data)
	if not dynamicIsland then return end
	local show = dynamicIslandShow
	
	if data and data.song then
		local title = data.song.name or "Unknown"
		local artist = table.concat(data.artistNames, ", ")
		
		local compactTitle = dynamicIsland:FindFirstChild("CompactContainer"):FindFirstChild("CompactInfo"):FindFirstChild("Title")
		local compactArtist = dynamicIsland:FindFirstChild("CompactContainer"):FindFirstChild("CompactInfo"):FindFirstChild("Artist")
		local expandedTitle = dynamicIsland:FindFirstChild("ExpandedContainer"):FindFirstChild("ExpandedInfo"):FindFirstChild("Title")
		local expandedArtist = dynamicIsland:FindFirstChild("ExpandedContainer"):FindFirstChild("ExpandedInfo"):FindFirstChild("Artist")
		
		if compactTitle then compactTitle.Text = title end
		if compactArtist then compactArtist.Text = artist end
		if expandedTitle then expandedTitle.Text = title end
		if expandedArtist then expandedArtist.Text = artist end
		
		if data.images and data.images.songCover and data.album and data.album.id then
			task.spawn(function()
				local folder = "Spotify Cache"
				if not isfolder(folder) then makefolder(folder) end
				
				local fileName = data.album.id .. ".jpeg"
				local path = folder .. "/" .. fileName
				
				local attempts = 0
				local success = false
				
				while attempts < 5 and not success do
					if not isfile(path) then
						local s, content = pcall(game.HttpGet, game, data.images.songCover)
						if s and content and #content > 0 then
							writefile(path, content)
							success = true
						else
							attempts = attempts + 1
							task.wait(0.5)
						end
					else
						success = true
					end
				end
				
				if success and isfile(path) and getcustomasset then
					local artId = nil
					local loadAttempts = 0
					
					while loadAttempts < 3 and not artId do
						local s, asset = pcall(getcustomasset, path)
						if s and asset then
							artId = asset
						else
							loadAttempts = loadAttempts + 1
							task.wait(0.2)
						end
					end

					if artId then
						local cArt = dynamicIsland:FindFirstChild("CompactContainer") and dynamicIsland.CompactContainer:FindFirstChild("CompactArt")
						local eArt = dynamicIsland:FindFirstChild("ExpandedContainer") and dynamicIsland.ExpandedContainer:FindFirstChild("ExpandedArt")
						if cArt and cArt.Image ~= artId then cArt.Image = artId end
						if eArt and eArt.Image ~= artId then eArt.Image = artId end
					end
				end
			end)
		end
		
		if data.playback and dynamicIslandState then
			dynamicIslandState.isPlaying = data.playback.playing
			if data.playback.total and data.playback.total > 0 then
				dynamicIslandState.duration = data.playback.total / 1000
				dynamicIslandState.position = data.playback.current / 1000
				dynamicIslandState.lastUpdate = tick()
				
				local current = dynamicIslandState.position
				local ratio = math.clamp(current / dynamicIslandState.duration, 0, 1)
				local progCont = dynamicIsland:FindFirstChild("ExpandedContainer"):FindFirstChild("ProgressContainer")
				if progCont then
					local barFill = progCont:FindFirstChild("ProgressBarBg"):FindFirstChild("BarFill")
					local tStart = progCont:FindFirstChild("TimeStart")
					local tEnd = progCont:FindFirstChild("TimeEnd")
					
					if barFill then 
						barFill.Size = UDim2.new(ratio, 0, 1, 0)
					end
					
					local function fmt(s)
						return string.format("%d:%02d", math.floor(s/60), s%60)
					end
					
					if tStart then 
						tStart.Text = fmt(math.floor(current))
					end
					if tEnd then 
						tEnd.Text = "-"..fmt(math.floor(dynamicIslandState.duration - current))
					end
				end
			end
		end
		
		local controls = dynamicIsland:FindFirstChild("ExpandedContainer"):FindFirstChild("Controls")
		if controls then
			local playBtn = controls:FindFirstChild("PlayPause")
			if playBtn then
				if data.playback.playing then
					playBtn.Image = "rbxassetid://121740587216950"
					playBtn.Size = UDim2.fromOffset(32, 32)
				else
					playBtn.Image = "rbxassetid://136341313090125"
					playBtn.Size = UDim2.fromOffset(24, 24)
				end
			end
		end
		
		if typeof(show) == "function" then show(true) end
	else
		if typeof(show) == "function" then show(false) end
	end
end

local function staggerReveal(list)
	if not list then return end
	for i, child in ipairs(list:GetChildren()) do
		if child:IsA("GuiObject") then
			child.BackgroundTransparency = 1
			if child:FindFirstChild("Title") then child.Title.TextTransparency = 1 end
			if child:FindFirstChild("Artist") then child.Artist.TextTransparency = 1 end
			if child:FindFirstChild("Cover") then child.Cover.ImageTransparency = 1 end
			
			task.delay(i * 0.03, function()
				tweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
				if child:FindFirstChild("Title") then tweenService:Create(child.Title, TweenInfo.new(0.5), {TextTransparency = 0}):Play() end
				if child:FindFirstChild("Artist") then tweenService:Create(child.Artist, TweenInfo.new(0.5), {TextTransparency = 0.4}):Play() end
				if child:FindFirstChild("Cover") then tweenService:Create(child.Cover, TweenInfo.new(0.5), {ImageTransparency = 0}):Play() end
			end)
		end
	end
end

local function fadeOutList(list)
	if not list then return end
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("GuiObject") then
			tweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
			if child:FindFirstChild("Title") then tweenService:Create(child.Title, TweenInfo.new(0.3), {TextTransparency = 1}):Play() end
			if child:FindFirstChild("Artist") then tweenService:Create(child.Artist, TweenInfo.new(0.3), {TextTransparency = 1}):Play() end
			if child:FindFirstChild("Cover") then tweenService:Create(child.Cover, TweenInfo.new(0.3), {ImageTransparency = 1}):Play() end
		end
	end
end

local function buildSpotifyUIInternal()
	musicPanel = Instance.new("CanvasGroup")
	musicPanel.Name = "SpotifyMusicPanel"
	musicPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	musicPanel.BackgroundTransparency = 0
	musicPanel.GroupTransparency = 0
	musicPanel.BorderSizePixel = 0
	musicPanel.ClipsDescendants = true
	musicPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	musicPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
	musicPanel.Size = UDim2.new(0, 600, 0, 350)
	musicPanel.Visible = false
	musicPanel.ZIndex = 100
	
	-- solid bg so panel isn't see-through
	local solidBg = Instance.new("Frame")
	solidBg.Name = "SolidBackground"
	solidBg.Size = UDim2.new(1, 0, 1, 0)
	solidBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	solidBg.BackgroundTransparency = 0
	solidBg.BorderSizePixel = 0
	solidBg.ZIndex = 99
	solidBg.Parent = musicPanel
	local solidBgCorner = Instance.new("UICorner")
	solidBgCorner.CornerRadius = UDim.new(0, 9)
	solidBgCorner.Parent = solidBg
	
	local glowFrame = Instance.new("Frame")
	glowFrame.Name = "GlowFrame"
	glowFrame.Size = UDim2.new(1, 0, 1, 0)
	glowFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	glowFrame.BackgroundTransparency = 0
	glowFrame.BorderSizePixel = 0
	glowFrame.ClipsDescendants = true
	glowFrame.Visible = false
	glowFrame.ZIndex = 101
	glowFrame.Parent = musicPanel

	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = UDim.new(0, 9)
	glowCorner.Parent = glowFrame
	
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
	})
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.9),
		NumberSequenceKeypoint.new(1, 1)
	})
	uiGradient.Rotation = 85
	uiGradient.Offset = Vector2.new(0, 1.5)
	uiGradient.Parent = glowFrame
	
	musicPanel.Parent = UI
	createDynamicIsland()

	local uiGradient = Instance.new("UIGradient")
	uiGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 5))
	}
	uiGradient.Rotation = 45
	uiGradient.Parent = musicPanel

	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.BackgroundTransparency = 1
	shadow.Position = UDim2.new(0.5, 0, 0.5, 5)
	shadow.Size = UDim2.new(1, 40, 1, 40)
	shadow.ZIndex = 99
	shadow.Image = "rbxassetid://6015897843"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.7
	shadow.Parent = musicPanel

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 9)
	uiCorner.Parent = musicPanel

	local loadingOverlay = Instance.new("Frame")
	loadingOverlay.Name = "LoadingOverlay"
	loadingOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	loadingOverlay.BackgroundTransparency = 0.3
	loadingOverlay.Size = UDim2.new(1, 0, 1, 0)
	loadingOverlay.Visible = false
	loadingOverlay.ZIndex = 200
	loadingOverlay.Parent = musicPanel

	local loadingCorner = Instance.new("UICorner")
	loadingCorner.CornerRadius = UDim.new(0, 9)
	loadingCorner.Parent = loadingOverlay

	local loadingIcon = Instance.new("ImageLabel")
	loadingIcon.Name = "LoadingIcon"
	loadingIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	loadingIcon.BackgroundTransparency = 1
	loadingIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	loadingIcon.Size = UDim2.new(0, 40, 0, 40)
	loadingIcon.Image = "rbxassetid://3570695787"
	loadingIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	loadingIcon.ZIndex = 201
	loadingIcon.Parent = loadingOverlay

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	header.BackgroundTransparency = 1
	header.BorderSizePixel = 0
	header.Size = UDim2.new(1, 0, 0, 60)
	header.ZIndex = 101
	header.Parent = musicPanel

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 9)
	headerCorner.Parent = header

	local headerFix = Instance.new("Frame")
	headerFix.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	headerFix.BackgroundTransparency = 1
	headerFix.BorderSizePixel = 0
	headerFix.Position = UDim2.new(0, 0, 1, -10)
	headerFix.Size = UDim2.new(1, 0, 0, 10)
	headerFix.ZIndex = 101
	headerFix.Parent = header

	local logo = Instance.new("ImageLabel")
	logo.Name = "Logo"
	logo.BackgroundTransparency = 1
	logo.Position = UDim2.new(0, 20, 0, 15)
	logo.Size = UDim2.new(0, 30, 0, 30)
	logo.Image = "rbxassetid://9622474485"
	logo.ZIndex = 102
	logo.Parent = header

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.new(0, 60, 0, 10)
	titleLabel.Size = UDim2.new(0, 200, 0, 25)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = "Spotify"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 18
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 102
	titleLabel.Parent = header

	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.BackgroundTransparency = 1
	subtitle.Position = UDim2.new(0, 60, 0, 35)
	subtitle.Size = UDim2.new(0, 300, 0, 15)
	subtitle.Font = Enum.Font.Gotham
	subtitle.Text = "Connected to your device"
	subtitle.TextColor3 = Color3.fromRGB(30, 215, 96)
	subtitle.TextSize = 12
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.ZIndex = 102
	subtitle.Parent = header

	local tokenSection = Instance.new("Frame")
	tokenSection.Name = "TokenSection"
	tokenSection.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	tokenSection.BackgroundTransparency = 0
	tokenSection.BorderSizePixel = 0
	tokenSection.Position = UDim2.new(0, 20, 0, 80)
	tokenSection.Size = UDim2.new(1, -40, 1, -100)
	tokenSection.Visible = true
	tokenSection.ZIndex = 101
	tokenSection.Parent = musicPanel

	local tokenCorner = Instance.new("UICorner")
	tokenCorner.CornerRadius = UDim.new(0, 12)
	tokenCorner.Parent = tokenSection

	local tokenTitle = Instance.new("TextLabel")
	tokenTitle.BackgroundTransparency = 1
	tokenTitle.Position = UDim2.new(0, 20, 0, 20)
	tokenTitle.Size = UDim2.new(1, -40, 0, 20)
	tokenTitle.Font = Enum.Font.GothamBold
	tokenTitle.Text = "Authentication Required"
	tokenTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	tokenTitle.TextSize = 16
	tokenTitle.TextXAlignment = Enum.TextXAlignment.Left
	tokenTitle.ZIndex = 102
	tokenTitle.Parent = tokenSection

	local tokenInput = Instance.new("TextBox")
	tokenInput.Name = "TokenInput"
	tokenInput.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	tokenInput.Position = UDim2.new(0.5, 0, 0.5, -20)
	tokenInput.AnchorPoint = Vector2.new(0.5, 0.5)
	tokenInput.Size = UDim2.new(0, 360, 0, 45)
	tokenInput.Font = Enum.Font.Gotham
	tokenInput.PlaceholderText = "Paste your Spotify OAuth token here..."
	tokenInput.Text = ""
	tokenInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	tokenInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	tokenInput.TextSize = 14
	tokenInput.TextXAlignment = Enum.TextXAlignment.Center
	tokenInput.ClearTextOnFocus = false
	tokenInput.ZIndex = 102
	tokenInput.Parent = tokenSection

	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 8)
	inputCorner.Parent = tokenInput

	local inputStroke = Instance.new("UIStroke")
	inputStroke.Color = Color3.fromRGB(60, 60, 60)
	inputStroke.Thickness = 1
	inputStroke.Parent = tokenInput

	local submitButton = Instance.new("TextButton")
	submitButton.Name = "SubmitButton"
	submitButton.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
	submitButton.Position = UDim2.new(0.5, 0, 0.5, 45)
	submitButton.AnchorPoint = Vector2.new(0.5, 0.5)
	submitButton.Size = UDim2.new(0, 120, 0, 35)
	submitButton.Font = Enum.Font.GothamBold
	submitButton.Text = "Connect"
	submitButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	submitButton.TextSize = 13
	submitButton.ZIndex = 102
	submitButton.Parent = tokenSection

	local submitCorner = Instance.new("UICorner")
	submitCorner.CornerRadius = UDim.new(0, 20)
	submitCorner.Parent = submitButton

	submitButton.MouseEnter:Connect(function()
		tweenService:Create(submitButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 235, 105)}):Play()
	end)
	submitButton.MouseLeave:Connect(function()
		tweenService:Create(submitButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 215, 96)}):Play()
	end)

	local howButton = Instance.new("TextButton")
	howButton.Name = "HowButton"
	howButton.BackgroundTransparency = 1
	howButton.Position = UDim2.new(0.5, 0, 0.5, 85)
	howButton.AnchorPoint = Vector2.new(0.5, 0.5)
	howButton.Size = UDim2.new(0, 50, 0, 25)
	howButton.Font = Enum.Font.Gotham
	howButton.Text = "How?"
	howButton.TextColor3 = Color3.fromRGB(150, 150, 150)
	howButton.TextSize = 11
	howButton.TextXAlignment = Enum.TextXAlignment.Center
	howButton.ZIndex = 102
	howButton.Parent = tokenSection
	
	howButton.MouseButton1Click:Connect(function()
	end)

	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.BackgroundTransparency = 1
	contentArea.Position = UDim2.new(0, 20, 0, 80)
	contentArea.Size = UDim2.new(1, -40, 1, -100)
	contentArea.Visible = false
	contentArea.ZIndex = 101
	contentArea.Parent = musicPanel

	playlistBrowser = Instance.new("ScrollingFrame")
	playlistBrowser.Name = "PlaylistBrowser"
	playlistBrowser.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	playlistBrowser.BackgroundTransparency = 0.5
	playlistBrowser.BorderSizePixel = 0
	playlistBrowser.Position = UDim2.new(0, 0, 0, 0)
	playlistBrowser.Size = UDim2.new(0, 220, 1, 0)
	playlistBrowser.ScrollBarThickness = 2
	playlistBrowser.ScrollBarImageColor3 = Color3.fromRGB(30, 215, 96)
	playlistBrowser.CanvasSize = UDim2.new(0, 0, 0, 0)
	playlistBrowser.ZIndex = 102
	playlistBrowser.Parent = contentArea

	local browserCorner = Instance.new("UICorner")
	browserCorner.CornerRadius = UDim.new(0, 12)
	browserCorner.Parent = playlistBrowser

	local browserLayout = Instance.new("UIListLayout")
	browserLayout.Padding = UDim.new(0, 8)
	browserLayout.SortOrder = Enum.SortOrder.LayoutOrder
	browserLayout.Parent = playlistBrowser

	local browserPadding = Instance.new("UIPadding")
	browserPadding.PaddingTop = UDim.new(0, 10)
	browserPadding.PaddingBottom = UDim.new(0, 10)
	browserPadding.PaddingLeft = UDim.new(0, 10)
	browserPadding.PaddingRight = UDim.new(0, 10)
	browserPadding.Parent = playlistBrowser

	browserLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		playlistBrowser.CanvasSize = UDim2.new(0, 0, 0, browserLayout.AbsoluteContentSize.Y + 20)
	end)

	local nowPlaying = Instance.new("Frame")
	nowPlaying.Name = "NowPlaying"
	nowPlaying.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	nowPlaying.BackgroundTransparency = 0.5
	nowPlaying.BorderSizePixel = 0
	nowPlaying.Position = UDim2.new(0, 235, 0, 0)
	nowPlaying.Size = UDim2.new(1, -235, 1, 0)
	nowPlaying.ZIndex = 102
	nowPlaying.Parent = contentArea

	local nowPlayingCorner = Instance.new("UICorner")
	nowPlayingCorner.CornerRadius = UDim.new(0, 12)
	nowPlayingCorner.Parent = nowPlaying

	for _, child in ipairs(nowPlaying:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end

	local artContainer = Instance.new("Frame")
	artContainer.Name = "ArtContainer"
	artContainer.BackgroundTransparency = 1
	artContainer.Position = UDim2.new(0.5, -75, 0.5, -100)
	artContainer.Size = UDim2.new(0, 150, 0, 150)
	artContainer.ZIndex = 103
	artContainer.Parent = nowPlaying

	local albumArt = Instance.new("ImageLabel")
	albumArt.Name = "AlbumArt"
	albumArt.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	albumArt.Size = UDim2.new(1, 0, 1, 0)
	albumArt.Image = ""
	albumArt.ZIndex = 104
	albumArt.Parent = artContainer

	local artCorner = Instance.new("UICorner")
	artCorner.CornerRadius = UDim.new(0, 12)
	artCorner.Parent = albumArt


	local songTitle = Instance.new("TextLabel")
	songTitle.Name = "SongTitle"
	songTitle.BackgroundTransparency = 1
	songTitle.Position = UDim2.new(0, 20, 0.5, 65)
	songTitle.Size = UDim2.new(1, -40, 0, 30)
	songTitle.Font = Enum.Font.GothamBold
	songTitle.Text = "No song playing"
	songTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	songTitle.TextSize = 20
	songTitle.TextXAlignment = Enum.TextXAlignment.Center
	songTitle.TextTruncate = Enum.TextTruncate.AtEnd
	songTitle.ZIndex = 103
	songTitle.Parent = nowPlaying

	local artistName = Instance.new("TextLabel")
	artistName.Name = "ArtistName"
	artistName.BackgroundTransparency = 1
	artistName.Position = UDim2.new(0, 20, 0.5, 90)
	artistName.Size = UDim2.new(1, -40, 0, 20)
	artistName.Font = Enum.Font.GothamMedium
	artistName.Text = "Start playing on Spotify..."
	artistName.TextColor3 = Color3.fromRGB(180, 180, 180)
	artistName.TextSize = 14
	artistName.TextXAlignment = Enum.TextXAlignment.Center
	artistName.TextTruncate = Enum.TextTruncate.AtEnd
	artistName.ZIndex = 103
	artistName.Parent = nowPlaying

	makeDraggable(musicPanel)


	local function loadPlaylists()
		for _, child in ipairs(playlistBrowser:GetChildren()) do
			if child:IsA("GuiObject") then child:Destroy() end
		end

		task.spawn(function()
			local playlists = getUserPlaylists(userToken)
			if playlists then
				for _, playlist in ipairs(playlists) do
					local playlistFrame = Instance.new("Frame")
					playlistFrame.Name = playlist.id
					playlistFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
					playlistFrame.BackgroundTransparency = 0.6
					playlistFrame.Size = UDim2.new(1, 0, 0, 60)
					playlistFrame.ZIndex = 103
					playlistFrame.Parent = playlistBrowser

					local playlistCorner = Instance.new("UICorner")
					playlistCorner.CornerRadius = UDim.new(0, 10)
					playlistCorner.Parent = playlistFrame

					local playlistTitle = Instance.new("TextLabel")
					playlistTitle.BackgroundTransparency = 1
					playlistTitle.Position = UDim2.new(0, 15, 0, 15)
					playlistTitle.Size = UDim2.new(1, -30, 0, 20)
					playlistTitle.Font = Enum.Font.GothamBold
					playlistTitle.Text = playlist.name
					playlistTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
					playlistTitle.TextSize = 14
					playlistTitle.TextXAlignment = Enum.TextXAlignment.Left
					playlistTitle.TextTruncate = Enum.TextTruncate.AtEnd
					playlistTitle.ZIndex = 104
					playlistTitle.Parent = playlistFrame

					local trackCount = Instance.new("TextLabel")
					trackCount.BackgroundTransparency = 1
					trackCount.Position = UDim2.new(0, 15, 0, 40)
					trackCount.Size = UDim2.new(1, -30, 0, 15)
					trackCount.Font = Enum.Font.Gotham
					trackCount.Text = playlist.tracks.total .. " tracks"
					trackCount.TextColor3 = Color3.fromRGB(150, 150, 150)
					trackCount.TextSize = 12
					trackCount.TextXAlignment = Enum.TextXAlignment.Left
					trackCount.ZIndex = 104
					trackCount.Parent = playlistFrame

					local playlistButton = Instance.new("TextButton")
					playlistButton.BackgroundTransparency = 1
					playlistButton.Size = UDim2.new(1, 0, 1, 0)
					playlistButton.Text = ""
					playlistButton.ZIndex = 105
					playlistButton.Parent = playlistFrame

					playlistButton.MouseEnter:Connect(function()
						tweenService:Create(playlistFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
					end)

					playlistButton.MouseLeave:Connect(function()
						tweenService:Create(playlistFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
					end)

					playlistButton.MouseButton1Click:Connect(function()
						local trackList = musicPanel.ContentArea:FindFirstChild("TrackList")
						if not trackList then
							trackList = Instance.new("ScrollingFrame")
							trackList.Name = "TrackList"
							trackList.BackgroundTransparency = 1
							trackList.Size = UDim2.new(1, 0, 1, 0)
							trackList.ScrollBarThickness = 2
							trackList.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
							trackList.BorderSizePixel = 0
							trackList.Parent = musicPanel.ContentArea
							
							local layout = Instance.new("UIListLayout")
							layout.SortOrder = Enum.SortOrder.LayoutOrder
							layout.Padding = UDim.new(0, 5)
							layout.Parent = trackList
							
							layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
								trackList.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
							end)
						end
						
						local playlistBrowser = musicPanel.ContentArea:FindFirstChild("PlaylistBrowser")
						local nowPlaying = musicPanel.ContentArea:FindFirstChild("NowPlaying")
						
						if playlistBrowser then playlistBrowser.Visible = false end
						if nowPlaying then nowPlaying.Visible = false end
						
						local glowFrame = musicPanel:FindFirstChild("GlowFrame")
						local gradient = glowFrame and glowFrame:FindFirstChild("UIGradient")
						if glowFrame and gradient then
							glowFrame.Visible = true
							tweenService:Create(gradient, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Offset = Vector2.new(0, 0.9)}):Play()
						end
						
						local oldTrackList = musicPanel.ContentArea:FindFirstChild("TrackList")
						if oldTrackList then oldTrackList:Destroy() end
						
						local trackList = Instance.new("ScrollingFrame")
						trackList.Name = "TrackList"
						trackList.BackgroundTransparency = 1
						trackList.Size = UDim2.new(1, -40, 1, -50)
						trackList.Position = UDim2.new(0, 20, 0, 50)
						trackList.ScrollBarThickness = 2
						trackList.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
						trackList.BorderSizePixel = 0
						trackList.Visible = true
						trackList.ZIndex = 200
						trackList.Parent = musicPanel.ContentArea
						
						local layout = Instance.new("UIListLayout")
						layout.SortOrder = Enum.SortOrder.LayoutOrder
						layout.Padding = UDim.new(0, 5)
						layout.Parent = trackList
						
						layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
							trackList.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
						end)
						
						enableSmoothScroll(trackList)

						local function staggerReveal(container, delayStep)
							local order = 0
							for _, child in ipairs(container:GetChildren()) do
								if child:IsA("GuiObject") then
									order += 1
									local originalBg = child.BackgroundTransparency
									if child:IsA("Frame") or child:IsA("TextButton") then
										child.BackgroundTransparency = 1
									end

									local restore = {}
									for _, desc in ipairs(child:GetDescendants()) do
										if desc:IsA("TextLabel") or desc:IsA("TextButton") then
											restore[#restore + 1] = {obj = desc, prop = "TextTransparency", value = desc.TextTransparency}
											desc.TextTransparency = 1
										elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
											restore[#restore + 1] = {obj = desc, prop = "ImageTransparency", value = desc.ImageTransparency}
											desc.ImageTransparency = 1
										end
									end

									task.delay(order * delayStep, function()
										if not child.Parent then return end
										if child:IsA("Frame") or child:IsA("TextButton") then
											tweenService:Create(child, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = originalBg}):Play()
										end
										for _, entry in ipairs(restore) do
											if entry.obj then
												tweenService:Create(entry.obj, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[entry.prop] = entry.value}):Play()
											end
										end
									end)
								end
							end
						end

						local function fadeOutList(container)
							for _, child in ipairs(container:GetChildren()) do
								if child:IsA("GuiObject") then
									if child:IsA("Frame") or child:IsA("TextButton") then
										tweenService:Create(child, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
									end
									for _, desc in ipairs(child:GetDescendants()) do
										if desc:IsA("TextLabel") or desc:IsA("TextButton") then
											tweenService:Create(desc, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
										elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
											tweenService:Create(desc, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
										end
									end
								end
							end
						end
						
						local backArrowImage = "rbxassetid://6031090991"

						local backBtn = Instance.new("ImageButton")
						backBtn.Name = "Back"
						backBtn.Size = UDim2.new(0, 24, 0, 24)
						backBtn.BackgroundTransparency = 1
						backBtn.Image = backArrowImage
						backBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
						backBtn.ScaleType = Enum.ScaleType.Fit
						backBtn.Rotation = 90
						backBtn.Position = UDim2.new(0, -12, 0, 18)
						backBtn.ImageTransparency = 1
						backBtn.ZIndex = 205
						backBtn.Parent = musicPanel.ContentArea

						tweenService:Create(backBtn, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Position = UDim2.new(0, 25, 0, 18),
							ImageTransparency = 0
						}):Play()
						
						backBtn.MouseButton1Click:Connect(function()
							fadeOutList(trackList)
							tweenService:Create(backBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
							tweenService:Create(trackList, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ScrollBarImageTransparency = 1}):Play()
							task.wait(0.2)

							if glowFrame and gradient then
								gradient.Offset = Vector2.new(0, 1.5)
								glowFrame.Visible = false
							end

							trackList:Destroy()
							backBtn:Destroy()
							
							if playlistBrowser then
								playlistBrowser.Visible = true
								staggerReveal(playlistBrowser, 0.04)
							end
							if nowPlaying then nowPlaying.Visible = true end
						end)
						
						local tracks = getPlaylistTracks(userToken, playlist.id)
						if typeof(tracks) ~= "table" then
							queueNotification("Spotify Error", "Couldn't load tracks for this playlist.", 9622474485)
							return
						end
						
						for i, item in ipairs(tracks) do
							if item.track then
								local trackBtn = Instance.new("TextButton")
								trackBtn.Name = "Track"
								trackBtn.Size = UDim2.new(1, 0, 0, 60)
								trackBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
								trackBtn.BackgroundTransparency = 0.6
								trackBtn.Text = ""
								trackBtn.AutoButtonColor = false
								trackBtn.ZIndex = 201
								trackBtn.Parent = trackList
								
								trackBtn.MouseEnter:Connect(function()
									tweenService:Create(trackBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
								end)
								trackBtn.MouseLeave:Connect(function()
									tweenService:Create(trackBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
								end)
								
								local trackCorner = Instance.new("UICorner")
								trackCorner.CornerRadius = UDim.new(0, 6)
								trackCorner.Parent = trackBtn
								
								local art = Instance.new("ImageLabel")
								art.Name = "Art"
								art.Position = UDim2.new(0, 8, 0.5, -22)
								art.Size = UDim2.new(0, 44, 0, 44)
								art.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
								art.BackgroundTransparency = 1
								art.ZIndex = 202
								art.Parent = trackBtn
								
								local artCorner = Instance.new("UICorner")
								artCorner.CornerRadius = UDim.new(0, 4)
								artCorner.Parent = art
								
								task.spawn(function()
									if item.track.album and item.track.album.images and #item.track.album.images > 0 then
										local imgData = item.track.album.images[#item.track.album.images]
										if imgData then
											local imgUrl = imgData.url
											local fileName = item.track.album.id .. "_small.jpg"
											local path = "Spotify Cache/" .. fileName
											
											if isfile(path) then
												art.Image = getcustomasset(path)
											else
												local content = game:HttpGet(imgUrl)
												writefile(path, content)
												art.Image = getcustomasset(path)
											end
										end
									end
								end)
								
								local title = Instance.new("TextLabel")
								title.BackgroundTransparency = 1
								title.Position = UDim2.new(0, 60, 0, 10)
								title.Size = UDim2.new(1, -70, 0, 20)
								title.Font = Enum.Font.GothamBold
								title.Text = item.track.name
								title.TextColor3 = Color3.fromRGB(255, 255, 255)
								title.TextSize = 13
								title.TextXAlignment = Enum.TextXAlignment.Left
								title.TextTruncate = Enum.TextTruncate.AtEnd
								title.ZIndex = 202
								title.Parent = trackBtn
								
								local artist = Instance.new("TextLabel")
								artist.BackgroundTransparency = 1
								artist.Position = UDim2.new(0, 60, 0, 32)
								artist.Size = UDim2.new(1, -70, 0, 15)
								artist.Font = Enum.Font.Gotham
								artist.Text = item.track.artists[1].name
								artist.TextColor3 = Color3.fromRGB(180, 180, 180)
								artist.TextSize = 11
								artist.TextXAlignment = Enum.TextXAlignment.Left
								artist.TextTruncate = Enum.TextTruncate.AtEnd
								artist.ZIndex = 202
								artist.Parent = trackBtn
								
								trackBtn.MouseButton1Click:Connect(function()
									spotifyPlayTrack(item.track.uri)
								end)
							end
						end

						staggerReveal(trackList, 0.05)
					end)
				end
			end
		end)
	end

	submitButton.MouseButton1Click:Connect(function()
		local token = tokenInput.Text
		if token ~= "" then
			if checkSpotifyToken(token) then
				userToken = token
				queueNotification("Spotify Connected", "Successfully connected to Spotify!", 9622474485)
				
				startSpotifyUpdateLoop()

				tweenService:Create(tokenSection, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
				for _, child in ipairs(tokenSection:GetChildren()) do
					if child:IsA("GuiObject") then
						local props = {BackgroundTransparency = 1}
						if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
							props.TextTransparency = 1
						elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
							props.ImageTransparency = 1
						end
						tweenService:Create(child, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
						tweenService:Create(child, TweenInfo.new(0.5), props):Play()
					end
				end
				task.wait(0.5)
				tokenSection.Visible = false
				
				contentArea.Visible = true
				for _, child in ipairs(contentArea:GetChildren()) do
					if child:IsA("GuiObject") then
						child.BackgroundTransparency = 1
						tweenService:Create(child, TweenInfo.new(0.5), {BackgroundTransparency = 0.5}):Play()
					end
				end

				loadPlaylists()

			else
				loadingOverlay.Visible = false
				queueNotification("Spotify Error", "Invalid token. Please check and try again.", 9622474485)
			end
		end
	end)

	if userToken and checkSpotifyToken(userToken) then
		tokenSection.Visible = false
		contentArea.Visible = true
		contentArea.BackgroundTransparency = 0.5
		
		for _, child in ipairs(contentArea:GetChildren()) do
			if child:IsA("GuiObject") then
				child.BackgroundTransparency = 0.5
				if child:IsA("ScrollingFrame") then
					child.ScrollBarImageTransparency = 0
				end
			end
		end

		loadPlaylists()
		startSpotifyUpdateLoop()
	end



end

local function updateSpotifyUI(data)
	if not musicPanel or not musicPanel:FindFirstChild("ContentArea") then return end

	local nowPlaying = musicPanel.ContentArea.NowPlaying
	if not data then
		updateDynamicIsland(nil)
		return
	end

	if data then
		
		nowPlaying.SongTitle.Text = data.song.name
		nowPlaying.ArtistName.Text = table.concat(data.artistNames, ", ")

		if getcustomasset and data.images.songCover then
			task.spawn(function()
				local folder = "Spotify Cache"
				if not isfolder(folder) then makefolder(folder) end

				local imagePath = folder.."/"..data.album.id..".jpeg"
				if not isfile(imagePath) then
					local success, content = pcall(game.HttpGet, game, data.images.songCover)
					if success then
						writefile(imagePath, content)
					end
				end

				if isfile(imagePath) then
					if nowPlaying:FindFirstChild("ArtContainer") and nowPlaying.ArtContainer:FindFirstChild("AlbumArt") then
						local success, artId = pcall(getcustomasset, imagePath)
						if success then
							nowPlaying.ArtContainer.AlbumArt.Image = artId
						end
					end
				end
			end)
		end
	end

	updateDynamicIsland(data)
end

startSpotifyUpdateLoop = function()
	if spotifyUpdateRoutine then return end
	spotifyUpdateRoutine = task.spawn(function()
		while true do
			if not userToken then 
				stopSpotifyUpdateLoop()
				break 
			end
			
			local data = getCurrentlyPlaying(userToken)
			if data then
				updateDynamicIsland(data)
				updateSpotifyUI(data)
			else
				updateDynamicIsland(nil)
			end
			
			task.wait(1)
		end
	end)
end

stopSpotifyUpdateLoop = function()
end

function SiriusSpotify.init(env)
	httpService = env.httpService
	httpRequest = env.httpRequest
	tweenService = env.tweenService
	userInputService = env.userInputService
	runService = env.runService or game:GetService("RunService")
	guiService = env.guiService or game:GetService("GuiService")
	contentProvider = env.contentProvider or game:GetService("ContentProvider")
	players = game:GetService("Players")
	lighting = game:GetService("Lighting")
	
	UI = env.UI
	siriusValues = env.siriusValues
	queueNotification = env.queueNotification
	getcustomasset = env.getcustomasset
	
	print("[SiriusSpotify] Init called.")
	print("[SiriusSpotify] queueNotification is:", queueNotification)
	
	if not queueNotification then
		warn("[SiriusSpotify] queueNotification is NIL! Using fallback.")
		queueNotification = function(title, text, icon)
			warn("[Fallback Notify]", title, text)
		end
	end
end

function SiriusSpotify.buildSpotifyUI()
	buildSpotifyUIInternal()
	if musicPanel then
		musicPanel.Visible = false
		musicPanel.GroupTransparency = 0
	end
end

function SiriusSpotify.updateDynamicIsland(data)
	updateDynamicIsland(data)
end

function SiriusSpotify.isAuthenticated()
	return userToken ~= nil and userToken ~= ""
end

function SiriusSpotify.getMusicPanel()
	return musicPanel
end

return SiriusSpotify


