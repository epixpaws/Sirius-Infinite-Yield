local SiriusSpotify = {}

local httpService
local httpRequest
local tweenService
local userInputService
local UI
local siriusValues
local queueNotification
local getcustomasset

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
    queueNotification("Spotify Session Expired", "Please re-enter your token.", 9622474485)
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
   queueNotification("Spotify Error", parsedBody.error.message, 9622474485)
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
 connection = game:GetService("RunService").RenderStepped:Connect(function(dt)
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

 local playBtn = makeBtn("PlayPause", "rbxassetid://136341313090125", UDim2.new(0.5, 0, 0.5, 0), UDim2.fromOffset(32, 32), function()
  if isPlaying then spotifyPause() else spotifyResume() end
 end)
 makeBtn("Prev", "rbxassetid://138415720834412", UDim2.new(0.5, -45, 0.5, 0), UDim2.fromOffset(24, 24), spotifyPrevious)
 makeBtn("Next", "rbxassetid://88365123525975", UDim2.new(0.5, 45, 0.5, 0), UDim2.fromOffset(24, 24), spotifyNext)

 local shapes = {
  [1] = {
   width = 400,
   height = 54,
   corner = 12,
   scale = 1,
   compactTrans = 0,
   expandedTrans = 1,
  },
  [2] = {
   width = 340,
   height = 160,
   corner = 32,
   scale = 1.02,
   compactTrans = 1,
   expandedTrans = 0,
  },
 }

 local widthSpring = Spring.new(1, 17)
 local heightSpring = Spring.new(1, 17)
 local cornerSpring = Spring.new(1, 20)
 local scaleSpring = Spring.new(1, 22)
 local compactTransSpring = Spring.new(1, 25)
 local expandedTransSpring = Spring.new(1, 25)

 widthSpring:SnapTo(400)
 heightSpring:SnapTo(54)
 cornerSpring:SnapTo(12)
 scaleSpring:SnapTo(1)
 compactTransSpring:SnapTo(0)
 expandedTransSpring:SnapTo(1)

 local function setShape(state)
  local s = shapes[state]
  if not s then return end

  widthSpring:SetTarget(s.width)
  heightSpring:SetTarget(s.height)
  cornerSpring:SetTarget(s.corner)
  scaleSpring:SetTarget(s.scale)
  compactTransSpring:SetTarget(s.compactTrans)
  expandedTransSpring:SetTarget(s.expandedTrans)

  if state == 2 then
   hitbox.Size = UDim2.new(0, 500, 0, 250)
  else
   hitbox.Size = UDim2.new(0, 500, 0, 120)
  end
 end

 hitbox.MouseEnter:Connect(function() setShape(2) end)
 hitbox.MouseLeave:Connect(function() setShape(1) end)

 dynamicIslandConnection = game:GetService("RunService").RenderStepped:Connect(function(dt)
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

  local newWidth = widthSpring:Update(dt)
  local newHeight = heightSpring:Update(dt)
  local newCorner = cornerSpring:Update(dt)
  local newScale = scaleSpring:Update(dt)
  local newCompactTrans = compactTransSpring:Update(dt)
  local newExpandedTrans = expandedTransSpring:Update(dt)

  dynamicIsland.Size = UDim2.fromOffset(newWidth, newHeight)
  corner.CornerRadius = UDim.new(0, newCorner)
  uiScale.Scale = newScale
  compactContainer.GroupTransparency = newCompactTrans
  expandedContainer.GroupTransparency = newExpandedTrans
  shadow.Size = UDim2.new(2.0, 0, 3.3, 0)

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

local function internalUpdateDynamicIsland(data)
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
    else
     playBtn.Image = "rbxassetid://136341313090125"
    end
   end
  end

  if typeof(show) == "function" then show(true) end
 else
  if typeof(show) == "function" then show(false) end
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

 local panelGradient = Instance.new("UIGradient")
 panelGradient.Color = ColorSequence.new{
  ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
  ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 5))
 }
 panelGradient.Rotation = 45
 panelGradient.Parent = musicPanel
end

function SiriusSpotify.init(env)
 httpService = env.httpService
 httpRequest = env.httpRequest
 tweenService = env.tweenService
 userInputService = env.userInputService
 UI = env.UI
 siriusValues = env.siriusValues
 queueNotification = env.queueNotification
 getcustomasset = env.getcustomasset
end

function SiriusSpotify.buildSpotifyUI()
 buildSpotifyUIInternal()
end

function SiriusSpotify.updateDynamicIsland(data)
 internalUpdateDynamicIsland(data)
end

return SiriusSpotify

