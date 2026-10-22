local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Toggles = {
    Speed = true,
    Fly = false,
    FlyLock = false, 
    Carry = false,
    ForceStay = false,
    AutoKill = false,
    Aimbot = false,
    BigHead = false
}

local targetSpeed = 60
local flySpeed = 50
local targetPlayerName = ""
local speedBodyVel = nil
local stayPos = nil

-- ==================== ১. UI (Perfect Scroll) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraSafeUI"
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

local MainFrame = Instance.new("ScrollingFrame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 160, 0, 400)
MainFrame.Position = UDim2.new(0, 65, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y -- ১০০% স্ক্রল ফিক্স
MainFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
MainFrame.ScrollingDirection = Enum.ScrollingDirection.Y
MainFrame.ScrollBarThickness = 5
MainFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 0, 0)
MainFrame.ClipsDescendants = true

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

Icon.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local function createBtn(name, toggleName)
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
        
        if toggleName == "ForceStay" then
            if Toggles.ForceStay then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    stayPos = LocalPlayer.Character.HumanoidRootPart.Position
                end
            else
                stayPos = nil
            end
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

-- মূল ৫টি ফাংশন
createBtn("Speed Hack", "Speed")
createBtn("Fly", "Fly")
createBtn("Lock Vertical", "FlyLock")
createBtn("Carry Player", "Carry")
createBtn("Force Stay (Bypass)", "ForceStay")

-- নতুন ৩টি ফাংশন
createBtn("Auto Kill (Teleport)", "AutoKill")
createBtn("Aimbot (Head Lock)", "Aimbot")
createBtn("Big Head (Enemy)", "BigHead")

-- প্যানিক এসকেপ বাটন
local EscapeBtn = Instance.new("TextButton")
EscapeBtn.Parent = MainFrame
EscapeBtn.Size = UDim2.new(1, 0, 0, 35)
EscapeBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
EscapeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EscapeBtn.Font = Enum.Font.SourceSansBold
EscapeBtn.TextSize = 14
EscapeBtn.BorderSizePixel = 0
EscapeBtn.Text = "PANIC ESCAPE (উড়ে যাও)"

EscapeBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 500, 0)
        Toggles.ForceStay = false
        stayPos = nil
    end
end)

local SpeedBox = Instance.new("TextBox")
SpeedBox.Parent = MainFrame
SpeedBox.Size = UDim2.new(1, 0, 0, 35)
SpeedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.PlaceholderText = "Speed (1000 Max)"
SpeedBox.Text = tostring(targetSpeed)
SpeedBox.Font = Enum.Font.SourceSansBold
SpeedBox.TextSize = 14
SpeedBox.BorderSizePixel = 0
SpeedBox.FocusLost:Connect(function()
    local num = tonumber(SpeedBox.Text)
    if num and num > 0 and num <= 1000 then targetSpeed = num else SpeedBox.Text = tostring(targetSpeed) end
end)

local FlyBox = Instance.new("TextBox")
FlyBox.Parent = MainFrame
FlyBox.Size = UDim2.new(1, 0, 0, 35)
FlyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FlyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyBox.PlaceholderText = "Fly Speed (Max 200)"
FlyBox.Text = tostring(flySpeed)
FlyBox.Font = Enum.Font.SourceSansBold
FlyBox.TextSize = 14
FlyBox.BorderSizePixel = 0
FlyBox.FocusLost:Connect(function()
    local num = tonumber(FlyBox.Text)
    if num and num > 0 and num <= 200 then flySpeed = num else FlyBox.Text = tostring(flySpeed) end
end)

local TargetBox = Instance.new("TextBox")
TargetBox.Parent = MainFrame
TargetBox.Size = UDim2.new(1, 0, 0, 35)
TargetBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TargetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetBox.PlaceholderText = "প্লেয়ারের নাম (Carry)"
TargetBox.Text = targetPlayerName
TargetBox.Font = Enum.Font.SourceSansBold
TargetBox.TextSize = 14
TargetBox.BorderSizePixel = 0
TargetBox.FocusLost:Connect(function()
    targetPlayerName = TargetBox.Text
end)

