class HdHomeRunRecording
{
    [string] $SeriesID
    [string] $Title   
    [string] $Category
    [string] $ImageURL   
    [string] $StartTime
    [string] $EpisodesURL
    [string] $UpdateID
}

class HdHomeRunEpisode
{
    [string] $Category
    [string] $ChannelAffiliate
    [string] $ChannelImageURL
    [string] $ChannelName
    [string] $ChannelNumber
    [int64]  $EndTime
    [string] $EpisodeNumber
    [string] $EpisodeTitle
    [string] $ImageURL
    [int64]  $OriginalAirdate
    [string] $ProgramID
    [int64]  $RecordEndTime
    [string] $RecordError
    [int64]  $RecordStartTime
    [string] $SeriesID
    [int64]  $StartTime
    [string] $Synopsis
    [string] $Title
    [string] $Filename
    [string] $PlayURL
    [string] $CmdURL
}

Function Get-HdHomeRunRecording
{
    <#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
        Get-hdhomeRunRecording | ? title -match "wwe" | Get-HdHomeRunEpisode | Save-HdHomeRunEpisode
    #>
    
    
    [CmdletBinding()]
    param([string] $HdHomeRun = "hdhomerun")

    $recordings = [HdHomeRunRecording[]] ((Invoke-WebRequest http://$HdHomeRun/recorded_files.json).Content | ConvertFrom-Json)
    Write-Output $recordings
}

Function Get-HdHomeRunEpisode
{
        <#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [HdHomeRunRecording] $Recording)

    begin{}
    end{}
    process{
        $episodeJson = @((Invoke-WebRequest $Recording.EpisodesURL).Content | ConvertFrom-Json)
        foreach($ep in $episodeJson)
        {
            $obj = New-Object HdHomeRunEpisode
            $obj.Category = $ep.Category
            $obj.ChannelAffiliate = $ep.ChannelAffiliate
            $obj.ChannelImageURL = $ep.ChannelImageURL
            $obj.ChannelName = $ep.ChannelName
            $obj.ChannelNumber = $ep.ChannelNumber
            $obj.EndTime = $ep.EndTime
            $obj.EpisodeNumber = $ep.EpisodeNumber
            $obj.EpisodeTitle = $ep.EpisodeTitle
            $obj.ImageURL = $ep.ImageURL
            $obj.OriginalAirdate = $ep.OriginalAirdate
            $obj.ProgramID = $ep.ProgramID
            $obj.RecordEndTime = $ep.RecordEndTime
            $obj.RecordError = $ep.RecordError
            $obj.RecordStartTime = $ep.RecordStartTime
            $obj.SeriesID = $ep.SeriesID
            $obj.StartTime = $ep.StartTime
            $obj.Synopsis = $ep.Synopsis
            $obj.Title = $ep.Title
            $obj.Filename = $ep.Filename
            $obj.PlayURL = $ep.PlayURL
            $obj.CmdURL = $ep.CmdURL

            Write-Output $obj
        }
    }
}

Function Remove-HdHomeRunEpisode
{
    <#
    .SYNOPSIS
    .DESCRIPTION
    .NOTES
    .LINK
    .EXAMPLE
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [HdHomeRunEpisode] $Episode,
        [switch] $ReRecord = $false)

    begin{}
    end{}
    process{
        $ReRecordVal = 0
        if($ReRecord){
            $ReRecordVal = 1
        }
        $url = $Episode.CmdURL + "&cmd=delete&rerecord=$ReRecordVal"
        Write-Verbose $url
        Invoke-WebRequest $url -Method Post

    }
}

Function Save-HdHomeRunEpisode{
        <#
    .SYNOPSIS
    .DESCRIPTION
    .NOTES
    .LINK
    .EXAMPLE
         Get-hdhomeRunRecording | ? title -match "wwe" | Get-HdHomeRunEpisode | Save-HdHomeRunEpisode
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [HdHomeRunEpisode] $Episode,
        $OutputFile = $null
    )
    begin{}
    end{}
    process{
        if($OutputFile -ne $null){
            Invoke-WebRequest $Episode.PlayURL -OutFile $OutputFile
        }
        else{
            Invoke-WebRequest $Episode.PlayURL -OutFile $Episode.Filename
        }
    }
}