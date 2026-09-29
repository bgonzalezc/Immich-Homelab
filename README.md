# Immich Homelab

Nube privada de fotografías autoalojada utilizando Immich, Docker, PostgreSQL y PowerShell.

Este proyecto documenta la implementación, monitorización y administración de un servidor privado de fotografías ejecutado en Windows 11. El sistema permite respaldar fotografías y videos desde dispositivos móviles mediante la red local, manteniendo los archivos bajo control del usuario.

## Objetivos del proyecto

- Crear una alternativa privada a servicios tradicionales de almacenamiento fotográfico en la nube.
- Respaldar fotografías y videos desde dispositivos móviles.
- Mantener los archivos originales bajo control local.
- Monitorizar el estado de la infraestructura.
- Registrar históricamente el crecimiento del almacenamiento.
- Automatizar tareas administrativas mediante PowerShell.
- Implementar respaldos independientes del servidor.
- Diseñar una estrategia de recuperación ante fallos.
- Experimentar con Docker, redes, PostgreSQL e infraestructura autoalojada.

## Arquitectura

```text
                       RED LOCAL
                           │
                      Router Wi-Fi
                           │
              ┌────────────┴────────────┐
              │                         │
           iPhone                   Windows 11
              │                         │
              │                   Docker Desktop
              │                         │
              │              ┌──────────┴──────────┐
              │              │                     │
              └─────────► Immich Server        PostgreSQL
                             │
                    ┌────────┴────────┐
                    │                 │
                  Valkey      Machine Learning
                    │
                    ▼
             Biblioteca multimedia
```

## Tecnologías utilizadas

- Immich
- Docker
- Docker Compose
- PostgreSQL
- Valkey
- PowerShell
- Programador de tareas de Windows
- WSL2
- Git
- Windows 11

## Monitorización del sistema

El proyecto incorpora herramientas desarrolladas en PowerShell para comprobar el estado del servidor y monitorizar el almacenamiento utilizado por Immich.

### Comprobación de estado

El script `health-check.ps1` comprueba:

- Disponibilidad de Docker.
- Estado de Immich Server.
- Estado de PostgreSQL.
- Estado de Valkey.
- Estado del servicio Machine Learning.
- Disponibilidad del servidor web de Immich.
- Espacio utilizado en disco.
- Espacio disponible.
- Tamaño de la biblioteca.
- Cantidad de archivos almacenados.

Ejecución:

```powershell
.\scripts\health-check.ps1
```

## Monitor de almacenamiento

El script `monitor-almacenamiento.ps1` registra periódicamente información sobre el almacenamiento utilizado por el servidor.

Entre los datos registrados se encuentran:

- Fecha y hora de la medición.
- Cantidad de archivos.
- Tamaño de la biblioteca de Immich.
- Espacio utilizado en disco.
- Espacio disponible.
- Estado del almacenamiento.
- Crecimiento desde la medición anterior.
- Velocidad aproximada de crecimiento.
- Tiempo estimado hasta alcanzar la reserva mínima configurada.

Ejecución manual:

```powershell
.\scripts\monitor-almacenamiento.ps1
```

Las mediciones se almacenan localmente en:

```text
data/almacenamiento.csv
```

La carpeta `data/` está excluida de Git para evitar publicar información generada por cada instalación.

## Configuración local

El repositorio incluye:

```text
config.example.json
```

Para utilizar los monitores se debe crear una copia llamada:

```text
config.json
```

Ejemplo:

```json
{
  "rutaBiblioteca": "C:\\Immich\\library",
  "reservaMinimaGB": 15,
  "intervaloMonitoreoMinutos": 60
}
```

`config.json` está excluido del repositorio mediante `.gitignore`, permitiendo que cada instalación utilice sus propias rutas y parámetros.

## Monitorización automática

El proyecto permite ejecutar automáticamente el monitor de almacenamiento mediante el Programador de tareas de Windows.

Para instalar la tarea:

```powershell
.\scripts\instalar-monitoreo.ps1
```

El intervalo utilizado se obtiene desde:

```json
"intervaloMonitoreoMinutos": 60
```

Con esta configuración, el sistema registra una medición aproximadamente cada 60 minutos sin necesidad de mantener una ventana de PowerShell abierta.

La tarea creada se llama:

