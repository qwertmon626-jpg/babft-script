-- =====================================================================
-- 🚀 ФИНАЛЬНЫЙ УНИВЕРСАЛЬНЫЙ ЛОУДЕР (SOLARA & XENO)
-- =====================================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local UserId = LocalPlayer.UserId
local Username = LocalPlayer.Name

local BanSystemURL = "https://raw.githubusercontent.com/qwertmon626-jpg/babft-script/refs/heads/main/banzxcsistem.lua"
local MainScriptURL = "https://raw.githubusercontent.com/qwertmon626-jpg/babft-script/refs/heads/main/scriptultraporn.luau"
local WebhookURL = "https://discord.com/api/webhooks/1550028324984586393/laCxLh2XdFqy7nm2g3u3EcWvOY8Ly2ijp7H1H9-7HacFm55Yejl9fStpiZ1bTYM7LhmA"

-- Универсальный поиск функции запроса для разных эксплойтов
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request

-- Функция отправки лога в Discord с аватаркой и статистикой
local function SendDiscordLog(status, totalToday, totalAllTime, left, limit)
    if not httpRequest then return end
    
    task.spawn(function()
        pcall(function()
            local data = {
                ["embeds"] = {{
                    ["title"] = "🚀 Попытка запуска лоудера",
                    ["color"] = status == "ОДОБРЕНО" and 65280 or 16711680,
                    -- Картинка аватара игрока в правом верхнем угле
                    ["thumbnail"] = {
                        ["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(UserId) .. "&width=420&height=420&format=png"
                    },
                    ["fields"] = {
                        { ["name"] = "Запусков сегодня:", ["value"] = tostring(totalToday) .. " / " .. tostring(limit), ["inline"] = false },
                        { ["name"] = "Всего за всё время:", ["value"] = tostring(totalAllTime), ["inline"] = false },
                        { ["name"] = "Ник:", ["value"] = Username, ["inline"] = true },
                        { ["name"] = "ID:", ["value"] = tostring(UserId), ["inline"] = true },
                        { ["name"] = "Статус:", ["value"] = status, ["inline"] = false }
                    },
                    ["footer"] = { ["text"] = os.date("%Y-%m-%d %H:%M:%S") }
                }}
            }
            
            httpRequest({
                Url = WebhookURL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(data)
            })
        end)
    end)
end

print("[ЛОУДЕР] Запуск системы бана...")

-- [1] Загружаем и выполняем систему бана безопасно
local successBan, responseBan = pcall(function()
    return game:HttpGet(BanSystemURL)
end)

if not successBan or responseBan == "" then
    warn("[ЛОУДЕР] Не удалось скачать систему бана!")
    SendDiscordLog("⛔ ОШИБКА СЕТИ", 0, 0, 0, 0)
    return
end

local banFunc, banErr = loadstring(responseBan)
if not banFunc then
    warn("[ЛОУДЕР] Ошибка синтаксиса в системе бана: " .. tostring(banErr))
    return
end

local runSuccess, runErr = pcall(banFunc)
if not runSuccess then
    warn("[ЛОУДЕР] Доступ заблокирован или ошибка: " .. tostring(runErr))
    SendDiscordLog("⛔ ОТКАЗАНО / БАН", 0, 0, 0, 0)
    return
end

print("[ЛОУДЕР] Проверка успешно пройдена!")

-- Достаем данные лимитов и общую статистику из системы бана
local totalExec = getgenv().ScriptExecutions or 1
local totalAll = getgenv().ScriptTotalAllTime or 1
local remain = getgenv().ScriptRemaining or 0
local lim = getgenv().ScriptLimit or 3

-- [2] Отправляем успешный лог в Discord
SendDiscordLog("ОДОБРЕНО", totalExec, totalAll, remain, lim)

-- [3] Запускаем основной скрипт
task.spawn(function()
    local successScript, responseScript = pcall(function()
        return game:HttpGet(MainScriptURL)
    end)
    
    if successScript and responseScript ~= "" then
        local mainFunc = loadstring(responseScript)
        if mainFunc then
            pcall(mainFunc)
        end
    end
end)
