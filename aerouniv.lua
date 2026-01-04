-- // SECURITY CHECK (PLACE LOCK)
local AllowedPlaceId = 4924922222
if game.PlaceId ~= AllowedPlaceId then
    game.Players.LocalPlayer:Kick("\n[ACCESS DENIED]\nThis script is for Brookhaven RP only!")
    return
end

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // VARIABLES
local TargetPlayer = nil
local IsFlinging = false
local IsViewing = false
local AutoDetectUsernames = true
local CurrentMode = "HELI"
local Angle = 0
local LastPosition = nil -- Store position for "Back to Place" feature

-- // GUI SETUP
local ScreenGui = Instance.new("ScreenGui", (gethui and gethui()) or Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "AeroV1_RGB_Edition"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 180, 0, 200)
MainFrame.Position = UDim2.new(0.5, -90, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Active = true
MainFrame.Draggable = true

-- // RGB STROKE
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "AERO V1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14

-- // SCROLLING CONTAINER
local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollFrame.Size = UDim2.new(1, -6, 1, -35)
ScrollFrame.Position = UDim2.new(0, 3, 0, 32)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 260)
ScrollFrame.ScrollBarThickness = 2

local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- // BUTTON CREATOR
local function CreateButton(name, text, order, color)
    local btn = Instance.new("TextButton", ScrollFrame)
    btn.Name = name
    btn.LayoutOrder = order 
    btn.Size = UDim2.new(0.92, 0, 0, 32)
    btn.BackgroundColor3 = color or Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.Text = text
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    return btn
end

local ModeBtn = CreateButton("ModeBtn", "MODE: HELI", 1)
local TargetBtn = CreateButton("TargetBtn", "SELECT TARGET", 2)
local ViewBtn = CreateButton("ViewBtn", "VIEW: OFF", 3)
local FlingBtn = CreateButton("FlingBtn", "LAUNCH", 4, Color3.fromRGB(0, 70, 50))
local DetectBtn = CreateButton("DetectBtn", "USER DETECTOR: ON", 5)

-------------------------------------------------------------------------------
-- // ACTIONS
-------------------------------------------------------------------------------

ModeBtn.MouseButton1Click:Connect(function()
    CurrentMode = (CurrentMode == "HELI" and "CAR" or "HELI")
    ModeBtn.Text = "MODE: " .. CurrentMode
end)

local pIdx = 1
TargetBtn.MouseButton1Click:Connect(function()
    local plrs = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= Player then table.insert(plrs, p) end end
    if #plrs > 0 then
        TargetPlayer = plrs[pIdx]
        TargetBtn.Text = "TARGET: " .. TargetPlayer.Name:sub(1,8)
        if IsViewing then Camera.CameraSubject = TargetPlayer.Character:FindFirstChildOfClass("Humanoid") end
        pIdx = (pIdx % #plrs) + 1
    end
end)

ViewBtn.MouseButton1Click:Connect(function()
    if not TargetPlayer then return end
    IsViewing = not IsViewing
    ViewBtn.Text = IsViewing and "VIEW: ON" or "VIEW: OFF"
    Camera.CameraSubject = IsViewing and TargetPlayer.Character:FindFirstChildOfClass("Humanoid") or Player.Character:FindFirstChildOfClass("Humanoid")
end)

FlingBtn.MouseButton1Click:Connect(function()
    if not TargetPlayer then return end
    
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    IsFlinging = not IsFlinging
    
    if IsFlinging then
        -- SAVE SAFE POSITION BEFORE FLINGING
        LastPosition = hrp.CFrame
        FlingBtn.Text = "STOP"
        FlingBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        workspace.FallenPartsDestroyHeight = 0/0
    else
        -- BACK TO PLACE (AUTOMATIC RETURN)
        FlingBtn.Text = "LAUNCH"
        FlingBtn.BackgroundColor3 = Color3.fromRGB(0, 70, 50)
        if LastPosition then
            hrp.CFrame = LastPosition
            LastPosition = nil -- Reset after successful return
        end
    end
end)

DetectBtn.MouseButton1Click:Connect(function()
    AutoDetectUsernames = not AutoDetectUsernames
    DetectBtn.Text = AutoDetectUsernames and "USER DETECTOR: ON" or "USER DETECTOR: OFF"
end)

-------------------------------------------------------------------------------
-- // MAIN ENGINE
-------------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    -- SMOOTH RGB RAINBOW EFFECT
    local hue = tick() % 5 / 5
    local rainbowColor = Color3.fromHSV(hue, 1, 1)
    
    -- Username Detector Logic
    local keywords = {"stars", "st4rs", "st4r", "afz", "afzh", "afzj"} 
    local userFound = false
    if AutoDetectUsernames then
        for _, p in ipairs(Players:GetPlayers()) do
            for _, key in ipairs(keywords) do
                if p.Name:lower():find(key) then userFound = true break end
            end
        end
    end

    if userFound then
        -- Flashing red effect when a username is detected
        UIStroke.Color = (math.sin(tick() * 10) > 0) and Color3.new(1, 0, 0) or Color3.new(0.2, 0, 0)
    else
        UIStroke.Color = rainbowColor
    end

    -- Fling Logic
    if IsFlinging and TargetPlayer and TargetPlayer.Character then
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local TRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local seat = nil
        
        if CurrentMode == "HELI" then
            local folder = workspace:FindFirstChild("Helicopters")
            if folder then
                for _, v in ipairs(folder:GetChildren()) do
                    local s = v:FindFirstChild("PilotSeat", true)
                    if s then seat = s break end
                end
            end
        else
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.SeatPart then seat = hum.SeatPart end
        end

        if seat and hrp and TRoot then
            Angle = Angle + 100
            local TargetCF = CFrame.new(TRoot.Position) * CFrame.Angles(math.rad(Angle), 0, 0)
            seat.CFrame = TargetCF
            hrp.CFrame = TargetCF
            seat.AssemblyLinearVelocity = Vector3.new(9e7, 9e7, 9e7)
            seat.AssemblyAngularVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
    end
end)

