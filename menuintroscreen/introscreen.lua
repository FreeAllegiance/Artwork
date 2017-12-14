Button = File.LoadLua("button/button.lua")()
Global = File.LoadLua("global/global.lua")()
Fonts = File.LoadLua("global/fonts.lua")()
Popup = File.LoadLua("global/popup.lua")()

introscreenversion = "introscreen alpha v0.05 "
Login_state= Screen.GetState("Login state")

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
UIScaleFactor = Number.Min(Number.Clamp(0.6,1.1, xres/1366), Number.Clamp(0.6, 1.1, yres/768))
checktext = Number.ToString(UIScaleFactor*1000)
fontheader1 = Fonts.create_scaled("Trebuchet MS", 26*UIScaleFactor, {Bold=true})
fontheader2 = Fonts.create_scaled("Trebuchet MS", 23*UIScaleFactor, {Italic=true, Bold=true})
fontheader4 = Fonts.create_scaled("Trebuchet MS", 19*UIScaleFactor, {Bold=true})

-- declare recurring variables used by multiple functions
button_width = UIScaleFactor*200  -- used below and in render_list()
button_normal_color = Color.Create(0.9, 0.9, 1, 0.8)
button_hover_color 	= Color.Create(1, 0.9, 0.8, 0.8)
button_selected_color = Color.Create(1,1,0.9, 0.95)
button_shadow_color = Color.Create(0.4,0.4,0.4,0.7)



logo = Image.Group({ 
		Image.Justify(
			Image.Multiply(Image.File("menuintroscreen/images/menuintroscreen_logo.png"),button_normal_color),
			Point.Create(278,78), 
			Justify.Topright
		),
	})

-- declare recurring variables outside of function
mainbtn_bg1 = Image.File("menuintroscreen/images/introBtn_border.png")
--btnimage_position = Point.Create(0,0)

