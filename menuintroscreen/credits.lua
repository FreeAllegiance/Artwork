
data = File.LoadLua("menuintroscreen/credits_data.lua")()
Fonts = File.LoadLua("global/fonts.lua")()

header_font = Fonts.h1
description_font = Fonts.h4
names_font = Fonts.p

header_color = Color.Create(1, 1, 1)
description_color = Color.Create(1, 1, 1)
names_color = Color.Create(1, 1, 1)

columns = {}
for column_index_onebased, column in pairs(data.Columns) do 
	column_width_without_margins = 200
	column_width_with_margins = 250

	sections = {}
	for section_index_onebased, section in pairs(column) do

		names = "- " .. table.concat(section[3], "\n- ")

		description_image = Image.String(
			description_font, 
			description_color, 
			column_width_without_margins, 
			section[2], 
			Justify.Left
		)

 		section_image = Image.StackVertical({
 			Image.String(
 				header_font, 
				header_color, 
				column_width_without_margins, 
				section[1], 
				Justify.Left
			),
			description_image,
			Image.Extent(Point.Create(0, 10), Color.Create(0,0,0,0)),
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

return Image.StackVertical({
	Image.String(
		header_font, 
		header_color, 
		column_width_without_margins, 
		"FreeAllegiance", 
		Justify.Left
	),
	Image.String(
		description_font, 
		description_color, 
		column_width_without_margins, 
		"The community\nblabla\nwe are important", 
		Justify.Left
	),
	Image.Extent(Point.Create(0, 20), Color.Create(0,0,0,0)),
	Image.Group(columns),
})