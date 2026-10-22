local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ==================== অ্যান্টি-চিট হুক (কিক ব্লক করার চেষ্টা) ====================
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" then
            return
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

local Toggles = {
    Speed = true, Fly = false, FlyLock = false, 
    Giant = false, SlapAura = true, Hitbox = false, 
    AntiVoid = true, InfJump = false, Noclip = false, 
    Fullbright = false, ESP = false, Antenna = true
}

local targetSpeed = 60
local flySpeed = 50
local targetSize = 3 
local jumpRequested = false
local isClickTP = false

-- ==================== ১. UI (Scrolling Fix) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GodTierUI"
pcall(function() ScreenGui.Parent = game.CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- টপ প্লেয়ার কাউন্টার বক্স
local TopGui = Instance.new("ScreenGui")
TopGui.Name = "TopCounter"
pcall(function() TopGui.Parent = game.CoreGui end)
if not TopGui.Parent then TopGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local TopBox = Instance.new("TextLabel")
TopBox.Parent = TopGui
TopBox.Size = UDim2.new(0, 150, 0, 40)
TopBox.Position = UDim2.new(0.5, -75, 0, 10)
TopBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TopBox.BackgroundTransparency = 0.5
TopBox.TextColor3 = Color3.fromRGB(0, 255, 0)
TopBox.Font = Enum.Font.SourceSansBold
TopBox.TextSize = 16
TopBox.Text = "Players: 0"
TopBox.BorderSizePixel = 0
TopBox.Visible = true

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
MainFrame.Size = UDim2.new(0, 170, 0, 350)
MainFrame.Position = UDim2.new(0, 65, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ScrollingDirection = Enum.ScrollingDirection.Y
MainFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
MainFrame.ScrollBarThickness = 6
MainFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 0, 0)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    MainFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end)

Icon.MouseButton1Click:Connect(function()
    if not dragging then MainFrame.Visible = not MainFrame.Visible end
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
    end)
end

createBtn("Speed Hack", "Speed")
createBtn("Fly", "Fly")
createBtn("Lock Vertical", "FlyLock")
createBtn("Mega Slap Aura (100m)", "SlapAura")
createBtn("Hitbox Expander", "Hitbox")
createBtn("Anti-Void (No Death)", "AntiVoid")
createBtn("Inf Jump", "InfJump")
createBtn("Noclip (Wall Hack)", "Noclip")
createBtn("Fullbright", "Fullbright")
createBtn("ESP (Player Box)", "ESP")
createBtn("Antenna Lines", "Antenna")
createBtn("Ultra Giant", "Giant")

local SpeedBox = Instance.new("TextBox")
SpeedBox.Parent = MainFrame
SpeedBox.Size = UDim2.new(1, 0, 0, 35)
SpeedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.PlaceholderText = "Walk Speed (Max 150)"
SpeedBox.Text = tostring(targetSpeed)
SpeedBox.Font = Enum.Font.SourceSansBold
SpeedBox.FocusLost:Connect(function()
    local num = tonumber(SpeedBox.Text)
    if num and num > 0 and num <= 150 then targetSpeed = num else SpeedBox.Text = tostring(targetSpeed) end
end)

local SizeBox = Instance.new("TextBox")
SizeBox.Parent = MainFrame
SizeBox.Size = UDim2.new(1, 0, 0, 35)
SizeBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeBox.PlaceholderText = "Size (3 to 50)"
SizeBox.Text = tostring(targetSize)
SizeBox.Font = Enum.Font.SourceSansBold
SizeBox.FocusLost:Connect(function()
    local num = tonumber(SizeBox.Text)
    if num and num >= 1 and num <= 50 then targetSize = num else SizeBox.Text = tostring(targetSize) end
end)

-- ==================== ২. ইভেন্ট ও ফাংশন অ্যাকশন বাটন ====================
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

createActionBtn("Click TP (Toggle)", function() isClickTP = not isClickTP end)
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
createActionBtn("FPS Boost (Low Graphics)", function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
        if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
    end
end)

-- ==================== ৩. মেইন লজিক (স্পিড, জায়ান্ট, নোক্লিপ) ====================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if Toggles.Speed and not Toggles.Fly then
        if hum.WalkSpeed ~= targetSpeed then pcall(function() hum.WalkSpeed = targetSpeed end) end
    end

    if Toggles.Noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then pcall(function() part.CanCollide = false end) end
        end
    end

    if Toggles.Giant then
        pcall(function() char:ScaleTo(targetSize) end)
    else
        pcall(function() char:ScaleTo(1) end)
    end
end)

-- ==================== ৪. ফ্লাই লজিক ====================
local bodyVel, gravityForce
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
        if hum.MoveDirection.Magnitude > 0 then direction = direction + hum.MoveDirection end
        
        if Toggles.FlyLock then direction = Vector3.new(direction.X, 0, direction.Z) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or jumpRequested then direction = direction + Vector3.new(0, 1, 0) end
        
        if direction.Magnitude > 0 then bodyVel.Velocity = direction.Unit * flySpeed else bodyVel.Velocity = Vector3.new(0, 0, 0) end
    else
        if bodyVel then bodyVel:Destroy() bodyVel = nil end
        if gravityForce then gravityForce:Destroy() gravityForce = nil end
    end
end)

-- ==================== ৫. স্ল্যাপ অরা (পাওয়ারফুল + কুলডাউন বাইপাস) ====================
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
                    if eHum and eHum.Health > 0 and (hrp.Position - eHrp.Position).Magnitude <= 100 then
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

-- ==================== ৬. Click TP ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if isClickTP and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local mouse = LocalPlayer:GetMouse()
            if mouse.Hit then
                pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end)
            end
        end
    end
end)

-- ==================== ৭. Fullbright & ESP + Antenna Lines ====================
local lighting = game:GetService("Lighting")
local bright = Instance.new("ColorCorrectionEffect")
bright.Name = "OllieBright"
bright.Brightness = 2
bright.Contrast = 1
bright.Enabled = false
bright.Parent = lighting

-- Drawing API সেটআপ
local Drawing = Drawing
local AntennaLines = {}

task.spawn(function()
    while task.wait(0.1) do
        bright.Enabled = Toggles.Fullbright
        
        -- প্লেয়ার কাউন্ট আপডেট
        local pCount = #Players:GetPlayers()
        TopBox.Text = "Players: " .. tostring(pCount)

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local char = p.Character
                local head = char:FindFirstChild("Head")
                local hrp = char:FindFirstChild("HumanoidRootPart")

                -- ESP (Highlight)
                if Toggles.ESP and hrp then
                    if not char:FindFirstChild("OllieESP") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "OllieESP"
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Parent = char
                    end
                else
                    if char:FindFirstChild("OllieESP") then char.OllieESP:Destroy() end
                end

                -- Antenna (Drawing API)
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
                        AntennaLines[p].From = Vector2.new(Camera.ViewportSize.X / 2, 30) -- স্ক্রিনের উপরের মাঝখান থেকে
                        AntennaLines[p].To = Vector2.new(headPos.X, headPos.Y)
                        AntennaLines[p].Visible = true
                    else
                        AntennaLines[p].Visible = false
                    end
                else
                    if AntennaLines[p] then
                        AntennaLines[p].Visible = false
                    end
                end
            end
        end
    end
end)

-- যারা লিভ করবে তাদের এন্টেনা রিমুভ হবে
Players.PlayerRemoving:Connect(function(p)
    if AntennaLines[p] then
        AntennaLines[p]:Remove()
        AntennaLines[p] = nil
    end
end)

print("Ultimate God-Tier V8 (Antenna & Counter) Loaded Successfully!")
