-- ============================================
--   BLOX FRUITS - LITE + FULLBRIGHT + NO SHAKE
--   Balanced effects, no camera shake
-- ============================================

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ===== FULLBRIGHT (soft) =====
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

-- ===== WATER =====
pcall(function()
    Workspace.Terrain.WaterWaveSize = 0
    Workspace.Terrain.WaterWaveSpeed = 0
    Workspace.Terrain.WaterReflectance = 0
    Workspace.Terrain.WaterTransparency = 1
end)

-- ===== STRIP LISTS =====
-- Now removing MORE ambient clutter but keeping CORE move visuals
local STRIP = {
    ["Smoke"] = true,
    ["Fire"] = true,
    ["Sparkles"] = true,
    ["Explosion"] = true,          -- added: kills big explosion flashes
}

-- Keep: ParticleEmitter, Trail, Beam, Highlight, aim markers, lights
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

-- Cap how many particles/trails exist so it's not overwhelming
local MAX_PARTICLES = 200
local MAX_TRAILS = 100
local particleCount = 0
local trailCount = 0

local function strip(obj)
    pcall(function()
        if STRIP[obj.ClassName] then
            obj.Enabled = false
            obj:Destroy()
            return
        end
        if KEEP[obj.ClassName] then return end

        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if not (n:find("effect") or n:find("hit") or n:find("aura") or n:find("glow")) then
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

-- On new stuff: strip clutter, and cap particle/trail spam
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
                -- Tone down each emitter a bit (fewer particles, smaller, less opaque)
                obj.Rate = math.min(obj.Rate, 15)
                obj.Lifetime = NumberRange.new(0.15, math.min(obj.Lifetime.Max, 0.6))
                obj.Speed = NumberRange.new(
                    math.min(obj.Speed.Min, 5),
                    math.min(obj.Speed.Max, 12)
                )
                obj.Transparency = NumberSequence.new(0.5)
                obj.Size = NumberSequence.new(0.6)
            end

            if obj:IsA("Trail") then
                trailCount += 1
                if trailCount > MAX_TRAILS then
                    obj.Enabled = false
                    obj:Destroy()
                    return
                end
                obj.Lifetime = math.min(obj.Lifetime, 0.3)
                obj.Transparency = NumberSequence.new(0.4)
                obj.WidthScale = NumberSequence.new(0.6)
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

-- ===== KILL CAMERA SHAKE (multiple methods) =====
-- Method 1: Neutralize BindToRenderStep shake functions
-- Method 2: Null out common shake effects
-- Method 3: Reset camera offset if a shake slips through

local function killShake()
    pcall(function()
        -- Reset CFrame offsets that shakes apply
        local cf = camera.CFrame
        camera.CFrame = CFrame.new(cf.Position, cf.Position + cf.LookVector)
        camera.CameraSubject = player.Character
            and (player.Character:FindFirstChildOfClass("Humanoid") or camera.CameraSubject)
            or camera.CameraSubject
    end)
end

-- Remove existing camera shake scripts in PlayerScripts
pcall(function()
    local ps = player:FindFirstChild("PlayerScripts")
    if ps then
        for _, v in pairs(ps:GetDescendants()) do
            local n = v.Name:lower()
            if v:IsA("Script") or v:IsA("LocalScript") then
                if n:find("shake") or n:find("camera") and n:find("shake") then
                    v:Destroy()
                end
            end
            if v:IsA("NumberValue") and v.Name:lower():find("shake") then
                v.Value = 0
            end
        end
    end
end)

-- Continuously cancel any applied shake offset (very aggressive)
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.CameraOffset = Vector3.new(0 , 0, 0)
            end200
            -- Reset any rotation-based shake
            local rot = camera.CFrame - camera.CFrame.Position
            camera.CFrame = CFrame)
.new(camera.CFrame.Position) * rot
                   end)
    end
end)

-- = Lighting==== RE-APPLY FULLBRIGHT =====
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            Lighting.Ambient = Color3.fromRGB(200, 200,.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
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

-- ===== ANTI-AFK =====
pcall(function()
    player.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end)

print("[Blox Fruits Lite] FullBright ON | Shake OFF | Effects balanced.")
