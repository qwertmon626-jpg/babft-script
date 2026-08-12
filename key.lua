-- ================================================================
-- BABFT LOADER - СИСТЕМА АВТОРИЗАЦИИ С КЛЮЧОМ
-- ================================================================

print("🔐 BABFT Loader v1.0")
print("📌 Введите ключ для загрузки скрипта")

-- =========================================================
-- 1. СПИСОК ВАЛИДНЫХ КЛЮЧЕЙ
-- =========================================================
local VALID_KEYS = {
    "ilyaeblan",        -- ТВОЙ КЛЮЧ
    "BABFT-2024-MASTER",
    "FREE-KEY-12345",
    "TEST-KEY-999",
    "BABFT-ULTIMATE-VIP"
}

-- =========================================================
-- 2. ФУНКЦИЯ ПРОВЕРКИ КЛЮЧА
-- =========================================================
local function CheckKey(inputKey)
    if not inputKey or inputKey == "" then return false end
    for _, validKey in ipairs(VALID_KEYS) do
        if inputKey:lower() == validKey:lower() then
            return true
        end
    end
    return false
end

-- =========================================================
-- 3. ФУНКЦИЯ ЗАПРОСА КЛЮЧА ЧЕРЕЗ GUI (ПРОСТОЕ ОКНО)
-- =========================================================
local function RequestKeyGUI()
    -- Пытаемся создать простое окно ввода
    local success, result = pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "BABFT_Loader"
        gui.Parent = game:GetService("CoreGui")
        
        -- Фон
        local background = Instance.new("Frame")
        background.Size = UDim2.new(0, 400, 0, 200)
        background.Position = UDim2.new(0.5, -200, 0.5, -100)
        background.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        background.BorderSizePixel = 0
        background.Parent = gui
        
        -- Заголовок
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 40)
        title.Position = UDim2.new(0, 0, 0, 0)
        title.Text = "🔐 BABFT Loader"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextScaled = true
        title.Font = Enum.Font.GothamBold
        title.BackgroundTransparency = 1
        title.Parent = background
        
        -- Поле ввода
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0.8, 0, 0, 40)
        input.Position = UDim2.new(0.1, 0, 0.3, 0)
        input.Text = "Введите ключ..."
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        input.BorderSizePixel = 0
        input.Font = Enum.Font.Gotham
        input.TextSize = 16
        input.ClearTextOnFocus = true
        input.Parent = background
        
        -- Кнопка подтверждения
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.4, 0, 0, 40)
        button.Position = UDim2.new(0.3, 0, 0.6, 0)
        button.Text = "✅ ПОДТВЕРДИТЬ"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        button.BorderSizePixel = 0
        button.Font = Enum.Font.GothamBold
        button.TextSize = 16
        button.Parent = background
        
        -- Статус
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1, 0, 0, 30)
        status.Position = UDim2.new(0, 0, 0.8, 0)
        status.Text = "Ожидание ввода..."
        status.TextColor3 = Color3.fromRGB(200, 200, 200)
        status.TextScaled = true
        status.Font = Enum.Font.Gotham
        status.BackgroundTransparency = 1
        status.Parent = background
        
        local resultKey = nil
        local finished = false
        
        -- Обработчик кнопки
        button.MouseButton1Click:Connect(function()
            local key = input.Text
            if key and key ~= "" and key ~= "Введите ключ..." then
                if CheckKey(key) then
                    resultKey = key
                    status.Text = "✅ Ключ принят! Загрузка..."
                    status.TextColor3 = Color3.fromRGB(0, 255, 0)
                    finished = true
                    task.wait(0.5)
                    gui:Destroy()
                else
                    status.Text = "❌ НЕВЕРНЫЙ КЛЮЧ! Попробуйте снова."
                    status.TextColor3 = Color3.fromRGB(255, 0, 0)
                    input.Text = ""
                end
            else
                status.Text = "⚠️ Введите ключ!"
                status.TextColor3 = Color3.fromRGB(255, 255, 0)
            end
        end)
        
        -- Enter для подтверждения
        input.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                button.MouseButton1Click:Fire()
            end
        end)
        
        -- Ждем завершения
        repeat task.wait(0.1) until finished or not gui.Parent
        
        if gui.Parent then
            gui:Destroy()
        end
        
        return resultKey
    end)
    
    if success then
        return result
    end
    return nil
end

-- =========================================================
-- 4. ОСНОВНАЯ ЛОГИКА ЗАГРУЗЧИКА
-- =========================================================
local function LoadScript()
    print("🔑 Запрос ключа...")
    
    -- Пытаемся показать GUI
    local key = RequestKeyGUI()
    
    -- Если GUI не сработал, пробуем через консоль
    if not key then
        print("📝 Введите ключ в консоли: ")
        -- Ждем ввода через консоль (для экзекьюторов)
        pcall(function()
            key = "ilyaeblan" -- Дефолтный ключ если не удалось запросить
        end)
    end
    
    -- Проверяем ключ
    if key and CheckKey(key) then
        print("✅ Ключ принят! Загрузка скрипта...")
        print("📥 Загрузка: https://raw.githubusercontent.com/qwertmon626-jpg/babft-script/refs/heads/main/babft-script.lua")
        
        -- Загружаем основной скрипт
        local success, err = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/qwertmon626-jpg/babft-script/refs/heads/main/babft-script.lua'))()
        end)
        
        if not success then
            print("❌ Ошибка загрузки: " .. tostring(err))
            -- Повторная попытка через 2 секунды
            task.wait(2)
            pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/qwertmon626-jpg/babft-script/refs/heads/main/babft-script.lua'))()
            end)
        end
    else
        print("❌ НЕВЕРНЫЙ КЛЮЧ! Доступ запрещен.")
        print("💡 Доступные ключи: ilyaeblan")
        
        -- Повторный запрос через 3 секунды
        print("🔄 Повторная попытка через 3 секунды...")
        task.wait(3)
        LoadScript() -- Рекурсивный вызов
    end
end

-- =========================================================
-- 5. ЗАПУСК ЗАГРУЗЧИКА
-- =========================================================
-- Проверяем сохраненный ключ
local savedKey = getgenv()._AUTH_KEY or ""

if savedKey ~= "" and CheckKey(savedKey) then
    print("✅ Авторизация по сохраненному ключу!")
    print("📥 Загрузка основного скрипта...")
    loadstring(game:HttpGet('https://raw.githubusercontent.com/qwertmon626-jpg/babft-script/refs/heads/main/babft-script.lua'))()
else
    -- Запускаем загрузчик
    LoadScript()
end

-- =========================================================
-- 6. КОМАНДЫ ДЛЯ КОНСОЛИ
-- =========================================================
print("═══════════════════════════════════════")
print("   🔐 BABFT LOADER v1.0")
print("   📌 Ключ по умолчанию: ilyaeblan")
print("   💡 Введите ключ в окне авторизации")
print("   🔄 Если окно не появилось - введите в консоли")
print("═══════════════════════════════════════")