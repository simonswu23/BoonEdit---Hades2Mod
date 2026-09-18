# Pull one historical Hades II build's scripts + English text.
#   .\pull.ps1 -Manifest 4276993195635717987 -Label 24432219_2026-07-28 -User <steam-account>
param(
  [Parameter(Mandatory=$true)][string]$Manifest,
  [Parameter(Mandatory=$true)][string]$Label,
  [Parameter(Mandatory=$true)][string]$User
)
$arc = if ($env:HADES2_ARCHIVE) { $env:HADES2_ARCHIVE } else { "C:\Users\simon\Downloads\Hades2ScriptArchive" }
& "C:\Users\simon\Downloads\DepotDownloader\DepotDownloader.exe" `
    -app 1145350 -depot 1145352 -manifest $Manifest `
    -filelist "$arc\filelist.txt" `
    -dir "$arc\$Label" `
    -username $User -remember-password
