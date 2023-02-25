# Set the Discord bot token here. Keep it as $env:BotToken if you want to use an environment variable.
$BotToken = $env:BotToken

# Put in YOUR bot id or it will try to respond to itself
$BotId = $env:BotId

# Set the owner's Discord ID here. Keep it as $env:BotOwner if you want to use an environment variable.
$BotOwner = $env:BotOwner

# Set the prefix for bot commands here. This does not apply for 'unprefixed' commands.
$BotCommandPrefix = "^"

# Set the PS Discord channel IDs in below array. Keep it as $env:PSChannelId if you want to use a single environment variable.
# Security notice: This is used for running PowerShell commands in a shared Discord channel.
$PSChannelIds = @( "$env:BotPSChannelId" )

$PSChannelAllowNonOwner = $true # Allow non-owner to use PS channel

$RegexTable = @{
    'domain'     = "^((?!-))(xn--)?[a-z0-9][a-z0-9-_]{0,61}[a-z0-9]{0,1}\.(xn--)?([a-z0-9\-]{1,61}|[a-z0-9-]{1,30}\.[a-z]{2,})$"
    'ip4address' = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
}
