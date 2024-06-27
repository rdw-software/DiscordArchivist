# DiscordArchivist

Source code for the Discord Archivist bot

## Features

RIght now it doesn't do much. But here's what I'm planning on implementing:

* Persistent log of all chat messages, posted links, and attachments (for archival purposes)
* Chat commands for specific things I find useful, on a per-server basis

Not sure I'll be adding anything too fancy, and I don't expect this to be useful for anyone but me.

## Why?

Data in the cloud isn't really under the user's control, and may theoretically vanish at any given moment. Since Discord doesn't provide an easy way of generating backups of a server's contents, this bot provides the same functionality as the IRC bots of old. Hopefully, it will prove entirely redundant, but you never know.

## Prerequisites

You must install the [Luvit](https://luvit.io/) runtime to use this bot.

The three main platforms should be supported (Windows/Linux/macOS), but YMMV.

## Usage

To run the bot program, execute this command in a terminal of your choice:

```sh
luvit main.lua
```
