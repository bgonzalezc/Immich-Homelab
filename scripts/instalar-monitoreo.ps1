# ============================================
# Immich Homelab - Instalador de Monitoreo
# ============================================

$RutaProyecto = Split-Path -Parent $PSScriptRoot
$RutaConfiguracion = Join-Path $RutaProyecto "config.json"
$RutaMonitor = Join-Path $PSScriptRoot "monitor-almacenamiento.ps1"

$NombreTarea = "Immich-Homelab-Monitor"
# Obtener usuario actual con dominio/equipo
$UsuarioActual = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

Write-Host ""
Write-Host "========================================="
Write-Host "   INSTALADOR DE MONITOREO AUTOMATICO"
Write-Host "========================================="
Write-Host ""

# Comprobar configuracion
if (!(Test-Path $RutaConfiguracion)) {
    Write-Host "[ERROR] No se encontro config.json"
    Write-Host "Crea config.json a partir de config.example.json."
    exit 1
}

# Comprobar monitor
if (!(Test-Path $RutaMonitor)) {
    Write-Host "[ERROR] No se encontro monitor-almacenamiento.ps1"
    exit 1
}

# Leer configuracion
$Configuracion = Get-Content $RutaConfiguracion -Raw | ConvertFrom-Json

$IntervaloMinutos = [int]$Configuracion.intervaloMonitoreoMinutos

if ($IntervaloMinutos -lt 1) {
    Write-Host "[ERROR] El intervalo de monitoreo no es valido."
    exit 1
}

Write-Host "Intervalo configurado: $IntervaloMinutos minutos"
Write-Host "Script: $RutaMonitor"
Write-Host ""

# Ejecutar PowerShell sin ventana interactiva
$Argumentos = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$RutaMonitor`""

$Accion = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument $Argumentos

# Primera ejecucion dentro de un minuto.
$Inicio = (Get-Date).AddMinutes(1)

$Trigger = New-ScheduledTaskTrigger `
    -Once `
    -At $Inicio `
    -RepetitionInterval (New-TimeSpan -Minutes $IntervaloMinutos)

# Ejecutar si el equipo esta disponible.
$ConfiguracionTarea = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries

$Principal = New-ScheduledTaskPrincipal `
    -UserId $UsuarioActual `
    -LogonType Interactive `
    -RunLevel Limited

# Registrar o actualizar tarea
Register-ScheduledTask `
    -TaskName $NombreTarea `
    -Action $Accion `
    -Trigger $Trigger `
    -Settings $ConfiguracionTarea `
    -Principal $Principal `
    -Description "Monitor automatico de almacenamiento para Immich Homelab" `
    -Force | Out-Null
    

Write-Host "[OK] Monitoreo automatico instalado."
Write-Host ""
Write-Host "Tarea:       $NombreTarea"
Write-Host "Intervalo:   cada $IntervaloMinutos minutos"
Write-Host "Primera vez: $Inicio"
Write-Host ""
Write-Host "No es necesario mantener PowerShell abierto."
Write-Host ""