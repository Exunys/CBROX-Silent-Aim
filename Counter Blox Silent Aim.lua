local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Typing

getgenv().DisableKey = Enum.KeyCode.E
getgenv().SilentAimEnabled = true

local Method = "FireServer"
local Remote = "HitPart"

local function GetClosestPlayer()
	local MaximumDistance = math.huge
	local Target

	local Thread = coroutine.wrap(function()
		wait(20)
		MaximumDistance = math.huge
	end)

	Thread()

	for _, v in pairs(game.Players:GetPlayers()) do
		if v.Name ~= LocalPlayer.Name then
			if v ~= LocalPlayer then
				if v.Character ~= nil then
					if v.Character.HumanoidRootPart ~= nil then
						if v.Character.Humanoid ~= nil and v.Character.Humanoid.Health ~= 0 then
							local ScreenPoint = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
							local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
							
							if VectorDistance < MaximumDistance then
								Target = v
								MaximumDistance = VectorDistance
							end
						end
					end
				end
			end
		end
	end

	return Target
end

UserInputService.TextBoxFocused:Connect(function()
    Typing = true
end)

UserInputService.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == getgenv().DisableKey and Typing == false then
    	getgenv().SilentAimEnabled = not getgenv().SilentAimEnabled
    end
end)

local OldNameCall = nil

OldNameCall = hookmetamethod(game, "__namecall", (function(Self, ...)
    local NameCallMethod = getnamecallmethod()
	local Arguments = {...}

    if tostring(NameCallMethod) == Method and tostring(Self) == Remote then
        if getgenv().SilentAimEnabled == true then
            Arguments[1] = GetClosestPlayer().Character.HeadHB
            Arguments[2] = GetClosestPlayer().Character.HeadHB.Position
            Arguments[10] = true
        end

        return Self.FireServer(Self, unpack(Arguments))
    end

    return OldNameCall(Self, ...)
end)
