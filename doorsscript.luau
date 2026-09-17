-- =====================================================================
-- 🚀 УНИВЕРСАЛЬНЫЙ ЛОУДЕР ДЛЯ SOLARA И XENO
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

-- Функция отправки вебхука с отладкой
local function SendDiscordLog(status, total, left, limit)
    if not httpRequest then 
        warn("[ЛОУДЕР]: Функция запросов (request) не найдена в твоем эксплойте!")
        return 
    end
    
    task.spawn(function()
        local success, err = pcall(function()
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
            
            httpRequest({
                Url = WebhookURL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(data)
            })
        end)
        
        if not success then
            warn("[WEBHOOK ERROR]: " . tostring(err))
        end
    end)
end

print("[ЛОУДЕР] Запуск системы бана...")

-- [1] Запускаем систему бана
local successBan, errBan = pcall(function()
    loadstring(game:HttpGet(BanSystemURL))()
end)

if not successBan then
    warn("[ЛОУДЕР] Ошибка в системе бана: " .. tostring(errBan))
    SendDiscordLog("⛔ ОТКАЗАНО / БАН", 0, 0, 0)
    return
end

print("[ЛОУДЕР] Проверка успешно пройдена!")

-- Достаем данные лимитов из системы бана
local totalExec = getgenv().ScriptExecutions or 1
local remain = getgenv().ScriptRemaining or 0
local lim = getgenv().ScriptLimit or 3

-- [2] Отправляем лог и запускаем чит
SendDiscordLog("ОДОБРЕНО", totalExec, remain, lim)

task.spawn(function()
    local successScript, errScript = pcall(function()
        loadstring(game:HttpGet(MainScriptURL))()
    end)
    if not successScript then
        warn("[ЛОУДЕР] Ошибка запуска основного скрипта: " .. tostring(errScript))
    end
end)
