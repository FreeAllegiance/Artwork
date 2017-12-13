--fonts
Global = File.LoadLua("global/global.lua")()

function Scaled(fontname, size, options)
	options = options or {}
	Ltd_size = Number.Clamp(8, 25, Number.Round(size))
	b_bold = options.Bold or false
	b_italic = options.Italic or false
	b_underline = options.Underline or false 
	return Font.Create(fontname, Ltd_size, {Bold=b_bold, Italic=b_italic, Underline=b_underline})
end	


return {
	p = 	Font.Create("Trebuchet MS", 18),
	pbold =	Font.Create("Trebuchet MS", 18, {Bold=true}),
	h1 = 	Font.Create("Trebuchet MS", 25, {Bold=true}),
	h2 = 	Font.Create("Trebuchet MS", 23, {Italic=true, Bold=true}),
	h3 = 	Font.Create("Trebuchet MS", 21, {Bold=true}),
	h4 = 	Font.Create("Trebuchet MS", 19, {Bold=true}),
	Scaled = Scaled,
}
	