local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local oldMenu = PlayerGui:FindFirstChild("XenoDebugMenu")
if oldMenu then
    oldMenu:Destroy()
end

LocalPlayer:Kick("You have been kicked from the server. Reason: Exploiting / Unauthorized client modification detected. [Error Code: 268]")
