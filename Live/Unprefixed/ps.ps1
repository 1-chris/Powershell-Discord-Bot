<#
.SYNOPSIS
    This is a PowerShell script that is used to run PowerShell commands in Discord.
    This is very dangerous and should only be used in a private Discord channel.
.DESCRIPTION
    This script is used to run PowerShell commands in Discord. It is very dangerous and should only be used in a private Discord channel.
    This script is designed to be used with the Discord bot script. This effectively turns a channel into a PowerShell terminal 
.EXAMPLE
    .\ps.ps1 -ChannelMessage $ChannelMessage
#>

[CmdletBinding()]
param (
    [Parameter()]
    $ChannelMessage
)

if ($null -ne $PSChannelIds -and $ChannelMessage.channel_id -in $PSChannelIds) {
    if ($ChannelMessage.content -notlike '*saveps*' -and $ChannelMessage.content -notlike '^*' -and ($ChannelMessage.author.id -eq $BotOwner -or $PSChannelAllowNonOwner)) {
        $CommandValue = $ChannelMessage.content 
        $ScriptBlock = $CommandValue.Replace('```', '').Replace("bottoken", "nope")
        $ScriptBlock | Out-File last.ps1
        $Output = Invoke-Expression $ScriptBlock | Out-String
    
        # Split the output into 1750 character chunks and send them as separate messages
        if ($Output.Length -le 1750) {
            $FormattedString = '```{0}```' -f $Output
            Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content $FormattedString
        }
        
        if ($Output.Length -gt 1750) {
            $OutputArray = $Output -split '((.|\n){1750})'
            foreach ($OutputChunk in $OutputArray) {
                try {
                    if ($OutputChunk.Length -gt 1) {
                        Write-Host "Sending chunk... $($OutputChunk.Length) characters"
                        $FormattedString = '```{0}```' -f $OutputChunk
                        Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content $FormattedString
                    } else {
                        # Avoid empty junk messages
                        Write-Host "Skipping chunk... $($OutputChunk.Length) characters"
                    }
                    Start-Sleep -Milliseconds 750 # Wait to avoid throttling
                } catch {
                    Write-Host "Error sending chunk... $($OutputChunk.Length) characters"
                }
            }
        }
    }

}
