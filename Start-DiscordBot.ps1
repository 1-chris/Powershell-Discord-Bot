# This is a discord bot made in powershell
# This script requires PowerShell 7.0 minimum. I used 7.2. 5.0 which comes with windows is not good enough
# Download here: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2#installing-the-msi-package

# Put in your Bot token
# You can get one here: https://discord.com/developers/applications
# Don't leak your bot token
$BotToken = ""

# Put in YOUR bot id or it will try to respond to itself
$BotId = ""

# Choose your intent permissions: https://discord.com/developers/docs/topics/gateway#gateway-intents
# Below chosen allows the bot to receive direct messages and discord server messages
# WARNING: This may not work anymore. I believe there have been recent changes in how gateway intents work.
$BotIntents = @('DIRECT_MESSAGES', 'GUILD_MESSAGES')

$RegexTable = @{
    'domain' = "^((?!-))(xn--)?[a-z0-9][a-z0-9-_]{0,61}[a-z0-9]{0,1}\.(xn--)?([a-z0-9\-]{1,61}|[a-z0-9-]{1,30}\.[a-z]{2,})$"
    'ip4address' = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
}

$Headers = @{
    "Authorization" = "Bot $BotToken"
    "User-Agent" = "PSDCBot (blabla, v0.1)"
}

# Various powershell preference settings useful for debugging and decluttering as needed
$InformationPreference = 'Continue'
$WarningPreference = 'Continue'
$VerbosePreference = 'SilentlyContinue'
$ErrorActionPreference = 'Continue'

# Actual bot logic goes here inside $script={}. This is a script block which is called in the main loop.
# More info about script blocks: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_script_blocks?view=powershell-7.2
$Script = {
    # Write the chat messages to the terminal
    $RecvObj.EventName -eq "MESSAGE_CREATE" ? ( Write-ChatMessage -ChannelMessage $RecvObj.Data ) : $null

    # Simplified name object for channel messages, filters out bots own messages 
    # Note - Typical properties for $ChannelMessage: type, tts, timestamp, referenced_message, pinned, nonce, mentions, mention_roles, mention_everyone, id, flags, embeds, edited_timestamp, content, components, channel_id, author, attachments
    $ChannelMessage = if($RecvObj.EventName -eq "MESSAGE_CREATE") { $RecvObj.Data | Where-Object {$_.author.id -ne $BotId} }
    
    # These try/catch/finally things are for error handling. More info: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.2
    try {
        # Instead of if statements we are using the ternery operator for either worse or simpler code idk. Info here: https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-70?view=powershell-7.2#ternary-operator
        $ChannelMessage.content -like 'hi*' -or $ChannelMessage.content -like 'hello*' ? ( 
            Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content "Hi $($ChannelMessage.author.username)" 
        ) : $null

        $ChannelMessage.content -like '*burger*' ? ( 
            Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content "I like burgers.`nMmmmm!" 
        ) : $null

        # This function-thingy looks up ip addresses from domain names
        $ChannelMessage.content -like 'lookup *' -and $ChannelMessage.content.SubString(7,($ChannelMessage.content.Length)-7) -match $RegexTable['domain'] ? (&{
            $LookupValue = $ChannelMessage.content.SubString(7, ($ChannelMessage.content.Length)-7) 
            $IPAddresses = (Get-IPInfo -IPAddress (Resolve-DnsName -Name $LookupValue -Type A_AAAA -DnsOnly -ErrorAction STOP).IPAddress) | Select-Object query,country,isp
            $IPAddresses | ForEach-Object -Begin {$string = ""} -Process { $string += "`tIP: $($_.query) Country: $($_.country) ISP: $($_.isp)`n" }
            Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content "$LookupValue results:`n$string"
        }) : $null

        # this thingy looks up ip addresses using ip-api.com free api. See below function Get-IPInfo which is in this script to see how it works
        $ChannelMessage.content -like 'lookupip *' -and $ChannelMessage.content.SubString(9,($ChannelMessage.content.Length)-9) -match $RegexTable['ip4address'] ? (&{
            $LookupValue = $ChannelMessage.content.SubString(9,($ChannelMessage.content.Length)-9)
            $IPLookup = Get-IPInfo -IPAddress $LookupValue -ErrorAction STOP
            $prop = $IPLookup | get-member -MemberType NoteProperty
            $prop | ForEach-Object -Begin {$string = ""} -Process  { $string += "`t$($_.Name): $($IPLookup."$($_.Name)")`n"}
            Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content "$LookupValue results:`n$string"
        }) : $null

    }
    catch {
        Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content "An error occurred :(((( thanks so much $($ChannelMessage.author.username). Error: $($PSItem.Exception.Message)"
    }
    finally {
        $Error.Clear()
    }
}

function Get-IPInfo {
    [cmdletbinding()]
    param( $IPAddress )
    $Collection = @()

    foreach ($ip in $IPAddress) {
        $Collection += Invoke-RestMethod -Uri "http://ip-api.com/json/$ip"
        Start-Sleep -Milliseconds 100
    }
    # this returns a collection because it can get multiple ip addresses at same time from "lookup domain" bot command
    return $Collection
}

