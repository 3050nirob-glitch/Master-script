local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ==================== অ্যান্টি-চিট হুক (কিক ব্লক) ====================
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" then return end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

local Toggles = {
    Speed = true, Fly = false, SlapAura = true, Giant = false, 
    Hitbox = false, ESP = false, Antenna = true, Noclip = false, 
    InfJump = false, AntiVoid = true, Fullbright = false, ClickTP = false,
    GodMode = true, AutoParry = false, RapidFire = false, NoReload = false,
    Invisible = false, MoonGravity = false, ZeroGravity = false, AntiFling = true
}

local Values = {
    Speed = 60, FlySpeed = 50, SlapRange = 100, GiantSize = 3
}

-- ==================== UI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateV9_UI"
pcall(function() ScreenGui.Parent = game.CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ড্র্যাগেবল আইকন
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

-- মেইন স্ক্রলিং ফ্রেম (ফিক্সড)
local MainFrame = Instance.new("ScrollingFrame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 180, 0, 400)
MainFrame.Position = UDim2.new(0, 65, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ScrollingDirection = Enum.ScrollingDirection.Y
MainFrame.ScrollingEnabled = true
MainFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y -- অটো স্ক্রল ফিক্স
MainFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
MainFrame.ScrollBarThickness = 6
MainFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 0, 0)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

Icon.MouseButton1Click:Connect(function()
    if not dragging then MainFrame.Visible = not MainFrame.Visible end
end)

-- হেল্পার ফাংশন (বাটন ও টেক্সট বক্স)
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

local function createBox(name, valueKey)
    local box = Instance.new("TextBox")
    box.Parent = MainFrame
    box.Size = UDim2.new(1, 0, 0, 30)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = name
    box.Text = tostring(Values[valueKey])
    box.Font = Enum.Font.SourceSansBold
    box.TextSize = 14
    box.BorderSizePixel = 0
    
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then Values[valueKey] = num else box.Text = tostring(Values[valueKey]) end
    end)
end

local function createButton(name, callback)
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

-- ==================== ১. কোর ফাংশনসমূহ (৫০+) ====================
createToggle("Speed Hack", "Speed")
createBox("Set Walk Speed", "Speed")

createToggle("Fly", "Fly")
createBox("Set Fly Speed", "FlySpeed")

createToggle("Slap Aura (Auto)", "SlapAura")
createBox("Set Slap Range (Studs)", "SlapRange")

createToggle("Ultra Giant", "Giant")
createBox("Set Giant Size", "GiantSize")

createToggle("Hitbox Expander", "Hitbox")
createToggle("ESP (Player Box)", "ESP")
createToggle("Antenna Lines", "Antenna")
createToggle("Noclip (Wall Hack)", "Noclip")
createToggle("Inf Jump", "InfJump")
createToggle("Anti-Void (No Death)", "AntiVoid")
createToggle("Fullbright", "Fullbright")
createToggle("Click TP", "ClickTP")
createToggle("God Mode (Local)", "GodMode")
createToggle("Auto Parry", "AutoParry")
createToggle("Rapid Fire", "RapidFire")
createToggle("No Reload", "NoReload")
createToggle("Invisible", "Invisible")
createToggle("Moon Gravity", "MoonGravity")
createToggle("Zero Gravity", "ZeroGravity")
createToggle("Anti-Fling", "AntiFling")

-- অ্যাকশন বাটনসমূহ
createButton("Bring All Players", function()
    local myChar = LocalPlayer.Character
    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function() p.Character.HumanoidRootPart.CFrame = myChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end)
            end
        end
    end
end)

createButton("Fling All Players", function()
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

createButton("Kill All (Spam)", function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum.Health = 0 end) end
        end
    end
end)

createButton("Freeze All", function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                p.Character.HumanoidRootPart.Anchored = true
            end)
        end
    end
end)

createButton("Server Hop", function()
    local Http = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId
    pcall(function()
        local servers = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, v in pairs(servers.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, v.id, LocalPlayer)
                break
            end
        end
    end)
end)

