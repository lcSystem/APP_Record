# Servidor API - APP-Record

Backend Node.js Express para la autenticación de usuarios de APP-Record.

## Instalación

```bash
cd server-nodejs
npm install
```

## Ejecutar

### Desarrollo (con auto-reload)
```bash
npm install -g nodemon  # Si no lo tienes instalado
npm run dev
```

### Producción
```bash
npm start
```

El servidor estará en: **http://localhost:3000**

## Endpoints

### Autenticación

#### Registrar Usuario
```
POST /api/auth/register
Content-Type: application/json

{
  "name": "Juan Pérez",
  "email": "juan@email.com",
  "password": "password123"
}
```

**Respuesta exitosa (201):**
```json
{
  "message": "Usuario registrado exitosamente",
  "user": {
    "id": 2,
    "name": "Juan Pérez",
    "email": "juan@email.com"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### Iniciar Sesión
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "admin@app.com",
  "password": "123456"
}
```

**Respuesta exitosa (200):**
```json
{
  "message": "Login exitoso",
  "user": {
    "id": 1,
    "name": "Usuario Admin",
    "email": "admin@app.com"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### Cerrar Sesión
```
POST /api/auth/logout
Authorization: Bearer {token}
```

**Respuesta (200):**
```json
{
  "message": "Sesión cerrada exitosamente"
}
```

#### Verificar Token
```
GET /api/auth/verify
Authorization: Bearer {token}
```

**Respuesta exitosa (200):**
```json
{
  "message": "Token válido",
  "user": {
    "id": 1,
    "name": "Usuario Admin",
    "email": "admin@app.com"
  }
}
```

#### Obtener Perfil
```
GET /api/auth/profile
Authorization: Bearer {token}
```

#### Actualizar Perfil
```
PUT /api/auth/profile
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Nuevo Nombre"
}
```

#### Renovar Token
```
POST /api/auth/refresh
Authorization: Bearer {token}
```

#### Eliminar Cuenta
```
DELETE /api/auth/account
Authorization: Bearer {token}
```

### Utilidades

#### Verificar Salud del Servidor
```
GET /health
```

**Respuesta (200):**
```json
{
  "status": "OK",
  "message": "Servidor funcionando correctamente"
}
```

#### Listar Usuarios (sin autenticación)
```
GET /api/users
```

## Credenciales de Prueba

- **Email:** admin@app.com
- **Contraseña:** 123456

## Configuración en Flutter

En `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://localhost:3000';
```

**En Android:** Usa `10.0.2.2` en lugar de `localhost`:
```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

**En iOS:** Usa `localhost:3000` normalmente

## Seguridad

⚠️ **Para producción:**

1. Cambiar `JWT_SECRET` en `server.js`
2. Usar HTTPS (no HTTP)
3. Agregar validaciones más estrictas
4. Implementar rate limiting
5. Usar una base de datos real (MongoDB, PostgreSQL)
6. Agregar autenticación de dos factores
7. Implementar logout tokens invalidos en servidor

## Estructura del Proyecto

```
server-nodejs/
├── server.js          # Archivo principal del servidor
├── package.json       # Dependencias
└── README.md          # Este archivo
```

## Dependencias

- **express** - Framework web
- **cors** - Manejo de CORS
- **jsonwebtoken** - Generación y verificación de JWT
- **bcryptjs** - Hash de contraseñas

## Desarrollo

Para agregar nuevos endpoints:

```javascript
app.post('/api/ruta', verifyToken, (req, res) => {
  // req.userId contiene el ID del usuario autenticado
  res.json({ message: 'Respuesta' });
});
```

## Troubleshooting

### Error: "EADDRINUSE: address already in use :::3000"
El puerto 3000 ya está en uso. Cambia en `server.js`:
```javascript
const PORT = 3001; // Cambiar a otro puerto
```

### Error: "Cannot find module 'express'"
Instala las dependencias:
```bash
npm install
```

### El token expira rápidamente
Cambia en `server.js`:
```javascript
{ expiresIn: '24h' } // Aumentar duración
```

## Licencia

MIT
