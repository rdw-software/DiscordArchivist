local config = require("config")
local chatCommands = config.chatCommands

local timer = require("timer")
local json = require("json")
local fs = require("fs")

local discordia = require("discordia")
local client = discordia.Client()

local ARCHIVAL_TIME_IN_SECONDS = 60
local ARCHIVAL_TIME_IN_MILLISECONDS = ARCHIVAL_TIME_IN_SECONDS * 1000

local stateFilePath = "state.json"
local state

if fs.existsSync(stateFilePath) then
	local stateFile = assert(io.open(stateFilePath, "r"))
	state = json.decode(stateFile:read("*a"))
	stateFile:close()
	print("Restored state from " .. stateFilePath)
else
	print("No persistent state found (first run or missing state file)")
	state = {
		channels = {}
	}
end

local function fetchNewMessages()
	print("Starting archival process...")
	 for guild in client.guilds:iter() do
		print("\tProcessing server: " .. guild.id)
		for channel in guild.textChannels:iter() do
			print("\t\tProcessing channel: " .. channel.id)
			state.channels[channel.id] = state.channels[channel.id] or {}
			local lastMessageId = state.channels[channel.id].lastMessageId
			local newMessages = {}
			local limit = 100

			while true do
				local messages

				if lastMessageId then
					messages = channel:getMessagesAfter(lastMessageId, limit)
				else
					messages = channel:getMessages(limit)
				end

				if not messages then break end

				for message in messages:iter() do
					table.insert(newMessages, {
						id = message.id,
						content = message.content,
						author = message.author.username,
						timestamp = message.timestamp
					})
					lastMessageId = message.id
				end

				if #messages < limit then break end
			end

			if #newMessages > 0 then
				local existingMessages = {}
				if fs.existsSync(channel.id .. ".json") then
					local file = assert(io.open(channel.id .. ".json", "r"))
					existingMessages = json.decode(file:read("*a"))
					file:close()
				end

				for _, message in ipairs(newMessages) do
					table.insert(existingMessages, message)
				end

				local file = assert(io.open(channel.id .. ".json", "w"))
				file:write(json.encode(existingMessages))
				file:close()

				state.channels[channel.id].lastMessageId = lastMessageId

				-- Save state to file
				local stateFile = assert(io.open(stateFilePath, "w"))
				stateFile:write(json.encode(state))
				stateFile:close()
			end
		end
	end
	print("Archival process complete")
end

client:on("ready", function()
	print("Logged in as ".. client.user.username)
	if config.statusText then
		client:setActivity(config.statusText)
	end

	timer.setInterval(ARCHIVAL_TIME_IN_MILLISECONDS, function()
		local co = coroutine.create(fetchNewMessages)
		local status, err = coroutine.resume(co)
		if not status then
			print("Error running message fetching coroutine: " .. err)
		end
	end)
end)

client:on("messageCreate", function(message)
	if chatCommands and chatCommands[message.content] then
		message.channel:send(chatCommands[message.content])
	end
end)

local tokenFile = io.open("discord.token")
assert(tokenFile, "Failed to read Discord API token from discord.token (no such file exists)")
local token = tokenFile:read("*a")
client:run("Bot " .. token)