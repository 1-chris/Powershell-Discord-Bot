[CmdletBinding()]
param (
    [Parameter()]
    $ChannelMessage
)

if ($ChannelMessage.content -like 'animefind *') {
    $LookupValue = $ChannelMessage.content.SubString(10, ($ChannelMessage.content.Length) - 10) 
    Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content "Looking up $LookupValue"
    Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content "$(Get-AnimeBySearchText -SearchText $LookupValue)"
}