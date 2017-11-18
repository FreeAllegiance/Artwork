button_script = File.LoadLua("button/button.lua")
Button = button_script()

--[[
	introscreenfont = Font.Create("Trebuchet MS", 20, {Bold=true})
	function create_stringimage(label, style)
	-- style contains many optional arguments: font, color, color_h, bgcolor, bgcolor_h, txtjustify)
		-- optional arguments processing
		button_caption_font 	= style.font or introscreenfont
		button_caption_color 	= style.color or Color.Create(1, 1, 1, 0.7)
		button_caption_color_h 	= style.color_h or Color.Create(1, 1, 1, 0.9)
		button_bgcolor 		    = style.bgcolor or Color.Create(0, 0, 0, 0.0)
		button_bgcolor_h 		= style.bgcolor_h or Color.Create(0, 0, 0, 0.0)
		label_justification 	= style.txtjustify  or Image.Justification.Center
		font_height = Font.Height(button_caption_font) 
		
		-- this will be unnecessary once we can justify text inside a text image
		stringimage_w = Number.Multiply(Number.Max(string.len(label),4),Number.Divide(font_height,2))

		return {
			normal = Image.String(button_caption_font, button_caption_color, stringimage_w, label),
			shadow = Image.String(button_caption_font, Color.Create(0.4,0.4,0.4,0.5), stringimage_w, label),
			hover = Image.String(button_caption_font, button_caption_color_h, stringimage_w, label),
		}
	end
	
	compleet nieuw plan:
	
	create_text_button gaat eruit.
	hebben we voorlopig niet nodig.
	
	oldstyle button hebben we ook niet nodig.

	in plaats daarvan houden we 1 list, die twee args doorstuurt; een image, en een string.
	
	een introscreen functie maakt voor normal, hover en select states elk een groupimage met label en image.
	(de images worden dus 'voorgekleurd' met de multiply, de stringimages krijgen hun kleur bij het maken ervan. Deze worden gegroepeerd. )
	de drie groupimages worden samen doorgestuurd naar de buttonmaker. 
	het enige dat de buttonmaker doet is de click area toevoegen en de states combineren in bijbehorende switches. 
	het gaat dus niet uitmaken of het om textbuttons gaat of om imagebuttons. de buttonmaker krijgt drie images om een button van te maken.
	
]]--
--[[
function training_button()
	button = Button.create_textbutton("Training", Point.Create(200, 60))

	Event.OnEvent(Screen.GetExternalEventSink("open.training"), button.events.click)

	return button.image
end
]]--
txtbuttonfont = Font.Create("Trebuchet MS", 30, {Bold=true})

function create_text_button(event_sink, label)
	-- create_textbutton(label, size,  font, txtcolor, bgcolor, bghovercolor, clickcolor)
	button = Button.create_textbutton(
			label, 
			Point.Create(200, 50), {
			txtfont=txtbuttonfont, 
			txtcolor=Color.Create(1,1,1,0.6), 
			txtcolor_h=Color.Create(1,1,1,0.8),
			--bgcolor = Color.Create(0,0,1,0.4),
			txtjustify = Image.Justification.Top,
		})
	Event.OnEvent(event_sink, button.events.click)

	return button.image
end

function create_mainbutton(event_sink, image_n)
	button = Button.create_image_button(image_n)
	Event.OnEvent(event_sink, button.events.click)
	return button.image
end

function create_oldstyle_button(event_sink, image_path)
	button = Button.create_old_button(image_path)

	Event.OnEvent(event_sink, button.events.click)

	return button.image
end

function create_button_list()
	list = {}
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.exit"), Image.LoadFile("menuintroscreen/images/introBtnExit.png"))
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.options"), Image.LoadFile("menuintroscreen/images/introBtnSettings.png"))
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.training"), Image.LoadFile("menuintroscreen/images/introBtnHelp.png"))
--	list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://www.freeallegiance.org/forums/"), "Website")
--	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.help"), "menuintroscreen/images/introBtnHelp.png", "HELP")
	list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://discord.gg/WcEJ9VH"), Image.LoadFile("menuintroscreen/images/introBtnDiscord.png"))
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.lan"), Image.LoadFile("menuintroscreen/images/introBtnLan.png"))
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.lobby"), Image.LoadFile("menuintroscreen/images/introBtnOnline.png"))
	return list
end

function create_txtbutton_list()
	list = {}
	list[#list+1] = create_text_button(Screen.GetExternalEventSink("open.exit"), "EXIT")
	list[#list+1] = create_text_button(Screen.GetExternalEventSink("open.options"), "OPTIONS")
	list[#list+1] = create_text_button(Screen.GetExternalEventSink("open.training"), "TRAINING")
--	list[#list+1] = create_text_button(Screen.CreateOpenWebsiteSink("https://www.freeallegiance.org/forums/"), "Website")
--	list[#list+1] = create_text_button(Screen.GetExternalEventSink("open.help"), "menuintroscreen/images/introBtnHelp.png", "HELP")
	list[#list+1] = create_text_button(Screen.CreateOpenWebsiteSink("https://discord.gg/WcEJ9VH"), "DISCORD")
	list[#list+1] = create_text_button(Screen.GetExternalEventSink("open.lan"), "LAN")
	list[#list+1] = create_text_button(Screen.GetExternalEventSink("open.lobby"), "PLAY ONLINE")
	return list
end	

function render_list(list, buttonimgwidth)
	translated_list = {}
	offset_x = #list * buttonimgwidth
	for i, item in pairs(list) do
		offset_x = offset_x - buttonimgwidth
		translated_list[#translated_list+1] = Image.Translate(item, Point.Create(offset_x, 0))
	end

	return Image.Group(translated_list)
end

buttonpane = render_list(create_button_list(), 200)
txtbuttonpane = render_list(create_txtbutton_list(),200)

resolution = Screen.GetResolution()
-- combine background image and logo
bgimageuncut = Image.Group({
	Image.LoadFile("menuintroscreen/images/menuintroscreen_bg.jpg"),
	Image.Translate(Image.Multiply(Image.LoadFile("menuintroscreen/images/menuintroscreen_logo.png"),Color.Create(1,1,1,0.6)),Point.Create(875,525)),
	})
-- calculate how much of the edges need to be trimmed to fit the resolution
xres = Point.X(resolution)
yres = Point.Y(resolution)
xbgcutout = Number.Min(xres,1920) -- less than or equal to 1920
ybgcutout = Number.Min(yres,1080) -- less than or equal to 1080
xbgoffset = Number.Divide(Number.Subtract(1920, xbgcutout),2)
ybgoffset = Number.Divide(Number.Subtract(1080, ybgcutout),2)
bgimagefileRect = Rect.Create(xbgoffset,ybgoffset, Number.Add(xbgoffset, xbgcutout), Number.Add(ybgoffset, ybgcutout))
-- trim the background image to size
bgimage = Image.Cut(bgimageuncut, bgimagefileRect)

return Image.Group({
	Image.ScaleFill(bgimage, resolution, Image.Justification.Center),
	Image.Translate(Image.Justify(buttonpane, resolution, Image.Justification.Bottom), Point.Create(0,70)),
	Image.Translate(Image.Justify(txtbuttonpane, resolution, Image.Justification.Bottom), Point.Create(0,50)),
})
