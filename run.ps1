param($Timer)

while ($true) {
    # Keep run.ps1 running
    Start-Sleep -Seconds 1

    try {
        Write-Host "Invoking Invoke-DiscordBot.ps1 at $(Get-Date)"

        # Invoke the Discord bot script
        & $PSScriptRoot/Invoke-DiscordBot.ps1
    } catch {
        Write-Host "Error on Invoke-DiscordBot.ps1 invocation at $(Get-Date). Error: $_ - $($_.Exception.Message)"
        Write-Host "Restarting Invoke-DiscordBot.ps1 at $(Get-Date)"
    }
}
