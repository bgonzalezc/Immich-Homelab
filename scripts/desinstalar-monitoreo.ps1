# ============================================
# Immich Homelab - Desinstalador de Monitoreo
# ============================================

$NombreTarea = "Immich-Homelab-Monitor"

Write-Host ""
Write-Host "========================================="
Write-Host "   DESINSTALADOR DE MONITOREO AUTOMATICO"
Write-Host "========================================="
Write-Host ""

$Tarea = Get-ScheduledTask `
    -TaskName $NombreTarea `
    -ErrorAction SilentlyContinue

if ($null -eq $Tarea) {
    Write-Host "[INFO] La tarea '$NombreTarea' no esta instalada."
    exit 0
}

Unregister-ScheduledTask `
    -TaskName $NombreTarea `
    -Confirm:$false

Write-Host "[OK] Monitoreo automatico desinstalado."
Write-Host ""
Write-Host "Tarea eliminada: $NombreTarea"
Write-Host ""
Write-Host "El historial almacenado en data\ no fue eliminado."