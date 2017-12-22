Colors = File.LoadLua("global/colors.lua")()
Global = File.LoadLua("global/global.lua")()
version = "button.lua v0.04 "

sound_mouseover = Screen.CreatePlaySoundSink("button/sound/mouseover.ogg")
sound_click = Screen.CreatePlaySoundSink("button/sound/cancel.ogg")

function create_image_button(image_n, image_h, image_sl, hovertext)
	button_image_size = Image.Size(image_n)
	button_x = Point.X(button_image_size)
	button_y = Point.Y(button_image_size)
	image_s = image_sl or image_n
	h_text = hovertext or "" 

	-- Create a transparant layer, and wrap it inside an image that registers events
	button_pick = Image.MouseEvent(Image.Extent(Point.Create(button_x, button_y), Color.Create(0, 0, 0, 0)));
	-- testrect = Image.Extent(Point.Create(button_x, button_y), Color.Create(1, 0, 0, 0.5))
	-- Grab the event streams we are interested in
	button_enter = Event.Get(button_pick, "mouse.enter")
	button_leave = Event.Get(button_pick, "mouse.leave")
	button_click = Event.Get(button_pick, "mouse.left.click")

	-- We can attach global listeners ("Sinks") to the event sources
	Event.OnEvent(sound_mouseover, button_enter);
	Event.OnEvent(sound_click, button_click);

	-- We can calculate if we are hovering by comparing two event sources
	btnstatus = Event.ToNumber({
		[button_leave]=0,
		[button_enter]=1,
		[button_click]=2,
	}, 0 )
	-- we return the hovertext based on the hover status.
	export_text = Event.ToString({
		[button_leave]="",
		[button_enter]=h_text,
	}, "")

	button_image_switched = Image.Switch(btnstatus, {
			[0]=image_n,
			[1]=image_h,
			[2]=image_s
		})

	export_button = Image.Group({
		button_image_switched,
		--testrect, 
		button_pick,
	})

	export_events = {
		click=button_click,
		enter=button_enter,
		leave=button_leave,
	}

	return {
		image=export_button,
		events=export_events,
		hovertext = export_text,
	}
end

function create_standard_textbutton(string, font, width, height)
	-- example: create_standard_textbutton("Hello World", Fonts.h1, 144, 72)
	string = string
	font = font	
	color_n = Colors.standard_ui
	color_h = Colors.button_hover_color
	btn_text_n = Image.String(font, color_n, string)
	btn_text_h = Image.String(font, color_h, string)
	width = width or Point.X(Image.Size(btn_text_n))+16
	height = height or 30
	background_src = Image.File("/button/images/default_bg.png")
	-- NOTE: To work around a bug that is soon to be fixed, I've put the button text below the button background in these groupimages. 
	-- please switch around when bug is fixed.
	button_n = Image.Group({
	Image.Justify(btn_text_n, Point.Create(width,height), Justify.Center),
	Global.create_backgroundpane(width,height,{src=background_src, partsize=16, color=color_n}),
	})
	button_h = Image.Group({
	Image.Justify(btn_text_h, Point.Create(width,height), Justify.Center),
	Global.create_backgroundpane(width,height,{src=background_src, partsize=16, color=color_h}),
	})
	button = create_image_button(button_n, button_h)
	return {
		image=button.image,
		events=button.events,
	}
end 

return {
	create_image_button=create_image_button,
	create_standard_textbutton = create_standard_textbutton,
	version = version,
}