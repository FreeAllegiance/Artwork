Global = File.LoadLua("global/global.lua")()
Fonts = File.LoadLua("global/fonts.lua")()
Colors = File.LoadLua("global/colors.lua")()

ControlStringInput = File.LoadLua("global/control_string_input.lua")()

local muted_white = Color.Create(0.8, 0.8, 0.8)
local width_default = 150
local font_default = Font.Create("Verdana", 14)

function create_listbox(target, list, opts)
	local opts = opts or {}

	-- each entry in the list may need to be converted to a string for use in the default entry renderer
	local entry_to_label = opts.entry_to_label

	-- each entry in the list needs to be converted into the value
	opts.entry_to_value = opts.entry_to_value or function (entry)
		return entry
	end

	local font = opts.font or font_default

	opts.width = opts.width or width_default

	opts.is_equal = opts.is_equal
	opts.is_selected = opts.is_selected or function (value)
		return opts.is_equal(target, value)
	end

	-- can be used to wire other event sinks
	opts.change_registration_callback = opts.change_registration_callback or function (register_func)
	end

	-- This is the default renderer, we could change it. If changed, it makes the entry_to_label unnecessary
	local entry_renderer = opts.entry_to_image or function (entry, index, target)
		local label_string = entry_to_label(entry)
		local is_selected = opts.is_selected(opts.entry_to_value(entry))

		local label_image_string = Image.String(font_default, muted_white, label_string)
		local label_image = Image.Group({
			label_image_string,
			Image.Extent(Point.Create(opts.width, Point.Y(Image.Size(label_image_string))), Color.Create(0,0,0,0))
		})
		local label_image_size = Image.Size(label_image)
		return Image.Switch(is_selected, {
			[ false ] = label_image,
			[ true ] = Image.Group({
				Image.Extent(label_image_size, Color.Create(0.2, 1, 0.2, 0.3)),
				label_image
			})
		})
	end

	-- method to wrap the render with a clickable area
	function clickable_entry_renderer(entry, index)
		local clickable_entry = Image.MouseEvent(entry_renderer(entry, index, target))
		local event_click = Event.Get(clickable_entry, "mouse.left.click")

		opts.change_registration_callback(function (secondary_target, secondary_target_func) 
			Event.OnEvent(secondary_target, event_click, function ()
				return secondary_target_func(entry)
			end)
		end)
		Event.OnEvent(target, event_click, function ()
			return opts.entry_to_value(entry)
		end)
		return clickable_entry
	end

	local rendered_entries = List.Map(list, clickable_entry_renderer)
	return Image.StackVertical(rendered_entries, 2)
end

-- Control.String.create_listbox(target, list, {entry_to_string=MyListItemModificationFunction, entry_renderer=MyLineFormattingFunction})
function create_listbox_string(target, list, opts)
	local opts = opts or {}
	opts.entry_to_value = opts.entry_to_value or function (entry)
		return entry
	end
	opts.entry_to_label = opts.entry_to_label or function (entry)
		return entry
	end
	opts.is_equal = opts.is_equal or function (a, b)
		return String.Equals(a, b)
	end
	return create_listbox(target, list, opts)
end

function create_listbox_boolean(target, opts)	
	local opts = opts or {}
	opts.entry_to_label = opts.entry_to_label or function (entry)
		if entry == true then
			return "Yes"
		else
			return "No"
		end
	end
	opts.is_equal = opts.is_equal or function (a, b)
		return Boolean.Equals(a, b)
	end
	return create_listbox(target, { true, false }, opts)
end

function create_listbox_number(target, list, opts)
	local opts = opts or {}
	opts.decimals = opts.decimals or 2
	opts.entry_to_label = opts.entry_to_label or function (entry)
		return Number.ToString(entry, opts.decimals)
	end
	opts.is_equal = opts.is_equal or function (a, b)
		return Number.Equals(a, b)
	end
	return create_listbox(target, list, opts)
end

function create_listbox_int(target, list, opts)
	local opts = opts or {}
	opts.decimals = opts.decimals or 0
	return create_listbox_number(target, list, opts)
end

function create_input_number(context, target, opts)
	local opts = opts or {}
	opts.decimals = opts.decimals or 2

	opts.string_to_value = opts.string_to_value or function (string)
		return Number.Round(String.ToNumber(string), opts.decimals)
	end
	opts.value_to_string = opts.value_to_string or function (number)
		return Number.ToString(number, opts.decimals)
	end
	opts.string_is_valid = opts.string_is_valid or function (string)
		return String.IsNumber(string)
	end

	return ControlStringInput.create(context, target, opts)
end

function create_input_int(context, target, opts)
	local opts = opts or {}
	opts.decimals = opts.decimals or 0
	return create_input_number(context, target, opts)
end


return {
	create_listbox=create_listbox,
	create_input=ControlStringInput.create,
	string = {
		create_listbox=create_listbox_string,
		create_input=ControlStringInput.create,
	},
	boolean={
		create_listbox=create_listbox_boolean
	},
	number={
		create_listbox=create_listbox_number,
		create_input=create_input_number
	},
	int={
		create_listbox=create_listbox_int,
		create_input=create_input_int
	}
}