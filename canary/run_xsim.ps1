# Canary, local run 2: Vivado Simulator compile (xvlog) and elaboration (xelab), one work folder per canary.
# Run from the repository root of the canary branch, in a shell where xvlog and xelab are on PATH.
# Commands and flags (including --sv): verify in your version.
#   powershell -ExecutionPolicy Bypass -File canary\run_xsim.ps1 -Mode default
#   powershell -ExecutionPolicy Bypass -File canary\run_xsim.ps1 -Mode sv
# Results: canary\logs\xsim_<mode>\summary.txt; xvlog.log and xelab.log in each canary folder.
param(
    [ValidateSet('default', 'sv')]
    [string] $Mode = 'default'
)

$Root = Split-Path -Parent $PSScriptRoot
$Src = Join-Path $Root 'src'
. (Join-Path $PSScriptRoot 'canary_list.ps1')

$OutDir = Join-Path $PSScriptRoot "logs\xsim_$Mode"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$Summary = Join-Path $OutDir 'summary.txt'

Set-Content -Path $Summary -Value "xvlog + xelab, mode=$Mode, $(Get-Date -Format s)"
Add-Content -Path $Summary -Value ((& xvlog --version) -join "`n")

foreach ($c in $Canaries) {
    $work = Join-Path $OutDir $c.Top
    New-Item -ItemType Directory -Force -Path $work | Out-Null
    $files = @($c.Files | ForEach-Object { Join-Path $Src $_ })
    $xvlogArgs = @()
    if ($Mode -eq 'sv') { $xvlogArgs += '--sv' }
    Push-Location $work
    & xvlog @xvlogArgs @files | Out-Null
    $c1 = $LASTEXITCODE
    $c2 = 'skipped'
    if ($c1 -eq 0) {
        & xelab $c.Top -s "$($c.Top)_snap" | Out-Null
        $c2 = $LASTEXITCODE
    }
    Pop-Location
    $msg = '{0,-22} xvlog={1}  xelab={2}' -f $c.Top, $c1, $c2
    Write-Host $msg
    Add-Content -Path $Summary -Value $msg
}
