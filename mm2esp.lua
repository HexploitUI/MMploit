--[[
    Credits to Kiriot22 for the Role getter <3
        - poorly coded by FeIix <3
]]

-- > Declarations < --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local roles

-- > Functions <--

function CreateHighlight() -- Create a highlight for new players
    for i, v in pairs(Players:GetChildren()) do
        if v ~= LP and v.Character and not v.Character:FindFirstChild("Highlight") then
            local highlight = Instance.new("Highlight")
            highlight.Parent = v.Character
            highlight.FillTransparency = 0.5  -- Add some transparency for the cham effect
            highlight.OutlineTransparency = 0.5
        end
    end
end

function UpdateHighlights() -- Update player highlights based on roles
    for _, v in pairs(Players:GetChildren()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Highlight") then
            local Highlight = v.Character:FindFirstChild("Highlight")
            if v.Name == Sheriff and IsAlive(v) then
                Highlight.FillColor = Color3.fromRGB(0, 0, 225)  -- Blue for Sheriff
            elseif v.Name == Murder and IsAlive(v) then
                Highlight.FillColor = Color3.fromRGB(225, 0, 0)  -- Red for Murderer
            elseif v.Name == Hero and IsAlive(v) and not IsAlive(game.Players[Sheriff]) then
                Highlight.FillColor = Color3.fromRGB(255, 250, 0)  -- Yellow for Hero
            else
                Highlight.FillColor = Color3.fromRGB(0, 225, 0)  -- Green for others
            end

            -- Cham effect: dynamically change colors based on player state (Alive or Dead)
            if not IsAlive(v) then
                Highlight.FillColor = Color3.fromRGB(105, 105, 105)  -- Gray for dead players
            end
        end
    end
end	

function IsAlive(Player) -- Check if the player is alive or not
    for i, v in pairs(roles) do
        if Player.Name == i then
            if not v.Killed and not v.Dead then
                return true
            else
                return false
            end
        end
    end
end

-- > Loops < --

RunService.RenderStepped:connect(function()
    roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    for i, v in pairs(roles) do
        if v.Role == "Murderer" then
            Murder = i
        elseif v.Role == 'Sheriff' then
            Sheriff = i
        elseif v.Role == 'Hero' then
            Hero = i
        end
    end
    CreateHighlight()
    UpdateHighlights()
end)
