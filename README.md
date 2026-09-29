\# Immich Homelab



Nube privada de fotografías autoalojada utilizando Immich, Docker y PostgreSQL.



Este proyecto documenta la implementación y administración de un servidor privado de fotografías ejecutado en un computador con Windows 11, permitiendo respaldar automáticamente fotografías y videos desde dispositivos móviles a través de la red local.



\## Objetivos del proyecto



\- Crear una alternativa privada a los servicios tradicionales de almacenamiento de fotografías en la nube.

\- Respaldar fotografías y videos desde dispositivos móviles.

\- Mantener los archivos originales bajo control local.

\- Monitorizar el estado de la infraestructura.

\- Controlar el crecimiento del almacenamiento.

\- Implementar respaldos automatizados.

\- Diseñar una estrategia de recuperación ante fallos.

\- Experimentar con Docker, redes, PowerShell e infraestructura autoalojada.



\##  Arquitectura



```text

&#x20;                      RED LOCAL

&#x20;                          │

&#x20;                     Router Wi-Fi

&#x20;                          │

&#x20;             ┌────────────┴────────────┐

&#x20;             │                         │

&#x20;          iPhone                   Windows 11

&#x20;             │                         │

&#x20;             │                   Docker Desktop

&#x20;             │                         │

&#x20;             │             ┌───────────┴───────────┐

&#x20;             │             │                       │

&#x20;             └────────► Immich Server          PostgreSQL

&#x20;                           │                       │

&#x20;                    Machine Learning           Base de datos

&#x20;                           │

&#x20;                    Biblioteca multimedia

```



\##  Tecnologías utilizadas



\- Immich

\- Docker

\- Docker Compose

\- PostgreSQL

\- Valkey

\- PowerShell

\- WSL2

\- Git

\- Windows 11



\##  Monitorización del sistema



El proyecto incluye un script desarrollado en PowerShell que comprueba automáticamente:



\- Disponibilidad de Docker.

\- Estado de Immich Server.

\- Estado de PostgreSQL.

\- Estado de Valkey.

\- Estado del servicio Machine Learning.

\- Disponibilidad del servidor web de Immich.

\- Espacio utilizado en disco.

\- Espacio disponible.

\- Tamaño de la biblioteca de Immich.

\- Cantidad de archivos almacenados.



Para ejecutarlo:



```powershell

.\\scripts\\health-check.ps1

```



Ejemplo de funcionamiento:



```text

=====================================

&#x20;      IMMICH HOMELAB STATUS

=====================================



\[OK] Docker is running

\[OK] immich-server

\[OK] immich-machine-learning

\[OK] database

\[OK] redis

\[OK] Immich web server responding

\[OK] Disk space is healthy

```



Actualmente los mensajes del script están en inglés. Una de las siguientes mejoras del proyecto será traducir completamente su interfaz al español.



\## Seguridad



La información sensible está excluida intencionalmente del repositorio.



Nunca deben almacenarse en GitHub:



\- Archivos `.env` con credenciales reales.

\- Contraseñas de PostgreSQL.

\- Claves privadas.

\- Datos internos de PostgreSQL.

\- Fotografías y videos personales.

\- Copias de seguridad que contengan información privada.



El repositorio incluye un archivo `.env.example` que sirve como plantilla segura de configuración sin contener credenciales reales.



\## Estrategia de respaldo



La arquitectura de respaldo planificada es:



```text

iPhone

&#x20;  │

&#x20;  ▼

Servidor Immich

&#x20;  │

&#x20;  ├── Biblioteca local

&#x20;  │

&#x20;  └── PostgreSQL

&#x20;           │

&#x20;           ▼

&#x20;     Respaldo externo

```



El objetivo a largo plazo es aproximarnos a una estrategia \*\*3-2-1\*\*:



\- 3 copias de los datos importantes.

\- 2 medios de almacenamiento diferentes.

\- 1 copia almacenada independientemente del servidor principal.



> Immich no debe considerarse por sí solo como la única copia de seguridad de fotografías importantes.





\## Estructura del repositorio



```text

immich-homelab/

│

├── scripts/

│   └── health-check.ps1

│

├── docs/

│

├── .env.example

├── .gitignore

└── README.md

```



La instalación real de Immich y la biblioteca multimedia permanecen separadas del repositorio para evitar que información privada sea añadida accidentalmente a Git.



\## Importante



Este repositorio contiene únicamente configuraciones, documentación y herramientas de automatización relacionadas con la infraestructura.



\*\*No contiene fotografías, videos, contraseñas ni información personal de la biblioteca de Immich.\*\*



\## Conocimientos aplicados



Este proyecto permite adquirir experiencia práctica en:



\- Aplicaciones contenerizadas.

\- Docker y Docker Compose.

\- Persistencia mediante volúmenes.

\- PostgreSQL.

\- Administración de servicios.

\- Redes locales.

\- Monitorización de infraestructura.

\- Automatización mediante PowerShell.

\- Seguridad de credenciales.

\- Persistencia de datos.

\- Estrategias de respaldo.

\- Recuperación ante fallos.

\- Servicios autoalojados.



\## Estado del proyecto



El servidor se encuentra operativo y permite realizar respaldos de fotografías y videos desde dispositivos móviles hacia una instancia privada de Immich.



El proyecto continuará incorporando herramientas de automatización, monitorización, respaldo y seguridad.

