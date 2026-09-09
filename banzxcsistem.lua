-- ОБНОВЛЕННАЯ СИСТЕМА БАНА (КИК КАК ОТ АДМИНА) V2.0
-- Использует User ID вместо ников (надежнее)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local UserId = LocalPlayer.UserId

-- НАСТРОЙКИ (МЕНЯЙ ТУТ, ЛУЧШЕ ИСПОЛЬЗОВАТЬ ID)
local WhitelistIDs = {
    [7982855852] = true, -- tubers0268
    [1395207311] = true, -- ilysha23112000
    [5635347980] = true, -- Papirus333564
    [3841899130] = true, -- Dvanseler
}

-- ПРИЧИНА КИКА
local KickReason = "Ты был забанен за распространение скрипта!"

-- ФУНКЦИЯ ПРОВЕРКИ (по ID)
local function IsBanned()
    if WhitelistIDs[UserId] then
        return false -- Ты в вайтлисте, не в бане
    else
        return true -- Тебя нет в списке, ты в бане
    end
end

-- ФУНКЦИЯ КИКА (Самый надежный способ)
local function KickPlayer()
    -- Способ 1: Попытка кикнуть через TeleportService (часто работает даже если обычный Kick заблокирован)
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    
    -- Способ 2: Запасной вариант (если первый не сработал)
    task.wait(0.1)
    pcall(function()
        LocalPlayer:Kick(KickReason)
    end)
    
    -- Способ 3: Кик через ReplicatedStorage (если у игры есть такой Remote, раскомментируй)
    -- pcall(function()
    --     local Remote = game:GetService("ReplicatedStorage"):FindFirstChild("KickPlayer")
    --     if Remote then Remote:InvokeServer(KickReason) end
    -- end)
end

-- ОСНОВНАЯ ПРОВЕРКА
if IsBanned() then
    print("Обнаружен нарушитель (ID: " .. UserId .. ")")
    print("Выполняется кик...")
    KickPlayer()
else
    print("Доступ разрешён для (ID: " .. UserId .. ")")
    -- ТУТ ЗАПУСКАЙ СВОЙ ОСНОВНОЙ СКРИПТ
    -- loadstring(game:HttpGet("ссылка_на_твой_скрипт"))()
end

-- ЗАЩИТА ОТ ОСТАНОВКИ (Ловушка)
-- Если кто-то попытается вырубить скрипт или заменить его, кик всё равно сработает
spawn(function()
    while true do
        task.wait(3)
        if IsBanned() then
            KickPlayer()
        end
    end
end)

-- Дополнительная защита: Если скрипт пытаются удалить (например, через геймджекер)
LocalPlayer.Changed:Connect(function(prop)
    if prop == "Parent" and LocalPlayer.Parent == nil then
        -- Если игрока попытались выкинуть или скрипт сломался, кикаем насильно
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
end)