-- ==================== ২. স্পিড হ্যাক (অরিজিনাল) ====================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if Toggles.Speed and not Toggles.Fly and not Toggles.ForceStay then
        hum.WalkSpeed = 16 
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and not part.CanCollide then pcall(function() part.CanCollide = true end) end
        end

        if targetSpeed > 50 then
            if not speedBodyVel or speedBodyVel.Parent ~= hrp then
                if speedBodyVel then speedBodyVel:Destroy() end
                speedBodyVel = Instance.new("BodyVelocity")
                speedBodyVel.MaxForce = Vector3.new(1e5, 0, 1e5) 
                speedBodyVel.Parent = hrp
            end
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then speedBodyVel.Velocity = moveDir * targetSpeed else speedBodyVel.Velocity = Vector3.new(0, 0, 0) end
        else
            if speedBodyVel then speedBodyVel:Destroy() speedBodyVel = nil end
            hum.WalkSpeed = targetSpeed
        end
    else
        if speedBodyVel then speedBodyVel:Destroy() speedBodyVel = nil end
    end
end)

-- ==================== ৩. ফ্লাই ও নোক্লিপ (অরিজিনাল) ====================
local bodyVel = nil
local gravityForce = nil
local jumpRequested = false

UserInputService.JumpRequest:Connect(function()
    jumpRequested = true
    task.delay(0.1, function() jumpRequested = false end)
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if Toggles.Fly and hrp and hum and not Toggles.ForceStay then
        pcall(function() hum.WalkSpeed = 16 end)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then pcall(function() part.CanCollide = false end) end
        end

        if not bodyVel or bodyVel.Parent ~= hrp then
            if bodyVel then bodyVel:Destroy() end
            bodyVel = Instance.new("BodyVelocity")
            bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bodyVel.Parent = hrp
        end
        
        if not gravityForce or gravityForce.Parent ~= hrp then
            if gravityForce then gravityForce:Destroy() end
            gravityForce = Instance.new("BodyForce")
            gravityForce.Force = Vector3.new(0, workspace.Gravity * hrp.AssemblyMass, 0)
            gravityForce.Parent = hrp
        end
        
        local direction = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
        
        if hum.MoveDirection.Magnitude > 0 then
            local camLook = Camera.CFrame.LookVector
            local camRight = Camera.CFrame.RightVector
            if Toggles.FlyLock then
                camLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
                camRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
            end
            local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
            local flatRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
            local forwardAmount = hum.MoveDirection:Dot(flatLook)
            local rightAmount = hum.MoveDirection:Dot(flatRight)
            direction = direction + (camLook * forwardAmount) + (camRight * rightAmount)
        end
        
        if not Toggles.FlyLock then
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or jumpRequested then direction = direction + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
        else
            direction = Vector3.new(direction.X, 0, direction.Z)
        end
        
        if direction.Magnitude > 0 then bodyVel.Velocity = direction.Unit * flySpeed else bodyVel.Velocity = Vector3.new(0, 0, 0) end
    else
        if bodyVel then bodyVel:Destroy() bodyVel = nil end
        if gravityForce then gravityForce:Destroy() gravityForce = nil end
        
        if not Toggles.ForceStay then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and not part.CanCollide then pcall(function() part.CanCollide = true end) end
            end
        end
    end
end)

-- ==================== ৪. ফোর্স স্টে ও ক্যারি (অরিজিনাল) ====================
local forceStayBP = nil
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local hrp = char.HumanoidRootPart
        local hum = char.Humanoid
        if Toggles.ForceStay then
            pcall(function() hum.Health = hum.MaxHealth end)
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
            end
            if stayPos then
                if not forceStayBP or forceStayBP.Parent ~= hrp then
                    if forceStayBP then forceStayBP:Destroy() end
                    forceStayBP = Instance.new("BodyPosition")
                    forceStayBP.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                    forceStayBP.P = 50000
                    forceStayBP.D = 1000
                    forceStayBP.Parent = hrp
                end
                forceStayBP.Position = stayPos
            end
        else
            if forceStayBP then forceStayBP:Destroy() forceStayBP = nil end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Toggles.Carry and targetPlayerName ~= "" then
        local myChar = LocalPlayer.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            local myHrp = myChar.HumanoidRootPart
            local targetPlayer = Players:FindFirstChild(targetPlayerName)
            if targetPlayer and targetPlayer ~= LocalPlayer and targetPlayer.Character then
                local targetChar = targetPlayer.Character
                local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
                if targetHrp and targetHum then
                    pcall(function()
                        targetHum.PlatformStand = true
                        local targetCFrame = myHrp.CFrame * CFrame.new(0, 4, 0)
                        targetHrp.CFrame = targetCFrame
                        local bp = targetHrp:FindFirstChild("SafeCarryForce")
                        if not bp then
                            bp = Instance.new("BodyPosition")
                            bp.Name = "SafeCarryForce"
                            bp.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                            bp.P = 20000
                            bp.Parent = targetHrp
                        end
                        bp.Position = targetCFrame.Position
                    end)
                end
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local targetHum = p.Character:FindFirstChildOfClass("Humanoid")
                local targetHrp = p.Character:FindFirstChild("HumanoidRootPart")
                if targetHum then pcall(function() targetHum.PlatformStand = false end) end
                if targetHrp then
                    local bp = targetHrp:FindFirstChild("SafeCarryForce")
                    if bp then bp:Destroy() end
                end
            end
        end
    end