function create_mainbutton(event_sink, argimage, arglabel, arghovertext, argfunction)
	argimageheight = Point.Y(Image.Size(argimage))
	scaledpt = Point.Create(UIScaleFactor, UIScaleFactor)
	function create_stringimages(label)
		--labelsize = 25*UIScaleFactor
		return {
		normal = Image.String(fontheader1, button_normal_color, label),
		shadow = Image.String(fontheader1, button_shadow_color, label),
		hover = Image.String(fontheader1, button_hover_color, label),
		selected = Image.String(fontheader1, button_selected_color, label),
		}
	end
	label = create_stringimages(arglabel)	
	btnsize = Point.Create(button_width, UIScaleFactor*(argimageheight+25+1)) -- 25 is 25px height of h1 font, 1px is for text shadow offset.
	image_n = Image.Group({
		Image.Justify(Image.Scale(Image.Multiply(argimage, button_normal_color),scaledpt),btnsize, Justify.Top),
		Image.Justify(Image.Group({
			Image.Translate(label.shadow, Point.Create(1,1)),
			label.normal,
		}), btnsize, Justify.Bottom),
	})
	image_h = Image.Group({
		Image.Justify(Image.Scale(Image.Multiply(mainbtn_bg1, button_hover_color),scaledpt),btnsize, Justify.Top),
		Image.Justify(Image.Scale(Image.Multiply(argimage, button_hover_color),scaledpt),btnsize, Justify.Top),
		Image.Justify(Image.Group({
			Image.Translate(label.shadow, Point.Create(1,1)),
			label.hover,
			}), 
		btnsize, Justify.Bottom)
	})
	-- selected doesnt need color multiply. 
	image_s = Image.Group({
			Image.Justify(Image.Scale(mainbtn_bg1,scaledpt), btnsize, Justify.Top),
			Image.Justify(Image.Scale(argimage,scaledpt), btnsize, Justify.Top),
		Image.Justify(Image.Group({
			Image.Translate(label.shadow, Point.Create(1,1)),
			label.selected,
			}), 
		btnsize, Justify.Bottom)
	})	
	
	button = Button.create_image_button(image_n, image_h, image_s, arghovertext)
	hovertext = hovertext .. button.hovertext --[[ concatenates the hoverstring with the contents of the toplevel one. Since there's only one 	non-empty string we should wind up with only the text for the button currently hovered over... ]]
	
	if argfunction then
		Event.OnEvent(event_sink, button.events.click, argfunction)
		else 
		Event.OnEvent(event_sink, button.events.click)
	end 

	
	--[[
	Event.OnEvent(
		create_mission_popup.get_is_open(), 
		create_mission_button.event_click, 
		function ()
			return Boolean.Not(create_mission_popup.get_is_open()) -- toggle get_is_open() on and off
		end)
	]]	
	return button.image
end

function create_hovertextimg(str)
	return Image.String(fontheader2, Global.color.white, Number.Divide(xres,2), hovertext, Justify.Center)
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
	bbimg = render_list(btnlist) 
	--[[-- compile the Button Bar (BB) image
	bbs = Image.Size(bbimg) -- get BB size as a point value
	bbx = Point.X(bbs) -- get BB width as a point val x coordinate
	bby = Point.Y(bbs) -- get BB height as a point val y coordinate
	fctr = Number.Min(1, (0.5*xres)/bbx) -- if smaller than 1, return ratio of the horizontal resolution and the Button Bar width.
	bbres = Point.Create(Number.Multiply(bbx, fctr), Number.Multiply(bby, fctr)) 
	btnbardiv = Point.Create((bbx*UIScaleFactor)-60, (bby*UIScaleFactor)-30)
	-- old calc: bbres = Point.Create(Number.Multiply(bbx, fctr), Number.Multiply(bby, fctr))
	return Image.ScaleFill(bbimg, btnbardiv, Justify.Center)
	]]
	return bbimg
end

-------     INTROSCREEN --------
----------------------------------------------

function make_introscreen(Loginstate_container)
hovertext = ""
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
						errimg = Image.String(fontheader2, Global.color.white, Number.Divide(xres,2), errMsg, Justify.Center)
						return errimg
					end,
			})
	end
	
	return Image.Group({
		Image.Translate(Image.Justify(create_buttonbar(create_button_list()), resolution, Justify.Bottom), Point.Create(0,-30)),
		Image.Justify(logo, resolution,Justify.Center),
		Image.Translate(Image.Justify(errortextImg(), resolution, Justify.Bottom),Point.Create(0, -175)),
		Image.Translate(Image.Justify(create_hovertextimg(hovertext), resolution, Justify.Bottom),Point.Create(0, -150)),
		Image.Justify(credits_button.image, resolution, Justify.Bottomright),
	})
end



---------------------- Connecting   ----------------
----------------------------------------------------------------------------------------------------------------------------------
function make_spinner(Loginstate_container)
	spinnerpoint = Point.Create(136,136) -- roughly the size of the diagonal of the spinner image. 
	spinner = Image.Group({
		Image.Extent(spinnerpoint, Global.color.transparent),
		Image.Justify(Image.Multiply(Image.File("menuintroscreen/images/spinner_aleph.png"),button_normal_color), spinnerpoint, Justify.Center),
		Image.Justify(Image.Rotate(Image.Multiply(Image.File("menuintroscreen/images/spinner.png"),button_normal_color), Number.Multiply(Screen.GetNumber("time"), 3.14)), spinnerpoint, Justify.Center),
		})

