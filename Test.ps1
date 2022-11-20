import-Module -Force .\HDHomeRun.psm1 
$Recordings = Get-HdHomeRunRecording 
$episodes = $Recordings | ? Title -match "penn" | Get-HdHomeRunEpisode | Select-Object -First 1
$episodes | Save-HdHomeRunEpisode