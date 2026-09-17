-- ============================================
--   NO BEAMS / NO GLOW - FAST SWEEP
-- ============================================

local Lighting  = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players   = game:GetService("Players")
local player    = Players.LocalPlayer

-- FullBright
pcall(function()
    Lighting.Ambient                 = Color3.fromRGB(178,178,178)
    Lighting.OutdoorAmbient          = Color3.fromRGB(160,160,160)
    Lighting.Brightness              = 1.5
    Lighting.ClockTime               = 14
    Lighting.GlobalShadows           = false
    Lighting.FogEnd                  = 9e9
    Lighting.EnvironmentDiffuseScale = 1    Lighting.EnvironmentSpecularScale= 0
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
            v:Destroy()
        end
    end
end)

pcall(function()
    Workspace.Terrain.WaterWaveSize     = 0
    Workspace.Terrain.WaterWaveSpeed    = 0
    Workspace.Terrain.WaterReflectance  = 0
    Workspace.Terrain.WaterTransparency = 1
end)

-- Fast sweep loop - kills beams, lights, pillars, and tones particles
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do

                -- Kill ALL beams
                if obj:IsA("Beam") then
                    obj.Enabled = false
                    obj:Destroy()

                -- Kill ALL lights
                elseif obj:IsA("Light") then
                    obj.Enabled = false
                    obj:Destroy()

                -- Kill ambient clutter
                elseif obj:IsA("Smoke") or obj:IsA("Fire")
                    or obj:IsA("Sparkles") or obj:IsA("Explosion") then
                    obj.Enabled = false
                    obj:Destroy()

                -- Tone particles way down (just a tiny flash)
                elseif obj:IsA("ParticleEmitter") then
                    obj.Rate          = math.min(obj.Rate, 3)
                    obj.Lifetime      = NumberRange.new(0.1, 0.25)
                    obj.Transparency  = NumberSequence.new(0.8)
                    obj.Size          = NumberSequence.new(0.4)
                    obj.LightEmission = 0

                -- Thin trails
                elseif obj:IsA("Trail") then
                    obj.Lifetime     = 0.1
                    obj.Transparency = NumberSequence.new(0.8)
                    obj.WidthScale   = NumberSequence.new(0.2)

                -- Kill giant pillar parts
                elseif obj:IsA("BasePart") then
                    obj.CastShadow = false
                    local s = obj.Size
                    if s.Y > 40 and s.X < 25 and s.Z < 25 then
                        obj:Destroy()
                    end
                end
            end
        end)
    end
end)

-- No camera shake (safe for sword spins)
pcall(function()
    local ps = player:FindFirstChild("PlayerScripts")
    if ps then
        for _, v in pairs(ps:GetDescendants()) do
            if (v:IsA("Script") or v:IsA("LocalScript"))
                and v.Name:lower():find("shake") then
                v:Destroy()
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            local c = player.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h then h.CameraOffset = Vector3.zero end
        end)
    end
end)

-- Lite render
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level03
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level02
end)

pcall(function() setfpscap(9999) end)

-- Re-apply FullBright
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            Lighting.Ambient        = Color3.fromRGB(178,178,178)
            Lighting.OutdoorAmbient = Color3.fromRGB(160,160,160)
            Lighting.Brightness     = 1.5
            Lighting.GlobalShadows  = false
            Lighting.FogEnd         = 9e9
        end)
    end
end)

print("[No Beams] Fast sweep active.")
