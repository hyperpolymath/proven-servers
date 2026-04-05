#!/usr/bin/env bash
# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# deploy-fly.sh: Deploy the nesy-solver playground stack to fly.io.
#
# Deploys in dependency order (all in the same fly.io org, reachable via
# .internal 6PN DNS):
#   1. ClickHouse (clickhouse-nesy) — volume + schema migration
#   2. verisim-api (verisim-api) — HTTP API, depends on ClickHouse
#   3. echidna (echidna-nesy) — prover dispatcher, standalone
#   4. nesy-solver-api (nesy-solver-api) — public edge, depends on (2)+(3)
#
# Prereqs:
#   - flyctl auth login   (interactive browser OAuth; set FLY_API_TOKEN instead
#                          for non-interactive runs)
#   - billing card attached to the fly.io org (trial no longer applies)
#
# Run:
#   ./deploy-fly.sh [phase]
#     phase = all (default)
#           | clickhouse | schema | verisim | echidna | nesy-api
#           | secrets    (re-set VERISIM_CLICKHOUSE_URL from saved password)
#
# Idempotent: app-create, volume-create, and schema steps all skip when
# already present. Re-running `all` is safe.
#
# State files (gitignored):
#   ~/.config/nesy-solver/fly-ch-password  — random password picked for
#                                            ClickHouse. Save this; if lost
#                                            you must redeploy with a new one.

set -euo pipefail

REGION="${FLY_REGION:-lhr}"
ORG="${FLY_ORG:-personal}"
CH_APP="clickhouse-nesy"
VERISIM_APP="verisim-api"
ECHIDNA_APP="echidna-nesy"
NESY_APP="nesy-solver-api"

# Repo paths (absolute, so the script works from any cwd).
REPOS_ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
VERISIMDB="$REPOS_ROOT/verisimdb"
ECHIDNA="$REPOS_ROOT/echidna"
NESY_API="$REPOS_ROOT/proven-servers/connectors/proven-nesy-solver-api/v"

# State directory for locally-generated secrets we need to reuse.
STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nesy-solver"
CH_PW_FILE="$STATE_DIR/fly-ch-password"

PHASE="${1:-all}"

say()  { printf "\n\033[1;34m▶ %s\033[0m\n" "$*"; }
ok()   { printf "  \033[1;32m✓\033[0m %s\n" "$*"; }
warn() { printf "  \033[1;33m!\033[0m %s\n" "$*"; }
die()  { printf "  \033[1;31m✗\033[0m %s\n" "$*" >&2; exit 1; }

ensure_app() {
  local app="$1"
  if flyctl apps list -j 2>/dev/null | grep -q "\"Name\": *\"$app\""; then
    ok "app $app exists"
  else
    say "creating app $app"
    flyctl apps create "$app" --org "$ORG"
  fi
}

ensure_volume() {
  local app="$1" name="$2" size="$3"
  if flyctl volumes list -a "$app" -j 2>/dev/null | grep -q "\"name\": *\"$name\""; then
    ok "volume $name exists on $app"
  else
    say "creating volume $name (${size}GB) on $app"
    flyctl volumes create "$name" --size "$size" --region "$REGION" -a "$app" --yes
  fi
}

# Start flyctl proxy and wait until the port is actually accepting connections
# (default 20s budget). Echoes the proxy PID on stdout on success.
wait_for_proxy() {
  local app="$1" local_port="$2" remote_port="$3"
  flyctl proxy "${local_port}:${remote_port}" -a "$app" >/tmp/fly-proxy-${app}.log 2>&1 &
  local pid=$!
  local tries=0
  while [ $tries -lt 20 ]; do
    if curl -sS --max-time 1 "http://localhost:${local_port}/ping" >/dev/null 2>&1 \
       || curl -sS --max-time 1 "http://localhost:${local_port}/" >/dev/null 2>&1; then
      echo "$pid"
      return 0
    fi
    sleep 1
    tries=$((tries + 1))
  done
  kill "$pid" 2>/dev/null || true
  die "flyctl proxy to $app:$remote_port did not come up in 20s (see /tmp/fly-proxy-${app}.log)"
}

load_or_pick_ch_password() {
  mkdir -p "$STATE_DIR"
  chmod 700 "$STATE_DIR"
  if [ -f "$CH_PW_FILE" ]; then
    cat "$CH_PW_FILE"
  else
    local pw
    pw="$(openssl rand -hex 24)"
    echo "$pw" > "$CH_PW_FILE"
    chmod 600 "$CH_PW_FILE"
    echo "$pw"
  fi
}

deploy_clickhouse() {
  say "=== Phase 1: ClickHouse ==="
  ensure_app "$CH_APP"
  ensure_volume "$CH_APP" clickhouse_data 1

  local pw
  pw="$(load_or_pick_ch_password)"
  flyctl secrets set CLICKHOUSE_PASSWORD="$pw" -a "$CH_APP" --stage >/dev/null 2>&1 \
    || warn "CLICKHOUSE_PASSWORD already set or stage failed"
  ok "password saved to $CH_PW_FILE"

  cd "$VERISIMDB"
  flyctl deploy -a "$CH_APP" -c clickhouse.fly.toml --remote-only
  ok "clickhouse deployed"
}

