-- ============================================
--   LITE GRAPHICS + FULLBRIGHT + KEEP EFFECTS
--   Auto-applies on execute. No UI.
-- ============================================

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- ===== FULLBRIGHT =====
pcall(function()
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.Brightness = 3
    Lighting.ClockTime = 14
    Lighting.GeographicLatitude = 0
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
    Lighting.EnvironmentDiffuseScale = 1
    Lighting.EnvironmentSpecularScale = 0
    Lighting.ShadowSoftness = 0

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

-- ===== STRIP ONLY VISUAL NOISE (keep gameplay effects) =====
local STRIP_CLASSES = {
    ["Smoke"] = true,
    ["Fire"] = true,
    ["Sparkles"] = true,
}

local KEEP_CLASSES = {
    ["ParticleEmitter"] = true,   -- keep hit sparks / attack FX
    ["Trail"] = true,             -- keep weapon trails
    ["Beam"] = true,              -- keep laser / beam moves
}

local function strip(obj)
    pcall(function()
        -- Remove ambient world clutter only
        if STRIP_CLASSES[obj.ClassName] then
            obj.Enabled = false
            obj:Destroy()
            return
        end

        -- Leave gameplay effects alone
        if KEEP_CLASSES[obj.ClassName] then
            return
        end

        -- No shadows, no reflect, no PBR materials (FPS boost)
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

Workspace.DescendantAdded:Connect(function(obj)
    task.defer(strip, obj)
end)

-- ===== LOWER RENDER QUALITY (keeps FPS high) =====
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

-- ===== FPS UNLOCK =====
pcall(function()
    setfpscap(9999)
end)

-- ===== RE-APPLY FULLBRIGHT PERIODICALLY =====
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 3
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
                    v:Destroy()
                end
            end
        end)
    end
end)

print("[Lite Graphics] FullBright ON, effects ON, lag OFF.")
