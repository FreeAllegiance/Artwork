Button = File.LoadLua("button/button.lua")()
Global = File.LoadLua("global/global.lua")()
introscreenversion = "introscreen alpha v0.04 "
stage= Screen.GetState("Login state")

-------------------------------------------------------
--[[ SUPER IMPORTANT OBJECT --- 
Loginstate_container will hold the data associated with the current login stage
from it you can get data that is only available when you are in that state.
The "Logged out" state currently has two values: An event sink to start the login process and whether or not there was an error (set to "Yes" if a previous login failed)
The "Logging in" state contains data about the current step in the login process
and "Logged in" contains the serverlist - used in the gamescreen function. 

]]
Loginstate_container = Loginstate_container
------------------------------------------------------------------

resolution = Screen.GetResolution()
xres = Point.X(resolution)
yres = Point.Y(resolution)

-- declare recurring variables used by multiple functions
	button_width = 144  -- used below and in render_list()
	button_normal_color = Global.color.white
	button_hover_color 	= Color.Create(0.9, 0.9, 1, 0.9)
	button_selected_color = Color.Create(1,1,0.9, 0.95)
	button_shadow_color = Color.Create(0.4,0.4,0.4,0.6)	
	stageset = stageset

	logo = Image.Group({ 
	Image.Justify(
		Image.Multiply(Image.File("menuintroscreen/images/menuintroscreen_logo.png"),Global.color.white),
		Point.Create(278,78), 
		Justify.Topright
		),
	})

 -- declare recurring variables outside of function
	introscreenfont = Global.font.h1
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
		return Image.String(Global.font.h2, Global.color.white, Number.Divide(xres,2), hovertext, Justify.Center)
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

	function create_buttonbar(btnlist)
		bbimg = render_list(btnlist)  -- compile the Button Bar (BB) image
		bbs = Image.Size(bbimg) -- get BB size as a point value
		bbx = Point.X(bbs) -- get BB width as a point val x coordinate
		bby = Point.Y(bbs) -- get BB height as a point val y coordinate
		fctr = Number.Min(1, Number.Divide(Number.Multiply(0.95,xres),bbx)) -- if smaller than 1, return ratio of the horizontal resolution and the Button Bar width.
		bbres = Point.Create(Number.Multiply(bbx, fctr), Number.Multiply(bby, fctr)) -- 
		return Image.ScaleFill(bbimg, bbres, Justify.Center)
	end

-------     INTROSCREEN --------
----------------------------------------------


