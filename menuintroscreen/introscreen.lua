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
	button_hover_color 	= Color.Create(0.9, 0.9, 1, 0.9)
	button_selected_color = Color.Create(1,1,0.9, 0.95)
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
	--	list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.lobby"), Image.File("menuintroscreen/images/introBtnOnline.png"), "PLAY ONLINE", "Play Allegiance.")
		return list
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
		Image.Translate(Image.Justify(create_buttonbar(create_button_list()), resolution, Justify.Bottom), Point.Create(0,-50)),
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
	xmargin = 10
	xcardsarea = Number.Subtract(xres,Number.Multiply(xmargin,2))
	cardsinnermargin = 15
	cardsoutermargin = 15
	--calculate the number of cards that fit into a horizontal row on the screen
	cardsrowlen = Number.Divide(xcardsarea, G.list_sum({cardwidth,cardsoutermargin,cardsoutermargin}))
	-- and round down by subtracting the Modulo.
	cardsrowlen = Number.Subtract(cardsrowlen,Number.Mod(cardsrowlen,1))
	hovertext = "" 
	callback = ""
	-------- temp bogus data

	function write(str,fnt,c)
		font = G.p or fnt
		color = c or G.white
		return Image.String(font, color, Number.Subtract(cardwidth, Number.Multiply(cardsinnermargin,2)), str, Justify.Center)
	end 

	function pos(img, x,y)
		return Image.Translate(img, Point.Create(x,y))
	end	
		-- bogus game data we can remove after real connection
	function gamedata()
		gamedata = {}
		gamedata[#gamedata+1] = {["Name"]="Wabbawabbit's Game", ["Player count"]=12, ["NoatWarriors"]=6, ["Server"]="Mach3", ["Style"]="CONQUEST", ["Status"]="In Progress", ["Time"]="0:35"}
		gamedata[#gamedata+1] = {["Name"]="MAIN US East Game", ["Player count"]=35, ["NoatWarriors"]=52, ["Server"]="AEast1", ["Style"]="CONQUEST", ["Status"]="Forging Teams", ["Time"]=""}
		gamedata[#gamedata+1] = {["Name"]="MAIN US WEST Game", ["Player count"]=102, ["NoatWarriors"]=0, ["Server"]="AWest1", ["Style"]="DEATHMATCH", ["Status"]="In Progress", ["Time"]="0:10"}
		gamedata[#gamedata+1] = {["Name"]="Wabbawabbit's Game", ["Player count"]=12, ["NoatWarriors"]=6, ["Server"]="Mach3", ["Style"]="CONQUEST", ["Status"]="In Progress", ["Time"]="0:35"}
		gamedata[#gamedata+1] = {["Name"]="MAIN US East Game", ["Player count"]=35, ["NoatWarriors"]=52, ["Server"]="AEast1", ["Style"]="CONQUEST", ["Status"]="Forging Teams", ["Time"]=""}
		gamedata[#gamedata+1] = {["Name"]="Wabbawabbit's Game", ["Player count"]=12, ["NoatWarriors"]=6, ["Server"]="Mach3", ["Style"]="CONQUEST", ["Status"]="In Progress", ["Time"]="0:35"}
		gamedata[#gamedata+1] = {["Name"]="MAIN US East Game", ["Player count"]=35, ["NoatWarriors"]=52, ["Server"]="AEast1", ["Style"]="CONQUEST", ["Status"]="Forging Teams", ["Time"]=""}
		gamedata[#gamedata+1] = {["Name"]="MAIN US WEST Game", ["Player count"]=102, ["NoatWarriors"]=0, ["Server"]="AWest1", ["Style"]="DEATHMATCH", ["Status"]="In Progress", ["Time"]="0:10"}
		gamedata[#gamedata+1] = {["Name"]="Wabbawabbit's Game", ["Player count"]=12, ["NoatWarriors"]=6, ["Server"]="Mach3", ["Style"]="CONQUEST", ["Status"]="In Progress", ["Time"]="0:35"}
		gamedata[#gamedata+1] = {["Name"]="MAIN US East Game", ["Player count"]=35, ["NoatWarriors"]=52, ["Server"]="AEast1", ["Style"]="CONQUEST", ["Status"]="Forging Teams", ["Time"]=""}
		return gamedata
	end
	
	games = gamedata() -- stageset:GetList("Server list")
	gamesn = 0
	for i in pairs(games) do gamesn = gamesn+1 end
	callback =""

	cardslist = {}
	for i, game in ipairs(games) do 
		row = Number.Divide(i,Number.Add(cardsrowlen,0.00001))
		row = Number.Subtract(row, Number.Mod(row,1))
		col = Number.Subtract(Number.Subtract(i, Number.Multiply(row, cardsrowlen)), 1)
		posx = Number.Multiply(col,cardwidth)
		posy = Number.Multiply(row,cardheight)
	-- broke this up into separate vars so it's easier to edit later
		gamename = game["Name"] --game:GetString("Name"),
		gamestyle = game["Style"]
		gameplayercount = Number.ToString(game["Player count"]) --game:GetString("Player count"),
		gamenoat =  Number.ToString(game["NoatWarriors"])
		gamestatus = game["Status"]
		gametime = game["Time"]
		gameserver = game["Server"]
		gamestate = G.list_concat({gamestatus, "-", gametime, " ", gameplayercount,"/", gamenoat})

		function makegamecardface(cardcolor) 
			gamecardface = Image.Group({
				G.create_backgroundpane(cardwidth, cardheight, {color=cardcolor}),	
				pos(write(gamestyle, G.h1, cardcolor),0,10),
				pos(write(gamestate, G.h4, cardcolor),0,35), 
				pos(write(gamename, G.h3, cardcolor),0,60),
			})
			return gamecardface
		end

		joinbtn_n = makegamecardface(button_normal_color)
		joinbtn_h = makegamecardface(button_hover_color)
		joinbtn_s = makegamecardface(button_selected_color)

		card = Button.create_image_button(joinbtn_n, joinbtn_h, joinbtn_s, "Connect To This Game Lobby And Join This Game")
		hovertext = String.Concat(hovertext, card.btnhovertext) --concatenates the hoverstring with the contents of the toplevel one.
		Event.OnEvent(Screen.GetExternalEventSink("open.lobby"), card.events.click)
		cardslist[#cardslist+1] = pos(card.image,posx,posy) 
	end
	gamecards = Image.Group(cardslist)

	function create_button_list()
		list = {}
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.exit"), Image.File("menuintroscreen/images/introBtnExit.png"), "EXIT", "Exit the game.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.options"), Image.File("menuintroscreen/images/introBtnSettings.png"), "OPTIONS", "Change your graphics, audio and game settings.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.training"), Image.File("menuintroscreen/images/introBtnHelp.png"), "TRAINING", "Learn how to play the game.")
		list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://discord.gg/WcEJ9VH"), Image.File("menuintroscreen/images/introBtnDiscord.png"), "DISCORD", "Join the community Discord server.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.lobby"), Image.File("menuintroscreen/images/introBtnOnline.png"), "PLAY ONLINE", "Play Allegiance.")
		--list[#list+1] = create_mainbutton(stageset:GetEventSink("Login sink"), Image.File("menuintroscreen/images/introBtnOnline.png"), "PLAY ONLINE", "Play Allegiance.")
		return list
	end

	gamescreen = Image.Group({
			gamecards,
			--Image.Justify(pos(write(callback, G.p),20,-20),resolution,Justify.Bottom),
			Image.Translate(Image.Justify(create_hovertextimg(hovertext), resolution, Justify.Bottom),Point.Create(0, -200)),
			Image.Translate(Image.Justify(create_buttonbar(create_button_list()), resolution, Justify.Bottom), Point.Create(0,-50)),
		})

	return gamescreen
end	


---- background image --------
-- combine background image and logo
function make_background()
	bgimageuncut = Image.Group({
		Image.File("menuintroscreen/images/menuintroscreen_bg.jpg"),
	--	Image.File("menuintroscreen/images/tempalignmentbg.png"),
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



-----
	---
	--[[	
	image_gamelist = Image.Group(
		List.MapToImages(
			stageset:GetList("Server list"),
			function (game, index) -- index is 0 based	
				button = Button.create_image_button(joinbtn_n, joinbtn_h, joinbtn_s, "Connect To This Game Lobby And Join This Game")
				hovertext = String.Concat(hovertext, button.btnhovertext) --concatenates the hoverstring with the contents of the toplevel one.
				Event.OnEvent(Screen.GetExternalEventSink("open.lobby"), button.events.click)
				
				gamestatus = G.list_concat({"Forging Teams - ", Number.ToString(5),"/", Number.ToString(10)}) -- Number.ToString(game:GetNumber("Playercount"))
				--gamestatus = String.Concat("Forging Teams - ", String.Concat(Number.ToString(5),"/")) -- Number.ToString(game:GetNumber("Playercount"))
				--gamestatus = String.Concat(gamestatus, ) Number.ToString(game:GetNumber("NoatWarriors"))
				gamecard = Image.Group({
					gamecard_bg,	
					pos(write("DEATHMATCH", G.h1),0,10), --game:GetString("Style"), 
					pos(write(gamestatus, G.h4),0,35), --game:GetString("Status"),
					pos(write("Bunnywabbit@DEV's Game", G.h3),0,60),--game:GetString("Name"),
					--Image.String(G.h2, G.white, Number.Subtract(cardwidth, 30), , Justify.Center),
					pos(Image.Justify(button.image,Point.Create(cardwidth,cardheight),Justify.Bottom),0,-30),
				})
				return pos(gamecard, Number.Multiply(index, 375), 0)
			end
		)
	)
]]
