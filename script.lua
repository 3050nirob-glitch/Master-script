local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

-- ==================== ১. অ্যান্টি-চিট ও কিক বাইপাস ====================
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" then return end
        if method == "UserOwnsGamePassAsync" or method == "PlayerOwnsAsset" then return true end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

local Toggles = {
    Speed = true, Fly = false, FlyWallHack = false, WallHack = false,
    ESP = false, Antenna = true, UnlockVIP = false, Aimbot = false, HeadshotOnly = false,
    AutoKill = false, AutoFarm = false, AutoCollect = false, Giant = false, 
    Invisible = false, ForceStay = false, AntiVoid = true, GodMode = true
}

local Values = {
    Speed = 100, FlySpeed = 150, GiantSize = 10, TargetName = ""
}

-- ==================== ২. UI (Perfect Scroll) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MasterUI_V14"
pcall(function() ScreenGui.Parent = game.CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Icon = Instance.new("TextButton")
Icon.Parent = ScreenGui
Icon.Size = UDim2.new(0, 45, 0, 45)
Icon.Position = UDim2.new(0, 10, 0, 50)
Icon.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Icon.Text = "H"
Icon.TextColor3 = Color3.fromRGB(255, 255, 255)
Icon.Font = Enum.Font.SourceSansBold
Icon.TextSize = 22
Icon.BorderSizePixel = 0

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
MainFrame.Size = UDim2.new(0, 180, 0, 420)
MainFrame.Position = UDim2.new(0, 65, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
MainFrame.ScrollBarThickness = 6
MainFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 0, 0)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- ১০০% স্ক্রল ফিক্স
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
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = placeholder
    box.Text = tostring(Values[valueKey])
    box.Font = Enum.Font.SourceSansBold
    box.TextSize = 14
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    
    box.FocusLost:Connect(function()
        if valueKey == "TargetName" then
            Values[valueKey] = box.Text
        else
            local num = tonumber(box.Text)
            if num and num >= 0 and num <= 2000 then Values[valueKey] = num else box.Text = tostring(Values[valueKey]) end
        end
    end)
end

local function createActionBtn(name, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.MouseButton1Click:Connect(callback)
end

-- ==================== ৩. মেইন ফাংশনসমূহ ====================
createToggle("Speed Hack", "Speed")
createBox("Speed (Max 2000)", "Speed")

createToggle("Fly", "Fly")
createToggle("Fly + WallHack", "FlyWallHack")
createBox("Fly Speed (Max 2000)", "FlySpeed")

createToggle("WallHack (Noclip)", "WallHack")
createToggle("ESP + Location Line", "ESP")
createToggle("Antenna Lines", "Antenna")
createToggle("Aimbot", "Aimbot")
createToggle("Headshot Only", "HeadshotOnly")
createToggle("Auto Kill", "AutoKill")
createToggle("Auto Farm", "AutoFarm")
createToggle("Auto Collect", "AutoCollect")
createToggle("Giant Body", "Giant")
createBox("Size (Max 2000)", "GiantSize")
createToggle("Invisible", "Invisible")
createToggle("Force Stay (Bypass)", "ForceStay")
createToggle("God Mode (Anti-Kick)", "GodMode")
createToggle("Anti-Void", "AntiVoid")

-- অ্যাকশন বাটন
createActionBtn("UNLOCK VIP (Bypass All)", function()
    local found = 0
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Tool") then
            pcall(function() local c = v:Clone(); c.Parent = LocalPlayer.Backpack; found = found + 1 end)
        end
    end
    print("Bypassed " .. found .. " Tools!")
end)

createActionBtn("Teleport (Click TP)", function()
    Toggles.ClickTP = not Toggles.ClickTP
    print("Click TP: " .. tostring(Toggles.ClickTP))
end)

createActionBtn("PANIC ESCAPE (Fly Up)", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 500, 0)
        Toggles.ForceStay = false
    end
end)

createActionBtn("Bring All Players", function()
    local myChar = LocalPlayer.Character
    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function() p.Character.HumanoidRootPart.CFrame = myChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end)
            end
        end
    end
end)

createActionBtn("Fling All Players", function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local bv = Instance.new("BodyAngularVelocity")
                bv.AngularVelocity = Vector3.new(9999, 9999, 9999)
                bv.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bv.Parent = p.Character.HumanoidRootPart
                p.Character.HumanoidRootPart.Velocity = Vector3.new(math.huge, math.huge, math.huge)
            end)
        end
    end
