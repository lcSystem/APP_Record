#!/bin/bash

# Script para probar los endpoints del API
# Uso: bash test-api.sh

SERVER="http://localhost:3000"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}  APP-Record API - Script de Pruebas${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"

# Función auxiliar
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local token=$4
    local description=$5

    echo -e "${YELLOW}${description}${NC}"
    echo -e "${BLUE}${method} ${SERVER}${endpoint}${NC}"

    if [ -z "$token" ]; then
        curl -X $method \
            -H "Content-Type: application/json" \
            -d "$data" \
            "${SERVER}${endpoint}" \
            -w "\n\n" \
            2>/dev/null | python3 -m json.tool
    else
        curl -X $method \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            -d "$data" \
            "${SERVER}${endpoint}" \
            -w "\n\n" \
            2>/dev/null | python3 -m json.tool
    fi
}

# 1. Health Check
echo -e "${GREEN}1. VERIFICAR SALUD DEL SERVIDOR${NC}\n"
curl "${SERVER}/health" -w "\n\n" 2>/dev/null | python3 -m json.tool

# 2. Listar usuarios existentes
echo -e "${GREEN}2. LISTAR USUARIOS EXISTENTES${NC}\n"
curl "${SERVER}/api/users" -w "\n\n" 2>/dev/null | python3 -m json.tool

# 3. Login con usuario admin
echo -e "${GREEN}3. LOGIN CON USUARIO ADMIN${NC}\n"
LOGIN_RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"email":"admin@app.com","password":"123456"}' \
    "${SERVER}/api/auth/login")

echo $LOGIN_RESPONSE | python3 -m json.tool
ADMIN_TOKEN=$(echo $LOGIN_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin).get('token', ''))")

echo -e "${YELLOW}Token obtenido: ${ADMIN_TOKEN:0:30}...${NC}\n"

# 4. Verificar token
echo -e "${GREEN}4. VERIFICAR TOKEN${NC}\n"
curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    "${SERVER}/api/auth/verify" | python3 -m json.tool

# 5. Obtener perfil
echo -e "${GREEN}5. OBTENER PERFIL DEL USUARIO${NC}\n"
curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    "${SERVER}/api/auth/profile" | python3 -m json.tool

# 6. Registrar nuevo usuario
echo -e "${GREEN}6. REGISTRAR NUEVO USUARIO${NC}\n"
REGISTER_RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{
        "name": "Test Usuario",
        "email": "test@example.com",
        "password": "password123"
    }' \
    "${SERVER}/api/auth/register")

echo $REGISTER_RESPONSE | python3 -m json.tool
TEST_TOKEN=$(echo $REGISTER_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin).get('token', ''))" 2>/dev/null || echo "")

# 7. Login con nuevo usuario
if [ -z "$TEST_TOKEN" ]; then
    echo -e "${GREEN}7. LOGIN CON NUEVO USUARIO${NC}\n"
    TEST_LOGIN=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d '{"email":"test@example.com","password":"password123"}' \
        "${SERVER}/api/auth/login")
    
    echo $TEST_LOGIN | python3 -m json.tool
    TEST_TOKEN=$(echo $TEST_LOGIN | python3 -c "import sys, json; print(json.load(sys.stdin).get('token', ''))")
fi

# 8. Actualizar perfil
echo -e "${GREEN}8. ACTUALIZAR PERFIL DEL USUARIO${NC}\n"
curl -s -X PUT \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TEST_TOKEN" \
    -d '{"name": "Nombre Actualizado"}' \
    "${SERVER}/api/auth/profile" | python3 -m json.tool

# 9. Renovar token
echo -e "${GREEN}9. RENOVAR TOKEN${NC}\n"
curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TEST_TOKEN" \
    "${SERVER}/api/auth/refresh" | python3 -m json.tool

# 10. Logout
echo -e "${GREEN}10. CERRAR SESIÓN${NC}\n"
curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TEST_TOKEN" \
    "${SERVER}/api/auth/logout" | python3 -m json.tool

echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Pruebas completadas${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
