# Roda a suite de testes do jogo (tests/test_*.tscn) em modo headless.
# Uso (PowerShell, na pasta do projeto):
#   .\tests\rodar_testes.ps1
#   .\tests\rodar_testes.ps1 -Godot "C:\caminho\Godot_v4.7.2-stable_win64_console.exe"
#   .\tests\rodar_testes.ps1 -Filtro hud        # so testes com "hud" no nome
#   .\tests\rodar_testes.ps1 -Prototipos        # inclui prototipos/vega_2d/tests
param(
    [string]$Godot = $env:GODOT,
    [string]$Filtro = "",
    [int]$TempoLimite = 180,
    [switch]$Prototipos
)

$projeto = Split-Path -Parent $PSScriptRoot

if (-not $Godot) {
    $candidatos = Get-ChildItem -Path "$env:USERPROFILE\Downloads" -Recurse -Depth 3 -Filter "Godot*win64*.exe" -ErrorAction SilentlyContinue |
        Sort-Object { $_.Name -notlike "*console*" }, Name
    if ($candidatos) { $Godot = $candidatos[0].FullName }
}
if (-not $Godot -or -not (Test-Path $Godot)) {
    Write-Host "Nao encontrei a Godot. Passe -Godot <caminho do .exe> ou defina `$env:GODOT." -ForegroundColor Red
    exit 2
}
Write-Host "Godot: $Godot"
Write-Host "Projeto: $projeto"

Write-Host "`n== Importando recursos (primeira vez apos mover arquivos pode demorar)"
& $Godot --headless --path $projeto --import 2>&1 | Out-Null
Write-Host "Importacao terminou com codigo $LASTEXITCODE"

$pastas = @("tests")
if ($Prototipos) { $pastas += "prototipos/vega_2d/tests" }
$cenas = foreach ($p in $pastas) {
    Get-ChildItem -Path (Join-Path $projeto $p) -Filter "test_*.tscn" | Where-Object { $_.Name -like "*$Filtro*" }
}

$falhas = @()
$i = 0
foreach ($cena in $cenas) {
    $i++
    $rel = "res://" + ($cena.FullName.Substring($projeto.Length + 1) -replace "\\", "/")
    $log = Join-Path $env:TEMP ("godot_" + $cena.BaseName + ".log")
    $proc = Start-Process -FilePath $Godot -ArgumentList @("--headless", "--path", "`"$projeto`"", $rel) `
        -NoNewWindow -PassThru -RedirectStandardOutput $log -RedirectStandardError "$log.err"
    if (-not $proc.WaitForExit($TempoLimite * 1000)) {
        $proc.Kill(); $codigo = "tempo esgotado"
    } else { $codigo = $proc.ExitCode }
    $erros = Select-String -Path $log, "$log.err" -Pattern "SCRIPT ERROR|FALHA" -ErrorAction SilentlyContinue
    if ($codigo -ne 0 -or $erros) {
        $falhas += [pscustomobject]@{ Teste = $cena.BaseName; Codigo = $codigo; Log = $log }
        Write-Host ("[{0}/{1}] FALHOU  {2} (codigo {3})" -f $i, $cenas.Count, $cena.BaseName, $codigo) -ForegroundColor Red
    } else {
        Write-Host ("[{0}/{1}] ok      {2}" -f $i, $cenas.Count, $cena.BaseName) -ForegroundColor Green
    }
}

Write-Host ("`n== {0}/{1} cenas passaram" -f ($cenas.Count - $falhas.Count), $cenas.Count)
if ($falhas) {
    $falhas | Format-Table -AutoSize
    exit 1
}
exit 0
