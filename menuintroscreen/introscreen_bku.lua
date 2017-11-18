button_script = File.LoadLua("button/button.lua")
Button = button_script()

--[[	
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

-- declare variables used by multiple functions
	button_width = 144
	button_separator = 56

 -- declare recurring variables outside of function
	introscreenfont = Font.Create("Trebuchet MS", 30, {Bold=true})
	button_caption_color 	= Color.Create(1, 1, 1, 0.7)
	button_caption_color_h 	= Color.Create(1, 1, 1, 0.9)
	button_selected_color = Color.Create(1,1,1)
	button_shadow_color = Color.Create(0.4,0.4,0.4,0.5)	
	function create_stringimages(label)
		label_justification 	= Image.Justification.Center
		-- STILL NEEDS A JUSTIFICATION APPLIED TO STRINGIMAGE
		return {
			normal = Image.String(intoscreenfont, button_caption_color, button_width, label),
			shadow = Image.String(intoscreenfont, button_shadow_color, button_width, label),
			hover = Image.String(intoscreenfont, button_caption_color_h, button_width, label),
			selected = Image.String(intoscreenfont, button_caption_color_h, button_width, label),
		}
	end

mainbtn_bg1 = Image.LoadFile("introBtn_border.png")
function create_mainbutton(event_sink, argimage, arglabel)
	label = create_stringimages(arglabel)
	image_n = Image.Group({
		Image.Multiply(argimage, Color.Create(1,1,1, 0.6)),
		Image.Translate(label.shadow, Point(2, -21)),
		Image.Translate(label.normal, Point(0, -20)),
		})
		
	image_h = Image.Group({
			Image.Multiply(mainbtn_bg1, Color.Create(1,1,1, 0.8)),
			Image.Multiply(argimage, Color.Create(1,1,1, 0.8)),
			Image.Translate(label.shadow, Point(2, -21)),
			Image.Translate(label.hover, Point(0, -20)),
		})
	image_s = Image.Group({
			mainbtn_bg1,
			argimage,
			Image.Translate(label.shadow, Point(2, -21)),
			Image.Translate(label.hover, Point(0, -20)),			
		})
	button = Button.create_image_button(image_n, image_h, image_s)
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
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.exit"), Image.LoadFile("menuintroscreen/images/introBtnExit.png"), "EXIT")
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.options"), Image.LoadFile("menuintroscreen/images/introBtnSettings.png"), "OPTIONS")
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.training"), Image.LoadFile("menuintroscreen/images/introBtnHelp.png"), "TRAINING")
--	list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://www.freeallegiance.org/forums/"), "Website")
--	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.help"), "menuintroscreen/images/introBtnHelp.png", "HELP")
	list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://discord.gg/WcEJ9VH"), Image.LoadFile("menuintroscreen/images/introBtnDiscord.png"), "DISCORD")
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.lan"), Image.LoadFile("menuintroscreen/images/introBtnLan.png"), "LAN")
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.lobby"), Image.LoadFile("menuintroscreen/images/introBtnOnline.png"), "PLAY ONLINE")
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
