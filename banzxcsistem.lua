-- =====================================================================
-- 🛡️ ЧИСТАЯ СИСТЕМА БАНА И ЛИМИТОВ (БЕЗ ДИСКОРДА)
-- =====================================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local UserId = LocalPlayer.UserId

-- Белый список и лимиты заходов в день
local Whitelist = {
    [7982855852] = 999, -- tubers0268
    [1395207311] = 1,   -- ilysha23112000
    [5635347980] = 3,   -- Papirus333564
    [3841899130] = 5,   -- Dvanseler
}

local DefaultLimit = 3
local canFiles = (writefile and readfile and isfile)

local function Kick(reason)
    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    task.wait(0.1)
    pcall(function() LocalPlayer:Kick(reason) end)
end

local userLimit = Whitelist[UserId]

if not userLimit then
    Kick("Доступ закрыт: Вас нет в белом списке!")
    error("Not whitelisted")
else
    local maxLimit = (type(userLimit) == "number") and userLimit or DefaultLimit
    local allowed = true
    local currentExecutions = 1
    local remainingRuns = 0
    
    if canFiles then
        local fileName = "system_limit_" .. UserId .. ".json"
        local today = os.date("%Y-%m-%d")
        local fileData = { lastDate = today, count = 0, totalAllTime = 0 }
        
        if isfile(fileName) then
            local success, decoded = pcall(function()
                return HttpService:JSONDecode(readfile(fileName))
            end)
            if success and decoded then fileData = decoded end
        end
        
        if fileData.lastDate ~= today then
            fileData.lastDate = today
            fileData.count = 0
        end
        
        if fileData.count >= maxLimit then
            allowed = false
            currentExecutions = fileData.totalAllTime
            remainingRuns = 0
        else
            fileData.count = fileData.count + 1
            fileData.totalAllTime = (fileData.totalAllTime or 0) + 1
            currentExecutions = fileData.totalAllTime
            remainingRuns = maxLimit - fileData.count
            
            writefile(fileName, HttpService:JSONEncode(fileData))
        end
    end
    
    if not allowed then
        Kick("Превышен дневной лимит запусков скрипта!")
        error("Limit reached")
    end
    
    -- Сохраняем данные для лоудера, чтобы он знал сколько запусков осталось
    getgenv().ScriptExecutions = currentExecutions
    getgenv().ScriptRemaining = remainingRuns
    getgenv().ScriptLimit = maxLimit
end
