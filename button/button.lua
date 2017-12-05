version = "button.lua v0.03 "

sound_mouseover = Screen.CreatePlaySoundSink("button/sound/mouseover.ogg")
sound_click = Screen.CreatePlaySoundSink("button/sound/cancel.ogg")

function create_image_button(image_n, image_h, image_s, hovertext)
	button_image_size = Image.Size(image_n)
	button_x = Point.X(button_image_size)
	button_y = Point.Y(button_image_size)
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
		click=button_click
	}

	return {
		image=export_button,
		events=export_events,
		btnhovertext = export_text,
		version = version,
	}
end

return {
	create_image_button=create_image_button,
}