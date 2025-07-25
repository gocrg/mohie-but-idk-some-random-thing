-- Prison [VC🔉] 
-- By dabbingman137 | Discord: dabbingman137
-- antilag is cooked dont enable it 

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local TargetUserId = 1067583 -- mohie's ID
local TargetGroupId = 3873266 -- "The Streets" Group ID
local SafeDistance = 50 -- Distance threshold (studs)
local AntiLagEnabled = false -- Default OFF (asks player)
local NotificationCooldown = 3 -- Prevents spam (seconds)
local LastNotificationTime = 0
local ActiveNotifications = {}

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PrisonVCAlerts"
ScreenGui.Parent = game:GetService("CoreGui")

-- Startup Credits (Shows first)
local function ShowCredits()
    local Credits = Instance.new("Frame")
    Credits.Name = "Credits"
    Credits.Size = UDim2.new(0.3, 0, 0.1, 0)
    Credits.Position = UDim2.new(0.5, 0, 0.5, 0)
    Credits.AnchorPoint = Vector2.new(0.5, 0.5)
    Credits.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Credits.BackgroundTransparency = 0.15
    Credits.BorderSizePixel = 0
    Credits.ZIndex = 50
    Credits.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Credits

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(100, 100, 180)
    UIStroke.Thickness = 2
    UIStroke.Parent = Credits

    local CreditsText = Instance.new("TextLabel")
    CreditsText.Text = "Discord: dabbingman137\nMade By dabbingman137"
    CreditsText.Font = Enum.Font.GothamBold
    CreditsText.TextColor3 = Color3.fromRGB(255, 255, 255)
    CreditsText.TextSize = 18
    CreditsText.BackgroundTransparency = 1
    CreditsText.Size = UDim2.new(0.9, 0, 0.9, 0)
    CreditsText.Position = UDim2.new(0.05, 0, 0.05, 0)
    CreditsText.ZIndex = 51
    CreditsText.Parent = Credits

    -- Fade out after 3 seconds
    task.delay(3, function()
        TweenService:Create(Credits, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(CreditsText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.delay(0.5, function() Credits:Destroy() end)
    end)
end

-- Graphics Optimization (Anti-Lag)
local function OptimizeGraphics()
    if not AntiLagEnabled then return end
    
    -- Lighting adjustments
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 500
    Lighting.Brightness = 2
    
    -- Remove expensive effects
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") then
            effect.Enabled = false
        end
    end
    
    -- Reduce particle quality
    settings().Rendering.QualityLevel = 5
    
    -- Destroy distant objects
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
            obj:Destroy()
        elseif obj:IsA("BasePart") and not obj.Anchored and (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 300 then
            obj:Destroy()
        end
    end
    
    -- Optimize character visuals
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("Clothing") or part:IsA("Accessory") then
                    part:Destroy()
                end
            end
        end
    end
end

-- Notification System
local function CreateNotification(title, message, color)
    if os.time() - LastNotificationTime < NotificationCooldown then return end
    LastNotificationTime = os.time()

    -- Close old notifications
    for _, notif in ipairs(ActiveNotifications) do
        TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, 10, notif.Position.Y.Scale, 0)}):Play()
        task.delay(0.3, function() notif:Destroy() end)
    end
    ActiveNotifications = {}

    -- Create new notification
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.Size = UDim2.new(0.3, 0, 0.1, 0)
    Notification.Position = UDim2.new(1, 10, 0.75, 0)
    Notification.AnchorPoint = Vector2.new(1, 0)
    Notification.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Notification.BackgroundTransparency = 0.15
    Notification.BorderSizePixel = 0
    Notification.ZIndex = 10
    Notification.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Notification

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(90, 90, 140)
    UIStroke.Thickness = 2
    UIStroke.Parent = Notification

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = title
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = color or Color3.fromRGB(255, 120, 120)
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
    TitleLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
    TitleLabel.ZIndex = 11
    TitleLabel.Parent = Notification

    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Text = message
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    MessageLabel.TextSize = 16
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
    MessageLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
    MessageLabel.ZIndex = 11
    MessageLabel.Parent = Notification

    -- Slide in animation
    TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Position = UDim2.new(0.97, 0, 0.75, 0)}):Play()
    table.insert(ActiveNotifications, Notification)

    -- Auto-close after 5 seconds
    task.delay(5, function()
        TweenService:Create(Notification, TweenInfo.new(0.5), {Position = UDim2.new(1, 10, 0.75, 0)}):Play()
        task.delay(0.5, function() Notification:Destroy() end)
    end)
end

-- Check if player is in target group
local function IsTarget(player)
    if player.UserId == TargetUserId then return true end
    if TargetGroupId and player:IsInGroup(TargetGroupId) then return true end
    return false
end

