
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

	local popup_list = List.CreateEventSink({})
	local popup_list_ids = List.CreateEventSink({})
	local popup_count = 0
	function create_popup(image)
		local popup_id = popup_count
		popup_count = popup_count + 1

		local popup_list_index = List.Find(popup_list_ids, function (id)
			return Number.Equals(id, popup_id)
		end)
		local popup_is_closed = Number.Equals(popup_list_index, -1)
		local popup_is_open = Boolean.Not(popup_is_closed)

		function add_open_source(open_source)
			local filtered_source = Event.Filter(open_source, popup_is_closed)

			Event.OnEvent(popup_list_ids:Get("append entry"), filtered_source, function ()
				return popup_id
			end)
			Event.OnEvent(popup_list:Get("append entry"), filtered_source, function ()
				return image
			end)
		end

		function add_close_source(close_source)
			local filtered_source = Event.Filter(close_source, popup_is_open)

			Event.OnEvent(popup_list_ids:Get("remove entry"), filtered_source, function () 
				return popup_list_index
			end)
			Event.OnEvent(popup_list:Get("remove entry"), filtered_source, function () 
				return popup_list_index
			end)
		end

		return {
			get_is_open=function ()
				return popup_is_open
			end,
			get_is_closed=function ()
				return popup_is_closed
			end,
			add_open_source=add_open_source,
			add_close_source=add_close_source,
		}
	end

	function create_result_image(size, image)
		local catchall_image = Image.MouseEvent(Image.Group({
			Image.Extent(size, Color.Create(0,0,0,0)),
			image,
			Image.Group(List.Map(popup_list, function (popup_image)
				return popup_image
			end)),
		}))

		local click_event = Event.Get(catchall_image, "mouse.left.click")
		add_defocus_source(click_event)

		return catchall_image
	end

	return {
		create_focus_target=create_focus_target,
		create_popup=create_popup,
		create_result_image=create_result_image
	}
end

return {
	create_context=create_context
}