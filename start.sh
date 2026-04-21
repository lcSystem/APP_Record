#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

cleanup() {
    echo -e "\n${YELLOW}⏹️  Deteniendo servidores...${NC}"
    if [ -n "$BACKEND_PID" ]; then
        echo -e "${YELLOW}  → Deteniendo Backend Node.js (PID: $BACKEND_PID)${NC}"
        kill $BACKEND_PID 2>/dev/null
        wait $BACKEND_PID 2>/dev/null
    fi
    echo -e "${GREEN}✅ Servidores detenidos${NC}"
    exit
}

trap cleanup SIGINT SIGTERM

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   APP-RECORD - Startup Script 🚀      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"

# Ruta de Flutter
FLUTTER_BIN="/home/lsyst/Descargas/flutter/bin/flutter"

# Verificar que Flutter esté instalado
if [ ! -f "$FLUTTER_BIN" ]; then
    echo -e "${RED}❌ Error: Flutter no encontrado en $FLUTTER_BIN${NC}"
    exit 1
fi

# Verificar que Node.js esté instalado
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Error: Node.js no está instalado${NC}"
    exit 1
fi

# Obtener la ruta del directorio actual
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}📍 Directorio del proyecto: $PROJECT_DIR${NC}"
echo ""

# Iniciar Backend Node.js
echo -e "${GREEN}🖥️  Iniciando Backend (Node.js) en http://localhost:3000...${NC}"
cd "$PROJECT_DIR/server-nodejs"

# Verificar si node_modules existe
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Instalando dependencias de Node.js...${NC}"
    npm install
fi

# Iniciar servidor Node.js
npm run dev > backend_server.log 2>&1 &
BACKEND_PID=$!

echo -e "${GREEN}✅ Backend iniciado (PID: $BACKEND_PID)${NC}"
echo -e "${YELLOW}   Log: $PROJECT_DIR/server-nodejs/backend_server.log${NC}"

# Esperar a que el backend esté listo
echo -e "${YELLOW}⏳ Esperando que el backend esté listo...${NC}"
sleep 3

# Verificar si el backend está corriendo
if ! ps -p $BACKEND_PID > /dev/null; then
    echo -e "${RED}❌ Error: El backend no pudo iniciarse${NC}"
    echo -e "${RED}📋 Revisa el log: $PROJECT_DIR/server-nodejs/backend_server.log${NC}"
    exit 1
fi

# Verificar conexión al backend
if ! curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  El backend aún no responde, esperando más tiempo...${NC}"
    sleep 3
fi

echo ""

# Iniciar Frontend Flutter
echo -e "${GREEN}📱 Iniciando Frontend (Flutter)...${NC}"
echo -e "${YELLOW}   Toggle 'API Remota' para usar el servidor local${NC}"
echo ""

cd "$PROJECT_DIR"

# Verificar si pubspec.yaml existe
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Error: pubspec.yaml no encontrado${NC}"
    cleanup
    exit 1
fi

# Obtener dependencias si es necesario
if [ ! -d "pubspec.lock" ] && [ ! -f "pubspec.lock" ]; then
    echo -e "${YELLOW}📦 Obteniendo dependencias de Flutter...${NC}"
    "$FLUTTER_BIN" pub get
fi

# Ejecutar Flutter
"$FLUTTER_BIN" run

# Cuando Flutter se cierre, limpiar
cleanup
