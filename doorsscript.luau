-- =====================================================================
-- 🚀 УНИВЕРСАЛЬНЫЙ ЛОУДЕР СИСТЕМЫ ЗАЩИТЫ И DISCORD ЛОГОВ V2.8
-- =====================================================================

-- [1] СЕРВИСЫ РОБЛОКСА
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- [2] ПЕРЕМЕННЫЕ ИГРОКА
local LocalPlayer = Players.LocalPlayer
local UserId = LocalPlayer.UserId
local Username = LocalPlayer.Name

-- [3] ВАЙТЛИСТ И НАСТРОЙКА ЛИМИТОВ ДЛЯ КАЖДОГО
-- Цифра — это сколько раз в день этот игрок может запустить скрипт.
local WhitelistIDs = {
    [7982855852] = 999, -- tubers0268 (Создатель — безлимит)
    [1395207311] = 3,   -- ilysha23112000 (3 раза в день)
    [5635347980] = 3,   -- Papirus333564 (3 раза в день)
    [3841899130] = 5,   -- Dvanseler (5 раз в день)
}

-- Дефолтный лимит для тех, кого нет в списке (на всякий случай)
local DefaultLimit = 3 

-- [4] ТВОЙ DISCORD ВЕБХУК
local WebhookURL = "https://discord.com/api/webhooks/1550028324984586393/laCxLh2XdFqy7nm2g3u3EcWvOY8Ly2ijp7H1H9-7HacFm55Yejl9fStpiZ1bTYM7LhmA"

-- [5] СООБЩЕНИЯ ПРИ КИКЕ
local KickReasonWhitelist = "Доступ закрыт! Вы не добавлены в вайтлист."
local KickReasonLimit = "Превышен лимит запусков скрипта на сегодня!"

local canUseFiles = (writefile and readfile and isfile)


-- =====================================================================
-- ФУНКЦИЯ 1: Получение аватарки игрока из Roblox для Discord
-- =====================================================================
local function GetPlayerThumbnail(id)
    local success, url = pcall(function()
        return Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    if success then
        return url
    else
        return "https://www.roblox.com/headshot-thumbnail/image?userId=1&width=420&height=420&format=png"
    end
end


-- =====================================================================
-- ФУНКЦИЯ 2: Отправка отчета в Discord
-- =====================================================================
local function SendDiscordLog(status, totalExecutions, remainingRuns, limit)
    pcall(function()
        local avatarUrl = GetPlayerThumbnail(UserId)
        
        local data = {
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "🚀 Запуск лоудера скрипта",
                ["color"] = status == "ОДОБРЕНО" and 65280 or 16711680,
                ["thumbnail"] = {
                    ["url"] = avatarUrl
                },
                ["fields"] = {
                    { ["name"] = "👤 Ник / ID:", ["value"] = Username .. " (`" .. UserId .. "`)", ["inline"] = false },
                    { ["name"] = "📊 Total Executions:", ["value"] = tostring(totalExecutions), ["inline"] = true },
                    { ["name"] = "⏳ Осталось запусков:", ["value"] = tostring(remainingRuns) .. " / " .. tostring(limit), ["inline"] = true },
                    { ["name"] = "📌 Статус:", ["value"] = status, ["inline"] = false }
                },
                ["footer"] = { ["text"] = "Система защиты • " .. os.date("%Y-%m-%d %H:%M:%S") }
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


-- =====================================================================
-- ФУНКЦИЯ 3: Надежный кик игрока
-- =====================================================================
local function KickPlayer(reason)
    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    task.wait(0.1)
    pcall(function() LocalPlayer:Kick(reason) end)
end


-- =====================================================================
-- ОСНОВНАЯ ПРОВЕРКА ПРИ ЗАПУСКЕ
-- =====================================================================
local playerLimit = WhitelistIDs[UserId]

if not playerLimit then
    SendDiscordLog("⛔ БАН (Не в вайтлисте)", 0, 0, 0)
    print("[ЗАЩИТА] Чужой ID: " .. UserId)
    KickPlayer(KickReasonWhitelist)
else
    local maxLimit = (type(playerLimit) == "number") and playerLimit or DefaultLimit
    
    local allowed = true
    local totalExecutions = 1
    local remainingRuns = 0
    
    if canUseFiles then
        local fileName = "script_limit_" .. UserId .. ".json"
        local today = os.date("%Y-%m-%d")
        
        local fileData = { lastDate = today, count = 0, totalAllTime = 0 }
        
        if isfile(fileName) then
            local success, decoded = pcall(function()
                return HttpService:JSONDecode(readfile(fileName))
            end)
            if success and decoded then
                fileData = decoded
            end
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
        SendDiscordLog("ОДОБРЕНО", totalExecutions, remainingRuns, maxLimit)
        print("[ЗАЩИТА] Доступ разрешён! Лимит на сегодня: " .. maxLimit)
        
        -- =================================================================
        -- ТУТ ВСТАВЛЯЙ ССЫЛКУ НА СВОЙ ОСНОВНОЙ СКРИПТ (ЧИТ)
        -- =================================================================
        -- loadstring(game:HttpGet("ССЫЛКА_НА_ТВОЙ_ЧИТ"))()
        
    else
        SendDiscordLog("⛔ ЛИМИТ ИСПЕРЧАН", totalExecutions, 0, maxLimit)
        print("[ЗАЩИТА] Лимит исчерпан.")
        KickPlayer(KickReasonLimit)
    end
end


-- =====================================================================
-- ЗАЩИТНЫЙ ЦИКЛ (Ловушка)
-- =====================================================================
spawn(function()
    while true do
        task.wait(5)
        if not WhitelistIDs[UserId] then
            KickPlayer(KickReasonWhitelist)
        end
    end
end)
