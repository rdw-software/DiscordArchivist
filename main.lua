local commands = require("commands")

local discordia = require("discordia")
local client = discordia.Client()

client:on("ready", function()
	print("Logged in as ".. client.user.username)
end)

client:on('messageCreate', function(message)
	if message.guild then
		local serverID = message.guild.id
		local serverCommands = commands[serverID]

		if commands and serverCommands[message.content] then
			message.channel:send(serverCommands[message.content])
		end
	end
end)

local tokenFile = io.open("discord.token")
assert(tokenFile, "Failed to read Discord API token from discord.token (no such file exists)")
local token = tokenFile:read("*a")
client:run("Bot " .. token)