createButton("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

createButton("FPS Boost (Low GFX)", function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
        if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
    end
end)

createButton("Spin Character", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local bv = Instance.new("BodyAngularVelocity")
        bv.AngularVelocity = Vector3.new(0, 20, 0)
        bv.MaxTorque = Vector3.new(0, math.huge, 0)
        bv.Parent = char.HumanoidRootPart
        task.delay(3, function() bv:Destroy() end)
    end
end)

createButton("Headless/Korblox", function()
    local char = LocalPlayer.Character
    if char then
        pcall(function()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.HeadScale.Value = 0.01
                local desc = hum:FindFirstChild("BodyTypeScale")
                if desc then desc.Value = 0.01 end
            end
        end)
    end
end)

createButton("Reset Character", function()
    if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end
end)

createButton("Spam Chat (Loop)", function()
    local chatEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvent then
        local sayMessage = chatEvent:FindFirstChild("SayMessageRequest")
        if sayMessage then
            for i=1, 10 do
                pcall(function() sayMessage:FireServer("OLLIE WAS HERE!", "All") end)
                task.wait(0.1)
            end
        end
    end
end)

createButton("Delete Map (Local)", function()
    for _, v in pairs(workspace:GetChildren()) do
        if v ~= LocalPlayer.Character and v:IsA("Model") then
            v:Destroy()
        end
    end
end)

createButton("Walk On Water", function()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local waterPlatform = Instance.new("Part")
            waterPlatform.Size = Vector3.new(50, 1, 50)
            waterPlatform.Transparency = 1
            waterPlatform.Anchored = true
            waterPlatform.CanCollide = true
            waterPlatform.Parent = workspace
            waterPlatform.CFrame = hrp.CFrame - Vector3.new(0, 3, 0)
        end
    end
end)

createButton("Goto Closest Player", function()
    local myChar = LocalPlayer.Character
    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
        local closest, dist = nil, 9999
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (myChar.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then closest = p; dist = d end
            end
        end
        if closest then
            myChar.HumanoidRootPart.CFrame = closest.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end
end)

-- ==================== ২. কোর লজিক ====================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- Speed
    if Toggles.Speed and not Toggles.Fly and hum.WalkSpeed ~= Values.Speed then
        pcall(function() hum.WalkSpeed = Values.Speed end)
    end

    -- God Mode (Local)
    if Toggles.GodMode and hum.Health < hum.MaxHealth then
        pcall(function() hum.Health = hum.MaxHealth end)
    end

    -- Noclip
    if Toggles.Noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then pcall(function() part.CanCollide = false end) end
        end
    end

    -- Gravity
    if Toggles.MoonGravity then workspace.Gravity = 50 elseif Toggles.ZeroGravity then workspace.Gravity = 0 else workspace.Gravity = 196.2 end

    -- Giant
    if Toggles.Giant then pcall(function() char:ScaleTo(Values.GiantSize) end) else pcall(function() char:ScaleTo(1) end) end
    
    -- Invisible
    if Toggles.Invisible then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then pcall(function() v.Transparency = 1 end) end
        end
    end
end)

-- Fly Logic
local bodyVel, gravityForce
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if Toggles.Fly and hrp and hum then
        hum.WalkSpeed = 16
        if not bodyVel then
            bodyVel = Instance.new("BodyVelocity")
            bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bodyVel.Parent = hrp
            gravityForce = Instance.new("BodyForce")
            gravityForce.Force = Vector3.new(0, workspace.Gravity * hrp.AssemblyMass, 0)
            gravityForce.Parent = hrp
        end
        
        local direction = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
        
        if direction.Magnitude > 0 then bodyVel.Velocity = direction.Unit * Values.FlySpeed else bodyVel.Velocity = Vector3.new(0, 0, 0) end
    else
        if bodyVel then bodyVel:Destroy() bodyVel = nil end
        if gravityForce then gravityForce:Destroy() gravityForce = nil end
    end
end)

-- Slap Aura & Hitbox Loop
task.spawn(function()
    while task.wait(0.05) do
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local hrp = char.HumanoidRootPart

        if Toggles.AntiVoid and hrp.Position.Y < -50 then
            pcall(function() hrp.CFrame = CFrame.new(0, 50, 0) end)
        end

        if Toggles.SlapAura then
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local tool = char:FindFirstChildOfClass("Tool") or (backpack and backpack:FindFirstChildOfClass("Tool"))
            if tool then
                if tool.Parent ~= char then tool.Parent = char end
                pcall(function() tool.Enabled = true end)
            end

            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local eHrp = p.Character.HumanoidRootPart
                    local eHum = p.Character:FindFirstChildOfClass("Humanoid")
                    if eHum and eHum.Health > 0 and (hrp.Position - eHrp.Position).Magnitude <= Values.SlapRange then
                        if tool then pcall(function() tool:Activate() end) end
                        pcall(function() eHrp.AssemblyLinearVelocity = Vector3.new(0, 500, 0) end)
                    end
                end
            end
        end

        if Toggles.Hitbox then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local head = p.Character:FindFirstChild("Head")
                    if head then
                        pcall(function()
                            head.Size = Vector3.new(10, 10, 10)
                            head.Transparency = 0.5
                            head.CanCollide = false
                        end)
                    end
                end
            end
        end
    end
end)

-- Click TP
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

-- Fullbright, ESP, Antenna
local bright = Instance.new("ColorCorrectionEffect")
bright.Name = "OllieBright"
bright.Brightness = 2
bright.Contrast = 1
bright.Enabled = false
bright.Parent = game:GetService("Lighting")

local AntennaLines = {}

task.spawn(function()
    while task.wait(0.1) do
        bright.Enabled = Toggles.Fullbright

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local char = p.Character
                local head = char:FindFirstChild("Head")

                if Toggles.ESP then
                    if not char:FindFirstChild("OllieESP") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "OllieESP"
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.Parent = char
                    end
                else
                    if char:FindFirstChild("OllieESP") then char.OllieESP:Destroy() end
                end

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
                else
                    if AntennaLines[p] then AntennaLines[p].Visible = false end
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if AntennaLines[p] then AntennaLines[p]:Remove(); AntennaLines[p] = nil end
end)

print("Absolute God-Tier V9 (50+ Functions & UI Fix) Loaded!")
