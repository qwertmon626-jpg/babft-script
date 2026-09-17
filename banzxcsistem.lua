-- ЛОУДЕР С ВАЙТЛИСТОМ, ЛИМИТАМИ И DISCORD ВЕБХУКОМ
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local UserId = LocalPlayer.UserId
local Username = LocalPlayer.Name

-- ТВОЙ ВАЙТЛИСТ И НАСТРОЙКИ ЛИМИТОВ ДЛЯ КАЖДОГО
-- maxRuns = сколько раз в день этот игрок может запустить скрипт
local WhitelistIDs = {
    [7982855852] = { name = "tuber0268", maxRuns = 999 }, -- Безлимит (или очень много)
    [1395207311] = { name = "ilysha23112000", maxRuns = 3 }, -- Только 3 раз в день
    [5635347980] = { name = "Papirus333564", maxRuns = 3 }, -- Только 3 раз в день
    [3841899130] = { name = "Dvanseler", maxRuns = 3 }, -- 3 раза в день
}

-- Твой вебхук
local WebhookURL = "https://discord.com/api/webhooks/1550028324984586393/laCxLh2XdFqy7nm2g3u3EcWvOY8Ly2ijp7H1H9-7HacFm55Yejl9fStpiZ1bTYM7LhmA"

-- Проверка поддержки файлов эксплойтом
local canUseFiles = (writefile and readfile and isfile)

-- Функция отправки лога в Discord
local function SendDiscordLog(status, extraInfo)
    pcall(function()
        local data = {
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "🚀 Попытка запуска лоудера",
                ["description"] = extraInfo or "",
                ["color"] = status == "ОДОБРЕНО" and 65280 or 16711680,
                ["fields"] = {
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
local function KickPlayer(reason)
    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    task.wait(0.1)
    pcall(function() LocalPlayer:Kick(reason) end)
end

-- ОСНОВНАЯ ПРОВЕРКА
local userData = WhitelistIDs[UserId]

if not userData then
    -- Если игрока вообще нет в вайтлисте
    SendDiscordLog("⛔ БАН (Нет в вайтлисте)")
    KickPlayer("Доступ запрещен! Вы не в вайтлисте.")
else
    -- Если игрок есть в вайтлисте, проверяем его лимит на сегодня
    local allowed = true
    local runsToday = 1
    
    if canUseFiles then
        local fileName = "script_limit_" .. UserId .. ".json"
        local today = os.date("%Y-%m-%d")
        
        local fileData = { lastDate = today, count = 0 }
        
        if isfile(fileName) then
            local success, decoded = pcall(function()
                return HttpService:JSONDecode(readfile(fileName))
            end)
            if success and decoded and decoded.lastDate == today then
                fileData = decoded
            end
        end
        
        -- Проверяем, не превысил ли лимит
        if fileData.lastDate == today and fileData.count >= userData.maxRuns then
            allowed = false
            runsToday = fileData.count
        else
            -- Увеличиваем счетчик запусков
            if fileData.lastDate ~= today then
                fileData.lastDate = today
                fileData.count = 1
            else
                fileData.count = fileData.count + 1
            end
            runsToday = fileData.count
            writefile(fileName, HttpService:JSONEncode(fileData))
        end
    end
    
    if allowed then
        SendDiscordLog("ОДОБРЕНО", "Запусков сегодня: " .. runsToday .. " / " .. userData.maxRuns)
        print("Доступ разрешен! Запуск скрипта...")
        
        -- ТУТ ТВОЙ ОСНОВНОЙ СКРИПТ ЧИТА
        -- loadstring(game:HttpGet("ссылка_на_скрипт"))()
    else
        SendDiscordLog("⛔ ЛИМИТ ИСПЕРЧАН", "Игрок исчерпал лимит (" .. runsToday .. "/" .. userData.maxRuns .. ")")
        KickPlayer("Превышен лимит запусков скрипта на сегодня! Лимит: " .. userData.maxRuns)
    end
end
