local Character = {}

local Players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

local player = Players.LocalPlayer

local character = player.Character or player.CharacterAdded:Wait()
while not character:FindFirstChild("Humanoid") do task.wait() end

local function handleMovement()
    coroutine.wrap(function()
        while task.wait() do
            local walkspeed = 12.951
            local FOV = 85

            if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                walkspeed = 16.836
                FOV = 88
            end
            
            character.Humanoid.JumpHeight = 3
            camera.FieldOfView = FOV
            character.Humanoid.WalkSpeed = walkspeed
        end
    end)()
end

function Character:GetRootPart()
    return character:FindFirstChild("HumanoidRootPart")
end

function Character:init()
    handleMovement()
    -- player.CameraMode = Enum.CameraMode.LockFirstPerson
    workspace.Gravity = 80
end

return Character