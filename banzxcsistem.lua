-- =====================================================================
-- 🛡️ НОВАЯ СИСТЕМА БАНА И ВАЙТЛИСТА
-- =====================================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local UserId = LocalPlayer.UserId
local Username = LocalPlayer.Name

-- [1] БЕЛЫЙ СПИСОК И ЛИМИТЫ (ID = сколько раз в день можно запустить)
local Whitelist = {
    [7982855852] = 999, -- tubers0268 (Создатель — безлимит)
    [1395207311] = 3,   -- ilysha23112000 (3 раза)
    [5635347980] = 3,   -- Papirus333564 (3 раза)
    [3841899130] = 5,   -- Dvanseler (5 раз)
}

local DefaultLimit = 3
local WebhookURL = "https://discord.com/api/webhooks/1550028324984586393/laCxLh2XdFqy7nm2g3u3EcWvOY8Ly2ijp7H1H9-7HacFm55Yejl9fStpiZ1bTYM7LhmA"
local canFiles = (writefile and readfile and isfile)

-- Функция отправки красивого лога в Discord
local function SendLog(status, total, left, limit)
    pcall(function()
        local data = {
            ["embeds"] = {{
                ["title"] = "🚀 Попытка запуска лоудера",
                ["color"] = status == "ОДОБРЕНО" and 65280 or 16711680,
                ["fields"] = {
                    { ["name"] = "Запусков сегодня:", ["value"] = tostring(total) .. " / " .. tostring(limit), ["inline"] = false },
                    { ["name"] = "Ник:", ["value"] = Username, ["inline"] = true },
                    { ["name"] = "ID:", ["value"] = tostring(UserId), ["inline"] = true },
                    { ["name"] = "Статус:", ["value"] = status, ["inline"] = false }
                },
                ["footer"] = { ["text"] = os.date("%Y-%m-%d %H:%M:%S") }
            }}
        }
        request({
            Url = WebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- Функция кика
local function Kick(reason)
    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    task.wait(0.1)
    pcall(function() LocalPlayer:Kick(reason) end)
end

-- [2] ПРОВЕРКА
local userLimit = Whitelist[UserId]

if not userLimit then
    SendLog("⛔ ОТКАЗАНО (Нет в вайтлисте)", 0, 0, 0)
    Kick("Доступ закрыт: Вас нет в белом списке!")
    error("Stopped execution")
else
    local maxLimit = (type(userLimit) == "number") and userLimit or DefaultLimit
    local allowed = true
    local totalExecutions = 1
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
            totalExecutions = fileData.totalAllTime
            remainingRuns = 0
        else
            fileData.count = fileData.count + 1
            fileData.totalAllTime = (fileData.totalAllTime or 0) + 1
            totalExecutions = fileData.totalAllTime
            remainingRuns = maxLimit - fileData.count
            
            writefile(fileName, HttpService:JSONEncode(fileData))
        end
    end
    
    if allowed then
        SendLog("ОДОБРЕНО", totalExecutions, remainingRuns, maxLimit)
        -- Проверка прошла успешно, идем дальше к основному скрипту
    else
        SendLog("⛔ ЛИМИТ ИСПЕРЧАН", totalExecutions, 0, maxLimit)
        Kick("Превышен дневной лимит запусков скрипта!")
        error("Stopped execution")
    end
end
