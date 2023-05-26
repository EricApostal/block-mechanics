local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local mouse = player:GetMouse()

local function hitCheck()
	if mouse.Target and (mouse.Target.Name ~= "block") then return end
    print(mouse.TargetSurface.Name)
end

RunService.Stepped:Connect(hitCheck)