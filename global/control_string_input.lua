white = Color.Create(1, 1, 1);

function blinking_cursor(position, height)
	-- Every half second, switch between 0 and 1
	timer = Number.Mod(Number.Round(2 * Screen.GetNumber("time")), 2)
	
	-- 0 is nothing, 1 is just a one pixel wide vertical line
	image_off = Image.Empty()
	image_on = Image.Extent(Point.Create(1, height), white)
	
	return Image.Translate(
		Image.Switch(timer, {
			[ 0 ] = image_on,
			[ 1 ] = image_off,
		}),
		Point.Create(position, 0)
	)
end

function create(context, font, text, width)
	height = Font.Height(font)
	string_image = Image.String(font, white, text)
	text_size = Image.Size(string_image)
	text_size_x = Point.X(text_size)
	
	local focus_target = context.create_focus_target()

	active = focus_target.get_has_focus()

	-- Once the text width exceeds the available width, the text is offset
	offset_x = Number.Max(0, text_size_x-width)

	result = Image.Group({
		-- Background to click on
		Image.Extent(Point.Create(width, height), Color.Create(0, 0, 0, 0)),
		-- Show that we are currently active by changing the background
		Image.Switch(active, {
			[ true ] = Image.Extent(Point.Create(width, height), Color.Create(1, 1, 1, 0.3)),
		}),
		-- The actual string
		Image.Cut(string_image, Rect.Create(offset_x, 0, width + offset_x, height)),
		-- Blinking cursor, only when active
		Image.Switch(active, {
			[ true ] = blinking_cursor(text_size_x - offset_x, height)
		}),
	})
	
	result = Image.MouseEvent(result)
	
	focus_target.add_focus_source(Event.Get(result, "mouse.left.click"))
	
	-- Get the event that occurs when a key goes up
	Event.OnEvent(text, focus_target.get_keyboard_char_source(), function (str)
		return text .. str
	end)

	Event.OnEvent(text, focus_target.get_keyboard_key_source("backspace"), function (str)
		return String.Slice(text, 0, -1)
	end)

	focus_target.add_defocus_source(focus_target.get_keyboard_key_source("enter"))
	focus_target.add_defocus_source(focus_target.get_keyboard_key_source("escape"))

	return result
end

return {
	create = create
}