#!/bin/bash
set -e

echo "Démarrage du conteneur..."

sleep 5 

echo "Exécution des migrations..."
./dbtool migrate


./dbtool reset-db

echo "Lancement du serveur..."
exec ./server
