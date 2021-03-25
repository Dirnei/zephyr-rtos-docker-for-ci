function Start-Ci() {
    Param(
        [Parameter(Mandatory = $False)]
        [Switch]$VerboseLog,
        [Parameter(Mandatory = $False)]
        [Switch]$Clean,
        [Parameter(Mandatory = $False)]
        [String]$Board,
        [Parameter(Mandatory = $True)]
        [String]$ProjectPath,
        [Parameter(Mandatory = $False)]
        [String]$BuildPath,
        [Parameter(Mandatory = $False)]
        [String[]]$ExtraCFlags,
        [Parameter(Mandatory = $False)]
        [String[]]$ExtraCxxFlags
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

    if ($BuildPath.Length -eq 0) {
        $BuildPath = "~/build"
    }
    
    if (-not(Test-Path $BuildPath)) {
        New-Item -ItemType Directory -Path $BuildPath
    }
    
    $BuildPath = Resolve-Path $BuildPath

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
    Write-Host " Build path   : " $BuildPath
    Write-Host " Caller path  : " $StartLocation
    Write-Host " Script path  : " $PSScriptRoot
    Write-Host "-----------------------------------------------------------------------------"
    
    if ($Clean -and (Test-Path $BuildPath)) {
        Remove-item -Path $BuildPath -Recurse -Force -InformationAction SilentlyContinue
        Write-Host -ForegroundColor Green " Build directory cleaned!"
    }
    
    $params = @{
        'p' = "auto"
        'd' = $BuildPath
        'b' = $config.boardname
    }
    
    $paramString = $params.Keys | ForEach-Object { "-$_" + $params.Item($_) }
    Set-Location "~/zephyrproject/zephyr"
    
    try {
        $voidOutput = "Used to speed up output."
        
        if ($ExtraCFlags.Length -ne 0) {
            $EXTRA_CMAKE_C_FLAGS = "-DEXTRA_CFLAGS="
            
            foreach ($flag in $ExtraCFlags) {
                $EXTRA_CMAKE_C_FLAGS += "-$flag "
            }
        }
        
        if ($ExtraCxxFlags.Length -ne 0) {
            $EXTRA_CMAKE_CXX_FLAGS = "-DEXTRA_CXXFLAGS="
            
            foreach ($flag in $ExtraCFlags) {
                $EXTRA_CMAKE_CXX_FLAGS += "-$flag "
            }
        }
        
        Write-Host " EXTRA C FLAGS   : " $EXTRA_CMAKE_C_FLAGS
        Write-Host " EXTRA CXX FLAGS : " $EXTRA_CXXMAKE_C_FLAGS
        Write-Host "-----------------------------------------------------------------------------"
        
        
        if ($VerboseLog) {
            west -v build $paramString $ProjectPath -- $EXTRA_CMAKE_C_FLAGS $EXTRA_CMAKE_CXX_FLAGS *>&1 | Tee-Object -Variable $voidOutput
        }
        else {
            Write-Host "west build $paramString $ProjectPath -- $EXTRA_CMAKE_C_FLAGS $EXTRA_CMAKE_CXX_FLAGS *>&1 | Tee-Object -Variable `$voidOutput"
            west build $paramString $ProjectPath -- $EXTRA_CMAKE_C_FLAGS $EXTRA_CMAKE_CXX_FLAGS *>&1 | Tee-Object -Variable $voidOutput
        }
        
    }
    finally {
        Set-Location $StartLocation
        exit $LASTEXITCODE
    }
}

Write-Host
Write-Host "        ███████ ███████ ██████  ██   ██ ██    ██ ██████       ██████ ██"
Write-Host "           ███  ██      ██   ██ ██   ██  ██  ██  ██   ██     ██      ██"
Write-Host "          ███   █████   ██████  ███████   ████   ██████      ██      ██"
Write-Host "         ███    ██      ██      ██   ██    ██    ██   ██     ██      ██"
Write-Host "        ███████ ███████ ██      ██   ██    ██    ██   ██      ██████ ██"
Write-Host