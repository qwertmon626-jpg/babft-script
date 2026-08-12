-- Получение размеров экрана
local camera = workspace.CurrentCamera
local screenSize = camera.ViewportSize

-- Создание текстового объекта на экране
local textDrawing = Drawing.new("Text")
textDrawing.Text = "иди нахуй а не скрипт"
textDrawing.Size = 32
textDrawing.Center = true
textDrawing.Outline = true
textDrawing.OutlineColor = Color3.fromRGB(0, 0, 0)
textDrawing.Color = Color3.fromRGB(255, 0, 0) -- Красный цвет

-- Размещение ровно по центру
textDrawing.Position = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
textDrawing.Visible = true

-- Скрипт засыпает на 5 секунд, затем текст исчезает и удаляется
task.wait(5)
textDrawing:Remove()
