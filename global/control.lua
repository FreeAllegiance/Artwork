Global = File.LoadLua("global/global.lua")()
Fonts = File.LoadLua("global/fonts.lua")()
Colors = File.LoadLua("global/colors.lua")()

ControlStringInput = File.LoadLua("global/control_string_input.lua")()

-- Control.String.create_listbox(target, list, {entry_to_string=MyListItemModificationFunction, entry_renderer=MyLineFormattingFunction})
function create_listbox(target, list, opts)	
	-- I think we can pass a function as an optional argument to this function
	-- a normal way to do this would I guess be function entry_renderer(entry) ... etc.
	opts = opts or {}
	-- I think for instance this will allow me to pass a function that will extract a string from a container
	-- or modify it in some way before it's put into the listbox.
	entry_to_string = opts.entry_to_string or function (entry)
		return entry
	end
	-- this i'm guessing would allow me to pass different formatting options as a function 
	entry_renderer = opts.entry_renderer or function (entry, index, target)
		string = entry_to_string(entry)
		is_selected = String.Equals(string, target)
		return Image.Switch(is_selected, {
			[ false ] = Image.String(Fonts.p, Color.Create(1, 1, 1), string),
			[ true ] = Image.String(Fonts.pbold, Color.Create(1, 1, 1), string)
		})
	end
	
	-- this runs for each entry in the list
	function clickable_entry_renderer(entry, index)
		clickable_entry = Image.MouseEvent(entry_renderer(entry, index, target))
		event_click = Event.Get(clickable_entry, "mouse.left.click")
		Event.OnEvent(target, event_click, function ()
			return entry_to_string(entry)
		end)
		return clickable_entry
	end
	rendered_entries = List.MapToImages(list, clickable_entry_renderer)
	return Image.StackVertical(rendered_entries)
end
--[[
function create_selectbox(target, list, opts)
 opts = opts or {}
 local show_menu = Boolean.CreateEventSink(false)
 local selected = target 
 values = create_listbox(target, list, opts)
 main_field = Image.Group({
	Global.create_box(75, 20),
	Image.String(Fonts.p, Colors.standard_ui, selected),
	Image.Translate(Image.String(Fonts.h1,Colors.standard_ui, "V"), Point.Create(75,0)), -- standin for arrow down symbol
 })
 mainfield_btn = Button.create_image_button(main_field, main_field)
 
 selectmenu = Image.Switch(
	show_menu,
	{
	[false]=Image.Empty(),
	[true]=values
	}
 )
 return Image.StackVertical({
	main_field_btn,
	selectmenu,
 })
end
]] 


return {
	string = {
		create_listbox=create_listbox,
		create_input=ControlStringInput.create,
	}
}