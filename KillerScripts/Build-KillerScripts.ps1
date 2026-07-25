#Requires -Version 5.1
<#
    Build-KillerScripts.ps1

    Refresh the shipped manifest from the killer-scripts repo, regenerate the
    module's exported command list, bump the patch version, and print the
    publish command. Run this whenever you add or rename a script in the repo.
#>
[CmdletBinding()]
param(
    [string]$RawBase = 'https://raw.githubusercontent.com/SteveTheKiller/killer-scripts/main/'
)

$ErrorActionPreference = 'Stop'
$here    = Split-Path -Parent $MyInvocation.MyCommand.Path
$psd1    = Join-Path $here 'KillerScripts.psd1'
$descOut = Join-Path $here 'descriptions.json'

# 1. Pull the latest descriptions.json from the repo.
[Net.ServicePointManager]::SecurityProtocol =
    [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$json = (Invoke-WebRequest -Uri ($RawBase + 'descriptions.json') -UseBasicParsing).Content
[System.IO.File]::WriteAllText($descOut, $json)
$manifest = $json | ConvertFrom-Json

# 2. Build the export lists from the script names.
$functions = @('Get-KillerScript', 'Invoke-KillerScript', 'Update-KillerScripts')
$aliases   = @()
# Custom short aliases for scripts whose lowercase name would collide with a
# built-in. Keep this in sync with $script:AliasOverrides in KillerScripts.psm1.
$aliasOverrides = @{ 'PRINT.ps1' = 'KillerPrint' }

foreach ($p in $manifest.PSObject.Properties) {
    if ($p.Name -notlike '*.ps1') { continue }
    $base       = $p.Name -replace '\.ps1$', ''
    $functions += "Invoke-$base"
    $short = if ($aliasOverrides.ContainsKey($p.Name)) { $aliasOverrides[$p.Name] } else { $base.ToLower() }
    # Skip an alias that collides with an existing command (e.g. print.exe).
    if (-not (Get-Command -Name $short -ErrorAction SilentlyContinue)) {
        $aliases += $short
    }
}

# 3. Bump the patch version.
$current = (Import-PowerShellDataFile -Path $psd1).ModuleVersion
$v       = [version]$current
$next    = [version]::new($v.Major, $v.Minor, $v.Build + 1)

# 4. Write it back into the manifest.
Update-ModuleManifest -Path $psd1 `
    -ModuleVersion $next `
    -FunctionsToExport $functions `
    -AliasesToExport $aliases

Write-Host "KillerScripts manifest updated: $($functions.Count) functions, $($aliases.Count) aliases, version $next."
Write-Host ''
Write-Host 'To publish:'
Write-Host "  Publish-Module -Path '$here' -NuGetApiKey <your PSGallery key>"
