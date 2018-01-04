
function create_context()
	local current_focus = Number.CreateEventSink(-1)


	local count = 0
	function create_unique_identifier()
		local id = count
		count = count + 1
		return id
	end

	function add_defocus_source(source)
		-- update the current focus according to this lua script
		Event.OnEvent(current_focus, source, function ()
			return -1
		end)

		-- The game code can receive events again
		Event.OnEvent(Screen.HasKeyboardFocus(), source, function ()
			return false
		end)
	end

	function create_focus_target()
		local id = create_unique_identifier()
		-- This lua script should be considered focused, and this target needs to equal the current focus
		local has_focus = Boolean.And(Screen.HasKeyboardFocus(), Number.Equals(id, current_focus))

		function get_has_focus()
			return has_focus
		end

		function add_focus_source(source)
			-- update the current focus according to this lua script
			Event.OnEvent(current_focus, source, function ()
				return id
			end)
			-- let the game code know we want to focus on this lua instance
			Event.OnEvent(Screen.HasKeyboardFocus(), source, function ()
				return true
			end)
		end

		function get_keyboard_char_source()
			return Event.Filter(Screen.GetKeyboardCharSource(), has_focus)
		end

		function get_keyboard_key_source(name)
			return Event.Filter(Screen.GetKeyboardKeySource(name), has_focus)
		end

		return {
			get_has_focus=get_has_focus,
			add_focus_source=add_focus_source,
			add_defocus_source=add_defocus_source,
			get_keyboard_char_source=get_keyboard_char_source,
			get_keyboard_key_source=get_keyboard_key_source,
		}
	end

	function create_result_image(size, image)
		local catchall_image = Image.MouseEvent(Image.Group({
			Image.Extent(size, Color.Create(0,0,0,0)),
			image,
		}))

		local click_event = Event.Get(catchall_image, "mouse.left.click")
		add_defocus_source(click_event)

		return catchall_image
	end

	return {
		create_focus_target=create_focus_target,
		create_result_image=create_result_image
	}
end

return {
	create_context=create_context
}