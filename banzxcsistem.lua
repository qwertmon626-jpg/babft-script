-- ПРОСТАЯ СИСТЕМА БАНА (КИК КАК ОТ АДМИНА)
-- Для Doors / любого другого скрипта

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- НАСТРОЙКИ (МЕНЯЙ ТУТ)
local Whitelist = {
    "tubers0268",
    "ilysha23112000", 
    "Papirus333564",
    "Dvanseler"
}

-- ПРИЧИНА КИКА
local KickReason = "Ты был забанен за распространение скрипта!"

-- ФУНКЦИЯ ПРОВЕРКИ
local function IsBanned()
    local myName = LocalPlayer.Name
    for _, name in ipairs(Whitelist) do
        if string.lower(myName) == string.lower(name) then
            return false -- Не в бане
        end
    end
    return true -- В бане
end

-- ФУНКЦИЯ КИКА (КАК ОТ АДМИНА)
local function KickPlayer()
    -- Способ 1: Простой кик
    LocalPlayer:Kick(KickReason)
    
    -- Способ 2: Кик через ReplicatedStorage (как у админов)
    -- Раскомментируй если первый не работает
    -- game:GetService("ReplicatedStorage"):FindFirstChild("KickPlayer"):InvokeServer(KickReason)
end

-- ОСНОВНАЯ ПРОВЕРКА
if IsBanned() then
    print("Обнаружен нарушитель: " .. LocalPlayer.Name)
    print("Выполняется кик...")
    
    -- Небольшая задержка чтобы скрипт успел отработать
    task.wait(0.5)
    
    -- КИКАЕМ
    KickPlayer()
else
    print("Доступ разрешён для: " .. LocalPlayer.Name)
    -- ТУТ ЗАПУСКАЙ СВОЙ ОСНОВНОЙ СКРИПТ
    -- loadstring(game:HttpGet("ссылка_на_твой_скрипт"))()
end

-- ЗАЩИТА ОТ ОСТАНОВКИ (если пытаются вырубить скрипт)
pcall(function()
    while true do
        task.wait(5)
        if IsBanned() then
            LocalPlayer:Kick(KickReason)
        end
    end
end)
