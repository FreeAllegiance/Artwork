
Control = File.LoadLua("global/control.lua")()
Button = File.LoadLua("button/button.lua")()

local section_labels = {
	Online="Profile",
	UI="User interface",
	Graphics="Graphics",
	Mouse="Mouse & Joystick",
	Keybindings="Keybindings",
	Sound="Sound",
	Modding="Modding",
	Debug="Debug",
}

local section_order = {
	"Online", "UI", 
	"Graphics", 
	"Mouse", "Keybindings", "Sound", "Modding", "Debug"
}

function entry_to_label_with_none(entry)
	return String.Switch(String.Equals(entry, ""), {
		[ true ] = "[ None ]",
		[ false ] = entry
	})
end

function create_section_entries(context, create_configuration)
	local section_entries = {
		Graphics=function ()
			-- need a dummy sink
			local fullscreen_resolution_sink = Point.CreateEventSink(
				Screen.Get("Configuration.Graphics.ResolutionX"),
				Screen.Get("Configuration.Graphics.ResolutionY")
			)

			return {
				create_configuration("Fullscreen", Control.boolean.create_listbox(Screen.Get("Configuration.Graphics.Fullscreen"), { true, false })),

				create_configuration("Available fullscreen modes", Control.create_listbox(
					fullscreen_resolution_sink,
					Screen.Get("Fullscreen modes"),
					{
						entry_to_label=function (entry)
							return entry:Get("Width") .. " x " .. entry:Get("Height") .. " @ " .. entry:Get("Rate")
						end,
						entry_to_value=function (entry)
							return Point.Create(entry:Get("Width"), entry:Get("Height"))
						end,
						is_selected=function (a)
							return Boolean.And(
								Number.Equals(Screen.Get("Configuration.Graphics.ResolutionX"), Point.X(a)),
								Number.Equals(Screen.Get("Configuration.Graphics.ResolutionY"), Point.Y(a))
							)
						end,
						change_registration_callback=function (register)
							register(Screen.Get("Configuration.Graphics.ResolutionX"), function (entry)
								return entry:Get("Width")
							end)
							register(Screen.Get("Configuration.Graphics.ResolutionY"), function (entry)
								return entry:Get("Height")
							end)
						end,
					}
				)),

				create_configuration("Custom resolution", Image.Switch(Screen.Get("Configuration.Graphics.Fullscreen"), {
					[ false ] = Image.StackHorizontal({
						Control.int.create_input(context, Screen.Get("Configuration.Graphics.ResolutionX"), {
							width = 50
						}),
						Image.String(Font.Create("Verdana", 16), Color.Create(0.8, 0.8, 0.8), "x"),
						Control.int.create_input(context, Screen.Get("Configuration.Graphics.ResolutionY"), {
							width = 50
						}),
					}, 10),
					[ true ] = Image.String(Font.Create("Verdana", 16), Color.Create(0.8, 0.8, 0.8), "Not available in fullscreen mode"),
				})),
				

				create_configuration("VSync", Control.boolean.create_listbox(Screen.Get("Configuration.Graphics.UseVSync"), { true, false })),
				create_configuration("Anti-aliasing", Control.boolean.create_listbox(Screen.Get("Configuration.Graphics.UseAntiAliasing"), { true, false })),
				create_configuration("Maximum texture size", Control.int.create_listbox(Screen.Get("Configuration.Graphics.MaxTextureSizeLevel"), { 0, 1, 2, 3 }, {
					entry_to_label=function (entry)
						local edge = Number.ToString(256 * Number.Power(2, entry), 0)
						return edge .. "x" .. edge
					end
				})),

				create_configuration("Brightness (gamma)", Control.number.create_input(context, Screen.Get("Configuration.Graphics.Gamma"))),

				create_configuration("Render Environment", Control.boolean.create_listbox(Screen.Get("Configuration.Graphics.Environment"))),
				create_configuration("Render Posters", Control.boolean.create_listbox(Screen.Get("Configuration.Graphics.Posters"))),
				create_configuration("Render Stars", Control.boolean.create_listbox(Screen.Get("Configuration.Graphics.Stars"))),
				create_configuration("Render Particles", Control.boolean.create_listbox(Screen.Get("Configuration.Graphics.Particles"))),
				create_configuration("Render Lens Flare", Control.boolean.create_listbox(Screen.Get("Configuration.Graphics.LensFlare"))),

				create_configuration("Debris", Control.number.create_listbox(Screen.Get("Configuration.Graphics.Debris"), { 0, 1.5, 1.0, 0.8 }, {
					entry_to_label=function (entry)
						return String.Switch(entry, {
							[0] = "Off",
							[1.5] = "Low",
							[1.0] = "Medium",
							[0.8] = "High",
						}, Number.ToString(entry, 2))
					end
				})),
			}
		end,
		Online=function ()
			return {
				create_configuration("Callsign", Control.string.create_input(context, Screen.Get("Configuration.Online.CharacterName"))),
				create_configuration("Squad tag", Control.string.create_listbox(
					Screen.Get("Configuration.Online.SquadTag"), 
					Screen.Get("AvailableSquadTags"),
					{
						entry_to_label=entry_to_label_with_none,
						change_registration_callback=function (register_func)
							register_func(Screen.Get("Configuration.Online.OfficerToken"), function ()
								return ""
							end)
						end
					}
				)),
				create_configuration("Token", Control.string.create_listbox(
					Screen.Get("Configuration.Online.OfficerToken"), 
					Screen.Get("AvailableTokens"),
					{
						entry_to_label=entry_to_label_with_none
					}
				)),
			}
		end,
		UI=function ()
			return {
				create_configuration("Startup credits", Control.boolean.create_listbox(Screen.Get("Configuration.Ui.ShowStartupCreditsMovie"))),
				create_configuration("Startup movie", Control.boolean.create_listbox(Screen.Get("Configuration.Ui.ShowStartupIntroMovie"))),
				create_configuration("Startup training suggestion", Control.boolean.create_listbox(Screen.Get("Configuration.Ui.ShowStartupTrainingSuggestion"))),
				create_configuration("Use old UI", Control.boolean.create_listbox(Screen.Get("Configuration.Ui.UseOldUi"))),

				create_configuration("Chat number of lines", Control.int.create_listbox(Screen.Get("Configuration.Chat.NumberOfLines"), { 5, 6, 7, 8, 9, 10})),
				create_configuration("Censor chat", Control.boolean.create_listbox(Screen.Get("Configuration.Chat.CensorChat"))),
				create_configuration("Filter chats to all", Control.boolean.create_listbox(Screen.Get("Configuration.Chat.FilterChatsToAll"))),
				create_configuration("Filter voice chats", Control.boolean.create_listbox(Screen.Get("Configuration.Chat.FilterVoiceChats"))),
				create_configuration("Filter chats from lobby", Control.boolean.create_listbox(Screen.Get("Configuration.Chat.FilterChatsFromLobby"))),
				create_configuration("Filter unknown chats", Control.boolean.create_listbox(Screen.Get("Configuration.Chat.FilterUnknownChats"))),


				create_configuration("Hud Style", Control.int.create_listbox(Screen.Get("Configuration.Ui.HudStyle"), { 0, 1, 2, 3, 4 }, {
					entry_to_label=function (entry)
						return String.Switch(entry, {
							[0] = "Normal",
							[1] = "Software",
							[2] = "Custom Hud 1",
							[3] = "Custom Hud 2",
							[4] = "Custom Hud 3",
						}, Number.ToString(entry))
					end
				})),
			}
		end,
		Mouse=function ()
			return {
				create_configuration("Use mouse as joystick (virtual joystick)", Control.boolean.create_listbox(Screen.Get("Configuration.Joystick.UseMouseAsJoystick"))),
				create_configuration("Show turn rate indicator", Control.boolean.create_listbox(Screen.Get("Configuration.Joystick.ShowDirectionIndicator"))),

				create_configuration("Mouse input method", Control.boolean.create_listbox(Screen.Get("Configuration.Mouse.UseRawInput"), {
					entry_to_label=function (entry)
						return String.Switch(entry, {
							[true] = "Raw",
							[false] = "DirectInput",
						})
					end
				})),
				
				create_configuration("Mouse sensitivity", Control.number.create_input(context, Screen.Get("Configuration.Mouse.Sensitivity"), {
					decimals=2
				})),
				create_configuration("Mouse acceleration", Control.int.create_listbox(Screen.Get("Configuration.Mouse.Acceleration"), { 0, 1, 2 }, {
					entry_to_label=function (entry)
						return String.Switch(entry, {
							[0] = "[ none ]",
							[1] = "2x",
							[2] = "4x",
						}, Number.ToString(entry))
					end
				})),

				create_configuration("Flip Y Axis", Control.boolean.create_listbox(Screen.Get("Configuration.Joystick.FlipYAxis"))),

				create_configuration("Joystick control response", Control.boolean.create_listbox(Screen.Get("Configuration.Joystick.ControlsLinear"), {
					entry_to_label=function (entry)
						return String.Switch(entry, {
							[true] = "Linear",
							[false] = "Quadratic",
						})
					end
				})),
				create_configuration("Joystick deadzone", Control.int.create_listbox(Screen.Get("Configuration.Joystick.Deadzone"), { 4, 10, 30 }, {
					entry_to_label=function (entry)
						return String.Switch(entry, {
							[4] = "Smallest",
							[10] = "Small",
							[30] = "Largest",
						}, Number.ToString(entry))
					end
				})),
				create_configuration("Joystick force feedback", Control.boolean.create_listbox(Screen.Get("Configuration.Joystick.EnableForceFeedback"))),
			}
		end,
		Keybindings=function ()
			local button = Button.create_standard_textbutton("Open keybindings popup", Font.Create("Verdana", 18), 200, 50)
			Event.OnEvent(Screen.Get("Open keymap popup"), button.events.click)
			return {
				button.image
			}
		end,
		Sound=function ()
			return {
				create_configuration("Effect volume", Control.int.create_input(context, Screen.Get("Configuration.Sound.EffectVolume"))),
				create_configuration("Voice over volume", Control.int.create_input(context, Screen.Get("Configuration.Sound.VoiceVolume"))),
			}
		end,
		Modding=function ()
			function image_string(text)
				return Image.String(Font.Create("Verdana", 14), Color.Create(0.8, 0.8, 0.8), text)
			end

			local create_mod_name = String.CreateEventSink("My new mod")

			local create_button = Button.create_standard_textbutton("Create", Font.Create("Verdana", 16), 200, 50)
			Event.OnEvent(Screen.Get("Create mod"), create_button.events.click, function ()
				return create_mod_name
			end)

			return {
				create_configuration("Mod directory", image_string(Screen.Get("Configuration.Modding.Path"))),
				create_configuration(
					"Found mods", 
					Image.Switch(List.Count(Screen.Get("Installed mods")), {
						[ 0 ] = image_string("No mods found")
					}, Image.StackVertical(List.Map(Screen.Get("Installed mods"), function (mod)
						local upload_button = Button.create_standard_textbutton("Upload new version", Font.Create("Verdana", 16), 200, 50)
						Event.OnEvent(mod:Get("Upload"), upload_button.events.click)

						return image_string(mod:Get("Name"))

						-- return Image.Group({
						-- 	image_string(String.Join({
						-- 		mod:Get("Name"),
						-- 		" (SteamId=",
						-- 		mod:Get("Identifier"),
						-- 		")",
						-- 	})),
						-- 	Image.Switch(mod:Get("IsOwned"), {
						-- 		[ true ]= Image.Translate(
						-- 			Image.Switch(mod:GetState("Upload state"), {
						-- 				NotOwned=function ()
						-- 					return image_string("Author: " .. "Not you")
						-- 				end,
						-- 				Idle=function ()
						-- 					local boolCanUpload = Boolean.Or(
						-- 						String.Equals(mod:Get("Identifier"), ""),
						-- 						mod:Get("IsOwned")
						-- 					)

						-- 					return Image.Switch(boolCanUpload, {
						-- 						[ true ]=upload_button.image,
						-- 					})
						-- 				end,
						-- 				Uploading=function (obj)
						-- 					return image_string(obj:Get("Status"))
						-- 				end,
						-- 			}),
						-- 			Point.Create(300, 0)
						-- 		),
						-- 	}),
						-- })
					end), 5))
				),
				image_string("-----------------------------------------------------------"),
				image_string([[
How to create a mod (this is a work in progress):
- Below, type a name and click the create button. This creates a directory in your '[install dir]/Mods'
- By placing files in this directory ('[install dir]/Mods/[your mod name]'), you can overwrite a lot of the game assets that would normally be loaded from '[install dir]/Artwork'.
]]),
				create_configuration("Create mod with name", Control.string.create_input(context, create_mod_name)),
				create_button.image,
			}
		end,
		Debug=function ()
			return {
				create_configuration("Artwork path", Control.string.create_input(context, Screen.Get("Configuration.Data.ArtworkPath"))),

				create_configuration("Log to file", Control.boolean.create_listbox(Screen.Get("Configuration.Debug.LogToFile"))),
				create_configuration("Log to output", Control.boolean.create_listbox(Screen.Get("Configuration.Debug.LogToOutput"))),
				create_configuration("Log Mdl", Control.boolean.create_listbox(Screen.Get("Configuration.Debug.Mdl"))),
				create_configuration("Window logging", Control.boolean.create_listbox(Screen.Get("Configuration.Debug.Window"))),
				create_configuration("Debugging mode LUNA", Control.boolean.create_listbox(Screen.Get("Configuration.Debug.Lua"))),

				create_configuration("Render bounding boxes", Control.boolean.create_listbox(Screen.Get("Configuration.Graphics.BoundingBoxes"))),
				create_configuration("Render objects transparent", Control.boolean.create_listbox(Screen.Get("Configuration.Graphics.TransparentObjects"))),
			}
		end,
	}
	return section_entries
end

return {
	section_labels=section_labels,
	section_order=section_order,
	create_section_entries=create_section_entries
}