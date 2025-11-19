#!/bin/bash
# set -e   # Descomenta si quieres que el script se detenga ante errores

sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker $USER
newgrp docker


echo "Eliminando contenedores..."
docker rm -f frontend backend mongo 2>/dev/null || true

echo "Eliminando red..."
docker network rm mi-red-app 2>/dev/null || true

echo "Limpiando pantalla..."
clear

echo "Eliminando imágenes..."
docker rmi mi-frontend mi-backend 2>/dev/null || true

echo "Prune de volúmenes..."
docker volume prune -f

echo "Proceso completado."
