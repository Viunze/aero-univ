-- // SECURITY CHECK (PLACE LOCK)
local AllowedPlaceId = 4924922222
if game.PlaceId ~= AllowedPlaceId then
    game.Players.LocalPlayer:Kick("\n[ACCESS DENIED]\nScript ini hanya untuk Brookhaven RP!")
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
local AutoDetectAdmins = true
local CurrentMode = "HELI"
local Angle = 0

-- // GUI SETUP (UKURAN DIKECILKAN)
local ScreenGui = Instance.new("ScreenGui", (gethui and gethui()) or Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "AeroV1_UltraMini"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 180, 0, 200) -- Ukuran lebih ramping (180x200)
MainFrame.Position = UDim2.new(0.5, -90, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12) -- Lebih gelap
MainFrame.Active = true
MainFrame.Draggable = true

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(0, 255, 150)

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
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 260) -- Tetap bisa scroll banyak fitur
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)

local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder 

-- // BUTTON CREATOR
local function CreateButton(name, text, order, color)
    local btn = Instance.new("TextButton", ScrollFrame)
    btn.Name = name
    btn.LayoutOrder = order 
    btn.Size = UDim2.new(0.92, 0, 0, 32) -- Tombol sedikit lebih pendek
    btn.BackgroundColor3 = color or Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.Text = text
    btn.BorderSizePixel = 0
    
    -- Rounded Corners
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 4)
    
    return btn
end

-- // INSTANTIATE BUTTONS (URUTAN SESUAI REQUEST)
local ModeBtn = CreateButton("ModeBtn", "MODE: HELI", 1)
local TargetBtn = CreateButton("TargetBtn", "SELECT TARGET", 2)
local ViewBtn = CreateButton("ViewBtn", "VIEW: OFF", 3)
local FlingBtn = CreateButton("FlingBtn", "LAUNCH FLING", 4, Color3.fromRGB(0, 70, 50))
local DetectBtn = CreateButton("DetectBtn", "DETECTOR: ON", 5)

FlingBtn.Font = Enum.Font.SourceSansBold

-------------------------------------------------------------------------------
-- // LOGIC & ACTIONS
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
    ViewBtn.TextColor3 = IsViewing and Color3.new(0, 1, 0.5) or Color3.new(1, 1, 1)
    Camera.CameraSubject = IsViewing and TargetPlayer.Character:FindFirstChildOfClass("Humanoid") or Player.Character:FindFirstChildOfClass("Humanoid")
end)

FlingBtn.MouseButton1Click:Connect(function()
    if not TargetPlayer then return end
    IsFlinging = not IsFlinging
    FlingBtn.Text = IsFlinging and "STOP" or "LAUNCH"
    FlingBtn.BackgroundColor3 = IsFlinging and Color3.fromRGB(120, 0, 0) or Color3.fromRGB(0, 70, 50)
    if IsFlinging then workspace.FallenPartsDestroyHeight = 0/0 end
end)

DetectBtn.MouseButton1Click:Connect(function()
    AutoDetectAdmins = not AutoDetectAdmins
    DetectBtn.Text = AutoDetectAdmins and "DETECTOR: ON" or "DETECTOR: OFF"
end)

-------------------------------------------------------------------------------
-- // MAIN ENGINE
-------------------------------------------------------------------------------
RunService.PostSimulation:Connect(function()
    -- Admin Visual Warning
    local keywords = {"stars", "st4rs", "st4r", "afz", "afzh", "afzj"} 
    local adminFound = false
    if AutoDetectAdmins then
        for _, p in ipairs(Players:GetPlayers()) do
            for _, key in ipairs(keywords) do
                if p.Name:lower():find(key) then adminFound = true break end
            end
        end
    end
    UIStroke.Color = adminFound and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 150)

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
