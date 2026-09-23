local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- Fullbright
Lighting.Brightness = 5
Lighting.ClockTime = 14
Lighting.GlobalShadows = false
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0
Lighting.FogEnd = 100000

-- Disable lighting/post-processing effects
for _, v in ipairs(Lighting:GetChildren()) do
	if v:IsA("PostEffect") then
		v.Enabled = false
	end
end

-- Disable expensive visual effects
for _, v in ipairs(Workspace:GetDescendants()) do
	if v:IsA("ParticleEmitter")
		or v:IsA("Trail")
		or v:IsA("Beam") then
		v.Enabled = false
	elseif v:IsA("Smoke")
		or v:IsA("Fire")
		or v:IsA("Sparkles") then
		v.Enabled = false
	end
end

-- Make terrain cheaper
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

if Terrain then
	Terrain.WaterWaveSize = 0
	Terrain.WaterWaveSpeed = 0
	Terrain.WaterReflectance = 0
	Terrain.WaterTransparency = 1
end

-- Keep disabling newly-created effects
Workspace.DescendantAdded:Connect(function(v)
	if v:IsA("ParticleEmitter")
		or v:IsA("Trail")
		or v:IsA("Beam")
		or v:IsA("Smoke")
		or v:IsA("Fire")
		or v:IsA("Sparkles") then
		v.Enabled = false
	end
end)

Lighting.ChildAdded:Connect(function(v)
	if v:IsA("PostEffect") then
		v.Enabled = false
	end
end)
