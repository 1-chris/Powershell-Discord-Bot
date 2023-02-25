[CmdletBinding()]
param (
    [Parameter()]
    $ChannelMessage
)

if ($ChannelMessage.content -like 'yt2mp3 *') {
	$start = Get-Date
	$url = $ChannelMessage.content -replace 'yt2mp3 ', ''

	if (-not (Get-Command "ffmpeg" -ErrorAction SilentlyContinue)) {
		Write-Host "Downloading ffmpeg"
		Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content "Downloading ffmpeg"
		Invoke-Expression "apt install ffmpeg -y" | Out-String
	}
	if (-not (Get-ChildItem "yt-dlp_linux" -ErrorAction SilentlyContinue)) {
		Write-Host "Downloading yt-dlp"
		Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content "Downloading yt-dlp"
		Invoke-WebRequest -Uri "https://github.com/yt-dlp/yt-dlp/releases/download/2023.02.17/yt-dlp_linux" -OutFile "yt-dlp_linux"
	}

	$guid = (New-Guid).Guid
	New-Item -ItemType Directory -Path "/tmp/yt2mp3/$guid"
	
	./yt-dlp_linux $url -x --audio-format mp3 -o "/tmp/yt2mp3/$guid/%(title)s.%(ext)s"
	
	$mp3 = Get-ChildItem "/tmp/yt2mp3/$guid" | Where-Object { $_.Extension -eq '.mp3' }
	
	if ($mp3.Count -eq 1) {
		Send-DiscordMessageWithFile -ChannelId $ChannelMessage.channel_id -FilePath "$($mp3.FullName)"
	}

	if ($mp3.Count -gt 1) {
		foreach ($file in $mp3) {
			try {
				Send-DiscordMessageWithFile -ChannelId $ChannelMessage.channel_id -FilePath "$($file.FullName)"
			}
			catch {
				Write-Host "Error sending file $($file.FullName)"
				Start-Sleep -Seconds 1
				Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content "Error sending file $($file.FullName)"
			}
			Start-Sleep -Seconds 1
		}
	}
	$end = Get-Date
	$duration = $end - $start
	Write-Host "Duration: $($duration.TotalSeconds) seconds"
	$DurationMessage = "Time taken: $($duration.TotalSeconds) seconds."
	if ($mp3.Count -gt 1) {
		$DurationMessage += "`nTime per file: $($duration.TotalSeconds / $mp3.Count) seconds."
	}
	Send-DiscordMessage -ChannelId $ChannelMessage.channel_id -Content $DurationMessage
}