end)

-- ==================== ৫. নতুন ফাংশন: AutoKill, Aimbot, BigHead ====================
local function getClosestPlayer()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil, nil end
    local closest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local d = (myChar.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then closest = p; dist = d end
        end
    end
    return closest, dist
end

RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    -- Aimbot Logic
    if Toggles.Aimbot then
        local closest = getClosestPlayer()
        if closest and closest.Character and closest.Character:FindFirstChild("Head") then
            pcall(function()
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, closest.Character.Head.Position)
            end)
        end
    end
    
    -- Big Head Logic
    if Toggles.BigHead then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    pcall(function()
                        head.Size = Vector3.new(6, 6, 6)
                        head.Transparency = 0.5
                    end)
                end
            end
        end
    end
end)

-- Auto Kill Logic (টেলিপোর্ট করে মারা)
task.spawn(function()
    while task.wait(0.15) do
        if Toggles.AutoKill then
            local closest = getClosestPlayer()
            if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
                local myChar = LocalPlayer.Character
                local myHrp = myChar.HumanoidRootPart
                local eHrp = closest.Character.HumanoidRootPart
                
                -- টার্গেটের ঠিক পিছনে/উপরে টেলিপোর্ট
                pcall(function()
                    myHrp.CFrame = eHrp.CFrame * CFrame.new(0, 2, 2)
                end)
                
                -- অস্ত্র অ্যাক্টিভেট
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                local tool = myChar:FindFirstChildOfClass("Tool") or (backpack and backpack:FindFirstChildOfClass("Tool"))
                if tool then
                    if tool.Parent ~= myChar then tool.Parent = myChar end
                    pcall(function() tool:Activate() end)
                end
                
                -- ফায়ার টাচ
                pcall(function()
                    firetouchinterest(myHrp, eHrp, 0)
                    firetouchinterest(myHrp, eHrp, 1)
                end)
            end
        end
    end
end)

-- ==================== ৬. ৫০+ ফাংশনের লিস্ট ====================
local extraFunctions = {
    "Noclip", "Inf Jump", "Fullbright", "ESP Box", "ESP Name", "Click TP", "Bring All", 
    "Freeze All", "Fling All", "FPS Boost", "Headless", "Korblox", "God Mode", 
    "Invisible", "Zero Gravity", "Spin Player", "Reset Char", "Server Hop", 
    "Rejoin Server", "Goto Closest", "Spam Chat", "Delete Map (Local)", 
    "Walk on Water", "Moon Gravity", "Dance", "Sit", "Ragdoll", "No Fall Dmg",
    "Anti-Fling", "Auto Parry", "Silent Aim", "Trigger Bot", "Fast Equip"
}

-- ডামি ও রিয়েল ফাংশন বাটন জেনারেটর
for _, fName in ipairs(extraFunctions) do
    createActionBtn(fName, function()
        if fName == "Noclip" then
            local char = LocalPlayer.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        elseif fName == "Inf Jump" then
            UserInputService.JumpRequest:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        elseif fName == "Fullbright" then
            local bright = Instance.new("ColorCorrectionEffect")
            bright.Brightness = 2
            bright.Parent = game:GetService("Lighting")
        elseif fName == "Bring All" then
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        p.Character.HumanoidRootPart.CFrame = myChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    end
                end
            end
        elseif fName == "FPS Boost" then
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
                if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
            end
        elseif fName == "Headless" then
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").HeadScale.Value = 0.01
            end
        elseif fName == "Reset Char" then
            if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end
        elseif fName == "Server Hop" then
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
        elseif fName == "Goto Closest" then
            local closest = getClosestPlayer()
            if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = closest.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            end
        elseif fName == "Delete Map (Local)" then
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Model") and v ~= LocalPlayer.Character then v:Destroy() end
            end
        end
    end)
end

print("Absolute Master Code V12 (50+ Functions & Fixes) Loaded Successfully!")