function make_introscreen(Loginstate_container)

	function create_button_list()
		list = {}
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.exit"), Image.File("menuintroscreen/images/introBtnExit.png"), "EXIT", "Exit the game.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.options"), Image.File("menuintroscreen/images/introBtnSettings.png"), "OPTIONS", "Change your graphics, audio and game settings.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.training"), Image.File("menuintroscreen/images/introBtnHelp.png"), "TRAINING", "Learn how to play the game.")
	--	list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://www.freeallegiance.org/forums/"), "Website")
	--	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.help"), "menuintroscreen/images/introBtnHelp.png", "HELP")
		list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://discord.gg/WcEJ9VH"), Image.File("menuintroscreen/images/introBtnDiscord.png"), "DISCORD", "Join the community Discord server.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.lan"), Image.File("menuintroscreen/images/introBtnLan.png"), "LAN", "Play on a Local Area Network.")
		list[#list+1] = create_mainbutton(Loginstate_container:GetEventSink("Login sink"), Image.File("menuintroscreen/images/introBtnOnline.png"), "PLAY ONLINE", "Play Allegiance.")
	--	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.lobby"), Image.File("menuintroscreen/images/introBtnOnline.png"), "PLAY ONLINE", "Play Allegiance.")
		return list
	end

	function errortextImg() 
		return Image.Switch(
			Loginstate_container:GetState("Has error"), {
				["No"] = function(Loginstate_container) return Image.Empty() end,
				["Yes"] = function (Loginstate_container)
						errMsg = Loginstate_container:GetString("Message") 
						errimg = Image.String(Global.font.h2, Global.color.white, Number.Divide(xres,2), errMsg, Justify.Center)
						return errimg
					end,
			})
	end
	
	return Image.Group({
		Image.Translate(Image.Justify(create_buttonbar(create_button_list()), resolution, Justify.Bottom), Point.Create(0,-30)),
		Image.Justify(logo, resolution,Justify.Center),
		Image.Translate(Image.Justify(errortextImg(), resolution, Justify.Bottom),Point.Create(0, -300)),
		Image.Translate(Image.Justify(create_hovertextimg(hovertext), resolution, Justify.Bottom),Point.Create(0, -150)),
		Image.Justify(Image.String(Font.Create("Verdana",12), button_normal_color, 300, String.Concat(buttonversion, introscreenversion), Justify.Right), resolution, Justify.Topright),
	})
end


--------------- GAME SCREEN --------------------------
------------------------------------------------------
function make_gamescreen(stageset)
	cardwidth = 330
	cardheight = 360
	xmargin = 75
	xcardsarea = Number.Subtract(xres,Number.Multiply(xmargin,2))
	ycardsarea = Number.Subtract(yres,Number.Add(150,170))
	cardsarea = Point.Create(xcardsarea,ycardsarea)
	cardsinnermargin = 15
	cardsoutermargin = 10
	--calculate the number of cards that fit into a horizontal row on the screen
	cardsrowlen = Number.Divide(xcardsarea, Global.list_sum({cardwidth,cardsoutermargin,cardsoutermargin}))
	-- and round down by subtracting the Modulo.
	cardsrowlen = Number.Subtract(cardsrowlen,Number.Mod(cardsrowlen,1))
	hovertext = "" 
	callback = ""
	-------- temp bogus data

---------------------- Connecting   ----------------
----------------------------------------------------------------------------------------------------------------------------------
function make_spinner(Loginstate_container)
	spinnerpoint = Point.Create(136,136) -- roughly the size of the diagonal of the spinner image. 
	spinner = Image.Group({
		Image.Extent(spinnerpoint, Global.color.transparent),
		Image.Justify(Image.Multiply(Image.File("menuintroscreen/images/spinner_aleph.png"),Global.color.white), spinnerpoint, Justify.Center),
		Image.Justify(Image.Rotate(Image.Multiply(Image.File("menuintroscreen/images/spinner.png"),Global.color.white), Number.Multiply(Screen.GetNumber("time"), 3.14)), spinnerpoint, Justify.Center),
		})

stepMsg = Loginstate_container:GetString("Step message")
stepMsgImg = Image.String(Global.font.h2, Global.color.white, Number.Divide(xres,2), stepMsg, Justify.Center)

	return Image.Group({
		Image.Justify(spinner, resolution,Justify.Center),
		--spinner,
		Image.Translate(Image.Justify(stepMsgImg, resolution, Justify.Bottom),Point.Create(0, -150)),
		})
end

--------------- GAME SCREEN --------------------------
------------------------------------------------------
function make_gamescreen(Loginstate_container)
	cardwidth = 250
	cardheight = 280
	xmargin = Number.Round(Number.Multiply(xres,0.04), 0)
	ytopmargin = 100 --Number.Round(Number.Multiply(yres,0.10),0)
	ybottommargin = 180
	xcardsarea = xres-(2*xmargin) -- Number.Subtract(xres,Global.list_sum({xmargin, xmargin}))
	ycardsarea = yres-(ybottommargin+ytopmargin) -- Number.Subtract(yres,Number.Add(ybottommargin,ytopmargin))
	cardsarea = Point.Create(xcardsarea,ycardsarea)
	cardsinnermargin = 15
	cardsoutermargin = 10
	--calculate the number of cards that fit into a horizontal row on the screen
	cardsrowlen = xcardsarea/(cardwidth+cardsoutermargin+cardsoutermargin)
	-- and round down by subtracting the Modulo.
	cardsrowlen = Number.Subtract(cardsrowlen,Number.Mod(cardsrowlen,1))
	hovertext = "" 
	callback = ""
	-------- temp bogus data

	function write(str,fnt,c)
		font = Global.font.p or fnt
		color = c or Global.color.white
		return Image.String(font, color, Number.Subtract(cardwidth, Number.Multiply(cardsinnermargin,2)), str, Justify.Center)
	end 

	function pos(img, x,y)
		return Image.Translate(img, Point.Create(x,y))
	end	
	games_container = Loginstate_container:GetList("Server list")
	cardslistImg = Image.Group(
		List.MapToImages(
			games_container,
			function (game, i)
				row = Number.Divide(i,Number.Add(cardsrowlen,0.00001))
				row = Number.Subtract(row, Number.Mod(row,1))
				col = Number.Subtract(Number.Subtract(i, Number.Multiply(row, cardsrowlen)), 1)
				posx = Number.Multiply(col,Global.list_sum({cardwidth, cardsoutermargin, cardsoutermargin}))
				posy = Number.Multiply(row,Global.list_sum({cardheight, cardsoutermargin, cardsoutermargin}))

				gamename = game:GetString("Name")
				gameplayercount = Number.ToString(game:GetNumber("Player count"))
				gamenoat =  Number.ToString(game:GetNumber("Player noat count"))			
				gametime = Number.ToString(game:GetNumber("Time in progress"))
				gameserver = game:GetString("Server name")
				gamestatus = String.Switch(
					game:GetBool("Is in progress"),{
					[true]="In Progress", 
					[false]="Building Teams",
				})
				gamestate = Global.list_concat({gamestatus, "-", gametime, " ", gameplayercount,"/", gamenoat})
				
				lst = {}
				lst["CONQUEST"] = game:GetBool("Has goal conquest")
				lst["TERRITORY"] = game:GetBool("Has goal territory")
				lst["PROSPERITY"] = game:GetBool("Has goal prosperity")
				lst["ARTIFACTS"] = game:GetBool("Has goal artifacts")
				lst["FLAGS"] = game:GetBool("Has goal flags")
				lst["DEATHMATCH"] = game:GetBool("Has goal deathmatch")
				lst["COUNTDOWN"] = game:GetBool("Has goal countdown")
				function findtruegamestyle()
					bools = {}
					for stylename, bool in ipairs(lst) do
						bools[bool] = stylename -- we don't care about the false values, just the one true value
					end 
					return bools[true] 
				end
				
				gamestyle = String.Switch(
					Number.Min(Boolean.Count(lst),2),{
					[0] = "UNKNOWN", 
					[1] = findtruegamestyle(),
					[2] = "CUSTOM GAME",
					}
				)

				function makegamecardface(cardcolor) 
					return Image.Group({
					Global.create_backgroundpane(cardwidth, cardheight, {color=cardcolor}),	
					pos(write(gamestyle, Global.font.h1, cardcolor),0,10),
					pos(write(gamestate, Global.font.h4, cardcolor),0,35), 
					pos(write(gamename, Global.font.h3, cardcolor),0,60),
					})
				end

				joinbtn_n = makegamecardface(button_normal_color)
				joinbtn_h = makegamecardface(button_hover_color)
				joinbtn_s = makegamecardface(button_selected_color)

				card = Button.create_image_button(joinbtn_n, joinbtn_h, joinbtn_s, "Connect To This Game Lobby And Join This Game")
				hovertext = String.Concat(hovertext, card.btnhovertext) --concatenates the hoverstring with the contents of the toplevel one.
				Event.OnEvent(game:GetEventSink("Join sink"), card.events.click)
				return  pos(card.image,posx,posy) 
			end	
		)
	)
	doWeNeedaScrollbar = Number.Min(Number.Max(0,Number.Subtract(Point.Y(Image.Size(cardslistImg)),ycardsarea)),1)
	gamecards = Image.Group({
		Image.Extent(cardsarea, Global.color.transparent),
		Image.Switch(
			doWeNeedaScrollbar, --if the vertical size of the cardimage < cardsarea (if it fits) return 0, otherwise return 1,
			{
			[0] = Image.Justify(cardslistImg,cardsarea, Justify.Top), -- then just show the cardsimage, else 
			[1] = Global.create_vertical_scrolling_container(
					Image.Justify(cardslistImg,cardsarea, Justify.Top),
					cardsarea
				)
			}), -- make a scrolling pane image
		})

	function create_button_list()
		list = {}
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.exit"), Image.File("menuintroscreen/images/introBtnExit.png"), "EXIT", "Exit the game.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.options"), Image.File("menuintroscreen/images/introBtnSettings.png"), "OPTIONS", "Change your graphics, audio and game settings.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.training"), Image.File("menuintroscreen/images/introBtnHelp.png"), "TRAINING", "Learn how to play the game.")
		list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://discord.gg/WcEJ9VH"), Image.File("menuintroscreen/images/introBtnDiscord.png"), "DISCORD", "Join the community Discord server.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.lobby"), Image.File("menuintroscreen/images/introBtnOnline.png"), "PLAY ONLINE", "Play Allegiance.")
		--list[#list+1] = create_mainbutton(Loginstate_container:GetEventSink("Login sink"), Image.File("menuintroscreen/images/introBtnOnline.png"), "PLAY ONLINE", "Play Allegiance.")
		return list
	end

	gamescreen = Image.Group({
			Image.Translate(Global.create_backgroundpane(Number.Add(xcardsarea, 40), Number.Add(ycardsarea,40), {color=Global.color.white}), Point.Create(xmargin-20, ytopmargin-20)),
			Image.Translate(gamecards, Point.Create(xmargin, ytopmargin)),
			--Image.Justify(pos(write(callback, Global.font.p),20,-20),resolution,Justify.Bottom),
			Image.Translate(Image.Justify(create_hovertextimg(hovertext), resolution, Justify.Bottom),Point.Create(0, -150)),
			Image.Translate(Image.Justify(create_buttonbar(create_button_list()), resolution, Justify.Bottom), Point.Create(0,-30)),
		})

	return gamescreen
end	


---- background image --------
-- combine background image and logo
function make_background()
	bgimageuncut = Image.File("menuintroscreen/images/menuintroscreen_bg.jpg")
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