function Write-ChatMessage {
    [cmdletbinding()]
    param( $ChannelMessage )
    
    $Timestamp = $ChannelMessage.timestamp
    $Username = $ChannelMessage.author.username
    $UserId = $ChannelMessage.author.id
    $Content = $ChannelMessage.content -Replace "`n", " "
    
    if ((-not [string]::IsNullOrEmpty($ChannelMessage.content)) -Or (-not [string]::IsNullOrWhiteSpace($ChannelMessage.content))) {
        Write-Host -NoNewLine -ForegroundColor Magenta "<$Timestamp - $Username $UserId> "
        Write-Host -NoNewLine -ForegroundColor White "$Content`n"
    }
}


# Generic function to simplify discord websocket calls
function Send-DiscordWebSocketData {
    [cmdletbinding()]
    param( $Data )
    
    $success = $false
    
    try {
        $Message = $Data | ConvertTo-Json
        $Array = @()
        $Message.ToCharArray() | ForEach-Object { $Array += [byte]$_ }
        $Message = New-Object System.ArraySegment[byte]  -ArgumentList @(,$Array)
        $Conn = $WS.SendAsync($Message, [System.Net.WebSockets.WebSocketMessageType]::Text, [System.Boolean]::TrueString, $CT)
        while (!$Conn.IsCompleted) { Start-Sleep -Milliseconds 50 }
        $success = $true
    }
    
    catch {
        Write-Error "Send-DiscordWebSocketData error: $($PSItem.Exception.Message)"
    }
    $msg = if($success){"Sent"}else{"SendFailed"}
    return ($Data | Select-Object @{N="SentOrRecvd";E={$msg}}, @{N="EventName";E={$_.t}}, @{N="SequenceNumber";E={$_.s}}, @{N="Opcode";E={$_.op}}, @{N="Data";E={$_.d}})

}

# Discord needs regular heartbeat to keep the websocket connected. Could use simplifying
function Send-DiscordHeartbeat
{
    [cmdletbinding()]
    #param( $SequenceNumber = $null )
    param( [int]$SequenceNumber = $SequenceNumber -is [int] -and $SequenceNumber -eq 0 ? ((Remove-Variable SequenceNumber -ErrorAction SilentlyContinue) && $null) : $SequenceNumber -isnot [int] -and $null -ne $SequenceNumber ? [int]$SequenceNumber : $SequenceNumber )
    
    $Prop = @{ 'op' = 1; 'd' = $SequenceNumber }
    $result = Send-DiscordWebSocketData -Data $Prop
    
    return $result
}

# I am not entirely sure how it works but it did.
# More info: https://discord.com/developers/docs/topics/gateway#gateway-intents
function Send-DiscordAuthentication
{
    [cmdletbinding()]
    param(
        [string]$Token,
        $Intents
    )
    $IntentsKeys = @{
        'GUILDS' = 1 -shl 0
        'GUILD_MEMBERS' = 1 -shl 1
        'GUILD_BANS' = 1 -shl 2
        'GUILD_EMOJIS_AND_STICKERS' = 1 -shl 3
        'GUILD_INTEGRATIONS' = 1 -shl 4
        'GUILD_WEBHOOKS' = 1 -shl 5
        'GUILD_INVITES' = 1 -shl 6
        'GUILD_VOICE_STATES' = 1 -shl 7
        'GUILD_PRESENCES' = 1 -shl 8
        'GUILD_MESSAGES' = 1 -shl 9
        'GUILD_MESSAGE_REACTIONS' = 1 -shl 10
        'GUILD_MESSAGE_TYPING' = 1 -shl 11
        'DIRECT_MESSAGES' = 1 -shl 12
        'DIRECT_MESSAGE_REACTIONS' = 1 -shl 13
        'DIRECT_MESSAGE_TYPING' = 1 -shl 14
        'GUILD_SCHEDULED_EVENTS' = 1 -shl 16
    }

    foreach ($key in $Intents) {
        # this is being set by looping through and, using a ternary operator like above. Actually reading this again I'm confused.
        $IntentsCalculation = $IntentsCalculation -eq $IntentsKeys[$key] ? $IntentsKeys[$key] : ( $IntentsCalculation + $IntentsKeys[$key] )
    }

    $Prop = @{
        'op' = 2;
        'd' = @{
            'token' = $Token;
            'intents' = [int]$IntentsCalculation;
            'properties' = @{
                '$os' = 'windows';
                '$browser' = 'pwshbot';
                '$device' = 'pwshbot';
            }
        }
    }

    $result = Send-DiscordWebSocketData -Data $Prop
    return $result
}

