Button = File.LoadLua("button/button.lua")()
Global = File.LoadLua("global/global.lua")()
Fonts = File.LoadLua("global/fonts.lua")()
Colors = File.LoadLua("global/colors.lua")()

function create_simple_text_button(text, text_height)
	font = Font.Create("Verdana",text_height)
	button_normal_color = Color.Create(0.9, 0.9, 1, 0.8)
	button_hover_color 	= Color.Create(1, 0.9, 0.8, 0.8)

	button_image = Image.String(font, button_normal_color, 300, text, Justify.Left)
	button_image_highlight = Image.String(font, button_hover_color, 300, text, Justify.Left)

	button_credits = Button.create_image_button(button_image, button_image_highlight, button_image)

	return {
		image=button_credits.image,
		event_click=button_credits.events.click,
	}
end

function create_popup_window(target_image, opts)
	local opts = opts or {}
	local size = opts.size or Screen.GetResolution()
	local close_btn = create_simple_text_button("X", 20)

	local controls = opts.control_maker or function ()
		return Image.Translate(
			close_btn.image,
			Point.Create(popup_x - 40, 15)
		)
	end

	target_image_size = Image.Size(target_image)
	target_x = Point.X(target_image_size)
	target_y = Point.X(target_image_size)

	margin = 40
	scrollbar_width = 20

	area_x = Point.X(size)
	area_y = Point.Y(size)

	target_container_maximum_x = area_x - 2 * margin
	target_container_maximum_y = area_y - 2 * margin

	target_container_x = Number.Min(target_container_maximum_x, target_x + scrollbar_width)
	target_container_y = Number.Min(target_container_maximum_y, target_y)

	popup_x = target_container_x + 2 * margin
	popup_y = target_container_y + 2 * margin

	target_container_offset = Point.Create(margin, margin)
	target_container_size = Point.Create(target_container_x, target_container_y)

	return {
		image=Image.Justify(
			Image.Group({
				Global.create_backgroundpane(popup_x, popup_y, {color=button_normal_color, src=Image.File("/global/images/backgroundpane_80pcOpacity.png")}),
				Image.Translate(
					Global.create_vertical_scrolling_container(target_image, target_container_size, button_normal_color),
					target_container_offset
				),
				controls()
			}),
			size,
			Justify.Center
		),
		close_source=close_btn.event_click,
	}
end

return {
	create_popup_window=create_popup_window,
	create_simple_text_button=create_simple_text_button
}