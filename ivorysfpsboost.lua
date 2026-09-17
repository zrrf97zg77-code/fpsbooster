-- ============================================
--   BLOX FRUITS - AGGRESSIVE LITE + LOOP
-- ============================================

local Lighting   = game:GetService("Lighting")
local Workspace  = game:GetService("Workspace")
local Players    = game:GetService("Players")
local player     = Players.LocalPlayer

-- ===== CONTINUOUS LIGHTING APPLIER =====
-- This loop runs forever, re-applying changes every 0.5s
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            Lighting.Ambient                 = Color3.fromRGB(178, 178, 178)
            Lighting.OutdoorAmbient          = Color3.fromRGB(160, 160, 160)
            Lighting.Brightness              = 1.5
            Lighting.ClockTime               = 14
            Lighting.GlobalShadows           = false
            Lighting.FogEnd                  = 9e9
            Lighting.EnvironmentDiffuseScale = 1
            Lighting.EnvironmentSpecularScale= 0
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
                    v:Destroy()
                end
            end
        end)
    end
end)

-- ===== CONTINUOUS TEXTURE/EFFECT STRIPPER =====
-- Runs every 0.3s, strips textures and effects that respawn
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                -- Kill beams (lightning/lasers)
                if obj:IsA("Beam") then
                    obj.Enabled = false
                    obj:Destroy()
                -- Kill lights (glow spam)
                elseif obj:IsA("Light") then
                    obj.Enabled = false
                    obj:Destroy()
                -- Kill ambient clutter
                elseif obj:IsA("Smoke") or obj:IsA("Fire")
                    or obj:IsA("Sparkles") or obj:IsA("Explosion") then
                    obj.Enabled = false
                    obj:Destroy()
                -- Strip textures to smooth plastic
                elseif obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                    obj.CastShadow = false
                -- Kill decals
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj:Destroy()
                end
            end
        end)
    end
end)

-- ===== NO CAMERA SHAKE =====
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.CameraOffset = Vector3.zero end
            end
        end)
    end
end)

-- ===== WATER =====
pcall(function()
    Workspace.Terrain.WaterWaveSize    = 0
    Workspace.Terrain.WaterWaveSpeed   = 0
    Workspace.Terrain.WaterReflectance = 0
    Workspace.Terrain.WaterTransparency= 1
end)

-- ===== LITE TEXTURES =====
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
end)

-- ===== FPS =====
pcall(function() setfpscap(9999) end)

-- ===== ANTI-AFK =====
pcall(function()
    player.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end)

print("[Aggressive Lite] Looping re-apply active.")
