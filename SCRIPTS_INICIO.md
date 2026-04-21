# Scripts de Inicio - APP-Record

## Descripción

Dos scripts bash para iniciar automáticamente el backend Node.js y frontend Flutter.

## Scripts Disponibles

### 1. `start.sh` (Recomendado - Completo)
Script completo con validaciones, logs y manejo de errores.

**Características:**
- ✅ Verifica dependencias (Flutter, Node.js)
- ✅ Instala dependencias automáticamente
- ✅ Genera logs del servidor
- ✅ Verifica que el backend esté listo
- ✅ Manejo limpio de Ctrl+C
- ✅ Mensajes coloridos

**Uso:**
```bash
cd /home/lsyst/Documentos/APP-Record
./start.sh
```

### 2. `start-lite.sh` (Rápido - Minimalista)
Script simple y rápido, ideal si ya tienes todo configurado.

**Características:**
- ⚡ Inicio rápido
- 📝 Menos mensajes
- 🔧 Configuración mínima

**Uso:**
```bash
cd /home/lsyst/Documentos/APP-Record
./start-lite.sh
```

## Qué Hacen Los Scripts

### Paso 1: Backend Node.js
- Navega a `server-nodejs/`
- Instala dependencias (si no existen)
- Inicia servidor en `http://localhost:3000`
- El servidor corre en segundo plano

### Paso 2: Frontend Flutter
- Navega a la raíz del proyecto
- Obtiene dependencias (si es necesario)
- Inicia `flutter run`
- Abre la app en tu dispositivo/emulador

### Paso 3: Limpieza
- Cuando cierres Flutter (Ctrl+C), se detiene el backend automáticamente

## Requisitos

```bash
# Flutter
flutter --version

# Node.js
node --version
npm --version

# Curl (para verificaciones)
curl --version
```

## Instalación Rápida

### Linux/Mac
```bash
# El script ya está listo
cd /home/lsyst/Documentos/APP-Record
./start.sh
```

### Windows (WSL)
```bash
cd /home/lsyst/Documentos/APP-Record
bash start.sh
```

## Logs

### Backend
- **Archivo:** `server-nodejs/backend_server.log`
- **Ubicación:** Se genera automáticamente
- **Ver logs:** `cat server-nodejs/backend_server.log`

### Flutter
- Se muestra en la terminal directamente

## Problemas Comunes

### Error: "Permission denied"
```bash
chmod +x start.sh
./start.sh
```

### Puerto 3000 en uso
```bash
# Ver qué usa el puerto
lsof -i :3000

# Matar el proceso
kill -9 <PID>
```

### Flutter no responde
- Presiona `r` en la terminal para recargar
- Presiona `R` para restart completo
- Presiona `q` para salir

### Backend no inicia
```bash
# Verifica los logs
cat server-nodejs/backend_server.log

# Intenta iniciarlo manualmente
cd server-nodejs
npm run dev
```

## Personalización

### Cambiar Puerto Backend
En `server-nodejs/server.js`:
```javascript
const PORT = 5000; // Cambiar aquí
```

### Cambiar Dispositivo Flutter
En la terminal después de iniciar:
- `d` - Mostrar dispositivos disponibles
- `c` - Cambiar de dispositivo

### Ver Logs en Tiempo Real
```bash
# En otra terminal
tail -f server-nodejs/backend_server.log
```

## Alternativas Manuales

### Iniciar por Separado

**Terminal 1 - Backend:**
```bash
cd server-nodejs
npm run dev
```

**Terminal 2 - Frontend:**
```bash
flutter run
```

### Con Emulador Específico
```bash
# Listar emuladores
emulator -list-avds

# Iniciar emulador
emulator -avd <nombre>

# Luego ejecutar
./start.sh
```

## Comandos Útiles Durante Ejecución

### En Flutter CLI
```
r     - Hot reload (recargar código)
R     - Hot restart (reinicio completo)
h     - Ver ayuda
d     - Ver dispositivos
c     - Ver logs conectados
q     - Salir
```

### En Backend (otra terminal)
```bash
# Ver estado
curl http://localhost:3000/health

# Ver usuarios
curl http://localhost:3000/api/users

# Ver logs
tail -f server-nodejs/backend_server.log
```

## Ejemplo de Sesión Completa

```bash
$ cd /home/lsyst/Documentos/APP-Record

$ ./start.sh
╔════════════════════════════════════════╗
║   APP-RECORD - Startup Script 🚀      ║
╚════════════════════════════════════════╝

📍 Directorio del proyecto: /home/lsyst/Documentos/APP-Record

🖥️  Iniciando Backend (Node.js) en http://localhost:3000...
✅ Backend iniciado (PID: 1234)
   Log: /home/lsyst/Documentos/APP-Record/server-nodejs/backend_server.log

⏳ Esperando que el backend esté listo...
✅ Backend respondiendo

📱 Iniciando Frontend (Flutter)...

Launching lib/main.dart on emulator in debug mode...
```

## Notas de Seguridad

⚠️ **Desarrollo Local:**
- Los scripts usan HTTP (no HTTPS)
- Credenciales en texto plano
- Base de datos en memoria

✅ **Para Producción:**
- Ver archivo `DESPLIEGUE.md`
- Usar HTTPS
- Migrar a base de datos real
- Variables de entorno securizadas

## Soporte

Si tienes problemas:
1. Revisa `SETUP_GUIA.md` (sección Troubleshooting)
2. Verifica los logs: `cat server-nodejs/backend_server.log`
3. Ejecuta manualmente para ver errores detallados

¡Listo para comenzar! 🚀
