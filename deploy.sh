#!/usr/bin/env bash
# Installe ou met à jour Heureux Hasard sur le serveur (stack Docker / Dockge).
#
#   Première installation :  curl -fsSL https://raw.githubusercontent.com/Renaar/Heureux-Hasard/main/deploy.sh | bash
#   Mise à jour           :  bash /opt/stacks/heureux-hasard/deploy.sh
#
# Variables facultatives : DEST (dossier de la stack), BRANCHE.
set -euo pipefail

DEPOT="https://github.com/Renaar/Heureux-Hasard.git"
DEST="${DEST:-/opt/stacks/heureux-hasard}"
BRANCHE="${BRANCHE:-main}"
PORT=3004

# sudo seulement si nécessaire (pas root)
SUDO=""
[ "$(id -u)" -ne 0 ] && SUDO="sudo"

echo "==> Heureux Hasard → $DEST (branche $BRANCHE)"

command -v git >/dev/null    || { echo "git est introuvable : sudo apt install -y git"; exit 1; }
command -v docker >/dev/null || { echo "docker est introuvable."; exit 1; }

if [ -d "$DEST/.git" ]; then
  echo "==> Mise à jour du dépôt"
  $SUDO git -C "$DEST" pull --quiet --ff-only origin "$BRANCHE"
else
  if [ -e "$DEST" ] && [ -n "$(ls -A "$DEST" 2>/dev/null)" ]; then
    echo "Le dossier $DEST existe déjà et n'est pas un dépôt git : je n'y touche pas."
    exit 1
  fi
  echo "==> Téléchargement du dépôt"
  $SUDO mkdir -p "$(dirname "$DEST")"
  $SUDO git clone --quiet --branch "$BRANCHE" "$DEPOT" "$DEST"
fi

# Pare-feu : ouvre le port si ufw est actif
if command -v ufw >/dev/null && $SUDO ufw status 2>/dev/null | grep -q "Status: active"; then
  $SUDO ufw allow "$PORT/tcp" >/dev/null && echo "==> Port $PORT ouvert dans ufw"
fi

# Ancienne installation sous le nom « Random Spin » : on l'arrête (même port).
ANCIEN="/opt/stacks/random-spin"
if [ -f "$ANCIEN/docker-compose.yml" ] && [ "$ANCIEN" != "$DEST" ]; then
  echo "==> Arrêt de l'ancienne stack random-spin (vous pourrez supprimer $ANCIEN)"
  (cd "$ANCIEN" && $SUDO docker compose down) || true
fi

echo "==> Démarrage du conteneur"
cd "$DEST"
$SUDO docker compose up -d

IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
echo
echo "✔ Heureux Hasard est en ligne : http://${IP:-<adresse-du-serveur>}:$PORT"
echo "  (pensez à Ctrl+F5 dans le navigateur après une mise à jour)"
