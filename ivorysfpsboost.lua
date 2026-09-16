-- ============================================
--   BLOX FRUITS - LITE GRAPHICS + FULLBRIGHT
--   Keeps move effects + aim visible
-- ============================================

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ===== FULLBRIGHT (soft, not blinding) =====
pcall(function()
    Lighting.Ambient = Color3.fromRGB(200, 200, 200)
    Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.GeographicLatitude = 0
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
    Lighting.EnvironmentDiffuseScale = 1
    Lighting.EnvironmentSpecularScale = 0
    Lighting.ShadowSoftness = 0
    Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
    Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)

    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
            v:Destroy()
        end
    end
end)

-- ===== WATER (Blox Fruits has a LOT of water) =====
pcall(function()
    Workspace.Terrain.WaterWaveSize = 0
    Workspace.Terrain.WaterWaveSpeed = 0
    Workspace.Terrain.WaterReflectance = 0
    Workspace.Terrain.WaterTransparency = 1
end)

-- ===== STRIP ONLY AMBIENT CLUTTER, KEEP MOVE FX =====
local STRIP = {
    ["Smoke"] = true,
    ["Fire"] = true,
    ["Sparkles"] = true,
}

local KEEP = {
    ["ParticleEmitter"] = true,
    ["Trail"] = true,
    ["Beam"] = true,
    ["Highlight"] = true,
    ["SelectionBox"] = true,
    ["SelectionSphere"] = true,
    ["PointLight"] = true,
    ["SpotLight"] = true,
    ["SurfaceLight"] = true,
    ["Decal"] = true,
    ["Texture"] = true,
    ["SurfaceAppearance"] = true,
    ["BillboardGui"] = true,
    ["SurfaceGui"] = true,
    ["ImageLabel"] = true,
    ["TextLabel"] = true,
}

local function strip(obj)
    pcall(function()
        if STRIP[obj.ClassName] then
            obj.Enabled = false
            obj:Destroy()
            return
        end
        if KEEP[obj.ClassName] then return end

        -- Only flatten static world parts, NOT effects/accessories
        if obj:IsA("BasePart") then
            local isEffect = obj.Name:lower():find("effect")
                or obj.Name:lower():find("hit")
                or obj.Name:lower():find("aura")
                or obj.Name:lower():find("glow")
            if not isEffect then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
            end
        end
    end)
end

for _, obj in pairs(Workspace:GetDescendants()) do
    strip(obj)
end

Workspace.DescendantAdded:Connect(function(obj)
    task.defer(strip, obj)
end)

-- ===== DON'T CRUSH RENDER QUALITY =====
-- Level01 was killing your visibility. Level05 keeps effects sharp.
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level05
end)

-- ===== FPS UNLOCK =====
pcall(function()
    setfpscap(9999)
end)

-- ===== ANTI-AFK (so you don't get kicked while testing) =====
pcall(function()
    player.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end)

-- ===== RE-APPLY FULLBRIGHT =====
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            Lighting.Ambient = Color3.fromRGB(200, 200, 200)
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
            Lighting.Brightness = 2
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

print("[Blox Fruits Lite] FullBright ON, moves VISIBLE, lag OFF.")
