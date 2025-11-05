#!/bin/bash
set -e

echo "=== DB Admin Bastion Setup (Idempotent) ==="

# Helper: Run command only if package not installed
install_if_missing() {
  local pkg="$1"
  if dpkg -l | grep -q "^ii  $pkg "; then
    echo "Package '$pkg' already installed."
  else
    echo "Installing $pkg..."
    apt install -y "$pkg"
  fi
}

# 1. Update package list (safe to run multiple times)
apt update -y

# 2. Install basics (idempotent)
for pkg in curl wget gnupg lsb-release jq ca-certificates awscli; do
  install_if_missing "$pkg"
done

# 3. Add PostgreSQL repo — safe to re-run
mkdir -p /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/postgresql.gpg ]; then
  echo "Adding PostgreSQL apt repository..."
  curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg
  echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
else
  echo "PostgreSQL repo already configured."
fi

# 4. Update again after repo add
apt update -y

# 5. Install PostgreSQL client & contrib — idempotent
install_if_missing postgresql
install_if_missing postgresql-contrib

# 6. Verify installations
echo "psql version:" $(psql --version 2>/dev/null || echo "not found")
echo "curl:" $(curl --version | head -1)
echo "aws:" $(aws --version)

# 7. Auto-configure DB credentials (idempotent)
BASHRC_LINE="# === AUTO DB CONFIG ==="
if ! grep -q "$BASHRC_LINE" /home/ubuntu/.bashrc 2>/dev/null; then
  if [ ! -z "$RDS_ENDPOINT" ] && [ ! -z "$SECRET_ARN" ]; then
    echo "Configuring DB credentials in ~/.bashrc..."
    PASSWORD=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --query SecretString --output text | jq -r .password)

    cat >> /home/ubuntu/.bashrc << EOF

$BASHRC_LINE
export RDS_ENDPOINT="$RDS_ENDPOINT"
export DB_USER="administrator"
export DB_PASSWORD="$PASSWORD"
alias psql-db='psql "host=\$RDS_ENDPOINT user=\$DB_USER dbname=postgres password=\$DB_PASSWORD"'
EOF
    echo "DB credentials loaded. Use: psql-db"
  fi
else
  echo "DB config already in ~/.bashrc"
fi

echo "DB Admin Bastion READY! (Safe to re-run)"