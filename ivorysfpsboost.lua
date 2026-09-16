-- ============================================
--   LITE GRAPHICS - AUTO APPLY
--   No UI. No toggles. Just fast.
-- ============================================

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- ===== LIGHTING / EFFECTS =====
pcall(function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 2
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.ShadowSoftness = 0
    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)

    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
            v:Destroy()
        end
    end
end)

-- ===== TERRAIN / WATER =====
pcall(function()
    Workspace.Terrain.WaterWaveSize = 0
    Workspace.Terrain.WaterWaveSpeed = 0
    Workspace.Terrain.WaterReflectance = 0
    Workspace.Terrain.WaterTransparency = 1
end)

-- ===== STRIP OBJECTS (initial pass) =====
local function strip(obj)
    pcall(function()
        if obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Smoke")
        or obj:IsA("Fire")
        or obj:IsA("Sparkles")
        or obj:IsA("Beam")
        or obj:IsA("Explosion") then
            obj.Enabled = false
            obj:Destroy()
        end

        if obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        end

        if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
            obj.TextureID = ""
        end

        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = false
        end
    end)
end

for _, obj in pairs(Workspace:GetDescendants()) do
    strip(obj)
end

-- ===== KEEP STRIPPING NEW STUFF =====
Workspace.DescendantAdded:Connect(function(obj)
    task.defer(strip, obj)
end)

-- ===== LOWER RENDER QUALITY =====
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

-- ===== FPS UNLOCK =====
pcall(function()
    setfpscap(9999)
end)

-- ===== RE-APPLY LIGHTING PERIODICALLY (some games reset it) =====
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.Brightness = 2
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.FogEnd = 9e9
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
                    v:Destroy()
                end
            end
        end)
    end
end)

print("[Lite Graphics] Applied. No UI, just speed.")
