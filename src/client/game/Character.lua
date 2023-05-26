local Character = {}

local Players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local character = player.Character or player.CharacterAdded:Wait()

local function handleMovement()
    coroutine.wrap(function()
        while task.wait() do
            local walkspeed = 12.951
            if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                walkspeed = 16.836
            end
            character.Humanoid.JumpHeight = 3.75
            character.Humanoid.WalkSpeed = walkspeed
        end
    end)()
end

function Character:init()
    handleMovement()
end

return Character