-- Ryota Hub Smooth Path System
-- contoh untuk project sendiri di Roblox Studio

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- data
local recording = false
local path = {}
local loop = false
local lastSafePos = nil

-------------------------------------------------
-- PATH RECORD
-------------------------------------------------

task.spawn(function()
	while true do
		if recording then
			table.insert(path, root.Position)
			lastSafePos = root.Position
		end
		task.wait(0.25)
	end
end)

-------------------------------------------------
-- CURVE SMOOTHING
-------------------------------------------------

local function curve(a,b,c,t)
	local p1 = a:Lerp(b,t)
	local p2 = b:Lerp(c,t)
	return p1:Lerp(p2,t)
end

local function moveCurve(a,b,c)
	for t=0,1,0.05 do
		local pos = curve(a,b,c,t)
		root.CFrame = CFrame.new(pos)
		RunService.Heartbeat:Wait()
	end
end

-------------------------------------------------
-- PLAYBACK
-------------------------------------------------

local function playPath()
	repeat
		for i=2,#path-1 do
			moveCurve(path[i-1],path[i],path[i+1])
		end
	until not loop
end

-------------------------------------------------
-- RECOVER JIKA JATUH
-------------------------------------------------

RunService.Heartbeat:Connect(function()
	if root.Position.Y < -50 then
		if lastSafePos then
			root.CFrame = CFrame.new(lastSafePos)
		end
	end
end)

-------------------------------------------------
-- MERGE PATH
-------------------------------------------------

local function mergePath(newPath)
	for _,pos in ipairs(newPath) do
		table.insert(path,pos)
	end
end

-------------------------------------------------
-- UI RYOTA HUB
-------------------------------------------------

local gui = Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))

local frame = Instance.new("Frame",gui)
frame.Size = UDim2.new(0,420,0,260)
frame.Position = UDim2.new(0.35,0,-0.5,0)
frame.BackgroundColor3 = Color3.fromRGB(35,0,0)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel",frame)
title.Size = UDim2.new(1,0,0,40)
title.Text = "Ryota Hub"
title.TextScaled = true
title.BackgroundColor3 = Color3.fromRGB(180,0,0)
title.TextColor3 = Color3.fromRGB(255,255,255)

local status = Instance.new("TextLabel",frame)
status.Size = UDim2.new(1,0,0,25)
status.Position = UDim2.new(0,0,0,40)
status.BackgroundTransparency = 1
status.Text = "Status: Idle"
status.TextColor3 = Color3.fromRGB(255,255,255)

local content = Instance.new("Frame",frame)
content.Size = UDim2.new(1,0,1,-70)
content.Position = UDim2.new(0,0,0,70)
content.BackgroundTransparency = 1

local function makeBtn(text,x,y)
	local b = Instance.new("TextButton",content)
	b.Size = UDim2.new(0,160,0,40)
	b.Position = UDim2.new(x,0,y,0)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(220,0,0)
	b.TextColor3 = Color3.fromRGB(255,255,255)
	return b
end

local recordBtn = makeBtn("Record",0.05,0.1)
local stopBtn = makeBtn("Stop",0.55,0.1)
local playBtn = makeBtn("Play",0.05,0.4)
local loopBtn = makeBtn("Loop OFF",0.55,0.4)

-------------------------------------------------
-- BUTTON LOGIC
-------------------------------------------------

recordBtn.MouseButton1Click:Connect(function()
	recording = true
	path = {}
	status.Text = "Status: Recording"
end)

stopBtn.MouseButton1Click:Connect(function()
	recording = false
	status.Text = "Status: Stopped"
end)

playBtn.MouseButton1Click:Connect(function()
	status.Text = "Status: Playing"
	playPath()
end)

loopBtn.MouseButton1Click:Connect(function()
	loop = not loop
	loopBtn.Text = loop and "Loop ON" or "Loop OFF"
end)

-------------------------------------------------
-- OPEN ANIMATION
-------------------------------------------------

local openTween = TweenService:Create(
	frame,
	TweenInfo.new(0.4,Enum.EasingStyle.Quad),
	{Position = UDim2.new(0.35,0,0.3,0)}
)

openTween:Play()
