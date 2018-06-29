

Button = File.LoadLua("button/button.lua")()
Global = File.LoadLua("global/global.lua")()
Fonts = File.LoadLua("global/fonts.lua")()
Colors = File.LoadLua("global/colors.lua")()
Popup = File.LoadLua("global/popup.lua")()
Control = File.LoadLua("global/control.lua")()
Context = File.LoadLua("global/context.lua")()

context = Context.create_context()

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
UIScaleFactor = Number.Min(Number.Clamp(xres/1366,0.6,1.1), Number.Clamp(yres/768,0.6, 1.1))
checktext = Number.ToString(UIScaleFactor*1000)
fontheader1 = Fonts.create_scaled("Trebuchet MS", 26*UIScaleFactor, {Bold=true})
fontheader2 = Fonts.create_scaled("Trebuchet MS", 23*UIScaleFactor, {Italic=true, Bold=true})
fontheader4 = Fonts.create_scaled("Trebuchet MS", 19*UIScaleFactor, {Bold=true})
e_errormessage = String.CreateEventSink("")
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

-- -- declare recurring variables outside of function
mainbtn_bg1 = Image.File("menuintroscreen/images/introBtn_border.png")
--btnimage_position = Point.Create(0,0)

local e_hovertext = String.CreateEventSink("")
function updatehovertext()
	
end 

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
	--hovertext = hovertext .. button.hovertext --[[ concatenates the hoverstring with the contents of the toplevel one. Since there's only one 	non-empty string we should wind up with only the text for the button currently hovered over... ]]
	Event.OnEvent(e_hovertext, button.events.enter, function() return arghovertext end)
	Event.OnEvent(e_hovertext, button.events.leave, function() return "" end)
	Event.OnEvent(e_hovertext, button.events.click, function() return "" end)
	if argfunction then
		Event.OnEvent(event_sink, button.events.click, argfunction)
		else 
		Event.OnEvent(event_sink, button.events.click)
	end 

	return button.image
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



-------     INTROSCREEN --------
----------------------------------------------

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
					errimg = Image.String(fontheader2, Colors.white, Number.Divide(xres,2), errMsg, Justify.Center)
					return errimg
				end,
		})
	end

	return Image.Group({
		Image.Translate(Image.Justify(render_list(create_button_list()), resolution, Justify.Bottom), Point.Create(0,-30)),
		Image.Justify(logo, resolution,Justify.Center),
		Image.Translate(Image.Justify(errortextImg(), resolution, Justify.Bottom),Point.Create(0, -175)),
		-- Image.Translate(Image.Justify(create_hovertextimg(hovertext), resolution, Justify.Bottom),Point.Create(0, -150)),
	})
end



