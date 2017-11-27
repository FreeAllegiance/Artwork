button_script = File.LoadLua("button/button.lua")
Button = button_script()
Global = File.LoadLua("global/global.lua")()

introscreenversion = "introscreen alpha v0.03 "

-------     INTROSCREEN --------
--------------------------------------------------------------------------------------------------------------------------
-- declare recurring variables used by multiple functions
	button_width = 144  -- used below and in Render_list()
	button_normal_color 	= Global.white
	button_hover_color 	= Color.Create(1, 1, 1, 0.9)
	button_selected_color = Color.Create(1,1,1)
	button_shadow_color = Color.Create(0.4,0.4,0.4,0.6)	

 -- declare recurring variables outside of function
	introscreenfont = Global.h1
	label_justification 	= Justify.Center
	function create_stringimages(label)
		return {
			normal = Image.String(introscreenfont, button_normal_color, button_width, label, Justify.Center),
			shadow = Image.String(introscreenfont, button_shadow_color, button_width, label, Justify.Center),
			hover = Image.String(introscreenfont, button_hover_color, button_width, label, Justify.Center),
			selected = Image.String(introscreenfont, button_selected_color, button_width, label, Justify.Center),
		}
	end

-- declare recurring variables outside of function
mainbtn_bg1 = Image.File("menuintroscreen/images/introBtn_border.png")
btnimage_position = Point.Create(0,0)
btntxt_pt = Point.Create(0,72)
btntxtshadow_pt = Point.Create(0,73)
hovertext = "" -- this will hold the eventual text for other functions to use
buttonversion = "text" -- this will hold the version of the button function
function create_mainbutton(event_sink, argimage, arglabel, arghovertext)
	label = create_stringimages(arglabel)
	image_n = Image.Group({
		Image.Translate(Image.Multiply(argimage, button_normal_color),btnimage_position),
		Image.Translate(label.shadow, btntxtshadow_pt),
		Image.Translate(label.normal, btntxt_pt), 
		})	
	image_h = Image.Group({
			Image.Translate(Image.Multiply(mainbtn_bg1, button_hover_color),btnimage_position),
			Image.Translate(Image.Multiply(argimage, button_hover_color),btnimage_position),
			Image.Translate(label.shadow, btntxtshadow_pt),
			Image.Translate(label.hover, btntxt_pt),
		})
	-- selected doesnt need color multiply. 
	image_s = Image.Group({
			Image.Translate(mainbtn_bg1,btnimage_position),
			Image.Translate(argimage,btnimage_position),
			Image.Translate(label.shadow, btntxtshadow_pt),
			Image.Translate(label.hover, btntxt_pt),		
		})
	button = Button.create_image_button(image_n, image_h, image_s, arghovertext)
	hovertext = String.Concat(hovertext, button.btnhovertext) --[[ concatenates the hoverstring with the contents of the toplevel one. Since there's only one 	non-empty string we should wind up with only the text for the button currently hovered over... ]]
	buttonversion = button.version
	Event.OnEvent(event_sink, button.events.click)
	return button.image
end

function create_button_list()
	list = {}
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.exit"), Image.File("menuintroscreen/images/introBtnExit.png"), "EXIT", "Exit the game.")
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.options"), Image.File("menuintroscreen/images/introBtnSettings.png"), "OPTIONS", "Change your graphics, audio and game settings.")
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.training"), Image.File("menuintroscreen/images/introBtnHelp.png"), "TRAINING", "Learn how to play the game.")
--	list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://www.freeallegiance.org/forums/"), "Website")
--	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.help"), "menuintroscreen/images/introBtnHelp.png", "HELP")
	list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://discord.gg/WcEJ9VH"), Image.File("menuintroscreen/images/introBtnDiscord.png"), "DISCORD", "Join the community Discord server.")
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.lan"), Image.File("menuintroscreen/images/introBtnLan.png"), "LAN", "Play on a Local Area Network.")
	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.lobby"), Image.File("menuintroscreen/images/introBtnOnline.png"), "PLAY ONLINE", "Play Allegiance.")
	return list
end

function render_list(list)
	translated_list = {}
	offset = button_width+56 -- this number indicates the spaces between buttons
	offset_x = #list * offset
	for i, item in pairs(list) do
		offset_x = offset_x - offset
		translated_list[#translated_list+1] = Image.Translate(item, Point.Create(offset_x, 0))
	end

	return Image.Group(translated_list)
end

function create_hovertextimg(str)
	strimg = Image.String(Global.h2, button_normal_color, Number.Divide(xres,2), hovertext, Justify.Center)
	return Image.Translate(Image.Justify(strimg, resolution, Justify.Bottom),Point.Create(0, -200))
end

function create_buttonbar()
	bbimg = render_list(create_button_list())  -- compile the Button Bar (BB) image
	bbs = Image.Size(bbimg) -- get BB size as a point value
	bbx = Point.X(bbs) -- get BB width as a point val x coordinate
	bby = Point.Y(bbs) -- get BB height as a point val y coordinate
	fctr = Number.Min(1, Number.Divide(Number.Multiply(0.95,xres),bbx)) -- if smaller than 1, return ratio of the horizontal resolution and the Button Bar width.
	bbres = Point.Create(Number.Multiply(bbx, fctr), Number.Multiply(bby, fctr)) -- 
	return Image.ScaleFill(bbimg, bbres, Justify.Center)
end

resolution = Screen.GetResolution()
xres = Point.X(resolution)
yres = Point.Y(resolution)

logo = Image.Group({ 
		Image.Justify(
			Image.Multiply(Image.File("menuintroscreen/images/menuintroscreen_logo.png"),Global.white),
			Point.Create(278,78), 
			Justify.Topright
			),
		})


menuintroscreen = Image.Group({
	Image.Translate(Image.Justify(create_buttonbar(), resolution, Justify.Bottom), Point.Create(0,-50)),
	--Image.Justify(spinner, resolution,Justify.Center),
	Image.Justify(logo, resolution,Justify.Center),
	create_hovertextimg(hovertext),
	Image.Justify(
		Image.String(Global.p, button_normal_color, 300, String.Concat(buttonversion, introscreenversion),Justify.Right), 
		resolution, 
		Justify.Topright
	),
})


---------------------- Connecting   ----------------
----------------------------------------------------------------------------------------------------------------------------------

spinnerpoint = Point.Create(136,136) -- roughly the size of the diagonal of the spinner image. 
spinner = Image.Group({
	Image.Extent(spinnerpoint, Global.transparent),
	Image.Justify(Image.Multiply(Image.File("menuintroscreen/images/spinner_aleph.png"),Global.white), spinnerpoint, Justify.Center),
	Image.Justify(Image.Rotate(Image.Multiply(Image.File("menuintroscreen/images/spinner.png"),Global.white), Number.Multiply(Screen.GetNumber("time"), 3.14)), spinnerpoint, Justify.Center),
	})


menuconnecting = Image.Group({
	Image.Justify(spinner, resolution,Justify.Center),
	spinner,
	})


---- background image --------
-- combine background image and logo
bgimageuncut = Image.File("menuintroscreen/images/menuintroscreen_bg.jpg")
-- calculate how much of the edges need to be trimmed to fit the resolution
xbgcutout = Number.Min(xres,1920) -- less than or equal to 1920
ybgcutout = Number.Min(yres,1080) -- less than or equal to 1080
xbgoffset = Number.Divide(Number.Subtract(1920, xbgcutout),2)
ybgoffset = Number.Divide(Number.Subtract(1080, ybgcutout),2)
bgimagefileRect = Rect.Create(xbgoffset,ybgoffset, Number.Add(xbgoffset, xbgcutout), Number.Add(ybgoffset, ybgcutout))
-- trim the background image to size
bgimage = Image.Cut(bgimageuncut, bgimagefileRect)



---------------------- Final Screen Switch Section ---------

-- this is where the stage connection logic goes. ----

stage= 1


--- this switches between the different interfaces based on where we are according to stage variable. -- 

export_image = Image.Switch(
	stage,{
	[1]=menuintroscreen,
	[2]=menuconnecting,
	[3]=menugameselect,
	[4]=menulangame,
	[5]=menuconnectionerror,
	[6]=menuoptions,  -- this would be an external lua file.
	[7]=menuquit,
	},
	1)

return Image.Group({
	Image.ScaleFill(bgimage, resolution, Justify.Center), -- we use the same background image for all of them.
	export_image,
	})
