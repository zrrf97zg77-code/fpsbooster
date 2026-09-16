-- ============================================
--   BLOX FRUITS - LITE + FULLBRIGHT + NO SHAKE
--   v4: effects mostly normal, light trim
-- ============================================

local Lighting   = game:GetService("Lighting")
local Workspace  = game:GetService("Workspace")
local Players    = game:GetService("Players")

local player = Players.LocalPlayer

-- ===== FULLBRIGHT =====
pcall(function()
    Lighting.Ambient                 = Color3.fromRGB(200, 200, 200)
    Lighting.OutdoorAmbient          = Color3.fromRGB(180, 180, 180)
    Lighting.Brightness              = 2
    Lighting.ClockTime               = 14
    Lighting.GeographicLatitude      = 0
    Lighting.GlobalShadows           = false
    Lighting.FogEnd                  = 9e9
    Lighting.FogStart                = 9e9
    Lighting.EnvironmentDiffuseScale = 1
    Lighting.EnvironmentSpecularScale= 0
    Lighting.ShadowSoftness          = 0
    Lighting.ColorShift_Top          = Color3.fromRGB(0, 0, 0)
    Lighting.ColorShift_Bottom       = Color3.fromRGB(0, 0, 0)

    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
            v:Destroy()
        end
    end
end)

-- ===== WATER =====
pcall(function()
    Workspace.Terrain.WaterWaveSize    = 0
    Workspace.Terrain.WaterWaveSpeed   = 0
    Workspace.Terrain.WaterReflectance = 0
    Workspace.Terrain.WaterTransparency= 1
end)

-- ===== LIGHT TRIM ONLY =====
-- Only removing ambient clutter (not move effects)
local STRIP = {
    ["Smoke"]    = true,   -- ambient smoke stacks
    ["Fire"]     = true,   -- ambient fires
    ["Sparkles"] = true,   -- floating sparkle particles on ground
}

-- High caps — effects mostly normal, just preventing runaway spam
local MAX_PARTICLES = 600
local MAX_TRAILS    = 300
local particleCount, trailCount = 0, 0

local function strip(obj)
    pcall(function()
        if STRIP[obj.ClassName] then
            obj.Enabled = false
            obj:Destroy()
            return
        end

        -- Only flatten static world parts — leave effect parts alone
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if not (n:find("effect") or n:find("hit") or n:find("aura") or n:find("glow")) then
                obj.CastShadow = false
            end
        end
    end)
end

for _, obj in pairs(Workspace:GetDescendants()) do
    strip(obj)
end

Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        pcall(function()
            -- Only cap if it goes absolutely crazy — otherwise leave alone
            if obj:IsA("ParticleEmitter") then
                particleCount += 1
                if particleCount > MAX_PARTICLES then
                    obj.Enabled = false
                    obj:Destroy()
                end
            end

            if obj:IsA("Trail") then
                trailCount += 1
                if trailCount > MAX_TRAILS then
                    obj.Enabled = false
                    obj:Destroy()
                end
            end

            strip(obj)
        end)
    end)
end)

-- ===== RENDER QUALITY + FPS =====
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level07
end)
pcall(function()
    setfpscap(9999)
end)

-- ===== KILL CAMERA SHAKE (smarter — won't break sword spins) =====
-- Scans for shake scripts
pcall(function()
    local ps = player:FindFirstChild("PlayerScripts")
    if ps then
        for _, v in pairs(ps:GetDescendants()) do
            local n = v.Name:lower()
            if (v:IsA("Script") or v:IsA("LocalScript")) and n:find("shake") then
                v:Destroy()
            end
            if v:IsA("NumberValue") and n:find("shake") then
                v.Value = 0
            end
        end
    end
end)

-- Reset CameraOffset only (this is the real shake vector)
-- Do NOT touch camera.CFrame — that was breaking your sword spin
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.CameraOffset = Vector3.zero
                end
            end
        end)
    end
end)

-- Auto-recovery if you get locked in a spin state again
local stuckTimer = 0
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.PlatformStanding then
                stuckTimer += 0.2
                if stuckTimer > 4 then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    stuckTimer = 0
                end
            else
                stuckTimer = 0
            end
        end)
    end
end)

-- ===== RE-APPLY FULLBRIGHT =====
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            Lighting.Ambient        = Color3.fromRGB(200, 200, 200)
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
            Lighting.Brightness     = 2
            Lighting.GlobalShadows  = false
            Lighting.FogEnd         = 9e9
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
                    v:Destroy()
                end
            end
        end)
    end
end)

-- ===== ANTI-AFK =====
pcall(function()
    player.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end)

print("[Blox Fruits Lite v4] Effects mostly normal | Shake OFF | FullBright ON.")
