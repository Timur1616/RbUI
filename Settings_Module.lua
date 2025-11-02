local SettingsModule = {}

function SettingsModule:Init(section, library)
	

	section:NewKeybind(
		"Menu Hotkey", 
		"Натисніть на поле, щоб змінити клавішу для відкриття/закриття меню.", 
		Enum.KeyCode.K, 
		function()
			if library and library.ToggleUI then
				library:ToggleUI()
			end
		end
	)

end


function SettingsModule:Shutdown()

end

return SettingsModule
