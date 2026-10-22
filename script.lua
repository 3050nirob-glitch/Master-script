local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

-- ==================== অ্যান্টি-কিক হুক (টেলিপোর্ট ব্লক রিমুভড) ====================
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" then 
            return 
        end
        if method == "UserOwnsGamePassAsync" or method == "PlayerOwnsAsset" then 
            return true 
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

local Toggles = {
    Speed = true, Fly = false, FlyLock = false, FlyWallHack = false, WallHack = false,
    ESP = false, Antenna = true, Aimbot = false, HeadshotOnly = false,
    AutoKill = false, AutoFarm = false, Giant = false, Invisible = false, 
    ForceStay = false, AntiVoid = true, GodMode = true, InfJump = false, Fullbright = false
}

local Values = {
    Speed = 100, FlySpeed = 150, GiantSize = 10
}

-- ==================== UI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MasterUI_V21"
pcall(function() ScreenGui.Parent = game.CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Icon = Instance.new("TextButton")
Icon.Parent = ScreenGui
Icon.Size = UDim2.new(0, 45, 0, 45)
Icon.Position = UDim2.new(0, 10, 0, 50)
Icon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Icon.Text = "H"
Icon.TextColor3 = Color3.fromRGB(255, 50, 50)
Icon.Font = Enum.Font.SourceSansBold
Icon.TextSize = 22
Icon.BorderSizePixel = 0
local iconCorner = Instance.new("UICorner", Icon)
iconCorner.CornerRadius = UDim.new(0, 8)
local iconStroke = Instance.new("UIStroke", Icon)
iconStroke.Color = Color3.fromRGB(255, 0, 0)
iconStroke.Thickness = 2

local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
Icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; mousePos = input.Position; framePos = Icon.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
Icon.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        Icon.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

local MainFrame = Instance.new("ScrollingFrame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 180, 0, 400)
MainFrame.Position = UDim2.new(0, 65, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
MainFrame.ScrollBarThickness = 4
MainFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
local frameCorner = Instance.new("UICorner", MainFrame)
frameCorner.CornerRadius = UDim.new(0, 10)
local frameStroke = Instance.new("UIStroke", MainFrame)
frameStroke.Color = Color3.fromRGB(50, 50, 50)
frameStroke.Thickness = 2

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

task.spawn(function()
    while task.wait(0.5) do
        if MainFrame and UIListLayout then
            MainFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 100)
        end
    end
end)

Icon.MouseButton1Click:Connect(function()
    if not dragging then MainFrame.Visible = not MainFrame.Visible end
end)

local function createToggle(name, toggleName)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Toggles[toggleName] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Text = name .. ": " .. (Toggles[toggleName] and "ON" or "OFF")
    local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        Toggles[toggleName] = not Toggles[toggleName]
        btn.Text = name .. ": " .. (Toggles[toggleName] and "ON" or "OFF")
        btn.BackgroundColor3 = Toggles[toggleName] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)
end

local function createBox(placeholder, valueKey)
    local box = Instance.new("TextBox")
    box.Parent = MainFrame
    box.Size = UDim2.new(1, 0, 0, 30)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    box.TextColor3 = Color3.fromRGB(200, 200, 200)
    box.PlaceholderText = placeholder
    box.Text = tostring(Values[valueKey])
    box.Font = Enum.Font.SourceSansBold
    box.TextSize = 14
    box.BorderSizePixel = 0
    local c = Instance.new("UICorner", box); c.CornerRadius = UDim.new(0, 6)
    
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num and num >= 0 and num <= 2000 then Values[valueKey] = num else box.Text = tostring(Values[valueKey]) end
    end)
end

local function createActionBtn(name, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Text = name
    local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        pcall(callback)
        task.wait(0.3)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
    end)
end

-- ==================== গুরুত্বপূর্ণ ফাংশন ====================
createToggle("Speed Hack", "Speed")
createBox("Speed (Max 2000)", "Speed")
createToggle("Fly", "Fly")
createToggle("Lock Vertical (Fly)", "FlyLock")
createToggle("Fly + WallHack", "FlyWallHack")
createBox("Fly Speed (Max 2000)", "FlySpeed")
createToggle("Aimbot", "Aimbot")
createToggle("Headshot Only", "HeadshotOnly")
createToggle("Auto Kill (Teleport)", "AutoKill")
createToggle("Auto Farm / Collect", "AutoFarm")
createToggle("Giant Body", "Giant")
createBox("Size (Max 2000)", "GiantSize")
createToggle("Invisible", "Invisible")
createToggle("Force Stay (Bypass)", "ForceStay")
createToggle("God Mode", "GodMode")
createToggle("Anti-Void", "AntiVoid")
createToggle("WallHack (Noclip)", "WallHack")
createToggle("ESP + Location", "ESP")
createToggle("Antenna Lines", "Antenna")
createToggle("Inf Jump", "InfJump")
createToggle("Fullbright", "Fullbright")

