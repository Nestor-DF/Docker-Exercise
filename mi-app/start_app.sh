#!/bin/bash

set -e

echo "========================================="
echo "     Iniciar aplicación Docker"
echo "========================================="
echo ""
echo "Selecciona una opción:"
echo "1) Levantar contenedores manualmente (docker run)"
echo "2) Levantar con docker compose"
echo ""
read -p "Elige 1 o 2: " OPTION

if [ "$OPTION" = "1" ]; then
    echo ""
    echo "🚀 Modo MANUAL seleccionado"
    echo ""

    # Crear red si no existe
    if docker network ls --format '{{.Name}}' | grep -q '^mi-red-app$'; then
        echo "🔹 La red mi-red-app ya existe"
    else
        echo "🔹 Creando red mi-red-app..."
        docker network create mi-red-app
    fi

    echo ""
    echo "📦 Construyendo imágenes..."

    echo "🔹 Backend"
    cd backend
    docker build -t mi-backend .
    cd ..

    echo "🔹 Frontend"
    cd frontend
    docker build -t mi-frontend .
    cd ..

    echo ""
    echo "🐳 Ejecutando contenedores..."

    docker run -d --name mongo --network mi-red-app -p 27017:27017 mongo:6
    docker run -d --name backend --network mi-red-app -p 4000:4000 -e MONGO_URL="mongodb://mongo:27017" mi-backend
    docker run -d --name frontend --network mi-red-app -p 3000:80 mi-frontend

    echo ""
    echo "✅ Aplicación levantada manualmente"
    echo "Backend: http://localhost:4000"
    echo "Frontend: http://localhost:3000"

elif [ "$OPTION" = "2" ]; then
    echo ""
    echo "🚀 Modo DOCKER COMPOSE seleccionado"
    echo ""

    echo "📦 Construyendo imágenes y levantando contenedores..."
    docker compose up -d --build

    echo ""
    echo "✅ Aplicación levantada con Docker Compose"
    echo "Backend: http://localhost:4000"
    echo "Frontend: http://localhost:3000"

else
    echo "❌ Opción no válida. Ejecuta el script y elige 1 o 2."
fi
