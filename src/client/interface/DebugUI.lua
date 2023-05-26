
local DebugUI = {}

local localplayer = game:GetService("Players").LocalPlayer
local Fusion = require(game:GetService("ReplicatedStorage").modules.fusion)
local PlayerGui = game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui')
local screen = PlayerGui:WaitForChild("ScreenGui")

local Value, Observer, Computed, ForKeys, ForValues, ForPairs, new, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs, Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup

local debug_toggled = false
local Position = Value("")

local function updatePos()
    coroutine.wrap(function() 
        while task.wait() do
            local pos = localplayer.Character:FindFirstChild("HumanoidRootPart").Position
            Position:set( math.round(pos.X * 30)/10 .. ", " .. math.round(pos.Y * 30)/10 .. ", " .. math.round(pos.Z * 30)/10 )
        end
    end)()
end

function DebugUI:init()
    updatePos()
    local main_ui = new "Frame" {
        Position = UDim2.fromOffset(0, 0),
        AnchorPoint = Vector2.new(0, 0),
        Size = UDim2.fromOffset(200, 40),
        BackgroundColor3 = Color3.new(0.3058823529411765, 0.3254901960784314, 0.34509803921568627),
    
        [Children] = {
            new "UICorner" {
                CornerRadius = UDim.new(0, 4),
            },
            new "TextLabel" {
                Text = Position,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 0),
                Size = UDim2.fromScale(1, 1),
                TextColor = BrickColor.White(),
                TextSize = 18,
                FontFace  = Font.fromName("RobotoMono")
            }
            
        }
    }
    main_ui.Parent = screen
end

function DebugUI:toggle()
    debug_toggled = not debug_toggled
end

return DebugUI