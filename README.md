# PowerShell-Discord-Bot

## Description
A PowerShell Discord bot that can be used to run PowerShell commands and scripts.

For a more simple bot in 1 file, you can browse this previous commit: https://github.com/1-chris/Powershell-Discord-Bot/tree/67d04b6e9854ccb84fabfaacfadc542be13e52ae

## Requirements
- Tested with PowerShell 7.x
- Created with Linux in mind so some included commands/scripts will need adjusting for Windows

## Setup
1. Ensure you've got a Discord bot token and invite the bot to your server.
2. Configure variables within the variables.ps1 file. 
3. Where to run the bot:
 - I recommend running this on a Linux server or container.
 - It is possible to run this within Azure Functions or within the Azure App Service 
 -- Note: Using ASP you'll find it won't work on Free Linux tier since it doesn't support 64bit PowerShell 7.x)


### Run the bot with the following command

```powershell
./Invoke-DiscordBot.ps1
```

## Default Commands

### .enableprefix <script name>
- Enables a script which listens on bot command prefix for the bot to respond to

### .disableprefix <script name>
- Disables a script which listens on bot command prefix for the bot to respond to

### .enableunprefixed <script name>
- Enables a script which runs against any message sent to a channel the bot is in

### .disableunprefixed <script name>
- Disables a script which runs against any message sent to a channel the bot is in

### "hi " / "hello "
- Responds with a greeting. This is included as very basic example of how to create a command.

## Included Scripts
- You can find the included scripts in the Logic and Unprefixed folder.

### Logic
These scripts are run when a message is sent to a channel the bot is in and the message starts with the prefix defined in the variables.ps1 file.
#### animefind.ps1
- Searches for an anime using AniList API and returns the first result.

#### lookup.ps1 
- IP information lookup using ipinfo.io and DNS record lookup

#### ps.ps1
- Runs PowerShell commands and returns the output.
- Supports saving commands as custom scripts for later use.
- These commands are locked down to the owner of the bot.

### Unprefixed
These scripts are run when a message is sent to a channel the bot is in and the message does not start with the prefix defined in the variables.ps1 file.

#### ps.ps1
- Supports using a channel as a shell.
- Customize access to the shell with the variables.ps1 file.
- These commands are locked down to the owner of the bot.
