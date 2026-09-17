-- ============================================
--   LIGHT EFFECTS ONLY - Blox Fruits
--   Strips lightning beams, keeps minimal move flashes
-- ============================================

local Lighting   = game:GetService("Lighting")
local Workspace  = game:GetService("Workspace")
local Players    = game:GetService("Players")

local player = Players.LocalPlayer

-- ===== SOFT FULLBRIGHT =====
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

-- ===== STRIP AMBIENT CLUTTER =====
local STRIP = {
    ["Smoke"]    = true,
    ["Fire"]     = true,
    ["Sparkles"] = true,
}

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

-- ===== EFFECT FILTER (NO BEAMS) =====
-- Keeps: small particles, thin trails (brief flashes only)
-- Removes: ALL beams (including lightning)
-- Removes: big lights

local MAX_PARTICLES = 150
local MAX_TRAILS    = 60
local pCount, tCount = 0, 0

local function tuneEffect(obj)
    pcall(function()
        -- KILL ALL BEAMS (lightning, lasers, projectiles)
        if obj:IsA("Beam") then
            obj.Enabled = false
            obj:Destroy()
            return
        end

        -- PARTICLES: small faint brief flashes
        if obj:IsA("ParticleEmitter") then
            pCount += 1
            if pCount > MAX_PARTICLES then
                obj.Enabled = false
                obj:Destroy()
                return
            end
            obj.Rate          = math.min(obj.Rate, 5)
            obj.Lifetime      = NumberRange.new(0.1, 0.3)
            obj.Speed         = NumberRange.new(0, 5)
            obj.Transparency  = NumberSequence.new(0.75)
            obj.Size          = NumberSequence.new(0.5)
            obj.LightEmission = 0
        end

        -- TRAILS: thin faint lines
        if obj:IsA("Trail") then
            tCount += 1
            if tCount > MAX_TRAILS then
                obj.Enabled = false
                obj:Destroy()
                return
            end
            obj.Lifetime     = 0.12
            obj.Transparency = NumberSequence.new(0.75)
            obj.WidthScale   = NumberSequence.new(0.25)
        end

        -- LIGHTS: kill them (they cause the glow spam)
        if obj:IsA("Light") then
            obj.Enabled = false
            obj:Destroy()
        end
    end)
end

for _, obj in pairs(Workspace:GetDescendants()) do
    tuneEffect(obj)
end

Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function() tuneEffect(obj) end)
end)

-- ===== CONTINUOUS BEAM KILLER =====
-- Some beams re-spawn; keep sweeping to kill them
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Beam") then
                    obj.Enabled = false
                    obj:Destroy()
                end
                if obj:IsA("Light") then
                    obj.Enabled = false
                    obj:Destroy()
                end
            end
        end)
    end
end)

-- ===== LITE TEXTURES =====
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level03
end)
pcall(function()
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level02
end)

-- ===== FPS =====
pcall(function()
    setfpscap(9999)
end)

-- ===== NO CAMERA SHAKE (safe for sword spins) =====
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

-- ===== LIGHTNING C PILLAR KILLER =====
-- Removes the giant white pillar entirely
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local size = obj.Size
                    if size.Y > 40 and size.X < 25 and size.Z < 25 then
                        obj.Transparency = 1
                        obj.CanCollide  = false
                        obj:Destroy()
                    end
                end
            end
        end)
    end
end)

-- ===== RE-APPLY FULLBRIGHT =====
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

print("[No Beams] Lightning/lasers REMOVED | Minimal flashes kept.")
