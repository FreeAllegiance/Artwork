button_script = File.LoadLua("button/button.lua")
Button = button_script()
G = File.LoadLua("global/global.lua")()

stage= Screen.GetState("Login state")

introscreenversion = "introscreen alpha v0.04 "
resolution = Screen.GetResolution()
xres = Point.X(resolution)
yres = Point.Y(resolution)

-- declare recurring variables used by multiple functions
	button_width = 144  -- used below and in Render_list()
	button_normal_color 	= G.white
	button_hover_color 	= Color.Create(1, 1, 1, 0.9)
	button_selected_color = Color.Create(1,1,1)
	button_shadow_color = Color.Create(0.4,0.4,0.4,0.6)	
	stageset = stageset

 -- declare recurring variables outside of function
	introscreenfont = G.h1
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
	buttonversion = "" -- this will hold the version of the button function
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

	function create_hovertextimg(str)
		return Image.String(G.h2, G.white, Number.Divide(xres,2), hovertext, Justify.Center)
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

-------     INTROSCREEN --------
----------------------------------------------
--[[
Stageset is the data associated with the current login stage
from it you can get data that is only available when you are in that state.
The "Logged out" state currently has two values: An event sink to start the login process and whether or not there was an error (set to "Yes" if a previous login failed)
The "Logging in" state contains data about the current step in the login process
and "Logged in" contains the serverlist - used in the gamescreen function.
]]

function make_introscreen(stageset)

	function create_button_list()
		list = {}
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.exit"), Image.File("menuintroscreen/images/introBtnExit.png"), "EXIT", "Exit the game.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.options"), Image.File("menuintroscreen/images/introBtnSettings.png"), "OPTIONS", "Change your graphics, audio and game settings.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.training"), Image.File("menuintroscreen/images/introBtnHelp.png"), "TRAINING", "Learn how to play the game.")
	--	list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://www.freeallegiance.org/forums/"), "Website")
	--	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.help"), "menuintroscreen/images/introBtnHelp.png", "HELP")
		list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://discord.gg/WcEJ9VH"), Image.File("menuintroscreen/images/introBtnDiscord.png"), "DISCORD", "Join the community Discord server.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.lan"), Image.File("menuintroscreen/images/introBtnLan.png"), "LAN", "Play on a Local Area Network.")
		list[#list+1] = create_mainbutton(stageset:GetEventSink("Login sink"), Image.File("menuintroscreen/images/introBtnOnline.png"), "PLAY ONLINE", "Play Allegiance.")
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

	logo = Image.Group({ 
			Image.Justify(
				Image.Multiply(Image.File("menuintroscreen/images/menuintroscreen_logo.png"),G.white),
				Point.Create(278,78), 
				Justify.Topright
				),
			})
	
	function errortextImg() 
		return Image.Switch(
			stageset:GetState("Has error"), {
				["No"] = function(stageset) return Image.Empty() end,
				["Yes"] = function (stageset)
						errMsg = stageset:GetString("Message") 
						errimg = Image.String(G.h2, G.white, Number.Divide(xres,2), errMsg, Justify.Center)
						return errimg
					end,
			})
	end
	return Image.Group({
		Image.Translate(Image.Justify(create_buttonbar(), resolution, Justify.Bottom), Point.Create(0,-50)),
		Image.Justify(logo, resolution,Justify.Center),
		Image.Translate(Image.Justify(errortextImg(), resolution, Justify.Bottom),Point.Create(0, -300)),
		Image.Translate(Image.Justify(create_hovertextimg(hovertext), resolution, Justify.Bottom),Point.Create(0, -200)),
		Image.Justify(Image.String(Font.Create("Verdana",12), button_normal_color, 300, String.Concat(buttonversion, introscreenversion), Justify.Right), resolution, Justify.Topright),
	})
end



---------------------- Connecting   ----------------
----------------------------------------------------------------------------------------------------------------------------------
function make_spinner(stageset)
	spinnerpoint = Point.Create(136,136) -- roughly the size of the diagonal of the spinner image. 
	spinner = Image.Group({
		Image.Extent(spinnerpoint, G.transparent),
		Image.Justify(Image.Multiply(Image.File("menuintroscreen/images/spinner_aleph.png"),G.white), spinnerpoint, Justify.Center),
		Image.Justify(Image.Rotate(Image.Multiply(Image.File("menuintroscreen/images/spinner.png"),G.white), Number.Multiply(Screen.GetNumber("time"), 3.14)), spinnerpoint, Justify.Center),
		})

stepMsg = stageset:GetString("Step message")
stepMsgImg = Image.String(G.h2, G.white, Number.Divide(xres,2), stepMsg, Justify.Center)

	return Image.Group({
		Image.Justify(spinner, resolution,Justify.Center),
		--spinner,
		Image.Translate(Image.Justify(stepMsgImg, resolution, Justify.Bottom),Point.Create(0, -300)),
		})
end

--------------- GAME SCREEN --------------------------
------------------------------------------------------
function make_gamescreen(stageset)
	cardwidth = 330
	cardheight = 360
	gamecard_bg = G.create_backgroundpane(cardwidth, cardheight)
	margin = 50
	cardsarea = Number.Subtract(xres,Number.Multiply(margin,2))
	--calculate the number of cards that fit into a horizontal row on the screen
	cardsrowlen = Number.Divide(cardsarea,cardwidth)
	-- and round down by subtracting the Modulo.
	cardsrowlen = Number.Subtract(cardsrowlen,Number.Mod(cardsrowlen,1))


	image_serverlist = Image.Group(
		List.MapToImages(
			stageset:GetList("Server list"),
			function (server, index) -- index is 0 based
				gamecard = Image.Group({
					gamecard_bg,	
					Image.String(
						G.h1, 
						G.white, 
						Number.Subtract(cardwidth, 30), 
						server:GetString("Name"), 
						Justify.Center
					),
					Image.String(
						G.h2, 
						G.white, 
						Number.Subtract(cardwidth, 30), 
						Number.ToString(server:GetNumber("Player count")), 
						Justify.Center
					),

				})
				return Image.Translate(
					gamecard, 
					Point.Create(
						Number.Multiply(index, 375), 
						0
					)
				)
			end
		)
	)
	
	gamescreen = Image.Group({
			image_serverlist,
		})

	return gamescreen
end	


---- background image --------
-- combine background image and logo
function make_background()
	bgimageuncut = Image.Group({
		Image.File("menuintroscreen/images/menuintroscreen_bg.jpg"),
		--Image.File("menuintroscreen/images/tempalignmentbg.png"),
	 })
	-- calculate how much of the edges need to be trimmed to fit the resolution
	xbgcutout = Number.Min(xres,1920) -- less than or equal to 1920
	ybgcutout = Number.Min(yres,1080) -- less than or equal to 1080
	xbgoffset = Number.Divide(Number.Subtract(1920, xbgcutout),2)
	ybgoffset = Number.Divide(Number.Subtract(1080, ybgcutout),2)
	bgimagefileRect = Rect.Create(xbgoffset,ybgoffset, Number.Add(xbgoffset, xbgcutout), Number.Add(ybgoffset, ybgcutout))
	-- trim the background image to size
	return Image.Cut(bgimageuncut, bgimagefileRect)
end

---------------------- Final Screen Switch Section ---------

stagescreen = Image.Switch(
	stage,{
	["Logged out"]=make_introscreen,
	["Logging in"]=make_spinner,
	["Logged in"]=make_gamescreen,
	})

return Image.Group({
	Image.ScaleFill(make_background(), resolution, Justify.Center), -- we use the same background image for all of them.
	stagescreen,
	})
