--// FAST MODE

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local fastMode = true

-- Store original lighting settings
local original = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	GlobalShadows = Lighting.GlobalShadows,
	EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
	EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
}

-- Store original effect states
local effects = {}

for _, obj in ipairs(Lighting:GetChildren()) do
	if obj:IsA("PostEffect") then
		effects[obj] = obj.Enabled
	end
end

local function enableFastMode()
	-- Full bright
	Lighting.Brightness = 3
	Lighting.ClockTime = 14
	Lighting.GlobalShadows = false

	-- Reduce lighting calculations
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0

	-- Disable post-processing effects
	for _, obj in ipairs(Lighting:GetChildren()) do
		if obj:IsA("PostEffect") then
			obj.Enabled = false
		end
	end

	-- Reduce particles/trails/beams
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ParticleEmitter") then
			obj.Enabled = false

		elseif obj:IsA("Trail") then
			obj.Enabled = false

		elseif obj:IsA("Beam") then
			obj.Enabled = false
		end
	end

	-- Reduce terrain effects
	local terrain = workspace:FindFirstChildOfClass("Terrain")

	if terrain then
		terrain.WaterWaveSize = 0
		terrain.WaterWaveSpeed = 0
		terrain.WaterReflectance = 0
		terrain.WaterTransparency = 1
	end
end

local function disableFastMode()
	-- Restore lighting
	for property, value in pairs(original) do
		Lighting[property] = value
	end

	-- Restore post effects
	for obj, enabled in pairs(effects) do
		if obj and obj.Parent then
			obj.Enabled = enabled
		end
	end

	-- Re-enable effects that were disabled
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ParticleEmitter")
			or obj:IsA("Trail")
			or obj:IsA("Beam") then

			obj.Enabled = true
		end
	end
end

-- Apply immediately
enableFastMode()

--// Optional keyboard toggle: F8
game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
	if processed then return end

	if input.KeyCode == Enum.KeyCode.F8 then
		fastMode = not fastMode

		if fastMode then
			enableFastMode()
		else
			disableFastMode()
		end
	end
end)
