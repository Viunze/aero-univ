-- // SECURITY CHECK (PLACE LOCK)
local AllowedPlaceId = 4924922222
if game.PlaceId ~= AllowedPlaceId then
    game.Players.LocalPlayer:Kick("\n[AERO SECURITY]\nThis script can only be used in:\nBrookhaven RP (ID: " .. AllowedPlaceId .. ")")
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
local CurrentMode = "HELI"
local Angle = 0
local LastPosition = nil 

-- // SETTINGS
local FlingPower = 9e7 
local RotPower = 9e8

-- // GUI SETUP
local ScreenGui = Instance.new("ScreenGui", (gethui and gethui()) or Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "AERO_V1"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 225)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -112)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "AERO V1"
Title.TextSize = 22 
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold

local ModeBtn = Instance.new("TextButton", MainFrame)
ModeBtn.Size = UDim2.new(0.9, 0, 0, 30); ModeBtn.Position = UDim2.new(0.05, 0, 0.16, 0)
ModeBtn.Text = "MODE: HELI"; ModeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); ModeBtn.TextColor3 = Color3.new(1, 1, 1)

local TargetBtn = Instance.new("TextButton", MainFrame)
TargetBtn.Size = UDim2.new(0.9, 0, 0, 30); TargetBtn.Position = UDim2.new(0.05, 0, 0.32, 0)
TargetBtn.Text = "SELECT TARGET"; TargetBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TargetBtn.TextColor3 = Color3.new(1, 1, 1)

local ViewBtn = Instance.new("TextButton", MainFrame)
ViewBtn.Size = UDim2.new(0.9, 0, 0, 30); ViewBtn.Position = UDim2.new(0.05, 0, 0.48, 0)
ViewBtn.Text = "VIEW: OFF"; ViewBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); ViewBtn.TextColor3 = Color3.new(1, 1, 1)

local FlingBtn = Instance.new("TextButton", MainFrame)
FlingBtn.Size = UDim2.new(0.9, 0, 0, 45); FlingBtn.Position = UDim2.new(0.05, 0, 0.70, 0)
FlingBtn.Text = "LAUNCH"; FlingBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 80); FlingBtn.TextColor3 = Color3.new(1, 1, 1)

-------------------------------------------------------------------------------
-- // VEHICLE LOGIC
-------------------------------------------------------------------------------

local function GetVehicleBase()
    local char = Player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if CurrentMode == "HELI" then
        local folder = workspace:FindFirstChild("Helicopters")
        if folder then
            for _, heli in ipairs(folder:GetChildren()) do
                local seat = heli:FindFirstChild("PilotSeat", true)
                if seat and seat:IsA("VehicleSeat") then return seat end
            end
        end
    else
        if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then return hum.SeatPart end
        local vehFolder = workspace:FindFirstChild("Vehicles")
        if vehFolder then
            for _, v in ipairs(vehFolder:GetChildren()) do
                local s = v:FindFirstChildWhichIsA("VehicleSeat", true)
                if s then return s end
            end
        end
    end
    return nil
end

-------------------------------------------------------------------------------
-- // MAIN LOOP (RGB & FLING)
-------------------------------------------------------------------------------

RunService.PostSimulation:Connect(function()
    -- RGB Border
    UIStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)

    if IsFlinging and TargetPlayer and TargetPlayer.Character then
        local seat = GetVehicleBase()
        local TChar = TargetPlayer.Character
        local TRoot = TChar:FindFirstChild("HumanoidRootPart")
        local THum = TChar:FindFirstChildOfClass("Humanoid")
        local MyChar = Player.Character

        if seat and TRoot and THum and MyChar then
            local vehicleModel = seat:FindFirstAncestorOfClass("Model") or seat.Parent
            
            if MyChar.Humanoid.SeatPart ~= seat then
                seat:Sit(MyChar.Humanoid)
            end

            Angle = Angle + 100
            local MoveDir = THum.MoveDirection * (TRoot.Velocity.Magnitude / 1.25)
            local OrbitPos = TRoot.Position + MoveDir + Vector3.new(0, 1, 0)
            local FinalCF = CFrame.new(OrbitPos) * CFrame.Angles(math.rad(Angle), math.rad(Angle), 0)
            
            if vehicleModel:IsA("Model") and vehicleModel.PrimaryPart then
                vehicleModel:SetPrimaryPartCFrame(FinalCF)
            else
                seat.CFrame = FinalCF
            end

            seat.AssemblyLinearVelocity = Vector3.new(FlingPower, FlingPower, FlingPower)
            seat.AssemblyAngularVelocity = Vector3.new(RotPower, RotPower, RotPower)

            for _, p in ipairs(vehicleModel:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = true
                    p.Velocity = seat.AssemblyLinearVelocity
                end
            end
        end
    end
end)

-------------------------------------------------------------------------------
-- // BUTTON ACTIONS
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
        TargetBtn.Text = TargetPlayer.Name:sub(1,10)
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
    
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    IsFlinging = not IsFlinging
    
    if IsFlinging then
        if hrp then LastPosition = hrp.CFrame end
        workspace.FallenPartsDestroyHeight = 0/0 
        FlingBtn.Text = "STOP"
        FlingBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    else
        FlingBtn.Text = "LAUNCH"
        FlingBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 80)
        
        if hum and hrp and LastPosition then
            -- 1. Hentikan semua gerakan fisik
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            
            -- 2. Lepas dari kursi
            hum.Sit = false
            
            -- 3. Teleport dulu baru lompat (agar posisi stabil)
            hrp.CFrame = LastPosition
            task.wait(0.05)
            hum.Jump = true 
            
            LastPosition = nil
        end

        workspace.FallenPartsDestroyHeight = -500 
    end
end)