apply_schema() {
  say "=== Phase 1b: Apply ClickHouse schema ==="
  cd "$VERISIMDB"
  local pw
  pw="$(load_or_pick_ch_password)"

  local proxy_pid
  proxy_pid=$(wait_for_proxy "$CH_APP" 18123 8123)
  ok "proxy up on localhost:18123"
  # shellcheck disable=SC2064
  trap "kill $proxy_pid 2>/dev/null || true" EXIT

  # ClickHouse HTTP rejects multi-statement bodies by default. Split the
  # schema file on semicolons and POST each statement separately.
  local tmpdir
  tmpdir=$(mktemp -d)
  csplit -z -s -f "$tmpdir/stmt-" -b '%02d.sql' \
    deploy/nesy-playground-schema.sql '/;$/+1' '{*}' || true
  local applied=0
  for f in "$tmpdir"/stmt-*.sql; do
    local stmt
    stmt=$(sed 's/^--.*$//' "$f" | tr '\n' ' ' | sed -E 's/;\s*$//' | sed -E 's/^\s+//;s/\s+$//')
    if [ -n "$stmt" ]; then
      curl -sSf -u "verisim:$pw" 'http://localhost:18123/' --data-binary "$stmt" >/dev/null
      applied=$((applied + 1))
    fi
  done
  rm -rf "$tmpdir"

  kill "$proxy_pid" 2>/dev/null || true
  trap - EXIT
  ok "schema applied ($applied statements)"
}

deploy_verisim() {
  say "=== Phase 2: verisim-api ==="
  ensure_app "$VERISIM_APP"
  # Now that the app exists, wire the ClickHouse connection URL.
  local pw
  pw="$(load_or_pick_ch_password)"
  # NB: URL has NO path suffix — verisim-api issues queries against fully-
  # qualified table names (`INSERT INTO verisimdb.proof_attempts ...`), so
  # the base URL must not include `/verisimdb`.
  flyctl secrets set \
    VERISIM_CLICKHOUSE_URL="http://verisim:${pw}@${CH_APP}.internal:8123" \
    VERISIM_GRPC_PORT="0" \
    -a "$VERISIM_APP" --stage >/dev/null
  ok "verisim-api secrets staged"

  cd "$VERISIMDB"
  flyctl deploy -a "$VERISIM_APP" -c fly.toml --dockerfile Containerfile.api --remote-only
  ok "verisim-api deployed"
}

deploy_echidna() {
  say "=== Phase 3: echidna ==="
  ensure_app "$ECHIDNA_APP"
  cd "$ECHIDNA"
  flyctl deploy -a "$ECHIDNA_APP" -c fly.toml \
    --dockerfile .containerization/Containerfile.full --remote-only
  ok "echidna deployed"
}

deploy_nesy_api() {
  say "=== Phase 4: nesy-solver-api ==="
  ensure_app "$NESY_APP"
  cd "$NESY_API"
  flyctl deploy -a "$NESY_APP" -c fly.toml --dockerfile Containerfile --remote-only
  ok "nesy-solver-api deployed"
  local hostname="https://${NESY_APP}.fly.dev"
  ok "public URL: $hostname"
  # Warm the machine so the health probe succeeds.
  curl -sS --max-time 10 "$hostname/health" >/dev/null || true
}

set_secrets_only() {
  say "=== Re-setting secrets from saved state ==="
  local pw
  pw="$(load_or_pick_ch_password)"
  flyctl secrets set \
    VERISIM_CLICKHOUSE_URL="http://verisim:${pw}@${CH_APP}.internal:8123" \
    VERISIM_GRPC_PORT="0" \
    -a "$VERISIM_APP" >/dev/null
  ok "verisim-api secrets updated (machine will restart)"
}

main() {
  if ! command -v flyctl >/dev/null 2>&1; then
    die "flyctl not in PATH — add: export PATH=\"\$HOME/.fly/bin:\$PATH\""
  fi
  if ! flyctl auth whoami >/dev/null 2>&1; then
    die "not authenticated — run: flyctl auth login"
  fi

  case "$PHASE" in
    clickhouse) deploy_clickhouse ;;
    schema)     apply_schema ;;
    verisim)    deploy_verisim ;;
    echidna)    deploy_echidna ;;
    nesy-api)   deploy_nesy_api ;;
    secrets)    set_secrets_only ;;
    all)
      deploy_clickhouse
      apply_schema
      deploy_verisim
      deploy_echidna
      deploy_nesy_api
      say "=== Deploy complete ==="
      ok "public URL: https://${NESY_APP}.fly.dev"
      ok "ClickHouse password: $CH_PW_FILE"
      ;;
    *)
      echo "usage: $0 [all|clickhouse|schema|verisim|echidna|nesy-api|secrets]"
      exit 1
      ;;
  esac
}

main "$@"
