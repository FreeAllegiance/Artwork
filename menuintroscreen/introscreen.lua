Button = File.LoadLua("button/button.lua")()
Global = File.LoadLua("global/global.lua")()
Fonts = File.LoadLua("global/fonts.lua")()
Popup = File.LoadLua("global/popup.lua")()
introscreenversion = "introscreen alpha v0.05 "
stage= Screen.GetState("Login state")

-------------------------------------------------------
--[[ SUPER IMPORTANT OBJECT --- 
Loginstate_container will hold the data associated with the current login stage
from it you can get data that is only available when you are in that state.
The "Logged out" state currently has two values: An event sink to start the login process and whether or not there was an error (set to "Yes" if a previous login failed)
The "Logging in" state contains data about the current step in the login process
and "Logged in" contains the serverlist - used in the missionscreen function. 

]]
Loginstate_container = Loginstate_container
------------------------------------------------------------------

resolution = Screen.GetResolution()
xres = Point.X(resolution)
yres = Point.Y(resolution)
ScaleX = Number.Min(1.0,Number.Max(0.6, xres/1400))
ScaleY = Number.Min(1.0,Number.Max(0.6, yres/900))
UIScaleFactor = Number.Min(ScaleX, ScaleY)
callback = Number.ToString(UIScaleFactor*1000)
-- declare recurring variables used by multiple functions
button_width = 200  -- used below and in render_list()
button_normal_color = Color.Create(0.9, 0.9, 1, 0.8)
button_hover_color 	= Color.Create(1, 0.9, 0.8, 0.8)
button_selected_color = Color.Create(1,1,0.9, 0.95)
button_shadow_color = Color.Create(0.4,0.4,0.4,0.7)	

logo = Image.Group({ 
Image.Justify(
	Image.Multiply(Image.File("menuintroscreen/images/menuintroscreen_logo.png"),Global.color.white),
	Point.Create(278,78), 
	Justify.Topright
	),
})

function create_stringimages(label)
	return {
		normal = Image.String(Fonts.h1, button_normal_color, label, {Width=200, Justification=Justify.Center}),
		shadow = Image.String(Fonts.h1, button_shadow_color, label, {Width=200, Justification=Justify.Center}),
		hover = Image.String(Fonts.h1, button_hover_color, label, {Width=200, Justification=Justify.Center} ),
		selected = Image.String(Fonts.h1, button_selected_color, label, {Width=200, Justification=Justify.Center}),
	}
