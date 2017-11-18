-- We have to wrap the entire script in a so called Immediately-Invoked Function Expression (IIFE)
-- otherwise variables would be pulled into the global scope

--[[
ok. new idea.

the buttons only do buttons.
so we have a new image button script and a classic button script.
the new style takes a btnimage object as arg, in which multiple versions of the button image are packed.
a normal, hover, and selected image. If the button has a label it is added before it's passed to the button scripts.
(note, text shadow images are added after the fact, underneath the button)

]]--

return (function()

	sound_mouseover = Screen.CreatePlaySoundSink("button/sound/mouseover.ogg")
	sound_click = Screen.CreatePlaySoundSink("button/sound/cancel.ogg")

	function create_textbutton(label, size, style)
		-- style contains many optional arguments: font, txtcolor, txtcolor_h, bgcolor, bgcolor_h, txtjustify)

		-- optional arguments processing
		button_caption_font 	= style.txtfont or Font.Create("Trebuchet MS", 20, {Bold=true})
		button_caption_color 	= style.txtcolor or Color.Create(1, 1, 1, 0.7)
		button_caption_color_h 	= style.txtcolor_h or Color.Create(1, 1, 1, 0.9)
		button_bgcolor 		    = style.bgcolor or Color.Create(0, 0, 0, 0.0)
		button_bgcolor_h 		= style.bgcolor_h or Color.Create(0, 0, 0, 0.0)
		label_justification 	= style.txtjustify  or Image.Justification.Center
		
		font_height = Font.Height(button_caption_font) 
	
		function create_button_layer(color)
			-- All the different layers have the same size, so we can reduce the duplication
			return Image.CreateExtent(size, color)
		end
		-- Create a transparant layer, and wrap it inside an image that registers events
		button_pick = Image.CreateMouseEvent(create_button_layer(Color.Create(0, 0, 0, 0)))
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
		-- Return the button. The button has three layers: 
		-- - Background which is dependent on the value in "is_hovering"
		-- - The button caption, somewhat centered
		-- - The mouse event layer, which needs to be on top
		stringimage_w = Number.Multiply(Number.Max(string.len(label),4),Number.Divide(font_height,2))
		button_caption = Image.Group({
			Image.String(button_caption_font, Color.Create(0.4,0.4,0.4,0.5), stringimage_w, label), -- generic text shadow
			Image.Translate(
				Image.Switch(is_hovering, {
					[false]	=Image.String(button_caption_font, button_caption_color, stringimage_w, label),
					[true]	=Image.String(button_caption_font, button_caption_color_h, stringimage_w, label),
				}), 
				Point.Create(-2, 1)
			)
		})	

		export_button = Image.Group({
			Image.Switch(is_hovering, {
				-- we need to wrap false and true in brackets because otherwise they would be interpreted as strings by lua
				[false]=create_button_layer(button_bgcolor),
				[true]=create_button_layer(button_bgcolor_h),
			}),
			Image.Justify(button_caption, size, label_justification),
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

function create_image_button(image, hover_image, slct_image)
		button_image = Image.Multiply(image, Color.Create(1,1,1, 0.6))
		if hover_image ~= nil then
			button_image_hover = Image.LoadFile(hover_image)
		else
			button_image_hover = Image.Multiply(image, Color.Create(1,1,1, 0.8))
		end 	
		if slct_image ~= nil then
			button_image_slct = Image.LoadFile(slct_image)
		else
			button_image_slct = Image.Multiply(image, Color.Create(1,1,1, 1))
		end 	
--[[
		if label ~= nil then 
			txtimage = create_text_image(label, size, style)
			button_image_total
			txtimage.normal 
			txtimage.shadow
			txtimage.hover
		end
]]--
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
		btnstatus = Event.ToNumber(0, {
			[button_leave]=0,
			[button_enter]=1,
			[button_click]=2,
		})

--[[ We can calculate if we are hovering by comparing two event sources
		is_hovering = Event.ToBoolean(false, {
			[button_enter]=true,
			[button_leave]=false,
		}, false)
]]--
		export_button = Image.Group({
			Image.Switch(btnstatus, {
				[0]=button_image,
				[1]=button_image_hover,
				[2]=button_image_slct
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
		})

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
