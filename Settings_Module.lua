local SettingsModule = {}

-- Ця функція викликається головним скриптом для створення елементів керування
-- Ми передаємо 'library', щоб мати доступ до функції ToggleUI()
function SettingsModule:Init(section, library)
	
	-- Створюємо елемент для налаштування гарячої клавіші
	section:NewKeybind(
		"Menu Hotkey", -- Назва елемента
		"Натисніть на поле, щоб змінити клавішу для відкриття/закриття меню.", -- Підказка
		Enum.KeyCode.K, -- Клавіша за замовчуванням
		function()
			-- Функція, яка буде викликатись при натисканні налаштованої клавіші
			if library and library.ToggleUI then
				library:ToggleUI()
			end
		end
	)

end

-- Ця функція викликається при закритті GUI для очищення
function SettingsModule:Shutdown()
	-- В цьому модулі немає чого очищувати, оскільки UI бібліотека сама керує своїми елементами
end

return SettingsModule