```text
Immich-Homelab-Monitor
```

Para comprobarla:

```powershell
Get-ScheduledTask -TaskName "Immich-Homelab-Monitor"
```

## Desinstalar la monitorización automática

Para eliminar la tarea programada:

```powershell
.\scripts\desinstalar-monitoreo.ps1
```

El desinstalador elimina únicamente la tarea automática.

El historial almacenado en `data/` no se elimina.

## Seguridad

La información sensible está excluida intencionalmente del repositorio.

Nunca deben almacenarse en GitHub:

- Archivos `.env` con credenciales reales.
- `config.json` de la instalación local.
- Contraseñas de PostgreSQL.
- Claves privadas.
- Datos internos de PostgreSQL.
- Fotografías y videos personales.
- Copias de seguridad con información privada.
- Historiales locales generados por los monitores.

El repositorio utiliza archivos de ejemplo como:

```text
.env.example
config.example.json
```

Estos permiten documentar la configuración sin publicar credenciales o información privada.

## Estrategia de respaldo

La arquitectura de respaldo planificada es:

```text
iPhone
   │
   ▼
Servidor Immich
   │
   ├── Biblioteca local
   │
   └── PostgreSQL
            │
            ▼
      Respaldo externo
```

El objetivo a largo plazo es aproximarse a una estrategia **3-2-1**:

- 3 copias de los datos importantes.
- 2 medios de almacenamiento diferentes.
- 1 copia almacenada independientemente del servidor principal.

> Immich no debe considerarse por sí solo como la única copia de seguridad de fotografías importantes.

Actualmente, el respaldo externo permanece como una mejora pendiente del proyecto.

## Estructura del repositorio

```text
immich-homelab/
│
├── scripts/
│   ├── health-check.ps1
│   ├── monitor-almacenamiento.ps1
│   ├── instalar-monitoreo.ps1
│   └── desinstalar-monitoreo.ps1
│
├── docs/
│
├── data/                       # Generado localmente e ignorado por Git
│
├── .env.example
├── config.example.json
├── .gitignore
└── README.md
```

La instalación real de Immich y la biblioteca multimedia permanecen separadas del repositorio.

```text
C:\Immich
        │
        └── Servidor y biblioteca privada

C:\Immich-Homelab
        │
        └── Código, automatización y documentación
```

Esta separación reduce el riesgo de añadir fotografías, bases de datos o credenciales accidentalmente al repositorio.

## Conocimientos aplicados

Este proyecto permite adquirir experiencia práctica en:

- Docker y Docker Compose.
- Aplicaciones contenerizadas.
- Persistencia mediante volúmenes.
- PostgreSQL.
- Administración de servicios.
- Redes locales.
- PowerShell.
- Automatización de tareas.
- Programador de tareas de Windows.
- Monitorización de infraestructura.
- Registro histórico de métricas.
- Gestión de configuración.
- Seguridad de credenciales.
- Estrategias de respaldo.
- Recuperación ante fallos.
- Git y GitHub.
- Servicios autoalojados.

## Estado del proyecto

Actualmente se encuentran operativos:

- Servidor Immich.
- Respaldo de fotografías y videos desde dispositivos móviles.
- Persistencia de la biblioteca multimedia.
- Persistencia de PostgreSQL.
- Monitor de estado del servidor.
- Monitor de almacenamiento.
- Historial de métricas.
- Estimación del crecimiento del almacenamiento.
- Monitorización automática mediante el Programador de tareas de Windows.

## Próximas mejoras

Entre las siguientes mejoras previstas se encuentran:

- Utilizar promedios de varias mediciones para mejorar las estimaciones de crecimiento.
- Crear gráficos históricos del almacenamiento.
- Desarrollar un dashboard de monitorización.
- Implementar alertas por poco espacio disponible.
- Automatizar respaldos de PostgreSQL.
- Incorporar un segundo dispositivo físico para copias de seguridad.
- Documentar procedimientos de recuperación ante fallos.
- Mejorar la portabilidad de los scripts entre diferentes instalaciones.

## Importante

Este repositorio contiene únicamente código, configuraciones de ejemplo, documentación y herramientas de automatización.

**No contiene fotografías, videos, contraseñas ni la base de datos privada de la instancia de Immich.**