local globalCommands = {
	["!help"] = "Beep bop! I'm a bot, and you can find my source code here: https://github.com/Duckwhale/DiscordArchivist",
}

-- Server-specific data (hardcoded for now)
local serverCommands = {
	["253226687649677312"] = { -- Ragnarok Research Lab
		-- TBD
	},
	["788119147740790854"] = { -- Rarity
		-- TBD
	}
}

-- Copy global commands so that they work everywhere
for command, responseText in pairs(globalCommands) do
	for serverID in pairs(serverCommands) do
		serverCommands[serverID][command] = responseText
	end
end

return serverCommands