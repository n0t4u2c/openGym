#!/bin/sh
# StuFit deploy, run on the Synology as root from Task Scheduler (see deploy/README.md).
# Fetches deploy/compose.yaml from GitHub, pulls the images it names, then restarts only
# what changed. The old file is kept as compose.yaml.bak.
set -eu
DIR=/volume1/docker/stufit
URL=https://raw.githubusercontent.com/n0t4u2c/openGym/stufit/deploy/compose.yaml
PATH=$PATH:/usr/local/bin

cd "$DIR"
trap 'rm -f compose.new' EXIT

if ! grep -q '^TUNNEL_TOKEN=.' .env 2>/dev/null; then
  echo "STOP: $DIR/.env with a TUNNEL_TOKEN line is missing. Nothing was changed."
  exit 1
fi

curl -fsSL "$URL" -o compose.new
grep -q '^services:' compose.new || { echo "STOP: the download is not a compose file. Nothing was changed."; exit 1; }
docker compose -f compose.new config -q

docker compose -f compose.new pull
cp -f compose.yaml compose.yaml.bak 2>/dev/null || true
mv compose.new compose.yaml
docker compose up -d --remove-orphans
docker image prune -f > /dev/null
docker compose ps
echo "Done."
