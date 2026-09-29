# - - - - - - - - - - - - - - - - - - - - - - -
# Immich Homelab - Monitor de Estado
# - - - -- - - - --- - -- - - - - - - - - - - -

$RutaImmich = "C:\Immich"
$RutaBiblioteca = "C:\Immich\library"

Write-Host ""
Write-Host "       ESTADO DE IMMICH HOMELAB"
Write-Host ""

# --- Docker ---
Write-Host "[*] Comprobando Docker..."

try {
    docker info *> $null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Docker está funcionando"
    }
    else {
        Write-Host "[ERROR] Docker no responde"
    }
}
catch {
    Write-Host "[ERROR] Docker no está instalado o no está disponible"
}

# --- Servicios de Immich ---
Write-Host ""
Write-Host "[*] Comprobando servicios de Immich..."

Set-Location $RutaImmich

$Servicios = docker compose ps --services --filter "status=running"

$ServiciosEsperados = @(
    "immich-server",
    "immich-machine-learning",
    "database",
    "redis"
)

foreach ($Servicio in $ServiciosEsperados) {

    if ($Servicios -contains $Servicio) {
        Write-Host "[OK] $Servicio"
    }
    else {
        Write-Host "[ERROR] $Servicio no está funcionando"
    }
}

# --- Servidor web ---
Write-Host ""
Write-Host "[*] Comprobando servidor web de Immich..."

try {

    $Respuesta = Invoke-WebRequest `
        -Uri "http://localhost:2283" `
        -UseBasicParsing `
        -TimeoutSec 5

    Write-Host "[OK] El servidor web de Immich está respondiendo"

}
catch {

    Write-Host "[ERROR] El servidor web de Immich no responde"

}

# --- Almacenamiento ---
Write-Host ""
Write-Host "[*] Comprobando almacenamiento..."

$Disco = Get-PSDrive C

$EspacioLibreGB = [math]::Round($Disco.Free / 1GB, 2)
$EspacioUsadoGB = [math]::Round($Disco.Used / 1GB, 2)

Write-Host "Disco C:"
Write-Host "Usado: $EspacioUsadoGB GB"
Write-Host "Libre: $EspacioLibreGB GB"

if ($EspacioLibreGB -lt 15) {
    Write-Host "[ADVERTENCIA] Queda poco espacio disponible"
}
else {
    Write-Host "[OK] El espacio disponible es suficiente"
}

# --- Biblioteca de Immich ---
Write-Host ""
Write-Host "[*] Analizando biblioteca de Immich..."

if (Test-Path $RutaBiblioteca) {

    $Archivos = Get-ChildItem $RutaBiblioteca `
        -Recurse `
        -File `
        -ErrorAction SilentlyContinue

    $CantidadArchivos = $Archivos.Count

    $BytesBiblioteca = ($Archivos | Measure-Object Length -Sum).Sum
    $TamanoBibliotecaGB = [math]::Round($BytesBiblioteca / 1GB, 2)

    Write-Host "Archivos almacenados: $CantidadArchivos"
    Write-Host "Tamaño de biblioteca: $TamanoBibliotecaGB GB"

}
else {

    Write-Host "[ERROR] No se encontró la biblioteca de Immich"

}

Write-Host ""
Write-Host "        COMPROBACION FINALIZADA"
Write-Host ""