-- ==================== অ্যাকশন ফাংশন ====================
createActionBtn("TP to Mouse (Click)", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local m = LocalPlayer:GetMouse()
        if m.Hit then char.HumanoidRootPart.CFrame = CFrame.new(m.Hit.Position + Vector3.new(0, 3, 0)) end
    end
end)

createActionBtn("Goto Closest", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local c, d = nil, 9999
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (char.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < d then c = p; d = dist end
            end
        end
        if c then char.HumanoidRootPart.CFrame = c.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end
    end
end)

createActionBtn("Bring All", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            end
        end
    end
end)

createActionBtn("Fling All", function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local bv = Instance.new("BodyAngularVelocity"); bv.AngularVelocity = Vector3.new(9999, 9999, 9999); bv.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bv.Parent = p.Character.HumanoidRootPart
            p.Character.HumanoidRootPart.Velocity = Vector3.new(math.huge, math.huge, math.huge)
        end
    end
end)

createActionBtn("Server Hop", function()
    local Http, TS = game:GetService("HttpService"), game:GetService("TeleportService")
    pcall(function()
        local s = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, v in pairs(s.data) do if v.playing < v.maxPlayers and v.id ~= game.JobId then TS:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer) break end end
    end)
end)

createActionBtn("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

createActionBtn("FPS Boost", function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
        if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
    end
end)

createActionBtn("Headless", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid").HeadScale.Value = 0.01 end
end)

createActionBtn("Korblox", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid").BodyTypeScale.Value = 0.01 end
end)

createActionBtn("Spin Player", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local bv = Instance.new("BodyAngularVelocity"); bv.AngularVelocity = Vector3.new(0, 20, 0); bv.MaxTorque = Vector3.new(0, math.huge, 0); bv.Parent = char.HumanoidRootPart
        task.delay(3, function() if bv then bv:Destroy() end end)
    end
end)

createActionBtn("Reset Character", function()
    if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end
end)

createActionBtn("Remove Fog & Sky", function()
    Lighting.FogEnd = 100000; Lighting.FogStart = 100000
    for _, v in pairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
end)

createActionBtn("Walk on Water", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local p = Instance.new("Part"); p.Name = "OllieWater"; p.Size = Vector3.new(50, 1, 50); p.Transparency = 1; p.Anchored = true; p.CanCollide = true; p.Parent = workspace; p.CFrame = char.HumanoidRootPart.CFrame - Vector3.new(0, 3, 0)
    end
end)

createActionBtn("Freeze All", function()
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.Anchored = true end end
end)

createActionBtn("Unlock VIP Tools", function()
    for _, v in pairs(game:GetDescendants()) do if v:IsA("Tool") then pcall(function() local c = v:Clone(); c.Parent = LocalPlayer.Backpack end) end end
end)

-- ==================== কোর লজিক (সেফ লোডিং) ====================
local bodyVel, gravityForce, speedBodyVel
local jumpRequested = false

UserInputService.JumpRequest:Connect(function()
    jumpRequested = true
    task.delay(0.1, function() jumpRequested = false end)
    if Toggles.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- Fullbright
    if Toggles.Fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
    else
        Lighting.Brightness = 1
    end

    -- God Mode & Anti Void
    if Toggles.GodMode and hum.Health < hum.MaxHealth then pcall(function() hum.Health = hum.MaxHealth end) end
    if Toggles.AntiVoid and hrp.Position.Y < -50 then pcall(function() hrp.CFrame = CFrame.new(0, 50, 0) end) end

    -- Giant & Invisible
    if Toggles.Giant then pcall(function() char:ScaleTo(Values.GiantSize) end) else pcall(function() char:ScaleTo(1) end) end
    if Toggles.Invisible then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Transparency = 1 end end end

    -- WallHack
    if Toggles.WallHack then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end end

    -- Speed
    if Toggles.Speed and not Toggles.Fly then
        hum.WalkSpeed = 16 
        if Values.Speed > 100 then
            if not speedBodyVel or speedBodyVel.Parent ~= hrp then
                if speedBodyVel then speedBodyVel:Destroy() end
                speedBodyVel = Instance.new("BodyVelocity"); speedBodyVel.MaxForce = Vector3.new(1e5, 0, 1e5); speedBodyVel.Parent = hrp
            end
            local m = hum.MoveDirection
            if m.Magnitude > 0 then speedBodyVel.Velocity = m * Values.Speed else speedBodyVel.Velocity = Vector3.new(0, 0, 0) end
        else
            if speedBodyVel then speedBodyVel:Destroy() speedBodyVel = nil end
            hum.WalkSpeed = Values.Speed
        end
    else
        if speedBodyVel then speedBodyVel:Destroy() speedBodyVel = nil end
    end

    -- Fly Logic
    if Toggles.Fly then
        hum.WalkSpeed = 16
        if not bodyVel or bodyVel.Parent ~= hrp then
            if bodyVel then bodyVel:Destroy() end
            bodyVel = Instance.new("BodyVelocity"); bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5); bodyVel.Parent = hrp
            gravityForce = Instance.new("BodyForce"); gravityForce.Force = Vector3.new(0, workspace.Gravity * hrp.AssemblyMass, 0); gravityForce.Parent = hrp
        end
        if Toggles.FlyWallHack then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end end
        
        local direction = Vector3.new()
        if hum.MoveDirection.Magnitude > 0 then
            local camLook = Camera.CFrame.LookVector
            local camRight = Camera.CFrame.RightVector
            local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
            local flatRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
            local forwardAmount = hum.MoveDirection:Dot(flatLook)
            local rightAmount = hum.MoveDirection:Dot(flatRight)
            
            if Toggles.FlyLock then
                direction = (flatLook * forwardAmount) + (flatRight * rightAmount)
            else
                direction = (camLook * forwardAmount) + (camRight * rightAmount)
            end
        end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or jumpRequested then direction = direction + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
        
        if direction.Magnitude > 0 then bodyVel.Velocity = direction.Unit * Values.FlySpeed else bodyVel.Velocity = Vector3.new(0, 0, 0) end
    else
        if bodyVel then bodyVel:Destroy() bodyVel = nil end
        if gravityForce then gravityForce:Destroy() gravityForce = nil end
    end
end)

