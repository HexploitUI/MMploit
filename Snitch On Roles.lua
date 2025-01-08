--[[ 
    Credits to Kiriot22 for the Role getter <3
    - improved and customized by FeIix <3
]]

-- > Declarations < --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local roles
local previousRoles = {}  -- Store the previous roles to check if they change
local hasLiedThisRound = false  -- Track if a lie has been told during this round

-- > Functions <-- 

function GetRandomPlayerExcluding(excludedNames)
    local potentialTargets = {}
    for _, player in pairs(Players:GetPlayers()) do
        if not table.find(excludedNames, player.Name) then
            table.insert(potentialTargets, player.Name)
        end
    end
    if #potentialTargets > 0 then
        return potentialTargets[math.random(1, #potentialTargets)]
    end
    return nil
end

function SendRoleToChat()
    -- Only lie if it hasn't been done yet in this round
    if not hasLiedThisRound then
        for i, v in pairs(roles) do
            -- Skip if the LocalPlayer has no role (Innocent)
            if i == LP.Name then
                if v.Role == "Murderer" or v.Role == "Sheriff" then
                    local fakeRole, fakeTarget

                    -- Generate fake information
                    if v.Role == "Murderer" then
                        fakeTarget = GetRandomPlayerExcluding({LP.Name, GetSheriff()})
                        fakeRole = "Murderer"
                    elseif v.Role == "Sheriff" then
                        fakeTarget = GetRandomPlayerExcluding({LP.Name})
                        fakeRole = "Sheriff"
                    end

                    if fakeTarget and fakeRole then
                        local message = fakeTarget .. " is the " .. fakeRole .. "!"
                        SendMessageToChat(message)
                    end
                    hasLiedThisRound = true  -- Mark that a lie has been told
                    return
                end
            end

            -- Send real messages for other players
            if v.Role == "Murderer" and (previousRoles[i] ~= "Murderer") then
                local message = i .. " is the Murderer!"
                SendMessageToChat(message)
            elseif v.Role == "Sheriff" and (previousRoles[i] ~= "Sheriff") then
                local message = i .. " is the Sheriff!"
                SendMessageToChat(message)
            end
        end
    end
end

function GetSheriff()
    for i, v in pairs(roles) do
        if v.Role == "Sheriff" then
            return i
        end
    end
    return nil
end

function SendMessageToChat(message)
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

function UpdatePreviousRoles()
    previousRoles = {}
    for i, v in pairs(roles) do
        previousRoles[i] = v.Role
    end
end

function IsAnyoneAssignedRole()
    for _, v in pairs(roles) do
        if v.Role ~= "Innocent" and v.Role ~= nil then
            return true
        end
    end
    return false
end

-- > Loops <--

RunService.RenderStepped:connect(function()
    roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()

    if not IsAnyoneAssignedRole() then
        previousRoles = {}
        hasLiedThisRound = false  -- Reset lie status when no roles are assigned
    else
        SendRoleToChat()
        UpdatePreviousRoles()
    end
end)
