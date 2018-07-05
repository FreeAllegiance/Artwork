
Colors = File.LoadLua("global/colors.lua")()

spinner_color = Color.Create(0.9, 0.9, 1, 0.8)

spinnerpoint = Point.Create(136,136) -- roughly the size of the diagonal of the spinner image. 
spinner = Image.Group({
	Image.Extent(spinnerpoint, Colors.transparent),
	Image.Justify(Image.Multiply(Image.File("menuintroscreen/images/spinner_aleph.png"),spinner_color), spinnerpoint, Justify.Center),
	Image.Justify(Image.Rotate(Image.Multiply(Image.File("menuintroscreen/images/spinner.png"),spinner_color), Number.Multiply(Screen.GetNumber("time"), 3.14)), spinnerpoint, Justify.Center),
	})

return spinner