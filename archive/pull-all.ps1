# Pull every build listed in manifests.txt. Logs in once; -remember-password covers the rest.
#   .\pull-all.ps1 -User <steam-account>
param([Parameter(Mandatory=$true)][string]$User)
$arc = if ($env:HADES2_ARCHIVE) { $env:HADES2_ARCHIVE } else { "C:\Users\simon\Downloads\Hades2ScriptArchive" }
$dd  = "C:\Users\simon\Downloads\DepotDownloader\DepotDownloader.exe"
foreach ($line in Get-Content "$arc\manifests.txt") {
  if ($line -match '^\s*#' -or $line -notmatch ',') { continue }
  $label, $manifest = $line.Split(',', 2)
  if (-not $manifest.Trim()) { Write-Host "skip $label (no manifest id)"; continue }
  if (Test-Path "$arc\$label\Content\Scripts") { Write-Host "have $label"; continue }
  Write-Host "`n=== $label  ($manifest)"
  & $dd -app 1145350 -depot 1145352 -manifest $manifest.Trim() `
        -filelist "$arc\filelist.txt" -dir "$arc\$label" `
        -username $User -remember-password
}
