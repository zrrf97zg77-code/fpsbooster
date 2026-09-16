-- ============================================
--   BLOX FRUITS - LITE + FULLBRIGHT + NO SHAKE
--   v6: fixes Lightning C white pillar glitch
-- ============================================

local Lighting   = game:GetService("Lighting")
local Workspace  = game:GetService("Workspace")
local Players    = game:GetService("Players")

local player = Players.LocalPlayer

-- ===== SOFTER FULLBRIGHT (prevents blowout) =====
pcall(function()
    Lighting.Ambient                 = Color3.fromRGB(178, 178, 178)
    Lighting.OutdoorAmbient          = Color3.fromRGB(160, 160, 160)
    Lighting.Brightness              = 1.5
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

-- ===== LIGHT TRIM =====
local STRIP = { ["Smoke"]=true, ["Fire"]=true, ["Sparkles"]=true }

local function strip(obj)
    pcall(function()
        if STRIP[obj.ClassName] then
            obj.Enabled = false
            obj:Destroy()
            return
        end
        if obj:IsA("BasePart") then
            obj.CastShadow = false
        end
    end)
end

for _, obj in pairs(Workspace:GetDescendants()) do
    strip(obj)
end

Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function() strip(obj) end)
end)

-- ===== LIGHTNING C PILLAR FIX =====
-- The Lightning C move spawns a giant bright pillar.
-- We detect it by size + brightness and tone it down (not remove it).
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                -- Look for giant vertical parts (the pillar)
                if obj:IsA("BasePart") then
                    local size = obj.Size
                    -- Pillar shape: tall, thin, and likely very bright
                    if size.Y > 40 and size.X < 25 and size.Z < 25 then
                        -- Check if it's a bright effect (transparency < 1)
                        if obj.Transparency < 0.9 then
                            -- Tone it down instead of removing
                            obj.Transparency = 0.85  -- mostly see-through
                            obj.Material = Enum.Material.SmoothPlastic
                            obj.Reflectance = 0
                            -- Reduce brightness if it has a light
                            for _, child in pairs(obj:GetChildren()) do
                                if child:IsA("Light") then
                                    child.Brightness = 0.5
                                    child.Range = 5
                                end
                                if child:IsA("ParticleEmitter") then
                                    child.Rate = math.min(child.Rate, 5)
                                    child.Transparency = NumberSequence.new(0.8)
                                end
                                if child:IsA("Beam") then
                                    child.Transparency = NumberSequence.new(0.8)
                                    child.Width0 = math.min(child.Width0, 1)
                                    child.Width1 = math.min(child.Width1, 1)
                                end
                            end
                        end
                    end
                end

                -- Also tone down particle emitters that are huge
                if obj:IsA("ParticleEmitter") then
                    if obj.Size and obj.Size.Max > 10 then
                        obj.Size = NumberSequence.new(3)
                        obj.Transparency = NumberSequence.new(0.8)
                        obj.Rate = math.min(obj.Rate, 5)
                    end
                end

                -- Tone down huge beams
                if obj:IsA("Beam") then
                    if obj.Width0 > 5 or obj.Width1 > 5 then
                        obj.Width0 = 1
                        obj.Width1 = 1
                        obj.Transparency = NumberSequence.new(0.8)
                    end
                end
            end
        end)
    end
end)

-- ===== LITE TEXTURES =====
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level04
end)

pcall(function()
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level02
end)

-- ===== FPS UNLOCK =====
pcall(function()
    setfpscap(9999)
end)

-- ===== KILL CAMERA SHAKE (safe for sword spins) =====
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

-- Auto-recovery if stuck in spin
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

-- ===== RE-APPLY SOFT FULLBRIGHT =====
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            Lighting.Ambient        = Color3.fromRGB(178, 178, 178)
            Lighting.OutdoorAmbient = Color3.fromRGB(160, 160, 160)
            Lighting.Brightness     = 1.5
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

print("[Blox Fruits Lite v6] Lightning C pillar fix ON | Effects normal | Shake OFF.")
