-- [[ FLOKZYBR_HUB V8 - GOD MODE & NETWORK OVERRIDE ]]
if not game:IsLoaded() then game.Loaded:Wait() end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [[ CONFIGURAÇÕES GLOBAIS ]]
local LP = game:GetService("Players").LocalPlayer
local Mouse = LP:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local State = {
    ThrowForce = 200000, 
    LineLength = 80000, 
    LineExtend = false,
    ControlActive = false, 
    ControlledTarget = nil,
    TPKeyActive = false,
    -- PROTEÇÕES
    AntiGrab = false, AntiRagdoll = false, AntiEverything = false,
    -- NETWORK & AIM
    Ownership = true,
    SilentAim = false,
    Aimbot = false,
    FOV = 150
}

-- [[ UI ]]
local Window = Rayfield:CreateWindow({
   Name = "FlokzyBR_Hub V8 | FTAP",
   LoadingTitle = "Injetando Network Ownership...",
   LoadingSubtitle = "by BlizTBr",
   ConfigurationSaving = { Enabled = false }
})

local CombatTab = Window:CreateTab("Combate & Aim", 4483362458)
local PowerTab = Window:CreateTab("Power & Physics", 4483364237)
local ServerTab = Window:CreateTab("Server Destroy", 4483362534)
local AntiTab = Window:CreateTab("Antis & Network", 4483362748)
local CreditTab = Window:CreateTab("Créditos", 4483362534)

-- [[ COMBATE & AIM ]]
CombatTab:CreateToggle({
    Name = "Silent Aim (100% Hit)",
    CurrentValue = false,
    Callback = function(v) State.SilentAim = v end,
})

CombatTab:CreateToggle({
    Name = "Aimbot Assist",
    CurrentValue = false,
    Callback = function(v) State.Aimbot = v end,
})

CombatTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {50, 800},
    Increment = 10,
    CurrentValue = 150,
    Callback = function(v) State.FOV = v end,
})

-- [[ POWER & PHYSICS ]]
PowerTab:CreateSlider({
   Name = "BlizTBr Throw Force",
   Range = {1000, 5000000},
   Increment = 25000,
   CurrentValue = 200000,
   Callback = function(v) State.ThrowForce = v end,
})

PowerTab:CreateToggle({
   Name = "Line Extend (Infinite Distance)",
   CurrentValue = false,
   Callback = function(v) State.LineExtend = v end,
})

PowerTab:CreateToggle({
   Name = "Control Player (C)",
   CurrentValue = false,
   Callback = function(v) State.ControlActive = v end,
})

-- [[ NETWORK & ANTIS ]]
AntiTab:CreateToggle({
    Name = "Force Network Ownership",
    CurrentValue = true,
    Callback = function(v) State.Ownership = v end,
})

AntiTab:CreateToggle({Name = "Anti-Grab", CurrentValue = false, Callback = function(v) State.AntiGrab = v end})
AntiTab:CreateToggle({Name = "Anti-Ragdoll", CurrentValue = false, Callback = function(v) State.AntiRagdoll = v end})
AntiTab:CreateToggle({Name = "Anti-Tudo", CurrentValue = false, Callback = function(v) State.AntiEverything = v end})

-- [[ SERVER DESTROY ]]
ServerTab:CreateButton({
    Name = "Blobman Bring All",
    Callback = function()
        local blob = workspace:FindFirstChild("Blobman") or workspace:FindFirstChild("Giant")
        if blob then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    pcall(function()
                        blob.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                        task.wait(0.02)
                    end)
                end
            end
            blob.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame
        end
    end,
})

-- [[ CRÉDITOS ]]
CreditTab:CreateLabel("Script And Dev: FlokzyBR_Hub")
CreditTab:CreateLabel("Status: God Mode Active")

-- [[ FUNÇÕES DE SUPORTE (AIM/TARGET) ]]
local function GetClosestPlayer()
    local target = nil
    local dist = State.FOV
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
            if vis and mag < dist then
                dist = mag
                target = p.Character.HumanoidRootPart
            end
        end
    end
    return target
end

-- [[ SISTEMA DE OWNERSHIP E FISICA ]]
RunService.Stepped:Connect(function()
    if State.Ownership then
        settings().Physics.AllowSleep = false
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "Terrain" then
                v.Velocity = v.Velocity + Vector3.new(0, 0.01, 0) -- Força o NetworkOwner
                pcall(function()
                    if LP.Character and (v.Position - LP.Character.HumanoidRootPart.Position).Magnitude < 50 then
                        v:SetNetworkOwner(LP)
                    end
                end)
            end
        end
    end
end)

-- [[ HEARTBEAT (THROW/CONTROL/AIM) ]]
RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end

    -- Line Extend
    if State.LineExtend then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function()
                tool.Distance.Value = State.LineLength
                tool.MaxLength.Value = State.LineLength
            end)
        end
    end

    -- Aimbot Assist
    if State.Aimbot then
        local target = GetClosestPlayer()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    -- Antis
    if State.AntiGrab then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("Weld") or v.Name:find("Grab") then v:Destroy() end end
    end
    if State.AntiRagdoll then char.Humanoid.PlatformStand = false char.Humanoid:ChangeState(1) end
end)

-- [[ THROW FORCE (MOUSE DIREITO) ]]
Mouse.Button2Down:Connect(function()
    local char = LP.Character
    local target = GetClosestPlayer()
    
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("Weld") or v.Name:find("Grab") then
            local victim = v.Part1 and v.Part1.Parent
            if victim and victim:FindFirstChild("HumanoidRootPart") then
                v:Destroy()
                local hrp = victim.HumanoidRootPart
                local throwDir = Mouse.Hit.LookVector
                
                -- Silent Aim Logic
                if State.SilentAim and target then
                    throwDir = (target.Position - hrp.Position).Unit
                end
                
                hrp.AssemblyLinearVelocity = throwDir * State.ThrowForce
                hrp.AssemblyAngularVelocity = Vector3.new(10000, 10000, 10000)
            end
        end
    end
end)

-- [[ TECLA C (CONTROL) ]]
game:GetService("UserInputService").InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.C and State.ControlActive then
        local t = Mouse.Target
        if t and t.Parent:FindFirstChild("HumanoidRootPart") then
            State.ControlledTarget = t.Parent.HumanoidRootPart
            -- Lógica de AlignPosition já integrada
            local att0 = Instance.new("Attachment", State.ControlledTarget)
            local ap = Instance.new("AlignPosition", State.ControlledTarget)
            ap.Attachment0 = att0
            ap.MaxForce = math.huge
            ap.Responsiveness = 200
            local targetPos = Instance.new("Attachment", workspace.Terrain)
            ap.Attachment1 = targetPos
            
            task.spawn(function()
                while State.ControlledTarget == t.Parent.HumanoidRootPart do
                    targetPos.WorldCFrame = Mouse.Hit * CFrame.new(0, 5, 0)
                    task.wait()
                end
                att0:Destroy() ap:Destroy() targetPos:Destroy()
            end)
        end
    end
end)

Rayfield:Notify({Title = "FlokzyBR_Hub V8", Content = "Network Ownership e God Mode Prontos!", Duration = 5})