stepMsg = Loginstate_container:GetString("Step message")
stepMsgImg = Image.String(fontheader2, button_normal_color, stepMsg, {Width=Number.Divide(xres,2), Justification=Justify.Center})

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
	hovertext = "" -- this will hold the eventual text for other functions to use
	cardwidth = 250
	cardheight = 280
	scaledcardwidth = Number.Round(cardwidth*UIScaleFactor) 
	scaledcardheight = Number.Round(cardheight*UIScaleFactor)
	xmargin = Number.Round(Number.Multiply(xres,0.1), 1)*UIScaleFactor
	ytopmargin = 100*UIScaleFactor --Number.Round(Number.Multiply(yres,0.10),0)
	ybottommargin = 180*UIScaleFactor
	scrollbarwidth = 26
	xcardsarea = (xres-scrollbarwidth)-(2*xmargin) -- Number.Subtract(xres,Global.list_sum({xmargin, xmargin}))
	ycardsarea = yres-(ybottommargin+ytopmargin) -- Number.Subtract(yres,Number.Add(ybottommargin,ytopmargin))
	cardsarea = Point.Create(xcardsarea+scrollbarwidth,ycardsarea)
	cardsinnermargin = Number.Round(15*UIScaleFactor)
	cardsoutermargin = Number.Round(10*UIScaleFactor)
	--calculate the number of cards that fit into a horizontal row on the screen
	-- we're using pre-scaled dimensions since we can't render the whole thing in one size 
	-- and scale down/up as needed, because the number of cards we can show 
	-- varies with the screen ratio.  
	cardsrowlen_fl = xcardsarea/(scaledcardwidth+(2*cardsoutermargin))
	-- and round down by subtracting the Modulo.
	cardsrowlen = cardsrowlen_fl - Number.Mod(cardsrowlen_fl,1)
	--checktext = Number.ToString(cardsrowlen)

	function write(str,fnt,c)
		fnt = fnt or Fonts.p
		color = c or Global.color.white
		textblock = Point.Create(scaledcardwidth-cardsinnermargin, 5)
		return Image.Group({
			Image.Extent(textblock, Global.color.transparent),
			Image.Justify(Image.String(fnt, color, str), textblock, Justify.Top),
		})
	end 

	function pos(img, x,y)
		return Image.Translate(img, Point.Create(x,y))
	end	
	
	function create_mission_screen()
		return Image.Group({
			Image.Extent(Point.Create(300, 200), Global.color.transparent),
			write("help", Fonts.h1),
		})		
	end
	create_mission_popup = Popup.create_single_popup_manager(create_mission_screen)	
	mission_container = Loginstate_container:GetList("Mission list")
	
	cardslistImg = Image.Group(
		List.MapToImages(
			mission_container,
			function (mission, i)
				j=i+1
				row_fl = j/cardsrowlen -- calculate how many rows are needed to display this mission 
				row = row_fl-Number.Mod(row_fl,1) -- rounddown that number because we don't want half a card in view
				col = j - (row*cardsrowlen) -- calculate the column this mission would be in.
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
		-- figure out whether there is a single or multiple win condition set for the mission				
		-- first collect all the booleans from the mission container
				function missionstylebools()
					lst = {}
					lst[#lst+1] = { name="CONQUEST", boolval = mission:GetBool("Has goal conquest")}
					lst[#lst+1] = { name="TERRITORY", boolval = mission:GetBool("Has goal territory")}
					lst[#lst+1] = { name="PROSPERITY", boolval = mission:GetBool("Has goal prosperity")}
					lst[#lst+1] = { name="ARTIFACTS", boolval = mission:GetBool("Has goal artifacts")}
					lst[#lst+1] = { name="FLAGS", boolval = mission:GetBool("Has goal flags")}
					lst[#lst+1] = { name="DEATHMATCH", boolval = mission:GetBool("Has goal deathmatch")}
					lst[#lst+1] = { name="COUNTDOWN", boolval = mission:GetBool("Has goal countdown")}
		-- now loop through	the list of booleans. On true concat the list index and add 1 to the counter.
					selectedstyle = ""
					trueCount = 0
					for k, thing in ipairs(lst) do
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
					return {
						trueCount = trueCount,
						selected = selectedstyle,
					}
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
					carddims = Point.Create(scaledcardwidth, scaledcardheight)
					missioncardface = Image.Group({
						Image.Extent(carddims, Global.color.transparent),
						pos(Image.StackVertical({
								write(missionstyle, fontheader1, cardcolor),
								write(missionstate, fontheader4, cardcolor), 
								write(missionname, fontheader1, cardcolor),
								write("Server: "..missionserver, fontheader4, cardcolor),
								write("Core: "..missioncore, fontheader4, cardcolor),
							}),
							cardsinnermargin,
							cardsinnermargin
						)
					})
					return missioncardface
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
				hovertext = hovertext .. card.hovertext --concatenates the hoverstring with the contents of the toplevel one.
				Event.OnEvent(mission:GetEventSink("Join"), card.events.click)
				--positioning
				-- we're using pre-scaled dimension because this is also about the space between the cards.
				posx = col*(scaledcardwidth+cardsoutermargin+cardsoutermargin) -- 
				posy = row*(scaledcardheight+cardsoutermargin+cardsoutermargin)
				
				function make_create_missioncard()
					missionstyle = "NEW MISSION"
					missionstate = ""
					missionname = "CREATE NEW MISSION" 
					missionserver = " - "
					missioncore = " - "
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
					create_missioncard = Button.create_image_button(joinbtn_n, joinbtn_h, joinbtn_s, "Create your own game on a server.")
					hovertext = hovertext .. create_missioncard.hovertext --concatenates the hoverstring with the contents of the toplevel one.
					Event.OnEvent(create_mission_popup.get_is_open(), 
						create_missioncard.events.click,
						function () return Boolean.Not(create_mission_popup.get_is_open()) end
						)
					return create_missioncard.image
				end			
				missioncard = Image.Switch(
					Number.Clamp(0,1,i),
					{
						[0] = Image.Group({
							make_create_missioncard(),
							pos(card.image,posx,posy),
							}),
						[1] = pos(card.image,posx,posy)			
					})			
				return missioncard
			end	
		)
	) 
	-- cardslistImg =Image.Extent(Point.Create(xcardsarea, 1250), Global.color.transparent)
	--if the vertical size of the cardimage < cardsarea (if it fits) return 0, otherwise return 1,
	doWeNeedaScrollbar = Number.Clamp(0,1, Point.Y(Image.Size(cardslistImg))-ycardsarea)
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
	function button_list()
		list = {}
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.exit"), Image.File("menuintroscreen/images/introBtnExit.png"), "EXIT", "Exit the game.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.options"), Image.File("menuintroscreen/images/introBtnSettings.png"), "OPTIONS", "Change your graphics, audio and game settings.")
		list[#list+1] = create_mainbutton(Screen.GetExternalEventSink("open.training"), Image.File("menuintroscreen/images/introBtnHelp.png"), "TRAINING", "Learn how to play the game.")
		list[#list+1] = create_mainbutton(Screen.CreateOpenWebsiteSink("https://discord.gg/WcEJ9VH"), Image.File("menuintroscreen/images/introBtnDiscord.png"), "DISCORD", "Join the community Discord server.")
		list[#list+1] = create_mainbutton(Loginstate_container:GetEventSink("Logout"), Image.File("menuintroscreen/images/introBtnBack.png"), "BACK", "Go Back To The Main Screen.")
		return list
	end
	-- create the mission creation dialog
	return Image.Group({
			Image.Translate(Image.Justify(Image.Scale(logo, Point.Create(UIScaleFactor,UIScaleFactor)), resolution, Justify.Top), Point.Create(0,15*UIScaleFactor)),	
			Image.Translate(Image.Justify(Image.Extent(Point.Create(xcardsarea, 3), button_normal_color), resolution, Justify.Top), Point.Create(0,95*UIScaleFactor)),	
			Image.Translate(missioncards, Point.Create(xmargin, ytopmargin)),
			Image.Translate(Image.Justify(create_buttonbar(button_list()), resolution, Justify.Bottom), Point.Create(0,-30*UIScaleFactor)),
			Image.Translate(Image.Justify(create_hovertextimg(hovertext), resolution, Justify.Bottom),Point.Create(0, -150*UIScaleFactor)),
			Image.Translate(Image.Justify(create_hovertextimg(hovertext), resolution, Justify.Bottom),Point.Create(0, -150*UIScaleFactor)),
			Image.Justify(create_mission_popup.get_area(cardsarea), resolution, Justify.Center)
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

statescreen = Image.Switch(
	Login_state,{
	["Logged out"]=make_introscreen, 
	["Logging in"]=make_spinner,
	["Logged in"]=make_missionscreen,
	})

return Image.Group({
	Image.ScaleFill(make_background(), resolution, Justify.Center), -- we use the same background image for all of them.
	statescreen,
	credits_popup.get_area(Point.Create(
			Point.X(resolution), 
			Point.Y(resolution) - 200
		)),
	Image.Justify(Image.String(Font.Create("Verdana",12), button_normal_color, Button.version.."\n"..introscreenversion.."\n"..Global.version .."\n".. checktext, {Width=200, Justification=Justify.Right}), resolution, Justify.Topright),
	})