---------------------- Connecting   ----------------
----------------------------------------------------------------------------------------------------------------------------------
function make_spinner(Loginstate_container)
	spinnerpoint = Point.Create(136,136) -- roughly the size of the diagonal of the spinner image. 
	spinner = Image.Group({
		Image.Extent(spinnerpoint, Colors.transparent),
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

function make_missionscreen(Loginstate_container)
	hovertext = "" -- this will hold the eventual text for other functions to use
	cardwidth = 250
	cardheight = 280
	scaledcardwidth = cardwidth*UIScaleFactor 
	scaledcardheight =cardheight*UIScaleFactor
	xmargin = Number.Multiply(xres,0.1)*UIScaleFactor
	ytopmargin = 100*UIScaleFactor --Number.Round(Number.Multiply(yres,0.10),0)
	ybottommargin = 180*UIScaleFactor
	scrollbarwidth = 26
	xcardsarea = (xres-scrollbarwidth)-(2*xmargin) -- Number.Subtract(xres,Global.list_sum({xmargin, xmargin}))
	ycardsarea = yres-(ybottommargin+ytopmargin) -- Number.Subtract(yres,Number.Add(ybottommargin,ytopmargin))
	cardsarea = Point.Create(xcardsarea+scrollbarwidth,ycardsarea)
	cardsinnermargin = 15*UIScaleFactor
	cardsoutermargin = 10*UIScaleFactor
	--calculate the number of cards that fit into a horizontal row on the screen
	-- we're using pre-scaled dimensions since we can't render the whole thing in one size 
	-- and scale down/up as needed, because the number of cards we can show 
	-- varies with the screen ratio.  
	cardsrowlen_fl = xcardsarea/(scaledcardwidth+(2*cardsoutermargin))
	-- and round down by subtracting the Modulo.
	cardsrowlen = cardsrowlen_fl - Number.Mod(cardsrowlen_fl,1)
	--checktext = Number.ToString(cardsrowlen)
	cardbackground_n = Global.create_backgroundpane(scaledcardwidth, scaledcardheight, {color=button_normal_color})
	cardbackground_h = 	Global.create_backgroundpane(scaledcardwidth, scaledcardheight, {color=button_hover_color, src=Image.File("/global/images/backgroundpane_highlight.png")})
	cardbackground_s = 	Global.create_backgroundpane(scaledcardwidth, scaledcardheight, {color=button_selected_color})
	
	function write(str,fnt,c)
		fnt = fnt or Fonts.p
		color = c or Colors.white
		textblock = Point.Create(scaledcardwidth-cardsinnermargin, 5)
		return Image.Group({
			Image.Extent(textblock, Colors.transparent),
			Image.Justify(Image.String(fnt, color, str), textblock, Justify.Top),
		})
	end 

	function pos(img, x,y)
		return Image.Translate(img, Point.Create(x,y))
	end	
	
	-- create the mission creation dialog
	function create_mission_screen()
		-- regularlist = {"alpha", "bravo", "charlie", "delta", "echo"}
		c_servers = Loginstate_container:GetList("Server list")
		c_cores = Loginstate_container:GetList("Core list")
		ChosenServer_eventsink = String.CreateEventSink("")
		ChosenCore_eventsink = String.CreateEventSink("")

		mission_name = String.CreateEventSink(Loginstate_container:Get("Callsign") .. "'s game")


		local create_btn = Button.create_standard_textbutton("CREATE", Fonts.h1, 120, 40)

		Event.OnEvent(Loginstate_container:Get("Create mission"), create_btn.events.click, function ()
			return ChosenServer_eventsink, ChosenCore_eventsink, mission_name
		end)
		
		-- dimensions		
		serverlistboxwidth = 110
		listboxheight = 100 -- Point.Y(Image.Size(serverlistbox))
		corelistboxwidth = 110
		-- functions to pass as arguments to the listboxmaker function
		local function entry_to_string (c_item)
			return c_item:GetString("Name") 
		end
		function entry_renderer(entry, index, target)
					entryWidth = 100
					listboxWidth = 110
					entryHeight = 20
					string = entry_to_string(entry)
					is_selected = String.Equals(string, target)
					return Image.Switch(is_selected, {
							[ false ] = Image.Group({
									Image.Translate(Image.Extent(Point.Create(listboxWidth, entryHeight), Colors.transparent),Point.Create(-10,0)),
									Image.String(Fonts.p, Colors.white, string, {Width=entryWidth}),
								}),
							[ true ] = Image.Group({
									Image.Translate(Image.Extent(Point.Create(listboxWidth, entryHeight), Color.Create(0.6,0.6,0.6,0.6)),Point.Create(-10,0)),
									Image.String(Fonts.pbold, Colors.white, string, {Width=entryWidth}),
								}),
						})
				end
		-- make the listboxes 
		serverlistbox = Image.Group({
				Image.Translate(Global.create_box(serverlistboxwidth, listboxheight, {background_color=Colors.dark}), Point.Create(-5,0)),
				Image.Translate(				
				Global.create_vertical_scrolling_container(
					Control.string.create_listbox(ChosenServer_eventsink, c_servers,{entry_to_label=entry_to_string,entry_to_value=entry_to_string,entry_renderer= entry_renderer}),
					Point.Create(serverlistboxwidth, listboxheight),
					button_normal_color
					),
					Point.Create(5, 2)
				),
			})
		corelistbox = Image.Group({
				Image.Translate(Global.create_box(corelistboxwidth, listboxheight, {background_color=Colors.dark}), Point.Create(-5,0)),
				Image.Translate(
					Global.create_vertical_scrolling_container(
						Control.string.create_listbox(ChosenCore_eventsink, c_cores, {entry_to_label=entry_to_string,entry_to_value=entry_to_string,entry_renderer= entry_renderer}),
						Point.Create(corelistboxwidth, listboxheight),
						button_normal_color  
					),
					Point.Create(5, 2)
				),
			})
		dialogwidth = 450
		dialogheight = 400
		return Image.Group({
			Image.Extent(Point.Create(dialogwidth,dialogheight), Colors.transparent),
			--Global.create_box(450,400),
			Image.Justify(
				Image.StackVertical({
					Image.Justify(Image.String(fontheader1, Colors.white, "CREATE MISSION"), Point.Create(dialogwidth, 20),Justify.Center),
					Image.Justify(Image.String(Fonts.create_scaled("Trebuchet MS", 23, {Bold=true}), Colors.white, "MISSION NAME:", {Width=140}), Point.Create(dialogwidth, 20),Justify.Center),
					Image.Justify(Control.string.create_input(context, mission_name, {width=dialogwidth-40}), Point.Create(dialogwidth-20, 20), Justify.Center),
					Image.Extent(Point.Create(0, 10), Colors.transparent),
					Image.String(fontheader4, Colors.white, "Select a server near your physical location to play on. Then select a game core. \n \n Cores are sets of game rules. Different cores may have different factions, weapons and balance values.", 
						{Width=dialogwidth, Justification=Justify.Center}
					),
					Image.Extent(Point.Create(dialogwidth, 30), Colors.transparent),
					Image.Justify(
						Image.Group({
							Image.Extent(Point.Create(dialogwidth-200, 30), Colors.transparent),
							Image.Justify(
								Image.StackVertical({
									Image.String(fontheader4, Colors.white, "Servers"),
									serverlistbox,
								}),
								Point.Create(dialogwidth-200, listboxheight+35),
								Justify.Left
							),
							Image.Justify(
								Image.StackVertical({
									Image.String(fontheader4, Colors.white, "Cores"),
									corelistbox,
								}),
								Point.Create(dialogwidth-200, listboxheight+35),
								Justify.Right
							),	
						}),
						Point.Create(dialogwidth, listboxheight+35),
						Justify.Top
					),
					Image.Switch(Loginstate_container:Get("Server has core")(ChosenServer_eventsink, ChosenCore_eventsink), {
						[ true ]=create_btn.image
					}),
				}),
				Point.Create(dialogwidth, dialogheight),
				Justify.Top
			),
		})
	end

	local create_mission_window = Popup.create_popup_window(Image.Lazy(create_mission_screen))

	local create_mission_popup = context.create_popup(create_mission_window.image);

	create_mission_popup.add_close_source(create_mission_window.close_source)

	local currentpassword = String.CreateEventSink("")
	function create_joining_popup()

		function with_transparent_background(img)
			return Image.Group({
				-- make sure we can't click on anything else by having a transparent background
				Image.Extent(cardsarea, Color.Create(0, 0, 0, 0)),
				Image.Justify(img, cardsarea, Justify.Center),
			})
		end

		return Image.Switch(Loginstate_container:GetState("Join mission state"), {
			Joining=function ()
				return with_transparent_background(Image.String(Fonts.h1, Color.Create(0.8, 0.8, 0.8), "Joining mission..."))
			end,
			Idle=function (obj)
				return Image.Switch(obj:Get("Has error"), {
					Yes = function (error_obj)
						local show_error = Boolean.CreateEventSink(true)

						local cancel_button = Button.create_standard_textbutton("Cancel", Fonts.h1, 120, 40)
						Event.OnEvent(show_error, cancel_button.events.click, function () return false end)

						local retry_button = Button.create_standard_textbutton("Retry", Fonts.h1, 120, 40)
						Event.OnEvent(error_obj:Get("Retry"), retry_button.events.click, function ()
							return currentpassword
						end)

						return Image.Switch(show_error, {
							[ true ]=with_transparent_background(Image.StackVertical({
								Image.String(Fonts.h1, Color.Create(0.8, 0.8, 0.8), "Failed: " .. error_obj:Get("Reason")),
								Image.Switch(error_obj:Get("Reason is incorrect password"), {
									[ true ] = Image.StackVertical({
										Image.StackHorizontal({
											Image.String(Fonts.h1, Color.Create(0.8, 0.8, 0.8), "Password: "),
											Control.string.create_input(context, currentpassword),
										}),
										retry_button.image,
									})
								}),
								cancel_button.image,
							}))
						})
					end,
				})
			end
		})
	end
	
	----------
	---- MISSION CARDS SECTION
	----------
	mission_container = Loginstate_container:GetList("Mission list")
	cardslistImg = Image.Group(
		List.Map(
			List.Sort(
				mission_container,
				function (mission)
					-- Negate the count to turn it from asc to desc
					return 0 - mission:Get("Player count")
				end
			),
			function (mission, i)
				j=i+1
				row_fl = j/cardsrowlen -- calculate how many rows are needed to display this mission 
				row = row_fl-Number.Mod(row_fl,1) -- rounddown that number because we don't want half a card in view
				col = j - (row*cardsrowlen) -- calculate the column this mission would be in.
				missionname = mission:GetString("Name")
				missionplayercount = mission:GetNumber("Player count")
				missionnoat =  mission:GetNumber("Player noat count")		
				missiont = mission:GetNumber("Time in progress")
				missionhours = missiont/3600
				missionminutes = Number.Mod(missionhours,1)
				missionhours = missionhours-missionminutes
				missionminutes = missionminutes*60
				missionminutes = missionminutes-Number.Mod(missionminutes,1)
				missiontime = String.Switch(
					Number.Clamp(missionminutes-9, 0, 1),
					{
					[0]=Number.ToString(missionhours) .. ":0" .. Number.ToString(missionminutes),
					[1]=Number.ToString(missionhours) .. ":" .. Number.ToString(missionminutes),
				})
				missionserver = mission:GetString("Server name")
				missioncore = mission:GetString("Core name")

				mission_playercount_string = Number.ToString(missionplayercount - missionnoat) .. "/" .. Number.ToString(missionplayercount)
				missionstate = String.Switch(
					mission:GetBool("Is in progress"),{
					[true]="In Progress: " .. missiontime .. " (" .. mission_playercount_string .. ")",
					[false]="Building Teams" .. " (" .. mission_playercount_string .. ")",
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
						Image.Extent(carddims, Colors.transparent),
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
				joinbtn_n = Image.Group({ 
					--Global.create_backgroundpane(scaledcardwidth, scaledcardheight, {color=button_normal_color}),
					cardbackground_n,
					makemissioncardface(button_normal_color)
				})
				joinbtn_h = Image.Group({ 
					--Global.create_backgroundpane(scaledcardwidth, scaledcardheight, {color=button_hover_color, src=Image.File("/global/images/backgroundpane_highlight.png")}),
					cardbackground_h,
					makemissioncardface(button_hover_color)
				})
				joinbtn_s = Image.Group({ 
					--Global.create_backgroundpane(scaledcardwidth, scaledcardheight, {color=button_selected_color}),
					cardbackground_s,
					makemissioncardface(button_selected_color)
				})
				missionhovertext = String.Switch(
					mission:GetBool("Is in progress"),{
					[true]="Join This Mission." ,
					[false]="Connect To The Lobby For This Mission.",
				})
				checktext = "what the hell?"
				card = Button.create_image_button(joinbtn_n, joinbtn_h, joinbtn_s)
				
				-- hovertext = hovertext .. card.hovertext --concatenates the hoverstring with the contents of the toplevel one.
				Event.OnEvent(e_hovertext, card.events.enter, function() return missionhovertext end)
				Event.OnEvent(e_hovertext, card.events.leave, function() return "" end)
				Event.OnEvent(e_hovertext, card.events.click, function() return "" end)
				Event.OnEvent(mission:Get("Join"), card.events.click, function ()
					return currentpassword
				end)
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
					create_missioncard = Button.create_image_button(joinbtn_n, joinbtn_h, joinbtn_s)
					create_mission_hovertext = "Create your own game on a server."
					--hovertext = hovertext .. create_missioncard.hovertext --concatenates the hoverstring with the contents of the toplevel one.
					Event.OnEvent(e_hovertext, create_missioncard.events.enter, function() return create_mission_hovertext end)
					Event.OnEvent(e_hovertext, create_missioncard.events.leave, function() return "" end)
					Event.OnEvent(e_hovertext, create_missioncard.events.click, function() return "" end)

					create_mission_popup.add_open_source(create_missioncard.events.click)
					return create_missioncard.image
				end			
				missioncard = Image.Switch(
					Number.Clamp(i, 0,1),
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
	-- cardslistImg =Image.Extent(Point.Create(xcardsarea, 1250), Colors.transparent)
	--if the vertical size of the cardimage < cardsarea (if it fits) return 0, otherwise return 1,
	doWeNeedaScrollbar = Number.Clamp(Point.Y(Image.Size(cardslistImg))-ycardsarea,0,1)
	missioncards = Image.Group({
		Image.Extent(cardsarea, Colors.transparent),
		Image.Switch(
			doWeNeedaScrollbar,
			{
			[0] = Image.Group({
					Image.Translate(Image.Justify(Image.Extent(Point.Create(xcardsarea, 3), button_normal_color), cardsarea, Justify.Top), Point.Create(0,-5)),	
					Image.Justify(cardslistImg,cardsarea, Justify.Center),
					}), -- then just show the cardsimage, else 
			[1] = Image.Group({
					Image.Translate(Global.create_backgroundpane(xcardsarea+50,ycardsarea+20, {color=button_normal_color}), Point.Create(0,-15)),
					Global.create_vertical_scrolling_container(
					Image.Justify(cardslistImg,Point.Create(xcardsarea+scrollbarwidth,ycardsarea), Justify.Top),
					Point.Create(xcardsarea+scrollbarwidth,ycardsarea-10),
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
	
	return Image.Group({
			-- logo at top
			Image.Translate(Image.Justify(Image.Scale(logo, Point.Create(UIScaleFactor,UIScaleFactor)), resolution, Justify.Top), Point.Create(0,15*UIScaleFactor)),
			-- mission list
			Image.Translate(missioncards, Point.Create(xmargin, ytopmargin)),
			--buttonbar
			Image.Translate(Image.Justify(render_list(button_list()), resolution, Justify.Bottom), Point.Create(0,-30*UIScaleFactor)),
			-- hovertext
			-- Image.Translate(Image.Justify(create_hovertextimg("hovertext"..hovertext), resolution, Justify.Bottom),Point.Create(0, -150*UIScaleFactor)),
			-- popups
			Image.Justify(create_joining_popup(), resolution, Justify.Center),	
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

function create_credits_button()
	local credits_window = Popup.create_popup_window(Image.Lazy(function ()
		return File.LoadLua("menuintroscreen/credits.lua")().create(context)
	end))

	local credits_popup = context.create_popup(credits_window.image);

	local credits_button = Popup.create_simple_text_button("Credits", 14);

	credits_popup.add_open_source(credits_button.event_click)
	credits_popup.add_close_source(credits_window.close_source)

	return credits_button.image
end


function create_hovertextimg(str)
	return Image.String(fontheader2, Colors.standard_ui, str, {Width=Number.Divide(xres,2), Justification=Justify.Center})
end

statescreen = Image.Switch(
	Login_state,{
	["Logged out"]=make_introscreen, 
	["Logging in"]=make_spinner,
	["Logged in"]=make_missionscreen,
	})

return context.create_result_image(
	resolution, 
	Image.Group({
		Image.ScaleFill(make_background(), resolution, Justify.Center), -- we use the same background image for all of them.
		statescreen,
		-- credits_popup.get_area(Point.Create(
		-- 		Point.X(resolution), 
		-- 		Point.Y(resolution) - 200
		-- 	)),
		Image.Translate(Image.Justify(create_hovertextimg(e_hovertext), resolution, Justify.Bottom),Point.Create(0, -150*UIScaleFactor)),
		Image.Justify(Image.String(Font.Create("Verdana",12), button_normal_color, Button.version.."\n"..introscreenversion.."\n"..Global.version .."\n".. checktext, {Width=200, Justification=Justify.Right}), resolution, Justify.Topright),
		Image.Justify(create_credits_button(), resolution, Justify.Bottomright),
	})
)
