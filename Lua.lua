local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "mm2 helper",
   LoadingTitle = "MM2 Helper Loading...",
   LoadingSubtitle = "by kupa scripts",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "MM2HelperConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvatelink",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "mm2 helper | Key System",
      Subtitle = "Created by kupa scripts",
      Note = "Введите ключ доступа",
      FileName = "MM2HelperKey",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"mm2bro"}
   }
})

-- Переменные
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local AimbotEnabled = false
local FOVRadius = 100
local RainbowFOV = false
local ESPOpen = false

local WalkSpeedValue = 16
local JumpPowerValue = 50
local BHopEnabled = false
local IsInvisible = false

-- FOV Circle setup
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Radius = FOVRadius
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

-- Функция определения ролей
local function GetPlayerRole(player)
    if not player or not player.Character then return "Innocent" end
    
    if player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then
        return "Murderer"
    elseif player.Backpack:FindFirstChild("Gun") or player.Character:FindFirstChild("Gun") then
        return "Sheriff"
    end
    
    return "Innocent"
end

-- Вкладка Main
local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateSection("Aimbot")

MainTab:CreateToggle({
   Name = "Аимбот на Мардера",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
      AimbotEnabled = Value
      FOVCircle.Visible = Value
   end,
})

MainTab:CreateSlider({
   Name = "Размер FOV",
   Range = {30, 500},
   Increment = 5,
   Suffix = "px",
   CurrentValue = 100,
   Flag = "FOVSize",
   Callback = function(Value)
      FOVRadius = Value
      FOVCircle.Radius = Value
   end,
})

MainTab:CreateColorPicker({
    Name = "Цвет FOV",
    Color = Color3.fromRGB(255, 255, 255),
    Flag = "FOVColor",
    Callback = function(Value)
        if not RainbowFOV then
            FOVCircle.Color = Value
        end
    end,
})

MainTab:CreateToggle({
   Name = "Радужный FOV",
   CurrentValue = false,
   Flag = "RainbowFOVToggle",
   Callback = function(Value)
      RainbowFOV = Value
   end,
})

MainTab:CreateSection("ESP Ролей")

local Highlights = {}

local function ClearESP()
    for player, highlight in pairs(Highlights) do
        if highlight then 
            highlight:Destroy() 
        end
    end
    Highlights = {}
end

MainTab:CreateToggle({
   Name = "Включить ESP",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
      ESPOpen = Value
      if not Value then
          ClearESP()
      end
   end,
})

-- Вкладка Player (Перемещение и Невидимость)
local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateSection("Модификации игрока")

PlayerTab:CreateSlider({
   Name = "Скорость бега (WalkSpeed)",
   Range = {16, 120},
   Increment = 1,
   Suffix = "spd",
   CurrentValue = 16,
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
      WalkSpeedValue = Value
   end,
})

PlayerTab:CreateSlider({
   Name = "Высота прыжка (JumpPower)",
   Range = {50, 200},
   Increment = 1,
   Suffix = "pwr",
   CurrentValue = 50,
   Flag = "JumpPowerSlider",
   Callback = function(Value)
      JumpPowerValue = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "BunnyHop (Авто-прыжок)",
   CurrentValue = false,
   Flag = "BHopToggle",
   Callback = function(Value)
      BHopEnabled = Value
   end,
})

PlayerTab:CreateSection("Невидимость")

local function SetInvisibility(state)
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if state then
        local clone = hrp:Clone()
        clone.Parent = char
        hrp.Transparency = 1
        
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.Transparency = 0.5
            end
        end
        
        task.spawn(function()
            while IsInvisible and task.wait() do
                if char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso") then
                    char.PrimaryPart = hrp
                end
            end
        end)
    else
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("BasePart") then
                v.Transparency = 0
            end
        end
    end
end

PlayerTab:CreateToggle({
   Name = "Невидимость (Invisibility)",
   CurrentValue = false,
   Flag = "InvisToggle",
   Callback = function(Value)
      IsInvisible = Value
      SetInvisibility(Value)
   end,
})

-- Основной цикл обновления
local hue = 0
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    if RainbowFOV then
        hue = (hue + 0.005) % 1
        FOVCircle.Color = Color3.fromHSV(hue, 1, 1)
    end
    
    -- Скорость и JumpPower
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        hum.WalkSpeed = WalkSpeedValue
        hum.UseJumpPower = true
        hum.JumpPower = JumpPowerValue
        
        if BHopEnabled and hum.FloorMaterial ~= Enum.Material.Air and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

    -- Аимбот
    if AimbotEnabled then
        local target = nil
        local shortestDist = FOVRadius
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if GetPlayerRole(plr) == "Murderer" then
                    local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                        
                        if dist < shortestDist then
                            shortestDist = dist
                            target = plr
                        end
                    end
                end
            end
        end
        
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
    
    -- Исправленная логика ESP (Авто-обновление при возрождении/смерти)
    if ESPOpen then
        -- Очищаем битые объекты Highlight от умерших игроков
        for plr, hl in pairs(Highlights) do
            if not plr or not plr.Parent or not plr.Character or not hl.Parent or hl.Parent ~= plr.Character then
                if hl then hl:Destroy() end
                Highlights[plr] = nil
            end
        end

        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                local role = GetPlayerRole(plr)
                local color = Color3.fromRGB(0, 255, 0)
                
                if role == "Murderer" then
                    color = Color3.fromRGB(255, 0, 0)
                elseif role == "Sheriff" then
                    color = Color3.fromRGB(0, 100, 255)
                end
                
                local hl = Highlights[plr]
                if not hl or not hl.Parent or hl.Parent ~= plr.Character then
                    hl = Instance.new("Highlight")
                    hl.Name = "RoleESP"
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    hl.Parent = plr.Character
                    Highlights[plr] = hl
                end
                
                hl.FillColor = color
                hl.OutlineColor = color
            end
        end
    end
end)