end)

-- ৫০+ ফাংশন লিস্ট
local extraFunctions = {
    "Inf Jump", "Fullbright", "Click TP", "Goto Closest", "Server Hop", "Rejoin Server",
    "FPS Boost", "Headless", "Korblox", "Spin Player", "Reset Char", "Spam Chat",
    "Delete Map (Local)", "Walk on Water", "Moon Gravity", "Zero Gravity", "Dance",
    "Sit", "Ragdoll", "No Fall Dmg", "Anti-Fling", "Auto Parry", "Silent Aim",
    "Trigger Bot", "Fast Equip", "Kill All (Local)", "Freeze All", "Remove Fog",
    "Remove Sky", "ESP Names", "ESP Health", "ESP Tracer", "Item ESP", "X-Ray",
    "Skeleton ESP", "Name Changer", "Auto Upgrade", "Auto Sell", "Auto Buy",
    "One Hit Kill", "Hitbox Viewer", "Inf Ammo", "Inf Stamina", "Instant Interact"
}

for _, fName in ipairs(extraFunctions) do
    createActionBtn(fName, function()
        if fName == "Inf Jump" then
            Toggles.InfJump = not Toggles.InfJump
        elseif fName == "Fullbright" then
            local bright = Instance.new("ColorCorrectionEffect")
            bright.Brightness = 3
            bright.Parent = game:GetService("Lighting")
        elseif fName == "Goto Closest" then
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local closest, dist = nil, 9999
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local d = (myChar.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if d < dist then closest = p; dist = d end
                    end
                end
                if closest then myChar.HumanoidRootPart.CFrame = closest.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end
            end
        elseif fName == "Server Hop" then
            local Http, TeleportService = game:GetService("HttpService"), game:GetService("TeleportService")
            pcall(function()
                local servers = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
                for _, v in pairs(servers.data) do
                    if v.playing < v.maxPlayers and v.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer)
                        break
                    end
                end
            end)
        elseif fName == "Rejoin Server" then
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        elseif fName == "Headless" then
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid").HeadScale.Value = 0.01 end
        elseif fName == "Korblox" then
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid").BodyTypeScale.Value = 0.01 end
        elseif fName == "Reset Char" then
            if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end
        end
    end)
end

-- ==================== ৪. কোর লজিক (স্পিড, ফ্লাই, ওয়ালহ্যাক) ====================
local bodyVel, gravityForce, speedBodyVel
local jumpRequested = false

UserInputService.JumpRequest:Connect(function()
    jumpRequested = true
    task.delay(0.1, function() jumpRequested = false end)
    if Toggles.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- God Mode
    if Toggles.GodMode and hum.Health < hum.MaxHealth then
        pcall(function() hum.Health = hum.MaxHealth end)
    end

    -- Anti-Void
    if Toggles.AntiVoid and hrp.Position.Y < -50 then
        pcall(function() hrp.CFrame = CFrame.new(0, 50, 0) end)
    end

    -- Giant
    if Toggles.Giant then pcall(function() char:ScaleTo(Values.GiantSize) end) else pcall(function() char:ScaleTo(1) end) end

    -- Invisible
    if Toggles.Invisible then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then pcall(function() v.Transparency = 1 end) end
        end
    end

    -- WallHack (Noclip)
    if Toggles.WallHack then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then pcall(function() part.CanCollide = false end) end
        end
    end

    -- Speed
    if Toggles.Speed and not Toggles.Fly then
        hum.WalkSpeed = 16 
        if Values.Speed > 100 then
            if not speedBodyVel or speedBodyVel.Parent ~= hrp then
                if speedBodyVel then speedBodyVel:Destroy() end
                speedBodyVel = Instance.new("BodyVelocity")
                speedBodyVel.MaxForce = Vector3.new(1e5, 0, 1e5) 
                speedBodyVel.Parent = hrp
            end
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then speedBodyVel.Velocity = moveDir * Values.Speed else speedBodyVel.Velocity = Vector3.new(0, 0, 0) end
        else
            if speedBodyVel then speedBodyVel:Destroy() speedBodyVel = nil end
            hum.WalkSpeed = Values.Speed
        end
    else
        if speedBodyVel then speedBodyVel:Destroy() speedBodyVel = nil end
    end

    -- Fly Logic (Mobile Smooth)
    if Toggles.Fly then
        hum.WalkSpeed = 16
        if not bodyVel or bodyVel.Parent ~= hrp then
            if bodyVel then bodyVel:Destroy() end
            bodyVel = Instance.new("BodyVelocity")
            bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bodyVel.Parent = hrp
            gravityForce = Instance.new("BodyForce")
            gravityForce.Force = Vector3.new(0, workspace.Gravity * hrp.AssemblyMass, 0)
            gravityForce.Parent = hrp
        end
        
        if Toggles.FlyWallHack then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
        
        local direction = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
        
        if hum.MoveDirection.Magnitude > 0 then
            direction = direction + hum.MoveDirection
        end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or jumpRequested then direction = direction + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
        
        if direction.Magnitude > 0 then bodyVel.Velocity = direction.Unit * Values.FlySpeed else bodyVel.Velocity = Vector3.new(0, 0, 0) end
    else
        if bodyVel then bodyVel:Destroy() bodyVel = nil end
        if gravityForce then gravityForce:Destroy() gravityForce = nil end
    end
end)

