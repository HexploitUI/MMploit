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
local previousRoles = {}  -- Store the previous roles to check if they change

-- > Functions <--

function SendRoleToChat() -- Sends the roles of Murderer and Sheriff to the chat
    for i, v in pairs(roles) do
        -- Skip if the LocalPlayer has no role (Innocent) or is the Murderer or Sheriff
        if i == LP.Name then
            if v.Role == "Murderer" or v.Role == "Sheriff" then
                return  -- Skip sending message for the LocalPlayer if they are Murderer or Sheriff
            end
        end

        -- Send message if the player is Murderer and is not the LocalPlayer
        if v.Role == "Murderer" and (previousRoles[i] ~= "Murderer") then
            local message = i .. " is the Murderer!"
            -- Chat system support (new and legacy)
            local tcs = game:GetService("TextChatService")
            local chat = tcs.ChatInputBarConfiguration.TargetTextChannel

            if tcs.ChatVersion == Enum.ChatVersion.LegacyChatService then
                local chatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                if chatEvent then
                    chatEvent.SayMessageRequest:FireServer(message, "All")
                end
            else
                if chat then
                    chat:SendAsync(message)
                else
                    print("Chat system not available.")
                end
            end
        end

        -- Send message if the player is Sheriff and is not the LocalPlayer
        if v.Role == "Sheriff" and (previousRoles[i] ~= "Sheriff") then
            local message = i .. " is the Sheriff!"
            -- Chat system support (new and legacy)
            local tcs = game:GetService("TextChatService")
            local chat = tcs.ChatInputBarConfiguration.TargetTextChannel

            if tcs.ChatVersion == Enum.ChatVersion.LegacyChatService then
                local chatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                if chatEvent then
                    chatEvent.SayMessageRequest:FireServer(message, "All")
                end
            else
                if chat then
                    chat:SendAsync(message)
                else
                    print("Chat system not available.")
                end
            end
        end
    end
end

function UpdatePreviousRoles() -- Update the previous roles after sending the messages
    previousRoles = {}
    for i, v in pairs(roles) do
        previousRoles[i] = v.Role
    end
end

function IsAnyoneAssignedRole() -- Check if any player has a role assigned
    for _, v in pairs(roles) do
        if v.Role ~= "Innocent" and v.Role ~= nil then
            return true
        end
    end
    return false  -- No roles assigned (Innocent or no role)
end

-- > Loops <--

RunService.RenderStepped:connect(function()
    roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()

    -- Check if no players have roles, indicating the start of a new round
    if not IsAnyoneAssignedRole() then
        -- Reset previous roles since it's a new round
        previousRoles = {}

        -- Wait for roles to be assigned before announcing them
        -- We should send the messages once the roles are updated
        SendRoleToChat()
    else
        -- If roles have changed, announce new roles and update the previous roles
        SendRoleToChat()
        UpdatePreviousRoles()
    end
end)
