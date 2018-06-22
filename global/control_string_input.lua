

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

function create(context, target, opts)
	local opts = opts or {}

	local font = opts.font or Font.Create("Verdana", 14)
	local string_to_value = opts.string_to_value or function (string)
		return string
	end
	local value_to_string = opts.value_to_string or function (value)
		return value
	end
	local string_is_valid = opts.string_is_valid or function (string)
		return true
	end
	local width = opts.width or 200

	-- starts empty, but immediately filled when activated
	local current_content = String.CreateEventSink("")

	local height = Font.Height(font)
	local string_image = Image.String(font, white, current_content)
	local target_string_image = Image.String(font, white, value_to_string(target))
	local text_size = Image.Size(string_image)
	local text_size_x = Point.X(text_size)
	
	local focus_target = context.create_focus_target()

	local active = focus_target.get_has_focus()

	-- Once the text width exceeds the available width, the text is offset
	local offset_x = Number.Max(0, text_size_x-width)

	local result = Image.MouseEvent(Image.Group({
		-- Background to click on
		Image.Extent(Point.Create(width, height), Color.Create(0, 0, 0, 0)),
		-- Show that we are currently active by changing the background
		Image.Switch(active, {
			[ true ] = Image.Extent(Point.Create(width, height), Color.Create(1, 1, 1, 0.3)),
		}),
		-- The actual string
		Image.Switch(active, {
			[ true ] = Image.Cut(string_image, Rect.Create(offset_x, 0, width + offset_x, height)),
			[ false ] = Image.Cut(target_string_image, Rect.Create(0, 0, width, height))
		}),
		-- Blinking cursor, only when active
		Image.Switch(active, {
			[ true ] = blinking_cursor(text_size_x - offset_x, height)
		}),
	}))

	-- Filling
	Event.OnEvent(current_content, Event.Get(result, "mouse.left.click"), function ()
		return value_to_string(target)
	end)
	
	-- enable keyboard presses
	focus_target.add_focus_source(Event.Get(result, "mouse.left.click"))
	
	-- Get the event that occurs when a key goes up
	Event.OnEvent(current_content, focus_target.get_keyboard_char_source(), function (str)
		return current_content .. str
	end)
	Event.OnEvent(current_content, focus_target.get_keyboard_key_source("backspace"), function ()
		return String.Slice(current_content, 0, -1)
	end)

	function use_new_string_if_valid(new_string)
		if string_is_valid(new_string) then
			return string_to_value(new_string)
		end
		return target
	end

	Event.OnEvent(target, focus_target.get_keyboard_char_source(), function (str)
		return use_new_string_if_valid(current_content .. str)
	end)
	Event.OnEvent(target, focus_target.get_keyboard_key_source("backspace"), function ()
		return use_new_string_if_valid(String.Slice(current_content, 0, -1))
	end)

	focus_target.add_defocus_source(focus_target.get_keyboard_key_source("enter"))
	focus_target.add_defocus_source(focus_target.get_keyboard_key_source("escape"))

	return result
end

return {
	create = create
}