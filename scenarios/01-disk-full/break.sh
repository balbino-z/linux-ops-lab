#!/usr/bin/env bash
# Scenario 01 — SPOILER: do not read before solving.
# A service left with debug logging on writes to the small data volume until it is full,
# and systemd keeps restarting it, so the disk refills after a naive cleanup.
set -euo pipefail

mkdir -p /srv/data/logs /srv/data/uploads
chown -R www-data:www-data /srv/data

cat > /usr/local/bin/report-worker <<'EOF'
#!/usr/bin/env bash
# report-worker: builds nightly reports (debug logging accidentally left on)
while true; do
  ts="$(date -Is)"
  for _ in $(seq 1 2000); do
    printf '%s DEBUG report-worker heartbeat payload=%0512d\n' "$ts" 0
  done
done >> /srv/data/logs/report-worker-debug.log
EOF
chmod 0755 /usr/local/bin/report-worker

cat > /etc/systemd/system/report-worker.service <<'EOF'
[Unit]
Description=Nightly report worker
After=network.target

[Service]
User=www-data
ExecStart=/usr/local/bin/report-worker
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now report-worker.service >/dev/null 2>&1

# Wait until the volume is full.
for _ in $(seq 1 60); do
  use="$(df --output=pcent /srv/data | tail -n 1 | tr -dc '0-9')"
  [ "$use" -ge 99 ] && break
  sleep 1
done
