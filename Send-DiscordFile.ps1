

function Send-DiscordMessageWithFile {
    [CmdletBinding()]
    param (
        [Parameter()]
        $ChannelId,
        $BotToken,
        $FolderPath,
        $FileName
    )
    
    # Don't leak your bot token
    if ($null -eq $BotToken) {
        $BotToken = $env:BotToken
    }
    
    $Headers = @{
        "Authorization" = "Bot $BotToken"
        "User-Agent"    = "PSDCBot (blabla, v0.2)"
    }

    # Thanks to https://stackoverflow.com/questions/68677742/multipart-form-data-file-upload-with-powershell

    $FileName = Split-Path $FilePath -Leaf
    $boundary = [System.Guid]::NewGuid().ToString()
    $TheFile = [System.IO.File]::ReadAllBytes($FilePath)
    $TheFileContent = [System.Text.Encoding]::GetEncoding('iso-8859-1').GetString($TheFile)
    
    $bodyLines = (
        "--$boundary",
        "Content-Disposition: form-data; name=`"Description`"`r`n",
        "File uploaded by a bot",
        "--$boundary",
        "Content-Disposition: form-data; name=`"TheFile`"; filename=`"$FileName`"",
        "Content-Type: application/json`r`n",
        $TheFileContent,
        "--$boundary--`r`n"
    ) -join "`r`n"

    Invoke-RestMethod -Uri "https://discord.com/api/v9/channels/$ChannelId/messages" -Method POST -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $bodyLines -Headers $Headers
}

if ($FolderPath) {
	$items = Get-ChildItem -Path $FolderPath -Recurse
	
	foreach ($item in $items) {
		Send-DiscordMessageWithFile -ChannelId $ChannelId -FilePath $item.FullName
	}
}

if ($FileName) {
	Send-DiscordMessageWithFile -ChannelId $ChannelId -FilePath $FileName
}