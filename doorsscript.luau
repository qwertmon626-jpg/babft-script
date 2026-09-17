-- =====================================================================
-- 🚀 ИДЕАЛЬНЫЙ ЛОУДЕР С ДИСКОРД ЛОГАМИ
-- =====================================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local UserId = LocalPlayer.UserId
local Username = LocalPlayer.Name

local BanSystemURL = "https://raw.githubusercontent.com/qwertmon626-jpg/babft-script/refs/heads/main/banzxcsistem.lua"
local MainScriptURL = "https://raw.githubusercontent.com/qwertmon626-jpg/babft-script/refs/heads/main/scriptultraporn.luau"
local WebhookURL = "https://discord.com/api/webhooks/1550028324984586393/laCxLh2XdFqy7nm2g3u3EcWvOY8Ly2ijp7H1H9-7HacFm55Yejl9fStpiZ1bTYM7LhmA"

-- Функция получения аватарки
local function GetAvatar(id)
    local success, url = pcall(function()
        return Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    return success and url or "https://www.roblox.com/headshot-thumbnail/image?userId=1&width=420&height=420&format=png"
end

-- Отправка лога в Discord из лоудера
local function SendDiscordLog(status, total, left, limit)
    pcall(function()
        local data = {
            ["embeds"] = {{
                ["title"] = "🚀 Попытка запуска лоудера",
                ["color"] = status == "ОДОБРЕНО" and 65280 or 16711680,
                ["thumbnail"] = { ["url"] = GetAvatar(UserId) },
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

-- [1] Запускаем систему бана
local successBan, errBan = pcall(function()
    loadstring(game:HttpGet(BanSystemURL))()
end)

-- Если система бана кикнула или выдала ошибку — шлем лог отказа и стоп
if not successBan then
    SendDiscordLog("⛔ ОТКАЗАНО / БАН", 0, 0, 0)
    return
end

-- Достаем данные лимитов, которые передала система бана
local totalExec = getgenv().ScriptExecutions or 1
local remain = getgenv().ScriptRemaining or 0
local lim = getgenv().ScriptLimit or 3

-- [2] Если проверка успешна — шлем в дискорд «ОДОБРЕНО» и запускаем чит
SendDiscordLog("ОДОБРЕНО", totalExec, remain, lim)

task.spawn(function()
    local successScript, errScript = pcall(function()
        loadstring(game:HttpGet(MainScriptURL))()
    end)
    if not successScript then
        warn("Ошибка запуска основного скрипта: " .. tostring(errScript))
    end
end)
