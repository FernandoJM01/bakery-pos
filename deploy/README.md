# Servidor local de la panadería / Bakery local server

[Español](#español) · [English](#english)

## Español

En la Fase 1 el sistema corre gratis en una computadora de la panadería que
queda siempre encendida (Linux, o Windows con Docker Desktop). Las cajas de las
dos sucursales y la administración se conectan a ella por Tailscale, una red
privada gratuita que da una dirección HTTPS de confianza. Las dos sucursales
usan la misma base de datos.

**Recomendado:** conecta la computadora y el módem a un no-break (UPS). Todo
vuelve a arrancar solo después de un apagón, pero un UPS evita cortes a media
venta y daños en el disco.

### 1. Instalar
1. Instala Docker: <https://docs.docker.com/engine/install/> (en Windows,
   Docker Desktop con WSL 2).
2. Instala Tailscale en esta computadora (<https://tailscale.com/download>) e
   inicia sesión. En la consola de Tailscale (DNS) activa **MagicDNS** y
   **HTTPS Certificates**.
3. Instala Tailscale en cada caja (tableta) y en las computadoras de la otra
   sucursal, con la misma cuenta.
4. Descarga este repositorio y entra a la carpeta `deploy`.

### 2. Configurar
1. Copia `.env.example` a `.env`.
2. Llena las cuatro claves. Cada una se genera con `openssl rand -hex 32`
   (usa solo letras y números). Guarda una copia del `.env` en un lugar seguro:
   sin él no se pueden leer los respaldos con otra instalación.
3. En `BACKUP_DIR` pon la carpeta de un segundo disco o memoria USB.
4. Construye la administración web: `./build-backoffice.sh`.

### 3. Encender, apagar, actualizar
- Encender: `docker compose up -d --build`
- Publicar con HTTPS (una sola vez): `sudo tailscale serve --bg 8080`.
  Tailscale muestra la dirección, por ejemplo
  `https://panaderia.tu-red.ts.net`. Esa es la dirección del servidor para las
  cajas y la administración.
- Primer dueño (una sola vez):
  `docker compose exec server node dist/cli/create-owner.js`
- Apagar: `docker compose down` (los datos se conservan).
- Actualizar: `git pull`, luego `./build-backoffice.sh` y
  `docker compose up -d --build`. Las migraciones corren solas antes del
  servidor.

### 4. Revisar que funciona
Abre `https://panaderia.tu-red.ts.net/health`. Debe decir
`"status":"ok","database":"ok"`. También `docker compose ps` debe mostrar
`server` como `healthy`.

### 5. Respaldos
- Cada noche a las `BACKUP_AT` (02:30) se guarda un respaldo comprimido en
  `BACKUP_DIR`, y se borran los de más de 30 días.
- Respaldo inmediato: `docker compose exec backup sh /backup.sh now`
- Copia opcional a la nube: sincroniza `BACKUP_DIR` con Google Drive u
  OneDrive (gratis) con su aplicación de escritorio.
- **Probar un respaldo (cada semana):** `./restore-test.sh`. Restaura el más
  reciente en una base de prueba, compara los conteos y no toca los datos
  reales. Debe terminar con `OK`.
- **Restaurar de verdad** (reemplaza todos los datos):
  `./restore.sh backups/pos-AAAAMMDD-HHMM.dump` y escribe `RESTAURAR`.

### Solo para pruebas: red local sin Tailscale
En `.env` pon `WEB_BIND=0.0.0.0` y `REQUIRE_HTTPS=false`, y abre
`http://IP-de-la-computadora:8080`. Así viaja todo sin cifrar: no lo uses con
ventas reales.

## English

In Phase 1 the system runs for free on an always-on computer at the bakery
(Linux, or Windows with Docker Desktop). The tills at both branches and the
back office reach it over Tailscale, a free private network that gives it a
trusted HTTPS name. Both branches share one database.

**Recommended:** put the computer and the router on a UPS. Everything restarts
on its own after a power cut, but a UPS avoids losing a sale midway and disk
damage.

### 1. Install
1. Install Docker: <https://docs.docker.com/engine/install/> (on Windows,
   Docker Desktop with WSL 2).
2. Install Tailscale on this computer (<https://tailscale.com/download>) and
   sign in. In the Tailscale admin console (DNS) turn on **MagicDNS** and
   **HTTPS Certificates**.
3. Install Tailscale on every till (tablet) and on the other branch's
   computers, with the same account.
4. Download this repository and open the `deploy` folder.

### 2. Configure
1. Copy `.env.example` to `.env`.
2. Fill in the four secrets, each from `openssl rand -hex 32` (letters and
   digits only). Keep a copy of `.env` somewhere safe.
3. Set `BACKUP_DIR` to a folder on a second disk or USB drive.
4. Build the back office: `./build-backoffice.sh`.

### 3. Start, stop, update
- Start: `docker compose up -d --build`
- Publish over HTTPS (once): `sudo tailscale serve --bg 8080`. Tailscale
  prints the address, e.g. `https://panaderia.your-tailnet.ts.net`; use it
  as the server address on the tills and for the back office.
- First owner (once): `docker compose exec server node dist/cli/create-owner.js`
- Stop: `docker compose down` (data is kept).
- Update: `git pull`, then `./build-backoffice.sh` and
  `docker compose up -d --build`. Migrations run before the server starts.

### 4. Check it works
Open `https://panaderia.your-tailnet.ts.net/health`; it must show
`"status":"ok","database":"ok"`, and `docker compose ps` must show `server`
as `healthy`.

### 5. Backups
- Every night at `BACKUP_AT` (02:30) a compressed dump goes to `BACKUP_DIR`;
  dumps older than 30 days are deleted.
- Back up now: `docker compose exec backup sh /backup.sh now`
- Optional cloud copy: sync `BACKUP_DIR` with Google Drive or OneDrive's free
  desktop app.
- **Test a restore (weekly):** `./restore-test.sh` restores the newest dump
  into a scratch database, compares row counts and leaves live data alone. It
  must end with `OK`.
- **Real restore** (replaces all data):
  `./restore.sh backups/pos-YYYYMMDD-HHMM.dump`, then type `RESTAURAR`.

### Testing only: plain LAN without Tailscale
Set `WEB_BIND=0.0.0.0` and `REQUIRE_HTTPS=false` in `.env` and open
`http://computer-ip:8080`. Traffic is unencrypted; never use it for real sales.
