-- =====================================================================
-- 🚀 ИДЕАЛЬНЫЙ ЧИСТЫЙ ЛОУДЕР
-- =====================================================================

local BanSystemURL = "https://raw.githubusercontent.com/qwertmon626-jpg/babft-script/refs/heads/main/banzxcsistem.lua"
local MainScriptURL = "https://raw.githubusercontent.com/qwertmon626-jpg/babft-script/refs/heads/main/scriptultraporn.luau"

-- [1] Запускаем систему проверки и бана, и ждем результата
local successBan, errBan = pcall(function()
    loadstring(game:HttpGet(BanSystemURL))()
end)

-- Если система бана выдала ошибку или кикнула игрока — прерываем запуск!
if not successBan then
    warn("[ЛОУДЕР] Доступ заблокирован системой бана. Скрипт не будет запущен.")
    return
end

-- [2] Если система бана отработала без ошибок и дала добро — запускаем чит
task.spawn(function()
    local successScript, errScript = pcall(function()
        loadstring(game:HttpGet(MainScriptURL))()
    end)
    
    if not successScript then
        warn("[ЛОУДЕР] Ошибка запуска основного скрипта: " .. tostring(errScript))
    end
end)
