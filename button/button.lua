-- We have to wrap the entire script in a so called Immediately-Invoked Function Expression (IIFE)
-- otherwise variables would be pulled into the global scope
return (function()

	sound_mouseover = Screen.CreatePlaySoundSink("button/sound/mouseover.ogg")
	sound_click = Screen.CreatePlaySoundSink("button/sound/cancel.ogg")

	function create_textbutton(label, size, font, txtcolor, bgcolor, hovercolor, clickcolor, txtdisabledcolor)

		-- optional arguments processing
		button_caption_font = font or Font.Create("Verdana", 16)
		button_caption_color = txtcolor or Color.Create(1, 1, 1)
		button_caption = Image.String(button_caption_font, button_caption_color, 100, label)
		button_bgcolor = bgcolor or Color.Create(1, 1, 1, 0.0)
		button_hovercolor = hovercolor or Color.Create(1, 1, 1, 0.2)
		button_disabled_caption_color = txtdisabledcolor or Color.Create(0.8,0.8,0.8,0.8)

		font_height = Font.Height(button_caption_font) -- while we wait until we can retrieve this directly from the fontobject

		function create_button_layer(color)
			-- All the different layers have the same size, so we can reduce the duplication
			return Image.CreateExtent(size, color)
		end

		-- Create a transparant layer, and wrap it inside an image that registers events
		button_pick = Image.CreateMouseEvent(create_button_layer(Color.Create(0, 0, 0, 0)));

		-- Grab the event streams we are interested in
		button_enter = Event.Get(button_pick, "mouse.enter")
		button_leave = Event.Get(button_pick, "mouse.leave")
		button_click = Event.Get(button_pick, "mouse.left.click")

		-- We can attach global listeners ("Sinks") to the event sources
		Event.OnEvent(sound_mouseover, button_enter);
		Event.OnEvent(sound_click, button_click);

		-- We can calculate if we are hovering by comparing two event sources
		is_hovering = Event.ToBoolean(false, {
			[button_enter]=true,
			[button_leave]=false,
		})

		-- Create a font and a caption with that font
		

		-- Return the button. The button has three layers: 
		-- - Background which is dependent on the value in "is_hovering"
		-- - The button caption, somewhat centered
		-- - The mouse event layer, which needs to be on top
		export_button = Image.Group({
			Image.Switch(is_hovering, {
				-- we need to wrap false and true in brackets because otherwise they would be interpreted as strings by lua
				[false]=create_button_layer(button_bgcolor),
				[true]=create_button_layer(button_hovercolor),
			}),
			Image.Translate(button_caption, 
				Point.Create(
					50,
					Number.Add(
						Number.Divide(Point.Y(size), 2), 
						Number.Multiply(font_height,2)
					)
				)
			),
			button_pick,
		})

		export_events = {
			click=button_click
		}

		return {
			image=export_button,
			events=export_events,
		}
	end

	function create_image_button(image_path, hover_image_path, click_image_path, disabled_image_path)
		button_image = Image.LoadFile(image_path)
		button_image_hover = Image.LoadFile(hover_image_path) or button_image
		button_image_click = Image.LoadFile(click_image_path) or button_image
		button_image_disabled = Image.LoadFile(disabled_image_path) or button_image

		button_image_size = Image.Size(button_image)
		button_x = Point.X(button_image_size)
		button_y = Point.Y(button_image_size)

		-- Create a transparant layer, and wrap it inside an image that registers events
		button_pick = Image.CreateMouseEvent(Image.CreateExtent(Point.Create(button_x, button_y), Color.Create(0, 0, 0, 0)));

		-- Grab the event streams we are interested in
		button_enter = Event.Get(button_pick, "mouse.enter")
		button_leave = Event.Get(button_pick, "mouse.leave")
		button_click = Event.Get(button_pick, "mouse.left.click")

		-- We can attach global listeners ("Sinks") to the event sources
		Event.OnEvent(sound_mouseover, button_enter);
		Event.OnEvent(sound_click, button_click);

		-- We can calculate if we are hovering by comparing two event sources
		is_hovering = Event.ToBoolean(false, {
			[button_enter]=true,
			[button_leave]=false,
		}, false)

		export_button = Image.Group({
			Image.Switch(is_hovering, {
				[false]=button_image,
				[true]=button_image_hover,
			}),
			button_pick,
		})

		export_events = {
			click=button_click
		}

		return {
			image=export_button,
			events=export_events,
		}
	end


	function create_old_button(image_path)
		button_image_full = Image.LoadFile(image_path)

		button_image_full_size = Image.Size(button_image_full)
		button_x = Point.X(button_image_full_size)
		button_full_y = Point.Y(button_image_full_size)
		button_y = Number.Divide(button_full_y, 4)

		-- Create a transparant layer, and wrap it inside an image that registers events
		button_pick = Image.CreateMouseEvent(Image.CreateExtent(Point.Create(button_x, button_y), Color.Create(0, 0, 0, 0)));

		-- Grab the event streams we are interested in
		button_enter = Event.Get(button_pick, "mouse.enter")
		button_leave = Event.Get(button_pick, "mouse.leave")
		button_click = Event.Get(button_pick, "mouse.left.click")

		-- We can attach global listeners ("Sinks") to the event sources
		Event.OnEvent(sound_mouseover, button_enter);
		Event.OnEvent(sound_click, button_click);

		-- We can calculate if we are hovering by comparing two event sources
		is_hovering = Event.ToBoolean(false, {
			[button_enter]=true,
			[button_leave]=false,
		}, false)

		clip_rect_normal = Rect.Create(0, Number.Multiply(3, button_y), button_x, Number.Multiply(4,button_y))
		clip_rect_hover = Rect.Create(0, button_y, button_x, Number.Multiply(2, button_y))
		clip_rect_click = Rect.Create(0, button_y, button_x, Number.Multiply(2, button_y))

		button_image_normal = Image.Cut(button_image_full, clip_rect_normal)
		button_image_hover = Image.Cut(button_image_full, clip_rect_hover)

		export_button = Image.Group({
			Image.Switch(is_hovering, {
				[false]=button_image_normal,
				[true]=button_image_hover,
			}),
			button_pick,
		})

		export_events = {
			click=button_click
		}

		return {
			image=export_button,
			events=export_events,
		}
	end


	return {
		create_textbutton=create_textbutton,
		create_old_button=create_old_button,
		create_image_button=create_image_button
	}

end)()
