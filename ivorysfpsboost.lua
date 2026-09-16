-- ============================================
--   BLOX FRUITS - LITE + FULLBRIGHT + NO SHAKE
--   v2: fewer effects, zero camera shake
-- ============================================

local Lighting   = game:GetService("Lighting")
local Workspace  = game:GetService("Workspace")
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ===== FULLBRIGHT (soft) =====
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

-- ===== STRIP LISTS =====
-- Removing MORE than last time (explosions, big flashes, ambient clutter)
local STRIP = {
    ["Smoke"]      = true,
    ["Fire"]       = true,
    ["Sparkles"]   = true,
    ["Explosion"]  = true,
}

-- Keep only the essentials so you can still see moves/aim
local KEEP = {
    ["ParticleEmitter"] = true,
    ["Trail"]           = true,
    ["Beam"]            = true,
    ["Highlight"]       = true,
    ["SelectionBox"]    = true,
    ["SelectionSphere"] = true,
    ["BillboardGui"]    = true,
    ["SurfaceGui"]      = true,
    ["ImageLabel"]      = true,
    ["TextLabel"]       = true,
}

-- Lower caps = less effect spam on screen
local MAX_PARTICLES = 120
local MAX_TRAILS    = 60
local MAX_BEAMS     = 40
local particleCount, trailCount, beamCount = 0, 0, 0

local function strip(obj)
    pcall(function()
        if STRIP[obj.ClassName] then
            obj.Enabled = false
            obj:Destroy()
            return
        end
        if KEEP[obj.ClassName] then return end

        -- Kill lights too (they're the biggest effect spam source)
        if obj:IsA("Light") then
            obj.Enabled = false
            obj:Destroy()
            return
        end

        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if not (n:find("effect") or n:find("hit") or n:find("aura")) then
                obj.Material     = Enum.Material.SmoothPlastic
                obj.Reflectance  = 0
                obj.CastShadow   = false
            end
        end
    end)
end

for _, obj in pairs(Workspace:GetDescendants()) do
    strip(obj)
end

-- On new stuff: strip clutter AND cap spam
Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        pcall(function()
            if obj:IsA("ParticleEmitter") then
                particleCount += 1
                if particleCount > MAX_PARTICLES then
                    obj.Enabled = false
                    obj:Destroy()
                    return
                end
                obj.Rate         = math.min(obj.Rate, 8)
                obj.Lifetime     = NumberRange.new(0.1, 0.4)
                obj.Speed        = NumberRange.new(0, 8)
                obj.Transparency = NumberSequence.new(0.6)
                obj.Size         = NumberSequence.new(0.4)
                obj.LightEmission= 0
            end

            if obj:IsA("Trail") then
                trailCount += 1
                if trailCount > MAX_TRAILS then
                    obj.Enabled = false
                    obj:Destroy()
                    return
                end
                obj.Lifetime     = math.min(obj.Lifetime, 0.2)
                obj.Transparency = NumberSequence.new(0.6)
                obj.WidthScale   = NumberSequence.new(0.4)
            end

            if obj:IsA("Beam") then
                beamCount += 1
                if beamCount > MAX_BEAMS then
                    obj.Enabled = false
                    obj:Destroy()
                    return
                end
                obj.Transparency = NumberSequence.new(0.5)
                obj.Width0       = math.min(obj.Width0, 0.5)
                obj.Width1       = math.min(obj.Width1, 0.5)
            end

            strip(obj)
        end)
    end)
end)

-- ===== RENDER QUALITY =====
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level05
end)

-- ===== FPS UNLOCK =====
pcall(function()
    setfpscap(9999)
end)

-- ===== KILL CAMERA SHAKE =====
-- Layer 1: scan PlayerScripts for anything named "shake"
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

-- Layer 2: also scan the LocalPlayer's own children
pcall(function()
    for _, v in pairs(player:GetDescendants()) do
        local n = v.Name:lower()
        if (v:IsA("Script") or v:IsA("LocalScript")) and n:find("shake") then
            v:Destroy()
        end
    end
end)

-- Layer 3: continuously reset CameraOffset + flatten shake CFrame
task.spawn(function()
    while task.wait(0.03) do
        pcall(function()
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.CameraOffset = Vector3.zero
            end
            if camera then
                local pos = camera.CFrame.Position
                local dir = camera.CFrame.LookVector
                camera.CFrame = CFrame.new(pos, pos + dir)
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

print("[Blox Fruits Lite v2] FullBright ON | Shake OFF | Effects reduced.")
