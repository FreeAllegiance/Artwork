
Popup = File.LoadLua("global/popup.lua")()
Fonts = File.LoadLua("global/fonts.lua")()

data = File.LoadLua("menuintroscreen/credits_data.lua")()
data_ms = File.LoadLua("menuintroscreen/credits_microsoft.lua")()
data_libs = File.LoadLua("menuintroscreen/credits_libraries.lua")()

header_font = Fonts.h1
subheader_font = Fonts.h3
description_font = Fonts.p
names_font = Fonts.p

header_color = Color.Create(1, 1, 1)
subheader_color = Color.Create(1, 1, 1)
description_color = Color.Create(1, 1, 1)
names_color = Color.Create(1, 1, 1)

function whitespace(height)
	return Image.Extent(Point.Create(0, height), Color.Create(0,0,0,0))
end

total_width = 450

column_width_without_margins = 200
column_width_with_margins = 250

function create(context)

	function create_columns_from_data(data)
		columns = {}
		for column_index_onebased, column in pairs(data.Columns) do 

			sections = {}
			for section_index_onebased, section in pairs(column) do

				if #section == 1 then
					section = {
						section[1],
						"",
						{},
					}
				elseif #section == 2 then
					section = {
						"",
						section[1],
						section[2],
					}
				end

				if #section[3] > 0 then
					names = "- " .. table.concat(section[3], "\n- ")
				else
					names = ""
				end

				description_image = Image.String(
					description_font, 
					description_color, 
					column_width_without_margins, 
					section[2], 
					Justify.Left
				)

		 		section_image = Image.StackVertical({
		 			Image.String(
		 				subheader_font, 
						subheader_color, 
						column_width_without_margins, 
						section[1], 
						Justify.Left
					),
					description_image,
					whitespace(10),
					Image.String(
		 				names_font, 
						names_color, 
						column_width_without_margins, 
						names, 
						Justify.Left
					),
				})

				sections[#sections+1] = section_image
			end
			column_image = Image.StackVertical(sections, 20)

			columns[#columns+1] = Image.Translate(column_image, Point.Create((column_index_onebased-1) * column_width_with_margins, 0))
		end
		return columns
	end

	function render_libs(data_libs)
		rows = {}
		for index_onebased, lib in pairs(data_libs) do

			if lib["License"] ~= nil then

				function create_license_image()
					return Image.String(
		 				names_font, 
						names_color, 
						500, 
						lib["License"], 
						Justify.Left
					)
				end

				local license_button = Popup.create_simple_text_button("Show license", 12)

				local license_popup_window = Popup.create_popup_window(Image.Lazy(create_license_image))
				local license_popup = context.create_popup(license_popup_window.image)

				license_popup.add_open_source(license_button.event_click)
				license_popup.add_close_source(license_popup_window.close_source)

				license_link = license_button.image
			else
				license_link = Image.Empty()
			end

	 		row_image = Image.StackVertical({
	 			Image.String(
	 				names_font, 
					names_color, 
					total_width,
					lib["Name"], 
					Justify.Left
				),
				license_link,
			})

			rows[#rows+1] = row_image
		end

		return Image.StackVertical(rows, 20)
	end

	function create_introduction_from_data(data)
		return Image.StackVertical({
			Image.String(
				header_font, 
				header_color, 
				total_width, 
				data["Title"], 
				Justify.Left
			),
			Image.String(
				description_font, 
				description_color, 
				total_width, 
				data["Description"], 
				Justify.Left
			)
		})
	end

	return Image.Group({
		Image.StackVertical({
			-- FreeAllegiance
			create_introduction_from_data(data),
			whitespace(20),
			Image.Group(create_columns_from_data(data)),
			whitespace(50),

			-- Microsoft
			create_introduction_from_data(data_ms),
			whitespace(20),
			Image.Group(create_columns_from_data(data_ms)),
			whitespace(50),

			-- 3rd party libs
			Image.String(
				header_font, 
				header_color, 
				total_width, 
				"Code projects used by Allegiance", 
				Justify.Left
			),
			Image.String(
				description_font, 
				description_color, 
				total_width, 
				"", 
				Justify.Left
			),
			whitespace(20),
			render_libs(data_libs),
		}),
	})
end

return {
	create=create
}