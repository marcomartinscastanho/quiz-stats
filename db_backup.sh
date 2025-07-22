#!/bin/bash

# Config
DB_CONTAINER_NAME="qs-backend-db-1"   # You can also use: $(docker-compose ps -q db)
DB_NAME="zecolmeiadb"
DB_USER="zecolmeia"
BACKUP_DIR="./db_backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/db_backup_$TIMESTAMP.sql"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Get the actual container name (in case it's dynamic)
CONTAINER_ID=$(docker ps --filter "name=db" --format "{{.ID}}")

if [ -z "$CONTAINER_ID" ]; then
  echo "❌ Could not find a running database container with name matching 'db'"
  exit 1
fi

echo "📦 Dumping database '$DB_NAME' from container '$CONTAINER_ID'..."

# Execute the pg_dump command inside the container
docker exec -t "$CONTAINER_ID" pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
  echo "✅ Backup successful! File saved to $BACKUP_FILE"
else
  echo "❌ Backup failed."
  rm -f "$BACKUP_FILE"  # Clean up partial backup
fi
