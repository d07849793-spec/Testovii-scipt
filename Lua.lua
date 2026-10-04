-- Тестовый скрипт для демонстрации
local StarterGui = game:GetService("StarterGui")

-- Выводим уведомление на экране
StarterGui:SetCore("SendNotification", {
    Title = "Aimtop Script Hub";
    Text = "Скрипт успешно загружен и запущен!";
    Duration = 5;
})

-- Выводим сообщение в консоль разработчика (F9)
print("[Aimtop Script Hub]: Тестовый скрипт работает отлично!")