end
-- declare recurring variables outside of function
mainbtn_bg1 = Image.File("menuintroscreen/images/introBtn_border.png")
--btnimage_position = Point.Create(0,0)
hovertext = "" -- this will hold the eventual text for other functions to use
function create_mainbutton(event_sink, argimage, arglabel, arghovertext)
	argimageheight = Point.Y(Image.Size(argimage))
	label = create_stringimages(arglabel)
	btnsize = Point.Create(button_width, argimageheight+25+1) -- 25 is 25px height of h1 font, 1px is for text shadow offset.
	image_n = Image.Group({
		Image.Justify(Image.Multiply(argimage, button_normal_color),btnsize, Justify.Top),
		Image.Justify(Image.Group({
			Image.Translate(label.shadow, Point.Create(1,1)),
			label.normal,
		}), btnsize, Justify.Bottom),
	})
	image_h = Image.Group({
		Image.Justify(Image.Multiply(mainbtn_bg1, button_hover_color),btnsize, Justify.Top),
		Image.Justify(Image.Multiply(argimage, button_hover_color),btnsize, Justify.Top),
		Image.Justify(Image.Group({
			Image.Translate(label.shadow, Point.Create(1,1)),
			label.hover,
			}), 
		btnsize, Justify.Bottom)
	})
	-- selected doesnt need color multiply. 
	image_s = Image.Group({
			Image.Justify(mainbtn_bg1, btnsize, Justify.Top),
			Image.Justify(argimage, btnsize, Justify.Top),
		Image.Justify(Image.Group({
			Image.Translate(label.shadow, Point.Create(1,1)),
			label.selected,
			}), 
		btnsize, Justify.Bottom)
	})		
	button = Button.create_image_button(image_n, image_h, image_s, arghovertext)
	hovertext = String.Concat(hovertext, button.btnhovertext) --[[ concatenates the hoverstring with the contents of the toplevel one. Since there's only one 	non-empty string we should wind up with only the text for the button currently hovered over... ]]
	Event.OnEvent(event_sink, button.events.click)
	return button.image
end

function create_hovertextimg(str)
	return Image.String(Fonts.h2, Global.color.white, Number.Divide(xres,2), hovertext, Justify.Center)
end

function render_list(list)
	translated_list = {}
	offset = button_width -- this number indicates the spaces between buttons
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
	fctr = Number.Min(1, (0.5*xres)/bbx) -- if smaller than 1, return ratio of the horizontal resolution and the Button Bar width.
	bbres = Point.Create(Number.Multiply(bbx, fctr), Number.Multiply(bby, fctr)) 
	btnbardiv = Point.Create(bbx*UIScaleFactor, bby*UIScaleFactor)
	-- old calc: bbres = Point.Create(Number.Multiply(bbx, fctr), Number.Multiply(bby, fctr))
	return Image.ScaleFill(bbimg, btnbardiv, Justify.Center)
end

-------     INTROSCREEN --------
----------------------------------------------


function create_credits_image()
	credits_image = File.LoadLua("menuintroscreen/credits.lua")()
	return credits_image
end

credits_popup = Popup.create_single_popup_manager(create_credits_image)
credits_button = Popup.create_simple_text_button("Credits", 14)

Event.OnEvent(credits_popup.get_is_open(), credits_button.event_click, function ()
	-- toggle
	return Boolean.Not(credits_popup.get_is_open())
end)


function make_introscreen(Loginstate_container)

	function create_button_list()
		list = {}
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.exit"), Image.File("menuintroscreen/images/introBtnExit.png"), "EXIT", "Exit the game.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.options"), Image.File("menuintroscreen/images/introBtnSettings.png"), "OPTIONS", "Change your graphics, audio and game settings.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.training"), Image.File("menuintroscreen/images/introBtnHelp.png"), "TRAINING", "Learn how to play the game.")
		list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://discord.gg/WcEJ9VH"), Image.File("menuintroscreen/images/introBtnDiscord.png"), "DISCORD", "Join the community Discord server.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.lan"), Image.File("menuintroscreen/images/introBtnLan.png"), "LAN", "Play on a Local Area Network.")
		list[#list+1] = create_mainbutton(Loginstate_container:GetEventSink("Login"), Image.File("menuintroscreen/images/introBtnOnline.png"), "PLAY", "Play Allegiance.")
		return list
	end

	function errortextImg() 
		return Image.Switch(
			Loginstate_container:GetState("Has error"), {
				["No"] = function(Loginstate_container) return Image.Empty() end,
				["Yes"] = function (Loginstate_container)
						errMsg = Loginstate_container:GetString("Message") 
						errimg = Image.String(Fonts.h2, Global.color.white, Number.Divide(xres,2), errMsg, Justify.Center)
						return errimg
					end,
			})
	end
	
	return Image.Group({
		Image.Translate(Image.Justify(create_buttonbar(create_button_list()), resolution, Justify.Bottom), Point.Create(0,-30)),
		Image.Justify(logo, resolution,Justify.Center),
		Image.Translate(Image.Justify(errortextImg(), resolution, Justify.Bottom),Point.Create(0, -300)),
		Image.Translate(Image.Justify(create_hovertextimg(hovertext), resolution, Justify.Bottom),Point.Create(0, -150)),
		credits_popup.get_area(Point.Create(
			Point.X(resolution), 
			Point.Y(resolution) - 200
		)),
		Image.Justify(credits_button.image, resolution, Justify.Bottomright),
	})
end



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
stepMsgImg = Image.String(Fonts.h2, Global.color.white, stepMsg, {Width=Number.Divide(xres,2), Justification=Justify.Center})

	return Image.Group({
		Image.Justify(spinner, resolution,Justify.Center),
		--spinner,
		Image.Translate(Image.Justify(stepMsgImg, resolution, Justify.Bottom),Point.Create(0, -150)),
		})
end

--------------- mission SCREEN --------------------------
------------------------------------------------------
--[[
to do:
'create mission' button(s)
back button
scaling for small resolutions
							   
fix hovertext

						  
]]



function make_missionscreen(Loginstate_container)
	cardwidth = 250
	cardheight = 280
	scaledcardwidth = cardwidth*UIScaleFactor -- we can't apply the scale factor yet because we can't dynamically scale fonts.
	scaledcardheight = cardheight*UIScaleFactor -- we have to apply the scaling after all the stringimages have been created.
	xmargin = Number.Round(Number.Multiply(xres,0.1), 1)*UIScaleFactor
	ytopmargin = 100*UIScaleFactor --Number.Round(Number.Multiply(yres,0.10),0)
	ybottommargin = 180*UIScaleFactor
	
	scrollbarwidth = 26
	xcardsarea = (xres-scrollbarwidth)-(2*xmargin) -- Number.Subtract(xres,Global.list_sum({xmargin, xmargin}))
	ycardsarea = yres-(ybottommargin+ytopmargin) -- Number.Subtract(yres,Number.Add(ybottommargin,ytopmargin))
	cardsarea = Point.Create(xcardsarea+scrollbarwidth,ycardsarea)
	cardsinnermargin = 15
	cardsoutermargin = 10
	--calculate the number of cards that fit into a horizontal row on the screen
	cardsrowlen = xcardsarea/(scaledcardwidth+(2*cardsoutermargin))
	-- and round down by subtracting the Modulo.
	cardsrowlen = cardsrowlen-Number.Mod(cardsrowlen,1)
	hovertext = "" 
	callback = ""
	-------- temp bogus data

	function write(str,fnt,c)
		fnt = fnt or Fonts.p
		color = c or Global.color.white
		return Image.Justify(
			Image.String(fnt, color, str), 
			Point.Create(cardwidth-cardsinnermargin, cardheight-cardsinnermargin), 
			Justify.Top
			)		
	end 

	function pos(img, x,y)
		return Image.Translate(img, Point.Create(x,y))
	end	

	mission_container = Loginstate_container:GetList("Mission list")
	
	cardslistImg = Image.Group(
		List.MapToImages(
			mission_container,
			function (mission, i)
				row = i/(cardsrowlen)
				row = row-Number.Mod(row,1)
				col = i - (row*cardsrowlen)
				posx = col*(scaledcardwidth+cardsoutermargin+cardsoutermargin)
				posy = row*(scaledcardheight+cardsoutermargin+cardsoutermargin)

				missionname = mission:GetString("Name")
				missionplayercount = Number.ToString(mission:GetNumber("Player count"))
				missionnoat =  Number.ToString(mission:GetNumber("Player noat count"))			
				missiont = mission:GetNumber("Time in progress")/1000
				missionhours = missiont/3600
				missionminutes = Number.Mod(missionhours,1)
				missionhours = missionhours-missionminutes
				missionminutes = missionminutes*60
				missionminutes = missionminutes-Number.Mod(missionminutes,1)
				missiontime = String.Switch(
					Number.Min(Number.Max(0, missionminutes-9),1),
					{
					[0]=Number.ToString(missionhours) .. ":0" .. Number.ToString(missionminutes),
					[1]=Number.ToString(missionhours) .. ":" .. Number.ToString(missionminutes),
				})
				missionserver = mission:GetString("Server name")
				missioncore = mission:GetString("Core name")
				missionstate = String.Switch(
					mission:GetBool("Is in progress"),{
					[true]="In Progress: " .. missiontime .. " - " .. missionplayercount .. "/" .. missionnoat ,
					[false]="Building Teams" .. "- " .. missionplayercount .. "/" .. missionnoat ,
				})

									
				function missionstylebools()
					lst = {}
					lst[#lst+1] = { name="CONQUEST", boolval = mission:GetBool("Has goal conquest")}
					lst[#lst+1] = { name="TERRITORY", boolval = mission:GetBool("Has goal territory")}
					lst[#lst+1] = { name="PROSPERITY", boolval = mission:GetBool("Has goal prosperity")}
					lst[#lst+1] = { name="ARTIFACTS", boolval = mission:GetBool("Has goal artifacts")}
					lst[#lst+1] = { name="FLAGS", boolval = mission:GetBool("Has goal flags")}
					lst[#lst+1] = { name="DEATHMATCH", boolval = mission:GetBool("Has goal deathmatch")}
					lst[#lst+1] = { name="COUNTDOWN", boolval = mission:GetBool("Has goal countdown")}

					selectedstyle = ""
					trueCount = 0
					for i, thing in ipairs(lst) do
						str = String.Switch(
							thing.boolval,
							{
							[true]=thing.name,
							[false]="",
							}
						)
						selectedstyle = selectedstyle .. str
						trueCount = trueCount + Boolean.ToNumber(thing.boolval)
					end
					styledata = {}
					styledata.trueCount = trueCount
					styledata.selected = selectedstyle
					return styledata
				end
				
				missionstyledata = missionstylebools()
				missionstyle = String.Switch(
					Number.Min(missionstyledata.trueCount,2),{
					[0] = "UNKNOWN", 
					[1] = missionstyledata.selected,
					[2] = "CUSTOM MISSION",
					}
				)
			
				function makemissioncardface(cardcolor) 
					missioncardface = Image.Group({
							Image.Extent(Point.Create(cardwidth, cardheight), Global.color.transparent),	
							pos(write(missionstyle, Fonts.h1, cardcolor),cardsinnermargin,10),
							pos(write(missionstate, Fonts.h4, cardcolor),cardsinnermargin,35), 
							pos(write(missionname, Fonts.h1, cardcolor),cardsinnermargin,60),
							pos(write("Server: "..missionserver, Fonts.h4, cardcolor),cardsinnermargin,105),
							pos(write("Core: "..missioncore, Fonts.h4, cardcolor),cardsinnermargin,120),
							})
				
					return Image.Scale(missioncardface, Point.Create(UIScaleFactor,UIScaleFactor))
				end
				-- Global.create_backgroundpane(cardwidth, cardheight, {color=cardcolor})
				joinbtn_n = Image.Group({ 
					Global.create_backgroundpane(scaledcardwidth, scaledcardheight, {color=button_normal_color}),
					makemissioncardface(button_normal_color)
				})
				joinbtn_h = Image.Group({ 
					Global.create_backgroundpane(scaledcardwidth, scaledcardheight, {color=button_hover_color, src=Image.File("/global/images/backgroundpane_highlight.png")}),
					makemissioncardface(button_hover_color)
				})
				joinbtn_s = Image.Group({ 
					Global.create_backgroundpane(scaledcardwidth, scaledcardheight, {color=button_selected_color}),
					makemissioncardface(button_selected_color)
				})

				card = Button.create_image_button(joinbtn_n, joinbtn_h, joinbtn_s, "Connect To This Lobby And Join This Mission")
				hovertext = String.Concat(hovertext, card.btnhovertext) --concatenates the hoverstring with the contents of the toplevel one.
				Event.OnEvent(mission:GetEventSink("Join"), card.events.click)
				return  pos(card.image,posx,posy) 
			end	
		)
	) 
	-- cardslistImg =Image.Extent(Point.Create(xcardsarea, 1250), Global.color.transparent)
	--if the vertical size of the cardimage < cardsarea (if it fits) return 0, otherwise return 1,
	doWeNeedaScrollbar = Number.Min(Number.Max(0, Point.Y(Image.Size(cardslistImg))-ycardsarea),1)
	missioncards = Image.Group({
		Image.Extent(cardsarea, Global.color.transparent),
		Image.Switch(
			doWeNeedaScrollbar,
			{
			[0] = Image.Justify(cardslistImg,cardsarea, Justify.Center), -- then just show the cardsimage, else 
			[1] = Image.Group({
					Image.Translate(Global.create_backgroundpane(xcardsarea+50,ycardsarea+30, {color=button_normal_color}), Point.Create(0,-15)),
					Global.create_vertical_scrolling_container(
					Image.Justify(cardslistImg,Point.Create(xcardsarea+scrollbarwidth,ycardsarea), Justify.Top),
					cardsarea,
					button_normal_color
					),	
				})
			}), -- make a scrolling pane image
		})

	function create_button_list()
		list = {}
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.exit"), Image.File("menuintroscreen/images/introBtnExit.png"), "EXIT", "Exit the game.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.options"), Image.File("menuintroscreen/images/introBtnSettings.png"), "OPTIONS", "Change your graphics, audio and game settings.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.training"), Image.File("menuintroscreen/images/introBtnHelp.png"), "TRAINING", "Learn how to play the game.")
		list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://discord.gg/WcEJ9VH"), Image.File("menuintroscreen/images/introBtnDiscord.png"), "DISCORD", "Join the community Discord server.")
		list[#list+1] = create_mainbutton(Loginstate_container:GetEventSink("Create mission dialog"), Image.File("menuintroscreen/images/introBtnLan.png"), "CREATE GAME", "Create your own game on a server.")
		list[#list+1] = create_mainbutton(Loginstate_container:GetEventSink("Logout"), Image.File("menuintroscreen/images/introBtnBack.png"), "BACK", "Go Back To The Main Screen.")
		return list
	end
	
	-- create the mission creation dialog

	return Image.Group({
																																											   
			Image.Translate(missioncards, Point.Create(xmargin, ytopmargin)),
																						 
			Image.Translate(Image.Justify(create_hovertextimg(hovertext), resolution, Justify.Bottom),Point.Create(0, -150)),
			Image.Translate(Image.Justify(create_buttonbar(create_button_list()), resolution, Justify.Bottom), Point.Create(0,-30)),
		})

	
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
	["Logged in"]=make_missionscreen,
	})

return Image.Group({
	Image.ScaleFill(make_background(), resolution, Justify.Center), -- we use the same background image for all of them.
	stagescreen,
	Image.Justify(Image.String(Font.Create("Verdana",12), button_normal_color, Button.version.."\n"..introscreenversion.."\n"..Global.version .."\n".. callback, {Width=200, Justification=Justify.Right}), resolution, Justify.Topright),
	})

