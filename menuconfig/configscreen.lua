
Context = File.LoadLua("global/context.lua")()
Button = File.LoadLua("button/button.lua")()
Global = File.LoadLua("global/global.lua")()
Control = File.LoadLua("global/control.lua")()

config_data = File.LoadLua("menuconfig/configdata.lua")()

context = Context.create_context()

resolution = Screen.GetResolution()
resolution_x = Point.X(resolution)
resolution_y = Point.Y(resolution)

titlebar_container_height = 100
titlebar_container_size = Point.Create(resolution_x, titlebar_container_height)

titlebar = Image.Group({
	Image.Extent(titlebar_container_size, Color.Create(0, 0, 0.5)),
	Image.Justify(
		Image.String(Font.Create("Verdana", 60), Color.Create(0.8, 0.8, 0.8), "Configuration"),
		titlebar_container_size,
		Justify.Center
		)
	})

local sidebar_width = 200;
local sidebar_height = resolution_y - titlebar_container_height
local sidebar_size = Point.Create(sidebar_width, sidebar_height)


local current_selected_tab = String.CreateEventSink("")


function create_sidebar_buttons_container()
	local button_font = Font.Create("Verdana", 16)
	local button_width = 150
	local button_height = 30
	local button_separation = 10

	function create_button_image(sink, label)
		local button = Button.create_standard_textbutton(label, button_font, button_width, button_height)
		Event.OnEvent(sink, button.events.click)
		return button.image
	end

	local sidebar_buttons_container = Image.StackVertical({
		create_button_image(Screen.Get("Open help popup"), "Quick reference"),
		Image.Switch(Screen.Get("Is in mission"), {
			[ true ] = Image.StackVertical({
				create_button_image(Screen.Get("Open mission info popup"), "Mission info"),
				create_button_image(Screen.Get("Open ping popup"), "Player pings"),
			}, button_separation)
		}),
		create_button_image(Screen.Get("Close sink"), "Close and continue"),
		Image.Switch(Screen.Get("Is in mission"), {
			[ true ] = create_button_image(Screen.Get("Quit mission sink"), "Quit mission")
		}),
		create_button_image(Screen.Get("Quit allegiance sink"), "Quit Allegiance"),
	}, button_separation)

	local sidebar_button_container_height = Point.Y(Image.Size(sidebar_buttons_container)) + 20

	return Image.Group({
		Image.Extent(Point.Create(sidebar_width - 20, sidebar_button_container_height), Color.Create(0, 0, 0.5)),
		Image.Justify(sidebar_buttons_container, Point.Create(sidebar_width - 20, sidebar_button_container_height), Justify.Center)
	}), sidebar_button_container_height
end

local sidebar_buttons_container, sidebar_button_container_height = create_sidebar_buttons_container()

local sidebar_sections_height = sidebar_height - sidebar_button_container_height

function create_sections_container()

	local button_size = Point.Create(sidebar_width, 50)

	local button_background = Image.Extent(button_size, Color.Create(0, 0, 0.3))
	local button_background_selected = Image.Extent(button_size, Color.Create(0, 0, 0.5))

	local section_images = {}
	for i, key in pairs(config_data.section_order) do
		local label = config_data.section_labels[key]

		function create_button_image(background_image, label)
			return Image.Group({
				background_image,
				Image.Justify(
					Image.String(Font.Create("Verdana", 16), Color.Create(0.8, 0.8, 0.8), label),
					Image.Size(background_image),
					Justify.Center
				)
			})
		end
		local section_button = Button.create_image_button(
			create_button_image(
				Image.Switch(current_selected_tab, {
					[key]=button_background_selected
				}, button_background),
				label
			),
			create_button_image(
				button_background_selected,
				label
			)
		)

		Event.OnEvent(current_selected_tab, section_button.events.click, function ()
			return key
		end)
		section_images[#section_images+1] = Image.Group({
			section_button.image
		})
	end

	local sidebar_sections_container = Image.StackVertical(section_images, 20)

	return Global.create_vertical_scrolling_container(
		sidebar_sections_container, 
		Point.Create(sidebar_width, sidebar_sections_height), 
		Color.Create(1, 0, 0)
	)
end


local sidebar_sections_container = create_sections_container()

local sidebar = Image.Group({
	Image.Extent(sidebar_size, Color.Create(0, 0, 0.2)),
	Image.Translate(sidebar_sections_container, Point.Create(0, 10)),
	Image.Justify(sidebar_buttons_container, sidebar_size, Justify.Bottom)
})


local divider_position = 200
local divider_margin = 10
function create_configuration(label, configuration_image)
	local label_font = Font.Create("Verdana", 16)
	local label_image = Image.String(label_font, Color.Create(0.8, 0.8, 0.8), label, {
		Width=190
		})

	local configuration_image_height = Point.Y(Image.Size(configuration_image))
	local label_image_height = Point.Y(Image.Size(label_image))

	local configuration_entry_height = Number.Max(configuration_image_height, label_image_height)

	return Image.Group({
		Image.Justify(label_image, Point.Create(divider_position - divider_margin, configuration_entry_height), Justify.Right),
		Image.Extent(Rect.Create(divider_position - 1, 0, divider_position + 1, configuration_entry_height), Color.Create(0.5, 0.5, 0.5)),
		Image.Translate(
			configuration_image,
			Point.Create(divider_position + divider_margin, 0)
		)
		
	})
end

local section_entries = config_data.create_section_entries(context, create_configuration)

function create_contents_container()
	local content_container_size = Point.Create(resolution_x - sidebar_width, sidebar_height)

	local lazy_sections = {}
	for key, config_func in pairs(section_entries) do
		lazy_sections[key] = Image.Lazy(function ()
			local configuration_entry_images = config_func()

			local content_image = Image.Group({
				Image.Translate(
					Image.StackVertical(configuration_entry_images, 20),
					Point.Create(0, 20)
				)
			})

			return Global.create_vertical_scrolling_container(content_image, content_container_size, Color.Create(1, 0, 0))
		end)
	end

	return Image.Group({
		Image.Extent(content_container_size, Color.Create(0, 0, 0)),
		Image.Switch(current_selected_tab, lazy_sections)
	})
end
local contents_container = create_contents_container()

return Image.Group({
	titlebar,
	Image.Translate(
		Image.Group({
			sidebar,
			Image.Translate(
				contents_container,
				Point.Create(sidebar_width, 0)
			)			
		}),
		Point.Create(0, titlebar_container_height)
	),
})