# used to simplify sending discord message in above script block
function Send-DiscordMessage
{
    [cmdletbinding()]
    param(
        $Token = $BotToken,
        $ChannelId,
        [string]$Content   
    )

    $Body = @{
        "content" = "$Content"
    }
    # this uses rest api instead of gateway to create new messages
    # more info: https://discord.com/developers/docs/resources/channel#create-message
    Invoke-RestMethod -Method POST -Uri "https://discord.com/api/v9/channels/$ChannelId/messages" -Headers $Headers -Body $Body | Out-Null # out-null at the end here just means discard whatever is being returned
}

# these regions are useful for collapsing code in VS code and probably other editors
#region code
$GatewaySession = Invoke-RestMethod -Uri "https://discord.com/api/gateway"
Write-Verbose "$($GatewaySession.url)"

# I stole much of this "websockety" code from this page talking about slack bots (which seem a hell of a lot easier)
# Page: https://wragg.io/powershell-slack-bot-using-the-real-time-messaging-api/
# I adapted some of the websocket code since it was tricky to get all the data being sent by discord

$WS = New-Object System.Net.WebSockets.ClientWebSocket  
$CT = New-Object System.Threading.CancellationToken

try{
    do{
        $Conn = $WS.ConnectAsync($GatewaySession.url, $CT)
        while (!$Conn.IsCompleted) { Start-Sleep -Milliseconds 100 }
        Write-Information "Connected to Web Socket."
        
        while ($WS.State -eq 'Open') {
            #region misc-code
            $DiscordData = ""
            $Size = 512000
            $Array = [byte[]] @(,0) * $Size
        
            $Recv = New-Object System.ArraySegment[byte] -ArgumentList @(,$Array)
            $Conn = $WS.ReceiveAsync($Recv, $CT) 
            while (!$Conn.IsCompleted) { Start-Sleep -Milliseconds 100 }
            $DiscordData = [System.Text.Encoding]::utf8.GetString($Recv.array)
        
            $LogStore += $DiscordData 

            try { $RecvObj = $DiscordData | ConvertFrom-Json | Select-Object @{N="SentOrRecvd";E={"Received"}}, @{N="EventName";E={$_.t}}, @{N="SequenceNumber";E={$_.s}}, @{N="Opcode";E={$_.op}}, @{N="Data";E={$_.d}} }
            catch {  Write-Error "ConvertFrom-Json failed $_.Exception"; Write-Host "Data: $RecvObj"; $RecvObj = $null;}
        
            # op code meanings are here: https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes
            if ($RecvObj.Opcode -eq '10') {
                Write-Verbose "HELLO received! Sending first heartbeat."
                $HeartbeatInterval = [int64]$RecvObj.Data.heartbeat_interval
                Start-Sleep -Milliseconds ($HeartbeatInterval * 0.1)
                Send-DiscordHeartbeat | Out-Null
                Write-Verbose "First heartbeat sent."
                $HeartbeatStart = [int64]((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalMilliseconds) # epoch time ms
                $NextHeartbeat = ($HeartbeatStart + [int64]$HeartbeatInterval)
                $continueAuth = $true
            }
            
            # this is probably broken but the bot still works so eh
            if ([int]$RecvObj.SequenceNumber -eq 1) { 
                $SequenceNumber = [int]$RecvObj.SequenceNumber 
            } elseif ([int]$SequenceNumber -eq 1 -Or [int]$RecvObj.SequenceNumber -gt [int]$SequenceNumber) {  
                $SequenceNumber = [int]$RecvObj.SequenceNumber 
            }

            # Getting the time between when each heartbeat should be sent
            $CurrentEpochMS = [int64]((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalMilliseconds)
            if($CurrentEpochMS -ge ($NextHeartbeat)) {
                Write-Verbose "Sending next heartbeat - $CurrentEpochMS >= $NextHeartbeat."
                if($SequenceNumber -ge 1) { Send-DiscordHeartbeat -SequenceNumber $SequenceNumber | Out-Null } 
                else { Send-DiscordHeartbeat | Out-Null }
                $NextHeartbeat = (([int64]((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalMilliseconds)) + [int64]$HeartbeatInterval)
            }

            if($RecvObj.Opcode -eq '11' -and $continueAuth -eq $true) {
                $continueAuth = $false
                Write-Verbose "First ACK received. Attempting authentication."
                Send-DiscordAuthentication -Token $BotToken -Intents $BotIntents | Out-Null #| Format-Table
                Write-Information "Successfully authenticated to Discord Gateway."
            }
            # opcode 9 is invalid session. Not sure how to stop this from regularly occuring
            if($RecvObj.Opcode -eq '9') { 
                Write-Warning "Session invalidated from opcode 9 received. Reauthenticating..."
                Send-DiscordAuthentication -Token $BotToken -Intents $BotIntents | Out-Null #| Format-Table 
                Write-Information "Successfully authenticated to Discord Gateway."
            }
            #endregion misc-code

            # Below we are calling the script block which is defined near the beggining of this script
            &$Script

        }
    } until (!$Conn)
} finally {
    if ($WS) { Write-Information "Closing websocket"; $WS.Dispose() }
}
#endregion code
