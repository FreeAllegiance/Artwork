

button_script = File.LoadLua("button/button.lua")
Button = button_script()

function training_button()
	button = Button.create_textbutton("Training", Point.Create(200, 60))

	Event.OnEvent(Screen.GetExternalEventSink("open.training"), button.events.click)

	return button.image
end

function create_default_button(event_sink, label)
	button = Button.create_textbutton(label, Point.Create(200, 60))

	Event.OnEvent(event_sink, button.events.click)

	return button.image
end

function create_mainbutton(event_sink, image_n, image_h, image_c, image_d)
	imgnormal = image_n
	imghover = image_h or imgnormal
	imgclick = image_c or imgnormal
	imgdisabld = image_d or imgnormal
	button = Button.create_image_button(imgnormal, imghover, imgclick, imgdisabld)

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
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.exit"), "menuintroscreen/images/introBtnExit.png")
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.options"), "menuintroscreen/images/introBtnSettings.png")
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.training"), "menuintroscreen/images/introBtnHelp.png")
	-- list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.motd"), "MOTD")

--	list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://www.freeallegiance.org/forums/"), "Website")
--	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.intro"), "Intro")

--	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.credits"), "Credits")
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.help"), "menuintroscreen/images/introBtnHelp.png")
	list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://discord.gg/WcEJ9VH"),"menuintroscreen/images/introBtnDiscord.png")
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.lan"), "menuintroscreen/images/introBtnLan.png")
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.lobby"), "menuintroscreen/images/introBtnOnline.png")
	return list
end

buttonimgwidth = 150

function render_list(list)
	translated_list = {}
	offset_x = #list * buttonimgwidth
	for i, item in pairs(list) do
		offset_x = offset_x - buttonimgwidth
		translated_list[#translated_list+1] = Image.Translate(item, Point.Create(offset_x, 0))
	end

	return Image.Group(translated_list)
end

buttonpane = render_list(create_button_list())
resolution = Screen.GetResolution()
-- this is a stupid way to do it because there is a justify thing that would handle this great. 
buttonpane_x = Number.Subtract(Number.Divide(Point.X(resolution),2), Number.Divide(Point.X(Image.Size(buttonpane)),2))

-- this needs a condition: crop if resolution is smaller than 1920x1080, scale if it is bigger.
return Image.Group({
	Image.ScaleFit(Image.LoadFile("menuintroscreen/images/menuintroscreen_bg.jpg"), resolution, Image.Justification.Center),
	Image.Translate(buttonpane, Point.Create(buttonpane_x, 50)),
})


-- cheatsheet :)
-- Image.CreateExtent(Rect.Create(0, 0, 300, Point.Y(resolution)), Color.Create(0.1, 0.1, 0.3)),