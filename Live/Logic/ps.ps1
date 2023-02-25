<#
.SYNOPSIS
    This is a PowerShell script that is used to run PowerShell commands in Discord.
    This is very dangerous and should only be used in a private Discord channel.
.DESCRIPTION
    This script is used to run PowerShell commands in Discord. It is very dangerous and should only be used in a private Discord channel.
    This script is designed to be used with the Discord bot script.
.EXAMPLE
    .\ps.ps1 -ChannelMessage $ChannelMessage
#>

[CmdletBinding()]
param (
    [Parameter()]
    $ChannelMessage
)

if ($ChannelMessage.content -like 'ps *' -and $ChannelMessage.author.id -eq $BotOwner) {
    $CommandValue = $ChannelMessage.content.SubString(3, ($ChannelMessage.content.Length) - 3) 
    $ScriptBlock = $CommandValue.Replace('```', '').Replace("bottoken", "nooooope")
    $Output = Invoke-Expression $ScriptBlock | Out-String
    $FormattedString = '```{0}```' -f $Output
    Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content $FormattedString
}

if ($ChannelMessage.content -like 'saveps *' -and $ChannelMessage.author.id -eq $BotOwner) {
    $CommandValue = $ChannelMessage.content.SubString(7, ($ChannelMessage.content.Length) - 7) 
    Copy-Item -Path "last.ps1" -Destination "savedcmd/$($CommandValue).ps1"
    Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content "Command saved as '^$CommandValue'"
}

if ($ChannelMessage.content -like '^*') {
    $CommandValue = $ChannelMessage.content.SubString(1, ($ChannelMessage.content.Length) - 1) 
    $ScriptBlock = Get-Content savedcmd/$($CommandValue).ps1 | Out-String
    $Output = Invoke-Expression $ScriptBlock | Out-String
    $FormattedString = '```{0}```' -f $Output
    Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content $FormattedString
}