function Start-Ci(){Param(
    [Parameter(Mandatory = $False)]
    [Switch]$VerboseLog,
    [Parameter(Mandatory = $False)]
    [Switch]$Clean,
    [Parameter(Mandatory = $False)]
    [String]$Board,
    [Parameter(Mandatory = $True)]
    [String]$ProjectPath
)

$ProjectPath = Resolve-Path $ProjectPath

function Test-Config() {
    if ((Test-Path("$ProjectPath/build.config")) -or (Test-Path("$ProjectPath/../build.config"))) {
        return $True
    }

    return $false
}

function Get-Config() {
    if (Test-Path("$ProjectPath/build.config")) {
        return Get-Content -Raw "$ProjectPath/build.config" | ConvertFrom-Json
    }
    else {
        return Get-Content -Raw "$ProjectPath/../build.config" | ConvertFrom-Json
    }
}

if (Test-Path("$ProjectPath/.git")) {
    $buildPath = "$ProjectPath/build"
} else {
    $buildPath = "$ProjectPath/../build"
}

$config = @{};
$config.boardname = $Board

$StartLocation = ${pwd}

if (Test-Config) {
    $config = Get-Config
}

if (($Board -ne $config.boardname) -And ($Board.Length -gt 0)) {
    Write-Host -ForegroundColor Red "Override Board to: " -NoNewline    
    Write-Host $Board
    $config.boardname = $Board
}

Write-Host -ForegroundColor Green "Current config:"
Write-Host "-----------------------------------------------------------------------------"
Write-Host " Board        : " $config.boardname
Write-Host " Zephyr path  :  /home/vsts/zephyrproject/zephyr" 
Write-Host "------------------------------- Resolved ------------------------------------"
Write-Host " Project path : " $ProjectPath
Write-Host " Build path   : " $buildPath
Write-Host " Caller path  : " $StartLocation
Write-Host " Script path  : " $PSScriptRoot
Write-Host "-----------------------------------------------------------------------------"

if ($Clean -and (Test-Path $buildPath)) {
    Write-Host -ForegroundColor Green "Build directory cleaned!"
    Remove-item -Path $buildPath -Recurse -Force -InformationAction SilentlyContinue
}

$params = @{
    'p' = "auto"
    'd' = $buildPath
    'b' = $config.boardname
}

$paramString = $params.Keys | ForEach-Object { "-$_" + $params.Item($_) }

Set-Location "~/zephyrproject/zephyr"

$voidOutput = "Used to speed up output."
if ($VerboseLog) {
    west -v build $paramString $ProjectPath *>&1 | Tee-Object -Variable $voidOutput
}
else {
    west build $paramString $ProjectPath *>&1 | Tee-Object -Variable $voidOutput
}

Set-Location $StartLocation
}
Write-Host
Write-Host "        ███████ ███████ ██████  ██   ██ ██    ██ ██████       ██████ ██"
Write-Host "           ███  ██      ██   ██ ██   ██  ██  ██  ██   ██     ██      ██"
Write-Host "          ███   █████   ██████  ███████   ████   ██████      ██      ██"
Write-Host "         ███    ██      ██      ██   ██    ██    ██   ██     ██      ██"
Write-Host "        ███████ ███████ ██      ██   ██    ██    ██   ██      ██████ ██"
Write-Host