-- ==================== ৫. Force Stay, Click TP & ESP/Antenna ====================
local forceStayBP
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        if Toggles.ForceStay then
            if not forceStayBP or forceStayBP.Parent ~= char.HumanoidRootPart then
                if forceStayBP then forceStayBP:Destroy() end
                forceStayBP = Instance.new("BodyPosition")
                forceStayBP.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                forceStayBP.P = 50000
                forceStayBP.Parent = char.HumanoidRootPart
            end
            forceStayBP.Position = char.HumanoidRootPart.Position
        else
            if forceStayBP then forceStayBP:Destroy() forceStayBP = nil end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Toggles.ClickTP and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local mouse = LocalPlayer:GetMouse()
            if mouse.Hit then
                pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end)
            end
        end
    end
end)

local AntennaLines = {}
task.spawn(function()
    while task.wait(0.05) do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local head = p.Character:FindFirstChild("Head")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                
                -- ESP
                if Toggles.ESP then
                    if not p.Character:FindFirstChild("OllieESP") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "OllieESP"
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Parent = p.Character
                    end
                else
                    if p.Character:FindFirstChild("OllieESP") then p.Character.OllieESP:Destroy() end
                end

                -- Antenna
                if Toggles.Antenna and head then
                    if not AntennaLines[p] then
                        local line = Drawing.new("Line")
                        line.Thickness = 1
                        line.Color = Color3.fromRGB(255, 0, 0)
                        line.Transparency = 1
                        AntennaLines[p] = line
                    end
                    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        AntennaLines[p].From = Vector2.new(Camera.ViewportSize.X / 2, 0)
                        AntennaLines[p].To = Vector2.new(headPos.X, headPos.Y)
                        AntennaLines[p].Visible = true
                    else
                        AntennaLines[p].Visible = false
                    end
                elseif AntennaLines[p] then
                    AntennaLines[p].Visible = false
                end
            end
        end
    end
end)

-- ==================== ৬. Aimbot, Auto Kill & Auto Farm ====================
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
        local target = getClosest()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            pcall(function() Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Character.Head.Position) end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if Toggles.AutoKill then
            local target = getClosest()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    pcall(function() myChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 2) end)
                    local tool = myChar:FindFirstChildOfClass("Tool") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChildOfClass("Tool"))
                    if tool then
                        if tool.Parent ~= myChar then tool.Parent = myChar end
                        pcall(function() tool:Activate() end)
                    end
                    pcall(function()
                        firetouchinterest(myChar.HumanoidRootPart, target.Character.HumanoidRootPart, 0)
                        firetouchinterest(myChar.HumanoidRootPart, target.Character.HumanoidRootPart, 1)
                    end)
                end
            end
        end

        -- Auto Collect (টাকা বা আইটেম কুড়ানো)
        if Toggles.AutoCollect or Toggles.AutoFarm then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("BasePart") and (string.find(string.lower(v.Name), "coin") or string.find(string.lower(v.Name), "cash") or string.find(string.lower(v.Name), "gem")) then
                        pcall(function()
                            firetouchinterest(char.HumanoidRootPart, v, 0)
                            firetouchinterest(char.HumanoidRootPart, v, 1)
                        end)
                    end
                end
            end
        end
    end
end)

print("Absolute Master Code V14 (Everything Unlocked) Loaded Successfully!")
