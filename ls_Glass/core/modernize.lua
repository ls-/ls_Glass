local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local type = _G.type

-- Mine
function E:Modernize(data, name, key)
	if not data.version then return end

	if key == "profile" then
		--> 110000.01
		if data.version < 11000001 then
			if data.chat then
				if data.chat.font then
					data.chat[1] = {
						font = {
							size = data.chat.font.size,
							shadow = data.chat.font.shadow,
							outline = data.chat.font.outline,
						},
					}

					data.chat.font = nil
				end

				data.chat.alpha = nil
				data.chat.fade = nil
				data.chat.slide_in_duration = nil
				data.chat.x_padding = nil
				data.chat.y_padding = nil
			end

			data.dock = nil

			data.version = 11000001
		--> 110207.02
		elseif data.version < 11020702 then
			if data.font and type(data.font) == "string" then
				data.font = {
					name = data.font,
				}

				data.version = 11020702
			end
		end
	end
end
