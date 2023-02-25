[CmdletBinding()]
param (
    [Parameter()]
    $ChannelMessage
)

if ($ChannelMessage.content -like 'lookup *' -and $ChannelMessage.content.SubString(7, ($ChannelMessage.content.Length) - 7) -match $RegexTable['domain']) {
    $LookupValue = $ChannelMessage.content.SubString(7, ($ChannelMessage.content.Length) - 7) 
    $IPAddresses = (Get-IPInfo -IPAddress (Get-DnsInfo -Domain $LookupValue).AddressList) | Select-Object query, country, isp
    $IPAddresses | ForEach-Object -Begin { $string = "" } -Process { $string += "`tIP: $($_.query) Country: $($_.country) ISP: $($_.isp)`n" }
    Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content "$LookupValue results:`n$string"
}

# this thingy looks up ip addresses using ip-api.com free api. See below function Get-IPInfo which is in this script to see how it works
if ($ChannelMessage.content -like 'lookupip *' -and $ChannelMessage.content.SubString(9, ($ChannelMessage.content.Length) - 9) -match $RegexTable['ip4address']) {
    $LookupValue = $ChannelMessage.content.SubString(9, ($ChannelMessage.content.Length) - 9)
    $IPLookup = Get-IPInfo -IPAddress $LookupValue -ErrorAction STOP
    $prop = $IPLookup | get-member -MemberType NoteProperty
    $prop | ForEach-Object -Begin { $string = "" } -Process { $string += "`t$($_.Name): $($IPLookup."$($_.Name)")`n" }
    Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content "$LookupValue results:`n$string"
}