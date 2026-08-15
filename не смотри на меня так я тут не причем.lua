local Library = (Abysall.UILibrary == "Linoria" and "LinoriaLib" or "Obsidian")
-- local BaseUrl = "https://raw.githubusercontent.com/mstudio45/" .. Library .. "/refs/heads/main/" -- broken since upio github got banned
local BaseUrl = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local AbysallUrl = "https://raw.githubusercontent.com/bocaj111004/Abysall/refs/heads/main/"

-- =====================================================
-- 1. ЗАГРУЗКА БИБЛИОТЕКИ
-- =====================================================
local Interface = {
  Library = loadstring(game:HttpGet(BaseUrl .. "Library.lua"))(),
  SaveManager = loadstring(game:HttpGet(BaseUrl .. "addons/SaveManager.lua"))(),
  ThemeManager = loadstring(game:HttpGet(BaseUrl .. "addons/ThemeManager.lua"))(),

  ApplyInfoTab = loadstring(game:HttpGet(AbysallUrl .. "Components/InfoTab.luau"))(),
  ApplySettingsTab = loadstring(game:HttpGet(AbysallUrl .. "Components/SettingsTab.luau"))()
}

-- =====================================================
-- 2. ДОБАВЛЯЕМ КРАСНУЮ ТЕМУ (qwertikz Red)
-- =====================================================
Interface.ThemeManager.BuiltInThemes = {
    -- Оригинальные темы (оставляем для выбора)
    ["Default"]        = { 1,  { FontColor = "ffffff", MainColor = "1c1c1c", AccentColor = "0055ff", BackgroundColor = "141414", OutlineColor = "323232" } },
    ["BBot"]           = { 2,  { FontColor = "ffffff", MainColor = "1e1e1e", AccentColor = "7e48a3", BackgroundColor = "232323", OutlineColor = "141414" } },
    ["Fatality"]       = { 3,  { FontColor = "ffffff", MainColor = "1e1842", AccentColor = "c50754", BackgroundColor = "191335", OutlineColor = "3c355d" } },
    ["Jester"]         = { 4,  { FontColor = "ffffff", MainColor = "242424", AccentColor = "db4467", BackgroundColor = "1c1c1c", OutlineColor = "373737" } },
    ["Mint"]           = { 5,  { FontColor = "ffffff", MainColor = "242424", AccentColor = "3db488", BackgroundColor = "1c1c1c", OutlineColor = "373737" } },
    ["Tokyo Night"]    = { 6,  { FontColor = "ffffff", MainColor = "191925", AccentColor = "6759b3", BackgroundColor = "16161f", OutlineColor = "323232" } },
    ["Ubuntu"]         = { 7,  { FontColor = "ffffff", MainColor = "3e3e3e", AccentColor = "e2581e", BackgroundColor = "323232", OutlineColor = "191919" } },
    ["Quartz"]         = { 8,  { FontColor = "ffffff", MainColor = "232330", AccentColor = "426e87", BackgroundColor = "1d1b26", OutlineColor = "27232f" } },
    ["Nord"]           = { 9,  { FontColor = "eceff4", MainColor = "3b4252", AccentColor = "88c0d0", BackgroundColor = "2e3440", OutlineColor = "4c566a" } },
    ["Dracula"]        = { 10, { FontColor = "f8f8f2", MainColor = "44475a", AccentColor = "ff79c6", BackgroundColor = "282a36", OutlineColor = "6272a4" } },
    ["Monokai"]        = { 11, { FontColor = "f8f8f2", MainColor = "272822", AccentColor = "f92672", BackgroundColor = "1e1f1c", OutlineColor = "49483e" } },
    ["Gruvbox"]        = { 12, { FontColor = "ebdbb2", MainColor = "3c3836", AccentColor = "fb4934", BackgroundColor = "282828", OutlineColor = "504945" } },
    ["Solarized"]      = { 13, { FontColor = "839496", MainColor = "073642", AccentColor = "cb4b16", BackgroundColor = "002b36", OutlineColor = "586e75" } },
    ["Catppuccin"]     = { 14, { FontColor = "d9e0ee", MainColor = "302d41", AccentColor = "f5c2e7", BackgroundColor = "1e1e2e", OutlineColor = "575268" } },
    ["One Dark"]       = { 15, { FontColor = "abb2bf", MainColor = "282c34", AccentColor = "c678dd", BackgroundColor = "21252b", OutlineColor = "5c6370" } },
    ["Cyberpunk"]      = { 16, { FontColor = "f9f9f9", MainColor = "262335", AccentColor = "00ff9f", BackgroundColor = "1a1a2e", OutlineColor = "413c5e" } },
    ["Oceanic Next"]   = { 17, { FontColor = "d8dee9", MainColor = "1b2b34", AccentColor = "6699cc", BackgroundColor = "16232a", OutlineColor = "343d46" } },
    ["Material"]       = { 18, { FontColor = "eeffff", MainColor = "212121", AccentColor = "82aaff", BackgroundColor = "151515", OutlineColor = "424242" } },
    
    -- ⚡ НОВАЯ КРАСНАЯ ТЕМА qwertikz
    ["qwertikz Red"]   = { 99, {
        FontColor = "ffffff",      -- Белый текст
        MainColor = "1a0a0a",       -- Тёмно-красный фон
        AccentColor = "ff1744",     -- Ярко-красный акцент (кнопки, ползунки)
        BackgroundColor = "0d0000", -- Почти чёрный с красным отливом
        OutlineColor = "4a1414"     -- Красная обводка
    }},
}

-- =====================================================
-- 3. ПЕРЕХВАТ ЗАГОЛОВКА (меняем на qwertikz Hub)
-- =====================================================
local originalCreateWindow = Interface.Library.CreateWindow

Interface.Library.CreateWindow = function(title, config)
    -- Меняем заголовок на qwertikz Hub
    local newTitle = "qwertikz Hub"
    if title and title ~= "" then
        newTitle = "qwertikz Hub | " .. title
    end
    
    -- Создаём окно с новым заголовком
    local window = originalCreateWindow(newTitle, config)
    
    -- Принудительно применяем красную тему
    Interface.ThemeManager.SetTheme("qwertikz Red")
    
    return window
end

-- =====================================================
-- 4. АВТОМАТИЧЕСКИ ПРИМЕНЯЕМ КРАСНУЮ ТЕМУ ПРИ ЗАГРУЗКЕ
-- =====================================================
-- Откладываем применение, чтобы библиотека успела загрузиться
task.spawn(function()
    task.wait(0.5)
    pcall(function()
        Interface.ThemeManager.SetTheme("qwertikz Red")
        print("🎨 qwertikz Red тема применена!")
    end)
end)

-- =====================================================
-- 5. ДОПОЛНИТЕЛЬНО: МЕНЯЕМ ВСЕ НАДПИСИ "Abysall" НА "qwertikz"
-- =====================================================
-- Это перехватывает создание всех текстовых элементов
local originalAddLabel = Interface.Library.AddLabel or function() end

-- Если в библиотеке есть функция AddLabel, подменяем её
if Interface.Library.AddLabel then
    Interface.Library.AddLabel = function(text, ...)
        if type(text) == "string" then
            text = text:gsub("Abysall", "qwertikz")
            text = text:gsub("Abysall Hub", "qwertikz Hub")
        end
        return originalAddLabel(text, ...)
    end
end

return Interface