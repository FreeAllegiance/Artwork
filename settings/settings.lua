Button = File.LoadLua("button/button.lua")()
Global = File.LoadLua("global/global.lua")()
Fonts = File.LoadLua("global/fonts.lua")()
Colors = File.LoadLua("global/colors.lua")()
Popup = File.LoadLua("global/popup.lua")()
Control = File.LoadLua("global/control.lua")()

version = "settings alpha v0.001 "

function makesettingsscreen()



	return settingsscreen
end

return makesettingsscreen()