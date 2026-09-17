-- ============================================
--   BLOX FRUITS - ULTRA LITE
--   Only shows minimal move indicators
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

-- ===== ULTRA LITE EFFECT FILTER =====
-- Keep effects visible but make them SMALL, FAINT, and SHORT
-- so you can see opponent moves without screen spam.

local MAX_PARTICLES = 250
local MAX_TRAILS    = 100
local MAX_BEAMS     = 50
local pCount, tCount, bCount = 0, 0, 0

Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        pcall(function()
            -- PARTICLES: shrink, fade, slow down
            if obj:IsA("ParticleEmitter") then
                pCount += 1
                if pCount > MAX_PARTICLES then
                    obj.Enabled = false
                    obj:Destroy()
                    return
                end
                obj.Rate          = math.min(obj.Rate, 4)         -- very few
                obj.Lifetime      = NumberRange.new(0.1, 0.3)     -- brief
                obj.Speed         = NumberRange.new(0, 5)         -- slow
                obj.Transparency  = NumberSequence.new(0.75)      -- faint
                obj.Size          = NumberSequence.new(0.5)       -- small
                obj.LightEmission = 0
            end

            -- TRAILS: thin and faint (weapon swing indicators)
            if obj:IsA("Trail") then
                tCount += 1
                if tCount > MAX_TRAILS then
                    obj.Enabled = false
                    obj:Destroy()
                    return
                end
                obj.Lifetime     = 0.15
                obj.Transparency = NumberSequence.new(0.7)
                obj.WidthScale   = NumberSequence.new(0.3)
            end

            -- BEAMS: thin and faint (projectile indicators)
            if obj:IsA("Beam") then
                bCount += 1
                if bCount > MAX_BEAMS then
                    obj.Enabled = false
                    obj:Destroy()
                    return
                end
                obj.Transparency = NumberSequence.new(0.7)
                obj.Width0       = 0.3
                obj.Width1       = 0.3
            end

            -- LIGHTS: dim them way down (keep just enough glow)
            if obj:IsA("Light") then
                obj.Brightness = math.min(obj.Brightness, 1)
                obj.Range      = math.min(obj.Range, 8)
            end
        end)
    end)
end)

-- Also apply to existing effects
for _, obj in pairs(Workspace:GetDescendants()) do
    pcall(function()
        if obj:IsA("ParticleEmitter") then
            obj.Rate          = math.min(obj.Rate, 4)
            obj.Lifetime      = NumberRange.new(0.1, 0.3)
            obj.Speed         = NumberRange.new(0, 5)
            obj.Transparency  = NumberSequence.new(0.75)
            obj.Size          = NumberSequence.new(0.5)
            obj.LightEmission = 0
        end
        if obj:IsA("Trail") then
            obj.Lifetime     = 0.15
            obj.Transparency = NumberSequence.new(0.7)
            obj.WidthScale   = NumberSequence.new(0.3)
        end
        if obj:IsA("Beam") then
            obj.Transparency = NumberSequence.new(0.7)
            obj.Width0       = 0.3
            obj.Width1       = 0.3
        end
        if obj:IsA("Light") then
            obj.Brightness = math.min(obj.Brightness, 1)
            obj.Range      = math.min(obj.Range, 8)
        end
    end)
end

-- ===== KEEP OUTLINES SO YOU SEE OPPONENTS =====
-- Add a highlight to nearby players so you can always see them
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local existing = plr.Character:FindFirstChild("LiteHighlight")
                    if not existing then
                        local h = Instance.new("Highlight")
                        h.Name = "LiteHighlight"
                        h.FillColor = Color3.fromRGB(255, 100, 100)
                        h.FillTransparency = 0.8
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.OutlineTransparency = 0.4
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent = plr.Character
                    end
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

-- ===== NO CAMERA SHAKE =====
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

-- ===== LIGHTNING C PILLAR FIX =====
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local size = obj.Size
                    if size.Y > 40 and size.X < 25 and size.Z < 25 then
                        if obj.Transparency < 0.9 then
                            obj.Transparency = 0.9
                            obj.Reflectance  = 0
                            for _, child in pairs(obj:GetChildren()) do
                                if child:IsA("Light") then
                                    child.Brightness = 0.3
                                    child.Range = 4
                                end
                                if child:IsA("ParticleEmitter") then
                                    child.Rate = 2
                                    child.Transparency = NumberSequence.new(0.85)
                                end
                                if child:IsA("Beam") then
                                    child.Transparency = NumberSequence.new(0.85)
                                    child.Width0 = 0.3
                                    child.Width1 = 0.3
                                end
                            end
                        end
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

print("[Blox Fruits Ultra Lite] Move indicators ON | Everything else minimal.")
