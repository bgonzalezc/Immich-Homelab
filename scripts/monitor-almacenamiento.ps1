# ============================================
# Immich Homelab - Monitor de Almacenamiento
# ============================================

# ============================================
# Configuracion
# ============================================

# ============================================
# Configuracion
# ============================================

# Detectar automaticamente la raiz del proyecto
$RutaProyecto = Split-Path -Parent $PSScriptRoot

# Archivo de configuracion local
$RutaConfiguracion = Join-Path $RutaProyecto "config.json"

if (!(Test-Path $RutaConfiguracion)) {
    Write-Host "[ERROR] No se encontro config.json"
    Write-Host ""
    Write-Host "Crea el archivo a partir de:"
    Write-Host "config.example.json"
    exit 1
}

# Leer configuracion
$Configuracion = Get-Content $RutaConfiguracion -Raw | ConvertFrom-Json

$RutaBiblioteca = $Configuracion.rutaBiblioteca
$ReservaMinimaGB = $Configuracion.reservaMinimaGB

# Datos generados por el monitor
$RutaDatos = Join-Path $RutaProyecto "data"
$ArchivoHistorial = Join-Path $RutaDatos "almacenamiento.csv"

Write-Host ""
Write-Host "========================================="
Write-Host "    MONITOR DE ALMACENAMIENTO IMMICH"
Write-Host "========================================="
Write-Host ""

# Crear carpeta de datos si no existe
if (!(Test-Path $RutaDatos)) {
    New-Item -ItemType Directory -Path $RutaDatos | Out-Null
    Write-Host "[OK] Carpeta de datos creada"
}

# Comprobar biblioteca
if (!(Test-Path $RutaBiblioteca)) {
    Write-Host "[ERROR] No se encontro la biblioteca de Immich"
    exit 1
}

Write-Host "[*] Analizando biblioteca..."

# Obtener archivos
$Archivos = Get-ChildItem $RutaBiblioteca `
    -Recurse `
    -File `
    -ErrorAction SilentlyContinue

$CantidadArchivos = $Archivos.Count

$BytesBiblioteca = ($Archivos | Measure-Object Length -Sum).Sum

if ($null -eq $BytesBiblioteca) {
    $BytesBiblioteca = 0
}

$BibliotecaGB = [math]::Round($BytesBiblioteca / 1GB, 2)

# Obtener informacion del disco
$Disco = Get-PSDrive C

$LibreGB = [math]::Round($Disco.Free / 1GB, 2)
$UsadoGB = [math]::Round($Disco.Used / 1GB, 2)

# Fecha actual
$Fecha = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host ""
Write-Host "Fecha:               $Fecha"
Write-Host "Archivos:            $CantidadArchivos"
Write-Host "Biblioteca Immich:   $BibliotecaGB GB"
Write-Host "Disco usado:         $UsadoGB GB"
Write-Host "Disco libre:         $LibreGB GB"

# Estado del almacenamiento
if ($LibreGB -lt 10) {
    $Estado = "CRITICO"
}
elseif ($LibreGB -lt 20) {
    $Estado = "ADVERTENCIA"
}
else {
    $Estado = "SALUDABLE"
}

Write-Host "Estado:              $Estado"

# Crear medicion
$Medicion = [PSCustomObject]@{
    Fecha            = $Fecha
    Archivos         = $CantidadArchivos
    BibliotecaGB     = $BibliotecaGB
    DiscoUsadoGB     = $UsadoGB
    DiscoLibreGB     = $LibreGB
    Estado           = $Estado
}

# Guardar historial
if (Test-Path $ArchivoHistorial) {

    $Medicion | Export-Csv `
        -Path $ArchivoHistorial `
        -Append `
        -NoTypeInformation `
        -Encoding UTF8

}
else {

    $Medicion | Export-Csv `
        -Path $ArchivoHistorial `
        -NoTypeInformation `
        -Encoding UTF8
}

Write-Host ""
Write-Host "[OK] Medicion guardada en el historial"

# Mostrar mediciones anteriores
$Historial = Import-Csv $ArchivoHistorial

Write-Host "Mediciones registradas: $($Historial.Count)"

# ============================================
# Analisis de tendencia
# ============================================

if ($Historial.Count -ge 2) {

    $Anterior = $Historial[-2]
    $Actual = $Historial[-1]

    # Convertir fechas
    $FechaAnterior = [datetime]::ParseExact(
        $Anterior.Fecha,
        "yyyy-MM-dd HH:mm:ss",
        $null
    )

    $FechaActual = [datetime]::ParseExact(
        $Actual.Fecha,
        "yyyy-MM-dd HH:mm:ss",
        $null
    )

    $HorasTranscurridas = ($FechaActual - $FechaAnterior).TotalHours

    # El CSV usa coma decimal según la configuración regional de Windows
$Cultura = [System.Globalization.CultureInfo]::GetCultureInfo("es-CL")

$BibliotecaAnterior = [double]::Parse(
    $Anterior.BibliotecaGB,
    $Cultura
)

$BibliotecaActual = [double]::Parse(
    $Actual.BibliotecaGB,
    $Cultura
)
    $CrecimientoGB = $BibliotecaActual - $BibliotecaAnterior
    $CrecimientoGB = [math]::Round($CrecimientoGB, 3)

    if ($HorasTranscurridas -gt 0 -and $CrecimientoGB -gt 0) {

        $VelocidadGBHora = $CrecimientoGB / $HorasTranscurridas
        $VelocidadGBHora = [math]::Round($VelocidadGBHora, 2)

        Write-Host ""
        Write-Host "--------- TENDENCIA ---------"
        Write-Host "Crecimiento:          $CrecimientoGB GB"
        Write-Host "Velocidad actual:     $VelocidadGBHora GB/h"

        # Consideramos 15 GB como reserva de seguridad
        $EspacioUtilGB = $LibreGB - $ReservaMinimaGB

        if ($EspacioUtilGB -gt 0) {

            $HorasRestantes = $EspacioUtilGB / $VelocidadGBHora
            $HorasRestantes = [math]::Round($HorasRestantes, 1)

            Write-Host "Margen antes de $($ReservaMinimaGB)GB: $([math]::Round($EspacioUtilGB, 2)) GB"
            Write-Host "Tiempo estimado:      $HorasRestantes horas"

        }
        else {

            Write-Host "[ADVERTENCIA] Ya se alcanzo la reserva minima de $ReservaMinimaGB GB"

        }

        Write-Host "-----------------------------"
        Write-Host ""
        Write-Host "NOTA: La estimacion representa la velocidad"
        Write-Host "actual de transferencia y no el crecimiento"
        Write-Host "normal de la biblioteca."

    }
    else {

        Write-Host ""
        Write-Host "[INFO] No se detecto crecimiento suficiente para calcular tendencia."

    }
}

Write-Host ""
Write-Host "========================================="
Write-Host "          MONITOREO FINALIZADO"
Write-Host "========================================="
Write-Host ""