#!/bin/bash

set -e

echo "🔻 Parando y eliminando contenedores individuales (si existen)..."

for c in frontend backend mongo; do
  ID=$(docker ps -aq -f name="^${c}$")
  if [ -n "$ID" ]; then
    echo "  - Eliminando contenedor: $c"
    docker rm -f "$c"
  else
    echo "  - Contenedor $c no existe, nada que hacer."
  fi
done

echo ""
echo "📦 Bajando stack de docker compose (si existe en este directorio)..."

if [ -f docker-compose.yml ] || [ -f docker-compose.yaml ]; then
  # --rmi local: elimina las imágenes construidas por docker compose
  # -v: elimina volúmenes anónimos
  docker compose down --rmi local -v || true
else
  echo "  - No se encontró docker-compose.yml, saltando este paso."
fi

echo ""
echo "🌐 Eliminando red 'mi-red-app' (si existe)..."

if docker network ls --format '{{.Name}}' | grep -q '^mi-red-app$'; then
  docker network rm mi-red-app
  echo "  - Red mi-red-app eliminada."
else
  echo "  - La red mi-red-app no existe, nada que hacer."
fi

echo ""
echo "🐳 Eliminando imágenes locales 'mi-backend' y 'mi-frontend' (si existen)..."

for img in mi-backend mi-frontend; do
  if docker images --format '{{.Repository}}' | grep -q "^${img}$"; then
    echo "  - Eliminando imagen: $img"
    docker rmi "$img" || true
  else
    echo "  - Imagen $img no existe, nada que hacer."
  fi
done

echo ""
echo "🧯 (Opcional) Limpiando imágenes huérfanas/dangling..."

docker image prune -f >/dev/null 2>&1 || true

echo ""
echo "✅ Reset completo. Se han eliminado contenedores, red e imágenes relacionadas con la app."