-- ESP & Antenna (সেফ লুপ)
local AntennaLines = {}
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local head = p.Character:FindFirstChild("Head")
                    if Toggles.ESP then
                        if not p.Character:FindFirstChild("OllieESP") then
                            local hl = Instance.new("Highlight"); hl.Name = "OllieESP"; hl.FillColor = Color3.fromRGB(255, 0, 0); hl.Parent = p.Character
                        end
                    else
                        if p.Character:FindFirstChild("OllieESP") then p.Character.OllieESP:Destroy() end
                    end
                    if Toggles.Antenna and head then
                        if not AntennaLines[p] then
                            local line = Drawing.new("Line"); line.Thickness = 1; line.Color = Color3.fromRGB(255, 0, 0); line.Transparency = 1; AntennaLines[p] = line
                        end
                        local hp, os = Camera:WorldToViewportPoint(head.Position)
                        if os then AntennaLines[p].From = Vector2.new(Camera.ViewportSize.X / 2, 0); AntennaLines[p].To = Vector2.new(hp.X, hp.Y); AntennaLines[p].Visible = true else AntennaLines[p].Visible = false end
                    elseif AntennaLines[p] then AntennaLines[p].Visible = false end
                end
            end
        end)
    end
end)

-- Aimbot & Auto Kill (সেফ লুপ)
local function getClosest()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local closest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local d = (myChar.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then closest = p; dist = d end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if Toggles.Aimbot or Toggles.HeadshotOnly then
        pcall(function()
            local target = getClosest()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Character.Head.Position)
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if Toggles.AutoKill then
                local target = getClosest()
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local myChar = LocalPlayer.Character
                    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                        myChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 2)
                        local tool = myChar:FindFirstChildOfClass("Tool") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChildOfClass("Tool"))
                        if tool then if tool.Parent ~= myChar then tool.Parent = myChar end; pcall(function() tool:Activate() end) end
                        pcall(function() firetouchinterest(myChar.HumanoidRootPart, target.Character.HumanoidRootPart, 0); firetouchinterest(myChar.HumanoidRootPart, target.Character.HumanoidRootPart, 1) end)
                    end
                end
            end
            if Toggles.AutoFarm then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    for _, v in pairs(workspace:GetChildren()) do
                        if v:IsA("BasePart") and (string.find(string.lower(v.Name), "coin") or string.find(string.lower(v.Name), "cash")) then
                            pcall(function() firetouchinterest(char.HumanoidRootPart, v, 0); firetouchinterest(char.HumanoidRootPart, v, 1) end)
                        end
                    end
                end
            end
        end)
    end
end)

print("Absolute Master V21 Loaded Successfully!")
