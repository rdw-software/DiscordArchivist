local discordia = require("discordia")
local client = discordia.Client()

client:on("ready", function()
	print("Logged in as ".. client.user.username)
end)

local tokenFile = io.open("discord.token")
assert(tokenFile, "Failed to read Discord API token from discord.token (no such file exists)")
local token = tokenFile:read("*a")
client:run("Bot " .. token)