# Canary, local run 1: Vivado synthesis in non-project mode, one Vivado process per canary.
# Run from the repository root of the canary branch, in a shell where vivado is on PATH
# (or pass -Vivado with the full path). Commands and flags: verify in your version.
#   powershell -ExecutionPolicy Bypass -File canary\run_vivado_synth.ps1 -Mode default
#   powershell -ExecutionPolicy Bypass -File canary\run_vivado_synth.ps1 -Mode sv
# Results: canary\logs\vivado_<mode>\summary.txt and one log per canary.
param(
    [ValidateSet('default', 'sv')]
    [string] $Mode = 'default',
    [string] $Vivado = 'vivado',
    [string] $Part = 'xc7z020clg484-1'   # ZedBoard
)

$Root = Split-Path -Parent $PSScriptRoot
$Src = Join-Path $Root 'src'
. (Join-Path $PSScriptRoot 'canary_list.ps1')

$OutDir = Join-Path $PSScriptRoot "logs\vivado_$Mode"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$Summary = Join-Path $OutDir 'summary.txt'
$Tcl = Join-Path $PSScriptRoot 'synth_one.tcl'

Set-Content -Path $Summary -Value "vivado synth_design, mode=$Mode, part=$Part, $(Get-Date -Format s)"
Add-Content -Path $Summary -Value ((& $Vivado -version) -join "`n")

foreach ($c in $Canaries) {
    $files = @($c.Files | ForEach-Object { (Join-Path $Src $_) -replace '\\', '/' })
    $log = Join-Path $OutDir "$($c.Top).log"
    Push-Location $OutDir
    & $Vivado -mode batch -nojournal -log $log -source $Tcl -tclargs $c.Top $Mode $Part @files | Out-Null
    $code = $LASTEXITCODE
    Pop-Location
    $result = Select-String -Path $log -Pattern '^CANARY_RESULT' | Select-Object -Last 1
    $text = if ($result) { $result.Line } else { '(no CANARY_RESULT line, see the log)' }
    $msg = '{0,-22} exit={1}  {2}' -f $c.Top, $code, $text
    Write-Host $msg
    Add-Content -Path $Summary -Value $msg
}