-- Proximity Alert System
local function CheckPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if targetRoot and localRoot then
                local distance = (targetRoot.Position - localRoot.Position).Magnitude

                if distance < SafeDistance then
                    if IsTarget(player) then
                        CreateNotification("TARGET NEARBY", player.Name .. " (The Streets) is " .. math.floor(distance) .. " studs away!", Color3.fromRGB(255, 80, 80))
                    else
                        CreateNotification("Player Nearby", player.Name .. " is " .. math.floor(distance) .. " studs away.", Color3.fromRGB(100, 200, 255))
                    end
                end
            end
        end
    end
end

-- Anti-Lag Toggle Prompt
local function AskAntiLag()
    local AntiLagPrompt = Instance.new("Frame")
    AntiLagPrompt.Name = "AntiLagPrompt"
    AntiLagPrompt.Size = UDim2.new(0.35, 0, 0.25, 0)
    AntiLagPrompt.Position = UDim2.new(0.5, 0, 0.5, 0)
    AntiLagPrompt.AnchorPoint = Vector2.new(0.5, 0.5)
    AntiLagPrompt.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    AntiLagPrompt.BackgroundTransparency = 0.1
    AntiLagPrompt.BorderSizePixel = 0
    AntiLagPrompt.ZIndex = 30
    AntiLagPrompt.Parent = ScreenGui

    local PromptCorner = Instance.new("UICorner")
    PromptCorner.CornerRadius = UDim.new(0, 12)
    PromptCorner.Parent = AntiLagPrompt

    local PromptTitle = Instance.new("TextLabel")
    PromptTitle.Text = "ANTI-LAG MODE"
    PromptTitle.Font = Enum.Font.GothamBold
    PromptTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    PromptTitle.TextSize = 20
    PromptTitle.BackgroundTransparency = 1
    PromptTitle.Position = UDim2.new(0.05, 0, 0.05, 0)
    PromptTitle.Size = UDim2.new(0.9, 0, 0.2, 0)
    PromptTitle.ZIndex = 31
    PromptTitle.Parent = AntiLagPrompt

    local PromptMessage = Instance.new("TextLabel")
    PromptMessage.Text = "Enable Anti-Lag? This will optimize graphics for better FPS."
    PromptMessage.Font = Enum.Font.Gotham
    PromptMessage.TextColor3 = Color3.fromRGB(220, 220, 255)
    PromptMessage.TextSize = 16
    PromptMessage.BackgroundTransparency = 1
    PromptMessage.Position = UDim2.new(0.05, 0, 0.3, 0)
    PromptMessage.Size = UDim2.new(0.9, 0, 0.3, 0)
    PromptMessage.ZIndex = 31
    PromptMessage.Parent = AntiLagPrompt

    -- Yes Button
    local YesButton = Instance.new("TextButton")
    YesButton.Name = "YesButton"
    YesButton.Text = "YES (Boost FPS)"
    YesButton.Font = Enum.Font.GothamBold
    YesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    YesButton.TextSize = 16
    YesButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    YesButton.Position = UDim2.new(0.1, 0, 0.65, 0)
    YesButton.Size = UDim2.new(0.35, 0, 0.2, 0)
    YesButton.ZIndex = 31
    YesButton.Parent = AntiLagPrompt

    -- No Button
    local NoButton = Instance.new("TextButton")
    NoButton.Name = "NoButton"
    NoButton.Text = "NO (Keep Graphics)"
    NoButton.Font = Enum.Font.GothamBold
    NoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoButton.TextSize = 16
    NoButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    NoButton.Position = UDim2.new(0.55, 0, 0.65, 0)
    NoButton.Size = UDim2.new(0.35, 0, 0.2, 0)
    NoButton.ZIndex = 31
    NoButton.Parent = AntiLagPrompt

    -- Button Effects
    local function ButtonEffect(button)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        end)
    end

    ButtonEffect(YesButton)
    ButtonEffect(NoButton)

    -- Handle Clicks
    YesButton.MouseButton1Click:Connect(function()
        AntiLagEnabled = true
        AntiLagPrompt:Destroy()
        OptimizeGraphics()
        CreateNotification("Anti-Lag ENABLED", "Graphics optimized for performance", Color3.fromRGB(100, 255, 100))
    end)

    NoButton.MouseButton1Click:Connect(function()
        AntiLagEnabled = false
        AntiLagPrompt:Destroy()
        CreateNotification("Anti-Lag DISABLED", "Using default graphics settings", Color3.fromRGB(255, 100, 100))
    end)
end

-- Initialize
ShowCredits()
task.delay(3.5, function()
    AskAntiLag()
    CreateNotification("PRISON [VC🔉] ACTIVE", "Tracking target: mohie & The Streets", Color3.fromRGB(255, 120, 120))
end)

-- Main Loop
RunService.Heartbeat:Connect(function()
    CheckPlayers()
    if AntiLagEnabled then OptimizeGraphics() end
end)
