button_script = File.LoadLua("button/button.lua")
Button = button_script()
--[[
still to do:
1) support 800x600 res by shrinking button bar below that size
2) add justification to the string images when it is implemented in the api
3) add hover text/ tooltip support
4) check if the button pick area / button are aligned sensibly.
]]

-- declare recurring variables used by multiple functions
	button_width = 144
	button_normal_color 	= Color.Create(1, 1, 1, 0.7)
	button_hover_color 	= Color.Create(1, 1, 1, 0.9)
	button_selected_color = Color.Create(1,1,1)
	button_shadow_color = Color.Create(0.4,0.4,0.4,0.5)	

 -- declare recurring variables outside of function
	introscreenfont = Font.Create("Trebuchet MS", 25, {Bold=true})
	label_justification 	= Image.Justification.Center
	function create_stringimages(label)
		-- STILL NEEDS A JUSTIFICATION APPLIED TO STRINGIMAGE
		return {
			normal = Image.String(introscreenfont, button_normal_color, button_width, label),
			shadow = Image.String(introscreenfont, button_shadow_color, button_width, label),
			hover = Image.String(introscreenfont, button_hover_color, button_width, label),
			selected = Image.String(introscreenfont, button_selected_color, button_width, label),
		}
	end

-- declare recurring variables outside of function
mainbtn_bg1 = Image.LoadFile("menuintroscreen/images/introBtn_border.png")
btnimage_position = Point.Create(0,10)
function create_mainbutton(event_sink, argimage, arglabel)
	label = create_stringimages(arglabel)
	image_n = Image.Group({
		Image.Translate(Image.Multiply(argimage, button_normal_color),btnimage_position),
		Image.Translate(label.shadow, Point.Create(2, -1)),
		label.normal,
		})	
	image_h = Image.Group({
			Image.Translate(Image.Multiply(mainbtn_bg1, button_hover_color),btnimage_position),
			Image.Translate(Image.Multiply(argimage, button_hover_color),btnimage_position),
			Image.Translate(label.shadow, Point.Create(2, -1)),
			label.hover,
		})
	-- selected doesnt need color multiply. 
	image_s = Image.Group({
			Image.Translate(mainbtn_bg1,btnimage_position),
			Image.Translate(argimage,btnimage_position),
			Image.Translate(label.shadow, Point.Create(2, -1)),
			label.hover,			
		})
	button = Button.create_image_button(image_n, image_h, image_s)
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

button_separator = 56
function render_list(list)
	translated_list = {}
	offset = button_width+button_separator
	offset_x = #list * offset
	for i, item in pairs(list) do
		offset_x = offset_x - offset
		translated_list[#translated_list+1] = Image.Translate(item, Point.Create(offset_x, 0))
	end

	return Image.Group(translated_list)
end

resolution = Screen.GetResolution()
-- combine background image and logo
bgimageuncut = Image.Group({
	Image.LoadFile("menuintroscreen/images/menuintroscreen_bg.jpg"),
	Image.Translate(Image.Multiply(Image.LoadFile("menuintroscreen/images/menuintroscreen_logo.png"),Color.Create(1,1,1,0.7)),Point.Create(875,525)),
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
--[[ 
function buttonbar()
	buttonimage = render_list(create_button_list())
	buttonimage_rendersize = Image.Size(buttonimage)
	buttonimagewidth = Point.X(buttonimage_rendersize)
	buttonimageheight = Point.Y(buttonimage_rendersize) 
	ratio = Divide(xres, buttonimagewidth)
	scalefactor = Number.Min(1, ratio)
	btnbarres = Point.Create(Number.Multiply(buttonimagewidth, scalefactor), Number.Multiply(buttonimageheight, scalefactor))
	return = Image.ScaleFill(buttonimage, btnbarres, Image.Justification.Center)
end
]]
return Image.Group({
	Image.ScaleFill(bgimage, resolution, Image.Justification.Center),
	Image.Translate(Image.Justify(render_list(create_button_list()), resolution, Image.Justification.Bottom), Point.Create(0,70)),
})
