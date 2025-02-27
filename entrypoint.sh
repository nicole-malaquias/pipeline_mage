#!/bin/bash

# Criar rede Docker, se não existir
if ! docker network ls | grep -q "mage-app"; then
    echo "Criando rede Docker..."
    docker network create mage-app
else
    echo "Rede Docker já existe."
fi

# Iniciar PostgreSQL
echo "Iniciando PostgreSQL..."
docker run -d --network mage-app --network-alias postgres_db \
   -p 5432:5432 -v pgdata:/var/lib/postgresql/data \
   -e POSTGRES_USER=${POSTGRES_USER} -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
   -e POSTGRES_DB=${POSTGRES_DB} -e PG_DATA=/var/lib/postgresql/data/pgdata \
   --name postgres_container \
   postgres:13-alpine3.17 postgres

# Esperar PostgreSQL iniciar
echo "Aguardando PostgreSQL iniciar..."
sleep 10  # Tempo para garantir que o banco esteja rodando

# Iniciar MageAI
echo "Iniciando MageAI..."
docker run -d --network mage-app -p 6789:6789 -v $(pwd):/home/src \
   -e MAGE_DATABASE_CONNECTION_URL="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres_db:5432/${POSTGRES_DB}" \
   --name mage_container \
   mageai/mageai \
   /app/run_app.sh mage start my_project

echo "MageAI está rodando em http://localhost:6789"
