# Ejemplos de Prueba con cURL

## Requisitos
- curl instalado
- Servidor ejecutándose: `npm run dev`
- jq (opcional, para formatear JSON): `sudo apt install jq`

---

## 1. Verificar Salud del Servidor
```bash
curl http://localhost:3000/health | jq
```

**Respuesta esperada:**
```json
{
  "status": "OK",
  "message": "Servidor funcionando correctamente"
}
```

---

## 2. Listar Usuarios
```bash
curl http://localhost:3000/api/users | jq
```

---

## 3. Registrar Nuevo Usuario
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Juan Pérez",
    "email": "juan@example.com",
    "password": "password123"
  }' | jq
```

**Guardar el token para pruebas posteriores:**
```bash
# En Bash
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Juan Pérez",
    "email": "juan'$RANDOM'@example.com",
    "password": "password123"
  }' | jq -r '.token')

echo "Token: $TOKEN"
```

---

## 4. Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@app.com",
    "password": "123456"
  }' | jq
```

---

## 5. Verificar Token
```bash
# Primero obtén un token del login anterior
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

curl -X GET http://localhost:3000/api/auth/verify \
  -H "Authorization: Bearer $TOKEN" | jq
```

---

## 6. Obtener Perfil
```bash
curl -X GET http://localhost:3000/api/auth/profile \
  -H "Authorization: Bearer $TOKEN" | jq
```

---

## 7. Actualizar Perfil
```bash
curl -X PUT http://localhost:3000/api/auth/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Nuevo Nombre"
  }' | jq
```

---

## 8. Renovar Token
```bash
curl -X POST http://localhost:3000/api/auth/refresh \
  -H "Authorization: Bearer $TOKEN" | jq
```

---

## 9. Cerrar Sesión
```bash
curl -X POST http://localhost:3000/api/auth/logout \
  -H "Authorization: Bearer $TOKEN" | jq
```

---

## 10. Eliminar Cuenta
```bash
curl -X DELETE http://localhost:3000/api/auth/account \
  -H "Authorization: Bearer $TOKEN" | jq
```

---

## Script Completo de Prueba

Guarda como `test.sh` y ejecuta con `bash test.sh`:

```bash
#!/bin/bash

SERVER="http://localhost:3000"

echo "🔍 Health Check..."
curl "$SERVER/health" | jq '.'

echo -e "\n📋 Listar usuarios..."
curl "$SERVER/api/users" | jq '.'

echo -e "\n🔐 Login admin..."
LOGIN=$(curl -s -X POST "$SERVER/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@app.com","password":"123456"}')
echo "$LOGIN" | jq '.'

TOKEN=$(echo "$LOGIN" | jq -r '.token')
echo -e "\n✅ Token: ${TOKEN:0:30}..."

echo -e "\n👤 Obtener perfil..."
curl -s -X GET "$SERVER/api/auth/profile" \
  -H "Authorization: Bearer $TOKEN" | jq '.'

echo -e "\n📝 Registrar usuario..."
REGISTER=$(curl -s -X POST "$SERVER/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test'$RANDOM'@example.com",
    "password": "test123"
  }')
echo "$REGISTER" | jq '.'

echo -e "\n🔓 Logout..."
curl -s -X POST "$SERVER/api/auth/logout" \
  -H "Authorization: Bearer $TOKEN" | jq '.'

echo -e "\n✅ Pruebas completadas"
```

---

## Postman Collection

Importa en Postman. Guarda como `postman_collection.json`:

```json
{
  "info": {
    "name": "APP-Record API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Health Check",
      "request": {
        "method": "GET",
        "url": "{{base_url}}/health"
      }
    },
    {
      "name": "Register",
      "request": {
        "method": "POST",
        "header": [{"key": "Content-Type", "value": "application/json"}],
        "url": "{{base_url}}/api/auth/register",
        "body": {
          "mode": "raw",
          "raw": "{\"name\":\"Test\",\"email\":\"test@example.com\",\"password\":\"pass123\"}"
        }
      }
    },
    {
      "name": "Login",
      "request": {
        "method": "POST",
        "header": [{"key": "Content-Type", "value": "application/json"}],
        "url": "{{base_url}}/api/auth/login",
        "body": {
          "mode": "raw",
          "raw": "{\"email\":\"admin@app.com\",\"password\":\"123456\"}"
        }
      }
    }
  ]
}
```

---

## Errores Comunes y Soluciones

### Error: "Cannot GET /api/auth/verify"
**Solución:** El método debe ser GET, no POST

### Error: "Token not provided"
**Solución:** Agrega el header: `-H "Authorization: Bearer $TOKEN"`

### Error: "Invalid email"
**Solución:** Usa un email válido

### Error: "ECONNREFUSED"
**Solución:** El servidor no está corriendo. Ejecuta: `npm run dev`

---

## Variables de Entorno en cURL

```bash
# Linux/Mac
export BASE_URL="http://localhost:3000"
export TOKEN="your_token_here"

curl -X GET "$BASE_URL/api/auth/verify" \
  -H "Authorization: Bearer $TOKEN"

# Windows (CMD)
set BASE_URL=http://localhost:3000
set TOKEN=your_token_here

curl -X GET "%BASE_URL%/api/auth/verify" ^
  -H "Authorization: Bearer %TOKEN%"
```

---

## Monitorear Respuestas

```bash
# Mostrar solo el código de estado HTTP
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/health

# Mostrar todos los headers
curl -i http://localhost:3000/health

# Guardar respuesta en archivo
curl http://localhost:3000/api/users -o response.json

# Mostrar tiempo de respuesta
curl -w "\nTiempo: %{time_total}s\n" http://localhost:3000/health
```
