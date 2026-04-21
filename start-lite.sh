#!/bin/bash

# APP-Record - Script de inicio rápido (versión lite)
# Uso: ./start-lite.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

cleanup() {
    echo -e "\n${YELLOW}Deteniendo...${NC}"
    [ -n "$BACKEND_PID" ] && kill $BACKEND_PID 2>/dev/null
    exit
}

trap cleanup SIGINT SIGTERM

echo -e "${GREEN}🚀 APP-Record - Iniciando...${NC}\n"

# Backend
echo -e "${GREEN}Backend (Node.js)...${NC}"
cd "$(dirname "$0")/server-nodejs"
npm run dev > /dev/null 2>&1 &
BACKEND_PID=$!
sleep 2

# Frontend
echo -e "${GREEN}Frontend (Flutter)...${NC}"
cd "$(dirname "$0")"
/home/lsyst/Descargas/flutter/bin/flutter run

cleanup
