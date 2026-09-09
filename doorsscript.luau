-- ==========================================
-- ИСПРАВЛЕННЫЙ ЛОУДЕР (Работает с новой системой бана)
-- ==========================================

-- ССЫЛКИ
local BanSystemURL = "https://raw.githubusercontent.com/qwertmon626-jpg/babft-script/refs/heads/main/banzxcsistem.lua"
local MainScriptURL = "https://raw.githubusercontent.com/qwertmon626-jpg/babft-script/refs/heads/main/scriptultraporn.luau"

-- ФУНКЦИЯ БЕЗОПАСНОЙ ЗАГРУЗКИ
local function SafeHttpGet(URL)
    local Success, Result = pcall(function()
        return game:HttpGet(URL, true) -- true = использовать кэш (быстрее)
    end)
    
    if Success then
        return Result
    else
        warn("[Ошибка] Не удалось скачать файл: " .. tostring(Result))
        return nil
    end
end

-- ФУНКЦИЯ ПРОВЕРКИ БАНА
local function CheckBanSystem()
    local ScriptContent = SafeHttpGet(BanSystemURL)
    
    if not ScriptContent then
        -- Если не удалось скачать систему бана, выдаем ошибку и не запускаем основной скрипт
        warn("[Безопасность] Не удалось загрузить систему бана. Прерывание.")
        return false
    end
    
    -- Загружаем систему бана в память.
    -- ВАЖНО: В твоей системе бана уже прописан кик, если ID не в вайтлисте.
    local Success, Error = pcall(function()
        loadstring(ScriptContent)()
    end)
    
    if not Success then
        warn("[Ошибка] Ошибка при выполнении системы бана: " .. tostring(Error))
        return false
    end
    
    -- Если система бана не кикнула тебя, значит ты в вайтлисте
    return true
end

-- ФУНКЦИЯ ЗАПУСКА ОСНОВНОГО СКРИПТА
local function LoadMainScript()
    local ScriptContent = SafeHttpGet(MainScriptURL)
    
    if not ScriptContent then
        warn("[Ошибка] Не удалось скачать основной скрипт.")
        return
    end
    
    local Success, Error = pcall(function()
        loadstring(ScriptContent)()
    end)
    
    if Success then
        print("[Успех] Основной скрипт успешно загружен и запущен!")
    else
        -- Здесь мы ловим ту самую ошибку с '}' и другие
        warn("[Критическая ошибка] Основной скрипт не запустился: " .. tostring(Error))
        warn("Проверь файл scriptultraporn.luau на GitHub на наличие лишних скобок и синтаксических ошибок.")
    end
end

-- ==========================================
-- ЗАПУСК
-- ==========================================

print("[Лоудер] Проверка системы бана...")
if CheckBanSystem() then
    print("[Лоудер] Проверка пройдена! Загрузка основного скрипта...")
    LoadMainScript()
else
    print("[Лоудер] Ты не прошел проверку или система бана выдала ошибку. Скрипт не запущен.")
end