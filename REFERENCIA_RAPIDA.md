# 📱 APP-Record - Referencia Rápida

## ¿Qué Se Implementó?

✅ **Registro de Usuarios** - Pantalla completa con validaciones  
✅ **Login HTTP** - Llamadas a API remota  
✅ **Backend Node.js** - Servidor con autenticación JWT  
✅ **Toggle API/Local** - Cambiar entre BD local y API remota  
✅ **Almacenamiento de Tokens** - Guardado persistente de sesiones

---

## 📁 Archivos Nuevos Creados

```
APP-Record/
├── lib/
│   ├── services/
│   │   ├── api_service.dart         ← Llamadas HTTP al servidor
│   │   └── token_storage.dart       ← Guardar tokens
│   └── screens/
│       └── register_screen.dart     ← Pantalla de registro
├── server-nodejs/
│   ├── server.js                    ← Backend Express
│   ├── package.json                 ← Dependencias Node
│   ├── .env.example                 ← Variables de entorno
│   ├── README.md                    ← Guía backend
│   ├── EJEMPLOS-CURL.md            ← Ejemplos con curl
│   └── test-api.sh                  ← Script de pruebas
├── AUTENTICACION.md                 ← Documentación técnica
├── SETUP_GUIA.md                    ← Guía de configuración
├── DESPLIEGUE.md                    ← Guía de producción
└── pubspec.yaml                     ← Actualizado con http package
```

---

## 🚀 Inicio Rápido

### 1️⃣ Instalar dependencias Flutter
```bash
cd /home/lsyst/Documentos/APP-Record
flutter pub get
```

### 2️⃣ Instalar servidor (opcional)
```bash
cd server-nodejs
npm install
npm run dev  # npm start para producción
```

### 3️⃣ Ejecutar la app
```bash
flutter run
```

---

## 🧪 Pruebas Rápidas

### Con BD Local (por defecto)
1. Toggle en ON "BD Local"
2. Email: `admin@app.com`
3. Contraseña: `123456`

### Con API Remota
1. Inicia servidor: `npm run dev`
2. Toggle en OFF "BD Local"
3. Registra usuario o usa admin

---

## 🔧 Configuración

### Cambiar URL del Servidor
En `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://tu-servidor.com';
```

### Para Android Emulador
```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

### Para Dispositivo Físico
```dart
static const String baseUrl = 'http://192.168.1.X:3000';
```

---

## 📚 Documentación

| Archivo | Contenido |
|---------|----------|
| `AUTENTICACION.md` | Guía técnica completa |
| `SETUP_GUIA.md` | Pasos de configuración |
| `DESPLIEGUE.md` | Desplegar en producción |
| `server-nodejs/README.md` | Guía del backend |
| `server-nodejs/EJEMPLOS-CURL.md` | Ejemplos con curl |

---

## 🌍 URLs de los Endpoints

```
POST   /api/auth/register      - Registrar usuario
POST   /api/auth/login         - Iniciar sesión
POST   /api/auth/logout        - Cerrar sesión
GET    /api/auth/verify        - Verificar token
GET    /api/auth/profile       - Obtener perfil
PUT    /api/auth/profile       - Actualizar perfil
POST   /api/auth/refresh       - Renovar token
GET    /api/users              - Listar usuarios
DELETE /api/auth/account       - Eliminar cuenta
GET    /health                 - Estado del servidor
```

---

## 🔐 Seguridad

✅ Contraseñas con hash (bcryptjs)  
✅ JWT tokens con expiración  
✅ CORS habilitado  
✅ Validaciones en servidor y cliente

⚠️ **En producción:**
- Usar HTTPS (no HTTP)
- Cambiar JWT_SECRET
- Agregar rate limiting
- Usar base de datos real

---

## 🐛 Troubleshooting

| Error | Solución |
|-------|----------|
| "Cannot find module 'http'" | `flutter pub get` |
| "Port 3000 already in use" | Cambiar puerto o detener proceso |
| "Connection refused" | Verificar servidor está corriendo |
| "Token inválido" | El token expiró, hacer login de nuevo |

---

## 📱 Flujos de Usuario

### Registro
```
RegisterScreen → validar datos → llamar API 
→ guardar token → ir a Login → HomeScreen
```

### Login
```
LoginScreen → validar datos → llamar API/BD 
→ guardar token → HomeScreen
```

### Cambiar entre API y BD Local
```
Toggle "BD Local" → autentica localmente
Toggle "API Remota" → llamadas HTTP
```

---

## 🎯 Próximos Pasos

1. ✅ Instalar `shared_preferences` para guardar tokens
2. ✅ Implementar persencia de sesión
3. ✅ Agregar recuperación de contraseña
4. ✅ 2FA (autenticación de dos factores)
5. ✅ OAuth (Google, Facebook)
6. ✅ Base de datos real (MongoDB, PostgreSQL)

---

## 📞 Comandos Útiles

```bash
# Flutter
flutter pub get              # Instalar paquetes
flutter run                  # Ejecutar app
flutter clean               # Limpiar caché

# Node.js
npm install                 # Instalar dependencias
npm run dev                 # Desarrollo con auto-reload
npm start                   # Modo producción
npm test                    # Ejecutar pruebas

# Testing
bash server-nodejs/test-api.sh    # Ejecutar pruebas
curl http://localhost:3000/health # Health check
```

---

## 🔑 Credenciales de Prueba

| Campo | Valor |
|-------|-------|
| Email | admin@app.com |
| Contraseña | 123456 |

---

## 💡 Tips

- Usa el toggle para cambiar entre desarrollo local y remoto
- Guarda tokens con `SharedPreferences` para persistencia
- Agrega refresh tokens para sesiones largas
- Implementa logout en ambos lados (cliente y servidor)
- Valida siempre en servidor, nunca confíes solo en cliente

---

## 📞 Soporte

Revisa estos archivos si tienes problemas:
- `AUTENTICACION.md` - Documentación técnica
- `server-nodejs/README.md` - Guía backend
- `server-nodejs/EJEMPLOS-CURL.md` - Ejemplos prácticos
- `DESPLIEGUE.md` - Producción

¡Listo para usar! 🎉
