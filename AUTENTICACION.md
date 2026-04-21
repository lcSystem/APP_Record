# Sistema de Autenticación - APP-Record

## Descripción
Se ha implementado un sistema completo de autenticación con:
- **Registro de usuarios** con validaciones
- **Login con HTTP** (llamadas a API remota)
- **Toggle para BD Local** (para desarrollo local)
- **Pantalla de login mejorada** con opciones de visualización de contraseña

## Cambios Realizados

### 1. **pubspec.yaml**
- ✅ Añadida dependencia `http: ^1.1.0`

### 2. **lib/services/api_service.dart** (NUEVO)
Servicio que maneja todas las llamadas HTTP:
- `registerUser()` - Registra un nuevo usuario
- `loginUser()` - Inicia sesión
- `logoutUser()` - Cierra sesión
- `verifyToken()` - Verifica validez del token

### 3. **lib/screens/register_screen.dart** (NUEVO)
Pantalla completa de registro con:
- Validación de nombre (mínimo 3 caracteres)
- Validación de email
- Validación de contraseña (mínimo 6 caracteres)
- Confirmación de contraseña
- Visualización de contraseña
- Manejo de errores

### 4. **lib/screens/login_screen.dart** (ACTUALIZADO)
Mejoras implementadas:
- Toggle entre API remota y BD local
- Visualización de contraseña
- Link a registro de nuevos usuarios
- Soporte para ambos métodos de autenticación

## Configuración del Servidor

**IMPORTANTE:** Antes de usar el sistema con API remota, necesitas:

### Reemplazar la URL base
En `lib/services/api_service.dart`, cambia:
```dart
static const String baseUrl = 'https://api.example.com';
```

Por tu servidor real (ej: `https://tu-servidor.com`)

### Endpoints requeridos en tu servidor

Tu servidor debe tener estos endpoints:

#### 1. **POST /api/auth/register**
Cuerpo (Request):
```json
{
  "name": "Juan Pérez",
  "email": "juan@email.com",
  "password": "pass123"
}
```

Respuesta exitosa (201 o 200):
```json
{
  "message": "Registro exitoso",
  "user": {
    "id": 1,
    "name": "Juan Pérez",
    "email": "juan@email.com"
  },
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

Respuesta error:
```json
{
  "message": "El email ya existe"
}
```

#### 2. **POST /api/auth/login**
Cuerpo (Request):
```json
{
  "email": "juan@email.com",
  "password": "pass123"
}
```

Respuesta exitosa (200):
```json
{
  "user": {
    "id": 1,
    "name": "Juan Pérez",
    "email": "juan@email.com"
  },
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

Respuesta error (401):
```json
{
  "message": "Credenciales inválidas"
}
```

#### 3. **POST /api/auth/logout**
Headers:
```
Authorization: Bearer {token}
```

Respuesta exitosa (200):
```json
{
  "message": "Sesión cerrada"
}
```

#### 4. **GET /api/auth/verify**
Headers:
```
Authorization: Bearer {token}
```

Respuesta exitosa (200):
```json
{
  "message": "Token válido"
}
```

## Usar Servidor Local para Pruebas

### Opción 1: Node.js Express
```bash
npm init -y
npm install express cors
```

**server.js:**
```javascript
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const users = [
  { id: 1, name: 'Admin', email: 'admin@app.com', password: '123456' }
];

app.post('/api/auth/register', (req, res) => {
  const { name, email, password } = req.body;
  if (users.find(u => u.email === email)) {
    return res.status(400).json({ message: 'Email ya existe' });
  }
  const user = { id: users.length + 1, name, email, password };
  users.push(user);
  res.status(201).json({
    message: 'Registro exitoso',
    user: { id: user.id, name: user.name, email: user.email },
    token: 'token_' + user.id
  });
});

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  const user = users.find(u => u.email === email && u.password === password);
  if (!user) {
    return res.status(401).json({ message: 'Credenciales inválidas' });
  }
  res.json({
    user: { id: user.id, name: user.name, email: user.email },
    token: 'token_' + user.id
  });
});

app.post('/api/auth/logout', (req, res) => {
  res.json({ message: 'Sesión cerrada' });
});

app.get('/api/auth/verify', (req, res) => {
  res.json({ message: 'Token válido' });
});

app.listen(3000, () => console.log('Servidor en puerto 3000'));
```

Luego en `api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:3000';
```

### Opción 2: Python Flask
```bash
pip install flask flask-cors
```

**app.py:**
```python
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

users = [
    {'id': 1, 'name': 'Admin', 'email': 'admin@app.com', 'password': '123456'}
]

@app.route('/api/auth/register', methods=['POST'])
def register():
    data = request.json
    if any(u['email'] == data['email'] for u in users):
        return jsonify({'message': 'Email ya existe'}), 400
    user = {'id': len(users) + 1, **data}
    users.append(user)
    return jsonify({
        'message': 'Registro exitoso',
        'user': {k: v for k, v in user.items() if k != 'password'},
        'token': f'token_{user["id"]}'
    }), 201

@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.json
    user = next((u for u in users if u['email'] == data['email'] 
                 and u['password'] == data['password']), None)
    if not user:
        return jsonify({'message': 'Credenciales inválidas'}), 401
    return jsonify({
        'user': {k: v for k, v in user.items() if k != 'password'},
        'token': f'token_{user["id"]}'
    })

app.run(debug=True, port=3000)
```

## Uso de la Aplicación

### 1. **Primera vez**
- Selecciona "BD Local" (switch)
- Usa: `admin@app.com` / `123456`
- O registra un nuevo usuario

### 2. **Con servidor remoto**
- Desactiva "BD Local" (switch)
- Usa un servidor que implemente los endpoints
- Los usuarios se crearán en el servidor

### 3. **Datos de prueba (BD Local)**
- Email: `admin@app.com`
- Contraseña: `123456`

## Consideraciones de Seguridad

⚠️ **En producción:**
- Usar HTTPS (nunca HTTP)
- No guardar contraseñas en texto plano
- Usar tokens JWT con expiración
- Implementar rate limiting
- Validar todos los datos en servidor
- Usar CORS apropiadamente

## Próximos Pasos

1. Configurar tu servidor con los endpoints requeridos
2. Actualizar `baseUrl` en `api_service.dart`
3. Probar con el toggle de API remota
4. Implementar persistencia de tokens (SharedPreferences)
5. Agregar recuperación de contraseña
