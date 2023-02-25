function Get-AnimeById {
    [CmdletBinding()]
    param( [int] $Id )
    # Here we define our query as a multi-line string
    $Query = 'query ($id: Int) {
        Media (id: $id, type: ANIME) {
          id
          title {
            romaji
            english
            native
          }
        }
      }
    '
    
    
    # Define our query variables and values that will be used in the query request
    $Variables = @{
        id = $Id
    }
    
    $Body = @{
        query = $Query
        variables = $Variables
    } | ConvertTo-Json -Depth 10
    
    $Url = 'https://graphql.anilist.co'
    
    $Headers = @{
        'Content-Type' = 'application/json'
        'Accept'       = 'application/json'
    }
    
    # Make the HTTP Api request
    $response = (Invoke-WebRequest -Method Post -Uri $Url -Body $Body -ContentType 'application/json' -Headers $Headers).Content
    return $response
}


function Get-AnimeBySearchText {
    [CmdletBinding()]
    param( [string] $SearchText, [int] $Quantity = 1 )

    # Here we define our query as a multi-line string
    $Query = 'query ($query: String, $type: MediaType) {
        Page {
          media(search: $query, type: $type) {
            id
            title {
              romaji
              english
              native
            }
            coverImage {
              medium
              large
            }
            format
            type
            averageScore
            popularity
            episodes
            season
            hashtag
            isAdult
            startDate {
              year
              month
              day
            }
            endDate {
              year
              month
              day
            }
          }
        }
      }
    '
    
    # Define our query variables and values that will be used in the query request
    $Variables = @{
        query = $SearchText
        type = 'ANIME'
    }
    
    $Body = @{
        query = $Query
        variables = $Variables
    } | ConvertTo-Json -Depth 10
    
    $Url = 'https://graphql.anilist.co'
    
    $Headers = @{
        'Content-Type' = 'application/json'
        'Accept'       = 'application/json'
    }
    
    # Make the HTTP Api request
    $Response = (Invoke-WebRequest -Method Post -Uri $Url -Body $Body -ContentType 'application/json' -Headers $Headers).Content

    return ($Response | convertfrom-json -depth 100).data.Page.media | Select-Object -first $Quantity | ConvertTo-Json -depth 100
}



function Get-IPInfo {
    [CmdletBinding()]
    param( 
        [Parameter()]
        $IPAddress 
    )
    
    $Collection = @()

    foreach ($ip in $IPAddress) {
        $Collection += Invoke-RestMethod -Uri "http://ip-api.com/json/$ip"
        Start-Sleep -Milliseconds 100
    }
    # this returns a collection because it can get multiple ip addresses at same time from "lookup domain" bot command
    return $Collection
}

function Get-DnsInfo {
    [CmdletBinding()]
    param( 
        [Parameter()]
        $Domain 
    )

    $Info = [System.Net.Dns]::GetHostEntry($Domain)
    return $Info
}

function Enable-PrefixedModule {
    [CmdletBinding()]
    param( 
        [Parameter()]
        $Name 
    )

    $file = Get-ChildItem -Path "$PSScriptRoot/../../Inactive/Logic/$Name.ps1" -ErrorAction SilentlyContinue

    if ($file) {
        Move-Item -Path $file.FullName -Destination "$PSScriptRoot/../Logic/$Name.ps1"
        return $true
    } 
    
    if ($null -ne $file) {
        return $false
    }
}

function Enable-UnprefixedModule {
    [CmdletBinding()]
    param( 
        [Parameter()]
        $Name 
    )

    $file = Get-ChildItem -Path "$PSScriptRoot/../../Inactive/Unprefixed/$Name.ps1" -ErrorAction SilentlyContinue

    if ($file) {
        Move-Item -Path $file.FullName -Destination "$PSScriptRoot/../Unprefixed/$Name.ps1"
        return $true
    } 
    
    if ($null -ne $file) {
        return $false
    }
}

function Disable-PrefixedModule {
    [CmdletBinding()]
    param( 
        [Parameter()]
        $Name 
    )

    $file = Get-ChildItem -Path "$PSScriptRoot/../Logic/$Name.ps1" -ErrorAction SilentlyContinue

    if ($file) {
        Move-Item -Path $file.FullName -Destination "$PSScriptRoot/../../Inactive/Logic/$Name.ps1"
        return $true
    } 
    
    if ($null -ne $file) {
        return $false
    }
    
}

function Disable-UnprefixedModule {
    [CmdletBinding()]
    param( 
        [Parameter()]
        $Name 
    )

    $file = Get-ChildItem -Path "$PSScriptRoot/../Unprefixed/$Name.ps1" -ErrorAction SilentlyContinue

    if ($file) {
        Move-Item -Path $file.FullName -Destination "$PSScriptRoot/../../Inactive/Unprefixed/$Name.ps1"
        return $true
    } 
  
    if ($null -ne $file) {
        return $false
    }
    
}