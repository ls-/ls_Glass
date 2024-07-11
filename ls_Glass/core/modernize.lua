local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local m_max = _G.math.max

-- Mine
function E:Modernize(data, name, key)
	if not data.version then return end

	if key == "profile" then
		--> 100000.03
		if data.version < 10000003 then
			if data.chat then
				if data.chat.x_padding then
					data.chat.x_padding = m_max(1, data.chat.x_padding)
				end

				if data.chat.y_padding then
					data.chat.y_padding = m_max(1, data.chat.y_padding)
				end
			end

			data.version = 10000003
		end

		--> 100002.01
		if data.version < 10000201 then
			if data.dock then
				if data.dock.edit then
					data.dock.edit.offset = nil
				end
			end

			data.version = 10000201
		end
	end
end
