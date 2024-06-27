# Discord Archivist

Extremely basic chat logging for Discord servers

## Features

Right now it doesn't do much. But here's what I've implemented so far:

* Persistent log of all chat messages, posted links, and attachments
* Configurable output directory, although the format is fixed (JSON)
* Message attachments ("embeds") are downloaded, but not external links
* Additionally provides chat commands that can execute arbitrary script code

The bot is written in Lua and uses the Discord REST API via [Discordia](https://github.com/SinisterRectus/Discordia).

## Limitations

This is something I quickly hacked together, so don't expect to be wowed. It mostly works, but that's about it.

## Goals

I wanted an easy way to back up the contents (messages, mainly) of any given Discord server.

Unfortunately, there's no built-in functionality for this. Also, the Discord search isn't great, so indexing the data might be easier once it's in a different format. Either way, data in the cloud isn't under the user's control and may vanish at any given moment, so a tool to create and maintain local backups seems like a useful thing to have.

## Prerequisites

You must install the [Luvit](https://luvit.io/) runtime to use this bot.

The three main platforms should be supported (Windows/Linux/macOS), but YMMV since I've done little testing.

To actually perform logging activities, you need to first create a [Discord Appication](https://discord.com/developers/applications) with the appropriate permissions:

* General Permissions: Read Messages/View Channels
* Text Permissions: Read Message History
* Integration Type: Guild Install (only for OAuth2)
* Can use [additional scopes](https://discord.com/developers/docs/topics/oauth2#shared-resources-oauth2-scopes) if you need more features (e.g., `bot`)

For the most part you just need to create a link for those permissions, visit it, and add the app to your server.

## Usage

Save your Discord API token in a text file called `discord.token` (without spaces, newlines or anything else).

Then run the bot program by executing this command in a terminal of your choice:

```sh
luvit main.lua
```

You can run it locally or as a service. It will create a simple JSON backup of all registered servers. Requires the appropriate permissions, and obviously the bot needs to be added to the server first in order to function.

Configuration is extremely basic right now, and mostly limited to the options listed in `config.lua`.

The bot will dump temporary log files (from Discordia) in the working directory. This can't currently be changed.
