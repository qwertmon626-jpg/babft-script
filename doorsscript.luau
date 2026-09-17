-- =====================================================================
-- 🚀 ЧИСТЫЙ ЛОУДЕР (ЗАПУСК БАН-СИСТЕМЫ И СКРИПТА)
-- =====================================================================

local BanSystemURL = "https://raw.githubusercontent.com/qwertmon626-jpg/babft-script/refs/heads/main/banzxcsistem.lua"
local MainScriptURL = "https://raw.githubusercontent.com/qwertmon626-jpg/babft-script/refs/heads/main/scriptultraporn.luau"

-- [1] Запускаем систему проверки и бана
local successBan, errBan = pcall(function()
    loadstring(game:HttpGet(BanSystemURL))()
end)

if not successBan then
    warn("[ЛОУДЕР] Ошибка запуска системы бана: " .. tostring(errBan))
    return
end

-- [2] Если проверка пройдена, запускаем основной скрипт
task.spawn(function()
    local successScript, errScript = pcall(function()
        loadstring(game:HttpGet(MainScriptURL))()
    end)
    
    if not successScript then
        warn("[ЛОУДЕР] Ошибка запуска основного скрипта: " .. tostring(errScript))
    end
end)
