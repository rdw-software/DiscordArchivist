local config = require("config")
local chatCommands = config.chatCommands

local timer = require("timer")
local json = require("json")
local fs = require("fs")

local discordia = require("discordia")
local client = discordia.Client()

local http = require("coro-http")

local stateFilePath = config.archiveDirectory .. "/" .. "state.json"
local state

if not fs.existsSync(config.archiveDirectory) then
	fs.mkdirSync(config.archiveDirectory)
end

if not fs.existsSync(config.attachmentsDirectory) then
	fs.mkdirSync(config.attachmentsDirectory)
end

if fs.existsSync(stateFilePath) then
	local stateFile = assert(io.open(stateFilePath, "r"))
	state = json.decode(stateFile:read("*a"))
	stateFile:close()
	print("Restored state from " .. stateFilePath)
else
	print("No persistent state found in " .. stateFilePath .. " (first run or missing state file?)")
	state = {
		channels = {}
	}
end

local function fetchNewMessages()
	print("Starting archival process in directory " .. config.archiveDirectory .. "/")
	 for guild in client.guilds:iter() do
		print("\tProcessing server: " .. guild.name .. " (" .. guild.id .. ")")
		for channel in guild.textChannels:iter() do
			print("\t\tProcessing channel: #" .. channel.name .. " (" .. channel.id .. ")")
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
						timestamp = message.timestamp,
						attachments = message.attachments or {},
						downloadedAttachments = {},
					})
					lastMessageId = message.id
				end

				if #messages < limit then break end
			end

			if #newMessages > 0 then
				local existingMessages = {}
				if fs.existsSync(config.archiveDirectory .. "/" .. channel.id .. ".json") then
					local file = assert(io.open(config.archiveDirectory .. "/" .. channel.id .. ".json", "r"))
					existingMessages = json.decode(file:read("*a"))
					file:close()
				end

				for _, message in ipairs(newMessages) do
					table.insert(existingMessages, message)
					for _, attachment in ipairs(message.attachments) do
						print("Downloading message attachment: " .. attachment.url)
						local res, data = http.request("GET", attachment.url)
						if res.code == 200 then
							local filePath = config.attachmentsDirectory .. "/" .. attachment.filename
							local file = assert(io.open(filePath, 'wb'))
							file:write(data)
							file:close()
							table.insert(message.downloadedAttachments, filePath)
							print("Saved attachment to disk: " .. filePath)
						else
							print("Warning: Failed to fetch message attachment from " .. attachment.url .. " (response code: " .. res.code .. ")")
						end
					end
				end

				local file = assert(io.open(config.archiveDirectory .. "/" .. channel.id .. ".json", "w"))
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
	print("Archival process complete (will repeat every " .. config.messageFetchIntervalInSeconds .. " seconds)")
end

client:on("ready", function()
	print("Logged in as ".. client.user.username)
	if config.statusText then
		client:setActivity(config.statusText)
	end

	timer.setInterval(config.messageFetchIntervalInSeconds * 1000, function()
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